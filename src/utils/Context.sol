// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgsender() public view returns (address) {
        return msg.sender;
    }
}
