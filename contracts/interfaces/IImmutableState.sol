// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 不可变状态
/// @notice 返回路由合约不可变状态的函数
interface IImmutableState {
    /// @return 返回 Uniswap V2 工厂合约的地址
    function factoryV2() external view returns (address);

    /// @return 返回 Uniswap V3 NFT 头寸管理器的地址
    function positionManager() external view returns (address);
}
