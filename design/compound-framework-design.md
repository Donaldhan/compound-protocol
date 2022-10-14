
# 引言

当前中心交易所借贷，面临黑客攻击，携款跑路，导致你的账号资金都是虚拟的，无法在链上使用，同时个人进行借贷需要管理各种条款和投机的风险；去中心化的借贷平台Compound
简化了借贷流程，同时避免了用户管理各种条款、投机的风险，主要有一个优势：

1. 不需要填写任何订单及线下操作就可以完成借贷；
2. 用户可以使用他的现有投资组合，借出ETH进行项目的ICO;
3. 交易者，可以借出代币，并在交易所抛售，进而获利（做空）；

在Compound上，用户利用空闲资产，赚钱收益，同时为借贷需求方，提供支持。



# 借贷协议

提供者提供资金，将会放入资产总池，同时会获得相应的ERC20 cToken；cToken可以作为收益的分配和提供者的体现依据；

借贷者抵押需要的资产进行借贷；高流动性，高价值的借贷抵押利率高，反之，贷抵押利率；

借贷方，可以借出不超过其资产的贷款，此举为了降低协议面临的风险；

borrowing capacity（借贷容量）：

collateral factors:（抵押因子）
liquidation discount：（清算折扣）

当前用户借出了超其资产的贷款时，将会面临系统清算，以市场的liquidation discount（清算折扣）和用户的cToken进行清算，超额的借贷；降低用户和协议的风险；
任何EOA账户都可以发起清算；

close factor：超额借贷时，需要偿还的贷款因子；

## Interest Rate Model

借贷需求越高，则利率越高，否则越低；

使用率：
U·a = Borrow·sa / (Cash·a + Borrow·sa)


Borrow·sa：借出的贷款
Cash·a：流动池中的现金

借贷率
Borrowing Interest Rate·a = 2.5% + U·a * 20%

协议不通过流动性保证，只通过借贷利率来保证，在极端情况下，高额的借贷利率将会激励提供现金供应，同时抑制借贷需求；


## 协议实现
所有借贷的实现都是基于ERC20的cToken合约

### cToken Contracts
用户提供的任何资产价格将会转换为基于ERC20的cToken；用户可以使用mint(uint
amountUnderlying) ，通过现金资产到市场获取cToken，使用 cToken的redeem(uint amount)赎回操作，获取自己的现金资产；


汇率exchangeRate:

exchangeRate = （underlyingBalance +totalBorrowBalance·a − reserves·a）/cTokenSupply·a
随着市场借款金额的增加totalBorrowBalance·a， 汇率将会在底层资产underlyingBalance和cTokenSupply之间进行增加；


> 合约abi

1. mint(uint256 amountUnderlying) ：转移底层资产到市场，获取相应的cToken；
2. redeem(uint256 amount)/redeemUnderlying(uint256 amountUnderlying):从市场赎回底层资产，并减少用户的cToken数量；
3. borrow(uint amount) :从市场借出抵押物允许的底层资产，并更新账户借贷余额；
4. repayBorrow(uint amount)/repayBorrowBehalf(address account, uint amount):还贷底层资产到时长，减少账户的借款金额；
5. liquidate(address borrower, address collateralAsset, uint closeAmount)：清算底层资产到市场，，减少账户的借款金额，转移借贷者相应的cToken到清算发起者；



### Interest Rate Mechanics 
利率随着借贷需求的变化而变化，
Interest Rate Index将会管理基于时间历史的利率，每次计算利率，将会影响资产的供应，借贷，偿还，赎回和清算；

每次交易发生， Interest Rate Index将会更新Compound的每个间隔索引的利率；


区块利率：
Index.a,n = Index.a,(n−1) *(1 + r *t)

市场借贷总额：

totalBorrowBalance.a,n = totalBorrowBalance.a,(n−1) *(1 + r *t)

借贷产生的利息reserves.a 将会作为储备金使用，具体计算如下：

reserves.a = reserves.a,(n−1)+ totalBorrowBalance.a,(n−1) *(r * t * reserveFactor)

reserveFactor:储备系数


### Borrower Dynamics
随着利率的变化，用户的可借贷金额随之变化，同时以tuple <uint256 balance, uint256 interestIndex> 进行维护；


### Borrowing
用户借贷将会检查用户的抵押物是否充足，另外放贷后，将会触发市场利率的更新；同时用户可以在任何适合偿还贷款；


### Liquidation
当抵押品市场价值降低，或者用户的借贷超额，将会触发清算，清算者将会获取清算借贷额度相应的cToken；


### Price Feeds
Compound协议将会代理委员会使用Price Oracle维护每个资产的汇率

### Comptroller
Compound协议针对特定的资产默认不支持，只有白名单中的才支持， 用户可以使用管理功能supportMarket(address market,address interest rate model)，添加
资产到市场，为了能够借出资产，资产必须从Price Oracle可以拉出对应有效价格；同时为了能够抵押，必须有一个有效的价格和抵押因子；

每个方法将会通过策略层Comptroller校验，Comptroller在用户的每个动作之前，将会校验抵押品和流动性
## 3.7 Governance
Compound将会先使用集中化的管理，控制利率的模型等，在将来将会交给社区和权益股东；管理员可以拥有一下权利：
1. list新的cToken市场；
2. 更新每个市场的利率模型；
3. 更新Oracle地址；
4. 从储备的cToken体现；
5. 任命新的admin，比如社区控制的DAO；

## Summary

* Compound提供了ETH资产的市场化流动；
* 每个市场的利率有供需关系决定，借出资产，利率上升，赎回资产，利率上升，激励额外的流动性；
* 用户可以在依赖于中心化组织的情况，从市场上获取收益；
* 用户可以使用从Compound中借出来的资产进行使用，售卖或者再借贷。




# 总结
Compound基于ERC20的cToken为用户提供的去中心化的借贷及存款，主要包括提供资产，借贷，偿还，赎回，清算关键操作。

提供者提供资金，将会放入资产总池，同时会获得相应的ERC20 cToken；cToken可以作为收益的分配和提供者的体现依据；

用户借贷将会检查用户的抵押物是否充足，另外放贷后，将会触发市场利率的更新；同时用户可以在任何适合偿还贷款；

随着利率的变化，用户的可借贷金额随之变化，同时以tuple <uint256 balance, uint256 interestIndex> 进行维护；

当抵押品市场价值降低，或者用户的借贷超额，将会触发清算，清算者将会以市场的liquidation discount（清算折扣）进行清算，获取清算借贷额度相应的cToken；
以降低用户和协议的风险，任何EOA账户都可以发起清算；


Compound协议针对特定的资产默认不支持，只有白名单中的才支持， 用户可以使用管理功能supportMarket(address market,address interest rate model)，添加
资产到市场，为了能够借出资产，资产必须从Price Oracle可以拉出对应有效价格；同时为了能够抵押，必须有一个有效的价格和抵押因子；

Compound的作用及关键特性、机制：

* Compound提供了ETH资产的市场化流动；
* 每个市场的利率有供需关系决定，借出资产，利率上升，赎回资产，利率上升，激励额外的流动性；
* 用户可以在依赖于中心化组织的情况，从市场上获取收益；
* 用户可以使用从Compound中借出来的资产进行使用，售卖或者再借贷。





# 附
[compound](https://compound.finance/) 
[compound-protocol](https://github.com/compound-finance/compound-protocol) 
[Compound Whitepaper](https://compound.finance/documents/Compound.Whitepaper.pdf)   
[CompoundProtocol](https://github.com/compound-finance/compound-protocol/blob/master/docs/CompoundProtocol.pdf)      
[DeFi 中的借贷及 Aave、Compound 的比较](https://www.tuoluo.cn/article/detail-10035172.html)   
[DeFi借贷平台两大龙头项目Compound和AAVE全面解析](https://www.panewslab.com/zh/articledetails/1606214769415477.html)  
[【DeFi技术解析】去中心化算法银行Compound技术解析之概述篇](https://zhuanlan.zhihu.com/p/114319666)   
[【DeFi技术解析】去中心化算法银行Compound技术解析之利率模型篇](https://zhuanlan.zhihu.com/p/126503548)   
[【DeFi 的世界】Compound 完全解析-利率模型篇](https://medium.com/steaker-com/defi-%E7%9A%84%E4%B8%96%E7%95%8C-compound-%E5%AE%8C%E5%85%A8%E8%A7%A3%E6%9E%90-%E5%88%A9%E7%8E%87%E6%A8%A1%E5%9E%8B%E7%AF%87-95e9b303c284)        
[详解 Compound 运作原理](https://learnblockchain.cn/article/1015)       
[什么是DeFi 中的Compound Finance？](https://academy.binance.com/zt/articles/what-is-compound-finance-in-defi)    
[Compound应用架构](https://learnblockchain.cn/article/4158)  
[剖析DeFi借贷产品之Compound：概述篇](https://mp.weixin.qq.com/s/6W81W9mz5hYCoTvJ9S5-9Q)          
[剖析DeFi借贷产品之Compound：合约篇](https://juejin.cn/post/6974005248947929124)     
[剖析DeFi借贷产品之Compound：Subgraph篇](https://learnblockchain.cn/article/2632)  
[剖析DeFi借贷产品之Compound：清算篇](https://mirror.xyz/0x546086AfA3D285aCD2c84783c2dCf8F2C23b6433/qdqHZGPih7gXdderdPtZaqloeedTVpgCUdpgUGMGGTk)      
[剖析DeFi借贷产品之Compound：延伸篇](https://mirror.xyz/0x546086AfA3D285aCD2c84783c2dCf8F2C23b6433/yYi562kzBNUSgcuZKbN0M_hGXtNpb_Su0X6kDuAC8kY)     
