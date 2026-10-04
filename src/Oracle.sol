// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { View } from "./utils/View.sol";
import {
    AggregatorV3Interface
} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { INGNOracle } from "./interfaces/INGNOracle.sol";

abstract contract Oracle is View {
    function oraclePrice(address quote, address feed, bool isInverted)
        internal
        view
        returns (uint256)
    {
        (uint256 rawPrice, uint256 decimals) = _stalenessCheck(feed, quote);
        if (rawPrice <= 0) return 0;
        return !isInverted
            ? (rawPrice * PRECISION) / (10 ** decimals)
            : (10 ** decimals * PRECISION) / rawPrice;
    }

    function _stalenessCheck(address feed, address asset) internal view returns (uint256, uint256) {
        uint8 decimals;
        if (feed == ngnPriceFeed) {
            (uint256 assetPricePerNgn, uint256 updatedAtForNgn) =
                INGNOracle(feed).getAssetPricePerNgn(asset);
            decimals = INGNOracle(feed).decimals();
            if (block.timestamp - updatedAtForNgn > STALE_PRICE_THRESHOLD) {
                return (0, 0);
            }
            if (assetPricePerNgn == 0) revert Pool__Zero_Price();
            return (assetPricePerNgn, uint256(decimals));
        }
        (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
            AggregatorV3Interface(feed).latestRoundData();

        decimals = AggregatorV3Interface(feed).decimals();
        if (block.timestamp - updatedAt > STALE_PRICE_THRESHOLD) return (0, 0);
        if (answeredInRound < roundId) return (0, 0);
        if (roundId == 0) return (0, 0);
        if (answer <= 0) return (0, 0);
        return (uint256(answer), uint256(decimals));
    }
}
