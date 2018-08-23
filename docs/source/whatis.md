bplist00�_WebMainResource�	
_WebResourceTextEncodingName^WebResourceURL_WebResourceFrameName_WebResourceData_WebResourceMIMETypeUUTF-8_�https://raw.githubusercontent.com/hyperledger-labs/fabric-docs-cn/fad88c27ad0002d9f7ac9ec6fb17547382721a0d/docs/source/whatis.mdPO��<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;"># Introduction - 引言

In general terms, a blockchain is an immutable transaction ledger, maintained
within a distributed network of _peer nodes_. These nodes each maintain a copy
of the ledger by applying transactions that have been validated by a _consensus
protocol_, grouped into blocks that include a hash that bind each block to the
preceding block.

一般而言，区块链是在 _节点_ 的分布式网络中被维护的，不可变更的交易账本。这些节点通过应用已经由 _共识协议_ 验证的交易，来分别维护账本的副本，该交易被分组为包括将每个区块绑定到前一个区块的散列的区块。

The first and most widely recognized application of blockchain is the
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin) cryptocurrency, though others
have followed in its footsteps. Ethereum, an alternative cryptocurrency, took a
different approach, integrating many of the same characteristics as Bitcoin but
adding _smart contracts_ to create a platform for distributed applications.
Bitcoin and Ethereum fall into a class of blockchain that we would classify as
_public permissionless_ blockchain technology.  Basically, these are public
networks, open to anyone, where participants interact anonymously.

区块链的第一个、也是最广为人知的应用是[比特币](https://en.wikipedia.org/wiki/Bitcoin)加密货币，其他应用都跟随它的脚步产生。以太币是另一种加密货币，采用了不同的方法，集成了许多与比特币相同的特性，但增加了 _智能合约_ ，从而为分布式应用创建了一个平台。比特币和以太坊属于一类区块链，我们将其归类为 _公共非许可_ 区块链技术。基本上，这些是公共网络，对任何人开放，参与者匿名互动。

As the popularity of Bitcoin, Ethereum and a few other derivative technologies
grew, interest in applying the underlying technology of the blockchain,
distributed ledger and distributed application platform to more innovative
_enterprise_ use cases also grew. However, many enterprise use cases require
performance characteristics that the permissionless blockchain technologies are
unable (presently) to deliver. In addition, in many use cases, the identity of
the participants is a hard requirement, such as in the case of financial
transactions where Know-Your-Customer (KYC) and Anti-Money Laundering (AML)
regulations must be followed.

随着比特币，以太坊和其他一些衍生技术的普及，更具创新性地将区块链基础技术、分布式账本和分布式应用平台应用于 _企业_ 用例的兴趣也在增长。但是，许多企业用例要求无授权区块链技术不可（目前）交付的性能特征。此外，在许多用例中，参与者的身份是一项硬性要求，如在金融交易情况下，必须遵循“了解客户”和“反洗钱”的法规。

For enterprise use, we need to consider the following requirements:

- Participants must be identified/identifiable
- Networks need to be _permissioned_
- High transaction throughput performance
- Low latency of transaction confirmation
- Privacy and confidentiality of transactions and data pertaining to business
  transactions

对于企业用途，我们需要考虑以下要求：
-	必须识别/可识别参与者
-	网络需要获得许可
-	高交易吞吐量性能
-	交易确认的低延迟
-	与商业交易有关的交易和数据的隐私和机密性

While many early blockchain platforms are currently being _adapted_ for
enterprise use, Hyperledger Fabric has been _designed_ for enterprise use from
the outset. The following sections describe how Hyperledger Fabric (Fabric)
differentiates itself from other blockchain platforms and describes some of the
motivation for its architectural decisions.

虽然许多早期的区块链平台目前适合企业使用，但Hyperledger Fabric 从一开始就被 _设计_ 于企业用途。以下部分描述了Hyperledger Fabric（Fabric）如何将自己与其他区块链平台区分开来，并描述了其架构决策的一些动机。

## Hyperledger Fabric

Hyperledger Fabric is an open source enterprise-grade permissioned distributed
ledger technology (DLT) platform, designed for use in enterprise contexts,
that delivers some key differentiating capabilities over other popular
distributed ledger or blockchain platforms.

Hyperledger Fabric是一种开源的企业级许可分布式账本技术平台，专为在企业环境中使用而设计，与其他流行的分布式账本或区块链平台相比，它有一些关键的差异化功能。

One key point of differentiation is that Hyperledger was established under the
Linux Foundation, which itself has a long and very successful history of
nurturing open source projects under **open governance** that grow strong
sustaining communities and thriving ecosystems. Hyperledger is governed by a
diverse technical steering committee, and the Hyperledger Fabric project by a
diverse set of maintainers from multiple organizations. It has a development
community that has grown to over 35 organizations and nearly 200 developers
since its earliest commits.

一个关键差异点是Hyperledger是在Linux基金会下建立的，该基金会本身在**开放式治理**下培育开源项目的历史悠久且非常成功，这些项目可以发展强大的持续社区和蓬勃发展的生态系统。Hyperledger由多元化技术指导委员会和Hyperledger Fabric项目管理，该项目由来自多个组织的各种维护人员组成。它拥有一个开发社区，自最早提交以来已经发展到超过35个组织和近200个开发人员。

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

Fabric是第一个支持**用通用编程语言编写智能合约**（如Java，Go和Node.js）的分布式账本平台，而不是受限制的领域特定语言（DSL）。这意味着大多数企业已经拥有开发智能合约所需的技能，并且不需要额外的培训来学习新的语言或领域特定语言。

The Fabric platform is also **permissioned**, meaning that, unlike with a public
permissionless network, the participants are known to each other, rather than
anonymous and therefore fully untrusted. This means that while the participants
may not _fully_ trust one another (they may, for example, be competitors in the
same industry), a network can be operated under a governance model that is built
off of what trust _does_ exist between participants, such as a legal agreement
or framework for handling disputes.

Fabric平台也获得了**许可**，这意味着，与公共非许可网络不同，参与者彼此了解，而不是匿名，因此完全不受信任。这意味着，尽管参与者可能不会 _完全_ 信任彼此（例如，在同行业竞争对手），网络可以在建立在参与者之间 _确实_ 存在的信任之上的治理模式下运行，如处理有争议的法律协议或框架。

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

该平台最重要的区别之一是它支持**可插拔的共识协议**，使平台能够更有效地进行定制以适应特定的用例和信任模型。例如，当部署在单个企业内或由可信任的权威机构运营时，完全拜占庭容错的共识可能被认为是不必要的，并且对性能和吞吐量造成过度拖累。在诸如此类的情况下，[崩溃容错](https://en.wikipedia.org/wiki/Fault_tolerance)共识协议可能绰绰有余，而在去中心化用例中，可能需要更传统的[拜占庭容错](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)共识协议。

Fabric can leverage consensus protocols that **do not require a native
cryptocurrency** to incent costly mining or to fuel smart contract execution.
Avoidance of a cryptocurrency reduces some significant risk/attack vectors,
and absence of cryptographic mining operations means that the platform can be
deployed with roughly the same operational cost as any other distributed system.

Fabric可以利用**不需要本机加密货币**的共识协议来激活昂贵的采矿或推动智能合约执行。避免加密货币会减少一些重要的风险/攻击向量，并且缺少加密挖掘操作意味着可以使用与任何其他分布式系统大致相同的运营成本来部署平台。

The combination of these differentiating design features makes Fabric one of
the **better performing platforms** available today both in terms of transaction
processing and transaction confirmation latency, and it enables **privacy and confidentiality** of transactions and the smart contracts (what Fabric calls "chaincode") that implement them.

这些差异化设计特性的结合使Fabric成为当今业务处理和事务确认延迟方面**性能更好的平台**之一，它实现了交易的**隐私和保密**以及它们的智能合约（Fabric称之为“链码”）。

Let's explore these differentiating features in more detail.

让我们更详细地探索这些差异化的功能。

## Modularity - 模块化

Hyperledger Fabric has been specifically architected to have a modular
architecture. Whether it is pluggable consensus, pluggable identity management
protocols such as LDAP or OpenID Connect, key management protocols or
cryptographic libraries, the platform has been designed at its core to be
configured to meet the diversity of enterprise use case requirements.

Hyperledger Fabric被专门设计为具有模块化架构。无论是可插拔的共识、可插拔的身份管理协议（如LDAP或OpenID Connect）、密钥管理协议，还是加密库，该平台的核心设计旨在满足企业用例需求的多样性。

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

在高层次水平下，Fabric由以下模块化组件组成：
-	可插拔 _排序服务_ 就交易顺序建立共识，然后向所有节点广播各区块。
- 可插入的 _成员服务提供者_ 负责将网络中的实体与加密身份相关联。
- 可选的 _P2P gossip服务_ 通过与其他节点的交易服务来传播区块输出。
- 智能合约（“链码”）在容器环境（例如Docker）内运行以隔离。它们可以用标准编程语言编写，但不能直接访问账本状态。
- 账本可以配置成支持各种DBMS。
- 可插拔的认可和验证政策实施，可根据应用程序独立配置。

There is fair agreement in the industry that there is no "one blockchain to
rule them all". Hyperledger Fabric can be configured in multiple ways to
satisfy the diverse solution requirements for multiple industry use cases.

业界一致公认，不存在“一个区块链统治所有人”的情况。Hyperledger Fabric可以通过多种方式进行配置，以满足多个行业用例的各种解决方案要求。

## Permissioned vs Permissionless Blockchains - 许可区块链与非许可区块链

In a permissionless blockchain, virtually anyone can participate, and every
participant is anonymous. In such a context, there can be no trust other than
that the state of the blockchain, prior to a certain depth, is immutable. In
order to mitigate this absence of trust, permissionless blockchains typically
employ a "mined" native cryptocurrency or transaction fees to provide economic
incentive to offset the extraordinary costs of participating in a form of
byzantine fault tolerant consensus based on "proof of work" (PoW).

在一个非许可区块链中，几乎任何人都可以参与，每个参与者都是匿名的。在这样的情况下，除了在某个深度之前区块链的状态是不可变的之外，不存在任何信任。为了减轻这种信任的缺失，非许可区块链通常采用“挖掘”的本地加密货币或交易费用来提供经济激励，以抵消参与基于“工作量证明”(PoW)的拜占庭容错共识形式的特殊成本。

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

另外，在这种许可情况下，参与者故意通过智能合约引入恶意代码的风险降低。首先，参与者彼此了解，且无论是提交应用程序交易、修改网络配置还是部署智能合约的所有行为，都被记录在区块链上，该区块链遵从为网络和相关交易类型建立的认可政策。这样不是完全匿名，因而可以很容易地识别有罪方，并根据治理模式的条款处理事件。

## Smart Contracts - 智能合约

A smart contract, or what Fabric calls "chaincode", functions as a trusted
distributed application that gains its security/trust from the blockchain and
the underlying consensus among the peers. It is the business logic of a
blockchain application.

作为受信任的分布式应用程序，智能合约，即Fabric中的“链码”从区块链获得其安全性/信任以及同行之间的基本共识。它是区块链应用的业务逻辑。

There are three key points that apply to smart contracts, especially when
applied to a platform:

- many smart contracts run concurrently in the network,
- they may be deployed dynamically (in many cases by anyone), and
- application code should be treated as untrusted, potentially even
malicious.

应用智能合约有三个关键点，尤其是应用于某个平台时：
- 许多智能合约在网络中同时运行，
- 它们可以动态部署（在很多情况下、由任何人），
- 应用代码应视为不受信任的，甚至可能是恶意的。

Most existing smart-contract capable blockchain platforms follow an
**order-execute** architecture in which the consensus protocol:

- validates and orders transactions then propagates them to all peer nodes,
- each peer then executes the transactions sequentially.

大多数现有的具有智能合约能力的区块链平台遵循**排序执行**架构，其中共识协议：
- 验证并将交易排序，然后将它们传播到所有节点，
- 每个节点按顺序执行交易。

The order-execute architecture can be found in virtually all existing blockchain
systems, ranging from public/permissionless platforms such as
[Ethereum](https://ethereum.org/) (with PoW-based consensus) to permissioned
platforms such as [Tendermint](http://tendermint.com/),
[Chain](http://chain.com/), and [Quorum](http://www.jpmorgan.com/global/Quorum).

几乎所有现有的区块链系统都可以找到排序执行架构，范围从公共/非许可平台，如[以太坊](https://ethereum.org/) （基于PoW的共识）到许可平台，如[Tendermint](http://tendermint.com/)，[Chain](http://chain.com/)和[Quorum](http://www.jpmorgan.com/global/Quorum)。

Smart contracts executing in a blockchain that operates with the order-execute
architecture must be deterministic; otherwise, consensus might never be reached.
To address the non-determinism issue, many platforms require that the smart
contracts be written in a non-standard, or domain-specific language
(such as [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) so that
non-deterministic operations can be eliminated. This hinders wide-spread
adoption because it requires developers writing smart contracts to learn a new
language and may lead to programming errors.

在区块链中执行的与排序执行架构一起运行的智能合约必须是确定性的；否则，可能永远不会达成共识。为了解决不确定性问题，许多平台要求智能合约以非标准或特定于域的语言（例如[Solidity](https://solidity.readthedocs.io/en/v0.4.23/)）编写，以便可以消除不确定性操作。这阻碍了智能合约的广泛应用，因为它要求开发人员编写智能合同以学习新语言，且可能导致编程错误。

Further, since all transactions are executed sequentially by all nodes,
performance and scale is limited. The fact that the smart contract code executes
on every node in the system demands that complex measures be taken to protect
the overall system from potentially malicious contracts in order to ensure
resiliency of the overall system.

此外，由于所有节点都按顺序执行所有交易，性能和规模是有限的。智能合约代码在系统中的每个节点上执行，这要求采取复杂措施来保护整个系统免受潜在恶意合同的影响，以确保整个系统的弹性。

## A New Approach - 一种新方法

Fabric introduces a new architecture for transactions that we call
**execute-order-validate**. It addresses the resiliency, flexibility,
scalability, performance and confidentiality challenges faced by the
order-execute model by separating the transaction flow into three steps:

- _execute_ a transaction and check its correctness, thereby endorsing it,
- _order_ transactions via a (pluggable) consensus protocol, and
- _validate_ transactions against an application-specific endorsement policy
before committing them to the ledger

Fabric为我们称为**排序执行验证**的交易引入了一种新的体系结构 。为了解决排序执行模型面临的弹性、灵活性、可伸缩性、性能和机密性问题，它将交易流分为三个步骤：
- _执行_ 一个交易并检查其正确性，从而给它背书，
- 通过（可插入的）共识协议将交易 _排序_ ，以及
- 根据特定应用程序的认可政策 _验证_ 交易，再将其提交到帐本

This design departs radically from the order-execute paradigm in that Fabric
executes transactions before reaching final agreement on their order.

这种设计与排序执行范例完全不同，因为Fabric在对排序达成最终协议之前执行交易。

In Fabric, an application-specific endorsement policy specifies which peer
nodes, or how many of them, need to vouch for the correct execution of a given
smart contract. Thus, each transaction need only be executed (endorsed) by the
subset of the peer nodes necessary to satisfy the transaction's endorsement
policy. This allows for parallel execution increasing overall performance and
scale of the system. This first phase also **eliminates any non-determinism**,
as inconsistent results can be filtered out before ordering.

在Fabric中，特定应用程序的背书策略指定哪些节点或多少节点需要保证正确执行给定的智能合约。因此，每个交易只需要由满足交易的背书策略所必需的节点的子集来执行（背书）。这样可以并行执行，从而提高系统的整体性能和规模。第一阶段也**消除了任何不确定性**，因为在排序之前可以滤除不一致的结果。

Because we have eliminated non-determinism, Fabric is the first blockchain
technology that **enables use of standard programming languages**. In the 1.1.0
release, smart contracts can be written in either Go or Node.js, while there are
plans to support other popular languages including Java in subsequent releases.

因为我们已经消除了不确定性，Fabric是第一个**能使用标准编程语言**的区块链技术。在1.1.0版本中，智能合约可以用Go或Node.js编写，而在后续版本中，也将计划支持其他流行语言，包括Java。

## Privacy and Confidentiality - 隐私和保密

As we have discussed, in a public, permissionless blockchain network that
leverages PoW for its consensus model, transactions are executed on every node.
This means that neither can there be confidentiality of the contracts
themselves, nor of the transaction data that they process. Every transaction,
and the code that implements it, is visible to every node in the network. In
this case, we have traded confidentiality of contract and data for byzantine
fault tolerant consensus delivered by PoW.

正如我们所讨论的，在一个公共的、非许可的区块链网络中，利用PoW作为其共识模型，交易在每个节点上执行。这意味着合同本身和他们处理的交易数据都不保密。每个交易以及实现它的代码，对于网络中的每个节点都是可见的。在这种情况下，我们交易了PoW提供的拜占庭容错共识的合同和数据的保密性。

This lack of confidentiality can be problematic for many business/enterprise use
cases. For example, in a network of supply-chain partners, some consumers might
be given preferred rates as a means of either solidifying a relationship, or
promoting additional sales. If every participant can see every contract and
transaction, it becomes impossible to maintain such business relationships in a
completely transparent network -- everyone will want the preferred rates!

对于许多商业/企业用例而言，保密性的缺乏可能会有问题。例如，在供应链合作伙伴网络中，某些消费者可能会获得优惠利率，作为巩固关系或促进额外销售的手段。如果每个参与者都可以看到每个合同和交易，那么，每个人都希望获得优惠费率！这样就无法在完全透明的网络中维持这种商业关系。

As a second example, consider the securities industry, where a trader building
a position (or disposing of one) would not want her competitors to know of this,
or else they will seek to get in on the game, weakening the trader's gambit.

第二个例子是证券行业的，建立头寸（或处置）的交易者不希望被她的竞争对手知道，否则他们将试图进入游戏，制定削弱交易者的策略。

In order to address the lack of privacy and confidentiality for purposes of
delivering on enterprise use case requirements, blockchain platforms have
adopted a variety of approaches. All have their trade-offs.

为了解决企业用例要求导致的缺乏隐私和保密的问题，区块链平台采用了多种方法。所有方法都需要权衡利弊。

Encrypting data is one approach to providing confidentiality; however, in a
permissionless network leveraging PoW for its consensus, the encrypted data is
sitting on every node. Given enough time and computational resource, the
encryption could be broken. For many enterprise use cases, the risk that their
information could become compromised is unacceptable.

加密数据是提供保密性的一种方法；然而，在利用PoW达成共识的非许可网络中，加密数据位于每个节点上。如果有足够的时间和计算资源，加密可能会被破解。对于许多企业用例，信息可能受损的风险是不能接受的。

Zero knowledge proofs (ZKP) are another area of research being explored to
address this problem, the trade-off here being that, presently, computing a ZKP
requires considerable time and computational resources. Hence, the trade-off in
this case is performance for confidentiality.

零知识证明（ZKP）是正在探索解决该问题的另一个研究领域。目前，计算ZKP需要相当多的时间和计算资源，因此，在这种情况下的利弊权衡是资源消耗与保密性能。

In a permissioned context that can leverage alternate forms of consensus, one
might explore approaches that restrict the distribution of confidential
information exclusively to authorized nodes.

在可以利用其他形式共识的许可情况下，人们可以探索将机密信息限制于授权节点的方法。

Hyperledger Fabric, being a permissioned platform, enables confidentiality
through its channel architecture. Basically, participants on a Fabric network
can establish a "channel" between the subset of participants that should be
granted visibility to a particular set of transactions. Think of this as a
network overlay. Thus, only those nodes that participate in a channel have
access to the smart contract (chaincode) and data transacted, preserving the
privacy and confidentiality of both.

Hyperledger Fabric是一个许可平台，通过其通道架构实现保密。基本上，Fabric网络上的参与者可以在参与者子集之间建立“通道”，该通道应被授予对特定交易集的可见性。将此视为网络覆盖。从而只有参与频道的节点才能访问智能合约（链码）和数据交易，保护了两者的隐私和保密性。

To improve upon its privacy and confidentiality capabilities, Fabric has
added support for [private data](./private-data/private-data.html) and is working
on zero knowledge proofs (ZKP) available in the future. More on this as it
becomes available.

为了提高其隐私和机密性能，Fabric增加了对[私有数据](./private-data/private-data.html)的支持，并且正在开发未来可用的零知识证明（ZKP）。随着它变得可用，将会有更多这方面的研究。

## Pluggable Consensus - 可插入的共识

The ordering of transactions is delegated to a modular component for consensus
that is logically decoupled from the peers that execute transactions and
maintain the ledger. Specifically, the ordering service. Since consensus is
modular, its implementation can be tailored to the trust assumption of a
particular deployment or solution. This modular architecture allows the platform
to rely on well-established toolkits for CFT (crash fault-tolerant) or BFT
(byzantine fault-tolerant) ordering.

交易的排序被委托给模块化组件以达成共识，该组件在逻辑上与执行交易（特别是排序交易）和维护分类帐的节点分离。由于共识是模块化的，可以根据特定部署或解决方案的信任假设来定制其实现。这种模块化架构允许平台依赖完善的工具包进行CFT（崩溃容错）或BFT（拜占庭容错）的排序。

In the currently available releases, Fabric offers a CFT ordering service
implemented with [Kafka](https://kafka.apache.org/) and
[Zookeeper](https://zookeeper.apache.org/). In subsequent releases, Fabric will
deliver a [Raft consensus ordering service](https://raft.github.io/) implemented
with etcd/Raft and a fully decentralized BFT ordering service.

在当前可用的版本中，Fabric提供了使用[Kafka](https://kafka.apache.org/)和[Zookeeper](https://zookeeper.apache.org/)实现的CFT订购服务。在之后的版本中，Fabric将提供使用etcd/Raft实现的[Raft共识排序服务](https://raft.github.io/)以及完全去中心化的BFT排序服务。

Note also that these are not mutually exclusive. A Fabric network can have
multiple ordering services supporting different applications or application
requirements.

需要注意的是，这些并不相互排斥。Fabric网络可以有多种排序服务，支持不同的应用或应用要求。

## Performance and Scalability - 性能和可伸缩性

Performance of a blockchain platform can be affected by many variables such as
transaction size, block size, network size, as well as limits of the hardware,
etc. The Hyperledger community is currently developing [a draft set of measures](https://docs.google.com/document/d/1DQ6PqoeIH0pCNJSEYiw7JVbExDvWh_ZRVhWkuioG4k0/edit#heading=h.t3gztry2ja8i) within the Performance and Scale working group, along
with a corresponding implementation of a benchmarking framework called
[Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

区块链平台的性能可能会受到许多变量的影响，例如交易大小，区块大小，网络大小以及硬件限制等。Hyperledger社区目前正在开发性能和规模工作组中的[一套衡量标准草案](https://docs.google.com/document/d/1DQ6PqoeIH0pCNJSEYiw7JVbExDvWh_ZRVhWkuioG4k0/edit#heading=h.t3gztry2ja8i)，以及称为[Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper)的基准的测试框架的相应实现 。

While that work continues to be developed and should be seen as a definitive
measure of blockchain platform performance and scale characteristics, a team
from IBM Research has published a
[peer reviewed paper](https://arxiv.org/abs/1801.10228v1) that evaluated the
architecture and performance of Hyperledger Fabric. The paper offers an in-depth
discussion of the architecture of Fabric and then reports on the team's
performance evaluation of the platform using a preliminary release of
Hyperledger Fabric v1.1.

目前，这项工作仍在开发中，且应为区块链平台性能和规模特征的明确衡量标准。同时，IBM Research的一个团队发表了一份[同行评审论文](https://arxiv.org/abs/1801.10228v1)，评估了Hyperledger Fabric的架构和性能，提供了对Fabric架构的深入讨论，然后通过Hyperledger Fabric v1.1初版报告了团队对平台的性能评估。

The benchmarking efforts that the research team did yielded a significant
number of performance improvements for the Fabric v1.1.0 release that more than
doubled the overall performance of the platform from the v1.0.0 release levels.

研究团队所做的基准测试工作为Fabric v1.1.0版本带来了巨大的性能改进，与v1.0.0版本相比，平台的整体性能提高了一倍以上。

## Conclusion - 结论

Any serious evaluation of blockchain platforms should include Hyperledger Fabric
in its short list.

任何对区块链平台的认真评估都应该在其名单中包含Hyperledger Fabric。

Combined, the differentiating capabilities of Fabric make it a highly scalable
system for permissioned blockchains supporting flexible trust assumptions that
enable the platform to support a wide range of industry use cases ranging from
government, to finance, to supply-chain logistics, to healthcare and so much
more

而且，Fabric的差异化功能使其成为一个高度可扩展的系统，用于支持灵活的信任假设的许可区块链，使该平台能够支持从政府，金融，供应链物流到医疗保健等的各种更多的行业用例。

More importantly, Hyperledger Fabric is the most active of the (currently) ten
Hyperledger projects. The community building around the platform is growing
steadily, and the innovation delivered with each successive release far
out-paces any of the other enterprise blockchain platforms.

更重要的是，Hyperledger Fabric（目前）是十个Hyperledger项目中最活跃的。围绕平台的社区建设正在稳步增长，相继每个版本提供的创新远远超过任何其他企业区块链平台。

## Acknowledgement - 致谢

The preceding is derived from the peer reviewed
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://arxiv.org/abs/1801.10228v1) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick

前面的内容源自同行审阅的 [“Hyperledger Fabric：一个许可区块链的分布式操作系统”](https://arxiv.org/abs/1801.10228v1) - Elli Androulaki，Artem Barger，Vita Bortnikov，Christian Cachin，Konstantinos Christidis，Angelo De Caro，David Enyeart，Christopher Ferris，Gennady Laventman，Yacov Manevich，Srinivasan Muralidharan，Chet Murthy，Binh Nguyen，Manish Sethi，Gari Singh，Keith Smith，Alessandro Sorniotti，Chrysoula Stathakopoulou，Marko Vukolic，Sharon Weed Cocco，Jason Yellick
</pre></body></html>Ztext/plain    ( F U l ~ � ���                           ��