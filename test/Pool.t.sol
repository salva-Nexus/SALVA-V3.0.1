// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { BaseTest } from "./BaseTest.t.sol";
import { console2 } from "forge-std/console2.sol";
import { Errors } from "../src/utils/Errors.sol";

contract Pool is BaseTest {
    function test_Initialization() public view {
        assertEq(pool.VERSION(), "v3.0.1");
        assertEq(pool.deployer(), deployer);
    }

    function test_AvailableLiquidity() public _deployInv {
        assertEq(pool.availableLiquidity(address(ngns)), 500_000 * 1e18);
        assertEq(pool.availableLiquidity(address(usdc)), 0);
    }

    function test_GetPrice_InvertedNGNFeed() public _deployInv {
        uint256 expectedPrice = (10 ** 8 * 1e18) / initialNgnUsdPrice;
        (uint256 actualPrice,) = pool.getPrice(address(ngns), address(usdc));

        assertEq(actualPrice, expectedPrice);
    }

    function test_GetPrice_WhenBelowFloor_Allowed() public _deployInv {
        ngnUsdFeed.setPrice(100000);
        uint256 expectedTarget = acquisitionPrice + (acquisitionPrice * spreadBps) / 10_000;
        (uint256 price,) = pool.getPrice(address(ngns), address(usdc));

        assertEq(price, expectedTarget);
    }

    function test_SwapExactInput_Success() public _deployInv {
        uint256 swapAmountUSDC = 100 * 1e6; // 100 USDC

        // Fund Charles with USDC
        usdc.mint(charles, swapAmountUSDC);
        _changePrank(charles);
        usdc.approve(address(pool), swapAmountUSDC);

        uint256 ngnsBefore = ngns.balanceOf(charles);
        uint256 usdcBefore = usdc.balanceOf(charles);
        uint256 expectedOut = pool.exactAmountOut(address(usdc), address(ngns), swapAmountUSDC);
        console2.log("EXPECTED NGNS OUTPUT", expectedOut);
        uint256 actualOut = pool.swapExactInput(address(usdc), address(ngns), swapAmountUSDC);

        assertEq(actualOut, expectedOut);
        assertEq(ngns.balanceOf(charles), ngnsBefore + actualOut);
        assertEq(usdc.balanceOf(charles), usdcBefore - swapAmountUSDC);
        _stopPrank();
    }

    function test_SwapExactOutput_Success() public _deployInv {
        uint256 requestedOutNGN = 50_000 * 1e18; // 50k NGNS
        uint256 requiredInUSDC = pool.exactAmountIn(address(usdc), address(ngns), requestedOutNGN);

        usdc.mint(thelma, requiredInUSDC);
        _changePrank(thelma);
        usdc.approve(address(pool), requiredInUSDC);

        uint256 actualIn = pool.swapExactOutput(address(usdc), address(ngns), requestedOutNGN);

        assertEq(actualIn, requiredInUSDC);
        assertEq(ngns.balanceOf(thelma), requestedOutNGN);
        _stopPrank();
    }

    function test_RevertIf_ZeroAmountSwap() public _deployInv {
        _changePrank(charles);
        vm.expectRevert(Errors.Pool__Zero_Amount.selector);
        pool.swapExactInput(address(usdc), address(ngns), 0);
        _stopPrank();
    }
}
