const contractABI = [{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"EtherClaimed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"EtherClaimedBack","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"EtherSent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"NFTClaimed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"NFTClaimedBack","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"NFTSent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"TokenClaimed","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"TokenClaimedBack","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"sender","type":"address"},{"indexed":true,"internalType":"address","name":"receiver","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"TokenSent","type":"event"},{"inputs":[],"name":"claimBackCROAK","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"claimBackEfrogs","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"claimBackEther","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"claimCROAK","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"claimEfrogs","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"claimEther","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"croakTokenAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"efrogsNFTAddress","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"getEtherTransfer","outputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"getNFTTransfer","outputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"senderAddr","type":"address"}],"name":"getTokenTransfer","outputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"sendCROAK","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"receiver","type":"address"},{"internalType":"uint256","name":"tokenId","type":"uint256"}],"name":"sendEfrogs","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address payable","name":"receiver","type":"address"}],"name":"sendEther","outputs":[],"stateMutability":"payable","type":"function"}];

const contractAddress = "0x8C2af51e53238532eF3024A2981BAab24CF5E50E";
const sepoliaChainId = '0xe705'; // Chain ID for 59141 in hexadecimal

let web3;
let contract;
let accounts;

window.addEventListener('DOMContentLoaded', () => {
    const connectButton = document.getElementById('connectButton');
    const claimBackEtherButton = document.getElementById('claimBackEther');
    const claimEtherButton = document.getElementById('claimEther');
    const sendEtherButton = document.getElementById('sendEther');
    const claimBackCROAKButton = document.getElementById('claimBackCROAK');
    const claimCROAKButton = document.getElementById('claimCROAK');
    const sendCROAKButton = document.getElementById('sendCROAK');
    const claimBackEfrogsButton = document.getElementById('claimBackEfrogs');
    const claimEfrogsButton = document.getElementById('claimEfrogs');
    const sendEfrogsButton = document.getElementById('sendEfrogs');

    connectButton.addEventListener('click', async () => {
        if (window.ethereum) {
            try {
                accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
                web3 = new Web3(window.ethereum);
                await checkNetwork();
                contract = new web3.eth.Contract(contractABI, contractAddress);
                document.getElementById('account').textContent = `Connected: ${accounts[0]}`;
                enableButtons();
            } catch (error) {
                console.error('User denied account access or error occurred', error);
            }
        } else {
            console.error('No Ethereum provider detected');
        }
    });

    async function checkNetwork() {
        const chainId = await web3.eth.getChainId();
        if (chainId !== parseInt(sepoliaChainId, 16)) {
            try {
                await window.ethereum.request({
                    method: 'wallet_switchEthereumChain',
                    params: [{ chainId: sepoliaChainId }],
                });
            } catch (switchError) {
                if (switchError.code === 4902) {
                    console.error('This network is not available in your MetaMask, please add it manually');
                } else {
                    console.error('Failed to switch to the network', switchError);
                }
            }
        }
    }

    function enableButtons() {
        claimBackEtherButton.disabled = false;
        claimEtherButton.disabled = false;
        sendEtherButton.disabled = false;
        claimBackCROAKButton.disabled = false;
        claimCROAKButton.disabled = false;
        sendCROAKButton.disabled = false;
        claimBackEfrogsButton.disabled = false;
        claimEfrogsButton.disabled = false;
        sendEfrogsButton.disabled = false;
    }

    claimBackEtherButton.addEventListener('click', async () => {
        if (contract && accounts) {
            try {
                await contract.methods.claimBackEther().send({ from: accounts[0] });
                console.log('Ether claimed back successfully');
            } catch (error) {
                console.error('Error claiming back ether:', error);
            }
        }
    });

    claimEtherButton.addEventListener('click', async () => {
        const senderAddr = document.getElementById('etherSenderAddr').value;
        if (contract && accounts && senderAddr) {
            try {
                await contract.methods.claimEther(senderAddr).send({ from: accounts[0] });
                console.log('Ether claimed successfully');
            } catch (error) {
                console.error('Error claiming ether:', error);
            }
        }
    });

    sendEtherButton.addEventListener('click', async () => {
        const receiver = document.getElementById('etherReceiver').value;
        const amount = document.getElementById('etherAmount').value;
        if (contract && accounts && receiver && amount) {
            try {
                await contract.methods.sendEther(receiver).send({ from: accounts[0], value: web3.utils.toWei(amount, 'ether') });
                console.log('Ether sent successfully');
            } catch (error) {
                console.error('Error sending ether:', error);
            }
        }
    });

    claimBackCROAKButton.addEventListener('click', async () => {
        if (contract && accounts) {
            try {
                await contract.methods.claimBackCROAK().send({ from: accounts[0] });
                console.log('CROAK claimed back successfully');
            } catch (error) {
                console.error('Error claiming back CROAK:', error);
            }
        }
    });

    claimCROAKButton.addEventListener('click', async () => {
        const senderAddr = document.getElementById('croakSenderAddr').value;
        if (contract && accounts && senderAddr) {
            try {
                await contract.methods.claimCROAK(senderAddr).send({ from: accounts[0] });
                console.log('CROAK claimed successfully');
            } catch (error) {
                console.error('Error claiming CROAK:', error);
            }
        }
    });

    sendCROAKButton.addEventListener('click', async () => {
        const receiver = document.getElementById('croakReceiver').value;
        const amount = document.getElementById('croakAmount').value;
        if (contract && accounts && receiver && amount) {
            try {
                await contract.methods.sendCROAK(receiver, amount).send({ from: accounts[0] });
                console.log('CROAK sent successfully');
            } catch (error) {
                console.error('Error sending CROAK:', error);
            }
        }
    });

    claimBackEfrogsButton.addEventListener('click', async () => {
        if (contract && accounts) {
            try {
                await contract.methods.claimBackEfrogs().send({ from: accounts[0] });
                console.log('Efrogs claimed back successfully');
            } catch (error) {
                console.error('Error claiming back Efrogs:', error);
            }
        }
    });

    claimEfrogsButton.addEventListener('click', async () => {
        const senderAddr = document.getElementById('efrogsSenderAddr').value;
        if (contract && accounts && senderAddr) {
            try {
                await contract.methods.claimEfrogs(senderAddr).send({ from: accounts[0] });
                console.log('Efrogs claimed successfully');
            } catch (error) {
                console.error('Error claiming Efrogs:', error);
            }
        }
    });

    sendEfrogsButton.addEventListener('click', async () => {
        const receiver = document.getElementById('efrogsReceiver').value;
        const tokenId = document.getElementById('efrogsTokenId').value;
        if (contract && accounts && receiver && tokenId) {
            try {
                await contract.methods.sendEfrogs(receiver, tokenId).send({ from: accounts[0] });
                console.log('Efrogs sent successfully');
            } catch (error) {
                console.error('Error sending Efrogs:', error);
            }
        }
    });
});
