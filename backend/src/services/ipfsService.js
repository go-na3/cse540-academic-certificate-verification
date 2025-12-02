const fs = require('fs');
const path = require('path');
const pinataSDK = require('@pinata/sdk');

const { PINATA_JWT, PINATA_GATEWAY_URL } = process.env;

if (!PINATA_JWT) {
  console.warn('PINATA_JWT missing. IPFS uploads will fail until configured.');
}

const pinata = PINATA_JWT ? pinataSDK({ pinataJWTKey: PINATA_JWT }) : null;
const gatewayBase = PINATA_GATEWAY_URL || 'https://gateway.pinata.cloud/ipfs/';

async function uploadFile(filePath, metadata = {}) {
  if (!pinata) throw new Error('Pinata client not initialized. Set PINATA_JWT in env.');
  const source = fs.createReadStream(filePath);
  const options = { pinataMetadata: { name: path.basename(filePath), keyvalues: metadata } };
  const result = await pinata.pinFileToIPFS(source, options);
  return { cid: result.IpfsHash, url: `${gatewayBase}${result.IpfsHash}` };
}

async function uploadBuffer(buffer, fileName = 'certificate.pdf', metadata = {}) {
  if (!pinata) throw new Error('Pinata client not initialized. Set PINATA_JWT in env.');
  // Pinata SDK requires a readable stream; create a temp file to keep things simple.
  const tempPath = path.join(process.cwd(), `.tmp-${Date.now()}-${fileName}`);
  fs.writeFileSync(tempPath, buffer);
  try {
    return await uploadFile(tempPath, metadata);
  } finally {
    fs.unlink(tempPath, () => {});
  }
}

module.exports = {
  uploadFile,
  uploadBuffer,
};
