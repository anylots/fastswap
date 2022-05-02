//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

interface IFastswapFactory {


    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);

}
