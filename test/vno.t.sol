// https://github.com/foundry-rs/forge-std

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import {VNO} from "src/vno.sol";
// import {VNO_with_nestedStrings} from "../../src/vno-with-nested-strings.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {SharedFunctions} from "./sharedFunctions.sol";

contract VNO_Test is SharedFunctions {
    function test_make_zero() public {
        uint256 early = 1900000000;
        uint256 later = 2000000000;

        cheats.warp(early);
        uint256 tokenId_before_mint = vno.currentId();
        uint256 alice_token_id = vno.currentId() + 1;
        console.log(
            "The tokenId before Alice minted a new token is:",
            tokenId_before_mint
        );

        assertTrue(!vno.universalExists(0));
        console.log("alice is:", alice);
        hoax(alice);
        vno.mintZero{value: 10 ether}();

        assertTrue(vno.universalExists(0));

        assertTrue(vno.ownerOf(vno.currentId()) == alice);

        uint256 aliceNumber = getUniversalFromTokenId(alice_token_id).number;
        uint256 aliceInstances = getUniversalFromTokenId(alice_token_id)
            .instances;

        (, uint256 aliceMintTime, uint256 aliceOrder, , , ) = vno
            .tokenId_to_metadata(alice_token_id);

        assertEq(aliceNumber, 0);
        assertEq(aliceInstances, 1);
        assertEq(aliceMintTime, early);
        assertEq(aliceOrder, 1);

        cheats.warp(later);
        console.log("The time now is", block.timestamp);
        console.log(
            "The owner of",
            alice_token_id,
            "is",
            vno.ownerOf(alice_token_id)
        );
        console.log("And the address of Alice is", alice);
        console.log("The number minted is", aliceNumber);
        console.log("of which there are instances:", aliceInstances);
        console.log("it was minted at mint time:", aliceMintTime);
        console.log("the order was:", aliceOrder);

        console.log(vno.universalExists(0));

        uint256 bobTokenId = vno.currentId() + 1;

        hoax(bob);
        vno.mintZero();

        uint256 bobNumber = getNumberFromTokenId(bobTokenId);
        uint256 bobInstance = getUniversalFromTokenId(bobTokenId).instances;
        (, uint256 bobMintTime, uint256 bobOrder, , , ) = vno
            .tokenId_to_metadata(bobTokenId);

        assertEq(bobNumber, 0);
        assertEq(bobInstance, 2);
        assertEq(bobMintTime, later);
        assertEq(bobOrder, 2);

        console.log("The time now is", block.timestamp);
        console.log("The owner of", bobTokenId, "is", vno.ownerOf(bobTokenId));
        console.log("And the address of Bob is", bob);
        console.log("The number minted is", bobNumber);
        console.log("of which there are instances:", bobInstance);
        console.log("it was minted at mint time:", bobMintTime);
        console.log("the order was:", bobOrder);
    }

    function test_mint_via_succession() public {
        hoax(alice); // pretend it's alice calling the functions
        uint256 oldAliceBalance = alice.balance; // record alice's old balance
        console.log(oldAliceBalance);

        uint256 zeroTokenId = vno.currentId() + 1; // the current tokenId will be the id of the zeroToke

        hoax(alice);
        vno.mintZero(); // make Zero and give it to alice
        assertTrue(vno.isUniversal(zeroTokenId)); // check if the zeroTokenId is indeed a Universal

        assertTrue(vno.ownerOf(zeroTokenId) == alice); // check if alice owns the token
        hoax(alice);
        uint256 oneTokenId = vno.mintBySuccession(zeroTokenId); // we will be minting the successor of zero, we are now recording the tokenId
        assertTrue(vno.isUniversal(oneTokenId)); // given it is the first token to be minted of the number one, it should be a universal
        assertTrue(vno.ownerOf(oneTokenId) == alice); // it should belong to alice
        assertTrue(getNumberFromTokenId(oneTokenId) == 1); // it should belong to alice
        hoax(alice);
        uint256 anotherOneTokenId = vno.mintBySuccession(zeroTokenId); // we now mint another token of number One
        assertTrue(!vno.isUniversal(anotherOneTokenId)); // it shouldn't be a universal
        assertTrue(vno.ownerOf(anotherOneTokenId) == alice); // it should belong to alice
        uint256 newAliceBalance = alice.balance; // since it was minted via the successor function, alice should have paid nothing
        console.log(newAliceBalance);
        assertEq(oldAliceBalance, newAliceBalance);

        hoax(bob); //now let us pretend bob is calling the functions
        uint256 oldBobBalance = bob.balance; // record bob's balance
        uint256 bobMintOneTokenId = vno.currentId(); // getting the tokenId in which bob minted
        hoax(bob);
        uint256 bobzerotokenid = vno.mintZero(); // for bob to mint the successor of one, he has to mint a zero first
        hoax(bob);
        uint256 bobOneTokenId = vno.mintBySuccession(bobzerotokenid); // bob mints a successor of one
        assertTrue(!vno.isUniversal(bobOneTokenId)); // the minted successor of zero should not be a universal
        assertTrue(vno.ownerOf(bobOneTokenId) == bob); // bob should be the owner of the token
        assertTrue(oldBobBalance == bob.balance); // bob's balance should not have been reduced

        hoax(bob);
        vno.safeTransferFrom(bob, alice, bobOneTokenId);
        assertEq(vno.ownerOf(bobOneTokenId), alice);
        hoax(alice);
        uint256 twoTokenId = vno.mintBySuccession(bobOneTokenId); // we will be minting the successor of one, we are now recording the tokenId
        assertTrue(vno.isUniversal(twoTokenId)); // given it is the first token to be minted of the number two, it should be a universal
        assertTrue(vno.ownerOf(twoTokenId) == alice); // it should belong to alice
        assertTrue(getNumberFromTokenId(twoTokenId) == 2); // it should belong to alice
    }

    function test_mint_via_direct() public {
        // To test this, you need to make a lot of numbers first
        hoax(alice);
        uint256 zeroTokenId = vno.mintZero();
        hoax(alice);
        uint256 oneTokenId = vno.mintBySuccession(zeroTokenId);
        hoax(alice);
        uint256 twoTokenId = vno.mintBySuccession(oneTokenId);

        hoax(bob);
        uint256 oldBobBalance = bob.balance;
        uint256 directMintTokenId = vno.mintByDirect{value: 0}(2); // Tax has not been set
        assertTrue(!vno.isUniversal(directMintTokenId));
        assertTrue(!vno.isUniversal(directMintTokenId));
    }

    function testMintViaAddition() public {
        // To test this, you need to make a lot of numbers first

        assertTrue(!vno.universalExists(0));
        hoax(alice);
        uint256 zeroTokenId = vno.mintZero();
        console.log(zeroTokenId);
        assertTrue(vno.universalExists(0));
        assertTrue(vno.isUniversal(zeroTokenId));
        hoax(alice);
        uint256 oneTokenId = vno.mintBySuccession(zeroTokenId);
        hoax(alice);
        uint256 twoTokenId = vno.mintBySuccession(oneTokenId);
        hoax(alice);
        uint256 threeTokenId = vno.mintByAddition(oneTokenId, twoTokenId); // minting by addition
        hoax(alice);
        uint256 anotherThreeTokenId = vno.mintByAddition(
            twoTokenId,
            oneTokenId
        ); // this is possible because both one and two should be universals

        assertTrue(vno.isUniversal(oneTokenId));

        assertTrue(vno.isUniversal(twoTokenId));
        assertTrue(vno.isUniversal(threeTokenId));
        assertTrue(!vno.isUniversal(anotherThreeTokenId));

        assertEq(
            getNumberFromTokenId(threeTokenId),
            getNumberFromTokenId(anotherThreeTokenId)
        );

        // hoax(bob);
    }

    function test_mint_via_multiplication() public {
        // To test this, you need to make a lot of numbers first

        assertTrue(!vno.universalExists(0));
        hoax(alice);
        uint256 zeroTokenId = vno.mintZero();
        console.log(zeroTokenId);
        assertTrue(vno.universalExists(0));
        assertTrue(vno.isUniversal(zeroTokenId));
        hoax(alice);
        uint256 oneTokenId = vno.mintBySuccession(zeroTokenId);
        hoax(alice);
        uint256 twoTokenId = vno.mintBySuccession(oneTokenId);
        hoax(alice);
        uint256 threeTokenId = vno.mintByAddition(oneTokenId, twoTokenId); // minting by addition
        hoax(alice);
        uint256 anotherThreeTokenId = vno.mintByAddition(
            twoTokenId,
            oneTokenId
        ); // this is possible because both one and two should be universals

        hoax(alice);
        uint256 nineTokenId = vno.mintByMultiplication(
            anotherThreeTokenId,
            threeTokenId
        ); // this is possible because both one and two should be universals

        assertTrue(vno.isUniversal(nineTokenId));
    }

    function test_mint_via_exponentiation() public {
        // To test this, you need to make a lot of numbers first

        assertTrue(!vno.universalExists(0));
        hoax(alice);
        uint256 id0_1 = vno.mintZero();
        assertTrue(vno.universalExists(0));
        assertTrue(vno.isUniversal(id0_1));
        hoax(alice);
        uint256 id1_1 = vno.mintBySuccession(id0_1);
        hoax(alice);
        uint256 id2_1 = vno.mintBySuccession(id1_1);
        hoax(alice);
        uint256 id3_1 = vno.mintBySuccession(id2_1);

        hoax(alice);
        uint256 id2_2 = vno.mintByDirect(2);
        hoax(alice);
        uint256 id3_2 = vno.mintByDirect(3);
        hoax(bob);
        uint256 id2_3 = vno.mintByDirect(2);
        hoax(bob);
        uint256 id3_3 = vno.mintByDirect(3);
        hoax(alice);
        uint256 id8_1 = vno.mintByExponentiation(id2_2, id3_2);
        assertTrue(vno.isUniversal(id8_1));
        assertEq(getNumberFromTokenId(id8_1), 8);
        hoax(bob);
        uint256 id8_2 = vno.mintByExponentiation(id2_3, id3_3);

        assertEq(getNumberFromTokenId(id8_1), getNumberFromTokenId(id8_2));
        assertEq(getNumberFromTokenId(id8_2), 8);
    }

    function test_mint_via_subtraction() public {
        assertTrue(!vno.universalExists(0));
        hoax(alice);
        uint256 id0_1 = vno.mintZero();

        assertTrue(vno.universalExists(0));
        assertTrue(vno.isUniversal(id0_1));
        hoax(alice);
        uint256 id1_1 = vno.mintBySuccession(id0_1);
        hoax(alice);
        uint256 id2_1 = vno.mintBySuccession(id1_1);
        hoax(alice);
        uint256 id3_1 = vno.mintBySuccession(id2_1);

        hoax(alice);
        uint256 id3_2 = vno.mintByDirect(3);
        hoax(alice);
        uint256 id3_3 = vno.mintByDirect(3);
        hoax(alice);
        uint256 id3_4 = vno.mintByDirect(3);

        hoax(alice);
        uint256 id27_1 = vno.mintByExponentiation(id3_2, id3_3);
        hoax(alice);
        uint256 id19683_1 = vno.mintByExponentiation(id27_1, id3_4);

        assertTrue(vno.isUniversal(id27_1));
        assertTrue(vno.isUniversal(id19683_1));
        assertEq(getNumberFromTokenId(id27_1), 27);
        assertEq(getNumberFromTokenId(id19683_1), 19683);

        hoax(alice);
        uint256 id19682_1 = vno.mintBySubtraction(id19683_1, id1_1);

        assertEq(getNumberFromTokenId(id19682_1), 19682);
        assertTrue(vno.isUniversal(id19682_1));

        hoax(alice);
        uint256 id27_2 = vno.mintByDirect(27);
        hoax(alice);
        uint256 id1_2 = vno.mintByDirect(1);
        hoax(alice);
        vm.expectRevert(VNO.NoNegativeNumbers.selector);
        uint256 strange = vno.mintBySubtraction(id1_2, id27_2);
    }

    function test_set_universal_tax() public {
        uint256 uid = make_universal(2, alice, alice);
        console.log("uid is", uid);
        assertEq(getNumberFromTokenId(uid), 2);
        assertEq(vno.ownerOf(uid), alice);
        uint256 tax = 7;

        hoax(alice);
        vno.setDirectMintTax(2, tax);

        assertEq(get_tax_from_universal(2), tax);

        startHoax(carol, 10000000);
        uint256 oldcarolBalance = carol.balance;
        console.log("carol's balance is:", oldcarolBalance);

        vno.mintByDirect{value: 100}(2);

        assertEq(carol.balance, oldcarolBalance - tax);
    }

    function test_repeatedly_setting_universal_tax() public {
        uint256 uid = make_universal(2, alice, alice);

        uint256 tax = 1000;
        console.log(get_tax_from_universal(2));
        hoax(alice);
        vno.setDirectMintTax(2, tax);
        assertEq(get_tax_from_universal(2), tax);
        assertEq(vno.ownerOf(get_tokenId_from_universal(2)), alice);
        assertTrue(getNumberFromTokenId(uid) == 2);
        assertTrue(vno.isUniversal(uid));
        //
        hoax(carol, 1 ether);
        uint256 oldcarolBalance = carol.balance;
        console.log("carol's old balance is:", oldcarolBalance);

        vno.mintByDirect{value: 1 ether}(2);

        assertEq(carol.balance, oldcarolBalance - tax);
        console.log("carol's new balance is:", oldcarolBalance);
        //
        hoax(alice);
        // setting the tax back to 0;
        vno.setDirectMintTax(2, 0);
        assertEq(get_tax_from_universal(2), 0);

        hoax(alice);
        // alice transfer the universal to bob
        vno.safeTransferFrom(alice, bob, uid);
        assertEq(vno.ownerOf(get_tokenId_from_universal(2)), bob);

        uint256 new_tax = 900;
        hoax(bob);
        vno.setDirectMintTax(2, new_tax);
        assertEq(get_tax_from_universal(2), new_tax);
    }

    function test_withdraw_from_universal() public {
        uint256 u = 23;
        uint256 uid = make_universal(u, alice, alice);
        uint256 id1 = make_particular(3, alice, alice);
        // uint256 id2 = make_particular(7, alice, alice);
        hoax(alice);
        uint256 id3 = vno.mintByDirect(3);
        console.log(getNumberFromTokenId(id3));

        uint256 tax = 1000;
        assertEq(vno.ownerOf(uid), alice);
        //  alice can set tax
        hoax(alice);
        vno.setDirectMintTax(23, tax);

        assertEq(get_tax_from_universal(23), tax);
        // some random dude minting a lot to pay fees to Alice.
        for (uint256 i = 0; i <= 100; i++) {
            hoax(bob);
            vno.mintByDirect{value: 100 ether}(u);
        }
        uint256 balance = get_balance_from_universal(u);
        assertTrue(balance != 0);
        console.log("The balance for the universal 23 is:", balance);

        hoax(alice, 10000);

        // // alice can withdraw
        vno.withdrawFromUniversal(u);
        assertTrue(get_balance_from_universal(u) == 0);
        assertEq(alice.balance, 10000 + balance);
    }

    // function test_withdraw_from_universal() public {
    //     uint256 uid = make_universal(23, alice, alice);
    //     uint256 id1 = make_particular(3, alice, alice);
    //     uint256 id2 = make_particular(7, alice, alice);
    //     hoax(alice);
    //     uint256 id3 = vno.mintByDirect(3);
    //     console.log(getNumberFromTokenId(id3));

    //     uint256 tax = 1000;
    //     assertEq(vno.ownerOf(uid), alice);
    //     //  alice can set tax
    //     hoax(alice);
    //     vno.setDirectMintTax(23, id1, tax);

    //     assertEq(get_tax_from_universal(23), tax);
    //     // some random dude minting a lot to pay fees to Alice.
    //     for (uint256 i = 0; i <= 100; i++) {
    //         hoax(bob);
    //         vno.mintByDirect{value: 100 ether}(23);
    //     }
    //     uint256 balance = get_balance_from_universal(23);
    //     assertTrue(balance != 0);
    //     console.log("The balance for the universal 23 is:", balance);

    //     hoax(alice, 10000);
    //     // // alice can withdraw
    //     vno.withdrawUniversalOwnerBalance(23, id2, id3);
    //     assertTrue(get_balance_from_universal(23) == 0);
    //     assertEq(alice.balance, 10000 + balance);
    // }

    //  This tests whether the contract can successfully withdraw funds from a universal wallet and reset the tax after a transfer of ownership. The test function does the following:

    // 1. Creates a new universal wallet with ID 23 and assigns it to the address "alice".
    // 2. Sets a direct mint tax of 1000 on the newly created universal wallet.
    // 3. Mints three new tokens with IDs id1, id2, and id3.
    // 4. Randomly mints 100 new tokens and sends them to the universal wallet to pay fees to Alice.
    // 5. Alice withdraws the balance of the universal wallet by transferring it to ids id2 and id3.
    // 6. Alice transfers ownership of the universal wallet to "carol".
    // 7. Carol sets a new direct mint tax of 200 on the universal wallet.
    // 8. Randomly mints 100 new tokens and sends them to the universal wallet to pay fees to Carol.
    // 9. Carol withdraws the balance of the universal wallet by transferring it to ids id5 and id6.
    // 10. Asserts that the balance of the universal wallet is zero after both withdrawals.
    // 11. Asserts that the balance of Carol's account is equal to the balance of the universal wallet plus an additional 10000 wei.
    function test_can_withdraw_from_universal_and_reset_tax_after_transfer()
        public
    {
        uint256 u = 23;
        uint256 uid = make_universal(u, alice, alice);
        hoax(alice);
        uint256 id1 = vno.mintByDirect(3);
        hoax(alice);
        uint256 id2 = vno.mintByDirect(7);
        hoax(alice);
        uint256 id3 = vno.mintByDirect(3);

        uint256 tax = 1000;
        assertEq(vno.ownerOf(uid), alice);
        //  alice can set tax
        hoax(alice);
        vno.setDirectMintTax(u, tax);

        assertEq(get_tax_from_universal(u), tax);
        // some random dude minting a lot to pay fees to Alice.
        for (uint256 i = 0; i <= 100; i++) {
            hoax(bob);
            vno.mintByDirect{value: 100 ether}(u);
        }
        uint256 balance = get_balance_from_universal(u);
        assertTrue(balance != 0);
        console.log("The balance for the universal 23 is:", balance);

        hoax(alice);
        // alice can withdraw
        vno.withdrawFromUniversal(u);
        console.log("Alice withdrawing:", balance);
        assertTrue(get_balance_from_universal(u) == 0);
        console.log("Balance left now:", get_balance_from_universal(u));

        // suppose alice transfers the token to carol
        hoax(alice);
        vno.safeTransferFrom(alice, carol, uid);
        assertEq(vno.ownerOf(uid), carol);

        hoax(carol);
        uint256 id4 = vno.mintByDirect(7);
        hoax(carol);
        uint256 id5 = vno.mintByDirect(3);
        hoax(carol);
        uint256 id6 = vno.mintByDirect(7);

        uint256 newTax = 200;
        hoax(carol);
        vno.setDirectMintTax(u, newTax);
        assertEq(get_tax_from_universal(u), newTax);

        // some random dude minting a lot to pay fees to carol
        for (uint256 i = 0; i <= 100; i++) {
            hoax(bob);
            vno.mintByDirect{value: 100 ether}(u);
        }
        uint256 newBalance = get_balance_from_universal(u);
        assertTrue(newBalance != 0);
        console.log("The balance for the universal 23 is:", newBalance);
        startHoax(carol, 10000);
        // // carol can withdraw
        console.log("Carol withdrawing:", newBalance);
        vno.withdrawFromUniversal(u);
        console.log("Balance left now:", get_balance_from_universal(u));
        assertTrue(get_balance_from_universal(u) == 0);
        assertEq(carol.balance, 10000 + newBalance);
    }

    function test_get_factorisation_from_universal() public {
        uint256 n = 2 ** 5 * 3 ** 2 * 7; // 2016
        uint256 universal_id = make_universal(n, alice, bob); // 2016
        uint256[] memory factorisation = vno.factorise(n);

        uint256[] memory primes = getUniversalFromTokenId(universal_id).primes;
        for (uint256 i; i < primes.length; i++) {
            assertEq(factorisation[i], primes[i]);
            console.log("prime", i, primes[i]);
        }
    }

    function test_get_factorisation_from_particular() public {
        uint256 n = 2 ** 5 * 3 ** 2 * 7; // 2016
        uint256 particular_id = make_particular(n, alice, bob);
        uint256[] memory factorisation = vno.factorise(n);
        uint256[] memory primes = getUniversalFromTokenId(particular_id).primes;
        for (uint256 i; i < primes.length; i++) {
            assertEq(factorisation[i], primes[i]);
        }
    }

    function test_draw_Universal() public {
        uint256 n = 2 ** 5 * 7 ** 2;
        uint256 universal_id = make_universal(n, alice, bob);
        string memory image = vno.drawUniversal(n);
        console.log(image);
    }

    function test_gas_universal() public {
        // uint256 n = 2 ** 5 * 3 * 7; //672
        uint256 n1 = 1;
        uint256 n2 = 2;
        uint256 n3 = 2 * 3 * 5 * 7 * 11 * 13;
        uint256 threeHundredEth = 1000; //gwei

        // uint256 n3 = 2 ** 5 * 3 ** 2 * 7 * 11 * 13;
        // make_universal(2 * 3 * 5, alice, bob);

        make_universal(threeHundredEth, alice, bob);
        // make_universal(n3, alice, bob);
        // vno.factorise(n3);
        string memory image = vno.drawUniversal(threeHundredEth);
        console.log(image);
        console.log("three hundred Eth is:", threeHundredEth);
        // uint256 id1 = make_universal(n1, alice, bob);
        // string memory image = vno.drawUniversal(n1);
        // VNO.Universal memory u1 = getUniversalFromTokenId(id1);
        // uint256[] memory p1 = u1.primes;
        // for (uint256 i; i < p1.length; i++) {
        //     console.log("factor", i, p1[i]);
        // }

        // uint256 id2 = make_universal(n2, alice, bob);
        // VNO.Universal memory u2 = getUniversalFromTokenId(id2);
        // uint256[] memory p2 = u2.primes;
        // for (uint256 i; i < p2.length; i++) {
        //     console.log("factor", i, p2[i]);
        // }
        // make_universal(3, alice, bob);

        // make_universal(5 * 7, alice, bob);

        // uint256 id3 = make_universal(n3, alice, bob);
        // VNO.Universal memory u3 = getUniversalFromTokenId(id3);
        // uint256[] memory p3 = u3.primes;
        // for (uint256 i; i < p3.length; i++) {
        //     console.log("factor", i, p3[i]);
        // }
    }

    function test_set_mint_by_succession_fee() public {
        assertEq(vno.mintBySuccessionFee(), 0);
        hoax(owner_of_vno);
        vno.set_mint_by_succession_fee(550000000000000000 wei);
        assertEq(vno.mintBySuccessionFee(), 550000000000000000);
    }

    function test_set_mint_by_addition_tax() public {
        uint256 id = make_particular(12, alice, alice);
        assertEq(vno.ownerOf(id), alice);
        uint256 id_30 = make_particular(30, alice, alice);
        uint256 id_90 = make_particular(90, alice, alice);
        hoax(alice);
        vno.setMintByAdditionTax(12, id_30, id_90);
        assertEq(vno.universal_to_additionTax(12), (30 + 90) * 10000000000000);
        console.log(vno.universal_to_additionTax(12), "mint by addition tax");

        uint256 id_5 = make_particular(5, bob, bob);
        uint256 id_7 = make_particular(7, bob, bob);
        hoax(bob);
        uint256 id_12 = vno.mintByAddition{value: 1 ether}(id_5, id_7);
        assertEq(get_balance_from_universal(12), (30 + 90) * 10000000000000);
    }

    function test_set_cut() public {
        uint256 id = make_particular(12, alice, alice);
        assertEq(vno.ownerOf(id), alice);
        uint256 id_30 = make_particular(30, alice, alice);
        uint256 id_90 = make_particular(90, alice, alice);
        hoax(alice);
        vno.setMintByAdditionTax(12, id_30, id_90);
        assertEq(vno.universal_to_additionTax(12), (30 + 90) * 10000000000000);
        console.log(vno.universal_to_additionTax(12), "mint by addition tax");
        hoax(owner_of_vno);
        uint256 cut = 100;
        vno.setCut(cut); // 1 %
        uint256 id_5 = make_particular(5, bob, bob);
        uint256 id_7 = make_particular(7, bob, bob);
        hoax(bob);
        uint256 id_12 = vno.mintByAddition{value: 1 ether}(id_5, id_7);
        assertEq(
            get_balance_from_universal(12),
            ((30 + 90) * 10000000000000 * (1000000 - cut)) / 1000000
        );

        // assertEq(
        //     vno.treasuryBalance(),
        //     ((30 + 90) * 10000000000000 * (cut) * 20) / (100 * 1000000)
        // );
        // for (uint256 i = 0; i < vno.currentId(); i++) {
        //     if (vno.tokenId_active(i) && !vno.isUniversal(i)) {
        //         console.log(
        //             "particular holder of id",
        //             i,
        //             vno.tokenId_to_balances(i)
        //         );
        //     }
        // }
    }
    // https://vomtom.at/solidity-0-6-4-and-call-value-curly-brackets/

    // function testDrawByPowers() public {
    //     string memory image = vno.drawByPowers(1);
    //     console.log(image);
    // }

    // function testFactorise() public {
    //     uint256 num = 49;
    //     uint256[] memory factors = vno.factorise(num);
    //     // uint256[] memory draw = vno.num_to_universal(num).primes();

    //     string memory factorString = "";
    //     // string memory drawString = "";

    //     for (uint256 i = 0; i < factors.length; i++) {
    //         factorString = string(
    //             abi.encodePacked(
    //                 factorString,
    //                 Strings.toString(factors[i]),
    //                 ","
    //             )
    //         );
    //     }
    //     // for (uint256 i = 0; i < draw.length; i++) {
    //     //     drawString = string(
    //     //         abi.encodePacked(factorString, Strings.toString(draw[i]), ",")
    //     //     );
    //     // }
    //     console.log(factorString);

    //     // console.log(drawString);

    //     // string memory image = vno.draw(49);
    //     // console.log(image);
    // }

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
