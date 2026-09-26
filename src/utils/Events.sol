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
    event InventoryAdded(
        address indexed base,
        address indexed quote,
        address indexed feed,
        uint256 floor,
        uint256 spread,
        uint256 amount
    );
    event LiquidityRemoved(address indexed asset, uint256 amount);
    event PriceUpdated(address indexed baseAsset, address indexed quoteAsset, uint256 price);
}
