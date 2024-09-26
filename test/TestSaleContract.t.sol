// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {SBTContract} from "../src/SBTContract.sol";
import {SBTPriceContract} from "../src/SBTPriceContract.sol";
import {SaleContract} from "../src/SaleContract.sol";

contract TestSaleContract is Test {

    IERC20 usdcContract;
    SBTContract tokenContract;
    SBTPriceContract priceContract;
    SaleContract saleContract;
    Vm.Wallet testUser = vm.createWallet("bob's wallet");

    function setUp() public {
        usdcContract = IERC20(0x28661511CDA7119B2185c647F23106a637CC074f);
        tokenContract = new SBTContract("TokenforSale", "TFS");
        priceContract = new SBTPriceContract(1000000);
        saleContract = new SaleContract();
    }

    function test_initialize() public{
        assertEq(saleContract.killSwitch(), false);
        assertEq(saleContract.owner(), address(this));
        assertEq(address(saleContract.tokenContract()), address(0));
        assertEq(address(saleContract.priceContract()), address(0));
        assertEq(address(saleContract.stableContract()), address(0x28661511CDA7119B2185c647F23106a637CC074f));
    }

    function setState() public returns(uint256 bfcPrice, uint256 usdcPrice){
        saleContract.setSBTContract(address(tokenContract));
        saleContract.setSBTPriceContract(address(priceContract));

        priceContract.setSBTPrice(200000);
        priceContract.setInterval(2000);
        bfcPrice = priceContract.getSBTPriceBFC();
        usdcPrice = priceContract.getSBTPriceUSDC();

        saleContract.setSBTContract(address(tokenContract));
        saleContract.setSBTPriceContract(address(priceContract));
        tokenContract.setSeller(address(saleContract));
    }

    // bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
    //     vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
    //     vm.expectRevert("Contract not set");
    //     vm.prank(address(0));
    //     vm.expectEmit();

    function test_setState() public {
        setState();
        saleContract.setSwitch(true);
        assertEq(saleContract.killSwitch(), true);
        assertEq(address(saleContract.tokenContract()), address(tokenContract));
        assertEq(address(saleContract.priceContract()), address(priceContract));
    }

    function test_failSetState() public{
        vm.startPrank(address(0));

        bytes4 selector = bytes4(keccak256("OwnableUnauthorizedAccount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        saleContract.setSwitch(true);
        assertEq(saleContract.killSwitch(), false);

        vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        saleContract.setSBTContract(address(tokenContract));
        assertEq(address(saleContract.tokenContract()), address(0));

        vm.expectRevert(abi.encodeWithSelector(selector, address(0)));
        saleContract.setSBTPriceContract(address(priceContract));
        assertEq(address(saleContract.priceContract()), address(0));

        vm.stopPrank();
    }

    function test_failBuySBT() public {
        vm.expectRevert("Contract not set");
        saleContract.buySBTBFC();
        vm.expectRevert("Contract not set");
        saleContract.buySBTUSDC();
    }

    function test_getPrice() public {
        setState();
        assertEq(priceContract.getSBTPriceUSDC(), 2000000);
    }

    function test_failMint() public{
        
    }

}
