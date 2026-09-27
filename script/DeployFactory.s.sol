// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { PoolFactory } from "../src/PoolFactory.sol";
import { Pool } from "../src/Pool.sol";

contract DeployFactoryScript is Script {
    function run() external {
        address multisig = address(0x01);
        address ngnPriceFeed = address(0x02);

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
