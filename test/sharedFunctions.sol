// https://github.com/foundry-rs/forge-std

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {VNO} from "src/vno.sol";
import "forge-std/Test.sol";

// import "openzeppelin-contracts/contracts/utils/Strings.sol";

interface CheatCodes {
    function startPrank(address) external;

    function prank(address) external;

    function deal(address who, uint256 newBalance) external;

    function addr(uint256 privateKey) external returns (address);

    function warp(uint256) external; // Set block.timestamp
}

contract SharedFunctions is Test {
    VNO vno;
    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
    // address HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

    address alice = cheats.addr(1);
    address bob = cheats.addr(2);
    address carol = cheats.addr(3);
    address dominic = cheats.addr(4);

    address owner_of_vno = cheats.addr(5);

    uint256 MAX_INT = 2 ** 256 - 1;

    function setUp() public {
        hoax(owner_of_vno);
        vno = new VNO();
    }

    string emptyset = "{}";
    string e = "{}";
    string i = "{{}}";
    string ii = "{{{}}}";
    string iii = "{{{{}}}}";
    string v = "{{{{{{}}}}}}";
    string vi = "{{{{{{{}}}}}}}";

    function stringsEq(
        string memory str1,
        string memory str2
    ) public pure returns (bool) {
        return (keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2)));
    }

    // struct Universal {
    //     uint256 number;
    //     uint256 instances;
    //     uint256 activeParticulars;
    //     uint256[] primes;
    //     bool made;
    // }

    function getUniversalFromTokenId(
        uint256 tokenId
    ) public view returns (VNO.Universal memory universal) {
        // Returns the universal that a token belongs to

        (
            uint256 number,
            uint256 mintTime,
            uint256 order,
            string memory method, // Make sure to remove the extra component
            uint256 oldTokenId1,
            uint256 oldTokenId2
        ) = vno.tokenId_to_metadata(tokenId);

        (
            uint256 num,
            uint256 instances,
            uint256 activeParticulars,
            uint256 tokenId // bool made // uint256[] memory primes
        ) = vno.num_to_universal(number);
        uint256[] memory primes = vno.getPrimesFromNum(num);

        return (
            VNO.Universal(num, instances, activeParticulars, tokenId, primes)
        );
    }

    function getNumberFromTokenId(
        uint256 tokenId
    ) public view returns (uint256 number) {
        VNO.Universal memory universal = getUniversalFromTokenId(tokenId);
        uint256 number = universal.number;
        return number;
    }

    function get_tokenId_from_universal(
        uint256 num
    ) public view returns (uint256 tokenId) {
        (, , , uint256 tokenId) = vno.num_to_universal(num);

        console.log("get_tokenId_from_universal says:", tokenId);
        return tokenId;
    }

    function make_universal(
        uint256 num,
        address universalOwner,
        address recipient
    ) public returns (uint256 universal_id) {
        if (num == 0) {
            hoax(universalOwner);
            uint256 zeroId = vno.mintZero();
            hoax(universalOwner);
            vno.safeTransferFrom(universalOwner, recipient, zeroId);
            return zeroId;
        } else {
            hoax(universalOwner);
            uint256 id = vno.mintZero();
            for (uint256 i = 0; i < num; i++) {
                console.log("making universal:", i + 1);
                hoax(universalOwner);
                id = vno.mintBySuccession(id);
            }
            hoax(universalOwner);
            vno.safeTransferFrom(universalOwner, recipient, id);
            return id;
        }
    }

    function make_particular(
        uint256 num,
        address precedingUniversalsOwner,
        address receipient
    ) public returns (uint256 particular_id) {
        uint256 id = make_universal(num, precedingUniversalsOwner, alice);
        console.log("alice", alice);
        console.log("bob", bob);
        // console.log(getNumberFromTokenId(id), num);
        hoax(precedingUniversalsOwner);
        uint256 nid = vno.mintByDirect{value: 10 ether}(num);
        console.log("nid:", nid);

        console.log(precedingUniversalsOwner, "precedingUniversalsOwner");
        hoax(precedingUniversalsOwner);
        vno.safeTransferFrom(precedingUniversalsOwner, receipient, nid);

        return nid;
    }
}
