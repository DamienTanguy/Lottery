// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./LotteryToken.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery is VRFConsumerBaseV2 {

    //From https://docs.chain.link/docs/vrf/v2/subscription/examples/get-a-random-number/
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Goerli coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;



    bool lotteryClosed;

    LotteryToken LT; //variable to point to the contract to mint the token

    mapping(uint => address) public winners;

    uint idLoterry;

    address payable[] public players;
    address payable owner;

    /*constructor(LotteryToken _LT){
        LT = _LT;
        owner = payable(msg.sender); //convertion of the addres in payable
    }*/

    constructor(uint64 subscriptionId, LotteryToken _LT) VRFConsumerBaseV2(vrfCoordinator) {
        //From my lottery contract
        LT = _LT;
        owner = payable(msg.sender); //convertion of the addres in payable
        //From chainlink
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function toggleLottery() external onlyOwner{
        lotteryClosed = !lotteryClosed;
    }

    //Method requestRandomWords & fulfillRandomWords from https://docs.chain.link/docs/vrf/v2/subscription/examples/get-a-random-number/
    function requestRandomWords() external onlyOwner {
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }

    function fulfillRandomWords(uint256, uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    function pickWinner() external onlyOwner {
        require(lotteryClosed,"Lottery is closed");

        uint winner = s_randomWords[0] % players.length;

        players[winner].transfer(address(this).balance / 100 * 90);
        owner.transfer(address(this).balance);

        LT.mint(players[winner], 10 * 10**18); //mint of 10 Token ERC20
        winners[idLoterry] = players[winner];
        idLoterry++;

        players = new address payable[](0); //init of the player list for the new lottery
    }

    function enter() external payable {
        require(!lotteryClosed,"Lottery is closed");
        require(msg.value == 0.001 ether, "Not enough funds to participate");
        players.push(payable(msg.sender));
    }

    function getBalance() external view returns(uint){
        return address(this).balance;
    }

    function getWinnerLottery(uint _idLottery) external view returns(address){
        return winners[_idLottery];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }



}