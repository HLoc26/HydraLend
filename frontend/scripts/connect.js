import { ethers } from "./ethers-5.1.esm.min.js";

var connectedAddr = "0x0";

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
  var balance = await getBalance(connectedAddr);
  document.getElementById("balance").textContent = balance.toString();

  document.getElementById("selected-unit").textContent = " " + unitSelect.options[unitSelect.selectedIndex].text;
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
