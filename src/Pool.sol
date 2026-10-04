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
        int256 _spread,
        uint256 _amount,
        bool _allowSwapBelowFloor,
        bool _isInverted
    ) external payable onlyDeployer returns (bool) {
        if (msg.value == 0 && _amount == 0) revert Pool__Zero_Amount();
        if (_amount > 0 && msg.value > 0 || _amount > 0 && msg.value > 0) {
            revert Pool__Amount_Mismatch();
        }
        if (_amount > 0) {
            _pull(_assetOut, _msgsender(), _amount);
        }
        Inventory memory inv = Inventory({
            assetOut: _assetOut,
            floor: uint96(_floor),
            assetIn: _assetIn,
            spreadBps: int96(_spread),
            feed: _feed,
            allowSwapBelowFloor: _allowSwapBelowFloor,
            isInverted: _isInverted
        });
        _updateInv(inv);
        emit InventoryAdded(_assetOut, _assetIn, _feed, _floor, _amount);
        return true;
    }

    function removeLiquidity(address asset, uint256 amount) external onlyDeployer returns (bool) {
        if (amount == 0) revert Pool__Zero_Amount();
        _push(asset, _msgsender(), amount);
        emit LiquidityRemoved(asset, amount);

        return true;
    }

    function updateSpread(address _base, address _quote, int96 _spread)
        external
        onlyDeployer
        returns (bool)
    {
        _updateSpread(_base, _quote, _spread);
        return true;
    }

    function VERSION() external pure returns (string memory) {
        return "v3.0.1";
    }

    receive() external payable { }
    fallback() external payable { }
}
