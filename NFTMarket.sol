// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarket is ERC721URIStorage {

    uint256 private _tokenIds;
    uint256 private _itemsSold;
    uint256 private _listPrice = 0.01 ether;

    address payable owner;

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    mapping(uint256 => ListedToken) private idToListedToken;

    event TokenListedSuccess (
        uint256 indexed tokenId,
        address owner,
        address seller,
        uint256 price,
        bool currentlyListed
    );

    constructor() ERC721("NFTMarket", "NFTM") {
        owner = payable(msg.sender);
    }

    function updateListPrice(uint256 newListPrice) public payable {
        require(owner == msg.sender, "Only owner can update listing price");
        _listPrice = newListPrice;
    }

    function getListPrice() public view returns (uint256) {
        return _listPrice;
    }

    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createListedToken(newTokenId, price);

        return newTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        require(msg.value == _listPrice, "Please pay the listing price");
        require(price > 0, "Price must be greater than 0");

        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        _transfer(msg.sender, address(this), tokenId);
        emit TokenListedSuccess(tokenId, address(this), msg.sender, price, true);
    }

    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint256 nftCount = _tokenIds;
        ListedToken[] memory tokens = new ListedToken[](nftCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= nftCount; i++) {
            ListedToken storage currentItem = idToListedToken[i];
            tokens[currentIndex] = currentItem;
            currentIndex++;
        }
        return tokens;
    }

    function getMyNFTs() public view returns (ListedToken[] memory) {
        uint256 totalItemCount = _tokenIds;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= totalItemCount; i++) {
            if (idToListedToken[i].owner == msg.sender || idToListedToken[i].seller == msg.sender) {
                itemCount++;
            }
        }

        ListedToken[] memory items = new ListedToken[](itemCount);
        for (uint256 i = 1; i <= totalItemCount; i++) {
            if (idToListedToken[i].owner == msg.sender || idToListedToken[i].seller == msg.sender) {
                items[currentIndex] = idToListedToken[i];
                currentIndex++;
            }
        }
        return items;
    }

    function executeSale(uint256 tokenId) public payable {
        uint256 price = idToListedToken[tokenId].price;
        address seller = idToListedToken[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToListedToken[tokenId].currentlyListed = true;
        idToListedToken[tokenId].seller = payable(msg.sender);
        _itemsSold++;

        _transfer(address(this), msg.sender, tokenId);
        approve(address(this), tokenId);

        payable(owner).transfer(_listPrice);
        payable(seller).transfer(msg.value);
    }
}