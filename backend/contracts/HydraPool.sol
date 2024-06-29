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
    /*/////////////////////////////////////////////
                 GETTER FUNCTIONS
    //////////////////////////////////////////////*/

    function getUserData(
        address user
    ) public view 
    returns (
        uint256 totalTokenCollateral,
        uint256 totalNFTCollateral,
        uint256 totalBorrowValue
    )
    {
        totalTokenCollateral = getUserTotalTokenCollateral(user);
        totalNFTCollateral = getUserTotalNFTCollateral(user);
        totalBorrowValue = getUserTotalBorrowValue(user);
    }

    function getUserTotalTokenCollateral(
        address user
    ) public view returns (uint256 totalValueInUSD) {
        uint len = supportedERC20s.length;
        for (uint256 i; i < len;) {
            address token = supportedERC20s[i];
            uint256 tokenAmount = vaults[token].totalAsset.toAmount(
                userShares[user][token].collateral,
                false
            );
            if (tokenAmount != 0) {
                totalVauleInUSD += getAmountInUSD(token, tokenAmount);
            }
            unchecked {
                ++i;
            }
        } 
    }

    function getUserNFTColatteralValue(address user) public view returns(uint256 totalValueInUSD) {
        uint len = supportedNFTs.length;
        for (uint256 i; i < len;) {
            address token = supportedNFTs[i];
            uint256 userDepositedNFTs = getDepositedNFTCount(user, nftAddress);
            if (userDepositedNFTs != 0) {
                uint256 nftFloorPrice = getTokenPrice(nftAddress);
                totalValueInUSD += userDepositedNFTs * nftFloorPrice;
            }
            unchecked {
                ++i;
            }
        }
    }

    function getUserTotalBorrow(
        address user
    ) public view returns (uint256 totalValueInUSD) {
        uint len = supportedERC20s.length;
        for (uint256 i; i < len;) {
            address token = supportedERC20s[i];
            uint256 tokenAmount = vaults[token].totalBorrow.toAmount(
                userShares[user][token].borrow,
                false
            );
            if (tokenAmount != 0) {
                totalValueInUSD += getAmountInUSD(token, tokenAmount);
            }
            unchecked {
                ++i;
            }
        }
    }

    function getUserTokenCollateralAndBorrow(
        address user,
        address token
    ) 
        external 
        view
        returns (uint256 tokenCollateralShare, uint256 tokenBorrowShare)
    {
        tokenCollateralShare = userShares[user][token].collateral;
        tokenBorrowShare = userShares[user][token].borrow;
    }

    function healthFactor(address user) public view returns (uint256 factor) {
        (
            uint256 totalTokenCollateral,
            uint256 totalNFTCollateral,
            uint256 totalBorrowValue
        ) = getUserData(user);

        uint256 userTotalCollateralValue = totalTokenCollateral +
            totalNFTCollateral;
        if (totalBorrowValue == 0) return 100 * MIN_HEALTH_FACTOR;
        uint256 collateralValueWithThreshold = (userTotalCollateralValue * 
            LIQUIDATION_THRESHOLD) / BPS;
        factor = 
            (collateralValueWithThreshold * MIN_HEALTH_FACTOR) /
            totalBorrowValue;
    }

    function getAmountInUSD(
        address token,
        uint256 amount
    ) public view returns (uint256 value) {
        uint256 price = getTokenPrice(token);
        uint8 decimals = token.tokenDecimals();
        uint256 amountIn18Decimals = amount * 10**(18 -decimals);
        value = (amountIn18Decimals * price) / PRECISION;
    }

    function getTokenVault(
        address token
    ) public view returns (Structs.TokenVault memory vault) {
        vault = vaults[token];
    }

    function getNFTLiquidationWarning(
        address account,
        address nftAddress,
        uint256 tokenId
    ) external view returns (Structs.LiquidatedWarning memory) {
        return nftLiquidationWarning[account][nftAddress][tokenId];
    }

    function amountToShares(
        address token, 
        uint256 amount,
        bool isAsset
    ) external view returns (uint256 shares) {
        if (isAsset) {
            shares = uint256(vaults[token].totalAsset.toShares(amount, false));
        } else {
            shares = uint256(vaults[token].totalBorrow.toShares(amount, false));
        }
    }

    function sharesToAmount(
        address token,
        uint256 shares,
        bool isAsset
    ) external view returns (uint256 amount) {
         if (isAsset) {
            amount = uint256(vaults[token].totalAsset.toAmount(shares, false));
        } else {
            amount = uint256(vaults[token].totalBorrow.toAmount(shares, false));
        }
    }

    function maxFlashloan(
        address token
    ) public view returns (uint256 maxFlashloamAmount) {
        maxFlashloanAmount = pausedStatus(token) ? 0 : type(uint256).max;
    }

    function flashloanFee(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        return (amount * vaults[token].VaultInfo.flashFeeRate) / BPS;
    }

    /*///////////////////////////////////////////////
                 OWNER FUNCTIONS
    ////////////////////////////////////////////////*/

    function setupVault(
        address token,
        address priceFeed,
        Structs.TokenType tokenType,
        Structs.VaultSetupParams memory params,
        bool addToken
    ) external onlyOwner {
        _setupVault(token, priceFeed, tokenType, params, addToken);
    }

    ////////INTERNAL FUNCTIONS////////

    //pulledAmount parameter represents an amount of tokens
    //that are being withdrawn or pulled from the vault. 
    //The function checks if the vault's remaining balance after
    // this withdrawal would still be above a certain reserve ratio.
    function vaultAboveReserveRatio(
        address token,
        uint256 pulledAmount
    ) internal view returns (bool isAboveReserveRatio) {
        uint256 minVaultReserve = (vaults[token].totalAsset.amount *
            vaults[token].VaultInfo.reserveRatio) / BPS;
        isAboveReserveRatio =
            vault[token].totalAsset.amount != 0 &&
            IERC20(token).balanceOf(address(this)) >= 
            minVaultReserve + pulledAmount;
    }

    function _withdraw(
        address token,
        uint256 amount,
        uint256 minAmountOutOrMaxShareIn,
        bool share
    ) internal {
        _accuredInterest(token);

        uint256 userCollateralShares = userShares[msg.sender][token].collateral;
        uint256 shares;
        if(share) {
            shares = amount;
            amount = vaults[token].totalAsset.toAmount(shares, false);
            if (amount < minAmountOutOrMaxShareIn)
                revert TooHighSlipage(amount);
        } else {
            shares = vaults[token].totalAsset.toShares(amount, false);
            if (shares > minAmountOutOrMaxShareIn)
                revert TooHighSlipage(shares);
        }
        if (
            userCollateralShares < shares ||
            IERC20(token).balanceOf(address(this)) < amount
        ) revert InsufficientBalance();
        unchecked {
            vaults[token].totalAsset.shares -= uint128(shares);
            vaults[token].totalAsset.amount -= uint128(amount);
            userShares[msg.sender][token].collateral -= shares;
        }

        token.transferERC20(address(this), msg.sender, amount);
        if (healthFactor(msg.sender) < MIN_HEALTH_FACTOR)
            revert BelowHealthFactor();
        emit Withdraw(msg.sender, token, amount, shares);
    }

    function _accuredInterest(
        address token
    ) 
        internal
        returns(
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            uint64 newRate
        )
    {
        Structs.TokenVault memory _vault = vaults[token];
        if (_vault.totalAsset.amount == 0) {
            return (0, 0, 0, 0);
        }

        //Add interest only once per block
        Structs.VaultInfo memory _currentRateInfo = _vault.vaultInfo;
        if (_currentRateInfo.lastTimestamp == block.timestamp) {
            newRate = _currentRateInfo.ratePerSec;
            return (_interestEarned, _feesAmount, _feesShare, newRate);
        }

        //If there are no borrows or vault or system is paused, no interest accured
        if(_vault.totalBorrow.shares ==0 || pausedStatus(token)) {
            _currentRateInfo.lastTimestamp =uint64(block.timestamp);
            _currentRateInfo.lastBlock = uint64(block.number);
            _vault.vaultInfo = _currentRateInfo;
        } else {
            uint256 _deltaTime = block.number - _currentRateInfo.lastBlock;
            uint256 _utilization = (_vault.totalBorrow.amount * PRECISION) /
                _vaults.totalAsset.amount;
            uint256 _newRate = _currentRateInfo.calculateInterestRate(
                _utilization
            );
            _currentRateInfo.ratePerSec = uint64(newRate);
            _currentRateInfo.lastTimestamp = uint64(block.timestamp);
            _currentRateInfo.lastBlock = uint64(block.number);

            emit UpdateInterestRate(_deltaTime, uint64(_newRate));

            //Calculate interest accures
            _interestEarned =
                (_deltaTime *
                _vault.totalBorrow.amount *
                _currentRateInfo.ratePerSec) /
            (PRECISION * BLOCKS_PER_YEAR);

            // Accumulate interest and fees
            _vault.totalBorrow.amount += uint128(_interestEarned);
            _vault.totalAsset.amount += uint128(_interestEarned);
            _vault.vaultInfo = _currentRateInfo;
            if (_currentRateInfo.feeToProtocolRate > 0) {
                _feesAmount =
                    (_interestEarned * _currentRateInfo.feeToProtocolRate) /
                    BPS;
                _feeShare =
                    (_feesAmount * _vault.totalAssets.shares) /
                    (_vault.totalAssets.amount - _feesAmount);
                _vault.totalAssets.shares += uint128(_feeShare);

                // accure protocol fee shares to this contract
                userShares[address(this)][token].collateral += _feesShare;
            }
            emit AccuredInterest(
                _currentRateInfo.ratePerSec,
                _interestEarned,
                _feesAmount,
                _feeShare
            );
        }
        //Save to storage 
        vaults[token] = _vault;
    }

    function _setupVault(
        address token,
        address priceFeed,
        Structs.TokenType tokenType,
        Structs.VaultSetupParams memory params,
        bool addToken
    ) internal {
        if (addToken) {
            addSupportedToken(token, priceFeed, tokenType);
        } else {
            //Cannot change vault setup when pausing
            WhenPaused(token);
        }
        if (tokenType == Structs.TokenType.ERC20) {
            if (params.reserveRatio > BPS)
                revert InvalidReserveRatio(params.reserveRatio);
            if (params.feeToProtocolRate > MAX_PROTOCOL_FEE)
                revert InvalidFeeRate(params.feeToProtocolRate);
            if(params.flashFeeRate > MAX_PROTOCOL_FEE)
                revert InvalidFeeRate(param.flashFeeRate);
            Structs.VaultInfo storage _vaultInfo = vaults[token].vaultInfo;
            _vaultInfo.reserveRatio = params.reserveRatio;
            _vaultInfo.feeToProtocolRate = params.feeToProtocolRate;
            _vaultInfo.flashFeeRate = params.flashFeeRate;
            _vaultInfo.baseRate = params.baseRate;
            _vaultInfo.additionalParam1 = params.additionalParam1;
            _vaultInfo.additionalParam2 = params.additionalParam2;
            _vaultInfo.optimalUtilization = params.optimalUtilization;

            emit NewVaultSetup(token, params);
        }
    }
    
}


