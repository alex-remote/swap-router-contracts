// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol';
import '@uniswap/v3-core/contracts/libraries/SafeCast.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-core/contracts/libraries/TickBitmap.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';
import '@uniswap/v3-periphery/contracts/libraries/Path.sol';
import '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import '@uniswap/v3-periphery/contracts/libraries/CallbackValidation.sol';

import '../interfaces/IQuoterV2.sol';
import '../libraries/PoolTicksCounter.sol';

/// @title 为兑换提供报价
/// @notice 无需实际执行兑换，即可获取给定兑换的预期输出数量或输入数量
/// @dev 这些函数的 gas 效率不高，_不应_在链上调用。应改为乐观地执行
/// 兑换，并在回调中检查数量。
contract QuoterV2 is IQuoterV2, IUniswapV3SwapCallback, PeripheryImmutableState {
    using Path for bytes;
    using SafeCast for uint256;
    using PoolTicksCounter for IUniswapV3Pool;

    /// @dev 临时存储变量，用于在精确输出兑换中检查一项安全条件。
    uint256 private amountOutCached;

    constructor(address _factory, address _WETH9) PeripheryImmutableState(_factory, _WETH9) {}

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) private view returns (IUniswapV3Pool) {
        return IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes memory path
    ) external view override {
        require(amount0Delta > 0 || amount1Delta > 0); // 不支持完全处于零流动性区间内的兑换
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);

        (bool isExactInput, uint256 amountToPay, uint256 amountReceived) =
            amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(amount0Delta), uint256(-amount1Delta))
                : (tokenOut < tokenIn, uint256(amount1Delta), uint256(-amount0Delta));

        IUniswapV3Pool pool = getPool(tokenIn, tokenOut, fee);
        (uint160 sqrtPriceX96After, int24 tickAfter, , , , , ) = pool.slot0();

        if (isExactInput) {
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, amountReceived)
                mstore(add(ptr, 0x20), sqrtPriceX96After)
                mstore(add(ptr, 0x40), tickAfter)
                revert(ptr, 96)
            }
        } else {
            // 如果缓存已被填充，则确保已收到全部输出数量
            if (amountOutCached != 0) require(amountReceived == amountOutCached);
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, amountToPay)
                mstore(add(ptr, 0x20), sqrtPriceX96After)
                mstore(add(ptr, 0x40), tickAfter)
                revert(ptr, 96)
            }
        }
    }

    /// @dev 解析应包含数值报价的 revert 原因
    function parseRevertReason(bytes memory reason)
        private
        pure
        returns (
            uint256 amount,
            uint160 sqrtPriceX96After,
            int24 tickAfter
        )
    {
        if (reason.length != 96) {
            if (reason.length < 68) revert('Unexpected error');
            assembly {
                reason := add(reason, 0x04)
            }
            revert(abi.decode(reason, (string)));
        }
        return abi.decode(reason, (uint256, uint160, int24));
    }

    function handleRevert(
        bytes memory reason,
        IUniswapV3Pool pool,
        uint256 gasEstimate
    )
        private
        view
        returns (
            uint256 amount,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256
        )
    {
        int24 tickBefore;
        int24 tickAfter;
        (, tickBefore, , , , , ) = pool.slot0();
        (amount, sqrtPriceX96After, tickAfter) = parseRevertReason(reason);

        initializedTicksCrossed = pool.countInitializedTicksCrossed(tickBefore, tickAfter);

        return (amount, sqrtPriceX96After, initializedTicksCrossed, gasEstimate);
    }

    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        public
        override
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        )
    {
        bool zeroForOne = params.tokenIn < params.tokenOut;
        IUniswapV3Pool pool = getPool(params.tokenIn, params.tokenOut, params.fee);

        uint256 gasBefore = gasleft();
        try
            pool.swap(
                address(this), // address(0) 可能会导致某些代币出现问题
                zeroForOne,
                params.amountIn.toInt256(),
                params.sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : params.sqrtPriceLimitX96,
                abi.encodePacked(params.tokenIn, params.fee, params.tokenOut)
            )
        {} catch (bytes memory reason) {
            gasEstimate = gasBefore - gasleft();
            return handleRevert(reason, pool, gasEstimate);
        }
    }

    function quoteExactInput(bytes memory path, uint256 amountIn)
        public
        override
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        )
    {
        sqrtPriceX96AfterList = new uint160[](path.numPools());
        initializedTicksCrossedList = new uint32[](path.numPools());

        uint256 i = 0;
        while (true) {
            (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();

            // 前一次兑换的输出成为后续兑换的输入
            (uint256 _amountOut, uint160 _sqrtPriceX96After, uint32 _initializedTicksCrossed, uint256 _gasEstimate) =
                quoteExactInputSingle(
                    QuoteExactInputSingleParams({
                        tokenIn: tokenIn,
                        tokenOut: tokenOut,
                        fee: fee,
                        amountIn: amountIn,
                        sqrtPriceLimitX96: 0
                    })
                );

            sqrtPriceX96AfterList[i] = _sqrtPriceX96After;
            initializedTicksCrossedList[i] = _initializedTicksCrossed;
            amountIn = _amountOut;
            gasEstimate += _gasEstimate;
            i++;

            // 决定是继续还是终止
            if (path.hasMultiplePools()) {
                path = path.skipToken();
            } else {
                return (amountIn, sqrtPriceX96AfterList, initializedTicksCrossedList, gasEstimate);
            }
        }
    }

    function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
        public
        override
        returns (
            uint256 amountIn,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        )
    {
        bool zeroForOne = params.tokenIn < params.tokenOut;
        IUniswapV3Pool pool = getPool(params.tokenIn, params.tokenOut, params.fee);

        // 如果未指定价格限制，则缓存输出数量，以便在兑换回调中进行比较
        if (params.sqrtPriceLimitX96 == 0) amountOutCached = params.amount;
        uint256 gasBefore = gasleft();
        try
            pool.swap(
                address(this), // address(0) 可能会导致某些代币出现问题
                zeroForOne,
                -params.amount.toInt256(),
                params.sqrtPriceLimitX96 == 0
                    ? (zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1)
                    : params.sqrtPriceLimitX96,
                abi.encodePacked(params.tokenOut, params.fee, params.tokenIn)
            )
        {} catch (bytes memory reason) {
            gasEstimate = gasBefore - gasleft();
            if (params.sqrtPriceLimitX96 == 0) delete amountOutCached; // 清除缓存
            return handleRevert(reason, pool, gasEstimate);
        }
    }

    function quoteExactOutput(bytes memory path, uint256 amountOut)
        public
        override
        returns (
            uint256 amountIn,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        )
    {
        sqrtPriceX96AfterList = new uint160[](path.numPools());
        initializedTicksCrossedList = new uint32[](path.numPools());

        uint256 i = 0;
        while (true) {
            (address tokenOut, address tokenIn, uint24 fee) = path.decodeFirstPool();

            // 前一次兑换的输入成为后续兑换的输出
            (uint256 _amountIn, uint160 _sqrtPriceX96After, uint32 _initializedTicksCrossed, uint256 _gasEstimate) =
                quoteExactOutputSingle(
                    QuoteExactOutputSingleParams({
                        tokenIn: tokenIn,
                        tokenOut: tokenOut,
                        amount: amountOut,
                        fee: fee,
                        sqrtPriceLimitX96: 0
                    })
                );

            sqrtPriceX96AfterList[i] = _sqrtPriceX96After;
            initializedTicksCrossedList[i] = _initializedTicksCrossed;
            amountOut = _amountIn;
            gasEstimate += _gasEstimate;
            i++;

            // 决定是继续还是终止
            if (path.hasMultiplePools()) {
                path = path.skipToken();
            } else {
                return (amountOut, sqrtPriceX96AfterList, initializedTicksCrossedList, gasEstimate);
            }
        }
    }
}
