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
    address assetHolder = 0x96C8399B3611B038513Fa2Fa8920D5870c0f2390;
    Vm.Wallet testUser = vm.createWallet("testUser's wallet");

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
        assertEq(priceContract.getSBTPriceUSDC(), 200000);
    }

    function test_failMintBeforeApprve() public{
        setState();
        vm.expectRevert("ERC20: insufficient allowance");
        saleContract.buySBTUSDC();
        vm.expectRevert("ERC20: insufficient allowance");
        vm.prank(testUser.addr);
        saleContract.buySBTUSDC();
    }

    function test_mintUSDC() public{
        (, uint256 usdcPrice) = setState();
        vm.prank(assetHolder);
        usdcContract.transfer(testUser.addr, 200000000);
        vm.startPrank(testUser.addr);
        usdcContract.approve(address(saleContract), usdcPrice);
        saleContract.buySBTUSDC();
        vm.stopPrank();

        assertEq(tokenContract.balanceOf(testUser.addr), 1);
        assertEq(tokenContract.ownerOf(1), testUser.addr);
        assertEq(saleContract.count(), 1);
    }

    function test_mintBFC() public{
        (uint256 bfcPrice, ) = setState();
        
        vm.deal(testUser.addr, 10000 ether);
        vm.prank(testUser.addr);
        saleContract.buySBTBFC{value: bfcPrice}();
        
        assertEq(tokenContract.balanceOf(testUser.addr), 1);
        assertEq(tokenContract.ownerOf(1), testUser.addr);
        assertEq(saleContract.count(), 1);
    }

    function test_withdraw() public{
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        saleContract.withdrawUSDC(100);

        (, uint256 usdcPrice) = setState();
        vm.prank(assetHolder);
        usdcContract.transfer(testUser.addr, 200000000);
        vm.startPrank(testUser.addr);
        usdcContract.approve(address(saleContract), usdcPrice);
        saleContract.buySBTUSDC();
        vm.stopPrank();

        saleContract.withdrawUSDC(500);
    }

}
