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

  const RibbonHat = await hre.ethers.getContractFactory("RibbonHat");
  const rhatNft = await RibbonHat.deploy(
    "0x4f0fe57066ab1c84569dc6dd2edfe08b92f97f33",
    "0xfb2ce50c4c8024e037e6be52dd658e2be23d93db",
    "https://gateway.pinata.cloud/ipfs/QmZsEQHMFadB6kmDKKjPDRab9N7qDZL45AAVam22hCbCRj",
    ["0x1668c9725e27Bf5943bBD43886E1Fb5AFe75c46C", "0x71a15Ac12ee91BF7c83D08506f3a3588143898B5"],
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
