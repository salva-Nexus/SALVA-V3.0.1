// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { PoolFactory } from "../src/PoolFactory.sol";
import { Pool } from "../src/Pool.sol";

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

        // 2. Deploy Factory & Base Implementation
        _changePrank(multisig);
        poolImpl = new Pool();
        factory = new PoolFactory(multisig, address(poolImpl));

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
        ngns.mint(deployer, 1_000_000 * 1e18);

        usdc.mint(charles, 100_000 * 1e6);
        ngns.mint(charles, 100_000 * 1e18);

        // 5. Set Initial Pool Liquidity & Price
        _changePrank(deployer);
        usdc.approve(address(pool), type(uint256).max);
        ngns.approve(address(pool), type(uint256).max);

        pool.provideLiquidity(address(usdc), 500_000 * 1e6);
        pool.provideLiquidity(address(ngns), 500_000 * 1e18);
        pool.provideLiquidityETH{ value: 50 ether }();

        pool.updatePrice(address(ngns), address(usdc), INITIAL_PRICE);
        pool.updatePrice(address(ngns), address(0), INITIAL_PRICE);
        _stopPrank();
    }

    function _changePrank(address newPrank) internal {
        vm.stopPrank();
        vm.startPrank(newPrank);
    }

    function _stopPrank() internal {
        vm.stopPrank();
    }
}
