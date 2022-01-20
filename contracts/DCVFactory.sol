//SPDX-License-Identifier: MIT

import "./DCV.sol";
import "./DCRT.sol";

contract DCVFactory {
  // unsure if should be immutable - assume yes?
  DCV public immutable dcv;
  DCRT public immutable dcrt;

  constructor (
    address vaultDistributionToken_, 
    uint256 unlockDate_,
    string memory nftName, 
    string memory nftSymbol, 
    uint256 maxTokens_,
    uint256 tokenPrice_,
    uint256 maxTokenPurchase_
  ) {
    dcrt = new DCRT(nftName, nftSymbol, maxTokens_, tokenPrice_, maxTokenPurchase_);
    dcv = new DCV(vaultDistributionToken_, address(dcrt), unlockDate_);
  }
}