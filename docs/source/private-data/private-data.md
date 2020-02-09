# Private data - 私有数据

## What is private data? - 什么是私有数据？

In cases where a group of organizations on a channel need to keep data private from
other organizations on that channel, they have the option to create a new channel
comprising just the organizations who need access to the data. However, creating
separate channels in each of these cases creates additional administrative overhead
(maintaining chaincode versions, policies, MSPs, etc), and doesn't allow for use
cases in which you want all channel participants to see a transaction while keeping
a portion of the data private.

如果一个通道上的一组组织需要对该通道上的其他组织保持数据私有，则可以选择创建一个新通道，其中只包含
需要访问数据的组织。但是，在每种情况下创建单独的通道会产生额外的管理开销(维护链码版本、策略、MSPs等)，
并且在保留一部分数据私有的同时，希望所有通道参与者看到事务的情况是不允许的。

That's why Fabric offers the ability to create
**private data collections**, which allow a defined subset of organizations on a
channel the ability to endorse, commit, or query private data without having to
create a separate channel.

这就是为什么从v1.2开始，Fabric提供了创建**私有数据集合**的功能，它允许在通道上定义的组织子集能够
背书、提交或查询私有数据，而无需创建单独的通道。

## What is a private data collection? - 什么是私有数据集合？

A collection is the combination of two elements:

集合是两个元素的组合:

1. **The actual private data**, sent peer-to-peer [via gossip protocol](../gossip.html)
   to only the organization(s) authorized to see it. This data is stored in a
   private state database on the peers of authorized organizations,
   which can be accessed from chaincode on these authorized peers.
   The ordering service is not involved here and does not see the
   private data. Note that because gossip distributes the private data peer-to-peer
   across authorized organizations, it is required to set up anchor peers on the channel,
   and configure CORE_PEER_GOSSIP_EXTERNALENDPOINT on each peer,
   in order to bootstrap cross-organization communication.

   **实际的私有数据**，通过 [Gossip 协议](../gossip.html)点对点地发送给授权可以看到它的组织。私有数据保存在被授权的组织的节点上的私有数据库上，它们可以被授权节点的链码访问。排序节点不能影响这里也不能看到私有数据。注意，由于 gossip 以点对点的方式向授权组织分发私有数据，所以必须设置通道上的锚节点，也就是每个节点上的 CORE_PEER_GOSSIP_EXTERNALENDPOINT 配置，以此来引导跨组织的通信。

2. **A hash of that data**, which is endorsed, ordered, and written to the ledgers
   of every peer on the channel. The hash serves as evidence of the transaction and
   is used for state validation and can be used for audit purposes.

   **该数据的hash值**，该hash值被背书、排序之后写入通道上每个节点的账本。Hash值用作交易的，
   用于状态验证，并可用于审计目的。

The following diagram illustrates the ledger contents of a peer authorized to have
private data and one which is not.

下面的图表分别说明了被授权和未被授权拥有私有数据的节点的账本内容。

![private-data.private-data](./PrivateDataConcept-2.png)

Collection members may decide to share the private data with other parties if they
get into a dispute or if they want to transfer the asset to a third party. The
third party can then compute the hash of the private data and see if it matches the
state on the channel ledger, proving that the state existed between the collection
members at a certain point in time.

如果集合成员陷入争端，或者他们想把资产转让给第三方，他们可能决定与其他参与方共享私有数据。
然后，第三方可以计算私有数据的hash，并查看它是否与通道账本上的状态匹配，从而证明在某个时间点，
集合成员之间存在该状态。

In some cases, you may decide to have a set of collections each comprised of a
single organization. For example an organization may record private data in their own
collection, which could later be shared with other channel members and
referenced in chaincode transactions. We'll see examples of this in the sharing
private data topic below.

有些情况，你可能选择每个组织会有一套集合。比如一个组织可能会将私有数据记录到他们自己的集合中，之后可以共享给其他的通道成员并且在链码中引用。我们会在下边的共享私有数据部分看到一些例子。

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

  当账本必须共享给一些组织，但是只有其中的部分组织可以在交易中使用这些数据的一部分或者全部时，
  使用**collections集合**比较合适。此外，由于私有数据是点对点传播的，而不是通过块传播的，
  所以在交易数据必须对排序服务节点保密时，应该使用私有数据集合。

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

**分销商**可能希望与**农民**和**托运商**进行私下交易，以对**批发商**和**零售商**保密交易
条款(以免暴露他们收取的加价)。

The **Distributor** may also want to have a separate private data relationship
with the **Wholesaler** because it charges them a lower price than it does the
**Retailer**.

**分销商**还可能希望与**批发商**建立单独的私人数据关系，因为它收取的价格低于**零售商**。

The **Wholesaler** may also want to have a private data relationship with the
**Retailer** and the **Shipper**.

**批发商**可能还想与**零售商**和**托运商**建立私有数据关系。

Rather than defining many small channels for each of these relationships, multiple
private data collections **(PDC)** can be defined to share private data between:

相比于为每一个特殊关系建立各种小的通道来说，更好的做法是，可以定义多个私有数据集合**(PDC)
(私有数据集合)**，在以下情况下共享私有数据:

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
**Distributor** and **Wholesaler** relationship.

使用此示例，属于**分销商**的节点将在其账本中包含多个私有的私有数据库，其中包括来自**分销商**、
**农民**和**托运商**子集合关系和**分销商**和**批发商**子集合关系的私有数据。

![private-data.private-data](./PrivateDataConcept-3.png)

## Transaction flow with private data - 使用私有数据的交易流

When private data collections are referenced in chaincode, the transaction flow
is slightly different in order to protect the confidentiality of the private
data as transactions are proposed, endorsed, and committed to the ledger.

当在chaincode中引用私有数据集合时，交易流程略有不同，以便在交易被提议、背书并提交到账本时保持
私有数据的机密性。

For details on transaction flows that don't use private data refer to our
documentation on [transaction flow](../txflow.html).

关于不使用私有数据的交易流程的详细信息，请参阅我们的[交易流程](../txflow.html)的文档。

1. The client application submits a proposal request to invoke a chaincode
   function (reading or writing private data) to endorsing peers which are
   part of authorized organizations of the collection. The private data, or
   data used to generate private data in chaincode, is sent in a `transient`
   field of the proposal.

   客户端应用程序提交一个提议的请求，让属于授权集合的背书节点执行Chaincode函数(读取或写入私有数据)。
   私有数据，或用于在chaincode中生成私有数据的数据，被发送到提案的 `transient`“瞬态”字段中。

2. The endorsing peers simulate the transaction and store the private data in
   a `transient data store` (a temporary storage local to the peer). They
   distribute the private data, based on the collection policy, to authorized peers
   via [gossip](../gossip.html).

   背书节点模拟交易，并将私有数据存储在`transient data store`“瞬时数据存储”(节点的本地临时存储)中。
   它们根据组织集合Collection的策略将私有数据通过[gossip](../gossip.html)分发给授权的对等方。
   
3. The endorsing peer sends the proposal response back to the client. The proposal
   response includes the endorsed read/write set, which includes public
   data, as well as a hash of any private data keys and values. *No private data is
   sent back to the client*. For more information on how endorsement works with
   private data, click [here](../private-data-arch.html#endorsement).
   
   背书节点将提案响应发送回客户端。提案响应中包含经过背书的读写集，这其中包含了公共数据，还包含任何私有数据键和值的哈希。*私有数据不会被发送回客户端*。更多关于带有私有数据的背书的信息，请查看[这里](../private-data-arch.html#endorsement)。

4. The client application submits the transaction (which includes the proposal
   response with the private data hashes) to the ordering service. The transactions
   with the private data hashes get included in blocks as normal.
   The block with the private data hashes is distributed to all the peers. In this way,
   all peers on the channel can validate transactions with the hashes of the private
   data in a consistent way, without knowing the actual private data.
   
   客户端应用程序将交易（包含带有私有数据哈希值的提案响应）提交给排序服务。带有私有数据哈希的交易同样被包含在区块中。带有私有数据哈希的区块被分发给所有节点。这样，通道中的所有节点就可以在不知道真实私有数据的情况下，用同样的方式来验证带有私有数据哈希值的交易。

5. At block commit time, authorized peers use the collection policy to
   determine if they are authorized to have access to the private data. If they do,
   they will first check their local `transient data store` to determine if they
   have already received the private data at chaincode endorsement time. If not,
   they will attempt to pull the private data from another authorized peer. Then they
   will validate the private data against the hashes in the public block and commit the
   transaction and the block. Upon validation/commit, the private data is moved to
   their copy of the private state database and private writeset storage. The
   private data is then deleted from the `transient data store`.
   
   在区块提交的时候，授权的节点会根据集合策略来决定它们是否有权访问私有数据。如果节点有访问权，它们会先检查自己的本地 ` transient data store ` ，以确定它们是否在链码背书的时候已经接收到了私有数据。如果没有的话，它们会尝试从其他已授权节点那里拉取私有数据，然后对照公共区块上的哈希值来验证私有数据并提交交易和区块。当验证或提交结束后，私有数据会被移动到这些节点私有数据库和私有读写存储的副本中。随后 ` transient data store  ` 中存储的这些私有数据会被删除。

## Sharing private data - 共享私有数据

In many scenarios private data keys/values in one collection may need to be shared with
other channel members or with other private data collections, for example when you
need to transact on private data with a channel member or group of channel members
who were not included in the original private data collection. The receiving parties
will typically want to verify the private data against the on-chain hashes
as part of the transaction.

在多数情况下，一个私有数据集合中的私有数据键或值可能需要与其他通道成员或者私有数据集合共享，例如，当你需要和一个通道成员或者一组通道成员交易私有数据，而初始私有数据集合中并没有这些成员时。私有数据的接收方一般都会在交易过程中对照链上的哈希值来验证私有数据。

There are several aspects of private data collections that enable the
sharing and verification of private data:

私有数据集合的以下几个方面促成了私有数据的共享和验证：

* First, you don't necessarily have to be a member of a collection to write to a key in
  a collection, as long as the endorsement policy is satisfied.
  Endorsement policy can be defined at the chaincode level, key level (using state-based
  endorsement), or collection level (starting in Fabric v2.0).
  
* 首先，只要符合背书策略，尽管你不是私有数据集的成员也可以为集合写入键。可以在链码层面，键层面（用基于状态的背书）或者集合层面（始于 Fabric v2.0）上定义背书策略。

* Second, starting in v1.4.2 there is a chaincode API GetPrivateDataHash() that allows
  chaincode on non-member peers to read the hash value of a private key. This is an
  important feature as you will see later, because it allows chaincode to verify private
  data against the on-chain hashes that were created from private data in previous transactions.
  
* 其次，从 v1.4.2 开始出现了链码 API GetPrivateDataHash() ，它支持非集合成员节点上的链码读取一个私有键的哈希值。下文中你将发现这是一个十分重要的功能，因为它允许链码对照之前交易中私有数据生成的链上哈希来验证私有数据。

This ability to share and verify private data should be considered when designing
applications and the associated private data collections.
While you can certainly create sets of multilateral private data collections to share data
among various combinations of channel members, this approach may result in a large
number of collections that need to be defined.
Alternatively, consider using a smaller number of private data collections (e.g.
one collection per organization, or one collection per pair of organizations), and
then sharing private data with other channel members, or with other
collections as the need arises. Starting in Fabric v2.0, implicit organization-specific
collections are available for any chaincode to utilize,
so that you don't even have to define these per-organization collections when
deploying chaincode.

当设计应用程序和相关私有数据集合时需要考虑这种共享和验证私有数据的能力。您当然可以创建出几组多边私有数据集合以供多个通道成员组合之间共享数据，但是这样做的话你就需要定义大量私有数据集合。或者你也可以考虑使用少量私有数据集合（例如，每个组织用一个集合，或者每对组织用一个集合），然后和其他通道成员共享私有数据，有需要时还可以和其他集合共享私有数据。从 Fabric v2.0 开始，隐含的组织特定集合可供所有链码使用，这样一来部署链码的时候你就不用定义每个组织中的私有数据集合。

### Private data sharing patterns - 私有数据共享模式

When modeling private data collections per organization, multiple patterns become available
for sharing or transferring private data without the overhead of defining many multilateral
collections. Here are some of the sharing patterns that could be leveraged in chaincode
applications:

为各组织的私有数据集合构建模型时，有多种模式可被用来共享或传输私有数据，且无需费力定义多个多边集合。以下是链码应用程序中可以使用的一些共享模式：

* **Use a corresponding public key for tracking public state** -
  You can optionally have a matching public key for tracking public state (e.g. asset
  properties, current ownership. etc), and for every organization that should have access
  to the asset's corresponding private data, you can create a private key/value in each
  organization's private data collection.
  
* **使用相应的公钥来追踪公共状态**：您可以选择使用一个相应的公钥来追踪特定的公共状态（例如：资产性质，当前所有权等公共状态），对于每个需要拥有资产相应私有数据访问权的组织，您可以在它们的私有数据集合中创建一个私有秘钥或值。

* **Chaincode access control** -
  You can implement access control in your chaincode, to specify which clients can
  query private data in a collection. For example, store an access control list
  for a private data collection key or range of keys, then in the chaincode get the
  client submitter's credentials (using GetCreator() chaincode API or CID library API
  GetID() or GetMSPID() ), and verify they have access before returning the private
  data. Similarly you could require a client to pass a passphrase into chaincode,
  which must match a passphrase stored at the key level, in order to access the
  private data. Note, this pattern can also be used to restrict client access to public
  state data.

* **链码访问控制**：您可以在您的链码中执行访问控制，指明什么客户端应用程序能够查询私有数据集合中的私有数据。例如，为一个或多个私有数据集合键存储一个访问控制列表，然后在链码中获取客户端应用程序提交者的证书（使用 GetCreator() chaincode API or CID library API GetID() or GetMSPID()来获取），并在返回私有数据之前验证这些证书。同样，为了访问私有数据，您可以要求客户端将密码短语传送到链码中，且该短语必须与存储在秘钥级别的密码短语相匹配。注意，这种模式也可用于限制客户端对公共状态数据的访问权。

* **Sharing private data out of band** -
  As an off-chain option, you could share private data out of band with other
  organizations, and they can hash the key/value to verify it matches
  the on-chain hash by using GetPrivateDataHash() chaincode API. For example,
  an organization that wishes to purchase an asset from you may want to verify
  an asset's properties and that you are the legitimate owner by checking the
  on-chain hash, prior to agreeing to the purchase.

* **使用带外数据来共享私有数据**：这是一种链下选项，您可以同其他组织以带外数据的形式共享私有数据，这些组织可使用 GetPrivateDataHash() 链码 API 将键或值转换成哈希以验证其是否与链上哈希匹配。例如，如果一个组织想要购买一份你的资产，那么在同意购买之前它会检查链上哈希，以验证如下事项：该资产的属性；你是否为该资产的合法所有人。

* **Sharing private data with other collections** -
  You could 'share' the private data on-chain with chaincode that creates a matching
  key/value in the other organization's private data collection. You'd pass the
  private data key/value to chaincode via transient field, and the chaincode
  could confirm a hash of the passed private data matches the on-chain hash from
  your collection using GetPrivateDataHash(), and then write the private data to
  the other organization's private data collection.

* **与其他集合共享私有数据**：您可以同链码在链上共享私有数据，该链码在其他组织的私有数据集合中生成一个相应的键或值。你将通过临时字段把私有数据键或值传送给链码，收到私有数据后该链码使用 GetPrivateDataHash() 验证此私有数据的一个哈希是否与您集合中的链上哈希一致，随后将该私有数据写入其他组织的私有数据集合中。

* **Transferring private data to other collections** -
  You could 'transfer' the private data with chaincode that deletes the private data
  key in your collection, and creates it in another organization's collection.
  Again, use the transient field to pass the private data upon chaincode invoke,
  and in the chaincode use GetPrivateDataHash() to confirm that the data exists in
  your private data collection, before deleting the key from your collection and
  creating the key in another organization's collection. To ensure that a
  transaction always deletes from one collection and adds to another collection,
  you may want to require endorsements from additional parties, such as a
  regulator or auditor.

* **将私有数据传送给其他集合**：您可以使用链码来”传送“私有数据，该链码把您集合中的私有数据键删除，然后在其他组织的集合中生成。与上述方法相同，这里在调用链码时使用临时字段传输私有数据，并且在链码中用 GetPrivateDataHash() 来验证你的私有数据集合中是否存在该数据，验证成功之后再把你的集合中该数据删除，并在其他组织的集合中生成该键。为确保每次操作都会从一个集合中删除一项交易并在另一个集合中添加该交易，你可能需要获得一些额外组织的背书，如监管者或审计者。

* **Using private data for transaction approval** -
  If you want to get a counterparty's approval for a transaction before it is
  completed (e.g. an on-chain record that they agree to purchase an asset for
  a certain price), the chaincode can require them to 'pre-approve' the transaction,
  by either writing a private key to their private data collection or your collection,
  which the chaincode will then check using GetPrivateDataHash(). In fact, this is
  exactly the same mechanism that the built-in lifecycle system chaincode uses to
  ensure organizations agree to a chaincode definition before it is committed to
  a channel. Starting with Fabric v2.0, this pattern
  becomes more powerful with collection-level endorsement policies, to ensure
  that the chaincode is executed and endorsed on the collection owner's own trusted
  peer. Alternatively, a mutually agreed key with a key-level endorsement policy
  could be used, that is then updated with the pre-approval terms and endorsed
  on peers from the required organizations.

* **使用私有数据进行交易确认**：如果您想在交易完成之前获得竞争对手的批准（即竞争对手同意以某价钱购买一项资产这一链上记录），链码会在竞争对手或您自己的私有数据集合中写入一个私有数据（链码随后将使用 GetPrivateDataHash() 来验证该数据），从而要求竞争对手”率先批准“这项交易。事实上，嵌入式生命周期系统链码就是使用这种机制来确保链码定义在被提交到通道之前已经获得通道上各组织的同意。这种私有数据共享模式从从 Fabric v2.0 开始凭借集合层面的背书策略变得越来越强大，确保在集合拥有者自己的信任节点上执行、背书链码。或者，您也可以使用具有秘钥层面背书策略、共同商定的秘钥，随后该秘钥被预先批准的条款更新，并且在指定组织的节点上获得背书。

* **Keeping transactors private** -
  Variations of the prior pattern can also eliminate leaking the transactors for a given
  transaction. For example a buyer indicates agreement to buy on their own collection,
  then in a subsequent transaction seller references the buyer's private data in
  their own private data collection. The proof of transaction with hashed references
  is recorded on-chain, only the buyer and seller know that they are the transactors,
  but they can reveal the pre-images if a need-to-know arises, such as in a subsequent
  transaction with another party who could verify the hashes.

* **使交易者保密**：对上一种共享模式进行些许变化还可以实现指定交易的交易者不被暴露。例如，买方表示同意在自己的私有数据集合上进行购买，随后在接下来的交易中卖方会在自己的私有数据集合中引用该买方的私有数据。带有哈希过的引用的交易证据被记录在链上，只有出售者和购买者知道这些是交易，但是如果需要需要知道的原则的话，他们可以暴漏原像，比如在一个接下来的跟其他的 party 进行交易中，对方就能够验证这个哈希值了。

Coupled with the patterns above, it is worth noting that transactions with private
data can be bound to the same conditions as regular channel state data, specifically:

结合以上几种模式，我们可以发现，私有数据的交易和普通的通道状态数据交易情况类似，特别是以下几点：

* **Key level transaction access control** -
  You can include ownership credentials in a private data value, so that subsequent
  transactions can verify that the submitter has ownership privilege to share or transfer
  the data. In this case the chaincode would get the submitter's credentials
  (e.g. using GetCreator() chaincode API or CID library API GetID() or GetMSPID() ),
  combine it with other private data that gets passed to the chaincode, hash it,
  and use GetPrivateDataHash() to verify that it matches the on-chain hash before
  proceeding with the transaction.

* **重要级别交易访问控制** -
  您可以在私有数据值中加入 所有权证书，这样一来，后续发生的交易就能够验证数据提交者是否具有共享和传输数据的所有权。在这种情况下，链码会获取数据提交者的证书（例如：使用 GetCreator() chaincode API or CID library API GetID() or GetMSPID() ），将此证书与链码收到的其他私有数据合并，

* **Key level endorsement policies** -
  And also as with normal channel state data, you can use state-based endorsement
  to specify which organizations must endorse transactions that share or transfer
  private data, using SetPrivateDataValidationParameter() chaincode API,
  for example to specify that only an owner's organization peer, custodian's organization
  peer, or other third party must endorse such transactions.
  
* **重要级别背书策略** - 
  和正常的通道状态数据一样，您可以使用基于状态的背书策略来指明哪些组织必须对共享或转移私有数据的交易做出背书，使用 SetPrivateDataValidationParameter() chaincode API  来进行一些操作，例如，指明必须对上述交易作出背书的仅包括一个拥有者的组织节点，托管组织的节点或者第三方组织。

### Example scenario: Asset transfer using private data collections - 样例场景：使用私有数据集合的资产交易

The private data sharing patterns mentioned above can be combined to enable powerful
chaincode-based applications. For example, consider how an asset transfer scenario
could be implemented using per-organization private data collections:

将上述私有数据共享模式结合起来能够赋能基于链码的应用程序。例如，思考一下如何使用各组织私有数据集合来实现资产转移场景：

* An asset may be tracked by a UUID key in public chaincode state. Only the asset's
  ownership is recorded, nothing else is known about the asset.
  
  在公共链码状态使用UUID键可以追踪一项资产。所记录信息只包括资产的所属权，没有其他信息。

* The chaincode will require that any transfer request must originate from the owning client,
  and the key is bound by state-based endorsement requiring that a peer from the
  owner's organization and a regulator's organization must endorse any transfer requests.
  
  链码要求：所有资产转移请求必须源自拥有者客户端，并且关键在于需要有基于 state 的背书，要求从所有者的组织和一个监管者的组织的一个 peer 必须要为所有的交易请求背书。

* The asset owner's private data collection contains the private details about
  the asset, keyed by a hash of the UUID. Other organizations and the ordering
  service will only see a hash of the asset details.
  
  资产拥有者的私有数据集合包含了有关该资产的私有信息，用一个 UUID 的哈希作为键值。其他的组织和排序服务将会只能看到资产详细的哈希值。

* Let's assume the regulator is a member of each collection as well, and therefore
  persists the private data, although this need not be the case.
  
  假定监管者是各私有数据集合的一员，因此它一直维护着私有数据，即使他并没必要这么做。

A transaction to trade the asset would unfold as follows:

一项资产交易的进行情况如下：

1. Off-chain, the owner and a potential buyer strike a deal to trade the asset
   for a certain price.
   
   链下，资产所有者和意向买家同意以某一特定价格交易该资产。

2. The seller provides proof of their ownership, by either passing the private details
   out of band, or by providing the buyer with credentials to query the private
   data on their node or the regulator's node.
   
   卖家通过以下方式提供资产所有权证明：利用带外数据传输私有信息；或者出示证书以供买家在其自身节点或管理员节点上查询私有数据。

3. Buyer verifies a hash of the private details matches the on-chain public hash.

   买家验证私有信息的哈希是否匹配链上公共哈希。

4. The buyer invokes chaincode to record their bid details in their own private data collection.
   The chaincode is invoked on buyer's peer, and potentially on regulator's peer if required
   by the collection endorsement policy.
   
   买家通过调取链码来在其自身私有数据集合中记录投标细节信息。一般在买家自己的节点上调取链码，但如果集合背书策略有相关规定，则也可能会在管理员节点上调取链码。

5. The current owner (seller) invokes chaincode to sell and transfer the asset, passing in the
   private details and bid information. The chaincode is invoked on peers of the
   seller, buyer, and regulator, in order to meet the endorsement policy of the public
   key, as well as the endorsement policies of the buyer and seller private data collections.

   当前的资产所有者（卖家）调取链码来卖出、转移资产，传递私有信息和投标信息。在卖家、买家和管理员的节点上调用链码，以满足公钥的背书策略以及买家和买家私有数据集合的背书策略。

6. The chaincode verifies that the submitting client is the owner, verifies the private
   details against the hash in the seller's collection, and verifies the bid details
   against the hash in the buyer's collection. The chaincode then writes the proposed
   updates for the public key (setting ownership to the buyer, and setting endorsement
   policy to be the buying organization and regulator), writes the private details to the
   buyer's private data collection, and potentially deletes the private details from seller's
   collection. Prior to final endorsement, the endorsing peers ensure private data is
   disseminated to any other authorized peers of the seller and regulator.
   
   链码验证交易发送方是否为资产拥有者，根据卖家私有数据集合中的哈希来验证私有细节信息，同时还会根据买家私有数据集合中的哈希来验证投标细节信息。随后链码为公钥书写提案更新（将资产拥有者设定为买家，将背书策略设定为买家和管理员），把私有细节信息写入买家的私有数据集合中，以上步骤成功完成后链码会把卖家私有数据集合中的相关私有细节信息删除。在最终背书之前，背书节点会确保已将私有数据分布给卖家和管理员的所有授权节点。

7. The seller submits the transaction with the public data and private data hashes
   for ordering, and it is distributed to all channel peers in a block.
   
   卖家提交交易等待排序，其中包括了公钥和私钥哈希，随后该交易被分布到区块中的所有通道节点上。

8. Each peer's block validation logic will consistently verify the endorsement policy
   was met (buyer, seller, regulator all endorsed), and verify that public and private
   state that was read in the chaincode has not been modified by any other transaction
   since chaincode execution.
   
   每个节点的区块验证逻辑都将一致性地验证背书策略是否得到满足（买家、卖家和管理员都作出背书），同时还验证链码中已读取的公钥和私钥自链码执行以来未被任何其他交易更改。

9. All peers commit the transaction as valid since it passed validation checks.
   Buyer peers and regulator peers retrieve the private data from other authorized
   peers if they did not receive it at endorsement time, and persist the private
   data in their private data state database (assuming the private data matched
   the hashes from the transaction).
   
   所有节点提交的交易都是有效的，因为交易已经通过验证。如果买家和管理员节点在背书时未收到私有数据的话，它们将会从其他授权节点那里获取这些私有数据，并将这些数据保存在自己的私有数据状态数据库中（假定私有数据与交易的哈希匹配）。

10. With the transaction completed, the asset has been transferred, and other
    channel members interested in the asset may query the history of the public
    key to understand its provenance, but will not have access to any private
    details unless an owner shares it on a need-to-know basis.
    
    交易完成后，资产被成功转移，其他对该资产感兴趣的通道成员可能会查询公钥的历史以了解该资产的来历，但是它们无法访问任何私有细节信息，除非资产拥有者在须知的基础上共享这些信息。

The basic asset transfer scenario could be extended for other considerations,
for example the transfer chaincode could verify that a payment record is available
to satisfy payment versus delivery requirements, or verify that a bank has
submitted a letter of credit, prior to the execution of the transfer chaincode.
And instead of transactors directly hosting peers, they could transact through
custodian organizations who are running peers.

以上是最基本的资产转移场景，我么可以对其进行扩展，例如，资产转移链码可能会验证一项付款记录是否可用于满足付款和交付要求，或者可能会验证一个银行是否在执行资产转移链码之前已经提交了信用证。交易各方并不直接维护节点，而是通过那些运行节点的托管组织来进行交易。

## Purging private data - 清除私有数据

For very sensitive data, even the parties sharing the private data might want
--- or might be required by government regulations --- to periodically "purge" the data
on their peers, leaving behind a hash of the data on the blockchain
to serve as immutable evidence of the private data.

对于非常敏感的数据，即使是共享私有数据的各方可能也希望（或者应政府相关法规要求必须）定期“清除”节点上的数据，仅把这些敏感数据的哈希留在区块链上，作为私有数据不可篡改的证据。

In some of these cases, the private data only needs to exist on the peer's private
database until it can be replicated into a database external to the peer's
blockchain. The data might also only need to exist on the peers until a chaincode business
process is done with it (trade settled, contract fulfilled, etc).

在某些情况下，私有数据只需要在其被复制到节点区块链外部的数据库之前存在于该节点的私有数据库中。而数据或许也只需要在链码业务流程结束之前存在于节点上（交易结算、合约履行等）。

To support these use cases, private data can be purged if it has not been modified
for a configurable number of blocks. Purged private data cannot be queried from chaincode,
and is not available to other requesting peers.

为了支持这些用户案例，如果私有数据已经持续 N 个块都没有被修改，则可以清除该私有数据，N 是可配置的。链码中无法查询已被清除的私有数据，并且其他节点也请求不到。

## How a private data collection is defined - 私有数据集合怎么定义

For more details on collection definitions, and other low level information about
private data and collections, refer to the [private data reference topic](../private-data-arch.html).

有关集合定义的更多详细信息，以及关于私有数据和集合的其他更底层的信息，请参阅[私有数据主题](../private-data-arch.html)。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
