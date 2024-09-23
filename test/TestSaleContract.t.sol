// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {SBTContract} from "../src/SBTContract.sol";
import {SBTPriceContract} from "../src/SBTPriceContract.sol";
import {SaleContract} from "../src/SaleContract.sol";

contract CounterTest is Test {

    IERC20 usdcContract;
    SBTContract tokenContract;
    SBTPriceContract priceContract;
    SaleContract saleContract;

    function setUp() public {
        usdcContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
        tokenContract = new SBTContract("TokenforSale", "TFS");
        priceContract = new SBTPriceContract(1000000);
        saleContract = new SaleContract();
    }

    // function beforeTestSetup(
    //     bytes4 testSelector
    // ) public pure returns (bytes[] memory beforeRt) {
    //     if (testSelector == this.testC.selector) {
    //         beforeRt = new bytes[](2);
    //         beforeRt[0] = abi.encodePacked(this.testA.selector);
    //         beforeRt[1] = abi.encodeWithSignature("setB(uint256)", 1);
    //     }
    // }

    function test_Initialize() public {
        assertEq(saleContract.killSwitch(), false);
        assertEq(saleContract.owner(), address(this));
        assertEq(address(saleContract.tokenContract()), address(0));
        assertEq(address(saleContract.priceContract()), address(0));
        assertEq(address(saleContract.stableContract()), address(0x28661511CDA7119B2185c647F23106a637CC074f));
    }

    function test_Set_state() public {
        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        // vm.expectRevert("Contract not set");
        vm.prank(address(0));
        // vm.expectEmit();
        saleContract.setSwitch(true);
        // assertEq(saleContract.killSwitch(), true);

        // saleContract.setSBTContract(testUser.address);
        // expect(await saleContract.tokenContract()).to.equal(testUser.address);

        // await saleContract.setSBTPriceContract(testUser.address);
        // expect(await saleContract.priceContract()).to.equal(testUser.address);
        
    }

    function test_error() public {
        vm.expectRevert("Contract not set");
        saleContract.buySBTBFC();
        saleContract.setSwitch(true);
    }

}
