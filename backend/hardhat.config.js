require('dotenv').config({ path: __dirname + '/.env' });
require('@nomicfoundation/hardhat-toolbox');

const { SEPOLIA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;
const isValidPrivateKey = (key) => /^0x[0-9a-fA-F]{64}$/.test((key || '').trim());
const hasSepolia = isValidPrivateKey(PRIVATE_KEY) && (SEPOLIA_RPC_URL || '').startsWith('http');

const networks = {
  hardhat: {},
  localhost: {
    url: 'http://127.0.0.1:8545',
  },
};

if (hasSepolia) {
  networks.sepolia = {
    url: SEPOLIA_RPC_URL,
    accounts: [PRIVATE_KEY],
  };
}

module.exports = {
  solidity: '0.8.20',
  defaultNetwork: 'hardhat',
  paths: {
    sources: './contracts',
    artifacts: './artifacts',
    cache: './cache',
    scripts: './scripts',
  },
  networks,
  etherscan: {
    apiKey: ETHERSCAN_API_KEY || '',
  },
};
