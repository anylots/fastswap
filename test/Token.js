const { expect } = require("chai");

describe("Token contract", function() {
  it("Deployment should assign the total supply of tokens to the owner", async function() {
    // const [owner] = await ethers.getSigners();

    // //deploy TokenA
    // const TokenA = await ethers.getContractFactory("TokenA");
    // const tokenA = await TokenA.deploy();
    // await tokenA.deployed();
    // console.log("tokenA deployed");

    // //deploy TokenB
    // const TokenB = await ethers.getContractFactory("TokenA");
    // const tokenB = await TokenB.deploy();
    // await tokenB.deployed();
    // console.log("TokenB deployed");


    // //deploy FastswapPair
    // const FastswapPair = await ethers.getContractFactory("FastswapPair");
    // const fastswapPair = await FastswapPair.deploy();
    // await fastswapPair.deployed();
    
    // console.log("FastswapPair deployed");
    // // await fastswapPair.initialize(tokenA.address,tokenB.address);
    


    // //deploy FastswapFactory
    // const FastswapFactory = await ethers.getContractFactory("FastswapFactory");
    // const fastswapFactory = await FastswapFactory.deploy();
    // await fastswapFactory.deployed();
    // console.log("FastswapFactory deployed:");
    // console.log(fastswapFactory.address);


    // //check fastswapPair ownerBalance
    // const ownerBalance = await fastswapPair.balanceOf(owner.getAddress());
    // console.log(ownerBalance);
    // // expect(10000).to.equal(ownerBalance);

    // console.log(tokenA.address);
    // // console.log(tokenA);

    // let pair = await fastswapFactory.createPair(tokenA.address,tokenB.address);
    // console.log("pair:");
    // console.log( pair);

    // // const pairBalance = await pairAdress.balanceOf(owner.getAddress());
    // // console.log(pairBalance);
    // const FastswapLibrary = await ethers.getContractFactory("FastswapLibrary");
    // const fastswapLibrary = await FastswapLibrary.deploy();
    // await fastswapLibrary.deployed();

    // // const pairBalance = await pairAdress.balanceOf(owner.getAddress());
    // // console.log(pairBalance);


    // let pairAdress = await fastswapLibrary.pairFor(fastswapFactory.address,tokenA.address,tokenB.address);
    // console.log(pairAdress);

    // let provider = ethers.getDefaultProvider();
    // let contract = new ethers.Contract(pairAdress, abi,provider);

    // let pairBalance = await contract.balanceOf(owner.getAddress());

    // console.log(pairBalance);


    const [owner] = await ethers.getSigners();

    const FastswapLibrary = await ethers.getContractFactory("FastswapLibrary");

    const fastswapLibrary = await FastswapLibrary.deploy();
    await fastswapLibrary.deployed();

    const hash = await fastswapLibrary.getInitHash();
    console.log(hash);

  });
});
