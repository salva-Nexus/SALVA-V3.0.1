// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { BaseTest } from "./BaseTest.t.sol";
import { console2 } from "forge-std/console2.sol";
import { Errors } from "../src/utils/Errors.sol";
import { Pool } from "../src/Pool.sol";

contract PoolTest is BaseTest {
    function test_Initialization() public view {
        assertEq(pool.VERSION(), "v3.0.1");
        assertEq(pool.deployer(), deployer);
    }

    function test_AvailableLiquidity() public _deployInv {
        assertEq(pool.availableLiquidity(address(ngns)), 500_000 * 1e18);
        assertEq(pool.availableLiquidity(address(usdc)), 0);
    }

    function test_SwapExactInput_Success() public _deployInv {
        uint256 swapAmountUSDC = 100 * 1e6;
        _changePrank(charles);
        uint256 ngnsBefore = ngns.balanceOf(charles);
        uint256 usdcBefore = usdc.balanceOf(charles);
        uint256 expectedOut = pool.exactAmountOut(address(usdc), address(ngns), swapAmountUSDC);
        console2.log("EXPECTED NGNS OUTPUT", expectedOut);
        uint256 actualOut =
            pool.swapExactInput(address(usdc), address(ngns), swapAmountUSDC, expectedOut);
        assertEq(actualOut, expectedOut);
        assertEq(ngns.balanceOf(charles), ngnsBefore + actualOut);
        assertEq(usdc.balanceOf(charles), usdcBefore - swapAmountUSDC);
        _stopPrank();
    }

    function test_SwapExactOutput_Success() public _deployInv {
        uint256 requestedOutNGN = 119047 * 1e18; // 50k NGNS
        uint256 requiredInUSDC = pool.exactAmountIn(address(usdc), address(ngns), requestedOutNGN);
        console2.log("EXPECTED USDC INPUT", requiredInUSDC);
        _changePrank(thelma);
        uint256 actualIn =
            pool.swapExactOutput(address(usdc), address(ngns), requestedOutNGN, requiredInUSDC);
        assertEq(actualIn, requiredInUSDC);
        _stopPrank();
    }

    function test_RevertIf_ZeroAmountSwap() public _deployInv {
        _changePrank(charles);
        vm.expectRevert(Errors.Pool__Zero_Amount.selector);
        pool.swapExactInput(address(usdc), address(ngns), 0, 0);
        _stopPrank();
    }

    function testFuzz_SwapExactInput_QuoteMatchesExecution(uint256 amountIn) public _deployInv {
        amountIn = bound(amountIn, 1e6, 400 * 1e6);
        _changePrank(charles);
        uint256 expectedOut = pool.exactAmountOut(address(usdc), address(ngns), amountIn);
        vm.assume(expectedOut > 0);
        uint256 ngnsBefore = ngns.balanceOf(charles);
        uint256 actualOut = pool.swapExactInput(address(usdc), address(ngns), amountIn, expectedOut);
        assertEq(actualOut, expectedOut, "quote/execution mismatch");
        assertEq(ngns.balanceOf(charles), ngnsBefore + actualOut);
        _stopPrank();
    }

    function test_RevertIf_PriceBelowFloor_WhenDisallowed() public {
        _changePrank(deployer);
        uint256 depositAmount = 500_000 * 1e18;
        pool.deployInv(
            address(usdc),
            address(ngns),
            address(ngnUsdFeed),
            9000000000000000,
            spreadBps,
            depositAmount,
            false,
            false
        );
        _stopPrank(); // 90000000000000
        (uint256 price, bool allow) = pool.getPrice(address(ngns), address(usdc));
        console2.log(price, acquisitionPrice);
        assertFalse(allow);

        _changePrank(charles);
        vm.expectRevert(Errors.Pool__Zero_Amount.selector);
        pool.swapExactInput(address(usdc), address(ngns), 100 * 1e6, 0);
        _stopPrank();
    }

    function test_SwapSucceeds_BelowFloor_WhenAllowed_ClampsToTarget() public _deployInv {
        _changePrank(deployer);
        ngnUsdFeed.updatePrice(1e15);
        _changePrank(charles);
        pool.swapExactInput(address(usdc), address(ngns), 100 * 1e6, 0);
        _stopPrank();
    }

    function test_DecimalScaling_SmallestUnitUSDCIn() public _deployInv {
        uint256 out = pool.exactAmountOut(address(usdc), address(ngns), 1);
        console2.log("1 unit USDC in => NGNS out:", out);
        assertLt(out, 10_000 * 1e18, "decimal scaling bug: tiny input produced huge output");
    }

    function test_RevertIf_SwapExceedsAvailableLiquidity() public _deployInv {
        uint256 available = pool.availableLiquidity(address(ngns));
        uint256 tooMuchOut = available + 1e18;
        uint256 requiredIn = pool.exactAmountIn(address(usdc), address(ngns), tooMuchOut);
        _changePrank(deployer);
        vm.expectRevert();
        pool.swapExactOutput(address(usdc), address(ngns), tooMuchOut, requiredIn);
        _stopPrank();
    }

    function test_RevertIf_SlippageExceeded_ExactInput() public _deployInv {
        ngnUsdFeed.updatePrice(11e14);
        _changePrank(charles);
        uint256 quoted = pool.exactAmountOut(address(usdc), address(ngns), 100 * 1e6);
        uint256 slippageBps = 100;
        uint256 slippageAmount = (quoted * slippageBps) / 10000;
        // NGN Strengthens, but that's not what i saw to receive
        ngnUsdFeed.updatePrice(12e14);
        vm.expectRevert(Errors.Pool__Slippage_Exceeded.selector);
        pool.swapExactInput(address(usdc), address(ngns), 100 * 1e6, quoted - slippageAmount);
        _stopPrank();
    }

    function test_RevertIf_SlippageExceeded_ExactOutput() public _deployInv {
        uint256 requestedOut = 10_000 * 1e18;
        uint256 requiredIn = pool.exactAmountIn(address(usdc), address(ngns), requestedOut);
        uint256 slippageBps = 100;
        uint256 slippageAmount = (requiredIn * slippageBps) / 10000;
        ngnUsdFeed.updatePrice(1000000000000000);
        _changePrank(thelma);
        vm.expectRevert(Errors.Pool__Slippage_Exceeded.selector);
        pool.swapExactOutput(
            address(usdc), address(ngns), requestedOut, requiredIn + slippageAmount
        );
        _stopPrank();
    }

    function test_DeployInvETH_And_SwapExactInput_WithETH() public {
        _changePrank(deployer);
        pool.deployInv{ value: 10 ether }(
            address(usdc), address(0), address(ethUsdFeed), 1800e18, spreadBps, 0, true, false
        );
        _stopPrank();

        _changePrank(charles);
        uint256 quoted = pool.exactAmountOut(address(usdc), address(0), 2000e6);
        console2.log("QUOTE: ", quoted);
        vm.assume(quoted > 0);
        uint256 ethBefore = charles.balance;
        uint256 usdcBefore = usdc.balanceOf(charles);

        uint256 exQuote = pool.swapExactInput(address(usdc), address(0), 2000e6, quoted);
        console2.log("EX QUOTE: ", exQuote);
        assertEq(charles.balance, ethBefore + quoted);
        assertEq(usdc.balanceOf(charles), usdcBefore - 2000e6);
        _stopPrank();
    }

    function test_SwapExactInput_NativeETH_ViaMsgValue() public {
        uint256 ethIn = 1 ether;

        _changePrank(deployer);
        pool.deployInv(
            address(0),
            address(usdc),
            address(ethUsdFeed),
            5e14,
            spreadBps,
            1_000_000 * 1e6,
            true,
            true
        );
        _stopPrank();

        _changePrank(charles);
        uint256 quoted = pool.exactAmountOut(address(0), address(usdc), ethIn);
        console2.log("QUOTE: ", quoted);

        uint256 usdcBefore = usdc.balanceOf(charles);
        uint256 exQuote = pool.swapExactInput{ value: ethIn }(address(0), address(usdc), 0, quoted);
        console2.log("EX QUOTE: ", exQuote);
        assertEq(usdc.balanceOf(charles), usdcBefore + quoted);
        _stopPrank();
    }

    function test_RevertIf_AmountMismatch_TokenInWithMsgValue() public _deployInv {
        _changePrank(charles);
        vm.expectRevert(Errors.Pool__Amount_Mismatch.selector);
        pool.swapExactInput{ value: 1 ether }(address(usdc), address(ngns), 100 * 1e6, 0);
        _stopPrank();
    }

    function test_Spread_AppliesPremiumAndDiscount() public {
        _changePrank(deployer);

        // Baseline: no spread
        pool.deployInv(
            address(usdc),
            address(ngns),
            address(ngnUsdFeed),
            acquisitionPrice,
            0,
            1e18,
            true,
            false
        );
        (uint256 basePrice,) = pool.getPrice(address(ngns), address(usdc));
        assertGt(basePrice, 0, "oracle price should be non-zero");

        // +10% premium (1000 bps) on the same pair
        pool.deployInv(
            address(usdc),
            address(ngns),
            address(ngnUsdFeed),
            acquisitionPrice,
            1000,
            1e18,
            true,
            false
        );
        (uint256 premiumPrice,) = pool.getPrice(address(ngns), address(usdc));
        assertEq(premiumPrice, basePrice + (basePrice * 1000) / 10_000, "premium mismatch");
        assertGt(premiumPrice, basePrice);

        // -5% discount (-500 bps)
        pool.deployInv(
            address(usdc),
            address(ngns),
            address(ngnUsdFeed),
            acquisitionPrice,
            -500,
            1e18,
            true,
            false
        );
        (uint256 discountPrice,) = pool.getPrice(address(ngns), address(usdc));
        assertEq(discountPrice, basePrice - (basePrice * 500) / 10_000, "discount mismatch");
        assertLt(discountPrice, basePrice);

        _stopPrank();
    }

    function test_UpdateSpread_ChangesPrice() public _deployInv {
        (uint256 priceBefore,) = pool.getPrice(address(ngns), address(usdc));
        assertGt(priceBefore, 0, "oracle price should be non-zero");
        pool.updateSpread(address(ngns), address(usdc), -500);
        (uint256 discounted,) = pool.getPrice(address(ngns), address(usdc));
        assertLt(discounted, priceBefore, "discount should lower price");
        pool.updateSpread(address(ngns), address(usdc), 0);
        (uint256 raw,) = pool.getPrice(address(ngns), address(usdc));
        assertEq(
            priceBefore, raw + (raw * uint256(uint96(spreadBps))) / 10_000, "old premium mismatch"
        );
        assertEq(discounted, raw - (raw * 500) / 10_000, "discount mismatch");
    }

    function test_RevertIf_UpdateSpread_NotDeployer() public _deployInv {
        _changePrank(charles);
        vm.expectRevert();
        pool.updateSpread(address(ngns), address(usdc), 500);
        _stopPrank();
    }
}
