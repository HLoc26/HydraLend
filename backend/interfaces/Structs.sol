//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface Structs {
    enum TokenType {
        ERC20,
        ERC721
    }

    struct SupportedToken {
        address usdPriceFeed;
        TokenType tokenType;
        bool supported;
    }

    struct AccountShares {
        uint256 collateral;
        uint256 borrow;
    }

    struct Vault {
        uint256 amount;
        uint256 shares;
    }

    struct TokenVault {
        Vault totalAsset;
        Vault totalBorrow;
        VaultInfo vaultInfo;
    }

    struct VaultInfo {
        uint256 reserveRatio;
        uint64 feeToProtocolRate;
        uint64 flashFeeRate;
        uint64 ratePerSec;
        uint64 lastTimestamp;
        uint64 lastBlock;
        uint64 baseRate;
        uint64 additionalParam1;
        uint64 additionalParam2;
        uint256 optimalUtilization;
    }

    struct LiquidatedWarning {
        address liquidator;
        uint64 liquidationTimestamp;
    }

    struct VaultSetupParamemters {
        uint64 reserveRatio;
        uint64 feeToProtocolRate;
        uint64 flashFeeRate;
        uint64 baseRate;
        uint64 additionalParam1;
        uint64 additionalParam2;
        uint256 optimalUtilization;
    }
}