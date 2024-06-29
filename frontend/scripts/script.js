// connected
if (window.ethereum._state.isConnected == true) {
  document.getElementById("accountBtn").textContent = "Account";
} else {
  document.getElementById("addrBtn").style.display = "none";
}

const borrow20 = document.getElementById("erc20");
const borrow721 = document.getElementById("erc721");
const supply = document.getElementById("supply");
const title = document.getElementById("title");

borrow20.addEventListener("click", () => {
  title.textContent = "Borrow ERC20";
});
borrow721.addEventListener("click", () => {
  title.textContent = "Borrow ERC721";
});
supply.addEventListener("click", () => {
  title.textContent = "Supply ERC20";
});
