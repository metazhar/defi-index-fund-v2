// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vault} from "../src/Vault.sol";
import {MultiAssetPool, IERC20} from "../src/MultiAssetPool.sol";
import {Test, console2} from "forge-std/Test.sol";

contract TestVault is Test {
    IERC20 public testTokenA;
    IERC20 public testTokenB;

    Vault public vault;
    MultiAssetPool public pool;

    function setUp() public {
        address tokenA = address(0x1);
        address tokenB = address(0x2);

        testTokenA = IERC20(tokenA);
        testTokenB = IERC20(tokenB);

        address[] memory assets = new address[](2);
        uint256[] memory weights = new uint256[](2);

        assets[0] = tokenA;
        assets[1] = tokenB;

        weights[0] = 50;
        weights[1] = 50;

        vault = new Vault(assets, weights);
        pool = MultiAssetPool(address(vault));
    }

    function test_Deposit() public {
        uint256 initialBalance = testTokenA.balanceOf(address(this));
        require(initialBalance > 0, "Initial balance too low");

        testTokenA.approve(address(vault), initialBalance);

        vault.deposit(address(testTokenA), initialBalance);

        uint256 expectedVaultBalance = (initialBalance * 1) / 100; // 1% fee
        uint256 expectedPoolBalance = initialBalance - expectedVaultBalance;

        require(
            testTokenA.balanceOf(address(vault)) == expectedVaultBalance,
            "Incorrect vault balance after deposit"
        );
        require(
            testTokenA.balanceOf(address(pool)) == expectedPoolBalance,
            "Incorrect pool balance after deposit"
        );
    }

    function test_Withdraw() public {
        uint256 depositAmount = testTokenA.balanceOf(address(this));
        testTokenA.approve(address(vault), depositAmount);
        vault.deposit(address(testTokenA), depositAmount);

        uint256 withdrawAmount = depositAmount / 2;
        vault.withdraw(address(testTokenA), withdrawAmount);

        uint256 expectedFee = (withdrawAmount * 1) / 100; // 1% fee
        uint256 expectedWithdrawal = withdrawAmount - expectedFee;

        require(
            testTokenA.balanceOf(address(this)) == expectedWithdrawal,
            "Incorrect balance after withdrawal"
        );
    }

    // ... Additional tests, e.g., test_swap, test_adjustWeights, etc.
}
