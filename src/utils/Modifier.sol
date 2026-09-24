// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Context } from "./Context.sol";
import { Storage } from "./Storage.sol";
import { Errors } from "./Errors.sol";

abstract contract Modifier is Context, Storage, Errors {
    modifier onlyUninitialized() {
        _requireUninitialized();
        _;
    }

    modifier onlyDeployer() {
        _onlyDeployer();
        _;
    }

    function _requireUninitialized() internal view {
        if (initialized) {
            revert Pool__Already_Initialized();
        }
    }

    function _onlyDeployer() internal view {
        if (_msgsender() != deployer) {
            revert Pool__Not_Authorized();
        }
    }

    function _checkZeroRate(uint256 exRate) internal pure {
        if (exRate == 0) {
            revert Pool__Invalid_Rate(exRate);
        }
    }
}
