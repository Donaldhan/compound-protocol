// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./ComptrollerInterface.sol";
import "./InterestRateModel.sol";
import "./EIP20NonStandardInterface.sol";
import "./ErrorReporter.sol";

contract CTokenStorage {
    /**
     * @dev Guard variable for re-entrancy checks 可重入检查
     */
    bool internal _notEntered;
    ///20 token 名称，符号，精度
    /**
     * @notice EIP-20 token name for this token 
     */
    string public name;

    /**
     * @notice EIP-20 token symbol for this token
     */
    string public symbol;

    /**
     * @notice EIP-20 token decimals for this token
     */
    uint8 public decimals;

    // Maximum borrow rate that can ever be applied (.0005% / block) 最大借款率，位数精度
    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    // Maximum fraction of interest that can be set aside for reserves 储备因子最大尾数
    uint internal constant reserveFactorMaxMantissa = 1e18;

    /**
     * @notice Administrator for this contract 管理员
     */
    address payable public admin;

    /**
     * @notice Pending administrator for this contract 变更中的管理员
     */ 
    address payable public pendingAdmin;

    /**
     * @notice Contract which oversees inter-cToken operations 控制器
     */
    ComptrollerInterface public comptroller;

    /**
     * @notice Model which tells what the current interest rate should be 利率模型
     */
    InterestRateModel public interestRateModel;

    // Initial exchange rate used when minting the first CTokens (used when totalSupply = 0) 
    // 初始化汇率，第一次mint时产生
    uint internal initialExchangeRateMantissa;

    /**
     * @notice Fraction of interest currently set aside for reserves
     */
    uint public reserveFactorMantissa;

    /**
     * @notice Block number that interest was last accrued at 上次计算利率的区块
     */
    uint public accrualBlockNumber;

    /**
     * @notice Accumulator of the total earned interest rate since the opening of the market 借贷索引
     */
    uint public borrowIndex;

    /**
     * @notice Total amount of outstanding borrows of the underlying in this market 市场底层资产借贷总量
     */
    uint public totalBorrows;

    /**
     * @notice Total amount of reserves of the underlying held in this market 市场底层资产总储备金
     */
    uint public totalReserves;

    /**
     * @notice Total number of tokens in circulation 总供应量
     */
    uint public totalSupply;

    // Official record of token balances for each account 每个账户的余额
    mapping (address => uint) internal accountTokens;

    // Approved token transfer amounts on behalf of others 账后授权人信息
    mapping (address => mapping (address => uint)) internal transferAllowances;

    /**
     * @notice Container for borrow balance information 借贷快照
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action 
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action 全局利率索引
     */
    struct BorrowSnapshot {
        uint principal;//本金
        uint interestIndex;
    }

    // Mapping of account addresses to outstanding borrow balances 账户借贷快照
    mapping(address => BorrowSnapshot) internal accountBorrows;

    /**
     * @notice Share of seized collateral that is added to reserves 抵押清算时的，资产扣押率
     */
    uint public constant protocolSeizeShareMantissa = 2.8e16; //2.8%
}

abstract contract CTokenInterface is CTokenStorage {
    /**
     * @notice Indicator that this is a CToken contract (for inspection) 是否为CToken合约
     */
    bool public constant isCToken = true;


    /*** Market Events ***/

    /**
     * @notice Event emitted when interest is accrued 利率变化事件
     */
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    /**
     * @notice Event emitted when tokens are minted 存款提供资产流动性Mint事件
     */
    event Mint(address minter, uint mintAmount, uint mintTokens);

    /** 
     * @notice Event emitted when tokens are redeemed 赎回事件
     */
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    /**
     * @notice Event emitted when underlying is borrowed 借贷事件
     */
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    /**
     * @notice Event emitted when a borrow is repaid 偿还贷款事件
     */
    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    /**
     * @notice Event emitted when a borrow is liquidated 清算事件
     */
    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address cTokenCollateral, uint seizeTokens);


    /*** Admin Events ***/

    /**
     * @notice Event emitted when pendingAdmin is changed 管理员变动事件
     */
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    /**
     * @notice Event emitted when pendingAdmin is accepted, which means admin is updated 新管理员产生事件
     */
    event NewAdmin(address oldAdmin, address newAdmin);

    /**
     * @notice Event emitted when comptroller is changed 校验控制器变更事件
     */
    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);

    /**
     * @notice Event emitted when interestRateModel is changed 市场利率模型变更事件
     */
    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    /**
     * @notice Event emitted when the reserve factor is changed  储备因子变更事件
     */
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    /**
     * @notice Event emitted when the reserves are added  储备金增加事件
     */ 
    event ReservesAdded(address benefactor // 增加储备者
    , uint addAmount, uint newTotalReserves);

    /**
     * @notice Event emitted when the reserves are reduced  储备金减少事件
     */
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);

    /**
     * @notice EIP20 Transfer event 20转账
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @notice EIP20 Approval event 20授权
     */
    event Approval(address indexed owner, address indexed spender, uint amount);


    /*** User Interface ***/

    function transfer(address dst, uint amount) virtual external returns (bool);
    function transferFrom(address src, address dst, uint amount) virtual external returns (bool);
    function approve(address spender, uint amount) virtual external returns (bool);
    function allowance(address owner, address spender) virtual external view returns (uint);
    function balanceOf(address owner) virtual external view returns (uint);
    ///底层资产余额
    function balanceOfUnderlying(address owner) virtual external returns (uint);
    ///账户资产快照
    function getAccountSnapshot(address account) virtual external view returns (uint, uint, uint, uint);
    ///区块借贷率
    function borrowRatePerBlock() virtual external view returns (uint);
    ///区块供应率
    function supplyRatePerBlock() virtual external view returns (uint);
    ///总借款
    function totalBorrowsCurrent() virtual external returns (uint);
    ///借款余额
    function borrowBalanceCurrent(address account) virtual external returns (uint);
    ///
    function borrowBalanceStored(address account) virtual external view returns (uint);
    ///当前汇率
    function exchangeRateCurrent() virtual external returns (uint);
    ///
    function exchangeRateStored() virtual external view returns (uint);
    ///现金
    function getCash() virtual external view returns (uint);
    ///计算利率
    function accrueInterest() virtual external returns (uint);
    ///清算扣押
    function seize(address liquidator, address borrower, uint seizeTokens) virtual external returns (uint);


    /*** Admin Functions ***/
    /// 管理员变更
    function _setPendingAdmin(address payable newPendingAdmin) virtual external returns (uint);
    /// 管理员产生
    function _acceptAdmin() virtual external returns (uint);
    /// 设置控制器
    function _setComptroller(ComptrollerInterface newComptroller) virtual external returns (uint);
    /// 设置储备金基准利率
    function _setReserveFactor(uint newReserveFactorMantissa) virtual external returns (uint);
    /// 减少储备金
    function _reduceReserves(uint reduceAmount) virtual external returns (uint);
    /// 设置利率模型
    function _setInterestRateModel(InterestRateModel newInterestRateModel) virtual external returns (uint);
}

contract CErc20Storage {
    /**
     * @notice Underlying asset for this CToken 底层资产token地址
     */
    address public underlying;
}

abstract contract CErc20Interface is CErc20Storage {

    /*** User Interface ***/
    ///存款：供应资产
    function mint(uint mintAmount) virtual external returns (uint);
    ///赎回资产
    function redeem(uint redeemTokens) virtual external returns (uint);
    ///赎回底层资产
    function redeemUnderlying(uint redeemAmount) virtual external returns (uint);
    ///借贷
    function borrow(uint borrowAmount) virtual external returns (uint);
    ///偿还借贷
    function repayBorrow(uint repayAmount) virtual external returns (uint);
    ///替借贷者，偿还借贷
    function repayBorrowBehalf(address borrower, uint repayAmount) virtual external returns (uint);
    ///清算借款
    function liquidateBorrow(address borrower, uint repayAmount, CTokenInterface cTokenCollateral) virtual external returns (uint);
    ///
    function sweepToken(EIP20NonStandardInterface token) virtual external;


    /*** Admin Functions ***/
    ///添加储备金
    function _addReserves(uint addAmount) virtual external returns (uint);
}

contract CDelegationStorage {
    /**
     * @notice Implementation address for this contract 当前合约的实现
     */
    address public implementation;
}

abstract contract CDelegatorInterface is CDelegationStorage {
    /**
     * @notice Emitted when implementation is changed 实现变更
     */
    event NewImplementation(address oldImplementation, address newImplementation);

    /**
     * @notice Called by the admin to update the implementation of the delegator 设置实现
     * @param implementation_ The address of the new implementation for delegation
     * @param allowResign Flag to indicate whether to call _resignImplementation on the old implementation 是否调用旧版本实现的_resignImplementation方法
     * @param becomeImplementationData The encoded bytes data to be passed to _becomeImplementation 传给新实现的数据_becomeImplementation
     */
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) virtual external;
}

abstract contract CDelegateInterface is CDelegationStorage {
    /**
     * @notice Called by the delegator on a delegate to initialize it for duty  成为新代理时触发
     * @dev Should revert if any issues arise which make it unfit for delegation
     * @param data The encoded bytes data for any initialization  代理初始化数据
     */
    function _becomeImplementation(bytes memory data) virtual external;

    /**
     * @notice Called by the delegator on a delegate to forfeit its responsibility 代理变更时，触发
     */
    function _resignImplementation() virtual external;
}
