// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title A simple Raffle contract
 * @dev Implements Chainlink VRFv2.5 for random number generation
 * @author Lokesh
 * @notice This contract allows users to enter a raffle and win a prize.
 */


contract Raffle {
    //Errors
    error Raffle__SendMoreToEnterRaffle();

    uint256 private immutable i_entraceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    //Events
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entraceFee= entranceFee;
        i_interval= interval;
        s_lastTimeStamp= block.timestamp;

    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entraceFee, "Not enough Eth");
        // require(msg.value >= i_entraceFee, SendMoreToEnterRaffle()); MORE READABLE
        if(msg.value < i_entraceFee) revert Raffle__SendMoreToEnterRaffle();
        
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    //1. Get a random number
    //2. Use the random number to pick a winning player
    //3. Be automatically called the pickWinner fn
    function pickWinner() external {
        //check to see if enough time has passed
        if((block.timestamp - s_lastTimeStamp) < i_interval) revert();

    }

    function getEntranceFee() external view returns(uint256){
        return i_entraceFee;
    }


    
}