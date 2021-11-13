const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RibbonHat", function () {
  it("Should allow ERC20 to ERC721 migration", async function () {
    const [contractOwner, rhatHolder, whitelisted1, whitelisted2, governor] = await ethers.getSigners();

    // Deploy ERC20 contract
    const RibbonHatToken = await ethers.getContractFactory("RibbonHatToken");
    const rhatErc20 = await RibbonHatToken.deploy("TestRHAT", "TRHAT", 64, rhatHolder.address);
    await rhatErc20.deployed();

    // Deploy NFT contract
    const RibbonHat = await ethers.getContractFactory("RibbonHat");
    const rhatNft = await RibbonHat.deploy(
      rhatErc20.address,
      governor.address,
      "ipfs://bafkreifis4mzcvhjahpjoyqep3nz5yq6dquic3lkgcubg6za6lsfjb5t4m",
      [whitelisted1.address, whitelisted2.address],
    );
    await rhatNft.deployed();

    // First, ensure all addresses have no NFT
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(0);
    expect(await rhatNft.balanceOf(whitelisted1.address, 0)).to.equal(0);
    expect(await rhatNft.balanceOf(whitelisted2.address, 0)).to.equal(0);

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
    try { await rhatNft.connect(whitelisted2).mint(); } catch {}
    expect(await rhatNft.balanceOf(whitelisted2.address, 0)).to.equal(1);

    // Test mint for ERC20 holder
    console.log("Minting for RHAT ERC20 holder");
    await rhatErc20.connect(rhatHolder).increaseAllowance(rhatNft.address, 1);
    await rhatNft.connect(rhatHolder).mint();
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(1);

    // Calling mint a second time should not generate a new NFT
    try { await rhatNft.connect(rhatHolder).mint(); } catch {}
    expect(await rhatNft.balanceOf(rhatHolder.address, 0)).to.equal(1);

    console.log("Governor cannot mint");
    expect(await rhatNft.governor()).to.equal(governor.address);
    try { await rhatNft.connect(governor).mint(); } catch {}
    expect(await rhatNft.balanceOf(governor.address, 0)).to.equal(0);

    console.log("Contract owner cannot mint");
    expect(await rhatNft.owner()).to.equal(contractOwner.address);
    try { await rhatNft.connect(contractOwner).mint(); } catch {}
    expect(await rhatNft.balanceOf(contractOwner.address, 0)).to.equal(0);
  });
});
