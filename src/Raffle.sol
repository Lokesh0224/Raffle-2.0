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
    address payable[] private s_players;

    //Events
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee){
        i_entraceFee= entranceFee;
    }

    function enterRaffle() public payable {
        // require(msg.value >= i_entraceFee, "Not enough Eth");
        // require(msg.value >= i_entraceFee, SendMoreToEnterRaffle()); MORE READABLE
        if(msg.value < i_entraceFee) revert Raffle__SendMoreToEnterRaffle();
        
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {}

    function getEntranceFee() external view returns(uint256){
        return i_entraceFee;
    }


    
}