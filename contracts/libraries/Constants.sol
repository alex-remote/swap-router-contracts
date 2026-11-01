// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

/// @title 常量状态
/// @notice 兑换路由合约使用的常量状态
library Constants {
    /// @dev 用于标识需要使用本合约所持某代币余额的情况
    uint256 internal constant CONTRACT_BALANCE = 0;

    /// @dev 用作标识 msg.sender 的标志，通过发送更多 0 字节来节省 gas
    address internal constant MSG_SENDER = address(1);

    /// @dev 用作标识 address(this) 的标志，通过发送更多 0 字节来节省 gas
    address internal constant ADDRESS_THIS = address(2);
}
