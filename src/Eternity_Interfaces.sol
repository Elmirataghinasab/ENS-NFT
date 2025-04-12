// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address account) {
        _transferOwnership(account);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function decimals() external view returns (uint8);
    
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC2981 is IERC165 {
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool approved) external;

    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

library SignedMath {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            int256 mask = n >> 255;
            return uint256((n + mask) ^ mask);
        }
    }
}

library Math {
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor,
        Ceil,
        Trunc,
        Expand
    }

    function tryAdd(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(
        uint256 a,
        uint256 b
    ) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            return a / b;
        }

        unchecked {
            return a == 0 ? 0 : (a - 1) / b + 1;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                return prod0 / denominator;
            }

            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)

                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = denominator & (0 - denominator);
            assembly {
                denominator := div(denominator, twos)

                prod0 := div(prod0, twos)

                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;

            uint256 remainder = a % n;
            uint256 gcd = n;

            int256 x = 0;
            int256 y = 1;

            while (remainder != 0) {
                uint256 quotient = gcd / remainder;

                (gcd, remainder) = (remainder, gcd - remainder * quotient);

                (x, y) = (y, x - y * int256(quotient));
            }

            if (gcd != 1) return 0;
            return x < 0 ? (n - uint256(-x)) : uint256(x);
        }
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);

        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(
        uint256 a,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return
                result +
                (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log2(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    function log10(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return
                result +
                (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log256(
        uint256 value,
        Rounding rounding
    ) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return
                result +
                (
                    unsignedRoundsUp(rounding) && 1 << (result << 3) < value
                        ? 1
                        : 0
                );
        }
    }

    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    error StringsInsufficientHexLength(uint256 value, uint256 length);

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toStringSigned(
        int256 value
    ) internal pure returns (string memory) {
        return
            string.concat(
                value < 0 ? "-" : "",
                toString(SignedMath.abs(value))
            );
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    function toHexString(
        uint256 value,
        uint256 length
    ) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    function equal(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return
            bytes(a).length == bytes(b).length &&
            keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;

    error ERC2981InvalidDefaultRoyalty(uint256 numerator, uint256 denominator);

    error ERC2981InvalidDefaultRoyaltyReceiver(address receiver);

    error ERC2981InvalidTokenRoyalty(
        uint256 tokenId,
        uint256 numerator,
        uint256 denominator
    );

    error ERC2981InvalidTokenRoyaltyReceiver(uint256 tokenId, address receiver);

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC165) returns (bool) {
        return
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) public view virtual returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];

        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) /
            _feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }

    function _setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            revert ERC2981InvalidDefaultRoyalty(feeNumerator, denominator);
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidDefaultRoyaltyReceiver(address(0));
        }

        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }

    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal virtual {
        uint256 denominator = _feeDenominator();
        if (feeNumerator > denominator) {
            revert ERC2981InvalidTokenRoyalty(
                tokenId,
                feeNumerator,
                denominator
            );
        }
        if (receiver == address(0)) {
            revert ERC2981InvalidTokenRoyaltyReceiver(tokenId, address(0));
        }

        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }

    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}

interface IERC20Errors {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

library ERC721Utils {
    function checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    operator,
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert("Invalid ERC721 Contract Receiver");
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Invalid ERC721 Contract Receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface Igenerator is IERC20Metadata, IERC20Errors {
    event Announcements(string news);

    function description() external view returns (string memory);

    function treasury() external view returns (address);

    function USDaddress() external view returns (address);

    function USDbalanceOfTreasury() external view returns (uint256);

    function totalBurnt() external view returns (uint256);

    function totalToken() external view returns (uint256);

    function totalDonate() external view returns (uint256);

    function isWhitelist(address whitelist) external view returns (bool);

    function USDtoEter(uint256 USDamount) external view returns (uint256);

    function EterToUSD(uint256 amount) external view returns (uint256);

    function getTotalTransferLevy() external view returns (uint256);

    function getTotalBuyLevy() external view returns (uint256);

    function getTotalSellLevy() external view returns (uint256);

    function divisor() external view returns (uint256);

    function buyTutorial() external pure returns (string memory);

    function license() external pure returns (string memory);

    function buy(uint256 USDamount) external returns (uint256);

    function sell(uint256 amount) external returns (uint256);

    function burn(uint256 amount) external returns (bool);

    function donate(uint256 USDamount) external returns (bool);

    function changeWhitelist(address whitelist, bool add) external;

    function changeDescription(string memory _newDescription) external;

    function owner() external returns (address);

    function changeUSD(
        uint256 routerVersion,
        uint256 stablecoin,
        uint256 dEX,
        uint256 amountOutMinimum
    ) external payable returns (bool);

    function changeUSDAddressOnly(address _newUSD) external;

    function announce(string memory news) external;

    function approveToken(address token) external;
}

interface IfanCommunity {
    event Announcements(string news);

    struct Fan {
        address referrer;
        bool isFanPro;
        uint256 slot;
        uint256 earning;
        uint256 endOfSubscriptionDate;
        bool[5] isAwardee;
        uint256[5] prizeEarning;
        address[] referees;
    }

    function description() external view returns (string memory);

    function generatorContractAddress() external view returns (address);

    function USDaddress() external view returns (address);

    function prizeTreasuryAddress() external view returns (address);

    function researchAndDevelopmentAddress() external view returns (address);

    function getFan(address fan) external view returns (Fan memory);

    function awardees(
        uint256 slotIndex
    ) external view returns (address[] memory);

    function numberOfAwardees(
        uint256 slotIndex
    ) external view returns (uint256);

    function prizes() external view returns (uint256[5] memory);

    function getSlots() external view returns (uint256[4] memory);

    function getSlotsTotal() external view returns (uint256[4] memory);

    function getSlotMinimumEarning() external view returns (uint256[4] memory);

    function getMinimumReferees() external view returns (uint256[5] memory);

    function getLevels() external view returns (uint256[14] memory);

    function getSubscriptionDateLimit() external view returns (uint256);

    function getStar(address fan) external view returns (uint256);

    function getNumberOfFans() external view returns (uint256);

    function getAllFans() external view returns (address[] memory fans);

    function getAllFanPros() external view returns (address[] memory fanPros);

    function hasAccess(address _address) external view returns (bool);

    function tutorial() external pure returns (string memory);

    function license() external pure returns (string memory);

    function registerWithUSD(
        uint256 slotIndex,
        address referrer
    ) external returns (bool);

    function registerWithEter(
        uint256 slotIndex,
        address referrer
    ) external returns (bool);

    function upgradeSubscriptionWithUSD(
        uint256 slotIndex
    ) external returns (bool success);

    function upgradeSubscriptionWithEter(
        uint256 slotIndex
    ) external returns (bool success);

    function renewSubscriptionWithUSD() external returns (bool);

    function renewSubscriptionWithEter() external returns (bool);

    function addToAwardeeList(uint256 slotIndex) external returns (bool);

    function awardPrize() external returns (bool);

    function changeUSD(address newUSD) external;

    function changeDescription(string memory _newDescription) external;

    function changeResearchAndDevelopment(
        address _researchAndDevelopment
    ) external;

    function changeGeneratorContract(address _generator) external;

    function changeAccess(address _address, bool add) external;

    function approveGenerator() external;

    function announce(string memory news) external;

    function approveToken(address token) external;

    function owner() external returns (address);
}

interface Iforecast {
    event Announcements(string news);

    struct Participant {
        uint256[] winningIndices;
        bool withdrawedEarning;
    }

    struct Game {
        bool hasEnded;
        mapping(uint256 => uint256) blueNumbersFrequency;
        mapping(uint256 => uint256) winnings;
        mapping(uint256 => address[]) winners;
        mapping(uint256 => address) participants;
        mapping(address => uint256[]) predictions;
        mapping(address => Participant) earnings;
        uint256 startTime;
        uint256 eterRaised;
        uint256 blueNumber;
        uint256 contractBalance;
        uint256 priceRate;
        uint256 finalWinningNumber;
        uint256 numberOfParticipants;
        uint256 numberOfPredictions;
        uint256 numberOfFreeEntriesUsed;
    }

    struct GameStruct {
        bool hasEnded;
        address[] participants;
        uint256[][] predictions;
        uint256[] winnings;
        address[][] winners;
        uint256 nonWinnersAmount;
        address[] nonwinners;
        uint256[] blueNumbersFrequency;
        uint256 startTime;
        uint256 eterRaised;
        uint256 numberOfParticipants;
        uint256 numberOfPredictions;
        uint256 numberOfFreeEntries;
        uint256 numberOfFreeEntriesUsed;
        uint256 finalWinningNumber;
        uint256 blueNumber;
        uint256 contractBalance;
        uint256 priceRate;
        string stage;
    }

    function getForecastTreasury() external view returns (address, uint256);

    function USDaddress() external view returns (address);

    function researchAndDevelopment() external view returns (address);

    function getFanAddress() external view returns (address);

    function getGeneratorAddress() external view returns (address);

    function getGameCounter() external view returns (uint256);

    function numberOfForecastAwardees(uint256 index) external returns (uint256);

    function getForecastPrizes()
        external
        view
        returns (uint256[] memory prizes);

    function numberOfSaviors() external view returns (uint256);

    function getSaviorPrize() external view returns (uint256);

    function description() external view returns (string memory);

    function tutorial() external view returns (string memory);

    function totalDonate() external view returns (uint256);

    function getTimestamp() external view returns (uint256);

    function getGameStage(
        uint256 gameIndex
    ) external view returns (string memory);

    function getGameInfo(
        uint256 gameIndex
    )
        external
        view
        returns (
            uint256 startTime,
            uint256 eterRaised,
            uint256 numberOfParticipants,
            uint256 numberOfPredictions,
            uint256 numberOfFreeEntries,
            uint256 numberOfFreeEntriesUsed,
            bool hasEnded
        );

    function getGameResult(
        uint256 gameIndex
    )
        external
        view
        returns (
            uint256[] memory numberOfWinners,
            uint256 numberOfNonWinners,
            uint256[] memory winningAmounts,
            uint256 nonWinningAmount
        );

    function getBlueNumberFrequency(
        uint256 gameIndex
    ) external view returns (uint256[] memory blueNumberFrequency);

    function getWinningNumber(
        uint256 gameIndex
    )
        external
        view
        returns (
            uint256 finalWinningNumber,
            uint256 blueNumber,
            uint256 contractBalance,
            uint256 priceRate
        );

    function getWinning(
        address account,
        uint256 gameIndex
    )
        external
        view
        returns (
            uint256[] memory winningIndices_,
            uint256[] memory earnings,
            bool withdrawed
        );

    function getNumberOfParticipations(
        address account
    ) external view returns (uint256);

    function hasUsedFreeEntry(address account) external view returns (bool);

    function hasUsedFreeEntryForFan(
        address account,
        uint256 gameIndex
    ) external view returns (bool);

    function isForecastAwardee(
        address account
    ) external view returns (bool, uint256);

    function isSavior(address account) external view returns (bool);

    function getParticipants(
        uint256 gameIndex
    )
        external
        returns (address[] memory participants, uint256[][] memory predictions);

    function getWinners(
        uint256 gameIndex
    )
        external
        view
        returns (uint256[] memory winnings, address[][] memory winners);

    function getNonWinners(
        uint256 gameIndex
    )
        external
        view
        returns (uint256 nonWinnersAmount, address[] memory nonwinners);

    function getGame(
        uint256 gameIndex
    ) external view returns (GameStruct memory game);

    function getForecastAwardees()
        external
        view
        returns (address[][] memory awardees);

    function getSaviors() external view returns (address[] memory _saviors);

    function hasAccess(address account) external returns (bool);

    function license() external pure returns (string memory);

    function startGame() external returns (bool);

    function participateWithEter(
        uint256[] memory pricePredictions
    ) external returns (bool);

    function participateWithUSD(
        uint256[] memory pricePredictions
    ) external returns (bool);

    function participateWithFreeEntry(
        uint256 pricePrediction
    ) external returns (bool);

    function checkMyWinning() external returns (bool);

    function withdrawMyWinning() external returns (bool);

    function addToForecastAwardees(uint256 slotIndex) external returns (bool);

    function awardForecastPrize() external returns (bool);

    function awardSaviorPrize() external returns (bool);

    function donate(
        uint256 treasuryIndex,
        uint256 eterAmount
    ) external returns (bool);

    function initGameZero() external;

    function changeAccess(address account, bool add) external;

    function changeResearchAndDevelopment(
        address newResearchAndDevelopment
    ) external;

    function changeDescription(string memory _newDescription) external;

    function changeTutorial(string memory newTutorial) external;

    function changeUSD(address newUSD) external;

    function changeGeneratorAddress(address newGeneratorAddress) external;

    function changeFanAddress(address newFanAddress) external;

    function approveGenerator(uint256 usdAmount, uint256 eterAmount) external;

    function approveToken(address token) external;

    function announce(string memory news) external;
}

interface Ieternal is IERC20Metadata {
    event Announcements(string news);

    function initRate() external;

    function initEternityContracts(
        address _USD,
        address _RADEC,
        address _GENERATORCONTRACT,
        address _FANCONTRACT,
        address _FORECASTCONTRACT,
        address _IC,
        address _EIPM,
        address _PC,
        address _DC,
        address ownersDelegate
    ) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function description() external view returns (string memory);

    function eterBalanceOfTreasury() external view returns (uint256);

    function eterBalanceOfSecondTreasury() external view returns (uint256);

    function totalBurnt() external view returns (uint256);

    function totalToken() external view returns (uint256);

    function totalDonate() external view returns (uint256);

    function isWhitelist(address whitelist) external view returns (bool);

    function getTotalTransferLevy() external view returns (uint256);

    function getTotalSellLevy() external view returns (uint256);

    function divisor() external view returns (uint256);

    function getGrowthRate() external view returns (uint256, uint256);

    function EterToET(uint256 eterAmount) external view returns (uint256);

    function ETtoEter(uint256 ETamount) external view returns (uint256);

    function USDtoEter(uint256 USDamount) external view returns (uint256);

    function EterToUSD(uint256 amount) external view returns (uint256);

    function USDtoET(uint256 USDamount) external view returns (uint256);

    function ETtoUSD(uint256 ETamount) external view returns (uint256);

    function currentRate() external view returns (uint256);

    function rateToReach() external view returns (uint256);

    function ETamountRequired() external view returns (uint256);

    function eterBalRequired() external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function getEternityContracts()
        external
        view
        returns (
            address USDcontract,
            address researchAndDevelopment,
            address EterContract,
            address FanCommunityContract,
            address ForecastContract,
            address InsuranceContract,
            address EIPManagerContract,
            address ProviderContract
        );

    function getRateVariables()
        external
        view
        returns (uint256, uint256, uint256);

    function getChangeInRate()
        external
        view
        returns (uint256[] memory, uint256[] memory, uint256[] memory);

    function buyTutorial() external pure returns (string memory);

    function license() external pure returns (string memory);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function controlRate() external;

    function buy(uint256 eterAmount) external returns (uint256);

    function sell(
        uint256 ETamount,
        address receiver
    ) external returns (uint256 eterAmount);

    function convert(uint256 ETamount) external returns (uint256 eterAmount);

    function burn(uint256 amount) external returns (bool);

    function donate(uint256 eterAmount) external returns (bool);

    function changeWhitelist(address whitelist, bool add) external;

    function changeDescription(string memory _newDescription) external;

    function announce(string memory news) external;

    function approveToken(address token) external;
}

interface Iinsurance {
    struct ETshare {
        uint256 requiredUSDamount;
        uint256 currentPaymentInUSD;
        uint256 eterAmount;
        uint256 ETamount;
        uint256 percentPaidInET;
        uint256 percentPaidInEter;
    }

    struct Levies {
        uint256 valueLevy;
        uint256 periodLevy;
        uint256 issueLevy;
        uint256 referrerLevy;
        uint256 RADLevy;
        uint256 timeLevy;
        uint256 balanceLevy;
    }

    struct ReserveParams {
        uint256 paymentOption;
        uint256 amountOption;
        uint256 periodOption;
        uint256 paymentPercentage;
    }

    struct ETdistribution {
        uint256 TOTAL;
        uint256 RAD;
        uint256 PC;
        uint256 IC;
        uint256 REFERRER;
        uint256 EIPM;
        uint256 EC;
        uint256 CALLER;
    }

    struct ReservedET {
        address referrer;
        ETshare e;
        Levies l;
        uint256 startDate;
        uint256 unlockDate;
    }

    struct ReferrerInfo {
        bool isEITS;
        uint256[] EIPsSold;
        mapping(uint256 => uint256) incomeFromTokenIds;
        uint256 totalIncome;
        uint256 referrerIncome;
        uint256 EITSincome;
    }

    function eterSecondTreasury() external view returns (uint256);

    function numberOfEITS() external view returns (uint256);

    function getEITSPrize() external view returns (uint256);

    function getEternityContracts()
        external
        view
        returns (
            address USDcontract,
            address researchAndDevelopment,
            address EterContract,
            address FanCommunityContract,
            address ForecastContract,
            address EternalContract,
            address EIPManagerContract,
            address ProviderContract,
            address DEFIcontract
        );

    function getWeeksPassed() external view returns (uint256, uint256, uint256);

    function totalDonate() external view returns (uint256);

    function getReservedET(
        uint256 tokenID
    ) external view returns (ReservedET memory);

    function getReservedETs(
        address buyer
    )
        external
        view
        returns (
            ReservedET[] memory RET,
            uint256[] memory tokenIDs,
            uint256 len
        );

    function getReservedTokenIds(
        address buyer
    ) external view returns (uint256[] memory);

    function getInsuranceReferrer(
        address account
    )
        external
        view
        returns (
            uint256 totalIncome,
            uint256 referrerIncome,
            uint256 EITSincome,
            uint256 numOfEIPsSold,
            uint256[] memory EIPsSold,
            uint256[] memory incomeFromTokenIds,
            bool isEITS
        );

    function getEITSs() external view returns (address[] memory);

    function getTotalETamountReserved() external view returns (uint256);

    function hasAccess(address account) external view returns (bool);

    function name() external pure returns (string memory);

    function license() external pure returns (string memory);

    function reserveET(
        ReserveParams memory r
    ) external returns (ReservedET memory);

    function addToReserve(
        uint256 tokenID,
        uint256 paymentOption,
        uint256 paymentPercentage
    ) external returns (ReservedET memory);

    function completeReserve(
        uint256 tokenID,
        address receiver
    ) external returns (uint256);

    function endWeek() external;

    function changeHeir(
        address[] memory heirs,
        uint256[] memory heirShares,
        uint256 paymentOption,
        bool addOneHeir
    ) external;

    function reducePeriod(
        uint256 tokenID,
        uint256 paymentOption,
        uint256 numOfDaysFromStart
    ) external;

    function buyBack(
        uint256 tokenID,
        bool receiveET,
        address receiver
    ) external returns (uint256);

    function donate(
        uint256 treasuryIndex,
        uint256 eterAmount
    ) external returns (bool);

    function transferEterToEC(uint256 eterRequired) external;

    function transferEtertoIC(uint256 eterToTransfer) external;

    function transferToDEFI() external returns (uint256);

    function editReservedTokenIDs(
        uint256 tokenId,
        address oldOwner,
        address newOwner
    ) external;

    function reduceTransferLevy(uint256 tokenId, bool _isHeir) external;

    function initDEFI(bool _initiateDefi) external;

    function changeAccess(address account, bool add) external;

    function initEternityContracts(
        address _USD,
        address _RADADDRESS,
        address _GENERATORCONTRACT,
        address _FANCONTRACT,
        address _FORECASTCONTRACT,
        address _EC,
        address _EIPM,
        address _PC,
        address _DC,
        address ownersDelegate
    ) external;

    function approveToken(address token) external;

    function addToEITSawardee() external returns (bool);

    function awardEITSPrize() external returns (bool);
}

interface IEIPM is IERC165, IERC721, IERC721Metadata {
    event ContractURIUpdated();

    struct TokenInfo {
        uint256 amountOpt;
        uint256 colorIndex;
        bool generated;
    }

    struct Heirs {
        address[] heirs;
        uint256[] heirShares;
    }

    struct Shareholders {
        uint256 totalProfit;
        mapping(uint256 => mapping(uint256 => uint256)) profits;
        mapping(uint256 => bool) received;
    }

    struct Dividends {
        uint256 numberOfShareholders;
        uint256 startDate;
        uint256[] profitAmount;
        uint256[] receivedAmount;
        uint256[] sharesCount;
        uint256[] totalShares;
        mapping(uint256 => bool) tokenIdsChecked;
        mapping(uint256 => address) receivers;
        mapping(address => mapping(uint256 => uint256[])) receiversProfits;
        mapping(address => bool) hasParticipated;
        bool hasDistributed;
    }

    function hasAccess(address account) external view returns (bool);

    function isWhitelist(address whitelist) external view returns (bool);

    function changeWhitelist(address whitelist, bool add) external;

    function approvePC() external;

    function changeAccess(address account, bool add) external;

    function updateBaseURI(string memory newBaseURI) external;

    function setContractURI(string memory newURI) external;

    function initEternityContracts(
        address _USD,
        address _RADEIPM,
        address _GENERATORCONTRACT,
        address _FANCONTRACT,
        address _FORECASTCONTRACT,
        address _EC,
        address _IC,
        address _PC,
        address _DC,
        address ownersDelegate
    ) external;

    function approveToken(address token) external;

    function license() external pure returns (string memory);

    function getEternityContracts()
        external
        view
        returns (
            address USDcontract,
            address researchAndDevelopment,
            address EterContract,
            address FanCommunityContract,
            address ForecastContract,
            address EternalContract,
            address InsuranceContract,
            address ProviderContract
        );

    function getbaseURI() external view returns (string memory);

    function totalBurnt() external view returns (uint256);

    function totalDonate() external view returns (uint256);

    function tokenCounter() external view returns (uint256);

    function contractURI() external view returns (string memory);

    function getSeasonCounter() external view returns (uint256);

    function getCurrentColorIdStatus()
        external
        view
        returns (uint256[][] memory, uint256[][] memory, uint256[][] memory);

    function getCurrentSeasonTimestamp()
        external
        view
        returns (uint256, uint256);

    function generateRandomNum(
        uint256 tokenId,
        uint256 randNum
    ) external view returns (uint256);

    function generateAverageNumber(
        uint256 tokenId
    ) external view returns (uint256);

    function getTokenInfo(
        uint256 tokenId
    ) external view returns (TokenInfo memory);

    function isEIPburned(uint256 tokenId) external view returns (bool);

    function isCEIP(uint256 tokenId) external view returns (bool);

    function totalCEIPs() external view returns (uint256);

    function getReservedETs(
        address buyer
    )
        external
        view
        returns (
            Iinsurance.ReservedET[] memory RET,
            uint256[] memory tokenIDs,
            uint256 len
        );

    function getShareholder(
        address shareholder,
        uint256 seasonIndex
    )
        external
        view
        returns (uint256 totalProfit, uint256[] memory profits, bool received);

    function getDividendReceivers(
        uint256 seasonIndex
    )
        external
        view
        returns (
            address[] memory receivers,
            uint256[][][] memory receiversProfits
        );

    function getDividends(
        uint256 seasonIndex
    )
        external
        view
        returns (
            uint256 numberOfShareholders,
            uint256 startDate,
            uint256[] memory profitAmount,
            uint256[] memory receivedAmount,
            uint256[] memory sharesCount,
            uint256[] memory totalShares
        );

    function colorDoesNotExist(
        uint256 amountOption,
        uint256 colorIndex
    ) external view returns (bool);

    function isHeir(
        address tokenOwner,
        address heir
    ) external view returns (bool);

    function getHeirs(address account) external view returns (Heirs memory);

    function checkCallerOrHeir(
        uint256 tokenId,
        address caller
    ) external view returns (bool _isHeir, Heirs memory h);

    function transfer(address to, uint256 tokenId) external;

    function safeTransfer(
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    function mint(
        address to,
        uint256 amountOption
    ) external returns (uint256 tokenId);

    function completeEIP(uint256 tokenId) external;

    function startSeason() external;

    function distributeTreasuries() external;

    function checkProfit(address tokenOwner) external returns (bool);

    function receiveProfit(
        address tokenOwner,
        address receiver
    ) external returns (bool);

    function addHeir(
        address caller,
        address extraHeir,
        uint256 heirShare
    ) external returns (bool);

    function editHeirs(
        address caller,
        address[] memory heirs,
        uint256[] memory heirShares
    ) external returns (uint256);

    function donate(uint256 ETamount) external returns (bool);
}

interface IAssistant {
    function approveToken(address token) external;

    function approveNFT(address token) external;

    function name() external pure returns (string memory);

    function license() external pure returns (string memory);

    function getEternityContracts()
        external
        view
        returns (
            address USDcontract,
            address EterContract,
            address EternalContract,
            address InsuranceContract,
            address EIPmanager
        );

    function initEternityContracts(
        address _USD,
        address _GENERATORCONTRACT,
        address _EC,
        address _IC,
        address _EIPM
    ) external;

    function approveContracts() external;

    function giftETER(
        uint256 usdAmount,
        address receiver
    ) external returns (uint256 eterAmount);

    function giftUSD(
        uint256 eterAmount,
        address receiver
    ) external returns (uint256 usdAmount);

    function giftUSDwithET(
        uint256 ETamount,
        address receiver
    ) external returns (uint256 usdAmount, uint256 eterAmount);

    function getSHIELDindex(uint256 tokenId) external view returns (uint256);

    function transferSHIELD(
        uint256 tokenId,
        address receiver
    ) external returns (bool);

    function groupTransferSHIELDs(
        uint256[] memory tokenIds,
        address[] memory receivers
    ) external returns (bool);

    function buyBackSHIELD(
        uint256 tokenId,
        bool receiveET,
        address receiver
    ) external returns (uint256);

    function groupBuyBackSHIELDs(
        uint256[] memory tokenIds,
        bool[] memory receiveETs,
        address[] memory receivers
    ) external returns (bool);

    function giftSHIELD(
        uint256 tokenId,
        address receiver
    ) external returns (bool);
}

interface IDefi {}

interface IProvider {}

interface IStock is IERC165, IERC721, IERC721Metadata {
    event ContractURIUpdated();

    struct Stock {
        address referrer;
        uint256 dateBought;
        uint256 multiplier;
        uint256 percentPaid;
    }

    struct StockReferrer {
        uint256[] stocksSold;
        uint256 stockAward;
    }

    function stocksCompleted(address account) external view returns (uint256);

    function getStocksOwned(
        address account
    ) external view returns (uint256[] memory);

    function getMultiplier(uint256 tokenId) external view returns (uint256);

    function getStockInfo(
        uint256 tokenId
    ) external view returns (bool, uint256);

    function totalSupply() external view returns (uint256);
}

interface IEternityDAO {
    event ProposalCreated(
        uint256 indexed proposalId,
        ProposalParams params,
        address approver,
        address proposer
    );

    event CastVote(
        uint256 indexed proposalId,
        address indexed voter,
        address caller,
        int256 totalVoteWeight
    );

    event ProposalReported(
        uint256 indexed proposalId,
        address reporter,
        string reason
    );

    event ProposalCanceled(uint256 indexed proposalId, string reason);

    event ProposalExecuted(
        uint256 indexed proposalId,
        bool[] successes,
        bytes[] returnDatas
    );

    enum ProposalState {
        Started,
        Successful,
        Failed,
        Canceled,
        Reported
    }

    struct ProposalParams {
        address[] targets;
        uint256[] values;
        bytes[] calldatas;
        string description;
    }

    struct ProposalCore {
        ProposalState state;
        address proposer;
        bytes32 proposalHash;
        uint256 startDate;
        uint256 endDate;
        uint256 numberOfParticipants;
        uint256 numberOfVotes;
        int256 totalVoteWeight;
    }

    struct Vote {
        uint256 proposalId;
        bool agree;
    }

    struct ShareOfDividend {
        uint256 seasonId;
        uint256 shareOfEter;
        uint256 shareOfEternal;
    }

    struct Stockholder {
        uint16 stocksBought;
        ShareOfDividend[] dividends;
        Vote[] votes;
        uint256[] proposals;
        uint256 totalEterDividend;
        uint256 totalEternalDividend;
        uint256 successfulProposals;
    }

    struct Dividend {
        uint256 idProfit;
        uint256 multiplierProfit;
        bool checked;
        bool received;
    }

    struct SeasonDividends {
        uint256 startDate;
        uint256 numberOfStockholders;
        uint256 numberOfStocks;
        uint256 eterDividends;
        uint256 eternalDividends;
        uint256 totalIds;
        uint256 totalMultipliers;
        mapping(uint256 => bool) tokenIdsChecked;
        mapping(address => Dividend) receivers;
        bool hasDistributed;
    }

    function proposalCounter() external view returns (uint256);

    function getStockholderProposals(
        address account
    ) external view returns (uint256);

    function hasVoted(address voter) external view returns (bool);

    function DAOowner() external view returns (address);
}

interface ILegioner {
    function isLegioner(address _legioner) external view returns (bool);

    function upgradeToLegend(address _legioner) external returns (bool);
}

interface ISublegioner {
    function isSubLegioner(address _sublegioner) external view returns (bool);

    function upgradeToLegioner(address _sublegioner) external returns (bool);
}

interface ILegend {
    struct Legend {
        bool isLegend;
        uint256 totalIncome;
    }

    struct LegendShareType {
        uint256 share;
        bool received;
    }

    struct SeasonShares {
        uint256 startDate;
        uint256 numOfLegends;
        uint256 eterShares;
        uint256 totalLegendShares;
        mapping(address => LegendShareType) _legendShares;
        bool hasDistributed;
    }

    function isLegend(address _legend) external view returns (bool);
}

interface IElite {
    function isElite(address _legend) external view returns (bool);
}
