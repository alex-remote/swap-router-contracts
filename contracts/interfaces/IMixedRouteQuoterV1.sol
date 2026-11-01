// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title MixedRouteQuoterV1 接口
/// @notice 支持为精确输入兑换计算报价数量。专门用于包含 V2 与 V3 混合流动性的路由。
/// @notice 对于每个池子，还会给出兑换跨越的已初始化 tick 数量以及兑换后池子的 sqrt 价格。
/// @dev 这些函数未标记为 view，因为它们依赖于调用非 view 函数并通过 revert
/// 来计算结果。它们的 gas 效率也不高，不应在链上调用。
interface IMixedRouteQuoterV1 {
    /// @notice 在不实际执行兑换的情况下，返回给定精确输入兑换可获得的输出数量
    /// @param path 兑换路径，即每个代币交易对及池子手续费
    /// @param amountIn 要兑换的第一个代币的数量
    /// @return amountOut 将会收到的最后一个代币的数量
    /// @return v3SqrtPriceX96AfterList 路径中每个 v3 池子在兑换后的 sqrt 价格列表，v2 池子为 0
    /// @return v3InitializedTicksCrossedList 路径中每个 v3 池子被兑换跨越的已初始化 tick 列表，v2 池子为 0
    /// @return v3SwapGasEstimate 路径中各 v3 兑换所消耗 gas 的估算值
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        returns (
            uint256 amountOut,
            uint160[] memory v3SqrtPriceX96AfterList,
            uint32[] memory v3InitializedTicksCrossedList,
            uint256 v3SwapGasEstimate
        );

    struct QuoteExactInputSingleV3Params {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    struct QuoteExactInputSingleV2Params {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
    }

    /// @notice 返回给定精确输入在单个池子内兑换时可获得的输出数量
    /// @param params 报价参数，编码为 `QuoteExactInputSingleParams`
    /// tokenIn 兑换输入的代币
    /// tokenOut 兑换输出的代币
    /// fee 该交易对所考虑的代币池子的手续费
    /// amountIn 期望的输入数量
    /// sqrtPriceLimitX96 兑换不得突破的池子价格限制
    /// @return amountOut 将会收到的 `tokenOut` 数量
    /// @return sqrtPriceX96After 兑换后池子的 sqrt 价格
    /// @return initializedTicksCrossed 兑换跨越的已初始化 tick 数量
    /// @return gasEstimate 兑换所消耗 gas 的估算值
    function quoteExactInputSingleV3(QuoteExactInputSingleV3Params memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );

    /// @notice 返回给定精确输入在单个 V2 池子内兑换时可获得的输出数量
    /// @param params 报价参数，编码为 `QuoteExactInputSingleV2Params`
    /// tokenIn 兑换输入的代币
    /// tokenOut 兑换输出的代币
    /// amountIn 期望的输入数量
    /// @return amountOut 将会收到的 `tokenOut` 数量
    function quoteExactInputSingleV2(QuoteExactInputSingleV2Params memory params) external returns (uint256 amountOut);

    /// @dev 这个新的 Quoter 不支持 ExactOutput 兑换，它专门用于支持同时跨越
    ///      V2 流动性交易对和 V3 池子的路由。
    /// @deprecated quoteExactOutputSingle 和 exactOutput。请改用 QuoterV2。
}
