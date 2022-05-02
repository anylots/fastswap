//SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.7.0;

import "./interfaces/IFastswapFactory.sol";
import "./libraries/TransferHelper.sol";
import "./interfaces/IFastswapRouter.sol";
import "./FastswapLibrary.sol";
import "./libraries/SafeMath.sol";

contract FastswapRouter is IFastswapRouter {
    using SafeMath for uint256;

    address public immutable override factory;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "FastswapRouter: EXPIRED");
        _;
    }

    constructor(address _factory) {
        factory = _factory;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (IFastswapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IFastswapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = FastswapLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = FastswapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "FastswapRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = FastswapLibrary.quote( amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "FastswapRouter: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = FastswapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        IFastswapPair(pair).mint(to);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = FastswapLibrary.pairFor(factory, tokenA, tokenB);
        IFastswapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IFastswapPair(pair).burn(to);
        (address token0, ) = FastswapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "FastswapRouter: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "FastswapRouter: INSUFFICIENT_B_AMOUNT"
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256 takeAmount,
        address tokenA,
        address tokenB,
        address to
    ) internal virtual {
        (address token0, ) = FastswapLibrary.sortTokens(tokenA, tokenB);
        (uint256 amount0Out, uint256 amount1Out) = tokenA == token0
            ? (uint256(0), takeAmount)
            : (takeAmount, uint256(0));
        IFastswapPair(FastswapLibrary.pairFor(factory, tokenA, tokenB)).swap(
            amount0Out,
            amount1Out,
            to,
            new bytes(0)
        );
    }

    function swapExactTokensForTokens(
        uint256 putAmount,
        uint256 takeAmountMin,
        address token0,
        address token1,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256 takeAmount) {
        takeAmount = FastswapLibrary.getAmountTake(
            factory,
            putAmount,
            token0,
            token1
        );
        require(
            takeAmount >= takeAmountMin,
            "FastswapRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            token0,
            msg.sender,
            FastswapLibrary.pairFor(factory, token0, token1),
            putAmount
        );
        _swap(takeAmount, token0, token1, to);
    }
}
