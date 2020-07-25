术语表
===========================
Glossary
===========================

专业术语很重要，因为所有 Hyperledger Fabric 项目的用户和开发人员都要一致的理解我们所说的每个术语的含义。比如什么是链码。本文档将会按需引用这些术语，如果你愿意的话也可以阅读整个文档，这会非常有启发！

Terminology is important, so that all Hyperledger Fabric users and developers
agree on what we mean by each specific term. What is a smart contract for
example. The documentation will reference the glossary as needed, but feel free
to read the entire thing in one sitting if you like; it's pretty enlightening!

.. _锚节点:

.. _Anchor-Peer:

锚节点
-----------

Anchor Peer
-----------

gossip 用来确保在不同组织中的 Peer 节点能够知道彼此。

Used by gossip to make sure peers in different organizations know about each other.

当提交一个包含锚节点更新的配置区块时，Peer 节点会联系锚节点并从它们那里获取该节点知道的所有 Peer 节点的信息。一旦每个组织中至少有一个 Peer 节点已经联系到一个或多个锚节点的话，锚节点就会知道这个通道中的每个 Peer 节点。因为 gossip 通信是不变的，并且 Peer 节点总是会要求告知他们不知道的 Peer 节点，这样就建立起了一个通道成员的通用视图。

When a configuration block that contains an update to the anchor peers is committed,
peers reach out to the anchor peers and learn from them about all of the peers known
to the anchor peer(s). Once at least one peer from each organization has contacted an
anchor peer, the anchor peer learns about every peer in the channel. Since gossip
communication is constant, and because peers always ask to be told about the existence
of any peer they don't know about, a common view of membership can be established for
a channel.

比如，我们可以假设在通道中有三个组织：``A``、``B``、``C``，有一个为组织 ``C`` 定义的锚节点 ``peer0.orgC``。当 ``peer1.orgA`` （来自组织 ``A``）联系 ``peer0.orgC`` 的时候，它会告诉 ``peer0.orgC`` 关于 ``peer0.orgA`` 的信息。然后当 ``peer1.orgB`` 联系 ``peer0.orgC`` 的时候，后者会告诉前者关于 ``peer0.orgA`` 的信息。之后，组织 ``A`` 和 ``B`` 就可以开始直接地交换成员信息而不需要任何来自 ``peer0.orgC`` 的帮助了。

For example, let's assume we have three organizations --- ``A``, ``B``, ``C`` --- in the channel
and a single anchor peer --- ``peer0.orgC`` --- defined for organization ``C``.
When ``peer1.orgA`` (from organization ``A``) contacts ``peer0.orgC``, it will
tell ``peer0.orgC`` about ``peer0.orgA``. And when at a later time ``peer1.orgB``
contacts ``peer0.orgC``, the latter would tell the former about ``peer0.orgB``.
From that point forward, organizations ``A`` and ``B`` would start exchanging
membership information directly without any assistance from ``peer0.orgC``.

由于组织间的通信要基于 gossip 来工作，所以在通道配置中至少要定义一个锚节点。为了高可用和冗余，非常建议每个组织提供他们自己的一组锚节点。

As communication across organizations depends on gossip in order to work, there must
be at least one anchor peer defined in the channel configuration. It is strongly
recommended that every organization provides its own set of anchor peers for high
availability and redundancy.

.. _术语表_ACL:

.. _glossary_ACL:

ACL
---

ACL（Access Control List，访问控制列表）将特定节点资源（例如系统链代码 API 或事件服务）的访问与 策略_ （指定需要多少和哪些类型的组织或角色）关联在一起。ACL 是通道配置的一部分。因此，它会保留在通道的配置区块中，并可使用标准的配置更新机制进行更新。

An ACL, or Access Control List, associates access to specific peer
resources (such as system chaincode APIs or event services) to a Policy_
(which specifies how many and what types of organizations or roles are
required). The ACL is part of a channel's configuration. It is therefore
persisted in the channel's configuration blocks, and can be updated using the
standard configuration update mechanism.

ACL 被组织为键值对列表的格式，其中键标识我们希望控制其访问的资源，值标识允许访问它的通道策略（组）。 例如， ``lscc/GetDeploymentSpec: /Channel/Application/Readers`` 定义对生命周期链代码 ``GetDeploymentSpec`` API（资源）的访问可由满足 ``/Channel/Application/Readers`` 策略的身份访问。

An ACL is formatted as a list of key-value pairs, where the key identifies
the resource whose access we wish to control, and the value identifies the
channel policy (group) that is allowed to access it. For example
``lscc/GetDeploymentSpec: /Channel/Application/Readers``
defines that the access to the life cycle chaincode ``GetDeploymentSpec`` API
(the resource) is accessible by identities which satisfy the
``/Channel/Application/Readers`` policy.

``configtx.yaml`` 文件中提供了一组默认 ACL，configtxgen 使用该文件来构建通道配置。可以在 ``configtx.yaml`` 的顶级 “Application” 部分中设置默认值，也可以在 “Profiles” 部分中按每个配置文件覆盖默认值。

A set of default ACLs is provided in the ``configtx.yaml`` file which is
used by configtxgen to build channel configurations. The defaults can be set
in the top level "Application" section of ``configtx.yaml`` or overridden
on a per profile basis in the "Profiles" section.

.. _区块:

.. _Block:

区块
-----

Block
-----

.. figure:: ./glossary/glossary.block.png
   :scale: 50 %
   :align: right
   :figwidth: 40 %
   :alt: 区块

.. figure:: ./glossary/glossary.block.png
   :scale: 50 %
   :align: right
   :figwidth: 40 %
   :alt: A Block

   区块 B1 是连接到区块 B0 的。区块 B2 是连接到区块 B1 的。

   Block B1 is linked to block B0. Block B2 is linked to block B1.

=======

一个区块包含了一组有序的交易。他们以加密的方式与前一个区块相连，并且他们也会跟后续的区块相连。在这个链条中的第一个区块被称为 **创世区块**。区块是由排序服务创建的，并且由 Peer节点 进行验证和提交。

A block contains an ordered set of transactions. It is cryptographically linked
to the preceding block, and in turn it is linked to be subsequent blocks. The
first block in such a chain of blocks is called the **genesis block**. Blocks
are created by the ordering service, and then validated and committed by peers.

.. _链:


链
-----

.. _Chain:

.. figure:: ./glossary/glossary.blockchain.png
   :scale: 75 %
   :align: right
   :figwidth: 40 %
   :alt: Blockchain


   区块链 B 包含了区块 0, 1, 2

Chain
-----

=======

.. figure:: ./glossary/glossary.blockchain.png
   :scale: 75 %
   :align: right
   :figwidth: 40 %
   :alt: Blockchain

账本的链是交易区块经过“哈希连接”结构化的交易日志。Peer 节点从排序服务收到交易区块，基于背书策略和并发冲突来标注区块的交易为有效或者无效状态，并且将区块追加到 Peer 节点文件系统的哈希链中。

   Blockchain B contains blocks 0, 1, 2.

.. _链码:

=======

链码
---------

The ledger's chain is a transaction log structured as hash-linked blocks of
transactions. Peers receive blocks of transactions from the ordering service, mark
the block's transactions as valid or invalid based on endorsement policies and
concurrency violations, and append the block to the hash chain on the peer's
file system.

请查看 智能合约_ 。

.. _chaincode:

.. _通道:

Chaincode
---------

通道
-------

See Smart-Contract_.

.. figure:: ./glossary/glossary.channel.png
   :scale: 30 %
   :align: right
   :figwidth: 40 %
   :alt: A Channel

.. _Channel:

   通道 C 连接了应用程序 A1，Peer 节点 P2 和排序服务 01。

Channel
-------

=======

.. figure:: ./glossary/glossary.channel.png
   :scale: 30 %
   :align: right
   :figwidth: 40 %
   :alt: A Channel

通道是基于数据隔离和保密构建的一个私有区块链。特定通道的账本在该通道中的所有 Peer 节点共享，交易方必须通过该通道的正确验证才能与账本进行交互。通道是由“ 配置区块_ ”来定义的。

   Channel C connects application A1, peer P2 and ordering service O1.

.. _提交:

=======

提交
------

A channel is a private blockchain overlay which allows for data
isolation and confidentiality. A channel-specific ledger is shared across the
peers in the channel, and transacting parties must be authenticated to
a channel in order to interact with it.  Channels are defined by a
Configuration-Block_.

通道中每个“ Peer节点_ ”都会验证交易的有序区块，然后将区块提交（写入或追加）到该通道上“ 账本_ ”的各个副本。Peer 节点也会标记每个区块中的每笔交易的状态为有效或者无效。


.. _并发控制版本检查:

.. _Commit:

并发控制版本检查
---------------------------------

Commit
------

并发控制版本检查（Concurrency Control Version Check，CCVC）是保持通道中各节点间状态同步的一种方法。Peer 节点并行的执行交易，在交易提交至账本之前，节点会检查交易在执行期间读到的数据是否被修改。如果读取的数据在执行和提交之间被改变，就会引发 CCVC 冲突，该交易就会在账本中被标记为无效，而且值不会更新到状态数据库中。

Each Peer_ on a channel validates ordered blocks of
transactions and then commits (writes/appends) the blocks to its replica of the
channel Ledger_. Peers also mark each transaction in each block
as valid or invalid.

.. _配置区块:

.. _Concurrency-Control-Version-Check:

配置区块
-------------------

Concurrency Control Version Check
---------------------------------

包含为系统链（排序服务）或通道定义成员和策略的配置数据。对某个通道或整个网络的配置修改（比如，成员离开或加入）都将导致生成一个新的配置区块并追加到适当的链上。这个配置区块会包含创始区块的内容，再加上增量。

Concurrency Control Version Check is a method of keeping ledger state in sync across
peers on a channel. Peers execute transactions in parallel, and before committing
to the ledger, peers check whether the state read at the time the transaction was executed
has been modified. If the data read for the transaction has changed between execution time and
commit time, then a Concurrency Control Version Check violation has
occurred, and the transaction is marked as invalid on the ledger and values
are not updated in the state database.

.. _共识:

.. _Configuration-Block:

共识
---------

Configuration Block
-------------------

贯串交易流程的一个广泛的概念，用于对区块中的交易生成一致的顺序和确保其正确性。

Contains the configuration data defining members and policies for a system
chain (ordering service) or channel. Any configuration modifications to a
channel or overall network (e.g. a member leaving or joining) will result
in a new configuration block being appended to the appropriate chain. This
block will contain the contents of the genesis block, plus the delta.

.. _共识者集合:

.. _Consensus:

共识者集合
-------------

Consensus
---------

Raft 排序服务中，在一个通道的共识机制中会有多个活动的排序节点参与其中。如果其他排序节点存在于系统通道，但是没有加入通道，它就不属于这个通道的共识者集合。

A broader term overarching the entire transactional flow, which serves to generate
an agreement on the order and to confirm the correctness of the set of transactions
constituting a block.

.. _联盟:

.. _Consenter-Set:

联盟
----------

Consenter set
-------------

联盟是区块链网络上非定序的组织集合。这些是组建和加入通道及拥有节点的组织。虽然区块链网络可以有多个联盟，但大多数区块链网络都只有一个联盟。在通道创建时，添加到通道的所有组织都必须是联盟的一部分。但是，未在联盟中定义的组织可能会被添加到现有通道中。

In a Raft ordering service, these are the ordering nodes actively participating
in the consensus mechanism on a channel. If other ordering nodes exist on the
system channel, but are not a part of a channel, they are not part of that
channel's consenter set.

.. _链码定义:

.. _Consortium:

链码定义
--------------------

Consortium
----------

链码定义用于组织在将链码应用在通道之前协商链码参数。每个想使用链码背书交易或者查询账本的通道成员都需要为他们的组织批准链码定义。一旦有足够多的通道成员批准了链码定义，使其满足了生命周期背书策略（默认是通道中的多数组织），链码定义就可以提交到通道中了。定义提交之后，链码的第一个调用（或者，必要的话调用 Init 方法）就会在通道上启动链码。

A consortium is a collection of non-orderer organizations on the blockchain
network. These are the organizations that form and join channels and that own
peers. While a blockchain network can have multiple consortia, most blockchain
networks have a single consortium. At channel creation time, all organizations
added to the channel must be part of a consortium. However, an organization
that is not defined in a consortium may be added to an existing channel.

.. _动态成员:

.. _Chaincode-definition:

动态成员
------------------

Chaincode definition
--------------------

Hyperledger Fabric 支持成员、节点、排序服务节点的添加或移除，而不影响整个网络的操作性。当业务关系调整或因各种原因需添加或移除实体时，动态成员至关重要。

A chaincode definition is used by organizations to agree on the parameters of a
chaincode before it can be used on a channel. Each channel member that wants to
use the chaincode to endorse transactions or query the ledger needs to approve
a chaincode definition for their organization. Once enough channel members have
approved a chaincode definition to meet the Lifecycle Endorsement policy (which
is set to a majority of organizations in the channel by default), the chaincode
definition can be committed to the channel. After the definition is committed,
the first invoke of the chaincode (or, if requested, the execution of the Init
function) will start the chaincode on the channel.

.. _背书:

.. _Dynamic-Membership:

背书
-----------

Dynamic Membership
------------------

背书是指特定节点执行链码交易并返回一个提案响应给客户端应用的过程。提案响应包含链码执行后返回的消息、结果（读写集）和事件，同时也包含证明该节点执行链码的签名。链码应用具有相应的背书策略，其中指定了背书节点。

Hyperledger Fabric supports the addition/removal of members, peers, and ordering service
nodes, without compromising the operationality of the overall network. Dynamic
membership is critical when business relationships adjust and entities need to
be added/removed for various reasons.

.. _背书策略:

.. _Endorsement:

背书策略
------------------

Endorsement
-----------

定义了通道上必须执行依赖于特定链码的交易的节点，和必要的组合响应（背书）。背书策略可指定特定链码应用交易背书的最小背书节点数、百分比或全部节点。背书策略可以基于应用程序和节点对于抵御（有意无意）不良行为的期望水平来组织管理。提交的交易在被执行节点标记成有效前，必须符合背书策略。

Refers to the process where specific peer nodes execute a chaincode transaction and return
a proposal response to the client application. The proposal response includes the
chaincode execution response message, results (read set and write set), and events,
as well as a signature to serve as proof of the peer's chaincode execution.
Chaincode applications have corresponding endorsement policies, in which the endorsing
peers are specified.

安装和实例化交易时，也需要一个明确的背书策略。

.. _Endorsement-policy:

.. _跟随者:

Endorsement policy
------------------

跟随者
--------

Defines the peer nodes on a channel that must execute transactions attached to a
specific chaincode application, and the required combination of responses (endorsements).
A policy could require that a transaction be endorsed by a minimum number of
endorsing peers, a minimum percentage of endorsing peers, or by all endorsing
peers that are assigned to a specific chaincode application. Policies can be
curated based on the application and the desired level of resilience against
misbehavior (deliberate or not) by the endorsing peers. A transaction that is submitted
must satisfy the endorsement policy before being marked as valid by committing peers.

在基于领导者的共识协议中，比如 Raft，有一些节点复制领导者生产的日志条目。在 Raft中，跟随者也接受领导者的“心跳”信息。当领导者停止发送这些信息达到配置中的时间是，跟随者会初始化一个领导者选举并选举出一个领导者。

.. _Follower:

.. _初始区块:

Follower
--------

初始区块
-------------

In a leader based consensus protocol, such as Raft, these are the nodes which
replicate log entries produced by the leader. In Raft, the followers also receive
"heartbeat" messages from the leader. In the event that the leader stops sending
those message for a configurable amount of time, the followers will initiate a
leader election and one of them will be elected leader.

初始化排序服务的的配置区块，也是链上的第一个区块。

.. _Genesis-Block:

.. _Gossip协议:

Genesis Block
-------------

Gossip 协议
---------------

The configuration block that initializes the ordering service, or serves as the
first block on a chain.

Gossip数据传输协议有三项功能：
1）管理节点发现和通道成员；
2）在通道上的所有节点间广播账本数据；
3）在通道上的所有节点间同步账本数据。
详情参考 :doc:`Gossip <gossip>` 话题。

.. _Gossip-Protocol:

.. _Fabric-ca:

Gossip Protocol
---------------

Hyperledger Fabric CA
---------------------

The gossip data dissemination protocol performs three functions:
1) manages peer discovery and channel membership;
2) disseminates ledger data across all peers on the channel;
3) syncs ledger state across all peers on the channel.
Refer to the :doc:`Gossip <gossip>` topic for more details.

Hyperledger Fabric CA 是默认的证书授权组件，用于向网络成员组织和他们的用户发行基于 PKI 的证书。CA 向每一个成员发行一个根证书（rootCert）并向每一个授权的用户发行一个注册证书（ECert）。

.. _Fabric-ca:

.. _初始化:

Hyperledger Fabric CA
---------------------

初始化
--------

Hyperledger Fabric CA is the default Certificate Authority component, which
issues PKI-based certificates to network member organizations and their users.
The CA issues one root certificate (rootCert) to each member and one enrollment
certificate (ECert) to each authorized user.

初始化链码应用的方法。所有的链码都需要有一个 Init 方法。默认情况下，该方法不会被执行。但是你可以在链码定义中请求执行 Init 方法来初始化链码。

.. _Init:

安装
-------

Init
----

将链码放到 Peer 节点文件系统的过程。

A method to initialize a chaincode application. All chaincodes need to have an
an Init function. By default, this function is never executed. However you can
use the chaincode definition to request the execution of the Init function in
order to initialize the chaincode.

实例化
-----------

Install
-------

在特定通道上启动和初始化链码应用的过程。实例化完成后，装有链码的节点可以接受链码调用。

The process of placing a chaincode on a peer's file system.

**NOTE**: *This method i.e. Instantiate was used in the 1.4.x and older versions of the chaincode
lifecycle. For the current procedure used to start a chaincode on a channel with
the new Fabric chaincode lifecycle introduced as part of Fabric v2.0,
see Chaincode-definition_.*

Instantiate
-----------

.. _Invoke:

The process of starting and initializing a chaincode application on a specific
channel. After instantiation, peers that have the chaincode installed can accept
chaincode invocations.

Invoke
------

**NOTE**: *This method i.e. Instantiate was used in the 1.4.x and older versions of the chaincode
lifecycle. For the current procedure used to start a chaincode on a channel with
the new Fabric chaincode lifecycle introduced as part of Fabric v2.0,
see Chaincode-definition_.*

Used to call chaincode functions. A client application invokes chaincode by
sending a transaction proposal to a peer. The peer will execute the chaincode
and return an endorsed proposal response to the client application. The client
application will gather enough proposal responses to satisfy an endorsement policy,
and will then submit the transaction results for ordering, validation, and commit.
The client application may choose not to submit the transaction results. For example
if the invoke only queried the ledger, the client application typically would not
submit the read-only transaction, unless there is desire to log the read on the ledger
for audit purpose. The invoke includes a channel identifier, the chaincode function to
invoke, and an array of arguments.

.. _Invoke:

用于调用链码内的函数。客户端应用通过向节点发送交易提案来调用链码。节点会执行链码并向客户端应用返回一个背书提案。客户端应用会收集充足的提案响应来判断是否符合背书策略，之后再将交易结果递交到排序、验证和提交。客户端应用可以选择不提交交易结果。比如，调用只查询账本，通常情况下，客户端应用是不会提交这种只读性交易的，除非基于审计目的，需要记录访问账本的日志。调用包含了通道标识符，调用的链码函数，以及一个包含参数的数组。

Invoke
------


Used to call chaincode functions. A client application invokes chaincode by
sending a transaction proposal to a peer. The peer will execute the chaincode
and return an endorsed proposal response to the client application. The client
application will gather enough proposal responses to satisfy an endorsement policy,
and will then submit the transaction results for ordering, validation, and commit.
The client application may choose not to submit the transaction results. For example
if the invoke only queried the ledger, the client application typically would not
submit the read-only transaction, unless there is desire to log the read on the ledger
for audit purpose. The invoke includes a channel identifier, the chaincode function to
invoke, and an array of arguments.

.. _Leader

.. _Leader:

Leader
------

In a leader based consensus protocol, like Raft, the leader is responsible for
ingesting new log entries, replicating them to follower ordering nodes, and
managing when an entry is considered committed. This is not a special **type**
of orderer. It is only a role that an orderer may have at certain times, and
then not others, as circumstances determine.

.. _Leading-Peer:

Leading Peer
------------

Each Organization_ can own multiple peers on each channel that
they subscribe to. One or more of these peers should serve as the leading peer
for the channel, in order to communicate with the network ordering service on
behalf of the organization. The ordering service delivers blocks to the
leading peer(s) on a channel, who then distribute them to other peers within
the same organization.

每一个“组织 Organization_ ”在其订阅的通道上可以拥有多个节点，其中一个节点会作为通道的主导节点，代表该成员与网络排序服务节点通信。排序服务将区块传递给通道上的主导节点，主导节点再将此区块分发给同一成员集群下的其他节点。

.. _Ledger:

.. _Ledger:

Ledger
------

Ledger
------

.. figure:: ./glossary/glossary.ledger.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Ledger

.. figure:: ./glossary/glossary.ledger.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Ledger

   A Ledger, 'L'

   A Ledger, 'L'



A ledger consists of two distinct, though related, parts -- a "blockchain" and
the "state database", also known as "world state". Unlike other ledgers,
blockchains are **immutable** -- that is, once a block has been added to the
chain, it cannot be changed. In contrast, the "world state" is a database
containing the current value of the set of key-value pairs that have been added,
modified or deleted by the set of validated and committed transactions in the
blockchain.

A ledger consists of two distinct, though related, parts -- a "blockchain" and
the "state database", also known as "world state". Unlike other ledgers,
blockchains are **immutable** -- that is, once a block has been added to the
chain, it cannot be changed. In contrast, the "world state" is a database
containing the current value of the set of key-value pairs that have been added,
modified or deleted by the set of validated and committed transactions in the
blockchain.

It's helpful to think of there being one **logical** ledger for each channel in
the network. In reality, each peer in a channel maintains its own copy of the
ledger -- which is kept consistent with every other peer's copy through a
process called **consensus**. The term **Distributed Ledger Technology**
(**DLT**) is often associated with this kind of ledger -- one that is logically
singular, but has many identical copies distributed across a set of network
nodes (peers and the ordering service).

账本由两个不同但相关的部分组成——“区块链”和“状态数据库”，也称为“世界状态”。与其他账本不同，区块链是 **不可变** 的——也就是说，一旦将一个区块添加到链中，它就无法更改。相反，“世界状态”是一个数据库，其中包含已由区块链中的一组经过验证和提交的交易添加，修改或删除的键值对集合的当前值。

.. _Log-entry:

It's helpful to think of there being one **logical** ledger for each channel in
the network. In reality, each peer in a channel maintains its own copy of the
ledger -- which is kept consistent with every other peer's copy through a
process called **consensus**. The term **Distributed Ledger Technology**
(**DLT**) is often associated with this kind of ledger -- one that is logically
singular, but has many identical copies distributed across a set of network
nodes (peers and the ordering service).

Log entry
---------

认为网络中每个通道都有一个 **逻辑** 账本是有帮助的。实际上，通道中的每个节点都维护着自己的账本副本——通过称为共识的过程与所有其他节点的副本保持一致。术语 **分布式账本技术** （DLT）通常与这种账本相关联——这种账本在逻辑上是单一的，但在一组网络节点（节点和排序服务）上分布有许多相同的副本。

The primary unit of work in a Raft ordering service, log entries are distributed
from the leader orderer to the followers. The full sequence of such entries known
as the "log". The log is considered to be consistent if all members agree on the
entries and their order.

.. _Log-entry

.. _Member:

Log entry
---------

Member
------

The primary unit of work in a Raft ordering service, log entries are distributed
from the leader orderer to the followers. The full sequence of such entries known
as the "log". The log is considered to be consistent if all members agree on the
entries and their order.

See Organization_.

.. _Member:

.. _MSP:

Member
------

Membership Service Provider
---------------------------

See Organization_.

.. figure:: ./glossary/glossary.msp.png
   :scale: 35 %
   :align: right
   :figwidth: 25 %
   :alt: An MSP

参见 Organization_ 。

   An MSP, 'ORG.MSP'

.. _MSP:


Membership Service Provider
---------------------------

The Membership Service Provider (MSP) refers to an abstract component of the
system that provides credentials to clients, and peers for them to participate
in a Hyperledger Fabric network. Clients use these credentials to authenticate
their transactions, and peers use these credentials to authenticate transaction
processing results (endorsements). While strongly connected to the transaction
processing components of the systems, this interface aims to have membership
services components defined, in such a way that alternate implementations of
this can be smoothly plugged in without modifying the core of transaction
processing components of the system.

.. figure:: ./glossary/glossary.msp.png
   :scale: 35 %
   :align: right
   :figwidth: 25 %
   :alt: An MSP

.. _Membership-Services:

   An MSP, 'ORG.MSP'

Membership Services
-------------------


Membership Services authenticates, authorizes, and manages identities on a
permissioned blockchain network. The membership services code that runs in peers
and orderers both authenticates and authorizes blockchain operations.  It is a
PKI-based implementation of the Membership Services Provider (MSP) abstraction.

The Membership Service Provider (MSP) refers to an abstract component of the
system that provides credentials to clients, and peers for them to participate
in a Hyperledger Fabric network. Clients use these credentials to authenticate
their transactions, and peers use these credentials to authenticate transaction
processing results (endorsements). While strongly connected to the transaction
processing components of the systems, this interface aims to have membership
services components defined, in such a way that alternate implementations of
this can be smoothly plugged in without modifying the core of transaction
processing components of the system.

.. _Ordering-Service:

成员服务提供者（MSP）是指为客户端和节点加入超级账本Fabric网络，提供证书的系统抽象组件。客户端用证书来认证他们的交易；节点用证书认证交易处理结果（背书）。该接口与系统的交易处理组件密切相关，旨在定义成员服务组件，以这种方式可选实现平滑接入，而不用修改系统的交易处理组件核心。

Ordering Service
----------------

.. _Membership-Services:

Also known as **orderer**. A defined collective of nodes that orders transactions into a block
and then distributes blocks to connected peers for validation and commit. The ordering service
exists independent of the peer processes and orders transactions on a first-come-first-serve basis
for all channels on the network.  It is designed to support pluggable implementations beyond the
out-of-the-box Kafka and Raft varieties. It is a common binding for the overall network; it
contains the cryptographic identity material tied to each Member_.

Membership Services
-------------------

.. _Organization:

Membership Services authenticates, authorizes, and manages identities on a
permissioned blockchain network. The membership services code that runs in peers
and orderers both authenticates and authorizes blockchain operations.  It is a
PKI-based implementation of the Membership Services Provider (MSP) abstraction.

Organization
------------

成员服务在许可的区块链网络上做认证、授权和身份管理。运行于节点和排序服务的成员服务代码均会参与认证和授权区块链操作。它是基于PKI的抽象成员服务提供者（MSP）的实现。

=====

.. _Ordering-Service:


Ordering Service
----------------

.. figure:: ./glossary/glossary.organization.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: An Organization

Also known as **orderer**. A defined collective of nodes that orders transactions into a block
and then distributes blocks to connected peers for validation and commit. The ordering service
exists independent of the peer processes and orders transactions on a first-come-first-serve basis
for all channels on the network.  It is designed to support pluggable implementations beyond the
out-of-the-box Kafka and Raft varieties. It is a common binding for the overall network; it
contains the cryptographic identity material tied to each Member_.

   An organization, 'ORG'

预先定义好的一组节点，将交易排序放入区块。排序服务独立于节点流程之外，并以先到先得的方式为网络上所有通道做交易排序。交易排序支持可插拔实现，目前默认实现了SOLO和Kafka。排序服务是整个网络的公用绑定，包含与每个“成员 Member_ ”相关的加密材料。


.. _Organization:

Also known as "members", organizations are invited to join the blockchain network
by a blockchain network provider. An organization is joined to a network by adding its
Membership Service Provider (MSP_) to the network. The MSP defines how other members of the
network may verify that signatures (such as those over transactions) were generated by a valid
identity, issued by that organization. The particular access rights of identities within an MSP
are governed by policies which are also agreed upon when the organization is joined to the
network. An organization can be as large as a multi-national corporation or as small as an
individual. The transaction endpoint of an organization is a Peer_. A collection of organizations
form a Consortium_. While all of the organizations on a network are members, not every organization
will be part of a consortium.

Organization
------------

.. _Peer:

=====

Peer
----


.. figure:: ./glossary/glossary.peer.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Peer

.. figure:: ./glossary/glossary.organization.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: An Organization

   A peer, 'P'

   An organization, 'ORG'

A network entity that maintains a ledger and runs chaincode containers in order to perform
read/write operations to the ledger.  Peers are owned and maintained by members.


.. _Policy:

Also known as "members", organizations are invited to join the blockchain network
by a blockchain network provider. An organization is joined to a network by adding its
Membership Service Provider (MSP_) to the network. The MSP defines how other members of the
network may verify that signatures (such as those over transactions) were generated by a valid
identity, issued by that organization. The particular access rights of identities within an MSP
are governed by policies which are also agreed upon when the organization is joined to the
network. An organization can be as large as a multi-national corporation or as small as an
individual. The transaction endpoint of an organization is a Peer_. A collection of organizations
form a Consortium_. While all of the organizations on a network are members, not every organization
will be part of a consortium.

Policy
------

也被称为“成员”，组织被区块链服务提供者邀请加入区块链网络。通过将成员服务提供程序（ MSP_ ）添加到网络，组织加入网络。MSP定义了网络的其他成员如何验证签名（例如交易上的签名）是由该组织颁发的有效身份生成的。MSP中身份的特定访问权限由策略控制，这些策略在组织加入网络时也同意。组织可以像跨国公司一样大，也可以像个人一样小。 组织的交易终端点是节点 Peer_ 。 一组组织组成了一个联盟 Consortium_ 。虽然网络上的所有组织都是成员，但并非每个组织都会成为联盟的一部分。

Policies are expressions composed of properties of digital identities, for
example: ``OR('Org1.peer', 'Org2.peer')``. They are used to restrict access to
resources on a blockchain network. For instance, they dictate who can read from
or write to a channel, or who can use a specific chaincode API via an ACL_.
Policies may be defined in ``configtx.yaml`` prior to bootstrapping an ordering
service or creating a channel, or they can be specified when instantiating
chaincode on a channel. A default set of policies ship in the sample
``configtx.yaml`` which will be appropriate for most networks.

.. _Peer:

.. _glossary-Private-Data:

Peer
----

Private Data
------------

.. figure:: ./glossary/glossary.peer.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Peer

Confidential data that is stored in a private database on each authorized peer,
logically separate from the channel ledger data. Access to this data is
restricted to one or more organizations on a channel via a private data
collection definition. Unauthorized organizations will have a hash of the
private data on the channel ledger as evidence of the transaction data. Also,
for further privacy, hashes of the private data go through the
Ordering-Service_, not the private data itself, so this keeps private data
confidential from Orderer.

   A peer, 'P'

.. _glossary-Private-Data-Collection:

A network entity that maintains a ledger and runs chaincode containers in order to perform
read/write operations to the ledger.  Peers are owned and maintained by members.

Private Data Collection (Collection)
------------------------------------

一个网络实体，维护账本并运行链码容器来对账本做读写操作。节点由成员所有，并负责维护。

Used to manage confidential data that two or more organizations on a channel
want to keep private from other organizations on that channel. The collection
definition describes a subset of organizations on a channel entitled to store
a set of private data, which by extension implies that only these organizations
can transact with the private data.

.. _策略 :

.. _Proposal:

Policy
------

Proposal
--------

Policies are expressions composed of properties of digital identities, for
example: ``Org1.Peer OR Org2.Peer``. They are used to restrict access to
resources on a blockchain network. For instance, they dictate who can read from
or write to a channel, or who can use a specific chaincode API via an ACL_.
Policies may be defined in ``configtx.yaml`` prior to bootstrapping an ordering
service or creating a channel, or they can be specified when instantiating
chaincode on a channel. A default set of policies ship in the sample
``configtx.yaml`` which will be appropriate for most networks.

A request for endorsement that is aimed at specific peers on a channel. Each
proposal is either an Init or an Invoke (read/write) request.

策略是由数字身份的属性组成的表达式，例如： ``Org1.Peer OR Org2.Peer`` 。 它们用于限制对区块链网络上的资源的访问。例如，它们决定谁可以读取或写入某个通道，或者谁可以通过ACL使用特定的链码API。在引导排序服务或创建通道之前，可以在 ``configtx.yaml`` 中定义策略，或者可以在通道上实例化链码时指定它们。示例 ``configtx.yaml`` 中提供了一组默认策略，适用于大多数网络。


.. _glossary-Private-Data:

.. _Query:

Private Data
------------

Query
-----

Confidential data that is stored in a private database on each authorized peer,
logically separate from the channel ledger data. Access to this data is
restricted to one or more organizations on a channel via a private data
collection definition. Unauthorized organizations will have a hash of the
private data on the channel ledger as evidence of the transaction data. Also,
for further privacy, hashes of the private data go through the
Ordering-Service_, not the private data itself, so this keeps private data
confidential from Orderer.

A query is a chaincode invocation which reads the ledger current state but does
not write to the ledger. The chaincode function may query certain keys on the ledger,
or may query for a set of keys on the ledger. Since queries do not change ledger state,
the client application will typically not submit these read-only transactions for ordering,
validation, and commit. Although not typical, the client application can choose to
submit the read-only transaction for ordering, validation, and commit, for example if the
client wants auditable proof on the ledger chain that it had knowledge of specific ledger
state at a certain point in time.

存储在每个授权节点的私有数据库中的机密数据，在逻辑上与通道账本数据分开。通过私有数据收集定义，对数据的访问仅限于通道上的一个或多个组织。未经授权的组织将在通道账本上拥有私有数据的哈希作为交易数据的证据。此外，为了进一步保护隐私，私有数据的哈希值通过排序服务 Ordering-Service_ 而不是私有数据本身，因此这使得私有数据对排序者保密。

.. _Quorum:

.. _glossary-Private-Data-Collection:

Quorum
------

Private Data Collection (Collection)
------------------------------------

This describes the minimum number of members of the cluster that need to
affirm a proposal so that transactions can be ordered. For every consenter set,
this is a **majority** of nodes. In a cluster with five nodes, three must be
available for there to be a quorum. If a quorum of nodes is unavailable for any
reason, the cluster becomes unavailable for both read and write operations and
no new logs can be committed.

Used to manage confidential data that two or more organizations on a channel
want to keep private from other organizations on that channel. The collection
definition describes a subset of organizations on a channel entitled to store
a set of private data, which by extension implies that only these organizations
can transact with the private data.

.. _Raft:

用于管理通道上的两个或多个组织希望与该通道上的其他组织保持私密的机密数据。集合定义描述了有权存储一组私有数据的通道上的组织子集，这通过扩展意味着只有这些组织才能与私有数据进行交易。

Raft
----

.. _Proposal:

New for v1.4.1, Raft is a crash fault tolerant (CFT) ordering service
implementation based on the `etcd library <https://coreos.com/etcd/>`_
of the `Raft protocol <https://raft.github.io/raft.pdf>`_. Raft follows a
"leader and follower" model, where a leader node is elected (per channel) and
its decisions are replicated by the followers. Raft ordering services should
be easier to set up and manage than Kafka-based ordering services, and their
design allows organizations to contribute nodes to a distributed ordering
service.

Proposal
--------

.. _SDK:

A request for endorsement that is aimed at specific peers on a channel. Each
proposal is either an Init or an Invoke (read/write) request.

Software Development Kit (SDK)
------------------------------

一种通道中针对特定节点的背书请求。每个提案要么是链码的实例化，要么是链码的调用（读写）请求。

The Hyperledger Fabric client SDK provides a structured environment of libraries
for developers to write and test chaincode applications. The SDK is fully
configurable and extensible through a standard interface. Components, including
cryptographic algorithms for signatures, logging frameworks and state stores,
are easily swapped in and out of the SDK. The SDK provides APIs for transaction
processing, membership services, node traversal and event handling.

.. _Query:

Currently, the two officially supported SDKs are for Node.js and Java, while two
more -- Python and Go -- are not yet official but can still be downloaded
and tested.

Query
-----

.. _Smart-Contract:

A query is a chaincode invocation which reads the ledger current state but does
not write to the ledger. The chaincode function may query certain keys on the ledger,
or may query for a set of keys on the ledger. Since queries do not change ledger state,
the client application will typically not submit these read-only transactions for ordering,
validation, and commit. Although not typical, the client application can choose to
submit the read-only transaction for ordering, validation, and commit, for example if the
client wants auditable proof on the ledger chain that it had knowledge of specific ledger
state at a certain point in time.

Smart Contract
--------------

.. _Quorum:

A smart contract is code -- invoked by a client application external to the
blockchain network -- that manages access and modifications to a set of
key-value pairs in the :ref:`World-State` via :ref:`Transaction`. In Hyperledger Fabric,
smart contracts are packaged as chaincode. Chaincode is installed on peers
and then defined and used on one or more channels.

Quorum
------

.. _State-DB:

This describes the minimum number of members of the cluster that need to
affirm a proposal so that transactions can be ordered. For every consenter set,
this is a **majority** of nodes. In a cluster with five nodes, three must be
available for there to be a quorum. If a quorum of nodes is unavailable for any
reason, the cluster becomes unavailable for both read and write operations and
no new logs can be committed.

State Database
--------------

.. _Raft:

World state data is stored in a state database for efficient reads and queries
from chaincode. Supported databases include levelDB and couchDB.

Raft
----

.. _System-Chain:

New for v1.4.1, Raft is a crash fault tolerant (CFT) ordering service
implementation based on the `etcd library <https://coreos.com/etcd/>`_
of the `Raft protocol` <https://raft.github.io/raft.pdf>`_. Raft follows a
"leader and follower" model, where a leader node is elected (per channel) and
its decisions are replicated by the followers. Raft ordering services should
be easier to set up and manage than Kafka-based ordering services, and their
design allows organizations to contribute nodes to a distributed ordering
service.

System Chain
------------

.. _SDK:

Contains a configuration block defining the network at a system level. The
system chain lives within the ordering service, and similar to a channel, has
an initial configuration containing information such as: MSP information, policies,
and configuration details.  Any change to the overall network (e.g. a new org
joining or a new ordering node being added) will result in a new configuration block
being added to the system chain.

Software Development Kit (SDK)
------------------------------

The system chain can be thought of as the common binding for a channel or group
of channels.  For instance, a collection of financial institutions may form a
consortium (represented through the system chain), and then proceed to create
channels relative to their aligned and varying business agendas.

The Hyperledger Fabric client SDK provides a structured environment of libraries
for developers to write and test chaincode applications. The SDK is fully
configurable and extensible through a standard interface. Components, including
cryptographic algorithms for signatures, logging frameworks and state stores,
are easily swapped in and out of the SDK. The SDK provides APIs for transaction
processing, membership services, node traversal and event handling.

.. _Transaction:

超级账本Fabric客户端软件开发包（SDK）为开发人员提供了一个结构化的库环境，用于编写和测试链码应用程序。SDK完全可以通过标准接口实现配置和扩展。它的各种组件：签名加密算法、日志框架和状态存储，都可以轻松地被替换。SDK提供APIs进行交易处理，成员服务、节点遍历以及事件处理。

Transaction
-----------

Currently, the two officially supported SDKs are for Node.js and Java, while two
more -- Python and Go -- are not yet official but can still be downloaded
and tested.

.. figure:: ./glossary/glossary.transaction.png
   :scale: 30 %
   :align: right
   :figwidth: 20 %
   :alt: A Transaction

目前，两个官方支持的SDK用于Node.js和Java，而另外三个——Python，Go和REST——尚非正式，但仍可以下载和测试。

   A transaction, 'T'

.. _智能合约:

Transactions are created when a chaincode is invoked from a client application
to read or write data from the ledger. Fabric application clients submit transaction proposals to
endorsing peers for execution and endorsement, gather the signed (endorsed) responses from those
endorsing peers, and then package the results and endorsements into a transaction that is
submitted to the ordering service. The ordering service orders and places transactions
in a block that is broadcast to the peers which validate and commit the transactions to the ledger
and update world state.

智能合约
--------------

.. _World-State:

A smart contract is code -- invoked by a client application external to the
blockchain network -- that manages access and modifications to a set of
key-value pairs in the :ref:`World-State` via :ref:`Transaction`. In Hyperledger Fabric,
smart contracts are packaged as chaincode. Chaincode is installed on peers
and then defined and used on one or more channels.

World State
-----------

智能合约是代码——由区块链网络外部的客户端应用程序调用——管理对 :ref:`World-State` 中的一组键值对的访问和修改。在超级账本Fabric中，智能合约被称为链码。智能合约链码安装在节点上并实例化为一个或多个通道。

.. figure:: ./glossary/glossary.worldstate.png
   :scale: 40 %
   :align: right
   :figwidth: 25 %
   :alt: Current State

.. _State-DB:

   The World State, 'W'

State Database
--------------

Also known as the “current state”, the world state is a component of the
HyperLedger Fabric :ref:`Ledger`. The world state represents the latest values
for all keys included in the chain transaction log. Chaincode executes
transaction proposals against world state data because the world state provides
direct access to the latest value of these keys rather than having to calculate
them by traversing the entire transaction log. The world state will change
every time the value of a key changes (for example, when the ownership of a
car -- the "key" -- is transferred from one owner to another -- the
"value") or when a new key is added (a car is created). As a result, the world
state is critical to a transaction flow, since the current state of a key-value
pair must be known before it can be changed. Peers commit the latest values to
the ledger world state for each valid transaction included in a processed block.

World state data is stored in a state database for efficient reads and queries
from chaincode. Supported databases include levelDB and couchDB.


为了从链码中高效的读写查询，当前状态数据存储在状态数据库中。支持的数据库包括levelDB和couchDB。

.. _System-Chain:

System Chain
------------

Contains a configuration block defining the network at a system level. The
system chain lives within the ordering service, and similar to a channel, has
an initial configuration containing information such as: MSP information, policies,
and configuration details.  Any change to the overall network (e.g. a new org
joining or a new ordering node being added) will result in a new configuration block
being added to the system chain.

一个在系统层面定义网络的配置区块。系统链存在于排序服务中，与通道类似，具有包含以下信息的初始配置：MSP（成员服务提供者）信息、策略和配置详情。全网中的任何变化（例如新的组织加入或者新的排序节点加入）将导致新的配置区块被添加到系统链中。

The system chain can be thought of as the common binding for a channel or group
of channels.  For instance, a collection of financial institutions may form a
consortium (represented through the system chain), and then proceed to create
channels relative to their aligned and varying business agendas.

系统链可看做是一个或一组通道的公用绑定。例如，金融机构的集合可以形成一个财团（表现为系统链）， 然后根据其相同或不同的业务计划创建通道。

.. _Transaction:

Transaction
-----------

.. figure:: ./glossary/glossary.transaction.png
   :scale: 30 %
   :align: right
   :figwidth: 20 %
   :alt: A Transaction

   A transaction, 'T'

Transactions are created when a chaincode is invoked from a client application
to read or write data from the ledger. Fabric application clients submit transaction proposals to
endorsing peers for execution and endorsement, gather the signed (endorsed) responses from those
endorsing peers, and then package the results and endorsements into a transaction that is
submitted to the ordering service. The ordering service orders and places transactions
in a block that is broadcast to the peers which validate and commit the transactions to the ledger
and update world state.

.. _World-State:

World State
-----------

.. figure:: ./glossary/glossary.worldstate.png
   :scale: 40 %
   :align: right
   :figwidth: 25 %
   :alt: Current State

   The World State, 'W'

Also known as the “current state”, the world state is a component of the
HyperLedger Fabric :ref:`Ledger`. The world state represents the latest values
for all keys included in the chain transaction log. Chaincode executes
transaction proposals against world state data because the world state provides
direct access to the latest value of these keys rather than having to calculate
them by traversing the entire transaction log. The world state will change
every time the value of a key changes (for example, when the ownership of a
car -- the "key" -- is transferred from one owner to another -- the
"value") or when a new key is added (a car is created). As a result, the world
state is critical to a transaction flow, since the current state of a key-value
pair must be known before it can be changed. Peers commit the latest values to
the ledger world state for each valid transaction included in a processed block.

世界状态也称为“当前状态”，是超级账本Fabric :ref:`Ledger` 的一个组件。世界状态表示链交易日志中包含的所有键的最新值。链码针对世界状态数据执行交易提案，因为世界状态提供对这些密钥的最新值的直接访问，而不是通过遍历整个交易日志来计算它们。每当键的值发生变化时（例如，当汽车的所有权——“钥匙”——从一个所有者转移到另一个——“值”）或添加新键（创造汽车）时，世界状态就会改变。因此，世界状态对交易流程至关重要，因为键值对的当前状态必须先知道才能更改。对于处理过的区块中包含的每个有效事务，节点将最新值提交到账本世界状态。
