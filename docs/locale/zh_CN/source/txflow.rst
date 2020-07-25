交易流程
================
Transaction Flow
================

本文讲解在一个标准的资产交换中的交易机制。该场景包含两个客户端 A 和 B，他们分别代表萝卜的买方和卖方。他们在网络上都有一个 Peer 节点，他们通过该节点来发送交易和与账本交互。

This document outlines the transactional mechanics that take place during a
standard asset exchange. The scenario includes two clients, A and B, who are
buying and selling radishes. They each have a peer on the network through which
they send their transactions and interact with the ledger.

.. image:: images/step0.png

**假设**

**Assumptions**

该流程中，假设已经设置了一个通道，并且该通道正常运行。应用程序的用户已经使用组织的 CA 注册和登记完成，并且拿到了用于在网络中用确认身份的加密材料。

This flow assumes that a channel is set up and running. The application user has
registered and enrolled with the organization’s Certificate Authority (CA) and
received back necessary cryptographic material, which is used to authenticate to
the network.

链码（包含了萝卜商店初始状态的键值对）已经安装在 Peer 节点上并在通道上完成了实例化。链码中的逻辑定义了萝卜的交易和定价规则。链码也设置了一个背书策略，该策略是每一笔交易都必须被 ``peerA`` 和 ``peerB`` 都签名。

The chaincode (containing a set of key value pairs representing the initial
state of the radish market) is installed on the peers and deployed to the
channel. The chaincode contains logic defining a set of transaction instructions
and the agreed upon price for a radish. An endorsement policy has also been set
for this chaincode, stating that both ``peerA`` and ``peerB`` must endorse any
transaction.

.. image:: images/step1.png

1. **客户端 A 发起一笔交易**

1. **Client A initiates a transaction**

将会发生什么？客户端 A 发送一个采购萝卜的请求。该请求会到达 ``peerA`` 和 ``peerB``，他们分别代表客户端 A 和客户端 B。背书策略要求所有交易都要两个节点背书，因此请求要到经过 ``peerA`` 和 ``peerB``。

What's happening? Client A is sending a request to purchase radishes. This
request targets ``peerA`` and ``peerB``, who are respectively representative of
Client A and Client B. The endorsement policy states that both peers must
endorse any transaction, therefore the request goes to ``peerA`` and ``peerB``.

然后，要构建一个交易提案。应用程序使用所支持的 SDK（Node，Java，Python）中的 API 生成一个交易提案。提案是带有确定输入参数的调用链码方法的请求，该请求的作用是读取或者更新账本。

Next, the transaction proposal is constructed. An application leveraging a
supported SDK (Node, Java, Python) utilizes one of the available API's
to generate a transaction proposal. The proposal is a request to invoke a
chaincode function with certain input parameters, with the intent of reading
and/or updating the ledger.

SDK 的作用是将交易提案打包成合适的格式（gRPC 使用的 protocol buffer）以及根据用户的密钥对交易提案生成签名。

The SDK serves as a shim to package the transaction proposal into the properly
architected format (protocol buffer over gRPC) and takes the user’s
cryptographic credentials to produce a unique signature for this transaction
proposal.

.. image:: images/step2.png

2. **背书节点验证签名并执行交易**

2. **Endorsing peers verify signature & execute the transaction**

背书节点验证（1）交易提案的格式完整，（2）且验证该交易提案之前没有被提交过（重放攻击保护），（3）验证签名是有效的（使用 MSP），（4）验证发起者（在这个例子中是客户端 A）有权在该通道上执行该操作（也就是说，每个背书节点确保发起者满足通道 *Writers* 策略）。背书节点将交易提案输入作为调用的链码函数的参数。然后根据当前状态数据库执行链码，生成交易结果，包括响应值、读集和写集（即表示要创建或更新的资产的键值对）。目前没有对账本进行更新。这些值以及背书节点的签名会一起作为“提案响应”返回到 SDK，SDK 会为应用程序解析该响应。

The endorsing peers verify (1) that the transaction proposal is well formed, (2)
it has not been submitted already in the past (replay-attack protection), (3)
the signature is valid (using the MSP), and (4) that the submitter (Client A, in the
example) is properly authorized to perform the proposed operation on that
channel (namely, each endorsing peer ensures that the submitter satisfies the
channel's *Writers* policy). The endorsing peers take the transaction proposal
inputs as arguments to the invoked chaincode's function. The chaincode is then
executed against the current state database to produce transaction results
including a response value, read set, and write set (i.e. key/value pairs
representing an asset to create or update). No updates are made to the
ledger at this point. The set of these values, along with the endorsing peer’s
signature is passed back as a “proposal response” to the SDK which parses the
payload for the application to consume.

.. note:: MSP 是节点的组件，它允许 Peer 节点验证来自客户端的交易请求，并签署交易结果（即背书）。写入策略在通道创建时就会定义，用来确定哪些用户有权向该通道提交交易。有关成员关系的更多信息，请查看 :doc:`membership/membership` 文档。

.. note:: The MSP is a peer component that allows peers to verify transaction
          requests arriving from clients and to sign transaction results
          (endorsements). The writing policy is defined at channel creation time
          and determines which users are entitled to submit a transaction to
          that channel. For more information about membership, check out our
          :doc:`membership/membership` documentation.

.. image:: images/step3.png

3. **检查提案响应**

3. **Proposal responses are inspected**

应用程序验证背书节点的签名，并比较这些提案响应，以确定其是否相同。如果链码只查询账本，应用程序将检查查询响应，并且通常不会将交易提交给排序服务。如果客户端应用程序打算向排序服务提交交易以更新账本，则应用程序在提交之前需确定是否已满足指定的背书策略（即 peerA 和 peerB 都要背书）。该结构是这样的，即使应用程序选择不检查响应或以其他方式转发未背书的交易，节点仍会执行背书策略，并在提交验证阶段遵守该策略。

The application verifies the endorsing peer signatures and compares the proposal
responses to determine if the proposal responses are the same. If the chaincode
is only querying the ledger, the application would only inspect the query response and
would typically not submit the transaction to the ordering service. If the client
application intends to submit the transaction to the ordering service to update the
ledger, the application determines if the specified endorsement policy has been
fulfilled before submitting (i.e. did peerA and peerB both endorse). The
architecture is such that even if an application chooses not to inspect
responses or otherwise forwards an unendorsed transaction, the endorsement
policy will still be enforced by peers and upheld at the commit validation
phase.

.. image:: images/step4.png

4. **客户端将背书结果封装进交易**

4. **Client assembles endorsements into a transaction**

应用程序将交易提案和“交易消息”中的交易响应“广播”给排序服务。交易会包含读写集，背书节点的签名和通道 ID。排序服务不需要为了执行其操作而检查交易的整个内容，它只是从网络中的所有通道接收交易，将它们按时间按通道排序，并将每个通道的交易打包成区块。

The application “broadcasts” the transaction proposal and response within a
“transaction message” to the ordering service. The transaction will contain the
read/write sets, the endorsing peers signatures and the Channel ID. The
ordering service does not need to inspect the entire content of a transaction in
order to perform its operation, it simply receives transactions from all
channels in the network, orders them chronologically by channel, and creates
blocks of transactions per channel.

.. image:: images/step5.png

5. **验证和提交交易**

5. **Transaction is validated and committed**

交易区块被“发送”给通道上的所有 Peer 节点。对区块内的交易进行验证，以确保满足背书策略，并确保自交易执行生成读集以来，读集中变量的账本状态没有变化。块中的交易会被标记为有效或无效。

The blocks of transactions are “delivered” to all peers on the channel.  The
transactions within the block are validated to ensure endorsement policy is
fulfilled and to ensure that there have been no changes to ledger state for read
set variables since the read set was generated by the transaction execution.
Transactions in the block are tagged as being valid or invalid.

.. image:: images/step6.png

6. **账本更新**

6. **Ledger updated**

每个 Peer 节点都将区块追加到通道的链上，对于每个有效的交易，写集都提交到当前状态数据库。系统会发出一个事件，通知客户端应用程序本次交易（调用）已被不可更改地附加到链上，同时还会通知交易验证结果是有效还是无效。

Each peer appends the block to the channel’s chain, and for each valid
transaction the write sets are committed to current state database. An event is
emitted by each peer to notify the client application that the transaction (invocation)
has been immutably appended to the chain, as well as notification of whether the
transaction was validated or invalidated.

.. note:: 应用程序应该在提交交易后监听交易事件，例如使用 ``submitTransaction`` API，它会自动监听交易事件。如果不监听交易事件，您将不知道您的交易是否已经被排序、验证并提交到账本。

.. note:: Applications should listen for the transaction event after submitting
          a transaction, for example by using the ``submitTransaction``
          API, which automatically listen for transaction events. Without
          listening for transaction events, you will not know
          whether your transaction has actually been ordered, validated, and
          committed to the ledger.

查看 :ref:`sequence diagram <swimlane>` 来更好的理解交易流程。

You can also use the swimlane sequence diagram below to examine the
transaction flow in more detail.

.. image:: images/flow-4.png
