// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Helper} from "../libraries/Helper.sol";
import {VaultAccounting} from "../libraries/VaultAccounting.sol";
import {InterestRate} from "../libraries/InterestRate.sol";
import {Pausing} from "../utils/Pausing.sol";
import {Structs} from "../interfaces/Structs.sol";
import {FlashLoanReceiverInterface} from "../interfaces/FlashLoanReceiverInterface.sol";
import {NFTPledging} from "./NFTPledging.sol";
import "../libraries/Helper.sol";

contract HydraPool is Pausing, NFTPledging {
    using VaultAccounting for Structs.Vault;
    using InterestRate for Structs.VaultInfo;
    using Helper for address;

    mapping(address => Structs.TokenVault) private vaults;
    mapping(address => mapping(address => Structs.AccountShares))
        private userShares;
    mapping(address => mapping(address => mapping(uint256 => Structs.LiquidatedWarning)))
        private nftLiquidationWarning;

    error TooHighSlipage();
    error InsufficientBalance();
    error BelowHealthFactor();
    error BorrowerIsSolvant();
    error SelfLiquidation();
    error InvalidNFTLiquidation(
        address borrower,
        address nftAddress,
        uint256 tokenId
    );
    error InvalidFeeRate(uint256 fee);
    error InvalidReserveRatio(uint256 ratio);
    error FlashloanPaused(address token);
    error FlashloanFailed();
    error NoLiquidationWarning();
    error WarningDelayHasNotPassed();
    error MustPayMoreDebt();
    error LiquidatorDelayHasNotPassed();
    error EmptyArray();
    error ArrayMismatch();

    event Deposit(address user, address token, uint256 amount, uint256 shares);
    event Borrow(address user, address token, uint256 amount, uint256 shares);
    event Repay(address user, address token, uint256 amount, uint256 shares);
    event Withdraw(address user, address token, uint256 amount, uint256 shares);
    event Liquidated(
        address borrower,
        address liquidator,
        uint repaidAmount,
        uint256 liquidatedCollateral,
        uint256 reward
    );
    event UpdateInterestRate(uint256 elapsedTime, uint64 newInterestRate);
    event AccuredInterest(
        uint64 interestRatePerSec,
        uint256 interestEarned,
        uint256 feesAmount,
        uint256 feesShare
    );
    event FlashloanSuccess(
        address initiator,
        address[] token,
        uint256[] amount,
        uint256[] fees,
        bytes data
    );
    event DepositNFT(address user, address nftAddress, tokenId);
    event WithdrawNFT(
        address user,
        address recipient,
        address nftAddress,
        uint256 tokenId
    );
    event LiquidatingNFTWarning(
        address liquidator,
        address borrower,
        address nftAddress,
        uint256 tokenId
    );
    event LiquidatingNFTStopped(
        address borrower,
        address nftAddres,
        uint256 tokenId
    );
    event NFTLiquidated(
        address liquidator,
        address borrower,
        address nftAddress,
        uint256 tokenId,
        uint256 totalRepayDebt,
        uint256 nftBuyPrice
    );
    event NewVaultSetup(
        address token,
        Structs.VaultSetupParams param
    );

    //Make a subnet that create a token, then replace daiAddress with token address and everything
    constructor(
        address daiAddress,
        address daiPriceFeed,
        Structs.VaultSetupParams memory daiVaultParams
    ) {
        _setupVault(
            daiAddress,
            daiPriceFeed,
            Structs.TokenType.ERC20,
            daiVaultParams,
            true
        );
    } 
}


