Understanding the Fabcar Network
================================

理解Fabcar 网络
================================

Fabcar was designed to leverage a network stripped down to only the components
necessary to run an application. And even with that level of simplification,
the ``./startFabric.sh`` script takes care of the installation and
configuration not baked into the network itself.

设计Fabcar的目的是将整个网络分离成各个组件来运行应用。它在一定程度上进行了简化，使用 ``./startFabric.sh`` 脚本来对网络进行搭建。

Obscuring the underpinnings of the network to that degree is fine for the
majority of application developers. They don't necessarily need to know how
network components actually work in detail in order to create their app.

对于大多数开发人员来说，将搭建网络中的基本操作隐藏到这种程度是很好的选择。他们在创建它们的app时，不需要了解到网络中的组件具体是怎么配合工作的。

But for those who do want to know about the fun stuff going on under the covers,
let's go through how applications **connect** to the network and
how they propose **queries** and **updates** on a more granular level, as well
as point out the differences between a small scale test network like Fabcar and
how apps will usually end up working in the real world.

但是对于那些想要了解深层原理的人来说，让我们一起更深入了解应用程序是怎么 **连接** 网络并发送 **queries** 和 **updates** 的，同时找到运行Fabcar这样的小应用与实际商用的app之间的区别。

We'll also point you to where you can get detailed information about how Fabric
networks are created and how a transaction flow works beyond the scope of the
role an application plays.

我们同样也会为你讲解，Fabric网络是怎么建立的和事务是怎么在网络中流转工作的。

Components of the Fabcar Network
--------------------------------

Fabcar网络中的组件
--------------------------------

Fabcar uses the "basic-network" sample as its limited development network. It
consists of a single peer node configured to use CouchDB as the state database,
a single "solo" ordering node, a certificate authority (CA) and a CLI container
for executing commands.

Fabcar使用了"basic-network"的样本来搭建它的网络环境。包含了一个使用CouchDB作为状态数据库的peer节点，一个采用"solo"共识的order 节点，一个CA和一个CLI容器来执行指令。

For detailed information on these components and what they do, refer to
:doc:`build_network`.

想要了解更多关于组件及组件作用的细节，请参照 :doc:`build_network`。

These components are bootstrapped by the ``./startFabric.sh`` script, which
also:

* creates a channel and joins the peer to the channel
* installs the ``fabcar`` smart contract onto the peer's file system and instantiates it on the channel (instantiate starts a container)
* calls the ``initLedger`` function to populate the channel ledger with 10 unique cars

这些组件将会通过 ``./startFabric.sh`` 自行创建，包括：
          * 创建channel 并且peer 加入channel
          * 安装 ``fabcar`` 智能合约在peer的文件系统并在channel中实例化
          * 调用 ``initLedger`` 功能在账本中生成10量不同的汽车

These operations would typically be done by an organizational or peer admin.
The script uses the CLI to execute these commands, however there is support in
the SDK as well. Refer to the `Hyperledger Fabric Node SDK repo
<https://github.com/hyperledger/fabric-sdk-node>`__ for example scripts.

这些操作分别被一个组织或peer admin完成。这个脚本使用CLI来执行命令，并且在SDK中也可以执行。请参照
`Hyperledger Fabric Node SDK repo <https://github.com/hyperledger/fabric-sdk-node>`__ 查看脚本示例。

How an Application Interacts with the Network
---------------------------------------------

应用是怎么与网络交互的
---------------------------------------------

Applications use **APIs** to invoke smart contracts. These smart contracts are
hosted in the network and identified by name and version. For example, our
chaincode container is titled - ``dev-peer0.org1.example.com-fabcar-1.0`` -
where the name is ``fabcar``, the version is ``1.0``, and the peer it is running
against is ``dev-peer0.org1.example.com``.

应用使用 **APIs** 来调用智能合约。这些智能合约在网络中以名称和版本进行区分，我们的chaincode容器叫做 - ``dev-peer0.org1.example.com-fabcar-1.0`` - 他的名字是 ``fabcar``, 版本号是 ``1.0``，peer运行在``dev-peer0.org1.example.com`` 中。

APIs are accessible with an SDK. For purposes of this exercise, we're using the
`Hyperledger Fabric Node SDK <https://fabric-sdk-node.github.io/>`__ though
there is also a Java SDK and CLI that can be used to drive transactions.
SDKs encapsulate all access to the ledger by allowing an application to
communicate with smart contracts, run queries, or receive ledger updates. These APIs use
several different network addresses and are run with a set of input parameters.

APIs是可以被SDK访问的。为了练习，我们使用 `Hyperledger Fabric Node SDK <https://fabric-sdk-node.github.io/>`__ 同时还有Java版本的SDK和CLI可以使用。SDK封装了接入账本调用智能合约的方法，包括查询或接受账本的变化。这些APIs使用了不同网络地址并与需要一系列的参数输入。

Smart contracts are installed by a peer administrator and then instantiated on a
channel by an identity fulfilling the chaincode's instantiation policy, which by
default is comprised of channel administrators.  The instantiation of
the smart contract follows the same transaction flow as a normal invocation - endorse,
order, validate, commit - and is a prerequisite to interacting with a chaincode
container. The script that launched our simplified Fabcar test network took care
of the installation and instantiation for us.

智能合约由对等管理员安装，然后通过履行链代码实例化策略的标识在通道上实例化，该策略默认由通道管理员组成。智能合约的实例化与正常调用的事务流相同 - 认可，订购，验证，提交 - 并且是与链代码容器交互的先决条件。这个脚本帮助我们启动Fabcar测试网络并替我们安装和实例化链码。

Query
^^^^^

查询
^^^^^

Queries are the simplest kind of invocation: a call and response.  The most common query
will interrogate the state database for the current value associated
with a key (``GetState``).  However, the `chaincode shim interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub>`__
also allows for different types of ``Get`` calls (e.g. ``GetHistoryForKey`` or ``GetCreator``).

查询是最简单的调用：一次请求和一个回复。最常见的查询将询问状态数据库中与键相关的当前值（``GetState``）。并且，`chaincode shim interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStub>`__ 同样支持不同类型的 ``Get`` 调用(如 ``GetHistoryForKey`` or ``GetCreator``)。


In our example, the peer holds a hash chain of all transactions and maintains
chaincode state through use of a state database, which in our case is a CouchDB container.  CouchDB
provides the added functionality of rich queries, contingent upon the chaincode data (key/val pairs)
being modeled as JSON.  When we call the ``GetState`` API in our smart contract, we
are retrieving the JSON value associated with a car from the CouchDB state database.

在我们的例子中，CouchDB容器维护了包含所有transaction的hash链并通过状态数据库维护了链码的状态。CouchDB提供了富查询功能，将链码数据(key/value)视情况的封装成json。当我们在智能合约中调用 ``GetState`` API时，我们将从状态数据库CouchDB中获得相关联的json数据。

Queries are constructed by identifying a peer, a chaincode, a channel and a set of
inputs (e.g. the key) for an available chaincode function and then utilizing the
``chain.queryByChaincode`` API to send the query to the peer.  The corresponding
value to the supplied inputs is returned to the application client as a response.

Query请求是由认证过的peer，chaincode，channel和一系列满足chaincode参数组成的，然后调用 ``chain.queryByChaincode`` API发送给peer节点。满足输入参数的数据将作为response返回给应用客户端。

Updates
^^^^^^^
更新
^^^^^^^

Ledger updates start with an application generating a transaction proposal. As with
query, a request is constructed to identify a peer, chaincode, channel, function, and
set of inputs for the transaction. The program then calls the
``channel.SendTransactionProposal`` API to send the transaction proposal to the
peer(s) for endorsement.

应用生成prososal transaction后账本开始更新。与query相同，一个请求包含了认证的peer，chaincode，channel，fucntion和输入参数。然后程序调用 ``channel.SendTransactionProposal`` API发送proposal 给peer进行背书。

The network (i.e. the endorsing peer(s)) returns a proposal response, which the
application uses to build and sign a transaction request. This request is sent
to the ordering service by calling the ``channel.sendTransaction`` API. The
ordering service bundles the transaction into a block and delivers it to all
peers on a channel for validation (the Fabcar network has only one peer and one channel).

网络（背书节点）返回proposal的response，response用来建立和签名请求。这个请求通过调用 ``channel.sendTransaction`` API发送给排序服务。排序服务将transaction分装进入block并传递给在同一个channel中的peer进行认证（Fabcar中只有一个peer和一个channel）。
Finally the application uses the :doc:`peer_event_services` to register for events
associated with a specific transaction ID so that the application can be notified
about the fate of a transaction (i.e. valid or invalid).

For More Information
--------------------

更多信息
--------------------

To learn more about how a transaction flow works beyond the scope of an
application, check out :doc:`txflow`.

想要了解更多关于transaction流转的信息，请参照 :doc:`txflow`。

To get started developing chaincode, read :doc:`chaincode4ade`.

想开始开发chaincode,请参照 :doc:`chaincode4ade`。

For more information on how endorsement policies work, check out
:doc:`endorsement-policies`.

想了解背书策略相关信息，请参照 :doc:`endorsement-policies`。

For a deeper dive into the architecture of Hyperledger Fabric, check out
:doc:`arch-deep-dive`.

想深入了解Hyperledger Fabric架构相关信息，请参照 :doc:`arch-deep-dive`。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
