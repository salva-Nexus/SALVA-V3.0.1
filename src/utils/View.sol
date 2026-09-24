// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { PairMath } from "./lib/PairMath.sol";
import { Storage } from "./Storage.sol";
import { Errors } from "./Errors.sol";
import { TokenGateway } from "./TokenGateway.sol";

abstract contract View is Storage, Errors, TokenGateway {
    function availableLiquidity(address asset) external view returns (uint256) {
        return _balanceOf(asset, address(this));
    }

    function exactAmountOut(address tokenIn, address tokenOut, uint256 amountIn)
        public
        view
        returns (uint256)
    {
        return _exactAmountOut(tokenIn, tokenOut, amountIn);
    }

    function _exactAmountOut(address tokenIn, address tokenOut, uint256 amountIn)
        internal
        view
        returns (uint256)
    {
        uint256 price = _getPrice(tokenOut, tokenIn);
        if (price == 0) revert Pool__Zero_Price();

        uint256 decimalsIn = _decimalsOf(tokenIn);
        uint256 decimalsOut = _decimalsOf(tokenOut);

        uint256 delta = PairMath._delta(decimalsIn, decimalsOut);
        uint256 rawAmountOut = PairMath._amountOut(amountIn, PRECISION, price);

        return delta == 0
            ? rawAmountOut
            : PairMath._scaleByDelta(decimalsIn, decimalsOut, rawAmountOut, delta);
    }
}
