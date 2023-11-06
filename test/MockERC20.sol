// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(
            allowances[sender][msg.sender] >= amount,
            "Insufficient allowance"
        );
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(address account, uint256 amount) public {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}
