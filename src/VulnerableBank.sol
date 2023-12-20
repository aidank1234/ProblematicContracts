// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint) public balances;

    // Deposit funds into the bank
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }

    // Withdraw funds from the bank
    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // This external call can lead to a reentrancy attack
        // because the balance is updated after the call.
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;
    }

    // Get the balance of an account
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }
}
