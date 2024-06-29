// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../interfaces/Structs.sol";

library InterestRate {
    uint256 internal constant RATE_PRECISION = 1e18;

    function getInterestRate(
        Structs.VaultInfo memory _interestRateInfo,
        uint256 utilization
    ) internal pure returns (uint256 newRate) {
        uint256 optimalUtilization = _interestRateInfo.optimalUtilization;
        uint256 baseRate = uint256(_interestRateInfo.baseRate);
        uint256 additionalParam1 = uint256(_interestRateInfo.additionalParam1);
        uint256 additionalParam2 = uint256(_interestRateInfo.additionalParam2);

        if (utilization <= optimalUtilization) {
            uint256 rate = (utilization * additionalParam1) / optimalUtilization;
            newRate = baseRate + rate;
        } else {
            uint256 delta = utilization - optimalUtilization;
            uint256 excessUtilizationRate = 
                (delta * RATE_PRECISION) / (RATE_PRECISION - optimalUtilization);
            newRate = baseRate + additionalParam1 + (excessUtilizationRate * additionalParam2)
                / RATE_PRECISION;
        }
    }
}