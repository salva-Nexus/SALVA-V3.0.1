// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Storage {
    address public deployer;
    address public ngnPriceFeed;
    bool public initialized;

    uint256 internal constant PRECISION = 10 ** 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant STALE_PRICE_THRESHOLD = 3 hours;
    uint256 internal constant PERCENTAGE_BPS = 10_000;

    struct Inventory {
        address assetOut;
        uint96 floor;
        address assetIn;
        int96 spreadBps;
        address feed;
        uint128 baseBalance;
        uint128 quoteBalance;
        bool isInverted;
        bool allowSwapBelowFloor;
    }
    mapping(bytes32 => Inventory) private inventories;

    function _keyPair(address _base, address _quote) internal pure returns (bytes32 k) {
        assembly ("memory-safe") {
            mstore(0x00, shl(0x60, _base))
            mstore(0x14, shl(0x60, _quote))
            k := keccak256(0x00, 0x28)
            mstore(0x20, 0x00)
        }
    }

    function _updateInv(Inventory memory _inv) internal {
        bytes32 k = _keyPair(_inv.assetOut, _inv.assetIn);
        inventories[k] = _inv;
    }

    function _updateSpread(address _base, address _quote, int96 _spread) internal {
        bytes32 k = _keyPair(_base, _quote);
        inventories[k].spreadBps = _spread;
    }

    function _updateInLiquidity(address _base, address _quote, address _assetIn, uint128 _amountIn)
        internal
    {
        bytes32 k = _keyPair(_base, _quote);
        if (_assetIn == _base) {
            inventories[k].baseBalance += _amountIn;
        } else {
            inventories[k].quoteBalance += _amountIn;
        }
    }

    function _updateOutLiquidity(
        address _base,
        address _quote,
        address _assetOut,
        uint128 _amountOut
    ) internal {
        bytes32 k = _keyPair(_base, _quote);
        if (_assetOut == _base) {
            inventories[k].baseBalance -= _amountOut;
        } else {
            inventories[k].quoteBalance -= _amountOut;
        }
    }

    function _getInv(address _base, address _quote) internal view returns (Inventory memory) {
        bytes32 k = _keyPair(_base, _quote);
        return inventories[k];
    }
}
