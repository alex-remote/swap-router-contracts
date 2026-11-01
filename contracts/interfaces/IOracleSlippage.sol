// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title OracleSlippage 接口
/// @notice 支持基于预言机价格的滑点检查
interface IOracleSlippage {
    /// @notice 确保路径上当前的（合成）tick 相对于截至 `secondsAgo` 的平均值，
    /// 向不利方向的偏离不超过 `maximumTickDivergence` 个 tick
    /// @param path 用于获取价格的路径
    /// @param maximumTickDivergence 价格允许恶化的最大 tick 数
    /// @param secondsAgo 计算预言机价格所依据的回溯秒数
    function checkOracleSlippage(
        bytes memory path,
        uint24 maximumTickDivergence,
        uint32 secondsAgo
    ) external view;

    /// @notice 确保路径上加权平均后的当前（合成）tick 相对于截至 `secondsAgo` 的平均值，
    /// 向不利方向的偏离不超过 `maximumTickDivergence` 个 tick
    /// @param paths 用于获取价格的各条路径
    /// @param amounts `paths` 中每个条目的权重
    /// @param maximumTickDivergence 价格允许恶化的最大 tick 数
    /// @param secondsAgo 计算预言机价格所依据的回溯秒数
    function checkOracleSlippage(
        bytes[] memory paths,
        uint128[] memory amounts,
        uint24 maximumTickDivergence,
        uint32 secondsAgo
    ) external view;
}
