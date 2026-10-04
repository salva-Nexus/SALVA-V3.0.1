// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title INGNOracle
/// @notice Interface for the NGNOracle contract
interface INGNOracle {
    struct PriceConfig {
        uint256 pricePerNgn;
        uint256 updatedAt;
    }

    function decimals() external view returns (uint8);
    function getUsdPricePerNgn() external view returns (uint256 price, uint256 updatedAt);
    function getAssetPricePerNgn(address asset)
        external
        view
        returns (uint256 price, uint256 updatedAt);
}
