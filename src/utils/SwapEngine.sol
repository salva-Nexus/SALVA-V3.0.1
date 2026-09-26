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
        returns (uint256 price)
    {
        Inventory memory inv = _getInv(_base, _quote);
        if (inv.feed == address(0)) return 0;
        uint256 oracle = oraclePrice(inv.feed, inv.isInverted);
        uint256 target = uint256(inv.floor) + (uint256(inv.floor) * inv.spreadBps) / SPREAD_BPS;
        if (oracle < target) {
            return inv.allowSwapBelowFloor ? target : 0;
        }
        return oracle;
    }

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
