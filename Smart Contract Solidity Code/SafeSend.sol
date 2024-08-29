//     Linea Hackathon 2024: Dev Cook-Off with Linea

//     Updated Version: More secured contract and additional checks! 
//      Also added transfers for the special Efrogs 🐸 NFTS, and $CROAK MemeToken
//
//     Author: Konstantinos Andreou 
//
//    The following code aims to solve a specific use case related to the secure transfers (Ether transfers, Efrogs NFTs transfers, $CROAK Meme Token Transfers)
//    between two parties while incorporating additional authentication to prevent losing funds
//    due to mistyped wallet addresses.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SafeSend is ReentrancyGuard {
    struct Transfer {
        address payable sender;
        address payable receiver;
        uint256 amount;
        bool claimed;
    }

    struct NFTTransfer {
        address sender;
        address receiver;
        uint256 tokenId;
        bool claimed;
    }

    struct TokenTransfer {
        address sender;
        address receiver;
        uint256 amount;
        bool claimed;
    }

    mapping(address => Transfer) private transfers;
    mapping(address => NFTTransfer) private nftTransfers;
    mapping(address => TokenTransfer) private tokenTransfers;

    address public constant efrogsNFTAddress = 0x194395587d7b169E63eaf251E86B1892fA8f1960;
    address public constant croakTokenAddress = 0xaCb54d07cA167934F57F829BeE2cC665e1A5ebEF;

    IERC721 private efrogsNFT = IERC721(efrogsNFTAddress);
    IERC20 private croakToken = IERC20(croakTokenAddress);

    event EtherSent(address indexed sender, address indexed receiver, uint256 amount);
    event EtherClaimed(address indexed sender, address indexed receiver, uint256 amount);
    event EtherClaimedBack(address indexed sender, uint256 amount);

    event NFTSent(address indexed sender, address indexed receiver, uint256 tokenId);
    event NFTClaimed(address indexed sender, address indexed receiver, uint256 tokenId);
    event NFTClaimedBack(address indexed sender, uint256 tokenId);

    event TokenSent(address indexed sender, address indexed receiver, uint256 amount);
    event TokenClaimed(address indexed sender, address indexed receiver, uint256 amount);
    event TokenClaimedBack(address indexed sender, uint256 amount);

    modifier onlySender(address senderAddr) {
        require(msg.sender == transfers[senderAddr].sender, "Only sender can call this function");
        _;
    }

    modifier notClaimed(address senderAddr) {
        require(!transfers[senderAddr].claimed, "Transfer has already been claimed");
        _;
    }

    modifier onlyNFTSender(address senderAddr) {
        require(msg.sender == nftTransfers[senderAddr].sender, "Only sender can call this function");
        _;
    }

    modifier nftNotClaimed(address senderAddr) {
        require(!nftTransfers[senderAddr].claimed, "Transfer has already been claimed");
        _;
    }

    modifier onlyTokenSender(address senderAddr) {
        require(msg.sender == tokenTransfers[senderAddr].sender, "Only sender can call this function");
        _;
    }

    modifier tokenNotClaimed(address senderAddr) {
        require(!tokenTransfers[senderAddr].claimed, "Transfer has already been claimed");
        _;
    }

    // Ether functions
    function sendEther(address payable receiver) external payable nonReentrant {
        require(msg.value > 0, "Must send a positive amount");
        require(transfers[msg.sender].amount == 0, "Existing transfer must be claimed first");

        transfers[msg.sender] = Transfer({
            sender: payable(msg.sender),
            receiver: receiver,
            amount: msg.value,
            claimed: false
        });

        emit EtherSent(msg.sender, receiver, msg.value);
    }

    function claimEther(address senderAddr) external nonReentrant notClaimed(senderAddr) {
        require(msg.sender == transfers[senderAddr].receiver, "You are not the intended receiver");

        transfers[senderAddr].claimed = true;
        uint256 amount = transfers[senderAddr].amount;

        // Reset the transfer data
        transfers[senderAddr] = Transfer({
            sender: payable(address(0)),
            receiver: payable(address(0)),
            amount: 0,
            claimed: true
        });

        payable(msg.sender).transfer(amount);

        emit EtherClaimed(transfers[senderAddr].sender, msg.sender, amount);
    }

    function claimBackEther() external nonReentrant onlySender(msg.sender) notClaimed(msg.sender) {
        uint256 amount = transfers[msg.sender].amount;

        // Reset the transfer data
        transfers[msg.sender] = Transfer({
            sender: payable(address(0)),
            receiver: payable(address(0)),
            amount: 0,
            claimed: true
        });

        payable(msg.sender).transfer(amount);

        emit EtherClaimedBack(msg.sender, amount);
    }

    // NFT functions
    function sendEfrogs(address receiver, uint256 tokenId) external nonReentrant {
        require(efrogsNFT.ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(nftTransfers[msg.sender].tokenId == 0, "Existing transfer must be claimed first");

        efrogsNFT.transferFrom(msg.sender, address(this), tokenId);

        nftTransfers[msg.sender] = NFTTransfer({
            sender: msg.sender,
            receiver: receiver,
            tokenId: tokenId,
            claimed: false
        });

        emit NFTSent(msg.sender, receiver, tokenId);
    }

    function claimEfrogs(address senderAddr) external nonReentrant nftNotClaimed(senderAddr) {
        require(msg.sender == nftTransfers[senderAddr].receiver, "You are not the intended receiver");

        nftTransfers[senderAddr].claimed = true;
        uint256 tokenId = nftTransfers[senderAddr].tokenId;

        // Reset the NFT transfer data
        nftTransfers[senderAddr] = NFTTransfer({
            sender: address(0),
            receiver: address(0),
            tokenId: 0,
            claimed: true
        });

        efrogsNFT.transferFrom(address(this), msg.sender, tokenId);

        emit NFTClaimed(nftTransfers[senderAddr].sender, msg.sender, tokenId);
    }

    function claimBackEfrogs() external nonReentrant onlyNFTSender(msg.sender) nftNotClaimed(msg.sender) {
        uint256 tokenId = nftTransfers[msg.sender].tokenId;

        // Reset the NFT transfer data
        nftTransfers[msg.sender] = NFTTransfer({
            sender: address(0),
            receiver: address(0),
            tokenId: 0,
            claimed: true
        });

        efrogsNFT.transferFrom(address(this), msg.sender, tokenId);

        emit NFTClaimedBack(msg.sender, tokenId);
    }

    // Token functions
    function sendCROAK(address receiver, uint256 amount) external nonReentrant {
        require(croakToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(tokenTransfers[msg.sender].amount == 0, "Existing transfer must be claimed first");

        croakToken.transferFrom(msg.sender, address(this), amount);

        tokenTransfers[msg.sender] = TokenTransfer({
            sender: msg.sender,
            receiver: receiver,
            amount: amount,
            claimed: false
        });

        emit TokenSent(msg.sender, receiver, amount);
    }

    function claimCROAK(address senderAddr) external nonReentrant tokenNotClaimed(senderAddr) {
        require(msg.sender == tokenTransfers[senderAddr].receiver, "You are not the intended receiver");

        tokenTransfers[senderAddr].claimed = true;
        uint256 amount = tokenTransfers[senderAddr].amount;

        // Reset the token transfer data
        tokenTransfers[senderAddr] = TokenTransfer({
            sender: address(0),
            receiver: address(0),
            amount: 0,
            claimed: true
        });

        croakToken.transfer(msg.sender, amount);

        emit TokenClaimed(tokenTransfers[senderAddr].sender, msg.sender, amount);
    }

    function claimBackCROAK() external nonReentrant onlyTokenSender(msg.sender) tokenNotClaimed(msg.sender) {
        uint256 amount = tokenTransfers[msg.sender].amount;

        // Reset the token transfer data
        tokenTransfers[msg.sender] = TokenTransfer({
            sender: address(0),
            receiver: address(0),
            amount: 0,
            claimed: true
        });

        croakToken.transfer(msg.sender, amount);

        emit TokenClaimedBack(msg.sender, amount);
    }

    // Getter functions
    function getEtherTransfer(address senderAddr) external view returns (address, address, uint256, bool) {
        Transfer memory transfer = transfers[senderAddr];
        return (transfer.sender, transfer.receiver, transfer.amount, transfer.claimed);
    }

    function getNFTTransfer(address senderAddr) external view returns (address, address, uint256, bool) {
        NFTTransfer memory transfer = nftTransfers[senderAddr];
        return (transfer.sender, transfer.receiver, transfer.tokenId, transfer.claimed);
    }

    function getTokenTransfer(address senderAddr) external view returns (address, address, uint256, bool) {
        TokenTransfer memory transfer = tokenTransfers[senderAddr];
        return (transfer.sender, transfer.receiver, transfer.amount, transfer.claimed);
    }
}
