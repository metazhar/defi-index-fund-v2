// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MultiAssetPool.sol";

contract Vault {
    address public owner = msg.sender;
    MultiAssetPool public pool;
    uint256 public feePercentage = 1; // 1% for simplicity

    constructor(address[] memory _assets, uint256[] memory _weights) {
        pool = new MultiAssetPool(_assets, _weights);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // User deposit to vault
    function deposit(address asset, uint256 amount) external {
        uint256 fee = (feePercentage * amount) / 100;
        uint256 netAmt = amount - fee;

        IERC20(asset).transferFrom(msg.sender, address(this), fee); // Transfer fee to vault directly
        IERC20(asset).transferFrom(msg.sender, address(pool), netAmt); // Transfer net amount to MultiAssetPool

        pool.deposit(asset, netAmt);
    }

    // User withdraw from vault
    function withdraw(address asset, uint256 amount) external {
        pool.withdraw(asset, amount);

        uint256 fee = (feePercentage * amount) / 100;
        uint256 netAmt = amount - fee;

        IERC20(asset).transfer(owner, fee); // Transfer fee to vault manager
        IERC20(asset).transfer(msg.sender, netAmt); // Transfer the net amount to the user
    }

    function balanceOfAsset(address asset) external view returns (uint256) {
        return pool.assetBalances(asset);
    }

    // // Administrative functions to manage the MultiAssetPool
    // function adjustWeights(address[] memory newAssets, uint256[] memory newWeights) external onlyOwner {
    //     pool.adjustWeights(newAssets, newWeights);
    // }

    // function addNewAsset(address newAsset, uint256 weight) external onlyOwner {
    //     pool.addNewAsset(newAsset, weight);
    // }

    // function removeAsset(address asset) external onlyOwner {
    //     pool.removeAsset(asset);
    // }

    // ... Additional functions as necessary for governance, emergency stops, etc.
}
