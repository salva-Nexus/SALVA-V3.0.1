// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { PoolFactory } from "../src/PoolFactory.sol";
import { Pool } from "../src/Pool.sol";
import { Addresses } from "./Addresses.s.sol";

contract DeployFactoryScript is Script, Addresses {
    function run() external {
        address multisig = _multisig();
        address ngnPriceFeed = _ngnOracle();

        vm.startBroadcast();
        Pool poolImplementation = new Pool();
        console.log("Pool Implementation deployed at:", address(poolImplementation));
        PoolFactory factory = new PoolFactory(multisig, ngnPriceFeed, address(poolImplementation));
        console.log("-----------------------------------------");
        console.log("PoolFactory deployed at:", address(factory));
        console.log("-----------------------------------------");
        vm.stopBroadcast();
    }
}
