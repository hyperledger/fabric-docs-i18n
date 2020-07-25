Hyperledger Fabric 模型
==========================
Hyperledger Fabric Model
========================

本节讲述了 Hyperledger Fabric 的关键设计特性，实现了全方位、可定制的企业级区块链解决方案：

This section outlines the key design features woven into Hyperledger Fabric that
fulfill its promise of a comprehensive, yet customizable, enterprise blockchain solution:

* :ref:`Assets` —— 资产是可以通过网络交换的几乎所有具有价值的东西，从食品到古董车、货币期货。
* :ref:`Chaincode` —— 链码执行与交易排序分离，限制了跨节点类型所需的信任和验证级别，并优化了网络可扩展性和性能。
* :ref:`Ledger-Features` —— 不可变的共享账本为每个通道编码整个交易历史记录，并包括类似 SQL 的查询功能，以便高效审计和解决争议。
* :ref:`Privacy` —— 通道和私有数据集合实现了隐私且机密的多边交易，这些交易通常是在共同网络上交换资产的竞争企业和受监管行业所要求的。
* :ref:`Security-Membership-Services` —— 许可成员资格提供可信的区块链网络，参与者知道所有交易都可以由授权的监管机构和审计员检测和跟踪。
* :ref:`Consensus` —— 达成共识的独特方法可实现企业所需的灵活性和可扩展性。

* `Assets`_ --- Asset definitions enable the exchange of almost anything with
  monetary value over the network, from whole foods to antique cars to currency
  futures.
* `Chaincode`_ --- Chaincode execution is partitioned from transaction ordering,
  limiting the required levels of trust and verification across node types, and
  optimizing network scalability and performance.
* `Ledger Features`_ --- The immutable, shared ledger encodes the entire
  transaction history for each channel, and includes SQL-like query capability
  for efficient auditing and dispute resolution.
* `Privacy`_ --- Channels and private data collections enable private and
  confidential multi-lateral transactions that are usually required by
  competing businesses and regulated industries that exchange assets on a common
  network.
* `Security & Membership Services`_ --- Permissioned membership provides a
  trusted blockchain network, where participants know that all transactions can
  be detected and traced by authorized regulators and auditors.
* `Consensus`_ --- A unique approach to consensus enables the
  flexibility and scalability needed for the enterprise.

.. _Assets:


资产
------

Assets
------

资产的范围可以从有形（房地产和硬件）到无形资产（合同和知识产权）。Hyperledger Fabric 提供使用链码交易来修改资产的功能。

Assets can range from the tangible (real estate and hardware) to the intangible
(contracts and intellectual property).  Hyperledger Fabric provides the
ability to modify assets using chaincode transactions.

资产在 Hyperledger Fabric 中表示为键值对的集合，状态更改记录为 :ref:`Channel` 账本上的交易。资产可以用二进制或 JSON 格式表示。

Assets are represented in Hyperledger Fabric as a collection of
key-value pairs, with state changes recorded as transactions on a :ref:`Channel`
ledger.  Assets can be represented in binary and/or JSON form.

.. _Chaincode:


链码
---------

Chaincode
---------

链码是定义单项或多项资产的软件，和能修改资产的交易指令；换句话说，它是业务逻辑。链码强制执行读取或更改键值对或其他状态数据库信息的规则。链码函数针对账本的当前状态数据库执行，并通过交易提案启动。链码执行会写入一组键值（写集），会被提交给网络并应用于所有节点的账本。

Chaincode is software defining an asset or assets, and the transaction instructions for
modifying the asset(s); in other words, it's the business logic.  Chaincode enforces the rules for reading
or altering key-value pairs or other state database information. Chaincode functions execute against
the ledger's current state database and are initiated through a transaction proposal. Chaincode execution
results in a set of key-value writes (write set) that can be submitted to the network and applied to
the ledger on all peers.

.. _Ledger-Features:


账本特征
---------------

Ledger Features
---------------

账本是 Fabirc 中所有状态转换的有序的防篡改的记录。状态转换是参与方提交的链码调用（“交易”）的结果。每个交易都会生成一组资产键值对，这些键值对以创建、更新或删除形式提交到账本。

The ledger is the sequenced, tamper-resistant record of all state transitions in the fabric.  State
transitions are a result of chaincode invocations ('transactions') submitted by participating
parties.  Each transaction results in a set of asset key-value pairs that are committed to the
ledger as creates, updates, or deletes.

账本由区块链（“链”）组成，用于以区块的形式存储不可变的顺序记录，以及用于维护当前 Fabirc 状态的状态数据库。每个通道有一个账本。每个节点为其所属的每个通道维护一个账本的副本。

The ledger is comprised of a blockchain ('chain') to store the immutable, sequenced record in
blocks, as well as a state database to maintain current fabric state.  There is one ledger per
channel. Each peer maintains a copy of the ledger for each channel of which they are a member.

Fabric 账本的一些特点：
- 使用基于键的查找、范围查询和组合键钥查询来查询和更新账本
- 使用富查询语言的只读查询（如果使用 CouchDB 作为状态数据库）
- 只读历史记录查询（查询键的账本历史记录），以支持数据溯源方案
- 包含链码读取的键/值的版本（读集）以及链码写入的键/值（写集）的交易
- 包含每个背书节点的签名，并提交给排序服务的交易
- 按顺序打包到区块，并从排序服务“分发”到通道上的节点的交易
- 节点根据背书策略验证交易并执行策略
- 在附加区块之前，执行版本检查以确保链码执行以后读取的资产的状态未发生更改
- 一旦交易被验证并提交，就不可改变
- 通道的账本包含了定义策略、访问控制列表和其他相关信息的配置区块
- 通道包含 :ref:`MSP` 的程序实例，允许从不同的证书颁发机构派生加密材料

Some features of a Fabric ledger:

查看 :doc:`ledger` 主题来更深地了解数据库、存储结构和 "查询能力"。

- Query and update ledger using key-based lookups, range queries, and composite key queries
- Read-only queries using a rich query language (if using CouchDB as state database)
- Read-only history queries --- Query ledger history for a key, enabling data provenance scenarios
- Transactions consist of the versions of keys/values that were read in chaincode (read set) and keys/values that were written in chaincode (write set)
- Transactions contain signatures of every endorsing peer and are submitted to ordering service
- Transactions are ordered into blocks and are "delivered" from an ordering service to peers on a channel
- Peers validate transactions against endorsement policies and enforce the policies
- Prior to appending a block, a versioning check is performed to ensure that states for assets that were read have not changed since chaincode execution time
- There is immutability once a transaction is validated and committed
- A channel's ledger contains a configuration block defining policies, access control lists, and other pertinent information
- Channels contain :ref:`MSP` instances allowing for crypto materials to be derived from different certificate authorities

.. _Privacy:

See the :doc:`ledger` topic for a deeper dive on the databases, storage structure, and "query-ability."

隐私
-------


Hyperledger Fabric 在每个通道上使用不可变的账本，以及可操纵和修改资产当前状态（即更新键值对）的链码。账本存在于通道范围内，它可以在整个网络中共享（假设每个参与者都在同一个公共通道上），也可以私有化的方式仅包括一组特定的参与者。

Privacy
-------

在后一种情况下，这些参与者将创建一个单独的通道，从而隔离他们的交易和账本。为了解决想要平衡整体透明和隐私之间差距的场景，可以仅在需要访问资产状态以执行读取和写入的节点上安装链码（换句话说，如果未在节点上安装链码，它将无法与账本正确连接）。

Hyperledger Fabric employs an immutable ledger on a per-channel basis, as well as
chaincode that can manipulate and modify the current state of assets (i.e. update
key-value pairs).  A ledger exists in the scope of a channel --- it can be shared
across the entire network (assuming every participant is operating on one common
channel) --- or it can be privatized to include only a specific set of participants.

当该通道上的组织子集需要保密其交易数据时，私有数据集合用于将此数据隔离在私有数据库中，在逻辑上与通道账本分开，只能由授权的组织子集访问。

In the latter scenario, these participants would create a separate channel and
thereby isolate/segregate their transactions and ledger.  In order to solve
scenarios that want to bridge the gap between total transparency and privacy,
chaincode can be installed only on peers that need to access the asset states
to perform reads and writes (in other words, if a chaincode is not installed on
a peer, it will not be able to properly interface with the ledger).

因此，通道将交易保持从更广泛的网络私有，而集合使数据在通道上的组织的子集之间保持私有。

When a subset of organizations on that channel need to keep their transaction
data confidential, a private data collection (collection) is used to segregate
this data in a private database, logically separate from the channel ledger,
accessible only to the authorized subset of organizations.

为了进一步模糊数据，在将交易发送到排序服务并将区块附加到账本之前，可以使用诸如 AES 之类的公共加密算法对链码内的值进行加密（部分或全部）。一旦加密数据被写入账本，它就只能由拥有用于生成密文的相应密钥的用户解密。

Thus, channels keep transactions private from the broader network whereas
collections keep data private between subsets of organizations on the channel.

有关如何在区块链网络上实现隐私的更多详细信息，请参阅 :doc:`private-data-arch` 主题。

To further obfuscate the data, values within chaincode can be encrypted
(in part or in total) using common cryptographic algorithms such as AES before
sending transactions to the ordering service and appending blocks to the ledger.
Once encrypted data has been written to the ledger, it can be decrypted only by
a user in possession of the corresponding key that was used to generate the cipher
text.

.. _Security-Membership-Services:

See the :doc:`private-data-arch` topic for more details on how to achieve
privacy on your blockchain network.

安全和成员服务
------------------------------


Hyperledger Fabric 支持交易网络，所有参与者都拥有已知身份。公钥基础结构用于生成与组织、网络组件以及终端用户或客户端应用程序相关联的加密证书。因此，可以在更广泛的网络和通道级别上操纵和管理数据访问控制。Hyperledger Fabric 的这种“许可”概念，加上通道的存在和功能，有助于解决隐私和机密性较高的问题。

Security & Membership Services
------------------------------

请参阅 :doc:`msp` 主题，以更好地了解加密实现，以及 Hyperledger Fabric 中使用的签名、验证、身份认证方法。

Hyperledger Fabric underpins a transactional network where all participants have
known identities.  Public Key Infrastructure is used to generate cryptographic
certificates which are tied to organizations, network components, and end users
or client applications.  As a result, data access control can be manipulated and
governed on the broader network and on channel levels.  This "permissioned" notion
of Hyperledger Fabric, coupled with the existence and capabilities of channels,
helps address scenarios where privacy and confidentiality are paramount concerns.

.. _Consensus:

See the :doc:`msp` topic to better understand cryptographic
implementations, and the sign, verify, authenticate approach used in
Hyperledger Fabric.

共识
---------


最近，在分布式账本技术中，共识已成为单个函数内特定算法的同义词。然而，共识不仅包括简单地就交易顺序达成一致，Hyperledger Fabric 通过其在整个交易流程中的基本角色，从提案和背书到排序、验证和提交，突出了这种区别。简而言之，共识被定义为包含区块的一组交易的正确性的闭环验证。

Consensus
---------

当区块中交易的订单和结果满足明确的策略标准检查时，最终会达成共识。这些检查和平衡发生在交易的生命周期中，并包括使用背书策略来指定哪些特定成员必须背书某个交易类以及系统链码，以确保强制执行和维护这些策略。在提交之前，节点将使用这些系统链码来确保存在足够的背书，并且它们来自适当的实体。此外，在包含交易的任何区块附加到账本之前，将进行版本控制检查，在此期间，账本的当前状态为同意。此最终检查可防止双重花费操作和可能危及数据完整性的其他威胁，并允许针对非静态变量执行功能。

In distributed ledger technology, consensus has recently become synonymous with
a specific algorithm, within a single function. However, consensus encompasses more
than simply agreeing upon the order of transactions, and this differentiation is
highlighted in Hyperledger Fabric through its fundamental role in the entire
transaction flow, from proposal and endorsement, to ordering, validation and commitment.
In a nutshell, consensus is defined as the full-circle verification of the correctness of
a set of transactions comprising a block.

除了发生的大量背书、验证和版本检查之外，交易流的所有方向上还发生着持续的身份验证。访问控制列表在网络的层级上实现（排序服务到通道），并且当交易提议通过不同的体系结构组件时，有效负载被重复签名、确认和验证。总而言之，共识不仅限于一批交易的商定订单；相反，它是一种总体特征，是在交易从提案到背书的过程中进行的持续验证的副产品。

Consensus is achieved ultimately when the order and results of a block's
transactions have met the explicit policy criteria checks. These checks and balances
take place during the lifecycle of a transaction, and include the usage of
endorsement policies to dictate which specific members must endorse a certain
transaction class, as well as system chaincodes to ensure that these policies
are enforced and upheld.  Prior to commitment, the peers will employ these
system chaincodes to make sure that enough endorsements are present, and that
they were derived from the appropriate entities.  Moreover, a versioning check
will take place during which the current state of the ledger is agreed or
consented upon, before any blocks containing transactions are appended to the ledger.
This final check provides protection against double spend operations and other
threats that might compromise data integrity, and allows for functions to be
executed against non-static variables.

查看 :doc:`txflow` 以获得共识的直观表示。

In addition to the multitude of endorsement, validity and versioning checks that
take place, there are also ongoing identity verifications happening in all
directions of the transaction flow.  Access control lists are implemented on
hierarchical layers of the network (ordering service down to channels), and
payloads are repeatedly signed, verified and authenticated as a transaction proposal passes
through the different architectural components.  To conclude, consensus is not
merely limited to the agreed upon order of a batch of transactions; rather,
it is an overarching characterization that is achieved as a byproduct of the ongoing
verifications that take place during a transaction's journey from proposal to
commitment.

Check out the :doc:`txflow` diagram for a visual representation
of consensus.
