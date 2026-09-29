// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { PoolFactory } from "../src/PoolFactory.sol";
import { Pool } from "../src/Pool.sol";
import { Addresses } from "./Addresses.s.sol";

contract DeployFactory is Script, Addresses {
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

        // BASE TESTNET => 0xe24CC0c10E226fc9d2ec1B338b36cD867a7bAACd
        // BNB TESTNET => 0x3689459CB769140A7221b3299BD087fA7000D606
    }
}
