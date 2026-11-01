// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../libraries/UniswapV2Library.sol';
import '../interfaces/ISwapRouter02.sol';
import '../interfaces/ITokenValidator.sol';
import '../base/ImmutableState.sol';

/// @notice 通过从 V2 上的代币/<基础代币>池子进行闪电借贷来验证代币。
/// @notice 返回值
///     Status.FOT：检测到转账时会被收取手续费。
///     Status.STF：该代币转账失败。
///     Status.UNKN：未检测到该代币存在任何问题。
/// @notice 返回值为 Status.UNKN 并不意味着该代币一定不是转账收费（fee-on-transfer）代币，
///     或其转账一定没有问题。这仅表示我们无法确定它存在任何
///     问题。
/// @dev 出于以下几点原因，我们无法保证此 lens 的结果一定正确：
/// @dev 1/ 某些代币仅在特定条件下收取手续费或允许转账，例如有些代币设有一份白名单，
/// @dev    列出需要/不需要收取手续费的地址。因此无法保证结果在所有情况下
/// @dev    都是正确的。
/// @dev 2/ 该代币可能在 V2 上没有任何池子，因此我们无法执行
/// @dev    闪电贷来测试该代币。
contract TokenValidator is ITokenValidator, IUniswapV2Callee, ImmutableState {
    string internal constant FOT_REVERT_STRING = 'FOT';
    // https://github.com/Uniswap/v2-core/blob/1136544ac842ff48ae0b1b939701436598d74075/contracts/UniswapV2Pair.sol#L46
    string internal constant STF_REVERT_STRING_SUFFIX = 'TRANSFER_FAILED';

    constructor(address _factoryV2, address _positionManager) ImmutableState(_factoryV2, _positionManager) {}

    function batchValidate(
        address[] calldata tokens,
        address[] calldata baseTokens,
        uint256 amountToBorrow
    ) public override returns (Status[] memory isFotResults) {
        isFotResults = new Status[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            isFotResults[i] = validate(tokens[i], baseTokens, amountToBorrow);
        }
    }

    function validate(
        address token,
        address[] calldata baseTokens,
        uint256 amountToBorrow
    ) public override returns (Status) {
        for (uint256 i = 0; i < baseTokens.length; i++) {
            Status result = _validate(token, baseTokens[i], amountToBorrow);
            if (result == Status.FOT || result == Status.STF) {
                return result;
            }
        }
        return Status.UNKN;
    }

    function _validate(
        address token,
        address baseToken,
        uint256 amountToBorrow
    ) internal returns (Status) {
        if (token == baseToken) {
            return Status.UNKN;
        }

        address pairAddress = UniswapV2Library.pairFor(this.factoryV2(), token, baseToken);

        // 如果 token/baseToken 交易对存在，则获取 token0。
        // 必须使用低级调用，因为 try/catch 不支持合约不存在的情况。
        (, bytes memory returnData) = address(pairAddress).call(abi.encodeWithSelector(IUniswapV2Pair.token0.selector));

        if (returnData.length == 0) {
            return Status.UNKN;
        }

        address token0Address = abi.decode(returnData, (address));

        // 闪电贷 {amountToBorrow}
        (uint256 amount0Out, uint256 amount1Out) =
            token == token0Address ? (amountToBorrow, uint256(0)) : (uint256(0), amountToBorrow);

        uint256 balanceBeforeLoan = IERC20(token).balanceOf(address(this));

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        try
            pair.swap(amount0Out, amount1Out, address(this), abi.encode(balanceBeforeLoan, amountToBorrow))
        {} catch Error(string memory reason) {
            if (isFotFailed(reason)) {
                return Status.FOT;
            }

            if (isTransferFailed(reason)) {
                return Status.STF;
            }

            return Status.UNKN;
        }

        // 兑换总会 revert，因此永远不应执行到此处。
        revert('Unexpected error');
    }

    function isFotFailed(string memory reason) internal pure returns (bool) {
        return keccak256(bytes(reason)) == keccak256(bytes(FOT_REVERT_STRING));
    }

    function isTransferFailed(string memory reason) internal pure returns (bool) {
        // 我们检查 revert 字符串的后缀，以便支持那些
        // 可能修改了前缀的分叉版本。
        string memory stf = STF_REVERT_STRING_SUFFIX;

        uint256 reasonLength = bytes(reason).length;
        uint256 suffixLength = bytes(stf).length;
        if (reasonLength < suffixLength) {
            return false;
        }

        uint256 ptr;
        uint256 offset = 32 + reasonLength - suffixLength;
        bool transferFailed;
        assembly {
            ptr := add(reason, offset)
            let suffixPtr := add(stf, 32)
            transferFailed := eq(keccak256(ptr, suffixLength), keccak256(suffixPtr, suffixLength))
        }

        return transferFailed;
    }

    function uniswapV2Call(
        address,
        uint256 amount0,
        uint256,
        bytes calldata data
    ) external view override {
        IUniswapV2Pair pair = IUniswapV2Pair(msg.sender);
        (address token0, address token1) = (pair.token0(), pair.token1());

        IERC20 tokenBorrowed = IERC20(amount0 > 0 ? token0 : token1);

        (uint256 balanceBeforeLoan, uint256 amountRequestedToBorrow) = abi.decode(data, (uint256, uint256));
        uint256 amountBorrowed = tokenBorrowed.balanceOf(address(this)) - balanceBeforeLoan;

        // 如果收到的代币少于调用 swap 时请求的数量，那么一定是该代币
        // 在转账过程中收取了手续费。
        if (amountBorrowed != amountRequestedToBorrow) {
            revert(FOT_REVERT_STRING);
        }

        // 注意：即使不在此处 revert，最终也会在交易对的 swap 方法中 revert，
        // 因为闪电借贷需要归还借入的数量加上 0.3% 的手续费，而我们没有
        // 足够的资金支付该手续费。因此在此提前 revert 以节省 gas/时间。
        revert('Unknown');
    }
}
