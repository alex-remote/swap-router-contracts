// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title QuoterV2 接口
/// @notice 支持对精确输入或精确输出兑换计算所得的数量进行报价。
/// @notice 对于每个池子，还会给出兑换跨越的已初始化 tick 数量以及兑换后池子的 sqrt 价格。
/// @dev 这些函数未标记为 view，因为它们依赖于调用非 view 函数并通过 revert
/// 来计算结果。它们的 gas 效率也不高，不应在链上调用。
interface IQuoterV2 {
    /// @notice 在不实际执行兑换的情况下，返回给定精确输入兑换可获得的输出数量
    /// @param path 兑换路径，即每个代币交易对及池子手续费
    /// @param amountIn 要兑换的第一个代币的数量
    /// @return amountOut 将会收到的最后一个代币的数量
    /// @return sqrtPriceX96AfterList 路径中每个池子在兑换后的 sqrt 价格列表
    /// @return initializedTicksCrossedList 兑换在路径中每个池子所跨越的已初始化 tick 列表
    /// @return gasEstimate 兑换所消耗 gas 的估计值
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice 返回给定精确输入在单个池子兑换中可获得的输出数量
    /// @param params 报价参数，编码为 `QuoteExactInputSingleParams`
    /// tokenIn 兑换的输入代币
    /// tokenOut 兑换的输出代币
    /// fee 该交易对所要考虑的代币池子的手续费
    /// amountIn 期望的输入数量
    /// sqrtPriceLimitX96 兑换不能超过的池子价格限制
    /// @return amountOut 将会收到的 `tokenOut` 数量
    /// @return sqrtPriceX96After 兑换后池子的 sqrt 价格
    /// @return initializedTicksCrossed 兑换跨越的已初始化 tick 数量
    /// @return gasEstimate 兑换所消耗 gas 的估计值
    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );

    /// @notice 在不实际执行兑换的情况下，返回给定精确输出兑换所需的输入数量
    /// @param path 兑换路径，即每个代币交易对及池子手续费。路径必须按逆序提供
    /// @param amountOut 要收到的最后一个代币的数量
    /// @return amountIn 需要支付的第一个代币的数量
    /// @return sqrtPriceX96AfterList 路径中每个池子在兑换后的 sqrt 价格列表
    /// @return initializedTicksCrossedList 兑换在路径中每个池子所跨越的已初始化 tick 列表
    /// @return gasEstimate 兑换所消耗 gas 的估计值
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        returns (
            uint256 amountIn,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice 返回在单个池子兑换中收到给定精确输出数量所需的输入数量
    /// @param params 报价参数，编码为 `QuoteExactOutputSingleParams`
    /// tokenIn 兑换的输入代币
    /// tokenOut 兑换的输出代币
    /// fee 该交易对所要考虑的代币池子的手续费
    /// amountOut 期望的输出数量
    /// sqrtPriceLimitX96 兑换不能超过的池子价格限制
    /// @return amountIn 为收到 `amountOut` 而需作为兑换输入的数量
    /// @return sqrtPriceX96After 兑换后池子的 sqrt 价格
    /// @return initializedTicksCrossed 兑换跨越的已初始化 tick 数量
    /// @return gasEstimate 兑换所消耗 gas 的估计值
    function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
        external
        returns (
            uint256 amountIn,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}
