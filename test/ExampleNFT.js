const { expect } = require("chai");
const { ethers } = require("hardhat");

const ipfs_constant = "QmPSMCaJPLGbau4b3NwQsyntxLpicekijHPruLwztLoW4s";
const ipfs_constant_2 = "QmPSMCaJPLGbau4b3NwQsyntxLpicekijHPruLwztLoW5s";

const ERC_721_CONTRACT = "ExampleNFT";

describe("Example ERC-721", function () {
  let hardhatToken;

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();
    const Token = await ethers.getContractFactory(ERC_721_CONTRACT);
    hardhatToken = await Token.deploy("ExampleNFT", "EXN");
    await hardhatToken.deployed();
  });

  it("User must be able to create a new token", async function () {
    const [, add_one] = await ethers.getSigners();
    await hardhatToken.connect(add_one).mint(ipfs_constant);
    expect(await hardhatToken.balanceOf(add_one.address)).to.equal(1);
  });

  it("The total supply must be accurate", async function () {
    const [, add_one] = await ethers.getSigners();
    await hardhatToken.connect(add_one).mint(ipfs_constant);
    expect(await hardhatToken.totalSupply()).to.equal(1);
    await hardhatToken.connect(add_one).mint(ipfs_constant_2);
    expect(await hardhatToken.totalSupply()).to.equal(2);
  });

  it("Users must be able to transfer their tokens", async function () {
    const [, add_one, add_two] = await ethers.getSigners();
    await hardhatToken.connect(add_one).mint(ipfs_constant);
    await hardhatToken.connect(add_two).mint(ipfs_constant);
    await hardhatToken.connect(add_one).transferToken(add_two.address, 0);
    expect(await hardhatToken.balanceOf(add_one.address)).to.equal(0);
    expect(await hardhatToken.balanceOf(add_two.address)).to.equal(2);
  });

  it("Owner is able to burn tokens", async function () {
    const [owner] = await ethers.getSigners();
    await hardhatToken.connect(owner).mint(ipfs_constant);
    await hardhatToken.connect(owner).mint(ipfs_constant_2);
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(2);
    await hardhatToken.connect(owner).burn(1, owner.address);
    expect(await hardhatToken.balanceOf(owner.address)).to.equal(1);
  });

  it("Owner is able to burn all tokens", async function () {
    const [owner, add_one] = await ethers.getSigners();
    await hardhatToken.connect(add_one).mint(ipfs_constant);
    await hardhatToken.connect(add_one).mint(ipfs_constant_2);
    expect(await hardhatToken.balanceOf(add_one.address)).to.equal(2);
    await hardhatToken.connect(owner).burnAll();
    expect(await hardhatToken.balanceOf(add_one.address)).to.equal(0);
  });

  it("The contract is able to be paused ", async function () {
    const [owner] = await ethers.getSigners();
    expect(await hardhatToken.paused()).to.equal(false);
    await hardhatToken.connect(owner).pauseContract();
    expect(await hardhatToken.paused()).to.equal(true);
    await hardhatToken.connect(owner).pauseContract();
    expect(await hardhatToken.paused()).to.equal(false);
  });
});
