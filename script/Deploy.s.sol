// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import "forge-std/Script.sol";
import {SaleContract} from "../src/SaleContract.sol";

contract Deploy is Script {

    SaleContract public saleContract ;

    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    function run() public{
        vm.startBroadcast(privateKey);
        
        saleContract = new SaleContract();

        vm.stopBroadcast();
    }
    
}