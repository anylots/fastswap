const { expect } = require("chai");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    const [owner] = await ethers.getSigners();

    const FastswapLibrary = await ethers.getContractFactory("FastswapLibrary");

    const fastswapLibrary = await FastswapLibrary.deploy();
    await fastswapLibrary.deployed();

    const hash = await fastswapLibrary.getInitHash();
    console.log(hash);
});
});
