// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./LotteryToken.sol";

contract Lottery {

    bool lotteryClosed;

    LotteryToken LT; //variable to point to the contract to mint the token

    mapping(uint => address) public winners;

    uint idLoterry;

    address payable[] public players;
    address payable owner;

    constructor(LotteryToken _LT){
        LT = _LT;
        owner = payable(msg.sender); //convertion of the addres in payable
    }

    function toggleLottery() external onlyOwner{
        lotteryClosed = !lotteryClosed;
    }

    //NOT THE GOOD WAY --> POSSIBLE FOR THE MINNER TO CHEAT --> GOOD WAY IS TO USE ORABLE
    function pickWinner() external onlyOwner {
        require(lotteryClosed,"Lottery is closed");
        //encodePacked --> concatenation
        //keccal256 --> hash 
        //convertion to number
        //modulo --> the left of the division so < players.length
        uint winner = uint(keccak256(abi.encodePacked(
            block.timestamp, block.difficulty, msg.sender
        ))) % players.length;

        players[winner].transfer(address(this).balance / 100 * 90); //90% goes to the winner
        owner.transfer(address(this).balance); //10% goes to the owner of the contract

        LT.mint(players[winner], 10 * 10**18); //mint of 10 Token ERC20
        winners[idLoterry] = players[winner];
        idLoterry++;

        players = new address payable[](0); //init of the player list for the new lottery
    }

    function enter() external payable {
        require(!lotteryClosed,"Lottery is closed");
        require(msg.value == 1 ether, "Not enough funds to participate");
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