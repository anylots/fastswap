//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./interfaces/IFastswapPair.sol";
import './interfaces/IERC20.sol';
import './libraries/Math.sol';
import './libraries/SafeMath.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IFastswapCallee.sol';
import './FastswapERC20.sol';

contract FastswapPair is FastswapERC20, IFastswapPair {

    using SafeMath  for uint;
    using UQ112x112 for uint224;
    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR =
    bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "Fastswap: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() {
        factory = msg.sender;
    }

    function getReserves() public view override returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    event Mint(address indexed sender, uint amount0, uint amount1);

    event Sync(uint112 reserve0, uint112 reserve1);


    /**
     * takeAmount0: expected amount of token0 purchase
     * takeAmount1: expected amount of token1 purchase
     * takeAdress: address of purchaser
     * data: callback data of caller contract
     */
    function swap(
        uint takeAmount0, 
        uint takeAmount1,
        address takerAdress,
        bytes calldata data
    ) external override {
        require(takeAmount0 > 0 || takeAmount1 > 0,"Fastswap: INSUFFICIENT_TAKE_AMOUNT");
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        require(takeAmount0 < _reserve0 && takeAmount0 < _reserve1,"Fastswap: INSUFFICIENT_LIQUIDITY");
        uint balance0;
        uint balance1;
        {// scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(takerAdress != _token0 && takerAdress != _token1, "Fastswap: INVALID_TAKE_ADRESS");
            if (takeAmount0 > 0) _safeTransfer(_token0, takerAdress, takeAmount0); // optimistically transfer tokens
            if (takeAmount1 > 0) _safeTransfer(_token1, takerAdress, takeAmount1); // optimistically transfer tokens
            if (data.length > 0)
            //Execute the callback function of the caller contract. 
            //This data is empty when calling ordinary transactions.
                IFastswapCallee(takerAdress).fastswapCall(
                    msg.sender,
                    takeAmount0,
                    takeAmount1,
                    data
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint putAmount0 = balance0 > _reserve0 - takeAmount0? balance0 - (_reserve0 - takeAmount0): 0;
        uint putAmount1 = balance1 > _reserve1 - takeAmount1? balance1 - (_reserve1 - takeAmount1): 0;
        require(
            putAmount0 > 0 || putAmount1 > 0,
            "Fastswap: INSUFFICIENT_PUT_AMOUNT"
        );
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(putAmount0.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(putAmount1.mul(3));
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint(_reserve0).mul(_reserve1).mul(1000**2),
                "Fastswap: K"
            );
        }

        _updateReserves(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, putAmount0, putAmount1, takeAmount0, takeAmount1, takerAdress);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock override returns (uint liquidity){
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _updateReserves(balance0, balance1, _reserve0, _reserve1);
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock override returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _updateReserves(balance0, balance1, _reserve0, _reserve1);
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Fastswap: TRANSFER_FAILED');
    }

    // update reserves and, on the first call per block, price accumulators
    function _updateReserves(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'Fastswap: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external override {
        require(msg.sender == factory, "Fastswap: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
        balanceOf[msg.sender] = 10000;
    }
}
