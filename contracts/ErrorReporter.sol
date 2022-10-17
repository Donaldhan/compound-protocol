// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;
//控制错误报告
contract ComptrollerErrorReporter {
  /// 错误信息
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,//没有授权
        COMPTROLLER_MISMATCH,//控制器不匹配
        INSUFFICIENT_SHORTFALL,//
        INSUFFICIENT_LIQUIDITY,//流动性不足
        INVALID_CLOSE_FACTOR,//无效的closeFactor
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,//无效的清算激励
        MARKET_NOT_ENTERED, // no longer possible
        MARKET_NOT_LISTED,//
        MARKET_ALREADY_LISTED,//
        MATH_ERROR,//
        NONZERO_BORROW_BALANCE,//非零借贷余额
        PRICE_ERROR,//价格错误
        REJECTION,//拒绝
        SNAPSHOT_ERROR,//快照错误
        TOO_MANY_ASSETS,//太多资产
        TOO_MUCH_REPAY//太多偿还
    }
   ///失败原因
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,//正在进行管理员变更
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,//正在进行管理员地址检查
        EXIT_MARKET_BALANCE_OWED,//
        EXIT_MARKET_REJECTION,//市场拒接退出
        // CLOSE_FACTOR
        SET_CLOSE_FACTOR_OWNER_CHECK,//
        SET_CLOSE_FACTOR_VALIDATION,//
        //抵押因子
        SET_COLLATERAL_FACTOR_OWNER_CHECK,//
        SET_COLLATERAL_FACTOR_NO_EXISTS,//
        SET_COLLATERAL_FACTOR_VALIDATION,//
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,//
        //代理实现检查
        SET_IMPLEMENTATION_OWNER_CHECK,//
        //清算激励检查
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,//
        SET_LIQUIDATION_INCENTIVE_VALIDATION,//
        SET_MAX_ASSETS_OWNER_CHECK,//
        SET_PENDING_ADMIN_OWNER_CHECK,//
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,//
        //oracle 价格检查
        SET_PRICE_ORACLE_OWNER_CHECK,//
        //市场资产支持检查
        SUPPORT_MARKET_EXISTS,//
        SUPPORT_MARKET_OWNER_CHECK,//
        SET_PAUSE_GUARDIAN_OWNER_CHECK//
    }

    /**
      * @dev `error` corresponds to enum Error; `info` corresponds to enum FailureInfo, and `detail` is an arbitrary
      * contract-specific code that enables us to report opaque error codes from upgradeable contracts.
      * 失败事件
      **/
    event Failure(uint error, uint info, uint detail);

    /**
      * 带失败原因的错误
      * @dev use this when reporting a known error from the money market or a non-upgradeable collaborator
      */
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }

    /**
      * 其他非透明性的错误
      * @dev use this when reporting an opaque error from an upgradeable collaborator contract
      */
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}
/// token错误报告
contract TokenErrorReporter {
    uint public constant NO_ERROR = 0; // support legacy return codes
    //转账
    error TransferComptrollerRejection(uint256 errorCode);//
    error TransferNotAllowed();//
    error TransferNotEnough();//
    error TransferTooMuch();//
    //提供流动性，存款
    error MintComptrollerRejection(uint256 errorCode);//
    error MintFreshnessCheck();//  
    //赎回
    error RedeemComptrollerRejection(uint256 errorCode);//
    error RedeemFreshnessCheck();//
    error RedeemTransferOutNotPossible();//
    //借款
    error BorrowComptrollerRejection(uint256 errorCode);//
    error BorrowFreshnessCheck();//
    error BorrowCashNotAvailable();//
    //偿还贷款 
    error RepayBorrowComptrollerRejection(uint256 errorCode);//
    error RepayBorrowFreshnessCheck();//
    //清算
    error LiquidateComptrollerRejection(uint256 errorCode);//
    error LiquidateFreshnessCheck();//
    error LiquidateCollateralFreshnessCheck();//
    error LiquidateAccrueBorrowInterestFailed(uint256 errorCode);//
    error LiquidateAccrueCollateralInterestFailed(uint256 errorCode);//
    error LiquidateLiquidatorIsBorrower();//
    error LiquidateCloseAmountIsZero();//
    error LiquidateCloseAmountIsUintMax();//
    error LiquidateRepayBorrowFreshFailed(uint256 errorCode);//
    //清算， 扣押
    error LiquidateSeizeComptrollerRejection(uint256 errorCode);//
    error LiquidateSeizeLiquidatorIsBorrower();//
    //控制器、管理员检查
    error AcceptAdminPendingAdminCheck();//

    error SetComptrollerOwnerCheck();//
    error SetPendingAdminOwnerCheck();//
    //储备金，基准利率检查
    error SetReserveFactorAdminCheck();//
    error SetReserveFactorFreshCheck();//
    error SetReserveFactorBoundsCheck();//

    error AddReservesFactorFreshCheck(uint256 actualAddAmount);//
    //减少储备金检查
    error ReduceReservesAdminCheck();//
    error ReduceReservesFreshCheck();//
    error ReduceReservesCashNotAvailable();//
    error ReduceReservesCashValidation();//
    //利率模型检查
    error SetInterestRateModelOwnerCheck();//
    error SetInterestRateModelFreshCheck();//
}
