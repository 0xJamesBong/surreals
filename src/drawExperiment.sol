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

// contract DrawExperiment {
//     using LibString for *;
//     using ABDKMathQuad for *;

//     function foo1(
//         string calldata str1,
//         string calldata str2
//     ) public pure returns (string memory) {
//         string memory _str1 = str1;
//         string memory _str2 = str2;

//         return string(abi.encodePacked(_str1, _str2));
//     }

//     function foo2(
//         string memory str1,
//         string memory str2
//     ) public returns (string memory) {
//         return string(abi.encodePacked(str1, str2));
//     }

//     // function foo2(
//     //     string memory input
//     // ) external view returns (string memory output) {
//     //     bytes memory myMemoryString = abi.decode(input, (bytes));
//     //     myMemoryString[0] = "A";
//     //     bytes memory myModifiedCalldataString = abi.encode(myMemoryString);
//     //     return output;
//     // }

//     function substring(
//         string memory str,
//         uint256 startIndex,
//         uint256 endIndex
//     ) public pure returns (string memory) {
//         bytes memory strBytes = bytes(str);
//         bytes memory result = new bytes(endIndex - startIndex);
//         for (uint256 i = startIndex; i < endIndex; ++i) {
//             result[i - startIndex] = strBytes[i];
//         }
//         return string(result);
//     }

//     function utfStringLength(
//         string memory str
//     ) public pure returns (uint256 length) {
//         uint256 i = 0;
//         bytes memory string_rep = bytes(str);
//         uint256 l = string_rep.length;
//         while (i < l) {
//             if (string_rep[i] >> 7 == 0) i += 1;
//             else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
//             else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
//             else if (string_rep[i] >> 3 == bytes1(uint8(0x1E)))
//                 i += 4;
//                 //For safety
//             else i++;
//             length++;
//         }
//     }

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
//             "cyan",
//             "red",
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
//         if (_prime == 2) {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(1, _prime + 1, image)
//                 );

//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else if (_prime == 3) {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(1, _prime - 1, image)
//                 );

//                 shape = abi.encodePacked(shape, incompleteShape);
//             }
//         } else {
//             for (uint256 i = 0; i < _prime; ++i) {
//                 bytes memory incompleteShape = rotate(
//                     i,
//                     _prime,
//                     scale(_prime - 1, 2 * _prime + 1, image)
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
//         uint256[] memory primes = factorise(_num);
//         // string memory factorString = "";

//         if (_num == 0) {
//             return (wrapCanvas(shape));
//         } else if (_num == 1) {
//             return (
//                 wrapCanvas(
//                     abi.encodePacked(
//                         abi.encodePacked(
//                             "<g transform='translate(0,2500)'>",
//                             '<g transform="translate(1000,1000) scale(0.8)">'
//                         ),
//                         makeCircle(_num),
//                         abi.encodePacked("</g>", "</g>")
//                     )
//                 )
//             );
//         } else {
//             console.log("we are here!");

//             console.log("the length of primes is:", primes.length);
//             uint256 l = primes.length;
//             for (uint256 i = 0; i < l; ++i) {
//                 if (i == 0) {
//                     shape = makePolygon(primes[i]);
//                     console.log("i ==0!");
//                     console.log(primes[i]);
//                 } else {
//                     console.log("i!=0!");
//                     if (primes[i] != 0) {
//                         console.log("composing the shape!");
//                         shape = composeShape(primes[i], shape);
//                     }
//                 }
//                 console.log(primes[i]);
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

//     function factorise(uint256 num) public pure returns (uint256[] memory) {
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

//             for (uint256 i = 3; i <= maxNumberOfPrimes; ++i) {
//                 while (n % i == 0) {
//                     factors[k] = i;
//                     k++;
//                     n = n / i;
//                 }
//             }
//             if (n > 2) {
//                 factors[k] = n;
//                 k++;
//                 n = n / n;
//             }
//         }

//         // Resize the array to remove unused slots
//         uint256[] memory resizedFactors = new uint256[](k);
//         for (uint256 i = 0; i < k; ++i) {
//             resizedFactors[i] = factors[i];
//         }
//         return resizedFactors;
//     }
// }
