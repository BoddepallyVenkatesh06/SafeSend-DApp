/**
 *Submitted for verification at sepolia.lineascan.build/ on 2024-05-31
 *Smart Contract: https://sepolia.lineascan.build/address/0x67c9492318f02f3e50b5d3221b3f51817bcfcef0#writeContract
*/

// SPDX-License-Identifier: MIT

//     Linea Hackathon 2024: May Dev Cook-Off with Linea
//
//     Author: Konstantinos Andreou 
//
//    The following code aims to solve a specific use case related to the secure transfer of funds
//    between two parties while incorporating additional authentication to prevent losing funds
//    due to mistyped wallet addresses.
//


pragma solidity ^0.8.0;

contract SafeSendLinea {
    struct Transfer {
        address payable sender;
        address payable receiver;
        uint256 amount;
        bool claimed;
    }

    mapping(address => Transfer) public transfers;

    event EtherSent(address indexed sender, address indexed receiver, uint256 amount);
    event EtherClaimed(address indexed sender, address indexed receiver, uint256 amount);
    event EtherClaimedBack(address indexed sender, uint256 amount);

    modifier onlySender(address senderAddr) {
        require(msg.sender == transfers[senderAddr].sender, "Only sender can call this function");
        _;
    }

    modifier notClaimed(address senderAddr) {
        require(!transfers[senderAddr].claimed, "Transfer has already been claimed");
        _;
    }

    function sendLinea(address payable receiver) external payable {
        require(msg.value > 0, "Must send a positive amount");

        transfers[msg.sender] = Transfer({
            sender: payable(msg.sender),
            receiver: receiver,
            amount: msg.value,
            claimed: false
        });

        emit EtherSent(msg.sender, receiver, msg.value);
    }

    function claimLinea(address senderAddr) external notClaimed(senderAddr) {
        require(msg.sender == transfers[senderAddr].receiver, "You are not the intended receiver");

        transfers[senderAddr].claimed = true;
        transfers[senderAddr].receiver.transfer(transfers[senderAddr].amount);

        emit EtherClaimed(transfers[senderAddr].sender, msg.sender, transfers[senderAddr].amount);
    }

    function claimBackLinea() external onlySender(msg.sender) notClaimed(msg.sender) {
        transfers[msg.sender].claimed = true;
        transfers[msg.sender].sender.transfer(transfers[msg.sender].amount);

        emit EtherClaimedBack(transfers[msg.sender].sender, transfers[msg.sender].amount);
    }
}
