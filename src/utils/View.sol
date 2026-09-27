// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { PairMath } from "./lib/PairMath.sol";
import { Storage } from "./Storage.sol";
import { Errors } from "./Errors.sol";
import { TokenGateway } from "./TokenGateway.sol";

abstract contract View is Storage, Errors, TokenGateway {
    function _getPrice(address _base, address _quote) internal view virtual returns (uint256);

    function getPrice(address _base, address _quote) external view returns (uint256) {
        return _getPrice(_base, _quote);
    }

    function getInventory(address _base, address _quote)
        public
        view
        returns (Inventory memory inv)
    {
        inv = _getInv(_base, _quote);
    }

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
        if (price == 0) return 0;
        uint256 decimalsIn = tokenIn == address(0) ? ETH_DECIMALS : _decimalsOf(tokenIn);
        uint256 decimalsOut = tokenOut == address(0) ? ETH_DECIMALS : _decimalsOf(tokenOut);
        uint256 delta = PairMath._delta(decimalsIn, decimalsOut);
        uint256 rawAmountOut = PairMath._amountOut(amountIn, PRECISION, price);
        return delta == 0
            ? rawAmountOut
            : PairMath._scaleOutByDelta(decimalsIn, decimalsOut, rawAmountOut, delta);
    }

    function exactAmountIn(address tokenIn, address tokenOut, uint256 amountOut)
        public
        view
        returns (uint256)
    {
        return _exactAmountIn(tokenIn, tokenOut, amountOut);
    }

    function _exactAmountIn(address tokenIn, address tokenOut, uint256 amountOut)
        internal
        view
        returns (uint256)
    {
        uint256 price = _getPrice(tokenOut, tokenIn);
        if (price == 0) return 0;
        uint256 decimalsIn = tokenIn == address(0) ? ETH_DECIMALS : _decimalsOf(tokenIn);
        uint256 decimalsOut = tokenOut == address(0) ? ETH_DECIMALS : _decimalsOf(tokenOut);
        uint256 delta = PairMath._delta(decimalsIn, decimalsOut);
        uint256 rawAmountIn = PairMath._amountIn(amountOut, PRECISION, price);
        return delta == 0
            ? rawAmountIn
            : PairMath._scaleInByDelta(decimalsIn, decimalsOut, rawAmountIn, delta);
    }
}
