// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RaceCondition {
    uint public highestBid;
    address public highestBidder;

    // Function to place a bid
    function placeBid() public payable {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");

        // Vulnerable to a race condition
        // The state is updated after sending the Ether back to the previous highest bidder
        if (highestBidder != address(0)) {
            (bool sent, ) = highestBidder.call{value: highestBid}("");
            require(sent, "Failed to send Ether");
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }
}
