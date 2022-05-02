//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

interface IFastswapRouter {
    function factory() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForTokens(
        uint putAmount,
        uint takeAmountMin,
        address token0,
        address token1,
        address to,
        uint deadline
    ) external returns (uint takeAmount);
}
