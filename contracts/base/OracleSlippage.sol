// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '../interfaces/IOracleSlippage.sol';

import '@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol';
import '@uniswap/v3-periphery/contracts/base/BlockTimestamp.sol';
import '@uniswap/v3-periphery/contracts/libraries/Path.sol';
import '@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol';

abstract contract OracleSlippage is IOracleSlippage, PeripheryImmutableState, BlockTimestamp {
    using Path for bytes;

    /// @dev 返回给定池子在当前区块开始时以及此刻的 tick。
    function getBlockStartingAndCurrentTick(IUniswapV3Pool pool)
        internal
        view
        returns (int24 blockStartingTick, int24 currentTick)
    {
        uint16 observationIndex;
        uint16 observationCardinality;
        (, currentTick, observationIndex, observationCardinality, , , ) = pool.slot0();

        // 需要 2 个观测值才能可靠地计算区块起始 tick
        require(observationCardinality > 1, 'NEO');

        // 如果最新的观测值发生在过去，则本区块内尚未发生任何改变 tick 的交易，
        // 因此 `slot0` 中的 tick 与当前区块开始时的 tick 相同。
        // 无需检查该观测值是否已初始化——它必定已初始化。
        (uint32 observationTimestamp, int56 tickCumulative, , ) = pool.observations(observationIndex);
        if (observationTimestamp != uint32(_blockTimestamp())) {
            blockStartingTick = currentTick;
        } else {
            uint256 prevIndex = (uint256(observationIndex) + observationCardinality - 1) % observationCardinality;
            (uint32 prevObservationTimestamp, int56 prevTickCumulative, , bool prevInitialized) =
                pool.observations(prevIndex);

            require(prevInitialized, 'ONI');

            uint32 delta = observationTimestamp - prevObservationTimestamp;
            blockStartingTick = int24((tickCumulative - prevTickCumulative) / delta);
        }
    }

    /// @dev 获取池子地址的虚函数，可在测试中被重写。
    function getPoolAddress(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view virtual returns (IUniswapV3Pool pool) {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }

    /// @dev 返回给定路径在过去 secondsAgo 秒内的合成时间加权平均 tick，以及当前 tick。
    /// 返回的合成 tick 始终表示 tokenOut/tokenIn 价格，
    /// 即 tick 越低代表价格越差。
    function getSyntheticTicks(bytes memory path, uint32 secondsAgo)
        internal
        view
        returns (int256 syntheticAverageTick, int256 syntheticCurrentTick)
    {
        bool lowerTicksAreWorse;

        uint256 numPools = path.numPools();
        address previousTokenIn;
        for (uint256 i = 0; i < numPools; i++) {
            // 此处假定路径已按兑换顺序排列
            (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
            IUniswapV3Pool pool = getPoolAddress(tokenIn, tokenOut, fee);

            // 获取当前池子的平均 tick 与当前 tick
            int256 averageTick;
            int256 currentTick;
            if (secondsAgo == 0) {
                // 针对 secondsAgo == 0 的情况（即自区块开始以来）进行优化
                (averageTick, currentTick) = getBlockStartingAndCurrentTick(pool);
            } else {
                (averageTick, ) = OracleLibrary.consult(address(pool), secondsAgo);
                (, currentTick, , , , , ) = IUniswapV3Pool(pool).slot0();
            }

            if (i == numPools - 1) {
                // 执行到这里说明这是路径中的最后一个池子，即 tokenOut 代表
                // 目标代币。因此，若 tokenIn < tokenOut，则 tokenIn 是最后一个池子的 token0，
                // 这意味着当前累计的 tick 将表示 tokenOut/tokenIn 价格。
                // 所以，这些价格越低，兑换得到的价格就越差
                lowerTicksAreWorse = tokenIn < tokenOut;
            } else {
                // 执行到这里说明需要继续迭代路径中的下一个池子
                path = path.skipToken();
                previousTokenIn = tokenIn;
            }

            // 将从当前池子得到的 tick 累加到累计的合成 tick 中，
            // 确保中间代币相互"抵消"
            bool add = (i == 0) || (previousTokenIn < tokenIn ? tokenIn < tokenOut : tokenOut < tokenIn);
            if (add) {
                syntheticAverageTick += averageTick;
                syntheticCurrentTick += currentTick;
            } else {
                syntheticAverageTick -= averageTick;
                syntheticCurrentTick -= currentTick;
            }
        }

        // 必要时翻转 tick 的符号，以确保 tick 越低总是代表价格越差
        if (!lowerTicksAreWorse) {
            syntheticAverageTick *= -1;
            syntheticCurrentTick *= -1;
        }
    }

    /// @dev 将 int256 转换为 int24，上溢或下溢时 revert
    function toInt24(int256 y) private pure returns (int24 z) {
        require((z = int24(y)) == y);
    }

    /// @dev 对传入的每条路径，获取过去 secondsAgo 秒内的合成时间加权平均 tick
    /// 以及当前 tick。然后对所有路径的合成 tick 进行加权
    /// 平均，权重为分配给各路径的输入数量占总输入数量的比例。
    /// 返回的合成 tick 始终表示 tokenOut/tokenIn 价格，即 tick 越低代表价格越差。
    /// 所有路径必须以相同的代币开始，并以相同的代币结束。
    function getSyntheticTicks(
        bytes[] memory paths,
        uint128[] memory amounts,
        uint32 secondsAgo
    ) internal view returns (int256 averageSyntheticAverageTick, int256 averageSyntheticCurrentTick) {
        require(paths.length == amounts.length);

        OracleLibrary.WeightedTickData[] memory weightedSyntheticAverageTicks =
            new OracleLibrary.WeightedTickData[](paths.length);
        OracleLibrary.WeightedTickData[] memory weightedSyntheticCurrentTicks =
            new OracleLibrary.WeightedTickData[](paths.length);

        for (uint256 i = 0; i < paths.length; i++) {
            (int256 syntheticAverageTick, int256 syntheticCurrentTick) = getSyntheticTicks(paths[i], secondsAgo);
            weightedSyntheticAverageTicks[i].tick = toInt24(syntheticAverageTick);
            weightedSyntheticCurrentTicks[i].tick = toInt24(syntheticCurrentTick);
            weightedSyntheticAverageTicks[i].weight = amounts[i];
            weightedSyntheticCurrentTicks[i].weight = amounts[i];
        }

        averageSyntheticAverageTick = OracleLibrary.getWeightedArithmeticMeanTick(weightedSyntheticAverageTicks);
        averageSyntheticCurrentTick = OracleLibrary.getWeightedArithmeticMeanTick(weightedSyntheticCurrentTicks);
    }

    /// @inheritdoc IOracleSlippage
    function checkOracleSlippage(
        bytes memory path,
        uint24 maximumTickDivergence,
        uint32 secondsAgo
    ) external view override {
        (int256 syntheticAverageTick, int256 syntheticCurrentTick) = getSyntheticTicks(path, secondsAgo);
        require(syntheticAverageTick - syntheticCurrentTick < maximumTickDivergence, 'TD');
    }

    /// @inheritdoc IOracleSlippage
    function checkOracleSlippage(
        bytes[] memory paths,
        uint128[] memory amounts,
        uint24 maximumTickDivergence,
        uint32 secondsAgo
    ) external view override {
        (int256 averageSyntheticAverageTick, int256 averageSyntheticCurrentTick) =
            getSyntheticTicks(paths, amounts, secondsAgo);
        require(averageSyntheticAverageTick - averageSyntheticCurrentTick < maximumTickDivergence, 'TD');
    }
}
