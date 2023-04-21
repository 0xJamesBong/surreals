// // https://github.com/foundry-rs/forge-std

// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.10;

// import "../../lib/forge-std/src/Test.sol";
// // import "../../lib/ds-test/src/test.sol";
// // import "../../lib/ds-test/src/console.sol";
// // import "../../lib/ds-test/src/cheats.sol";
// import "../../src/vno-old.sol";
// import "forge-std/Test.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// interface CheatCodes {
//     function startPrank(address) external;

//     function prank(address) external;

//     function deal(address who, uint256 newBalance) external;

//     function addr(uint256 privateKey) external returns (address);

//     function warp(uint256) external; // Set block.timestamp
// }

// contract VNO_Old_Test is Test {
//     VNO_OLD vno_old;
//     CheatCodes cheats = CheatCodes(HEVM_ADDRESS);
//     // HEVM_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D

//     address alice = cheats.addr(1);
//     address bob = cheats.addr(2);
//     address candice = cheats.addr(3);
//     address dominic = cheats.addr(4);

//     function setUp() public {
//         vno_old = new VNO_OLD();
//     }

//     struct Universal {
//         string nestedString;
//         uint256 number;
//         uint256 instances;
//     }

//     string emptyset = "{}";
//     string e = "{}";
//     string i = "{{}}";
//     string ii = "{{{}}}";
//     string iii = "{{{{}}}}";
//     string v = "{{{{{{}}}}}}";
//     string vi = "{{{{{{{}}}}}}}";

//     function testutfStringLength() public {
//         string memory two = "{{{}}}";
//         string memory three = "{{{{}}}}";
//         string memory five = "{{{{{{{}}}}}}}";
//         assertEq(vno_old.utfStringLength(two), 6);
//         assertEq(vno_old.utfStringLength(three), 8);
//         assertEq(vno_old.utfStringLength(five), 14);
//     }

//     function testPredecessorString() public {
//         string memory predE = vno_old.predecessorString(e);
//         string memory predi = vno_old.predecessorString(i);
//         string memory predii = vno_old.predecessorString(ii);
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
//         // (bool isFive                     , uint256 numLfive,                    uint256 numRfive)   = vno_old.isNestedString(five                  );
//         (
//             bool isOtherGlyphs,
//             uint256 numLOtherGlyphs,
//             uint256 numROtherGlyphs
//         ) = vno_old.isNestedString(otherGlyphs);
//         (
//             bool isMisordered,
//             uint256 numLmisordered,
//             uint256 numRmisordered
//         ) = vno_old.isNestedString(misordered);
//         (
//             bool isnotequalbrackets,
//             uint256 numLnotequalbrackets,
//             uint256 numRnotequalbrackets
//         ) = vno_old.isNestedString(notequalbrackets);
//         (
//             bool isAsymmetricNestedString,
//             uint256 numLAsymmetricNestedString,
//             uint256 numRAsymmetricNestedString
//         ) = vno_old.isNestedString(asymmetricNestedString);

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

//         string memory ee = vno_old.addNestedSets(emptyset, emptyset);
//         console.log("The string of ee is", ee);
//         string memory eo = vno_old.addNestedSets(emptyset, one);
//         string memory oe = vno_old.addNestedSets(one, emptyset);
//         string memory oo = vno_old.addNestedSets(one, one);
//         string memory twothree = vno_old.addNestedSets(two, three);

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
//     }

//     function testMultiplyNestedSets() public {
//         string memory exi = vno_old.multiplyNestedSets(e, i); // zero multiplied with anything should be 0 should be 0
//         string memory ixi = vno_old.multiplyNestedSets(i, i); // anything multiplied by 1 should be itself.
//         string memory iixi = vno_old.multiplyNestedSets(ii, i); // anything multiplied by 1 should be itself.
//         string memory iiixe = vno_old.multiplyNestedSets(iii, e); // multiplication by 1 should return self, commutativity test
//         string memory exiii = vno_old.multiplyNestedSets(e, iii); // multiplication by 1 should return self, commutativity test
//         string memory iixiii = vno_old.multiplyNestedSets(ii, iii); //  commutativity test
//         string memory iiixii = vno_old.multiplyNestedSets(iii, ii); //  commutativity test

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
//         string memory v = vno_old.addNestedSets(iii, ii);
//         string memory imi = vno_old.subtractNestedSets(i, i); // anything multiplied by 1 should be itself.
//         string memory iimi = vno_old.subtractNestedSets(ii, i); // anything multiplied by 1 should be itself.
//         string memory iiime = vno_old.subtractNestedSets(iii, e); // multiplication by 1 should return self, commutativity test
//         string memory vmiii = vno_old.subtractNestedSets(v, iii); // multiplication by 1 should return self, commutativity test

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
//         string memory iEiii = vno_old.exponentiateNestedSets(i, iii); // one to the power of three is one
//         string memory iiEi = vno_old.exponentiateNestedSets(ii, i); // two the power of one is one
//         string memory vEiii = vno_old.exponentiateNestedSets(v, iii); // five to the power of three is 125
//         string memory oneHundredAndTwentyFive = vno_old.multiplyNestedSets(
//             vno_old.multiplyNestedSets(v, v),
//             v
//         );
//         // string memory iiime     = vno_old.exponentiateNestedSets(iii, e);       // iiii expect revert

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

//     function testMassiveExponentiation() public {
//         string memory x;
//         string memory y;

//         for (uint256 u = 0; u < 20; u++) {
//             if (u == 0) {
//                 y = "{}";
//             } else {
//                 y = vno_old.addNestedSets(y, i);
//             }
//         }
//         x = vno_old.exponentiateNestedSets(ii, y);
//         console.log(x, vno_old.nestedStringToNum(x));
//     }

//     function testMakeZero() public {
//         uint256 early = 1900000000;
//         uint256 later = 2000000000;

//         cheats.warp(early);
//         uint256 tokenId_before_mint = vno_old.getCurrentTokenId();
//         console.log(
//             "The tokenId before Alice minted a new token is:",
//             tokenId_before_mint
//         );

//         assertTrue(!vno_old.universalExists(0));
//         vno_old.makeZero(alice);

//         assertTrue(vno_old.universalExists(0));

//         // console.log("The tokenId after Alice minting is:", vno_old.getCurrentTokenId());
//         assertTrue(vno_old.ownerOf(tokenId_before_mint) == alice);

//         string memory aliceNestedString = vno_old
//             .getUniversalFromTokenId(tokenId_before_mint)
//             .nestedString;
//         uint256 aliceNumber = vno_old
//             .getUniversalFromTokenId(tokenId_before_mint)
//             .number;
//         uint256 aliceInstances = vno_old
//             .getUniversalFromTokenId(tokenId_before_mint)
//             .instances;
//         (, uint256 aliceMintTime, uint256 aliceOrder) = vno_old
//             .tokenId_to_metadata(tokenId_before_mint);

//         assertTrue(
//             keccak256(abi.encodePacked(aliceNestedString)) ==
//                 keccak256(abi.encodePacked(emptyset))
//         );
//         assertEq(aliceNumber, 0);
//         assertEq(aliceInstances, 1);
//         assertEq(aliceMintTime, early);
//         assertEq(aliceOrder, 1);

//         cheats.warp(later);
//         console.log("The time now is", block.timestamp);
//         console.log(
//             "The owner of",
//             tokenId_before_mint,
//             "is",
//             vno_old.ownerOf(tokenId_before_mint)
//         );
//         console.log("And the address of Alice is", alice);
//         console.log("The number minted is", aliceNumber);
//         console.log("of which there are instances:", aliceInstances);
//         console.log("it was minted at mint time:", aliceMintTime);
//         console.log("the order was:", aliceOrder);
//         console.log(
//             "The nested string of the token Alice owned is",
//             aliceNestedString
//         );

//         console.log(vno_old.universalExists(0));

//         uint256 bobTokenId = vno_old.getCurrentTokenId();

//         vno_old.makeZero(bob);

//         string memory bobNestedString = vno_old
//             .getUniversalFromTokenId(bobTokenId)
//             .nestedString;
//         uint256 bobNumber = vno_old.getUniversalFromTokenId(bobTokenId).number;
//         uint256 bobInstance = vno_old
//             .getUniversalFromTokenId(bobTokenId)
//             .instances;
//         (, uint256 bobMintTime, uint256 bobOrder) = vno_old.tokenId_to_metadata(
//             bobTokenId
//         );

//         assertTrue(
//             keccak256(abi.encodePacked(bobNestedString)) ==
//                 keccak256(abi.encodePacked(emptyset))
//         );
//         assertEq(bobNumber, 0);
//         assertEq(bobInstance, 2);
//         assertEq(bobMintTime, later);
//         assertEq(bobOrder, 2);

//         console.log("The time now is", block.timestamp);
//         console.log(
//             "The owner of",
//             bobTokenId,
//             "is",
//             vno_old.ownerOf(bobTokenId)
//         );
//         console.log("And the address of Bob is", bob);
//         console.log("The number minted is", bobNumber);
//         console.log("of which there are instances:", bobInstance);
//         console.log("it was minted at mint time:", bobMintTime);
//         console.log("the order was:", bobOrder);
//         console.log(
//             "The nested string of the token Bob owned is",
//             bobNestedString
//         );
//     }

//     function testMintSuccessor() public {
//         hoax(alice); // pretend it's alice calling the functions
//         uint256 oldAliceBalance = alice.balance; // record alice's old balance
//         console.log(oldAliceBalance);

//         uint256 zeroTokenId = vno_old.getCurrentTokenId(); // the current tokenId will be the id of the zeroToke

//         vno_old.makeZero(alice); // make Zero and give it to alice
//         assertTrue(vno_old.isUniversal(zeroTokenId)); // check if the zeroTokenId is indeed a Universal

//         assertTrue(vno_old.ownerOf(zeroTokenId) == alice); // check if alice owns the token
//         uint256 oneTokenId = vno_old.mintSuccessor(alice, zeroTokenId); // we will be minting the successor of zero, we are now recording the tokenId
//         assertTrue(vno_old.isUniversal(oneTokenId)); // given it is the first token to be minted of the number one, it should be a universal
//         assertTrue(vno_old.ownerOf(oneTokenId) == alice); // it should belong to alice

//         uint256 anotherOneTokenId = vno_old.mintSuccessor(alice, zeroTokenId); // we now mint another token of number One
//         assertTrue(!vno_old.isUniversal(anotherOneTokenId)); // it shouldn't be a universal
//         assertTrue(vno_old.ownerOf(anotherOneTokenId) == alice); // it should belong to alice
//         uint256 newAliceBalance = alice.balance; // since it was minted via the successor function, alice should have paid nothing
//         console.log(newAliceBalance);
//         assertEq(oldAliceBalance, newAliceBalance);

//         hoax(bob); //now let us pretend bob is calling the functions
//         uint256 oldBobBalance = bob.balance; // record bob's balance
//         uint256 bobMintOneTokenId = vno_old.getCurrentTokenId(); // getting the tokenId in which bob minted
//         uint256 bobzerotokenid = vno_old.makeZero(bob); // for bob to mint the successor of one, he has to mint a zero first
//         uint256 bobOneTokenId = vno_old.mintSuccessor(bob, bobzerotokenid); // bob mints a successor of one
//         assertTrue(!vno_old.isUniversal(bobOneTokenId)); // the minted successor of zero should not be a universal
//         assertTrue(vno_old.ownerOf(bobOneTokenId) == bob); // bob should be the owner of the token
//         assertTrue(oldBobBalance == bob.balance); // bob's balance should not have been reduced
//     }

//     function testDirectMint() public {
//         // To test this, you need to make a lot of numbers first
//         hoax(alice);
//         uint256 zeroTokenId = vno_old.makeZero(alice);
//         hoax(alice);
//         uint256 oneTokenId = vno_old.mintSuccessor(alice, zeroTokenId);
//         hoax(alice);
//         uint256 twoTokenId = vno_old.mintSuccessor(alice, oneTokenId);
//         uint256 tax = 1000;
//         hoax(alice);
//         vno_old.setUniversalTax(2, tax);
//         startHoax(bob);
//         uint256 oldBobBalance = bob.balance;
//         uint256 directMintTokenId = vno_old.directMint{value: 1000}(bob, 2);
//         assertTrue(!vno_old.isUniversal(directMintTokenId));
//         assertTrue(!vno_old.isUniversal(directMintTokenId));
//         assertEq(oldBobBalance - tax, bob.balance);
//     }

//     function testMintViaAddition() public {
//         // To test this, you need to make a lot of numbers first
//         hoax(alice);
//         uint256 zeroTokenId = vno_old.makeZero(alice);
//         uint256 oneTokenId = vno_old.mintSuccessor(alice, zeroTokenId);
//         uint256 twoTokenId = vno_old.mintSuccessor(alice, oneTokenId);
//         uint256 threeTokenId = vno_old.mintByAddition(
//             alice,
//             oneTokenId,
//             twoTokenId
//         ); // minting by addition
//         uint256 anotherThreeTokenId = vno_old.mintByAddition(
//             alice,
//             twoTokenId,
//             oneTokenId
//         ); // this is possible because both one and two should be universals
//         assertTrue(vno_old.isUniversal(oneTokenId));
//         assertTrue(vno_old.isUniversal(twoTokenId));
//         assertTrue(vno_old.isUniversal(threeTokenId));
//         assertTrue(!vno_old.isUniversal(anotherThreeTokenId));

//         assertEq(
//             vno_old.getNumberFromTokenId(threeTokenId),
//             vno_old.getNumberFromTokenId(anotherThreeTokenId)
//         );

//         hoax(bob);
//     }

//     function testMintViaMultiplication() public {
//         // To test this, you need to make a lot of numbers first
//         hoax(alice);
//         uint256 zeroTokenId = vno_old.makeZero(alice);
//         uint256 oneTokenId = vno_old.mintSuccessor(alice, zeroTokenId);
//         uint256 twoTokenId = vno_old.mintSuccessor(alice, oneTokenId);
//     }

//     function testMintViaExponentiation() public {}

//     function testMintViaSubtraction() public {}

//     function testPayUniversalOwner() public {
//         hoax(alice);
//         uint256 zeroTokenId = vno_old.makeZero(alice);
//         hoax(alice);
//         uint256 oneTokenId = vno_old.mintSuccessor(alice, zeroTokenId);
//         hoax(alice);
//         uint256 twoTokenId = vno_old.mintSuccessor(alice, oneTokenId);
//         uint256 tax = 1000;
//         hoax(alice);
//         vno_old.setUniversalTax(2, tax);
//         startHoax(bob, 10000);
//         uint256 oldBobBalance = bob.balance;
//         console.log("bob's balance is:", oldBobBalance);
//         vno_old.payUniversalOwner{value: 1000}(2);
//         assertEq(bob.balance, oldBobBalance - tax);
//     }

//     // https://github.com/foundry-rs/forge-std

//     function testHoax() public {
//         // we call `hoax`, which gives the target address
//         // eth and then calls `prank`
//         address moron = address(1337);
//         hoax(moron);
//         uint256 moronBalanceBefore = moron.balance;

//         console.log(
//             "The balance of vno_old was originally:",
//             address(vno_old).balance
//         );
//         console.log(
//             "And the balance of moron was originally:",
//             moronBalanceBefore
//         );
//         vno_old.payUniversalOwner{value: 100}(2);
//         // payable(address(vno_old)).payUniversalOwner{value: 100}(2);

//         console.log(
//             "after moron sent some money to vno_old, moron has:",
//             moron.balance
//         );
//         console.log(
//             "and vno_old has this amount of money:",
//             address(vno_old).balance
//         );
//         assertEq(moronBalanceBefore - 100, moron.balance);
//         assertEq(100, address(vno_old).balance);
//         // console.log(moron.balance);
//         // console.log(address(vno_old).balance);

//         // overloaded to allow you to specify how much eth to
//         // initialize the address with
//         hoax(address(1337), 1);
//         // vno_old.payUniversalOwner{value: 1}(address(1337));
//     }

//     // function testHoax() public {
//     //     address moron = address(1337);
//     //     hoax(moron);
//     //     uint256 moronBalanceBefore = moron.balance;
//     //     console.log("The balance of vno_old was originally:",address(vno_old).balance);
//     //     console.log("And the balance of moron was originally:",moronBalanceBefore);
//     //     vno_old.payHoax{value: 100}();

//     // }
//     // https://vomtom.at/solidity-0-6-4-and-call-value-curly-brackets/
//     function testBar() public {
//         // we call `hoax`, which gives the target address
//         // eth and then calls `prank`
//         address moron = address(1337);
//         hoax(moron);
//         uint256 moronBalanceBefore = moron.balance;

//         console.log(
//             "The balance of vno_old was originally:",
//             address(vno_old).balance
//         );
//         console.log(
//             "And the balance of moron was originally:",
//             moronBalanceBefore
//         );
//         // vno_old.bar(moron);
//         vno_old.bar{value: 100}(moron);

//         console.log(
//             "after moron sent some money to vno_old, moron has:",
//             moron.balance
//         );
//         console.log(
//             "and vno_old has this amount of money:",
//             address(vno_old).balance
//         );
//         assertEq(moronBalanceBefore - 100, moron.balance);
//         assertEq(100, address(vno_old).balance);
//         // console.log(moron.balance);
//         console.log(address(vno_old).balance);
//         //
//         // overloaded to allow you to specify how much eth to
//         // initialize the address with
//         hoax(address(1337), 1);
//         bool success = vno_old.bar{value: 1}(address(1337));
//         //
//         console.log(success);
//     }

//     function testSendViaCall() public {
//         // we call `hoax`, which gives the target address
//         // eth and then calls `prank`
//         address moron = address(1337);
//         hoax(moron);
//         uint256 moronBalanceBefore = moron.balance;

//         console.log(
//             "The balance of vno_old was originally:",
//             address(vno_old).balance
//         );
//         console.log(
//             "And the balance of moron was originally:",
//             moronBalanceBefore
//         );
//         vno_old.bar{value: 100}(moron);

//         console.log(
//             "after moron sent some money to vno_old, moron has:",
//             moron.balance
//         );
//         console.log(
//             "and vno_old has this amount of money:",
//             address(vno_old).balance
//         );
//         assertEq(moronBalanceBefore - 100, moron.balance);
//         assertEq(100, address(vno_old).balance);
//         // console.log(moron.balance);
//         // console.log(address(vno_old).balance);

//         // overloaded to allow you to specify how much eth to
//         // initialize the address with
//         hoax(address(1337), 1);
//         bool success = vno_old.sendViaCall{value: 1}();
//         console.log(success);
//     }

//     function testMakePolygon() public {
//         string memory polygon = vno_old.makePolygon(7);
//         console.log(polygon);
//     }

//     // function testDrawByPowers() public {
//     //     string memory image = vno_old.drawByPowers(1);
//     //     console.log(image);
//     // }

//     function testFactorise() public {
//         uint256 num = 49;
//         uint256[] memory factors = vno_old.factorise(num);
//         // uint256[] memory draw = vno_old.num_to_universal(num).primes();

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
//         assertTrue(vno_old.stringsEq(factorString, "7,7,0,0,0,0,0,0,"));

//         // console.log(drawString);

//         // string memory image = vno_old.draw(49);
//         // console.log(image);
//     }

//     function testdivReturnDecimal() public {
//         uint256 X = 260;
//         uint256 Y = 20000;
//         string memory decimal = vno_old.divReturnDecimal(X, Y);
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
//         //     vno_old.utfStringLength(Strings.toString(Y)),
//         //     "Y:",
//         //     vno_old.utfStringLength(Strings.toString(X))
//         // );
//         // uint256 zeros = (
//         //     (X % Y == 0)
//         //         ? 0
//         //         : (
//         //             (X % 10 == 0 && Y % 10 == 0)
//         //                 ? vno_old.utfStringLength(Strings.toString(Y)) -
//         //                     vno_old.utfStringLength(Strings.toString(X))
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
//         vno_old.factorise(num);
//         (string memory image, ) = vno_old.draw(num);
//         // string memory image = vno_old.draw(num);
//         console.log(image);
//     }

//     // function testSendingEther() public {
//     //     uint256 aliceInitialBalance = 100;
//     //     uint256 bobInitialBalance = 0;
//     //     assertEq(alice.balance, 0);
//     //     assertEq(bobInitialBalance, 0);
//     //     cheats.deal(alice, aliceInitialBalance);
//     //     assertEq(alice.balance, 100);
//     //     cheats.prank(alice);
//     //     (bool sent,) = payable(bob).call{value:100 ether}("");
//     //     require(sent, "not sent");
//     //     assertEq(alice.balance,0);
//     //     assertEq(bob.balance, 100);
//     // }

//     // function testDeposit() public {
//     //     // https://vomtom.at/solidity-0-6-4-and-call-value-curly-brackets/
//     //     // https://soliditydeveloper.com/foundry
//     //     console.log("originally, dear poor Alice had only:", alice.balance);
//     //     assertEq(alice.balance, 0);
//     //     uint256 gibmoney = 10;
//     //     console.log("now I'm gibbing money to Alice. The amount is", gibmoney);
//     //     cheats.deal(alice, gibmoney);
//     //     console.log("And now Alice has:", alice.balance);
//     //     assertEq(alice.balance, 10);
//     //     console.log("The original balance of the vno_old is:", address(vno_old).balance);
//     //     console.log("the msg.sender now is:", msg.sender);
//     //     uint256 sentMoney = 3;
//     //     console.log("Now alice is sending money to the vno_old contract. The amount is:", sentMoney);
//     //     console.log("the address of vno_old is",address(vno_old));
//     //     cheats.startPrank(alice);
//     //     (bool success, ) = payable(vno_old).call{value: 3 ether}("");
//     //     console.log("the address of alice is:", alice);
//     //     console.log("the msg.sender now is:", msg.sender);

//     //     // console.log(alice);
//     //     // assertEq(msg.sender, alice);

//     //     // (bool success, ) = address(vno_old).call{value: 3 ether}("");
//     //     console.log(success);
//     //     // payable(alice).call{value: 3 ether}("");
//     //     assertEq(alice.balance, 7);
//     //     console.log("And now alice's balance is:", alice.balance);
//     //     console.log("The balance of the vno_old is now:", address(vno_old).balance);
//     //     // assertEq(address(vno_old).balance, 3);
//     // }

//     //    function testAM() public {
//     //         uint256 num = 7;
//     //         uint256 tokenId_before_mint = vno_old.getCurrentTokenId();
//     //         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
//     //         vno_old.anotherMint(alice, num);
//     //         uint256 tokenId_after_mint = vno_old.getCurrentTokenId();
//     //         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
//     //         assertTrue(vno_old.ownerOf(tokenId_before_mint)==alice);
//     //         console.log("The owner of", tokenId_before_mint, "is", vno_old.ownerOf(tokenId_before_mint));
//     //         console.log("And the address of Alice is", alice);
//     //     }

//     //     // to test whether you get Minttime from AnotherMint
//     //     function testAMGetMinttimeFromTokenId () public {
//     //         uint256 time = 1641070800;
//     //         cheats.warp(time);
//     //         uint256 num = 10;
//     //         uint256 tokenId_before_mint = vno_old.getCurrentTokenId();
//     //         console.log("The tokenId before Alice minted a new token is:", tokenId_before_mint);
//     //         vno_old.anotherMint(alice, num);
//     //         uint256 tokenId_after_mint = vno_old.getCurrentTokenId();
//     //         console.log("The tokenId after Alice minting is:", tokenId_after_mint);
//     //         console.log("The token was minted at time", vno_old.getMinttimeFromTokenId(tokenId_before_mint));
//     //         assertTrue(vno_old.ownerOf(tokenId_before_mint)==alice);
//     //         assertTrue(vno_old.getMinttimeFromTokenId(tokenId_before_mint)==time);

//     //     }

//     //     // to test whether you can return the number from the tokenId

//     //     function testAMGetNumberFromTokenId() public {
//     //         uint256 num = 10;
//     //         uint256 tokenId_before_mint = vno_old.getCurrentTokenId();

//     //         vno_old.anotherMint(alice, num);

//     //         assertTrue(vno_old.ownerOf(tokenId_before_mint)==alice);
//     //         assertTrue(vno_old.getNumFromTokenId(tokenId_before_mint)==num);

//     //     }

//     //     // to test whether the time is recorded in the metadata of anotherMint

//     //     function testAMMintingSameNumAtDifferentTimes() public {
//     //         uint256 early = 1900000000;
//     //         uint256 later = 2000000000;
//     //         uint256 num = 10;

//     //         cheats.warp(early);

//     //         uint256 alice_tokenId = vno_old.getCurrentTokenId();
//     //         vno_old.anotherMint(alice, num);
//     //         console.log("The tokenId Alice minted is:", alice_tokenId, "at time:", vno_old.getMinttimeFromTokenId(alice_tokenId));

//     //         assertTrue(vno_old.getMinttimeFromTokenId(alice_tokenId)==early);

//     //         cheats.warp(later);

//     //         uint256 bob_tokenId = vno_old.getCurrentTokenId();

//     //         vno_old.anotherMint(bob, num);
//     //         console.log("The tokenId Bob minted is:", bob_tokenId, "at time:", vno_old.getMinttimeFromTokenId(bob_tokenId));

//     //         assertTrue(vno_old.ownerOf(alice_tokenId)==alice);
//     //         assertTrue(vno_old.getMinttimeFromTokenId(alice_tokenId) < vno_old.getMinttimeFromTokenId(bob_tokenId));
//     //         assertTrue(vno_old.getNumFromTokenId(alice_tokenId) == vno_old.getNumFromTokenId(bob_tokenId));
//     //     }

//     //     function testFirstMintsShouldHaveHigherOrdersThanLaterMints() public {
//     //         uint256 num = 7;
//     //         uint256 mint1  = 1;
//     //         uint256 mint2  = 2;
//     //         uint256 mint3  = 3;

//     //         cheats.warp(mint1);

//     //         uint256 alice_tokenId = vno_old.getCurrentTokenId();
//     //         vno_old.anotherMint(alice, num);
//     //         uint256 alice_mint_time = vno_old.getMinttimeFromTokenId(    alice_tokenId);
//     //         uint256 alice_token_num = vno_old.getNumFromTokenId(         alice_tokenId);

//     //         console.log("alice has minted:",                  alice_tokenId);
//     //         console.log("alice's token has number:",          alice_mint_time);
//     //         console.log("alice's token was minted at time:",  alice_token_num);

//     //         cheats.warp(mint2);

//     //         uint256 bob_tokenId = vno_old.getCurrentTokenId();
//     //         vno_old.anotherMint(bob, num);
//     //         uint256 bob_mint_time = vno_old.getMinttimeFromTokenId(      bob_tokenId);
//     //         uint256 bob_token_num = vno_old.getNumFromTokenId(           bob_tokenId);
//     //         console.log("bob has minted:",                   bob_tokenId);
//     //         console.log("bob's token has number:",           bob_token_num);
//     //         console.log("bob's token was minted at time:",   bob_mint_time);

//     //         cheats.warp(mint3);

//     //         uint256 candice_tokenId = vno_old.getCurrentTokenId();
//     //         vno_old.anotherMint(candice, num);
//     //         uint256 candice_mint_time = vno_old.getMinttimeFromTokenId(  candice_tokenId);
//     //         uint256 candice_token_num = vno_old.getNumFromTokenId(       candice_tokenId);
//     //         console.log("candice has minted:",                   candice_tokenId);
//     //         console.log("candice's token has number:",           candice_token_num);
//     //         console.log("candice's token was minted at time:",   candice_mint_time);

//     //         assertTrue(alice_token_num == num);
//     //         assertTrue(bob_token_num == num);
//     //         assertTrue(candice_token_num == num);
//     //         assertTrue(alice_token_num == bob_token_num && bob_token_num == candice_token_num);
//     //         assertTrue(alice_mint_time==mint1);
//     //         assertTrue(bob_mint_time==mint2);
//     //         assertTrue(candice_mint_time==mint3);
//     //         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);
//     //         assertTrue(alice_mint_time < bob_mint_time && bob_mint_time < candice_mint_time);

//     //         uint256 alice_order = vno_old.getOrderFromTokenId(alice_tokenId);
//     //         uint256 bob_order = vno_old.getOrderFromTokenId(bob_tokenId);
//     //         uint256 candice_order = vno_old.getOrderFromTokenId(candice_tokenId);

//     //         assertTrue(alice_order == 1);
//     //         assertTrue(bob_order == 2);
//     //         assertTrue(candice_order ==3);
//     //     }
// }
