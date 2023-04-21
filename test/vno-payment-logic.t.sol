// // https://github.com/foundry-rs/forge-std

// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.10;

// import "../../lib/forge-std/src/Test.sol";
// // import "../../lib/ds-test/src/test.sol";
// // import "../../lib/ds-test/src/console.sol";
// // import "../../lib/ds-test/src/cheats.sol";
// import "../../src/vno.sol";
// import "forge-std/Test.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// interface CheatCodes {
//     function startPrank(address) external;

//     function prank(address) external;

//     function deal(address who, uint256 newBalance) external;

//     function addr(uint256 privateKey) external returns (address);

//     function warp(uint256) external; // Set block.timestamp
// }

// contract VNO_Test is Test {
//     VNO vno;
//     CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
//     // HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

//     address alice = cheats.addr(1);
//     address bob = cheats.addr(2);
//     address candice = cheats.addr(3);
//     address dominic = cheats.addr(4);

//     function setUp() public {
//         vno = new VNO();
//     }

//     string emptyset = "{}";
//     string e = "{}";
//     string i = "{{}}";
//     string ii = "{{{}}}";
//     string iii = "{{{{}}}}";
//     string v = "{{{{{{}}}}}}";
//     string vi = "{{{{{{{}}}}}}}";

//     function testPayUniversalOwner() public {
//         hoax(alice);
//         uint256 zeroTokenId = vno.mintZero(alice);
//         hoax(alice);
//         uint256 oneTokenId = vno.mintBySuccession(alice, zeroTokenId);
//         hoax(alice);
//         uint256 twoTokenId = vno.mintBySuccession(alice, oneTokenId);
//         uint256 tax = 1000;
//         hoax(alice);
//         vno.setUniversalTax(2, tax);
//         startHoax(bob, 10000);
//         uint256 oldBobBalance = bob.balance;
//         console.log("bob's balance is:", oldBobBalance);
//         vno.payUniversalOwner{value: 1000}(2);
//         assertEq(bob.balance, oldBobBalance - tax);
//     }

//     // https://github.com/foundry-rs/forge-std

//     function testHoax() public {
//         // we call `hoax`, which gives the target address
//         // eth and then calls `prank`
//         address moron = address(1337);
//         hoax(moron);
//         uint256 moronBalanceBefore = moron.balance;

//         console.log("The balance of vno was originally:", address(vno).balance);
//         console.log(
//             "And the balance of moron was originally:",
//             moronBalanceBefore
//         );
//         vno.payUniversalOwner{value: 100}(2);
//         // payable(address(vno)).payUniversalOwner{value: 100}(2);

//         console.log(
//             "after moron sent some money to vno, moron has:",
//             moron.balance
//         );
//         console.log("and vno has this amount of money:", address(vno).balance);
//         assertEq(moronBalanceBefore - 100, moron.balance);
//         assertEq(100, address(vno).balance);
//         // console.log(moron.balance);
//         // console.log(address(vno).balance);

//         // overloaded to allow you to specify how much eth to
//         // initialize the address with
//         hoax(address(1337), 1);
//         // vno.payUniversalOwner{value: 1}(address(1337));
//     }

//     // function testHoax() public {
//     //     address moron = address(1337);
//     //     hoax(moron);
//     //     uint256 moronBalanceBefore = moron.balance;
//     //     console.log("The balance of vno was originally:",address(vno).balance);
//     //     console.log("And the balance of moron was originally:",moronBalanceBefore);
//     //     vno.payHoax{value: 100}();

//     // }
//     // https://vomtom.at/solidity-0-6-4-and-call-value-curly-brackets/

//     // function testDrawByPowers() public {
//     //     string memory image = vno.drawByPowers(1);
//     //     console.log(image);
//     // }

//     function testFactorise() public {
//         uint256 num = 49;
//         uint256[] memory factors = vno.factorise(num);
//         // uint256[] memory draw = vno.num_to_universal(num).primes();

//         string memory factorString = "";
//         // string memory drawString = "";

//         for (uint256 i = 0; i < factors.length; i++) {
//             factorString = string(
//                 abi.encodePacked(
//                     factorString,
//                     Strings.toString(factors[i]),
//                     ","
//                 )
//             );
//         }
//         // for (uint256 i = 0; i < draw.length; i++) {
//         //     drawString = string(
//         //         abi.encodePacked(factorString, Strings.toString(draw[i]), ",")
//         //     );
//         // }
//         console.log(factorString);

//         // console.log(drawString);

//         // string memory image = vno.draw(49);
//         // console.log(image);
//     }

//     function testdivReturnDecimal() public {
//         uint256 X = 260;
//         uint256 Y = 20000;
//         string memory decimal = vno.divReturnDecimal(X, Y);
//         console.log(decimal);
//         // bytes16 b = 16;
//         // console.log(b);
//         // uint256 x = X;
//         // uint256 y = Y;

//         // uint256 d = 0;
//         // uint256 s = 0;
//         // uint256 I = x / y;

//         // if (X % Y != 0) {
//         //     while (x % y != 0 && d <= 18) {
//         //         // while (x % y != 0 && d <= 18) {
//         //         console.log(s, x, d);
//         //         s = s * 10 + (x * 10) / y;

//         //         x = (x * 10) % y;

//         //         d += 1;
//         //     }
//         // }

//         // console.log(
//         //     "X:",
//         //     vno.utfStringLength(Strings.toString(Y)),
//         //     "Y:",
//         //     vno.utfStringLength(Strings.toString(X))
//         // );
//         // uint256 zeros = (
//         //     (X % Y == 0)
//         //         ? 0
//         //         : (
//         //             (X % 10 == 0 && Y % 10 == 0)
//         //                 ? vno.utfStringLength(Strings.toString(Y)) -
//         //                     vno.utfStringLength(Strings.toString(X))
//         //                 : 0
//         //         )
//         // );

//         // string memory zeroString = "";

//         // if (zeros != 0) {
//         //     for (uint256 i = 0; i < zeros; i++) {
//         //         zeroString = string(
//         //             abi.encodePacked(zeroString, Strings.toString(0))
//         //         );
//         //     }
//         // }

//         // string memory decimal = string(
//         //     abi.encodePacked(
//         //         Strings.toString(I),
//         //         ".",
//         //         zeroString,
//         //         Strings.toString(s % (10**d))
//         //     )
//         // );
//         // console.log(decimal);
//     }

//     function testDraw() public {
//         uint256 num = 5 ** 3;
//         vno.factorise(num);
//         string memory image = vno.drawUniversal(num);
//         // string memory image = vno.draw(num);
//         console.log(image);
//     }
// }
