# The scenario

**Audience**: Architects, Application and smart contract developers, Business
professionals

**受众**：架构师, 应用和智能合约开发者, 业务专家

In this topic, we're going to describe a business scenario involving six
organizations who use PaperNet, a commercial paper network built on Hyperledger
Fabric, to issue, buy and redeem commercial paper. We're going to use the
scenario to outline requirements for the development of commercial paper
applications and smart contracts used by the participant organizations.

在本主题中，我们将会描述一个涉及六个组织的业务场景，这些组织使用基于 Hyperledger Fabric 
构建的商业票据网络 PaperNet 来发行，购买和兑换商业票据。我们将使用该场景概述参与组织使用
的商业票据应用程序和智能合约的开发要求。

## PaperNet network

PaperNet is a commercial paper network that allows suitably authorized
participants to issue, trade, redeem and rate commercial paper.

PaperNet 是一个商业票据网络，允许适当授权的参与者发行，交易，兑换和估价商业票据。

![develop.systemscontext](./develop.diagram.1.png)

*The PaperNet commercial paper network. Six organizations currently use PaperNet
network to issue, buy, sell, redeem and rate commercial paper. MagentoCorp
issues and redeems commercial paper.  DigiBank, BigFund, BrokerHouse and
HedgeMatic all trade commercial paper with each other. RateM provides various
measures of risk for commercial paper.*

*PaperNet 商业票据网络。六个组织目前使用 PaperNet 网络发行，购买，出售，兑换和估价商业票据。
MagentoCorp 发行和兑换商业票据。 DigiBank, BigFund，BrokerHouse 和 HedgeMatic 互相交易商业
票据。RateM 为商业票据提供各种风险衡量标准。*

Let's see how MagnetoCorp uses PaperNet and commercial paper to help its
business.

让我们来看一下 MagnetoCorp 如何使用 PaperNet 和商业票据来帮助其业务。

## Introducing the actors

MagnetoCorp is a well-respected company that makes self-driving electric
vehicles. In early April 2020, MagnetoCorp won a large order to manufacture
10,000 Model D cars for Daintree, a new entrant in the personal transport
market. Although the order represents a significant win for MagnetoCorp,
Daintree will not have to pay for the vehicles until they start to be delivered
on November 1, six months after the deal was formally agreed between MagnetoCorp
and Daintree.

MagnetoCorp 是一家备受推崇的公司，生产自动驾驶电动车。在 2020 年 4 月初，MagnetoCorp 公司
赢得了大量订单，为 Daintree 公司制造 10,000 辆 D 型车，Daintree 是个人运输市场的新进入者。
尽管该订单代表了 MagnetoCorp 公司的重大胜利，但在 MagnetoCorp 和 Daintree 正式达成协议后
六个月，Daintree 将于 11 月 1 日开始交付之前不需要支付车辆费用。

To manufacture the vehicles, MagnetoCorp will need to hire 1000 workers for at
least 6 months. This puts a short term strain on its finances -- it will require
an extra 5M USD each month to pay these new employees. **Commercial paper** is
designed to help MagnetoCorp overcome its short term financing needs -- to meet
payroll every month based on the expectation that it will be cash rich when
Daintree starts to pay for its new Model D cars.

为了制造这些车辆，MagnetoCorp 公司将需要雇佣 1000 名工人至少 6 个月。这对它的财务状况造成了
短期压力，-- 每月需要额外 500 万美元来支付这些新员工。**商业票据**是为帮助 MagnetoCorp 公司克服
短期融资需求而设计的，-- 每月基于 Daintree 公司开始支付 D 型车辆费用时就会有充足现金的预期来满足
工资单。

At the end of May, MagnetoCorp needs 5M USD to meet payroll for the extra
workers it hired on May 1. To do this, it issues a commercial paper with a face
value of 5M USD with a maturity date 6 months in the future -- when it expects
to see cash flow from Daintree. DigiBank thinks that MagnetoCorp is
creditworthy, and therefore doesn't require much of a premium above the central
bank base rate of 2%, which would value 4.95M USD today at 5M USD in 6 months
time. It therefore purchases the MagnetoCorp 6 month commercial paper for 4.94M
USD -- a slight discount compared to the 4.95M USD it is worth. DigiBank fully
expects that it will be able to redeem 5M USD from MagnetoCorp in 6 months time,
making it a profit of 10K USD for bearing the increased risk associated with
this commercial paper. This extra 10K means it receives a 2.4% return on
investment -- significantly better than the risk free return of 2%.

在五月底，MagnetoCorp 公司需要 500 万美元才能满足 5 月 1 日雇佣的额外工人。要做到这个，
它会发行一张面值 500 万美元的商业票据，未来6个月到期 -- 当预计看到 Daintree 现金流时。
DigiBank 认为 MagnetoCorp 公司是值得信赖的，因此，不需要高于中央银行 2% 基准利率的溢价，
这将会使得今天价值 495 万美元，在6个月时间后价值 500 万美元。所以它以 494 万美元的价格购买了
MagnetoCorp 公司 6 个月到期的商业票据 -- 与 495 万美元的价值相比略有折扣。DigiBank 完全
预计它将能够在 6 个月内从 MagnetoCorp 赎回 500 万美元，因此承担与此商业票据相关的风险增加，
使其获利 10K 美元。

At the end of June, when MagnetoCorp issues a new commercial paper for 5M USD to
meet June's payroll, it is purchased by BigFund for 4.94M USD.  That's because
the commercial conditions are roughly the same in June as they are in May,
resulting in BigFund valuing MagnetoCorp commercial paper at the same price that
DigiBank did in May.

在六月底，MagnetoCorp 公司发行一个 500 万美元的商业票据来支付六月份的工资单时，被 BigFund
以 494 万美元购买。这是因为六月的商业条件与五月大致相同，导致 BigFund 以与 DigiBank 五月份
相同的价格对 MagnetoCorp 商业票据进行估值。

Each subsequent month, MagnetoCorp can issue new commercial paper to meet its
payroll obligations, and these may be purchased by DigiBank, or any other
participant in the PaperNet commercial paper network -- BigFund, HedgeMatic or
BrokerHouse. These organizations may pay more or less for the commercial paper
depending on two factors -- the central bank base rate, and the risk associated
with MagnetoCorp. This latter figure depends on a variety of factors such as the
production of Model D cars, and the creditworthiness of MagnetoCorp as assessed
by RateM, a ratings agency.

接下来的每个月，MagnetoCorp 公司可以发行新的商业票据来满足它的工资义务，这些票据可以被 DigiBank
或其他任何在 PaperNet 商业票据网络的参与者购买 -- BigFund, HedgeMatic 或 BrokerHouse。这些组织
可能会根据两个因素为商业票据支付更多或更少的费用 -- 央行基准利率和与 MagnetoCorp 相关的风险。
后者取决于各种因素，如 D 型车的生产，以及评级机构 RateM 评估的 MagnetoCorp 公司的信誉度。

The organizations in PaperNet have different roles, MagnetoCorp issues paper,
DigiBank, BigFund, HedgeMatic and BrokerHouse trade paper and RateM rates paper.
Organizations of the same role, such as DigiBank, Bigfund, HedgeMatic and
BrokerHouse are competitors. Organizations of different roles are not
necessarily competitors, yet might still have opposing business interest, for
example MagentoCorp will desire a high rating for its papers to sell them at
a high price, while DigiBank would benefit from a low rating, such that it can
buy them at a low price. As can be seen, even a seemingly simple network such
as PaperNet can have complex trust relationships. A blockchain can help
establish trust among organizations that are competitors or have opposing
business interests that might lead to disputes. Fabric in particular has the
means to capture even fine-grained trust relationships.

Let's pause the MagnetoCorp story for a moment, and develop the client
applications and smart contracts that PaperNet uses to issue, buy, sell and
redeem commercial paper as well as capture the trust relationships between
the organizations.  We'll come back to the role of the rating agency,
RateM, a little later.

让我们暂停 MagnetoCorp 的故事，开发 PaperNet 用于发行，购买，出售和兑换商业票据的客户
应用程序和智能合约以获取组织之间的信任关系。稍后我们将回到评级机构 RateM 的角色。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
