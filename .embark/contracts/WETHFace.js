import web3 from 'Embark/web3';
import EmbarkJS from 'Embark/EmbarkJS';
let WETHFaceJSONConfig = {"contract_name":{"className":"WETHFace","args":[],"code":"","runtimeBytecode":"","realRuntimeBytecode":"","swarmHash":"","gasEstimates":null,"functionHashes":{"deposit()":"d0e30db0","withdraw(uint256)":"2e1a7d4d"},"abiDefinition":[{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"}],"filename":"main.sol","gas":"auto","gasPrice":100,"type":"file","deploy":false},"code":"","runtime_bytecode":"","real_runtime_bytecode":"","swarm_hash":"","gas_estimates":null,"function_hashes":{"deposit()":"d0e30db0","withdraw(uint256)":"2e1a7d4d"},"abi":[{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"deposit","outputs":[],"payable":true,"stateMutability":"payable","type":"function"}]};
let WETHFace = new EmbarkJS.Contract(WETHFaceJSONConfig);

__embarkContext.execWhenReady(function() {

WETHFace.setProvider(web3.currentProvider);

WETHFace.options.from = web3.eth.defaultAccount;

});
export default WETHFace;
