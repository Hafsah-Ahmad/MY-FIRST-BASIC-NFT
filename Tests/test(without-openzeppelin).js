const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HafsaNFT", function () {
  let NFT, nft, owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    NFT = await ethers.getContractFactory("HafsasNFT");
    nft = await NFT.deploy();
    await nft.waitForDeployment();
  });

  it("Should have correct name and symbol", async () => {
    expect(await nft.name()).to.equal("Hafsa's1stNFT");
    expect(await nft.symbol()).to.equal("HAFSO");
  });

  it("Owner should be able to reserve NFTs", async () => {
    await nft.reserveNFTs();
    expect(await nft.balanceOf(owner.address)).to.equal(50);
  });

  it("Should allow minting when correct value sent", async () => {
    await nft.connect(addr1).mintNFT(2, { value: ethers.parseEther("0.06") });
    expect(await nft.balanceOf(addr1.address)).to.equal(2);
  });

  it("Should fail if not enough ETH is sent", async () => {
    await expect(
      nft.connect(addr1).mintNFT(2, { value: ethers.parseEther("0.01") })
    ).to.be.revertedWith("Not enough Ether sent");
  });

  it("Should enforce max mint per transaction", async () => {
    await expect(
      nft.connect(addr1).mintNFT(5, { value: ethers.parseEther("0.15") })
    ).to.be.revertedWith("Cannot mint more than 3 NFTs at once");
  });

  it("Owner should withdraw funds", async () => {
    await nft.connect(addr1).mintNFT(1, { value: ethers.parseEther("0.03") });

    const ownerBalanceBefore = await ethers.provider.getBalance(owner.address);

    const tx = await nft.withdraw();
    await tx.wait();

    const ownerBalanceAfter = await ethers.provider.getBalance(owner.address);
    expect(ownerBalanceAfter).to.be.gt(ownerBalanceBefore);
  });
});
