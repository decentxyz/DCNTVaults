// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./DCNTVault.sol";
import "./DCNT.sol";

contract DCVFactory {
  // unsure if should be immutable - assume yes?
  DCNT public immutable dcnt;
  DCNTVault public immutable dcntVault;

  constructor (
    address _vaultDistributionToken, 
    uint256 _unlockDate,
    string memory nftName, 
    string memory nftSymbol, 
    uint256 _maxTokens,
    uint256 _tokenPrice,
    uint256 _maxTokenPurchase
  ) {
    dcnt = new DCNT(nftName, nftSymbol, _maxTokens, _tokenPrice, _maxTokenPurchase);
    dcntVault = new DCNTVault(_vaultDistributionToken, address(dcnt), _unlockDate);
  }
}