// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/Stake.sol";
import "./mocks/mockERC20.sol";

contract StakeTest is Test {
    Stake public stake;
    mockERC20 public token;

    function setUp() public {
        stake = new Stake();
        token = new mockERC20();
    }

    function testStake() public {
        token.approve(address(stake), 100_000e18);
        stake.stake(100_000e18, address(token));
        assertEq(stake.balances(address(this), address(token)), 100_000e18);
    }

    function testWithdraw() public {
        token.approve(address(stake), 100_000e18);
        stake.stake(100_000e18, address(token));
        stake.withdraw(100_000e18, address(token));
        assertEq(stake.balances(address(this), address(token)), 0);
    }
}  