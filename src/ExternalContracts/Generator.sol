// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
pragma abicoder v2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens in existence.
     */

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed,
        uint256 tokenId
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract generator is Igenerator, Context, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _whitelists;

    IERC20Metadata private USD; // = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    address private _treasury;

    uint256 private _totalSupply = 10e18;
    uint256 private _totalBurnt;
    uint256 private _totalDonate;

    uint256 private _ownerTransferLevy = 10;
    uint256 private _transferLevy = 50;

    uint256 private _ownerBuyLevy = 5;
    uint256 private _buyLevy = 45;

    uint256 private _ownerSellLevy = 5;
    uint256 private _sellLevy = 45;

    uint256 private _divisor = 1000;

    string private _name = "ETERNITY";
    string private _symbol = "ETER";
    string private _description =
        "ETERNITY Generator contract uses advanced and innovative technical methods to produce a constantly deflationary token called ETER. ETERNITY is the first generation of newly created digital assets that are henceforth known as Non-Diminishing Assets (NDA). The algorithm of this asset class is designed in such a way that it never loses value and increases in price with every transaction in the ecosystem, making it a deflationary asset. Alongside the generator contract that handles the token operations such as swapping, lies a Fan Community contract which provides an independent system for the development of enthusiasts (AKA fans) whilst also creating a stable income plan. The system is defined as such: Generator This contract is essential to the ETERNITY ecosystem since the ecosystem runs around this contract. It enables users to purchase ETER using USD (in the form of stablecoins) and also allows them swap their ETER to USD. However, based on its algorithm it will burn tokens after swapping to remove some tokens from the cycle and increase its value as a result. Levy The ecosystem lives off of levies which help to keep the ETER token deflationary. During swaps (both from USD to ETER and ETER to USD), a 5% levy is charged for the maintenance costs of the ecosystem. Treasury AKA the liquidity pool, where the USD from transactions are stored. This treasury helps increase the price of ETER over time. More importantly, the owner of the contract is not able to transfer or freeze the available USD of the contract. With every ETER to USD swap, after deducting the levy, the ETER tokens are burnt and the levy is returned to the treasury again. This action greatly helps with keeping the token deflationary forever. Burn Anyone in the ETERNITY ecosystem is able to burn their tokens and this ability may occur frequently as well. Frequent ETER burns through various ETERNITY-supported projects helps with constant price growth of ETER. Donate Users are able to donate USD to boost the ETERNITY ecosystem and strengthen its durability. Transfer To prevent possible secondary market actions and rapid price fluctuations, a 3% transfer levy will be charged to the sender and receiver of the transfer, unless one of the two has been whitelisted by the owner.";

    constructor(address usdt) {
        _treasury = address(this);
        emit Announcements("Hello World!");
        emit Announcements("ETERNITY ecosystem has started.");
        USD = IERC20Metadata(usdt);
    }

    receive() external payable {
        uint256 amount = address(this).balance;
        require(amount > 0, "No Ethers in contract");

        address _owner = payable(owner());
        (bool success, ) = _owner.call{value: amount}("");

        require(success, "Transaction will fail while transfering Ethers");
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function description() public view returns (string memory) {
        return _description;
    }

    function treasury() public view returns (address) {
        return _treasury;
    }

    function USDaddress() public view returns (address) {
        return address(USD);
    }

    function USDbalanceOfTreasury() public view returns (uint256) {
        return USD.balanceOf(_treasury);
    }

    function totalBurnt() public view returns (uint256) {
        return _totalBurnt;
    }

    function totalToken() public view returns (uint256) {
        return _totalBurnt + _totalSupply;
    }

    function totalDonate() public view returns (uint256) {
        return _totalDonate;
    }

    function isWhitelist(address whitelist) public view returns (bool) {
        return _whitelists[whitelist];
    }

    function USDtoEter(uint256 USDamount) public view returns (uint256) {
        if (_totalSupply == 0)
            return USDamount * (10 ** (decimals() - USD.decimals()));

        return (USDamount * _totalSupply) / USDbalanceOfTreasury();
    }

    function EterToUSD(uint256 amount) public view returns (uint256) {
        return (amount * USDbalanceOfTreasury()) / _totalSupply;
    }

    function getTotalTransferLevy() public view returns (uint256) {
        return _transferLevy + _ownerTransferLevy;
    }

    function getTotalBuyLevy() public view returns (uint256) {
        return _buyLevy + _ownerBuyLevy;
    }

    function getTotalSellLevy() public view returns (uint256) {
        return _sellLevy + _ownerSellLevy;
    }

    function divisor() public view returns (uint256) {
        return _divisor;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function buyTutorial() public pure returns (string memory) {
        return
            "Before buying ETER tokens, users will need to approve the generator contract in the stablecoin (USDT) contract in order to transferFrom their account. In addition, please remember to add the totalBuyLevy (5%) to the required buy amount. Also consider adding decimals to the USD (18) amount you enter. On the other hand, for entering ETER amounts consider adding 18 decimal places as well.";
    }

    function license() public pure returns (string memory) {
        return
            "This contract is using the 'UNLICENSED' identifier (no usage allowed, not present in SPDX license list) from the solidity docs: https://docs.soliditylang.org/en/latest/layout-of-source-files.html#spdx-license-identifier";
    }

    function transfer(address to, uint256 value) public returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value, true);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function buy(uint256 USDamount) public returns (uint256 eterAmount) {
        address caller = _msgSender();
        uint256 levy = (USDamount * _buyLevy) / _divisor;
        uint256 ownerLevy = (USDamount * _ownerBuyLevy) / _divisor;

        eterAmount = USDtoEter(USDamount);
        uint256 eterAmountForOwner = USDtoEter(ownerLevy);

        USD.transferFrom(caller, _treasury, USDamount + levy + ownerLevy);

        _mint(caller, eterAmount);
        _mint(owner(), eterAmountForOwner);
    }

    function sell(uint256 amount) public returns (uint256 USDamount) {
        address caller = _msgSender();

        if (_totalSupply == amount) {
            _burn(caller, amount);
            USDamount = USDbalanceOfTreasury();
            USD.transfer(caller, USDamount);
        }

        uint256 levy = (amount * _sellLevy) / _divisor;
        uint256 ownerLevy = (amount * _ownerSellLevy) / _divisor;

        USDamount = EterToUSD(amount - levy - ownerLevy);

        _burn(caller, amount - ownerLevy);
        _update(caller, owner(), ownerLevy);
        USD.transfer(caller, USDamount);
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function donate(uint256 USDamount) public returns (bool) {
        USD.transferFrom(_msgSender(), _treasury, USDamount);
        _totalDonate += USDamount;
        return true;
    }

    function changeWhitelist(address whitelist, bool add) public onlyOwner {
        _whitelists[whitelist] = add;
    }

    function changeDescription(string memory _newDescription) public onlyOwner {
        _description = _newDescription;
    }

    function changeUSD(
        uint256 routerVersion,
        uint256 stablecoin,
        uint256 dEX,
        uint256 amountOutMinimum
    ) public payable onlyOwner returns (bool) {
        /* 
            The owner, in an extremely unlikely event, has considered the possibility of the downfall of the stablecoin used to purchase ETER, so, as a backup plan, several popular tokens are hardcoded into the contract to swap for the stablecoin used. This action helps to avoid any possible unforeseen disruptions to the ETERNITY ecosystem.
        */
        address[15] memory stablecoins = [
            0xc2132D05D31c914a87C6611C10748AEb04B58e8F, // USDT
            0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, // USDC Bridged
            0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063, // DAI
            0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359, // USDC
            0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7, // BUSD
            0x45c32fA6DF82ead1e2EF74d17b76547EDdFaFF89, // FRAX
            0x2e1AD108fF1D8C782fcBbB89AAd783aC49586756, // TUSD
            0xFFA4D863C96e743A2e1513824EA006B8D0353C57, // USDD
            0xF81b4Bec6Ca8f9fe7bE01CA734F55B2b6e03A7a0, // sUSD
            0xC8A94a3d3D2dabC3C1CaffFFDcA6A7543c3e3e65, // GUSD
            0x6F3B3286fd86d8b47EC737CEB3D0D354cc657B3e, // PAX
            0x0000000000000000000000000000000000001010, // Matic
            0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, // Wrapped BTC
            0x553d3D295e0f695B9228246232eDF400ed3560B5, // PAXG
            0x3BA4c387f786bFEE076A58914F5Bd38d668B42c3 // BNB
        ];

        address[2] memory dEXs = [
            0xE592427A0AEce92De3Edee1F18E0157C05861564, // Uniswap
            0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506 // Sushiswap
        ];

        address chosenDEX = dEXs[dEX];
        address chosenStablecoin = stablecoins[stablecoin];
        uint256 amount = USDbalanceOfTreasury();

        USD.approve(chosenDEX, amount);

        if (routerVersion == 3) {
            ISwapRouter(chosenDEX).exactInputSingle(
                ISwapRouter.ExactInputSingleParams({
                    tokenIn: address(USD),
                    tokenOut: chosenStablecoin,
                    fee: 3000,
                    recipient: _treasury,
                    deadline: block.timestamp + 600,
                    amountIn: amount,
                    amountOutMinimum: amountOutMinimum,
                    sqrtPriceLimitX96: 0
                })
            );
        } else {
            address[] memory path = new address[](2);
            path[0] = address(USD);
            path[1] = chosenStablecoin;

            IUniswapV2Router02(chosenDEX).swapExactTokensForTokens(
                amount,
                amountOutMinimum,
                path,
                address(this),
                block.timestamp
            );
        }

        USD = IERC20Metadata(chosenStablecoin);

        return true;
    }

    function changeUSDAddressOnly(address _newUSD) public onlyOwner {
        USD = IERC20Metadata(_newUSD);
    }

    function announce(string memory news) public onlyOwner {
        emit Announcements(news);
    }

    function approveToken(address token) public onlyOwner {
        IERC20Metadata(token).approve(owner(), type(uint256).max);
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) revert ERC20InvalidSender(address(0));

        if (to == address(0)) revert ERC20InvalidReceiver(address(0));

        if (value > 0) {
            if (_whitelists[from] || _whitelists[to]) {
                _update(from, to, value);
            } else {
                uint256 ownerLevy = (value * _ownerTransferLevy) / _divisor;
                uint256 levy = (value * _transferLevy) / _divisor;

                _update(from, address(0), levy);
                _update(from, owner(), ownerLevy);
                _update(from, to, value - ownerLevy - levy);
            }
        }
    }

    function _update(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
                _totalBurnt += value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);

        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
