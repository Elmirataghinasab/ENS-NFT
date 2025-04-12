// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// External Imports
import {Igenerator, Ieternal, IfanCommunity} from "./ExternalContracts/Eternity_Interfaces.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2981, IERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {String} from "./ExternalContracts/stringlib.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Eternity Identification NFT Contract
/// @notice This contract mints NFTs with unique usernames and supports multiple payment options.
contract EternityIdentification is ERC721, ERC2981, Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                              CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error CannotBuyMoreNFT(); // You cannot buy more NFTs from the contract.
    error UsernameExists(); // The username is already taken.
    error TransactionFailed(); // Your transaction has failed.
    error InvalidUsernameUsage(); // You cannot use this username.
    error AlreadyMintedFreeNFT(); // You have already minted your free NFT.
    error NotDaoOwner(); // Caller is not the DAO owner.
    error NotAFanPro(); // Caller is not a Fan Pro.
    error InvalidUsernameLength(); // The username length is invalid.
    error TransferFailed(); // Token transfer failed.

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    event NFTMinted(string username, uint256 tokenId);
    event ContractURIUpdated(string newURI);
    event BaseURIUpdated(string newURI);

    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/

    // Prices are denominated in "eter" (1 eter = 10**18)
    uint256 private constant PRICE_FOR_4_CHARACTERS = 8;
    uint256 private constant PRICE_FOR_5_CHARACTERS = 6;
    uint256 private constant PRICE_FOR_6_CHARACTERS = 4;
    uint256 private constant PRICE_FOR_7_OR_MORE_CHARACTERS = 2;

    uint256 private ETHER_UNIT = 10 ** 18;

    // Predefined addresses for fee distribution (immutable constants)
    address private constant DAO_CONTRACT_ADDRESS =
        0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
    address private constant SECOND_CONTRACT_ADDRESS = address(85);

    /*//////////////////////////////////////////////////////////////
                           STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    // Token counter for NFT IDs
    uint256 internal _tokenId = 0;

    // Contract URI info
    string private contractURI = "www.eter.to/contractURI/EES.json";
    string private baseURI = "www.eter.to/EESs/";

    // Royalty fee (in basis points)
    uint96 private _royaltyFee = 1900;

    // External contract interfaces
    Igenerator private GC =
        Igenerator(0xD829E975B00F4cB4ccd8cEfE80525A219D2d3B15);
    IERC20 private USD = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    Ieternal private EC = Ieternal(0xa1340485617478F5b196669E4506b3DBE6B9D6Ea);
    IfanCommunity fanCommunity =
        IfanCommunity(0xDD05ed9e4E14aD0133b285e84eCf836133FA3b7d);

    // Mappings
    mapping(address => uint256) private userNFTCount;
    mapping(uint256 => string) private tokenIdToUsername;
    mapping(string => uint256) private usernameToTokenId;
    mapping(string => bool) private usernameExists;
    mapping(uint256 => uint256) private unlockedNFTsByLevel;
    mapping(address => bool) private fanProFreeMinted;
    mapping (uint256 => EIDInfo) private tokenIdToEIDInfo;
    /*//////////////////////////////////////////////////////////////
                              STRUCT
    //////////////////////////////////////////////////////////////*/
    struct EIDInfo {
        uint256 dateMinted;
        string username;
        address minter;       
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("Eternity Identification", "EID") Ownable(msg.sender) {
        // Set initial royalty info
        setRoyaltyInfo(msg.sender, _royaltyFee);

        // Approve maximum USD spending for generator contract
        USD.approve(address(GC), type(uint256).max);

        // Initialize unlocked NFT counts per level
        unlockedNFTsByLevel[1] = 2;
        unlockedNFTsByLevel[2] = 4;
        unlockedNFTsByLevel[3] = 8;
        unlockedNFTsByLevel[4] = 16;
    }

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Restricts function access to the DAO owner.
    modifier onlyDaoOwner() {
        if (msg.sender != DAO_CONTRACT_ADDRESS) {
            revert NotDaoOwner();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              ROYALTY FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Override supportsInterface to include ERC2981 support.
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC2981) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice Calculates the royalty based on the sale price.
    /// @param salePrice The sale price of the NFT.
    /// @return The calculated royalty fee.
    function calculateRoyalty(uint256 salePrice) public view returns (uint256) {
        return (salePrice * _royaltyFee) / 10000;
    }

    /// @notice Sets the default royalty information.
    /// @param receiver The address that will receive royalty fees.
    /// @param royaltyFee_ The royalty fee in basis points.
    function setRoyaltyInfo(
        address receiver,
        uint96 royaltyFee_
    ) public onlyOwner {
        _royaltyFee = royaltyFee_;
        _setDefaultRoyalty(receiver, _royaltyFee);
    }

    /*//////////////////////////////////////////////////////////////
                          NFT MINTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Buys and mints a new NFT with the specified username.
    /// @param username The desired username (case-insensitive).
    /// @param paymentOption The payment option to use (0 = USD, 1 = GC, 2 = ETERNAL).
    function buy(string memory username, uint256 paymentOption) public {
        // Check if the user has reached their allowed NFT limit based on level
        uint256 allowedNFTs = unlockedNFTsByLevel[
            fanCommunity.getStar(msg.sender)
        ];
        if (allowedNFTs <= userNFTCount[msg.sender]) {
            revert CannotBuyMoreNFT();
        }
        // Check for duplicate username (case-insensitive)
        if (usernameExists[String.upper(username)]) {
            revert UsernameExists();
        }

        // Determine the payment amount based on username length
        uint256 amountToPay = ETHER_UNIT;
        uint256 nameLength = String.length(username);
        if (nameLength == 4) {
            amountToPay *= PRICE_FOR_4_CHARACTERS;
        } else if (nameLength == 5) {
            amountToPay *= PRICE_FOR_5_CHARACTERS;
        } else if (nameLength == 6) {
            amountToPay *= PRICE_FOR_6_CHARACTERS;
        } else if (nameLength >= 7) {
            amountToPay *= PRICE_FOR_7_OR_MORE_CHARACTERS;
        } else {
            revert InvalidUsernameUsage();
        }

        // Complete the payment based on the chosen option
        bool success = _completePayment(msg.sender, paymentOption, amountToPay);
        if (!success) {
            revert TransactionFailed();
        }

        // Mint the NFT and update state
        
        _tokenId++;
        _safeMint(msg.sender, _tokenId);
        EIDInfo memory newMinter=EIDInfo ({
            dateMinted: block.timestamp,
            username: username,
            minter:msg.sender
        });
        tokenIdToEIDInfo[_tokenId]=newMinter;
        userNFTCount[msg.sender]++;
        string memory upperUsername = String.upper(username);
        tokenIdToUsername[_tokenId] = upperUsername;
        usernameToTokenId[upperUsername] = _tokenId;
        usernameExists[upperUsername] = true;
        emit NFTMinted(upperUsername, _tokenId);
    }

    /// @notice Internal function to process payments in different tokens.
    /// @param caller The address of the caller.
    /// @param paymentOption The payment option (0 = USD, 1 = GC, 2 = ETERNAL).
    /// @param eterAmount The amount in eter to be paid.
    /// @return True if payment was successful.
    function _completePayment(
        address caller,
        uint256 paymentOption,
        uint256 eterAmount
    ) internal returns (bool) {
        if (paymentOption == 0) {
            // Payment via USD
            uint256 usdAmount = (GC.EterToUSD(eterAmount) * 100) / 95;
            require(USD.balanceOf(caller) >= usdAmount, "EES22");
            require(USD.allowance(caller, address(this)) >= usdAmount, "EES23");

            USD.safeTransferFrom(caller, address(this), usdAmount);
            eterAmount = GC.buy((usdAmount * 100) / 105);
            bool success1 = GC.transfer(DAO_CONTRACT_ADDRESS, eterAmount / 2);
            bool success2 = GC.transfer(
                SECOND_CONTRACT_ADDRESS,
                eterAmount / 2
            );
            if (!success1 || !success2) {
                revert TransferFailed();
            }
            return true;
        } else if (paymentOption == 1) {
            // Payment via GC
            require(GC.balanceOf(caller) >= eterAmount, "EES24");
            require(GC.allowance(caller, address(this)) >= eterAmount, "EES25");
            uint256 amountToSend = (eterAmount * 100) / 94;
            bool success1 = GC.transferFrom(
                caller,
                address(this),
                amountToSend
            );
            bool success2 = GC.transfer(DAO_CONTRACT_ADDRESS, eterAmount / 2);
            bool success3 = GC.transfer(
                SECOND_CONTRACT_ADDRESS,
                eterAmount / 2
            );
            if (!success1 || !success2 || !success3) {
                revert TransferFailed();
            }
            return true;
        } else if (paymentOption == 2) {
            // Payment via ETERNAL
            uint256 eternalEquivalent = EC.EterToET(eterAmount);
            uint256 etAmount = (eternalEquivalent * 100) / 97;
            require(EC.balanceOf(caller) >= etAmount, "EES26");
            require(EC.allowance(caller, address(this)) >= etAmount, "EES27");
            bool success1 = EC.transferFrom(caller, address(this), etAmount);
            bool success2 = EC.transfer(
                DAO_CONTRACT_ADDRESS,
                eternalEquivalent / 2
            );
            if (!success1 || !success2) {
                revert TransferFailed();
            }
            EC.sell(eternalEquivalent / 2, SECOND_CONTRACT_ADDRESS);
            return true;
        } else {
            revert("EES28");
        }
    }

    /// @notice Mints a free NFT for Fan Pro users with a 3-character username.
    /// @param username The desired username (must be exactly 3 characters).
    function getFreeNFT(string memory username) public {
        if (!fanCommunity.getFan(msg.sender).isFanPro) {
            revert NotAFanPro();
        }
        if (fanProFreeMinted[msg.sender]) {
            revert AlreadyMintedFreeNFT();
        }
        if (String.length(username) != 3) {
            revert InvalidUsernameLength();
        }

        _tokenId++;
        _safeMint(msg.sender, _tokenId);
        EIDInfo memory newMinter=EIDInfo ({
            dateMinted: block.timestamp,
            username: username,
            minter:msg.sender
        });
        tokenIdToEIDInfo[_tokenId]=newMinter;
        string memory upperUsername = String.upper(username);
        tokenIdToUsername[_tokenId] = upperUsername;
        usernameToTokenId[upperUsername] = _tokenId;
        usernameExists[upperUsername] = true;
        emit NFTMinted(upperUsername, _tokenId);
        fanProFreeMinted[msg.sender] = true;
    }

    /// @notice Mints an NFT by the DAO for a given user with a 3-character username.
    /// @param username The desired username (must be exactly 3 characters).
    /// @param user The address to receive the NFT.
    function mintByDao(
        string memory username,
        address user
    ) public onlyDaoOwner {
        if (String.length(username) != 3) {
            revert InvalidUsernameLength();
        }
        _tokenId++;
        _safeMint(user, _tokenId);
        EIDInfo memory newMinter=EIDInfo ({
            dateMinted: block.timestamp,
            username: username,
            minter:msg.sender
        });
        tokenIdToEIDInfo[_tokenId]=newMinter;
        string memory upperUsername = String.upper(username);
        tokenIdToUsername[_tokenId] = upperUsername;
        usernameToTokenId[upperUsername] = _tokenId;
        usernameExists[upperUsername] = true;
        emit NFTMinted(upperUsername, _tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                              URI FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the base URI for tokens.
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @notice Updates the base token URI.
    /// @param newURI The new base URI.
    function updateBaseURI(string memory newURI) external onlyOwner {
        baseURI = newURI;
        emit BaseURIUpdated(newURI);
    }

    /// @notice Returns the current base token URI.
    function getBaseURI() public view returns (string memory) {
        return baseURI;
    }

    /// @notice Returns the contract metadata URI.
    function getContractURI() public view returns (string memory) {
        return contractURI;
    }

    /// @notice Updates the contract metadata URI.
    /// @param newURI The new contract URI.
    function updateContractURI(string memory newURI) external onlyOwner {
        contractURI = newURI;
        emit ContractURIUpdated(newURI);
    }

    /// @notice Returns the token URI for a given tokenId.
    /// @param tokenId The token ID.
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        // Concatenate base URI, tokenId, and ".json"
        return string.concat(baseURI, toString(tokenId), ".json");
    }

    /*//////////////////////////////////////////////////////////////
                         STRING HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";

    /// @notice Converts a uint256 to its ASCII string decimal representation.
    /// @param value The number to convert.
    /// @return The string representation of the number.
    function toString(uint256 value) public pure returns (string memory) {
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

    /*//////////////////////////////////////////////////////////////
                          GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the number of NFTs minted by a user.
    function getUserNFTCount(address user) public view returns (uint256) {
        return userNFTCount[user];
    }

    /// @notice Checks if a username (case-insensitive) exists.
    /// @param username The username to check.
    function usernameExistsFor(
        string calldata username
    ) public view returns (bool) {
        return usernameExists[String.upper(username)];
    }

    /// @notice Returns the DAO contract address.
    function getDaoAddress() public pure returns (address) {
        return DAO_CONTRACT_ADDRESS;
    }

    /// @notice Returns the secondary contract address.
    function getSecondContractAddress() public pure returns (address) {
        return SECOND_CONTRACT_ADDRESS;
    }

    /// @notice Returns the token ID associated with a username.
    /// @param username The username (case-insensitive).
    function getTokenIdByUsername(
        string memory username
    ) public view returns (uint256) {
        return usernameToTokenId[String.upper(username)];
    }

    /// @notice Returns the username associated with a token ID.
    /// @param tokenId The token ID.
    function getUsernameByTokenId(
        uint256 tokenId
    ) public view returns (string memory) {
        return tokenIdToUsername[tokenId];
    }

    /// @notice Returns the current token counter.
    function getCurrentTokenId() public view returns (uint256) {
        return _tokenId;
    }

    /// @notice Returns the tokenIds EIDInfo.
    function getEIDInfoByTokenId(uint256 tokenId)public view returns(EIDInfo memory){
        return tokenIdToEIDInfo[tokenId];
    }

    /// @notice Returns the owner address for a given username.
    /// @param username The username (case-insensitive).
    function usernameToUserAddress(
        string memory username
    ) public view returns (address) {
        uint256 tokenId = usernameToTokenId[String.upper(username)];
        return ownerOf(tokenId);
    }
    
}
