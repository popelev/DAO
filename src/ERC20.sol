// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DAOVoteToken is ERC20 {

    ERC20 public USDT;
    address public DAO;
    constructor() ERC20("DAOVoteToken", "DVT") {}

    function swapUSDTtoDVT(uint value) external {
        (bool success) = USDT.transferFrom(msg.sender, DAO, value);
        _mint(msg.sender, value);
    }

}