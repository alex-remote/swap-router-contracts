// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '../interfaces/IImmutableState.sol';

/// @title 不可变状态
/// @notice 兑换路由合约使用的不可变状态
abstract contract ImmutableState is IImmutableState {
    /// @inheritdoc IImmutableState
    address public immutable override factoryV2;
    /// @inheritdoc IImmutableState
    address public immutable override positionManager;

    constructor(address _factoryV2, address _positionManager) {
        factoryV2 = _factoryV2;
        positionManager = _positionManager;
    }
}
