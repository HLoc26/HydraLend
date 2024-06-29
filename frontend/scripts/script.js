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

const supply_container = document.getElementById("supply-container");
const borrow20_container = document.getElementById("borrow20-container");
const borrow721_container = document.getElementById("borrow721-container");

borrow20.addEventListener("click", () => {
  title.textContent = "Borrow by pledging ERC20s";
  // show the class borrow 20, hide the other 2
  borrow20_container.style.display = "grid";
  borrow721_container.style.display = "none";
  supply_container.style.display = "none";
});
borrow721.addEventListener("click", () => {
  title.textContent = "Borrow by pledging NFTs";
  // show the class borrow 721, hide the other 2
  borrow20_container.style.display = "none";
  console.log(borrow721_container.display);
  borrow721_container.style.display = "grid";
  supply_container.style.display = "none";
});
supply.addEventListener("click", () => {
  title.textContent = "Supply ERC20s";
  // show the class supply, hide the other 2
  borrow20_container.style.display = "none";
  borrow721_container.style.display = "none";
  supply_container.style.display = "grid";
});
