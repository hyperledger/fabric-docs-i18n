# 智能合约处理
# Smart Contract Processing

**受众**：架构师、应用程序和智能合约开发人员

**Audience**: Architects, Application and smart contract developers

区块链网络的核心是智能合约。在 PaperNet 中，商业票据智能合约中的代码定义了商业票据的有效状态，以及将票据从一种状态状态转变为另一种状态的交易逻辑。在本主题中，我们将向您展示如何实现一个真实世界的智能合约，该合约管理发行、购买和兑换商业票据的过程。

At the heart of a blockchain network is a smart contract. In PaperNet, the code
in the commercial paper smart contract defines the valid states for commercial
paper, and the transaction logic that transition a paper from one state to
another. In this topic, we're going to show you how to implement a real world
smart contract that governs the process of issuing, buying and redeeming
commercial paper.

我们将会介绍:

We're going to cover:

* [什么是智能合约以及智能合约为什么重要](#智能合约)
* [如何定义智能合约](#合约类)
* [如何定义交易](#交易定义)
* [如何实现一笔交易](#交易逻辑)
* [如何在智能合约中表示业务对象](#表示对象)
* [如何在账本中存储和检索对象](#访问账本)

* [What is a smart contract and why it's important](#smart-contract)
* [How to define a smart contract](#contract-class)
* [How to define a transaction](#transaction-definition)
* [How to implement a transaction](#transaction-logic)
* [How to represent a business object in a smart contract](#representing-an-object)
* [How to store and retrieve an object in the ledger](#access-the-ledger)

如果您愿意，可以[下载示例](../install.html)，甚至可以[在本地运行](../tutorial/commercial_paper.html)。它是用 JavaScript 和 Java 编写的，但逻辑与语言无关，因此您可以轻松地查看正在发生的事情！（该示例也可用于 Go。）

If you'd like, you can [download the sample](../install.html) and even [run it
locally](../tutorial/commercial_paper.html). It is written in JavaScript and Java, but
the logic is quite language independent, so you'll easily be able to see what's
going on! (The sample will become available for Go as well.)

## 智能合约

## Smart Contract

智能合约定义业务对象的不同状态，并管理对象在不同状态之间变化的过程。智能合约很重要，因为它们允许架构师和智能合约开发人员定义在区块链网络中协作的不同组织之间共享的关键业务流程和数据。

A smart contract defines the different states of a business object and governs
the processes that move the object between these different states. Smart
contracts are important because they allow architects and smart contract
developers to define the key business processes and data that are shared across
the different organizations collaborating in a blockchain network.

在 PaperNet 网络中，智能合约由不同的网络参与者共享，例如 MagnetoCorp 和 DigiBank。 连接到网络的所有应用程序必须使用相同版本的智能合约，以便它们共同实现相同的共享业务流程和数据。

In the PaperNet network, the smart contract is shared by the different network
participants, such as MagnetoCorp and DigiBank.  The same version of the smart
contract must be used by all applications connected to the network so that they
jointly implement the same shared business processes and data.

## 实现语言

## Implementation Languages

支持两种运行时，Java 虚拟机和 Node.js。支持使用 JavaScript、TypeScript、Java 或其他可以运行在支持的运行时上其中一种语言。

There are two runtimes that are supported, the Java Virtual Machine and Node.js. This
gives the opportunity to use one of JavaScript, TypeScript, Java or any other language
that can run on one of these supported runtimes.

在 Java 和 TypeScript 中，标注或者装饰器用来为智能合约和它的结构提供信息。这就更加丰富了开发体验——比如，作者信息或者强调返回类型。使用 JavaScript 的话就必须遵守一些规范，同时，对于什么可以自动执行也有一些限制。

In Java and TypeScript, annotations or decorators are used to provide information about
the smart contract and it's structure. This allows for a richer development experience ---
for example, author information or return types can be enforced. Within JavaScript,
conventions must be followed, therefore, there are limitations around what can be
determined automatically.

这里给出的示例包括 JavaScript 和 Java 两种语言。

Examples here are given in both JavaScript and Java.

## 合约类
  
 PaperNet 商业票据智能合约的副本包含在单个文件中。如果您已下载，请使用浏览器或在您喜欢的编辑器中打开它。
  - `papercontract.js` - [JavaScript 版本](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
  - `CommercialPaperContract.java` - [Java 版本](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp//contract-java/src/main/java/org/example/CommercialPaperContract.java)

## Contract class

您可能会从文件路径中注意到这是 MagnetoCorp 的智能合约副本。 MagnetoCorp 和 DigiBank 必须同意他们将要使用的智能合约版本。现在，你看哪个组织的合约副本无关紧要，它们都是一样的。

A copy of the PaperNet commercial paper smart contract is contained in a single
file. View it with your browser, or open it in your favorite editor if you've downloaded it.
  - `papercontract.js` - [JavaScript version](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
  - `CommercialPaperContract.java` - [Java version](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp//contract-java/src/main/java/org/example/CommercialPaperContract.java)

花一些时间看一下智能合约的整体结构; 注意，它很短！在文件的顶部，您将看到商业票据智能合约的定义：
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContract extends Contract {...}
```
</details>


<details>
<summary>Java</summary>
```Java
@Contract(...)
@Default
public class CommercialPaperContract implements ContractInterface {...}
```
</details>

You may notice from the file path that this is MagnetoCorp's copy of the smart
contract.  MagnetoCorp and DigiBank must agree on the version of the smart contract
that they are going to use. For now, it doesn't matter which organization's copy
you use, they are all the same.

`CommercialPaperContract` 类中包含商业票据中交易的定义——**发行**，**购买**和**兑换**。这些交易带给了商业票据创建和在它们的生命周期中流动的能力。我们马上会查看这些[交易](#transaction-definition)，但是现在我们需要关注一下 JavaScript， `CommericalPaperContract` 扩展的 Hyperledger Fabric `Contract` [类](https://fabric-shim.github.io/release-1.4/fabric-contract-api.Contract.html)。

Spend a few moments looking at the overall structure of the smart contract;
notice that it's quite short! Towards the top of the file, you'll see
that there's a definition for the commercial paper smart contract:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContract extends Contract {...}
```
</details>

在 Java 中，类必须使用 `@Contract(...)` 标注进行包装。它支持额外的智能合约信息，比如许可和作者。 `@Default()` 标注表明该智能合约是默认合约类。在智能合约中标记默认合约类在一些有多个合约类的智能合约中会很有用。

<details>
<summary>Java</summary>
```Java
@Contract(...)
@Default
public class CommercialPaperContract implements ContractInterface {...}
```
</details>

如果你使用 TypeScript 实现，也有类似 `@Contract(...)` 的标注，和 Java 中功能相似。


关于可用的标注的更多信息，请查看 API 文档：
* [Java 智能合约 API 文档](https://hyperledger.github.io/fabric-chaincode-java/)
* [Node.js 智能合约 API 文档](https://fabric-shim.github.io/)

The `CommercialPaperContract` class contains the transaction definitions for commercial paper -- **issue**, **buy**
and **redeem**. It's these transactions that bring commercial papers into
existence and move them through their lifecycle. We'll examine these
[transactions](#transaction-definition) soon, but for now notice for JavaScript, that the
`CommericalPaperContract` extends the Hyperledger Fabric `Contract`
[class](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-contract-api.Contract.html).

我们先导入这些类、标注和  `Context` 类：

With Java, the class must be decorated with the `@Contract(...)` annotation. This provides the opportunity
to supply additional information about the contract, such as license and author. The `@Default()` annotation
indicates that this contract class is the default contract class. Being able to mark a contract class as the
default contract class is useful in some smart contracts which have multiple contract classes.

<details open="true">
<summary>JavaScript</summary>
```JavaScript
const { Contract, Context } = require('fabric-contract-api');
```
</details>

If you are using a TypeScript implementation, there are similar `@Contract(...)` annotations that fulfill the same purpose as in Java.

<details>
<summary>Java</summary>
```Java
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contact;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.License;
import org.hyperledger.fabric.contract.annotation.Transaction;
```
</details>

For more information on the available annotations, consult the available API documentation:
* [API documentation for Java smart contracts](https://hyperledger.github.io/fabric-chaincode-java/)
* [API documentation for Node.js smart contracts](https://hyperledger.github.io/fabric-chaincode-node/)

我们的商业票据合约将使用这些类的内置功能，例如自动方法调用，[每个交易上下文](./transactioncontext.html)，[交易处理器](./transactionhandler.html)，和类共享状态。

The Fabric contract class is also available for smart contracts written in Go. While we do not discuss the Go contract API in this topic, it uses similar concepts as the API for Java and JavaScript:
* [API documentation for Go smart contracts](https://github.com/hyperledger/fabric-contract-api-go)

还要注意 JavaScript 类构造函数如何使用其[超类](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)通过一个[命名空间](./namespace.html)来初始化自身：

These classes, annotations, and the `Context` class, were brought into scope earlier:

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

<details open="true">
<summary>JavaScript</summary>
```JavaScript
const { Contract, Context } = require('fabric-contract-api');
```
</details>

在 Java 类中，构造器是空的，合约名会通过 `@Contract()` 注解进行识别。如果不是就会使用类名。

<details>
<summary>Java</summary>
```Java
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contact;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.License;
import org.hyperledger.fabric.contract.annotation.Transaction;
```
</details>

最重要的是，`org.papernet.commercialpaper` 非常具有描述性——这份智能合约是所有 PaperNet 组织关于商业票据商定的定义。


通常每个文件只有一个智能合约（合约往往有不同的生命周期，这使得将它们分开是明智的）。但是，在某些情况下，多个智能合约可能会为应用程序提供语法帮助，例如 `EuroBond`、`DollarBond`、`YenBond` 但基本上提供相同的功能。在这种情况下，智能合约和交易可以消除歧义。

Our commercial paper contract will use built-in features of these classes, such
as automatic method invocation, a
[per-transaction context](./transactioncontext.html),
[transaction handlers](./transactionhandler.html), and class-shared state.

## 交易定义

Notice also how the JavaScript class constructor uses its
[superclass](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)
to initialize itself with an explicit [contract name](./contractname.html):

在类中定位 **issue** 方法。
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```
</details>

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                             String issuer,
                             String paperNumber,
                             String issueDateTime,
                             String maturityDateTime,
                             int faceValue) {...}
```
</details>

With the Java class, the constructor is blank as the explicit contract name can be specified in the `@Contract()` annotation. If it's absent, then the name of the class is used.

Java 标注 `@Transaction` 用于标记该方法为交易定义；TypeScript 中也有等价的标注。

Most importantly, `org.papernet.commercialpaper` is very descriptive -- this smart
contract is the agreed definition of commercial paper for all PaperNet
organizations.

无论何时调用此合约来`发行`商业票据，都会调用该方法。回想一下如何使用以下交易创建商业票据 00001：

Usually there will only be one smart contract per file -- contracts tend to have
different lifecycles, which makes it sensible to separate them. However, in some
cases, multiple smart contracts might provide syntactic help for applications,
e.g. `EuroBond`, `DollarBond`, `YenBond`, but essentially provide the same
function. In such cases, smart contracts and transactions can be disambiguated.

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

## Transaction definition

我们已经更改了编程样式的变量名称，但是看看这些属性几乎直接映射到 `issue` 方法变量。

Within the class, locate the **issue** method.
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```
</details>

只要应用程序请求发行商业票据，合约就会自动调用 `issue` 方法。交易属性值通过相应的变量提供给方法。使用示例应用程序，了解应用程序如何使用[应用程序](./application.html)主题中的 Hyperledger Fabric SDK 提交一笔交易。

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                             String issuer,
                             String paperNumber,
                             String issueDateTime,
                             String maturityDateTime,
                             int faceValue) {...}
```
</details>

您可能已经注意到 **issue** 方法中定义的一个额外变量 ctx。它被称为[**交易上下文**](./transactioncontext.html)，它始终是第一个参数。默认情况下，它维护与[交易逻辑](#交易逻辑)相关的每个合约和每个交易的信息。例如，它将包含 MagnetoCorp 指定的交易标识符，MagnetoCorp 可以发行用户的数字证书，也可以调用账本 API。

The Java annotation `@Transaction` is used to mark this method as a transaction definition; TypeScript has an equivalent annotation.

通过实现自己的 `createContext()` 方法而不是接受默认实现，了解智能合约如何扩展默认交易上下文：

This function is given control whenever this contract is called to `issue` a
commercial paper. Recall how commercial paper 00001 was created with the
following transaction:

<details open="true">
<summary>JavaScript</summary>
```JavaScript
createContext() {
  return new CommercialPaperContext()
}
```
</details>

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

<details>
<summary>Java</summary>
```Java
@Override
public Context createContext(ChaincodeStub stub) {
     return new CommercialPaperContext(stub);
}
```
</details>

We've changed the variable names for programming style, but see how these
properties map almost directly to the `issue` method variables.


The `issue` method is automatically given control by the contract whenever an
application makes a request to issue a commercial paper. The transaction
property values are made available to the method via the corresponding
variables. See how an application submits a transaction using the Hyperledger
Fabric SDK in the [application](./application.html) topic, using a sample
application program.

此扩展上下文将自定义属性 `paperList` 添加到默认值：
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContext extends Context {

You might have noticed an extra variable in the **issue** definition -- `ctx`.
It's called the [**transaction context**](./transactioncontext.html), and it's
always first. By default, it maintains both per-contract and per-transaction
information relevant to [transaction logic](#transaction-logic). For example, it
would contain MagnetoCorp's specified transaction identifier, a MagnetoCorp
issuing user's digital certificate, as well as access to the ledger API.

  constructor() {
    super();
    // All papers are held in a list of papers
    this.paperList = new PaperList(this);
}
```
</details>

See how the smart contract extends the default transaction context by
implementing its own `createContext()` method rather than accepting the
default implementation:

<details>
<summary>Java</summary>
```Java
class CommercialPaperContext extends Context {
    public CommercialPaperContext(ChaincodeStub stub) {
        super(stub);
        this.paperList = new PaperList(this);
    }
    public PaperList paperList;
}
```
</details>

<details open="true">
<summary>JavaScript</summary>
```JavaScript
createContext() {
  return new CommercialPaperContext()
}
```
</details>

我们很快就会看到 `ctx.paperList` 如何随后用于帮助存储和检索所有 PaperNet 商业票据。

<details>
<summary>Java</summary>
```Java
@Override
public Context createContext(ChaincodeStub stub) {
     return new CommercialPaperContext(stub);
}
```
</details>

为了巩固您对智能合约交易结构的理解，找到**购买**和**兑换**交易定义，看看您是否可以理解它们如何映射到相应的商业票据交易。


**购买**交易：

This extended context adds a custom property `paperList` to the defaults:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContext extends Context {

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

  constructor() {
    super();
    // All papers are held in a list of papers
    this.paperList = new PaperList(this);
}
```
</details>

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseTime) {...}
```
</details>

<details>
<summary>Java</summary>
```Java
class CommercialPaperContext extends Context {
    public CommercialPaperContext(ChaincodeStub stub) {
        super(stub);
        this.paperList = new PaperList(this);
    }
    public PaperList paperList;
}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {...}
```
</details>

We'll soon see how `ctx.paperList` can be subsequently used to help store and
retrieve all PaperNet commercial papers.

**兑换**交易：

To solidify your understanding of the structure of a smart contract transaction,
locate the **buy** and **redeem** transaction definitions, and see if you can
see how they map to their corresponding commercial paper transactions.

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Redeemer = DigiBank
Redeem time = 31 Dec 2020 12:00:00 EST
```

The **buy** transaction:

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async redeem(ctx, issuer, paperNumber, redeemingOwner, redeemDateTime) {...}
```
</details>

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper redeem(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String redeemingOwner,
                              String redeemDateTime) {...}
```
</details>

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseTime) {...}
```
</details>

在两个案例中，注意商业票据交易和智能合约方法调用之间 1：1 的关系。。

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {...}
```
</details>

所有 JavaScript 方法都使用 `async` 和 `await`
[关键字](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)。

The **redeem** transaction:

## 交易逻辑

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Redeemer = DigiBank
Redeem time = 31 Dec 2020 12:00:00 EST
```

现在您已经了解了合约的结构和交易的定义，下面让我们关注智能合约中的逻辑。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async redeem(ctx, issuer, paperNumber, redeemingOwner, redeemDateTime) {...}
```
</details>

回想一下第一个**发行**交易：

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper redeem(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String redeemingOwner,
                              String redeemDateTime) {...}
```
</details>

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

In both cases, observe the 1:1 correspondence between the commercial paper
transaction and the smart contract method definition.

它导致 **issue** 方法被传递调用：
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

All of the JavaScript functions use the `async` and `await`
[keywords](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function) which allow JavaScript functions to be treated as if they were synchronous function calls.

   // create an instance of the paper
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);


  // Smart contract, rather than paper, moves paper into ISSUED state
  paper.setIssued();

## Transaction logic

  // Newly issued paper is owned by the issuer
  paper.setOwner(issuer);

Now that you've seen how contracts are structured and transactions are defined,
let's focus on the logic within the smart contract.

  // Add the paper to the list of all similar commercial papers in the ledger world state
  await ctx.paperList.addPaper(paper);

Recall the first **issue** transaction:

  // Must return a serialized paper to caller of smart contract
  return paper.toBuffer();
}
```
</details>

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String issueDateTime,
                              String maturityDateTime,
                              int faceValue) {

It results in the **issue** method being passed control:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

    System.out.println(ctx);

   // create an instance of the paper
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);

    // create an instance of the paper
    CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
            faceValue,issuer,"");

  // Smart contract, rather than paper, moves paper into ISSUED state
  paper.setIssued();

    // Smart contract, rather than paper, moves paper into ISSUED state
    paper.setIssued();

  // Newly issued paper is owned by the issuer
  paper.setOwner(issuer);

    // Newly issued paper is owned by the issuer
    paper.setOwner(issuer);

  // Add the paper to the list of all similar commercial papers in the ledger world state
  await ctx.paperList.addPaper(paper);

    System.out.println(paper);
    // Add the paper to the list of all similar commercial papers in the ledger
    // world state
    ctx.paperList.addPaper(paper);

  // Must return a serialized paper to caller of smart contract
  return paper.toBuffer();
}
```
</details>

    // Must return a serialized paper to caller of smart contract
    return paper;
}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String issueDateTime,
                              String maturityDateTime,
                              int faceValue) {


    System.out.println(ctx);

逻辑很简单：获取交易输入变量，创建新的商业票据 `paper`，使用 `paperList` 将其添加到所有商业票据的列表中，并将新的商业票据（序列化为buffer）作为交易响应返回。

    // create an instance of the paper
    CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
            faceValue,issuer,"");

了解如何从交易上下文中检索 `paperList` 以提供对商业票据列表的访问。`issue()`、`buy()` 和 `redeem()` 不断重新访问 `ctx.paperList` 以使商业票据列表保持最新。

    // Smart contract, rather than paper, moves paper into ISSUED state
    paper.setIssued();

**购买**交易的逻辑更详细描述：
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

    // Newly issued paper is owned by the issuer
    paper.setOwner(issuer);

  // Retrieve the current paper using key fields provided
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

    System.out.println(paper);
    // Add the paper to the list of all similar commercial papers in the ledger
    // world state
    ctx.paperList.addPaper(paper);

  // Validate current owner
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

    // Must return a serialized paper to caller of smart contract
    return paper;
}
```
</details>

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

The logic is simple: take the transaction input variables, create a new
commercial paper `paper`, add it to the list of all commercial papers using
`paperList`, and return the new commercial paper (serialized as a buffer) as the
transaction response.

  // Update the paper
  await ctx.paperList.updatePaper(paper);
  return paper.toBuffer();
}
```
</details>

See how `paperList` is retrieved from the transaction context to provide access
to the list of commercial papers. `issue()`, `buy()` and `redeem()` continually
re-access `ctx.paperList` to keep the list of commercial papers up-to-date.

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {

The logic for the **buy** transaction is a little more elaborate:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

    // Retrieve the current paper using key fields provided
    String paperKey = State.makeKey(new String[] { paperNumber });
    CommercialPaper paper = ctx.paperList.getPaper(paperKey);

  // Retrieve the current paper using key fields provided
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

    // Validate current owner
    if (!paper.getOwner().equals(currentOwner)) {
        throw new RuntimeException("Paper " + issuer + paperNumber + " is not owned by " + currentOwner);
    }

  // Validate current owner
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

    // First buy moves state from ISSUED to TRADING
    if (paper.isIssued()) {
        paper.setTrading();
    }

  // First buy moves state from ISSUED to TRADING
  if (paper.isIssued()) {
      paper.setTrading();
  }

    // Check paper is not already REDEEMED
    if (paper.isTrading()) {
        paper.setOwner(newOwner);
    } else {
        throw new RuntimeException(
                "Paper " + issuer + paperNumber + " is not trading. Current state = " + paper.getState());
    }

  // Check paper is not already REDEEMED
  if (paper.isTrading()) {
      paper.setOwner(newOwner);
  } else {
      throw new Error('Paper ' + issuer + paperNumber + ' is not trading. Current state = ' +paper.getCurrentState());
  }

    // Update the paper
    ctx.paperList.updatePaper(paper);
    return paper;
}
```
</details>

  // Update the paper
  await ctx.paperList.updatePaper(paper);
  return paper.toBuffer();
}
```
</details>

在使用 `paper.setOwner(newOwner)` 更改拥有者之前，理解交易如何检查 `currentOwner` 并检查该 `paper` 应该是 `TRADING` 状态的。基本流程很简单：检查一些前提条件，设置新拥有者，更新账本上的商业票据，并将更新的商业票据（序列化为 buffer ）作为交易响应返回。

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {

为什么不看一下你否能理解**兑换**交易的逻辑？

    // Retrieve the current paper using key fields provided
    String paperKey = State.makeKey(new String[] { paperNumber });
    CommercialPaper paper = ctx.paperList.getPaper(paperKey);

## 对象的表示

    // Validate current owner
    if (!paper.getOwner().equals(currentOwner)) {
        throw new RuntimeException("Paper " + issuer + paperNumber + " is not owned by " + currentOwner);
    }

我们已经了解了如何使用 `CommercialPaper` 和 `PaperList` 类定义和实现**发行**、**购买**和**兑换**交易。让我们通过查看这些类如何工作来结束这个主题。

    // First buy moves state from ISSUED to TRADING
    if (paper.isIssued()) {
        paper.setTrading();
    }

定位到 `CommercialPaper` 类：

    // Check paper is not already REDEEMED
    if (paper.isTrading()) {
        paper.setOwner(newOwner);
    } else {
        throw new RuntimeException(
                "Paper " + issuer + paperNumber + " is not trading. Current state = " + paper.getState());
    }

<details open="true">
<summary>JavaScript</summary>
在 [paper.js 文件中](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paper.js)：

    // Update the paper
    ctx.paperList.updatePaper(paper);
    return paper;
}
```
</details>

```JavaScript
class CommercialPaper extends State {...}
```
</details>

See how the transaction checks `currentOwner` and that `paper` is `TRADING`
before changing the owner with `paper.setOwner(newOwner)`. The basic flow is
simple though -- check some pre-conditions, set the new owner, update the
commercial paper on the ledger, and return the updated commercial paper
(serialized as a buffer) as the transaction response.

<details>
<summary>Java</summary>
In the [CommercialPaper.java file](https://github.com/hyperledger/fabric-samples/blob/release-1.4/commercial-paper/organization/magnetocorp/contract-java/src/main/java/org/example/CommercialPaper.java):

Why don't you see if you can understand the logic for the **redeem**
transaction?


## Representing an object

```Java
@DataType()
public class CommercialPaper extends State {...}
```
</details>

We've seen how to define and implement the **issue**, **buy** and **redeem**
transactions using the `CommercialPaper` and `PaperList` classes. Let's end
this topic by seeing how these classes work.


Locate the `CommercialPaper` class:

此类包含商业票据状态的内存表示。了解 `createInstance` 方法如何使用提供的参数初始化一个新的商业票据：

<details open="true">
<summary>JavaScript</summary>
In the
[paper.js file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paper.js):

<details open="true">
<summary>JavaScript</summary>
```JavaScript
static createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {
  return new CommercialPaper({ issuer, paperNumber, issueDateTime, maturityDateTime, faceValue });
}
```
</details>

```JavaScript
class CommercialPaper extends State {...}
```
</details>

<details>
<summary>Java</summary>
```Java
public static CommercialPaper createInstance(String issuer, String paperNumber, String issueDateTime,
        String maturityDateTime, int faceValue, String owner, String state) {
    return new CommercialPaper().setIssuer(issuer).setPaperNumber(paperNumber).setMaturityDateTime(maturityDateTime)
            .setFaceValue(faceValue).setKey().setIssueDateTime(issueDateTime).setOwner(owner).setState(state);
}
```
</details>

<details>
<summary>Java</summary>
In the [CommercialPaper.java file](https://github.com/hyperledger/fabric-samples/blob/release-1.4/commercial-paper/organization/magnetocorp/contract-java/src/main/java/org/example/CommercialPaper.java):

回想一下**发行**交易如何使用这个类：


<details open="true">
<summary>JavaScript</summary>
```JavaScript
let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);
```
</details>

```Java
@DataType()
public class CommercialPaper extends State {...}
```
</details>

<details>
<summary>Java</summary>
```Java
CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
        faceValue,issuer,"");
```
</details>


查看每次调用发行交易时，如何创建包含交易数据的商业票据的新内存实例。

This class contains the in-memory representation of a commercial paper state.
See how the `createInstance` method initializes a new commercial paper with the
provided parameters:

需要注意的几个要点：

<details open="true">
<summary>JavaScript</summary>
```JavaScript
static createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {
  return new CommercialPaper({ issuer, paperNumber, issueDateTime, maturityDateTime, faceValue });
}
```
</details>

  * 这是一个内存中的表示; 我们[稍后](#访问账本)会看到它如何在帐本上显示。

<details>
<summary>Java</summary>
```Java
public static CommercialPaper createInstance(String issuer, String paperNumber, String issueDateTime,
        String maturityDateTime, int faceValue, String owner, String state) {
    return new CommercialPaper().setIssuer(issuer).setPaperNumber(paperNumber).setMaturityDateTime(maturityDateTime)
            .setFaceValue(faceValue).setKey().setIssueDateTime(issueDateTime).setOwner(owner).setState(state);
}
```
</details>

  * `CommercialPaper` 类扩展了 `State` 类。 `State` 是一个应用程序定义的类，它为状态创建一个公共抽象。所有状态都有一个它们代表的业务对象类、一个复合键，可以被序列化和反序列化，等等。当我们在帐本上存储多个业务对象类型时， `State` 可以帮助我们的代码更清晰。检查 `state.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js)中的 `State` 类。

Recall how this class was used by the **issue** transaction:

  * 票据在创建时会计算自己的密钥，在访问帐本时将使用此密钥。密钥由 `issuer` 和 `paperNumber` 的组合形成。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);
```
</details>

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```

<details>
<summary>Java</summary>
```Java
CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
        faceValue,issuer,"");
```
</details>

  * 票据通过交易而不是票据类变更到 `ISSUED` 状态。那是因为智能合约控制票据的状态生命周期。例如，`import` 交易可能会立即创建一组新的 `TRADING` 状态的票据。

See how every time the issue transaction is called, a new in-memory instance of
a commercial paper is created containing the transaction data.

`CommercialPaper` 类的其余部分包含简单的辅助方法：

A few important points to note:

```JavaScript
getOwner() {
    return this.owner;
}
```

  * This is an in-memory representation; we'll see
    [later](#accessing-the-ledger) how it appears on the ledger.

回想一下智能合约如何使用这样的方法来维护商业票据的整个生命周期。例如，在**兑换**交易中，我们看到：


```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

  * The `CommercialPaper` class extends the `State` class. `State` is an
    application-defined class which creates a common abstraction for a state.
    All states have a business object class which they represent, a composite
    key, can be serialized and de-serialized, and so on.  `State` helps our code
    be more legible when we are storing more than one business object type on
    the ledger. Examine the `State` class in the `state.js`
    [file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js).

## 访问账本


现在在 `paperlist.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js)中找到 `PaperList` 类：

  * A paper computes its own key when it is created -- this key will be used
    when the ledger is accessed. The key is formed from a combination of
    `issuer` and `paperNumber`.

```JavaScript
class PaperList extends StateList {
```

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```

此实用程序类用于管理 Hyperledger Fabric 状态数据库中的所有 PaperNet 商业票据。PaperList 数据结构在[架构主题](./architecture.html)中有更详细的描述。


与 `CommercialPaper` 类一样，此类扩展了应用程序定义的 `StateList` 类，该类为一系列状态创建了一个通用抽象——在本例中是 PaperNet 中的所有商业票据。

  * A paper is moved to the `ISSUED` state by the transaction, not by the paper
    class. That's because it's the smart contract that governs the lifecycle
    state of the paper. For example, an `import` transaction might create a new
    set of papers immediately in the `TRADING` state.

`addPaper()` 方法是对 `StateList.addState()` 方法的简单封装：

The rest of the `CommercialPaper` class contains simple helper methods:

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

```JavaScript
getOwner() {
    return this.owner;
}
```

您可以在 `StateList.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)中看到 `StateList` 类如何使用 Fabric API `putState()` 将商业票据作为状态数据写在帐本中：

Recall how methods like this were used by the smart contract to move the
commercial paper through its lifecycle. For example, in the **redeem**
transaction we saw:

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

帐本中的每个状态数据都需要以下两个基本要素：

## Access the ledger

  * **键（Key）**: `键` 由 `createCompositeKey()` 使用固定名称和 `state` 密钥形成。在构造 `PaperList` 对象时分配了名称，`state.getSplitKey()` 确定每个状态的唯一键。

Now locate the `PaperList` class in the `paperlist.js`
[file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js):

  * **数据（Data）**: `数据` 只是商业票据状态的序列化形式，使用 `State.serialize()` 方法创建。`State` 类使用 JSON 对数据进行序列化和反序列化，并根据需要使用 State 的业务对象类，在我们的例子中为 `CommercialPaper`，在构造 `PaperList` 对象时再次设置。

```JavaScript
class PaperList extends StateList {
```

注意 `StateList` 不存储有关单个状态或状态总列表的任何内容——它将所有这些状态委托给 Fabric 状态数据库。这是一个重要的设计模式 -- 它减少了 Hyperledger Fabric 中[账本 MVCC 冲突](../readwrite.html)的机会。

This utility class is used to manage all PaperNet commercial papers in
Hyperledger Fabric state database. The PaperList data structures are described
in more detail in the [architecture topic](./architecture.html).

StateList `getState()` 和 `updateState()` 方法以类似的方式工作：

Like the `CommercialPaper` class, this class extends an application-defined
`StateList` class which creates a common abstraction for a list of states -- in
this case, all the commercial papers in PaperNet.

```JavaScript
async getState(key) {
  let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));
  let data = await this.ctx.stub.getState(ledgerKey);
  let state = State.deserialize(data, this.supportedClasses);
  return state;
}
```

The `addPaper()` method is a simple veneer over the `StateList.addState()`
method:

```JavaScript
async updateState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

了解他们如何使用 Fabric APIs `putState()`、 `getState()` 和 `createCompositeKey()` 来存取账本。我们稍后将扩展这份智能合约，以列出 paperNet 中的所有商业票据。实现账本检索的方法可能是什么样的？

You can see in the `StateList.js`
[file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)
how the `StateList` class uses the Fabric API `putState()` to write the
commercial paper as state data in the ledger:

是的！在本主题中，您已了解如何为 PaperNet 实现智能合约。您可以转到下一个子主题，以查看应用程序如何使用 Fabric SDK 调用智能合约。

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
