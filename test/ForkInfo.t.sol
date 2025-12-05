// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract ForkInfoTest is Test {
    function testForkInfo() public {
        emit log_named_uint("chainid", block.chainid);
        emit log_named_uint("block number", block.number);
    }
}
