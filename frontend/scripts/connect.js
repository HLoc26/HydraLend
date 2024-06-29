import { ethers } from "./ethers-5.1.esm.min.js";

var connectedAddr = "0x0";

// check for user's chain
const chainIdHex = await window.ethereum.request({ method: "eth_chainId" });

if (chainIdHex != "0xa869") {
  alert("You are not on avalanche C-Chain, please connect to chainId 43113");
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
  if (typeof window.ethereum != "undefined") {
    try {
      var addrs = await window.ethereum.request({ method: "eth_requestAccounts" });
    } catch (error) {
      console.log(error);
    }
    // Handle account changed
    document.getElementById("accountBtn").innerHTML = "Connected";
    connectedAddr = addrs[addrs.length - 1];
    var len = connectedAddr.length;
    document.getElementById("addrBtn").innerHTML = connectedAddr.substr(0, 6) + "..." + connectedAddr.substr(len - 4, len);
    document.getElementById("addrBtn").style.display = "block";
    await changeBalance();
  } else {
    document.getElementById("title").innerHTML = "TitleText";
  }
}
var accountBtn = document.getElementById("accountBtn");
accountBtn.onclick = connect;

// Handle changed unit
const unitSelect = document.getElementById("unit");
var selectedSymbol = unitSelect.value;

unitSelect.addEventListener("change", () => {
  selectedSymbol = unitSelect.value;
  console.log(`Symbol changed to ${selectedSymbol}`);
  // Convert balance
  changeBalance();
});

// Change balance display
async function changeBalance() {
  var balance = await getBalance(connectedAddr); // currently at AVAX

  var unit = unitSelect.options[unitSelect.selectedIndex].text;

  // Change input and balance's value according to unit
  var conversionRate = await getConversionRate();
  if (unit == "ETH") {
    var balance_num = Number(balance);
    balance = balance_num / conversionRate;
    console.log(`Converted from ${balance_num} AVAX to ${balance} ETH`);
  }
  document.getElementById("balance").textContent = balance.toString();
  document.getElementById("selected-unit").textContent = " " + unit;
}

// get conversion rate
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
    console.error("Error fetching balance: ", error);
  }
}
