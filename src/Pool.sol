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
        if (_amount > 0 && msg.value > 0) {
            revert Pool__Amount_Mismatch();
        }
        uint128 amount = _assetOut == address(0) ? uint128(msg.value) : uint128(_amount);
        if (_assetOut != address(0)) {
            _pull(_assetOut, _msgsender(), _amount);
        }
        Inventory memory inv = Inventory({
            assetOut: _assetOut,
            floor: uint96(_floor),
            assetIn: _assetIn,
            spreadBps: int96(_spread),
            feed: _feed,
            baseBalance: amount,
            quoteBalance: 0,
            allowSwapBelowFloor: _allowSwapBelowFloor,
            isInverted: _isInverted
        });
        _updateInv(inv);
        emit InventoryAdded(_assetOut, _assetIn, _feed, _floor, amount);
        return true;
    }

    function removeLiquidity(address _base, address _quote, address _assetOut, uint256 _amount)
        external
        onlyDeployer
        returns (bool)
    {
        if (_amount == 0) revert Pool__Zero_Amount();
        _updateOutLiquidity(_base, _quote, _assetOut, uint128(_amount));
        _push(_assetOut, _msgsender(), _amount);
        emit LiquidityRemoved(_assetOut, _amount);
        return true;
    }

    function addLiquidity(address _base, address _quote, uint256 _amount)
        external
        payable
        onlyDeployer
        returns (bool)
    {
        if (_amount > 0 && msg.value > 0) revert Pool__Amount_Mismatch();
        uint256 depositAmount = _amount > 0 ? _amount : msg.value;
        _updateInLiquidity(_base, _quote, _base, uint128(depositAmount));
        if (_base != address(0)) {
            _pull(_base, _msgsender(), depositAmount);
        }
        emit LiquidityAdded(_base, depositAmount);
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
