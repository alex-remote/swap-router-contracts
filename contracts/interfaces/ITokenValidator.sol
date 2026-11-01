// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @notice 通过从 V2 上的 token/<base token> 池子进行闪电借贷来验证代币。
/// @notice 返回值
///     Status.FOT：检测到转账时会被收取手续费。
///     Status.STF：该代币转账失败。
///     Status.UNKN：未检测到该代币存在任何问题。
/// @notice 返回 Status.UNKN 并不意味着该代币一定不是转账收费（fee-on-transfer）代币，
///     或其转账一定没有问题。它仅表示我们无法确定该代币存在任何
///     问题。
/// @dev 出于以下几个原因，我们无法保证此 lens 的结果一定正确：
/// @dev 1/ 某些代币会在特定条件下收取手续费或允许转账，例如有些代币设有一个白名单（allowlist），
/// @dev    列出需要/不需要收取手续费的地址。因此无法保证结果
/// @dev    在所有情况下都正确。
/// @dev 2/ 该代币有可能在 V2 上没有任何池子，因此我们无法执行
/// @dev    闪电贷来测试该代币。
/// @dev 这些函数没有标记为 view，因为它们依赖于调用非 view 函数并 revert
/// 来计算结果。
interface ITokenValidator {
    // Status.FOT：检测到转账时会被收取手续费。
    // Status.STF：该代币转账失败。
    // Status.UNKN：未发现该代币存在问题。
    enum Status {UNKN, FOT, STF}

    /// @notice 通过检测代币是否可转账、转账时是否收取手续费来验证该代币
    /// @param token 要检查是否转账收费的代币地址
    /// @param baseTokens 在寻找可供闪电贷的池子时，尝试与
    /// token 组成交易对的代币地址列表。
    /// @param amountToBorrow 尝试从池子中闪电借贷的数量
    /// @return 代币的状态
    function validate(
        address token,
        address[] calldata baseTokens,
        uint256 amountToBorrow
    ) external returns (Status);

    /// @notice 通过检测每个代币是否可转账、转账时是否收取手续费来逐一验证代币
    /// @param tokens 要检查是否转账收费的代币地址列表
    /// @param baseTokens 在寻找可供闪电贷的池子时，尝试与
    /// token 组成交易对的代币地址列表。
    /// @param amountToBorrow 尝试从池子中闪电借贷的数量
    /// @return 代币的状态
    function batchValidate(
        address[] calldata tokens,
        address[] calldata baseTokens,
        uint256 amountToBorrow
    ) external returns (Status[] memory);
}
