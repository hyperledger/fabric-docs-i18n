Private Data - 私有数据
=======================

.. note:: This topic assumes an understanding of the conceptual material in the
`documentation on private data <private-data/private-data.html>`_.

.. note:: 这个话题假设你已经理解了在 `私有数据的文档 <private-data/private-data.html>`_ 所描述的概念上的资料。

Private data collection definition - 私有数据集合的定义
-------------------------------------------------------

A collection definition contains one or more collections, each having a policy
definition listing the organizations in the collection, as well as properties
used to control dissemination of private data at endorsement time and,
optionally, whether the data will be purged.

一个集合的定义包含了一个或者多个集合，每个集合具有一个原则定义列出了在集合中的所有组织，还包括用来控制在背书阶段私有数据的传播所使用的属性，另外还有一个可选项来决定数据是否会被删除。

The collection definition gets deployed to the channel at the time of chaincode
instantiation (or upgrade). If using the peer CLI to instantiate the chaincode, the
collection definition file is passed to the chaincode instantiation
using the ``--collections-config`` flag. If using a client SDK, check the `SDK
documentation <https://fabric-sdk-node.github.io/>`_ for information on providing the collection
definition.

这个集合的定义会在 chaincode 实例化（或者升级）的时候被部署到 channel 中。如果使用的是 peer CLI 来初始化 chaincode 的话，会使用 ``--collections-config``  标志来将这个集合定义文件传给 chaincode 的实例化过程。如果使用的是一个客户端 SDK，查看 `SDK 文档 <https://fabric-sdk-node.github.io/>`_ 来了解更多关于如何提供集合定义的内容。

Collection definitions are composed of five properties:
集合定义包括五个属性：

* ``name``: Name of the collection.
* ``name``: 集合的名字.

* ``policy``: The private data collection distribution policy defines which
  organizations' peers are allowed to persist the collection data expressed using
  the ``Signature`` policy syntax, with each member being included in an ``OR``
  signature policy list. To support read/write transactions, the private data
  distribution policy must define a broader set of organizations than the chaincode
  endorsement policy, as peers must have the private data in order to endorse
  proposed transactions. For example, in a channel with ten organizations,
  five of the organizations might be included in a private data collection
  distribution policy, but the endorsement policy might call for any three
  of the organizations to endorse.
* ``policy``: 私有数据集合分发策略，它定义了哪些组织的 peers 被允许使用 ``Signature`` 策略语法并且将每个成员包含在一个 ``OR`` 签名策略列表中来将描述的集合数据进行持久化的操作，为了支持读/写交易，私有数据的分发策略必须要定义一个比 chaincode 背书策略更大范围的一个组织的集合，因为 peers 必须要拥有这些私有数据才能来对这些交易提案进行背书。比如，在一个具有 10 个组织的 channel 中，其中 5 个组织可能会被包含在一个私有数据集合的分发策略中，但是背书策略可能会调用其中的任何 3 个组织来进行背书。

* ``requiredPeerCount``: Minimum number of peers (across authorized organizations)
  that each endorsing peer must successfully disseminate private data to before the
  peer signs the endorsement and returns the proposal response back to the client.
  Requiring dissemination as a condition of endorsement will ensure that private data
  is available in the network even if the endorsing peer(s) become unavailable. When
  ``requiredPeerCount`` is ``0``, it means that no distribution is **required**,
  but there may be some distribution if ``maxPeerCount`` is greater than zero. A
  ``requiredPeerCount`` of ``0`` would typically not be recommended, as it could
  lead to loss of private data in the network if the endorsing peer(s) becomes unavailable.
  Typically you would want to require at least some distribution of the private
  data at endorsement time to ensure redundancy of the private data on multiple
  peers in the network.

* ``requiredPeerCount``: 在 peer 为背书签名并将提案的回应返回给客户端前，每个背书 peer 必须要成功地传播私有数据到达的 peers 的最小数量(在被授权的组织当中)。将要求传播作为背书的一个条件会确保即使如果背书 peer(s) 变得不可用的时候，私有数据在网络中还是可用的。当 ``requiredPeerCount`` 是 ``0`` 的时候，这代表分发并不是 **必须** 的，但是如果 ``maxPeerCount`` 比 0 大的话，这里可能会有一些分发。``requiredPeerCount`` 是 ``0`` 通常并不被建议，因为那会造成如果背书 peer(s) 变得不可用的时候，网络中的私有数据会丢失。通常你会想要要求当背书的时候对于私有数据会有一些分发来确保私有数据在网络中的多个 peers 上会有冗余存储。

* ``maxPeerCount``: For data redundancy purposes, the maximum number of other
  peers (across authorized organizations) that each endorsing peer will attempt
  to distribute the private data to. If an endorsing peer becomes unavailable between
  endorsement time and commit time, other peers that are collection members but who
  did not yet receive the private data at endorsement time, will be able to pull
  the private data from peers the private data was disseminated to. If this value
  is set to ``0``, the private data is not disseminated at endorsement time,
  forcing private data pulls against endorsing peers on all authorized peers at
  commit time.

* ``maxPeerCount``: 为了数据的冗余存储的目的，每个背书 peer 将会尝试将私有数据分发到的其他的 peers (在被授权的组织中) 的最大数量。如果在背书时间和提交时间之间一个背书 peer 变得不可用的时候，在背书时间还没有收到私有数据的作为集合成员的其他 peers，将能够从私有数据已经传播到的 peers 那里拉取回私有数据。如果这个值被设置为 ``0``，私有数据在背书的时候不会被扩散，这会强制在提交的时候，私有数据需要从所有被授权的 peers 上的背书 peers 拉取。

* ``blockToLive``: Represents how long the data should live on the private
  database in terms of blocks. The data will live for this specified number of
  blocks on the private database and after that it will get purged, making this
  data obsolete from the network. To keep private data indefinitely, that is, to
  never purge private data, set the ``blockToLive`` property to ``0``.

* ``blockToLive``: 代表了数据应该以区块的形式在私有数据库中存在多久。数据会在私有数据库上对于指定数量的区块存在，在那之后它会被删除，会使这个数据从网络中废弃。为了无限期的保持私有数据，也就是从来也不会删除私有数据的话，将 ``blockToLive`` 属性设置为 ``0``。

Here is a sample collection definition JSON file, containing an array of two
collection definitions:

下边是一个集合定义 JSON 文件的例子，包含关于两个集合定义的数组：

.. code:: bash

 [
  {
     "name": "collectionMarbles",
     "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
     "requiredPeerCount": 0,
     "maxPeerCount": 3,
     "blockToLive":1000000
  },
  {
     "name": "collectionMarblePrivateDetails",
     "policy": "OR('Org1MSP.member')",
     "requiredPeerCount": 0,
     "maxPeerCount": 3,
     "blockToLive":3
  }
 ]

This example uses the organizations from the BYFN sample network, ``Org1`` and
``Org2`` . The policy in the  ``collectionMarbles`` definition authorizes both
organizations to the private data. This is a typical configuration when the
chaincode data needs to remain private from the ordering service nodes. However,
the policy in the ``collectionMarblePrivateDetails`` definition restricts access
to a subset of organizations in the channel (in this case ``Org1`` ). In a real
scenario, there would be many organizations in the channel, with two or more
organizations in each collection sharing private data between them.

这个例子使用了来自于 BYFN 样例网络中的组织，``Org1`` 和 ``Org2``。在 ``collectionMarbles`` 定义中的策略对于私有数据授权了两个组织。这个是在 chaincode 数据需要与排序服务节点保持私有化的时候的一种典型配置。然而，在 ``collectionMarblePrivateDetails`` 定义中的策略却将访问控制在了在 channel (在这里指的是 ``Org1``) 中的一个组织的子集。在一个真正的情况中，在 channel 中会有好多组织，在每个集合中的两个或者多个组织间会彼此共享数据。

Endorsement - 背书
~~~~~~~~~~~~~~~~~~~

Since private data is not included in the transactions that get submitted to
the ordering service, and therefore not included in the blocks that get distributed
to all peers in a channel, the endorsing peer plays an important role in
disseminating private data to other peers of authorized organizations. This ensures
the availability of private data in the channel's collection, even if endorsing
peers become unavailable after their endorsement. To assist with this dissemination,
the  ``maxPeerCount`` and ``requiredPeerCount`` properties in the collection definition
control the degree of dissemination at endorsement time.

由于私有数据不会被包含在提交到排序服务的交易中，因此也就不会被包含在被分发给 channel 中所有 peers 的区块中，背书节点扮演着一个传播私有数据给其他被授权组织的 peers 的重要的橘色。这确保了即使背书 peers 在他们的背书之后变成不可用的时候，私有数据在 channel 的集合中的可用性。为了辅助这个传播，在集合定义中的 ``maxPeerCount`` 和 ``requiredPeerCount`` 属性控制了在背书的时候传播的程度。

If the endorsing peer cannot successfully disseminate the private data to at least
the ``requiredPeerCount``, it will return an error back to the client. The endorsing
peer will attempt to disseminate the private data to peers of different organizations,
in an effort to ensure that each authorized organization has a copy of the private
data. Since transactions are not committed at chaincode execution time, the endorsing
peer and recipient peers store a copy of the private data in a local ``transient store``
alongside their blockchain until the transaction is committed.

如果背书 peer 不能够成功地将私有数据分发到至少 ``requiredPeerCount`` 要求的那样，它将会返回一个错误给客户端。背书 peer 会尝试将私有数据分发到不同组织的 peers，来确保每个被授权的组织具有私有数据的一个副本。因为交易在 chaincode 执行期间还没有被提交，背书 peer 和接收 peers 除了他们的区块链外，还在一个本地的 ``transient store`` 中存储了私有数据的一个副本，直到交易被提交。

How private data is committed - 私有数据是如何被提交的
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When authorized peers do not have a copy of the private data in their transient
data store at commit time (either because they were not an endorsing peer or because
they did not receive the private data via dissemination at endorsement time),
they will attempt to pull the private data from another authorized
peer, *for a configurable amount of time* based on the peer property
``peer.gossip.pvtData.pullRetryThreshold`` in the peer configuration ``core.yaml``
file.

当一个被授权的节点在提交的时候，在他们的瞬时的数据存储中没有私有数据的副本的时候 (或者是因为他们不是一个背书 peer，或者是因为他们在背书的时候通过传播没有接收到私有数据)，他们会尝试从其他的被授权 peer 那里拉取私有数据，*持续一个可配置的时间长度* 基于在 peer 配置文件 ``core.yaml`` 中的 peer 属性 ``peer.gossip.pvtData.pullRetryThreshold``。

.. note:: The peers being asked for private data will only return the private data
if the requesting peer is a member of the collection as defined by the
          private data dissemination policy.

.. note:: 这个被询问私有数据的 peer 将只有当提出请求的 peer 是像私有数据分散策略定义的集合中的一员的时候才会返回私有数据。

Considerations when using ``pullRetryThreshold``:
当使用 ``pullRetryThreshold`` 时候需要考虑的问题：

* If the requesting peer is able to retrieve the private data within the
  ``pullRetryThreshold``, it will commit the transaction to its ledger
  (including the private data hash), and store the private data in its
  state database, logically separated from other channel state data.

* 如果提出请求的 peer 能够在 ``pullRetryThreshold`` 内取回私有数据的话，它将会把交易提交到自己的账本 (包括私有数据的哈希值)，并且将私有数据存储在它的 state 数据库中，同其他 channel state 数据进行了逻辑上的分离。

* If the requesting peer is not able to retrieve the private data within
  the ``pullRetryThreshold``, it will commit the transaction to it’s blockchain
  (including the private data hash), without the private data.

* 如果提出uqingqiu的 peer 没能在 ``pullRetryThreshold`` 内取回私有数据的话，它将会把交易提交到自己的账本 (包括私有数据的哈希值)，但是不会存储私有数据。

* If the peer was entitled to the private data but it is missing, then
  that peer will not be able to endorse future transactions that reference
  the missing private data - a chaincode query for a key that is missing will
  be detected (based on the presence of the key’s hash in the state database),
  and the chaincode will receive an error.

* 如果某个 peer 对于私有数据是有资格拥有的，但是却没有得到的话，那么那个 peer 将无法为将来引用到这个丢失的私有数据的交易进行背书 - 对于一个主键丢失的 chaincode 查询将会被发现 (基于在 state 数据库中对主键的哈希值的显示)，chaincode 将会收到一个错误。

Therefore, it is important to set the ``requiredPeerCount`` and ``maxPeerCount``
properties large enough to ensure the availability of private data in your
channel. For example, if each of the endorsing peers become unavailable
before the transaction commits, the ``requiredPeerCount`` and ``maxPeerCount``
properties will have ensured the private data is available on other peers.

因此，将 ``requiredPeerCount`` 和 ``maxPeerCount`` 设置成足够大的值来确保在你的 channel 中的私有数据的可用性是非常重要的。比如，如果在交易提交之前，每个背书 peer 都变为不可用了，``requiredPeerCount`` 和 ``maxPeerCount`` 属性将会确保私有数据在其他的 peers 上是可用的。

.. note:: For collections to work, it is important to have cross organizational
gossip configured correctly. Refer to our documentation on :doc:`gossip`,
          paying particular attention to the section on "anchor peers".

.. note:: 为了让集合能够工作，在夸组织间的 gossip 配置正确是非常重要的。阅读我们的文档 :doc:`gossip`,尤其注意 "anchor peers" 这部分。

Referencing collections from chaincode - 从 chaincode 中引用集合
----------------------------------------------------------------

A set of `shim APIs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim>`_
are available for setting and retrieving private data.

有一系列的 `shim APIs <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim>`_ 是可用的，可以他们来设置和取回私有数据。

The same chaincode data operations can be applied to channel state data and
private data, but in the case of private data, a collection name is specified
along with the data in the chaincode APIs, for example
``PutPrivateData(collection,key,value)`` and ``GetPrivateData(collection,key)``.

相同的 chaincode 数据操作也可以应用到 channel state 数据和私有数据上，但是对于私有数据的情况，要指定一个结合名字，同时带有在 chaincode APIs 中的数据，比如

A single chaincode can reference multiple collections.

一个单一的 chaincode 可以引用多个集合。

How to pass private data in a chaincode proposal - 如何在一个 chaincode 提案中传递私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since the chaincode proposal gets stored on the blockchain, it is also important
not to include private data in the main part of the chaincode proposal. A special
field in the chaincode proposal called the ``transient`` field can be used to pass
private data from the client (or data that chaincode will use to generate private
data), to chaincode invocation on the peer.  The chaincode can retrieve the
``transient`` field by calling the `GetTransient() API <https://github.com/hyperledger/fabric/blob/8b3cbda97e58d1a4ff664219244ffd1d89d7fba8/core/chaincode/shim/interfaces.go#L315-L321>`_.
This ``transient`` field gets excluded from the channel transaction.

因为 chaincode 提案被存储在区块链上，不要把私有数据包含在 chaincode 提案的主要部分也是非常重要的。在 chaincode 提案中有一个特殊的被称为 ``transient`` 的字段，它可以用来从客户端将私有数据 (或者 chaincode 将用来生成私有数据的数据) 传递给在 peer 上的 chaincode 的调用。Chaincode 可以通过调用 `GetTransient() API <https://github.com/hyperledger/fabric/blob/8b3cbda97e58d1a4ff664219244ffd1d89d7fba8/core/chaincode/shim/interfaces.go#L315-L321>`_ 来获取 ``transient`` 字段。这个 ``transient`` 字段会从 channel 交易中被排除。

Considerations when using private data - 当使用私有数据的时候需要考虑的问题
---------------------------------------------------------------------------

Querying Private Data - 查询私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Private collection data can be queried just like normal channel data, using
shim APIs:

私有集合数据能够像常见的 channel 数据那样使用 shim APIs 来进行查询：

* ``GetPrivateDataByRange(collection, startKey, endKey string)``
* ``GetPrivateDataByPartialCompositeKey(collection, objectType string, keys []string)``

And for the CouchDB state database, JSON content queries can be passed using the
shim API:

对于 CouchDB state 数据库，JSON 内容查询可以使用 shim API 被传入：

* ``GetPrivateDataQueryResult(collection, query string)``

Limitations - 限制:

* Clients that call chaincode that executes range or rich JSON queries should be aware
  that they may receive a subset of the result set, if the peer they query has missing
  private data, based on the explanation in Private Data Dissemination section
  above.  Clients can query multiple peers and compare the results to
  determine if a peer may be missing some of the result set.
* 客户端调用执行范围或者富 JSON 查询的 chaincode 的时候应该知道，根据上边关于私有数据扩散部分的解释，如果他们查询的 peer 有丢失的私有数据的话，他们可能会接收到结果集的一个子集。客户端可以查询多个 peers 并且比较返回的结果，以确定是否一个 peer 可能会丢失掉结果集中的部分数据。
* Chaincode that executes range or rich JSON queries and updates data in a single
  transaction is not supported, as the query results cannot be validated on the peers
  that don’t have access to the private data, or on peers that are missing the
  private data that they have access to. If a chaincode invocation both queries
  and updates private data, the proposal request will return an error. If your application
  can tolerate result set changes between chaincode execution and validation/commit time,
  then you could call one chaincode function to perform the query, and then call a second
  chaincode function to make the updates. Note that calls to GetPrivateData() to retrieve
  individual keys can be made in the same transaction as PutPrivateData() calls, since
  all peers can validate key reads based on the hashed key version.
* 对于在单一的一个交易中既执行范围或者富 JSON 查询并且更新数据是不支持的，因为查询结果无法在以下类型的 peers 上进行验证的：不能访问私有数据的 peers 或者对于那些他们可以访问相关的私有数据但是私有数据是丢失的。如果一个 chaincode 的调用既查询又更新私有数据的话，这个提案请求将会返回一个错误。如果你的应用程序能够容忍在 chaincode 执行和验证/提交阶段结果集的变动，那么你可以调用一个 chaincode 方法来执行这个查询，然后在调用第二个 chaincode 方法来执行变更。注意，调用 GetPrivateData() 来获取单独的键值可以跟 PutPrivateData() 调用放在同一个交易中，因为所有的 peers 都能够基于被哈希过的键的版本来验证键的读取。
* Note that private data collections only define which organization’s peers
  are authorized to receive and store private data, and consequently implies
  which peers can be used to query private data. Private data collections do not
  by themselves limit access control within chaincode. For example if
  non-authorized clients are able to invoke chaincode on peers that have access
  to the private data, the chaincode logic still needs a means to enforce access
  control as usual, for example by calling the GetCreator() chaincode API or
  using the client identity `chaincode library <https://github.com/hyperledger/fabric/tree/master/core/chaincode/lib/cid>`__ .
* 注意，私有数据集合仅仅定义了哪个组织的 peers 被授权来接收并存储私有数据，然后意味着哪些 peers 能够被用来查询私有数据。私有数据集合不会由他们自己来限制在 chaincode 中的访问控制。比如如果未被授权的客户端能够在能够访问私有数据的 peers 上调用 chaincode 的话，chaincode 逻辑仍旧需要一种方式来迫使像常规那样进行访问控制，比如通过调用 GetCreator() chaincode API 或者使用客户端身份信息 `chaincode library <https://github.com/hyperledger/fabric/tree/master/core/chaincode/lib/cid>`__ 。

Using Indexes with collections - 使用集合索引
----------------------------------------------

The topic :doc:`couchdb_as_state_database` describes indexes that can be
applied to the channel’s state database to enable JSON content queries, by
packaging indexes in a ``META-INF/statedb/couchdb/indexes`` directory at chaincode
installation time.  Similarly, indexes can also be applied to private data
collections, by packaging indexes in a ``META-INF/statedb/couchdb/collections/<collection_name>/indexes``
directory. An example index is available `here <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`_.

:doc:`couchdb_as_state_database` 章节描述了索引能够被应用到 channel 的 state 数据库来启用 JSON 内容查询，在 chaincode 安装阶段，通过将所以打包在一个 ``META-INF/statedb/couchdb/indexes`` 的路径下。类似的，索引页可以被应用到私有数据集合中，通过将所以打包在一个 ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` 路径下。一个索引的实例可以查看 `这里 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`_。

Private Data Purging - 私有数据删除
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To keep private data indefinitely, that is, to never purge private data,
set ``blockToLive`` property to ``0``.

为了保持私有数据的永久性，也就是说永远不会删除私有数据，可以将 ``blockToLive`` 属性设置为 ``0``。

Recall that prior to commit, peers store private data in a local
transient data store. This data automatically gets purged when the transaction
commits.  But if a transaction was never submitted to the channel and
therefore never committed, the private data would remain in each peer’s
transient store.  This data is purged from the transient store after a
configurable number blocks by using the peer’s
``peer.gossip.pvtData.transientstoreMaxBlockRetention`` property in the peer
``core.yaml`` file.

记住在提交前，peers 将私有数据存储在一个本地瞬时的数据存储中。这个数据会在交易被提交的时候被自动地删除。但是如果一笔交易从未被提交到 channe 而从未被提交的话，那么私有数据将会保留在每个 peer 的瞬时存储中。这些数据会在一个可配置的数量的区块之后从瞬时存储中被删除，这个可配置的区块数可以通过在 peer ``core.yaml`` 文件中的 ``peer.gossip.pvtData.transientstoreMaxBlockRetention`` 属性值来定义。

Upgrading a collection definition - 升级一个集合定义
----------------------------------------------------

If a collection is referenced by a chaincode, the chaincode will use the prior
collection definition unless a new collection definition is specified at upgrade
time. If a collection configuration is specified during the upgrade, a definition
for each of the existing collections must be included, and you can add new
collection definitions.

如果一个集合被一个 chaincode 引用，那么这个 chaincode 会使用之前的集合定义除非在升级的时候一个新的结合定义被指定。如果一个集合的配置在升级的过程中被指定，那么对于每一个已经存在的集合的定义必须要被包含进来，并且你可以添加新的集合定义。

Collection updates becomes effective when a peer commits the block that
contains the chaincode upgrade transaction. Note that collections cannot be
deleted, as there may be prior private data hashes on the channel’s blockchain
that cannot be removed.

集合的更新会在一个 peer 提交包含 chaincode 更新交易的区块的时候生效。注意，集合是不能够被删除的，因为这里可能有在 channel 的区块链上的之前的私有数据的哈希值，而这些哈希值是不能被删除的。

.. Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/