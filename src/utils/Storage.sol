// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Storage {
    address public deployer;
    bool public initialized;

    uint256 internal constant PRECISION = 10 ** 18;
    uint256 internal constant ETH_DECIMALS = 18;

    // key = keccak256(base ++ quote) -> quote amount per 1 base, scaled to 1e18
    mapping(bytes32 => uint256) public quotePricePerBase;

    function _keyPair(address _base, address _quote) internal pure returns (bytes32 k) {
        assembly ("memory-safe") {
            mstore(0x00, shl(0x60, _base))
            mstore(0x14, shl(0x60, _quote))
            k := keccak256(0x00, 0x28)
            mstore(0x20, 0x00)
        }
    }

    function _updatePrice(address _base, address _quote, uint256 _quoteForBase) internal {
        bytes32 key = _keyPair(_base, _quote);
        assembly ("memory-safe") {
            sstore(key, _quoteForBase)
        }
    }

    function _getPrice(address _base, address _quote) internal view returns (uint256 p) {
        bytes32 key = _keyPair(_base, _quote);
        assembly ("memory-safe") {
            p := sload(key)
        }
    }
}
