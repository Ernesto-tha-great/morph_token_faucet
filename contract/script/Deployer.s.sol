// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TokenFaucet} from "../src/Faucet.sol";

contract CounterScript is Script {
    function setUp() public {}

      function run() public returns(TokenFaucet) {
        vm.startBroadcast();
       TokenFaucet tokenFaucet = new TokenFaucet(1, 86400);

        vm.stopBroadcast();
        return tokenFaucet;
    }
}
