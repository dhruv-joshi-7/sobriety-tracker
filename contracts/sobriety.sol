// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sobriety {
    address payable friend;
    address trustee;
    address addict;
    uint256 locktime = 1 days;

    struct locked{
        uint256 expiry;
        uint256 amount;
        address friend;
        bool permission;
    }
    
    mapping(address => locked) users;
    mapping(address => address) trusted_pairs;

    constructor (address payable _friend, address _trustee) {
        friend = _friend;
        trustee = _trustee;
        addict = msg.sender;
    }

    function lockMoney(uint256 num_days) public payable {
        require(msg.value > 0, "No value");
        trusted_pairs[trustee] = addict;
        locked storage userinfo = users[msg.sender];
        userinfo.expiry = block.timestamp + num_days*locktime;
        userinfo.amount = msg.value;
        userinfo.friend = friend;
        userinfo.permission = false;
    }

    function allowTransfer() public {
        require(msg.sender == trustee, "Not authorized");
        require(trusted_pairs[msg.sender] == addict, "Incorrect Pair");
        require(block.timestamp < users[addict].expiry, "Time has expired");
        users[addict].permission = true;
        uint256 value = users[addict].amount;
        users[addict].amount = 0;
        users[addict].expiry = 0;
        friend.transfer(value);
    }
}