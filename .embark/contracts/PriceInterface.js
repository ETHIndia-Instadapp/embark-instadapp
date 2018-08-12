import web3 from 'Embark/web3';
import EmbarkJS from 'Embark/EmbarkJS';
let PriceInterfaceJSONConfig = {"contract_name":{"className":"PriceInterface","args":[],"code":"","runtimeBytecode":"","realRuntimeBytecode":"","swarmHash":"","gasEstimates":null,"functionHashes":{"peek()":"59e02dd7"},"abiDefinition":[{"constant":true,"inputs":[],"name":"peek","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"}],"filename":"main.sol","gas":"auto","gasPrice":100,"type":"file","deploy":false},"code":"","runtime_bytecode":"","real_runtime_bytecode":"","swarm_hash":"","gas_estimates":null,"function_hashes":{"peek()":"59e02dd7"},"abi":[{"constant":true,"inputs":[],"name":"peek","outputs":[{"name":"","type":"bytes32"},{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"}]};
let PriceInterface = new EmbarkJS.Contract(PriceInterfaceJSONConfig);

__embarkContext.execWhenReady(function() {

PriceInterface.setProvider(web3.currentProvider);

PriceInterface.options.from = web3.eth.defaultAccount;

});
export default PriceInterface;
