//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

interface IFastswapCallee {
    function fastswapCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
