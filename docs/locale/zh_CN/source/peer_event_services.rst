基于通道的 Peer 节点事件服务
=================================
Peer channel-based event services
=================================

概述
----------------

General overview
----------------

在 Fabric 的早期版本中，Peer 事件服务被称为事件中心。每当添加新区块到 Peer 节点的帐本中时，该服务都会发送事件，而不管该通道是不是涉及该区块，并且只有运行事件 Peer 的组织成员才能访问该事件（即，与该事件相关联的成员） ）。

In previous versions of Fabric, the peer event service was known as the event
hub. This service sent events any time a new block was added to the peer's
ledger, regardless of the channel to which that block pertained, and it was only
accessible to members of the organization running the eventing peer (i.e., the
one being connected to for events).

从v1.1开始，有了提供事件的新服务。这些服务使用完全不同的设计来按通道提供事件。这意味着事件的注册发生在通道级别而不是 Peer 节点端，从而可以对 Peer 节点的数据访问进行精细控制。接收事件的请求是从 Peer 节点组织外部的身份接受的（由通道配置进行定义）。这还提供了更高的可靠性，以及一种接收可能错过的事件的方式（无论是由于连接问题还是由于 Peer 节点正在加入已经运行的网络而导致的事件遗漏）。

Starting with v1.1, there are new services which provide events. These services use an
entirely different design to provide events on a per-channel basis. This means
that registration for events occurs at the level of the channel instead of the peer,
allowing for fine-grained control over access to the peer's data. Requests to
receive events are accepted from identities outside of the peer's organization (as
defined by the channel configuration). This also provides greater reliability and a
way to receive events that may have been missed (whether due to a connectivity issue
or because the peer is joining a network that has already been running).

可用的服务
------------------

Available services
------------------

* ``Deliver``

该服务将已提交到帐本的整个区块发送出去。如果链码有事件设置，则可以在区块的 ``ChaincodeActionPayload`` 中找到。

This service sends entire blocks that have been committed to the ledger. If
any events were set by a chaincode, these can be found within the
``ChaincodeActionPayload`` of the block.

* ``DeliverWithPrivateData``

该服务发送与 ``Deliver`` 服务相同的数据，以及来自客户组织的的任何授权访问的私有数据。

This service sends the same data as the ``Deliver`` service, and additionally
includes any private data from collections that the client's organization is
authorized to access.

* ``DeliverFiltered``

该服务发送“已过滤”的区块，这是有关已提交到账本的区块的最小信息集。它主要针对 Peer 节点拥有者希望外部客户端接收关于他们的交易和交易状态的主要数据的情况。用于在 Peer 所有者希望外部客户主要接收有关其交易和交易状态信息的网络中。如果链码中有事件设置，则可以在过滤后的区块的 ``FilteredChaincodeAction`` 中找到。

This service sends "filtered" blocks, minimal sets of information about blocks
that have been committed to the ledger. It is intended to be used in a network
where owners of the peers wish for external clients to primarily receive
information about their transactions and the status of those transactions. If
any events were set by a chaincode, these can be found within the
``FilteredChaincodeAction`` of the filtered block.

.. note:: 链码事件的有效负载将不包含在已过滤的区块中。

.. note:: The payload of chaincode events will not be included in filtered blocks.

如何注册事件
--------------------------

How to register for events
--------------------------

事件的注册是通过将包含消息的信封发送到 Peer 节点来完成的，该信封包含所需的开始和停止位置，寻找行为定义（一直阻塞到准备就绪，还是直接失败）。辅助变量 ``SeekOldest`` 和 ``SeekNewest`` 可以用于指示最老的（即第一个）区块或账本的最新的（即最后一个）区块。要使服务无限期发送事件，``SeekInfo`` 消息应包含停止位置 ``MAXINT64``。

Registration for events is done by sending an envelope
containing a deliver seek info message to the peer that contains the desired start
and stop positions, the seek behavior (block until ready or fail if not ready).
There are helper variables ``SeekOldest`` and ``SeekNewest`` that can be used to
indicate the oldest (i.e. first) block or the newest (i.e. last) block on the ledger.
To have the services send events indefinitely, the ``SeekInfo`` message should
include a stop position of ``MAXINT64``.

.. note:: 如果在 Peer 节点上启用了双向 TLS ，则必须在信封的通道头中设置 TLS 证书哈希。

.. note:: If mutual TLS is enabled on the peer, the TLS certificate hash must be
          set in the envelope's channel header.

默认情况下，事件服务使用“Channel Readers”策略来确定是否授权客户端的事件请求。

By default, the event services use the Channel Readers policy to determine whether
to authorize requesting clients for events.

传递响应消息概述
-------------------------------------

Overview of deliver response messages
-------------------------------------

事件服务发送 ``DeliverResponse`` 消息作为回应。

The event services send back ``DeliverResponse`` messages.

每条消息应该包含如下内容之一：

Each message contains one of the following:

 * 状态 --  HTTP 状态代码。如果发生任何故障，每个服务将返回相应的故障代码；否则，一旦服务完成 ``SeekInfo`` 请求的所有信息，它将返回 ``200 - SUCCESS`` 。
 * 区块 -- 仅由 ``Deliver`` 服务返回。
 * 区块和私有数据 -- 仅由 ``DeliverWithPrivateData`` 服务返回。
 * 已过滤的区块 -- 仅由 ``DeliverFiltered`` 服务返回。

 * status -- HTTP status code. Each of the services will return the appropriate failure
   code if any failure occurs; otherwise, it will return ``200 - SUCCESS`` once
   the service has completed sending all information requested by the ``SeekInfo``
   message.
 * block -- returned only by the ``Deliver`` service.
 * block and private data -- returned only by the ``DeliverWithPrivateData`` service.
 * filtered block -- returned only by the ``DeliverFiltered`` service.

过滤后的区块包含：

A filtered block contains:

 * 通道ID
 * 编号（如区块高度）
 * 过滤交易的数组。
 * 交易ID。

 * channel ID.
 * number (i.e. the block number).
 * array of filtered transactions.
 * transaction ID.

   * 类型 (e.g. ``ENDORSER_TRANSACTION``, ``CONFIG``。）
   * 交易验证代码。

   * type (e.g. ``ENDORSER_TRANSACTION``, ``CONFIG``).
   * transaction validation code.

 * 过滤的交易行为。
     * 过滤后的链码行为数组。
        * 交易的链码事件（除去负载）

 * filtered transaction actions.
     * array of filtered chaincode actions.
        * chaincode event for the transaction (with the payload nilled out).

SDK事件文档
-----------------------

SDK event documentation
-----------------------

有关使用事件服务的更多详细信息，请参阅 `SDK documentation. <https://hyperledger.github.io/fabric-sdk-node/master/tutorial-channel-events.html>`_

For further details on using the event services, refer to the `SDK documentation. <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-channel-events.html>`_
