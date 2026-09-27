<div align="center">

<h1>⇄ SALVA PEX</h1>

</div>

---

## 🧭 What is Salva PEX?

Salva PEX is a **peer-to-peer exchange** for swapping crypto assets — built so that anyone, anywhere, can either **trade** or **become the market** for a pair of assets, without needing a centralized exchange, an order book, or anyone's permission.

### 🛍️ If you're a trader

- You swap directly against a pool's own liquidity — instantly, at a price the pool owner has configured.
- You always know your worst-case price before you swap (slippage protection).
- You can pay in, or receive, plain crypto or native ETH — whichever the pool supports.

### 🏦 If you're a liquidity provider (market maker)

- **Anyone can open a pool.** No listing process, no approval from Salva, no gatekeeping.
- **You set your own price floor and spread.** Your pool follows the live market price, but it will never sell below the floor you chose.
- **You keep full control of your funds.** Only you can add or remove liquidity from your own pool
- **You decide your own risk.** Want your pool to keep quoting even below your floor in a fast market? You can allow that too.

---

## 🛠️ For Developers

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `cast`, `anvil`)
- Git

### Setup

```bash
git clone https://github.com/salva-Nexus/SALVA-V3.0.1.git
cd SALVA-V3.0.1
forge install
```

### Build & Test

```bash
forge build
forge test -vvv
```

### Contract Overview

| Contract | Purpose |
|---|---|
| `PoolFactory` | Deploys a minimal-proxy `Pool` clone per liquidity provider via `deployPool()` |
| `Pool` | A single provider's exchange — inventory, pricing, and swaps live here |
| `SwapEngine` | Core swap logic (`swapExactInput`, `swapExactOutput`) and price resolution |
| `Oracle` | Reads and normalizes external price feed data |

### Key Entry Points

```solidity
// Spin up your own pool
address myPool = poolFactory.deployPool();

// List an ERC-20 <-> ERC-20 inventory (floor-protected)
Pool(myPool).deployInv(assetIn, assetOut, feed, floor, spreadBps, amount, allowSwapBelowFloor, isInverted);

// List an inventory where you provide native ETH as the outgoing asset
Pool(myPool).deployInvETH{ value: amount }(assetIn, feed, floor, spreadBps, allowSwapBelowFloor, isInverted);

// Swap
Pool(myPool).swapExactInput(tokenIn, tokenOut, amountIn, minAmountOut);
Pool(myPool).swapExactOutput(tokenIn, tokenOut, amountOut, maxAmountIn);

// Manage your own liquidity
Pool(myPool).removeLiquidity(asset, amount);
Pool(myPool).removeLiquidityETH(amount);
```

> `tokenIn` / `tokenOut` use `address(0)` to represent native ETH.

---

<div align="center">

<sub>Built for the Salva Nexus ecosystem</sub>

</div>