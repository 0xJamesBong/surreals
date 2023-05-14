// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract Surreals is ERC20 {
    constructor() ERC20("Surreals", "SUR", 18) {}

    bool vno_owned;

    function transferControlToVNO(
        address vnoAddress
    ) onlyOwner returns (bool success) {
        transferOwnership(vnoAddress);
        vno_owned = true;
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(vno_owned == false);
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function mint(address to, uint256 amount) onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) onlyOwner {
        _burn(msg.sender, amount);
    }
}
