Hyperledger Fabric Functionalities - Hyperledger Fabirc功能
==================================

Hyperledger Fabric is an implementation of distributed ledger technology
(DLT) that delivers enterprise-ready network security, scalability,
confidentiality and performance, in a modular blockchain architecture.
Hyperledger Fabric delivers the following blockchain network functionalities:

Hyperledger Fabric是分布式账本技术（DLT）的一种实现，该技术可在模块化区块链架构中提供企业级网络安全性、可扩展性、机密性和性能。Hyperledger Fabric提供以下区块链网络功能：

Identity management - 身份管理
-------------------

To enable permissioned networks, Hyperledger Fabric provides a membership
identity service that manages user IDs and authenticates all participants on
the network. Access control lists can be used to provide additional layers of
permission through authorization of specific network operations. For example, a
specific user ID could be permitted to invoke a chaincode application, but
be blocked from deploying new chaincode.

为了启用许可网络，Hyperledger Fabric提供了一个成员身份服务，用于管理用户ID并认证网络上的所有参与者。访问控制列表可用于通过授权特定网络操作来提供额外的权限层。例如，可以允许特定用户ID调用链码应用程序，但是不能部署新的链码。

Privacy and confidentiality - 隐私和保密
---------------------------

Hyperledger Fabric enables competing business interests, and any groups that
require private, confidential transactions, to coexist on the same permissioned
network. Private **channels** are restricted messaging paths that can be used
to provide transaction privacy and confidentiality for specific subsets of
network members. All data, including transaction, member and channel
information, on a channel are invisible and inaccessible to any network members
not explicitly granted access to that channel.

Hyperledger Fabric使竞争商业利益以及任何需要私人机密交易的群体能够在同一个许可网络上共存。私有 **通道** 是受限制的消息传递路径，可用于为网络成员的特定子集提供交易隐私和机密性。通道上的所有数据（包括交易、成员和通道信息）都是不可见的，并且对于未明确授予对该通道的访问权限的任何网络成员都是不可访问的。

Efficient processing - 高效处理
--------------------

Hyperledger Fabric assigns network roles by node type. To provide concurrency
and parallelism to the network, transaction execution is separated from
transaction ordering and commitment. Executing transactions prior to
ordering them enables each peer node to process multiple transactions
simultaneously. This concurrent execution increases processing efficiency on
each peer and accelerates delivery of transactions to the ordering service.

Hyperledger Fabric按节点类型分配网络角色。为了向网络提供并发性和并行性，交易执行与交易排序、承诺分开。先执行交易再将其排序，使每个节点能够同时处理多个交易。这种并发执行提高了每个节点的处理效率，并加速了交易交付到排序服务的过程。

In addition to enabling parallel processing, the division of labor unburdens
ordering nodes from the demands of transaction execution and ledger
maintenance, while peer nodes are freed from ordering (consensus) workloads.
This bifurcation of roles also limits the processing required for authorization
and authentication; all peer nodes do not have to trust all ordering nodes, and
vice versa, so processes on one can run independently of verification by the
other.

除了启用并行处理之外，分工还可以减轻排序节点对交易执行和账本维护的需求，同时使节点免于排序（共识）工作负载。角色的分叉也限制了授权和认证所需的处理；所有节点都不必信任所有排序节点，反之亦然，因此一方上的进程可以独立于另一方的验证运行。

Chaincode functionality - 链码功能
-----------------------

Chaincode applications encode logic that is
invoked by specific types of transactions on the channel. Chaincode that
defines parameters for a change of asset ownership, for example, ensures that
all transactions that transfer ownership are subject to the same rules and
requirements. **System chaincode** is distinguished as chaincode that defines
operating parameters for the entire channel. Lifecycle and configuration system
chaincode defines the rules for the channel; endorsement and validation system
chaincode defines the requirements for endorsing and validating transactions.

Chaincode应用程序编码由通道上特定交易类型调用的逻辑，例如，确保所有转让所有权的交易都遵循相同的规则和要求。 **系统链码** 与链码不同，其定义整个通道的操作参数。生命周期和配置系统链码定义了通道的规则；认可和验证系统链码定义了认可和验证交易的要求。

Modular design - 模块化设计
--------------

Hyperledger Fabric implements a modular architecture to
provide functional choice to network designers. Specific algorithms for
identity, ordering (consensus) and encryption, for example, can be plugged in
to any Hyperledger Fabric network. The result is a universal blockchain
architecture that any industry or public domain can adopt, with the assurance
that its networks will be interoperable across market, regulatory and
geographic boundaries.

Hyperledger Fabric实现了模块化架构，为网络设计人员提供了功能选择。例如，用于身份验证，排序（一致）和加密的特定算法可以插入到任何Hyperledger Fabric网络。这会产生任何行业或公共领域都可以采用的通用区块链架构，并确保其网络可跨市场、监管和地理边界进行互操作。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
