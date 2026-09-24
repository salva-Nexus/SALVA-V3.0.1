// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { BaseTest } from "./BaseTest.t.sol";
import { console2 } from "forge-std/console2.sol";

contract Pool is BaseTest {
    function test_Initialization() public view {
        assertEq(pool.VERSION(), "v3.0.1");
        assertEq(pool.deployer(), deployer);
    }

    function test_UpdatePrice() public {
        _changePrank(deployer);
        uint256 newPrice = 900000000000000; // 0.00090
        pool.updatePrice(address(ngns), address(usdc), newPrice);
        uint256 price = pool.getPrice(address(ngns), address(usdc));
        console2.log("NGN/USDC Price: ", price);
        assertEq(price, newPrice);
        _stopPrank();
    }

    function test_ProvideAndRemoveLiquidityETH() public {
        _changePrank(deployer);
        uint256 initialEthBal = address(deployer).balance;

        pool.provideLiquidityETH{ value: 10 ether }();
        assertEq(address(deployer).balance, initialEthBal - 10 ether);

        pool.removeLiquidityETH(5 ether);
        assertEq(address(deployer).balance, initialEthBal - 5 ether);
        _stopPrank();
    }

    function test_SwapExactInput_USDC_To_NGNS() public {
        _changePrank(charles);
        usdc.approve(address(pool), type(uint256).max);

        uint256 usdcIn = 840; // 0.00084 USDC
        uint256 expectedNgnsOut = 1e18; // 1 NGNS

        uint256 charlesNgnsBefore = ngns.balanceOf(charles);
        uint256 amountOut = pool.swapExactInput(address(usdc), address(ngns), usdcIn);

        assertEq(amountOut, expectedNgnsOut);
        assertEq(ngns.balanceOf(charles), charlesNgnsBefore + expectedNgnsOut);
        _stopPrank();
    }

    function test_SwapExactOutput_USDC_To_NGNS() public {
        _changePrank(charles);
        usdc.approve(address(pool), type(uint256).max);

        uint256 targetNgnsOut = 1e18; // 1 NGNS target
        uint256 expectedUsdcIn = 840; // 0.00084 USDC expected

        uint256 charlesUsdcBefore = usdc.balanceOf(charles);
        uint256 amountIn = pool.swapExactOutput(address(usdc), address(ngns), targetNgnsOut);

        assertEq(amountIn, expectedUsdcIn);
        assertEq(usdc.balanceOf(charles), charlesUsdcBefore - expectedUsdcIn);
        _stopPrank();
    }

    function test_SwapExactInput_ETH_To_NGNS() public {
        _changePrank(charles);
        uint256 ethIn = 1 ether;

        uint256 charlesNgnsBefore = ngns.balanceOf(charles);
        uint256 charlesEthBefore = charles.balance;
        uint256 amountOut = pool.swapExactInput{ value: ethIn }(address(0), address(ngns), 0);
        uint256 charlesEthNow = charles.balance;
        assertTrue(amountOut > 0);
        assertEq(ngns.balanceOf(charles), charlesNgnsBefore + amountOut);
        assertLt(charlesEthNow, charlesEthBefore);
        _stopPrank();
    }

    function test_RevertIf_Erc20SwapWithETH() public {
        _changePrank(charles);
        usdc.approve(address(pool), type(uint256).max);

        // Sending ETH along with an ERC20 swap should trigger Pool__Amount_Mismatch
        vm.expectRevert();
        pool.swapExactInput{ value: 1 ether }(address(usdc), address(ngns), 840);
        _stopPrank();
    }
}
