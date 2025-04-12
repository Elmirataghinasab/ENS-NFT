// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {NFTScript} from "../../script/NFT.s.sol";
import {NFTCollection} from "./contract/NFT.sol";
import {Token} from "../../src/ExternalContracts/token.sol";
import {FanCommunity} from "./contract/getstarMock.sol";
import {generator} from "../../src/ExternalContracts/Generator.sol";
import {eternal} from "./contract/eternalMock.sol";

contract NFTTest is Test {
    NFTScript deploy;
    Token usdt;
    NFTCollection system;
    generator Generator;
    eternal Eternal;
    FanCommunity fan;

    address user1 = address(2);
    address user2 = address(3);
    address user3 = address(4);
    address user4 = address(5);
    address Owner;
    uint256 initialSupply = 100e18;
    uint256 private constant DECIMAl = 10 ** 18;

    function setUp() public {
        deploy = new NFTScript();
        usdt = deploy.runToken(initialSupply);
        Generator = deploy.runGenerator(address(usdt));
        Eternal = deploy.runeternalMock(address(usdt), address(Generator));
        fan = new FanCommunity();
        system = deploy.runNFTCollection(
            address(Eternal),
            address(usdt),
            address(Generator),
            address(fan)
        );
        Owner = system.owner();

        vm.startPrank(Generator.owner());
        Generator.changeWhitelist(Owner, true);
        vm.stopPrank();
    }

    ///tests///
    function testBuyOption1() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 1 * DECIMAl);
        usdt.transfer(address(system), 1 * DECIMAl);
        usdt.transfer(user1, 3 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 3 * DECIMAl);
        usdt.approve(address(Generator), 3 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(2 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user1);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user1);
        system.Buy("ABCDEFG", 0);
        vm.stopPrank();
        uint256 userBalanceAfter = usdt.balanceOf(user1);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABCDEFG");
        assertEq(system.getTokenIdbyusername("ABCDEFG"), 1);
        assertEq(system.getTokenId(), 1);
    }

    function testBuyOption2() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 10e18);
        usdt.approve(address(Generator), 1000e18);
        Generator.buy(5 * DECIMAl);
        Generator.transfer(user1, 3 * DECIMAl);
        Generator.transfer(address(system), 1 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        Generator.approve(address(system), 3 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        uint256 userBalanceBefore = Generator.balanceOf(user1);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));

        vm.startPrank(user1);
        system.Buy("ABCDEFG", 1);
        vm.stopPrank();

        uint256 userBalanceAfter = Generator.balanceOf(user1);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));

        //uint256 buyFee = Generator.getTotalBuyLevy();
        uint256 transferFee = Generator.getTotalTransferLevy();

        assertEq(userBalanceBefore - userBalanceAfter, 2 * DECIMAl * 100 / 94);
        assertEq(
            daoBalanceAfter - daoBalanceBefore,
            (1 * DECIMAl * (1000 - transferFee)) / 1000
        );
        assertEq(
            secBalanceAfter - secBalanceBefore,
            (1 * DECIMAl * (1000 - transferFee)) / 1000
        );
        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user1);
    }

    function testBuyOption3() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 10e18);
        usdt.approve(address(Generator), 10e18);
        uint256 eterAmount = Generator.buy(5 * DECIMAl);
        Generator.transfer(user1, (eterAmount * 100) / 106);
        vm.stopPrank();

        vm.startPrank(user1);
        Generator.approve(address(Eternal), 10000e18);
        Eternal.buy((((eterAmount * 100) / 106) * 100) / 103);
        vm.stopPrank();

        fan.setStar(user1, 2);

        uint256 contractBalanceBefore = Eternal.balanceOf(address(system));
        uint256 userBalanceBefore = Eternal.balanceOf(user1);
        uint256 daoBalanceBefore = Eternal.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 eternalEquivalent = Eternal.EterToET(2 * DECIMAl);
        uint256 eterToSend = (eternalEquivalent * 100) / 97;

        vm.startPrank(user1);
        Eternal.approve(address(system), 1000e18);
        system.Buy("ABCDEFG", 2);
        vm.stopPrank();

        uint256 contractBalanceAfter = Eternal.balanceOf(address(system));
        uint256 userBalanceAfter = Eternal.balanceOf(user1);
        uint256 daoBalanceAfter = Eternal.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );

        vm.assertEq(contractBalanceAfter - contractBalanceBefore, 0);
        assertEq(userBalanceBefore - userBalanceAfter, eterToSend);
        assertEq(
            daoBalanceAfter - daoBalanceBefore - 2,
            ((eternalEquivalent / 2) * 97) / 100
        );

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user1);
    }

    function testBuysecondAndThirdTime() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 2 * DECIMAl);
        usdt.transfer(address(system), 2 * DECIMAl);
        usdt.transfer(user1, 6 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(address(system));
        usdt.approve(address(Generator), 2 * DECIMAl);
        Generator.approve(address(system), 4 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 6 * DECIMAl);
        usdt.approve(address(Generator), 6 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        vm.startPrank(user1);
        system.Buy("ABCDEFG", 0);

        system.Buy("ABCDEFH", 0);
        vm.stopPrank();

        assertEq(system.getusersNFTCount(user1), 2);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user1);
        assertEq(system.getUsernameExistance("ABCDEFH"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFH"), user1);

        vm.startPrank(user1);
        vm.expectRevert(
            NFTCollection.NFTCollection_YouCannotBuyMoreNFTFromContract.selector
        );
        system.Buy("ABCDEFW", 0);
        vm.stopPrank();
    }

    function testTransferToFan() public {
        vm.startPrank(user1);
        fan.setPro(user1);
        system.transferToFanPro("ABC");
        vm.stopPrank();

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABC"), true);
        assertEq(system.usernameToUSerAddress("ABC"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABC");
    }

    function testRevertsOnfanProFails() public {
        vm.startPrank(user1);
        fan.setPro(user1);
        system.transferToFanPro("ABC");
        vm.expectRevert(
            NFTCollection.NFTCollection_YouHavemintedYourFreeNFTBefore.selector
        );
        system.transferToFanPro("ABD");
        vm.stopPrank();

        vm.startPrank(user2);
        vm.expectRevert(NFTCollection.NFTCollection_YouAreNotAfanPro.selector);
        system.transferToFanPro("ABE");
        vm.stopPrank();
    }

    function testMintByDao() public {
        vm.startPrank(0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496);
        system.MintByDao("abc", user1);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(
            NFTCollection.NFTCollection_YouAreNotTheDaoOwner.selector
        );
        system.MintByDao("abd", user2);
        vm.stopPrank();

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABC"), true);
        assertEq(system.getUsernameExistance("abc"), true);
        assertEq(system.usernameToUSerAddress("ABC"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABC");
    }

    ///royaltyTests///
    function testRoyaltyCalculation() public view {
        uint256 saleprice = DECIMAl;
        uint256 royalty = system.calculateRoyalty(saleprice);

        assertEq((saleprice * 19) / 100, royalty);
    }

    function testsetRoyaltyInfo() public {
        vm.startPrank(system.owner());
        system.setRoyaltyInfo(system.owner(), 1500);
        vm.stopPrank();

        uint256 saleprice = DECIMAl;
        uint256 royalty = system.calculateRoyalty(saleprice);

        assertEq((saleprice * 15) / 100, royalty);
    }

    function testIfURIfunctionsWork() public {
        string memory contracturi = "www.eter.to/contractURI/EES.json";
        string memory baseuri = "www.eter.to/EESs/";
        assertEq(system.getbaseURI(), baseuri);
        assertEq(system.getContractURI(), contracturi);

        vm.prank(Owner);
        system.updateBaseURI("newBaseURI");
        vm.assertEq(system.getbaseURI(), "newBaseURI");

        vm.prank(Owner);
        system.updaetContractURI("newContractURI");
        vm.assertEq(system.getContractURI(), "newContractURI");
    }

    function testBuyReverts() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 4 * DECIMAl);
        usdt.transfer(address(system), 4 * DECIMAl);
        usdt.transfer(user1, 6 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(address(system));
        usdt.approve(address(Generator), 10000 * DECIMAl);
        Generator.approve(address(system), 20000 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 30000 * DECIMAl);
        usdt.approve(address(Generator), 30000 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        vm.startPrank(user1);
        system.Buy("ABCDEFG", 0);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(NFTCollection.NFTCollection_UsernameExists.selector);
        system.Buy("ABCDEFG", 0);
        vm.stopPrank();

        vm.startPrank(user1);
        vm.expectRevert(
            NFTCollection.NFTCollection_YouCannotUseThisUserName.selector
        );
        system.Buy("A", 0);
        vm.stopPrank();
    }

    function testBuyOption16Words() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 1 * DECIMAl);
        usdt.transfer(address(system), 1 * DECIMAl);
        usdt.transfer(user1, 5 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 10 * DECIMAl);
        usdt.approve(address(Generator), 10 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(4 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user1);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user1);
        system.Buy("ABCDEF", 0);
        vm.stopPrank();

        uint256 userBalanceAfter = usdt.balanceOf(user1);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDEF"), true);
        assertEq(system.usernameToUSerAddress("ABCDEF"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABCDEF");
        assertEq(system.getTokenIdbyusername("ABCDEF"), 1);
        assertEq(system.getTokenId(), 1);
    }

    function testBuyOption15Words() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 1 * DECIMAl);
        usdt.transfer(address(system), 1 * DECIMAl);
        usdt.transfer(user1, 6 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 10 * DECIMAl);
        usdt.approve(address(Generator), 10 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(6 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user1);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user1);
        system.Buy("ABCDE", 0);
        vm.stopPrank();

        uint256 userBalanceAfter = usdt.balanceOf(user1);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDE"), true);
        assertEq(system.usernameToUSerAddress("ABCDE"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABCDE");
        assertEq(system.getTokenIdbyusername("ABCDE"), 1);
        assertEq(system.getTokenId(), 1);
    }

    function testBuyOption4Words() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 1 * DECIMAl);
        usdt.transfer(address(system), 1 * DECIMAl);
        usdt.transfer(user1, 8 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 10 * DECIMAl);
        usdt.approve(address(Generator), 10 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        uint256 transferFee = Generator.getTotalTransferLevy();

        uint256 usdtAmount = Generator.EterToUSD(8 * DECIMAl);
        uint256 amountToTransfer = (usdtAmount * 100) / 95;
        uint256 userBalanceBefore = usdt.balanceOf(user1);
        uint256 daoBalanceBefore = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceBefore = Generator.balanceOf(address(85));
        uint256 gcEquivalent = Generator.USDtoEter(
            (amountToTransfer * 100) / 105
        );

        vm.startPrank(user1);
        system.Buy("ABCD", 0);
        vm.stopPrank();

        uint256 userBalanceAfter = usdt.balanceOf(user1);
        uint256 daoBalanceAfter = Generator.balanceOf(
            0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
        );
        uint256 secBalanceAfter = Generator.balanceOf(address(85));
        vm.assertEq(userBalanceBefore - userBalanceAfter, amountToTransfer);
        vm.assertEq(
            daoBalanceAfter - daoBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );
        vm.assertEq(
            secBalanceAfter - secBalanceBefore,
            ((gcEquivalent / 2) * (1000 - transferFee)) / 1000
        );

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCD"), true);
        assertEq(system.usernameToUSerAddress("ABCD"), user1);
        assertEq(system.getusernamebyTokenId(1), "ABCD");
        assertEq(system.getTokenIdbyusername("ABCD"), 1);
        assertEq(system.getTokenId(), 1);
    }

    function testIfOwnerChangesAfterTransfer() public {
        vm.startPrank(Owner);
        usdt.transfer(address(Generator), 1 * DECIMAl);
        usdt.transfer(address(system), 1 * DECIMAl);
        usdt.transfer(user1, 3 * DECIMAl);
        vm.stopPrank();

        vm.startPrank(user1);
        usdt.approve(address(system), 3 * DECIMAl);
        usdt.approve(address(Generator), 3 * DECIMAl);
        vm.stopPrank();

        fan.setStar(user1, 1);

        vm.startPrank(user1);
        system.Buy("ABCDEFG", 0);

        assertEq(system.getusersNFTCount(user1), 1);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user1);

        system.transferFrom(user1, user2, 1);
        vm.stopPrank();

        assertEq(system.getusersNFTCount(user2), 0);
        assertEq(system.getUsernameExistance("ABCDEFG"), true);
        assertEq(system.usernameToUSerAddress("ABCDEFG"), user2);
    }
}
