// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DAO} from "../src/DAO.sol";

contract DAOTest is Test {
    DAO public dao;

    function setUp() public {
        dao = new DAO();
    }

    function test_Increment() public {
        assertEq(1, 1);
    }
}
