// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Modifier } from "./Modifier.sol";
import { View } from "./View.sol";
import { Events } from "./Events.sol";

abstract contract SwapEngine is Modifier, View, Events {
    function swapExactInput(address tokenIn, address tokenOut, uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        if (amountIn == 0) revert Pool__Zero_Amount();
        amountOut = _exactAmountOut(tokenIn, tokenOut, amountIn);
        _pull(tokenIn, _msgsender(), amountIn);
        _push(tokenOut, _msgsender(), amountOut);

        emit Swapped(_msgsender(), tokenIn, tokenOut, amountIn, amountOut);
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
