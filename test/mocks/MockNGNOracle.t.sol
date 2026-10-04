// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { MockV3Aggregator } from "./MockV3Aggregator.t.sol";

contract MockNGNOracle {
    uint8 public constant decimals = 18;
    uint256 internal pricePerNgn;
    uint256 internal updatedAt;

    mapping(address => address) public tokenToUsdFeed;

    constructor(uint256 initialPrice) {
        pricePerNgn = initialPrice;
        updatedAt = block.timestamp;
    }

    function updatePrice(uint256 newPrice) external returns (bool) {
        pricePerNgn = newPrice;
        updatedAt = block.timestamp;
        return true;
    }

    function setTokenUsdFeed(address token, address feed) external {
        tokenToUsdFeed[token] = feed;
    }

    function getUsdPricePerNgn() external view returns (uint256 price, uint256 timestamp) {
        return (pricePerNgn, updatedAt);
    }

    function getAssetPricePerNgn(address asset) external view returns (uint256, uint256) {
        address feed = tokenToUsdFeed[asset];
        require(feed != address(0), "FeedNotFound");
        MockV3Aggregator priceFeed = MockV3Aggregator(feed);
        (, int256 rawPrice,,,) = priceFeed.latestRoundData();
        require(rawPrice > 0, "InvalidFeedResponse");

        uint8 feedDecimals = priceFeed.decimals();
        uint256 tokenUsdPrice = uint256(rawPrice);
        uint256 flippedTokenPrice = (10 ** (feedDecimals + decimals)) / tokenUsdPrice;
        return ((flippedTokenPrice * pricePerNgn) / (10 ** 18), updatedAt);
    }
}
