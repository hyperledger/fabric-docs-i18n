# 场景

**受众**：架构师, 应用和智能合约开发者, 业务专家

在本主题中，我们将会描述一个涉及六个组织的业务场景，这些组织使用基于 Hyperledger Fabric 构建的商业票据网络 PaperNet 来发行，购买和兑换商业票据。我们将使用该场景概述参与组织使用的商业票据应用程序和智能合约的开发要求。

## PaperNet 网络

PaperNet 是一个商业票据网络，允许适当授权的参与者发行，交易，兑换和估价商业票据。

![develop.systemscontext](./develop.diagram.1.png)

*PaperNet 商业票据网络。六个组织目前使用 PaperNet 网络发行，购买，出售，兑换和估价商业票据。MagentoCorp 发行和兑换商业票据。 DigiBank, BigFund，BrokerHouse 和 HedgeMatic 互相交易商业票据。RateM 为商业票据提供各种风险衡量标准。*

让我们来看一下 MagnetoCorp 如何使用 PaperNet 和商业票据来帮助其业务。

## 演员介绍

MagnetoCorp 是一家备受推崇的公司，生产自动驾驶电动车。在2020年4月初，MagnetoCorp 公司赢得了大量订单，为 Daintree 公司制造10,000辆 D 型车，Daintree 是个人运输市场的新进入者。尽管该订单代表了 MagnetoCorp 公司的重大胜利，但在 MagnetoCorp 和 Daintree 正式达成协议后六个月，Daintree 在11月1日开始交付之前不需要支付车辆费用。

为了制造这些车辆，MagnetoCorp 公司将需要雇佣1000名工人至少6个月。这对它的财务状况造成了短期压力，每月需要额外支付500万美元给这些新员工。**商业票据**是为帮助 MagnetoCorp 公司克服短期融资需求而设计的，该票据是基于 Daintree 公司开始支付 D 型车辆费用时就会有充足现金的预期，来支付 MagnetoCorp 每月的工资单。

在五月底，MagnetoCorp 公司需要500万美元才能满足5月1日雇佣的额外工人。要做到这个，它会发行一张面值500万美元的商业票据，未来六个月到期，也就是预计看到 Daintree 现金流时。DigiBank 认为 MagnetoCorp 公司是值得信赖的，因此，不需要高于中央银行2%基准利率的溢价，这将会使得当前票据价值495万美元，在六个月时间后价值500万美元。所以它以494万美元的价格购买了 MagnetoCorp 公司六个月到期的商业票据，这与495万美元的价值相比略有折扣。DigiBank 预计它将能够在六个月内从 MagnetoCorp 赎回500万美元，因此承担与此商业票据相关的风险增加，使其获利1万美元。

在六月底，MagnetoCorp 公司发行一个500万美元的商业票据来支付六月份的工资单时，被 BigFund 以494万美元购买。这是因为六月的商业条件与五月大致相同，导致 BigFund 以与 DigiBank 五月份相同的价格对 MagnetoCorp 商业票据进行估值。

接下来的每个月，MagnetoCorp 公司可以发行新的商业票据来满足它的工资义务，这些票据可以被 DigiBank 或其他任何在 PaperNet 商业票据网络的参与者购买—— BigFund, HedgeMatic 或 BrokerHouse。这些组织可能会根据两个因素为商业票据支付更多或更少的费用——央行基准利率和与 MagnetoCorp 相关的风险。后者取决于各种因素，如 D 型车的生产，以及评级机构 RateM 评估的 MagnetoCorp 公司的信誉度。

PaperNet 中的组织有不同的角色，MagnetoCorp 发行票据，DigiBank、 BigFund、 HedgeMatic 和 BrokerHouse 交易票据，RateM 评估票据。相同角色的组织比如 DigiBank、 BigFund、 HedgeMatic 和 BrokerHouse 是竞争者。不同角色的组织没有竞争，但是仍有对立的商业利益，比如 MagentoCorp 希望更高的评级以便于提高票据价格，DigiBank 会从低评级中受益，因为它可以以较低的价格购买。像 PaperNet，看似简单的网络也有复杂的信任关系。区块链可以帮助建立组织之间的信任关系，即使这些组织是竞争关系或者有利益冲突而可能产生纠纷。Fabric 甚至有方法捕获细粒度的信任关系。

让我们暂停 MagnetoCorp 的故事，开发 PaperNet 用于发行，购买，出售和兑换商业票据的客户应用程序和智能合约。稍后我们将回到评级机构 RateM 的角色。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
