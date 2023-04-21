// // https://github.com/foundry-rs/forge-std

// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.10;

// import "../../lib/forge-std/src/Test.sol";
// import {VNO_with_nestedStrings} from "../../src/vno-with-nested-strings.sol";
// // import "../../src/vno.sol";
// import "forge-std/Test.sol";
// import "solmate/utils/LibString.sol";

// interface CheatCodes {
//     function startPrank(address) external;

//     function prank(address) external;

//     function deal(address who, uint256 newBalance) external;

//     function addr(uint256 privateKey) external returns (address);

//     function warp(uint256) external; // Set block.timestamp
// }

// contract String_Manipulation_Test is Test {
//     VNO_with_nestedStrings vno;
//     // VNO vno;
//     CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

//     address alice = cheats.addr(1);
//     address bob = cheats.addr(2);
//     address candice = cheats.addr(3);
//     address dominic = cheats.addr(4);

//     function setUp() public {
//         vno = new VNO_with_nestedStrings();
//     }

//     string emptyset = "{}";
//     string e = "{}";
//     string i = "{{}}";
//     string ii = "{{{}}}";
//     string iii = "{{{{}}}}";
//     string v = "{{{{{{}}}}}}";
//     string vi = "{{{{{{{}}}}}}}";

//     function test_concat() public {
//         string memory str1 = "a";
//         string memory str2 = "b";
//         string memory str3 = "c";
//         string memory str4 = "d";
//         assertEq(
//             vno.concat(str1, str2, str3),
//             vno.concat(vno.concat(str1, str2), str3)
//         );
//         assertEq(
//             vno.concat(str1, str2, str3),
//             vno.concat(str1, vno.concat(str2, str3))
//         );
//     }

//     function testutfStringLength() public {
//         string memory two = "{{{}}}";
//         string memory three = "{{{{}}}}";
//         string memory five = "{{{{{{{}}}}}}}";
//         assertEq(vno.utfStringLength(two), 6);
//         assertEq(vno.utfStringLength(three), 8);
//         assertEq(vno.utfStringLength(five), 14);
//     }

//     function testPredecessorString() public {
//         string memory predE = vno.predecessorString(e);
//         string memory predi = vno.predecessorString(i);
//         string memory predii = vno.predecessorString(ii);
//         console.log("The predecessor of zero should be", e, predE);
//         console.log("The predecessor of one  should be", e, predi);
//         console.log("The predecessor of two  should be", i, predii);
//         assertTrue(
//             keccak256(abi.encodePacked(e)) == keccak256(abi.encodePacked(predE))
//         );
//         // assertTrue(keccak256(abi.encodePacked(e))==keccak256(abi.encodePacked(predi)));
//         assertTrue(
//             keccak256(abi.encodePacked(i)) ==
//                 keccak256(abi.encodePacked(predii))
//         );
//     }

//     function testIsNestedString() public {
//         string memory five = "{{{{{{}}}}}}";
//         string memory otherGlyphs = "{1a44}";
//         string memory misordered = "}{}}";
//         string memory notequalbrackets = "{}}";
//         string memory asymmetricNestedString = "{{{{{}}}";
//         //
//         // (bool isFive                     , uint256 numLfive,                    uint256 numRfive)   = vno.isNestedString(five                  );
//         (
//             bool isOtherGlyphs,
//             uint256 numLOtherGlyphs,
//             uint256 numROtherGlyphs
//         ) = vno.isNestedString(otherGlyphs);
//         (
//             bool isMisordered,
//             uint256 numLmisordered,
//             uint256 numRmisordered
//         ) = vno.isNestedString(misordered);
//         (
//             bool isnotequalbrackets,
//             uint256 numLnotequalbrackets,
//             uint256 numRnotequalbrackets
//         ) = vno.isNestedString(notequalbrackets);
//         (
//             bool isAsymmetricNestedString,
//             uint256 numLAsymmetricNestedString,
//             uint256 numRAsymmetricNestedString
//         ) = vno.isNestedString(asymmetricNestedString);

//         // console.log(isFive, numLfive, numRfive);
//         console.log(isOtherGlyphs, numLOtherGlyphs, numROtherGlyphs);
//         console.log(isMisordered, numLmisordered, numRmisordered);
//         console.log(
//             isnotequalbrackets,
//             numLnotequalbrackets,
//             numRnotequalbrackets
//         );
//         console.log(
//             isAsymmetricNestedString,
//             numLAsymmetricNestedString,
//             numRAsymmetricNestedString
//         );

//         // assertTrue(isFive                     == true  );
//         assertTrue(isOtherGlyphs == false);
//         assertTrue(isMisordered == false);
//         assertTrue(isnotequalbrackets == false);
//         assertTrue(isAsymmetricNestedString == false);
//     }

//     function testAddNestedSets() public {
//         string memory emptyset = "{}";
//         string memory one = "{{}}";
//         string memory two = "{{{}}}";
//         string memory three = "{{{{}}}}";
//         string memory five = "{{{{{{}}}}}}";
//         // 2 = {{{}}}
//         // 3 = {{{{}}}}
//         // 5 = {{{{{{{}}}}}}}

//         string memory ee = vno.addNestedSets(emptyset, emptyset);
//         console.log("The string of ee is", ee);
//         string memory eo = vno.addNestedSets(emptyset, one);
//         string memory oe = vno.addNestedSets(one, emptyset);
//         string memory oo = vno.addNestedSets(one, one);
//         string memory twothree = vno.addNestedSets(two, three);

//         console.log("The string of oo is", oo);
//         assertTrue(
//             keccak256(abi.encodePacked(ee)) ==
//                 keccak256(abi.encodePacked(emptyset))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(eo)) == keccak256(abi.encodePacked(one))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(oe)) == keccak256(abi.encodePacked(one))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(oo)) == keccak256(abi.encodePacked(two))
//         );
//         console.log("The string of twothree is", twothree);
//         console.log("The string of five is", five);
//         assertTrue(
//             keccak256(abi.encodePacked(five)) ==
//                 keccak256(abi.encodePacked(twothree))
//         );

//         assertTrue(
//             keccak256(abi.encodePacked(vno.addNestedSets(two, five))) ==
//                 keccak256(abi.encodePacked(vno.addNestedSets(five, two)))
//         );
//     }

//     function testMultiplyNestedSets() public {
//         string memory exi = vno.multiplyNestedSets(e, i); // zero multiplied with anything should be 0 should be 0
//         string memory ixi = vno.multiplyNestedSets(i, i); // anything multiplied by 1 should be itself.
//         string memory iixi = vno.multiplyNestedSets(ii, i); // anything multiplied by 1 should be itself.
//         string memory iiixe = vno.multiplyNestedSets(iii, e); // multiplication by 1 should return self, commutativity test
//         string memory exiii = vno.multiplyNestedSets(e, iii); // multiplication by 1 should return self, commutativity test
//         string memory iixiii = vno.multiplyNestedSets(ii, iii); //  commutativity test
//         string memory iiixii = vno.multiplyNestedSets(iii, ii); //  commutativity test

//         console.log("exi    should be", e, exi);
//         console.log("ixi    should be", i, ixi);
//         console.log("iixi   should be", ii, iixi);
//         console.log("iiixe  should be", e, iiixe);
//         console.log("exiii  should be", e, exiii);
//         console.log("iixiii should be", vi, iixiii);
//         console.log("iiixii should be", iixiii, iiixii);

//         assertTrue(
//             keccak256(abi.encodePacked(exi)) == keccak256(abi.encodePacked(e))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(ixi)) == keccak256(abi.encodePacked(i))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(iixi)) == keccak256(abi.encodePacked(ii))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(iiixe)) == keccak256(abi.encodePacked(e))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(exiii)) == keccak256(abi.encodePacked(e))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(iixiii)) ==
//                 keccak256(abi.encodePacked(vi))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(iiixii)) ==
//                 keccak256(abi.encodePacked(iiixii))
//         );
//     }

//     function testSubtractNestedSets() public {
//         string memory v = vno.addNestedSets(iii, ii);
//         string memory imi = vno.subtractNestedSets(i, i); // anything multiplied by 1 should be itself.
//         string memory iimi = vno.subtractNestedSets(ii, i); // anything multiplied by 1 should be itself.
//         string memory iiime = vno.subtractNestedSets(iii, e); // multiplication by 1 should return self, commutativity test
//         string memory vmiii = vno.subtractNestedSets(v, iii); // multiplication by 1 should return self, commutativity test

//         console.log("v should be", "{{{{{{}}}}}}", v);
//         console.log("imi    should be", e, imi);
//         console.log("iimi   should be", i, iimi);
//         console.log("iiime  should be", iii, iiime);
//         console.log("vmiii  should be", ii, vmiii);

//         assertTrue(
//             keccak256(abi.encodePacked("{{{{{{}}}}}}")) ==
//                 keccak256(abi.encodePacked(v))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(e)) == keccak256(abi.encodePacked(imi))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(i)) == keccak256(abi.encodePacked(iimi))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(iii)) ==
//                 keccak256(abi.encodePacked(iiime))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(ii)) ==
//                 keccak256(abi.encodePacked(vmiii))
//         );
//     }

//     // this is not written yet
//     function testExponentiateNestedSets() public {
//         string memory iEiii = vno.exponentiateNestedSets(i, iii); // one to the power of three is one
//         string memory iiEi = vno.exponentiateNestedSets(ii, i); // two the power of one is one
//         string memory vEiii = vno.exponentiateNestedSets(v, iii); // five to the power of three is 125
//         string memory oneHundredAndTwentyFive = vno.multiplyNestedSets(
//             vno.multiplyNestedSets(v, v),
//             v
//         );
//         // string memory iiime     = vno.exponentiateNestedSets(iii, e);       // iiii expect revert

//         console.log("iEiii                   should be", i, iEiii);
//         console.log("iiEi                    should be", ii, iiEi);
//         console.log(
//             "vEiii                   should be",
//             vEiii,
//             oneHundredAndTwentyFive
//         );
//         // console.log("oneHundredAndTwentyFive should be", iii ,   iiime);

//         assertTrue(
//             keccak256(abi.encodePacked(i)) == keccak256(abi.encodePacked(iEiii))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(ii)) == keccak256(abi.encodePacked(iiEi))
//         );
//         assertTrue(
//             keccak256(abi.encodePacked(vEiii)) ==
//                 keccak256(abi.encodePacked(oneHundredAndTwentyFive))
//         );
//     }
// }
