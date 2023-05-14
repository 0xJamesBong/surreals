// https://github.com/foundry-rs/forge-std

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../../lib/forge-std/src/Test.sol";
// import "../../lib/ds-test/src/test.sol";
// import "../../lib/ds-test/src/console.sol";
// import "../../lib/ds-test/src/cheats.sol";
import "../src/vno.sol";
import {SharedFunctions} from "./sharedFunctions.sol";

import "forge-std/Test.sol";

interface CheatCodes {
    function startPrank(address) external;

    function prank(address) external;

    function deal(address who, uint256 newBalance) external;

    function addr(uint256 privateKey) external returns (address);

    function warp(uint256) external; // Set block.timestamp
}

contract Draw_Test is SharedFunctions {
    function test_drawUniversal() public view {
        // string memory drawing = vno.drawUniversal(27 * 3);
        string memory drawing = vno.drawUniversal(5 * 2);
        console.log(drawing);
    }

    function test_drawParticular() public view {
        string memory particular = vno.drawParticular(MAX_INT);
        console.log(particular);
    }

    function test_factorise() public {
        uint256[] memory factors = vno.factorise(8 ** 3 * 4 * 5 ** 8);
        for (uint256 i = 0; i < factors.length; i++) {
            if (factors[i] != 0) {
                console.log("Factor", i, ":", factors[i]);
            }
        }
        console.log("The length of the factors array is:", factors.length);
    }

    function test_factorise_zero() public {
        uint256[] memory factors = vno.factorise(0);
        for (uint256 i = 0; i < factors.length; i++) {
            if (factors[i] != 0) {
                console.log("Factor", i, ":", factors[i]);
            }
        }
        console.log("The length of the factors array is:", factors.length);
        assertEq(factors.length, 0);
    }

    function test_factorise_one() public {
        uint256[] memory factors = vno.factorise(1);
        for (uint256 i = 0; i < factors.length; i++) {
            if (factors[i] != 0) {
                console.log("Factor", i, ":", factors[i]);
            }
        }
        console.log("The length of the factors array is:", factors.length);
        assertEq(factors.length, 1);
    }

    // function testdivReturnDecimal() public {
    //     uint256 X = 260;
    //     uint256 Y = 20000;
    //     string memory decimal = vno.divReturnDecimal(X, Y);
    //     console.log(decimal);
    //     // bytes16 b = 16;
    //     // console.log(b);
    //     // uint256 x = X;
    //     // uint256 y = Y;

    //     // uint256 d = 0;
    //     // uint256 s = 0;
    //     // uint256 I = x / y;

    //     // if (X % Y != 0) {
    //     //     while (x % y != 0 && d <= 18) {
    //     //         // while (x % y != 0 && d <= 18) {
    //     //         console.log(s, x, d);
    //     //         s = s * 10 + (x * 10) / y;

    //     //         x = (x * 10) % y;

    //     //         d += 1;
    //     //     }
    //     // }

    //     // console.log(
    //     //     "X:",
    //     //     vno.utfStringLength(Strings.toString(Y)),
    //     //     "Y:",
    //     //     vno.utfStringLength(Strings.toString(X))
    //     // );
    //     // uint256 zeros = (
    //     //     (X % Y == 0)
    //     //         ? 0
    //     //         : (
    //     //             (X % 10 == 0 && Y % 10 == 0)
    //     //                 ? vno.utfStringLength(Strings.toString(Y)) -
    //     //                     vno.utfStringLength(Strings.toString(X))
    //     //                 : 0
    //     //         )
    //     // );

    //     // string memory zeroString = "";

    //     // if (zeros != 0) {
    //     //     for (uint256 i = 0; i < zeros; i++) {
    //     //         zeroString = string(
    //     //             abi.encodePacked(zeroString, Strings.toString(0))
    //     //         );
    //     //     }
    //     // }

    //     // string memory decimal = string(
    //     //     abi.encodePacked(
    //     //         Strings.toString(I),
    //     //         ".",
    //     //         zeroString,
    //     //         Strings.toString(s % (10**d))
    //     //     )
    //     // );
    //     // console.log(decimal);
    // }
}
