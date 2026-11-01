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

- [x] `contracts/V3SwapRouter.sol` — 原始 238 行 → 译后 238 行（改动 23 行注释）✅
- [x] `contracts/V2SwapRouter.sol` — 原始 94 行 → 译后 94 行（改动 8 行注释）✅
- [x] `contracts/SwapRouter02.sol` — 原始 22 行 → 译后 22 行（改动 1 行注释）✅

### 批次 A2 · base 合约（一）

- [x] `contracts/base/ApproveAndCall.sol` — 原始 126 行 → 译后 126 行（改动 10 行注释）✅
- [x] `contracts/base/ImmutableState.sol` — 原始 18 行 → 译后 18 行（改动 2 行注释）✅
- [x] `contracts/base/MulticallExtended.sol` — 原始 34 行 → 译后 34 行（改动 1 行注释）✅
- [x] `contracts/base/PeripheryPaymentsExtended.sol` — 原始 29 行 → 译后 29 行（改动 0 行注释：仅含 `@inheritdoc`，按规则保留）✅
- [x] `contracts/base/PeripheryPaymentsWithFeeExtended.sol` — 原始 32 行 → 译后 32 行（改动 0 行注释：仅含 `@inheritdoc`，按规则保留）✅

### 批次 A3 · base 合约（二）与库

- [x] `contracts/base/OracleSlippage.sol` — 原始 171 行 → 译后 171 行（改动 26 行注释）✅
- [x] `contracts/libraries/Constants.sol` — 原始 15 行 → 译后 15 行（改动 5 行注释）✅
- [x] `contracts/libraries/PoolTicksCounter.sol` — 原始 96 行 → 译后 96 行（改动 16 行注释）✅
- [x] `contracts/libraries/UniswapV2Library.sol` — 原始 90 行 → 译后 90 行（改动 7 行注释）✅

### 批次 A4 · 接口（一）

- [x] `contracts/interfaces/IApproveAndCall.sol` — 原始 63 行 → 译后 63 行（改动 21 行注释）✅
- [x] `contracts/interfaces/IImmutableState.sol` — 原始 12 行 → 译后 12 行（改动 4 行注释）✅
- [x] `contracts/interfaces/IMixedRouteQuoterV1.sol` — 原始 72 行 → 译后 72 行（改动 32 行注释）✅
- [x] `contracts/interfaces/IMulticallExtended.sol` — 原始 26 行 → 译后 26 行（改动 12 行注释）✅
- [x] `contracts/interfaces/IOracleSlippage.sol` — 原始 31 行 → 译后 31 行（改动 13 行注释）✅

### 批次 A5 · 接口（二）

- [x] `contracts/interfaces/IPeripheryPaymentsExtended.sol` — 原始 29 行 → 译后 29 行（改动 15 行注释）✅
- [x] `contracts/interfaces/IPeripheryPaymentsWithFeeExtended.sol` — 原始 29 行 → 译后 29 行（改动 8 行注释）✅
- [x] `contracts/interfaces/IQuoter.sol` — 原始 51 行 → 译后 51 行（改动 26 行注释）✅
- [x] `contracts/interfaces/IQuoterV2.sol` — 原始 98 行 → 译后 98 行（改动 41 行注释）✅

### 批次 A6 · 接口（三）

- [x] `contracts/interfaces/ISwapRouter02.sol` — 原始 15 行 → 译后 15 行（改动 1 行注释）✅
- [x] `contracts/interfaces/ITokenValidator.sol` — 原始 50 行 → 译后 50 行（改动 31 行注释）✅
- [x] `contracts/interfaces/IV2SwapRouter.sol` — 原始 35 行 → 译后 35 行（改动 16 行注释）✅
- [x] `contracts/interfaces/IV3SwapRouter.sol` — 原始 69 行 → 译后 69 行（改动 20 行注释）✅

### 批次 A7 · lens 合约（一）

- [x] `contracts/lens/MixedRouteQuoterV1.sol` — 原始 237 行 → 译后 237 行（改动 20 行注释）✅
- [x] `contracts/lens/Quoter.sol` — 原始 170 行 → 译后 170 行（改动 16 行注释）✅

### 批次 A8 · lens 合约（二）

- [x] `contracts/lens/QuoterV2.sol` — 原始 273 行 → 译后 273 行（改动 16 行注释）✅
- [x] `contracts/lens/TokenValidator.sol` — 原始 159 行 → 译后 159 行（改动 25 行注释）✅

### 批次 A9 · 测试辅助、配置与 CI

- [x] `contracts/test/MockObservations.sol` — 原始 77 行 → 译后 77 行（改动 2 行注释）✅
- [x] `test/shared/completeFixture.ts` — 原始 36 行 → 译后 36 行（改动 1 行注释）✅
- [x] `test/shared/computePoolAddress.ts` — 原始 22 行 → 译后 22 行（改动 2 行注释）✅
- [x] `test/shared/constants.ts` — 原始 21 行 → 译后 21 行（改动 0 行注释：仅含表达式注释 `// 1 << 23`）✅
- [x] `test/shared/encodePriceSqrt.ts` — 原始 16 行 → 译后 16 行（改动 1 行注释）✅
- [x] `test/shared/path.ts` — 原始 61 行 → 译后 61 行（改动 6 行注释）✅
- [x] `test/shared/quoter.ts` — 原始 160 行 → 译后 160 行（改动 4 行注释）✅
- [x] `hardhat.config.ts` — 原始 70 行 → 译后 70 行（改动 2 行注释）✅
- [x] `.github/workflows/release.yml` — 原始 45 行 → 译后 45 行（改动 3 行注释）✅
- [x] `.github/workflows/tests.yml` — 原始 41 行 → 译后 41 行（改动 2 行注释）✅

### 批次 A10 · 测试（SwapRouter 主测试）

- [x] `test/SwapRouter.spec.ts` — 原始 1623 行 → 译后 1623 行（改动 72 行注释）✅

### 批次 A11 · 测试（一）

- [x] `test/ApproveAndCall.spec.ts` — 原始 388 行 → 译后 388 行（改动 25 行注释）✅
- [x] `test/TokenValidator.spec.ts` — 原始 158 行 → 译后 158 行（改动 8 行注释）✅
- [x] `test/SwapRouter.gas.spec.ts` — 原始 470 行 → 译后 470 行（改动 9 行注释）✅

### 批次 A12 · 测试（二）

- [x] `test/MixedRouteQuoterV1.spec.ts` — 原始 460 行 → 译后 460 行（改动 22 行注释）✅
- [x] `test/MixedRouteQuoterV1.integ.ts` — 原始 184 行 → 译后 184 行（改动 11 行注释）✅

### 批次 A13 · 测试（三）

- [x] `test/QuoterV2.spec.ts` — 原始 578 行 → 译后 578 行（改动 15 行注释）✅
- [x] `test/Quoter.spec.ts` — 原始 201 行 → 译后 201 行（改动 2 行注释）✅
- [x] `test/PoolTicksCounter.spec.ts` — 原始 280 行 → 译后 280 行（改动 1 行注释）✅

## 四、Markdown 文件翻译清单

### 批次 A14 · Markdown（一）

- [x] `README.md` → `README_zh.md` — 原始 65 行 → 译件 65 行 ✅
- [x] `contracts/lens/README.md` → `contracts/lens/README_zh.md` — 原始 4 行 → 译件 4 行 ✅

### 批次 A15 · Markdown（二）

- [x] `bug-bounty.md` → `bug-bounty_zh.md` — 原始 80 行 → 译件 80 行 ✅

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
- 2026-11-01：批次 A13 完成，3 个文件通过校验并勾选。
- 2026-11-01：批次 A10 完成，1 个文件通过校验并勾选。
- 2026-11-01：批次 A1 完成，3 个文件通过校验并勾选。
- 2026-11-01：批次 A2 完成，5 个文件通过校验并勾选。
- 2026-11-01：批次 A12 完成，2 个文件通过校验并勾选。
- 2026-11-01：批次 A14 完成，2 个文件通过校验并勾选。
- 2026-11-01：批次 A11 完成，3 个文件通过校验并勾选。
- 2026-11-01：批次 A8 完成，2 个文件通过校验并勾选。
- 2026-11-01：批次 A7 完成，2 个文件通过校验并勾选。
- 2026-11-01：批次 A15 完成，1 个文件通过校验并勾选。
- 2026-11-01：批次 A6 完成，4 个文件通过校验并勾选。
- 2026-11-01：批次 A9 完成，10 个文件通过校验并勾选。
- 2026-11-01：批次 A4 完成，5 个文件通过校验并勾选。
- 2026-11-01：批次 A5 完成，4 个文件通过校验并勾选。
- 2026-11-01：批次 A3 完成，4 个文件通过校验并勾选。
- 2026-11-01：全部 15 个批次完成（48 个源文件 + 3 个 Markdown 译件）；主代理完成全量校验，派发验证子代理进行编译与字节码对比。

## 七、全局校验结果

| 校验项 | 方法 | 结果 |
| --- | --- | --- |
| 行数不变 | 逐文件对比 HEAD 与工作区行数（`check_comments.py`） | 48/48 源文件一致；3/3 译件与原件行数一致 |
| 只改注释 | 按行剥离注释（识别 `//`、`/* */`、YAML `#`，跳过字符串）后比较代码骨架 | 48/48 通过，代码、字符串、测试名均未改动 |
| SPDX / 换行 | SPDX 行逐字对比；检查 CRLF 与文件末尾换行 | 全部通过 |
| NatSpec 标签 | 逐行比较 `@tag` 序列、`@param` 参数名、`@inheritdoc` 整行 | 全部一致 |
| 原 Markdown 未改 | `git diff` 检查 `README.md` / `bug-bounty.md` / `contracts/lens/README.md` | 原件未改动 |
| 编译与字节码 | solc 0.7.6 分别编译翻译前后的 `contracts/`，对比字节码 | 进行中 |

## 八、翻译备注

**保留未译的注释（有意为之）**

- `contracts/base/MulticallExtended.sol` 第 10 行 `/// @title Multicall`：合约名，按规则保留。
- `contracts/lens/TokenValidator.sol` 第 30 行：纯 URL 注释。
- `contracts/test/MockObservations.sol` 中 `// slot0`；`test/shared/constants.ts` 中 `// 1 << 23`；`test/PoolTicksCounter.spec.ts` 中 `// 1100` / `// 1101`；`test/Quoter*.spec.ts` / `test/MixedRouteQuoterV1.spec.ts` 中 `// -2%` / `// +2%`；`test/MixedRouteQuoterV1.integ.ts` 中 `// V3 - V2` 等路由标记；`test/SwapRouter.spec.ts` 中路径示意图（如 `// 0 → 1 → 2`）；`test/TokenValidator.spec.ts` 中仅含代币符号的行尾注释：均为数值、标识符或示意，无英文句子。
- `README_zh.md` 代码块中被注释掉的代码 `// router.exactInput(...);` 保持原样。

**原文疑点（按原文忠实翻译，未擅自更正）**

- `test/shared/path.ts`：注释写读取 "2 bytes" 作为手续费，但代码按 `FEE_SIZE` 实际读取 3 个字节。
- `contracts/libraries/PoolTicksCounter.sol` 第 31 行：注释称 tickAfter 已初始化时"只有向下兑换才计入"，与同函数 `@dev` 及第 32–34 行注释、代码逻辑（向下兑换时不计入）相反。
- `contracts/interfaces/IV3SwapRouter.sol`：`exactOutputSingle` / `exactOutput` 的 `@notice` 原文续行为半句，译文按原文语法直译。

**术语补充（术语表外，已在各文件统一）**

- position manager → 头寸管理器（首次出现括注英文）；artifact → 构件；IL routes → IL 路由（保留缩写）；非标准标签 `@define` / `@deprecated` 保留不译。
