module.exports = {
  development: {
    enabled: true,
    networkType: "custom",
    networkId: "1337",
    isDev: true,
    genesisBlock: "config/development/genesis.json",
    datadir: ".embark/development/datadir",
    mineWhenNeeded: true,
    nodiscover: true,
    maxpeers: 0,
    rpcHost: "localhost",
    rpcPort: 8545,
    rpcCorsDomain: "auto",
    rpcApi: ['eth', 'web3', 'net', 'debug', 'personal'],
    proxy: true,
    account: {
      password: "config/development/password",
      numAccounts: 3,
      balance: "5 ether"
    },
    targetGasLimit: 10000000000,
    wsOrigins: "auto",
    wsRPC: true,
    wsHost: "localhost",
    wsPort: 8546,
    wsApi: ['eth', 'web3', 'net', 'shh', 'debug', 'personal'],
    simulatorMnemonic: "example exile argue silk regular smile grass bomb merge arm assist farm",
    simulatorBlocktime: 0
  },
  ropsten: {
    deployment: {
      "mnemonic": "indicate high slight census shift bread salute noodle mobile unable three smoke",
      "addressIndex": "0", // Optional. The index to start getting the address
      "numAddresses": "1", // Optional. The number of addresses to get
    },
    enabled: true,
    networkType: "ropsten",
    light: true,
    host: "https://ropsten.infura.io/v3/f702fde988c34ef3bf109793f35bbbdd",
    port: false,
    protocol: 'https', // <=== must be specified for infura, can also be http, or ws
    type: "rpc",
    "contracts": {
      "address": "0xa76E1831372F835FF1176200a62D455501bd2cf4"
    }
  },
  kovan: {
    deployment: {
      "mnemonic": "indicate high slight census shift bread salute noodle mobile unable three smoke",
      "addressIndex": "0", // Optional. The index to start getting the address
      "numAddresses": "1", // Optional. The number of addresses to get
    },
    enabled: true,
    networkType: "kovan",
    light: true,
    host: "https://kovan.infura.io/v3/f702fde988c34ef3bf109793f35bbbdd",
    port: false,
    protocol: 'https', // <=== must be specified for infura, can also be http, or ws
    type: "rpc",
    "contracts": {
      "address": "0xa76E1831372F835FF1176200a62D455501bd2cf4"
    }
  },
  livenet: {
    enabled: true,
    networkType: "livenet",
    light: true,
    rpcHost: "localhost",
    rpcPort: 8545,
    rpcCorsDomain: "http://localhost:8000",
    account: {
      password: "config/livenet/password"
    }
  },
  privatenet: {
    enabled: true,
    networkType: "custom",
    rpcHost: "localhost",
    rpcPort: 8545,
    rpcCorsDomain: "http://localhost:8000",
    datadir: "yourdatadir",
    networkId: "123",
    bootnodes: ""
  }
}
