//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface FlashLoanReceiverInterface {
    /**
     * @param initiator ng bat dau khoan vay
     * @param token token vay
     * @param amounts so tien vay
     * @param fees phi vay
     * @param data user-defined parameters
     * @return bool success or not
     */
    function onFlashLoan(
        address initiator,
        address[] calldata token,
        uint256[] calldata amounts,
        uint256[] calldata fees,
        bytes calldata data
    ) external returns (bool);
}