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
        if (block.chainid == BASE_MAINNET) {
            return address(0xBCdE35307e897625E39915B200Be0A0a17088Da6);
        }
        if (block.chainid == BASE_SEPOLIA) {
            return address(0x7Fe2bB5D44bFE124A7eDbE507035246e6327CB3A);
        }
        if (block.chainid == BNB_MAINNET) {
            return address(0xa2B37292A360EF2E19f0ff465142752aaDFd5556);
        }
        if (block.chainid == BNB_TESTNET) {
            return address(0x8f574842E7CC0277E9256418C46A90e3398d4005);
        }
        revert("Addresses: Unsupported Chain ID");
    }

    function _ngnOracle() internal view returns (address) {
        if (block.chainid == BASE_MAINNET) {
            return address(0xf0Ed0652d5150606a84C7EF9726d9585478532Bc);
        }
        if (block.chainid == BASE_SEPOLIA) {
            return address(0x6b51afD271bB46C8Ff068beAa511Fee5756Fcc66);
        }
        if (block.chainid == BNB_MAINNET) {
            return address(0x97F0BCA29304E39936dbf4C58b887DEAE5D9A75B);
        }
        if (block.chainid == BNB_TESTNET) {
            return address(0x3Ad5c68BF82bB402F81379124DCf513015CAafF1);
        }
        revert("Addresses: Unsupported Chain ID");
    }

    function _poolFactory() internal view returns (address) {
        if (block.chainid == BASE_MAINNET) {
            return address(0x805658D6520d53ECEe0E2DA8a95Df3E55213F0fA);
        }
        if (block.chainid == BASE_SEPOLIA) {
            return address(0x2b9Bb8e60f63B886545f9C6F14a697b9C6eE45a9);
        }
        if (block.chainid == BNB_MAINNET) {
            return address(0x27BfB5f2da83c25909f272d30725D85ECC0B5920);
        }
        if (block.chainid == BNB_TESTNET) {
            return address(0xd2611e3acE93303052478af5EE5d13e2E9c63C7A);
        }
        revert("Addresses: Unsupported Chain ID");
    }
}
