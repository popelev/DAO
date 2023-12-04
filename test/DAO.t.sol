// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {DAO} from "../src/DAO.sol";
import {DAOVoteToken} from "../src/Token.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

contract DaoTest is Test {
        
        uint8 constant VOTE_NO = 0;
        uint8 constant VOTE_YES = 1;
        uint8 constant VOTE_ABSTAIN = 2;

        DAOVoteToken public token;
        TimelockController public timelock;
        EtherReciever public etherReciever;
        DAO public DAO_GOV;
        address public deployer = makeAddr('deployer');
        address[] public proposers = [makeAddr('proposer1'), makeAddr('proposer2')];
        address[] public executors = [makeAddr('executor1'), makeAddr('executor2')];
        address public admin = makeAddr('admin');
        address[] public users = [makeAddr('user1'), makeAddr('user2'), makeAddr('user3')];

        address[] public _target;
        uint256[] public _value;
        bytes[] public _calldata;
        string public _description;

        event logUint(uint);


        function setUp() public {

                etherReciever = new EtherReciever();
                vm.deal(deployer, 10_000 ether);
                vm.startPrank(deployer);
                token = new DAOVoteToken();
                timelock = new TimelockController(0, proposers, executors, deployer);
                timelock._setRoleAdmin(role, adminRole);
                DAO_GOV = new DAO(IVotes(token), timelock);

                bytes32 PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
                bytes32 EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
                bytes32 CANCELLER_ROLE = keccak256("CANCELLER_ROLE");
                
                timelock.grantRole(PROPOSER_ROLE , address(DAO_GOV));
                timelock.grantRole(EXECUTOR_ROLE , address(DAO_GOV));
                timelock.grantRole(CANCELLER_ROLE , address(DAO_GOV));

                token.mint(users[0], 1_000_000);
                token.mint(users[1], 1_000_000);
                token.mint(users[2], 1_000_000);
                
                vm.stopPrank();

                vm.deal(address(DAO_GOV), 10_000 ether);
                vm.deal(address(timelock), 10_000 ether);

                vm.deal(users[0], 10_000 ether);
                vm.deal(users[1], 10_000 ether);
                vm.deal(users[2], 10_000 ether);

                vm.prank(users[0]);
                token.delegate(users[0]);

                vm.prank(users[1]);
                token.delegate(users[1]);

                vm.prank(users[2]);
                token.delegate(users[2]);
        }

        function test_setUp() public {
                assert(token.balanceOf(users[0]) == 1_000_000);
                assert(token.balanceOf(users[1]) == 1_000_000);
                assert(token.balanceOf(users[2]) == 1_000_000);
        }

        function test_createPropose() public {
                vm.startPrank(proposers[0]);
                _target.push(users[1]);
                _value.push(1 ether);
                _calldata.push(bytes(''));
                _description = "Send 1 ether to user 1";

                uint256 proposalId = DAO_GOV.propose(_target, _value, _calldata, _description);
                address proposer = DAO_GOV.proposalProposer(proposalId);
                assert(proposers[0] == proposer);
                vm.stopPrank(); 
        }

        function test_votePropose() public {
                vm.startPrank(proposers[0]);
                _target.push(users[1]);
                _value.push(1 ether);
                _calldata.push(bytes(''));
                _description = "Send 1 ether to user 1";
                uint256 proposalId = DAO_GOV.propose(_target, _value, _calldata, _description);
                vm.stopPrank(); 

                skip(2 days);
                vm.roll(172801);

                vm.prank(users[0]);
                DAO_GOV.castVote(proposalId, VOTE_NO);

                vm.prank(users[1]);
                DAO_GOV.castVote(proposalId, VOTE_YES);
                
                vm.prank(users[2]);
                DAO_GOV.castVote(proposalId, VOTE_ABSTAIN);

                (uint256 n, uint256 y, uint256 a) = DAO_GOV.proposalVotes(proposalId);
                assert(n == 1_000_000);
                assert(y == 1_000_000);
                assert(a == 1_000_000);
        }

         function test_executePropose() public {
                vm.startPrank(proposers[0]);
                _target.push(address(etherReciever));
                _value.push(1 ether);
                _calldata.push(bytes(''));
                _description = "Send 1 ether to some contract";
                uint256 proposalId = DAO_GOV.propose(_target, _value, _calldata, _description);
                vm.stopPrank(); 

                skip(2 days);
                vm.roll(172801);

                vm.prank(users[0]);
                DAO_GOV.castVote(proposalId, VOTE_YES);

                vm.prank(users[1]);
                DAO_GOV.castVote(proposalId, VOTE_YES);
                
                vm.prank(users[2]);
                DAO_GOV.castVote(proposalId, VOTE_YES);
     
                skip(6 days);
                vm.roll(900000);
                
                bytes32 _descriptionHash = keccak256(bytes(_description));

                vm.startPrank(executors[0]);
                DAO_GOV.queue(_target, _value, _calldata, _descriptionHash);

                skip(1 days);
                vm.roll(900001);

                DAO_GOV.execute(_target, _value, _calldata, _descriptionHash);
                vm.stopPrank(); 
        }
}

contract EtherReciever {
        fallback() external payable {}

        receive() external payable {}
}

                // hashProposal = keccak256(abi.encode(targets, values, calldatas, descriptionHash));
