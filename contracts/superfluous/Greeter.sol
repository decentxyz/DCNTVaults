//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Greeter {
    constructor() {
    }

    function greet() public view returns (uint256) {
        IERC20 myAddress = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        return myAddress.totalSupply();

    }
}
