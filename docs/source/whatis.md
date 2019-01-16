# Introduction

In general terms, a blockchain is an immutable transaction ledger, maintained
within a distributed network of _peer nodes_. These nodes each maintain a copy
of the ledger by applying transactions that have been validated by a _consensus
protocol_, grouped into blocks that include a hash that bind each block to the
preceding block.

通常来说，区块链是一个不可变更的交易账本，维护在由 _peer节点_ 组成的分布式网络中。这些节点通过应用交易维护各自的一个账本的拷贝，那些交易已经被 _共识协议_ 校验过并且包含在绑定了前一个区块hash的区块中。

The first and most widely recognized application of blockchain is the
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin) cryptocurrency, though others
have followed in its footsteps. Ethereum, an alternative cryptocurrency, took a
different approach, integrating many of the same characteristics as Bitcoin but
adding _smart contracts_ to create a platform for distributed applications.
Bitcoin and Ethereum fall into a class of blockchain that we would classify as
_public permissionless_ blockchain technology.  Basically, these are public
networks, open to anyone, where participants interact anonymously.

第一个被广为人知的区块链应用是[比特币](https://en.wikipedia.org/wiki/Bitcoin)加密货币，然而其他应用都是基于它的。以太坊是另一类加密货币，它采用了不同方法，整合了许多类似比特币的特征，但是新增了_智能合约_ 为分布式应用平台创建了一个平台。比特币和以太坊属于一类区块链，我们将其归类为 _公共非许可_ 区块链技术。基本上，这些是公共网络，允许任何人在上面参与者匿名互动。

As the popularity of Bitcoin, Ethereum and a few other derivative technologies
grew, interest in applying the underlying technology of the blockchain,
distributed ledger and distributed application platform to more innovative
_enterprise_ use cases also grew. However, many enterprise use cases require
performance characteristics that the permissionless blockchain technologies are
unable (presently) to deliver. In addition, in many use cases, the identity of
the participants is a hard requirement, such as in the case of financial
transactions where Know-Your-Customer (KYC) and Anti-Money Laundering (AML)
regulations must be followed.

随着比特币，以太坊和其他一些衍生技术的普及，更具创新性地将区块链基础技术、分布式账本和分布式应用平台应用于 _企业_ 案例的兴趣也在增长。但是，许多企业案例要求的性能特征，目前非许可区块链技术无法达到。此外，在许多案例中，参与者身份是一个硬性要求，如在金融交易案例中，必须遵循“了解客户”和“反洗钱”的法规。

For enterprise use, we need to consider the following requirements:

- Participants must be identified/identifiable
- Networks need to be _permissioned_
- High transaction throughput performance
- Low latency of transaction confirmation
- Privacy and confidentiality of transactions and data pertaining to business
  transactions

对于企业用途，我们需要考虑以下要求：

- 必须识别/可识别参与者
- 网络需要获得 _许可_
- 高交易吞吐量性能
- 交易确认低延迟  
- 与商业交易有关的交易和数据的隐私和机密性

While many early blockchain platforms are currently being _adapted_ for
enterprise use, Hyperledger Fabric has been _designed_ for enterprise use from
the outset. The following sections describe how Hyperledger Fabric (Fabric)
differentiates itself from other blockchain platforms and describes some of the
motivation for its architectural decisions.

虽然许多早期的区块链平台正在被 _调整_ 为企业使用，Hyperledger Fabric 从一开始就被 _设计_ 于企业用途。以下部分描述了Hyperledger Fabric（Fabric）如何将自己与其他区块链平台区分开来，并描述了其架构决策的一些动机。

## Hyperledger Fabric

Hyperledger Fabric is an open source enterprise-grade permissioned distributed
ledger technology (DLT) platform, designed for use in enterprise contexts,
that delivers some key differentiating capabilities over other popular
distributed ledger or blockchain platforms.

Hyperledger Fabric是一种开源的企业级许可分布式账本技术(DLT)平台,专为在企业环境中使用而设计，与其他流行的分布式账本或区块链平台相比，它有一些关键的差异功能。

One key point of differentiation is that Hyperledger was established under the
Linux Foundation, which itself has a long and very successful history of
nurturing open source projects under **open governance** that grow strong
sustaining communities and thriving ecosystems. Hyperledger is governed by a
diverse technical steering committee, and the Hyperledger Fabric project by a
diverse set of maintainers from multiple organizations. It has a development
community that has grown to over 35 organizations and nearly 200 developers
since its earliest commits.

一个关键差异点是Hyperledger是在Linux基金会下建立的，该基金会本身在**开放式治理**下培育开源项目的历史悠久且非常成功，这些项目可以发展强大的持续社区和蓬勃发展的生态系统。Hyperledger由多元化技术指导委员会管理，Hyperledger Fabric项目由来自多个组织的不同的维护人员管理。自最早提交以来它拥有一个开发社区已经发展到超过35个组织和近200个开发人员。

Fabric has a highly **modular** and **configurable** architecture, enabling
innovation, versatility and optimization for a broad range of industry use cases
including banking, finance, insurance, healthcare, human resources, supply
chain and even digital music delivery.

Fabric具有高度**模块化**和**可配置**的架构，可为各种行业用例提供创新，多功能性和优化，包括银行，金融，保险，医疗保健，人力资源，供应链甚至数字音乐传递。

Fabric is the first distributed ledger platform to support **smart contracts
authored in general-purpose programming languages** such as Java, Go and
Node.js, rather than constrained domain-specific languages (DSL). This means
that most enterprises already have the skill set needed to develop smart
contracts, and no additional training to learn a new language or DSL is needed.

Fabric是第一个支持**用通用编程语言编写智能合约**（如Java，Go和Node.js）的分布式账本平台，而不是受限制的特定领域语言（DSL）。这意味着大多数企业已经拥有开发智能合约所需的技能，并且不需要额外的培训来学习新的语言或特定领域语言。

The Fabric platform is also **permissioned**, meaning that, unlike with a public
permissionless network, the participants are known to each other, rather than
anonymous and therefore fully untrusted. This means that while the participants
may not _fully_ trust one another (they may, for example, be competitors in the
same industry), a network can be operated under a governance model that is built
off of what trust _does_ exist between participants, such as a legal agreement
or framework for handling disputes.

Fabric平台也获得了许可，这意味着，与公共非许可网络不同，参与者彼此了解，而不是匿名那样完全不受信任。这意味着，尽管参与者可能不会 _完全_ 信任彼此（例如，在同行业竞争对手），网络可以在建立在参与者之间 _确实_ 存在的信任之上的治理模式下运行，如处理有争议的法律协议或框架。

One of the most important of the platform's differentiators is its support for
**pluggable consensus protocols** that enable the platform to be more
effectively customized to fit particular use cases and trust models. For
instance, when deployed within a single enterprise, or operated by a trusted
authority, fully byzantine fault tolerant consensus might be considered
unnecessary and an excessive drag on performance and throughput. In situations
such as that, a
[crash fault-tolerant](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT)
consensus protocol might be more than adequate whereas, in a multi-party,
decentralized use case, a more traditional
[byzantine fault tolerant](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)
(BFT) consensus protocol might be required.

该平台最重要的区别之一是它支持**可插拔的共识协议**，使平台能够更有效地进行定制以适应特定的案例和信任模型。例如，当部署在单个企业内或由可信任的权威机构管理时，完全拜占庭容错的共识可能被认为是不必要的，并且过多的降低了性能和吞吐量。在诸如此类的情况下，[崩溃容错](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT)共识协议可能绰绰有余，而在去中心化用例中，可能需要更传统的[拜占庭容错](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)(BFT)共识协议。

Fabric can leverage consensus protocols that **do not require a native
cryptocurrency** to incent costly mining or to fuel smart contract execution.
Avoidance of a cryptocurrency reduces some significant risk/attack vectors,
and absence of cryptographic mining operations means that the platform can be
deployed with roughly the same operational cost as any other distributed system.

Fabric可以利用**不需要本机加密货币**的共识协议来激励昂贵的采矿或推动智能合约执行。避免加密货币会减少一些重要的风险/攻击向量，并且没有加密挖矿操作意味着可以使用与任何其他分布式系统大致相同的运营成本来部署平台。

The combination of these differentiating design features makes Fabric one of
the **better performing platforms** available today both in terms of transaction
processing and transaction confirmation latency, and it enables **privacy and confidentiality** of transactions and the smart contracts (what Fabric calls
  "chaincode") that implement them.
  
这些差异化设计特性的结合使Fabric成为当今交易处理和交易确认延迟方面**性能更好的平台**之一，它实现了交易的**隐私和保密**以及智能合约（Fabric称之为“链码”）。

Let's explore these differentiating features in more detail.

让我们更详细地探索这些差异化的功能。

## Modularity(模块化)

Hyperledger Fabric has been specifically architected to have a modular
architecture. Whether it is pluggable consensus, pluggable identity management
protocols such as LDAP or OpenID Connect, key management protocols or
cryptographic libraries, the platform has been designed at its core to be
configured to meet the diversity of enterprise use case requirements.

Hyperledger Fabric被专门设计为具有模块化架构。无论是可插拔的共识、可插拔的身份管理协议（如LDAP或OpenID Connect）、密钥管理协议，还是加密库，该平台的核心设计旨在满足企业案例需求的多样性。

At a high level, Fabric is comprised of the following modular components:

- A pluggable _ordering service_ establishes consensus on the order of
transactions and then broadcasts blocks to peers.
- A pluggable _membership service provider_ is responsible for associating
entities in the network with cryptographic identities.
- An optional _peer-to-peer gossip service_ disseminates the blocks output by
ordering service to other peers.
- Smart contracts ("chaincode") run within a container environment (e.g. Docker)
for isolation. They can be written in standard programming languages but do not
have direct access to the ledger state.
- The ledger can be configured to support a variety of DBMSs.
- A pluggable endorsement and validation policy enforcement that can be
independently configured per application.

总体来看，Fabric由以下模块化的组件组成：

- 可插拔 _排序服务_ 对交易顺序建立共识，然后向所有节点广播各区块。
- 可插入的 _成员服务提供者_ 负责将网络中的实体与加密身份相关联。
- 可选的 _P2P gossip服务_ 通过排序服务传播区块输出到其他节点。
- 智能合约（“链码”）在容器环境（例如Docker）内运行以隔离。它们可以用标准编程语言编写，但不能直接访问账本状态。
- 账本可以配置成支持各种DBMS。
- 可插拔的背书和验证策略实施，可根据应用程序自由配置。

There is fair agreement in the industry that there is no "one blockchain to
rule them all". Hyperledger Fabric can be configured in multiple ways to
satisfy the diverse solution requirements for multiple industry use cases.

业界一致公认，不存在“一个区块链统治所有人”的情况。Hyperledger Fabric可以通过多种方式进行配置，以满足多个行业案例的各种解决方案要求。

## Permissioned vs Permissionless Blockchains - 许可区块链与非许可区块链

In a permissionless blockchain, virtually anyone can participate, and every
participant is anonymous. In such a context, there can be no trust other than
that the state of the blockchain, prior to a certain depth, is immutable. In
order to mitigate this absence of trust, permissionless blockchains typically
employ a "mined" native cryptocurrency or transaction fees to provide economic
incentive to offset the extraordinary costs of participating in a form of
byzantine fault tolerant consensus based on "proof of work" (PoW).

在一个非许可区块链中，几乎任何人都可以参与，每个参与者都是匿名的。在这样的情况下，区块链状态达到不可变的确定区块深度前不存在信任。为了弥补这种信任的缺失，非许可区块链通常采用“挖矿”本地加密货币或交易费用来提供经济激励，以抵消参与基于“工作量证明”(PoW)的拜占庭容错共识形式的特殊成本。

**Permissioned** blockchains, on the other hand, operate a blockchain amongst
a set of known, identified and often vetted participants operating under a
governance model that yields a certain degree of trust. A permissioned
blockchain provides a way to secure the interactions among a group of entities
that have a common goal but which may not fully trust each other. By relying on
the identities of the participants, a permissioned blockchain can use more
traditional crash fault tolerant (CFT) or byzantine fault tolerant (BFT)
consensus protocols that do not require costly mining.

另一方面，**许可**区块链在一组已知的、已识别的且经常经过审查的参与者中操作区块链，这些参与者在产生一定程度信任的治理模型下运作。许可的区块链提供了一种方法来保护具有共同目标，但可能彼此不完全信任的一组实体之间的交互。通过依赖参与者的身份，许可的区块链可以使用更传统的崩溃容错（CFT）或拜占庭容错（BFT）共识协议，而不需要昂贵的挖掘。

Additionally, in such a permissioned context, the risk of a participant
intentionally introducing malicious code through a smart contract is diminished.
First, the participants are known to one another and all actions, whether
submitting application transactions, modifying the configuration of the network
or deploying a smart contract are recorded on the blockchain following an
endorsement policy that was established for the network and relevant transaction
type. Rather than being completely anonymous, the guilty party can be easily
identified and the incident handled in accordance with the terms of the
governance model.

另外，在如许可情况下，参与者故意通过智能合约引入恶意代码的风险被降低。首先，参与者彼此了解对方以及所有的操作，无论是提交应用交易、修改网络配置还是部署智能合约都根据网络中已经确定的背书策略和相关交易类型被记录在区块链上。与完全匿名相比，可以很容易地识别犯罪方，并根据治理模式的条款处理事件。

## Smart Contracts

A smart contract, or what Fabric calls "chaincode", functions as a trusted
distributed application that gains its security/trust from the blockchain and
the underlying consensus among the peers. It is the business logic of a
blockchain application.

There are three key points that apply to smart contracts, especially when
applied to a platform:

- many smart contracts run concurrently in the network,
- they may be deployed dynamically (in many cases by anyone), and
- application code should be treated as untrusted, potentially even
malicious.

Most existing smart-contract capable blockchain platforms follow an
**order-execute** architecture in which the consensus protocol:

- validates and orders transactions then propagates them to all peer nodes,
- each peer then executes the transactions sequentially.

The order-execute architecture can be found in virtually all existing blockchain
systems, ranging from public/permissionless platforms such as
[Ethereum](https://ethereum.org/) (with PoW-based consensus) to permissioned
platforms such as [Tendermint](http://tendermint.com/),
[Chain](http://chain.com/), and [Quorum](http://www.jpmorgan.com/global/Quorum).

Smart contracts executing in a blockchain that operates with the order-execute
architecture must be deterministic; otherwise, consensus might never be reached.
To address the non-determinism issue, many platforms require that the smart
contracts be written in a non-standard, or domain-specific language
(such as [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) so that
non-deterministic operations can be eliminated. This hinders wide-spread
adoption because it requires developers writing smart contracts to learn a new
language and may lead to programming errors.

Further, since all transactions are executed sequentially by all nodes,
performance and scale is limited. The fact that the smart contract code executes
on every node in the system demands that complex measures be taken to protect
the overall system from potentially malicious contracts in order to ensure
resiliency of the overall system.

## A New Approach

Fabric introduces a new architecture for transactions that we call
**execute-order-validate**. It addresses the resiliency, flexibility,
scalability, performance and confidentiality challenges faced by the
order-execute model by separating the transaction flow into three steps:

- _execute_ a transaction and check its correctness, thereby endorsing it,
- _order_ transactions via a (pluggable) consensus protocol, and
- _validate_ transactions against an application-specific endorsement policy
before committing them to the ledger

This design departs radically from the order-execute paradigm in that Fabric
executes transactions before reaching final agreement on their order.

In Fabric, an application-specific endorsement policy specifies which peer
nodes, or how many of them, need to vouch for the correct execution of a given
smart contract. Thus, each transaction need only be executed (endorsed) by the
subset of the peer nodes necessary to satisfy the transaction's endorsement
policy. This allows for parallel execution increasing overall performance and
scale of the system. This first phase also **eliminates any non-determinism**,
as inconsistent results can be filtered out before ordering.

Because we have eliminated non-determinism, Fabric is the first blockchain
technology that **enables use of standard programming languages**. In the 1.1.0
release, smart contracts can be written in either Go or Node.js, while there are
plans to support other popular languages including Java in subsequent releases.

## Privacy and Confidentiality

As we have discussed, in a public, permissionless blockchain network that
leverages PoW for its consensus model, transactions are executed on every node.
This means that neither can there be confidentiality of the contracts
themselves, nor of the transaction data that they process. Every transaction,
and the code that implements it, is visible to every node in the network. In
this case, we have traded confidentiality of contract and data for byzantine
fault tolerant consensus delivered by PoW.

This lack of confidentiality can be problematic for many business/enterprise use
cases. For example, in a network of supply-chain partners, some consumers might
be given preferred rates as a means of either solidifying a relationship, or
promoting additional sales. If every participant can see every contract and
transaction, it becomes impossible to maintain such business relationships in a
completely transparent network -- everyone will want the preferred rates!

As a second example, consider the securities industry, where a trader building
a position (or disposing of one) would not want her competitors to know of this,
or else they will seek to get in on the game, weakening the trader's gambit.

In order to address the lack of privacy and confidentiality for purposes of
delivering on enterprise use case requirements, blockchain platforms have
adopted a variety of approaches. All have their trade-offs.

Encrypting data is one approach to providing confidentiality; however, in a
permissionless network leveraging PoW for its consensus, the encrypted data is
sitting on every node. Given enough time and computational resource, the
encryption could be broken. For many enterprise use cases, the risk that their
information could become compromised is unacceptable.

Zero knowledge proofs (ZKP) are another area of research being explored to
address this problem, the trade-off here being that, presently, computing a ZKP
requires considerable time and computational resources. Hence, the trade-off in
this case is performance for confidentiality.

In a permissioned context that can leverage alternate forms of consensus, one
might explore approaches that restrict the distribution of confidential
information exclusively to authorized nodes.

Hyperledger Fabric, being a permissioned platform, enables confidentiality
through its channel architecture. Basically, participants on a Fabric network
can establish a "channel" between the subset of participants that should be
granted visibility to a particular set of transactions. Think of this as a
network overlay. Thus, only those nodes that participate in a channel have
access to the smart contract (chaincode) and data transacted, preserving the
privacy and confidentiality of both.

To improve upon its privacy and confidentiality capabilities, Fabric has
added support for [private data](./private-data/private-data.html) and is working
on zero knowledge proofs (ZKP) available in the future. More on this as it
becomes available.

## Pluggable Consensus

The ordering of transactions is delegated to a modular component for consensus
that is logically decoupled from the peers that execute transactions and
maintain the ledger. Specifically, the ordering service. Since consensus is
modular, its implementation can be tailored to the trust assumption of a
particular deployment or solution. This modular architecture allows the platform
to rely on well-established toolkits for CFT (crash fault-tolerant) or BFT
(byzantine fault-tolerant) ordering.

In the currently available releases, Fabric offers a CFT ordering service
implemented with [Kafka](https://kafka.apache.org/) and
[Zookeeper](https://zookeeper.apache.org/). In subsequent releases, Fabric will
deliver a [Raft consensus ordering service](https://raft.github.io/) implemented
with etcd/Raft and a fully decentralized BFT ordering service.

Note also that these are not mutually exclusive. A Fabric network can have
multiple ordering services supporting different applications or application
requirements.

## Performance and Scalability

Performance of a blockchain platform can be affected by many variables such as
transaction size, block size, network size, as well as limits of the hardware,
etc. The Hyperledger community is currently developing [a draft set of measures](https://docs.google.com/document/d/1DQ6PqoeIH0pCNJSEYiw7JVbExDvWh_ZRVhWkuioG4k0/edit#heading=h.t3gztry2ja8i) within the Performance and Scale working group, along
with a corresponding implementation of a benchmarking framework called
[Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

While that work continues to be developed and should be seen as a definitive
measure of blockchain platform performance and scale characteristics, a team
from IBM Research has published a
[peer reviewed paper](https://arxiv.org/abs/1801.10228v1) that evaluated the
architecture and performance of Hyperledger Fabric. The paper offers an in-depth
discussion of the architecture of Fabric and then reports on the team's
performance evaluation of the platform using a preliminary release of
Hyperledger Fabric v1.1.

The benchmarking efforts that the research team did yielded a significant
number of performance improvements for the Fabric v1.1.0 release that more than
doubled the overall performance of the platform from the v1.0.0 release levels.

## Conclusion

Any serious evaluation of blockchain platforms should include Hyperledger Fabric
in its short list.

Combined, the differentiating capabilities of Fabric make it a highly scalable
system for permissioned blockchains supporting flexible trust assumptions that
enable the platform to support a wide range of industry use cases ranging from
government, to finance, to supply-chain logistics, to healthcare and so much
more.

More importantly, Hyperledger Fabric is the most active of the (currently) ten
Hyperledger projects. The community building around the platform is growing
steadily, and the innovation delivered with each successive release far
out-paces any of the other enterprise blockchain platforms.

## Acknowledgement

The preceding is derived from the peer reviewed
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://arxiv.org/abs/1801.10228v2) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
