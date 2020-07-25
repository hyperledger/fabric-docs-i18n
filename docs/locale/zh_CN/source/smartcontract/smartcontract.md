# 智能合约和链码
# Smart Contracts and Chaincode

**受众** ：架构师、应用程序和智能合约开发者、管理员。

**Audience**: Architects, application and smart contract developers,
administrators

从应用程序开发人员的角度来看，**智能合约**与[账本](../ledger/ledger.html)一起构成了 Hyperledger Fabric 区块链系统的核心。账本包含了与一组业务对象的当前和历史状态有关的事实，而**智能合约**定义了生成这些被添加到账本中的新事实的可执行逻辑。管理员通常使用**链码**将相关的智能合约组织起来进行部署，并且链码也可以用于 Fabric 的底层系统编程。在本主题中，我们将重点讨论为什么存在**智能合约**和**链码**，以及如何和何时使用它们。

From an application developer's perspective, a **smart contract**, together with
the [ledger](../ledger/ledger.html), form the heart of a Hyperledger Fabric
blockchain system. Whereas a ledger holds facts about the current and historical
state of a set of business objects, a **smart contract** defines the executable
logic that generates new facts that are added to the ledger. A **chaincode**
is typically used by administrators to group related smart contracts for
deployment, but can also be used for low level system programming of Fabric. In
this topic, we'll focus on why both **smart contracts** and **chaincode** exist,
and how and when to use them.

在本主题中，我们将讨论：

In this topic, we'll cover:

* [什么是智能合约](#智能合约)
* [术语说明](#术语)
* [智能合约和账本](#账本)
* [怎么开发一个智能合约](#开发)
* [背书策略的重要性](#背书)
* [验证交易](#有效交易)
* [通道和链码定义](#通道)
* [智能合约之间的通信](#互通)
* [什么是系统链码](#系统链码)

* [What is a smart contract](#smart-contract)
* [A note on terminology](#terminology)
* [Smart contracts and the ledger](#ledger)
* [How to develop a smart contract](#developing)
* [The importance of endorsement policies](#endorsement)
* [Valid transactions](#valid-transactions)
* [Channels and chaincode definitions](#channels)
* [Communicating between smart contracts](#intercommunication)
* [What is system chaincode?](#system-chaincode)

## 智能合约

## Smart contract

在各业务彼此进行交互之前，必须先定义一套通用的合约，其中包括通用术语、数据、规则、概念定义和流程。将这些合约放在一起，就构成了管理交易各方之间所有交互的**业务模型**。

Before businesses can transact with each other, they must define a common set of
contracts covering common terms, data, rules, concept definitions, and
processes. Taken together, these contracts lay out the **business model** that
govern all of the interactions between transacting parties.

![smart.diagram1](./smartcontract.diagram.01.png) 

![smart.diagram1](./smartcontract.diagram.01.png) *A smart contract defines the
rules between different organizations in executable code. Applications invoke a
smart contract to generate transactions that are recorded on the ledger.*

*智能合约用可执行的代码定义了不同组织之间的规则。应用程序调用智能合约来生成被记录到账本上的交易。*

Using a blockchain network, we can turn these contracts into executable programs
-- known in the industry as **smart contracts** -- to open up a wide variety of
new possibilities. That's because a smart contract can implement the governance
rules for **any** type of business object, so that they can be automatically
enforced when the smart contract is executed. For example, a smart contract
might ensure that a new car delivery is made within a specified timeframe, or
that funds are released according to prearranged terms, improving the flow of
goods or capital respectively. Most importantly however, the execution of a
smart contract is much more efficient than a manual human business process.

使用区块链网络，我们可以将这些合约转换为可执行程序（业内称为**智能合约**），从而实现了各种各样的新可能性。这是因为智能合约可以为**任何**类型的业务对象实现治理规则，以便在执行智能合约时自动执行这些规则。例如，一个智能合约可能会确保新车在指定的时间内交付，或者根据预先安排的条款释放资金，前者可改善货物流通，而后者可优化资本流动。然而最重要的是，智能合约的执行要比人工业务流程高效得多。

In the [diagram above](#smart-contract), we can see how two organizations,
`ORG1` and `ORG2` have defined a `car` smart contract to `query`, `transfer` and
`update` cars.  Applications from these organizations invoke this smart contract
to perform an agreed step in a business process, for example to transfer
ownership of a specific car from `ORG1` to `ORG2`.

在[上图](#智能合约)中，我们可以看到组织 `ORG1` 和 `ORG2` 是如何通过定义一个 `car` 智能合约来实现 `查询`、`转移` 和 `更新` 汽车的。来自这些组织的应用程序调用此智能合约执行业务流程中已商定的步骤，例如将特定汽车的所有权从 `ORG1` 转移到 `ORG2`。


## 术语

## Terminology

Hyperledger Fabric 用户经常交替使用**智能合约**和**链码**。通常，智能合约定义的是控制世界状态中业务对象生命周期的**交易逻辑**，随后该交易逻辑被打包进链码，紧接着链码会被部署到区块链网络中。可以将智能合约看成交易的管理者，而链码则管理着如何将智能合约打包以便用于部署。

Hyperledger Fabric users often use the terms **smart contract** and
**chaincode** interchangeably. In general, a smart contract defines the
**transaction logic** that controls the lifecycle of a business object contained
in the world state. It is then packaged into a chaincode which is then deployed
to a blockchain network.  Think of smart contracts as governing transactions,
whereas chaincode governs how smart contracts are packaged for deployment.

![smart.diagram2](./smartcontract.diagram.02.png) 

![smart.diagram2](./smartcontract.diagram.02.png) *A smart contract is defined
within a chaincode.  Multiple smart contracts can be defined within the same
chaincode. When a chaincode is deployed, all smart contracts within it are made
available to applications.*

*一个智能合约定义在一个链码中。而多个智能合约也可以定义在同一个链码中。当一个链码部署完毕，该链码中的所有智能合约都可供应用程序使用。*

In the diagram, we can see a `vehicle` chaincode that contains three smart
contracts: `cars`, `boats` and `trucks`.  We can also see an `insurance`
chaincode that contains four smart contracts: `policy`, `liability`,
`syndication` and `securitization`.  In both cases these contracts cover key
aspects of the business process relating to vehicles and insurance. In this
topic, we will use the `car` contract as an example. We can see that a smart
contract is a domain specific program which relates to specific business
processes, whereas a chaincode is a technical container of a group of related
smart contracts.

从上图中我们可以看到，`vehicle` 链码包含了以下三个智能合约：`cars`、`boats ` 和 `trucks`；而 `insurance` 链码包含了以下四个智能合约：`policy`、`liability`、`syndication` 和 `securitization`。以上每种智能合约都涵盖了与车辆和保险有关的业务流程的一些关键点。在本主题中，我们将以 `car` 智能合约为例。我们可以看到，智能合约是一个特定领域的程序，它与特定的业务流程相关，而链码则是一组相关智能合约安装和实例化的技术容器。


## 账本

## Ledger

以最简单的方式来说，区块链记录着更新账本状态的交易，且记录不可篡改。智能合约以编程方式访问账本两个不同的部分：一个是**区块链**（记录所有交易的历史，且记录不可篡改），另一个是**世界状态**（保存这些状态当前值的缓存，是经常需要用到的对象的当前值）。

At the simplest level, a blockchain immutably records transactions which update
states in a ledger. A smart contract programmatically accesses two distinct
pieces of the ledger -- a **blockchain**, which immutably records the history of
all transactions, and a **world state** that holds a cache of the current value
of these states, as it's the current value of an object that is usually
required.

智能合约主要在世界状态中将状态**写入**（put）、**读取**（get）和**删除**（delete），还可以查询不可篡改的区块链交易记录。

Smart contracts primarily **put**, **get** and **delete** states in the world
state, and can also query the immutable blockchain record of transactions.

* **读取（get）** 操作一般代表的是查询，目的是获取关于交易对象当前状态的信息。
* **写入（put）** 操作通常生成一个新的业务对象或者对账本世界状态中现有的业务对象进行修改。
* **删除（delete）** 操作代表的是将一个业务对象从账本的当前状态中移除，但不从账本的历史中移除。

* A **get** typically represents a query to retrieve information about the
  current state of a business object.
* A **put** typically creates a new business object or modifies an existing one
  in the ledger world state.
* A **delete** typically represents the removal of a business object from the
  current state of the ledger, but not its history.

智能合约有许多可用的 [API](../developapps/transactioncontext.html#structure)。但重要的是，在任意情况下，无论交易创建、读取、更新还是删除世界状态中的业务对象，区块链都包含了这些操作的记录，且[记录不可更改](../ledger/ledger.html) 。

Smart contracts have many
[APIs](../developapps/transactioncontext.html#structure) available to them.
Critically, in all cases, whether transactions create, read, update or delete
business objects in the world state, the blockchain contains an [immutable
record](../ledger/ledger.html) of these changes.

## 开发

## Development

智能合约是应用程序开发的重点，正如我们所看到的，一个链码中可定义一个或多个智能合约。将链码部署到网络中以后，网络上的组织就都可以使用该链码中的所有智能合约。这意味着只有管理员才需要考虑链码；其他人都只用考虑智能合约。

Smart contracts are the focus of application development, and as we've seen, one
or more smart contracts can be defined within a single chaincode.  Deploying a
chaincode to a network makes all its smart contracts available to the
organizations in that network. It means that only administrators need to worry
about chaincode; everyone else can think in terms of smart contracts.

智能合约的核心是一组 `交易` 定义。例如，在 [`fabcar.js`](https://github.com/hyperledger/fabric-samples/blob/master/chaincode/fabcar/javascript/lib/fabcar.js#L93) 中，你可以看到一个创建了一辆新车的智能合约交易：

At the heart of a smart contract is a set of `transaction` definitions. For
example, look at fabcar.js
[here](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/javascript/lib/fabcar.js#L93),
where you can see a smart contract transaction that creates a new car:

```javascript
async createCar(ctx, carNumber, make, model, color, owner) {

    const car = {
        color,
        docType: 'car',
        make,
        model,
        owner,
    };

    await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
}
```

在[编写您的第一个应用程序](../write_first_app.html) 教程中，您可以了解更多关于 **Fabcar** 智能合约的信息。

You can learn more about the **Fabcar** smart contract in the [Writing your
first application](../write_first_app.html) tutorial.

智能合约几乎可以描述所有与多组织决策中数据不可变性相关的业务案例。智能合约开发人员的工作是将一个现有的业务流程（可能是管理金融价格或交付条件）用 JavaScript、GOLANG 或 Java 等编程语言来表示成一个智能合约。将数百年的法律语言转换为编程语言需要法律和技术方面的技能，**智能合约审核员**们不断地实践着这些技能。您可以在[开发应用程序主题](../developapps/developing_applications.html)中了解如何设计和开发智能合约。

A smart contract can describe an almost infinite array of business use cases
relating to immutability of data in multi-organizational decision making. The
job of a smart contract developer is to take an existing business process that
might govern financial prices or delivery conditions, and express it as
a smart contract in a programming language such as JavaScript, Go, or Java.
The legal and technical skills required to convert centuries of legal language
into programming language is increasingly practiced by **smart contract
auditors**. You can learn about how to design and develop a smart contract in
the [Developing applications
topic](../developapps/developing_applications.html).

## 背书


每个链码都有一个背书策略与之相关联，该背书策略适用于此链码中定义的所有智能合约。背书策略非常重要，它指明了区块链网络中哪些组织必须对一个给定的智能合约所生成的交易进行签名，以此来宣布该交易**有效**。

## Endorsement

![smart.diagram3](./smartcontract.diagram.03.png) 

Associated with every chaincode is an endorsement policy that applies to all of
the smart contracts defined within it. An endorsement policy is very important;
it indicates which organizations in a blockchain network must sign a transaction
generated by a given smart contract in order for that transaction to be declared
**valid**.

*每个智能合约都有一个与之关联的背书策略。这个背书策略定义了在智能合约生成的交易被认证为有效之前，哪些组织必须同意该交易。*

![smart.diagram3](./smartcontract.diagram.03.png) *Every smart contract has an
endorsement policy associated with it. This endorsement policy identifies which
organizations must approve transactions generated by the smart contract before
those transactions can be identified as valid.*

一个示例背书策略可能这样定义：参与区块链网络的四个组织中有三个必须在交易被认为**有效**之前签署该交易。所有的交易，无论是**有效的**还是**无效的**，都会被添加到分布式账本中，但只有**有效**交易会更新世界状态。

An example endorsement policy might define that three of the four organizations
participating in a blockchain network must sign a transaction before it is
considered **valid**. All transactions, whether **valid** or **invalid** are
added to a distributed ledger, but only **valid** transactions update the world
state.

如果一项背书策略指定了必须有不止一个组织来签署交易，那么只有当足够数量的组织都执行了智能合约，才能够生成有效交易。在[上面](#背书)的示例中，要使用于车辆 `transfer` 的智能合约交易有效，需要 `ORG1` 和 `ORG2` 都执行并签署该交易。

If an endorsement policy specifies that more than one organization must sign a
transaction, then the smart contract must be executed by a sufficient set of
organizations in order for a valid transaction to be generated. In the example
[above](#endorsement), a smart contract transaction to `transfer` a car would
need to be executed and signed by both `ORG1` and `ORG2` for it to be valid.

背书策略是 Hyperledger Fabric 与以太坊（Ethereum）或比特币（Bitcoin）等其他区块链的区别所在。在这些区块链系统中，网络上的任何节点都可以生成有效的交易。而 Hyperledger Fabric 更真实地模拟了现实世界；交易必须由 Fabric 网络中受信任的组织验证。例如，一个政府组织必须签署一个有效的 `issueIdentity` 交易，或者一辆车的 `买家` 和 `卖家` 都必须签署一个 `车辆` 转移交易。背书策略的设计旨在让 Hyperledger Fabric 更好地模拟这些真实发生的交互。

Endorsement policies are what make Hyperledger Fabric different to other
blockchains like Ethereum or Bitcoin. In these systems valid transactions can be
generated by any node in the network. Hyperledger Fabric more realistically
models the real world; transactions must be validated by trusted organizations
in a network. For example, a government organization must sign a valid
`issueIdentity` transaction, or both the `buyer` and `seller` of a car must sign
a `car` transfer transaction. Endorsement policies are designed to allow
Hyperledger Fabric to better model these types of real-world interactions.

最后，背书策略只是 Hyperledger Fabric 中[策略](../access_control.html#policies)的一个例子。还可以定义其他策略来确定谁可以查询或更新账本，或者谁可以在网络中添加或删除参与者。总体来说，虽然区块链网络中的组织联盟并非一成不变，但是它们需要事先商定好策略。实际上，策略本身可以定义对自己进行更改的规则。虽然现在谈论这个主题有点早，但是在 Fabric 提供的规则基础上来定义[自定义背书策略](../pluggable_endorsement_and_validation.html)的规则也是可能实现的。

Finally, endorsement policies are just one example of
[policy](../access_control.html#policies) in Hyperledger Fabric. Other policies
can be defined to identify who can query or update the ledger, or add or remove
participants from the network. In general, policies should be agreed in advance
by the consortium of organizations in a blockchain network, although they are
not set in stone. Indeed, policies themselves can define the rules by which they
can be changed. And although an advanced topic, it is also possible to define
[custom endorsement policy](../pluggable_endorsement_and_validation.html) rules
over and above those provided by Fabric.

## 有效交易

## Valid transactions

当智能合约执行时，它会在区块链网络中组织所拥有的节点上运行。智能合约提取一组名为**交易提案**的输入参数，并将其与程序逻辑结合起来使用以读写账本。对世界状态的更改被捕获为**交易提案响应**（或简称**交易响应**），该响应包含一个**读写集**，其中既含有已读取的状态，也含有还未书写的新状态（如果交易有效的话）。注意，在执行智能合约时**世界状态没有更新**！

When a smart contract executes, it runs on a peer node owned by an organization
in the blockchain network. The contract takes a set of input parameters called
the **transaction proposal** and uses them in combination with its program logic
to read and write the ledger. Changes to the world state are captured as a
**transaction proposal response** (or just **transaction response**) which
contains a **read-write set** with both the states that have been read, and the
new states that are to be written if the transaction is valid. Notice that the
world state **is not updated when the smart contract is executed**!

![smart.diagram4](./smartcontract.diagram.04.png) 

![smart.diagram4](./smartcontract.diagram.04.png) *All transactions have an
identifier, a proposal, and a response signed by a set of organizations. All
transactions are recorded on the blockchain, whether valid or invalid, but only
valid transactions contribute to the world state.*

*所有的交易都有一个识别符、一个提案和一个被一群组织签名的响应。所有交易，无论是否有效，都会被记录在区块链上，但仅有效交易会更新世界状态。*

Examine the `car transfer` transaction. You can see a transaction `t3` for a car
transfer between `ORG1` and `ORG2`. See how the transaction has input `{CAR1,
ORG1, ORG2}` and output `{CAR1.owner=ORG1, CAR1.owner=ORG2}`, representing the
change of owner from `ORG1` to `ORG2`. Notice how the input is signed by the
application's organization `ORG1`, and the output is signed by *both*
organizations identified by the endorsement policy, `ORG1` and `ORG2`.  These
signatures were generated by using each actor's private key, and mean that
anyone in the network can verify that all actors in the network are in agreement
about the transaction details.

检查 `车辆转移` 交易。您可以看到 `ORG1` 和 `ORG2` 之间为转移一辆车而进行的交易 `t3`。看一下交易是如何通过输入 `{CAR1，ORG1，ORG2}` 和输出 `{CAR1.owner=ORG1，CAR1.owner=ORG2}` 来表示汽车的所有者从 `ORG1` 变为了 `ORG2`。注意输入是如何由应用程序的组织 `ORG1` 签名的，输出是如何由背书策略标识的*两个*组织（ `ORG1` 和 `ORG2` ）签名的。这些签名是使用每个参与者的私钥生成的，这意味着网络中的任何人都可以验证网络中的所有参与者是否在交易细节上达成了一致。

A transaction that is distributed to all peer nodes in the network is
**validated** in two phases by each peer. Firstly, the transaction is checked to
ensure it has been signed by sufficient organizations according to the endorsement
policy. Secondly, it is checked to ensure that the current value of the world state
matches the read set of the transaction when it was signed by the endorsing peer
nodes; that there has been no intermediate update. If a transaction passes both
these tests, it is marked as **valid**. All transactions are added to the
blockchain history, whether **valid** or **invalid**, but only **valid**
transactions result in an update to the world state.

一项交易被分发给网络中的所有节点，各节点通过两个阶段对其进行**验证**。首先，根据背书策略检查交易，确保该交易已被足够的组织签署。其次，继续检查交易，以确保当该交易在受到背书节点签名时它的交易读集与世界状态的当前值匹配，并且中间过程中没有被更新。如果一个交易通过了这两个测试，它就被标记为**有效**。所有交易，不管是**有效的**还是**无效的**，都会被添加到区块链历史中，但是仅**有效的**交易才会更新世界状态。

In our example, `t3` is a valid transaction, so the owner of `CAR1` has been
updated to `ORG2`. However, `t4` (not shown) is an invalid transaction, so while
it was recorded in the ledger, the world state was not updated, and `CAR2`
remains owned by `ORG2`.

在我们的示例中，`t3` 是一个有效的交易，因此 `CAR1` 的所有者已更新为 `ORG2`。但是 `t4` （未显示）是无效的交易，所以当把它记录在账本上时，世界状态没有更新，`CAR2` 仍然属于 `ORG2` 所有。

Finally, to understand how to use a smart contract or chaincode with world
state, read the [chaincode namespace
topic](../developapps/chaincodenamespace.html).

最后，要了解如何通过世界状态来使用智能合约或链码，请阅读[链码命名空间主题](../developapps/chaincodenamespace.html)。

## Channels

## 通道

Hyperledger Fabric allows an organization to simultaneously participate in
multiple, separate blockchain networks via **channels**. By joining multiple
channels, an organization can participate in a so-called **network of networks**.
Channels provide an efficient sharing of infrastructure while maintaining data
and communications privacy. They are independent enough to help organizations
separate their work traffic with different counterparties, but integrated enough
to allow them to coordinate independent activities when necessary.

Hyperledger Fabric 允许一个组织利用**通道**同时参与多个、彼此独立的区块链网络。通过加入多个通道，一个组织可以参与一个所谓的**网络的网络**。通道在维持数据和通信隐私的同时还提供了高效的基础设施共享。通道是足够独立的，可以帮助组织将自己的工作与其他组织的分开，同时它还具有足够的协调性，在必要时能够协调各个独立的活动。

![smart.diagram5](./smartcontract.diagram.05.png) *A channel provides a
completely separate communication mechanism between a set of organizations. When
a chaincode definition is committed to a channel, all the smart contracts within
the chaincode are made available to the applications on that channel.*

![smart.diagram5](./smartcontract.diagram.05.png) 

While the smart contract code is installed inside a chaincode package on an
organizations peers, channel members can only execute a smart contract after
the chaincode has been defined on a channel. The **chaincode definition** is a
struct that contains the parameters that govern how a chaincode operates. These
parameters include the chaincode name, version, and the endorsement policy.
Each channel member agrees to the parameters of a chaincode by approving a
chaincode definition for their organization. When a sufficient number of
organizations (a majority by default) have approved to the same chaincode
definition, the definition can be committed to the channel. The smart contracts
inside the chaincode can then be executed by channel members, subject to the
endorsement policy specified in the chaincode definition. The endorsement policy
applies equally to all smart contracts defined within the same chaincode.

*通道在一群组织之间提供了一种完全独立的通信机制。当链码定义被提交到通道上时，该通道上所有的应用程序都可以使用此链码中的智能合约。*

In the example [above](#channels), a `car` contract is defined on the `VEHICLE`
channel, and an `insurance` contract is defined on the `INSURANCE` channel.
The chaincode definition of `car` specifies an endorsement policy that requires
both `ORG1` and `ORG2` to sign transactions before they can be considered valid.
The chaincode definition of the `insurance` contract specifies that only `ORG3`
is required to endorse a transaction. `ORG1` participates in two networks, the
`VEHICLE` channel and the `INSURANCE` network, and can coordinate activity with
`ORG2` and `ORG3` across these two networks.

虽然智能合约代码被安装在组织节点的链码包内，但是只有等到链码被定义在通道上之后，该通道上的成员才能够执行其中的智能合约。链码定义是一种包含了许多参数的结构，这些参数管理着链码的运行方式，包含着链码名、版本以及背书策略。各通道成员批准各自组织的一个链码定义，以表示其对该链码的参数表示同意。当足够数量（默认是大多数）的组织都已批准同一个链码定义，该定义可被提交至这些组织所在的通道。随后，通道成员可依据该链码定义中指明的背书策略来执行其中的智能合约。这个背书策略可同等使用于在相同链码中定义的所有智能合约。

The chaincode definition provides a way for channel members to agree on the
governance of a chaincode before they start using the smart contract to
transact on the channel. Building on the example above, both `ORG1` and `ORG2`
want to endorse transactions that invoke the `car` contract. Because the default
policy requires that a majority of organizations approve a chaincode definition,
both organizations need to approve an endorsement policy of `AND{ORG1,ORG2}`.
Otherwise, `ORG1` and `ORG2` would approve different chaincode definitions and
would be unable to commit the chaincode definition to the channel as a result.
This process guarantees that a transaction from the `car` smart contract needs
to be approved by both organizations.

在[上面](#通道)的示例中，`car` 智能合约被定义在 `VEHICLE` 通道上，`insurance` 智能合约被定义在 `INSURANCE` 通道上。`car` 的链码定义明确了以下背书策略：任何交易在被认定为有效之前必须由 `ORG1` 和 `ORG2` 共同签名。`insurance` 智能合约的链码定义明确了只需要 `ORG3` 对交易进行背书即可。`ORG1` 参与了 `VEHICLE` 通道和 `INSURANCE` 通道这两个网络，并且能够跨网络协调与 `ORG2` 和 `ORG3` 的活动。

## Intercommunication

链码的定义为通道成员提供了一种他们在通道上使用智能合约来交易之前，同意对于一个链码的管理的方式。在上边的例子中，`ORG1` 和 `ORG2` 想要为调用 `car` 智能合约的交易背书。因为默认的背书策略要求主要的组织需要批准一个链码的定义，双方的组织需要批准一个 `AND{ORG1,ORG2}` 的背书策略。否则的话，`ORG1` 和 `ORG2` 将会批准不同的链码定义，并且最终不能够将链码定义提交到通道。这个流程确保了一个来自于 `car` 智能合约的交易需要被两个组织批准。

A Smart Contract can call other smart contracts both within the same
channel and across different channels. It this way, they can read and write
world state data to which they would not otherwise have access due to smart
contract namespaces.

## 互通

There are limitations to this inter-contract communication, which are described
fully in the [chaincode namespace](../developapps/chaincodenamespace.html#cross-chaincode-access) topic.

一个智能合约既可以调用同通道上的其他智能合约，也可以调用其他通道上的智能合约。这样一来，智能合约就可以读写原本因为智能合约命名空间而无法访问的世界状态数据。

## System chaincode

这些都是智能合约彼此通信的限制，我们将在[链码命名空间](../developapps/chaincodenamespace.html#cross-chaincode-access)主题中详细描述。

The smart contracts defined within a chaincode encode the domain dependent rules
for a business process agreed between a set of blockchain organizations.
However, a chaincode can also define low-level program code which corresponds to
domain independent *system* interactions, unrelated to these smart contracts
for business processes.

## 系统链码

The following are the different types of system chaincodes and their associated
abbreviations:

链码中定义的智能合约为一群区块链组织共同认可的业务流程编码了领域相关规则。然而，链码还可以定义低级别程序代码，这些代码符合无关于领域的*系统*交互，但与业务流程的智能合约无关。

* `_lifecycle` runs in all peers and manages the installation of chaincode on
  your peers, the approval of chaincode definitions for your organization, and
  the committing of chaincode definitions to channels. You can read more about
  how `_lifecycle` implements the Fabric chaincode lifecycle [process](../chaincode_lifecycle.html).

以下是不同类型的系统链码及其相关缩写：

* Lifecycle system chaincode (LSCC) manages the chaincode lifecycle for the
  1.x releases of Fabric. This version of lifecycle required that chaincode be
  instantiated or upgraded on channels. You can still use LSCC to manage your
  chaincode if you have the channel application capability set to V1_4_x or below.

* **_lifecycle** 在所有 Peer 节点上运行，它负责管理节点上的链码安装、批准组织的链码定义、将链码定义提交到通道上。你可以在[这里](../chaincode4noah.html)阅读更多关于 `_lifecycle` 如何实现 Fabric 链码生命周期的内容。

* **Configuration system chaincode (CSCC)** runs in all peers to handle changes to a
  channel configuration, such as a policy update.  You can read more about this
  process in the following chaincode
  [topic](../configtx.html#configuration-updates).

* **生命周期系统链码（LSCC）** 负责为1.x版本的 Fabric 管理链码生命周期。该版本的生命周期要求在通道上实例化或升级链码。你可以阅读更多关于 LSCC 如何实现这一[过程](../chaincode4noah.html)。如果你的 V1_4_x 或更低版本设有通道应用程序的功能，那么你也可以使用 LSCC 来管理链码。

* **Query system chaincode (QSCC)** runs in all peers to provide ledger APIs which
  include block query, transaction query etc. You can read more about these
  ledger APIs in the transaction context
  [topic](../developapps/transactioncontext.html).

* **配置系统链码（CSCC）** 在所有 Peer 节点上运行，以处理通道配置的变化，比如策略更新。你可以在[这里](../configtx.html#configuration-updates)阅读更多 CSCC 实现的内容。

* **Endorsement system chaincode (ESCC)** runs in endorsing peers to
  cryptographically sign a transaction response. You can read more about how
  the ESCC implements this [process](../peers/peers.html#phase-1-proposal).

* **查询系统链码（QSCC）** 在所有 Peer 节点上运行，以提供账本 API（应用程序编码接口），其中包括区块查询、交易查询等。你可以在交易场景[主题](../developapps/transactioncontext.html)中查阅更多这些账本 API 的信息。

* **Validation system chaincode (VSCC)** validates a transaction, including checking
  endorsement policy and read-write set versioning. You can read more about the
  VSCC implements this [process](../peers/peers.html#phase-3-validation).

* **背书系统链码（ESCC）** 在背书节点上运行，对一个交易响应进行密码签名。你可以在[这里](../peers/peers.html#phase-1-proposal)阅读更多 ESCC 实现的内容。

It is possible for low level Fabric developers and administrators to modify
these system chaincodes for their own uses. However, the development and
management of system chaincodes is a specialized activity, quite separate from
the development of smart contracts, and is not normally necessary. Changes to
system chaincodes must be handled with extreme care as they are fundamental to
the correct functioning of a Hyperledger Fabric network. For example, if a
system chaincode is not developed correctly, one peer node may update its copy
of the world state or blockchain differently compared to another peer node. This
lack of consensus is one form of a **ledger fork**, a very undesirable situation.

* **验证系统链码（VSCC）** 验证一个交易，包括检查背书策略和读写集版本。你可以在[这里](../peers/peers.html#phase-3-validation)阅读更多 LSCC 实现的内容。

底层的 Fabric 开发人员和管理员可以根据自己的需要修改这些系统链码。然而，系统链码的开发和管理是一项专门的活动，完全独立于智能合约的开发，通常没有必要进行系统链码的开发和管理。系统链码对于一个  Hyperledger Fabric 网络的正常运行至关重要，因此必须非常小心地处理系统链码的更改。例如，如果没有正确地开发系统链码，那么有可能某个 Peer 节点更新的世界状态或区块链备份与其他 Peer 节点的不同。这种缺乏共识的现象是**账本分叉**的一种形式，是极不理想的情况。
