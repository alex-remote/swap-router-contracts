# Uniswap 兑换路由合约

[![Tests](https://github.com/Uniswap/swap-router-contracts/workflows/Tests/badge.svg)](https://github.com/Uniswap/swap-router-contracts/actions?query=workflow%3ATests)
[![Lint](https://github.com/Uniswap/swap-router-contracts/workflows/Lint/badge.svg)](https://github.com/Uniswap/swap-router-contracts/actions?query=workflow%3ALint)

本仓库包含用于在 Uniswap V2 和 V3 协议上进行兑换的智能合约。

## 漏洞赏金

本仓库适用 Uniswap V3 漏洞赏金计划，
具体依据[此处](./bug-bounty.md)所定义的条款。

## 本地部署

如需将此代码部署到本地测试网，应安装 npm 包
`@uniswap/swap-router-contracts`
并从位于以下路径的构件（artifacts）中导入字节码：
`@uniswap/swap-router-contracts/artifacts/contracts/*/*.json`。
例如：

```typescript
import {
  abi as SWAP_ROUTER_ABI,
  bytecode as SWAP_ROUTER_BYTECODE,
} from '@uniswap/swap-router-contracts/artifacts/contracts/SwapRouter02.sol/SwapRouter02.json'

// 部署字节码
```

这样可以确保你测试时所用的字节码与已部署到
主网和公共测试网的字节码完全相同，并且所有 Uniswap 代码都能与
你的本地部署正确地互操作。

## 使用 Solidity 接口

兑换路由合约的接口可供 Solidity 智能合约导入，
通过 npm 构件 `@uniswap/swap-router-contracts` 获取，例如：

```solidity
import '@uniswap/swap-router-contracts/contracts/interfaces/ISwapRouter02.sol';

contract MyContract {
  ISwapRouter02 router;

  function doSomethingWithSwapRouter() {
    // router.exactInput(...);
  }
}

```

## 测试

部分测试使用 Hardhat 主网分叉（mainnet forking），因此需要归档节点。
可以在工作区根目录下创建一个 `.env` 文件，其内容为：

```
ARCHIVE_RPC_URL='...'
```

或者在运行测试时设置该变量：

```
export ARCHIVE_RPC_URL='...' && npm run test
```
