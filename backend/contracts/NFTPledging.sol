// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TokenSupporter} from "./TokenSupporter.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/Structs.sol";

contract NFTPledging is TokenSupporter, IERC721Receiver {
    using EnumerableSet for EnumerableSet.UintSet;

    error InvalidNFT();

    mapping(address user => mapping(address nft => EnumerableSet.UintSet tokenIds)) depositedNFTs;

    function _depositNFT(address nftAddress, uint256 tokenId) internal {
        allowedToken(nftAddress);
        IERC721(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        depositedNFTs[msg.sender][nftAddress].add(tokenId);
    }

    function _withdrawNft(
        address owner,
        address recipient,
        address nftAddress,
        uint256 tokenId
    ) internal {
        if (!hasDepositedNFT(owner, nftAddress, tokenId)) revert InvalidNFT();
        depositedNFTs[owner][nftAddress].remove(tokenId);
        IERC721(nftAddress).safeTransferFrom(
            address(this), recipient, tokenId
        );
    }

    function hasDepositedNFT(
        address owner,
        address nftAddress,
        uint256 tokenId
    ) public view returns (bool) {
        return depositedNFTs[owner][nftAddress].contains(tokenId);
    }

    function getDepositedNFT(
        address owner,
        address nftAddress
    ) public view returns (uint256[] memory) {
        return depositedNFTs[owner][nftAddress].values();
    }

    function getDepositedNFTCount(address owner, address nftAddress)
        public view returns (uint256) {
            return depositedNFTs[owner][nftAddress].length();
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}