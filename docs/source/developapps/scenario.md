# 场景

**受众**：架构师, 应用和智能合约开发者, 业务专家

在本主题中，我们将会描述一个涉及六个组织的业务场景，这些组织使用基于 Hyperledger Fabric 构建的商业票据网络 PaperNet 来进行商业票据的发行，购买和兑换操作。我们将围绕该场景来概述参与组织使用的商业票据应用程序和智能合约的开发要求。

## PaperNet 网络

PaperNet 是一个商业票据网络，它允许网络中的组织在获得适当授权的前提下执行商业票据的发行、交易、兑换和评估操作。

![develop.systemscontext](./develop.diagram.1.png)

*上图展示的是 PaperNet 商业票据网络。其中的六个组织目前使用  PaperNet 网络发行，购买，出售，兑换和评估商业票据。其中 MagentoCorp 负责发行和兑换商业票据。 DigiBank, BigFund，BrokerHouse 和 HedgeMatic 互相交易商业票据。而 RateM 则对商业票据进行各种风险评估。*

让我们来看一下 MagnetoCorp 如何使用 PaperNet 和商业票据来辅助开展自身业务的。

## 网络成员介绍

MagnetoCorp 是一家广受尊重的自动驾驶电动汽车制造商。在2020年4月初，MagnetoCorp 公司赢得了一份为 Daintree 公司制造10,000辆 Model D 汽车的大订单，后者是私家车市场的新成员。虽然这份订单意味着MagnetoCorp 公司获得重大胜利，但是在11月1日车辆交付——即双方正式确定交易后六个月——之前它还无法收到货款。

为完成生产任务，MagnetoCorp 公司需雇佣1000名员工进行至少6个月的工作。这样一来，MagnetoCorp 每月需额外支出500万美元以支付新员工的工资，给公司带来了短期的财务压力。**商业票据**旨在帮助 MagnetoCorp 公司解决短期融资难题，其原理在于：MagnetoCorp 公司出售商业票据获得现款以供新员工工资开支，根据预期，它将在 Daintree 公司开始支付货款时获得大量资金。

在五月底，MagnetoCorp 公司需要为月初入职的新员工支付总计500万美元的工资。为此，MagnetoCorp 发行一张面值为500万美元、期限为6个月——预计MagnetoCorp 将在6个月内收到货款——的商业票据。DigiBank 认为 MagnetoCorp 公司信誉良好，因此只需收取略高于央行2%基础利率的溢价。根据基础利率，这张到期后价值500万美元的票据目前估价495万美元。基于以上判断，DigiBank 决定以494万美元的价格从MagnetoCorp 公司购得这张期限为6个月的商业票据，与基础利率计算的495万美元估价相比略有折扣。DigiBank 非常希望在未来6个月内可以向MagnetoCorp 公司兑现500万美元，从而获利 1万美元，以作为自己承担与该票据相关的风险的报酬。这1万美元的获利意味着 DigiBank 公司此次投资收到2.4%的报酬，远高于2%的无风险报酬。

六月底时，MagnetoCorp 公司为支付新员工六月份的工资发行了另一张面值同为500万美元的商业票据， BigFund 公司以494万美元的价格购得该票据，与五月份的购价相同，这是因为六月份的相关商业情况基本未发生改变。

接下来每个月，MagnetoCorp 公司都可以通过发行商业票据来支付新员工的工资，票据购买方可能是 DigiBank 或其他任何 PaperNet 商业票据网络的参与者，即BigFund, HedgeMatic 或 BrokerHouse。票据的最终购价取决于央行基础利率和 MagnetoCorp 公司相关风险，后者受多种因素的影响，例如  Model D 汽车的生产情况，信用评级机构 RateM 给 MagnetoCorp 公司做出的信用评估等。

PaperNet 网络中各成员分别扮演不同的角色，其中 MagnetoCorp 负责发行票据，DigiBank、 BigFund、 HedgeMatic 和 BrokerHouse 负责交易票据，而 RateM 负责评估票据。角色相同的组织互为竞争关系，如 DigiBank、 BigFund、 HedgeMatic 和 BrokerHouse。角色不同的组织不一定互为竞争关系，但是可能也存在对立的商业利益，比如 MagnetoCorp 和 DigiBank，前者希望自己发行的商业票据能获得高评级，从而卖出高价，而后者却希望前者的票据获得低评级，从而可以低价买入该票据。从上文中我们可以看到，即使是 PaperNet 这种看似很简单的网络可能也存在复杂的信任关系。对此，区块链技术可以在互为竞争关系或彼此间存在可导致争端的对立商业利益的组织之间建立起信任。其中 Fabric 尤为如此，它能够抓住极其细微的信任关系。

关于  MagnetoCorp 的讨论就到此为止，现在让我们来开发客户端应用程序和智能合约（ PaperNet 用来发行、购买、销售和兑换商业票据以及抓住信任关系）。稍后我们将接着讨论评级机构 RateM 所扮演的角色。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
