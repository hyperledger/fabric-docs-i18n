服务发现
=================
Service Discovery
=================

为什么我们需要服务发现?
---------------------------------

Why do we need service discovery?
---------------------------------

为了在 Peer 节点上执行链码，将交易提交给排序节点，并更新交易状态，应用程序需要连接 SDK 中开放的 API。

In order to execute chaincode on peers, submit transactions to orderers, and to
be updated about the status of transactions, applications connect to an API
exposed by an SDK.

然而，为了让应用程序连接到相关的网络节点，SDK 需要大量信息。除了通道上排序节点和 Peer 节点的 CA 证书和 TLS 证书及其 IP 地址和端口号之外，它还必须知道相关的背书策略以及安装了链码的 Peer 节点（这样应用程序才能知道将链码提案发送给哪个 Peer 节点）。

However, the SDK needs a lot of information in order to allow applications to
connect to the relevant network nodes. In addition to the CA and TLS certificates
of the orderers and peers on the channel -- as well as their IP addresses and port
numbers -- it must know the relevant endorsement policies as well as which peers
have the chaincode installed (so the application knows which peers to send chaincode
proposals to).

在 v1.2 之前，这些信息是静态编码的。然而，这种实现不能动态响应网络的更改（例如添加已安装相关链码的 Peer 节点或 Peer 节点临时离线）。静态配置也不能让应用程序对背书策略本身的更改做出反应（比如通道中加入了新的组织）。

Prior to v1.2, this information was statically encoded. However, this implementation
is not dynamically reactive to network changes (such as the addition of peers who have
installed the relevant chaincode, or peers that are temporarily offline). Static
configurations also do not allow applications to react to changes of the
endorsement policy itself (as might happen when a new organization joins a channel).

此外，客户端应用程序无法知道哪些 Peer 节点已更新账本，哪些未更新。因此该应用程序可能向网络中尚未同步账本的 Peer 节点提交提案，从而导致事务在提交时失效并浪费资源。

In addition, the client application has no way of knowing which peers have updated
ledgers and which do not. As a result, the application might submit proposals to
peers whose ledger data is not in sync with the rest of the network, resulting
in transaction being invalidated upon commit and wasting resources as a consequence.

**服务发现** 通过让 Peer 节点动态计算所需信息，并以可消耗的方式将其提供给 SDK，从而改善了此过程。

The **discovery service** improves this process by having the peers compute
the needed information dynamically and present it to the SDK in a consumable
manner.

Fabric 中的服务发现是如何工作的
---------------------------------------------------

How service discovery works in Fabric
-------------------------------------

应用程序启动时会通过设置得知应用程序开发人员或者管理员所信任的一组 Peer 节点，以便为发现查询提供可信的响应。客户端应用程序所使用的候选节点也在该组织中。请注意，为了被服务发现所识别，Peer 节点必须定义一个 ``EXTERNAL_ENDPOINT`` 。想了解如何执行此操作，请查看我们的文档 :doc:`discovery-cli` 

The application is bootstrapped knowing about a group of peers which are
trusted by the application developer/administrator to provide authentic responses
to discovery queries. A good candidate peer to be used by the client application
is one that is in the same organization. Note that in order for peers to be known
to the discovery service, they must have an ``EXTERNAL_ENDPOINT`` defined. To see
how to do this, check out our :doc:`discovery-cli` documentation.

应用程序向发现服务发出配置查询并获取它所拥有的所有静态配置，否则就需要与网络的其余节点通信。继续向 Peer 节点的发现服务发送查询，就可以随时刷新此信息。

The application issues a configuration query to the discovery service and obtains
all the static information it would have otherwise needed to communicate with the
rest of the nodes of the network. This information can be refreshed at any point
by sending a subsequent query to the discovery service of a peer.

该服务在 Peer 节点（而不是应用程序）上运行，并使用 gossip 通信层维护的网络元数据信息来找出哪些 Peer 节点在线。它还从 Peer 节点的状态数据库中获取信息，例如相关的签名策略等。

The service runs on peers -- not on the application -- and uses the network metadata
information maintained by the gossip communication layer to find out which peers
are online. It also fetches information, such as any relevant endorsement policies,
from the peer's state database.

通过服务发现，应用程序不再需要指定为他们背书的 Peer 节点。给定通道和链码 ID，SDK 就可以通过发现服务查询其所对应的 Peer 节点。然后，发现服务会计算出由两个对象组成的描述符：

With service discovery, applications no longer need to specify which peers they
need endorsements from. The SDK can simply send a query to the discovery service
asking which peers are needed given a channel and a chaincode ID. The discovery
service will then compute a descriptor comprised of two objects:

1. **布局（Layouts）**: Peer 组的列表，以及每个组中应当选取的 Peer 节点数。
2. **组到 Peer 的映射**: 布局中的组和通道的 Peer 节点的对应。实际上，一个组很可能是代表一个组织的 Peer 节点，但是由于服务 API 是通用的并且与组织无关，因此这只是一个“组”。

1. **Layouts**: a list of groups of peers and a corresponding amount of peers from
   each group which should be selected.
2. **Group to peer mapping**: from the groups in the layouts to the peers of the
   channel. In practice, each group would most likely be peers that represent
   individual organizations, but because the service API is generic and ignorant of
   organizations this is just a "group".

下面是一个``AND(Org1, Org2)``策略的描述符示例，其中每个组织中有两个 Peer 节点。

The following is an example of a descriptor from the evaluation of a policy of
``AND(Org1, Org2)`` where there are two peers in each of the organizations.

.. code-block:: JSON

.. code-block:: none

   Layouts: [
        QuantitiesByGroup: {
          “Org1”: 1,
          “Org2”: 1,
        }
   ],
   EndorsersByGroups: {
     “Org1”: [peer0.org1, peer1.org1],
     “Org2”: [peer0.org2, peer1.org2]
   }


In other words, the endorsement policy requires a signature from one peer in Org1
and one peer in Org2. And it provides the names of available peers in those orgs who
can endorse (``peer0`` and ``peer1`` in both Org1 and in Org2).

换言之，背书策略需要两个分别来自 Org1 和 Org2 的 Peer 节点的签名。它提供了组织中可以背书的（Org1 和 Org2 中都有 ``peer0`` 和 ``peer1``） Peer 节点的名称。

The SDK then selects a random layout from the list. In the example above, the
endorsement policy is Org1 ``AND`` Org2. If instead it was an ``OR`` policy, the SDK
would randomly select either Org1 or Org2, since a signature from a peer from either
Org would satisfy the policy.

之后 SDK 会随机从列表中选择一个布局。在上边的例子中的背书策略是 Org1 ``AND`` Org2。如果换成 ``OR`` 策略，SDK 就会随机选择 Org1 或 Org2，因为任意一个节点的签名都可以满足背书策略。

After the SDK has selected a layout, it selects from the peers in the layout based on a
criteria specified on the client side (the SDK can do this because it has access to
metadata like ledger height). For example, it can prefer peers with higher ledger heights
over others -- or to exclude peers that the application has discovered to be offline
-- according to the number of peers from each group in the layout. If no single
peer is preferable based on the criteria, the SDK will randomly select from the peers
that best meet the criteria.

SDK 选择布局后，会根据客户端指定的标准对布局中的 Peer 节点进行选择（SDK 可以这样做是因为它能够访问元数据，比如账本高度）。例如，SDK 可以根据布局中每个组的 Peer 节点的数量，优先选择具有更高的账本高度的 Peer 节点，或者排除应用程序发现的处于脱机状态的 Peer 节点。如果无法根据标准选定一个 Peer 节点, SDK 将从最符合标准的 Peer 节点中随机选择。

Capabilities of the discovery service
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

发现服务的功能
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The discovery service can respond to the following queries:

发现服务可以响应以下查询：

* **Configuration query**: Returns the ``MSPConfig`` of all organizations in the channel
  along with the orderer endpoints of the channel.
* **Peer membership query**: Returns the peers that have joined the channel.
* **Endorsement query**: Returns an endorsement descriptor for given chaincode(s) in
  a channel.
* **Local peer membership query**: Returns the local membership information of the
  peer that responds to the query. By default the client needs to be an administrator
  for the peer to respond to this query.

* **配置查询**： 从通道的排序节点返回通道中所有组织的 ``MSPConfig``。
* **Peer 成员查询**： 返回已加入通道的 Peer 节点。
* **背书查询**： 返回通道中给定链码的背书描述符。
* **本地 Peer 成员查询**： 返回响应查询的 Peer 节点的本地成员信息。默认情况下，客户端需要是 Peer 节点的管理员才能响应此查询。

Special requirements
~~~~~~~~~~~~~~~~~~~~~~
When the peer is running with TLS enabled the client must provide a TLS certificate when connecting
to the peer. If the peer isn't configured to verify client certificates (clientAuthRequired is false), this TLS certificate
can be self-signed.

特殊要求
~~~~~~~~~~~~~~~~~~~~~~
当 Peer 节点在启用 TLS 的情况下运行时，客户端在连接到 Peer 节点时必须提供 TLS 证书。如果未将 Peer 节点配置为验证客户端证书（clientAuthRequired 为 false），则此 TLS 证书可以是自签名的。
