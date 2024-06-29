// connected
if (window.ethereum._state.isConnected == true) {
  document.getElementById("accountBtn").textContent = "Account";
} else {
  document.getElementById("addrBtn").style.display = "none";
}
