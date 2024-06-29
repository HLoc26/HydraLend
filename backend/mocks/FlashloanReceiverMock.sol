// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract FlashloanReceiverMock {
    constructor(address pool, address weth, address wbtc) {
        IERC20(weth).approve(address(pool), type(uint256).max);
        IERC20(wbtc).approve(address(pool), type(uint256).max);
    }
    function onFlashLoan(
        address initiator,
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external returns (bool) {
        // do user operations

        return true;
    }
}

contract BadFlashloanReceiverMock {
    constructor(address pool, address weth, address wbtc) {
        IERC20(weth).approve(address(pool), type(uint256).max);
        IERC20(wbtc).approve(address(pool), type(uint256).max);
    }

    function onFlashLoan(
        address initiator,
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external returns (bool) {
        // do user operations

        // will always return false which should revert the flashloan tx
        return false;
    }
}
