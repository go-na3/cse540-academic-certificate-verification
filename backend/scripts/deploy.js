const { ethers } = require('hardhat');
require('dotenv').config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying with account:', deployer.address);

  const envAdmin = (process.env.ADMIN_ADDRESS || '').trim();
  const admin = envAdmin && ethers.isAddress(envAdmin) ? envAdmin : deployer.address;
  if (envAdmin && !ethers.isAddress(envAdmin)) {
    throw new Error(`ADMIN_ADDRESS is not a valid address: ${envAdmin}`);
  }
  console.log('Admin set to:', admin);

  const CertificateRegistry = await ethers.getContractFactory('CertificateRegistry');
  const contract = await CertificateRegistry.deploy(admin);
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log('CertificateRegistry deployed to:', address);

  const receipt = await contract.deploymentTransaction().wait();
  console.log('Gas used:', receipt.gasUsed.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
