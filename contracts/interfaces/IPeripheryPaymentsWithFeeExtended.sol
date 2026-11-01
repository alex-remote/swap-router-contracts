// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;

import '@uniswap/v3-periphery/contracts/interfaces/IPeripheryPaymentsWithFee.sol';

import './IPeripheryPaymentsExtended.sol';

/// @title 带手续费的外围支付扩展（Periphery Payments With Fee Extended）
/// @notice 便于存入和提取 ETH 的函数
interface IPeripheryPaymentsWithFeeExtended is IPeripheryPaymentsExtended, IPeripheryPaymentsWithFee {
    /// @notice 将本合约的 WETH9 余额解包，并以 ETH 形式发送给 msg.sender，其中一定比例（介于
    /// 0（不含）与 1（含）之间）的部分发送给 feeRecipient
    /// @dev amountMinimum 参数用于防止恶意合约窃取用户的 WETH9。
    function unwrapWETH9WithFee(
        uint256 amountMinimum,
        uint256 feeBips,
        address feeRecipient
    ) external payable;

    /// @notice 将本合约持有的某种代币全部转给 msg.sender，其中一定比例（介于
    /// 0（不含）与 1（含）之间）的部分发送给 feeRecipient
    /// @dev amountMinimum 参数用于防止恶意合约窃取用户的代币
    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        uint256 feeBips,
        address feeRecipient
    ) external payable;
}
