const fs = require('fs')

const overrides = {
    gasLimit: 9999999
}

async function main() {

    //addLiquidity
    // await addLiquidity();

    // await test();
    // await getInitHash();

    await swapExactTokensForTokens();

}

async function getInitHash() {
    const [wallet] = await ethers.getSigners();
    let contractPath = "./artifacts/contracts/FastswapFactory.sol/FastswapFactory.json";
    const fastswapRouter_contract = connectContract(contractPath, "0x59b670e9fA9D0A427751Af201D676719a970857b", wallet);
    const balanceOfTokenA = await fastswapRouter_contract.getInitHash();
    console.log("getInitHash is " + balanceOfTokenA);
}

/**
 * addLiquidity
 */
async function addLiquidity() {
    console.log('\n' + "addLiquidity started....");

    const [wallet] = await ethers.getSigners();

    //approve token transfer
    let tokenAPath = "./artifacts/contracts/TokenA.sol/TokenA.json";
    const tokenA = connectContract(tokenAPath, "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853", wallet);
    await tokenA.approve("0x67d269191c92Caf3cD7723F116c85e6E9bf55933", 20000)
    console.log("tokenA_approve complated");

    let tokenBPath = "./artifacts/contracts/tokenB.sol/tokenB.json";
    const tokenB = connectContract(tokenBPath, "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6", wallet);
    await tokenB.approve("0x67d269191c92Caf3cD7723F116c85e6E9bf55933", 10000)
    console.log("tokenB_approve complated");


    let FastswapRouter = "./artifacts/contracts/FastswapRouter.sol/FastswapRouter.json";
    const fastswapRouter_contract = connectContract(FastswapRouter, "0x67d269191c92Caf3cD7723F116c85e6E9bf55933", wallet);
    await fastswapRouter_contract.addLiquidity("0xa513E6E4b8f2a923D98304ec87F64353C4D5C853", "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",
        20000, 10000, 10000, 5000,"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", ethers.constants.MaxUint256,
        overrides);
    console.log("addLiquidity complated");

    const balanceOfTokenA = await tokenA.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    console.log("balanceOfTokenA is " + balanceOfTokenA);

    const balanceOfTokenB = await tokenB.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    console.log("balanceOfTokenB is " + balanceOfTokenB);
}

async function swapExactTokensForTokens() {
    console.log('\n' + "swapExactTokensForTokens started....");

    let privateKey = "0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a";
    // Connect a wallet to localhost
    let customHttpProvider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
    let wallet = new ethers.Wallet(privateKey, customHttpProvider);

    //approve token transfer
    let tokenAPath = "./artifacts/contracts/TokenA.sol/TokenA.json";
    const tokenA = connectContract(tokenAPath, "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853", wallet);
    await tokenA.approve("0x67d269191c92Caf3cD7723F116c85e6E9bf55933", 100)
    console.log("tokenAapprove complated");

    //check balance
    const tokenA_BalanceBeforeSwap = await tokenA.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
    console.log("tokenA_BalanceBeforeSwap on account1 is " + tokenA_BalanceBeforeSwap);

    const tokenB_contract = connectContract("./artifacts/contracts/TokenB.sol/TokenB.json", "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6", wallet);
    const tokenB_BalanceBeforeSwap = await tokenB_contract.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
    console.log("tokenB_BalanceBeforeSwap on account1 is " + tokenB_BalanceBeforeSwap);


    //swap with router
    let contractPath = "./artifacts/contracts/FastswapRouter.sol/FastswapRouter.json";
    const fastswapRouter_contract = connectContract(contractPath, "0x67d269191c92Caf3cD7723F116c85e6E9bf55933", wallet);
    await fastswapRouter_contract.swapExactTokensForTokens(100, 20, "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853", "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",
        "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", ethers.constants.MaxUint256,
        overrides);
    console.log("swapExactTokensForTokens complated");

    //check balance
    const tokenA_BalanceAfterSwap = await tokenA.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
    console.log("tokenA_BalanceAfterSwap on account1 is " + tokenA_BalanceAfterSwap);

    const tokenB_BalanceAfterSwap = await tokenB_contract.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
    console.log("tokenB_BalanceAfterSwap on account1 is " + tokenB_BalanceAfterSwap);
}

async function test() {
    let privateKey = "";
    let wallet = new ethers.Wallet(privateKey);

    // Connect a wallet to mainnet
    let customHttpProvider = new ethers.providers.JsonRpcProvider("http://localhost:8545");
    let walletWithProvider = new ethers.Wallet(privateKey, customHttpProvider);

    const tokenA_contract = connectContract("./artifacts/contracts/TokenA.sol/TokenA.json", "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853", walletWithProvider);
    await tokenA_contract.transfer("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 1000);
    const balanceBeforeSwap = await tokenA_contract.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc");
    console.log("balanceBeforeSwap on account1 is " + balanceBeforeSwap);
}


/**
 * 
 * @param {string} contractPath 
 * @param {string} contractAddress 
 * @param {Wallet} wallet 
 * @returns
 */
function connectContract(contractPath, contractAddress, wallet) {
    let jsonStr = fs.readFileSync(contractPath);
    let jsonInfo = JSON.parse(jsonStr);
    let abi = jsonInfo.abi;

    let contract = new ethers.Contract(contractAddress, abi, wallet);
    console.log('\n' + contractPath.split('sol/')[1].split('.')[0] + " is connected");
    return contract;
}




main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
