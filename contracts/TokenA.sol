
//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./libraries/console.sol";
import "./interfaces/IERC20.sol";
import './libraries/SafeMath.sol';

// This is the main building block for smart contracts.
contract TokenA is IERC20{
    using SafeMath for uint;

    // Some string type variables to identify the token.
    string public override name = "TokenA";
    string public override symbol= "TokenA";
    uint8 public override decimals = 18;

    uint256 public override totalSupply = 100000000000;

    // An address type variable is used to store ethereum accounts.
    address public owner;

    // A mapping is a key/value map. Here we store each account balance.
    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint)) public override allowance;

    /**
     *
     * The `constructor` is executed only once when the contract is created.
     * The `public` modifier makes a function callable from outside the contract.
     */
    constructor() {
        // The totalSupply is assigned to transaction sender, which is the account
        // that is deploying the contract.
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function approve(address spender, uint value) external override returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(owner, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }
}
