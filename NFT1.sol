// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint256 private _tokenIds;
    address contractAddress;

    event TokenCreated(uint256 tokenId, address owner, string tokenURI);
    constructor(address marketplaceAddress) ERC721("Token Name", "Token Symbol") {
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds++;
        uint256 newItemId = _tokenIds;

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);

        emit TokenCreated(newItemId, msg.sender, tokenURI);

        return newItemId;
    }
}
