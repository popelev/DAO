// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAOVoteToken} from "../src/Token.sol";

contract TokenTest is Test {
    address public USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function setUp() public {
        token = new DAOVoteToken();
    }

    function test_Increment() public {
        assertEq(1, 1);
    }
}
