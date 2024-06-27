// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MorphFaucet} from "../src/Faucet.sol";

contract CounterScript is Script {
    function setUp() public {}

      function run() public returns(MorphFaucet) {
        vm.startBroadcast();
       MorphFaucet morphFaucet = new MorphFaucet(86400);

        vm.stopBroadcast();
        return morphFaucet;
    }
}
