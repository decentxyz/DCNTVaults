//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * Note: this is how our "vaults" would look if we took a snapshot + distributed
 * (as opposed to DCNT)
 * Drawing heavily from the work at Uniswap + Mirror in their two contracts:
 * https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol
 * https://github.com/mirror-xyz/splits/blob/main/contracts/Splitter.sol
 */
contract RoyaltyVaultDistributor {
  address public immutable token;
  uint256 public immutable unlockDate;
  bytes32 public immutable merkleRoot;

  // This is a packed array of booleans.
  mapping(uint256 => uint256) private claimedBitMap;

  // This event is triggered after transfer is attempted
  event Claimed(address account, uint256 amount);

  // for our purpose USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
  constructor(address token_, bytes32 merkleRoot_, uint256 unlockDate_) {
    token = token_;
    merkleRoot = merkleRoot_;
    unlockDate = unlockDate_;
  }

  function getVaultBalance() public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  function isClaimed(uint256 index) public view returns (bool) {
    uint256 claimedWordIndex = index / 256;
    uint256 claimedBitIndex = index % 256;
    uint256 claimedWord = claimedBitMap[claimedWordIndex];
    uint256 mask = (1 << claimedBitIndex);
    return claimedWord & mask == mask;
  }

  function _setClaimed(uint256 index) private {
    uint256 claimedWordIndex = index / 256;
    uint256 claimedBitIndex = index % 256;
    claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
  }

  function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {
    require(block.timestamp >= unlockDate, 'Must wait for vault expiration to withdraw');
    require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

    // Verify the merkle proof.
    bytes32 node = keccak256(abi.encodePacked(index, account, amount));
    require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

    // Mark it claimed and send the token.
    _setClaimed(index);
    require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

    emit Claimed(account, amount);
  }

}
