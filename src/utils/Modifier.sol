// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Context } from "./Context.sol";
import { Storage } from "./Storage.sol";
import { Errors } from "./Errors.sol";

abstract contract Modifier is Context, Storage, Errors {
    modifier nonReentrant() {
        assembly {
            if gt(tload(0x00), 0x00) {
                revert(0x00, 0x00)
            }
            tstore(0x00, 0x01)
        }
        _;
        // assembly {
        //     tstore(0x00, 0x00)
        // }
    }
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
}
