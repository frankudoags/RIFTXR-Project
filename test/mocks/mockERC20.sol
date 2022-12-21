//SPDX LICENCE IDENTIFIER: MIT
pragma solidity ^0.8.10;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract mockERC20 is ERC20 {
    constructor() ERC20("MOCKERC20", "MERC") {
        _mint(msg.sender, 100_000e18);
    }
}