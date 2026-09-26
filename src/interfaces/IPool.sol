// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPool {
    function initialize(address deployer, address ngnPriceFeed) external;
}
