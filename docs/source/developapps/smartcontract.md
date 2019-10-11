# 智能合约处理

**受众** ：架构师、应用程序和智能合约开发人员

区块链网络的核心是智能合约。 在PaperNet中，商业票据智能合约中的代码定义了商业票据的有效状态，
以及将票据从一种状态状态转变为另一种状态的交易逻辑。 在本主题中，我们将向您展示如何实现一个真实世界的
智能合约，该合约管理发行、购买和兑换商业票据的过程。

我们将会介绍:

* [什么是智能合约以及智能合约为什么重要](#smart-contract)
* [如何定义智能合约](#contract-class)
* [如何定义交易](#transaction-definition)
* [如何实现一笔交易](#transaction-logic)
* [如何在智能合约中表示业务对象](#representing-an-object)
* [如何在账本中存储和检索对象](#access-the-ledger)

如果您愿意，可以 [下载样本](../install.html) ，甚至可以 [在本地运行](../tutorial/commercial_paper.html)。 
它是用JavaScript编写的，但逻辑与语言无关，因此您可以轻松地查看正在发生的事情！（该示例也可用于Java和GOLANG。）

## 智能合约

智能合约定义业务对象的不同状态，并管理对象在不同状态之间变化的过程。 智能合约很重要，因为它们允许架构师
和智能合约开发人员定义在区块链网络中协作的不同组织之间共享的关键业务流程和数据。

在PaperNet网络中，智能合约由不同的网络参与者共享，例如MagnetoCorp和DigiBank。 连接到网络的
所有应用程序必须使用相同版本的智能合约，以便它们共同实现相同的共享业务流程和数据。

## 合约类

PaperNet商业票据智能合约的副本包含在`papercontract.js`中. [View it](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)。如果您已下载，请使用浏览器查看，或在您喜欢的编辑器中打开它。

您可能会从文件路径中注意到这是MagnetoCorp的智能合约副本。 MagnetoCorp和DigiBank必须同意他们
将要使用的智能合约版本。 现在，你看哪个组织的合约副本无关紧要，它们都是一样的。

花一些时间看一下智能合约的整体结构; 注意它很短！ 在`papercontract.js`的顶部，您将看到商业票据智能合约的定义：

```JavaScript
class CommercialPaperContract extends Contract {...}
```

 `CommercialPaperContract`
[类](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)
包含商业票据的交易定义 -- **发行**、 **购买**和**兑换**。 正是这些交易带来了商业票据的存在，
并将它们贯穿整个生命周期。 我们很快就会检查这些[交易](#transaction-definition) ，但现在请注意`CommericalPaperContract`如何扩展
Hyperledger Fabric Contract `Contract`[类](https://fabric-shim.github.io/release-1.4/fabric-contract-api.Contract.html)。 
这个内置类和`Context`类开始就被导入进代码区域：

```JavaScript
const { Contract, Context } = require('fabric-contract-api');
```

我们的商业票据合约将使用这些类的内置功能，例如自动方法调用， [每个交易上下文](./transactioncontext.html),
[交易处理器](./transactionhandler.html)，和类共享状态。

还要注意类构造函数如何使用其[超类](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)
通过一个[命名空间](./namespace.html)来初始化自身：

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

最重要的是， `org.papernet.commercialpaper` 非常具有描述性 - 这份智能合约是所有PaperNet组织关于商业票据的商定定义。

通常每个文件只有一个智能合约 - 合约往往有不同的生命周期，这使得将它们分开是明智的。 但是，在某些情况下，
多个智能合约可能会为应用程序提供语法帮助，例如`EuroBond`、`DollarBond`、`YenBond`
但基本上提供相同的功能。 在这种情况下，智能合约和交易可以消除歧义。

## 交易定义

在类中找到**issue**方法。

```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```

无论何时调用此合约来`issue`商业票据，都会调用该方法。 回想一下如何使用以下交易创建商业票据00001：

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

我们已经更改了编程样式的变量名称，但是看看这些属性几乎直接映射到`issue`方法变量。

只要应用程序请求发行商业票据，合约就会自动调用`issue`方法。 交易属性值通过相应的变量提供给方法。
使用示例应用程序，了解应用程序如何使用[应用程序](./application.html)主题中的Hyperledger Fabric SDK提交一笔交易。

您可能已经注意到**issue**方法中定义的一个额外变量 -- ctx 。 它被称为[**交易上下文**](./transactioncontext.html)，它始终是第一个参数。 
默认情况下，它维护与[交易逻辑](#transaction-logic)相关的每个合约和每个交易的信息。 例如，它将包含MagnetoCorp
指定的交易标识符，MagnetoCorp可以发行用户的数字证书，也可以调用账本API。

通过实现自己的`createContext()`方法而不是接受默认实现，了解智能合约如何扩展默认交易上下文：

```JavaScript
createContext() {
  return new CommercialPaperContext()
}
```

此扩展上下文将自定义属性paperList添加到默认值：

```JavaScript
class CommercialPaperContext extends Context {

  constructor() {
    super();
    // All papers are held in a list of papers
    this.paperList = new PaperList(this);
}
```

我们很快就会看到`ctx.paperList`如何随后用于帮助存储和检索所有PaperNet商业票据。

为了巩固您对智能合约交易结构的理解，找到**buy**和**redeem**交易定义，看看您是否可以理解它们如何映射到相应的商业票据交易。

**buy** 交易：

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

**redeem** 交易：

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

在这两种情况下，观察商业票据交易和智能合约方法定义之间的1：1对应关系。 
并且不用担心`async`和`await`[关键字](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
 -- 它们允许将异步JavaScript函数视为其他编程语言中的同步方法。

## 交易逻辑

现在您已经了解了合约的结构和交易的定义，下面让我们关注智能合约中的逻辑。

回想一下第一个**issue**交易：

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

它导致**issue**方法被传递调用：

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

逻辑很简单：获取交易输入变量，创建新的商业票据`paper`,，使用`paperList`将其添加到所有商业票据的列表中，
并将新的商业票据（序列化为buffer）作为交易响应返回。

了解如何从交易上下文中检索`paperList`以提供对商业票据列表的访问。 `issue()` 、
`buy()`和`redeem()` 不断重新访问`ctx.paperList`以使商业票据列表保持最新。

**buy**交易的逻辑更详细描述：

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

在使用`paper.setOwner(newOwner)`更改拥有者之前，理解交易如何检查`currentOwner`并检查该
`paper`应该是`TRADING`状态的。 基本流程很简单 -- 检查一些前提条件，设置新拥有者，
更新账本上的商业票据，并将更新的商业票据（序列化为buffer）作为交易响应返回。

你为什么不知道你否能理解**redeem**交易的逻辑？

## 表示对象

我们已经了解了如何使用`CommercialPaper`和`PaperList`类定义和实现**issue**、 **buy**和**redeem**交易。 
让我们通过查看这些类如何工作来结束这个主题。

在`paper.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paper.js)
中找到`CommercialPaper`类：

```JavaScript
class CommercialPaper extends State {...}
```

此类包含商业票据状态的内存表示。 了解`createInstance`方法如何使用提供的参数初始化一个新的商业票据：

```JavaScript
static createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {
  return new CommercialPaper({ issuer, paperNumber, issueDateTime, maturityDateTime, faceValue });
}
```

回想一下**issue**交易如何使用这个类：

```JavaScript
let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);
```

查看每次调用发行交易时，如何创建包含交易数据的商业票据的新内存实例。

需要注意的几个要点：

  * 这是一个内存中的表示; 我们[稍后](#accessing-the-ledger)会看到它如何在帐本上显示。

  * `CommercialPaper`类扩展了`State`类。 `State`是一个应用程序定义的类，它为状态创建一个公共抽象。 
    所有状态都有一个它们代表的业务对象类、一个复合键，可以被序列化和反序列化，等等。当我们在帐本上存储多个业务对象类型时， `State`可以帮助我们的代码更清晰。 检查`state.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js)中的`State`类。

  * 票据在创建时会计算自己的密钥 -- 在访问帐本时将使用此密钥。 密钥由`issuer`和`paperNumber`的组合形成。

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```

  * 票据通过交易而不是票据类变更到`ISSUED`状态。 那是因为智能合约控制票据的状态生命周期。 
    例如， `import`交易可能会立即创建一组新的`TRADING`状态的票据。

`CommercialPaper`类的其余部分包含简单的辅助方法：

```JavaScript
getOwner() {
    return this.owner;
}
```

回想一下智能合约如何使用这样的方法来维护商业票据的整个生命周期。 例如，在**redeem**交易中，我们看到：

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

## 访问账本

现在在`paperlist.js` [文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js)中找到`PaperList`类：

```JavaScript
class PaperList extends StateList {
```

此实用程序类用于管理Hyperledger Fabric状态数据库中的所有PaperNet商业票据。 
PaperList数据结构在[架构主题](./architecture.html)中有更详细的描述。

与`CommercialPaper`类一样，此类扩展了应用程序定义的`StateList`类，该类为一系列状态创建了一个通用抽象 - 在本例中是PaperNet中的所有商业票据。

`addPaper()`方法是对`StateList.addState()`方法的简单封装：

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

您可以在`StateList.js`[文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)
中看到`StateList`类如何使用Fabric API `putState()`将商业票据作为状态数据写在帐本中：

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

帐本中的每个状态数据都需要以下两个基本要素：

  * **Key**: `key` 由`createCompositeKey()`使用固定名称和`state`密钥形成。 
    在构造`PaperList`对象时分配了名称， `state.getSplitKey()`确定每个状态的唯一键。
  
  * **Data**: `data` 只是商业票据状态的序列化形式，使用`State.serialize()`实用程序方法创建。 
    `State`类使用JSON对数据进行序列化和反序列化，并根据需要使用State的业务对象类，
    在我们的例子中为`CommercialPaper` ，在构造`PaperList` 对象时再次设置。

注意`StateList`不存储有关单个状态或状态总列表的任何内容 -- 它将所有这些状态委托给Fabric状态数据库。 
这是一个重要的设计模式 -- 它减少了Hyperledger Fabric中[账本MVCC冲突](../readwrite.html)的机会。

StateList `getState()`和`updateState()`方法以类似的方式工作：

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

了解他们如何使用Fabric APIs `putState()`、 `getState()`和`createCompositeKey()`来存取账本。 
我们稍后将扩展这份智能合约，以列出paperNet中的所有商业票据 -- 实现账本检索的方法可能是什么样的？

是的！ 在本主题中，您已了解如何为PaperNet实现智能合约。 您可以转到下一个子主题，以查看应用程序如何使用Fabric SDK调用智能合约。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
