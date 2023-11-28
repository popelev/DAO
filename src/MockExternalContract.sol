// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

contract MockExternalContract {
    string public message;
    mapping(address=>uint256) public balances;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Not owner");
        owner = newOwner;
    }

    function pay(string calldata _message) external payable{
        message = _message;
        balances[msg.sender] = msg.value;
    }
}