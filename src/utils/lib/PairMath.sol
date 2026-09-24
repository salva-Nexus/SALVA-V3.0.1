// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library PairMath {
    // Was referenced but never declared inside the library. A library has
    // no access to a contract's state, even one named identically
    // (Storage.PRECISION) — it needs its own constant.
    uint256 internal constant PRECISION = 1e18;

    function _amountOut(uint256 _amountIn, uint256 _price) internal pure returns (uint256) {
        // Was using the unscoped name `amountIn`, which doesn't exist —
        // the parameter here is `_amountIn`.
        return (_amountIn * PRECISION) / _price;
    }

    function _delta(uint256 decimalsIn, uint256 decimalsOut) internal pure returns (uint256) {
        return decimalsIn > decimalsOut ? decimalsIn - decimalsOut : decimalsOut - decimalsIn;
    }

    function _scaleByDelta(uint256 decimalsIn, uint256 decimalsOut, uint256 amount, uint256 delta)
        internal
        pure
        returns (uint256)
    {
        return decimalsIn < decimalsOut ? amount * 10 ** delta : amount / 10 ** delta;
    }

    // Kept for the commented-out swapExactOutput path in SwapEngine.sol.
    function getAmountIn(uint256 amountOut, uint256 rate) internal pure returns (uint256 amountIn) {
        amountIn = (amountOut * rate) / PRECISION;
    }
}
