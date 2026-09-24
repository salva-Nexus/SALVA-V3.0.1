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
        if (tokenIn != address(0)) _pull(tokenIn, _msgsender(), cacheAmountIn);
        _push(tokenOut, _msgsender(), amountOut);
        emit Swapped(_msgsender(), tokenIn, tokenOut, cacheAmountIn, amountOut);
    }

    // /// @notice Swaps a dynamic input amount for an exact output amount
    // function swapExactOutput(
    //     address tokenIn,
    //     address tokenOut,
    //     uint256 amountOut,
    //     uint256 maxAmountIn
    // ) external returns (uint256 amountIn) {
    //     if (amountOut == 0) revert Pool__Zero_Amount();
    //
    //     uint256 rate = _getPrice(tokenOut, tokenIn);
    //     if (rate == 0) revert Pool__ZeroRate();
    //
    //     amountIn = PairMath.getAmountIn(amountOut, rate);
    //     if (amountIn > maxAmountIn) revert ExcessiveInput();
    //
    //     _pull(tokenIn, _msgSender(), amountIn);
    //     _push(tokenOut, _msgSender(), amountOut);
    //
    //     emit Swapped(_msgSender(), tokenIn, tokenOut, amountIn, amountOut);
    // }
}
