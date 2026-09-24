// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { IPool } from "./interfaces/IPool.sol";
import { Context } from "./utils/Context.sol";

contract PoolFactory is Context {
    using Clones for address;

    address public baseImplementation;
    address public multisig;

    event BaseImplementationUpdated(address indexed newImpl);
    event PoolCreated(address indexed poolAddress);

    error Factory__ZeroAddress();
    error Factory__Unauthorized();
    error Factory__PoolInitializationFailed();

    constructor(address _multisig, address _baseImplementation) {
        if (_multisig == address(0) || _baseImplementation == address(0)) {
            revert Factory__ZeroAddress();
        }
        baseImplementation = _baseImplementation;
        multisig = _multisig;
    }

    function setBaseImpl(address _newImplementation) external {
        if (_msgsender() != multisig) revert Factory__Unauthorized();
        if (_newImplementation == address(0)) revert Factory__ZeroAddress();
        baseImplementation = _newImplementation;
        emit BaseImplementationUpdated(_newImplementation);
    }

    function deployPool() external returns (address pool) {
        address impl = baseImplementation;
        if (impl == address(0)) revert Factory__ZeroAddress();

        pool = impl.clone();

        IPool(pool).initialize(_msgsender());

        emit PoolCreated(pool);
    }
}
