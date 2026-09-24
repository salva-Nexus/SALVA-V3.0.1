// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SwapEngine } from "./utils/SwapEngine.sol";

contract Pool is SwapEngine {
    function initialize(address _deployer) external onlyUninitialized {
        deployer = _deployer;
        initialized = true;
    }

    function provideLiquidity(address asset, uint256 amount) external onlyDeployer returns (bool) {
        // Transfer assets from the LP's wallet to this pool contract
        _pull(asset, _msgsender(), amount);
        emit LiquidityAdded(asset, amount);

        return true;
    }

    function removeLiquidity(address asset, uint256 amount) external onlyDeployer returns (bool) {
        // Transfer assets from the pool contract back to the LP's wallet
        _push(asset, _msgsender(), amount);
        emit LiquidityRemoved(asset, amount);
        return true;
    }

    function provideLiquidityETH() external payable onlyDeployer returns (bool) {
        if (msg.value == 0) revert Pool__Zero_Amount();
        emit LiquidityAdded(address(0), msg.value);
        return true;
    }

    /// @notice Withdraw native ETH liquidity back to LP
    function removeLiquidityETH(uint256 amount) external onlyDeployer returns (bool) {
        if (amount == 0) revert Pool__Zero_Amount();
        _push(address(0), _msgsender(), amount);
        emit LiquidityRemoved(address(0), amount);
        return true;
    }

    // Quote for base must be scaled to 18 decimals
    function updatePrice(address _baseAsset, address _quoteAsset, uint256 _quoteForBase)
        external
        onlyDeployer
        returns (bool)
    {
        if (_quoteForBase == 0) revert Pool__Zero_Price();
        _updatePrice(_baseAsset, _quoteAsset, _quoteForBase);
        emit PriceUpdated(_baseAsset, _quoteAsset, _quoteForBase);
        return true;
    }

    function VERSION() external pure returns (string memory) {
        return "v3.0.1";
    }

    receive() external payable { }
    fallback() external payable { }
}
