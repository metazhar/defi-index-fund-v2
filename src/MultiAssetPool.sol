// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiAssetPool {
    address public vault;
    address[] public assets;
    mapping(address => uint256) public assetWeights;
    mapping(address => uint256) public assetBalances;

    constructor(address[] memory _assets, uint256[] memory _weights) {
        require(
            _assets.length == _weights.length,
            "Mismatched assets and weights."
        );

        vault = msg.sender; // Assuming the Vault contract deploys this contract.
        assets = _assets;
        for (uint256 i = 0; i < _assets.length; i++) {
            assetWeights[_assets[i]] = _weights[i];
        }
    }

    // For User
    function deposit(address asset, uint256 amount) external {
        require(assetWeights[asset] > 0, "Asset not in pool.");

        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        assetBalances[asset] += amount;
    }

    // For Vault
    function withdraw(address asset, uint256 amount) external {
        require(msg.sender == vault, "Only Vault can withdraw.");

        assetBalances[asset] -= amount;
        IERC20(asset).transfer(vault, amount);
    }

    // For Arbitrageurs
    function swap(address fromAsset, address toAsset, uint256 amount) external {
        // Need some checks here to prevent bad behavior from arbitrageurs
        // But for now we have a simple swap function to rebalance weights in the pool

        require(
            assetWeights[fromAsset] > 0 && assetWeights[toAsset] > 0,
            "Invalid assets."
        );

        uint256 outputAmount = calculateSwapOutput(fromAsset, toAsset, amount);
        require(outputAmount > 0, "Insufficient liquidity.");

        assetBalances[fromAsset] += amount;
        assetBalances[toAsset] -= outputAmount;

        IERC20(fromAsset).transferFrom(msg.sender, address(this), amount);
        IERC20(toAsset).transfer(msg.sender, outputAmount);
    }

    function calculateSwapOutput(
        address fromAsset,
        address toAsset,
        uint256 inputAmount
    ) public view returns (uint256) {
        // This is a simplified logic for example purposes.
        // In a real-world scenario, this would involve more complex mathematical models to
        // ensure that the weights are respected and to counteract potential impermanent loss.
        uint256 fromWeight = assetWeights[fromAsset];
        uint256 toWeight = assetWeights[toAsset];

        return (inputAmount * toWeight) / fromWeight;
    }

    // TODO
    // ____________________________________________________________

    // // // Placeholder for adjusting asset weights.
    // function adjustWeights(address[] memory newAssets, uint256[] memory newWeights) external {
    //     // Implement logic for adjusting weights.
    //     // Consider authorization checks to ensure only authorized entities can adjust.
    // }

    // // Placeholder for adding new assets to the pool.
    // function addNewAsset(address newAsset, uint256 weight) external {
    //     // Implement logic for adding new assets.
    //     // Remember to check if asset is already present.
    // }

    // // Placeholder for removing assets.
    // function removeAsset(address asset) external {
    //     // Implement logic for removing an asset from the pool.
    //     // Consider what should be done with the existing balance of the asset.
    // }

    // // Placeholder for governance or administrative changes.
    // function changeGovernance(address newGovernance) external {
    //     // Logic to change the governance or administrative controls of the contract.
    // }

    // // Placeholder for emergency stop in case of detected issues.
    // function emergencyPause() external {
    //     // Implement logic to pause certain functions in emergencies.
    // }

    // // Placeholder for resuming operations post-emergency.
    // function emergencyResume() external {
    //     // Implement logic to resume operations after an emergency stop.
    // }
}
