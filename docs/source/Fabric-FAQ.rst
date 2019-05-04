Frequently Asked Questions
==========================

Endorsement - 背书
--------------------

**Endorsement architecture - 背书架构**:

:Question:
  How many peers in the network need to endorse a transaction?

  在一个网络中需要多少个 peers 来对一笔交易进行背书？

:Answer:
  The number of peers required to endorse a transaction is driven by the
  endorsement policy that is specified in the chaincode definition.

:Question:
  Does an application client need to connect to all peers?

  一个应用程序客户端需要连接所有的 peers 吗？

:Answer:
  Clients only need to connect to as many peers as are required by the
  endorsement policy for the chaincode.

  客户端只需要连接对于 chaincode 的背书策略所需数量的 peers 即可。

Security & Access Control - 安全 & 访问控制
--------------------------------------------

:Question:
  How do I ensure data privacy?

  我如何来确保数据隐私？

:Answer:
  There are various aspects to data privacy. First, you can segregate your
  network into channels, where each channel represents a subset of participants
  that are authorized to see the data for the chaincodes that are deployed to
  that channel.

  对于数据隐私，这里有很多个方面。首先，你可以将你的网络隔离到不同的 channels，每个 channel 代表了网络参与者们的一个子集，这些参与者们被授权查看对于被部署到这个 channel 的 chaincode 的数据。

  Second, you can use `private-data <private-data/private-data.html>`_ to keep ledger data private from
  other organizations on the channel. A private data collection allows a
  defined subset of organizations on a channel the ability to endorse, commit,
  or query private data without having to create a separate channel.
  Other participants on the channel receive only a hash of the data.
  For more information refer to the :doc:`private_data_tutorial` tutorial.
  Note that the key concepts topic also explains `when to use private data instead of a channel <private-data/private-data.html#when-to-use-a-collection-within-a-channel-vs-a-separate-channel>`_.

  其次，你可以使用 `private-data <private-data/private-data.html>`_ 来同这个 channel 上的其他组织保持账本的数据隐私。一个 private data collection 允许在一个 channel 上定义的组织的子集有能力来背书、提交或者查询 private data 而不需要创建一个额外的 channel。在这个 channel 上的其他的参与者只会收到数据的哈希值。更多信息可以参考 :doc:`private_data_tutorial` 教程。注意，关键概念话题也解释了 `什么时候应该使用 private data 而不是一个 channel <private-data/private-data.html#when-to-use-a-collection-within-a-channel-vs-a-separate-channel>`_。

  Third, as an alternative to Fabric hashing the data using private data,
  the client application can hash or encrypt the data before calling
  chaincode. If you hash the data then you will need to provide a means to
  share the source data. If you encrypt the data then you will need to provide
  a means to share the decryption keys.

  第三，作为 Fabric 使用 private data 来对于数据进行哈希的替代方案，客户端应用能够在调用 chaincode 之前将数据进行哈希或者加密。如果你将数据进行哈希运算的话，那么你需要提供一个方式来共享原始的数据。如果你将信息进行加密的话，那么你需要提供一个方式来共享解密秘钥。

  Fourth, you can restrict data access to certain roles in your organization, by
  building access control into the chaincode logic.

  第四，你可以通过向 chaincode 逻辑中构建访问控制的方式，将对于数据的访问限制在你的组织中的某些角色上。

  Fifth, ledger data at rest can be encrypted via file system encryption on the
  peer, and data in-transit is encrypted via TLS.

  第五，剩下的账本数据可以通过在 peer 上的文件系统加密的方式来进行加密，并且在交换的数据是通过 TLS 来进行加密的。

:Question:
  Do the orderers see the transaction data?

     排序节点能够看到交易数据吗？

:Answer:
  No, the orderers only order transactions, they do not open the transactions.
  If you do not want the data to go through the orderers at all, then utilize
  the private data feature of Fabric.  Alternatively, you can hash or encrypt
  the data in the client application before calling chaincode. If you encrypt
  the data then you will need to provide a means to share the decryption keys.

  不，排序节点仅仅对交易进行排序，他们不会打开交易。如果你不想让数据经过排序节点，那么应该使用 Fabric 的 private data 功能。或者，你可以在调用 chaincode 之前在客户端应用中对数据进行哈希运算或加密。如果你对数据进行加密的话，那么你需要提供 一种方式来共享解密的秘钥。

Application-side Programming Model - 应用程序端编程模型
-------------------------------------------------------

:Question:
  How do application clients know the outcome of a transaction?

  应用程序客户端如何知道一笔交易的输出是什么？

:Answer:
  The transaction simulation results are returned to the client by the
  endorser in the proposal response.  If there are multiple endorsers, the
  client can check that the responses are all the same, and submit the results
  and endorsements for ordering and commitment. Ultimately the committing peers
  will validate or invalidate the transaction, and the client becomes
  aware of the outcome via an event, that the SDK makes available to the
  application client.

  模拟交易的结果会在提案的反馈中通过背书节点返回给客户端。如果这里有多个背书节点，那么客户端会检查所有的反馈都是一样的，并且将结果和背书提交来进行排序及提交。最终提交节点将会验证或者不验证这笔交易，并且客户端会通过一个 SDK 对于应用程序客户端可用的 event 变得可以了解输出的内容了。

:Question:
  How do I query the ledger data?

  我应该如何查询账本的数据？

:Answer:
  Within chaincode you can query based on keys. Keys can be queried by range,
  and composite keys can be modeled to enable equivalence queries against
  multiple parameters. For example a composite key of (owner,asset_id) can be
  used to query all assets owned by a certain entity. These key-based queries
  can be used for read-only queries against the ledger, as well as in
  transactions that update the ledger.

  在 chaincode 中，你可以基于 keys 来查询。Keys 可以按照范围来查询，组合 keys 还可以被用来针对于多参数进行等效的查询。比如一个组合 key （owner, asset_id）可以被用来查询所有由某个 entity 所有的资产。这些基于 key 的查询可以被用来对于账本进行只读查询，在更新账本的交易中也可以。

  If you model asset data as JSON in chaincode and use CouchDB as the state
  database, you can also perform complex rich queries against the chaincode
  data values, using the CouchDB JSON query language within chaincode. The
  application client can perform read-only queries, but these responses are
  not typically submitted as part of transactions to the ordering service.

  如果你将资产的数据在 chaincode 中定义为 JSON 格式并且使用 CouchDB 作为 state 数据库的话，你也可以在 chaincode 中使用 CouchDB JSON 查询语言来针对 chaincode 数据值进行复杂的富查询。应用程序客户端可以进行只读查询，但是这些反馈通常不会作为交易的一部分被提交到排序服务。

:Question:
  How do I query the historical data to understand data provenance?

  我应该如何查询历史数据来理解数据的起源？

:Answer:
  The chaincode API ``GetHistoryForKey()`` will return history of
  values for a key.

  Chaincode API ``GetHistoryForKey()`` 能够返回一个 key 对应的值的历史。

:Question:
  How to guarantee the query result is correct, especially when the peer being
  queried may be recovering and catching up on block processing?

  如何保证查询的结果是正确的，尤其是当被查询的 peer 可能正在恢复并且在追赶区块的处理？

:Answer:
  The client can query multiple peers, compare their block heights, compare
  their query results, and favor the peers at the higher block heights.

  客户端可以查询多个 peers，比较他们的区块高度，比较他们的查询结果，并且选择具有更高的区块高度的 peers。

Chaincode (Smart Contracts and Digital Assets) - Chaincode（智能合约和数字资产）
----------------------------------------------------------------------------------

:Question:
  Does Hyperledger Fabric support smart contract logic?

  Hyperledger Fabric 支持智能合约逻辑吗？

:Answer:
  Yes. We call this feature :ref:`chaincode`. It is our interpretation of the
  smart contract method/algorithm, with additional features.

  是的。我们将这个功能称为 Chaincode。它是我们对于智能合约方法/算法的解释，带有额外的功能。

  A chaincode is programmatic code deployed on the network, where it is
  executed and validated by chain validators together during the consensus
  process. Developers can use chaincodes to develop business contracts,
  asset definitions, and collectively-managed decentralized applications.

  一个 chaincode 是部署在网络上的编程代码，它会在共识过程中被 chain 验证者执行并验证。开发者可以使用 chaincodes 来开发业务合约，资产定义，以及共同管理的去中心化的应用。

:Question:
  How do I create a business contract?

  我如何能够创建一个业务合约？

:Answer:
  There are generally two ways to develop business contracts: the first way is
  to code individual contracts into standalone instances of chaincode; the
  second way, and probably the more efficient way, is to use chaincode to
  create decentralized applications that manage the life cycle of one or
  multiple types of business contracts, and let end users instantiate
  instances of contracts within these applications.

  通常有两种方式开发业务合约：第一种方式是将单独的合约编码到独立的 chaincode 实例中。第二种方式，也可能是更有效率的一种方式，是使用 chaincode 来创建去中心化的应用，来管理一个或者多个类型的业务合约的生命周期，并且让用户在这些应用中实例化这些合约的实例。

:Question:
  How do I create assets?

  我应该如何创建资产？

:Answer:
  Users can use chaincode (for business rules) and membership service (for
  digital tokens) to design assets, as well as the logic that manages them.

  用户可以使用 chaincode（对于业务规则）和成员服务（对于数字 tokens）来设计资产，以及管理这些资产的逻辑。

  There are two popular approaches to defining assets in most blockchain
  solutions: the stateless UTXO model, where account balances are encoded
  into past transaction records; and the account model, where account
  balances are kept in state storage space on the ledger.

  在大多区块链解决方案中由两种流行的方式来定义资产：stateless 的 UTXO 模型，账户余额会被编码到过去的交易记录中；和账户模型，账户的余额会被保存在账本上的 state 存储空间中。

  Each approach carries its own benefits and drawbacks. This blockchain
  technology does not advocate either one over the other. Instead, one of our
  first requirements was to ensure that both approaches can be easily
  implemented.

  每种方式都带有他们自己的好处及坏处。这个区块链技术不主张任何一种方式。相反，我们的第一个需求就是确保两种方式都能够被轻松实现。

:Question:
  Which languages are supported for writing chaincode?

  编写 chaincode 都支持哪些语言？

:Answer:
  Chaincode can be written in any programming language and executed in
  containers. Currently, Golang, node.js and java chaincode are supported.

  Chaincode 能够使用任何的编程语言来编写并且在容器中执行。当前，支持 Golang、node.js 和 java chaincode。

  It is also possible to build Hyperledger Fabric applications using
  `Hyperledger Composer <https://hyperledger.github.io/composer/>`__.

  也可以使用 `Hyperledger Composer <https://hyperledger.github.io/composer/>`__ 来构建 Hyperledger Fabric 应用。

:Question:
  Does the Hyperledger Fabric have native currency?

  Hyperledger 有原生的货币吗？

:Answer:
  No. However, if you really need a native currency for your chain network,
  you can develop your own native currency with chaincode. One common attribute
  of native currency is that some amount will get transacted (the chaincode
  defining that currency will get called) every time a transaction is processed
  on its chain.

  没有。然而，如果你的 chain 网络真的需要一个原生的货币的话，你可以通过 chaincode 来开发你自己的原生货币。对于原生货币的一个常用属性就是一些数量的货币会在每次一笔交易在它的 chain 上被处理的时候被交换（定义该货币的 chaincode 将被调用）。

Differences in Most Recent Releases - 近期 Releases 中的不同
-------------------------------------------------------------

:Question:
  Where can I find what  are the highlighted differences between releases?

  我在哪里能够看到在不同的 releases 中都有哪些变动？

:Answer:
  The differences between any subsequent releases are provided together with
  the :doc:`releases`.

  在任何 releases 中的变动的地方在 :doc:`releases` 中一起被提供出来。

:Question:
  Where to get help for the technical questions not answered above?

  如果上边的问题没有被回答的话，我应该到哪里来获得技术上的帮助？

:Answer:
  Please use `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger>`__.

  请使用 `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger>`__。

Ordering Service - 排序服务
-----------------------------

:Question:
  **I have an ordering service up and running and want to switch consensus
  algorithms. How do I do that?**

  我有一个正在运行的排序服务，如果我想要转换共识算法，我该怎么做？

:Answer:
  This is explicitly not supported.

  这个是不支持的。
..

:Question:
  **What is the orderer system channel?**

  什么是排序节点系统 channel？

:Answer:
  The orderer system channel (sometimes called ordering system channel) is the
  channel the orderer is initially bootstrapped with. It is used to orchestrate
  channel creation. The orderer system channel defines consortia and the initial
  configuration for new channels. At channel creation time, the organization
  definition in the consortium, the ``/Channel`` group's values and policies, as
  well as the ``/Channel/Orderer`` group's values and policies, are all combined
  to form the new initial channel definition.

  排序节点系统 channel（有时被称为排序系统 channel）指的是排序节点初始被启动的 channel。它被用来编排 channel 的创建。排序节点系统 channel 定义了联盟以及对于新的 channels 的初始配置信息。在 channel 被创建的时候，对于在联盟中的组织的定义， ``/Channel`` 组的值和策略，以及 ``/Channel/Orderer`` 组的值和策略，会被合并起来来形成一个新的初始的 channel 定义。
..

:Question:
  **If I update my application channel, should I update my orderer system
  channel?**

  如果我更新了我的应用程序 channel，我是否需要更新我的排序系统 channel？

:Answer:
  Once an application channel is created, it is managed independently of any
  other channel (including the orderer system channel). Depending on the
  modification, the change may or may not be desirable to port to other
  channels. In general, MSP changes should be synchronized across all channels,
  while policy changes are more likely to be specific to a particular channel.

  一旦一个应用程序 channel 被创建，它会独立于其他任何的 channel（包括排序节点系统 channel）被管理。基于所做的改动，变动可能需要或者可能不需要被放置到其他的 channels。大体来讲，MSP 的变动应该被同步到所有的 channels，然而策略的变动更像是针对于一个特定 channel 的。
..

:Question:
  **Can I have an organization act both in an ordering and application role?**

  我可以有一个组织既作为一个排序节点又作为应用程序的角色吗？

:Answer:
  Although this is possible, it is a highly discouraged configuration. By
  default the ``/Channel/Orderer/BlockValidation`` policy allows any valid
  certificate of the ordering organizations to sign blocks. If an organization
  is acting both in an ordering and application role, then this policy should be
  updated to restrict block signers to the subset of certificates authorized for
  ordering.

  尽管这是可能的，但是我们强烈不建议这样配置。默认的 ``/Channel/Orderer/BlockValidation`` 策略允许任何具有有效的证书的排序组织可以来为区块签名。如果一个组织既作为一个排序节点又是应用程序的角色的话，那么这个策略就应该被更新为将区块签名者限制为被授权来排序的证书的子集。
..

:Question:
  **I want to write a consensus implementation for Fabric. Where do I begin?**

  我想要写一个针对于 Fabric 的共识实现，我应该如何开始？

:Answer:
  A consensus plugin needs to implement the ``Consenter`` and ``Chain``
  interfaces defined in the `consensus package`_. There are two plugins built
  against these interfaces already: solo_ and kafka_. You can study them to take
  cues for your own implementation. The ordering service code can be found under
  the `orderer package`_.

  一个共识的插件需要实现在 `consensus package`_ 中定义 ``Consenter`` 和 ``Chain`` 接口。针对于这些接口已经有了两个插件：solo_ 和 kafka_。你可以学习他们来为你自己的实现寻求线索。排序服务的代码可以在 `orderer package`_ 中找到。

.. _consensus package: https://github.com/hyperledger/fabric/blob/master/orderer/consensus/consensus.go
.. _solo: https://github.com/hyperledger/fabric/tree/master/orderer/consensus/solo
.. _kafka: https://github.com/hyperledger/fabric/tree/master/orderer/consensus/kafka
.. _orderer package: https://github.com/hyperledger/fabric/tree/master/orderer

..

:Question:
  **I want to change my ordering service configurations, e.g. batch timeout,
  after I start the network, what should I do?**

  我想要改变我的排序服务配置，比如批处理的超时时间，当我启动了网络之后，我该如何做？

:Answer:
  This falls under reconfiguring the network. Please consult the topic on
  :doc:`commands/configtxlator`.

  这属于网络的配置。请参考 :doc:`commands/configtxlator` 话题。

Solo
~~~~

:Question:
  **How can I deploy Solo in production?**

  我如何在生产环境部署 Solo？

:Answer:
  Solo is not intended for production.  It is not, and will never be, fault
  tolerant.

  Solo 不是被用于生产环境的。它不是并且永远也不会是容错的。

Kafka
~~~~~

:Question:
  **How do I remove a node from the ordering service?**

  我如何能够从排序服务中删除一个节点？

:Answer:
  This is a two step-process:

  1. Add the node's certificate to the relevant orderer's MSP CRL to prevent peers/clients from connecting to it.
  2. Prevent the node from connecting to the Kafka cluster by leveraging standard Kafka access control measures such as TLS CRLs, or firewalling.


  这是一个两步的流程：

  1. 将节点的证书添加到相关排序节点的 MSP CRL 中来阻止 peers/客户端连接到它。
  2. 通过使用标准的 Kafka 访问控制措施，比如 TLS CRLs 或者防火墙的方式来阻止节点连接 Kafka 集群。
..

:Question:
  **I have never deployed a Kafka/ZK cluster before, and I want to use the
  Kafka-based ordering service. How do I proceed?**

  我之前从来没有部署过一个 Kafka/ZK 集群，我想使用基于 Kafka 的排序服务。我应该如何做？

:Answer:
  The Hyperledger Fabric documentation assumes the reader generally has the
  operational expertise to setup, configure, and manage a Kafka cluster
  (see :ref:`kafka-caveat`). If you insist on proceeding without such expertise,
  you should complete, *at a minimum*, the first 6 steps of the
  `Kafka Quickstart guide`_ before experimenting with the Kafka-based ordering
  service. You can also consult `this sample configuration file`_ for a brief
  explanation of the sensible defaults for Kafka/ZooKeeper.

  Hyperledger Fabric 文档假设阅读者大体上已经有了维护的经验来创建、设置和管理一个 Kafka 集群（查看 :ref:`kafka-caveat`）。如果没有这样的经验你还要继续的话，你应该在尝试基于 Kafka 的排序服务之前完成，至少 `Kafka Quickstart guide`_ 中的前 6 步。你也可以查看 `this sample configuration file`_ 来了解一个关于 Kafka/ZooKeeper 的合理默认值的简洁的解释。

.. _Kafka Quickstart guide: https://kafka.apache.org/quickstart
.. _this sample configuration file: https://github.com/hyperledger/fabric/blob/release-1.1/bddtests/dc-orderer-kafka.yml

..

:Question:
  **Where can I find a Docker composition for a network that uses the
  Kafka-based ordering service?**

  我从哪里能够找到使用基于 Kafka 的排序服务的 Docker？

:Answer:
  Consult `the end-to-end CLI example`_.

  查看 `the end-to-end CLI example`_。
.. _the end-to-end CLI example: https://github.com/hyperledger/fabric/blob/release-1.3/examples/e2e_cli/docker-compose-e2e.yaml

..

:Question:
  **Why is there a ZooKeeper dependency in the Kafka-based ordering service?**

  为什么在基于 Kafka 的排序服务中会有对于 ZooKeeper 的依赖？

:Answer:
  Kafka uses it internally for coordination between its brokers.

  Kafka 在内部使用它来在它的 brokers 之间进行协调。
..

:Question:
  **I'm trying to follow the BYFN example and get a "service unavailable" error,
  what should I do?**

  我尝试遵循 BYFN 样例并且遇到一个 “service unavailable” 错误，我应该怎么做？

:Answer:
  Check the ordering service's logs. A "Rejecting deliver request because of
  consenter error" log message is usually indicative of a connection problem
  with the Kafka cluster. Ensure that the Kafka cluster is set up properly, and
  is reachable by the ordering service's nodes.

BFT
~~~

:Question:
  **When is a BFT version of the ordering service going to be available?**

  什么时候会有 BFT 版本的排序服务？

:Answer:
  No date has been set. We are working towards a release during the 1.x cycle,
  i.e. it will come with a minor version upgrade in Fabric. Track FAB-33_ for
  updates.

  目前还没有具体的时间。我们在 1.x 周期中尝试将它放置到一个 release 中，比如它会在 Fabric 的一个小的版本更新中。可以查看 FAB-33_ 来获得更新。

.. _FAB-33: https://jira.hyperledger.org/browse/FAB-33

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
