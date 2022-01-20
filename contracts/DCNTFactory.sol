// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./DCNTVault.sol";
import "./DCNT.sol";

contract DCVFactory {
  // unsure if should be immutable - assume yes?
  DCNT public immutable dcnt;
  DCNTVault public immutable dcntVault;

  constructor (
    address vaultDistributionToken_, 
    uint256 unlockDate_,
    string memory nftName, 
    string memory nftSymbol, 
    uint256 maxTokens_,
    uint256 tokenPrice_,
    uint256 maxTokenPurchase_
  ) {
    dcnt = new DCNT(nftName, nftSymbol, maxTokens_, tokenPrice_, maxTokenPurchase_);
    dcntVault = new DCNTVault(vaultDistributionToken_, address(dcnt), unlockDate_);
  }
}