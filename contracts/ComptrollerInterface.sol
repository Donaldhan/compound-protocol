// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

abstract contract ComptrollerInterface {
    /// @notice Indicator that this is a Comptroller contract (for inspection)
    bool public constant isComptroller = true;

    /*** Assets You Are In ***/
    ///加入资产到市场
    function enterMarkets(address[] calldata cTokens) virtual external returns (uint[] memory);
    ///退出市场
    function exitMarket(address cToken) virtual external returns (uint);

    /*** Policy Hooks ***/
    ///是否允许存款
    function mintAllowed(address cToken, address minter, uint mintAmount) virtual external returns (uint);
    ///存款校验
    function mintVerify(address cToken, address minter, uint mintAmount, uint mintTokens) virtual external;
    ///是否允许赎回
    function redeemAllowed(address cToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    ///赎回校验
    function redeemVerify(address cToken, address redeemer, uint redeemAmount, uint redeemTokens) virtual external;
    ///是否允许借款
    function borrowAllowed(address cToken, address borrower, uint borrowAmount) virtual external returns (uint);
    ///借款校验
    function borrowVerify(address cToken, address borrower, uint borrowAmount) virtual external;
    ///是否允许偿还贷款
    function repayBorrowAllowed(
        address cToken,
        address payer, //付款者
        address borrower,//借款者
        uint repayAmount//还款金额
        ) virtual external returns (uint);
    ///偿还贷款校验    
    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) virtual external;
    ///是否允许清算 
    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) virtual external returns (uint);
    ///清算校验     
    function liquidateBorrowVerify(
        address cTokenBorrowed,//抵押资产地址
        address cTokenCollateral,//借款资产地址
        address liquidator,//清算者
        address borrower,//借款者
        uint repayAmount, //偿还金额
        uint seizeTokens //扣押token
        ) virtual external;
    ///是否允许扣押
    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) virtual external returns (uint);
    /// 扣押 token   
    function seizeVerify(
        address cTokenCollateral,//抵押资产地址
        address cTokenBorrowed,//借款资产地址
        address liquidator,//清算者
        address borrower,//借款者
        uint seizeTokens //扣押token
        ) virtual external;
    ///是否允许转账
    function transferAllowed(address cToken, address src, address dst, uint transferTokens) virtual external returns (uint);
    ///转账校验
    function transferVerify(address cToken, address src, address dst, uint transferTokens) virtual external;

    /*** Liquidity/Liquidation Calculations ***/
    /// 流动性、清算计算
    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,//借款资产
        address cTokenCollateral,//抵押资产
        uint repayAmount) virtual external view returns (uint, uint);
}
