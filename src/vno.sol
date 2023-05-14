// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {ERC721} from "solmate/tokens/ERC721.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {Owned} from "solmate/auth/Owned.sol";
import "solmate/utils/LibString.sol";

import "forge-std/console.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol";
import "./StringManipulations.sol";

// contract VNO is ERC721, Ownable, ReentrancyGuard {
contract VNO is ERC721, Owned, ReentrancyGuard {
    using LibString for *;
    using ABDKMathQuad for *;
    using StringManipulations for *;

    address public surreals;

    function setSurreals(address surreals_) public onlyOwner {
        surreals = surreals_;
    }

    function _burn(uint256 id) internal override {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");
        require(!isUniversal(id), "Universals cannot be burnt!");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    ///@notice id of current ERC721 being minted
    uint256 public currentId;

    constructor() ERC721("VNO", "VNO") Owned(msg.sender) {}

    //////////////////////////////////////////////////////////////////////////////////////////
    // The VNO
    //////////////////////////////////////////////////////////////////////////////////////////

    // Traditionally, in set theoretic constructions of the natural numbers, addition is defined as such:
    // for any numbers a,b
    // a + 0 = a, a + S(b) = S(a+b), S() being 'successor of'
    // the definition is therefore recursive
    // Here, to save gas, we do something else.

    //////////////////////////////////////////////////////////////////////////////////////////
    // The Object of the Number (metadata)
    //////////////////////////////////////////////////////////////////////////////////////////

    /*
    The Universal Struct stores information of the object that is the number
    
    */
    struct Universal {
        uint256 number;
        uint256 instances;
        uint256 activeParticulars;
        uint256 tokenId;
        uint256[] primes;
    }

    /*
    The Metadata Struct stores the metadata of each NFT 
    each tokenId has its own metadata struct
    */

    // There are four methods in which a new token can be minted:
    // (1) direct mint, if the universal already exists -- "direct"
    // (2) mint by succession -- "succession"
    // (3) mint by addition --"addition"
    // (4) mint by multiplication -- "multiplication"

    // For the generatingTokenIds section, if the method is:
    // (1) direct mint, then the generatingNumber is the Universal;
    // (2) succession, then the generatingNumber is the predecessor;
    // (3) addition, then the generatingNumber is an array of the two summing numbers;
    // (4) Multiplication, then the generatingNumber is an array of the multiplying numbers;

    struct Metadata {
        uint256 number;
        uint256 mintTime;
        uint256 order; // records which instance of a universal a token is
        string method;
        uint256 generatingTokenId1;
        uint256 generatingTokenId2;
        // uint256[2] generatingTokenIds;
    }

    // maps a
    mapping(uint256 => mapping(uint256 => uint256))
        public num_to_particularsList; // this maps a number to its own list of particulars, which is itself is a mapping from orders to tokenIds

    mapping(uint256 => mapping(uint256 => bool))
        public num_to_activeParticularsList; // this maps a number to its own list of active particulars, which itself a mapping from tokenIds to bools

    mapping(uint256 => Metadata) public tokenId_to_metadata; // this is where metadata of a token is stored
    mapping(uint256 => Universal) public num_to_universal; //  this is where Universals are stored

    mapping(uint256 => uint256) public tokenId_to_balances; // this maps tokenId to balances
    mapping(uint256 => bool) public tokenId_active;

    function Time() public view returns (uint256 timeCreated) {
        timeCreated = block.timestamp;
        return timeCreated;
    }

    function isUniversal(uint256 tokenId) public view returns (bool) {
        return (num_to_universal[tokenId_to_metadata[tokenId].number].tokenId ==
            tokenId);
    }

    function universalExists(uint256 num) public view returns (bool) {
        Universal memory universal = num_to_universal[num];
        return (universal.tokenId != 0);
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Taxation Policy Setting
    //////////////////////////////////////////////////////////////////////////////////////////

    uint256 public treasuryBalance;
    uint256 public paymentToTreasury;
    uint256 public cut;

    mapping(uint256 => uint256) public universal_to_directTax; // in gwei
    mapping(uint256 => uint256) public universal_to_additionTax; // in gwei
    mapping(uint256 => uint256) public universal_to_multiplicationTax; // in gwei
    mapping(uint256 => uint256) public universal_to_exponentiationTax; // in gwei
    mapping(uint256 => uint256) public universal_to_subtractionTax; // in gwei

    // mapping(uint256 => uint256) public universalToBalance;

    function setCut(uint256 bp) public onlyOwner {
        // cut is applied to all
        // the treasury tax is set in terms of basis points
        // The tax can range from 0 to 100*10000 = 1,000,000 (which amounts to 100%)
        require(bp >= 0, "negative taxes are not allowed!");
        require(bp <= 1000000, "tax is more than 100%!");
        cut = bp;
    }

    function withdrawTreasury(uint256 amount, address to) public onlyOwner {
        require(
            amount <= treasuryBalance,
            'you"re withdrawing more than the treasury!'
        );
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, 'the withdrawal didn"t go through');
        if (success) {
            treasuryBalance = treasuryBalance - amount;
        }
    }

    uint256 public mintBySuccessionFee;

    function set_mint_by_succession_fee(
        uint256 new_succession_fee
    ) public onlyOwner {
        mintBySuccessionFee = new_succession_fee;
    }

    uint256 public activeParticulars;

    function withdrawFromParticular(uint256 tokenId) public nonReentrant {
        if (msg.sender != ownerOf(tokenId)) {
            revert NotOwnerOfToken();
        }
        if (!tokenId_active[tokenId]) {
            revert ParticularEmptiedAlready();
        }
        if (tokenId_to_balances[tokenId] == 0) {
            revert NothingToWithdraw();
        }
        if (isUniversal(tokenId)) {
            revert UniversalPretendingToBeUniversal();
        }
        uint256 num = tokenId_to_metadata[tokenId].number;

        (bool success, ) = payable(msg.sender).call{
            value: tokenId_to_balances[tokenId]
        }("");
        require(success, 'the withdrawal didn"t go through');
        if (success) {
            tokenId_to_balances[tokenId] == 0;
            num_to_activeParticularsList[num][tokenId] = false;
            num_to_universal[num].activeParticulars -= 1;
        }
    }

    function getTax(
        uint256 targetNum,
        address maker,
        string memory method
    ) public returns (uint256 amount) {
        address owner = _ownerOf[num_to_universal[targetNum].tokenId];
        // address owner = _ownerOf[universal_to_tokenId[targetNum]];

        // if owner == address(0) then it means a Universal is being minted
        // if maker == owner then it means it's the owner himself minting
        if (owner == address(0) || maker == owner) {
            return 0;
        } else {
            if (StringManipulations.stringsEq(method, "direct")) {
                return universal_to_directTax[targetNum];
            } else if (StringManipulations.stringsEq(method, "succession")) {
                return mintBySuccessionFee;
            } else if (StringManipulations.stringsEq(method, "addition")) {
                return universal_to_additionTax[targetNum];
            } else if (
                StringManipulations.stringsEq(method, "multiplication")
            ) {
                return universal_to_multiplicationTax[targetNum];
            } else if (
                StringManipulations.stringsEq(method, "exponentiation")
            ) {
                return universal_to_exponentiationTax[targetNum];
            } else if (StringManipulations.stringsEq(method, "subtraction")) {
                return universal_to_subtractionTax[targetNum];
            }
        }
    }

    //  if there is no fallback function, no payable function will work
    fallback() external payable {}

    function sendViaCall() public payable returns (bool) {
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = payable(address(this)).call{
            value: msg.value
        }("");
        require(sent, "Failed to send Ether");
        return sent;
    }

    mapping(uint256 => uint256) public balances;

    // Fallback function is called when msg.data is not empty

    // function withdrawUniversalOwnerBalance(
    //     uint256 num,
    //     uint256 tokenId1,
    //     uint256 tokenId2
    // ) public nonReentrant {
    //     uint256 universal_tokenId = num_to_universal[num].tokenId;
    //     address universalOwner = ownerOf(universal_tokenId);

    //     if (msg.sender != universalOwner) {
    //         revert NotOwnerOfUniversal();
    //     }
    //     require(
    //         tokenId_to_balances[universal_tokenId] > 0,
    //         'there"s no money for you withdraw!'
    //     );

    //     if (isUniversal(tokenId1) || isUniversal(tokenId2)) {
    //         revert BurningAUniversal();
    //     }

    //     require(
    //         tokenId_to_metadata[tokenId1].number != 1,
    //         "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
    //     );
    //     require(
    //         tokenId_to_metadata[tokenId2].number != 1,
    //         "Cheeky! 1 is coprime with everything yes, but not allowed for our purposes!"
    //     );

    //     if (
    //         !areCoprime(num, tokenId_to_metadata[tokenId1].number) ||
    //         !areCoprime(num, tokenId_to_metadata[tokenId2].number) ||
    //         !areCoprime(
    //             tokenId_to_metadata[tokenId1].number,
    //             tokenId_to_metadata[tokenId2].number
    //         )
    //     ) {
    //         revert NotCoprime();
    //     }
    //     _burn(tokenId1);
    //     _burn(tokenId2);

    //     // Note that universal taxes are set in absolute amounts, not basis points.

    //     (bool success, ) = payable(universalOwner).call{
    //         value: tokenId_to_balances[universal_tokenId]
    //     }("");
    //     require(success, 'it didn"t go through');
    //     if (success) {
    //         tokenId_to_balances[universal_tokenId] = 0;
    //     }
    // }

    // this is for all tokens, Universals and Particular
    mapping(uint256 => address) tokenId_to_address_withdrawal_rights;
    mapping(uint256 => uint256) tokenId_to_assignment_time_of_withdrawal_rights;
    mapping(uint256 => uint256) tokenId_to_withdrawal_rights_expiry_time;

    // mapping(uint256 => uint256) tokenId_to_balances;

    function assignUniversalWithdrawalRights(
        uint256 num,
        address newRightsHolder,
        uint256 time
    ) public onlyUniversalOwner(num) returns (bool success) {
        uint256 tokenId = num_to_universal[num].tokenId;
        require(tokenId_to_assignment_time_of_withdrawal_rights[tokenId] == 0);
        require(tokenId_to_withdrawal_rights_expiry_time[tokenId] == 0);
        require(time > 0);

        // needs some good logic governing the circumstances in which you can assign new rights;
        tokenId_to_address_withdrawal_rights[tokenId] = newRightsHolder;
        tokenId_to_assignment_time_of_withdrawal_rights[tokenId] = block
            .timestamp;
        tokenId_to_withdrawal_rights_expiry_time[tokenId] = time;
        return true;
    }

    function revokeUniversalWithdrawalRights(
        uint256 num
    ) public onlyUniversalOwner(num) returns (bool success) {
        uint256 tokenId = num_to_universal[num].tokenId;
        require(
            block.timestamp -
                tokenId_to_assignment_time_of_withdrawal_rights[tokenId] >
                tokenId_to_withdrawal_rights_expiry_time[tokenId]
        );
        tokenId_to_assignment_time_of_withdrawal_rights[tokenId] = 0;
        tokenId_to_withdrawal_rights_expiry_time[tokenId] = 0;
        tokenId_to_address_withdrawal_rights[tokenId] = address(0);
        return true;
    }

    // onlyUniversalRightsHolder(uid)
    function withdrawFromUniversal(
        uint256 num // universals use num, particulars use tokenId
    ) public onlyUniversalRightsHolder(num) returns (bool success) {
        uint256 uid = num_to_universal[num].tokenId;
        address rightsHolder = tokenId_to_address_withdrawal_rights[uid];
        address universalHolder = ownerOf(uid);

        if (rightsHolder == address(0)) {
            rightsHolder = universalHolder;
        }

        (bool _success, ) = rightsHolder.call{value: tokenId_to_balances[uid]}(
            ""
        );
        require(_success, "The withdrawal didn't go through");
        if (_success) {
            tokenId_to_balances[uid] = 0;
            return true;
        } else {
            return false;
        }
    }

    modifier onlyUniversalRightsHolder(uint256 num) {
        uint256 uid = num_to_universal[num].tokenId;
        address rightsHolder = tokenId_to_address_withdrawal_rights[uid];
        address universalHolder = ownerOf(uid);
        if (rightsHolder == address(0)) {
            rightsHolder = universalHolder;
        }
        require(msg.sender == rightsHolder, "Invalid sender");

        _;
    }

    modifier onlyParticularRightsHolder(uint256 tokenId) {
        address rightsHolder = tokenId_to_address_withdrawal_rights[tokenId];
        address particularHolder = ownerOf(tokenId);
        if (rightsHolder == address(0)) {
            rightsHolder = particularHolder;
        }
        require(msg.sender == particularHolder, "Invalid sender");

        _;
    }

    // // particular withdrawal rights
    // function assignParticularWithdrawalRights(
    //     uint256 tokenId,
    //     address newRightsHolder,
    //     uint256 time
    // ) public onlyTokenOwner(tokenId) returns (bool success) {
    //     require(tokenId_to_assignment_time_of_withdrawal_rights[tokenId] == 0);
    //     require(tokenId_to_withdrawal_rights_expiry_time[tokenId] == 0);
    //     require(time > 0);

    //     // needs some good logic governing the circumstances in which you can assign new rights;
    //     tokenId_to_address_withdrawal_rights[tokenId] = newRightsHolder;
    //     tokenId_to_assignment_time_of_withdrawal_rights[tokenId] = block
    //         .timestamp;
    //     tokenId_to_withdrawal_rights_expiry_time[tokenId] = time;
    //     return true;
    // }

    // function revokeParticularWithdrawalRights(
    //     uint256 tokenId
    // ) public onlyTokenOwner(tokenId) returns (bool success) {
    //     require(
    //         block.timestamp -
    //             tokenId_to_assignment_time_of_withdrawal_rights[tokenId] >
    //             tokenId_to_withdrawal_rights_expiry_time[tokenId]
    //     );
    //     tokenId_to_assignment_time_of_withdrawal_rights[tokenId] = 0;
    //     tokenId_to_withdrawal_rights_expiry_time[tokenId] = 0;
    //     tokenId_to_address_withdrawal_rights[tokenId] = address(0);
    //     return true;
    // }

    // function withdrawFromParticular(
    //     uint256 tokenId
    // ) public returns (bool success) {
    //     address rightsHolder = tokenId_to_address_withdrawal_rights[tokenId];
    //     address particularHolder = ownerOf(tokenId);
    //     require(
    //         msg.sender == rightsHolder || msg.sender == particularHolder,
    //         "Invalid sender"
    //     );

    //     if (rightsHolder == address(0)) {
    //         rightsHolder = particularHolder;
    //     }

    //     (bool _success, ) = rightsHolder.call{
    //         value: tokenId_to_balances[tokenId]
    //     }("");
    //     require(_success, "The withdrawal didn't go through");
    //     if (_success) {
    //         tokenId_to_balances[tokenId] = 0;
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }

    function gcd(uint a, uint b) private pure returns (uint) {
        if (b == 0) {
            return a;
        }
        return gcd(b, a % b);
    }

    function areCoprime(uint a, uint b) private pure returns (bool) {
        return gcd(a, b) == 1;
    }

    error BurningAUniversal();
    error NotOwnerOfUniversal();
    error NotCoprime();
    error SettingNegativeTax();

    function setDirectMintTax(
        uint256 num,
        uint256 amount // in gwei
    ) public onlyUniversalRightsHolder(num) {
        if (amount < 0) {
            revert SettingNegativeTax();
        }
        console.log("here!");
        universal_to_directTax[num] = amount;
        console.log(universal_to_directTax[num]);
    }

    modifier onlyUniversalOwner(uint256 num) {
        // console.log(ownerOf(num_to_universal[num].tokenId), msg.sender);
        require(
            msg.sender == ownerOf(num_to_universal[num].tokenId),
            "Not owner of universal"
        );
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(msg.sender == ownerOf(tokenId), "Not owner of token");
        _;
    }

    modifier notBurningAUniversal(uint256 tokenId) {
        require(!isUniversal(tokenId), "BurningAUniversal");
        _;
    }

    function setMintByAdditionTax(
        uint256 num,
        uint256 tokenId1,
        uint256 tokenId2 // in 10000000000000 wei (10000 gwei)
    )
        public
        onlyUniversalOwner(num)
        notBurningAUniversal(tokenId1)
        notBurningAUniversal(tokenId2)
    {
        uint256 n1 = tokenId_to_metadata[tokenId1].number;
        uint256 n2 = tokenId_to_metadata[tokenId2].number;
        universal_to_additionTax[num] = (n1 + n2) * 10000000000000; //
        _burn(tokenId1);
        _burn(tokenId2);
    }

    function setMintByMultiplicationTax(
        uint256 num,
        uint256 tokenId1,
        uint256 tokenId2 // in 10000000000000 wei (10000 gwei)
    )
        public
        onlyUniversalOwner(num)
        notBurningAUniversal(tokenId1)
        notBurningAUniversal(tokenId2)
    {
        uint256 n1 = tokenId_to_metadata[tokenId1].number;
        uint256 n2 = tokenId_to_metadata[tokenId2].number;
        universal_to_multiplicationTax[num] = (n1 * n2) * 10000000000000; //
        _burn(tokenId1);
        _burn(tokenId2);
    }

    function setMintByExponentiationTax(
        uint256 num,
        uint256 tokenId1,
        uint256 tokenId2 // in 10000000000000 wei (10000 gwei)
    )
        public
        onlyUniversalRightsHolder(num)
        notBurningAUniversal(tokenId1)
        notBurningAUniversal(tokenId2)
    {
        uint256 n1 = tokenId_to_metadata[tokenId1].number;
        uint256 n2 = tokenId_to_metadata[tokenId2].number;
        universal_to_exponentiationTax[num] = (n1 ** n2) * 10000000000000; //
        _burn(tokenId1);
        _burn(tokenId2);
    }

    function setMintBySubtractionTax(
        uint256 num,
        uint256 tokenId1,
        uint256 tokenId2 // in 10000000000000 wei (10000 gwei)
    )
        public
        onlyUniversalRightsHolder(num)
        notBurningAUniversal(tokenId1)
        notBurningAUniversal(tokenId2)
    {
        uint256 n1 = tokenId_to_metadata[tokenId1].number;
        uint256 n2 = tokenId_to_metadata[tokenId2].number;
        require(n1 > n2, "Tax cannot be negative");
        universal_to_exponentiationTax[num] = (n1 - n2) * 10000000000000; //
        _burn(tokenId1);
        _burn(tokenId2);
    }

    function getPrimesFromNum(
        uint256 num
    ) public view returns (uint256[] memory primes) {
        uint256[] memory primes = num_to_universal[num].primes;
        return primes;
    }

    function composeMetadata(
        uint256 targetNum,
        string memory method,
        uint256 generatingTokenId1,
        uint256 generatingTokenId2,
        uint256 tokenId
    ) private {
        if (!universalExists(targetNum)) {
            uint256[] memory primes = factorise(targetNum);
            num_to_universal[targetNum] = Universal(
                targetNum,
                1,
                0,
                tokenId,
                // true,
                primes
            );
            tokenId_to_metadata[tokenId] = Metadata(
                targetNum,
                Time(),
                1,
                method,
                generatingTokenId1,
                generatingTokenId2
            );
            // universal_to_tokenId[targetNum] = tokenId;
        } else {
            uint256 instances = getInstances(targetNum);
            num_to_universal[targetNum].instances += 1;
            num_to_universal[targetNum].activeParticulars += 1;
            uint256 order = instances + 1;
            num_to_particularsList[targetNum][order] = tokenId;
            num_to_activeParticularsList[targetNum][tokenId] = true;

            uint256 mintTime = Time();
            tokenId_to_metadata[tokenId] = Metadata(
                targetNum,
                mintTime,
                order,
                method,
                generatingTokenId1,
                generatingTokenId2
            );
        }
    }

    function getInstances(uint256 num) public view returns (uint256 instances) {
        instances = num_to_universal[num].instances;
        return instances;
    }

    error InsufficientPayment();
    error UnableToRefund();
    error NotOwnerOfToken();
    error ParticularEmptiedAlready();
    error NothingToWithdraw();
    error UniversalPretendingToBeUniversal();

    function mintNumber(
        address maker,
        uint256 targetNum,
        string memory method,
        uint256 generatingTokenId1,
        uint256 generatingTokenId2,
        uint256 fee
    ) public nonReentrant returns (uint256 newTokenId) {
        // require(
        //     keccak256(abi.encodePacked(numToNestedString(targetNum))) ==
        //         keccak256(abi.encodePacked(targetNumNestedString)),
        //     "the target and its nested string disagree"
        // );
        uint256 tax = getTax(targetNum, maker, method);

        if (fee < tax) {
            revert InsufficientPayment();
        }
        uint256 refund = (tax == 0 ? fee : fee - tax);

        console.log("refund amount:", refund);
        console.log("fee amount:", fee);
        console.log("tax amount:", tax);
        console.log("this address balance:", address(this).balance);
        console.log("maker is:", maker);
        console.log("msg.sender is:", msg.sender);

        (bool refunded, ) = (payable(maker)).call{value: refund}("");

        if (!refunded) {
            revert UnableToRefund();
        } else {
            currentId = currentId + 1;
            composeMetadata(
                targetNum,
                method,
                generatingTokenId1,
                generatingTokenId2,
                currentId
            );
            // recall that universal taxes are set as whole numbers, not percentages
            uint256 universal_tokenId = num_to_universal[targetNum].tokenId;
            // uint256 universal_tokenId = universal_to_tokenId[targetNum];
            tokenId_to_balances[universal_tokenId] +=
                (tax * (1000000 - cut)) /
                1000000;
            // universalToBalance[targetNum] += (tax * (1000000 - cut)) / 1000000;
            uint256 activeParticulars = num_to_universal[targetNum]
                .activeParticulars;
            if (activeParticulars != 0) {
                uint256 distribute_to_active_particulars = (tax * cut * 80) /
                    (100 * 1000000 * activeParticulars); // 80% of the cut goes to previous particular holders; 20% goes to the treasury
                // looping over the active particulars
                for (uint256 i = 0; i < activeParticulars; i++) {
                    if (num_to_activeParticularsList[targetNum][i] == true) {
                        uint256 ith_particular = i;
                        tokenId_to_balances[
                            ith_particular
                        ] += distribute_to_active_particulars;
                    }
                    // uint256 ith_particular = num_to_activeParticularsList[
                    //     targetNum
                    // ][i];
                }
                num_to_activeParticularsList[targetNum][currentId] = true;

                num_to_universal[targetNum].activeParticulars += 1;
            }
            treasuryBalance += (tax * cut * 20) / (100 * 1000000);

            _safeMint(maker, currentId);

            return currentId;
        }
    }

    error NoNegativeNumbers();

    error notOwnerOftheToken();

    //////////////////////////////////////////////////////////////////////////////////////////
    // Minting Functionality
    //////////////////////////////////////////////////////////////////////////////////////////

    function mintZero() public payable returns (uint256 newTokenId) {
        uint256[2] memory generatingNumbers;
        uint256 newTokenId = mintNumber(
            msg.sender,
            0,
            "genesis",
            0,
            0,
            msg.value
        );

        return newTokenId;
    }

    function mintBySuccession(
        uint256 oldTokenId
    ) public payable returns (uint256 newTokenId) {
        // checks if num is new, if new, increases its order to 1 (first!)
        // if not new, does nothing and goes straight next

        if (ownerOf(oldTokenId) != msg.sender) {
            revert notOwnerOftheToken();
        }
        uint256 n = tokenId_to_metadata[oldTokenId].number;

        newTokenId = mintNumber(
            msg.sender,
            n + 1,
            "succession",
            oldTokenId,
            0,
            msg.value
        );

        return newTokenId;
    }

    function mintByDirect(
        uint256 num
    ) public payable returns (uint256 newTokenId) {
        require(
            universalExists(num) == true,
            "the universal of the predecessor has not been made yet"
        );
        uint256 universalTokenId = num_to_universal[num].tokenId;
        newTokenId = mintNumber(
            msg.sender,
            num,
            "direct",
            universalTokenId,
            0,
            msg.value
        );
        return newTokenId;
    }

    function mintByAddition(
        uint256 oldTokenId1,
        uint256 oldTokenId2
    ) public payable returns (uint256 newTokenId) {
        require(
            ((ownerOf(oldTokenId1) == msg.sender) &&
                (ownerOf(oldTokenId2) == msg.sender)),
            'you don"t own the tokens you"re adding'
        );
        uint256 n1 = tokenId_to_metadata[oldTokenId1].number;
        uint256 n2 = tokenId_to_metadata[oldTokenId2].number;

        newTokenId = mintNumber(
            msg.sender,
            n1 + n2,
            "addition",
            oldTokenId1,
            oldTokenId2,
            msg.value
        );
        require(ownerOf(newTokenId) == msg.sender, "not minted");

        if (!isUniversal(oldTokenId1)) {
            _burn(oldTokenId1);
        }
        if (!isUniversal(oldTokenId2)) {
            _burn(oldTokenId2);
        }

        return newTokenId;
    }

    function mintByMultiplication(
        uint256 oldTokenId1,
        uint256 oldTokenId2
    ) public payable returns (uint256 newTokenId) {
        require(
            ((ownerOf(oldTokenId1) == msg.sender) &&
                (ownerOf(oldTokenId2) == msg.sender)),
            'you don"t own the tokens you"re multiplying'
        );
        uint256 n1 = tokenId_to_metadata[oldTokenId1].number;
        uint256 n2 = tokenId_to_metadata[oldTokenId2].number;

        newTokenId = mintNumber(
            msg.sender,
            n1 * n2,
            "multiplication",
            oldTokenId1,
            oldTokenId2,
            msg.value
        );
        require(ownerOf(newTokenId) == msg.sender, "not minted");
        if (!isUniversal(oldTokenId1)) {
            _burn(oldTokenId1);
        }
        if (!isUniversal(oldTokenId2)) {
            _burn(oldTokenId2);
        }
        return newTokenId;
    }

    function mintByExponentiation(
        uint256 oldTokenId1,
        uint256 oldTokenId2
    ) public payable returns (uint256 newTokenId) {
        require(
            ((ownerOf(oldTokenId1) == msg.sender) &&
                (ownerOf(oldTokenId2) == msg.sender)),
            "you don't own the tokens you're exponentiating"
        );

        uint256 n1 = tokenId_to_metadata[oldTokenId1].number;
        uint256 n2 = tokenId_to_metadata[oldTokenId2].number;
        uint256[2] memory generatingNumbers;
        generatingNumbers[0] = n1;
        generatingNumbers[1] = n2;

        newTokenId = mintNumber(
            msg.sender,
            n1 ** n2,
            "exponentiation",
            oldTokenId1,
            oldTokenId2,
            msg.value
        );
        require(ownerOf(newTokenId) == msg.sender, "not minted");
        if (!isUniversal(oldTokenId1)) {
            _burn(oldTokenId1);
        }
        if (!isUniversal(oldTokenId2)) {
            _burn(oldTokenId2);
        }
        return newTokenId;
    }

    function mintBySubtraction(
        uint256 oldTokenId1,
        uint256 oldTokenId2
    ) public payable returns (uint256 newTokenId) {
        require(
            ((ownerOf(oldTokenId1) == msg.sender) &&
                (ownerOf(oldTokenId2) == msg.sender)),
            "you don't own the tokens you're subtracting"
        );
        uint256 n1 = tokenId_to_metadata[oldTokenId1].number;
        uint256 n2 = tokenId_to_metadata[oldTokenId2].number;

        if (n1 < n2) {
            revert NoNegativeNumbers();
        }
        int256 _n = int(n1) - int(n2);
        console.log(uint256(_n), "look here at subtraction!");
        uint256 n = uint256(_n);
        uint256[2] memory generatingNumbers;
        generatingNumbers[0] = n1;
        generatingNumbers[1] = n2;

        newTokenId = mintNumber(
            msg.sender,
            n,
            "subtraction",
            oldTokenId1,
            oldTokenId2,
            msg.value
        );

        require(ownerOf(newTokenId) == msg.sender, "not minted");
        if (!isUniversal(oldTokenId1)) {
            _burn(oldTokenId1);
        }
        if (!isUniversal(oldTokenId2)) {
            _burn(oldTokenId2);
        }
        return newTokenId;
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Graph Drawing
    //////////////////////////////////////////////////////////////////////////////////////////

    // https://ethereum.stackexchange.com/questions/132239/how-to-compare-string-and-bytes32-in-an-optimal-way
    function toByte(uint8 _uint8) private pure returns (bytes1) {
        if (_uint8 < 10) {
            return bytes1(_uint8 + 48);
        } else {
            return bytes1(_uint8 + 87);
        }
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) private pure returns (string memory) {
        uint8 i = 0;
        bytes memory bytesArray = new bytes(64);
        uint256 l = bytesArray.length;
        for (i = 0; i < l; ++i) {
            uint8 _f = uint8(_bytes32[i / 2] & 0x0f);
            uint8 _l = uint8(_bytes32[i / 2] >> 4);

            bytesArray[i] = toByte(_l);
            ++i;
            bytesArray[i] = toByte(_f);
        }
        return string(bytesArray);
    }

    function makeCircle(uint256 num) public view returns (bytes memory circle) {
        string[13] memory colours = [
            "red",
            "cyan",
            "deeppink",
            "magenta",
            "lime",
            "blue",
            "white",
            "gold",
            "aqua",
            "yellow",
            "orange",
            "greenyellow",
            "dodgerblue"
        ];

        uint256 rand = uint256(keccak256(abi.encodePacked("circle", num)));
        string memory colour = colours[rand % colours.length];
        return
            abi.encodePacked(
                "<circle cx='5000' cy='5000' r='5000' fill='",
                colour,
                "'/>"
            );
    }

    function rotate(
        uint256 many2Pis,
        uint256 manyethsOf2Pis,
        bytes memory image
    ) public view returns (bytes memory rotated) {
        return
            abi.encodePacked(
                "<g transform='rotate(",
                divReturnDecimal(360 * many2Pis, manyethsOf2Pis),
                ",5000,5000)'>",
                image,
                "</g>"
            );
    }

    function scale(
        uint256 up,
        uint256 down,
        bytes memory image
    ) public view returns (bytes memory scaled) {
        return
            abi.encodePacked(
                "<g transform='translate(",
                divReturnDecimal((down - up) * 5000, down),
                "), scale(",
                divReturnDecimal(up, down),
                ")'>",
                image,
                "</g>"
            );
    }

    function makePolygon(
        uint256 prime
    ) public view returns (bytes memory polygon) {
        bytes memory shape = bytes("");
        uint256 _prime = prime;
        if (_prime == 2) {
            for (uint256 i = 0; i < _prime; ++i) {
                bytes memory incompleteShape = rotate(
                    i,
                    _prime,
                    scale(1, _prime + 1, makeCircle(i))
                );
                shape = abi.encodePacked(shape, incompleteShape);
            }
        } else if (_prime == 3) {
            for (uint256 i = 0; i < _prime; ++i) {
                bytes memory incompleteShape = rotate(
                    i,
                    _prime,
                    scale(1, _prime, makeCircle(i))
                );
                shape = abi.encodePacked(shape, incompleteShape);
            }
        } else {
            for (uint256 i = 0; i < _prime; ++i) {
                uint256 x = _prime * i;
                bytes memory incompleteShape = rotate(
                    i,
                    _prime,
                    scale(1, _prime - 1, makeCircle(x))
                );
                shape = abi.encodePacked(shape, incompleteShape);
            }
        }
        return shape;
    }

    function composeShape(
        uint256 prime,
        bytes memory image
    ) public view returns (bytes memory shape) {
        bytes memory shape = bytes("");
        uint256 _prime = prime;
        uint256 up;
        uint256 down;

        if (_prime == 2) {
            up = 1;
            down = _prime + 1;
        } else if (_prime == 3) {
            up = 1;
            down = _prime - 1;
        } else {
            up = _prime - 1;
            down = 2 * _prime + 1;
        }
        bytes memory scaled_image = scale(up, down, image);

        for (uint256 i = 0; i < _prime; ++i) {
            bytes memory incompleteShape = rotate(i, _prime, scaled_image);
            shape = abi.encodePacked(shape, incompleteShape);
        }

        return shape;
    }

    function wrapCanvas(
        bytes memory stuffInside
    ) private pure returns (string memory drawing) {
        return
            string(
                abi.encodePacked(
                    "<svg xmlns='http://www.w3.org/2000/svg' width='10000' height='10000' style='background-color:black'>",
                    '<g transform="translate(1000,1000) scale(0.8)">',
                    stuffInside,
                    "</g>",
                    "</svg>"
                )
            );
    }

    function drawUniversal(
        uint256 num
    ) public view returns (string memory image) {
        bytes memory shape = "";
        uint256 _num = num;
        // uint256[] memory primes = factorise(_num);

        uint256[] memory primes = num_to_universal[num].primes;
        if (_num == 0) {
            return (wrapCanvas(shape));
        } else if (_num == 1) {
            bytes memory head = abi.encodePacked(
                "<g transform='translate(0,2500)'><g transform='translate(1000,1000) scale(0.8)'>"
            );
            bytes memory tail = abi.encodePacked("</g></g>");
            return wrapCanvas(abi.encodePacked(head, makeCircle(_num), tail));
        } else {
            // console.log("we are here!");
            // console.log("the length of primes is:", primes.length);
            uint256 l = primes.length;
            for (uint256 i = 0; i < l; ++i) {
                if (i == 0) {
                    shape = makePolygon(primes[i]);
                    // console.log("i ==0!");
                    // console.log(primes[i]);
                } else {
                    // console.log("i!=0!");
                    if (primes[i] != 0) {
                        // console.log("composing the shape!");
                        shape = composeShape(primes[i], shape);
                    }
                }
                // console.log(primes[i]);
            }
        }

        return (wrapCanvas(shape));
    }

    function drawParticular(
        uint256 num
    ) public view returns (string memory image) {
        string memory num_str = num.toString();
        uint256 length = StringManipulations.utfStringLength(num_str);

        uint256 fontSize = 1000;
        if (length <= 10) {
            fontSize = 1000;
        } else if (length <= 20) {
            fontSize = 800;
        } else if (length <= 30) {
            fontSize = 600;
        } else if (length <= 40) {
            fontSize = 400;
        } else {
            string memory first = StringManipulations.substring(num_str, 0, 9);
            string memory last = StringManipulations.substring(
                num_str,
                length - 9,
                length
            );
            return (
                wrapCanvas(
                    abi.encodePacked(
                        '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="400">',
                        first,
                        "......",
                        last,
                        '</text><text x="50%" y="60%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="400">Total:',
                        length,
                        " digits</text>"
                    )
                )
            );
        }

        return (
            wrapCanvas(
                abi.encodePacked(
                    '<text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" class="base" font-size="',
                    fontSize.toString(),
                    '">',
                    num_str,
                    "</text>"
                )
            )
        );
    }

    // The divReturnDecimal() function takes two unsigned integers x and y as input parameters and returns a string representation of the decimal result of the division (x / y). The function calculates the integer part and the decimal part (up to 18 decimal places) separately and concatenates them into a single string.

    // Here's a step-by-step explanation of the code:

    // Initialize variables _x and _y with the input values x and y.
    // Calculate the integer part of the division (I) using _x / _y.
    // Initialize variables d and s to store the count of decimal places and the decimal part of the result, respectively.
    // If the division has a remainder (_x % _y != 0), the loop calculates the decimal part of the result up to 18 decimal places or until there's no remainder left.
    // Calculate the number of trailing zeros that should be added after the decimal point, based on the input values x and y.
    // Create a zeroString by concatenating the required number of zeros.
    // Concatenate the integer part, the decimal point, zeroString, and the calculated decimal part s into a single string decimal.
    // Return the decimal string as the final result.
    // This function is useful when you need to perform division between unsigned integers and get the result as a string with decimal places, up to a maximum of 18.

    function divReturnDecimal(
        uint256 x,
        uint256 y
    ) public pure returns (bytes memory) {
        uint256 _x = x;
        uint256 _y = y;

        uint256 d = 0; // decimals
        uint256 s = 0; // decimal digits
        uint256 I = _x / _y; // integers

        if (_x % _y != 0) {
            while (_x % _y != 0 && d <= 18) {
                s = s * 10 + (_x * 10) / _y;

                _x = (_x * 10) % _y;

                d += 1;
            }
        }

        uint256 zeros = (
            (_x % _y == 0)
                ? 0
                : (
                    (_x % 10 == 0 && _y % 10 == 0)
                        ? StringManipulations.utfStringLength(_y.toString()) -
                            StringManipulations.utfStringLength(_x.toString())
                        : 0
                )
        );

        // string memory zeroString = "";
        bytes memory zeroString = bytes("");

        if (zeros != 0) {
            for (uint256 i = 0; i < zeros; ++i) {
                zeroString = abi.encodePacked(
                    zeroString,
                    uint256(0).toString()
                );
            }
        }

        bytes memory decimal = abi.encodePacked(
            I.toString(),
            ".",
            zeroString,
            (s % (10 ** d)).toString()
        );
        return decimal;
    }

    function factorise(uint256 num) public view returns (uint256[] memory) {
        if (num <= 1) {
            uint256[] memory factors = new uint256[](num == 0 ? 0 : 1);
            if (num == 1) {
                factors[0] = 1;
            }
            return factors;
        }

        uint256 n = num;
        uint256 maxNumberOfPrimes = (n.fromUInt().sqrt()).toUInt() + 1;
        uint256[] memory factors = new uint256[](maxNumberOfPrimes);
        uint256 k = 0;

        while (n != 1) {
            uint256 p = 0;
            uint256 eights;
            uint256 fours;

            // Figure out the highest power p of 2 that divides n.
            for (; n % 2 == 0; n /= 2) {
                p++;
            }

            if (p == 1) {
                factors[k++] = 2;
            } else {
                eights = p / 3;
                fours = (p - (eights * 3)) / 2;

                for (uint256 i = 0; i < eights; ++i) {
                    factors[k++] = 8;
                }
                for (uint256 i = 0; i < fours; ++i) {
                    factors[k++] = 4;
                }
            }

            for (uint256 i = 3; i <= maxNumberOfPrimes; ++i) {
                while (n % i == 0) {
                    factors[k++] = i;
                    n /= i;

                    if (!universalExists(n) && n != 1) {
                        uint256[]
                            memory alreadyComputedFactorisation = num_to_universal[
                                n
                            ].primes;
                        uint256 l = alreadyComputedFactorisation.length;
                        uint256[] memory allFactors = new uint256[](k + l);

                        for (uint256 j = 0; j < k; j++) {
                            allFactors[j] = factors[j];
                        }

                        for (uint256 j = 0; j < l; j++) {
                            if (alreadyComputedFactorisation[j] != 1) {
                                allFactors[
                                    k + j
                                ] = alreadyComputedFactorisation[j];
                            }
                        }

                        return allFactors;
                    }
                }
            }

            if (n > 2) {
                // This is where the number is prime
                factors[k++] = n;
                n = 1; // Set n to 1 to exit the while loop
            }
        }

        // Resize the array to remove unused slots
        uint256[] memory resizedFactors = new uint256[](k);
        for (uint256 i = 0; i < k; ++i) {
            resizedFactors[i] = factors[i];
        }

        return resizedFactors;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        } else {
            if (isUniversal(tokenId)) {
                string memory tokenURI = drawUniversal(
                    tokenId_to_metadata[tokenId].number
                );
                return tokenURI;
            } else {
                string memory tokenURI = drawParticular(
                    tokenId_to_metadata[tokenId].number
                );
                return tokenURI;
            }
        }
    }

    error NonExistentTokenURI();
}
