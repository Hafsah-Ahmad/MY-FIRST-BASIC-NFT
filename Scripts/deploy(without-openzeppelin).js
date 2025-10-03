const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const balance = await deployer.getBalance();
  console.log("Account balance:", hre.ethers.formatEther(balance));

  // Deploy contract
  const NFT = await hre.ethers.getContractFactory("HafsaNFT");
  const nft = await NFT.deploy();

  await nft.waitForDeployment();

  console.log("NFT contract deployed to:", await nft.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
