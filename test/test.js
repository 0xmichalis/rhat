const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("RibbonHat", function () {
  it("Should allow ERC20 to ERC721 migration", async function () {
    // Deploy ERC20 contract
    const RibbonHatToken = await ethers.getContractFactory("RibbonHatToken");
    const rhatErc20 = await RibbonHatToken.deploy("TestRHAT", "TRHAT", 64, "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    await rhatErc20.deployed();

    // Deploy NFT contract
    const RibbonHat = await ethers.getContractFactory("RibbonHat");
    const rhatNft = await RibbonHat.deploy(
      rhatErc20.address,
      "ipfs://bafkreifis4mzcvhjahpjoyqep3nz5yq6dquic3lkgcubg6za6lsfjb5t4m",
      ["0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"],
    );
    await rhatNft.deployed();

    // Transfer RHAT ERC20 to an address to test wrapping
    console.log("Setting up RHAT ERC20 holder");
    await rhatErc20.increaseAllowance("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 1);
    const transferTx = await rhatErc20.transferFrom("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "0x90F79bf6EB2c4f870365E785982E1f101E93b906", 1);
    await transferTx.wait();

    const [erc20Deployer, whitelisted1, whitelisted2, rhatHolder, randy] = await ethers.getSigners();
    // First, ensure all addresses have no NFT
    expect(await rhatNft.balanceOf(erc20Deployer.address, 0)).to.equal(0);
    expect(await rhatNft.balanceOf(whitelisted1.address, 0)).to.equal(0);
    expect(await rhatNft.balanceOf(whitelisted2.address, 0)).to.equal(0);
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(0);

    // mint for whitelisted accounts
    console.log("Minting for whitelisted accounts");
    await rhatNft.connect(whitelisted1).mint();
    expect(await rhatNft.balanceOf(whitelisted1.address, 0)).to.equal(1);
    await rhatNft.connect(whitelisted2).mint();
    expect(await rhatNft.balanceOf(whitelisted2.address, 0)).to.equal(1);

    // Calling mint a second time should not generate a new NFT for a whitelisted addy
    // TODO: Figure out a different way to expect failure via chai
    try { await rhatNft.connect(whitelisted1).mint(); } catch {}
    expect(await rhatNft.balanceOf(whitelisted1.address, 0)).to.equal(1);

    // Test mint for ERC20 holder
    console.log("Minting for RHAT ERC20 holder");
    await rhatErc20.connect(rhatHolder).increaseAllowance(rhatNft.address, 1);
    await rhatNft.connect(rhatHolder).mint();
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(1);

    // Calling mint a second time should not generate a new NFT
    try { await rhatNft.connect(rhatHolder).mint(); } catch {}
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(1);

    // whitelist addition test
    console.log("Adding to whitelist");
    try { await rhatNft.connect(randy).mint(); } catch {}
    expect(await rhatNft.balanceOf(randy.address, 0)).to.equal(0);
    await rhatNft.connect(erc20Deployer).addToWhitelist(randy.address);
    await rhatNft.connect(randy).mint();
    expect(await rhatNft.balanceOf(randy.address, 0)).to.equal(1);
    try { await rhatNft.connect(randy).mint(); } catch {}
    expect(await rhatNft.balanceOf(randy.address, 0)).to.equal(1);
  });
});
