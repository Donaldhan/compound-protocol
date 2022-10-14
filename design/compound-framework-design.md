
利用空闲资产，赚钱收益

中心交易所借贷，面临黑客攻击，携款跑路，导致你的账号资金都是虚拟的，无法在链上使用，同时个人进行借贷需要管理各种条款和投机的风险；去中心化的借贷平台Compound
简化了借贷流程，同时避免了用户管理各种条款、投机的风。


1. 不需要填写任何订单及线下操作就可以完成借贷；
2. 用户可以使用他的现有投资组合，借出ETH进行项目的ICO;
3. 交易者，可以借出代币，并在交易所抛售，进而获利（做空）；


# tip
用户可以使用抵押贷出ETH，又可以使用ETH，在Uniswap，swap其他代币，再在Compound上进行抵押，获取ETH，完成加杠杆操作，比较安全，比合约风险要小的多，
并且不会面临爆仓的风险。


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
