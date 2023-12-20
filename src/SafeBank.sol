// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeBank {
    bool private locked;
    mapping(address => uint) public balances;

    constructor() {
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function safeWithdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(!locked, "Reentrant call detected");

        locked = true;
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");
        locked = false;

        balances[msg.sender] -= _amount;
    }
}
