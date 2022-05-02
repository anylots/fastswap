//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./libraries/console.sol";
import "./interfaces/IERC20.sol";
import "./libraries/SafeMath.sol";

// This is the main building block for smart contracts.
contract FastswapERC20 {
    using SafeMath for uint256;

    // Some string type variables to identify the token.
    string public name = "FAST";
    string public symbol = "FAST";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     *
     * The `constructor` is executed only once when the contract is created.
     * The `public` modifier makes a function callable from outside the contract.
     */
    constructor() {
        // The totalSupply is assigned to transaction sender, which is the account
        // that is deploying the contract.
        balanceOf[msg.sender] = totalSupply;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    )internal {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }
}
