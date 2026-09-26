// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MockNGNOracle {
    uint256 public pricePerNgn;
    uint256 public updatedAt;
    uint8 public constant decimals = 8;

    constructor(uint256 initialPrice) {
        pricePerNgn = initialPrice;
        updatedAt = block.timestamp;
    }

    function getUsdPricePerNgn() external view returns (uint256 price, uint256 updatedAtTimestamp) {
        return (pricePerNgn, updatedAt);
    }

    function setPrice(uint256 newPrice) external {
        pricePerNgn = newPrice;
        updatedAt = block.timestamp;
    }

    function setPriceAndTimestamp(uint256 newPrice, uint256 newUpdatedAt) external {
        pricePerNgn = newPrice;
        updatedAt = newUpdatedAt;
    }
}
