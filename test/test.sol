pragma solidity 0.8.10;

import "forge-std/Test.sol";

contract ContractBTest is Test {
    uint256 testNumber;

    function setUp() public {
        testNumber = 42;
    }

    function test_NumberIs42() public {
        assertEq(testNumber, 42);
    }

    function set45() public{
        testNumber += 3;
    }

    function test_NumberIs45() public{
        set45();
        assertEq(testNumber, 45);
    }

            // vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        // vm.expectRevert("Contract not set");

    function testFail_Subtract43() public {
        testNumber -= 43;
    }
}

// Test revert with unknown error
// With custom error
// With “text” error