// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Helper} from "./libraries/Helper.sol";
import {VaultAccounting} from "./libraries/VaultAccounting.sol";
import {InterestRate} from "./libraries/InterestRate.sol";
import {Pausing} from "./utils/Pausing.sol";
import {Structs} from "./interfaces/Structs.sol";
import {FlashLoanReceiverInterface} from "./interfaces/FlashLoanReceiverInterface.sol";
import {NFTPledging} from "./NFTPledging.sol";
import "./libraries/Helper.sol";

contract HydraPool is Pausing, NFTPledging {
    using VaultAccounting for Structs.Vault;
    using InterestRate for Structs.VaultInfo;
    using Helper for address;

    mapping(address => Structs.TokenVault) private vaults;
    mapping(address => mapping(address => Structs.AccountShares))
        private userShares;
    mapping(address => mapping(address => mapping(uint256 => Structs.LiquidatedWarning)))
        private nftLiquidationWarning;

    error TooHighSlipage(uint256 sharesOutOrAmountIn);
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
    event DepositNFT(address user, address nftAddress, uint256 tokenId);
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
        Structs.VaultSetupParamemters params
    );

    //Make a subnet that create a token, then replace daiAddress with token address and everything
    constructor(
        address daiAddress,
        address daiPriceFeed,
        Structs.VaultSetupParamemters memory daiVaultParams
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
                ERC20 FUNCTIONS
    //////////////////////////////////////////////*/
    function supply(
        address token,
        uint256 amount,
        uint256 minSharesOut
    ) external {
        WhenNotPaused(token);
        allowedToken(token);
        _accuredInterest(token);

        token.transferERC20(msg.sender, address(this),amount);
        uint256 shares = vaults[token].totalAsset.toShares(amount, false);
        if (shares < minSharesOut) revert TooHighSlipage(shares);

        vaults[token].totalAsset.shares += uint128(shares);
        vaults[token].totalAsset.amount += uint128(amount);
        userShares[msg.sender][token].collateral += shares;

        emit Deposit(msg.sender, token, amount, shares);
    }

    function borrow(address token, uint256 amount) external {
        WhenNotPaused(token);
        if(!vaultAboveReserveRatio(token,amount))
            revert InsufficientBalance();
        _accuredInterest(token);

        uint256 shares = vaults[token].totalBorrow.toShares(amount, false);
        vaults[token].totalBorrow.shares += uint128(shares);
        vaults[token].totalBorrow.amount += uint128(amount);
        userShares[msg.sender][token].borrow += shares;
        
        token.transferERC20(address(this), msg.sender, amount);
        if(healthFactor(msg.sender) < MIN_HEALTH_FACTOR)
            revert BelowHealthFactor();

        emit Borrow(msg.sender, token, amount, shares);
    }

    function repay(address token, uint256 amount) external {
        _accuredInterest(token);
        uint256 userBorrowShare = userShares[msg.sender][token].borrow;
        uint256 shares = vaults[token].totalBorrow.toShares(amount, true);
        if (amount == type(uint256).max || shares > userBorrowShare) {
            shares = userBorrowShare;
            amount = vaults[token].totalBorrow.toAmount(shares, true);
        }
        token.transferERC20(msg.sender, address(this), amount);
        unchecked {
            vaults[token].totalBorrow.shares -= uint128(shares);
            vaults[token].totalBorrow.amount -= uint128(amount);
            userShares[msg.sender][token].borrow = userBorrowShare - shares;
        }

        emit Repay(msg.sender, token, amount, shares);
    }

    function withdraw(
        address token,
        uint256 amount,
        uint256 maxShareIn
    ) external {
        _withdraw(token, amount, maxShareIn, false);
    }

    function redeem(
        address token,
        uint256 shares,
        uint256 minAmountOut
    ) external {
        _withdraw(token, shares, minAmountOut, true);
    }

    function liquidate(
        address account,
        address collateral,
        address userBorrowToken,
        uint256 amountToLiquidate
    ) external {
        if (msg.sender == account) revert SelfLiquidation();
        uint256 accountHealth = healthFactor(account);
        if (accountHealth >= MIN_HEALTH_FACTOR) revert BorrowerIsSolvant();

        uint256 collateralShares = userShares[account][collateral].collateral;
        uint256 borrowShares = userShares[account][userBorrowToken].borrow;
        if (collateralShares == 0 || borrowShares == 0) return;
        {
            uint256 totalBorrowAmount = vaults[userBorrowToken]
                .totalBorrow
                .toAmount(borrowShares, true);

            uint256 maxBorrowAmountToLiquidate = accountHealth >=
                FULL_LIQUIDATION_THRESHOLD
                ? (totalBorrowAmount * DEFAULT_LIQUIDATION_CLOSE) / BPS
                : totalBorrowAmount;
            amountToLiquidate = amountToLiquidate > maxBorrowAmountToLiquidate
                ? maxBorrowAmountToLiquidate
                : amountToLiquidate;
        } 

        uint256 collateralAmountToLiquidate;
        uint256 liquidationReward;
        {
            address user = account;
            address borrowToken = userBorrowToken;
            address collateralToken = collateral;
            uint256 liquidationAmount = amountToLiquidate;

            uint256 _userTotalCollateralAmount = vaults[collateralToken]
                .totalAsset
                .toAmount(collateralShares, false);
            
            uint256 collateralPrice = getTokenPrice(collateralToken);
            uint256 borrowTokenPrice = getTokenPrice(borrowToken);
            uint8 collateralDecimals = collateralToken.tokenDecimals();
            uint8 borrowTokenDecimals = borrowToken.tokenDecimals();

            collateralAmountToLiquidate =
                (liquidationAmount *
                    borrowTokenPrice *
                    10 ** collateralDecimals) /
                (collateralPrice * 10 ** borrowTokenDecimals);
            uint256 maxLiquidationReward = (collateralAmountToLiquidate *
                LIQUIDATION_REWARD) / BPS;
            if (collateralAmountToLiquidate > _userTotalCollateralAmount) {
                collateralAmountToLiquidate = _userTotalCollateralAmount;
                liquidationReward = 
                    ((_userTotalCollateralAmount *
                        collateralPrice *
                        10 ** borrowTokenDecimals) / borrowTokenPrice) *
                    10 ** collateralDecimals;
                amountToLiquidate = liquidationAmount;
            } else {
                uint256 collateralBalanceAfter = _userTotalCollateralAmount -
                    collateralAmountToLiquidate;
                liquidationReward = maxLiquidationReward >
                    collateralBalanceAfter
                    ? collateralBalanceAfter
                    : maxLiquidationReward;
            }
            //Update borrow vault
            uint128 repaidBorrowShares = uint128(
                vaults[borrowToken].totalBorrow.toShares(
                    liquidationAmount,
                    false
                )
            );
            vaults[borrowToken].totalBorrow.shares -= repaidBorrowShares;
            vaults[borrowToken].totalBorrow.amount -= uint128(
                liquidationAmount
            );

            //Update collateral vault
            uint128 liquidatedCollShares = uint128(
                vaults[collateralToken].totalAsset.toShares(
                    collateralAmountToLiquidate + liquidationReward,
                    false
                )
            );
            vaults[collateralToken].totalAsset.shares -= liquidatedCollShares;
            vaults[collateralToken].totalAsset.amount -= uint128(
                collateralAmountToLiquidate + liquidationReward
            );
            userShares[user][borrowToken].borrow -= repaidBorrowShares;
            userShares[user][collateralToken].collateral -= liquidatedCollShares;
        }

        //Repay borrowed amount
        userBorrowToken.transferERC20(
            address(this),
            msg.sender,
            collateralAmountToLiquidate + liquidationReward
        );
        //Transfer collateral & liquidation reward to liquidator
        collateral.transferERC20(
            address(this),
            msg.sender,
            collateralAmountToLiquidate + liquidationReward
        );

        emit Liquidated(
            account,
            msg.sender,
            amountToLiquidate,
            collateralAmountToLiquidate + liquidationReward,
            liquidationReward
        );
    }

    function flashloan(
        address receiverAddress,
        address[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata data
    ) external {
        if (tokens.length == 0) revert EmptyArray();
        if (tokens.length != amounts.length) revert ArrayMismatch();

        FlashLoanReceiverInterface receiver = FlashLoanReceiverInterface(receiverAddress);
        uint256[] memory fees = new uint256[](tokens.length);
        for (uint256 i; i < tokens.length; ) {
            if (maxFlashloan(tokens[i]) == 0) revert FlashloanPaused(tokens[i]);
            fees[i] = flashloanFee(tokens[i], amounts[i]);
            tokens[i].transferERC20(address(this), receiverAddress, amounts[i]);
            unchecked {
                ++i;
            }
        }
        if (!receiver.onFlashLoan(
            msg.sender,
            tokens,
            amounts,
            fees,
            data
        )) revert FlashloanFailed();

        uint256 amountPlusFee;
        for (uint256 i; i < tokens.length; ) {
            amountPlusFee = amounts[i] + fees[i];
            tokens[i].transferERC20(
                receiverAddress,
                address(this),
                amountPlusFee
            );
            vaults[tokens[i]].totalAsset.amount += uint128(fees[i]);
            unchecked {
                ++i;
            }
        }

        emit FlashloanSuccess(msg.sender, tokens, amounts, fees, data);
    }

    function accureInterest(
        address token
    ) 
        external
        returns (
            uint256 _interestEarned,
            uint256 _feesAmount,
            uint256 _feesShare,
            uint64 _newRate
        ) 
    {
        return _accuredInterest(token);
    }

    /*//////////////////////////////////////////////
                NFT FUNCTIONS
    //////////////////////////////////////////////*/

    function depositNft(
        address recipient,
        address nftAddress,
        uint256 tokenId
    ) external {
        _withdrawNft(msg.sender, recipient, nftAddress, tokenId);
        if (healthFactor(msg.sender) < MIN_HEALTH_FACTOR) revert BelowHealthFactor();
        emit WithdrawNFT(msg.sender, recipient, nftAddress, tokenId);
    }

    function triggerNFTiquidation(
        address account,
        address nftAddress,
        uint256 tokenId
    ) external {
        if (!hasDepositedNFT(account, nftAddress, tokenId)) revert InvalidNFT();
        uint256 totalTokenCollateralValue = getUserTotalTokenCollateral(
            account
        );

        if (
            healthFactor(account) >= MIN_HEALTH_FACTOR ||
            totalTokenCollateralValue != 0
        ) revert InvalidNFTLiquidation(account, nftAddress, tokenId);

        Structs.LiquidatedWarning storage warning = nftLiquidationWarning[
            account
        ][nftAddress][tokenId];
        warning.liquidator = msg.sender;
        warning.liquidationTimestamp = uint64(block.timestamp + NFT_WARNING_DELAY);

        emit LiquidatingNFTWarning(msg.sender, account, nftAddress, tokenId);
    }

    function stopNFTLiquidation(
        address account,
        address nftAddress,
        uint256 tokenId
    ) external {
        if (healthFactor(account) < MIN_HEALTH_FACTOR)
            revert BelowHealthFactor();
        delete nftLiquidationWarning[account][nftAddress][tokenId];
        emit LiquidatingNFTStopped(account, nftAddress, tokenId);
    }

    function executeNFTLiquidation(
        address account,
        address nftAddress,
        uint256 tokenId,
        address[] calldata repayTokens,
        uint256[] calldata repayAmounts
    ) external {
        if (repayTokens.length == 0) revert EmptyArray();
        if (repayTokens.length != repayAmounts.length) revert ArrayMismatch();
        canLiquidateNFT(account, nftAddress, tokenId);

        uint256 totalDebtValue = getUserTotalBorrow(account);
        uint256 nftFloorPrice = getTokenPrice(nftAddress);
        uint256 totalRepaidDebtValue;
        {
            address borrower = account;
            address token;
            uint256 amount;
            uint256 borrowShares;
            for (uint256 i; i < repayTokens.length; ) {
                token = repayTokens[i];
                amount = repayAmounts[i];
                _accuredInterest(token);
                borrowShares = vaults[token].totalBorrow.toShares(amount, true);
                token.transferERC20(msg.sender, address(this), amount);
                vaults[token].totalBorrow.shares -= uint128(borrowShares);
                vaults[token].totalBorrow.amount -= uint128(amount);

                userShares[borrower][token].borrow -= uint128(borrowShares);

                totalRepaidDebtValue += getAmountInUSD(token, amount);
                unchecked {
                    ++i;
                }
            }

            //must repay at least debt equivalent of half NFT value
            if (
                totalDebtValue > nftFloorPrice &&
                totalRepaidDebtValue <
                (nftFloorPrice * DEFAULT_LIQUIDATION_CLOSE) / BPS
            ) revert MustPayMoreDebt();
        }

        uint256 nftBuyPrice;
        {
            address borrower = account;
            uint256 totalLiquidatorDiscount = (totalRepaidDebtValue *
                (BPS + NFT_LIQUIDATION_DISCOUNT)) / BPS;
            nftBuyPrice = nftFloorPrice - totalLiquidatorDiscount;

            address DAI =  supportedERC20s[0];
            DAI.transferERC20(msg.sender, address(this), nftBuyPrice);

            uint256 shares = vaults[DAI].totalAsset.toShares(
                nftBuyPrice,
                false
            );
            vaults[DAI].totalAsset.shares += uint128(shares);
            vaults[DAI].totalAsset.amount += uint128(nftBuyPrice);
            userShares[borrower][DAI].collateral += shares;
        }

        _withdrawNft(account, msg.sender, nftAddress, tokenId);

        emit NFTLiquidated(
            msg.sender,
            account,
            nftAddress,
            tokenId,
            totalRepaidDebtValue,
            nftBuyPrice
        );
    }

    function canLiquidateNFT(
        address account,
        address nftAddress,
        uint256 tokenId
    ) public view {
        if (healthFactor(account) < MIN_HEALTH_FACTOR)
             revert BorrowerIsSolvant();
        Structs.LiquidatedWarning storage warning = nftLiquidationWarning[
            account
        ][nftAddress][tokenId];
        if (warning.liquidator == address(0)) revert NoLiquidationWarning();
        if (block.timestamp < warning.liquidationTimestamp)
            revert WarningDelayHasNotPassed();
        if (
            block.timestamp <=
            warning.liquidationTimestamp + NFT_LIQUIDATOR_DELAY &&
            msg.sender != warning.liquidator
        ) revert LiquidatorDelayHasNotPassed();
        
    }
    /*//////////////////////////////////////////////
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
        totalNFTCollateral = getUserNFTCollateral(user);
        totalBorrowValue = getUserTotalBorrow(user);
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
                totalValueInUSD += getAmountInUSD(token, tokenAmount);
            }
            unchecked {
                ++i;
            }
        } 
    }

    function getUserNFTCollateral(address user) public view returns(uint256 totalValueInUSD) {
        uint len = supportedNFTs.length;
        for (uint256 i; i < len;) {
            address nftAddress = supportedNFTs[i];
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
    ) public view returns (uint256 maxFlashloanAmount) {
        maxFlashloanAmount = pausedStatus(token) ? 0 : type(uint256).max;
    }

    function flashloanFee(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        return (amount * vaults[token].vaultInfo.flashFeeRate) / BPS;
    }

    /*///////////////////////////////////////////////
                 OWNER FUNCTIONS
    ////////////////////////////////////////////////*/

    function setupVault(
        address token,
        address priceFeed,
        Structs.TokenType tokenType,
        Structs.VaultSetupParamemters memory params,
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
            vaults[token].vaultInfo.reserveRatio) / BPS;
        isAboveReserveRatio =
            vaults[token].totalAsset.amount != 0 &&
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
                _vault.totalAsset.amount;
            uint256 _newRate = _currentRateInfo.getInterestRate(
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
                _feesShare =
                    (_feesAmount * _vault.totalAsset.shares) /
                    (_vault.totalAsset.amount - _feesAmount);
                _vault.totalAsset.shares += uint128(_feesShare);

                // accure protocol fee shares to this contract
                userShares[address(this)][token].collateral += _feesShare;
            }
            emit AccuredInterest(
                _currentRateInfo.ratePerSec,
                _interestEarned,
                _feesAmount,
                _feesShare
            );
        }
        //Save to storage 
        vaults[token] = _vault;
    }

    function _setupVault(
        address token,
        address priceFeed,
        Structs.TokenType tokenType,
        Structs.VaultSetupParamemters memory params,
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
                revert InvalidFeeRate(params.flashFeeRate);
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


