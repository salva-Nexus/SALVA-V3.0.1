// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library PairMath {
    function _amountOut(uint256 _amountIn, uint256 _precision, uint256 _price)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return (_amountIn * _precision) / _price;
        }
    }

    function _delta(uint256 decimalsIn, uint256 decimalsOut) internal pure returns (uint256) {
        unchecked {
            return decimalsIn > decimalsOut ? decimalsIn - decimalsOut : decimalsOut - decimalsIn;
        }
    }

    function _scaleByDelta(uint256 decimalsIn, uint256 decimalsOut, uint256 amount, uint256 delta)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return decimalsIn < decimalsOut ? amount * 10 ** delta : amount / 10 ** delta;
        }
    }

    // function getAmountIn(uint256 amountOut, uint256 rate) internal pure returns (uint256 amountIn) {
    //     amountIn = (amountOut * rate) / PRECISION;
    // }
}
