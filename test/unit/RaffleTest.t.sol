//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol"; /*    "../../script/HelperConfig.s.sol"     */
import {Raffle} from "../../src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig = new HelperConfig();

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        /* assert(uint256(raffle.getRaffleState()) == 0; */
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); /* Compare the received output with the expected output */
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        //Arrange
        vm.prank(PLAYER); //the very next line is cheatcode so this line will work for the second next line
        //Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector); //expect the next line of code to revert with a specific custom error
        raffle.enterRaffle(); // No ETH sent here
    }

    function testRaffleRecordsPlayersWhenTheyEntered() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        raffle.enterRaffle{value: entranceFee}(); //the test will fail when the PLAYER has zero funds, so use deal cheatcode
        //Assert
        address playerRecorded = raffle.getPlayer(0); //getPlayer(0) because there is only one PLAYER entering the raffle
        assert(playerRecorded == PLAYER);
    }

    function testEnteringRaffleEmitsEvent() public {
        //Arrange
        vm.prank(PLAYER);
        //Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        //Assert
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        //Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector); //expect the next line of code to revert with a specific custom error
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    /*/////////////////////////////////////////////////////////
                           CHECK UPKEEP 
    ////////////////////////////////////////////////////////*/

    function testcheckUpkeepReturnsFalseIfItHasNoBalance() public {
        //Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //Act
        (bool upkeepNeeded,) = raffle.checkUpKeep("");

        //Assert
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        //Act
        (bool upkeepNeeded,) = raffle.checkUpKeep("");

        //Assert
        assert(!upkeepNeeded);
    }

    /*///////////////////////////////////////////////////////////////////////
                            PERFORM UPKEEP
    //////////////////////////////////////////////////////////////////////*/

    function testPerformUpkeepIsOnlyCalledIfCheckUpkeepIsTrue() public{
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        //Act/Assert
        raffle.performUpkeep("");

    }

    //test for the revert
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public{
        //Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState rState = raffle.getRaffleState();

        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance= currentBalance+entranceFee;
        numPlayers=1;

        //Act / Assert 
        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle__UpkeepNotSatisfied.selector, currentBalance, numPlayers, rState));
        raffle.performUpkeep("");
    }

    modifier raffleEntered(){
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdateRaffleStateAndEmitsRequestId() public raffleEntered{
        //Arrange
        
        //Act 
        vm.recordLogs();//records the logs that is happening in the next function and store that recorded log in the array
        raffle.performUpkeep("");
        Vm.Log[] memory entries =  vm.getRecordedLogs();//all of the recorded entries store them in to the entries array
        bytes32 requestId= entries[1].topics[1];

        //Assert 
        Raffle.RaffleState raffleState= raffle.getRaffleState();
        assert(uint256(requestId)>0);
        assert(uint256(raffleState)==1);

    }

    

}
