// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// ============ Imports ============

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title template NFT contract
contract DecentNft is ERC721Enumerable, Ownable {

  /// ============ Immutable storage ============

  uint256 public immutable MAX_TOKENS;
  uint256 public immutable tokenPrice;
  uint256 public immutable maxTokenPurchase;

  /// ============ Mutable storage ============

  bool public saleIsActive = false;
  string public baseURI;

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param sender recipient of NFT mint
  /// @param tokenId_ of token minted
  event Minted(address sender, uint256 tokenId_);

  /// ============ Constructor ============

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

  function mintDecentNft(uint numberOfTokens) public payable {
    uint256 mintIndex = totalSupply();
    require(saleIsActive, "Sale must be active to mint");
    require(mintIndex <= MAX_TOKENS, "SOLD OUT: Have exceded total supply");
    require(numberOfTokens <= maxTokenPurchase, "Can only mint 20 tokens at a time");
    require(mintIndex + numberOfTokens < MAX_TOKENS, "Purchase would exceed max supply");
    require(msg.value >= (tokenPrice * numberOfTokens), "Insufficient funds");

    for(uint256 i = 0; i < numberOfTokens; i++) {
      _safeMint(msg.sender, mintIndex);
      emit Minted(msg.sender, mintIndex++);
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
  function reserveDCNT(uint256 numReserved) public onlyOwner {        
    uint256 supply = totalSupply();
    for (uint256 i = 0; i < numReserved; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }
}
