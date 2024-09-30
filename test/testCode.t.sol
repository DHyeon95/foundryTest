// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";


contract TestContract is Test {

    string rpc;
    address usdc = 0x9039B6f30aa5bD00c303A3644c16B8Cc8031CE53;
    uint256 chainID ;

    Vm.Wallet testUser = vm.createWallet("testUser's wallet");

    struct Apple {
        string color;
        uint8 sourness;
        uint8 sweetness;
    }

    struct FruitStall {
        Apple[] apples;
        string name;
    }

    function setUp() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
    }

    function test() public{

        console.log("before : " , IERC20(usdc).balanceOf(testUser.addr));
        deal(address(usdc), testUser.addr, 100 * 10 ** IERC20(usdc).decimals()); // import StdUtils.sol first
        console.log("after : " , IERC20(usdc).balanceOf(testUser.addr));

    }

}

