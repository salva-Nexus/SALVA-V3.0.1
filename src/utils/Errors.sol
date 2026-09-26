// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

abstract contract Errors {
    error Pool__Already_Initialized();
    error Pool__Not_Authorized();
    error Pool__Zero_Price();
    error Pool__Zero_Amount();
    error Pool__Amount_Mismatch();
    error Pool_Zero_Address();
    error Pool__Stale_Price();
    error Pool__Invalid_Round();
    error Pool__Price_Below_Floor();
}
