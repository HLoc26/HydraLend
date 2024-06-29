// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library ChainlinkOracle {
    error InvalidPrice();

    uint256 private constant TIME_OUT = 2 hours;

    uint256 private constant USD_ORACLE_DECIMALS = 10;

    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256 price) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answerInRound
        ) = priceFeed.latestRoundData();

        if (
            answer <= 0 ||
            updatedAt == 0 ||
            answerInRound < roundId ||
            block.timestamp - updatedAt > TIME_OUT
        ) revert InvalidPrice();

        price = uint256(answer) * 10 ** USD_ORACLE_DECIMALS;
    } 

    function getTimeOut(AggregatorV3Interface) public pure returns (uint256) {
        return TIME_OUT;
    }
}