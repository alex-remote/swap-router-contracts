// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

import '@uniswap/v3-periphery/contracts/interfaces/IPeripheryPayments.sol';

/// @title 外围支付扩展（Periphery Payments Extended）
/// @notice 便于存入和提取 ETH 及代币的函数
interface IPeripheryPaymentsExtended is IPeripheryPayments {
    /// @notice 将本合约的 WETH9 余额解包，并以 ETH 形式发送给 msg.sender。
    /// @dev amountMinimum 参数用于防止恶意合约窃取用户的 WETH9。
    /// @param amountMinimum 要解包的 WETH9 最小数量
    function unwrapWETH9(uint256 amountMinimum) external payable;

    /// @notice 将本合约的 ETH 余额包装为 WETH9
    /// @dev 生成的 WETH9 由路由合约托管，因此需要进一步分发
    /// @param value 要包装的 ETH 数量
    function wrapETH(uint256 value) external payable;

    /// @notice 将本合约持有的某种代币全部转给 msg.sender
    /// @dev amountMinimum 参数用于防止恶意合约窃取用户的代币
    /// @param token 将被转给 msg.sender 的代币的合约地址
    /// @param amountMinimum 执行转账所要求的代币最小数量
    function sweepToken(address token, uint256 amountMinimum) external payable;

    /// @notice 将指定数量的代币从 msg.sender 转入 address(this)
    /// @param token 要拉取的代币
    /// @param value 要支付的数量
    function pull(address token, uint256 value) external payable;
}
