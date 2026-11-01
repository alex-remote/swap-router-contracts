// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title 路由合约的代币兑换功能
/// @notice 通过 Uniswap V2 兑换代币的函数
interface IV2SwapRouter {
    /// @notice 将 `amountIn` 数量的一种代币兑换为尽可能多的另一种代币
    /// @dev 将 `amountIn` 设为 0 会使合约查询自身余额，
    /// 并兑换全部余额，从而允许合约在调用此函数之前先转入代币。
    /// @param amountIn 要兑换的代币数量
    /// @param amountOutMin 必须收到的最少输出数量
    /// @param path 兑换所经过的代币的有序列表
    /// @param to 接收者地址
    /// @return amountOut 收到的代币数量
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountOut);

    /// @notice 用尽可能少的一种代币兑换精确数量的另一种代币
    /// @param amountOut 要兑换得到的代币数量
    /// @param amountInMax 调用者愿意支付的最大输入数量
    /// @param path 兑换所经过的代币的有序列表
    /// @param to 接收者地址
    /// @return amountIn 需要支付的代币数量
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to
    ) external payable returns (uint256 amountIn);
}
