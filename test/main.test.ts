import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers, waffle } from "hardhat";
import { before, beforeEach } from "mocha";


const deployERC20 = async (amountToMint: number) => {
  const TestERC20 = await ethers.getContractFactory("TestERC20");
  const erc20Token = await TestERC20.deploy(
    "token",
    "tkn",
    amountToMint
  );
  return await erc20Token.deployed();
}

const deployNFT = async () => {
  const TestERC721 = await ethers.getContractFactory("TestERC721");
  const erc721Token = await TestERC721.deploy(
    "nft",
    "NFT",
  );
  return await erc721Token.deployed();
}

const deployDCNTVault = async (
  _vaultDistributionTokenAddress: string,
  _NftWrapperTokenAddress: string,
  _unlockDate: number
) => {
  const DCNTVault = await ethers.getContractFactory("DCNTVault");
  const dcntVault = await DCNTVault.deploy(
    _vaultDistributionTokenAddress,
    _NftWrapperTokenAddress,
    _unlockDate
  );
  return await dcntVault.deployed();
}

describe("DCNTVault contract", () => {
  let token: Contract, nft: Contract, vault: Contract, unlockedVault: Contract;
  let addr1: SignerWithAddress, 
      addr2: SignerWithAddress, 
      addr3: SignerWithAddress, 
      addr4: SignerWithAddress,
      addr5: SignerWithAddress;

  describe("basic tests", () => {

    beforeEach(async () => {
      [addr1, addr2, addr3, addr4] = await ethers.getSigners();
      let currentDate = new Date();
      nft = await deployNFT();
      token = await deployERC20(100);
      // token.setBalance(owner.address, 100);
      vault = await deployDCNTVault(
        token.address,
        nft.address,
        Math.floor(currentDate.getTime() / 1000)
      )
    })
    
    describe("initial deployment", async () => {
      it("should have the same erc20 address as its backing token", async () => {
        expect(ethers.utils.getAddress(await vault.vaultDistributionToken())).to.equal(token.address);
      })
      
      it("should have the same erc721 address as its backing nft", async () => {
        expect(ethers.utils.getAddress(await vault.nftVaultKey())).to.equal(nft.address);
      })
    })

    describe("vault functionality", async () => {
      it("should have a vault balance of zero", async () => {
        expect(await vault.vaultBalance()).to.equal(0);
      })
      
      describe("and 50 tokens are added to the vault", async () => {
        it("should have a vault balance of 50", async () => {
          await token.connect(addr1).transfer(vault.address, 50);
          // console.log(await token.transfer(vault.address, 100));
          expect(await vault.vaultBalance()).to.equal(50);
        })
      })
      
      describe("and 50 more tokens are added to the vault", async () => {
        it("should have a vault balance of 100", async () => {
          await token.connect(addr1).transfer(vault.address, 100);
          // console.log(await token.transfer(vault.address, 100));
          expect(await vault.vaultBalance()).to.equal(100);
        })
      })
    })
  })
  
  describe("claiming core functionality", async () => {
    before(async () => {
      [addr1, addr2, addr3, addr4] = await ethers.getSigners();
      let tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);

      nft = await deployNFT();
      token = await deployERC20(100);

      // mint 1 nft for 1 address and 2 for 2 more
      await nft.connect(addr1).mintNft(1);
      await nft.connect(addr2).mintNft(2);
      await nft.connect(addr3).mintNft(2);

      vault = await deployDCNTVault(
        token.address,
        nft.address,
        Math.floor(tomorrow.getTime() / 1000)
      )

      // send 100 tokens to the vaul
      await token.connect(addr1).transfer(vault.address, 100);
    })
    describe("and the vault has not expired yet", async () => {
      
      describe("and a user with an nft tries to pull out money", async () => {
        it("should produce a warning preventing this", async () => {
          await expect(vault.claimAll(addr1.address)).to.be.revertedWith(
            'vault is still locked'
          );
        })
      })

      describe("and a user without an nft tries to pull out money", async () => {
        it("should produce a warning preventing this", async () => {
          await expect(vault.claimAll(addr4.address)).to.be.revertedWith(
            'vault is still locked'
          );
        })
      })
    })

    before(async () => {
      [addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
      let tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() - 1);

      nft = await deployNFT();
      token = await deployERC20(100);


      // set nft portions
      await nft.connect(addr1).mintNft(1);
      await nft.connect(addr2).mintNft(2);
      await nft.connect(addr3).mintNft(2);

      unlockedVault = await deployDCNTVault(
        token.address,
        nft.address,
        Math.floor(tomorrow.getTime() / 1000)
      )

      // send 100 tokens to the vault
      await token.connect(addr1).transfer(unlockedVault.address, 100);
    })

    describe("and the vault is unlocked", async () => {

      describe("and a user without any nft keys tries to redeem tokens", async () => {
        it("he would recieve zero tokens", async () => {
          await unlockedVault.claimAll(addr4.address);
          expect(await token.balanceOf(addr4.address)).to.equal(0)
        })
      })

      describe("and a user with one nft tries to redeem his tokens (1/5 nfts * 100 tokens)", async () => {
        it("should transfer 20 tokens to the user's account", async () => {
          console.log(await nft.balanceOf(addr1.address));
          // console.log(await vault.vaultBalance());
          await unlockedVault.claimAll(addr1.address)
          expect(await token.balanceOf(addr1.address)).to.equal(20)
        })
      })

    //   describe("and a user who has already redeemed his tokens tries to redeem again", async () => {
    //     it("should prevent the user from doing this", async () => {
    //       // console.log(await vault.vaultBalance());
    //       await vault.claimAll(addr1.address)
    //       // balance will still equal 20
    //       expect(token.balanceOf(addr1.address)).to.equal(20)
    //     })
    //   })
      
    //   describe("and a user with two nfts tries to redeem tokens (2/5 * 100)", async () => {
    //     it("should should transfer 40 tokens to the user's account", async () => {
    //       // console.log(await vault.vaultBalance());
    //       await vault.claimAll(addr2.address)
    //       // balance will still equal 20
    //       expect(token.balanceOf(addr2.address)).to.equal(40)
    //     })
    //   })
    })
  })

  describe("claiming division tests", async () => {
    // before(async () => {
    //   [addr1, addr2, addr3] = await ethers.getSigners();
    //   let currentDate = new Date();
    //   nft = await deployNFT();
    //   token = await deployERC20(73);
    //   // token.setBalance(owner.address, 100);
    //   vault = await deployDCNTVault(
    //     token.address,
    //     nft.address,
    //     Math.floor(currentDate.getTime() / 1000)
    //   )
    // })

    describe("and a user with three of eleven nfts tries to redeem tokens (3/11 * 73)", async () => {
      it("should should transfer 19.9(~ish) tokens to the user's account", async () => {

      })
    })

    describe("and he then receives another one and tries to redeem it", async () => {

    }) 
    
    describe("and he then receives another one thats already been claimed and tries to redeem it", async () => {
      
    })
  })
})
