// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { BaseTest } from "./BaseTest.t.sol";
import { console2 } from "forge-std/console2.sol";

contract Pool is BaseTest {
    function test_Initialization() public view {
        assertEq(pool.VERSION(), "v3.0.1");
        assertEq(pool.deployer(), deployer);
    }

    function test_NewInventory() public _deployInv {
        assertEq(pool.getPrice(address(ngns), address(usdc)), (10 ** 8 * 1e18) / initialUsdNgnPrice);
        assertEq(ngns.balanceOf(address(pool)), 500_000 * 1e18);
    }
}
