# 链码命名空间
# Chaincode namespace

**本文面向的读者是**: 架构师，应用程序和智能合约开发人员，管理员

**Audience**: Architects, application and smart contract developers,
administrators

链码命名空间允许其保持自己的世界状态与其他链码的不同。具体来说，同链码的智能合约对相同的世界状态都拥有直接的访问权，而不同链码的智能合约无法直接访问对方的世界状态。如果一个智能合约需要访问其他链码的世界状态，可通过执行链码-对-链码的调用来完成。最后，区块链可以包含涉及了不同世界状态的交易。

A chaincode namespace allows it to keep its world state separate from other
chaincodes. Specifically, smart contracts in the same chaincode share direct
access to the same world state, whereas smart contracts in different chaincodes
cannot directly access each other's world state. If a smart contract needs to
access another chaincode world state, it can do this by performing a
chaincode-to-chaincode invocation. Finally, a blockchain can contain
transactions which relate to different world states.

本文我们将讲述以下内容：

In this topic, we're going to cover:

* [命名空间的重要性](#motivation)
* [什么是链码命名空间](#scenario)
* [通道和链码命名空间](#channels)
* [如何使用链码命名空间](#usage)
* [如何使用智能合约来访问世界状态](#cross-chaincode-access)
* [链码命名空间的设计考虑](#considerations)

* [The importance of namespaces](#motivation)
* [What is a chaincode namespace](#scenario)
* [Channels and namespaces](#channels)
* [How to use chaincode namespaces](#usage)
* [How to access world states across smart contracts](#cross-chaincode-access)
* [Design considerations for chaincode namespaces](#considerations)

## 动机

## Motivation

命名空间是一个常见的概念。我们知道虽然*公园街道，纽约和帕克街道，西雅图*这些属于不同街道，但是他们有共同的名字。城市为公园街提供了一个**命名空间**，同时赋予了它自由度和清晰度。

A namespace is a common concept. We understand that *Park Street, New York* and
*Park Street, Seattle* are different streets even though they have the same
name. The city forms a **namespace** for Park Street, simultaneously providing
freedom and clarity.

在电脑系统中也是如此。命名空间实现了让不同用户在不影响其他方操作的情况下对一个共享系统的不同部分进行编程和操作。许多编程语言都有命名空间，这就使得程序可以轻松地分配独特的识别符，如变量名，而无须担心其他程序也在进行相同操作。下文中会介绍到Hyperledger Fabric通过命名空间使得智能合约可以保持自己的账本世界状态与其他智能合约的不同。

It's the same in a computer system. Namespaces allow different users to program
and operate different parts of a shared system, without getting in each other's
way. Many programming languages have namespaces so that programs can freely
assign unique identifiers, such as variable names, without worrying about other
programs doing the same. We'll see that Hyperledger Fabric uses namespaces to
help smart contracts keep their ledger world state separate from other smart
contracts.

## 情景

## Scenario

让我们通过下面的图表来看一下账本世界状态如何管理对通道组织很重要的商业对象的相关事实。无论对象是商业票据，债券，还是车牌号码，无论这些对象位于生命周期的什么位置，它们都会被作为状态维持在账本数据状态数据库中。智能合约通过与账本（世界状态和区块链）交互来管理这些商业对象，而多数情况下这一过程会涉及到智能合约查询或更新账本世界状态。

Let's examine how the ledger world state organizes facts about business objects
that are important to the organizations in a channel using the diagram below.
Whether these objects are commercial papers, bonds, or vehicle registrations,
and wherever they are in their lifecycle, they are maintained as states within
the ledger world state database. A smart contract manages these business objects
by interacting with the ledger (world state and blockchain), and in most cases
this will involve it querying or updating the ledger world state.

账本世界状态是通过访问该状态的智能合约的链码来进行划分的，理解这一点至关重要 。这种划分或者*命名空间*对架构师、管理员和程序员来说是一点非常重要的设计考虑。

It's vitally important to understand that the ledger world state is partitioned
according to the chaincode of the smart contract that accesses it, and this
partitioning, or *namespacing* is an important design consideration for
architects, administrators and programmers.

![chaincodens.scenario](./develop.diagram.50.png) *账本世界状态根据访问其状态的链码被分成不同命名空间。在一个给定通道上，相同链码的智能合约共享相同世界状态，不同链码的智能合约无法直接访问对方的世界状态。同样的道理，区块链可以包含与不同链码世界状态相关的交易。*

![chaincodens.scenario](./develop.diagram.50.png) *The ledger world state is
separated into different namespaces according to the chaincode that accesses it.
Within a given channel, smart contracts in the same chaincode share the same
world state, and smart contracts in different chaincodes cannot directly access
each other's world state. Likewise, a blockchain can contain transactions that
relate to different chaincode world states.*

在我们的示例中可以看到两种不同的链码中定义了四种智能合约，每个都位于它们自己的链码容器里。  `euroPaper` 和`yenPaper` 智能合约被定义在  `papers` 链码中。  `euroBond` 和 `yenBond`  智能合约的情况也类似——它们被定义在`bonds`链码中。该设计可帮助应用程序员们理解他们的工作对象，是商业票据还是欧元或日元的债券，因为各金融产品的规则不会受货币种类影响，这就使得用相同链码管理这些金融产品的部署成为可能。

In our example, we can see four smart contracts defined in two different
chaincodes, each of which is in their own chaincode container. The `euroPaper`
and `yenPaper` smart contracts are defined in the `papers` chaincode. The
situation is similar for the `euroBond` and `yenBond` smart contracts  -- they
are defined in the `bonds` chaincode. This design helps application programmers
understand whether they are working with commercial papers or bonds priced in
Euros or Yen, and because the rules for each financial product don't really
change for different currencies, it makes sense to manage their deployment in
the same chaincode.

 [上图](#scenario) 还展示了这一部署选择的结果。数据库管理系统为`papers` 和 `bonds` 链码以及各自其中包含的智能合约创建了不同的世界状态数据库。  `World state A` 和 `world state B` 被分别放在不同的数据库中；其中的数据也被分隔开，从而使得一个单独的世界状态查询（比如）不会同时访问两个世界状态。据说世界状态根据其链码进行了*命名空间设定*。

The [diagram](#scenario) also shows the consequences of this deployment choice.
The database management system (DBMS) creates different world state databases
for the `papers` and `bonds` chaincodes and the smart contracts contained within
them. `World state A` and `world state B` are each held within distinct
databases; the data are isolated from each other such that a single world state
query (for example) cannot access both world states. The world state is said to
be *namespaced* according to its chaincode.

看看  `world state A` 是如何包含两个列表的商业票据 `paperListEuro` 和 `paperListYen` 。状态  `PAP11` 和`PAP21` 分别是由  `euroPaper` 和 `yenPaper` 智能合约管理的每个票据的示例。由于这些智能合约共享同样的链码命名空间，因此它们的key(`PAPxyz`) 必须在 `papers` 链码的命名空间里是唯一的。要注意怎样能在`papers` 链码上写一个能对所有商业票据（无论是欧元还是日元）执行汇总计算的智能合约，因为这些商业票据共享相同的命名空间。债券的情况也类似——债券保存在  `world state B` 中，  `world state B` 与另一个`bonds` 数据库形成映射，它们的key必须都是唯一的。

See how `world state A` contains two lists of commercial papers `paperListEuro`
and `paperListYen`. The states `PAP11` and `PAP21` are instances of each paper
managed by the `euroPaper` and `yenPaper` smart contracts respectively. Because
they share the same chaincode namespace, their keys (`PAPxyz`) must be unique
within the namespace of the `papers` chaincode, a little like a street name is
unique within a town. Notice how it would be possible to write a smart contract
in the `papers` chaincode that performed an aggregate calculation over all the
commercial papers -- whether priced in Euros or Yen -- because they share the
same namespace. The situation is similar for bonds -- they are held within
`world state B` which maps to a separate `bonds` database, and their keys must
be unique.

同样重要的一点是，命名空间意味着  `euroPaper` 和 `yenPaper` 无法直接访问  `world state B` ，也意味着  `euroBond` 和 `yenBond` 无法直接访问  `world state A` 。这样的分隔是有帮助的，因为商业票据和债券是相差很大的两种金融工具，它们各有不同的属性和规定。同时命名空间还意味着 `papers` 和 `bonds`  可以有相同的key，因为它们在不同的命名空间。这是有帮助的，因为它为命名提供了足够大的自由空间。以此来为不同的商业对象命名。

Just as importantly, namespaces mean that `euroPaper` and `yenPaper` cannot
directly access `world state B`, and that `euroBond` and `yenBond` cannot
directly access `world state A`. This isolation is helpful, as commercial papers
and bonds are very distinct financial instruments; they have different
attributes and are subject to different rules. It also means that `papers` and
`bonds` could have the same keys, because they are in different namespaces. This
is helpful; it provides a significant degree of freedom for naming. Use this
freedom to name different business objects meaningfully.

最重要的一点是，我们可以看到区块链是与在特定通道上运行的节点相关的，它包括了影响 `world state A` 和 `world state B` 的交易。这就解释了为什么区块链是节点中最基础的数据结构。因为世界状态集是区块链交易的汇总结构，所以它总是能从区块链中重新创建。世界状态通常仅要求该状态的当前值，所以它可以简化智能合约，提升智能合约的效率。通过命名空间来让世界状态彼此各不相同，这能帮助智能合约将各自逻辑从其他智能合约中隔离出来，而不需要担心那些与不同世界状态通信的交易。例如， `bonds`  合约不需要担心 `paper`  交易，因为该合约无法看到由它所造成的世界状态。

Most importantly, we can see that a blockchain is associated with the peer
operating in a particular channel, and that it contains transactions that affect
both `world state A` and `world state B`. That's because the blockchain is the
most fundamental data structure contained in a peer. The set of world states can
always be recreated from this blockchain, because they are the cumulative
results of the blockchain's transactions. A world state helps simplify smart
contracts and improve their efficiency, as they usually only require the current
value of a state. Keeping world states separate via namespaces helps smart
contracts isolate their logic from other smart contracts, rather than having to
worry about transactions that correspond to different world states. For example,
a `bonds` contract does not need to worry about `paper` transactions, because it
cannot see their resultant world state.

同样值得注意的是，节点，链码容器和数据库管理系统（DBMS）在逻辑上来说都是不同的过程。节点和其所有的链码容器始终位于不同的操作系统进程中，但是DBMS可被配置为嵌入或分离，这取决于它的种类。对于LevelDB来说，DBMS整体被包含在节点中，但是对于CouchDB来说，这是另外一个操作系统进程。

It's also worth noticing that the peer, chaincode containers and DBMS all are
logically different processes. The peer and all its chaincode containers are
always in physically separate operating system processes, but the DBMS can be
configured to be embedded or separate, depending on its
[type](../ledger/ledger.html#world-state-database-options). For LevelDB, the
DBMS is wholly contained within the peer, but for CouchDB, it is a separate
operating system process.

要记住，该示例中命名空间的选择是商业上要求共享不同币种商业票据的结果，但是要将商业票据与债券区别开，这一点很重要。想想如何对命名空间的结果进行修改以满足保持每个金融资产等级互不相同这一商业需求，或者来共享所有商业票据和债券。

It's important to remember that namespace choices in this example are the result
of a business requirement to share commercial papers in different currencies but
isolate them separate from bonds. Think about how the namespace structure would
be modified to meet a business requirement to keep every financial asset class
separate, or share all commercial papers and bonds?

## 通道

## Channels

如果一个节点加入了多个通道，那么将会为每个通道创建、管理一条新的区块链。而且每当有链码部署在一条新通道上，就会为其创建一个新的世界状态数据库。这就意味着通道还可以随着链码命名空间来为世界状态生成一种命名空间。

If a peer is joined to multiple channels, then a new blockchain is created
and managed for each channel. Moreover, every time a chaincode is deployed to
a new channel, a new world state database is created for it. It means that
the channel also forms a kind of namespace alongside that of the chaincode for
the world state.

然而，相同的节点和链码容器流程可同时加入多个通道，与区块链和世界状态数据库不同，这些流程不会随着加入的通道数而增加。

However, the same peer and chaincode container processes can be simultaneously
joined to multiple channels -- unlike blockchains, and world state databases,
these processes do not increase with the number of channels joined.

例如，如果链码 `papers` 和 `bonds`  在一个新的通道上被部署了，将会有一个完全不同的区块链和两个新的世界状态数据库被创建出来。但是，节点和链码容器不会随之增加；它们只会各自连接到更多相应的通道上。

For example, if you deployed the `papers` and `bonds` chaincode to a new
channel, there would a totally separate blockchain created, and two new world
state databases created. However, the peer and chaincode containers would not
increase; each would just be connected to multiple channels.

## 使用

## Usage

让我们来用商业票据的[例子](https://hyperledger-fabric.readthedocs.io/en/latest/developapps/chaincodenamespace.html#scenario)讲解一个应用程序是如何使用带有命名空间的智能合约的。值得注意的是应用程序与节点交互，该节点将请求发送到对应的链码容器，随后，该链码容器访问DBMS。请求的传输是由下图中的节点**核心**组件完成的。

Let's use our commercial paper [example](#scenario) to show how an application
uses a smart contract with namespaces. It's worth noting that an application
communicates with the peer, and the peer routes the request to the appropriate
chaincode container which then accesses the DBMS. This routing is done by the
peer **core** component shown in the diagram.

以下是使用商业票据和债券的应用程序代码，以欧元和日元定价。该代码可以说是不言自明的：

Here's the code for an application that uses both commercial papers and bonds,
priced in Euros and Yen. The code is fairly self-explanatory:

```javascript
const euroPaper = network.getContract(papers, euroPaper);
paper1 = euroPaper.submit(issue, PAP11);

const yenPaper = network.getContract(papers, yenPaper);
paper2 = yenPaper.submit(redeem, PAP21);

const euroBond = network.getContract(bonds, euroBond);
bond1 = euroBond.submit(buy, BON31);

const yenBond = network.getContract(bonds, yenBond);
bond2 = yenBond.submit(sell, BON41);
```

看一下应用程序是怎么：

See how the application:

* 访问`euroPaper` 和 `yenPaper` 合约，用 `getContract() ` API指明`paper` 的链码。看交互点**1a**和**2a**。
  
* 访问  `euroBond` 和 `yenBond`  合约，用 `getContract()`  API指明`bonds`链码。看交互点**3a**和**4a**。
  
* 向网络提交一个  `issue` 交易，以使 `PAP11`  票据使用  `euroPaper` 合约。看交互点**1a**。这就产生了由  `world state A` 中的  `PAP11`  状态代表的商业票据；交互点**1b**。这一操作在交互点**1c**上被捕获为区块链的一项交易。
  
* 向网络发送一个  `redeem` 交易，让商业票据 `PAP21` 来使用 `yenPaper` 合约。看交互点**2a**。这就产生了由   `world state A` 中 `PAP21`  代表的一个商业票据；交互点**2b**。该操作在交互点**2c**被捕获为区块链的一项交易。
  
* 向网络发送一个  `buy` 交易，让债券 `BON31` 来使用 `euroBond` 合约。看交互点**3a**。这就产生了由   `world state B` 中 `BON31`  代表的一个商业票据；交互点**3b**。该操作在交互点**3c**被捕获为区块链的一项交易。
  
* 向网络发送一个  `sell` 交易，让债券 `BON41` 来使用 `yenBond` 合约。看交互点**4a**。这就产生了由   `world state B` 中 `BON41`  代表的一个商业票据；交互点**4b**。该操作在交互点**4c**被捕获为区块链的一项交易。

* Accesses the `euroPaper` and `yenPaper` contracts using the `getContract()`
  API specifying the `papers` chaincode. See interaction points **1a** and
  **2a**.


* Accesses the `euroBond` and `yenBond` contracts using the `getContract()` API
  specifying the `bonds` chaincode. See interaction points **3a** and **4a**.

我们来看智能合约是如何与世界状态交互的：

* Submits an `issue` transaction to the network for commercial paper `PAP11`
  using the `euroPaper` contract. See interaction point **1a**. This results in
  the creation of a commercial paper represented by state `PAP11` in `world
  state A`; interaction point **1b**. This operation is captured as a
  transaction in the blockchain at interaction point **1c**.

* `euroPaper` 和 `yenPaper`  合约可直接访问 `world state A`，但无法直接访问 `world state B`。 `world state A`储存在与`papers`链码相对应的数据库管理系统中的`papers`数据库里面。
  
* `euroBond` 和 `yenBond`  合约可以直接访问`world state B`，但是无法直接访问`world state A`。`world state B`储存在与`bonds`链码相对应的数据库管理系统中的`bonds`数据库里面。

* Submits a `redeem` transaction to the network for commercial paper `PAP21`
  using the `yenPaper` contract. See interaction point **2a**. This results in
  the creation of a commercial paper represented by state `PAP21` in `world
  state A`; interaction point **2b**. This operation is captured as a
  transaction in the blockchain at interaction point **2c**.


* Submits a `buy` transaction to the network for bond `BON31` using the
  `euroBond` contract. See interaction point **3a**. This results in the
  creation of a bond represented by state `BON31` in `world state B`;
  interaction point **3b**. This operation is captured as a transaction in the
  blockchain at interaction point **3c**.

看看区块链是如何为所有世界状态捕获交易的：

* Submits a `sell` transaction to the network for bond `BON41` using the
  `yenBond` contract. See interaction point **4a**. This results in the creation
  of a bond represented by state `BON41` in `world state B`; interaction point
  **4b**. This operation is captured as a transaction in the blockchain at
  interaction point **4c**.

* 与交易相对应的交互点**1c**和**2c**分别创建和更新商业票据 `PAP11` 和 `PAP21`。它们都包含在    `world state A` 中。
  
* 与交易相对应的交互点**3c**和**4c**都会对  `BON31` 和 `BON41` 进行更新。它们都包含在`world state B` 中。
  
* 如果 `world state A` 或 `world state B` 因任何原因被破坏，可通过重新进行区块链上的所有交易来重新创建`world state A` 或 `world state B`。



See how smart contracts interact with the world state:

## 跨区块链访问

* `euroPaper` and `yenPaper` contracts can directly access `world state A`, but
  cannot directly access `world state B`. `World state A` is physically held in
  the `papers` database in the database management system (DBMS) corresponding
  to the `papers` chaincode.

如 [情景](#scenario)中的示例可见， `euroPaper` 和 `yenPaper`  无法直接访问` world state B `。这是因为我们对链码和智能合约进行了设置，使得这些链码和世界状态各自之间保持不同。不过，我们来想象一下 `euroPaper` 需要访问 `world state B`。

* `euroBond` and `yenBond` contracts can directly access `world state B`, but
  cannot directly access `world state A`. `World state B` is physically held in
  the `bonds` database in the database management system (DBMS) corresponding to
  the `bonds` chaincode.

为什么会发生这种情况呢？想象一下当发行商业票据时，智能合约想根据到期日相似的债券的当前收益情况来对票据进行定价。这种情况时，需要  `euroPaper` 合约能够在 `world state B`中查询债券价格。看以下图表来研究一下应该如何设计交互的结构。


![chaincodens.scenario](./develop.diagram.51.png) *链码和智能合约如何能够直接访问其他世界状态——通过自己的链码。*

See how the blockchain captures transactions for all world states:

注意如何：

* Interactions **1c** and **2c** correspond to transactions create and update
  commercial papers `PAP11` and `PAP21` respectively. These are both contained
  within `world state A`.

* 应用程序在`euroPaper`智能合约中发送`issue`交易来颁布`PAP11`。看交互点**1a**。
  
* `euroPaper`智能合约中的`issue`交易在`euroBond`智能合约中调用`query`交易。看交互点**1b**。
  
* `euroBond`中的`query`从`world state B`中索取信息。看交互点**1c**。
   
* 当控制返回到`issue`交易，它可利用响应中的信息对票据定价，并使用信息来更新`world state A`。看交互点**1d**。
  
* 发行以日元定价的商务票据的控制流程也是一样的。看交互点**2a**，**2b**，**2c**和**2d**。

* Interactions **3c** and **4c** correspond to transactions both update bonds
  `BON31` and `BON41`. These are both contained within `world state B`.

链码间的控制传递是利用`invokeChiancode()`
[API](https://fabric-shim.github.io/master/fabric-shim.ChaincodeStub.html#invokeChaincode__anchor)（应用程序编程端口）来实现的。该API将控制权从一个链码传递到另一个链码。

* If `world state A` or `world state B` were destroyed for any reason, they
  could be recreated by replaying all the transactions in the blockchain.

虽然我们在示例中只谈论了查询交易，但是用户也能够调用一个将更新所谓链码世界状态的智能合约。请参考下面的 [思考](#思考) 部分。


## 思考

## Cross chaincode access

* 大体上来说，每各链码都包含一个智能合约。

As we saw in our example [scenario](#scenario), `euroPaper` and `yenPaper`
cannot directly access `world state B`.  That's because we have designed our
chaincodes and smart contracts so that these chaincodes and world states are
kept separately from each other.  However, let's imagine that `euroPaper` needs
to access `world state B`.

* 若多个智能合约之间关系紧密，应该把它们部署在同一链码中。通常，只有当这些智能合约共享相同的世界状态时才需要这样做。
  
* 链码命名空间将不同的世界状态分隔开来。这大体上会将彼此不相关的数据区分开。注意，命名空间是由Hyperledger Fabric分配并直接映射到链码名字的，用户无法选择。
  
* 对于使用`invokeChaincode()`API的链码间交互，必须将这两个链码安装在相同节点上。
  
  * 对于仅需要查询被调用链码的世界状态的交互，该调用可发生在与调用发起者链码不同的通道上。
      
    * 对于需要更新背调用链码世界状态的交互，调用必须发生在与调用发起者链码相同的通道上。

Why might this happen? Imagine that when a commercial paper was issued, the
smart contract wanted to price the paper according to the current return on
bonds with a similar maturity date.  In this case it will be necessary for the
`euroPaper` contract to be able to query the price of bonds in `world state B`.
Look at the following diagram to see how we might structure this interaction.

![chaincodens.scenario](./develop.diagram.51.png) *How chaincodes and smart
contracts can indirectly access another world state -- via its chaincode.*

Notice how:

* the application submits an `issue` transaction in the `euroPaper` smart
  contract to issue `PAP11`. See interaction **1a**.

* the `issue` transaction in the `euroPaper` smart contract calls the `query`
  transaction in the `euroBond` smart contract. See interaction point **1b**.

* the `query`in `euroBond` can retrieve information from `world state B`. See
   interaction point **1c**.

* when control returns to the `issue` transaction, it can use the information in
  the response to price the paper and update `world state A` with information.
  See interaction point **1d**.

* the flow of control for issuing commercial paper priced in Yen is the same.
  See interaction points **2a**, **2b**, **2c** and **2d**.

Control is passed between chaincode using the `invokeChaincode()`
[API](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-shim.ChaincodeStub.html#invokeChaincode__anchor).

This API passes control from one chaincode to another chaincode.

Although we have only discussed query transactions in the example, it is
possible to invoke a smart contract which will update the called chaincode's
world state.  See the [considerations](#considerations) below.

## Considerations

* In general, each chaincode will have a single smart contract in it.

* Multiple smart contracts should only be deployed in the same chaincode if they
  are very closely related.  Usually, this is only necessary if they share the
  same world state.

* Chaincode namespaces provide isolation between different world states. In
  general it makes sense to isolate unrelated data from each other. Note that
  you cannot choose the chaincode namespace; it is assigned by Hyperledger
  Fabric, and maps directly to the name of the chaincode.

* For chaincode to chaincode interactions using the `invokeChaincode()` API,
  both chaincodes must be installed on the same peer.

    * For interactions that only require the called chaincode's world state to
      be queried, the invocation can be in a different channel to the caller's
      chaincode.

    * For interactions that require the called chaincode's world state to be
      updated, the invocation must be in the same channel as the caller's
      chaincode.
