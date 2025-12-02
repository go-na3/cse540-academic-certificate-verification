require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { ethers } = require('ethers');

const ETH_PROVIDER_URL = process.env.ETH_PROVIDER_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;
const CONTRACT_ABI_PATH = process.env.CONTRACT_ABI_PATH || path.resolve(__dirname, '../../artifacts/contracts/CertificateRegistry.sol/CertificateRegistry.json');

let provider = null;
let signer = null;

if (ETH_PROVIDER_URL) {
  provider = new ethers.JsonRpcProvider(ETH_PROVIDER_URL);
}

if (PRIVATE_KEY) {
  signer = provider ? new ethers.Wallet(PRIVATE_KEY, provider) : new ethers.Wallet(PRIVATE_KEY);
}

function loadAbi(abiPath) {
  try {
    const raw = fs.readFileSync(abiPath, 'utf8');
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed)) return parsed;
    if (parsed.abi && Array.isArray(parsed.abi)) return parsed.abi;
    throw new Error('ABI array not found in JSON');
  } catch (err) {
    throw new Error(`Unable to load ABI from ${abiPath}: ${err.message}`);
  }
}

let abi = null;
try {
  if (fs.existsSync(CONTRACT_ABI_PATH)) {
    abi = loadAbi(CONTRACT_ABI_PATH);
  }
} catch (e) {
  abi = null;
}

function getContract(address = CONTRACT_ADDRESS) {
  if (!abi) throw new Error('Contract ABI not loaded. Set CONTRACT_ABI_PATH to a valid ABI JSON file.');
  if (!address) throw new Error('Contract address not provided. Set CONTRACT_ADDRESS env var or pass address explicitly.');
  // prefer signer for write operations, fallback to provider for reads
  const actor = signer || provider;
  if (!actor) throw new Error('Neither provider nor signer configured. Set ETH_PROVIDER_URL and/or PRIVATE_KEY in env.');
  return new ethers.Contract(address, abi, actor);
}

module.exports = {
  provider,
  signer,
  getContract,
  loadAbi,
};
