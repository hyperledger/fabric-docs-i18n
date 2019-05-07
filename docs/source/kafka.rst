Bringing up a Kafka-based Ordering Service - 启用基于 Kafka 的排序服务
===========================================

.. _kafka-caveat:

Caveat emptor - 郑重声明
-------------

This document assumes that the reader knows how to set up a Kafka cluster and a ZooKeeper ensemble, and keep them secure for general usage by preventing unauthorized access. The sole purpose of this guide is to identify the steps you need to take so as to have a set of Hyperledger Fabric ordering service nodes (OSNs) use your Kafka cluster and provide an ordering service to your blockchain network.

本文档假设读者知道怎么配置 Kafka 和 ZooKeeper 集群，并阻止了非授权访问以保证它们
在使用过程中的安全性。本指南的唯一目的是说明如何配置你的 Hyperledger Fabric 排序
服务节点 （OSNs，ordering service nodes）使用 Kafka 集群为你的区块链网络提供排序
服务的步骤。

Big picture - 概览
-----------

Each channel maps to a separate single-partition topic in Kafka. When an OSN receives transactions via the ``Broadcast`` RPC, it checks to make sure that the broadcasting client has permissions to write on the channel, then relays (i.e. produces) those transactions to the appropriate partition in Kafka. This partition is also consumed by the OSN which groups the received transactions into blocks locally, persists them in its local ledger, and serves them to receiving clients via the ``Deliver`` RPC. For low-level details, refer to `the document that describes how we came to this design <https://docs.google.com/document/d/19JihmW-8blTzN99lAubOfseLUZqdrB6sBR0HsRgCAnY/edit>`_ — Figure 8 is a schematic representation of the process described above.

每个通道映射到 Kafka 中一个单独的单分区 topic。当一个 OSN 通过 ``Broadcast`` RPC 
接收到交易时，它会进行检查以确认广播的客户端有写入通道的权限，然后将交易转发（或
者说是生产）到 Kafka 中合适的分区中。这个分区被 OSN 消费，将接受到的交易打包到本
地区块，持久化保存在他们的本地账本，然后通过 ``Deliver`` RPC 将他们发送给接收客户
端。底层的细节请参考 `the document that describes how we came to this design <https://docs.google.com/document/d/19JihmW-8blTzN99lAubOfseLUZqdrB6sBR0HsRgCAnY/edit>`_ — 
图表 8 阐述了上述过程。

Steps - 步骤
-----

Let ``K`` and ``Z`` be the number of nodes in the Kafka cluster and the ZooKeeper ensemble respectively:

使用 ``K`` 和 ``Z`` 表示 Kafka 和 ZooKeeperer 集群中的节点数量：

#. At a minimum, ``K`` should be set to 4. (As we will explain in Step 4 below,  this is the minimum number of nodes necessary in order to exhibit crash fault tolerance, i.e. with 4 brokers, you can have 1 broker go down, all channels will continue to be writeable and readable, and new channels can be created.)

#. ``K`` 的最小值为 4。（我们将在第 4 步中解释，这是崩溃错误容忍的最小节点数量，
   比如，有 4 个 broker，当有 1 个 broker 宕机的时候，仍然可以继续读写和创建新
   通道。）

#. ``Z`` will either be 3, 5, or 7. It has to be an odd number to avoid split-brain scenarios, and larger than 1 in order to avoid single point of failures. Anything beyond 7 ZooKeeper servers is considered an overkill.

#. ``Z`` 可以是 3、5 或者 7。它应该是奇数个以防止脑裂的发生，并且多余 1 个以防止
   单点故障。多余 7 个 ZooKeeper 服务器就没有必要了。

Then proceed as follows:

具体过程如下：

3. Orderers: **Encode the Kafka-related information in the network's genesis block.** If you are using ``configtxgen``, edit ``configtx.yaml`` —or pick a preset profile for the system channel's genesis block—  so that:

3. Orderers： **Kafka 相关的信息编码在网络的创世区块中。** 如果你使用了 ``configtxgen``, 
   编辑 ``configtx.yaml`` —— 或者使用一个系统通道创世区块的预配置文件 —— 然后：

   #. ``Orderer.OrdererType`` is set to ``kafka``.

   #. ``Orderer.OrdererType`` 设置为 ``kafka`` 。

   #. ``Orderer.Kafka.Brokers`` contains the address of *at least two* of the Kafka brokers in your cluster in ``IP:port`` notation. The list does not need to be exhaustive. (These are your bootstrap brokers.)

   #. ``Orderer.Kafka.Brokers`` 包含 *至少两个* 你的集群中的 Kafka broker 的 ``IP:port`` 。
      列表中不需要是所有的节点。（这些是你的引导 broker 。）

#. Orderers: **Set the maximum block size.** Each block will have at most `Orderer.AbsoluteMaxBytes` bytes (not including headers), a value that you can set in ``configtx.yaml``. Let the value you pick here be ``A`` and make note of it — it will affect how you configure your Kafka brokers in Step 6.

#. Orderers: **设置最小区块大小。** 每个区块最大为 `Orderer.AbsoluteMaxBytes` 个字节（不
   包含头部），这个值你可以在 ``configtx.yaml`` 中设置。我们使用 ``A`` 来代表它 —— 它将影
   响到我们在第 6 步对 Kafka broker 的配置。

#. Orderers: **Create the genesis block.** Use ``configtxgen``. The settings you picked in Steps 3 and 4 above are system-wide settings, i.e. they apply across the network for all the OSNs. Make note of the genesis block's location.

#. Orderers： **创建创世区块。** 使用 ``configtxgen`` 。在第 3 步和第 4 步的设置是系统层
   级的设计，将影响到网络中所有的 OSN。记下创世区块的位置。

#. Kafka cluster: **Configure your Kafka brokers appropriately.** Ensure that every Kafka broker has these keys configured:

#. Kafka 集群： **合理的配置你的 Kafka brokers。** 确保每一个 Kafka broker 配置了这些关键项：

   #. ``unclean.leader.election.enable = false`` — Data consistency is key in a blockchain environment. We cannot have a channel leader chosen outside of the in-sync replica set, or we run the risk of overwriting the offsets that the previous leader produced, and —as a result— rewrite the blockchain that the orderers produce.

   #. ``unclean.leader.election.enable = false`` — 数据持久化是区块链环境中的重要环节。我们
      不能在同步复制集合之外选择一个领导通道，或者我们冒着覆盖上一个领队产生的偏移量的风险，
      并因此重写排序节点产生的区块。

   #. ``min.insync.replicas = M`` — Where you pick a value ``M`` such that ``1 < M < N`` (see ``default.replication.factor`` below). Data is considered committed when it is written to at least ``M`` replicas (which are then considered in-sync and belong to the in-sync replica set, or ISR). In any other case, the write operation returns an error. Then:

   #. ``min.insync.replicas = M`` — 这里的值 ``M`` 设为 ``1 < M < N`` （查看下边的 ``default.replication.factor`` ）。 
      数据写入至少 ``M`` 个副本之后才认为被提交。其他情况下，写操作返回一个错误。然后：

      #. If up to ``N-M`` replicas —out of the ``N`` that the channel data is written to— become unavailable, operations proceed normally.

      #. 如果写入的 ``N`` 个副本中有 ``N-M`` 个不可用，操作仍可正常运行。

      #. If more replicas become unavailable, Kafka cannot maintain an ISR set of ``M,`` so it stops accepting writes. Reads work without issues. The channel becomes writeable again when ``M`` replicas get in-sync.

      #. 如果有更多的副本不可用，Kafka 就不能维护 ISR 集合中的 ``M`` 个，所以它就会停止接受
         写入。读取是没有问题的。当重新同步到 ``M`` 个副本的时候，通道可以恢复写的功能。

   #. ``default.replication.factor = N`` — Where you pick a value ``N`` such that ``N < K``. A replication factor of ``N`` means that each channel will have its data replicated to ``N`` brokers. These are the candidates for the ISR set of a channel. As we noted in the ``min.insync.replicas section`` above, not all of these brokers have to be available all the time. ``N`` should be set *strictly smaller* to ``K`` because channel creations cannot go forward if less than ``N`` brokers are up. So if you set ``N = K``, a single broker going down means that no new channels can be created on the blockchain network — the crash fault tolerance of the ordering service is non-existent.

   #. ``default.replication.factor = N`` — 这里的值 ``N`` 设为 ``N < K`` 。 ``N`` 个副本意味着每个通道都会将它的数据备份到 ``N`` 个 broker。 这些是一个通道 ISR 集合的备份。就像我们在上边提到的 ``min.insync.replicas section`` 不是所有的节点随时都是可用的。 #########翻译到这里了##########``N`` should be set *strictly smaller* to ``K`` because channel creations cannot go forward if less than ``N`` brokers are up. So if you set ``N = K``, a single broker going down means that no new channels can be created on the blockchain network — the crash fault tolerance of the ordering service is non-existent.


      Based on what we've described above, the minimum allowed values for ``M`` and ``N`` are 2 and 3 respectively. This configuration allows for the creation of new channels to go forward, and for all channels to continue to be writeable.
   #. ``message.max.bytes`` and ``replica.fetch.max.bytes`` should be set to a value larger than ``A``, the value you picked in ``Orderer.AbsoluteMaxBytes`` in Step 4 above. Add some buffer to account for headers — 1 MiB is more than enough. The following condition applies:

      ::

         Orderer.AbsoluteMaxBytes < replica.fetch.max.bytes <= message.max.bytes

      (For completeness, we note that ``message.max.bytes`` should be strictly smaller to ``socket.request.max.bytes`` which is set by default to 100 MiB. If you wish to have blocks larger than 100 MiB you will need to edit the hard-coded value in ``brokerConfig.Producer.MaxMessageBytes`` in ``fabric/orderer/kafka/config.go`` and rebuild the binary from source. This is not advisable.)
   #. ``log.retention.ms = -1``. Until the ordering service adds support for pruning of the Kafka logs, you should disable time-based retention and prevent segments from expiring. (Size-based retention —see ``log.retention.bytes``— is disabled by default in Kafka at the time of this writing, so there's no need to set it explicitly.)

#. Orderers: **Point each OSN to the genesis block.** Edit ``General.GenesisFile`` in ``orderer.yaml`` so that it points to the genesis block created in Step 5 above. (While at it, ensure all other keys in that YAML file are set appropriately.)
#. Orderers: **Adjust polling intervals and timeouts.** (Optional step.)

   #. The ``Kafka.Retry`` section in the ``orderer.yaml`` file allows you to adjust the frequency of the metadata/producer/consumer requests, as well as the socket timeouts. (These are all settings you would expect to see in a Kafka producer or consumer.)
   #. Additionally, when a new channel is created, or when an existing channel is reloaded (in case of a just-restarted orderer), the orderer interacts with the Kafka cluster in the following ways:

      #. It creates a Kafka producer (writer) for the Kafka partition that corresponds to the channel.
      #. It uses that producer to post a no-op ``CONNECT`` message to that partition.
      #. It creates a Kafka consumer (reader) for that partition.

      If any of these steps fail, you can adjust the frequency with which they are repeated. Specifically they will be re-attempted every ``Kafka.Retry.ShortInterval`` for a total of ``Kafka.Retry.ShortTotal``, and then every ``Kafka.Retry.LongInterval`` for a total of ``Kafka.Retry.LongTotal`` until they succeed. Note that the orderer will be unable to write to or read from a channel until all of the steps above have been completed successfully.

#. **Set up the OSNs and Kafka cluster so that they communicate over SSL.** (Optional step, but highly recommended.) Refer to `the Confluent guide <https://docs.confluent.io/2.0.0/kafka/ssl.html>`_ for the Kafka cluster side of the equation, and set the keys under ``Kafka.TLS`` in ``orderer.yaml`` on every OSN accordingly.
#. **Bring up the nodes in the following order: ZooKeeper ensemble, Kafka cluster, ordering service nodes.**

Additional considerations
-------------------------

#. **Preferred message size.** In Step 4 above (see `Steps`_ section) you can also set the preferred size of blocks by setting the ``Orderer.Batchsize.PreferredMaxBytes`` key. Kafka offers higher throughput when dealing with relatively small messages; aim for a value no bigger than 1 MiB.
#. **Using environment variables to override settings.** When using the sample Kafka and Zookeeper Docker images provided with Fabric (see ``images/kafka`` and ``images/zookeeper`` respectively), you can override a Kafka broker or a ZooKeeper server's settings by using environment variables. Replace the dots of the configuration key with underscores — e.g. ``KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false`` will allow you to override the default value of ``unclean.leader.election.enable``. The same applies to the OSNs for their *local* configuration, i.e. what can be set in ``orderer.yaml``. For example ``ORDERER_KAFKA_RETRY_SHORTINTERVAL=1s`` allows you to override the default value for ``Orderer.Kafka.Retry.ShortInterval``.

Kafka Protocol Version Compatibility
------------------------------------

Fabric uses the `sarama client library <https://github.com/Shopify/sarama>`_ and vendors a version of it that supports Kafka 0.10 to 1.0, yet is still known to work with older versions.

Using the ``Kafka.Version`` key in ``orderer.yaml``, you can configure which version of the Kafka protocol is used to communicate with the Kafka cluster's brokers. Kafka brokers are backward compatible with older protocol versions. Because of a Kafka broker's backward compatibility with older protocol versions, upgrading your Kafka brokers to a new version does not require an update of the ``Kafka.Version`` key value, but the Kafka cluster might suffer a `performance penalty <https://kafka.apache.org/documentation/#upgrade_11_message_format>`_ while using an older protocol version.

Debugging
---------

Set environment variable ``FABRIC_LOGGING_SPEC`` to ``DEBUG`` and set ``Kafka.Verbose`` to ``true`` in ``orderer.yaml`` .

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
