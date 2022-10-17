// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./InterestRateModel.sol";

/**
  * @title Compound's JumpRateModel Contract
  * @author Compound
  */
contract JumpRateModel is InterestRateModel {
    //新利率参数
    event NewInterestParams(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

    uint256 private constant BASE = 1e18; //基础精度

    /**
     * @notice The approximate number of blocks per year that is assumed by the interest rate model 每年的区块数量
     */
    uint public constant blocksPerYear = 2102400;

    /**
     * @notice The multiplier of utilization rate that gives the slope of the interest rate 
     * 在给定利率范围内的使用率multiplier
     */
    uint public multiplierPerBlock;

    /**
     * @notice The base interest rate which is the y-intercept when utilization rate is 0
     * 基础利率
     */
    uint public baseRatePerBlock;

    /**
     * @notice The multiplierPerBlock after hitting a specified utilization point
     * 在命中一个给定 utilization后，跳跃的步数multiplierPerBlock
     */
    uint public jumpMultiplierPerBlock;

    /**
     * @notice The utilization point at which the jump multiplier is applied
     * multiplierPerBlock使用的使用率Point
     */
    uint public kink;

    /**
     * @notice Construct an interest rate model
     * @param baseRatePerYear The approximate target base APR, as a mantissa (scaled by BASE) 基础利率
     * @param multiplierPerYear The rate of increase in interest rate wrt utilization (scaled by BASE) 在每个范围内增加的利率
     * @param jumpMultiplierPerYear The multiplierPerBlock after hitting a specified utilization point 
     * @param kink_ The utilization point at which the jump multiplier is applied 当前使用量point
     */
    constructor(uint baseRatePerYear, uint multiplierPerYear, uint jumpMultiplierPerYear, uint kink_) public {
        baseRatePerBlock = baseRatePerYear / blocksPerYear;
        multiplierPerBlock = multiplierPerYear / blocksPerYear;
        jumpMultiplierPerBlock = jumpMultiplierPerYear / blocksPerYear;
        kink = kink_;

        emit NewInterestParams(baseRatePerBlock, multiplierPerBlock, jumpMultiplierPerBlock, kink);
    }

    /**
     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows - reserves)` 计算使用率
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market (currently unused)
     * @return The utilization rate as a mantissa between [0, BASE]
     */
    function utilizationRate(uint cash, uint borrows, uint reserves) public pure returns (uint) {
        // Utilization rate is 0 when there are no borrows
        if (borrows == 0) {
            return 0;
        }

        return borrows * BASE / (cash + borrows - reserves);
    }

    /**
     * @notice Calculates the current borrow rate per block, with the error code expected by the market 计算当前借贷利率
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @return The borrow rate percentage per block as a mantissa (scaled by BASE)
     */
    function getBorrowRate(uint cash, uint borrows, uint reserves) override public view returns (uint) {
        //使用率
        uint util = utilizationRate(cash, borrows, reserves);

        if (util <= kink) {//小于当前使用率
            return (util * multiplierPerBlock / BASE) + baseRatePerBlock;
        } else {
            uint normalRate = (kink * multiplierPerBlock / BASE) + baseRatePerBlock;//正常借贷率
            uint excessUtil = util - kink;//超限数
            return (excessUtil * jumpMultiplierPerBlock/ BASE) + normalRate;
        }
    }

    /**
     * @notice Calculates the current supply rate per block 计算当前供应率
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market
     * @param reserveFactorMantissa The current reserve factor for the market
     * @return The supply rate percentage per block as a mantissa (scaled by BASE)
     */
    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) override public view returns (uint) {
        uint oneMinusReserveFactor = BASE - reserveFactorMantissa;//储备因子
        uint borrowRate = getBorrowRate(cash, borrows, reserves);//借贷率
        uint rateToPool = borrowRate * oneMinusReserveFactor / BASE;//流动池借贷率
        return utilizationRate(cash, borrows, reserves) * rateToPool / BASE;
    }
}
