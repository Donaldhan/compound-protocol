// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

/**
  * @title Compound's InterestRateModel Interface 利率模型接口
  * @author Compound
  */
abstract contract InterestRateModel {
    /// @notice Indicator that this is an InterestRateModel contract (for inspection) 是否为利率模型合约
    bool public constant isInterestRateModel = true;

    /**
      * @notice Calculates the current borrow interest rate per block 计算当前区块的借贷利率
      * @param cash The total amount of cash the market has 市场总现金
      * @param borrows The total amount of borrows the market has outstanding 市场总借贷
      * @param reserves The total amount of reserves the market has 市场的储备金
      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
      */
    function getBorrowRate(uint cash, uint borrows, uint reserves) virtual external view returns (uint);

    /**
      * @notice Calculates the current supply interest rate per block 计算当前的供应率
      * @param cash The total amount of cash the market has 市场总现金
      * @param borrows The total amount of borrows the market has outstanding 市场总借贷
      * @param reserves The total amount of reserves the market has 市场的储备金
      * @param reserveFactorMantissa The current reserve factor the market has 储备金因子
      * @return The supply rate per block (as a percentage, and scaled by 1e18)
      */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) virtual external view returns (uint);
}
