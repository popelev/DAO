// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DAOVoteToken is Ownable, ERC20, ERC20Permit, ERC20Votes {
    constructor() Ownable(msg.sender) ERC20("DAOVoteToken", "DVT") ERC20Permit("DAOVoteToken") {}

    // The functions below are overrides required by Solidity.

    function _update(address _from, address _to, uint256 _amount) internal override(ERC20, ERC20Votes) {
        super._update(_from, _to, _amount);
    }

    function nonces(address _owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(_owner);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }


    function mint(address _to, uint256 _amount) onlyOwner() external {
        _mint(_to, _amount);
    }
}

contract  TokenProvider is ReentrancyGuard {
    ERC20 public USDT;
    DAOVoteToken public VoteToken;
    address public DAO;

    constructor(address _voteToken){
        VoteToken = DAOVoteToken(_voteToken);
    }

    function buyDVT(uint256 _amount) nonReentrant() external {

        require(USDT.decimals() == VoteToken.decimals());
        
        uint256  balanceBefore = USDT.balanceOf(address(DAO));
        (bool success) = USDT.transferFrom(msg.sender, DAO, _amount);
        uint256 balanceAfter = USDT.balanceOf(address(DAO));
        
        uint256 transferedAmount = balanceAfter - balanceBefore;

        VoteToken.mint(msg.sender, transferedAmount);
    }
}

