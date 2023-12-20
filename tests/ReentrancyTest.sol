// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract Attacker {
    SafeBank public secureContract;

    constructor(SecureContract _secureContract) {
        secureContract = _secureContract;
    }

    // Fallback function used to attempt reentrancy
    receive() external payable {
        secureContract.safeWithdraw(msg.value);
    }

    function attack() external payable {
        secureContract.deposit{value: msg.value}();
        secureContract.safeWithdraw(msg.value);
    }
}

contract SecureContractTest is Test {
    SecureContract secureContract;
    Attacker attacker;

    function setUp() public {
        secureContract = new SecureContract();
        attacker = new Attacker(secureContract);
    }

    function testNoReentrancy() public {
        uint depositAmount = 1 ether;
        vm.deal(address(attacker), depositAmount);

        uint preAttackBalance = address(secureContract).balance;
        attacker.attack{value: depositAmount}();

        uint postAttackBalance = address(secureContract).balance;
        uint postAttackAttackerBalance = address(attacker).balance;

        // Assert that the contract's balance is unchanged
        assertEq(preAttackBalance, postAttackBalance, "Contract balance should be unchanged");

        // Assert that the attacker's balance is reduced by the deposit amount
        assertEq(postAttackAttackerBalance, 0, "Attacker should not have recovered the funds");
    }
}
