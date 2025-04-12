// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Script, console} from "forge-std/Script.sol";
import {NFTCollection} from "../test/unit/contract/NFT.sol";
import {FanCommunity} from "../test/unit/contract/getstarMock.sol";
import {generator} from "../src/ExternalContracts/Generator.sol";
import {eternal} from "../test/unit/contract/eternalMock.sol";
import {Token} from "../src/ExternalContracts/token.sol";

contract NFTScript is Script {
    function runToken(uint256 initialSupply) external returns (Token) {
        vm.startBroadcast();
        Token token = new Token(initialSupply);
        vm.stopBroadcast();

        return token;
    }

    function runMock() external returns (FanCommunity) {
        vm.startBroadcast();
        FanCommunity fanCommunity = new FanCommunity();
        vm.stopBroadcast();

        return fanCommunity;
    }

    function runGenerator(address usdt) external returns (generator) {
        vm.startBroadcast();
        generator Generator = new generator(usdt);
        vm.stopBroadcast();

        return Generator;
    }

    function runeternalMock(
        address usdt,
        address gen
    ) external returns (eternal) {
        vm.startBroadcast();
        eternal Eternal = new eternal(usdt, gen);
        vm.stopBroadcast();

        return Eternal;
    }

    function runNFTCollection(
        address eternalmock,
        address token,
        address _generator,
        address _fan
    ) external returns (NFTCollection) {
        vm.startBroadcast();
        NFTCollection NFTcollection = new NFTCollection(
            _generator,
            token,
            eternalmock,
            _fan
        );
        vm.stopBroadcast();

        return NFTcollection;
    }
}
