// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Vault} from "../src/Vault.sol";
import {MultiAssetPool, IERC20} from "../src/MultiAssetPool.sol";
import {Test, console2} from "forge-std/Test.sol";
import {MockERC20} from "./MockERC20.sol";

contract TestVault is Test {
    IERC20 public tokenA;
    IERC20 public tokenB;

    Vault public vault;
    MultiAssetPool public pool;

    uint256 public amount;

    function setUp() public {
        // Create mock ERC20 tokens
        MockERC20 mockTokenA = new MockERC20("Token A", "TKA", 18);
        MockERC20 mockTokenB = new MockERC20("Token B", "TKB", 18);

        // Mint some tokens for this contract
        mockTokenA.mint(address(this), 100 * 10 ** 18);
        mockTokenB.mint(address(this), 100 * 10 ** 18);

        // Cast MockERC20 to IERC20
        tokenA = IERC20(address(mockTokenA));
        tokenB = IERC20(address(mockTokenB));

        address[] memory assets = new address[](2);
        uint256[] memory weights = new uint256[](2);

        assets[0] = address(tokenA);
        assets[1] = address(tokenB);

        weights[0] = 50;
        weights[1] = 50;

        vault = new Vault(assets, weights);
        pool = MultiAssetPool(address(vault));
    }

    function test_Deposit() public {
        uint256 initialBalance = tokenA.balanceOf(address(this));
        require(initialBalance > 100000, "Initial balance too low");

        amount = 5;

        tokenA.approve(address(vault), amount);

        vault.deposit(address(tokenA), amount);

        // make a variable for the expectedVaultBalance to be 1% subtracted from the intial balance
        uint256 expectedPoolBalance = amount - ((amount * 1) / 100); // 1% fee

        require(
            tokenA.balanceOf(address(pool)) == expectedPoolBalance,
            "Incorrect pool balance after deposit"
        );
    }

    // function test_Withdraw() public {
    //     uint256 depositAmount = testTokenA.balanceOf(address(this));
    //     testTokenA.approve(address(vault), depositAmount);
    //     vault.deposit(address(testTokenA), depositAmount);

    //     uint256 withdrawAmount = depositAmount / 2;
    //     vault.withdraw(address(testTokenA), withdrawAmount);

    //     uint256 expectedFee = (withdrawAmount * 1) / 100; // 1% fee
    //     uint256 expectedWithdrawal = withdrawAmount - expectedFee;

    //     require(
    //         testTokenA.balanceOf(address(this)) == expectedWithdrawal,
    //         "Incorrect balance after withdrawal"
    //     );
    // }

    // ... Additional tests, e.g., test_swap, test_adjustWeights, etc.
}
