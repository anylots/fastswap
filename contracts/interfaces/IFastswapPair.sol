//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

interface IFastswapPair{

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function initialize(address, address) external;
}
