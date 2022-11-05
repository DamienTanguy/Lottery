// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LotteryToken is ERC20 {

    address owner; //address of the owner contract
    address approvedContract; //address of the contract that mint the Lottery token ERC20 for the winner --> the Lottery contract

    constructor() ERC20("Lottery Token", "LT") {
        owner = msg.sender;
    }

    function setApprovedContract (address _approvedContract) external onlyOwner {
        approvedContract = _approvedContract;
    }

    function mint(address _to, uint _numberOfToken) external {
        require(msg.sender == approvedContract, "Contract not approved");
        _mint(_to, _numberOfToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

}