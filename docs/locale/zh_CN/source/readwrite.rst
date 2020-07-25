读写集语义
~~~~~~~~~~~~~~~~~~~~~~~~
Read-Write set semantics
~~~~~~~~~~~~~~~~~~~~~~~~

本文档讨论有关读写集语义实现的详细信息。

This document discusses the details of the current implementation about
the semantics of read-write sets.

交易模拟和读写集
'''''''''''''''''''''''''''''''''''''''''

Transaction simulation and read-write set
'''''''''''''''''''''''''''''''''''''''''

 ``背书节点`` 在模拟交易期间，会为交易准备一个读写集。``读集`` 包含了模拟期间交易读取的键和键的版本的列表。``写集`` 包含了交易写入键（可以与读取集中的键重叠）的新值。如果交易是删除一个键，该键就会被增加一个删除标识（在新值的位置）。

During simulation of a transaction at an ``endorser``, a read-write set
is prepared for the transaction. The ``read set`` contains a list of
unique keys and their committed version numbers (but not values) that
the transaction reads during simulation. The ``write set`` contains a list
of unique keys (though there can be overlap with the keys present in the read set)
and their new values that the transaction writes. A delete marker is set (in
the place of new value) for the key if the update performed by the
transaction is to delete the key.

如果交易多次向同一个键写入数据，只有最后写入的数据会记录下来。同样，如果交易读取一个键的值，就会返回这个键的已提交状态的值，即使读取之前在同一个交易中更新了键值。换句话说，不支持“读你所写”的语义。

Further, if the transaction writes a value multiple times for a key,
only the last written value is retained. Also, if a transaction reads a
value for a key, the value in the committed state is returned even if
the transaction has updated the value for the key before issuing the
read. In another words, Read-your-writes semantics are not supported.

就像前面所说的，键的版本只记录在读集中；写集只包含键和交易设置的键的最新值。

As noted earlier, the versions of the keys are recorded only in the read
set; the write set just contains the list of unique keys and their
latest values set by the transaction.

版本的实现有很多种。版本设计的基本需求是，键不能有重复的版本号。例如单调递增的数字。在目前的实现中，我们使用交易所在的区块高度来作为交易中所有修改的键的版本号。这样区块中交易的高度通过一个元组来表示（txNumber 是区块中交易的高度）。这种方式比递增的数字有更多好处，主要有，它可以让其他组件比如状态数据库、交易模拟和验证有更多的设计选择。

There could be various schemes for implementing versions. The minimal
requirement for a versioning scheme is to produce non-repeating
identifiers for a given key. For instance, using monotonically
increasing numbers for versions can be one such scheme. In the current
implementation, we use a blockchain height based versioning scheme in
which the height of the committing transaction is used as the latest
version for all the keys modified by the transaction. In this scheme,
the height of a transaction is represented by a tuple (txNumber is the
height of the transaction within the block). This scheme has many
advantages over the incremental number scheme - primarily, it enables
other components such as statedb, transaction simulation and validation
to make efficient design choices.

下边是为模拟一个交易所准备的读写集示例。为了简化说明，我们使用了一个递增的数字来表示版本。

Following is an illustration of an example read-write set prepared by
simulation of a hypothetical transaction. For the sake of simplicity, in
the illustrations, we use the incremental numbers for representing the
versions.

::

    <TxReadWriteSet>
      <NsReadWriteSet name="chaincode1">
        <read-set>
          <read key="K1", version="1">
          <read key="K2", version="1">
        </read-set>
        <write-set>
          <write key="K1", value="V1"
          <write key="K3", value="V2"
          <write key="K4", isDelete="true"
        </write-set>
      </NsReadWriteSet>
    <TxReadWriteSet>

    <TxReadWriteSet>
      <NsReadWriteSet name="chaincode1">
        <read-set>
          <read key="K1", version="1">
          <read key="K2", version="1">
        </read-set>
        <write-set>
          <write key="K1", value="V1">
          <write key="K3", value="V2">
          <write key="K4", isDelete="true">
        </write-set>
      </NsReadWriteSet>
    <TxReadWriteSet>

另外，如果交易在模拟中执行的是一个范围查询，范围查询和它的结果都会被记录在读写集的 ``查询信息（query-info）`` 中。

Additionally, if the transaction performs a range query during
simulation, the range query as well as its results will be added to the
read-write set as ``query-info``.

交易验证和使用读写集更新世界状态
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Transaction validation and updating world state using read-write set
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

``提交节点`` 使用读写集中的读集来验证交易，使用写集来更新受影响的键的版本和值。

A ``committer`` uses the read set portion of the read-write set for
checking the validity of a transaction and the write set portion of the
read-write set for updating the versions and the values of the affected
keys.

在验证阶段，如果读集中键的版本和世界状态中键的版本一致就认为该交易是 ``有效的`` ，这里我们假设所有之前 ``有效`` 的交易（同一个区块中该交易之前的交易）都会被提交（*提交状态*）。当读写集中包含一个或多个查询信息（query-info）时，需要执行额外的验证。

In the validation phase, a transaction is considered ``valid`` if the
version of each key present in the read set of the transaction matches
the version for the same key in the world state - assuming all the
preceding ``valid`` transactions (including the preceding transactions
in the same block) are committed (*committed-state*). An additional
validation is performed if the read-write set also contains one or more
query-info.

这种额外的验证需要确保在根据查询信息获得的结果的超集（多个范围的合并）中没有插入、删除或者更新键。换句话说，如果我们在模拟执行交易期间重新执行任何一个范围，我们应该得到相同的结果。这个检查保证了如果交易在提交期间出了虚项，该交易就会被标记为无效的。这种检查只存在于范围查询中（例如链码中的 ``GetStateByRange`` 方法）其他查询中没有实现（例如链码中的 ``GetQueryResult`` 方法）。其他查询仍会存在出现虚项的风险，我们应该只在不向排序服务提交的只读交易中使用查询，除非应用程序能保证模拟的结果和验证/提交时的结果一致。

This additional validation should ensure that no key has been
inserted/deleted/updated in the super range (i.e., union of the ranges)
of the results captured in the query-info(s). In other words, if we
re-execute any of the range queries (that the transaction performed
during simulation) during validation on the committed-state, it should
yield the same results that were observed by the transaction at the time
of simulation. This check ensures that if a transaction observes phantom
items during commit, the transaction should be marked as invalid. Note
that the this phantom protection is limited to range queries (i.e.,
``GetStateByRange`` function in the chaincode) and not yet implemented
for other queries (i.e., ``GetQueryResult`` function in the chaincode).
Other queries are at risk of phantoms, and should therefore only be used
in read-only transactions that are not submitted to ordering, unless the
application can guarantee the stability of the result set between
simulation and validation/commit time.

如果交易通过了有效性验证，提交节点就会根据写集更新世界状态。在更新阶段，会根据写集更新世界状态中对应的键的值。然后，世界状态中键的版本会更新到最新的版本。

If a transaction passes the validity check, the committer uses the write
set for updating the world state. In the update phase, for each key
present in the write set, the value in the world state for the same key
is set to the value as specified in the write set. Further, the version
of the key in the world state is changed to reflect the latest version.

模拟和验证示例
'''''''''''''''''''''''''''''''''

Example simulation and validation
'''''''''''''''''''''''''''''''''

本章节通过示例场景帮助你理解读写集语义。在本例中，``k`` 表示键，在世界状态中表示一个元组 ``(k,ver,val)`` ， ``ver`` 是键 ``k`` 的版本， ``val`` 是值。

This section helps with understanding the semantics through an example
scenario. For the purpose of this example, the presence of a key, ``k``,
in the world state is represented by a tuple ``(k,ver,val)`` where
``ver`` is the latest version of the key ``k`` having ``val`` as its
value.

现在假设有五个交易 ``T1，T2，T3，T4 和 T5`` ，所有的交易模拟都基于同一个世界状态的快照。下边的步骤展示了世界状态和模拟这些交易时的读写活动。

Now, consider a set of five transactions ``T1, T2, T3, T4, and T5``, all
simulated on the same snapshot of the world state. The following snippet
shows the snapshot of the world state against which the transactions are
simulated and the sequence of read and write activities performed by
each of these transactions.

::

    World state: (k1,1,v1), (k2,1,v2), (k3,1,v3), (k4,1,v4), (k5,1,v5)
    T1 -> Write(k1, v1'), Write(k2, v2')
    T2 -> Read(k1), Write(k3, v3')
    T3 -> Write(k2, v2'')
    T4 -> Write(k2, v2'''), read(k2)
    T5 -> Write(k6, v6'), read(k5)

现在，假设这些交易的顺序是从 T1 到 T5（他们可以在同一个区块，也可以在不同区块）

Now, assume that these transactions are ordered in the sequence of
T1,..,T5 (could be contained in a single block or different blocks)

1. ``T1`` 通过了验证，因为它没有执行任何读操作。然后世界状态中的键 ``k1`` 和 ``k2`` 被更新为 ``(k1,2,v1'), (k2,2,v2')``

1. ``T1`` passes validation because it does not perform any read.
   Further, the tuple of keys ``k1`` and ``k2`` in the world state are
   updated to ``(k1,2,v1'), (k2,2,v2')``

2. ``T2`` 没有通过验证，因为它读了键 ``k1``，但是交易 ``T1`` 改变了 ``k1``

2. ``T2`` fails validation because it reads a key, ``k1``, which was
   modified by a preceding transaction - ``T1``

3. ``T3`` 通过了验证，因为它没有执行任何读操作。然后世界状态中的键 ``k2`` 被更新为 ``(k2,3,v2'')``

3. ``T3`` passes the validation because it does not perform a read.
   Further the tuple of the key, ``k2``, in the world state is updated
   to ``(k2,3,v2'')``

4. ``T4`` 没有通过验证，因为它读了键 ``k2``，但是交易 ``T1`` 改变了 ``k2``

4. ``T4`` fails the validation because it reads a key, ``k2``, which was
   modified by a preceding transaction ``T1``

5. ``T5`` 通过了验证，因为它读了键 ``k5``，但是 ``k5`` 没有被其他任何交易改变

5. ``T5`` passes validation because it reads a key, ``k5,`` which was
   not modified by any of the preceding transactions

**Note**: 不支持有多个读写集的交易。

**Note**: Transactions with multiple read-write sets are not yet supported.
