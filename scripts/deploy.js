
const fs = require('fs')

async function main() {

    //deploy
    await deployContracts();

    // await deploySpecificContract("./artifacts/contracts/FastswapPair.sol/FastswapPair.json");
    // const [wallet] = await ethers.getSigners();
    // let FastswapFactory = "./artifacts/contracts/FastswapFactory.sol/FastswapFactory.json";
    // let factory_address = await deployOnChain(FastswapFactory, wallet);

    // let FastswapRouter = "./artifacts/contracts/FastswapRouter.sol/FastswapRouter.json";
    // await deployOnChain(FastswapRouter, wallet, '0x5FbDB2315678afecb367f032d93F642f64180aa3');

}


/**
 * deployContracts
 */
async function deploySpecificContract(contractPath) {
    console.log('\n' + "contract deploy started....");

    const [wallet] = await ethers.getSigners();
    console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>the wallet address is: " + wallet.address);

    let contract_address = await deployOnChain(contractPath, wallet);

}

/**
 * deployContracts
 */
async function deployContracts() {
    console.log('\n' + "contract deploy started....");

    const [wallet] = await ethers.getSigners();
    console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>the wallet address is: " + wallet.address);

    let FastswapFactory = "./artifacts/contracts/FastswapFactory.sol/FastswapFactory.json";
    let factory_address = await deployOnChain(FastswapFactory, wallet);

    let FastswapRouter = "./artifacts/contracts/FastswapRouter.sol/FastswapRouter.json";
    await deployOnChain(FastswapRouter, wallet, factory_address);
    console.log('\n' + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Factory&Router deploy complate");


    let contractList = [];
    // contractList.push("./artifacts/contracts/FastswapLibrary.sol/FastswapLibrary.json");
    // contractList.push("./artifacts/contracts/FastswapPair.sol/FastswapPair.json");
    // contractList.push("./artifacts/contracts/interfaces/IERC20.sol/IERC20.json");
    // contractList.push("./artifacts/contracts/interfaces/IFastswapCallee.sol/IFastswapCallee.json");
    // contractList.push("./artifacts/contracts/interfaces/IFastswapFactory.sol/IFastswapFactory.json");
    // contractList.push("./artifacts/contracts/interfaces/IFastswapPair.sol/IFastswapPair.json");
    // contractList.push("./artifacts/contracts/interfaces/IFastswapRouter.sol/IFastswapRouter.json");
    // contractList.push("./artifacts/contracts/libraries/Math.sol/Math.json");
    // contractList.push("./artifacts/contracts/libraries/SafeMath.sol/SafeMath.json");
    // contractList.push("./artifacts/contracts/libraries/TransferHelper.sol/TransferHelper.json");
    // contractList.push("./artifacts/contracts/libraries/UQ112x112.sol/UQ112x112.json");
    contractList.push("./artifacts/contracts/TokenA.sol/TokenA.json");
    contractList.push("./artifacts/contracts/TokenB.sol/TokenB.json");

    for (let i = 0; i < contractList.length; i++) {
        await deployOnChain(contractList[i], wallet);
    }


    console.log('\n' + ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>all contract are deployed");

}

/**
 * Deploy a contract on the chain
 * 
 * @param {string} contractPath 
 * @param {Wallet} wallet 
 */
async function deployOnChain(contractPath, wallet, deployParam) {
    if (contractPath === undefined) {
        console.log("contractPath is null");
        return;
    }
    let jsonStr = fs.readFileSync(contractPath);
    let jsonInfo = JSON.parse(jsonStr);
    let abi = jsonInfo.abi;
    let bytecode = jsonInfo.bytecode;
    let contractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
    let contract = new Object();

    if (deployParam === undefined) {
        contract = await contractFactory.deploy();
    } else {
        contract = await contractFactory.deploy(deployParam);
    }
    console.log('\n' + "contractAddress of " + contractPath.split('sol')[1].split('.')[0] + " is");
    console.log(contract.address);
    return contract.address
}


main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
