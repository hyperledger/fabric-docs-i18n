# 排序服务
# The Ordering Service

**受众**：架构师、排序服务管理员、通道创建者

**Audience:** Architects, ordering service admins, channel creators

本主题将概念性的介绍排序的概念、排序节点是如何与 Peer 节点交互的、它们在交易流程中如何所发挥作用以及当前可用的排序服务的实现方式，尤其关注建议的 **Raft** 排序服务实现。

This topic serves as a conceptual introduction to the concept of ordering, how
orderers interact with peers, the role they play in a transaction flow, and an
overview of the currently available implementations of the ordering service,
with a particular focus on the recommended **Raft** ordering service implementation.

## 什么是排序？

## What is ordering?

许多分布式区块链，如以太坊（Ethereum）和比特币（Bitcoin），都是非许可的，这意味着任何节点都可以参与共识过程，在共识过程中，交易被排序并打包成区块。因此，这些系统依靠**概率**共识算法最终保证账本一致性高的概率，但仍容易受到不同的账本（有时也称为一个账本“分叉”），在网络中不同的参与者对于交易顺序有不同的观点。

Many distributed blockchains, such as Ethereum and Bitcoin, are not permissioned,
which means that any node can participate in the consensus process, wherein
transactions are ordered and bundled into blocks. Because of this fact, these
systems rely on **probabilistic** consensus algorithms which eventually
guarantee ledger consistency to a high degree of probability, but which are
still vulnerable to divergent ledgers (also known as a ledger "fork"), where
different participants in the network have a different view of the accepted
order of transactions.

Hyperledger Fabric 的工作方式不同。它有一种称为**排序节点**的节点使交易有序，并与其他排序节点一起形成一个**排序服务**。因为 Fabric 的设计依赖于**确定性**的共识算法，所以 Peer 节点所验证的区块都是最终的和正确的。账本不会像其他分布式的以及无需许可的区块链中那样产生分叉。

Hyperledger Fabric works differently. It features a node called an
**orderer** (it's also known as an "ordering node") that does this transaction
ordering, which along with other orderer nodes forms an **ordering service**.
Because Fabric's design relies on **deterministic** consensus algorithms, any block
validated by the peer is guaranteed to be final and correct. Ledgers cannot fork
the way they do in many other distributed and permissionless blockchain networks.

除了促进确定性之外，排序节点还将链码执行的背书（发生在节点）与排序分离，这在性能和可伸缩性方面给 Fabric 提供了优势，消除了由同一个节点执行和排序时可能出现的瓶颈。

In addition to promoting finality, separating the endorsement of chaincode
execution (which happens at the peers) from ordering gives Fabric advantages
in performance and scalability, eliminating bottlenecks which can occur when
execution and ordering are performed by the same nodes.

## 排序节点和通道配置

## Orderer nodes and channel configuration

除了**排序**角色之外，排序节点还维护着允许创建通道的组织列表。此组织列表称为“联盟”，列表本身保存在“排序节点系统通道”（也称为“排序系统通道”）的配置中。默认情况下，此列表及其所在的通道只能由排序节点管理员编辑。请注意，排序服务可以保存这些列表中的几个，这使得联盟成为 Fabric 多租户的载体。

In addition to their **ordering** role, orderers also maintain the list of
organizations that are allowed to create channels. This list of organizations is
known as the "consortium", and the list itself is kept in the configuration of
the "orderer system channel" (also known as the "ordering system channel"). By
default, this list, and the channel it lives on, can only be edited by the
orderer admin. Note that it is possible for an ordering service to hold several
of these lists, which makes the consortium a vehicle for Fabric multi-tenancy.

排序节点还对通道执行基本访问控制，限制谁可以读写数据，以及谁可以配置数据。请记住，谁有权修改通道中的配置元素取决于相关管理员在创建联盟或通道时设置的策略。配置交易由排序节点处理，因为它需要知道当前的策略集合，并根据策略来执行其基本的访问控制。在这种情况下，排序节点处理配置更新，以确保请求者拥有正确的管理权限。如果有权限，排序节点将根据现有配置验证更新请求，生成一个新的配置交易，并将其打包到一个区块中，该区块将转发给通道上的所有节点。然后节点处理配置交易，以验证排序节点批准的修改确实满足通道中定义的策略。

Orderers also enforce basic access control for channels, restricting who can
read and write data to them, and who can configure them. Remember that who
is authorized to modify a configuration element in a channel is subject to the
policies that the relevant administrators set when they created the consortium
or the channel. Configuration transactions are processed by the orderer,
as it needs to know the current set of policies to execute its basic
form of access control. In this case, the orderer processes the
configuration update to make sure that the requestor has the proper
administrative rights. If so, the orderer validates the update request against
the existing configuration, generates a new configuration transaction,
and packages it into a block that is relayed to all peers on the channel. The
peers then process the configuration transactions in order to verify that the
modifications approved by the orderer do indeed satisfy the policies defined in
the channel.

## 排序节点和身份

## Orderer nodes and Identity

与区块链网络交互的所有东西，包括节点、应用程序、管理员和排序节点，都从它们的数字证书和成员服务提供者（MSP）定义中获取它们的组织身份。

Everything that interacts with a blockchain network, including peers,
applications, admins, and orderers, acquires their organizational identity from
their digital certificate and their Membership Service Provider (MSP) definition.

有关身份和 MSP 的更多信息，请查看我们关于[身份](../identity/identity.html)和[成员](../membership/membership.html)的文档。

For more information about identities and MSPs, check out our documentation on
[Identity](../identity/identity.html) and [Membership](../membership/membership.html).

与 Peer 节点一样，排序节点属于组织。也应该像 Peer 节点一样为每个组织使用单独的证书授权中心（CA）。这个 CA 是否将作为根 CA 发挥作用，或者您是否选择部署根 CA，然后部署与该根 CA 关联的中间 CA，这取决于您。

Just like peers, ordering nodes belong to an organization. And similar to peers,
a separate Certificate Authority (CA) should be used for each organization.
Whether this CA will function as the root CA, or whether you choose to deploy
a root CA and then intermediate CAs associated with that root CA, is up to you.

## 排序节点和交易流程

## Orderers and the transaction flow

### 阶段一：提案

### Phase one: Proposal

从我们对 [Peer 节点](../peers/peers.html)的讨论中，我们已经看到它们构成了区块链网络的基础，托管账本，应用程序可以通过智能合约查询和更新这些账本。

We've seen from our topic on [Peers](../peers/peers.html) that they form the basis
for a blockchain network, hosting ledgers, which can be queried and updated by
applications through smart contracts.

具体来说，更新账本的应用程序涉及到三个阶段，该过程确保区块链网络中的所有节点保持它们的账本彼此一致。

Specifically, applications that want to update the ledger are involved in a
process with three phases that ensures all of the peers in a blockchain network
keep their ledgers consistent with each other.

在第一阶段，客户端应用程序将交易提案发送给一组节点，这些节点将调用智能合约来生成一个账本更新提案，然后背书该结果。背书节点此时不将提案中的更新应用于其账本副本。相反，背书节点将向客户端应用程序返回一个提案响应。已背书的交易提案最终将在第二阶段经过排序生成区块，然后在第三阶段分发给所有节点进行最终验证和提交。

In the first phase, a client application sends a transaction proposal to
a subset of peers that will invoke a smart contract to produce a proposed
ledger update and then endorse the results. The endorsing peers do not apply
the proposed update to their copy of the ledger at this time. Instead, the
endorsing peers return a proposal response to the client application. The
endorsed transaction proposals will ultimately be ordered into blocks in phase
two, and then distributed to all peers for final validation and commit in
phase three.

要深入了解第一个阶段，请参阅[节点](../peers/peers.html#phase-1-proposal)主题。

For an in-depth look at the first phase, refer back to the [Peers](../peers/peers.html#phase-1-proposal) topic.

### 阶段二：将交易排序并打包到区块中

### Phase two: Ordering and packaging transactions into blocks

在完成交易的第一阶段之后，客户端应用程序已经从一组节点接收到一个经过背书的交易提案响应。现在是交易的第二阶段。

After the completion of the first phase of a transaction, a client
application has received an endorsed transaction proposal response from a set of
peers. It's now time for the second phase of a transaction.

在此阶段，应用程序客户端把包含已背书交易提案响应的交易提交到排序服务节点。排序服务创建交易区块，这些交易区块最终将分发给通道上的所有 Peer 节点，以便在第三阶段进行最终验证和提交。

In this phase, application clients submit transactions containing endorsed
transaction proposal responses to an ordering service node. The ordering service
creates blocks of transactions which will ultimately be distributed to
all peers on the channel for final validation and commit in phase three.

排序服务节点同时接收来自许多不同应用程序客户端的交易。这些排序服务节点一起工作，共同组成排序服务。它的工作是将提交的交易按定义好的顺序安排成批次，并将它们打包成*区块*。这些区块将成为区块链的*区块*！

Ordering service nodes receive transactions from many different application
clients concurrently. These ordering service nodes work together to collectively
form the ordering service. Its job is to arrange batches of submitted transactions
into a well-defined sequence and package them into *blocks*. These blocks will
become the *blocks* of the blockchain!

区块中的交易数量取决于区块的期望大小和最大间隔时间相关的通道配置参数（确切地说，是 `BatchSize` 和 `BatchTimeout` 参数）。然后将这些区块保存到排序节点的账本中，并分发给已经加入通道的所有节点。如果此时恰好有一个 Peer 节点关闭，或者稍后加入通道，它将在重新连接到排序服务节点或与另一个 Peer 节点通信之后接收到这些区块。我们将在第三阶段看到节点如何处理这个区块。

The number of transactions in a block depends on channel configuration
parameters related to the desired size and maximum elapsed duration for a
block (`BatchSize` and `BatchTimeout` parameters, to be exact). The blocks are
then saved to the orderer's ledger and distributed to all peers that have joined
the channel. If a peer happens to be down at this time, or joins the channel
later, it will receive the blocks after reconnecting to an ordering service
node, or by gossiping with another peer. We'll see how this block is processed
by peers in the third phase.

![Orderer1](./orderer.diagram.1.png)

*排序节点的第一个角色是打包提案的账本更新。在本例中，应用程序 A1 向排序节点 O1 发送由 E1 和 E2 背书的交易 T1。同时，应用程序 A2 将 E1 背书的交易 T2 发送给排序节点 O1。O1 将来自应用程序 A1 的交易 T1 和来自应用程序 A2 的交易 T2 以及来自网络中其他应用程序的交易打包到区块 B2 中。我们可以看到，在 B2 中，交易顺序是 T1、T2、T3、T4、T6、T5，但这可能不是这些交易到达排序节点的顺序！（这个例子显示了一个非常简单的排序服务配置，只有一个排序节点。）*

*The first role of an ordering node is to package proposed ledger updates. In
this example, application A1 sends a transaction T1 endorsed by E1 and E2 to
the orderer O1. In parallel, Application A2 sends transaction T2 endorsed by E1
to the orderer O1. O1 packages transaction T1 from application A1 and
transaction T2 from application A2 together with other transactions from other
applications in the network into block B2. We can see that in B2, the
transaction order is T1,T2,T3,T4,T6,T5 -- which may not be the order in which
these transactions arrived at the orderer! (This example shows a very
simplified ordering service configuration with only one ordering node.)*

值得注意的是，一个区块中交易的顺序不一定与排序服务接收的顺序相同，因为可能有多个排序服务节点几乎同时接收交易。重要的是，排序服务将交易放入严格的顺序中，并且 Peer 节点在验证和提交交易时将使用这个顺序。

It's worth noting that the sequencing of transactions in a block is not
necessarily the same as the order received by the ordering service, since there
can be multiple ordering service nodes that receive transactions at approximately
the same time.  What's important is that the ordering service puts the transactions
into a strict order, and peers will use this order when validating and committing
transactions.

区块内交易的严格排序使得 Hyperledger Fabric 与其他区块链稍有不同，在其他区块链中，相同的交易可以被打包成多个不同的区块，从而形成一个链。在 Hyperledger Fabric 中，由排序服务生成的区块是**最终的**。一旦一笔交易被写进一个区块，它在账本中的地位就得到了保证。正如我们前面所说，Hyperledger Fabric 的最终性意味着没有**账本分叉**，也就是说，经过验证的交易永远不会被重写或删除。

This strict ordering of transactions within blocks makes Hyperledger Fabric a
little different from other blockchains where the same transaction can be
packaged into multiple different blocks that compete to form a chain.
In Hyperledger Fabric, the blocks generated by the ordering service are
**final**. Once a transaction has been written to a block, its position in the
ledger is immutably assured. As we said earlier, Hyperledger Fabric's finality
means that there are no **ledger forks** --- validated transactions will never
be reverted or dropped.

我们还可以看到，虽然节 Peer 点执行智能合约并处理交易，而排序节点不会这样做。到达排序节点的每个授权交易都被机械地打包在一个区块中，排序节点不判断交易的内容（前面提到的通道配置交易除外）。

We can also see that, whereas peers execute smart contracts and process transactions,
orderers most definitely do not. Every authorized transaction that arrives at an
orderer is mechanically packaged in a block --- the orderer makes no judgement
as to the content of a transaction (except for channel configuration transactions,
as mentioned earlier).

在第二阶段的最后，我们看到排序节点负责一些简单但重要的过程，包括收集已提案的交易更新、排序并将它们打包成区块、准备分发。

At the end of phase two, we see that orderers have been responsible for the simple
but vital processes of collecting proposed transaction updates, ordering them,
and packaging them into blocks, ready for distribution.

### 阶段三：验证和提交

### Phase three: Validation and commit

交易工作流的第三个阶段涉及到从排序节点到 Peer 节点的区块的分发和随后的验证，这些区块可能会被提交到账本中。

The third phase of the transaction workflow involves the distribution and
subsequent validation of blocks from the orderer to the peers, where they can be
committed to the ledger.

第三阶段排序节点将区块分发给连接到它的所有 Peer 节点开始。同样值得注意的是，并不是每个 Peer 节点都需要连接到一个排序节点，Peer 节点可以使用 [**gossip 协议**](../gossip.html)将区块关联到其他节点。

Phase 3 begins with the orderer distributing blocks to all peers connected to
it. It's also worth noting that not every peer needs to be connected to an orderer ---
peers can cascade blocks to other peers using the [**gossip**](../gossip.html)
protocol.

每个节点将独立地以确定的方式验证区块，以确保账本保持一致。具体来说，通道中每个节点都将验证区块中的每个交易，以确保得到了所需组织的节点背书，也就是节点的背书和背书策略相匹配，并且不会因最初认可该事务时可能正在运行的其他最近提交的事务而失效。无效的交易仍然保留在排序节点创建的区块中，但是节点将它们标记为无效，并且不更新账本的状态。

Each peer will validate distributed blocks independently, but in a deterministic
fashion, ensuring that ledgers remain consistent. Specifically, each peer in the
channel will validate each transaction in the block to ensure it has been endorsed
by the required organization's peers, that its endorsements match, and that
it hasn't become invalidated by other recently committed transactions which may
have been in-flight when the transaction was originally endorsed. Invalidated
transactions are still retained in the immutable block created by the orderer,
but they are marked as invalid by the peer and do not update the ledger's state.

![Orderer2](./orderer.diagram.2.png)

*排序节点的第二个角色是将区块分发给 Peer 节点。在本例中，排序节点 O1 将区块 B2 分配给节点 P1 和 P2。节点 P1 处理区块 B2，在 P1 上的账本 L1 中添加一个新区块。同时，节点 P2 处理区块 B2，从而将一个新区块添加到 P2 上的账本 L1中。一旦这个过程完成，节点 P1 和 P2 上的账本 L1 就会保持一致的更新，并且每个节点都可以通知与之连接的应用程序交易已经被处理。*

*The second role of an ordering node is to distribute blocks to peers. In this
example, orderer O1 distributes block B2 to peer P1 and peer P2. Peer P1
processes block B2, resulting in a new block being added to ledger L1 on P1. In
parallel, peer P2 processes block B2, resulting in a new block being added to
ledger L1 on P2. Once this process is complete, the ledger L1 has been
consistently updated on peers P1 and P2, and each may inform connected
applications that the transaction has been processed.*

总之，第三阶段看到的是由排序服务生成的区块一致地应用于账本。将交易严格地按区块排序，允许每个节点验证交易更新是否在整个区块链网络上一致地应用。

In summary, phase three sees the blocks generated by the ordering service applied
consistently to the ledger. The strict ordering of transactions into blocks
allows each peer to validate that transaction updates are consistently applied
across the blockchain network.

要更深入地了解阶段三，请参阅[节点](../peers/peers.html#phase-3-validation-and-commit)主题。

For a deeper look at phase 3, refer back to the [Peers](../peers/peers.html#phase-3-validation-and-commit) topic.

## 排序服务实现

## Ordering service implementations

虽然当前可用的每个排序服务都以相同的方式处理交易和配置更新，但是仍然有几种不同的实现可以在排序服务节点之间就严格的交易排序达成共识。

While every ordering service currently available handles transactions and
configuration updates the same way, there are nevertheless several different
implementations for achieving consensus on the strict ordering of transactions
between ordering service nodes.

有关如何建立排序节点（无论该节点将在什么实现中使用）的信息，请参阅[关于建立排序节点](../orderer_deploy.html)的文档。

For information about how to stand up an ordering node (regardless of the
implementation the node will be used in), check out [our documentation on standing up an ordering node](../orderer_deploy.html).

* **Raft** (推荐)

* **Raft** (recommended)

  作为 v1.4.1 的新特性，Raft 是一种基于 [`etcd`](https://coreos.com/etcd/) 中 [Raft 协议](https://raft.github.io/raft.pdf)实现的崩溃容错（Crash Fault Tolerant，CFT）排序服务。Raft 遵循“领导者跟随者”模型，这个模型中，在每个通道上选举领导者节点，其决策被跟随者复制。Raft  排序服务会比基于 Kafka 的排序服务更容易设置和管理，它的设计允许不同的组织为分布式排序服务贡献节点。

  New as of v1.4.1, Raft is a crash fault tolerant (CFT) ordering service
  based on an implementation of [Raft protocol](https://raft.github.io/raft.pdf)
  in [`etcd`](https://coreos.com/etcd/). Raft follows a "leader and
  follower" model, where a leader node is elected (per channel) and its decisions
  are replicated by the followers. Raft ordering services should be easier to set
  up and manage than Kafka-based ordering services, and their design allows
  different organizations to contribute nodes to a distributed ordering service.

* **Kafka** (在 v2.0 中被废弃)

* **Kafka** (deprecated in v2.x)

  和基于 Raft 的排序类似，Apache Kafka 是一个 CFT 的实现，它使用“领导者和跟随者”节点配置。Kafka 利用一个 ZooKeeper 进行管理。基于 Kafka 的排序服务从 Fabric v1.0 开始就可以使用，但许多用户可能会发现管理 Kafka 集群的额外管理开销令人生畏或不受欢迎。

  Similar to Raft-based ordering, Apache Kafka is a CFT implementation that uses
  a "leader and follower" node configuration. Kafka utilizes a ZooKeeper
  ensemble for management purposes. The Kafka based ordering service has been
  available since Fabric v1.0, but many users may find the additional
  administrative overhead of managing a Kafka cluster intimidating or undesirable.

* **Solo** (在 v2.0 中被废弃)

* **Solo** (deprecated in v2.x)

  排序服务的 Solo 实现仅仅是为了测试，并且只包含了一个单一的排序节点。它已经被弃用了，可能会在将来的版本中被完全移除。既存的 Solo 用户应该迁移到一个单一节点的 Raft 网络获得同样的功能。

  The Solo implementation of the ordering service is intended for test only and
  consists only of a single ordering node.  It has been deprecated and may be
  removed entirely in a future release.  Existing users of Solo should move to
  a single node Raft network for equivalent function.

## Raft

有关如何配置 Raft 排序服务的信息，请参阅有关[配置 Raft 排序服务](../raft_configuration.html)的文档。

For information on how to configure a Raft ordering service, check out our
[documentation on configuring a Raft ordering service](../raft_configuration.html).

对于将用于生产网络的排序服务，Fabric 实现了使用“领导者跟随者”模型的 Raft 协议，领导者是在一个通道的排序节点中动态选择的（这个集合的节点称为“共识者集合（consenter set）”），领导者将信息复制到跟随者节点。Raft 被称为“崩溃容错”是因为系统可以承受节点的损失，包括领导者节点，前提是要剩余大量的排序节点（称为“法定人数（quorum）”）。换句话说，如果一个通道中有三个节点，它可以承受一个节点的丢失（剩下两个节点）。如果一个通道中有五个节点，则可以丢失两个节点（剩下三个节点）。

The go-to ordering service choice for production networks, the Fabric
implementation of the established Raft protocol uses a "leader and follower"
model, in which a leader is dynamically elected among the ordering
nodes in a channel (this collection of nodes is known as the "consenter set"),
and that leader replicates messages to the follower nodes. Because the system
can sustain the loss of nodes, including leader nodes, as long as there is a
majority of ordering nodes (what's known as a "quorum") remaining, Raft is said
to be "crash fault tolerant" (CFT). In other words, if there are three nodes in a
channel, it can withstand the loss of one node (leaving two remaining). If you
have five nodes in a channel, you can lose two nodes (leaving three
remaining nodes).

从它们提供给网络或通道的服务的角度来看，Raft 和现有的基于 Kafka 的排序服务（我们将在稍后讨论）是相似的。它们都是使用领导者跟随者模型设计的 CFT 排序服务。如果您是应用程序开发人员、智能合约开发人员或节点管理员，您不会注意到基于 Raft 和 Kafka 的排序服务之间的功能差异。然而，有几个主要的差异值得考虑，特别是如果你打算管理一个排序服务：

From the perspective of the service they provide to a network or a channel, Raft
and the existing Kafka-based ordering service (which we'll talk about later) are
similar. They're both CFT ordering services using the leader and follower
design. If you are an application developer, smart contract developer, or peer
administrator, you will not notice a functional difference between an ordering
service based on Raft versus Kafka. However, there are a few major differences worth
considering, especially if you intend to manage an ordering service:

* Raft 更容易设置。虽然 Kafka 有很多崇拜者，但即使是那些崇拜者也（通常）会承认部署 Kafka 集群及其 ZooKeeper 集群会很棘手，需要在 Kafka 基础设施和设置方面拥有高水平的专业知识。此外，使用 Kafka 管理的组件比使用 Raft 管理的组件多，这意味着有更多的地方会出现问题。Kafka 有自己的版本，必须与排序节点协调。**使用 Raft，所有内容都会嵌入到您的排序节点中**。

* Raft is easier to set up. Although Kafka has many admirers, even those
admirers will (usually) admit that deploying a Kafka cluster and its ZooKeeper
ensemble can be tricky, requiring a high level of expertise in Kafka
infrastructure and settings. Additionally, there are many more components to
manage with Kafka than with Raft, which means that there are more places where
things can go wrong. And Kafka has its own versions, which must be coordinated
with your orderers. **With Raft, everything is embedded into your ordering node**.

* Kafka 和 Zookeeper 并不是为了在大型网络上运行。Kafka 是 CFT，它应该在一组紧密的主机中运行。这意味着实际上，您需要有一个组织运行 Kafka 集群。考虑到这一点，在使用 Kafka 时，让不同组织运行排序节点不会给您带来太多的分散性，因为这些节点都将进入同一个由单个组织控制的 Kafka 集群。使用 Raft，每个组织都可以有自己的排序节点参与排序服务，从而形成一个更加分散的系统。

* Kafka and Zookeeper are not designed to be run across large networks. While
Kafka is CFT, it should be run in a tight group of hosts. This means that
practically speaking you need to have one organization run the Kafka cluster.
Given that, having ordering nodes run by different organizations when using Kafka
(which Fabric supports) doesn't give you much in terms of decentralization because
the nodes will all go to the same Kafka cluster which is under the control of a
single organization. With Raft, each organization can have its own ordering
nodes, participating in the ordering service, which leads to a more decentralized
system.

* Raft 是原生支持的，这就意味着用户需要自己去获得所需的镜像并且学习应该如何使用 Kafka 和 Zookeeper。同样，对 Kafka 相关问题的支持是通过 [Apache](https://kafka.apache.org/) 来处理的，Apache 是 Kafka 的开源开发者，而不是 Hyperledge Fabric。另一方面，Fabric Raft 的实现已经开发出来了，并将在 Fabric 开发人员社区及其支持设备中得到支持。

* Raft is supported natively, which means that users are required to get the requisite images and
learn how to use Kafka and ZooKeeper on their own. Likewise, support for
Kafka-related issues is handled through [Apache](https://kafka.apache.org/), the
open-source developer of Kafka, not Hyperledger Fabric. The Fabric Raft implementation,
on the other hand, has been developed and will be supported within the Fabric
developer community and its support apparatus.

* Kafka 使用一个服务器池（称为“Kafka 代理”），而且排序组织的管理员要指定在特定通道上使用多少个节点，但是 Raft 允许用户指定哪个排序节点要部署到哪个通道。通过这种方式，节点组织可以确保如果他们也拥有一个排序节点，那么这个节点将成为该通道的排序服务的一部分，而不是信任并依赖一个中心来管理 Kafka 节点。

* Where Kafka uses a pool of servers (called "Kafka brokers") and the admin of
the orderer organization specifies how many nodes they want to use on a
particular channel, Raft allows the users to specify which ordering nodes will
be deployed to which channel. In this way, peer organizations can make sure
that, if they also own an orderer, this node will be made a part of a ordering
service of that channel, rather than trusting and depending on a central admin
to manage the Kafka nodes.

* Raft 是向开发拜占庭容错（BFT）排序服务迈出的第一步。正如我们将看到的，Fabric 开发中的一些决策是由这个驱动的。如果你对 BFT 感兴趣，学习如何使用 Raft 应该可以慢慢过渡。

* Raft is the first step toward Fabric's development of a byzantine fault tolerant
(BFT) ordering service. As we'll see, some decisions in the development of
Raft were driven by this. If you are interested in BFT, learning how to use
Raft should ease the transition.

由于所有这些原因，在 Fabric v2.0 中，对于基于 Kafka 的排序服务正在被弃用。

For all of these reasons, support for Kafka-based ordering service is being
deprecated in Fabric v2.x.

注意：与 Solo 和 Kafka 类似，在向客户发送回执后 Raft 排序服务也可能会丢失交易。例如，如果领导者和跟随者提供回执时同时崩溃。因此，应用程序客户端应该监听节点上的交易提交事件，而不是检查交易的有效性。但是应该格外小心，要确保客户机也能优雅地容忍在配置的时间内没有交易提交超时。根据应用程序的不同，在这种超时情况下可能需要重新提交交易或收集一组新的背书。

Note: Similar to Solo and Kafka, a Raft ordering service can lose transactions
after acknowledgement of receipt has been sent to a client. For example, if the
leader crashes at approximately the same time as a follower provides
acknowledgement of receipt. Therefore, application clients should listen on peers
for transaction commit events regardless (to check for transaction validity), but
extra care should be taken to ensure that the client also gracefully tolerates a
timeout in which the transaction does not get committed in a configured timeframe.
Depending on the application, it may be desirable to resubmit the transaction or
collect a new set of endorsements upon such a timeout.

### Raft 概念

### Raft concepts

虽然 Raft 提供了许多与 Kafka 相同的功能（尽管它是一个简单易用的软件包）但它与 Kafka 的功能却大不相同，它向 Fabric 引入了许多新的概念，或改变了现有的概念。

While Raft offers many of the same features as Kafka --- albeit in a simpler and
easier-to-use package --- it functions substantially different under the covers
from Kafka and introduces a number of new concepts, or twists on existing
concepts, to Fabric.

**日志条目（Log entry）**。 Raft 排序服务中的主要工作单元是一个“日志条目”，该项的完整序列称为“日志”。如果大多数成员（换句话说是一个法定人数）同意条目及其顺序，则我们认为条目是一致的，然后将日志复制到不同排序节点上。

**Log entry**. The primary unit of work in a Raft ordering service is a "log
entry", with the full sequence of such entries known as the "log". We consider
the log consistent if a majority (a quorum, in other words) of members agree on
the entries and their order, making the logs on the various orderers replicated.

**共识者集合（Consenter set）**。主动参与给定通道的共识机制并接收该通道的日志副本的排序节点。这可以是所有可用的节点（在单个集群中或在多个集群中为系统通道提供服务），也可以是这些节点的一个子集。

**Consenter set**. The ordering nodes actively participating in the consensus
mechanism for a given channel and receiving replicated logs for the channel.
This can be all of the nodes available (either in a single cluster or in
multiple clusters contributing to the system channel), or a subset of those
nodes.

**有限状态机（Finite-State Machine，FSM）**。Raft 中的每个排序节点都有一个 FSM，它们共同用于确保各个排序节点中的日志序列是确定（以相同的顺序编写）。

**Finite-State Machine (FSM)**. Every ordering node in Raft has an FSM and
collectively they're used to ensure that the sequence of logs in the various
ordering nodes is deterministic (written in the same sequence).

**法定人数（Quorum）**。描述需要确认提案的最小同意人数。对于每个共识者集合，这是**大多数**节点。在具有五个节点的集群中，必须有三个节点可用，才能有一个法定人数。如果节点的法定人数因任何原因不可用，则排序服务集群对于通道上的读和写操作都不可用，并且不能提交任何新日志。

**Quorum**. Describes the minimum number of consenters that need to affirm a
proposal so that transactions can be ordered. For every consenter set, this is a
**majority** of nodes. In a cluster with five nodes, three must be available for
there to be a quorum. If a quorum of nodes is unavailable for any reason, the
ordering service cluster becomes unavailable for both read and write operations
on the channel, and no new logs can be committed.

**领导者（Leader）**。这并不是一个新概念，正如我们所说，Kafka 也使用了领导者，但是在任何给定的时间，通道的共识者集合都选择一个节点作为领导者，这一点非常重要（我们稍后将在 Raft 中描述这是如何发生的）。领导者负责接收新的日志条目，将它们复制到跟随者的排序节点，并在认为提交了某个条目时进行管理。这不是一种特殊**类型**的排序节点。它只是排序节点在某些时候可能扮演的角色，而不是由客观环境决定的其他角色。

**Leader**. This is not a new concept --- Kafka also uses leaders, as we've said ---
but it's critical to understand that at any given time, a channel's consenter set
elects a single node to be the leader (we'll describe how this happens in Raft
later). The leader is responsible for ingesting new log entries, replicating
them to follower ordering nodes, and managing when an entry is considered
committed. This is not a special **type** of orderer. It is only a role that
an orderer may have at certain times, and then not others, as circumstances
determine.

**跟随者（Follower）**。再次强调，这不是一个新概念，但是理解跟随者的关键是跟随者从领导者那里接收日志并复制它们，确保日志保持一致。我们将在关于领导者选举的部分中看到，跟随者也会收到来自领导者的“心跳”消息。如果领导者在一段可配置的时间内停止发送这些消息，跟随者将发起一次领导者选举，它们中的一个将当选为新的领导者。

**Follower**. Again, not a new concept, but what's critical to understand about
followers is that the followers receive the logs from the leader and
replicate them deterministically, ensuring that logs remain consistent. As
we'll see in our section on leader election, the followers also receive
"heartbeat" messages from the leader. In the event that the leader stops
sending those message for a configurable amount of time, the followers will
initiate a leader election and one of them will be elected the new leader.

### 交易流程中的 Raft

### Raft in a transaction flow

每个通道都在 Raft 协议的**单独**实例上运行，该协议允许每个实例选择不同的领导者。这种配置还允许在集群由不同组织控制的排序节点组成的用例中进一步分散服务。虽然所有 Raft 节点都必须是系统通道的一部分，但它们不一定必须是所有应用程序通道的一部分。通道创建者（和通道管理员）能够选择可用排序节点的子集，并根据需要添加或删除排序节点（只要一次只添加或删除一个节点）。

Every channel runs on a **separate** instance of the Raft protocol, which allows
each instance to elect a different leader. This configuration also allows
further decentralization of the service in use cases where clusters are made up
of ordering nodes controlled by different organizations. While all Raft nodes
must be part of the system channel, they do not necessarily have to be part of
all application channels. Channel creators (and channel admins) have the ability
to pick a subset of the available orderers and to add or remove ordering nodes
as needed (as long as only a single node is added or removed at a time).

虽然这种配置以冗余心跳消息和线程的形式产生了更多的开销，但它为 BFT 奠定了必要的基础。

While this configuration creates more overhead in the form of redundant heartbeat
messages and goroutines, it lays necessary groundwork for BFT.

在 Raft 中，交易（以提案或配置更新的形式）由接收交易的排序节点自动路由到该通道的当前领导者。这意味着 Peer 节点和应用程序在任何特定时间都不需要知道谁是领导者节点。只有排序节点需要知道。

In Raft, transactions (in the form of proposals or configuration updates) are
automatically routed by the ordering node that receives the transaction to the
current leader of that channel. This means that peers and applications do not
need to know who the leader node is at any particular time. Only the ordering
nodes need to know.

当排序节点检查完成后，将按照我们交易流程的第二阶段的描述，对交易进行排序、打包成区块、协商并分发。

When the orderer validation checks have been completed, the transactions are
ordered, packaged into blocks, consented on, and distributed, as described in
phase two of our transaction flow.

### 架构说明

### Architectural notes

#### Raft 是如何选举领导者的

#### How leader election works in Raft

尽管选举领导者的过程发生在排序节点的内部过程中，但是值得注意一下这个过程是如何工作的。

Although the process of electing a leader happens within the orderer's internal
processes, it's worth noting how the process works.

节点总是处于以下三种状态之一：跟随者、候选人或领导者。所有节点最初都是作为**跟随者**开始的。在这种状态下，他们可以接受来自领导者的日志条目（如果其中一个已经当选），或者为领导者投票。如果在一段时间内没有接收到日志条目或心跳（例如，5秒），节点将自己提升到**候选**状态。在候选状态中，节点从其他节点请求选票。如果候选人获得法定人数的选票，那么他就被提升为领导者。领导者必须接受新的日志条目并将其复制到跟随者。

Raft nodes are always in one of three states: follower, candidate, or leader.
All nodes initially start out as a **follower**. In this state, they can accept
log entries from a leader (if one has been elected), or cast votes for leader.
If no log entries or heartbeats are received for a set amount of time (for
example, five seconds), nodes self-promote to the **candidate** state. In the
candidate state, nodes request votes from other nodes. If a candidate receives a
quorum of votes, then it is promoted to a **leader**. The leader must accept new
log entries and replicate them to the followers.

要了解领导者选举过程的可视化表示，请查看[数据的秘密生活](http://thesecretlivesofdata.com/raft/)。

For a visual representation of how the leader election process works, check out
[The Secret Lives of Data](http://thesecretlivesofdata.com/raft/).

#### 快照

#### Snapshots

如果一个排序节点宕机，它如何在重新启动时获得它丢失的日志？

If an ordering node goes down, how does it get the logs it missed when it is
restarted?

虽然可以无限期地保留所有日志，但是为了节省磁盘空间，Raft 使用了一个称为“快照”的过程，在这个过程中，用户可以定义日志中要保留多少字节的数据。这个数据量将决定区块的数量（这取决于区块中的数据量。注意，快照中只存储完整的区块）。

While it's possible to keep all logs indefinitely, in order to save disk space,
Raft uses a process called "snapshotting", in which users can define how many
bytes of data will be kept in the log. This amount of data will conform to a
certain number of blocks (which depends on the amount of data in the blocks.
Note that only full blocks are stored in a snapshot).

例如，假设滞后副本 `R1` 刚刚重新连接到网络。它最新的区块是`100`。领导者 `L` 位于第 `196` 块，并被配置为快照20个区块。`R1` 因此将从 `L` 接收区块 `180`，然后为区块 `101` 到 `180` 区块 `分发` 请求。然后`180` 到 `196` 的区块将通过正常 Raft 协议复制到 `R1`。

For example, let's say lagging replica `R1` was just reconnected to the network.
Its latest block is `100`. Leader `L` is at block `196`, and is configured to
snapshot at amount of data that in this case represents 20 blocks. `R1` would
therefore receive block `180` from `L` and then make a `Deliver` request for
blocks `101` to `180`. Blocks `180` to `196` would then be replicated to `R1`
through the normal Raft protocol.

### Kafka (在 v2.0中被弃用)

### Kafka (deprecated in v2.x)

Fabric 支持的另一个容错崩溃排序服务是对 Kafka 分布式流平台的改写，将其用作排序节点集群。您可以在 [Apache Kafka 网站](https://kafka.apache.org/intro)上阅读更多关于 Kafka 的信息，但是在更高的层次上，Kafka 使用与 Raft 相同概念上的“领导者跟随者”配置，其中交易（Kafka 称之为“消息”）从领导者节点复制到跟随者节点。就像 Raft 一样，在领导者节点宕机的情况下，一个跟随者成为领导者，排序可以继续，以此来确保容错。

The other crash fault tolerant ordering service supported by Fabric is an
adaptation of a Kafka distributed streaming platform for use as a cluster of
ordering nodes. You can read more about Kafka at the [Apache Kafka Web site](https://kafka.apache.org/intro),
but at a high level, Kafka uses the same conceptual "leader and follower"
configuration used by Raft, in which transactions (which Kafka calls "messages")
are replicated from the leader node to the follower nodes. In the event the
leader node goes down, one of the followers becomes the leader and ordering can
continue, ensuring fault tolerance, just as with Raft.

Kafka 集群的管理，包括任务协调、集群成员、访问控制和控制器选择等，由 ZooKeeper 集合及其相关 API 来处理。

The management of the Kafka cluster, including the coordination of tasks,
cluster membership, access control, and controller election, among others, is
handled by a ZooKeeper ensemble and its related APIs.

Kafka 集群和 ZooKeeper 集合的设置是出了名的棘手，所以我们的文档假设您对 Kafka 和 ZooKeeper 有一定的了解。如果您决定在不具备此专业知识的情况下使用 Kafka，那么在试验基于 Kafka 的排序服务之前，至少应该完成 [Kafka 快速入门指南](https://kafka.apache.org/quickstart)的前六个步骤。您还可以参考 [这个示例配置文件](https://github.com/hyperledger/fabric/blob/release-1.1/bddtests/dc-orderer-kafka.yml) 来简要解释 Kafka 和 ZooKeeper 的合理默认值。

Kafka clusters and ZooKeeper ensembles are notoriously tricky to set up, so our
documentation assumes a working knowledge of Kafka and ZooKeeper. If you decide
to use Kafka without having this expertise, you should complete, *at a minimum*,
the first six steps of the [Kafka Quickstart guide](https://kafka.apache.org/quickstart) before experimenting with the
Kafka-based ordering service. You can also consult
[this sample configuration file](https://github.com/hyperledger/fabric/blob/release-1.1/bddtests/dc-orderer-kafka.yml)
for a brief explanation of the sensible defaults for Kafka and ZooKeeper.

要了解如何启动基于 Kafka 的排序服务，请查看我们关于 [Kafka 的文档](../kafka.html)。

To learn how to bring up a Kafka-based ordering service, check out [our documentation on Kafka](../kafka.html).
