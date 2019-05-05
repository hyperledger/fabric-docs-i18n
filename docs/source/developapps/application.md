# Application - 应用

**Audience**: Architects, Application and smart contract developers

**受众** ：架构师、应用程序和智能合约开发人员

An application can interact with a blockhain network by submitting transactions
to a ledger or querying ledger content. This topic covers the mechanics of how
an application does this; in our scenario, organizations access PaperNet using
applications which invoke **issue**, **sell** and **redeem** transactions
defined in a commercial paper smart contract. Even though MagnetoCorp's
application to issue a commercial paper is basic, it covers all the major points
of understanding.

应用程序可以通过将交易提交到帐本或查询帐本内容来与区块链网络进行交互。 本主题介绍了应用程序如何
执行此操作的机制; 在我们的场景中，组织使用应用程序访问PaperNet，这些应用程序调用定义在商业票据
智能合约中的**issue**、 **sell** 和**redeem** 交易。 尽管MagnetoCorp的应用发行商业票据
是基础功能，但它涵盖了所有主要的理解点。

In this topic, we're going to cover:

* [The application flow to invoke a smart contract](#basic-flow)
* [How an application uses a wallet and identity](#wallet)
* [How an application connects using a gateway](#gateway)
* [How to access a particular network](#network-channel)
* [How to construct a transaction request](#construct-request)
* [How to submit a transaction](#submit-transaction)
* [How to process a transaction response](#process-response)

在本主题中，我们将介绍：

* [从应用程序到调用智能合约](#basic-flow)
* [应用程序如何使用钱包和身份](#wallet)
* [应用程序如何使用网关连接](#gateway)
* [如何访问特定网络](#network-channel)
* [如何构造交易请求](#construct-request)
* [如何提交交易](#submit-transaction)
* [如何处理交易响应](#process-response)

To help your understanding, we'll make reference to the commercial paper sample
application provided with Hyperledger Fabric. You can [download
it](../install.html) and [run it locally](../tutorial/commercial_paper.html). It
is written in JavaScript, but the logic is quite language independent, so you'll
be easily able to see what's going on! (The sample will become available for
Java and GOLANG as well.)

为了帮助您理解，我们将参考Hyperledger Fabric提供的商业票据样例应用程序。 您可以[下载](../install.html) 
并[在本地运行它](../tutorial/commercial_paper.html)。它是用JavaScript编写的，但逻辑与语言无关，
因此您可以轻松地查看正在发生的事情！（该样例也可用于Java和GOLANG。）

## Basic Flow - 基本流程

An application interacts with a blockchain network using the Fabric SDK. Here's
a simplified diagram of how an application invokes a commercial paper smart
contract:

应用程序使用Fabric SDK与区块链网络交互。 以下是应用程序如何调用商业票据智能合约的简化图表：

![develop.application](./develop.diagram.3.png) *A PaperNet application invokes
the commercial paper smart contract to submit an issue transaction request.*

*PaperNet应用程序调用商业票据智能合约来提交发行交易请求。*

An application has to follow six basic steps to submit a transaction:

* Select an identity from a wallet
* Connect to a gateway
* Access the desired network
* Construct a transaction request for a smart contract
* Submit the transaction to the network
* Process the response

应用程序必须遵循六个基本步骤来提交交易：

* 从钱包中选择一个身份
* 连接到网关
* 访问所需的网络
* 构建智能合约的交易请求
* 将交易提交到网络
* 处理响应

You're going to see how a typical application performs these six steps using the
Fabric SDK. You'll find the application code in the `issue.js` file. [View
it](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/application/issue.js)
in your browser, or open it in your favourite editor if you've downloaded it.
Spend a few moments looking at the overall structure of the application; even
with comments and spacing, it's only 100 lines of code!

您将看到典型应用程序如何使用Fabric SDK执行这六个步骤。 您可以在`issue.js`文件中找到应用程序代码。
如果您已下载，请在浏览器中[查看](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/application/issue.js)，
或在您喜欢的编辑器中打开它。 花一些时间看一下应用程序的整体结构; 
尽管有注释和空白，但是它只有100行代码！

## Wallet - 钱包

Towards the top of `issue.js`, you'll see two Fabric classes are brought
into scope:

在`issue.js`的顶部，您将看到两个Fabric类导入代码域：

```JavaScript
const { FileSystemWallet, Gateway } = require('fabric-network');
```

You can read about the `fabric-network` classes in the
[node SDK documentation](https://fabric-sdk-node.github.io/master/module-fabric-network.html), but for
now, let's see how they are used to connect MagnetoCorp's application to
PaperNet. The application uses the Fabric **Wallet** class as follows:

您可以在[节点SDK文档](https://fabric-sdk-node.github.io/master/module-fabric-network.html)中了解`fabric-network`类，
但是现在，让我们看看如何使用它们将MagnetoCorp的应用程序连接到PaperNet。该应用程序使用Fabric **Wallet**类，如下所示：

```JavaScript
const wallet = new FileSystemWallet('../identity/user/isabella/wallet');
```

See how `wallet` locates a [wallet](./wallet.html) in the local filesystem. The
identity retrieved from the wallet is clearly for a user called Isabella, who is
using the `issue` application. The wallet holds a set of identities -- X.509
digital certificates -- which can be used to access PaperNet or any other Fabric
network. If you run the tutorial, and look in this directory, you'll see the
identity credentials for Isabella.

了解`wallet`如何在本地文件系统中找到[钱包](./wallet.html)。从钱包中检索到的身份显然适用于
使用`issue`应用程序的Isabella用户。钱包拥有一组身份 -- X.509数字证书 -- 可用于访问PaperNet
或任何其他Fabric网络。如果您运行该教程，并查看此目录，您将看到Isabella的身份凭证。

Think of a [wallet](./wallet.html) holding the digital equivalents of your
government ID, driving license or ATM card. The X.509 digital certificates
within it will associate the holder with a organization, thereby entitling them
to rights in a network channel. For example, `Isabella` might be an
administrator in MagnetoCorp, and this could give her more privileges than a
different user -- `Balaji` from DigiBank.  Moreover, a smart contract can
retrieve this identity during smart contract processing using the [transaction
context](./transactioncontext.html).

想想一个[钱包](./wallet.html)里面装着政府身份证，驾照或ATM卡的数字等价物。 其中的X.509数字证书
将持有者与组织相关联，从而使他们有权在网络通道中获得权利。 例如， `Isabella`可能是MagnetoCorp的管理员，
这可能比其他用户更有特权 -- 来自DigiBank的`Balaji`。 此外，智能合约可以在使用
[交易上下文](./transactioncontext.html)的智能合约处理期间检索此身份。

Note also that wallets don't hold any form of cash or tokens -- they hold
identities.

另请注意，钱包不持有任何形式的现金或代币 -- 它们持有身份。

## Gateway - 网关

The second key class is a Fabric **Gateway**. Most importantly, a
[gateway](./gateway.html) identifies one or more peers that provide access to a
network -- in our case, PaperNet. See how `issue.js` connects to its gateway:

第二个关键类是Fabric **Gateway**。 最重要的是， [网关](./gateway.html)识别一个或多个提供
网络访问的peer节点 -- 在我们的例子中是PaperNet。 了解`issue.js` 如何连接到其网关：

```JavaScript
await gateway.connect(connectionProfile, connectionOptions);
```

`gateway.connect()` has two important parameters:

  * **connectionProfile**: the file system location of a
    [connection profile](./connectionprofile.html) that identifies
    a set of peers as a gateway to PaperNet

  * **connectionOptions**: a set of options used to control how `issue.js`
    interacts with PaperNet

`gateway.connect()` 有两个重要参数：

  * **connectionProfile**： [连接配置文件](./connectionprofile.html)的文件系统位置，用于将一组peer节点标识为PaperNet的网关

  * **connectionOptions**： 一组用于控制`issue.js`与PaperNet交互的选项
    
See how the client application uses a gateway to insulate itself from the
network topology, which might change. The gateway takes care of sending the
transaction proposal to the right peer nodes in the network using the
[connection profile](./connectionprofile.html) and [connection
options](./connectionoptions.html).

了解客户端应用程序如何使用网关将自身与可能发生变化的网络拓扑隔离开来。 
网关负责使用[连接配置文件](./connectionprofile.html)和[连接选项](./connectionoptions.html)
将交易提案发送到网络中的正确peer节点。

Spend a few moments examining the connection
[profile](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)
`./gateway/connectionProfile.yaml`. It uses
[YAML](http://yaml.org/spec/1.2/spec.html#Preview), making it easy to read.

花一些时间检查连接[配置文件](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)
`./gateway/connectionProfile.yaml`。 它使用[YAML](http://yaml.org/spec/1.2/spec.html#Preview)，易于阅读。

It was loaded and converted into a JSON object:

它被加载并转换为JSON对象：

```JavaScript
let connectionProfile = yaml.safeLoad(file.readFileSync('./gateway/connectionProfile.yaml', 'utf8'));
```

Right now, we're only interested in the `channels:` and `peers:` sections of the
profile: (We've modified the details slightly to better explain what's
happening.)

现在，我们只关注`channels:`和 `peers:`配置部分:(我们稍微修改了细节，以便更好地解释发生了什么。）

```YAML
channels:
  papernet:
    peers:
      peer1.magnetocorp.com:
        endorsingPeer: true
        eventSource: true

      peer2.digibank.com:
        endorsingPeer: true
        eventSource: true

peers:
  peer1.magnetocorp.com:
    url: grpcs://localhost:7051
    grpcOptions:
      ssl-target-name-override: peer1.magnetocorp.com
      request-timeout: 120
    tlsCACerts:
      path: certificates/magnetocorp/magnetocorp.com-cert.pem

  peer2.digibank.com:
    url: grpcs://localhost:8051
    grpcOptions:
      ssl-target-name-override: peer1.digibank.com
    tlsCACerts:
      path: certificates/digibank/digibank.com-cert.pem
```

See how `channel:` identifies the `PaperNet:` network channel, and two of its
peers. MagnetoCorp has `peer1.magenetocorp.com` and DigiBank has
`peer2.digibank.com`, and both have the role of endorsing peers. Link to these
peers via the `peers:` key, which contains details about how to connect to them,
including their respective network addresses.

了解`channel:`如何识别`PaperNet:` 网络通道及其两个peer节点。 MagnetoCorp拥有`peer1.magenetocorp.com`，
DigiBank拥有`peer2.digibank.com`，两者都有背书peer的角色。 通过`peers:` key链接到这些peer节点，
其中包含有关如何连接它们的详细信息，包括它们各自的网络地址。

The connection profile contains a lot of information -- not just peers -- but
network channels, network orderers, organizations, and CAs, so don't worry if
you don't understand all of it!

连接配置文件包含大量信息 -- 不仅仅是peer节点 -- 而是网络通道，网络排序节点，组织和CA，
因此如果您不了解所有信息，请不要担心！

Let's now turn our attention to the `connectionOptions` object:

现在让我们将注意力转向`connectionOptions`对象：

```JavaScript
let connectionOptions = {
  identity: userName,
  wallet: wallet
}
```

See how it specifies that identity, `userName`, and wallet, `wallet`, should be
used to connect to a gateway. These were assigned values earlier in the code.

了解它如何指定应使用identity、`userName`和wallet、`wallet` 连接到网关。 
这些是在代码中分配值较早的。

There are other [connection options](./connectionoptions.html) which an
application could use to instruct the SDK to act intelligently on its behalf.
For example:

应用程序可以使用其他[连接选项](./connectionoptions.html)来指示SDK代表它智能地执行操作。 
例如：

```JavaScript
let connectionOptions = {
  identity: userName,
  wallet: wallet,
  eventHandlerOptions: {
    commitTimeout: 100,
    strategy: EventStrategies.MSPID_SCOPE_ANYFORTX
  },
}
```

Here, `commitTimeout` tells the SDK to wait 100 seconds to hear whether a
transaction has been committed. And `strategy:
EventStrategies.MSPID_SCOPE_ANYFORTX` specifies that the SDK can notify an
application after a single MagnetoCorp peer has confirmed the transaction, in
contrast to `strategy: EventStrategies.NETWORK_SCOPE_ALLFORTX` which requires
that all peers from MagnetoCorp and DigiBank to confirm the transaction.

这里， `commitTimeout`告诉SDK等待100秒以听取是否已提交交易。 
`strategy:EventStrategies.MSPID_SCOPE_ANYFORTX`指定SDK可以在单个MagnetoCorp peer节点
确认交易后通知应用程序，与`strategy: EventStrategies.NETWORK_SCOPE_ALLFORTX`相反，
`strategy: EventStrategies.NETWORK_SCOPE_ALLFORTX`要求MagnetoCorp和DigiBank的所有的peer节点确认交易。

If you'd like to, [read more](./connectionoptions.html) about how connection
options allow applications to specify goal-oriented behaviour without having to
worry about how it is achieved.

如果您愿意，请[阅读更多](./connectionoptions.html) 有关连接选项如何允许应用程序
指定面向目标的行为而不必担心如何实现的信息。

## Network channel -网络通道

The peers defined in the gateway `connectionProfile.yaml` provide
`issue.js` with access to PaperNet. Because these peers can be joined to
multiple network channels, the gateway actually provides the application with
access to multiple network channels!

在网关`connectionProfile.yaml`中定义的peers提供`issue.js`来访问PaperNet。 
由于这些peers可以连接到多个网络通道，因此网关实际上为应用程序提供了对多个网络通道的访问！

See how the application selects a particular channel:

了解应用程序如何选择特定通道：

```JavaScript
const network = await gateway.getNetwork('PaperNet');
```

From this point onwards, `network` will provide access to PaperNet.  Moreover,
if the application wanted to access another network, `BondNet`, at the same
time, it is easy:

从这一点开始， `network`将提供对PaperNet的访问。 此外，如果应用程序想要访问另一个网络， 
`BondNet`，同时，它很容易：

```JavaScript
const network2 = await gateway.getNetwork('BondNet');
```

Now our application has access to a second network, `BondNet`, simultaneously
with `PaperNet`!

现在，我们的应用程序可以访问第二个网络`BondNet`，同时可以访问`PaperNet`！

We can see here a powerful feature of Hyperledger Fabric -- applications can
participate in a **network of networks**, by connecting to multiple gateway
peers, each of which is joined to multiple network channels. Applications will
have different rights in different channels according to their wallet identity
provided in `gateway.connect()`.

我们在这里可以看到Hyperledger Fabric的一个强大功能 -- 应用程序可以通过连接到多个网关peers来
加入**网络中的网络**，每个网关peer都连接到多个网络通道。 根据`gateway.connect()`提供的钱包标识，
应用程序将在不同的通道中拥有不同的权限。

## Construct request - 构造请求

The application is now ready to **issue** a commercial paper.  To do this, it's
going to use `CommercialPaperContract` and again, its fairly straightforward to
access this smart contract:

该应用程序现在准备**发行**商业票据。 要做到这一点，它将再次使用`CommercialPaperContract`，
，它可以非常直接地访问这个智能合约：

```JavaScript
const contract = await network.getContract('papercontract', 'org.papernet.commercialpaper');
```

Note how the application provides a name -- `papercontract` -- and an explicit
contract name: `org.papernet.commercialpaper`! We see how a [contract
name](./contractname.html) picks out one contract from the `papercontract.js`
chaincode file that contains many contracts. In PaperNet, `papercontract.js` was
installed and instantiated with the name `papercontract`, and if you're
interested, read [how](../chaincode4noah.html) to install and instantiate a
chaincode containing multiple smart contracts.

请注意应用程序如何提供名称 -- `papercontract` -- 以及可选的合约命名空间： `org.papernet.commercialpaper`！ 
我们看到[contractname](./contractname.html)如何从包含许多合约的`papercontract.js`链码文件中选出一个合约。 
在PaperNet中，`papercontract.js`已安装并使用名称`papercontract`实例化，如果您有兴趣，
请[how](../chaincode4noah.html)安装和实例化包含多个智能合约的链代码。

If our application simultaneously required access to another contract in
PaperNet or BondNet this would be easy:

如果我们的应用程序同时需要访问PaperNet或BondNet中的另一个合同，这将很容易：

```JavaScript
const euroContract = await network.getContract('EuroCommercialPaperContract');

const bondContract = await network2.getContract('BondContract');
```

In these examples, note how we didn't use a qualifying contract name -- we have
only one smart contract per file, and `getContract()` will use the first
contract it finds.

Recall the transaction MagnetoCorp uses to issue its first commercial paper:

回想一下MagnetoCorp用于发行其第一份商业票据的交易：

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

Let's now submit this transaction to PaperNet!

我们现在将此交易提交给PaperNet！

## Submit transaction - 提交交易

Submitting a transaction is a single method call to the SDK:

提交一个交易是对SDK的单个方法调用：

```JavaScript
const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001', '2020-05-31', '2020-11-30', '5000000');
```

See how the `submitTransaction()` parameters match those of the transaction
request.  It's these values that will be passed to the `issue()` method in the
smart contract, and used to create a new commercial paper.  Recall its
signature:

了解`submitTransaction()`参数如何与交易请求匹配。 它们的值将传递给智能合约中的`issue()`方法，
并用于创建新的商业票据。 回想一下它的签名：

```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```

It might appear that a smart contract receives control shortly after the
application issues `submitTransaction()`, but that's not the case. Under the
covers, the SDK uses the `connectionOptions` and `connectionProfile` details to
send the transaction proposal to the right peers in the network, where it can
get the required endorsements. But the application doesn't need to worry about
any of this -- it just issues `submitTransaction` and the SDK takes care of it
all!

Note that the `submitTransaction` API includes a process for listening for
transaction commits. Listening for commits is required because without it,
you will not know whether your transaction has successfully been orderered,
validated, and committed to the ledger.

Let's now turn our attention to how the application handles the response!

现在让我们将注意力转向应用程序如何处理响应！

## Process response - 处理响应

Recall from `papercontract.js` how the **issue** transaction returns a
commercial paper response:

回想一下`papercontract.js` 如何**发行**交易返回一个商业票据响应：

```JavaScript
return paper.toBuffer();
```

You'll notice a slight quirk -- the new `paper` needs to be converted to a
buffer before it is returned to the application. Notice how `issue.js` uses the
class method `CommercialPaper.fromBuffer()` to rehydrate the response buffer as
a commercial paper:

您会注意到一个轻微的怪癖 -- 新`paper`需要在返回到应用程序之前转换为缓冲区。 
请注意`issue.js`如何使用类方法`CommercialPaper.fromBuffer()`将响应缓冲区重新转换为商业票据：

```JavaScript
let paper = CommercialPaper.fromBuffer(issueResponse);
```

This allows `paper` to be used in a natural way in a descriptive completion
message:

这样可以在描述性完成消息中以自然的方式使用 `paper`：

```JavaScript
console.log(`${paper.issuer} commercial paper : ${paper.paperNumber} successfully issued for value ${paper.faceValue}`);
```

See how the same `paper` class has been used in both the application and smart
contract -- if you structure your code like this, it'll really help readability
and reuse.

了解如何在应用程序和智能合约中使用相同的`paper`类 - 如果您像这样构建代码，它将真正有助于可读性和重用。

As with the transaction proposal, it might appear that the application receives
control soon after the smart contract completes, but that's not the case. Under
the covers, the SDK manages the entire consensus process, and notifies the
application when it is complete according to the `strategy` connectionOption. If
you're interested in what the SDK does under the covers, read the detailed
[transaction flow](../../txflow.html).

与交易提案一样，智能合约完成后，应用程序可能会很快收到控制权，但事实并非如此。 SDK负责管理整个共识流程，
并根据`strategy`connectionOption在应用程序完成时通知应用程序。 如果您对SDK的内容感兴趣，
请阅读详细的[交易流程](../../txflow.html)。

That’s it! In this topic you’ve understood how to call a smart contract from a
sample application by examining how MagnetoCorp's application issues a new
commercial paper in PaperNet. Now examine the key ledger and smart contract data
structures are designed by in the [architecture topic](./architecture.md) behind
them.

就是这样！ 在本主题中，您已了解如何通过检查MagnetoCorp的应用程序如何在PaperNet中发行新的商业票据，
从示例应用程序调用智能合约。 现在检查关键账本和智能合约数据结构是由它们背后的
[架构主题](./architecture.md)设计的。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
