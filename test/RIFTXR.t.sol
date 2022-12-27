// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/RIFTXR.sol";
import "./mocks/mockERC721.sol";
import "./mocks/mockERC20.sol";

contract RIFTXRTest is Test {
    RIFTXR public rift;
    MockERC721 public mockERC721;
    mockERC20 public ERC20_MOCK;
    
    function setUp() public {
        rift = new RIFTXR();
        mockERC721 = new MockERC721();
        ERC20_MOCK = new mockERC20();
        rift.setMintEnabled(true);
    }

    function testMintSuccessful() public {
        rift.mintPublic(1);
        assertEq(rift.totalSupply(), 1);
        assertEq(rift.balanceOf(address(this)), 1);
        rift.mintPublic(1);
        assertEq(rift.totalSupply(), 2);
        assertEq(rift.balanceOf(address(this)), 2);
        rift.mintPublic(1);
        assertEq(rift.totalSupply(), 3);
        assertEq(rift.balanceOf(address(this)), 3);
    }
    function testFailMintmaxPassesPerWalletError() public {
        rift.mintPublic(1);
        rift.mintPublic(1);
        rift.mintPublic(1);
        rift.mintPublic(1);
    }
    function testFailnumOfTokensTooHigh() public {
        rift.mintPublic(4);
    }

    function testFailMintNotEnabled() public {
        rift.setMintEnabled(false);
        rift.mintPublic(1);
    }

    function testERC721Withdrawal() public {
        IERC721(address(mockERC721)).transferFrom(address(this), address(rift), 1);
        assertEq(mockERC721.balanceOf(address(this)), 0);
        assertEq(mockERC721.balanceOf(address(rift)), 1);

        rift.withdrawERC721Tokens(address(mockERC721), 1);
        assertEq(mockERC721.balanceOf(address(this)), 1);
    }

    function testERC20Withdrawal() public {
        ERC20_MOCK.transfer(address(rift), 100e18);
        assertEq(ERC20_MOCK.balanceOf(address(this)), 99_900e18);
        assertEq(ERC20_MOCK.balanceOf(address(rift)), 100e18);

        rift.withdrawERC20Tokens(address(ERC20_MOCK));
        assertEq(ERC20_MOCK.balanceOf(address(this)), 100_000e18);
    }
}