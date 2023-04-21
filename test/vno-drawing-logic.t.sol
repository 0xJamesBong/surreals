// // https://github.com/foundry-rs/forge-std

// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.10;

// import "forge-std/Test.sol";
// import "../src/vno.sol";

// // import "@openzeppelin/contracts/utils/Strings.sol";

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
// }
