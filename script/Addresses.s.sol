// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Addresses {
    // ------------------------------------------------------------------------
    // Chain ID Constants
    // ------------------------------------------------------------------------
    uint256 internal constant BASE_MAINNET = 8453;
    uint256 internal constant BASE_SEPOLIA = 84532;
    uint256 internal constant BNB_MAINNET = 56;
    uint256 internal constant BNB_TESTNET = 97;

    // ------------------------------------------------------------------------
    // Internal Routing Functions
    // ------------------------------------------------------------------------

    function _multisig() internal view returns (address) {
        if (block.chainid == BASE_MAINNET) return address(0x1234);
        if (block.chainid == BASE_SEPOLIA) {
            return address(0x7Fe2bB5D44bFE124A7eDbE507035246e6327CB3A);
        }
        if (block.chainid == BNB_MAINNET) return address(0x1234);
        if (block.chainid == BNB_TESTNET) {
            return address(0x8f574842E7CC0277E9256418C46A90e3398d4005);
        }
        revert("Addresses: Unsupported Chain ID");
    }

    function _ngnOracle() internal view returns (address) {
        if (block.chainid == BASE_MAINNET) return address(0x1234);
        if (block.chainid == BASE_SEPOLIA) {
            return address(0x6b51afD271bB46C8Ff068beAa511Fee5756Fcc66);
        }
        if (block.chainid == BNB_MAINNET) return address(0x1234);
        if (block.chainid == BNB_TESTNET) {
            return address(0x9066888C32Fa7807C796c183E868ADb3A27Aa6CF);
        }
        revert("Addresses: Unsupported Chain ID");
    }
}
