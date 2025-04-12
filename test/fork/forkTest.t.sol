// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {NFTScript} from "../../script/NFT.s.sol";
import {EternityIdentification} from "../../src/NFT.sol";
import "../../src/ExternalContracts/Eternity_Interfaces.sol";

contract NFTTest is Test {
    NFTScript deploy;
    IERC20Metadata usdt;
    EternityIdentification system;
    Igenerator Generator;
    Ieternal Eternal;
    IfanCommunity fan;

    address usdtHolder = 0xC9dA44904AD04019676319598CFbB9dABd69817E;
    address gcHolder = 0xa1340485617478F5b196669E4506b3DBE6B9D6Ea;
    address ecHolder = 0xA3BF7E8344210265416c52E1A5Ff1B312B5eAFF1;
    address fanPro = 0x2b1f3559EbBa4CeE28e3d00520a4b40cBC5cab05;
    address user = 0x1F26cb8a4A89177bb1dee58367cF6a90F12450E3;
    address user2 = address(2);
    address user3 = address(3);
    address user4 = address(4);
    address Owner;
    uint256 initialSupply = 100e18;
    uint256 private constant DECIMAl = 10 ** 18;

    function setUp() public {
        deploy = new NFTScript();
        usdt = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        Generator = Igenerator(0xD829E975B00F4cB4ccd8cEfE80525A219D2d3B15);
        fan = IfanCommunity(0xDD05ed9e4E14aD0133b285e84eCf836133FA3b7d);
        Eternal = Ieternal(0xa1340485617478F5b196669E4506b3DBE6B9D6Ea);

        system = new EternityIdentification();
        Owner = system.owner();

        ///variables from other contracts

        vm.startPrank(Generator.owner());
        Generator.changeWhitelist(Owner, true);
        vm.stopPrank();

        vm.startPrank(fan.owner());
        fan.changeAccess(address(system), true);
        vm.stopPrank();
    }

    function fundUsdt(address receiver, uint256 amount) public {
        console.log(usdt.balanceOf(usdtHolder));
        vm.prank(usdtHolder);
        usdt.transfer(receiver, amount);
    }

    function fundGc(address receiver, uint256 amount) public {
        vm.prank(gcHolder);
        Generator.transfer(receiver, amount);
    }

    function fundEc(address receiver, uint256 amount) public {
        vm.prank(ecHolder);
        Eternal.transfer(receiver, amount);
    }

    ///tests///

    function testForkBuyOption1() public {
        fundUsdt(user, 100 * 1e6);

        vm.startPrank(user);
        usdt.approve(address(system), 3 * DECIMAl);
        usdt.approve(address(Generator), 3 * DECIMAl);
        vm.stopPrank();

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(2 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user);
        system.buy("ABCDEFG", 0);
        vm.stopPrank();

        uint256 userBalanceAfter = usdt.balanceOf(user);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore - 1,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore - 1,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );

        assertEq(system.getUserNFTCount(user), 1);
        assertEq(system.usernameExistsFor("ABCDEFG"), true);
        assertEq(system.usernameToUserAddress("ABCDEFG"), user);
        assertEq(system.getUsernameByTokenId(1), "ABCDEFG");
        assertEq(system.getTokenIdByUsername("ABCDEFG"), 1);
        assertEq(system.getCurrentTokenId(), 1);
    }

    function testForkBuyOption2() public {
        fundGc(user, 10 * DECIMAl);

        vm.startPrank(user);
        Generator.approve(address(system), 10 * DECIMAl);
        vm.stopPrank();

        uint256 userBalanceBefore = Generator.balanceOf(user);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));

        vm.startPrank(user);
        system.buy("ABCDEFG", 1);
        vm.stopPrank();

        uint256 userBalanceAfter = Generator.balanceOf(user);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));

        uint256 transferFee = Generator.getTotalTransferLevy();

        assertEq(
            userBalanceBefore - userBalanceAfter,
            ((2 * DECIMAl) * 100) / 94
        );
        assertEq(
            daoBalanceAfter - daoBalanceBefore,
            (1 * DECIMAl * (1000 - transferFee)) / 1000
        );
        assertEq(
            secBalanceAfter - secBalanceBefore,
            (1 * DECIMAl * (1000 - transferFee)) / 1000
        );
        assertEq(system.getUserNFTCount(user), 1);
        assertEq(system.usernameExistsFor("ABCDEFG"), true);
        assertEq(system.usernameToUserAddress("ABCDEFG"), user);
    }

    function testForkBuyOption3() public {
        fundEc(user, 10 * DECIMAl);

        uint256 contractBalanceBefore = Eternal.balanceOf(address(system));
        uint256 userBalanceBefore = Eternal.balanceOf(user);
        uint256 daoBalanceBefore = Eternal.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 eternalEquivalent = Eternal.EterToET(2 * DECIMAl);
        uint256 eterToSend = (eternalEquivalent * 100) / 97;

        vm.startPrank(user);
        Eternal.approve(address(system), 1000e18);
        system.buy("ABCDEFG", 2);
        vm.stopPrank();

        uint256 contractBalanceAfter = Eternal.balanceOf(address(system));
        uint256 userBalanceAfter = Eternal.balanceOf(user);
        uint256 daoBalanceAfter = Eternal.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );

        vm.assertEq(contractBalanceAfter - contractBalanceBefore, 1);
        assertEq(userBalanceBefore - userBalanceAfter, eterToSend);
        assertEq(
            daoBalanceAfter - daoBalanceBefore - 3,
            ((eternalEquivalent / 2) * 97) / 100
        );

        assertEq(system.getUserNFTCount(user), 1);
        assertEq(system.usernameExistsFor("ABCDEFG"), true);
        assertEq(system.usernameToUserAddress("ABCDEFG"), user);
    }

    function testForkExceedAvailableNFTCount() public {
        fundUsdt(user, 1000e6);
        vm.startPrank(user);
        usdt.approve(address(system), 1000e6);

        system.buy("ABCDEFG", 0);
        system.buy("ABCDEFH", 0);
        system.buy("ABCDEFI", 0);
        system.buy("ABCDEFJ", 0);

        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(EternityIdentification.CannotBuyMoreNFT.selector);
        system.buy("ABCDEFK", 0);
        vm.stopPrank();
    }

    function testForlTransferToFan() public {
        vm.startPrank(fanPro);
        system.getFreeNFT("ABC");
        vm.stopPrank();

        assertEq(system.getUserNFTCount(fanPro), 0);
        assertEq(system.usernameExistsFor("ABC"), true);
        assertEq(system.usernameToUserAddress("ABC"), fanPro);
        assertEq(system.getUsernameByTokenId(1), "ABC");
        assertEq(system.getTokenIdByUsername("ABC"), 1);
        assertEq(system.getCurrentTokenId(), 1);
    }

       function testForlRevertsOnfanProFails() public {
        vm.startPrank(fanPro);
        system.getFreeNFT("ABC");
        vm.expectRevert(
            EternityIdentification.AlreadyMintedFreeNFT.selector
        );
        system.getFreeNFT("ABD");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert(EternityIdentification.NotAFanPro.selector);
        system.getFreeNFT("ABE");
        vm.stopPrank();
    }

    function testForkMintByDao() public {
        vm.startPrank(0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496);
        system.mintByDao("abc", user);
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert(EternityIdentification.NotDaoOwner.selector);
        system.mintByDao("abd", user2);
        vm.stopPrank();

        assertEq(system.getUserNFTCount(user), 0);
        assertEq(system.usernameExistsFor("ABC"), true);
        assertEq(system.usernameToUserAddress("ABC"), user);
        assertEq(system.getUsernameByTokenId(1), "ABC");
        assertEq(system.getTokenIdByUsername("ABC"), 1);
        assertEq(system.getCurrentTokenId(), 1);
    }

    function testForkBuyOption16Words() public {
        fundUsdt(user, 1000e6);
        vm.startPrank(user);
        usdt.approve(address(system), 1000e6);

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(4 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user);
        system.buy("ABCDEF", 0);
        vm.stopPrank();

        uint256 userBalanceAfter = usdt.balanceOf(user);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore - 2,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore - 2,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
    }
}
