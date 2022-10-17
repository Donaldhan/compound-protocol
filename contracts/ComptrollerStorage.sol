// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CToken.sol";
import "./PriceOracle.sol";

contract UnitrollerAdminStorage {
    /**
    * @notice Administrator for this contract 管理员
    */
    address public admin;

    /**
    * @notice Pending administrator for this contract 变更中的管理员
    */
    address public pendingAdmin;

    /**
    * @notice Active brains of Unitroller 控制器实现
    */
    address public comptrollerImplementation;

    /**
    * @notice Pending brains of Unitroller 变更中的控制器实现
    */
    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {

    /**
     * @notice Oracle which gives the price of any given asset 价格预言机
     */
    PriceOracle public oracle;

    /**
     * @notice Multiplier used to calculate the maximum repayAmount when liquidating a borrow 
     * 清算时，清算借贷资产因子
     */
    uint public closeFactorMantissa;

    /**
     * @notice Multiplier representing the discount on collateral that a liquidator receives
     * 清算者抵押折扣奖励因子
     */
    uint public liquidationIncentiveMantissa;

    /**
     * @notice Max number of assets a single account can participate in (borrow or use as collateral)
     * 单账户可以抵押或借贷的最大资产数量
     */
    uint public maxAssets;

    /**
     * @notice Per-account mapping of "assets you are in", capped by maxAssets CToken资产
     */
    mapping(address => CToken[]) public accountAssets;

}

contract ComptrollerV2Storage is ComptrollerV1Storage {
    struct Market {
        // Whether or not this market is listed 市场是否Listed
        bool isListed;

        //  Multiplier representing the most one can borrow against their collateral in this market. 抵押因子
        //  For instance, 0.9 to allow borrowing 90% of collateral value.
        //  Must be between 0 and 1, and stored as a mantissa.
        uint collateralFactorMantissa;

        // Per-market mapping of "accounts in this asset" 资产账户地址
        mapping(address => bool) accountMembership;

        // Whether or not this market receives COMP 市场是否接受COMP
        bool isComped;
    }

    /**
     * @notice Official mapping of cTokens -> Market metadata cToken市场信息
     * @dev Used e.g. to determine if a market is supported
     */
    mapping(address => Market) public markets;


    /**
     * @notice The Pause Guardian can pause certain actions as a safety mechanism.
     * 暂停安全机制
     *  Actions which allow users to remove their own assets cannot be paused.
     * 此操作，允许用户使用未暂停的资产
     *  Liquidation / seizing / transfer can only be paused globally, not by market.
     */
    address public pauseGuardian;
    bool public _mintGuardianPaused; //mint操作暂停
    bool public _borrowGuardianPaused; //借贷暂停标志
    bool public transferGuardianPaused;//转移暂停标志
    bool public seizeGuardianPaused;//扣押暂停标志
    mapping(address => bool) public mintGuardianPaused; //CToken， 挖矿暂停标志
    mapping(address => bool) public borrowGuardianPaused; //CToken，借贷暂停标志
}

contract ComptrollerV3Storage is ComptrollerV2Storage {
    /// 
    struct CompMarketState {
        // The market's last updated compBorrowIndex or compSupplyIndex
        //Comp 市场索引
        uint224 index;

        // The block number the index was last updated at 索引对应的区块
        uint32 block;
    }

    /// @notice A list of all markets 所有资本市场
    CToken[] public allMarkets;

    /// @notice The rate at which the flywheel distributes COMP, per block
    /// Comp的飞轮分布率
    uint public compRate;

    /// @notice The portion of compRate that each market currently receives 每个市场的compRate
    mapping(address => uint) public compSpeeds;

    /// @notice The COMP market supply state for each market 每个市场的COMP供应状态
    mapping(address => CompMarketState) public compSupplyState;

    /// @notice The COMP market borrow state for each market 每个市场的COMP借贷状态
    mapping(address => CompMarketState) public compBorrowState;

    /// @notice The COMP borrow index for each market for each supplier as of the last time they accrued COMP 每个市场的COMP每个供应对应的借贷索引
    mapping(address => mapping(address => uint)) public compSupplierIndex;

    /// @notice The COMP borrow index for each market for each borrower as of the last time they accrued COMP  每个市场的COMP每个借贷对应的借贷索引
    mapping(address => mapping(address => uint)) public compBorrowerIndex;

    /// @notice The COMP accrued but not yet transferred to each user 还没有转用户的COMP累计数量
    mapping(address => uint) public compAccrued;
}

contract ComptrollerV4Storage is ComptrollerV3Storage {
    // @notice The borrowCapGuardian can set borrowCaps to any number for any market. Lowering the borrow cap could disable borrowing on the given market.
    /// 借贷的上限合约地址，低借贷量可以关闭市场借贷
    address public borrowCapGuardian;

    // @notice Borrow caps enforced by borrowAllowed for each cToken address. Defaults to zero which corresponds to unlimited borrowing.
    /// 每个市场允许借贷的上限
    mapping(address => uint) public borrowCaps;
}

contract ComptrollerV5Storage is ComptrollerV4Storage {
    /// @notice The portion of COMP that each contributor receives per block 每个区块贡献者获取的COMP数量
    mapping(address => uint) public compContributorSpeeds;

    /// @notice Last block at which a contributor's COMP rewards have been allocated 上个区块，贡献值获取的COMP数量
    mapping(address => uint) public lastContributorBlock;
}

contract ComptrollerV6Storage is ComptrollerV5Storage {
    /// @notice The rate at which comp is distributed to the corresponding borrow market (per block)
    /// 借贷市场借贷关联的comp rate
    mapping(address => uint) public compBorrowSpeeds;

    /// @notice The rate at which comp is distributed to the corresponding supply market (per block)
    // 供应市场借贷关联的comp rate
    mapping(address => uint) public compSupplySpeeds;
}

contract ComptrollerV7Storage is ComptrollerV6Storage {
    /// @notice Flag indicating whether the function to fix COMP accruals has been executed (RE: proposal 62 bug)
    /// fix COMP 功能是否执行
    bool public proposal65FixExecuted;

    /// @notice Accounting storage mapping account addresses to how much COMP they owe the protocol.
    /// 每个用户获取的Comp
    mapping(address => uint) public compReceivable;
}
