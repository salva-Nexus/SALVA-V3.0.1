// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library PairMath {
    function _amountOut(uint256 amountIn, uint256 precision, uint256 price)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return (amountIn * precision) / price;
        }
    }

    function _amountIn(uint256 amountOut, uint256 precision, uint256 price)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return (amountOut * price) / precision;
        }
    }

    function _delta(uint256 decimalsIn, uint256 decimalsOut) internal pure returns (uint256) {
        unchecked {
            return decimalsIn > decimalsOut ? decimalsIn - decimalsOut : decimalsOut - decimalsIn;
        }
    }

    function _scaleOutByDelta(
        uint256 decimalsIn,
        uint256 decimalsOut,
        uint256 amount,
        uint256 delta
    ) internal pure returns (uint256) {
        unchecked {
            return decimalsIn < decimalsOut ? amount * 10 ** delta : amount / 10 ** delta;
        }
    }

    function _scaleInByDelta(uint256 decimalsIn, uint256 decimalsOut, uint256 amount, uint256 delta)
        internal
        pure
        returns (uint256)
    {
        unchecked {
            return decimalsIn > decimalsOut ? amount * 10 ** delta : amount / 10 ** delta;
        }
    }
}
