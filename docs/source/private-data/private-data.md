# Private data - 私有数据

## What is private data? - 什么是私有数据？

In cases where a group of organizations on a channel need to keep data private from
other organizations on that channel, they have the option to create a new channel
comprising just the organizations who need access to the data. However, creating
separate channels in each of these cases creates additional administrative overhead
(maintaining chaincode versions, policies, MSPs, etc), and doesn't allow for use
cases in which you want all channel participants to see a transaction while keeping
a portion of the data private.

如果一个通道上的一组组织需要对该通道上的其他组织保持数据私有，则可以选择创建一个新通道，其中只包含需要访问数据的组织。但是，在每种情况下创建单独的通道会产生额外的管理开销(维护链码版本、策略、MSPs等)，并且在保留一部分数据私有的同时，希望所有通道参与者看到事务的情况是不允许的。

That's why, starting in v1.2, Fabric offers the ability to create
**private data collections**, which allow a defined subset of organizations on a
channel the ability to endorse, commit, or query private data without having to
create a separate channel.

这就是为什么从v1.2开始，Fabric提供了创建**私有数据集合**的功能，它允许在通道上定义的组织子集能够背书、提交或查询私有数据，而无需创建单独的通道。

## What is a private data collection? - 什么是私有数据集合？

A collection is the combination of two elements:

集合是两个元素的组合:

1. **The actual private data**, sent peer-to-peer [via gossip protocol](../gossip.html)
   to only the organization(s) authorized to see it. This data is stored in a
   private database on the peer (sometimes called a "side" database, or
   "SideDB"). The ordering service is not involved here and does not see the
   private data. Note that setting up gossip requires setting up anchor peers
   in order to bootstrap cross-organization communication.

   **实际的私有数据**， [通过 gossip protocol](../gossip.html)点对点发送给授权查看它的组织。这些数据存储在节点的私有数据库中(有时称为“侧”数据库或“SideDB”)。这里不涉及排序服务，也看不到私有数据。注意，建立gossip通信需要建立锚节点，以引导跨组织的通信。

2. **A hash of that data**, which is endorsed, ordered, and written to the ledgers
   of every peer on the channel. The hash serves as evidence of the transaction and
   is used for state validation and can be used for audit purposes.

   **该数据的hash值**，该hash值被背书、排序之后写入通道上每个节点的账本。Hash值用作交易的，用于状态验证，并可用于审计目的。

The following diagram illustrates the ledger contents of a peer authorized to have
private data and one which is not.

下面的图表分别说明了被授权和未被授权拥有私有数据的节点的账本内容。

![private-data.private-data](./PrivateDataConcept-2.png)

Collection members may decide to share the private data with other parties if they
get into a dispute or if they want to transfer the asset to a third party. The
third party can then compute the hash of the private data and see if it matches the
state on the channel ledger, proving that the state existed between the collection
members at a certain point in time.

如果集合成员陷入争端，或者他们想把资产转让给第三方，他们可能决定与其他参与方共享私有数据。然后，第三方可以计算私有数据的hash，并查看它是否与通道账本上的状态匹配，从而证明在某个时间点，集合成员之间存在该状态。

### When to use a collection within a channel vs. a separate channel - 什么时候使用一个通道内的组织集合，什么时候使用单独的通道

* Use **channels** when entire transactions (and ledgers) must be kept
  confidential within a set of organizations that are members of the channel.

  当必须将整个账本在属于通道成员的组织中保密时，使用**channels**比较合适。

* Use **collections** when transactions (and ledgers) must be shared among a set
  of organizations, but when only a subset of those organizations should have
  access to some (or all) of the data within a transaction.  Additionally,
  since private data is disseminated peer-to-peer rather than via blocks,
  use private data collections when transaction data must be kept confidential
  from ordering service nodes.

  当账本必须共享给一些组织，但是只有其中的部分组织可以在交易中使用这些数据的一部分或者全部时，使用**collections集合**比较合适。此外，由于私有数据是点对点传播的，而不是通过块传播的，所以在交易数据必须对排序服务节点保密时，应该使用私有数据集合。

## A use case to explain collections - 解释集合的用例

Consider a group of five organizations on a channel who trade produce:

设想一个通道上的五个组织，他们从事农产品贸易：

* **A Farmer** selling his goods abroad

  **农民**在国外售卖他的货物

* **A Distributor** moving goods abroad

  **分销商**将货物运往国外

* **A Shipper** moving goods between parties

  **托运商**负责参与方之间的货物运输

* **A Wholesaler** purchasing goods from distributors

  **批发商**向分销商采购商品

* **A Retailer** purchasing goods from shippers and wholesalers

  **零售商**向托运人和批发商采购商品

The **Distributor** might want to make private transactions with the
**Farmer** and **Shipper** to keep the terms of the trades confidential from
the **Wholesaler** and the **Retailer** (so as not to expose the markup they're
charging).

**分销商**可能希望与**农民**和**托运商**进行私下交易，以对**批发商**和**零售商**保密交易条款(以免暴露他们收取的加价)。

The **Distributor** may also want to have a separate private data relationship
with the **Wholesaler** because it charges them a lower price than it does the
**Retailer**.

**分销商**还可能希望与**批发商**建立单独的私人数据关系，因为它收取的价格低于**零售商**。

The **Wholesaler** may also want to have a private data relationship with the
**Retailer** and the **Shipper**.

**批发商**可能还想与**零售商**和**托运商**建立私有数据关系。

Rather than defining many small channels for each of these relationships, multiple
private data collections **(PDC)** can be defined to share private data between:

相比于为每一个特殊关系建立各种小的通道来说，更好的做法是，可以定义多个私有数据集合**(PDC)(私有数据集合)**，在以下情况下共享私有数据:

1. PDC1: **Distributor**, **Farmer** and **Shipper**

   私有数据集合1： **分销商**, **农民** and **托运商**

2. PDC2: **Distributor** and **Wholesaler**

   私有数据集合2：**分销商** 和 **批发商**

3. PDC3: **Wholesaler**, **Retailer** and **Shipper**

   私有数据集合3：**批发商**, **零售商** and **托运商**

![private-data.private-data](./PrivateDataConcept-1.png)

Using this example, peers owned by the **Distributor** will have multiple private
databases inside their ledger which includes the private data from the
**Distributor**, **Farmer** and **Shipper** relationship and the
**Distributor** and **Wholesaler** relationship. Because these databases are kept
separate from the database that holds the channel ledger, private data is
sometimes referred to as "SideDB".

使用此示例，属于**分销商**的节点将在其账本中包含多个私有的私有数据库，其中包括来自**分销商**、**农民**和**托运商**子集合关系和**分销商**和**批发商**子集合关系的私有数据。因为这些数据库与存储通道账本的数据库是分开的，所以私有数据有时被称为“SideDB”。

![private-data.private-data](./PrivateDataConcept-3.png)

## Transaction flow with private data - 使用私有数据的交易流

When private data collections are referenced in chaincode, the transaction flow
is slightly different in order to protect the confidentiality of the private
data as transactions are proposed, endorsed, and committed to the ledger.

当在chaincode中引用私有数据集合时，交易流程略有不同，以便在交易被提议、背书并提交到账本时保持私有数据的机密性。

For details on transaction flows that don't use private data refer to our
documentation on [transaction flow](../txflow.html).

关于不使用私有数据的交易流程的详细信息，请参阅我们的[交易流程](../txflow.html)的文档。

1. The client application submits a proposal request to invoke a chaincode
   function (reading or writing private data) to endorsing peers which are
   part of authorized organizations of the collection. The private data, or
   data used to generate private data in chaincode, is sent in a `transient`
   field of the proposal.

   客户端应用程序提交一个提议的请求，让属于授权集合的背书节点执行Chaincode函数(读取或写入私有数据)。私有数据，或用于在chaincode中生成私有数据的数据，被发送到提案的 `transient`“瞬态”字段中。

2. The endorsing peers simulate the transaction and store the private data in
   a `transient data store` (a temporary storage local to the peer). They
   distribute the private data, based on the collection policy, to authorized peers
   via [gossip](../gossip.html).

   背书节点模拟交易，并将私有数据存储在`transient data store`“瞬时数据存储”(节点的本地临时存储)中。它们根据组织集合Collection的策略将私有数据通过[gossip](../gossip.html)分发给授权的对等方。

3. The endorsing peer sends the proposal response back to the client with public
   data, including a hash of the private data key and value. *No private data is
   sent back to the client*. For more information on how endorsement works with
   private data, click [here](../private-data-arch.html#endorsement).

   背书节点将提案的响应发送回客户端，发送的数据都是公开的，其中包含私有数据key和value的hash。 *没有私有数据被发送回客户端*。有关如何给包含私有数据的交易进行背书的更多信息，请单击[here](../private-data-arch.html#endorsement)。

4. The client application submits the transaction to the ordering service (with
   hashes of the private data) which gets distributed into blocks as normal.
   The block with the hashed values is distributed to all the peers. In this way,
   all peers on the channel can validate transactions with the hashes of the private
   data in a consistent way, without knowing the actual private data.

   客户端应用程序将交易提交给order排序服务(带有私有数据的hash)，该交易像往常一样被分发到块中。具有hash值的块被分配给所有的节点。通过这种方式，通道上的所有节点都可以以一致的方式使用私有数据的hash值验证交易，而不需要知道实际的私有数据。

5. At block-committal time, authorized peers use the collection policy to
   determine if they are authorized to have access to the private data. If they do,
   they will first check their local `transient data store` to determine if they
   have already received the private data at chaincode endorsement time. If not,
   they will attempt to pull the private data from another peer. Then they will
   validate the private data against the hashes in the public block and commit the
   transaction and the block. Upon validation/commit, the private data is moved to
   their copy of the private state database and private writeset storage. The
   private data is then deleted from the `transient data store`.

   在块提交时，授权的节点根据集合策略来确定它们是否被授权访问私有数据。如果他们被授权了，他们将首先检查他们的本地`transient data store` “瞬态数据存储”，以确定他们是否已经在链码背书时间收到了私有数据。如果没有，他们将尝试从另一个节点提取私有数据。然后，它们将根据公共块中的hash值验证私有数据，并提交交易和块。在验证/提交时，私有数据被移动到私有状态数据库和私有writeset存储的副本。然后从`transient data store`“临时数据存储”中删除私有数据。

## How a private data collection is defined - 私有数据集合如何定义

For more details on collection definitions, and other low level information about
private data and collections, refer to the [private data reference topic](../private-data-arch.html).

有关集合定义的详细信息，以及关于私有数据和集合的其他低级别的信息，请参阅[private data reference topic](../private data-arch.html)。

## Purging data - 净化数据

For very sensitive data, even the parties sharing the private data might want
--- or might be required by government regulations --- to "purge" the data stored
on their peers after a set amount of time, leaving behind only a hash of the data
to serve as immutable evidence of the transaction.

对于非常敏感的数据，即使共享私有数据的各方也可能想---或者可能被政府监管方要求---在一定的时间之后“清除”存储在其节点上的数据，只留下数据的hash值作为交易的不可篡改证据。

In some of these cases, the private data only needs to exist on the peer's private
database until it can be replicated into a database external to the blockchain
network. The data might also only need to exist on the peers until a chaincode business
process is done with it (trade settled, contract fulfilled, etc). To support the later
use case, it is possible to purge private data if it has not been modified once a set
number of subsequent blocks have been added to the private database.

在某些情况下，私有数据只需要存在于节点的私有数据库中，直到它可以复制到区块链网络外部的数据库中。数据可能只需要存在于peer节点上，等到使用它完成链码业务流程(交易结算、合同履行等)即可删除。为了支持后面的用例，如果在私有数据库中添加了一组后续块之后还没有修改私有数据，那么可以清除私有数据。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
