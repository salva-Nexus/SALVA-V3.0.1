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

        // BASE TESTNET => 0x30E58a3f4ed3968dd2181A472eD88AfdD8a688BF
        // BNB TESTNET => 0xfcf3080E29b153db281F203F2aCB7Ea61dEf8eA3
    }
}
