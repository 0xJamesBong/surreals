// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.2;

// import "openzeppelin-contracts/contracts/access/Ownable.sol";
// import "solmate/utils/ReentrancyGuard.sol";
// import "openzeppelin-contracts/contracts/utils/Strings.sol";
// import "solmate/tokens/ERC721.sol";
// import "solmate/utils/LibString.sol";
// import "forge-std/console.sol";
// import "abdk/ABDKMathQuad.sol";
// import {SD59x18, sd, ln, div, unwrap, mul, ceil, floor, sqrt} from "prb-math/SD59x18.sol";

// // import {SD59x18, sd, ln, div, unwrap, mul, ceil, floor} from "prb-math/SD59x18.sol";

// // import "@openzeppelin/contracts/access/Ownable.sol";
// // import "@openzeppelin/contracts/utils/Counters.sol";
// // import {ReentrancyGuard} from "lib/solmate/src/utils/ReentrancyGuard.sol";
// // import "@openzeppelin/contracts/utils/Strings.sol";
// // import {ERC721} from "lib/solmate/src/tokens/ERC721.sol";
// // import {LibString} from "lib/solmate/src/utils/LibString.sol";
// // // import '../lib/forge-std/lib/ds-test/src/console.sol';
// // import "../lib/forge-std/src/console.sol";
// // import "../lib/abdk/ABDKMathQuad.sol";

// contract VNO_with_nestedStrings is ERC721, Ownable, ReentrancyGuard {
//     using LibString for *;
//     using ABDKMathQuad for *;

//     function _burn(uint256 id) internal override {
//         address owner = _ownerOf[id];

//         require(owner != address(0), "NOT_MINTED");
//         require(!isUniversal(id), "Universals cannot be burnt!");

//         // Ownership check above ensures no underflow.
//         unchecked {
//             _balanceOf[owner]--;
//         }

//         delete _ownerOf[id];

//         delete getApproved[id];

//         emit Transfer(owner, address(0), id);
//     }

//     ///@notice id of current ERC721 being minted
//     uint256 public currentId;

//     address public tax_avoidance_address;

//     function set_tax_avoidance_address(
//         address nftCollection
//     ) public onlyOwner returns (bool) {
//         tax_avoidance_address = nftCollection;
//     }

//     // Counters.Counter private _tokenIdCounter;

//     constructor() ERC721("Number", "Num") {}

//     //////////////////////////////////////////////////////////////////////////////////////////
//     // String Manipulations
//     ////////////////////////////////////////////////su//////////////////////////////////////////

//     function substring(
//         string memory str,
//         uint256 startIndex,
//         uint256 endIndex
//     ) public pure returns (string memory) {
//         bytes memory strBytes = bytes(str);
//         bytes memory result = new bytes(endIndex - startIndex);
//         for (uint256 i = startIndex; i < endIndex; i++) {
//             result[i - startIndex] = strBytes[i];
//         }
//         return string(result);
//     }

//     // https://ethereum.stackexchange.com/questions/13862/is-it-possible-to-check-string-variables-length-inside-the-contract
//     function utfStringLength(
//         string memory str
//     ) public pure returns (uint256 length) {
//         uint256 i = 0;
//         bytes memory string_rep = bytes(str);

//         while (i < string_rep.length) {
//             if (string_rep[i] >> 7 == 0) i += 1;
//             else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
//             else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
//             else if (string_rep[i] >> 3 == bytes1(uint8(0x1E)))
//                 i += 4;
//                 //For safety
//             else i += 1;
//             length++;
//         }
//     }

//     function isNestedString(
//         string memory where
//     ) public pure returns (bool, uint256 numL, uint256 numR) {
//         // https://ethereum.stackexchange.com/questions/69307/find-word-in-string-solidity
//         bytes memory whereBytes = bytes(where);
//         bool legal = true;
//         uint256 numL = 0;
//         uint256 numR = 0;
//         for (uint256 i = 0; i <= whereBytes.length - 1; i++) {
//             bool flag = false;
//             // recording the number of left and right brackets
//             if (whereBytes[i] == "{") {
//                 numL += 1;
//             } else if (whereBytes[i] == "}") {
//                 numR += 1;
//             }
//             if (whereBytes[i] != "{" && whereBytes[i] != "}") {
//                 flag = true;
//             }

//             if (
//                 i + 1 != whereBytes.length &&
//                 whereBytes[i] == "}" &&
//                 whereBytes[i + 1] == "{"
//             ) {
//                 flag = true;
//             }
//             // if any one flag is raised, break loop
//             if (flag) {
//                 legal = false;
//                 break;
//             }
//         }
//         if (numL != numR) {
//             legal = false;
//         }
//         return (legal, numL, numR);
//     }

//     function stringsEq(
//         string memory str1,
//         string memory str2
//     ) public pure returns (bool) {
//         bytes32 compareStr1 = keccak256(abi.encodePacked(str1));
//         bytes32 compareStr2 = keccak256(abi.encodePacked(str2));
//         return (compareStr1 == compareStr2);
//     }

//     function isSubstring(
//         string memory str1,
//         string memory str2
//     ) public pure returns (bool) {
//         // Only determines if nestedSet 1 is a substring of nestedSet2
//         // I don"t care about the other way around
//         // proper substrings only
//         // This function relies on the fact that we have already checked they"re legal strings
//         // Which enables the iff that isSubstring(nestedSet1, nestedSet2) == true iff nestedSet1 < nestedSet2 as numbers.
//         (bool isStr1, , ) = isNestedString(str1);
//         (bool isStr2, , ) = isNestedString(str2);
//         require(isStr1 == true, "nestedSet1 is not legal nested substring");
//         require(isStr2 == true, "nestedSet2 is not legal nested substring");
//         return (utfStringLength(str1) < utfStringLength(str2));
//     }

//     function successorString(
//         string memory nestedSet
//     ) public returns (string memory successor) {
//         (bool isNestedString, , ) = isNestedString(nestedSet);
//         require(isNestedString == true, "nestedSet is not legal nested string");
//         bytes memory predecessor = abi.encodePacked(nestedSet);
//         string memory successorString = string(
//             abi.encodePacked("{", predecessor, "}")
//         );
//         return successorString;
//     }

//     function predecessorString(
//         string memory nestedSet
//     ) public returns (string memory predecessor) {
//         (bool isNestedString, , ) = isNestedString(nestedSet);
//         require(isNestedString == true, "nestedSet is not legal nested string");
//         bytes memory thisNestedSet = abi.encodePacked(nestedSet);
//         string memory predecessorString = (
//             (keccak256(thisNestedSet) == keccak256(abi.encodePacked(emptyset)))
//                 ? emptyset
//                 : string(
//                     abi.encodePacked(
//                         substring(nestedSet, 1, utfStringLength(nestedSet) - 1)
//                     )
//                 )
//         );
//         return predecessorString;
//     }

//     string emptyset = "{}";
//     string one = "{{}}";
//     string predecessorOfZero = "{}";

//     function addNestedSets(
//         string memory nestedSet1,
//         string memory nestedSet2
//     ) public returns (string memory addedNestedSet) {
//         (bool isNestedString1, , ) = isNestedString(nestedSet1);
//         (bool isNestedString2, , ) = isNestedString(nestedSet2);
//         require(
//             isNestedString1 == true,
//             "nestedSet1 is not legal nested string"
//         );
//         require(
//             isNestedString2 == true,
//             "nestedSet2 is not legal nested string"
//         );

//         bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
//         bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
//         bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
//         bytes32 compareOne = keccak256(abi.encodePacked(one));
//         uint256 nestedSet1Length = utfStringLength(nestedSet1);

//         if (
//             stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)
//         ) {
//             // if either one is 0
//             if (stringsEq(nestedSet1, emptyset) == false) {
//                 return nestedSet1;
//             } else if (stringsEq(nestedSet2, emptyset) == false) {
//                 return nestedSet2;
//             } else {
//                 return emptyset;
//             }
//         } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
//             if (stringsEq(nestedSet1, one) == false) {
//                 return successorString(nestedSet1);
//             } else if (stringsEq(nestedSet2, one) == false) {
//                 return successorString(nestedSet2);
//             } else {
//                 return successorString(nestedSet1);
//             }
//         } else {
//             string memory substring1 = substring(
//                 nestedSet1,
//                 0,
//                 nestedSet1Length / 2 - 1
//             );
//             string memory substring2 = substring(
//                 nestedSet1,
//                 nestedSet1Length / 2,
//                 nestedSet1Length - 1
//             );

//             // concatenating the three strings together, sandwiching the successor of nestedSet2 with the two substrings obtained from nestedSet1
//             return
//                 predecessorString(
//                     string(
//                         abi.encodePacked(
//                             abi.encodePacked(
//                                 substring1,
//                                 successorString(nestedSet2)
//                             ),
//                             substring2
//                         )
//                     )
//                 );
//         }
//     }

//     // Subtraction is defined as such:
//     // For any x, x-x =0, S(x)-n = S(x-n), S() being 'successor of'
//     // Note that we are careful not to produce negative numbers - this we do by require the subtrahend is a substring of the minuend
//     // for the expression a - b, a = minuend, b = subtrahend
//     function subtractNestedSets(
//         string memory minuend,
//         string memory subtrahend
//     ) public returns (string memory addedNestedSet) {
//         (bool isNestedString1, , ) = isNestedString(minuend);
//         (bool isNestedString2, , ) = isNestedString(subtrahend);
//         require(
//             isNestedString1 == true,
//             "nestedSet1 is not legal nested string"
//         );
//         require(
//             isNestedString2 == true,
//             "nestedSet2 is not legal nested string"
//         );
//         require(
//             isSubstring(subtrahend, minuend) == true ||
//                 stringsEq(minuend, subtrahend),
//             "the subtrahend is bigger than the minuend. You need to extend this number system to the integers to do that."
//         );
//         string memory result = (
//             (stringsEq(minuend, subtrahend))
//                 ? emptyset
//                 : successorString(
//                     subtractNestedSets(predecessorString(minuend), subtrahend)
//                 )
//         );
//         return result;
//     }

//     // Multiplication is defined as such:
//     // For any a, b, a * 0 = 0, a * S(b) = a * b + a

//     function multiplyNestedSets(
//         string memory nestedSet1,
//         string memory nestedSet2
//     ) public returns (string memory addedNestedSet) {
//         (bool isNestedString1, , ) = isNestedString(nestedSet1);
//         (bool isNestedString2, , ) = isNestedString(nestedSet2);
//         require(
//             isNestedString1 == true,
//             "nestedSet1 is not legal nested string"
//         );
//         require(
//             isNestedString2 == true,
//             "nestedSet2 is not legal nested string"
//         );

//         bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
//         bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
//         bytes32 compareEmptySet = keccak256(abi.encodePacked(emptyset));
//         bytes32 compareOne = keccak256(abi.encodePacked(one));
//         if (
//             stringsEq(nestedSet1, emptyset) || stringsEq(nestedSet2, emptyset)
//         ) {
//             return emptyset;
//         } else if (stringsEq(nestedSet1, one) || stringsEq(nestedSet2, one)) {
//             string memory result = (
//                 (stringsEq(nestedSet1, one)) ? nestedSet2 : nestedSet1
//             );
//             return result;
//         } else if (
//             isSubstring(nestedSet1, nestedSet2) ||
//             stringsEq(nestedSet1, nestedSet2)
//         ) {
//             return
//                 addNestedSets(
//                     multiplyNestedSets(
//                         nestedSet2,
//                         predecessorString(nestedSet1)
//                     ),
//                     nestedSet2
//                 );
//         } else {
//             return
//                 addNestedSets(
//                     multiplyNestedSets(
//                         nestedSet1,
//                         predecessorString(nestedSet2)
//                     ),
//                     nestedSet1
//                 );
//         }
//     }

//     // Exponentiation is defined as such:
//     // for any numbers a,b
//     // a ^ b = a * a ^ P(b), P() being 'predecessor of'
//     function exponentiateNestedSets(
//         string memory base,
//         string memory exponent
//     ) public returns (string memory addedNestedSet) {
//         // revert if exponent is zero
//         // Although a  ^ 0 == 1 is common knowledge; the proof implicitly assumes the existence of a multiplicative inverse of a, which we do not in this construction of the natural numbers
//         // Therefore, exponentiation here is purely a computational shortcut
//         require(!stringsEq(exponent, emptyset));
//         // // revert if 0 ^ 0
//         // require( !stringsEq(base, emptyset) && !stringsEq(exponent, emptyset));
//         (bool isNestedString1, , ) = isNestedString(base);
//         (bool isNestedString2, , ) = isNestedString(exponent);
//         require(
//             isNestedString1 == true,
//             "nestedSet1 is not legal nested string"
//         );
//         require(
//             isNestedString2 == true,
//             "nestedSet2 is not legal nested string"
//         );
//         if (stringsEq(base, emptyset)) {
//             return emptyset;
//         } else if (stringsEq(base, one)) {
//             return one;
//         } else if (stringsEq(exponent, one)) {
//             return base;
//         } else {
//             return
//                 multiplyNestedSets(
//                     base,
//                     exponentiateNestedSets(base, predecessorString(exponent))
//                 );
//         }
//     }

//     //////////////////////////////////////////////////////////////////////////////////////////
//     // The VNO
//     //////////////////////////////////////////////////////////////////////////////////////////

//     // Traditionally, in set theoretic constructions of the natural numbers, addition is defined as such:
//     // for any numbers a,b
//     // a + 0 = a, a + S(b) = S(a+b), S() being 'successor of'
//     // the definition is therefore recursive
//     // Here, to save gas, we do something else.

//     function concat(
//         string memory str1,
//         string memory str2
//     ) public pure returns (string memory concatStr) {
//         return string(abi.encodePacked(str1, str2));
//     }

//     function concat(
//         string memory str1,
//         string memory str2,
//         string memory str3
//     ) public pure returns (string memory concatStr) {
//         return string(abi.encodePacked(str1, str2, str3));
//     }

//     //////////////////////////////////////////////////////////////////////////////////////////
//     // The Object of the Number (metadata)
//     //////////////////////////////////////////////////////////////////////////////////////////

//     /*
//     The Universal Struct stores information of the object that is the number

//     */
//     struct Universal {
//         string nestedString;
//         uint256 number;
//         uint256 instances;
//         uint256[] primes;
//         // uint256[] allInstances; // entries are tokenIds
//         // Factorisation factorisation;
//         // uint256[] primeFactors;
//         // uint256[] powers;
//     }

//     /*
//     The Metadata Struct stores the metadata of each NFT
//     each tokenId has its own metadata struct
//     */

//     // There are four methods in which a new token can be minted:
//     // (1) direct mint, if the universal already exists -- "direct"
//     // (2) mint by succession -- "succession"
//     // (3) mint by addition --"addition"
//     // (4) mint by multiplication -- "multiplication"

//     // For the generatingNumbers section, if the method is:
//     // (1) direct mint, then the generatingNumber is the Universal;
//     // (2) succession, then the generatingNumber is the predecessor;
//     // (3) addition, then the generatingNumber is an array of the two summing numbers;
//     // (4) Multiplication, then the generatingNumber is an array of the multiplying numbers;

//     struct Metadata {
//         Universal universal;
//         uint256 mintTime;
//         uint256 order; // records which instance of a universal a token is
//         string method;
//         uint256[2] generatingNumbers;
//     }

//     mapping(uint256 => Metadata) public tokenId_to_metadata; // looks at the token"s metadata
//     mapping(uint256 => Universal) public num_to_universal; //
//     mapping(uint256 => uint256) public universal_to_tokenId;
//     mapping(uint256 => uint256) public universal_to_tax; // in gwei
//     mapping(uint256 => uint256) public universal_to_additionTax; // in gwei
//     mapping(uint256 => uint256) public universal_to_multiplicationTax; // in gwei
//     mapping(uint256 => uint256) public universalToBalance;

//     mapping(uint256 => uint256) public tokenId_to_balances;
//     mapping(uint256 => bool) public tokenId_active;

//     function nestedStringToNum(
//         string memory nestedString
//     ) public pure returns (uint256 num) {
//         uint256 x = utfStringLength(nestedString) / 2 - 1;
//         return x;
//     }

//     function emptySet() public pure returns (string memory emptyset) {
//         return "{}";
//     }

//     function numToNestedString(
//         uint256 number
//     ) public view returns (string memory) {
//         string memory left;
//         string memory right;
//         string memory nestedString = emptySet();
//         if (number == 0) {
//             return nestedString;
//         } else {
//             for (uint256 i = 0; i < number; i++) {
//                 nestedString = concat("{", nestedString, "}");
//             }
//         }

//         return nestedString;
//     }

//     function Time() public view returns (uint256 timeCreated) {
//         timeCreated = block.timestamp;
//         return timeCreated;
//     }

//     function isUniversal(uint256 tokenId) public view returns (bool) {
//         return (universal_to_tokenId[
//             tokenId_to_metadata[tokenId].universal.number
//         ] == tokenId);
//     }

//     //////////////////////////////////////////////////////////////////////////////////////////
//     // Minting Functionality
//     //////////////////////////////////////////////////////////////////////////////////////////

//     uint256 public treasuryBalance;
//     uint256 public paymentToTreasury;
//     uint256 public cut;

//     function setCut(uint256 bp) public onlyOwner {
//         // the Math Bretheren Tax applies to all Universal Owners
//         // the treasury tax is set in terms of basis points
//         // The tax can range from 0 to 100*10000 = 1,000,000 (which amounts to 100%)
//         require(bp >= 0, "negative taxes are not allowed!");
//         require(bp <= 1000000, "tax is more than 100%!");
//         cut = bp;
//     }

//     function withdrawTreasury(uint256 amount, address to) public onlyOwner {
//         require(
//             amount <= treasuryBalance,
//             'you"re withdrawing more than the treasury!'
//         );
//         (bool success, ) = payable(to).call{value: amount}("");
//         require(success, 'the withdrawal didn"t go through');
//         if (success) {
//             treasuryBalance = treasuryBalance - amount;
//         }
//     }

//     //  if there is no fallback function, no payable function will work
//     fallback() external payable {}

//     function sendViaCall() public payable returns (bool) {
//         // Call returns a boolean value indicating success or failure.
//         // This is the current recommended method to use.
//         (bool sent, bytes memory data) = payable(address(this)).call{
//             value: msg.value
//         }("");
//         require(sent, "Failed to send Ether");
//         return sent;
//     }

//     mapping(uint256 => uint256) public balances;

//     // Fallback function is called when msg.data is not empty

//     function withdrawUniversalOwnerBalance(
//         uint256 num,
//         uint256 tokenId1,
//         uint256 tokenId2
//     ) public nonReentrant {
//         address universalOwner = ownerOf(universal_to_tokenId[num]);

//         if (msg.sender != universalOwner) {
//             revert NotOwnerOfUniversal();
//         }
//         require(
//             universalToBalance[num] > 0,
//             'there"s no money for you withdraw!'
//         );

//         if (isUniversal(tokenId1) || isUniversal(tokenId2)) {
//             revert BurningAUniversal();
//         }

//         require(
//             tokenId_to_metadata[tokenId1].universal.number != 1,
//             "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
//         );
//         require(
//             tokenId_to_metadata[tokenId2].universal.number != 1,
//             "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
//         );

//         if (
//             !areCoprime(num, tokenId_to_metadata[tokenId1].universal.number) ||
//             !areCoprime(num, tokenId_to_metadata[tokenId2].universal.number) ||
//             !areCoprime(
//                 tokenId_to_metadata[tokenId1].universal.number,
//                 tokenId_to_metadata[tokenId2].universal.number
//             )
//         ) {
//             revert NotCoprime();
//         }
//         _burn(tokenId1);
//         _burn(tokenId2);

//         // Note that universal taxes are set in absolute amounts, not basis points.

//         (bool success, ) = payable(universalOwner).call{
//             value: universalToBalance[num]
//         }("");
//         require(success, 'it didn"t go through');
//         if (success) {
//             universalToBalance[num] = 0;
//         }
//     }

//     function gcd(uint a, uint b) private pure returns (uint) {
//         if (b == 0) {
//             return a;
//         }
//         return gcd(b, a % b);
//     }

//     function areCoprime(uint a, uint b) internal pure returns (bool) {
//         return gcd(a, b) == 1;
//     }

//     error BurningAUniversal();
//     error NotOwnerOfUniversal();
//     error NotCoprime();
//     error SettingNegativeTax();

//     function setUniversalTax(
//         uint256 num,
//         uint256 tokenId1,
//         uint256 amount // in gwei
//     ) public {
//         if (msg.sender != ownerOf(universal_to_tokenId[num])) {
//             revert NotOwnerOfUniversal();
//         }
//         if (amount < 0) {
//             revert SettingNegativeTax();
//         }
//         // require(amount >= 0, "Negative tax not allowed");

//         if (isUniversal(tokenId1)) {
//             revert BurningAUniversal();
//         }

//         require(
//             tokenId_to_metadata[tokenId1].universal.number != 1,
//             "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
//         );

//         if (!areCoprime(num, tokenId_to_metadata[tokenId1].universal.number)) {
//             revert NotCoprime();
//         }
//         _burn(tokenId1);

//         // Note that universal taxes are set in absolute amounts, not basis points.

//         universal_to_tax[num] = amount;
//     }

//     // function setMintByAdditionTax(
//     //     uint256 num,
//     //     uint256 tokenId1,
//     //     uint256 amount // in wei
//     // ) public {
//     //     if (msg.sender != ownerOf(universal_to_tokenId[num])) {
//     //         revert NotOwnerOfUniversal();
//     //     }
//     //     if (amount < 0) {
//     //         revert SettingNegativeTax();
//     //     }
//     //     // require(amount >= 0, "Negative tax not allowed");

//     //     if (isUniversal(tokenId1)) {
//     //         revert BurningAUniversal();
//     //     }

//     //     require(
//     //         tokenId_to_metadata[tokenId1].universal.number != 1,
//     //         "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
//     //     );

//     //     if (!areCoprime(num, tokenId_to_metadata[tokenId1].universal.number)) {
//     //         revert NotCoprime();
//     //     }
//     //     _burn(tokenId1);

//     //     // Note that universal taxes are set in absolute amounts, not basis points.

//     //     universal_to_tax[num] = amount;
//     // }
//     function composeMetadata(
//         uint256 targetNum,
//         string memory targetNumNestedString,
//         string memory method,
//         uint256[2] memory generatingTokenIds,
//         uint256 tokenId
//     ) internal {
//         if (!universalExists(targetNum)) {
//             // you can also use the following line to check if the number exists

//             Universal storage x = num_to_universal[targetNum];
//             x.nestedString = targetNumNestedString;
//             x.number = targetNum;
//             x.instances = 1;
//             x.primes = factorise(targetNum);
//             // for (uint256 i = 0; i < x.primes.length; i++) {
//             //     if (x.primes[i] != 0) {
//             //         // console.log("Factor", i, ":", x.primes[i]);
//             //     }
//             // }

//             tokenId_to_metadata[tokenId] = Metadata(
//                 x,
//                 Time(),
//                 1,
//                 method,
//                 generatingTokenIds
//             );
//             universal_to_tokenId[targetNum] = tokenId;
//         } else {
//             uint256 instances = getInstances(targetNum);
//             num_to_universal[targetNum].instances = instances + 1;
//             uint256 order = instances + 1;
//             uint256 mintTime = Time();
//             tokenId_to_metadata[tokenId] = Metadata(
//                 num_to_universal[targetNum],
//                 mintTime,
//                 order,
//                 method,
//                 generatingTokenIds
//             );
//         }
//     }

//     error InsufficientPayment();
//     error UnableToRefund();
//     error NotOwnerOfToken();
//     error ParticularEmptiedAlready();
//     error NothingToWithdraw();
//     error UniversalPretendingToBeUniversal();

//     uint256 public mintBySuccessionFee;

//     function set_mint_by_succession_fee(
//         uint256 new_succession_fee
//     ) public onlyOwner {
//         mintBySuccessionFee = new_succession_fee;
//     }

//     uint256 public activeParticulars;

//     function withdrawFromParticular(uint256 tokenId) public nonReentrant {
//         if (msg.sender != ownerOf(tokenId)) {
//             revert NotOwnerOfToken();
//         }
//         if (!tokenId_active[tokenId]) {
//             revert ParticularEmptiedAlready();
//         }
//         if (tokenId_to_balances[tokenId] == 0) {
//             revert NothingToWithdraw();
//         }
//         if (isUniversal(tokenId)) {
//             revert UniversalPretendingToBeUniversal();
//         }
//         (bool success, ) = payable(msg.sender).call{
//             value: tokenId_to_balances[tokenId]
//         }("");
//         require(success, 'the withdrawal didn"t go through');
//         if (success) {
//             tokenId_active[tokenId] = false;
//             tokenId_to_balances[tokenId] == 0;
//             activeParticulars -= 1;
//         }
//     }

//     function getTax(
//         uint256 targetNum,
//         address maker,
//         string memory method
//     ) public returns (uint256 amount) {
//         address owner = _ownerOf[universal_to_tokenId[targetNum]];

//         if (owner == address(0) || maker == owner) {
//             return 0;
//         } else {
//             if (stringsEq(method, "succession")) {
//                 return mintBySuccessionFee;
//             } else if (stringsEq(method, "addition")) {
//                 return universal_to_tax[targetNum];
//             } else if (stringsEq(method, "multiplication")) {
//                 return universal_to_tax[targetNum];
//             } else if (stringsEq(method, "direct")) {
//                 return universal_to_tax[targetNum];
//             }
//         }
//     }

//     function mintNumber(
//         address maker,
//         uint256 targetNum,
//         string memory targetNumNestedString,
//         string memory method,
//         uint256[2] memory generatingTokenIds,
//         uint256 fee
//     ) public nonReentrant returns (uint256 newTokenId) {
//         require(
//             keccak256(abi.encodePacked(numToNestedString(targetNum))) ==
//                 keccak256(abi.encodePacked(targetNumNestedString)),
//             "the target and its nested string disagree"
//         );

//         uint256 tax = (
//             _ownerOf[universal_to_tokenId[targetNum]] == address(0)
//                 ? 0
//                 : (
//                     maker == ownerOf(universal_to_tokenId[targetNum])
//                         ? (
//                             stringsEq(method, "succession")
//                                 ? mintBySuccessionFee
//                                 : 0
//                         )
//                         : universal_to_tax[targetNum]
//                 )
//         );

//         if (fee < tax) {
//             revert InsufficientPayment();
//         }
//         uint256 refund = (tax == 0 ? fee : fee - tax);

//         (bool refunded, ) = maker.call{value: refund}("");
//         if (!refunded) {
//             revert UnableToRefund();
//         } else {
//             currentId = currentId + 1;
//             // recall that universal taxes are set as whole numbers, not percentages
//             universalToBalance[targetNum] += (tax * (1000000 - cut)) / 1000000;

//             for (uint256 i = 0; i < currentId; i++) {
//                 if (tokenId_active[i] && !isUniversal(i)) {
//                     tokenId_to_balances[i] +=
//                         (tax * cut * 80) /
//                         (100 * 1000000 * activeParticulars); // 80% of the cut goes to previous particular holders; 20% goes to the treasury
//                 }
//             }
//             tokenId_active[currentId] = true;
//             activeParticulars += 1;

//             treasuryBalance += (tax * cut * 20) / (100 * 1000000);
//             composeMetadata(
//                 targetNum,
//                 targetNumNestedString,
//                 method,
//                 generatingTokenIds,
//                 currentId
//             );

//             _safeMint(maker, currentId);

//             return currentId;
//         }
//     }

//     // Number making

//     function makeNumZero()
//         public
//         pure
//         returns (
//             string memory emptyset,
//             string memory method,
//             uint256[2] memory generatingNumbers
//         )
//     {
//         string memory emptyset = "{}";
//         string memory method = "genesis";
//         uint256[2] memory generatingNumbers;
//         return (emptyset, method, generatingNumbers);
//     }

//  function makeNumBySuccession(
//         string memory nestedSet
//     )
//         public
//         view
//         returns (
//             string memory successorSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory successorSet = successorString(nestedSet);
//         string memory method = "succession";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet);
//         return (successorSet, method, generatingTokenIds);
//     }

//     function makeNumByDirect(
//         string memory nestedString
//     )
//         public
//         view
//         returns (
//             uint256 n,
//             string memory method,
//             uint256[2] memory generatingNumbers
//         )
//     {
//         string memory method = "direct";
//         uint256[2] memory generatingNumbers;
//         generatingNumbers[0] = n;

//         return (n, method, generatingNumbers);
//     }

//     function getInstances(uint256 num) public view returns (uint256 instances) {
//         instances = num_to_universal[num].instances;
//         return instances;
//     }

//     function mintZero(
//         address maker
//     ) public payable returns (uint256 newTokenId) {
//         (
//             string memory nestedString,
//             string memory method,
//             uint256[2] memory generatingNumbers
//         ) = makeNumZero();

//         uint256 newTokenId = mintNumber(
//             maker,
//             0,
//             method,
//             generatingNumbers,
//             msg.value
//         );

//         return newTokenId;
//     }

//     error notOwnerOftheToken();

//     //////////////////////////////////////////////////////////////////////////////////////////
//     // Graph Drawing
//     //////////////////////////////////////////////////////////////////////////////////////////

//     // https://ethereum.stackexchange.com/questions/132239/how-to-compare-string-and-bytes32-in-an-optimal-way
//     function toByte(uint8 _uint8) internal pure returns (bytes1) {
//         if (_uint8 < 10) {
//             return bytes1(_uint8 + 48);
//         } else {
//             return bytes1(_uint8 + 87);
//         }
//     }

//     function bytes32ToString(
//         bytes32 _bytes32
//     ) internal pure returns (string memory) {
//         uint8 i = 0;
//         bytes memory bytesArray = new bytes(64);
//         uint256 l = bytesArray.length;
//         for (i = 0; i < l; ++i) {
//             uint8 _f = uint8(_bytes32[i / 2] & 0x0f);
//             uint8 _l = uint8(_bytes32[i / 2] >> 4);

//             bytesArray[i] = toByte(_l);
//             ++i;
//             bytesArray[i] = toByte(_f);
//         }
//         return string(bytesArray);
//     }

//     function random(bytes memory input) internal view returns (uint256) {
//         return uint256(keccak256(input));
//     }

//     function makeCircle(uint256 num) public view returns (bytes memory circle) {
//         string[13] memory colours = [
//             "red",
//             "cyan",
//             "deeppink",
//             "magenta",
//             "lime",
//             "blue",
//             "white",
//             "gold",
//             "aqua",
//             "yellow",
//             "orange",
//             "greenyellow",
//             "dodgerblue"
//         ];
//         uint256 rand = random(abi.encodePacked("circle", num));
//         string memory colour = colours[rand % colours.length];
//         bytes memory circle = abi.encodePacked(
//             "<circle cx='5000' cy='5000' r='5000' fill='",
//             colour,
//             "'/>"
//         );

//         return circle;
//     }

//     function rotate(
//         uint256 many2Pis,
//         uint256 manyethsOf2Pis,
//         bytes memory image
//     ) public view returns (bytes memory rotated) {
//         bytes memory degreesString = divReturnDecimal(
//             360 * many2Pis,
//             manyethsOf2Pis
//         );
//         bytes memory head = abi.encodePacked(
//             "<g transform='rotate(",
//             degreesString,
//             ",5000,5000)'>"
//         );
//         string memory tail = "</g>";

//         return (abi.encodePacked(head, image, tail));
//     }

//     function scale(
//         uint256 up,
//         uint256 down,
//         bytes memory image
//     ) public view returns (bytes memory scaled) {
//         bytes memory head = abi.encodePacked(
//             "<g transform='translate(",
//             divReturnDecimal((down - up) * 5000, down),
//             "), scale(",
//             divReturnDecimal(up, down),
//             ")'>"
//         );
//         bytes memory tail = "</g>";
//         return abi.encodePacked(head, image, tail);
//     }

//     function makePolygon(
//         uint256 prime
//     ) public view returns (bytes memory polygon) {
//         bytes memory shape = bytes("");
//         uint256 _prime = prime;
//         if (_prime == 2) {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(1, _prime + 1, makeCircle(i))
//                 );
//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else if (_prime == 3) {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(1, _prime, makeCircle(i))
//                 );
//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 uint256 x = _prime * i;
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(1, _prime - 1, makeCircle(x))
//                 );
//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         }
//         return shape;
//     }

//     function composeShape(
//         uint256 prime,
//         bytes memory image
//     ) public view returns (bytes memory shape) {
//         bytes memory shape = bytes("");
//         uint256 _prime = prime;
//         bytes memory scaled_image;

//         if (_prime == 2) {
//             bytes memory scaled_image = scale(1, _prime + 1, image);
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scaled_image
//                     // scale(1, _prime + 1, image)
//                 );

//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else if (_prime == 3) {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory scaled_image = scale(1, _prime - 1, image);
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scaled_image
//                     // scale(1, _prime - 1, image)
//                 );

//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory scaled_image = scale(
//                     _prime - 1,
//                     2 * _prime + 1,
//                     image
//                 );
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scaled_image
//                     // scale(_prime - 1, 2 * _prime + 1, image)
//                 );

//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         }
//         return shape;
//     }

//     function wrapCanvas(
//         bytes memory stuffInside
//     ) internal pure returns (string memory drawing) {
//         bytes memory _stuffInside = stuffInside;
//         bytes
//             memory head = "<svg  xmlns='http://www.w3.org/2000/svg' width='10000' height='10000' style='background-color:black'>";
//         string memory tail = "</svg>";
//         return
//             string(
//                 abi.encodePacked(
//                     abi.encodePacked(
//                         head,
//                         "\n",
//                         abi.encodePacked(
//                             '<g transform="translate(1000,1000) scale(0.8)">',
//                             stuffInside,
//                             "</g>"
//                         )
//                     ),
//                     "\n",
//                     tail
//                 )
//             );
//     }

//     function drawUniversal(
//         uint256 num
//     ) public view returns (string memory image) {
//         bytes memory shape = "";
//         uint256 _num = num;
//         // uint256[] memory primes = factorise(_num);

//         uint256[] memory primes = num_to_universal[num].primes;
//         if (_num == 0) {
//             return (wrapCanvas(shape));
//         } else if (_num == 1) {
//             bytes memory head = abi.encodePacked(
//                 "<g transform='translate(0,2500)'><g transform='translate(1000,1000) scale(0.8)'>"
//             );
//             bytes memory tail = abi.encodePacked("</g></g>");
//             return wrapCanvas(abi.encodePacked(head, makeCircle(_num), tail));
//         } else {
//             // console.log("we are here!");
//             // console.log("the length of primes is:", primes.length);
//             uint256 l = primes.length;
//             for (uint256 i = 0; i < l; ++i) {
//                 if (i == 0) {
//                     shape = makePolygon(primes[i]);
//                     // console.log("i ==0!");
//                     // console.log(primes[i]);
//                 } else {
//                     // console.log("i!=0!");
//                     if (primes[i] != 0) {
//                         // console.log("composing the shape!");
//                         shape = composeShape(primes[i], shape);
//                     }
//                 }
//                 // console.log(primes[i]);
//             }
//         }

//         return (wrapCanvas(shape));
//     }

//     function drawParticular(
//         uint256 num
//     ) public view returns (string memory image) {
//         uint256 _num = num;
//         string memory num_str = _num.toString();
//         uint256 length = utfStringLength(num_str);
//         if (length <= 10) {
//             return
//                 wrapCanvas(
//                     abi.encodePacked(
//                         '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="1000">',
//                         num_str,
//                         "</text>"
//                     )
//                 );
//         } else if (length <= 20) {
//             return
//                 wrapCanvas(
//                     abi.encodePacked(
//                         '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="800">',
//                         num_str,
//                         "</text>"
//                     )
//                 );
//         } else if (length <= 30) {
//             return
//                 wrapCanvas(
//                     abi.encodePacked(
//                         '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="600">',
//                         num_str,
//                         "</text>"
//                     )
//                 );
//         } else if (length <= 40) {
//             return
//                 wrapCanvas(
//                     abi.encodePacked(
//                         '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="400">',
//                         num_str,
//                         "</text>"
//                     )
//                 );
//         } else {
//             string memory first = substring(num_str, 0, 9);
//             string memory last = substring(num_str, length - 9, length);
//             return (
//                 wrapCanvas(
//                     abi.encodePacked(
//                         abi.encodePacked(
//                             '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="400">',
//                             first,
//                             "......"
//                         ),
//                         abi.encodePacked(
//                             last,
//                             '</text><text x="50%" y="60%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="400">Total:',
//                             length
//                         ),
//                         " digits</text>"
//                     )
//                 )
//             );
//         }
//     }

//     // The divReturnDecimal() function takes two unsigned integers x and y as input parameters and returns a string representation of the decimal result of the division (x / y). The function calculates the integer part and the decimal part (up to 18 decimal places) separately and concatenates them into a single string.

//     // Here's a step-by-step explanation of the code:

//     // Initialize variables _x and _y with the input values x and y.
//     // Calculate the integer part of the division (I) using _x / _y.
//     // Initialize variables d and s to store the count of decimal places and the decimal part of the result, respectively.
//     // If the division has a remainder (_x % _y != 0), the loop calculates the decimal part of the result up to 18 decimal places or until there's no remainder left.
//     // Calculate the number of trailing zeros that should be added after the decimal point, based on the input values x and y.
//     // Create a zeroString by concatenating the required number of zeros.
//     // Concatenate the integer part, the decimal point, zeroString, and the calculated decimal part s into a single string decimal.
//     // Return the decimal string as the final result.
//     // This function is useful when you need to perform division between unsigned integers and get the result as a string with decimal places, up to a maximum of 18.

//     function divReturnDecimal(
//         uint256 x,
//         uint256 y
//     ) public view returns (bytes memory) {
//         uint256 _x = x;
//         uint256 _y = y;

//         uint256 d = 0;
//         uint256 s = 0;
//         uint256 I = _x / _y;

//         if (_x % _y != 0) {
//             while (_x % _y != 0 && d <= 18) {
//                 s = s * 10 + (_x * 10) / _y;

//                 _x = (_x * 10) % _y;

//                 d += 1;
//             }
//         }

//         uint256 zeros = (
//             (_x % _y == 0)
//                 ? 0
//                 : (
//                     (_x % 10 == 0 && _y % 10 == 0)
//                         ? utfStringLength(_y.toString()) -
//                             utfStringLength(_x.toString())
//                         : 0
//                 )
//         );

//         string memory zeroString = "";

//         if (zeros != 0) {
//             for (uint256 i = 0; i < zeros; ++i) {
//                 zeroString = string(
//                     abi.encodePacked(zeroString, uint256(0).toString())
//                 );
//             }
//         }

//         bytes memory decimal = abi.encodePacked(
//             I.toString(),
//             ".",
//             zeroString,
//             (s % (10 ** d)).toString()
//         );
//         return decimal;
//     }

//     function universalExists(uint256 num) public view returns (bool) {
//         Universal memory universal = num_to_universal[num];
//         // if (bytes(universal.nestedString).length > 0) {
//         //     // The nested string is not empty
//         //     return false;
//         // }
//         if (universal.number != 0) {
//             // The number is not zero
//             return false;
//         }
//         if (universal.instances != 0) {
//             // The instances is not zero
//             return false;
//         }
//         if (universal.primes.length > 0) {
//             // The primes array is not empty
//             return false;
//         }
//         // All fields are empty
//         return true;
//     }

//     function factorise(uint256 num) public view returns (uint256[] memory) {
//         uint256 _num = num;
//         if (_num <= 1) {
//             uint256[] memory factors = new uint256[](_num == 0 ? 0 : 1);
//             if (_num == 1) {
//                 factors[0] = 1;
//             }
//             return factors;
//         }

//         uint256 n = num;
//         uint256 maxNumberOfPrimes = (n.fromUInt().sqrt()).toUInt() + 1;
//         uint256[] memory factors = new uint256[](maxNumberOfPrimes);
//         uint256 k = 0;

//         while (n != 1) {
//             uint256 p = 0;
//             uint256 eights;
//             uint256 fours;
//             // figure out the highest power p of 2 that divides n.
//             while (n % 2 == 0) {
//                 p++;
//                 n = n / 2;
//             }

//             if (p == 1) {
//                 factors[k] = 2;
//                 k++;
//             } else {
//                 eights = p / 3;
//                 fours = (p - (eights * 3)) / 2;
//                 for (uint256 i = 0; i < eights; ++i) {
//                     factors[k] = 8;
//                     k++;
//                 }
//                 for (uint256 i = 0; i < fours; ++i) {
//                     factors[k] = 4;
//                     k++;
//                 }
//             }
//             // for (uint256 i = maxNumberOfPrimes; 3 <= i; --i) {
//             for (uint256 i = 3; i <= maxNumberOfPrimes; ++i) {
//                 while (n % i == 0) {
//                     factors[k] = i;
//                     k++;
//                     n = n / i;
//                     if (!universalExists(n) && n != 1) {
//                         // console.log("we are now looking at", n);
//                         uint256[]
//                             memory alreadyComputedFactorisation = num_to_universal[
//                                 n
//                             ].primes;
//                         uint256 l = alreadyComputedFactorisation.length;
//                         uint256[] memory allFactors = new uint256[](k + l);

//                         for (uint256 i = 0; i < k; i++) {
//                             allFactors[i] = factors[i];
//                             // console.log("replicating!", factors[i]);
//                         }

//                         for (uint256 j = 0; j < l; j++) {
//                             if (alreadyComputedFactorisation[j] != 1) {
//                                 allFactors[
//                                     k + j
//                                 ] = alreadyComputedFactorisation[j];
//                                 // console.log(
//                                 //     "copying!",
//                                 //     alreadyComputedFactorisation[j]
//                                 // );
//                             }
//                         }
//                         return allFactors;
//                     }
//                 }
//             }
//             if (n > 2) {
//                 // This is where the number is prime
//                 factors[k] = n;
//                 k++;
//                 n = 1; // n = n /n
//             }
//         }

//         // Resize the array to remove unused slots
//         uint256[] memory resizedFactors = new uint256[](k);
//         for (uint256 i = 0; i < k; ++i) {
//             resizedFactors[i] = factors[i];
//         }
//         return resizedFactors;
//     }

//     function tokenURI(
//         uint256 tokenId
//     ) public view virtual override returns (string memory) {
//         if (ownerOf(tokenId) == address(0)) {
//             revert NonExistentTokenURI();
//         } else {
//             if (isUniversal(tokenId)) {
//                 string memory tokenURI = drawUniversal(
//                     tokenId_to_metadata[tokenId].universal.number
//                 );
//                 return tokenURI;
//             } else {
//                 string memory tokenURI = drawParticular(
//                     tokenId_to_metadata[tokenId].universal.number
//                 );
//                 return tokenURI;
//             }
//         }
//     }

//     error NonExistentTokenURI();

//     function makeNumByDirect(
//         string memory nestedSet
//     )
//         public
//         view
//         returns (
//             string memory,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory method = "direct";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet);

//         return (nestedSet, method, generatingTokenIds);
//     }

//     function makeNumByAddition(
//         string memory nestedSet1,
//         string memory nestedSet2
//     )
//         public
//         view
//         returns (
//             string memory addedNestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory addedNestedSet = addNestedSets(nestedSet1, nestedSet2);

//         string memory method = "addition";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet1);
//         generatingTokenIds[1] = nestedStringToNum(nestedSet2);
//         return (addedNestedSet, method, generatingTokenIds);
//     }

//     function makeNumBySubtraction(
//         string memory nestedSet1,
//         string memory nestedSet2
//     )
//         public
//         view
//         returns (
//             string memory addedNestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory addedNestedSet = subtractNestedSets(
//             nestedSet1,
//             nestedSet2
//         );
//         string memory method = "subtraction";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet1);
//         generatingTokenIds[1] = nestedStringToNum(nestedSet2);
//         return (addedNestedSet, method, generatingTokenIds);
//     }

//     function makeNumByMultiplication(
//         string memory nestedSet1,
//         string memory nestedSet2
//     )
//         public
//         view
//         returns (
//             string memory addedNestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory addedNestedSet = addNestedSets(nestedSet1, nestedSet2);
//         string memory method = "multiplication";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet1);
//         generatingTokenIds[1] = nestedStringToNum(nestedSet2);
//         return (addedNestedSet, method, generatingTokenIds);
//     }

//     function makeNumByExponentiation(
//         string memory nestedSet1,
//         string memory nestedSet2
//     )
//         public
//         view
//         returns (
//             string memory addedNestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         )
//     {
//         string memory addedNestedSet = exponentiateNestedSets(
//             nestedSet1,
//             nestedSet2
//         );
//         string memory method = "exponentiation";
//         uint256[2] memory generatingTokenIds;
//         generatingTokenIds[0] = nestedStringToNum(nestedSet1);
//         generatingTokenIds[1] = nestedStringToNum(nestedSet2);
//         return (addedNestedSet, method, generatingTokenIds);
//     }

//     function getInstances(uint256 num) public view returns (uint256 instances) {
//         instances = num_to_universal[num].instances;
//         return instances;
//     }

//     function mintZero(
//         address maker
//     ) public payable returns (uint256 newTokenId) {
//         (
//             string memory nestedString,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumZero();

//         uint256 newTokenId = mintNumber(
//             maker,
//             0,
//             nestedString,
//             method,
//             generatingTokenIds,
//             msg.value
//         );

//         return newTokenId;
//     }

//     error notOwnerOftheToken();

//     function mintByDirect(
//         address maker,
//         uint256 num
//     ) public payable returns (uint256 newTokenId) {
//         require(
//             universalExists(num) == true,
//             "the universal of the predecessor has not been made yet"
//         );

//         (
//             string memory nestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumByDirect(numToNestedString(num));

//         newTokenId = mintNumber(
//             maker,
//             num,
//             nestedSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );
//         return newTokenId;
//     }

//     function mintByAddition(
//         address maker,
//         uint256 oldTokenId1,
//         uint256 oldTokenId2
//     ) public payable returns (uint256 newTokenId) {
//         require(
//             ((ownerOf(oldTokenId1) == maker) &&
//                 (ownerOf(oldTokenId2) == maker)),
//             'you don"t own the tokens you"re adding'
//         );

//         (
//             string memory nestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumByAddition(
//                 tokenId_to_metadata[oldTokenId1].universal.nestedString,
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString
//             );
//         uint256 targetNum = nestedStringToNum(nestedSet);
//         newTokenId = mintNumber(
//             maker,
//             targetNum,
//             nestedSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );
//         require(ownerOf(newTokenId) == maker, "not minted");

//         if (!isUniversal(oldTokenId1)) {
//             _burn(oldTokenId1);
//         }
//         if (!isUniversal(oldTokenId2)) {
//             _burn(oldTokenId2);
//         }

//         return newTokenId;
//     }

//     function mintBySubtraction(
//         address maker,
//         uint256 oldTokenId1,
//         uint256 oldTokenId2
//     ) public payable returns (uint256 newTokenId) {
//         require(
//             ((ownerOf(oldTokenId1) == maker) &&
//                 (ownerOf(oldTokenId2) == maker)),
//             'you don"t own the tokens you"re adding'
//         );

//         (
//             string memory nestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumBySubtraction(
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString,
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString
//             );
//         uint256 targetNum = nestedStringToNum(nestedSet);

//         newTokenId = mintNumber(
//             maker,
//             targetNum,
//             nestedSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );
//         require(ownerOf(newTokenId) == maker, "not minted");
//         if (!isUniversal(oldTokenId1)) {
//             _burn(oldTokenId1);
//         }
//         if (!isUniversal(oldTokenId2)) {
//             _burn(oldTokenId2);
//         }
//         return newTokenId;
//     }

//     function mintByMultiplication(
//         address maker,
//         uint256 oldTokenId1,
//         uint256 oldTokenId2
//     ) public payable returns (uint256 newTokenId) {
//         require(
//             ((ownerOf(oldTokenId1) == maker) &&
//                 (ownerOf(oldTokenId2) == maker)),
//             'you don"t own the tokens you"re adding'
//         );

//         (
//             string memory nestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumByMultiplication(
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString,
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString
//             );

//         uint256 targetNum = nestedStringToNum(nestedSet);

//         newTokenId = mintNumber(
//             maker,
//             targetNum,
//             nestedSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );
//         require(ownerOf(newTokenId) == maker, "not minted");
//         if (!isUniversal(oldTokenId1)) {
//             _burn(oldTokenId1);
//         }
//         if (!isUniversal(oldTokenId2)) {
//             _burn(oldTokenId2);
//         }
//         return newTokenId;
//     }

//     function mintByExponentiation(
//         address maker,
//         uint256 oldTokenId1,
//         uint256 oldTokenId2
//     ) public payable returns (uint256 newTokenId) {
//         require(
//             ((ownerOf(oldTokenId1) == maker) &&
//                 (ownerOf(oldTokenId2) == maker)),
//             'you don"t own the tokens you"re adding'
//         );

//         (
//             string memory nestedSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumByExponentiation(
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString,
//                 tokenId_to_metadata[oldTokenId2].universal.nestedString
//             );

//         uint256 targetNum = nestedStringToNum(nestedSet);

//         newTokenId = mintNumber(
//             maker,
//             targetNum,
//             nestedSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );
//         require(ownerOf(newTokenId) == maker, "not minted");
//         if (!isUniversal(oldTokenId1)) {
//             _burn(oldTokenId1);
//         }
//         if (!isUniversal(oldTokenId2)) {
//             _burn(oldTokenId2);
//         }
//         return newTokenId;
//     }

//     function mintBySuccession(
//         address maker,
//         uint256 oldTokenId
//     ) public payable returns (uint256 newTokenId) {
//         // checks if num is new, if new, increases its order to 1 (first!)
//         // if not new, does nothing and goes straight next

//         if (ownerOf(oldTokenId) != maker) {
//             revert notOwnerOftheToken();
//         }
//         // require(
//         //     ownerOf(oldTokenId) == maker,
//         //     'you don"t own the token you"re making the successor of'
//         // );
//         (
//             string memory successorSet,
//             string memory method,
//             uint256[2] memory generatingTokenIds
//         ) = makeNumBySuccession(
//                 tokenId_to_metadata[oldTokenId].universal.nestedString
//             );

//         uint256 targetNum = nestedStringToNum(successorSet);

//         newTokenId = mintNumber(
//             maker,
//             targetNum,
//             successorSet,
//             method,
//             generatingTokenIds,
//             msg.value
//         );

//         return newTokenId;
//     }
// function nestedStringToNum(
//     string memory nestedString
// ) public pure returns (uint256 num) {
//     uint256 x = utfStringLength(nestedString) / 2 - 1;
//     return x;
// }
// }
