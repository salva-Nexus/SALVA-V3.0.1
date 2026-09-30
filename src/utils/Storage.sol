// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Storage {
    address public deployer;
    address public ngnPriceFeed;
    bool public initialized;

    uint256 internal constant PRECISION = 10 ** 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 internal constant STALE_PRICE_THRESHOLD = 3 hours;

    struct Inventory {
        address assetOut;
        uint96 floor;
        address assetIn;
        bool allowSwapBelowFloor;
        address feed;
        bool isInverted;
    }

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
        address assetOut = _inv.assetOut;
        uint256 floor = _inv.floor;
        address assetIn = _inv.assetIn;
        bool allowSwapBelowFloor = _inv.allowSwapBelowFloor;
        address feed = _inv.feed;
        bool isInverted = _inv.isInverted;

        assembly ("memory-safe") {
            sstore(k, or(shl(0x60, assetOut), floor))
            sstore(add(k, 1), or(shl(0x60, assetIn), allowSwapBelowFloor))
            sstore(add(k, 2), or(shl(0x60, feed), isInverted))
        }
    }

    function _getInv(address _base, address _quote) internal view returns (Inventory memory inv) {
        bytes32 k = _keyPair(_base, _quote);

        address _assetOut;
        uint96 _floor;
        address _assetIn;
        bool _allowSwapBelowFloor;
        address _feed;
        bool _isInverted;

        assembly ("memory-safe") {
            let slot0 := sload(k)
            let slot1 := sload(add(k, 1))
            let slot2 := sload(add(k, 2))

            _assetOut := shr(0x60, slot0)
            _floor := and(slot0, 0xffffffffffffffffffffffffffff)
            _assetIn := shr(0x60, slot1)
            _allowSwapBelowFloor := and(slot1, 0xff)
            _feed := shr(0x60, slot2)
            _isInverted := and(slot2, 0xff)
        }

        inv = Inventory({
            assetOut: _assetOut,
            floor: _floor,
            assetIn: _assetIn,
            allowSwapBelowFloor: _allowSwapBelowFloor,
            feed: _feed,
            isInverted: _isInverted
        });
    }
}
