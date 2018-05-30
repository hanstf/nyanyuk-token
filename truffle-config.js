require('babel-register');
require('babel-polyfill');
var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic =  process.env.ropsten_mnemonic;

module.exports = {
    networks: {
        test: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "3"
        },
        ropsten: {
            provider: function() {
                return new HDWalletProvider(mnemonic, process.env.ropsten_node)
            },
            network_id: "3",
            gas: 4612388
        }
    }
};