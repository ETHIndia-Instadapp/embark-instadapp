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

interface token {
    function transfer(address receiver, uint amount) external returns(bool);
    function approve(address spender, uint256 value) external returns (bool);
}

interface MakerCDP {
    function open() external returns (bytes32 cup);
    function join(uint wad) external; // Join PETH
    function give(bytes32 cup, address guy) external;
    function lock(bytes32 cup, uint wad) external;
    function free(bytes32 cup, uint wad) external;
    function draw(bytes32 cup, uint wad) external;
    function wipe(bytes32 cup, uint wad) external;
    function shut(bytes32 cup) external;
    function bite(bytes32 cup) external;
}

interface PriceInterface {
    function peek() public view returns (bytes32, bool);
}

interface WETHFace {
    function deposit() external payable;
}

contract InternalCDP {

    address public WETH = 0xd0a1e359811322d97991e03f863a0c30c2cf029c;
    address public PETH = 0xf4d791139ce033ad35db2b2201435fad668b1b64;
    address public MKR = 0xaaf64bfcc32d0f15873a02163e7e500671a4ffcd;
    address public DAI = 0xc4375b7de8af5a38a93548eb8453a498222c4ff2;

    address public onChainPrice = 0xA944bd4b25C9F186A846fd5668941AA3d3B8425F;

    address public Admin;
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

    constructor() public {
        Admin = msg.sender;
        ApproveERC20();
        openCDP();
    }

    modifier onlyAdmin() {
        require(msg.sender == Admin, "Permission Denied");
        _;
    }

    bytes32 public CDPByteCode;
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

contract CentralCDP is InternalCDP {

    // Send Ether to contract address to lock ether
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

}

//// to do later
// add events (contract)
// keep 1 WETH already locked in your contract to overcome that WETH to PETH problem

//// Improvements
// instead of open CDP create CDP from individual address and give CDP
// add a give CDP option to transfer the CDP to another address
// tub.per in tub contract