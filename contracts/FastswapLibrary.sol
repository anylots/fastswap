//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./interfaces/IFastswapPair.sol";
import './libraries/SafeMath.sol';

import "./libraries/console.sol";


library FastswapLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'FastswapLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'FastswapLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'd1759038614a19ae87b1f1ff5f556aa0f99043936d233558ef80002b0f289875' // init code hash
            ))));   
        console.log("FastswapLibrary_pairFor %s", toString(abi.encodePacked(pair)));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IFastswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'FastswapLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'FastswapLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountTake(address factory, uint putAmount, address tokenA, address tokenB) internal view returns (uint takeAmount) {
        require(putAmount > 0, 'FastswapLibrary: INSUFFICIENT_INPUT_AMOUNT');
        (uint reservePut, uint reserveTake) = getReserves(factory, tokenA, tokenB);   
        require(reservePut > 0 && reserveTake > 0, 'FastswapLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = putAmount.mul(997);
        uint numerator = amountInWithFee.mul(reserveTake);
        uint denominator = reservePut.mul(1000).add(amountInWithFee);
        takeAmount = numerator / denominator;
    }

    // performs chained getAmountOut calculations on any number of pairs
    // function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
    //     require(path.length >= 2, 'FastswapLibrary: INVALID_PATH');
    //     amounts = new uint[](path.length);
    //     amounts[0] = amountIn;
    //     for (uint i; i < path.length - 1; i++) {
    //         (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
    //         amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    //     }
    // }

    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

}
