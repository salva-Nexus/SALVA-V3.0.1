// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Events {
    event Swapped(
        address indexed sender,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    event LiquidityAdded(address indexed asset, uint256 amount);
    event LiquidityRemoved(address indexed asset, uint256 amount);
    event PriceUpdated(address indexed baseAsset, address indexed quoteAsset, uint256 price);
}
