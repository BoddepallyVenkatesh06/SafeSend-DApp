SafeSend Contract - Linea Hackathon 2024: Dev Cook-Off with Linea

Author: Konstantinos Andreou

Description:
The SafeSend contract facilitates secure and authenticated transfers of Ether, Efrogs NFTs, and $CROAK Meme Tokens between parties. It integrates additional authentication measures to prevent the loss of funds due to mistyped wallet addresses.

Features:

    Ether Transfers: Secure transfer of Ether with claim and reclaim functionalities.

    Efrogs NFT Transfers: Secure transfer of Efrogs NFTs with claim and reclaim functionalities.

    $CROAK Meme Token Transfers: Secure transfer of $CROAK tokens with claim and reclaim functionalities.

Security Measures:

    Utilizes OpenZeppelin's ReentrancyGuard to protect against reentrancy attacks.

    Implements comprehensive modifiers to ensure that only the designated sender or receiver can claim or reclaim the transfers.

    Ensures that each transfer must be claimed or reclaimed before a new transfer can be initiated by the same sender.

Dependencies:

    OpenZeppelin Contracts: Imported to leverage secure and audited implementations of common contract functionalities.
        @openzeppelin/contracts/security/ReentrancyGuard.sol
        @openzeppelin/contracts/token/ERC721/IERC721.sol
        @openzeppelin/contracts/token/ERC20/IERC20.sol


Smart Contract Overview

The SafeSend contract is designed to securely manage Ether, NFT, and token transfers with additional safety checks.

Structure Definitions:

    Transfer: Manages Ether transfers.

        address payable sender
        address payable receiver
        uint256 amount
        bool claimed
        NFTTransfer: Manages Efrogs NFT transfers.

        address sender
        address receiver
        uint256 tokenId
        bool claimed
        TokenTransfer: Manages $CROAK token transfers.

        address sender
        address receiver
        uint256 amount
        bool claimed

    Key Functions:

    Ether Functions:

        sendEther(address payable receiver) external payable nonReentrant
        claimEther(address senderAddr) external nonReentrant notClaimed(senderAddr)
        claimBackEther() external nonReentrant onlySender(msg.sender) notClaimed(msg.sender)
        NFT Functions:

        sendEfrogs(address receiver, uint256 tokenId) external nonReentrant
        claimEfrogs(address senderAddr) external nonReentrant nftNotClaimed(senderAddr)
        claimBackEfrogs() external nonReentrant onlyNFTSender(msg.sender) nftNotClaimed(msg.sender)
        Token Functions:

        sendCROAK(address receiver, uint256 amount) external nonReentrant
        claimCROAK(address senderAddr) external nonReentrant tokenNotClaimed(senderAddr)
        claimBackCROAK() external nonReentrant onlyTokenSender(msg.sender) tokenNotClaimed(msg.sender)
        Getter Functions:

        getEtherTransfer(address senderAddr) external view returns (address, address, uint256, bool)
        getNFTTransfer(address senderAddr) external view returns (address, address, uint256, bool)
        getTokenTransfer(address senderAddr) external view returns (address, address, uint256, bool)
        Security Modifiers:

        onlySender(address senderAddr)
        notClaimed(address senderAddr)
        onlyNFTSender(address senderAddr)
        nftNotClaimed(address senderAddr)
        onlyTokenSender(address senderAddr)
        tokenNotClaimed(address senderAddr)
        Deployment

    Ensure the contract addresses for efrogsNFTAddress and croakTokenAddress are correctly set.
    Compile and deploy the contract using a compatible Ethereum development environment (e.g., Remix, Truffle).
    Usage

    Send Ether, NFT, or Tokens: Initiate a transfer using the respective send function.
        Claim: The designated receiver can claim the transfer using the respective claim function.
        Claim Back: The sender can reclaim the transfer if it has not been claimed by the receiver.

        
Conclusion
The SafeSend contract provides a secure and reliable way to manage transfers of Ether, Efrogs NFTs, and $CROAK Meme Tokens, ensuring that only the intended recipients can claim the assets, thus preventing accidental losses due to mistyped addresses.