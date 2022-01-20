// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DCRT is ERC721Enumerable, Ownable {

  uint256 public immutable MAX_TOKENS;
  uint256 public immutable tokenPrice;
  uint256 public immutable maxTokenPurchase;
  bool public saleIsActive = false;
  string public baseURI;

  event Minted(address sender, uint256 tokenId_);

  constructor(
    string memory name, 
    string memory symbol, 
    uint256 maxTokens_,
    uint256 tokenPrice_,
    uint256 maxTokenPurchase_
  ) ERC721 (name, symbol) {
    MAX_TOKENS = maxTokens_;
    tokenPrice = tokenPrice_;
    maxTokenPurchase = maxTokenPurchase_;
  }

  function mintRNFT(uint numberOfTokens) public payable {
    require(saleIsActive, "Sale must be active to mint an RNFT");
    require(totalSupply() <= MAX_TOKENS, "SOLD OUT: Have exceded total supply");
    require(numberOfTokens <= maxTokenPurchase, "Can only mint 20 tokens at a time");
    require(totalSupply() + numberOfTokens < MAX_TOKENS, "Purchase would exceed max supply");
    require(msg.value >= (tokenPrice * numberOfTokens), "Insufficient funds");

    for(uint256 i = 0; i < numberOfTokens; i++) {
      uint256 mintIndex = totalSupply();
      _safeMint(msg.sender, mintIndex);
      emit Minted(msg.sender, mintIndex);
    }
  }

  function flipSaleState() public onlyOwner {
    saleIsActive = !saleIsActive;
  }

  function withdraw() public onlyOwner {
    uint256 balance = address(this).balance;
    payable(msg.sender).transfer(balance);
  }

  function setBaseURI(string memory uri) public onlyOwner{
    baseURI = uri;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  // save some for creator
  function reserveDCRT(uint256 numReserved) public onlyOwner {        
    uint256 supply = totalSupply();
    for (uint256 i = 0; i < numReserved; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }
}
