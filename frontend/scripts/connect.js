import { ethers } from "./ethers-5.1.esm.min.js";
import { contractAddr, abi, avaxAddr } from "./constants.js";
var connectedAddr = "0x0";

// Check for user's chain
const chainIdHex = await window.ethereum.request({ method: "eth_chainId" });

if (chainIdHex !== "0xa869") {
  alert("You are not on Avalanche C-Chain, please connect to chainId 43113");
  await window.ethereum.request({
    method: "wallet_switchEthereumChain",
    params: [{ chainId: "0xa869" }], // chainId must be in hexadecimal numbers
  });
}

window.ethereum.on("chainChanged", handleChainChanged);

function handleChainChanged(chainIdHex) {
  window.location.reload();
}

// Handle connection
async function connect() {
  if (typeof window.ethereum !== "undefined") {
    try {
      var addrs = await window.ethereum.request({ method: "eth_requestAccounts" });
    } catch (error) {
      console.log(error);
    }
    // Handle account changed
    document.getElementById("accountBtn").innerHTML = "Connected";
    connectedAddr = addrs[addrs.length - 1];
    var len = connectedAddr.length;
    document.getElementById("addrBtn").innerHTML = `${connectedAddr.substr(0, 6)}...${connectedAddr.substr(len - 4, len)}`;
    document.getElementById("addrBtn").style.display = "block";
    await updateBalances();
  } else {
    document.getElementById("title").innerHTML = "TitleText";
  }
}

document.getElementById("accountBtn").onclick = connect;

// Add event listeners to navbar items
document.getElementById("erc20").onclick = updateBalances;
document.getElementById("erc721").onclick = updateBalances;
document.getElementById("supply").onclick = updateBalances;

// Add event listeners to select elements
document.getElementById("supply-unit").onchange = updateBalances;
document.getElementById("borrow20-pledge-unit").onchange = updateBalances;
document.getElementById("borrow721-pledge-unit").onchange = updateBalances;

var selectedSymbol = "AVAX"; // Default to AVAX

// Update balances for each section
async function updateBalances() {
  const supplyUnit = document.getElementById("supply-unit").value;
  const borrow20Unit = document.getElementById("borrow20-pledge-unit").value;
  const borrow721Unit = document.getElementById("borrow721-pledge-unit").value;

  await updateBalanceForUnit(supplyUnit, "supply");
  await updateBalanceForUnit(borrow20Unit, "20");
  await updateBalanceForUnit(borrow721Unit, "721");
}

function updateBalanceDisplay(balance, unit, section) {
  document.getElementById(`${section}-balance`).textContent = balance.toString();
  document.getElementById(`${section}-selected-unit`).textContent = " " + unit;
}

// Coinbase API endpoint for spot price of ETH in AVAX
const apiUrl = "https://api.coinbase.com/v2/prices/ETH-AVAX/spot";

// Function to fetch spot price
async function getConversionRate() {
  try {
    const response = await fetch(apiUrl);

    if (!response.ok) {
      throw new Error("Network response was not ok");
    }

    const data = await response.json();
    console.log("Spot Price:", data.data.amount);
    return data.data.amount;
  } catch (error) {
    console.error("Error fetching spot price:", error);
    throw error;
  }
}

// Get addr's balance
async function getBalance(addr) {
  try {
    var balanceHex = await window.ethereum.request({
      method: "eth_getBalance",
      params: [addr, "latest"],
    });
    var balanceWei = ethers.BigNumber.from(balanceHex);
    console.log("Wei: ", balanceWei.toString());
    var balanceEth = ethers.utils.formatUnits(balanceWei, "ether");
    console.log("Ether: ", balanceEth);
    return balanceEth;
  } catch (error) {
    console.error("Error fetching balance:", error);
  }
}

// Function to update balance when a new unit is selected
async function updateBalanceForUnit(unit, section) {
  var balance = await getBalance(connectedAddr); // Get balance in AVAX
  var conversionRate = await getConversionRate();
  var convertedBalance;

  if (unit === "ether") {
    convertedBalance = balance / conversionRate; // Convert AVAX balance to ETH
  } else {
    convertedBalance = balance; // Keep balance in AVAX
  }

  updateBalanceDisplay(convertedBalance, unit.toUpperCase(), section);
}

// Fund
async function supply() {
  const amount = document.getElementById("supply-amount").value;
  console.log(`Funding with ${amount}...`);
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddr, abi, signer);
    try {
      const transactionResponse = await contract.supply(avaxAddr, ethers.utils.parseEther(amount), 0, {
        gasLimit: 50000,
        value: ethers.utils.parseEther(amount),
      });
      await listenForTransactionMine(transactionResponse, provider);
    } catch (error) {
      console.log(error);
    }
  } else {
    document.getElementById("supply-btn").innerHTML = "Please install MetaMask";
  }
}

const supplyBtn = document.getElementById("supply-btn");
supplyBtn.onclick = supply;

async function depositNft() {
  var recipient = contractAddr;
  var nftAddr = document.getElementById("nft-addr").value;
  var tokenId = document.getElementById("nft-token").value;
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddr, abi, signer);
    try {
      const transactionResponse = await contract.depositNft(recipient, nftAddr, tokenId);
      await listenForTransactionMine(transactionResponse, provider);
    } catch (error) {
      console.log(error);
    }
  } else {
    document.getElementById("confirm721").innerHTML = "Please install MetaMask";
  }
}
const confirm721 = document.getElementById("confirm721");
confirm721.onclick = depositNft;

async function borrow() {
  var token = document.getElementById("20-token").value;
  var amount = document.getElementById("borrow-amount").value;
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.providers.Web3Provider(windows.ethereum);
    const signer = provider.getSigner();
    const contract = new ethers.Contract(contractAddr, abi, signer);
    try {
      const transactionResponse = await contract.borrow(token, amount);
      await listenForTransactionMine(transactionResponse, provider);
    } catch (error) {
      console.log(error);
    }
  } else {
    document.getElementById("confirm20").innerHTML = "Please install MetaMask";
  }
}
const confirm20 = document.getElementById("confirm20");
confirm20.onclick = depositNft;

function listenForTransactionMine(transactionResponse, provider) {
  console.log(`Mining ${transactionResponse.hash}`);
  return new Promise((resolve, reject) => {
    try {
      provider.once(transactionResponse.hash, (transactionReceipt) => {
        console.log(`Completed with ${transactionReceipt.confirmations} confirmations. `);
        resolve();
      });
    } catch (error) {
      reject(error);
    }
  });
}
