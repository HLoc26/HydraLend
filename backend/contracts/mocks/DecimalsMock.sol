// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20DecimalsMock is ERC20 {
    uint8 public tokenDecimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 _decimals
    ) payable ERC20(name, symbol) {
        tokenDecimals = _decimals;
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transferInternal(address from, address to, uint256 value) public {
        _transfer(from, to, value);
    }

    function approveInternal(
        address owner,
        address spender,
        uint256 value
    ) public {
        _approve(owner, spender, value);
    }

    function decimals() public view override returns (uint8) {
        return tokenDecimals;
    }
}
