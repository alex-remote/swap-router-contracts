// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

interface IApproveAndCall {
    enum ApprovalType {NOT_REQUIRED, MAX, MAX_MINUS_ONE, ZERO_THEN_MAX, ZERO_THEN_MAX_MINUS_ONE}

    /// @dev 供链下调用的查询函数（lens），用于确定应调用相关授权函数中的哪一个（如有）
    /// @param token 要授权的代币
    /// @param amount 要授权的数量
    /// @return 所需的授权类型
    function getApprovalType(address token, uint256 amount) external returns (ApprovalType);

    /// @notice 以最大可能数量授权某个代币
    /// @param token 要授权的代币
    function approveMax(address token) external payable;

    /// @notice 以最大可能数量减一授权某个代币
    /// @param token 要授权的代币
    function approveMaxMinusOne(address token) external payable;

    /// @notice 先将代币授权为零，再以最大可能数量授权
    /// @param token 要授权的代币
    function approveZeroThenMax(address token) external payable;

    /// @notice 先将代币授权为零，再以最大可能数量减一授权
    /// @param token 要授权的代币
    function approveZeroThenMaxMinusOne(address token) external payable;

    /// @notice 使用任意 calldata 调用头寸管理器（position manager）
    /// @param data 要转发给头寸管理器的 calldata
    /// @return result 调用的返回结果
    function callPositionManager(bytes memory data) external payable returns (bytes memory result);

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
    }

    /// @notice 调用头寸管理器的 mint 函数
    /// @param params 要转发给头寸管理器的 calldata
    /// @return result 调用的返回结果
    function mint(MintParams calldata params) external payable returns (bytes memory result);

    struct IncreaseLiquidityParams {
        address token0;
        address token1;
        uint256 tokenId;
        uint256 amount0Min;
        uint256 amount1Min;
    }

    /// @notice 调用头寸管理器的 increaseLiquidity 函数
    /// @param params 要转发给头寸管理器的 calldata
    /// @return result 调用的返回结果
    function increaseLiquidity(IncreaseLiquidityParams calldata params) external payable returns (bytes memory result);
}
