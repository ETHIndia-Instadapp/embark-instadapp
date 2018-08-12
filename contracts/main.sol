pragma solidity ^0.4.24;

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// @authors Sowmay Jain, Samyak Jain & Satish Nampally

interface token {
    function transfer(address receiver, uint amount) external returns(bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
}

// Interface for functions of MakerDAO CDP
interface MakerCDP {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; // Join PETH
    function exit(uint wad) external; // Exit PETH
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function shut(bytes32 cup) external;
    function bite(bytes32 cup) external;
}

// Interface retrives the ETH prices from MakerDAO price feeds
interface PriceInterface {
    function peek() public view returns (bytes32, bool);
}

interface WETHFace {
    function deposit() external payable;
    function withdraw(uint wad) external;
}

// Contract to manage the global cdp stats and 
// user individual exposure, contract also initalises the 
// MakerDAO contracts to that will be used to setup
// CDP and manage.
contract DeclaredVar {

    address public WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c;
    address public PETH = 0xf4d791139ce033ad35db2b2201435fad668b1b64;
    address public MKR = 0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd;
    address public DAI = 0xc4375b7de8af5a38a93548eb8453a498222c4ff2;

    address public onChainPrice = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;

    address public CDPAddr = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;
    MakerCDP DAILoanMaster = MakerCDP(CDPAddr);

    // for calculating the loan percentage to users
    uint public GlobalLocked; // Total ETH Locked
    uint public GlobalWithdraw; // Total DAI Withdrawn

    struct Loan {
        uint Collateral; // locked ETH
        uint Withdrawn; // withdrawn DAI
        uint EtherPrice; // average ether price at which the loan is issued
    }

    mapping (address => Loan) public Loans; // borrower >>> loan
    bytes32 public CDPByteCode;

}

// Contract that overrides the MakerDAO functions
// that acts like bridge and agreegate the transaction 
// to open and manage CDP
contract IssueLoan is DeclaredVar {

    function openCDP() internal {
        CDPByteCode = DAILoanMaster.open();
    }

    // ETH to WETH
    function ETH_WETH(uint weiAmt) internal {
        WETHFace wethFunction = WETHFace(WETH);
        wethFunction.deposit.value(weiAmt)();
    }

    // WETH to PETH
    // WETH to PETH conversion will not be always same = give more WETH and get less PETH
    function WETH_PETH(uint weiAmt) internal {
        // factor the conversion rate between PETH & WETH
        DAILoanMaster.join(weiAmt);
    }

    // Lock PETH in CDP Contract
    function PETH_CDP(uint weiAmt) internal {
        DAILoanMaster.lock(CDPByteCode, weiAmt);
    }

    // getting ether price from where MakerDAO take price feeds
    function getETHprice() public view returns (uint ethprice) {
        PriceInterface ethPrice = PriceInterface(onChainPrice); // https://conteract.io/c/6Cd6544A04
        bytes32 priceByte;
        (priceByte, ) = ethPrice.peek();
        uint priceNum = uint(priceByte) / 10**18;
        return priceNum;
    }

    // allowing WETH, PETH, MKR, DAI // called in the constructor
    function ApproveERC20() internal {
        token WETHtkn = token(WETH);
        WETHtkn.approve(CDPAddr, 2**256 - 1);
        token PETHtkn = token(PETH);
        PETHtkn.approve(CDPAddr, 2**256 - 1);
        token MKRtkn = token(MKR);
        MKRtkn.approve(CDPAddr, 2**256 - 1);
        token DAItkn = token(DAI);
        DAItkn.approve(CDPAddr, 2**256 - 1);
    }

}

// Contract uses the IssueLoan contract and this is actual functions 
// that are going to be consumed by Dapps to simplify the Loan CDP
// all the 12 transaction are managed and aggregrated into one single function
contract CentralCDP is IssueLoan {

    // Send Ether to contract address to lock ether
    // Convert ETH -> WETH, WETH -> PETH and PETH -> CDP
    // once the CDP is approved, calling intiateWithdraw to draw
    // dai from CDP and transfer to user wallet
    function InitiateLoan(uint daiAmt) public payable {
        // interchanging required tokens
        if (msg.value != 0) {
            ETH_WETH(msg.value);
            WETH_PETH(msg.value);
            PETH_CDP(msg.value);
        }

        Loan storage l = Loans[msg.sender];
        GlobalLocked += msg.value;
        l.Collateral += msg.value;

        if (daiAmt != 0) {
            InitiateWithdraw(daiAmt);
        }

    }

    // Withdraw DAI from CDP
    // implmentation from drawing Dai from CDP and transfer to 
    // user wallet
    function InitiateWithdraw(uint daiAmt) internal {
        Loan storage l = Loans[msg.sender];

        // DAI check
        uint lockedETH = l.Collateral;
        uint getPrice = getETHprice();
        uint availableDAI = (lockedETH * getPrice / 2) - l.Withdrawn;
        require(availableDAI > daiAmt, "You can't withdraw more than 50% dollar price of ether.");

        // draw DAI
        DAILoanMaster.draw(CDPByteCode, daiAmt);

        // transfer DAI
        token tokenFunctions = token(DAI);
        tokenFunctions.transfer(msg.sender, daiAmt);

        // set new ether price of borrower
        l.EtherPrice = (l.EtherPrice*l.Withdrawn + getPrice*daiAmt) / (l.Withdrawn + daiAmt);

        // storing local variables
        GlobalWithdraw += daiAmt;
        l.Withdrawn += daiAmt;
    }

    // function to Free the ETH by repaying Dai
    function getETHtoFree(uint daitoWipe) public view returns (uint ETHtoFree) {
        Loan memory l = Loans[msg.sender];
        require(daitoWipe <= l.Withdrawn, "You're paying more than what you've taken.");
        ETHtoFree = (daitoWipe * l.Collateral) / l.Withdrawn;
    }

    // Provide allowance before you access the DAI
    // reapying the loan / Dai to CDP to free the locked ETH
    function RepayBack(uint daitoWipe, bool wethbool) public {
        uint unlocketh = getETHtoFree(daitoWipe);
        token tokenFunction = token(DAI);
        tokenFunction.transferFrom(msg.sender, address(this), daitoWipe);
        DAILoanMaster.wipe(CDPByteCode, daitoWipe);
        DAILoanMaster.free(CDPByteCode, unlocketh);
        DAILoanMaster.exit(unlocketh);

        if (wethbool) {
            token tokenFunctions = token(WETH);
            tokenFunctions.transfer(msg.sender, unlocketh);
        }

        Loan storage l = Loans[msg.sender];
        GlobalLocked -= unlocketh;
        l.Collateral -= unlocketh;
        GlobalWithdraw -= daitoWipe;
        l.Withdrawn -= daitoWipe;
    }

}

// Giving CDP approval to WETH, PETH, MKR, DAI and opening the CDP
// ownersdhip of this CDP will be this contract and all user will
// interact with our Dapp
contract CDPResolver is CentralCDP {
    constructor() public {
        ApproveERC20();
        openCDP();
    }
}