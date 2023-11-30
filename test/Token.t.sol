// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DAOVoteToken, TokenGiver} from "../src/Token.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenTest is Test {
    address public USDT_address = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public USDT_holder =  0x3CC936b795A188F0e246cBB2D74C5Bd190aeCF18;
    address public DAO = makeAddr('DAO');
    address public deployer = makeAddr('deployer');
    address public user = makeAddr('user');
    DAOVoteToken token;
    TokenGiver tokenGiver;
    ERC20 USDT;
    function setUp() public {
        uint256 forkId = vm.createSelectFork(vm.envString("RPC_URL"));

        USDT = ERC20(USDT_address);
        // funding accounts
        vm.deal(deployer, 10_000 ether);
        vm.deal(user, 10_000 ether);

        vm.startPrank(USDT_holder);
        USDT_address.call(abi.encodeWithSignature("transfer(address,uint256)", user, 10_000_000));
        assertEq(USDT.balanceOf(user), 10_000_000);
        vm.stopPrank();

        // deploying core contracts

        vm.startPrank(deployer);
        token = new DAOVoteToken();
        assert(token.owner() == deployer);
        tokenGiver = new TokenGiver(DAO, address(token), address(USDT));
        token.transferOwnership(address(tokenGiver));
        assert(token.owner() == address(tokenGiver));
        vm.stopPrank();
    }

    function test_BuyTokens() public {
        vm.startPrank(user);

        assertEq(USDT.balanceOf(user), 10_000_000);
        USDT_address.call(abi.encodeWithSignature("approve(address,uint256)", address(tokenGiver), 10_000_000));
        tokenGiver.buyDVT(5_000_000);
        assertEq(USDT.balanceOf(user), 5_000_000);
        assertEq(token.balanceOf(user), 5_000_000); 

        vm.stopPrank();
    }
}
