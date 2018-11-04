Ledger - 账本
==============

The ledger is the sequenced, tamper-resistant record of all state transitions. State
transitions are a result of chaincode invocations ("transactions") submitted by participating
parties.  Each transaction results in a set of asset key-value pairs that are committed to the
ledger as creates, updates, or deletes.

账本是一个有序的，无法篡改的所有 state 交换的记录。State 的交换是由参与节点提交的对于 chaincode 的调用结果。每次交易会产生一套键-值对儿的资产，这会以新建、更新或者删除的形式被提交到账本中。

The ledger is comprised of a blockchain ('chain') to store the immutable, sequenced record in
blocks, as well as a state database to maintain current state.  There is one ledger per
channel. Each peer maintains a copy of the ledger for each channel of which they are a member.

账本的组成包括：一个区块链（“链”）来存储不可更改的、有序的记录，这些记录被记录在区块中，还有一个 state 数据库来维护当前的 state。每个 channel 会有一个账本。每个 peer 维护了每个 channel 中的账本的副本，而他们是每个 channel 中的成员。

Chain - 链
------------

The chain is a transaction log, structured as hash-linked blocks, where each block contains a
sequence of N transactions. The block header includes a hash of the block's transactions, as
well as a hash of the prior block's header. In this way, all transactions on the ledger are
sequenced and cryptographically linked together. In other words, it is not possible to tamper with
the ledger data, without breaking the hash links. The hash of the latest block represents every
transaction that has come before, making it possible to ensure that all peers are in a consistent
and trusted state.

链是一个交易的 log，以哈希-连接的区块形式为结构，每个区块包含了一个有序的 N 笔交易。区块的头包含了区块中的交易的哈希值，还包含了前一个区块头的哈希值。通过这种方式，账本中的所有交易都是有序的并且经过加密地连接在了一起。换句话说，想要不破坏哈希连接而直接篡改账本的数据是不可能的。最后的区块的哈希值代表了之前进行的每笔交易，确保了所有的 peers 都具有一致并可信的 state。

The chain is stored on the peer file system (either local or attached storage), efficiently
supporting the append-only nature of the blockchain workload.

这个链被存储在 peer 的文件系统中（或者本地或者附加的存储媒介），有效地支持了区块链的仅可以附加的特性。

State Database - State 数据库
-------------------------------

The ledger's current state data represents the latest values for all keys ever included in the chain
transaction log. Since current state represents all latest key values known to the channel, it is
sometimes referred to as World State.

账本的当前 state 数据代表了在链交易 log 中包含的所有键的最新的值。因为当前的 state 代表了对于 channel 所知的所有最新的键的值，他们通常被称为 World State。

Chaincode invocations execute transactions against the current state data. To make these
chaincode interactions extremely efficient, the latest values of all keys are stored in a state
database. The state database is simply an indexed view into the chain's transaction log, it can
therefore be regenerated from the chain at any time. The state database will automatically get
recovered (or generated if needed) upon peer startup, before transactions are accepted.

Chaincode 调用会针对当前的 state 数据执行交易。为了使这些 chaincode 的交互非常高效，所有键的最新值会被存储在一个 state 数据库中。State 数据库是链的交易 log 的索引过的视图，所以它可以从 chain 上在任何时间重新生成出来。当 peer 启动的时候，在接受交易之前，State 数据库会自动地恢复（如果需要也可以重新生成）。

State database options include LevelDB and CouchDB. LevelDB is the default state database
embedded in the peer process and stores chaincode data as key-value pairs. CouchDB is an optional
alternative external state database that provides addition query support when your chaincode data
is modeled as JSON, permitting rich queries of the JSON content. See
:doc:`couchdb_as_state_database` for more information on CouchDB.

State 数据库的选项包括 LevelDB 和 CouchDB。LevelDB 是在 peer 流程中内置的默认的 state 数据库，它是以键-值对儿的形式存储 chaincode 数据。CouchDB 是一个可选替换方案，它是外部的 state 数据库，当你的 chaincode 数据是 JSON 的格式的话，CouchDB 提供了额外的查询支持，允许针对于 JSON 内容的富查询。浏览 :doc:`couchdb_as_state_database` 了解关于 CouchDB 的更多信息。

Transaction Flow - 交易流程
---------------------------

At a high level, the transaction flow consists of a transaction proposal sent by an application
client to specific endorsing peers.  The endorsing peers verify the client signature, and execute
a chaincode function to simulate the transaction. The output is the chaincode results,
a set of key-value versions that were read in the chaincode (read set), and the set of keys/values
that were written in chaincode (write set). The proposal response gets sent back to the client
along with an endorsement signature.

在更高层次看来，交易流程包括了一个由一个应用客户端发送给指定的背书节点的一个交易提案。背书节点会验证客户端的签名，并执行一个 chaincode 方法来模拟这笔交易。这样做的输出是 chaincode 的结果，一套从 chaincode 中读取的键-值（读取集），和一套写入 chaincode 的键-值（写入集）。提案的答复会发送回给客户端并带有一个背书签名。

The client assembles the endorsements into a transaction payload and broadcasts it to an ordering
service. The ordering service delivers ordered transactions as blocks to all peers on a channel.

客户端会将这个背书结果组装到一个交易 payload 中并将它广播给一个排序服务。排序服务将排序后的交易以区块的形式发送给一个 channel 的所有 peers 节点。

Before committal, peers will validate the transactions. First, they will check the endorsement
policy to ensure that the correct allotment of the specified peers have signed the results, and they
will authenticate the signatures against the transaction payload.

在提交之前，peers 会验证所有交易。首先，他们会检查背书策略来确保指定的 peers 已经为结果提供了签名，并且他们会对于这个交易 payload 授权他们的签名。

Secondly, peers will perform a versioning check against the transaction read set, to ensure
data integrity and protect against threats such as double-spending. Hyperledger Fabric has concurrency
control whereby transactions execute in parallel (by endorsers) to increase throughput, and upon
commit (by all peers) each transaction is verified to ensure that no other transaction has modified
data it has read. In other words, it ensures that the data that was read during chaincode execution
has not changed since execution (endorsement) time, and therefore the execution results are still
valid and can be committed to the ledger state database. If the data that was read has been changed
by another transaction, then the transaction in the block is marked as invalid and is not applied to
the ledger state database. The client application is alerted, and can handle the error or retry as
appropriate.

其次，peers 节点会针对于交易的读取集进行一个版本检查，来确保数据的一致性并且防范诸如双花这样的威胁。Hyperledger Fabric 具有并发控制，使交易可以并行地（被背书节点）执行来提高吞吐量，并且在（被所有 peer 节点）提交之后，每笔交易都会被确认来确保它之前读取的数据没有任何的交易数据被修改过。换句话说，它确保了在 chaincode 执行的时候读取的数据在执行（背书）时间之后没有被修改过，因此这个执行结果依然有效并且可以被提交到账本 state 数据库。如果读取的数据被其他的交易修改了的话，那么在区块中的交易会被标记为无效的并且不会应用到账本 state 数据库中。客户端应用会收到警告提醒，并可以处理这个错误或者适当地尝试重新提交。

See the :doc:`txflow`, :doc:`readwrite`, and :doc:`couchdb_as_state_database` topics for a deeper
dive on transaction structure, concurrency control, and the state DB.

浏览 :doc:`txflow`, :doc:`readwrite`, and :doc:`couchdb_as_state_database` 来对交易结构、并发控制和 state 数据库进行深入研究。

.. Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/
