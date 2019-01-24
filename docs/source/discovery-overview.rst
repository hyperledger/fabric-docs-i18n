Service Discovery - 服务发现
=================

Why do we need service discovery? - 为什么需要服务发现？
---------------------------------

In order to execute chaincode on peers, submit transactions to orderers, and to
be updated about the status of transactions, applications connect to an API
exposed by an SDK.

应用程序需要连接到通过SDK发布的API来完成诸如在peer上执行链码、将交易提交给
orderer、或接收交易状态变更的信息。

However, the SDK needs a lot of information in order to allow applications to
connect to the relevant network nodes. In addition to the CA and TLS certificates
of the orderers and peers on the channel -- as well as their IP addresses and port
numbers -- it must know the relevant endorsement policies as well as which peers
have the chaincode installed (so the application knows which peers to send chaincode
proposals to).

然而，SDK需要很多信息才能够将应用程序接入到相关的网络节点。这些信息不光包括：用来和peer
及orderer建立链接的的证书、peer和orderer的网络IP地址及端口。还要提供相关的背书策略，和
链码安装在哪些peer节点上（便于应用程序知晓要将链码草案发送到哪些peer节点）等信息。

Prior to v1.2, this information was statically encoded. However, this implementation
is not dynamically reactive to network changes (such as the addition of peers who have
installed the relevant chaincode, or peers that are temporarily offline). Static
configurations also do not allow applications to react to changes of the
endorsement policy itself (as might happen when a new organization joins a channel).

在v1.2之前，这些信息都是静态，且需手动编码提供。并且，无法响应相关的网络变更（例如，链码peer节点的
新增与下线），这些静态配置也不能支持应用程序有效应对背书策略的变化（例如，一个新组织加入channel）。

In addition, the client application has no way of knowing which peers have updated
ledgers and which do not. As a result, the application might submit proposals to
peers whose ledger data is not in sync with the rest of the network, resulting
in transaction being invalidated upon commit and wasting resources as a consequence.

而且，客户端应用也无法知道哪些peer节点已经更新了账本，哪些peer节点还没有完成更新。
这可能会导致应用程序向还未完成账本更新的peer节点提交交易草案，然后在提交时被拒，造成
资源浪费。

The **discovery service** improves this process by having the peers compute
the needed information dynamically and present it to the SDK in a consumable
manner.

**发现服务** 通过让peer节点来计算所需动态信息，然后提供给SDK去使用。

How service discovery works in Fabric - Fabric中的发现服务如何工作
-------------------------------------

The application is bootstrapped knowing about a group of peers which are
trusted by the application developer/administrator to provide authentic responses
to discovery queries. A good candidate peer to be used by the client application
is one that is in the same organization. Note that in order for peers to be known
to the discovery service, they must have an ``EXTERNAL_ENDPOINT`` defined. To see
how to do this, check out our :doc:`discovery-cli` documentation.

应用程序在启动时知道可以访问哪些可信的peer节点来执行发现查询。和应用程序在同一个组织
内的peer节点会是很好的选择。注意：为了能够让 peers 对于发现服务可知，他们必须要定义一个 ``EXTERNAL_ENDPOINT``。想知道怎么做，请查看我们的 :doc:`discovery-cli` 文档。

The application issues a configuration query to the discovery service and obtains
all the static information it would have otherwise needed to communicate with the
rest of the nodes of the network. This information can be refreshed at any point
by sending a subsequent query to the discovery service of a peer.

应用程序向发现服务发送一个配置查询，即可获得网络的静态信息。这些信息在需要的时候即可通过
向发现服务发送新的查询获得。

The service runs on peers -- not on the application -- and uses the network metadata
information maintained by the gossip communication layer to find out which peers
are online. It also fetches information, such as any relevant endorsement policies,
from the peer's state database.

发现服务运行于peer节点上，利用gossip通讯层维护的元数据来得知哪些peer节点在线。发现服务也
从peer节点的状态数据库提取其他诸如背书策略等信息。

With service discovery, applications no longer need to specify which peers they
need endorsements from. The SDK can simply send a query to the discovery service
asking which peers are needed given a channel and a chaincode ID. The discovery
service will then compute a descriptor comprised of two objects:

有了发现服务，应用程序不必在指定要从哪些peer节点获得背书。SDK只要依据给定的通道
和链码ID，向发现服务发送一个简单的查询。发现服务就可以计算出包含下面两个对象的描述：

1. **Layouts**: a list of groups of peers and a corresponding amount of peers from
   each group which should be selected.

1. **布局**: peer节点的分组清单，和每组中选出的对应数量的peer节点

2. **Group to peer mapping**: from the groups in the layouts to the peers of the
   channel. In practice, each group would most likely be peers that represent
   individual organizations, but because the service API is generic and ignorant of
   organizations this is just a "group".

2. **分组和peer节点映射**: 从布局中的分组到通道中的peer节点。实际应用中，节点分组
  通常由统一组织中的peer节点组成。只是服务API是通用的，因而忽略组织而采用分组。

The following is an example of a descriptor from the evaluation of a policy of
``AND(Org1, Org2)`` where there are two peers in each of the organizations.

下面的示例描述了两个组织，每个组织中包含两个peer节点，且采用``AND(Org1, Org2)``的
评估策略：

.. code-block:: JSON

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

换句话，背书策略要求Org1中的一个peer节点和Org2中的一个peer节点共同参与背书。而且，描述还
表明Org1和Org2分别有哪些peer节点可以参与背书（Org1和Org2中的``peer0``和``peer1``）。

The SDK then selects a random layout from the list. In the example above, the
endorsement policy is Org1 ``AND`` Org2. If instead it was an ``OR`` policy, the SDK
would randomly select either Org1 or Org2, since a signature from a peer from either
Org would satisfy the policy.

SDK则从上述描述中随机选择一个布局。换句话说，上例中背书策略是Org1``AND``Org2。如果
背书策略是``OR``的话，SDK会随机的选择Org1或者Org2。应为一个组织中的一个peer节点的签名
既满足背书策略。

After the SDK has selected a layout, it selects from the peers in the layout based on a
criteria specified on the client side (the SDK can do this because it has access to
metadata like ledger height). For example, it can prefer peers with higher ledger heights
over others -- or to exclude peers that the application has discovered to be offline
-- according to the number of peers from each group in the layout. If no single
peer is preferable based on the criteria, the SDK will randomly select from the peers
that best meet the criteria.

SDK选定布局后，更具客户端定义的条件选出peer节点（SDK因为知道账本高度，因此能够做这件事）。
例如，依据布局分组中peer节点的数量，可以选择账本高度高的peer节点，或者排除已下线peer节点。
如果并没有peer节点满足要求的优先条件，SDK则随机选择次优peer节点。

Capabilities of the discovery service - 发现服务的能力
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The discovery service can respond to the following queries:

发现服务可以支持一下查询：

* **Configuration query**: Returns the ``MSPConfig`` of all organizations in the channel
  along with the orderer endpoints of the channel.
  **配置布局**: 返回通道中包含所有组织和orderder节点endpoint的``MSPConfig``信息。

* **Peer membership query**: Returns the peers that have joined the channel.
  **Peer membership query**: 返回已加入通道的peer节点。

* **Endorsement query**: Returns an endorsement descriptor for given chaincode(s) in
  a channel.
  **Endorsement query**: 返回给定通道中给定链码的背书策略描述。

* **Local peer membership query**: Returns the local membership information of the
  peer that responds to the query. By default the client needs to be an administrator
  for the peer to respond to this query.
  **Local peer membership query**: 返回处理查询请求的peer节点的本地会员信息。缺省情况下，
  peer节点在客户端是管理员的情况下会处理次请求。

Special requirements - 特殊要求
~~~~~~~~~~~~~~~~~~~~~~
When the peer is running with TLS enabled the client must provide a TLS certificate when connecting
to the peer. If the peer isn't configured to verify client certificates (clientAuthRequired is false), this TLS certificate
can be self-signed.

当peer节点使用TLS是，客户端必须提供TLS证书才能链接peer节点。如果peer节点根据配置没有
验证客户端证书，TLS证书可以自我验签。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
