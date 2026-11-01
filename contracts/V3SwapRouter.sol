// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/libraries/SafeCast.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-periphery/contracts/libraries/Path.sol';
import '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import '@uniswap/v3-periphery/contracts/libraries/CallbackValidation.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import './interfaces/IV3SwapRouter.sol';
import './base/PeripheryPaymentsWithFeeExtended.sol';
import './base/OracleSlippage.sol';
import './libraries/Constants.sol';

/// @title Uniswap V3 兑换路由合约
/// @notice 用于在 Uniswap V3 上无状态执行兑换的路由合约
abstract contract V3SwapRouter is IV3SwapRouter, PeripheryPaymentsWithFeeExtended, OracleSlippage {
    using Path for bytes;
    using SafeCast for uint256;

    /// @dev 用作 amountInCached 的占位值，因为精确输出兑换计算出的输入数量
    /// 实际上永远不可能等于该值
    uint256 private constant DEFAULT_AMOUNT_IN_CACHED = type(uint256).max;

    /// @dev 临时存储变量，用于返回精确输出兑换中计算出的输入数量。
    uint256 private amountInCached = DEFAULT_AMOUNT_IN_CACHED;

    /// @dev 返回给定代币对和手续费对应的池子。该池子合约不一定已存在。
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (IUniswapV3Pool) {
        return IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0); // 不支持完全发生在流动性为 0 区间内的兑换
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);

        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(amount0Delta))
                : (tokenOut < tokenIn, uint256(amount1Delta));

        if (isExactInput) {
            pay(tokenIn, data.payer, msg.sender, amountToPay);
        } else {
            // 要么发起下一次兑换，要么进行支付
            if (data.path.hasMultiplePools()) {
                data.path = data.path.skipToken();
                exactOutputInternal(amountToPay, msg.sender, 0, data);
            } else {
                amountInCached = amountToPay;
                // 注意：由于精确输出兑换按逆序执行，这里的 tokenOut 实际上是 tokenIn
                pay(tokenOut, data.payer, msg.sender, amountToPay);
            }
        }
    }

    /// @dev 执行单次精确输入兑换
    function exactInputInternal(
        uint256 amountIn,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountOut) {
        // 查找并替换接收者地址
        if (recipient == Constants.MSG_SENDER) recipient = msg.sender;
        else if (recipient == Constants.ADDRESS_THIS) recipient = address(this);

        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0, int256 amount1) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                amountIn.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );

        return uint256(-(zeroForOne ? amount1 : amount0));
    }

    /// @inheritdoc IV3SwapRouter
    function exactInputSingle(ExactInputSingleParams memory params)
        external
        payable
        override
        returns (uint256 amountOut)
    {
        // 以 amountIn == Constants.CONTRACT_BALANCE 作为标志，表示兑换本合约的全部余额
        bool hasAlreadyPaid;
        if (params.amountIn == Constants.CONTRACT_BALANCE) {
            hasAlreadyPaid = true;
            params.amountIn = IERC20(params.tokenIn).balanceOf(address(this));
        }

        amountOut = exactInputInternal(
            params.amountIn,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({
                path: abi.encodePacked(params.tokenIn, params.fee, params.tokenOut),
                payer: hasAlreadyPaid ? address(this) : msg.sender
            })
        );
        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }

    /// @inheritdoc IV3SwapRouter
    function exactInput(ExactInputParams memory params) external payable override returns (uint256 amountOut) {
        // 以 amountIn == Constants.CONTRACT_BALANCE 作为标志，表示兑换本合约的全部余额
        bool hasAlreadyPaid;
        if (params.amountIn == Constants.CONTRACT_BALANCE) {
            hasAlreadyPaid = true;
            (address tokenIn, , ) = params.path.decodeFirstPool();
            params.amountIn = IERC20(tokenIn).balanceOf(address(this));
        }

        address payer = hasAlreadyPaid ? address(this) : msg.sender;

        while (true) {
            bool hasMultiplePools = params.path.hasMultiplePools();

            // 前一次兑换的输出作为后续兑换的输入
            params.amountIn = exactInputInternal(
                params.amountIn,
                hasMultiplePools ? address(this) : params.recipient, // 对于中间的兑换，由本合约托管代币
                0,
                SwapCallbackData({
                    path: params.path.getFirstPool(), // 只需要路径中的第一个池子
                    payer: payer
                })
            );

            // 决定继续还是终止
            if (hasMultiplePools) {
                payer = address(this);
                params.path = params.path.skipToken();
            } else {
                amountOut = params.amountIn;
                break;
            }
        }

        require(amountOut >= params.amountOutMinimum, 'Too little received');
    }

    /// @dev 执行单次精确输出兑换
    function exactOutputInternal(
        uint256 amountOut,
        address recipient,
        uint160 sqrtPriceLimitX96,
        SwapCallbackData memory data
    ) private returns (uint256 amountIn) {
        // 查找并替换接收者地址
        if (recipient == Constants.MSG_SENDER) recipient = msg.sender;
        else if (recipient == Constants.ADDRESS_THIS) recipient = address(this);

        (address tokenOut, address tokenIn, uint24 fee) = data.path.decodeFirstPool();

        bool zeroForOne = tokenIn < tokenOut;

        (int256 amount0Delta, int256 amount1Delta) =
            getPool(tokenIn, tokenOut, fee).swap(
                recipient,
                zeroForOne,
                -amountOut.toInt256(),
                sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : sqrtPriceLimitX96,
                abi.encode(data)
            );

        uint256 amountOutReceived;
        (amountIn, amountOutReceived) = zeroForOne
            ? (uint256(amount0Delta), uint256(-amount1Delta))
            : (uint256(amount1Delta), uint256(-amount0Delta));
        // 从技术上讲，有可能收不到完整的输出数量，
        // 因此若未指定价格限制，则通过 require 排除这种可能
        if (sqrtPriceLimitX96 == 0) require(amountOutReceived == amountOut);
    }

    /// @inheritdoc IV3SwapRouter
    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        override
        returns (uint256 amountIn)
    {
        // 使用兑换的返回数据，以避免一次 SLOAD
        amountIn = exactOutputInternal(
            params.amountOut,
            params.recipient,
            params.sqrtPriceLimitX96,
            SwapCallbackData({path: abi.encodePacked(params.tokenOut, params.fee, params.tokenIn), payer: msg.sender})
        );

        require(amountIn <= params.amountInMaximum, 'Too much requested');
        // 尽管单跳情况下不使用它，仍必须将其重置
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }

    /// @inheritdoc IV3SwapRouter
    function exactOutput(ExactOutputParams calldata params) external payable override returns (uint256 amountIn) {
        exactOutputInternal(
            params.amountOut,
            params.recipient,
            0,
            SwapCallbackData({path: params.path, payer: msg.sender})
        );

        amountIn = amountInCached;
        require(amountIn <= params.amountInMaximum, 'Too much requested');
        amountInCached = DEFAULT_AMOUNT_IN_CACHED;
    }
}
