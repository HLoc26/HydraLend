// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../libraries/ChainlinkOracle.sol";
import "../interfaces/Structs.sol";
import "../utils/Constants.sol";

contract TokenSupporter is Constants {
    using ChainlinkOracle for AggregatorV3Interface;

    address[] internal supportedERC20s;
    address[] internal supportedNFTs;

    mapping(address => Structs.SupportedToken) internal supportedToken;

    error TokenNotSupported();
    error AlreadySupported();
    error InvalidTokenType(Structs.TokenType tokenType);

    event AddSupportedToken(address token, Structs.TokenType tokenType);

    function addSupportedToken(
        address token,
        address priceFeed,
        Structs.TokenType tokenType
    ) internal {
        if (supportedToken[token].supported) revert AlreadySupported();
        if (uint(tokenType) > 1) revert InvalidTokenType(tokenType);

        supportedToken[token].usdPriceFeed = priceFeed;
        supportedToken[token].tokenType = tokenType;
        supportedToken[token].supported = true;

        if (tokenType == Structs.TokenType.ERC721) {
            supportedNFTs.push(token);
        } else {
            supportedERC20s.push(token);
        }

        emit AddSupportedToken(token, tokenType);
    }

    function getTokenPrice(address token) public view returns (uint256 price) {
        if (!supportedToken[token].supported) return 0;
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            supportedToken[token].usdPriceFeed
        );
        price = priceFeed.getPrice();
    }

    function allowedToken(address token) internal view {
        if (!supportedToken[token].supported) revert TokenNotSupported();
    }
}