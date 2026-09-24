// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Modifier } from "./Modifier.sol";
import { View } from "./View.sol";
import { Events } from "./Events.sol";

abstract contract SwapEngine is Modifier, View, Events {
    function swapExactInput(address tokenIn, address tokenOut, uint256 amountIn)
        external
        payable
        nonReentrant
        returns (uint256 amountOut)
    {
        uint256 cacheAmountIn = amountIn == 0 ? msg.value : amountIn;
        if (cacheAmountIn == 0) revert Pool__Zero_Amount();
        amountOut = _exactAmountOut(tokenIn, tokenOut, cacheAmountIn);
        if (amountOut == 0) revert Pool__Zero_Amount();
        if (tokenIn != address(0)) {
            if (msg.value > 0) revert Pool__Amount_Mismatch();
            _pull(tokenIn, _msgsender(), cacheAmountIn);
        }
        _push(tokenOut, _msgsender(), amountOut);
        emit Swapped(_msgsender(), tokenIn, tokenOut, cacheAmountIn, amountOut);
    }

    function swapExactOutput(address tokenIn, address tokenOut, uint256 amountOut)
        external
        payable
        nonReentrant
        returns (uint256 amountIn)
    {
        uint256 cacheAmountOut = amountOut == 0 ? msg.value : amountOut;
        if (cacheAmountOut == 0) revert Pool__Zero_Amount();
        amountIn = _exactAmountIn(tokenIn, tokenOut, cacheAmountOut);
        if (amountIn == 0) revert Pool__Zero_Amount();
        if (tokenIn != address(0)) {
            if (msg.value > 0) revert Pool__Amount_Mismatch();
            _pull(tokenIn, _msgsender(), amountIn);
        }
        _push(tokenOut, _msgsender(), cacheAmountOut);
        emit Swapped(_msgsender(), tokenIn, tokenOut, amountIn, cacheAmountOut);
    }
}
