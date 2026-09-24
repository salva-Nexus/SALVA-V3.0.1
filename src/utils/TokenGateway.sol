// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract TokenGateway {
    using SafeERC20 for IERC20;
    error TokenGateway__ETHTransferFailed();

    function _balanceOf(address token, address owner) internal view returns (uint256) {
        if (token == address(0)) {
            return owner.balance;
        }
        return IERC20(token).balanceOf(owner);
    }

    function _decimalsOf(address token) internal view returns (uint8) {
        if (token == address(0)) {
            return 18;
        }
        return IERC20Metadata(token).decimals();
    }

    function _pull(address token, address from, uint256 amount) internal {
        IERC20(token).safeTransferFrom(from, address(this), amount);
    }

    function _push(address token, address to, uint256 amount) internal {
        if (token == address(0)) {
            (bool success,) = payable(to).call{ value: amount }("");
            if (!success) revert TokenGateway__ETHTransferFailed();
            return;
        }
        IERC20(token).safeTransfer(to, amount);
    }
}
