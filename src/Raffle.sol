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
    uint256 private immutable i_entraceFee;

    constructor(uint256 entranceFee){
        i_entraceFee= entranceFee;
    }

    function enterRaffle() public payable {}

    function pickWinner() public {}

    function getEntranceFee() external view returns(uint256){
        return i_entraceFee;
    }


    
}