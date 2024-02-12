const hre = require("hardhat");
const fs = require('fs');

async function main() {
  // Get the contract factory
  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  
  // Replace this with the actual address you want to pass as an argument
  const marketplaceAddress = "address"; 
  
  // Deploy the contract with the provided constructor argument
  const nftMarketplace = await NFTMarketplace.deploy(marketplaceAddress);

  // Wait for the contract to be deployed
  await nftMarketplace.deployed();

  // Log the deployed contract address
  console.log("NFTMarketplace deployed to:", nftMarketplace.address);

  // Write the contract address to a config file
  fs.writeFileSync('./config.js', `
  export const marketplaceAddress = "${nftMarketplace.address}"
  `);
}

// Run the main function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
