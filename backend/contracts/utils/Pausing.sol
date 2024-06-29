// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Pausing is Ownable {

    bool public globalPaused = true;

    mapping (address vaulToken => bool status) vaultPaused;

    error isPaused();
    error isNotPaused();

    event SystemPaused(bool state);
    event VaultPaused(address vault, bool state);

    function WhenPaused(address vault) internal view {
        if (!globalPaused && !vaultPaused[vault]) revert isNotPaused();
    }

    function WhenNotPaused(address vault) internal view {
        if (pausedStatus(vault)) revert isPaused();
    }

    function pausedStatus(address vault) public view returns (bool) {
        return globalPaused || vaultPaused[vault];
    }

    function setPausedStatus(address vault, bool status) external onlyOwner {
        if (vault == address(0)) {
            // pass address(0) to pause/unpause all vaults
            globalPaused = status;
            emit SystemPaused(status);
        } else {
            vaultPaused[vault] = status;
            emit VaultPaused(vault, status);
        }
    }
}