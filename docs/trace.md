# 英文注释中文翻译 · 任务进度跟踪

> 分支：`swap-router_zh`　·　基线提交：`70bc2e4`　·　创建日期：2026-11-01

## 一、翻译规则

1. 在英文原文位置直接替换为中文，**翻译后文件行数必须与原文件完全一致**。
2. 保留专有名词、函数名、变量名、合约名、NatSpec 标签（`@notice` / `@param xxx` / `@return` / `@dev` / `@inheritdoc` 等）及 URL。
3. 只改注释，不改任何代码、字符串字面量（如 `require` 的 revert 信息、测试用例名 `it('...')` / `describe('...')`）。
4. 英文 `.md` 文件另存为同目录下 `_zh.md` 后缀的翻译件，原件保持不变。
5. 勾选框含义：`[ ]` 未翻译，`[x]` 已翻译且通过行数校验。

## 二、统计总览

| 类别 | 文件数 | 总行数 |
| --- | ---: | ---: |
| 仓库受跟踪文件（基线） | 89 | 17275 |
| 需原地翻译注释的源文件（.sol / .ts / .yml） | 48 | 7275 |
| 需另存 `_zh.md` 翻译件的 Markdown 文件 | 3 | 149 |
| 无需翻译的文件 | 38 | 9851 |
| 子代理批次数 | 15 | — |

## 三、源文件注释原地翻译清单

### 批次 A1 · 核心路由合约

- [ ] `contracts/V3SwapRouter.sol` — 原始 238 行
- [ ] `contracts/V2SwapRouter.sol` — 原始 94 行
- [ ] `contracts/SwapRouter02.sol` — 原始 22 行

### 批次 A2 · base 合约（一）

- [ ] `contracts/base/ApproveAndCall.sol` — 原始 126 行
- [ ] `contracts/base/ImmutableState.sol` — 原始 18 行
- [ ] `contracts/base/MulticallExtended.sol` — 原始 34 行
- [ ] `contracts/base/PeripheryPaymentsExtended.sol` — 原始 29 行
- [ ] `contracts/base/PeripheryPaymentsWithFeeExtended.sol` — 原始 32 行

### 批次 A3 · base 合约（二）与库

- [ ] `contracts/base/OracleSlippage.sol` — 原始 171 行
- [ ] `contracts/libraries/Constants.sol` — 原始 15 行
- [ ] `contracts/libraries/PoolTicksCounter.sol` — 原始 96 行
- [ ] `contracts/libraries/UniswapV2Library.sol` — 原始 90 行

### 批次 A4 · 接口（一）

- [ ] `contracts/interfaces/IApproveAndCall.sol` — 原始 63 行
- [ ] `contracts/interfaces/IImmutableState.sol` — 原始 12 行
- [ ] `contracts/interfaces/IMixedRouteQuoterV1.sol` — 原始 72 行
- [ ] `contracts/interfaces/IMulticallExtended.sol` — 原始 26 行
- [ ] `contracts/interfaces/IOracleSlippage.sol` — 原始 31 行

### 批次 A5 · 接口（二）

- [ ] `contracts/interfaces/IPeripheryPaymentsExtended.sol` — 原始 29 行
- [ ] `contracts/interfaces/IPeripheryPaymentsWithFeeExtended.sol` — 原始 29 行
- [ ] `contracts/interfaces/IQuoter.sol` — 原始 51 行
- [ ] `contracts/interfaces/IQuoterV2.sol` — 原始 98 行

### 批次 A6 · 接口（三）

- [ ] `contracts/interfaces/ISwapRouter02.sol` — 原始 15 行
- [ ] `contracts/interfaces/ITokenValidator.sol` — 原始 50 行
- [ ] `contracts/interfaces/IV2SwapRouter.sol` — 原始 35 行
- [ ] `contracts/interfaces/IV3SwapRouter.sol` — 原始 69 行

### 批次 A7 · lens 合约（一）

- [ ] `contracts/lens/MixedRouteQuoterV1.sol` — 原始 237 行
- [ ] `contracts/lens/Quoter.sol` — 原始 170 行

### 批次 A8 · lens 合约（二）

- [ ] `contracts/lens/QuoterV2.sol` — 原始 273 行
- [ ] `contracts/lens/TokenValidator.sol` — 原始 159 行

### 批次 A9 · 测试辅助、配置与 CI

- [ ] `contracts/test/MockObservations.sol` — 原始 77 行
- [ ] `test/shared/completeFixture.ts` — 原始 36 行
- [ ] `test/shared/computePoolAddress.ts` — 原始 22 行
- [ ] `test/shared/constants.ts` — 原始 21 行
- [ ] `test/shared/encodePriceSqrt.ts` — 原始 16 行
- [ ] `test/shared/path.ts` — 原始 61 行
- [ ] `test/shared/quoter.ts` — 原始 160 行
- [ ] `hardhat.config.ts` — 原始 70 行
- [ ] `.github/workflows/release.yml` — 原始 45 行
- [ ] `.github/workflows/tests.yml` — 原始 41 行

### 批次 A10 · 测试（SwapRouter 主测试）

- [ ] `test/SwapRouter.spec.ts` — 原始 1623 行

### 批次 A11 · 测试（一）

- [ ] `test/ApproveAndCall.spec.ts` — 原始 388 行
- [ ] `test/TokenValidator.spec.ts` — 原始 158 行
- [ ] `test/SwapRouter.gas.spec.ts` — 原始 470 行

### 批次 A12 · 测试（二）

- [ ] `test/MixedRouteQuoterV1.spec.ts` — 原始 460 行
- [ ] `test/MixedRouteQuoterV1.integ.ts` — 原始 184 行

### 批次 A13 · 测试（三）

- [ ] `test/QuoterV2.spec.ts` — 原始 578 行
- [ ] `test/Quoter.spec.ts` — 原始 201 行
- [ ] `test/PoolTicksCounter.spec.ts` — 原始 280 行

## 四、Markdown 文件翻译清单

### 批次 A14 · Markdown（一）

- [ ] `README.md` → `README_zh.md` — 原始 65 行
- [ ] `contracts/lens/README.md` → `contracts/lens/README_zh.md` — 原始 4 行

### 批次 A15 · Markdown（二）

- [ ] `bug-bounty.md` → `bug-bounty_zh.md` — 原始 80 行

## 五、无需翻译的文件

| 文件 | 行数 | 原因 |
| --- | ---: | --- |
| `.gitattributes` | 1 | 不含英文注释 |
| `.github/workflows/lint.yml` | 33 | 不含英文注释 |
| `.gitignore` | 7 | 不含英文注释 |
| `.prettierignore` | 1 | 不含英文注释 |
| `.prettierrc` | 5 | 不含英文注释 |
| `.solhint.json` | 6 | JSON 格式不支持注释 |
| `.yarnrc` | 1 | 不含英文注释 |
| `LICENSE` | 339 | 许可证法律文本，非代码注释 |
| `contracts/base/PeripheryValidationExtended.sol` | 11 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/interfaces/IWETH.sol` | 10 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/ImmutableStateTest.sol` | 8 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/MockTimeSwapRouter.sol` | 24 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/OracleSlippageTest.sol` | 62 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/PoolTicksCounterTest.sol` | 18 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/TestERC20.sol` | 10 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/TestMulticallExtended.sol` | 26 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `contracts/test/TestUniswapV3Callee.sol` | 62 | 仅含 SPDX 许可证标识注释（机器可读，不可翻译） |
| `package.json` | 68 | JSON 格式不支持注释 |
| `test/ImmutableState.spec.ts` | 58 | 不含英文注释 |
| `test/MulticallExtended.spec.ts` | 50 | 不含英文注释 |
| `test/OracleSlippage.spec.ts` | 447 | 不含英文注释 |
| `test/PeripheryPaymentsExtended.spec.ts` | 50 | 不含英文注释 |
| `test/__snapshots__/ImmutableState.spec.ts.snap` | 3 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/MixedRouteQuoterV1.spec.ts.snap` | 27 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/Multicall.spec.ts.snap` | 5 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/Path.spec.ts.snap` | 3 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/PoolAddress.spec.ts.snap` | 5 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/QuoterV2.spec.ts.snap` | 51 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/SwapRouter.gas.spec.ts.snap` | 37 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/__snapshots__/SwapRouter.spec.ts.snap` | 3 | Jest 自动生成的快照文件，头部注释为 Jest 版本标识，修改会破坏快照 |
| `test/contracts/WETH9.json` | 156 | JSON 格式不支持注释 |
| `test/shared/expandTo18Decimals.ts` | 9 | 不含英文注释 |
| `test/shared/expect.ts` | 8 | 不含英文注释 |
| `test/shared/externalFixtures.ts` | 76 | 不含英文注释 |
| `test/shared/snapshotGasCost.ts` | 27 | 不含英文注释 |
| `test/shared/ticks.ts` | 2 | 不含英文注释 |
| `tsconfig.json` | 14 | JSON 格式不支持注释 |
| `yarn.lock` | 8128 | 依赖锁文件，自动生成 |

## 六、进度日志

- 2026-11-01：完成文件统计，生成本跟踪文档；共 15 个批次，派发子代理并行翻译。
