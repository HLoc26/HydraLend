// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../interfaces/Structs.sol";

library VaultAccounting {
    function toShares(
        Structs.Vault memory total,
        uint256 amount,
        bool roundUp
    ) internal pure returns (uint256 shares) {
        if(total.amount == 0) {
            shares = amount;
        } else {
            shares = (amount * total.shares) / total.amount;
            if (roundUp && (shares * total.amount) / total.shares < amount) {
                shares = shares + 1;
            }
        }
    }

    function toAmount(
        Structs.Vault memory total,
        uint256 shares,
        bool roundUp
    ) internal pure returns (uint256 amount) {
        if(total.shares == 0) {
            amount = shares;
        } else {
            amount = (shares * total.amount) / total.shares;
            if (roundUp && (amount * total.shares) / total.amount < shares) {
                amount = amount + 1;
            }
        }
    }
}