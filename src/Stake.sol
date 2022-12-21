//SPDX LICENSE IDENTIFIER: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TransferFailed();

contract Stake {
    mapping(address => mapping(address => uint256)) public balances;

    function stake(uint amount, address token) public returns (bool) {
        balances[msg.sender][token] += amount;
        (bool success) = IERC20(token).transferFrom(msg.sender, address(this), amount);
        if (!success) revert TransferFailed();
        return success;
    }

    function withdraw(uint amount, address token) public returns (bool) {
        balances[msg.sender][token] -= amount;
        (bool success) = IERC20(token).transfer(msg.sender, amount);
        if (!success) revert TransferFailed();
        return success;
    }
}
