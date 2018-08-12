module.exports = {
  // default applies to all enviroments
  default: {
    // rpc to deploy the contracts
    deployment: {
      host: "localhost",
      port: 8545,
      type: "rpc"
    },
    // order of connections the dapp should connect to
    dappConnection: [
      "$WEB3",  // uses pre existing web3 object if available (e.g in Mist)
      "ws://localhost:8546",
      "http://localhost:8545"
    ],
    contracts: {
      DTwitter: {
        args: [ ]
      }
    },
    gas: "auto",
    gasLimit: 9000000,
    gasPrice: 100
  },
  testnet: {
    deployment:{
      // accounts: [
      //   {
      //     "mnemonic": "wave pigeon sustain sock boring monitor left sight hedgehog weapon champion session",
      //     "addressIndex": "0", // Optional. The index to start getting the address
      //     "numAddresses": "2", // Optional. The number of addresses to get
      //     "hdpath": "m/44'/60'/0'/0/" // Optional. HD derivation path
      //   }
      // ],
      accounts: [
        {
          "mnemonic": "indicate high slight census shift bread salute noodle mobile unable three smoke",
          "addressIndex": "0", // Optional. The index to start getting the address
          "numAddresses": "2", // Optional. The number of addresses to get
          "hdpath": "m/44'/60'/0'/0/" // Optional. HD derivation path
        }
      ],
      contracts: {
        InternalCDP: {
          "Currency": {
            "deploy": true,
            "from": '0x99d9b44655702dfa54853c80dea7d73699d8f35f',
            "args": [
              100
            ]
          }
        },
        CentralCDP: {
          "Currency": {
            "deploy": true,
            "from": '0x99d9b44655702dfa54853c80dea7d73699d8f35f',
            "args": [
              100
            ]
          }
        }
      },
      gasLimit: 30000000,
      gasPrice: 91200,
      host: "https://ropsten.infura.io/v3/f702fde988c34ef3bf109793f35bbbdd",
      port: false,
      protocol: 'https',
      type: "rpc"
    }
  }
}
