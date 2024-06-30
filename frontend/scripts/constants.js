export const contractAddr = "0xa0361dD679b25933174221743B998290fBd0593c";
export const avaxAddr = "0x5498BB86BC934c8D34FDA08E81D444153d0D06aD";
export const abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "daiAddress",
        type: "address",
      },
      {
        internalType: "address",
        name: "daiPriceFeed",
        type: "address",
      },
      {
        components: [
          {
            internalType: "uint64",
            name: "reserveRatio",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "feeToProtocolRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "flashFeeRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "baseRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope1",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope2",
            type: "uint64",
          },
          {
            internalType: "uint256",
            name: "optimalUtilization",
            type: "uint256",
          },
        ],
        internalType: "struct Structs.VaultSetupParamemters",
        name: "daiVaultParams",
        type: "tuple",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [],
    name: "AlreadySupported",
    type: "error",
  },
  {
    inputs: [],
    name: "ArrayMismatch",
    type: "error",
  },
  {
    inputs: [],
    name: "BelowHealthFactor",
    type: "error",
  },
  {
    inputs: [],
    name: "BorrowerIsSolvant",
    type: "error",
  },
  {
    inputs: [],
    name: "EmptyArray",
    type: "error",
  },
  {
    inputs: [],
    name: "FlashloanFailed",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "FlashloanPaused",
    type: "error",
  },
  {
    inputs: [],
    name: "InsufficientBalance",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "fee",
        type: "uint256",
      },
    ],
    name: "InvalidFeeRate",
    type: "error",
  },
  {
    inputs: [],
    name: "InvalidNFT",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "borrower",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "InvalidNFTLiquidation",
    type: "error",
  },
  {
    inputs: [],
    name: "InvalidPrice",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "ratio",
        type: "uint256",
      },
    ],
    name: "InvalidReserveRatio",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "enum Structs.TokenType",
        name: "tokenType",
        type: "uint8",
      },
    ],
    name: "InvalidTokenType",
    type: "error",
  },
  {
    inputs: [],
    name: "LiquidatorDelayHasNotPassed",
    type: "error",
  },
  {
    inputs: [],
    name: "MustPayMoreDebt",
    type: "error",
  },
  {
    inputs: [],
    name: "NoLiquidationWarning",
    type: "error",
  },
  {
    inputs: [],
    name: "SelfLiquidation",
    type: "error",
  },
  {
    inputs: [],
    name: "TokenNotSupported",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "sharesOutOrAmountIn",
        type: "uint256",
      },
    ],
    name: "TooHighSlipage",
    type: "error",
  },
  {
    inputs: [],
    name: "TransferFailed",
    type: "error",
  },
  {
    inputs: [],
    name: "WarningDelayHasNotPassed",
    type: "error",
  },
  {
    inputs: [],
    name: "isNotPaused",
    type: "error",
  },
  {
    inputs: [],
    name: "isPaused",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint64",
        name: "interestRatePerSec",
        type: "uint64",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "interestEarned",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "feesAmount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "feesShare",
        type: "uint256",
      },
    ],
    name: "AccuredInterest",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: false,
        internalType: "enum Structs.TokenType",
        name: "tokenType",
        type: "uint8",
      },
    ],
    name: "AddSupportedToken",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
    ],
    name: "Borrow",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
    ],
    name: "Deposit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "DepositNFT",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "initiator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address[]",
        name: "token",
        type: "address[]",
      },
      {
        indexed: false,
        internalType: "uint256[]",
        name: "amount",
        type: "uint256[]",
      },
      {
        indexed: false,
        internalType: "uint256[]",
        name: "fees",
        type: "uint256[]",
      },
      {
        indexed: false,
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "FlashloanSuccess",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "borrower",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "liquidator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "repaidAmount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "liquidatedCollateral",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "reward",
        type: "uint256",
      },
    ],
    name: "Liquidated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "borrower",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "nftAddres",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "LiquidatingNFTStopped",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "liquidator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "borrower",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "LiquidatingNFTWarning",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "liquidator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "borrower",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "totalRepayDebt",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "nftBuyPrice",
        type: "uint256",
      },
    ],
    name: "NFTLiquidated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        components: [
          {
            internalType: "uint64",
            name: "reserveRatio",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "feeToProtocolRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "flashFeeRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "baseRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope1",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope2",
            type: "uint64",
          },
          {
            internalType: "uint256",
            name: "optimalUtilization",
            type: "uint256",
          },
        ],
        indexed: false,
        internalType: "struct Structs.VaultSetupParamemters",
        name: "params",
        type: "tuple",
      },
    ],
    name: "NewVaultSetup",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
    ],
    name: "Repay",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bool",
        name: "state",
        type: "bool",
      },
    ],
    name: "SystemPaused",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "elapsedTime",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint64",
        name: "newInterestRate",
        type: "uint64",
      },
    ],
    name: "UpdateInterestRate",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "vault",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "state",
        type: "bool",
      },
    ],
    name: "VaultPaused",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
    ],
    name: "Withdraw",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "WithdrawNFT",
    type: "event",
  },
  {
    inputs: [],
    name: "BLOCKS_PER_YEAR",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "BPS",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "PRECISION",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "accureInterest",
    outputs: [
      {
        internalType: "uint256",
        name: "_interestEarned",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_feesAmount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_feesShare",
        type: "uint256",
      },
      {
        internalType: "uint64",
        name: "_newRate",
        type: "uint64",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "isAsset",
        type: "bool",
      },
    ],
    name: "amountToShares",
    outputs: [
      {
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "borrow",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "canLiquidateNFT",
    outputs: [],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "depositNft",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
      {
        internalType: "address[]",
        name: "repayTokens",
        type: "address[]",
      },
      {
        internalType: "uint256[]",
        name: "repayAmounts",
        type: "uint256[]",
      },
    ],
    name: "executeNFTLiquidation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "receiverAddress",
        type: "address",
      },
      {
        internalType: "address[]",
        name: "tokens",
        type: "address[]",
      },
      {
        internalType: "uint256[]",
        name: "amounts",
        type: "uint256[]",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "flashloan",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "flashloanFee",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "getAmountInUSD",
    outputs: [
      {
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
    ],
    name: "getDepositedNFT",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
    ],
    name: "getDepositedNFTCount",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "getNFTLiquidationWarning",
    outputs: [
      {
        components: [
          {
            internalType: "address",
            name: "liquidator",
            type: "address",
          },
          {
            internalType: "uint64",
            name: "liquidationTimestamp",
            type: "uint64",
          },
        ],
        internalType: "struct Structs.LiquidatedWarning",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "getTokenPrice",
    outputs: [
      {
        internalType: "uint256",
        name: "price",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "getTokenVault",
    outputs: [
      {
        components: [
          {
            components: [
              {
                internalType: "uint256",
                name: "amount",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "shares",
                type: "uint256",
              },
            ],
            internalType: "struct Structs.Vault",
            name: "totalAsset",
            type: "tuple",
          },
          {
            components: [
              {
                internalType: "uint256",
                name: "amount",
                type: "uint256",
              },
              {
                internalType: "uint256",
                name: "shares",
                type: "uint256",
              },
            ],
            internalType: "struct Structs.Vault",
            name: "totalBorrow",
            type: "tuple",
          },
          {
            components: [
              {
                internalType: "uint256",
                name: "reserveRatio",
                type: "uint256",
              },
              {
                internalType: "uint64",
                name: "feeToProtocolRate",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "flashFeeRate",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "ratePerSec",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "lastTimestamp",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "lastBlock",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "baseRate",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "slope1",
                type: "uint64",
              },
              {
                internalType: "uint64",
                name: "slope2",
                type: "uint64",
              },
              {
                internalType: "uint256",
                name: "optimalUtilization",
                type: "uint256",
              },
            ],
            internalType: "struct Structs.VaultInfo",
            name: "vaultInfo",
            type: "tuple",
          },
        ],
        internalType: "struct Structs.TokenVault",
        name: "vault",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "getUserData",
    outputs: [
      {
        internalType: "uint256",
        name: "totalTokenCollateral",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "totalNFTCollateral",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "totalBorrowValue",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "getUserNFTCollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "totalValueInUSD",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "getUserTokenCollateralAndBorrow",
    outputs: [
      {
        internalType: "uint256",
        name: "tokenCollateralShare",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "tokenBorrowShare",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "getUserTotalBorrow",
    outputs: [
      {
        internalType: "uint256",
        name: "totalValueInUSD",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "getUserTotalTokenCollateral",
    outputs: [
      {
        internalType: "uint256",
        name: "totalValueInUSD",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "globalPaused",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "hasDepositedNFT",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "user",
        type: "address",
      },
    ],
    name: "healthFactor",
    outputs: [
      {
        internalType: "uint256",
        name: "factor",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "collateral",
        type: "address",
      },
      {
        internalType: "address",
        name: "userBorrowToken",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amountToLiquidate",
        type: "uint256",
      },
    ],
    name: "liquidate",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
    ],
    name: "maxFlashloan",
    outputs: [
      {
        internalType: "uint256",
        name: "maxFlashloanAmount",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "address",
        name: "",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "onERC721Received",
    outputs: [
      {
        internalType: "bytes4",
        name: "",
        type: "bytes4",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "vault",
        type: "address",
      },
    ],
    name: "pausedStatus",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "minAmountOut",
        type: "uint256",
      },
    ],
    name: "redeem",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "repay",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "vault",
        type: "address",
      },
      {
        internalType: "bool",
        name: "status",
        type: "bool",
      },
    ],
    name: "setPausedStatus",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "address",
        name: "priceFeed",
        type: "address",
      },
      {
        internalType: "enum Structs.TokenType",
        name: "tokenType",
        type: "uint8",
      },
      {
        components: [
          {
            internalType: "uint64",
            name: "reserveRatio",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "feeToProtocolRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "flashFeeRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "baseRate",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope1",
            type: "uint64",
          },
          {
            internalType: "uint64",
            name: "slope2",
            type: "uint64",
          },
          {
            internalType: "uint256",
            name: "optimalUtilization",
            type: "uint256",
          },
        ],
        internalType: "struct Structs.VaultSetupParamemters",
        name: "params",
        type: "tuple",
      },
      {
        internalType: "bool",
        name: "addToken",
        type: "bool",
      },
    ],
    name: "setupVault",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "shares",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "isAsset",
        type: "bool",
      },
    ],
    name: "sharesToAmount",
    outputs: [
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "stopNFTLiquidation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "minSharesOut",
        type: "uint256",
      },
    ],
    name: "supply",
    outputs: [],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "nftAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "triggerNFTiquidation",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "maxShareIn",
        type: "uint256",
      },
    ],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];
