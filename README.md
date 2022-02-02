# DCNT Vaults
A time-locked vault that distributes erc-20 tokens to owners of an nft-collection at expiry 

DCNT (Decentralized Creator Nonfungible Token) Vaults.

**INTRODUCTION**

DCNT Vaults significantly expand the utility of NFTs without compromising their proven value as a digital collectible and reputation instrument.  They offer a fungible financial layer that can be valued independently of the artwork, while simultaneously providing upward price pressure on the core art (NFTs).  Owners can maintain the integrity of NFTs’ individuality and contribution to wallet identity while earning alternative yield via wrapped NFT ERC-20 tokens staked into various DAOs and protocols. 

Importantly, this mechanism exists entirely on-chain, so the redemption of locked ERC-20 tokens is not dependent on the solvency or benevolence of any one entity.

**MECHANISM**

DCNT VW’s mechanism distributes tokens based strictly on one’s percentage ownership in an NFT collection, eliminating the need for a snapshot, manual split entry, or Merkle tree (IRL examples include Uniswap’s [Merkle Distributor](https://github.com/Uniswap/merkle-distributor), Mirror’s [Splits](https://github.com/mirror-xyz/splits), and OpenZepplin’s [Payment Splitter](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentSplitter.sol)). These NFTs can trade hands after the vault unlocks, and whoever the current owner is can claim their respective ERC-20 token share. 

For example, suppose a collection of 100 NFTs are minted. A DCNT VW can then be created with a time horizon of one year to wrap this collection, and 10,000 USDC is deposited into the embedded vault over the locked period.  At the end of the year, each NFT could “unlock” and redeem a percentage of the vault (in this case 100 USDC).

Note these contracts have not been audited

