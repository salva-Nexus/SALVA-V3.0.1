// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Modifier } from "./Modifier.sol";
import { Events } from "./Events.sol";
import { Oracle } from "../Oracle.sol";

abstract contract SwapEngine is Modifier, Oracle, Events {
    function _getPrice(address _base, address _quote)
        internal
        view
        override
        returns (uint256, bool)
    {
        Inventory memory inv = _getInv(_base, _quote);
        if (inv.feed == address(0)) return (0, inv.allowSwapBelowFloor);
        uint256 oracle = oraclePrice(
            inv.feed == ngnPriceFeed ? inv.isInverted ? inv.assetOut : inv.assetIn : address(0),
            inv.feed,
            inv.isInverted
        );
        if (oracle <= 0) return (0, inv.allowSwapBelowFloor);
        // Calculate price based on merchants spread
        uint256 price;
        if (inv.spreadBps < 0) {
            uint256 discountBps = uint256(uint96(-inv.spreadBps));
            price = oracle - (oracle * discountBps / PERCENTAGE_BPS);
        } else if (inv.spreadBps > 0) {
            uint256 premiumBps = uint256(uint96(inv.spreadBps));
            price = oracle + (oracle * premiumBps / PERCENTAGE_BPS);
        } else {
            price = oracle;
        }
        bool canSwap = inv.allowSwapBelowFloor ? true : price < inv.floor ? false : true;
        return (price, canSwap);
    }

    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external payable returns (uint256 amountOut) {
        if (amountIn > 0 && msg.value > 0) revert Pool__Amount_Mismatch();
        uint256 cacheAmountIn = amountIn == 0 ? msg.value : amountIn;
        if (cacheAmountIn == 0) revert Pool__Zero_Amount();
        amountOut = _exactAmountOut(tokenIn, tokenOut, cacheAmountIn);
        if (amountOut == 0) revert Pool__Zero_Amount();
        if (amountOut < minAmountOut) revert Pool__Slippage_Exceeded();
        if (tokenIn != address(0)) {
            if (msg.value > 0) revert Pool__Amount_Mismatch();
            _pull(tokenIn, _msgsender(), cacheAmountIn);
        }
        _push(tokenOut, _msgsender(), amountOut);
        emit Swapped(_msgsender(), tokenIn, tokenOut, cacheAmountIn, amountOut);
    }

    function swapExactOutput(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 maxAmountIn
    ) external payable returns (uint256 amountIn) {
        if (amountOut == 0) revert Pool__Zero_Amount();
        amountIn = _exactAmountIn(tokenIn, tokenOut, amountOut);
        if (amountIn == 0) revert Pool__Zero_Amount();
        if (amountIn > maxAmountIn) revert Pool__Slippage_Exceeded();

        if (tokenIn == address(0)) {
            // Native ETH input: msg.value is the max budget sent by user
            if (msg.value < amountIn) revert Pool__Insufficient_ETH();
            _push(tokenOut, _msgsender(), amountOut);
            // Refund excess ETH if msg.value was greater than exact amountIn
            uint256 refund = msg.value - amountIn;
            if (refund > 0) {
                _push(tokenIn, _msgsender(), refund);
            }
        } else {
            if (msg.value > 0) revert Pool__Amount_Mismatch();
            _pull(tokenIn, _msgsender(), amountIn);
            _push(tokenOut, _msgsender(), amountOut);
        }

        emit Swapped(_msgsender(), tokenIn, tokenOut, amountIn, amountOut);
    }
}
