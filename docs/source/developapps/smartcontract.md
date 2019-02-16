# Smart Contract Processing - 智能合约处理

**Audience**: Architects, Application and smart contract developers

**受众** ：建筑师，应用程序和智能合约开发人员

At the heart of a blockchain network is a smart contract. In PaperNet, the code
in the commercial paper smart contract defines the valid states for commercial
paper, and the transaction logic that transition a paper from one state to
another. In this topic, we're going to show you how to implement a real world
smart contract that governs the process of issuing, buying and redeeming
commercial paper. 

区块链网络的核心是智能合约。 在PaperNet中，商业票据智能合约中的代码定义了商业票据的有效状态，
以及将票据从一种状态状态转变为另一种状态的交易逻辑。 在本主题中，我们将向您展示如何实现一个真实世界的
智能合约，该合约管理发行、购买和兑换商业票据的过程。

We're going to cover:

* [What is a smart contract and why it's important](#smart-contract)
* [How to define a smart contract](#contract-class)
* [How to define a transaction](#transaction-definition)
* [How to implement a transaction](#transaction-logic)
* [How to represent a business object in a smart contract](#representing-an-object)
* [How to store and retrieve an object in the ledger](#access-the-ledger)

我们将会介绍:

* [什么是智能合约以及智能合约为什么重要](#smart-contract)
* [如何定义智能合约](#contract-class)
* [如何定义交易](#transaction-definition)
* [如何实现一笔交易](#transaction-logic)
* [如何在智能合约中表示业务对象](#representing-an-object)
* [如何在账本中存储和检索对象](#access-the-ledger)

If you'd like, you can [download the sample](../install.html) and even [run it
locally](../tutorial/commercial_paper.html). It is written in JavaScript, but
the logic is quite language independent, so you'll be easily able to see what's
going on! (The sample will become available for Java and GOLANG as well.)

如果您愿意，可以 [下载样本](../install.html) ，甚至可以 [在本地运行](../tutorial/commercial_paper.html)。 
它是用JavaScript编写的，但逻辑与语言无关，因此您可以轻松地查看正在发生的事情！（该示例也可用于Java和GOLANG。）

## Smart Contract - 智能合约

A smart contract defines the different states of a business object and governs
the processes that move the object between these different states. Smart
contracts are important because they allow architects and smart contract
developers to define the key business processes and data that are shared across
the different organizations collaborating in a blockchain network.

智能合约定义业务对象的不同状态，并管理对象在不同状态之间变化的过程。 智能合约很重要，因为它们允许架构师
和智能合约开发人员定义在区块链网络中协作的不同组织之间共享的关键业务流程和数据。

In the PaperNet network, the smart contract is shared by the different network
participants, such as MagnetoCorp and DigiBank.  The same version of the smart
contract must be used by all applications connected to the network so that they
jointly implement the same shared business processes and data.

在PaperNet网络中，智能合约由不同的网络参与者共享，例如MagnetoCorp和DigiBank。 连接到网络的
所有应用程序必须使用相同版本的智能合约，以便它们共同实现相同的共享业务流程和数据。

## Contract class - 合约类

A copy of the PaperNet commercial paper smart contract is contained in
`papercontract.js`. [View
it](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
with your browser, or open it in your favourite editor if you've downloaded it.

PaperNet商业票据智能合约的副本包含在`papercontract.js`中. [View
                      it](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)。 
                      如果您已下载，请使用浏览器查看，或在您喜欢的编辑器中打开它。

You may notice from the file path that this is MagnetoCorp's copy of the smart
contract.  MagnetoCorp and DigiBank must agree the version of the smart contract
that they are going to use. For now, it doesn't matter which organization's copy
you look at, they are all the same.

您可能会从文件路径中注意到这是MagnetoCorp的智能合约副本。 MagnetoCorp和DigiBank必须同意他们
将要使用的智能合约版本。 现在，你看哪个组织的合约副本无关紧要，它们都是一样的。

Spend a few moments looking at the overall structure of the smart contract;
notice that it's quite short! Towards the top of `papercontract.js`, you'll see
that there's a definition for the commercial paper smart contract:

花一些时间看一下智能合约的整体结构; 注意它很短！ 在`papercontract.js`的顶部，您将看到商业票据智能合约的定义：

```JavaScript
class CommercialPaperContract extends Contract {...}
```

The `CommercialPaperContract`
[class](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)
contains the transaction definitions for commercial paper -- **issue**, **buy**
and **redeem**. It's these transactions that bring commercial papers into
existence and move them through their lifecycle. We'll examine these
[transactions](#transaction-definition) soon, but for now notice how
`CommericalPaperContract` extends the Hyperledger Fabric `Contract`
[class](https://fabric-shim.github.io/release-1.4/fabric-contract-api.Contract.html).
This built-in class, and the `Context` class, were brought into scope earlier:

 `CommercialPaperContract`
[类](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)
包含商业票据的交易定义 -- **发行**、 **购买**和**兑换**。 正是这些交易带来了商业票据的存在，
并将它们贯穿整个生命周期。 我们很快就会检查这些[交易](#transaction-definition) ，但现在请注意`CommericalPaperContract`如何扩展
Hyperledger Fabric Contract `Contract`[类](https://fabric-shim.github.io/release-1.4/fabric-contract-api.Contract.html)。 
这个内置类和`Context`类开始就被导入进代码区域：

```JavaScript
const { Contract, Context } = require('fabric-contract-api');
```

Our commercial paper contract will use built-in features of these classes, such
as automatic method invocation, a
[per-transaction context](./transactioncontext.html),
[transaction handlers](./transactionhandler.html), and class-shared state.

我们的商业票据合约将使用这些类的内置功能，例如自动方法调用， [每个交易上下文](./transactioncontext.html),
[交易处理器](./transactionhandler.html)，和类共享状态。

Notice also how the class constructor uses its
[superclass](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)
to initialize itself with a [namespace](./namespace.html):

还要注意类构造函数如何使用其[超类](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)
通过一个[命名空间](./namespace.html)来初始化自身：

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

Most importantly, `org.papernet.commercialpaper` is very descriptive -- this smart
contract is the agreed definition of commercial paper for all PaperNet
organizations.

最重要的是， `org.papernet.commercialpaper` 非常具有描述性 - 这份智能合约是所有PaperNet组织关于商业票据的商定定义。

Usually there will only be one smart contract per file -- contracts tend to have
different lifecycles, which makes it sensible to separate them. However, in some
cases, multiple smart contracts might provide syntactic help for applications,
e.g. `EuroBond`, `DollarBond`, `YenBond`, but essentially provide the same
function. In such cases, smart contracts and transactions can be disambiguated.

通常每个文件只有一个智能合约 - 合约往往有不同的生命周期，这使得将它们分开是明智的。 但是，在某些情况下，
多个智能合约可能会为应用程序提供语法帮助，例如`EuroBond`、`DollarBond`、`YenBond`
但基本上提供相同的功能。 在这种情况下，智能合约和交易可以消除歧义。

## Transaction definition

Within the class, locate the **issue** method.

```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```

This function is given control whenever this contract is called to `issue` a
commercial paper. Recall how commercial paper 00001 was created with the
following transaction:

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

We've changed the variable names for programming style, but see how these
properties map almost directly to the `issue` method variables.

The `issue` method is automatically given control by the contract whenever an
application makes a request to issue a commercial paper. The transaction
property values are made available to the method via the corresponding
variables. See how an application submits a transaction using the Hyperledger
Fabric SDK in the [application](./application.html) topic, using a sample
application program.

You might have noticed an extra variable in the **issue** definition -- `ctx`.
It's called the [**transaction context**](./transactioncontext.html), and it's
always first. By default, it maintains both per-contract and per-transaction
information relevant to [transaction logic](#transaction-logic). For example, it
would contain MagnetoCorp's specified transaction identifier, a MagnetoCorp
issuing user's digital certificate, as well as access to the ledger API.

See how the smart contract extends the default transaction context by
implementing its own `createContext()` method rather than accepting the
default implementation:

```JavaScript
createContext() {
  return new CommercialPaperContext()
}
```

This extended context adds a custom property `paperList` to the defaults:

```JavaScript
class CommercialPaperContext extends Context {

  constructor() {
    super();
    // All papers are held in a list of papers
    this.paperList = new PaperList(this);
}
```

We'll soon see how `ctx.paperList` can be subsequently used to help store and
retrieve all PaperNet commercial papers.

To solidify your understanding of the structure of a smart contract transaction,
locate the **buy** and **redeem** transaction definitions, and see if you can
see how they map to their corresponding commercial paper transactions.

The **buy** transaction:

```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseTime) {...}
```

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

The **redeem** transaction:

```JavaScript
async redeem(ctx, issuer, paperNumber, redeemingOwner, redeemDateTime) {...}
```

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Redeemer = DigiBank
Redeem time = 31 Dec 2020 12:00:00 EST
```

In both cases, observe the 1:1 correspondence between the commercial paper
transaction and the smart contract method definition.  And don't worry about the
`async` and `await`
[keywords](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
-- they allow asynchronous JavaScript functions to be treated like their
synchronous cousins in other programming languages.


## Transaction logic

Now that you've seen how contracts are structured and transactions are defined,
let's focus on the logic within the smart contract.

Recall the first **issue** transaction:

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

It results in the **issue** method being passed control:

```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

   // create an instance of the paper
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);

  // Smart contract, rather than paper, moves paper into ISSUED state
  paper.setIssued();

  // Newly issued paper is owned by the issuer
  paper.setOwner(issuer);

  // Add the paper to the list of all similar commercial papers in the ledger world state
  await ctx.paperList.addPaper(paper);

  // Must return a serialized paper to caller of smart contract
  return paper.toBuffer();
}
  ```

The logic is simple: take the transaction input variables, create a new
commercial paper `paper`, add it to the list of all commercial papers using
`paperList`, and return the new commercial paper (serialized as a buffer) as the
transaction response.

See how `paperList` is retrieved from the transaction context to provide access
to the list of commercial papers. `issue()`, `buy()` and `redeem()` continually
re-access `ctx.paperList` to keep the list of commercial papers up-to-date.

The logic for the **buy** transaction is a little more elaborate:

```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

  // Retrieve the current paper using key fields provided
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

  // Validate current owner
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

  // First buy moves state from ISSUED to TRADING
  if (paper.isIssued()) {
      paper.setTrading();
  }

  // Check paper is not already REDEEMED
  if (paper.isTrading()) {
      paper.setOwner(newOwner);
  } else {
      throw new Error('Paper ' + issuer + paperNumber + ' is not trading. Current state = ' +paper.getCurrentState());
  }

  // Update the paper
  await ctx.paperList.updatePaper(paper);
  return paper.toBuffer();
}
```

See how the transaction checks `currentOwner` and that `paper` is `TRADING`
before changing the owner with `paper.setOwner(newOwner)`. The basic flow is
simple though -- check some pre-conditions, set the new owner, update the
commercial paper on the ledger, and return the updated commercial paper
(serialized as a buffer) as the transaction response.

Why don't you see if you can understand the logic for the **redeem**
transaction?

## Representing an object

We've seen how to define and implement the **issue**, **buy** and **redeem**
transactions using the `CommercialPaper` and `PaperList` classes. Let's end
this topic by seeing how these classes work.

Locate the `CommercialPaper` class in the `paper.js`
[file](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paper.js):

```JavaScript
class CommercialPaper extends State {...}
```

This class contains the in-memory representation of a commercial paper state.
See how the `createInstance` method initializes a new commercial paper with the
provided parameters:

```JavaScript
static createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {
  return new CommercialPaper({ issuer, paperNumber, issueDateTime, maturityDateTime, faceValue });
}
```

Recall how this class was used by the **issue** transaction:

```JavaScript
let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);
```

See how every time the issue transaction is called, a new in-memory instance of
a commercial paper is created containing the transaction data.

A few important points to note:

  * This is an in-memory representation; we'll see
    [later](#accessing-the-ledger) how it appears on the ledger.


  * The `CommercialPaper` class extends the `State` class. `State` is an
    application-defined class which creates a common abstraction for a state.
    All states have a business object class which they represent, a composite
    key, can be serialized and de-serialized, and so on.  `State` helps our code
    be more legible when we are storing more than one business object type on
    the ledger. Examine the `State` class in the `state.js`
    [file](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js).


  * A paper computes its own key when it is created -- this key will be used
    when the ledger is accessed. The key is formed from a combination of
    `issuer` and `paperNumber`.

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```


  * A paper is moved to the `ISSUED` state by the transaction, not by the paper
    class. That's because it's the smart contract that governs the lifecycle
    state of the paper. For example, an `import` transaction might create a new
    set of papers immediately in the `TRADING` state.

The rest of the `CommercialPaper` class contains simple helper methods:

```JavaScript
getOwner() {
    return this.owner;
}
```

Recall how methods like this were used by the smart contract to move the
commercial paper through its lifecycle. For example, in the **redeem**
transaction we saw:

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

## Access the ledger

Now locate the `PaperList` class in the `paperlist.js`
[file](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js):

```JavaScript
class PaperList extends StateList {
```

This utility class is used to manage all PaperNet commercial papers in
Hyperledger Fabric state database. The PaperList data structures are described
in more detail in the [architecture topic](./architecture.html).

Like the `CommercialPaper` class, this class extends an application-defined
`StateList` class which creates a common abstraction for a list of states -- in
this case, all the commercial papers in PaperNet.

The `addPaper()` method is a simple veneer over the `StateList.addState()`
method:

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

You can see in the `StateList.js`
[file](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)
how the `StateList` class uses the Fabric API `putState()` to write the
commercial paper as state data in the ledger:

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

Every piece of state data in a ledger requires these two fundamental elements:

  * **Key**: `key` is formed with `createCompositeKey()` using a fixed name and
    the key of `state`. The name was assigned when the `PaperList` object was
    constructed, and `state.getSplitKey()` determines each state's unique key.


  * **Data**: `data` is simply the serialized form of the commercial paper
    state, created using the `State.serialize()` utility method. The `State`
    class serializes and deserializes data using JSON, and the State's business
    object class as required, in our case `CommercialPaper`, again set when the
    `PaperList` object was constructed.


Notice how a `StateList` doesn't store anything about an individual state or the
total list of states -- it delegates all of that to the Fabric state database.
This is an important design pattern -- it reduces the opportunity for [ledger
MVCC collisions](../readwrite.html) in Hyperledger Fabric.

The StateList `getState()` and `updateState()` methods work in similar ways:

```JavaScript
async getState(key) {
  let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));
  let data = await this.ctx.stub.getState(ledgerKey);
  let state = State.deserialize(data, this.supportedClasses);
  return state;
}
```

```JavaScript
async updateState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

See how they use the Fabric APIs `putState()`, `getState()` and
`createCompositeKey()` to access the ledger. We'll expand this smart contract
later to list all commercial papers in paperNet -- what might the method look
like to implement this ledger retrieval?

That's it! In this topic you've understood how to implement the smart contract
for PaperNet.  You can move to the next sub topic to see how an application
calls the smart contract using the Fabric SDK.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
