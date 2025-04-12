// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {IERC20, Igenerator, IERC20Metadata, Ieternal} from "../../../src/ExternalContracts/Eternity_Interfaces.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./getstarMock.sol";
import {String} from "../../../src/ExternalContracts/stringlib.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IFanCommunity} from "./getstarMock.sol";

//make sure to change feedominator in ERC2981

contract NFTCollection is ERC721, ERC2981, Ownable {
    error NFTCollection_YouCannotBuyMoreNFTFromContract();
    error NFTCollection_UsernameExists();
    error NFTCollection_YourTransactionFailed();
    error NFTCollection_YouCannotUseThisUserName();
    error NFTCollection_YouHavemintedYourFreeNFTBefore();
    error NFTCollection_YouAreNotTheDaoOwner();
    error NFTCollection_YouAreNotAfanPro();
    error NFTCollection_InvalidUsername();

    event NFTMinted(string username, uint256 tokenId);
    event ContractURIUpdated(string newURI);
    event BaseURIUpdated(string newURI);

    //prices are in eter
    uint256 private constant PRICE_FOR_4WORDS = 8;
    uint256 private constant PRICE_FOR_5WORDS = 6;
    uint256 private constant PRICE_FOR_6WORDS = 4;
    uint256 private constant PRICE_FOR_7WORDS = 2;

    IFanCommunity fanCommunity;

    uint256 internal _tokenId = 0;

    //contract URI info
    string private _contractURI = "www.eter.to/contractURI/EES.json";
    string private baseURI = "www.eter.to/EESs/";

    //royalty info
    uint96 private royaltyFee = 1900;

    uint256 private constant DECIMAl = 10 ** 18;

    //address to tranfer eter
    address private constant DaoContract =
        0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
    address private constant SecondContract = address(85);

    mapping(address => uint) userToNFTCount;
    mapping(uint256 => string) tokenIdToUsername;
    mapping(string => uint256) usernameToTokenId;
    mapping(string => bool) usernameExist;
    // mapping(string => address) usernameToUSerAddress;
    mapping(uint => uint) LevelToUnlockedCount;
    mapping(address => bool) IffanProFreeMint;

    ///variables from other contracts
    Igenerator private GC;
    /* =Igenerator(0xD829E975B00F4cB4ccd8cEfE80525A219D2d3B15);*/
    IERC20Metadata private USD;
    /* = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);*/
    Ieternal private EC;

    /*= Ieternal(0xa1340485617478F5b196669E4506b3DBE6B9D6Ea);*/

    ////name of collection and symbol is upto you
    constructor(
        address generator,
        address usdt,
        address et,
        address fan
    ) ERC721("MYCollection", "MC") Ownable(msg.sender) {
        setRoyaltyInfo(msg.sender, royaltyFee);
        fanCommunity = IFanCommunity(fan);
        GC = Igenerator(generator);
        USD = IERC20Metadata(usdt);
        EC = Ieternal(et);
        USD.approve(address(GC), type(uint256).max);
        //initialize levels
        LevelToUnlockedCount[1] = 2;
        LevelToUnlockedCount[2] = 4;
        LevelToUnlockedCount[3] = 8;
        LevelToUnlockedCount[4] = 16;
    }

    modifier OnlyDaoOwner() {
        if (msg.sender != DaoContract) {
            revert NFTCollection_YouAreNotTheDaoOwner();
        }
        _;
    }

    function Buy(string memory username, uint256 paymentOption) public {
        if (
            LevelToUnlockedCount[fanCommunity.getStar(msg.sender)] <=
            userToNFTCount[msg.sender]
        ) {
            revert NFTCollection_YouCannotBuyMoreNFTFromContract();
        }
        if (usernameExist[String.upper(username)]) {
            revert NFTCollection_UsernameExists();
        }
        uint256 amountToPay = DECIMAl;
        if (String.length(username) == 4) {
            amountToPay *= PRICE_FOR_4WORDS;
        } else if (String.length(username) == 5) {
            amountToPay *= PRICE_FOR_5WORDS;
        } else if (String.length(username) == 6) {
            amountToPay *= PRICE_FOR_6WORDS;
        } else if (String.length(username) >= 7) {
            amountToPay *= PRICE_FOR_7WORDS;
        } else {
            revert NFTCollection_YouCannotUseThisUserName();
        }

        bool success = completePayment(msg.sender, paymentOption, amountToPay);

        if (success) {
            _tokenId++;
            _safeMint(msg.sender, _tokenId);
            userToNFTCount[msg.sender]++;
            tokenIdToUsername[_tokenId] = String.upper(username);
            usernameToTokenId[String.upper(username)] = _tokenId;
            usernameExist[String.upper(username)] = true;
            emit NFTMinted(String.upper(username), _tokenId);
        } else {
            revert NFTCollection_YourTransactionFailed();
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC2981) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function calculateRoyalty(
        uint256 _salePrice
    ) public view returns (uint256) {
        return (_salePrice * royaltyFee) / 10000;
    }

    function setRoyaltyInfo(
        address receiver,
        uint96 _royaltyfee
    ) public onlyOwner {
        royaltyFee = _royaltyfee;
        _setDefaultRoyalty(receiver, royaltyFee);
    }

    ///getter functions///

    function getusersNFTCount(address user) public view returns (uint) {
        return userToNFTCount[user];
    }

    function getUsernameExistance(
        string calldata username
    ) public view returns (bool) {
        return usernameExist[String.upper(username)];
    }

    function getDaoAddress() public pure returns (address) {
        return DaoContract;
    }

    function getSecondAddress() public pure returns (address) {
        return SecondContract;
    }

    function getTokenIdbyusername(
        string memory username
    ) public view returns (uint256) {
        return usernameToTokenId[String.upper(username)];
    }

    function getusernamebyTokenId(
        uint256 tokenId
    ) public view returns (string memory) {
        return tokenIdToUsername[tokenId];
    }

    function getTokenId() public view returns (uint256) {
        return _tokenId;
    }

    ///functions from other contracts
    function completePayment(
        address caller,
        uint256 paymentOption,
        uint256 eterAmount
    ) internal returns (bool) {
        if (paymentOption == 0) {
            //USD
            uint256 USDamount = (GC.EterToUSD(eterAmount) * 100) / 95; //eternal in usd
            require(USD.balanceOf(caller) >= USDamount, "EES22");
            require(USD.allowance(caller, address(this)) >= USDamount, "EES23");

            USD.transferFrom(caller, address(this), USDamount);

            eterAmount = GC.buy((USDamount * 100) / 105);
            GC.transfer(DaoContract, eterAmount / 2);
            GC.transfer(SecondContract, eterAmount / 2);

            return true;
        } else if (paymentOption == 1) {
            //GC
            require(GC.balanceOf(caller) >= eterAmount, "EES24");
            require(GC.allowance(caller, address(this)) >= eterAmount, "EES25");
            uint256 amountToSend = (eterAmount * 100) / 94;

            GC.transferFrom(caller, address(this), amountToSend);

            GC.transfer(DaoContract, eterAmount / 2);
            GC.transfer(SecondContract, eterAmount / 2);

            return true;
        } else if (paymentOption == 2) {
            //
            uint256 eternalEquivalent = EC.EterToET(eterAmount); //eternal in eter
            uint256 ETamount = (eternalEquivalent * 100) / 97;

            require(EC.balanceOf(caller) >= ETamount, "EES26");
            require(EC.allowance(caller, address(this)) >= ETamount, "EES27");

            EC.transferFrom(caller, address(this), ETamount);
            EC.transfer(DaoContract, eternalEquivalent / 2);
            EC.sell(eternalEquivalent / 2, SecondContract);

            return true;
        } else revert("EES28");
    }

    function transferToFanPro(string calldata username) public {
        if (fanCommunity.makeuserfanPro(msg.sender)) {
            if (!IffanProFreeMint[msg.sender]) {
                if (String.length(username) != 3) {
                    revert NFTCollection_InvalidUsername();
                }
                _tokenId++;
                _safeMint(msg.sender, _tokenId);
                userToNFTCount[msg.sender]++;
                tokenIdToUsername[_tokenId] = String.upper(username);
                usernameToTokenId[String.upper(username)] = _tokenId;
                usernameExist[String.upper(username)] = true;
                emit NFTMinted(String.upper(username), _tokenId);
                IffanProFreeMint[msg.sender] = true;
            } else {
                revert NFTCollection_YouHavemintedYourFreeNFTBefore();
            }
        } else {
            revert NFTCollection_YouAreNotAfanPro();
        }
    }

    function MintByDao(
        string calldata username,
        address user
    ) public OnlyDaoOwner {
        if (String.length(username) != 3) {
            revert NFTCollection_InvalidUsername();
        }
        _tokenId++;
        _safeMint(user, _tokenId);
        userToNFTCount[user]++;
        tokenIdToUsername[_tokenId] = String.upper(username);
        usernameToTokenId[String.upper(username)] = _tokenId;

        usernameExist[String.upper(username)] = true;
        emit NFTMinted(String.upper(username), _tokenId);
    }

    function usernameToUSerAddress(
        string memory username
    ) public view returns (address) {
        uint256 tokenId = usernameToTokenId[String.upper(username)];
        address owner = ownerOf(tokenId);
        return owner;
    }

    ///URI functions
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function updateBaseURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
        emit BaseURIUpdated(newURI);
    }

    function getbaseURI() public view returns (string memory) {
        return baseURI;
    }

    function getContractURI() public view returns (string memory) {
        return _contractURI;
    }

    function updaetContractURI(string memory newURI) external onlyOwner {
        _contractURI = newURI;
        emit ContractURIUpdated(newURI);
    }

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly ("memory-safe") {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly ("memory-safe") {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        return string(string.concat(baseURI, toString(tokenId), ".json"));
    }
}
