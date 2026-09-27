// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SwapEngine } from "./utils/SwapEngine.sol";

contract Pool is SwapEngine {
    function initialize(address _deployer, address _ngnFeed) external onlyUninitialized {
        deployer = _deployer;
        ngnPriceFeed = _ngnFeed;
        initialized = true;
    }

    function deployInv(
        address _assetIn,
        address _assetOut,
        address _feed,
        uint256 _floor,
        uint256 _spread,
        uint256 _amount,
        bool _allowSwapBelowFloor,
        bool _isInverted
    ) external onlyDeployer returns (bool) {
        _pull(_assetOut, _msgsender(), _amount);

        Inventory memory inv = Inventory({
            assetOut: _assetOut,
            floor: uint96(_floor),
            assetIn: _assetIn,
            spreadBps: uint96(_spread),
            feed: _feed,
            allowSwapBelowFloor: _allowSwapBelowFloor,
            isInverted: _isInverted
        });

        _updateInv(inv);

        emit InventoryAdded(_assetOut, _assetIn, _feed, _floor, _spread, _amount);

        return true;
    }

    function deployInvETH(
        address _assetIn,
        address _feed,
        uint256 _floor,
        uint256 _spread,
        bool _allowSwapBelowFloor,
        bool _isInverted
    ) external payable onlyDeployer returns (bool) {
        if (msg.value == 0) revert Pool__Zero_Amount();

        Inventory memory inv = Inventory({
            assetOut: address(0),
            floor: uint96(_floor),
            assetIn: _assetIn,
            spreadBps: uint96(_spread),
            feed: _feed,
            allowSwapBelowFloor: _allowSwapBelowFloor,
            isInverted: _isInverted
        });

        _updateInv(inv);

        emit InventoryAdded(address(0), _assetIn, _feed, _floor, _spread, msg.value);

        return true;
    }

    function removeLiquidity(address asset, uint256 amount) external onlyDeployer returns (bool) {
        if (amount == 0) revert Pool__Zero_Amount();

        _push(asset, _msgsender(), amount);
        emit LiquidityRemoved(asset, amount);

        return true;
    }

    function removeLiquidityETH(uint256 amount) external onlyDeployer returns (bool) {
        if (amount == 0) revert Pool__Zero_Amount();

        _push(address(0), _msgsender(), amount);
        emit LiquidityRemoved(address(0), amount);

        return true;
    }

    function VERSION() external pure returns (string memory) {
        return "v3.0.1";
    }

    receive() external payable { }
    fallback() external payable { }
}
