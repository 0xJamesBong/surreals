// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "solmate/utils/LibString.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";

library StringManipulations {
    using LibString for *;
    using ABDKMathQuad for *;

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    // https://ethereum.stackexchange.com/questions/13862/is-it-possible-to-check-string-variables-length-inside-the-contract
    function utfStringLength(
        string memory str
    ) public pure returns (uint256 length) {
        uint256 i = 0;
        bytes memory string_rep = bytes(str);

        while (i < string_rep.length) {
            if (string_rep[i] >> 7 == 0) i += 1;
            else if (string_rep[i] >> 5 == bytes1(uint8(0x6))) i += 2;
            else if (string_rep[i] >> 4 == bytes1(uint8(0xE))) i += 3;
            else if (string_rep[i] >> 3 == bytes1(uint8(0x1E)))
                i += 4;
                //For safety
            else i += 1;
            length++;
        }
    }

    function isNestedString(
        string memory where
    ) public pure returns (bool, uint256 numL, uint256 numR) {
        // https://ethereum.stackexchange.com/questions/69307/find-word-in-string-solidity
        bytes memory whereBytes = bytes(where);
        bool legal = true;
        uint256 numL = 0;
        uint256 numR = 0;
        for (uint256 i = 0; i <= whereBytes.length - 1; i++) {
            bool flag = false;
            // recording the number of left and right brackets
            if (whereBytes[i] == "{") {
                numL += 1;
            } else if (whereBytes[i] == "}") {
                numR += 1;
            }
            if (whereBytes[i] != "{" && whereBytes[i] != "}") {
                flag = true;
            }

            if (
                i + 1 != whereBytes.length &&
                whereBytes[i] == "}" &&
                whereBytes[i + 1] == "{"
            ) {
                flag = true;
            }
            // if any one flag is raised, break loop
            if (flag) {
                legal = false;
                break;
            }
        }
        if (numL != numR) {
            legal = false;
        }
        return (legal, numL, numR);
    }

    function stringsEq(
        string memory nestedSet1,
        string memory nestedSet2
    ) public pure returns (bool) {
        bytes32 compareNestedSet1 = keccak256(abi.encodePacked(nestedSet1));
        bytes32 compareNestedSet2 = keccak256(abi.encodePacked(nestedSet2));
        return (compareNestedSet1 == compareNestedSet2);
    }

    function isSubstring(
        string memory nestedSet1,
        string memory nestedSet2
    ) public pure returns (bool) {
        // Only determines if nestedSet 1 is a substring of nestedSet2
        // I don"t care about the other way around
        // proper substrings only
        // This function relies on the fact that we have already checked they"re legal strings
        // Which enables the iff that isSubstring(nestedSet1, nestedSet2) == true iff nestedSet1 < nestedSet2 as numbers.
        (bool isNestedString1, , ) = isNestedString(nestedSet1);
        (bool isNestedString2, , ) = isNestedString(nestedSet2);
        require(
            isNestedString1 == true,
            "nestedSet1 is not legal nested substring"
        );
        require(
            isNestedString2 == true,
            "nestedSet2 is not legal nested substring"
        );
        return (utfStringLength(nestedSet1) < utfStringLength(nestedSet2));
    }
}
