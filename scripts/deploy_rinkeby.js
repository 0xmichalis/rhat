// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const RibbonHatToken = await hre.ethers.getContractFactory("RibbonHatToken");
  // Replace with your own beneficiary
  const rhatErc20 = await RibbonHatToken.deploy("TestRHAT", "TRHAT", 64, "0xBdC85027BCDBe20B3430523a773bf3008888FA9d");
  await rhatErc20.deployed();
  console.log("rhatErc20 deployed to:", rhatErc20.address);

  const RibbonHat = await hre.ethers.getContractFactory("RibbonHat");
  const rhatNft = await RibbonHat.deploy(
    rhatErc20.address,
    "https://gateway.pinata.cloud/ipfs/QmZsEQHMFadB6kmDKKjPDRab9N7qDZL45AAVam22hCbCRj",
    ["0xdb480965AbE4CC4524B325AdB81C051F55efAB4A", "0x1668c9725e27Bf5943bBD43886E1Fb5AFe75c46C"],
  );
  await rhatNft.deployed();
  console.log("rhatNft deployed to:", rhatNft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
