//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./interfaces/IFastswapFactory.sol";
import "./FastswapPair.sol";
import "./libraries/console.sol";


contract FastswapFactory is IFastswapFactory {
    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function createPair(address tokenA, address tokenB)
        external
        override
        returns (address pair)
    {
        require(tokenA != tokenB, "Fastswap: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Fastswap: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "Fastswap: PAIR_EXISTS"
        ); // single check is sufficient
        bytes memory bytecode = type(FastswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IFastswapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);

        console.log("FastswapFactory_pairFor %s", toString(abi.encodePacked(pair)));
        return pair;
    }

    function getInitHash() public pure returns (bytes32) {
        bytes memory bytecode = type(FastswapPair).creationCode;
        return keccak256(abi.encodePacked(bytecode));
    }

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
