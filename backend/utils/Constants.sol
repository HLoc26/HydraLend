// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract Constants {
    uint256 public constant BPS = 1e5; //Basis point, 1e5 means 5 decimals precision
    uint256 public constant PRECISION = 1e18; //18 decimals 
    uint256 internal constant MIN_HEALTH_FACTOR = 1e18;
    uint256 internal constant FULLY_LIQUIDATION_THRESHOLD = 0.9e18;
    uint256 internal constant LIQUIDATION_THRESHOLD = 8e4; //80%
    uint256 internal constant DEFAULT_LIQUIDATION_CLOSE = 5e4; //50%
    uint256 internal constant LIQUIDATION_REWARD = 5e3; //5%

    uint256 internal constant NFT_LIQUIDATION_DISCOUNT = 1e4; //10%
    uint256 internal constant NFT_WARNING_DELAY = 24 hours;
    uint256 internal constant NFT_LIQUIDATOR_DELAY = 5 minutes;

    //default interest if borrow = 0
    uint64 internal constant DEFAULT_INTEREST = 158247046; //0.5% annual rate 1e18 precision 
    uint256 internal constant MAX_PROTOCOL_FEE = 0.5e4;
    uint256 public constant BLOCKS_PER_YEAR = 2102400; //Average ethereum blocks per year
}
