// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    // function renounceOwnership() public virtual onlyOwner {
    //     _transferOwnership(address(0));
    // }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

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
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

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
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

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
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

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
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

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
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

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
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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

interface Igenerator is 
    IERC20Metadata, 
    IERC20Errors 
{
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

    IERC20Metadata private USD = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    address private _treasury;

    uint256 private _totalSupply;
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
    string private _description = "ETERNITY Generator contract uses advanced and innovative technical methods to produce a constantly deflationary token called ETER. ETERNITY is the first generation of newly created digital assets that are henceforth known as Non-Diminishing Assets (NDA). The algorithm of this asset class is designed in such a way that it never loses value and increases in price with every transaction in the ecosystem, making it a deflationary asset. Alongside the generator contract that handles the token operations such as swapping, lies a Fan Community contract which provides an independent system for the development of enthusiasts (AKA fans) whilst also creating a stable income plan. The system is defined as such: Generator This contract is essential to the ETERNITY ecosystem since the ecosystem runs around this contract. It enables users to purchase ETER using USD (in the form of stablecoins) and also allows them swap their ETER to USD. However, based on its algorithm it will burn tokens after swapping to remove some tokens from the cycle and increase its value as a result. Levy The ecosystem lives off of levies which help to keep the ETER token deflationary. During swaps (both from USD to ETER and ETER to USD), a 5% levy is charged for the maintenance costs of the ecosystem. Treasury AKA the liquidity pool, where the USD from transactions are stored. This treasury helps increase the price of ETER over time. More importantly, the owner of the contract is not able to transfer or freeze the available USD of the contract. With every ETER to USD swap, after deducting the levy, the ETER tokens are burnt and the levy is returned to the treasury again. This action greatly helps with keeping the token deflationary forever. Burn Anyone in the ETERNITY ecosystem is able to burn their tokens and this ability may occur frequently as well. Frequent ETER burns through various ETERNITY-supported projects helps with constant price growth of ETER. Donate Users are able to donate USD to boost the ETERNITY ecosystem and strengthen its durability. Transfer To prevent possible secondary market actions and rapid price fluctuations, a 3% transfer levy will be charged to the sender and receiver of the transfer, unless one of the two has been whitelisted by the owner.";

    constructor() {
        _treasury = address(this);
        emit Announcements("Hello World!");
        emit Announcements("ETERNITY ecosystem has started.");
    }

    receive() external payable {
        uint256 amount = address(this).balance;
        require(
            amount > 0, 
            "No Ethers in contract"
        );
        
        address _owner = payable(owner());
        (bool success, ) = _owner.call{value: amount}("");

        require(success, "Transaction will fail while transfering Ethers");
    }

    function name() 
        public 
        view 
        returns (string memory) 
    {
        return _name;
    }

    function symbol() 
        public 
        view 
        returns (string memory) 
    {
        return _symbol;
    }

    function totalSupply() 
        public 
        view 
        returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address account) 
        public 
        view 
        returns (uint256) 
    {
        return _balances[account];
    }

    function description() 
        public 
        view 
        returns (string memory) 
    {
        return _description;
    }

    function treasury() 
        public 
        view 
        returns (address) 
    {
        return _treasury;
    }

    function USDaddress() 
        public 
        view 
        returns (address) 
    {
        return address(USD);
    }

    function USDbalanceOfTreasury() 
        public 
        view 
        returns (uint256) 
    {
        return USD.balanceOf(_treasury);
    }

    function totalBurnt() 
        public 
        view 
        returns (uint256) 
    {
        return _totalBurnt;
    }
    
    function totalToken() 
        public 
        view 
        returns (uint256) 
    {
        return _totalBurnt + _totalSupply;
    }
    
    function totalDonate() 
        public 
        view 
        returns (uint256) 
    {
        return _totalDonate;
    }
    
    function isWhitelist(
        address whitelist
    ) 
        public 
        view 
        returns (bool) 
    {
        return _whitelists[whitelist];
    }

    function USDtoEter(uint256 USDamount) 
        public 
        view 
        returns (uint256) 
    {
        if (_totalSupply == 0) return USDamount * (
            10 ** (decimals() - USD.decimals())
        );

        return (USDamount * _totalSupply) / USDbalanceOfTreasury();
    }

    function EterToUSD(uint256 amount) 
        public 
        view 
        returns (uint256) 
    {
        return (amount * USDbalanceOfTreasury()) / _totalSupply;
    }

    function getTotalTransferLevy() 
        public 
        view 
        returns (uint256) 
    {
        return _transferLevy + _ownerTransferLevy;
    }

    function getTotalBuyLevy() 
        public 
        view 
        returns (uint256) 
    {
        return _buyLevy + _ownerBuyLevy;
    }

    function getTotalSellLevy() 
        public 
        view 
        returns (uint256) 
    {
        return _sellLevy + _ownerSellLevy;
    }

    function divisor() 
        public 
        view 
        returns (uint256) 
    {
        return _divisor;
    }

    function decimals() 
        public 
        pure 
        returns (uint8) 
    {
        return 18;
    }

    function buyTutorial()
        public
        pure
        returns (string memory) 
    {
        return "Before buying ETER tokens, users will need to approve the generator contract in the stablecoin (USDT) contract in order to transferFrom their account. In addition, please remember to add the totalBuyLevy (5%) to the required buy amount. Also consider adding decimals to the USD (18) amount you enter. On the other hand, for entering ETER amounts consider adding 18 decimal places as well.";
    }

    function license()
        public
        pure
        returns (string memory) 
    {
        return "This contract is using the 'UNLICENSED' identifier (no usage allowed, not present in SPDX license list) from the solidity docs: https://docs.soliditylang.org/en/latest/layout-of-source-files.html#spdx-license-identifier";
    }

    function transfer(
        address to, 
        uint256 value
    ) 
        public 
        returns (bool) 
    {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) 
        public 
        view 
        returns (uint256) 
    {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) 
        public 
        returns (bool) 
    {
        address owner = _msgSender();
        _approve(owner, spender, value, true); 
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) 
        public 
        returns (bool) 
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function buy(
        uint256 USDamount
    ) 
        public 
        returns (uint256 eterAmount) 
    {
        address caller = _msgSender();
        uint256 levy = USDamount * _buyLevy / _divisor;
        uint256 ownerLevy = USDamount * _ownerBuyLevy / _divisor;

        eterAmount = USDtoEter(USDamount);
        uint256 eterAmountForOwner = USDtoEter(ownerLevy); 

        USD.transferFrom(caller, _treasury, USDamount + levy + ownerLevy);

        _mint(caller, eterAmount);
        _mint(owner(), eterAmountForOwner);
    }

    function sell(
        uint256 amount
    )   
        public 
        returns (uint256 USDamount) 
    {
        address caller = _msgSender();

        if (_totalSupply == amount) {
            _burn(caller, amount);
            USDamount = USDbalanceOfTreasury();
            USD.transfer(caller, USDamount);
        }
        
        uint256 levy = amount * _sellLevy / _divisor;
        uint256 ownerLevy = amount * _ownerSellLevy / _divisor;

        USDamount = EterToUSD(amount - levy - ownerLevy);
        
        _burn(caller, amount - ownerLevy);
        _update(caller, owner(), ownerLevy);
        USD.transfer(caller, USDamount);
    }

    function burn(
        uint256 amount
    )   
        public 
        returns (bool) 
    {
        _burn(_msgSender(), amount);
        return true;
    }

    function donate(
        uint256 USDamount
    )   
        public 
        returns (bool) 
    {
        USD.transferFrom(_msgSender(), _treasury, USDamount);
        _totalDonate += USDamount;
        return true;
    }

    function changeWhitelist(
        address whitelist, 
        bool add
    )   
        public 
        onlyOwner 
    {
        _whitelists[whitelist] = add;
    }

    function changeDescription(
        string memory _newDescription
    ) 
        public 
        onlyOwner 
    {
        _description = _newDescription;
    }

    function changeUSD(
        uint256 routerVersion,
        uint256 stablecoin, 
        uint256 dEX, 
        uint256 amountOutMinimum
    ) 
        public 
        payable 
        onlyOwner 
        returns (bool) 
    {
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
            0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506  // Sushiswap
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

    function changeUSDAddressOnly(
        address _newUSD
    ) 
        public
        onlyOwner
    {
        USD = IERC20Metadata(_newUSD);
    }

    function announce(
        string memory news
    )
        public 
        onlyOwner 
    {
        emit Announcements(news);
    }

    function approveToken(
        address token
    ) 
        public 
        onlyOwner 
    {
        IERC20Metadata(token).approve(owner(), type(uint256).max);
    }
    
    function _transfer(
        address from, 
        address to, 
        uint256 value
    ) 
        internal 
    {
        if (from == address(0)) revert ERC20InvalidSender(address(0));

        if (to == address(0)) revert ERC20InvalidReceiver(address(0));

        if (value > 0) {
            if (_whitelists[from] || _whitelists[to]) {
                _update(from, to, value);
            } else {
                uint256 ownerLevy = value * _ownerTransferLevy / _divisor;
                uint256 levy = value * _transferLevy / _divisor;

                _update(from, address(0), levy);
                _update(from, owner(), ownerLevy);
                _update(from, to, value - ownerLevy - levy);
            }
        }
    }

    function _update(
        address from, 
        address to, 
        uint256 value
    ) 
        internal 
    {
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

    function _mint(
        address account, 
        uint256 value
    ) 
        internal 
    {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function _burn(
        address account, 
        uint256 value
    ) 
        internal 
    {
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
    ) 
        internal 
    {
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
    ) 
        internal 
    {
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
    function awardees(uint256 slotIndex) external view returns (address[] memory);

    function numberOfAwardees(uint256 slotIndex) external view returns (uint256);
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

    function registerWithUSD(uint256 slotIndex, address referrer) external returns (bool);
    function registerWithEter(uint256 slotIndex, address referrer) external returns (bool);

    function upgradeSubscriptionWithUSD(uint256 slotIndex) external returns (bool success);
    function upgradeSubscriptionWithEter(uint256 slotIndex) external returns (bool success);

    function renewSubscriptionWithUSD() external returns (bool);
    function renewSubscriptionWithEter() external returns (bool);

    function addToAwardeeList(uint256 slotIndex) external returns (bool);
    function awardPrize() external returns (bool);
    
    function changeUSD(address newUSD) external;
    function changeDescription(string memory _newDescription) external; 

    function changeResearchAndDevelopment(address _researchAndDevelopment) external;
    function changeGeneratorContract(address _generator) external;

    function changeAccess(address _address, bool add) external;
    function approveGenerator() external;

    function announce(string memory news) external;
    function approveToken(address token) external;
}

contract fanCommunity is Context, Ownable, IfanCommunity {

    Igenerator private generatorContract;
    IERC20Metadata private USD = IERC20Metadata(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);


    mapping(address => Fan) private _fans;
    mapping(uint256 => address) private _fanCounter;
    mapping(uint256 => address) private _fanProCounter;

    mapping(uint256 => address[]) private _awardees;
    mapping(uint256 => uint256) private _prizes;

    mapping(address => bool) private _access;

    string private _description = "This contract creates a human network of the ETERNITY (ETER) ecosystem where it helps to expand the fans of the network and also provides a fair income-generating plan for them. The initial cost of joining the community is 10 USD, which most of this amount returns to the community and also helps increase the price of ETER. The commission plan is a multi-level plan up to 15 levels, whereby an unlimited number of fans can be added to the community. The commission is distributed instantly with no need for extra user interaction. In addition, with the use of price algorithms embedded into the Generator smart contract, ETER will always be deflationary.";

    address private researchAndDevelopment = 0xC7e597C1c3D0820d8eaeeF5C707f1C4BbDF21658;
    address private prizeTreasury;

    uint256 private subscriptionDateLimit = 365 days;
    
    uint256 private fanCounter = 0;
    uint256 private fanProCounter = 0;

    uint256[4] private slotsTotal = [10, 50, 210, 910];
    uint256[4] private slots = [10, 40, 160, 700];

    uint256[4] private slotMinimumEarning = [0, 0, 40, 350]; 

    uint256[5] private minimumReferees = [50, 40, 30, 20, 1];

    uint256[14] private levels = [12, 10, 8, 7, 5, 4, 6, 8, 6, 4, 5, 7, 8, 10];

    constructor (
        address _generator
    ) {
        generatorContract = Igenerator(_generator);
        prizeTreasury = address(this);
    }
    
    modifier checkFanOrHasAccess() {
        address caller = _msgSender();
        bool allow = _access[caller];

        if (!allow) {
            for (uint256 i = 0; i < fanCounter; i++) {
                if (_fanCounter[i] == caller) allow = true;
            }
        }

        require(
            allow,
            "Only fans and whitelists can call this function"
        );
        _;
    }

    modifier checkCallerOrHasAccess(address fan) {
        address caller = _msgSender();
        bool allow = _access[caller] || caller == fan;

        require(
            allow,
            "Only the owner of the address and whitelists can call this function"
        );
        _;
    }

    modifier onlyWithAccess() {
        require(
            _access[_msgSender()], 
            "Not all users have access to this function"
        );
        _;
    }

    receive() external payable {
        uint256 amount = address(this).balance;
        require(
            amount > 0, 
            "No Ethers in contract"
        );
        
        address _owner = payable(owner());
        (bool success, ) = _owner.call{value: amount}("");

        require(success, "Transaction will fail while transfering Ethers");
    }

    function description() 
        public 
        view 
        returns (string memory) 
    {
        return _description;
    }

    function generatorContractAddress() 
        public
        view
        checkFanOrHasAccess
        returns (address)
    {
        return address(generatorContract);
    }

    function USDaddress() 
        public
        view
        checkFanOrHasAccess
        returns (address)
    {
        return address(USD);
    }

    function prizeTreasuryAddress() 
        public
        view
        checkFanOrHasAccess
        returns (address)
    {
        return prizeTreasury;
    }

    function researchAndDevelopmentAddress() 
        public
        view
        checkFanOrHasAccess
        returns (address)
    {
        return researchAndDevelopment;
    }

    function getFan(
        address fan
    ) 
        public 
        view
        checkCallerOrHasAccess(fan)
        returns (Fan memory) 
    {
        return _fans[fan];
    }

    function awardees(
        uint256 slotIndex
    ) 
        public 
        view 
        onlyWithAccess
        returns (address[] memory) 
    {
        return _awardees[slotIndex];
    }

    function numberOfAwardees(
        uint256 slotIndex
    ) 
        public 
        view
        checkFanOrHasAccess 
        returns (uint256) 
    {
        return _awardees[slotIndex].length;
    }

    function prizes() 
        public 
        view
        checkFanOrHasAccess 
        returns (uint256[5] memory prizes_) 
    {
        for (uint256 i = 0; i < 5; i++) {
            prizes_[i] = _prizes[i];
        }
    }

    function getSlots() 
        public
        view
        checkFanOrHasAccess
        returns (uint256[4] memory)
    {
        return slots;
    }

    function getSlotsTotal() 
        public
        view
        checkFanOrHasAccess
        returns (uint256[4] memory)
    {
        return slotsTotal;
    }

    function getSlotMinimumEarning() 
        public
        view
        checkFanOrHasAccess
        returns (uint256[4] memory)
    {
        return slotMinimumEarning;
    }

    function getMinimumReferees() 
        public
        view
        checkFanOrHasAccess
        returns (uint256[5] memory)
    {
        return minimumReferees;
    }

    function getLevels() 
        public
        view
        checkFanOrHasAccess
        returns (uint256[14] memory)
    {
        return levels;
    }

    function getSubscriptionDateLimit() 
        public
        view
        checkFanOrHasAccess
        returns (uint256)
    {
        return subscriptionDateLimit;
    }

    function getStar(address fan) 
        public 
        view
        checkFanOrHasAccess 
        returns (uint256) 
    {
        return _fans[fan].slot + 1;
    }

    function getNumberOfFans() 
        public 
        view
        checkFanOrHasAccess 
        returns (uint256) 
    {
        return fanCounter + fanProCounter;
    }

    function getAllFans() 
        public 
        view
        onlyWithAccess 
        returns (address[] memory fans) 
    {
        fans = new address[](fanCounter);
        for (uint256 i = 0; i < fanCounter; i++) {
            fans[i] = _fanCounter[i];
        }
    }

    function getAllFanPros() 
        public 
        view
        onlyWithAccess 
        returns (address[] memory fanPros)
    {
        fanPros = new address[](fanProCounter);
        for (uint256 i = 0; i < fanProCounter; i++) {
            fanPros[i] = _fanProCounter[i];
        }
    }

    function hasAccess(
        address _address
    ) 
        public 
        view
        onlyOwner
        returns (bool) 
    {
        return _access[_address];
    }

    function tutorial()
        public
        pure
        returns (string memory) 
    {
        return "Before registering, upgradingSubscription or even renewingSubscription with both ETER and stablecoin, users will need to approve the fan community contract in the token contract (generator contract for approving ETER and (stablecoin contract for approving USDT) in order to transferFrom their account. In addition, please remember to add the totalBuyLevy (5%) to the required buy amount, when purchasing via USD (buying with ETER is exempt from paying levy). Lastly, please consider adding decimal places to your amounts (both USD and ETER decimals are 18).";
    }

    function license()
        public
        pure
        returns (string memory) 
    {
        return "This contract is using the 'UNLICENSED' identifier (no usage allowed, not present in SPDX license list) from the solidity docs: https://docs.soliditylang.org/en/latest/layout-of-source-files.html#spdx-license-identifier";
    }

    function registerWithUSD(
        uint256 slotIndex,
        address referrer
    ) 
        public 
        returns (bool) 
    {
        uint256 USDamount = slotsTotal[slotIndex] * (10 ** USD.decimals());
        return register(referrer, slotIndex, true, USDamount);
    }

    function registerWithEter(
        uint256 slotIndex,
        address referrer
    ) 
        public 
        returns (bool) 
    {
        uint256 amount = generatorContract.USDtoEter(
            slotsTotal[slotIndex] * (10 ** USD.decimals())
        );
        return register(referrer, slotIndex, false, amount);
    }

    function upgradeSubscriptionWithUSD(
        uint256 slotIndex
    ) 
        public 
        returns (bool success) 
    {
        uint256 USDamount = slots[slotIndex] * (10 ** USD.decimals());
        return upgradeSubscription(
            slotIndex, 
            true,
            USDamount
        );
    }

    function upgradeSubscriptionWithEter(
        uint256 slotIndex
    ) 
        public 
        returns (bool success) 
    {
        uint256 amount = generatorContract.USDtoEter(
            slots[slotIndex] * (10 ** USD.decimals())
        );
        return upgradeSubscription(
            slotIndex, 
            false,
            amount
        );
    }

    function renewSubscriptionWithUSD() 
        public 
        returns (bool) 
    {
        address caller = _msgSender();
        Fan storage fan = _fans[caller];

        uint256 currentSlotIndex = fan.slot;
        uint256 USDamount = slotsTotal[currentSlotIndex - 1] * (10 ** USD.decimals());

        return renewSubscription(
            true,
            USDamount,
            caller,
            fan,
            currentSlotIndex
        );
    }

    function renewSubscriptionWithEter() 
        public 
        returns (bool) 
    {
        address caller = _msgSender();
        Fan memory fan = _fans[caller];

        uint256 currentSlotIndex = fan.slot;
        uint256 amount = generatorContract.USDtoEter(
            slotsTotal[currentSlotIndex - 1] * (10 ** USD.decimals())
        );

        return renewSubscription(
            false,
            amount,
            caller,
            fan,
            currentSlotIndex
        );
    }

    function addToAwardeeList(
        uint256 slotIndex
    ) 
        public 
        returns (bool) 
    {
        address caller = _msgSender();
        Fan storage fan = _fans[caller];

        if (slotIndex == 4) {
            require(
                fan.isFanPro, 
                "Only Fan pros are able to opt for slot5 prize"
            );
        } 
        else {
            require(
                fan.slot >= slotIndex, 
                "Caller's current slot is lower than chosen slot"
            );
        }

        for (uint256 _slot = 0; _slot < 5; _slot++) {
            address[] memory a = _awardees[_slot];
            uint256 awardeeCount = a.length;

            if (slotIndex == _slot) {
                for (uint256 i = 0; i < awardeeCount; i++) {
                    require(
                        a[i] != caller,
                        "Caller is already an awardee in this slot"
                    );
                }
                continue;
            }

            if (!fan.isFanPro) {
                for (uint256 i = 0; i < awardeeCount; i++) {
                    if (a[i] == caller) {
                        fan.isAwardee[_slot] = false;
                        _awardees[_slot][i] = a[awardeeCount - 1];
                        _awardees[_slot].pop();
                        continue;
                    }
                }
            }
            else {
                if (slotIndex != 4 && _slot != 4) {
                    for (uint256 i = 0; i < awardeeCount; i++) {
                        if (a[i] == caller) {
                            fan.isAwardee[_slot] = false;
                            _awardees[_slot][i] = a[awardeeCount - 1];
                            _awardees[_slot].pop();
                            continue;
                        }
                    }
                }
            }
        }

        uint256 count = 0;
        uint256 min = minimumReferees[slotIndex];

        if (slotIndex == 4) {
            for (uint256 i = 0; i < fan.referees.length; i++) {
                if (_fans[fan.referees[i]].slot == 3) {
                    fan.isAwardee[slotIndex] = true;
                    _awardees[slotIndex].push(caller);
                    return awardPrize();
                }
            }
        } 
        else {
            for (uint256 i = 0; i < fan.referees.length; i++) {
                if (_fans[fan.referees[i]].slot >= slotIndex) {
                    count++;
                    if (count >= min) {
                        fan.isAwardee[slotIndex] = true;
                        _awardees[slotIndex].push(caller);
                        return awardPrize();
                    }
                }
            }
        }

        revert("Caller does not meet the requirements for chosen slot");
    }

    function awardPrize() 
        public 
        returns (bool) 
    {
        
        for (uint256 _slot = 0; _slot < 5; _slot++) {
            address[] memory a = _awardees[_slot];
            uint256 awardeesCount = a.length;

            if (awardeesCount == 0) continue;
            
            uint256 shareOfAwardee = _prizes[_slot] / awardeesCount;

            for (uint256 i = 0; i < awardeesCount; i++) {
                Fan storage f = _fans[a[i]];
                f.prizeEarning[_slot] += shareOfAwardee;
                generatorContract.transfer(
                    a[i],
                    shareOfAwardee
                );
            }
            _prizes[_slot] = 0;
        }

        return true;
    }

    function changeUSD(
        address newUSD
    ) 
        public 
        onlyOwner 
    {
        USD = IERC20Metadata(newUSD);
    }

    function changeDescription(
        string memory _newDescription
    ) 
        public 
        onlyOwner 
    {
        _description = _newDescription;
    }

    function changeResearchAndDevelopment(
        address _researchAndDevelopment
    ) 
        public 
        onlyOwner 
    {
        researchAndDevelopment = _researchAndDevelopment;
    }

    function changeGeneratorContract(
        address _generator
    ) 
        public 
        onlyOwner 
    {
        generatorContract = Igenerator(_generator);
    }

    function changeAccess(
        address _address, 
        bool add
    ) 
        public 
        onlyOwner 
    {
        _access[_address] = add;
    }

    function approveGenerator() 
        public 
        onlyOwner 
    {
        USD.approve(
            address(generatorContract), 
            type(uint256).max
        );
        generatorContract.approve(
            address(generatorContract), 
            type(uint256).max
        );
    }

    function announce(
        string memory news
    )
        public 
        onlyOwner 
    {
        emit Announcements(news);
    }

    function approveToken(
        address token
    ) 
        public 
        onlyOwner 
    {
        IERC20Metadata(token).approve(owner(), type(uint256).max);
    }

    function register(
        address referrer,
        uint256 slotIndex,
        bool payWithUSD,
        uint256 amount
    ) 
        internal 
        returns (bool)
    {
        address caller = _msgSender();

        require(
            _fans[caller].endOfSubscriptionDate == 0,
            "Caller has already been registered"
        );

        bool isPro = referrer == address(0);

        if (isPro) {
            require(
                slotIndex == 3, 
                "Fan pros must opt for the last slot, so please set slotIndex as 3, otherwise set a referrer address"
            );
            _fanProCounter[fanProCounter] = caller; 
            fanProCounter++;
        } 
        else {
            require (
                slotIndex <= 1, 
                "A new fan can only register upto the 2nd slot, so please choose a valid slotIndex (either 0 or 1). Unless you wish to become a fan pro, in which case you should opt for slotIndex 3 with null address set as referrer"
            );
            require(
                _fans[referrer].endOfSubscriptionDate > 0,
                "Referrer has not been registered as a fan"
            );

        }
        
        _fanCounter[fanCounter] = caller; 
        fanCounter++;

        return distribute(
            payWithUSD, 
            caller, 
            referrer, 
            slotIndex, 
            amount, 
            isPro,
            false,
            false
        );
    }

    function upgradeSubscription(
        uint256 slotIndex,
        bool payWithUSD,
        uint256 amount
    )
        internal
        returns (bool) 
    {
        address caller = _msgSender();
        Fan storage fan = _fans[caller];

        require(
            fan.referrer != address(0), 
            "Caller has not registered in network or is already a Fan pro"
        );

        require(
            generatorContract.EterToUSD(fan.earning) >=
            slotMinimumEarning[slotIndex] * (10 ** USD.decimals()),
            "Total earning does not reach the next slot's minimum requirement"
        );

        return distribute(
            payWithUSD, 
            caller, 
            fan.referrer, 
            slotIndex, 
            amount, 
            false, 
            true,
            false
        );
    }

    function renewSubscription(
        bool payWithUSD,
        uint256 amount,
        address caller,
        Fan memory fan,
        uint256 currentSlotIndex
    )
        internal 
        returns (bool) 
    {
        uint256 endDate = fan.endOfSubscriptionDate;

        require(
            endDate > 0,
            "Caller has not registered as a fan"
        );

        require(
            endDate > block.timestamp,
            "Caller's end of subscription date has passed and can no longer renew subscription"
        );

        require(
            !fan.isFanPro,
            "Caller is a fan pro and does not need to renew subscription"
        );
        
        require(
            currentSlotIndex > 0,
            "Caller does not need to renew subscription since caller's slot is 10"
        );

        return distribute(
            payWithUSD, 
            caller, 
            fan.referrer, 
            currentSlotIndex, 
            amount, 
            false, 
            true,
            true
        );
    }

    function distribute(
        bool payWithUSD,
        address caller, 
        address referrer, 
        uint256 slotIndex,
        uint256 amount,
        bool isPro,
        bool fanExists,
        bool renew
    ) 
        internal
        returns (bool)
    {
        uint256 eterAmount;

        if (payWithUSD) {
            USD.transferFrom(caller, prizeTreasury, amount * 105 / 100);
            eterAmount = generatorContract.buy(amount);
        } else {
            eterAmount = amount;
            generatorContract.transferFrom(caller, prizeTreasury, eterAmount);
        }

        uint256 fivePercent = eterAmount / 20;
        uint256 tenPercent = fivePercent * 2;

        generatorContract.transfer(caller, fivePercent);
        generatorContract.burn(fivePercent);
        eterAmount -= tenPercent;

        if (!isPro) {
            generatorContract.transfer(referrer, tenPercent);

            Fan storage ref = _fans[referrer];
            if (!fanExists) ref.referees.push(caller);
            
            ref.earning += tenPercent;

            uint256 amountTransfered = divideBetweenReferrers(
                tenPercent * 7, 
                referrer, 
                slotIndex,
                fanExists
            );
            eterAmount -= (tenPercent + amountTransfered);
        }
        else {
            generatorContract.transfer(caller, fivePercent);
            eterAmount -= fivePercent;
        }

        distributeToPrize(tenPercent);
        eterAmount -= tenPercent;

        Fan storage fan = _fans[caller];

        if (!fanExists) {
            fan.referrer = referrer;
            fan.isFanPro = isPro;
            fan.endOfSubscriptionDate = block.timestamp + subscriptionDateLimit;
        } 
        else if (renew) fan.endOfSubscriptionDate += subscriptionDateLimit;

        fan.slot = slotIndex;

        return generatorContract.transfer(
            researchAndDevelopment, 
            eterAmount
        );
    }

    function divideBetweenReferrers(
        uint256 eterAmount,
        address _referrer,
        uint256 slotIndex,
        bool fanExists
    ) 
        internal
        returns (uint256 amountTransfered)
    {
        if (fanExists) return distributeToReferrers(
            eterAmount, 
            _referrer, 
            slotIndex
        );
            
        for (uint256 i = 0; i < slotIndex + 1; i++) {
            uint256 a = eterAmount * slots[i] / slotsTotal[slotIndex];
            amountTransfered += distributeToReferrers(
                a,
                _referrer, 
                i
            );
        }
    }

    function distributeToReferrers(
        uint256 amount,
        address _referrer,
        uint256 slotIndex
    ) 
        internal
        returns (uint256 amountTransfered)
    {
        bool endLoop = false;
        uint256 level = 0;

        while (!endLoop) {
            _referrer = _fans[_referrer].referrer;

            if (_referrer == address(0)) { 
                endLoop = true;
                continue;
            }

            Fan storage ref = _fans[_referrer];

            if (
                ref.endOfSubscriptionDate < block.timestamp &&
                !ref.isFanPro &&
                ref.slot != 0
            ) 
                ref.slot = 0; 

            if (ref.slot >= slotIndex) {
                uint256 share = amount * levels[level] / 100;
                generatorContract.transfer(_referrer, share);

                ref.earning += share;
                amountTransfered += share;
                level++;
            } 

            if (level == 14) endLoop = true;
        }
    }

    function distributeToPrize(uint256 amount) internal {
        uint256 twentyPercent = amount / 5;
        _prizes[0] += twentyPercent;
        _prizes[1] += twentyPercent;
        _prizes[2] += twentyPercent;
        _prizes[3] += twentyPercent;
        _prizes[4] += twentyPercent;
    }
}