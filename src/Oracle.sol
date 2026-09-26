// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { View } from "./utils/View.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { INGNOracle } from "./interfaces/INGNOracle.sol";

abstract contract Oracle is View {
    function oraclePrice(address feed, bool isInverted) public view returns (uint256 price) {
        (uint256 rawPrice, uint256 decimals) = _stalenessCheck(feed);
        price = !isInverted
            ? (rawPrice * PRECISION) / (10 ** decimals)
            : (10 ** decimals * PRECISION) / rawPrice;
    }

    function _stalenessCheck(address feed) internal view returns (uint256, uint256) {
        uint8 decimals;
        if (feed == ngnPriceFeed) {
            (uint256 usdPricePerNgn, uint256 updatedAtForNgn) = INGNOracle(feed).getUsdPricePerNgn();
            decimals = INGNOracle(feed).decimals();
            if (block.timestamp - updatedAtForNgn > STALE_PRICE_THRESHOLD) {
                revert Pool__Stale_Price();
            }
            if (usdPricePerNgn == 0) revert Pool__Zero_Price();
            return (usdPricePerNgn, uint256(decimals));
        }
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            AggregatorV3Interface(feed).latestRoundData();

        decimals = AggregatorV3Interface(feed).decimals();

        if (block.timestamp - updatedAt > STALE_PRICE_THRESHOLD) {
            revert Pool__Stale_Price();
        }
        if (answeredInRound < roundId) {
            revert Pool__Stale_Price();
        }
        if (roundId == 0) {
            revert Pool__Invalid_Round();
        }
        if (answer <= 0) {
            revert Pool__Zero_Price();
        }

        return (uint256(answer), uint256(decimals));
    }
}
