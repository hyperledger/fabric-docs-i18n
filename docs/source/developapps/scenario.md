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

*PaperNet 商业票据网络。六个组织目前使用 PaperNet 网络发行，购买，出售，兑换和估价商业票据。MagentoCorp 发行和兑换商业票据。 DigiBank, BigFund，BrokerHouse 和 HedgeMatic 互相交易商业票据。RateM 为商业票据提供各种风险衡量标准。*

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

To manufacture the vehicles, MagnetoCorp will need to hire 1000 workers for at
least 6 months. This puts a short term strain on its finances -- it will require
an extra 5M USD each month to pay these new employees. **Commercial paper** is
designed to help MagnetoCorp overcome its short term financing needs -- to meet
payroll every month based on the expectation that it will be cash rich when
Daintree starts to pay for its new Model D cars.

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

At the end of June, when MagnetoCorp issues a new commercial paper for 5M USD to
meet June's payroll, it is purchased by BigFund for 4.94M USD.  That's because
the commercial conditions are roughly the same in June as they are in May,
resulting in BigFund valuing MagnetoCorp commercial paper at the same price that
DigiBank did in May.

Each subsequent month, MagnetoCorp can issue new commercial paper to meet its
payroll obligations, and these may be purchased by DigiBank, or any other
participant in the PaperNet commercial paper network -- BigFund, HedgeMatic or
BrokerHouse. These organizations may pay more or less for the commercial paper
depending on two factors -- the central bank base rate, and the risk associated
with MagnetoCorp. This latter figure depends on a variety of factors such as the
production of Model D cars, and the creditworthiness of MagnetoCorp as assessed
by RateM, a ratings agency.

Let's pause the MagnetoCorp story for a moment, and develop the client
applications and smart contracts that PaperNet uses to issue, buy, sell and
redeem commercial paper.  We'll come back to the role of the rating agency,
RateM, a little later.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
