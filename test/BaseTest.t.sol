// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { PoolFactory } from "../src/PoolFactory.sol";
import { Pool } from "../src/Pool.sol";
import { MockV3Aggregator } from "./mocks/MockV3Aggregator.t.sol";
import { MockNGNOracle } from "./mocks/MockNGNOracle.t.sol";
import { console2 } from "forge-std/console2.sol";

contract MockERC20 is ERC20 {
    uint8 private immutable _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals_) ERC20(name, symbol) {
        _decimals = decimals_;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}

abstract contract BaseTest is Test {
    PoolFactory internal factory;
    Pool internal poolImpl;
    Pool internal pool;

    MockERC20 internal usdc; // 6 decimals
    MockERC20 internal ngns; // 18 decimals
    MockNGNOracle internal ngnUsdFeed;
    MockV3Aggregator internal usdcUsdFeed;
    uint256 internal initialNgnUsdPrice = 84000; // 0.00084 USD per NGN (8 DECIMAL)
    uint256 internal initialUsdcUsdPrice = 1e8;
    uint256 internal acquisitionPrice = 1000e18; // got 1 USD for 1000 NGN
    uint256 internal spreadBps = 1000; // 10%
    address internal multisig = makeAddr("multisig");
    address internal deployer = makeAddr("deployer");
    address internal charles = makeAddr("Charles");
    address internal thelma = makeAddr("Thelma");

    // NGNS/USDC price scaled to 18 decimals (0.00084 USDC per NGNS -> 8.4e14)
    uint256 internal constant INITIAL_PRICE = 840000000000000;

    function setUp() public virtual {
        // 1. Deploy Mock Tokens
        usdc = new MockERC20("USD Coin", "USDC", 6);
        ngns = new MockERC20("Naira Stable", "NGNS", 18);
        ngnUsdFeed = new MockNGNOracle(initialNgnUsdPrice);
        (uint256 p,) = ngnUsdFeed.getUsdPricePerNgn();
        assertEq(p, initialNgnUsdPrice);
        usdcUsdFeed = new MockV3Aggregator(8, int256(initialUsdcUsdPrice));

        // 2. Deploy Factory & Base Implementation
        _changePrank(multisig);
        poolImpl = new Pool();
        factory = new PoolFactory(multisig, address(ngnUsdFeed), address(poolImpl));

        // 3. Deploy Proxy Pool via Factory
        _changePrank(deployer);
        address poolAddr = factory.deployPool();
        pool = Pool(payable(poolAddr));
        _stopPrank();

        // 4. Fund Test Accounts
        vm.deal(deployer, 100 ether);
        vm.deal(charles, 100 ether);
        vm.deal(thelma, 100 ether);

        usdc.mint(deployer, 1_000_000 * 1e6);
        ngns.mint(deployer, 500_000_000_000 * 1e18);

        usdc.mint(charles, 100_000 * 1e6);
        usdc.mint(thelma, 100_000 * 1e6);
        ngns.mint(charles, 100_000 * 1e18);

        // 5. Set Initial Pool Liquidity & Price
        _changePrank(deployer);
        usdc.approve(address(pool), type(uint256).max);
        ngns.approve(address(pool), type(uint256).max);

        _changePrank(charles);
        usdc.approve(address(pool), type(uint256).max);
        ngns.approve(address(pool), type(uint256).max);

        _changePrank(thelma);
        usdc.approve(address(pool), type(uint256).max);
        ngns.approve(address(pool), type(uint256).max);
        _stopPrank();
    }

    modifier _deployInv() {
        _changePrank(deployer);
        uint256 depositAmount = 500_000 * 1e18;
        pool.deployInv(
            address(usdc),
            address(ngns),
            address(ngnUsdFeed),
            acquisitionPrice,
            spreadBps,
            depositAmount,
            true,
            true
        );
        Pool.Inventory memory inv = pool.getInventory(address(ngns), address(usdc));
        console2.log("--- Inventory Details ---");
        console2.log("Asset Out: ", inv.assetOut);
        console2.log("Floor: ", inv.floor);
        console2.log("Asset In: ", inv.assetIn);
        console2.log("Spread Bps: ", inv.spreadBps);
        console2.log("Feed: ", inv.feed);
        console2.log("Allow Swap Below Floor: ", inv.allowSwapBelowFloor);
        console2.log("Is Inverted: ", inv.isInverted);
        _;
    }

    function _changePrank(address newPrank) internal {
        vm.stopPrank();
        vm.startPrank(newPrank);
    }

    function _stopPrank() internal {
        vm.stopPrank();
    }
}
