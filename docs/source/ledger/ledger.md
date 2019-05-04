# Ledger - 账本

**Audience**: Architects, Application and smart contract developers,
administrators

A **ledger** is a key concept in Hyperledger Fabric; it stores important factual
information about business objects; both the current value of the attributes of
the objects, and the history of transactions that resulted in these current
values.

In this topic, we're going to cover:

* [What is a Ledger?](#what-is-a-ledger?)
* [Storing facts about business objects](#ledgers-facts-and-states)
* [A blockchain ledger](#a-blockchain-ledger)
* [The world state](#world-state)
* [The blockchain data structure](#blockchain)
* [How blocks are stored in a blockchain](#blocks)
* [Transactions](#transactions)
* [World state database options](#world-state-database-options)
* [The **Fabcar** example ledger](#example-ledger-fabcar)
* [Ledgers and namespaces](#namespaces)
* [Ledgers and channels](#channels)

## What is a Ledger? - 什么是账本？

A ledger contains the current state of a business as a journal of transactions.
The earliest European and Chinese ledgers date from almost 1000 years ago, and
the Sumerians had [stone
ledgers](http://www.sciencephoto.com/media/686227/view/accounting-ledger-sumerian-cuneiform)
4000 years ago -- but let's start with a more up-to-date example!

一个账本包含了对于一个业务的当前的 state，就像是一个包含所有交易的分类账本。在大概 1000 年前，就有最早的欧
洲和中国的账本，在 4000 年前，苏美尔人拥有
 [石头账本](http://www.sciencephoto.com/media/686227/view/accounting-ledger-sumerian-cuneiform)
  -- 但是让我们从一个更现代化的例子开始！

You're probably used to looking at your bank account. What's most important to
you is the available balance -- it's what you're able to spend at the current
moment in time. If you want to see how your balance was derived, then you can
look through the transaction credits and debits that determined it. This is a
real life example of a ledger -- a state (your bank balance), and a set of
ordered transactions (credits and debits) that determine it. Hyperledger Fabric
is motivated by these same two concerns -- to present the current value of a set
of ledger states, and to capture the history of the transactions that determined
these states.

你可能已经习惯了查看你的银行账户。对于你来说最重要的应该是可用的余额 -- 那是你在当时可以花费的部分。
如果你想看看你的余额是如何产生出来的，那么你可以查看收入和支出的交易记录。这是现实生活中的一个账本的
例子 -- 一个 state (你的银行余额)，和决定了余额的一系列的有序的交易 (收入和支出)。Hyperledger Fabric 
同样是基于这两个问题而产生的 -- 用来展示一系列账本的 states 的当前值，并且记录决定了这些 states 的交易记录。


## Ledgers, Facts and States

A ledger doesn't literally store business objects -- instead it stores **facts**
about those objects. When we say "we store a business object in a ledger" what
we really mean is that we're recording the facts about the current state of an
object, and the facts about the history of transactions that led to the current
state. In an increasingly digital world, it can feel like we're looking at an
object, rather than facts about an object. In the case of a digital object, it's
likely that it lives in an external datastore; the facts we store in the ledger
allow us to identify its location along with other key information about it.

While the facts about the current state of a business object may change, the
history of facts about it is **immutable**, it can be added to, but it cannot be
retrospectively changed. We're going to see how thinking of a blockchain as an
immutable history of facts about business objects is a simple yet powerful way
to understand it.

Let's now take a closer look at the Hyperledger Fabric ledger structure!

现在让我们来详细看一下 Hyperledger Fabric 的账本结构吧！

## The Ledger - 账本

In Hyperledger Fabric, a ledger consists of two distinct, though related, parts
-- a world state and a blockchain. Each of these represents a set of facts about
a set of business objects.

在 Hyperledger Fabric 中，一个区块链账本包含两部分，但是是两个相关的部分 -- 一个 world state 
和一个区块链。每一部分都表示有关一组业务对象的一组事实。

Firstly, there's a **world state** -- a database that holds a cache of the
**current values** of a set of ledger states. The world state makes it easy for
a program to directly access the current value of a state rather than having to
calculate it by traversing the entire transaction log. Ledger states are, by
default, expressed as **key-value** pairs, and we'll see later how Hyperledger
Fabric provides flexibility in this regard. The world state can change
frequently, as states can be created, updated and deleted.

Secondly, there's a **blockchain** -- a transaction log that records all the
changes that have resulted in the current the world state. Transactions are
collected inside blocks that are appended to the blockchain -- enabling you to
understand the history of changes that have resulted in the current world state.
The blockchain data structure is very different to the world state because once
written, it cannot be modified; it is **immutable**.

![ledger.ledger](./ledger.diagram.1.png) *A Ledger L comprises blockchain B and
world state W, where blockchain B determines world state W. We can also say that
world state W is derived from blockchain B.*

It's helpful to think of there being one **logical** ledger in a Hyperledger
Fabric network. In reality, the network maintains multiple copies of a ledger --
which are kept consistent with every other copy through a process called
**consensus**. The term **Distributed Ledger Technology** (**DLT**) is often
associated with this kind of ledger -- one that is logically singular, but has
many consistent copies distributed throughout a network.

在一个 Hyperledger Fabric 网络中存在一个 **逻辑** 账本。在现实世界中，这个网络维护了一个
账本的多个副本 -- 他们彼此通过一个称为 **共识** 的流程保持一致。**分布式账本技术** (**DLT**) 
这个词经常会关联到这种类型的账本上 -- 一个逻辑上是单独的，但是有很多相同的副本分布式地存储在一个
网络中。

Let's now examine the world state and blockchain data structures in more detail.

现在让我们来详细看一下 world state 和区块链数据结构。

## World State

The world state holds the current value of the attributes of a business object
as a unique ledger state. That's useful because programs usually require the
current value of an object; it would be cumbersome to traverse the entire
blockchain to calculate an object's current value -- you just get it directly
from the world state.

![ledger.worldstate](./ledger.diagram.3.png) *A ledger world state containing
two states. The first state is: key=CAR1 and value=Audi. The second state has a
more complex value: key=CAR2 and value={model:BMW, color=red, owner=Jane}. Both
states are at version 0.*

A ledger state records a set of facts about a particular business object. Our
example shows ledger states for two cars, CAR1 and CAR2, each having a key and a
value. An application program can invoke a smart contract which uses simple
ledger APIs to **get**, **put** and **delete** states. Notice how a state value
can be simple (Audi...) or compound (type:BMW...). The world state is often
queried to retrieve objects with certain attributes, for example to find all red
BMWs.

The world state is implemented as a database. This makes a lot of sense because
a database provides a rich set of operators for the efficient storage and
retrieval of states.  We'll see later that Hyperledger Fabric can be configured
to use different world state databases to address the needs of different types
of state values and the access patterns required by applications, for example in
complex queries.

World state 是作为一个数据库实现的。这很有道理因为一个数据库提供了一套丰富的操作来有效的存储
和返回 states。之后我们会看到 Hyperledger Fabric 能够针对不同类型的 state 值以及应用程序
所需的访问模式，比如需要复杂的查询来配置使用不同的 world state 数据库。

Applications submit transactions which capture changes to the world state, and
these transactions end up being committed to the ledger blockchain. Applications
are insulated from the details of this [consensus](../txflow.html) mechanism by
the Hyperledger Fabric SDK; they merely invoke a smart contract, and are
notified when the transaction has been included in the blockchain (whether valid
or invalid). The key design point is that only transactions that are **signed**
by the required set of **endorsing organizations** will result in an update to
the world state. If a transaction is not signed by sufficient endorsers, it will
not result in a change of world state. You can read more about how applications
use [smart contracts](../smartcontract/smartcontract.html), and how to [develop
applications](../developapps/developing_applications.html).

You'll also notice that a state has a version number, and in the diagram above,
states CAR1 and CAR2 are at their starting versions, 0. The version number for
internal use by Hyperledger Fabric, and is incremented every time the state
changes. The version is checked whenever the state is updated to make sure the
current states matches the version at the time of endorsement. This ensures that
the world state is changing as expected; that there has not been a concurrent
update.

Finally, when a ledger is first created, the world state is empty. Because any
transaction which represents a valid change to world state is recorded on the
blockchain, it means that the world state can be re-generated from the
blockchain at any time. This can be very convenient -- for example, the world
state is automatically generated when a peer is created. Moreover, if a peer
fails abnormally, the world state can be regenerated on peer restart, before
transactions are accepted.

最终，当一个账本第一次被创建的时候，world state 是空的。因为任何代表一个有效的对于
world state 的变动的交易都会被记录到区块链中，这意味着 world state 可以在任何时间从
区块链上被重新生成。这是非常方便的 -- 比如，当一个 peer 节点被创建的时候，world state
会被自动的生成。如果一个 peer 节点非正常的停掉了，当 peer 重启的时候，在交易被接受前，
world state 能够被重新生成。

## Blockchain - 区块链

Let's now turn our attention from the world state to the blockchain. Whereas the
world state contains a set of facts relating to the current state of a set of
business objects, the blockchain is an historical record of the facts about how
these objects arrived at their current states. The blockchain has recorded every
previous version of each ledger state and how it has been changed.

The blockchain is structured as sequential log of interlinked blocks, where each
block contains a sequence of transactions, each transaction representing a query
or update to the world state. The exact mechanism by which transactions are
ordered is discussed [elsewhere](../peers/peers.html#peers-and-orderers);
what's important is that block sequencing, as well as transaction sequencing
within blocks, is established when blocks are first created by a Hyperledger
Fabric component called the **ordering service**.

Each block's header includes a hash of the block's transactions, as well a copy
of the hash of the prior block's header. In this way, all transactions on the
ledger are sequenced and cryptographically linked together. This hashing and
linking makes the ledger data very secure. Even if one node hosting the ledger
was tampered with, it would not be able to convince all the other nodes that it
has the 'correct' blockchain because the ledger is distributed throughout a
network of independent nodes.

每个区块的头包含了区块的交易的哈希值，也包括了前一个区块头的哈希值的副本。通过这种方式，账本
上的所有交易都是有序的并且通过加密的形式连接在了一起。这种哈希和连接使账本数据非常安全。即使
一个节点拥有的账本被改动了，这不会影响其他的具有 “正确的” 区块链的节点，因为账本是被分发到
一个网络的不同的独立节点的。

The blockchain is always implemented as a file, in contrast to the world state,
which uses a database. This is a sensible design choice as the blockchain data
structure is heavily biased towards a very small set of simple operations.
Appending to the end of the blockchain is the primary operation, and query is
currently a relatively infrequent operation.

区块链通常是以文件的形式实现的，对比于使用数据库的 world state。这是一个有意义的设计选择，
因为区块链数据结构只会涉及到非常少的一系列简单操作。向区块链的尾部附加新的区块是主要的操作，
查询对于当前来说是一个相对不经常做的一项操作。

Let's have a look at the structure of a blockchain in a little more detail.

让我们更详细的看下一个区块链的结构。

![ledger.blockchain](./ledger.diagram.2.png) *A blockchain B containing blocks
B0, B1, B2, B3. B0 is the first block in the blockchain, the genesis block.*

*区块链 B 包含了区块 B0, B1, B2, B3。B0 是区块链中的第一个区块，创世区块*

In the above diagram, we can see that **block** B2 has a **block data** D2 which
contains all its transactions: T5, T6, T7.

在上边的图表中，我们能够看到 **区块** B2 有一个 **区块数据** D2，它包含了所有的交易：T5，T6，T7。

Most importantly, B2 has a **block header** H2, which contains a cryptographic
**hash** of all the transactions in D2 as well as with the equivalent hash from
the previous block B1. In this way, blocks are inextricably and immutably linked
to each other, which the term **blockchain** so neatly captures!

最重要的是，B2 有一个 **区块头** H2，它包含了一个在 D2 中的所有交易的经过加密的 **哈希值**，
还有从前一个区块 B1 的同等的哈希值。通过这种方式，这些区块变成了无法拆分并且无法变更的彼此相互
关联，这正是 **区块链** 这个词所表达的意义！

Finally, as you can see in the diagram, the first block in the blockchain is
called the **genesis block**.  It's the starting point for the ledger, though it
does not contain any user transactions. Instead, it contains a configuration
transaction containing the initial state of the network channel (not shown). We
discuss the genesis block in more detail when we discuss the blockchain network
and [channels](../channels.html) in the documentation.

最终，就像你在图表中看到的，在区块链中的第一个区块被称为 **创世区块**。它是账本的起点，尽管
它没有包含任何的用户交易。但是，它包含了一个配置交易，其中包括这个网络 channel (没有显示出来) 
的初始 stste。我们会在讨论区块链网络和 [channels](../channels.html) 的时候更详细地讨论创世区块。

## Blocks - 区块

Let's have a closer look at the structure of a block. It consists of three
sections

让我们来更进一步地研究一下一个区块的结构。它包含三个部分

* **Block Header** - **区块头**

  This section comprises three fields, written when a block is created.

  这个部分包含三个字段，是当一个区块被创建的时候写入的。

  * **Block number**: An integer starting at 0 (the genesis block), and
  increased by 1 for every new block appended to the blockchain.

  * **区块编号**: 一个从 0  开始 (创世区块) 的数字，对于每一个附加到区块链上的新的区块，它的编号会增加1。

  * **Current Block Hash**: The hash of all the transactions contained in the
  current block.

  * **当前区块的哈希值**: 在当前区块中包含的所有交易的哈希值。

  * **Previous Block Hash**: A copy of the hash from the previous block in the
  blockchain.

  * **前一区块的哈希值**: 在区块链中前一个区块的哈希值的副本。

  These fields are internally derived by cryptographically hashing the block
  data. They ensure that each and every block is inextricably linked to its
  neighbour, leading to an immutable ledger.

  ![ledger.blocks](./ledger.diagram.4.png) *Block header details. The header H2
  of block B2 consists of block number 2, the hash CH2 of the current block data
  D2, and a copy of a hash PH1 from the previous block, block number 1.*

  *区块头详情：区块 B2 的区块头 H2 包含了区块编号 2，当前区块数据 D2 的哈希值 CH2，和从前
  一个区块的哈希值 PH1 的副本，区块编号 1。*

* **Block Data** - **区块数据**

  This section contains a list of transactions arranged in order. It is written
  when the block is created by the ordering service. These transactions have a
  rich but straightforward structure, which we describe [later](#Transactions)
  in this topic.

  这部分包含了一个有序排列的交易列表。它是在区块被排序服务创建的时候写入的。这些交易具有一个
  丰富但是很直接的结构，我们会在 [后边](#Transactions) 描述。

* **Block Metadata** - **区块 Metadata**

  This section contains the time when the block was written, as well as the
  certificate, public key and signature of the block writer. Subsequently, the
  block committer also adds a valid/invalid indicator for every transaction,
  though this information is not included in the hash, as that is created when
  the block is created.

  这个部分包含了区块被写入的时间，还有证书，公钥以及区块写入者的签名。接下来，区块的提交者
  也会为每一笔交易添加一个有效/无效的标记，但是这个信息是不会包含进哈希值的，因为它是在区块
  已经被写入的时候产生的。

## Transactions - 交易

As we've seen, a transaction captures changes to the world state. Let's have a
look at the detailed **blockdata** structure which contains the transactions in
a block.

就像我们看到的，一笔交易记录了对于 world state 的变更。让我们来详细看一下 **区块数据** 的
结构，这些数据指的是包含在一个区块中的交易。

![ledger.transaction](./ledger.diagram.5.png) *Transaction details. Transaction
T4 in blockdata D1 of block B1 consists of transaction header, H4, a transaction
signature, S4, a transaction proposal P4, a transaction response, R4, and a list
of endorsements, E4.*

*交易详情：区块 B1 的区块数据 D1 中的交易 T4 包括了交易头 H4，一个交易签名 S4，一个交易的
提案 P4，一个交易的回应，和一个背书的列表, E4。*

In the above example, we can see the following fields:

在上边的例子中，我们能够看到以下的字段：

* **Header** - **头**

  This section, illustrated by H4, captures some essential metadata about the
  transaction -- for example, the name of the relevant chaincode, and its
  version.

  这部分由 H4 表示，记录了关于交易的一些基本的 metadata -- 比如，相关的 chaincode 的
  名字以及它的版本。

* **Signature** - **签名**

  This section, illustrated by S4, contains a cryptographic signature, created
  by the client application. This field is used to check that the transaction
  details have not been tampered with, as it requires the application's private
  key to generate it.

  这部分由 S4 表示，包含了一个由客户端应用程序创建的经过加密的签名。这个字段被用来检查交易的
  详细内容没有被篡改过，因为这个签名需要应用程序的私钥来生成。

* **Proposal** - **提案**

  This field, illustrated by P4, encodes the input parameters supplied by an
  application to the smart contract which creates the proposed ledger update.
  When the smart contract runs, this proposal provides a set of input
  parameters, which, in combination with the current world state, determines the
  new world state.
  
  这部分由 P4 表示，包含了对于智能合约的一个应用程序提供过的输入参数，这个智能合约创建了这个对
  账本的更新。当 chaincode 执行的时候，这个提案提供了一套输入参数，这些参数同当前的
   world state 一起决定了新的 world state。

* **Response** - **回应**

  This section, illustrated by R4, captures the before and after values of the
  world state, as a **Read Write set** (RW-set). It's the output of a smart
  contract, and if the transaction is successfully validated, it will be applied
  to the ledger to update the world state.

  这部分由 R4 表示，记录了 world state 的之前和之后的值，作为 **读写集** (RW-set)。它是
  一个智能合约的输出，并且如果交易被正确地验证过了的话，它会被应用到账本上以更新 world state。

* **Endorsements** - **背书**

  As shown in E4, this is a list of signed transaction responses from each
  required organization sufficient to satisfy the endorsement policy. You'll
  notice that, whereas only one transaction response is included in the
  transaction, there are multiple endorsements. That's because each endorsement
  effectively encodes its organization's particular transaction response --
  meaning that there's no need to include any transaction response that doesn't
  match sufficient endorsements as it will be rejected as invalid, and not
  update the world state.

  就像 E4 显示的那样，这是一个来自于每个所需组织的签过名的交易回应的列表，这能够有效的满足
  背书策略。你会注意到，在交易中只包含一个交易回应，但是会有多个背书。这是因为每个背书有效地
  包含了它的组织的指定的交易回应 -- 这意味着不需要包含任何的没有满足有效的背书的交易回应因为
  它会被作为无效的交易被拒绝，并且不会更新 world state。

That concludes the major fields of the transaction -- there are others, but
these are the essential ones that you need to understand to have a solid
understanding of the ledger data structure.

这就证明了交易的主要字段 -- 还有一些其他的，但是这些是你需要理解的以对于账本数据结构有
很深的理解的基础知识。

## World State database options - World state 数据库选项

The world state is physically implemented as a database, to provide simple and
efficient storage and retrieval of ledger states. As we've seen, ledger states
can have simple or compound values, and to accommodate this, the world state
database implementation can vary, allowing these values to be efficiently
implemented. Options for the world state database currently include LevelDB and
CouchDB.

World state 物理上是以一个数据库的形式实现的，提供了简单有效的对于账本 states 的存储及获取。
就像我们看到的，账本 states 可以有简单或者复合的值，为了适应这个，world state 数据库实现很
多样，允许这些值能够被有效的实现。当前对于 world state 数据库的选项包括 LevelDB 和 CouchDB。

LevelDB is the default and is particularly appropriate when ledger states are
simple key-value pairs. A LevelDB database is closely co-located with a network
node -- it is embedded within the same operating system process.

默认的是 LevelDB，这对于账本 states 是简单的键-值对的情况是很适用的。一个 LevelDB 数据库
会紧密地跟一个网路节点关联 -- 它会被嵌入到以相同的操作系统进程中。

CouchDB is a particularly appropriate choice when ledger states are structured
as JSON documents because CouchDB supports the rich queries and update of richer
data types often found in business transactions. Implementation-wise, CouchDB
runs in a separate operating system process, but there is still a 1:1 relation
between a peer node and a CouchDB instance. All of this is invisible to a smart
contract. See [CouchDB as the StateDatabase](../couchdb_as_state_database.html)
for more information on CouchDB.

CouchDB 对于账本 states 的结构是 JSON 文档的形式的时候比较适用，因为 CouchDB 支持富查询
以及对在业务交易中经常发现的富数据类型。实现的角度上讲，CouchDB 运行在一个分开的操作系统进程
中，但是这在一个peer节点和一个 CouchDB 实例之间还是有一个 1:1 的关系。所有这些都能在智能
合约中看到。浏览 [CouchDB 作为 StateDatabase](../couchdb_as_state_database.html) 
了解更详细内容。

In LevelDB and CouchDB, we see an important aspect of Hyperledger Fabric -- it
is *pluggable*. The world state database could be a relational data store, or a
graph store, or a temporal database.  This provides great flexibility in the
types of ledger states that can be efficiently accessed, allowing Hyperledger
Fabric to address many different types of problems.

在 LevelDB 和 CouchDB 中，我们能够看到 Hyperledger Fabric 的一个重要的特征 -- 它是
 *可插拔* 的。World state 数据库可以是一个关系型数据存储，或者是一个 graph 存储，或者
 是一个临时的数据库。这对于不同的账本 states 的类型进行有效的访问提供了很大的灵活性，
 允许 Hyperledger Fabric 解决不同类型的问题。

## Example Ledger: fabcar - 样例账本: fabcar

As we end this topic on the ledger, let's have a look at a sample ledger. If
you've run the [fabcar sample application](../write_first_app.html), then you've
created this ledger.

因为我们要以这个话题来结束账本的介绍，让我们来看一个样例账本。如果你运行了
 [fabcar sample application](../write_first_app.html)，那么你就已经创建了这个账本。

The fabcar sample app creates a set of 10 cars each with a unique identity; a
different color, make, model and owner. Here's what the ledger looks like after
the first four cars have been created.

Fabcar 样例应用创建了 10 辆车，每辆有不同的属性：有不同的颜色，制造商，型号和拥有者。
下边是在前四辆车被创建之后账本的样子。

![ledger.transaction](./ledger.diagram.6.png) *The ledger, L, comprises a world
state, W and a blockchain, B. W contains four states with keys: CAR1, CAR2, CAR3
and CAR4. B contains two blocks, 0 and 1. Block 1 contains four transactions:
T1, T2, T3, T4.*

*这个账本，L，包含了一个 world state W，和一个区块链 B。W 包含了四个 states，state 包含
键：CAR1, CAR2, CAR3 and CAR4。B 包含两个区块，0 和 1。区块 1 包含了四笔交易：T1, T2,
T3, T4.*

We can see that the world state contains states that correspond to CAR0, CAR1,
CAR2 and CAR3. CAR0 has a value which indicates that it is a blue Toyota Prius,
currently owned by Tomoko, and we can see similar states and values for the
other cars. Moreover, we can see that all car states are at version number 0,
indicating that this is their starting version number -- they have not been
updated since they were created.

我们能够看到 world state 包含了对应于 CAR0, CAR1, CAR2 and CAR3 的 world states。
CAR0 具有一个表述这是一个绿色的 Toyota Prius，由 Tomoko 拥有的值，我们还能看到对于其他车
的类似的 states。并且，我们能够看到所有的 car states 都在版本编号 0，说明这是他们的开始版本
编号 -- 他们在被创建之后还没有被更新过。

We can also see that the blockchain contains two blocks.  Block 0 is the genesis
block, though it does not contain any transactions that relate to cars. Block 1
however, contains transactions T1, T2, T3, T4 and these correspond to
transactions that created the initial states for CAR0 to CAR3 in the world
state. We can see that block 1 is linked to block 0.

我们还能看到这个区块链包含两个区块。区块 0 是创世区块，尽管他没有包含任何有关车的交易。
区块 1 包含了交易 T1, T2, T3, T4 这些是对应于在 world state 中的创建对于 CAR0 到 CAR3 
的初始 states 交易。我们能够看到区块 1 是连接到 区块 0 的。

We have not shown the other fields in the blocks or transactions, specifically
headers and hashes.  If you're interested in the precise details of these, you
will find a dedicated reference topic elsewhere in the documentation. It gives
you a fully worked example of an entire block with its transactions in glorious
detail -- but for now, you have achieved a solid conceptual understanding of a
Hyperledger Fabric ledger. Well done!

我们没有显示区块或者交易中的其他字段，尤其是头和哈希值。如果你对这些感兴趣的话，你会在文档的
其他部分找到专有的参考话题。它会给你一个整体的可工作的例子，包含所有的区块和他的交易的详细内
容 -- 但是目前来说，你已经对于一个 Hyperledger Fabric 账本有了很好的概念上的理解了。做的很棒！

## Namespaces

Even though we have presented the ledger as though it were a single world state
and single blockchain, that's a little bit of an over-simplification. In
reality, each chaincode has its own world state that is separate from all other
chaincodes. World states are in a namespace so that only smart contracts within
the same chaincode can access a given namespace.

A blockchain is not namespaced. It contains transactions from many different
smart contract namespaces. You can read more about chaincode namespaces in this
[topic](./developapps/chaincodenamespace.html).

Let's now look at how the concept of a namespace is applied within a Hyperledger
Fabric channel.

## Channels

In Hyperledger Fabric, each [channel](../channels.html) has a completely
separate ledger. This means a completely separate blockchain, and completely
separate world states, including namespaces. It is possible for applications and
smart contracts to communicate between channels so that ledger information can
be accessed between them.

You can read more about how ledgers work with channels in this
[topic](./developapps/chaincodenamespace.html#channel).


## More information - 更多信息

See the [Transaction Flow](../txflow.html),
[Read-Write set semantics](../readwrite.html) and
[CouchDB as the StateDatabase](../couchdb_as_state_database.html) topics for a
deeper dive on transaction flow, concurrency control, and the world state
database.

查看 [交易流](../txflow.html),
[读写集语义学](../readwrite.html) 和
[CouchDB 作为 StateDatabase](../couchdb_as_state_database.html) 话题来深入了解交易流程，并发控制和 world state 数据库。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
