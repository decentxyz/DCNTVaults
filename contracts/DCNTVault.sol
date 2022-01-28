// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// Questions:
///   Should be using SafeERC20 (https://docs.openzeppelin.com/contracts/4.x/api/token/erc20)
///   Should fields be stored as addresses or contracts (IERC20/721)
///   Gas improvement as a whole


/// ============ Imports ============

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";


/// @title Decentralized Creator Nonfungible Token Vaults (DCNT Vaults)
/// @notice claimable ERC20s for NFT holders after vault expiration 
contract DCNTVault {

  /// ============ Immutable storage ============

  /// @notice vault token to be distributed to token holders
  IERC20 public immutable vaultDistributionToken;
  /// @notice "ticket" token held by user
  IERC721Enumerable public immutable nftVaultKey;
  /// @notice unlock date when distribution can start happening
  uint256 public immutable unlockDate;

  /// ============ Mutable storage ============
  
  /// @notice Mapping of addresses who have claimed tokens
  mapping(uint256 => bool) internal hasClaimedTokenId;

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param account recipient of claim
  /// @param amount of tokens claimed
  event Claimed(address account, uint256 amount);

  /// ============ Errors ============

  /// @notice Thrown if address has already claimed
  error AlreadyClaimed();

  /// ============ Constructor ============

  /// @notice Creates a new vault
  /// @param _vaultDistributionTokenAddress of token
  /// @param _nftVaultKeyAddress of token
  /// @param _unlockDate date of vault expiration
  constructor(
    // for our purpose USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
    address _vaultDistributionTokenAddress, 
    address _nftVaultKeyAddress,
    uint256 _unlockDate
  ) {
    vaultDistributionToken = IERC20(_vaultDistributionTokenAddress);
    nftVaultKey = IERC721Enumerable(_nftVaultKeyAddress);
    unlockDate = _unlockDate;
  }

  /// ============ Functions ============

  function vaultBalance() public view returns (uint256) {
    return vaultDistributionToken.balanceOf(address(this));
  }

  function amountClaimed(uint256 numNftVaultKeys) private view returns (uint256) {
    return numNftVaultKeys / vaultBalance();
  }

  // claim all the tokens from Nft
  function claimAll(address to) external {
    require(block.timestamp >= unlockDate, 'vault is still locked');
    require(vaultBalance() > 0, 'vault is empty');
    uint256 numTokens = nftVaultKey.balanceOf(to);
    uint256 tokensToClaim = 0;
    for (uint256 i = 0; i < numTokens; i++){
      uint256 tokenId = nftVaultKey.tokenOfOwnerByIndex(to, i);
      if (!hasClaimedTokenId[tokenId]) {
        tokensToClaim++;
        hasClaimedTokenId[tokenId] = true;
      }
    }
    // require(tokensToClaim > 0, 'address does not own token');
    uint256 amount = amountClaimed(tokensToClaim);
    require(vaultDistributionToken.transfer(to, amount), 'Transfer failed');
    emit Claimed(to, amount);
  }

  // would this be necessary if have a claimAll? for flexibility yes but tbd 
  function claim(address to, uint256 tokenId) external {
    require(block.timestamp >= unlockDate, 'vault is still locked');
    require(vaultBalance() > 0, 'vault is empty');
    require(nftVaultKey.ownerOf(tokenId) == to, 'address does not own token');
    if (hasClaimedTokenId[tokenId]) revert AlreadyClaimed();
    // mark it claimed and send token (confused why doing this before not after calling transfer)
    hasClaimedTokenId[tokenId] = true;
    uint256 amount = amountClaimed(1);
    require(vaultDistributionToken.transfer(to, amount), 'Transfer failed');
    emit Claimed(to, amount);
  }
}
