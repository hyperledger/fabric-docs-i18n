<<<<<<< HEAD
启用基于 Kafka 的排序服务
=======
Bringing up a Kafka-based Ordering Service - 启用基于 Kafka 的排序服务
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
===========================================

.. _kafka-caveat:

<<<<<<< HEAD
郑重声明
=======
Caveat emptor - 郑重声明
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
-------------

本文档假设读者知道怎么配置 Kafka 和 ZooKeeper 集群，并阻止了非授权访问以保证它们在使用过程中的安全性。本指南的唯一目的是说明如何配置你的 Hyperledger Fabric 排序服务节点（OSN，ordering service node）使用 Kafka 集群为你的区块链网络提供排序服务的步骤。

<<<<<<< HEAD
关于排序节点的角色以及它在网络和交易流程中的作用的信息，请参考 :doc:`orderer/ordering_service` 。

关于如何设置排序节点的信息，请参考 :doc:`orderer_deploy` 。

关于配置 Raft 排序服务的信息，请参考 :doc:`raft_configuration` 。

概览
=======
本文档假设读者知道怎么配置 Kafka 和 ZooKeeper 集群，并阻止了非授权访问以保证它们
在使用过程中的安全性。本指南的唯一目的是说明如何配置你的 Hyperledger Fabric 排序
服务节点 （OSNs，ordering service nodes）使用 Kafka 集群为你的区块链网络提供排序
服务的步骤。

Big picture - 概览
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
-----------

每个通道映射到 Kafka 中一个单独的单分区主题（topic）。当一个 OSN 通过 ``Broadcast`` RPC 接收到交易时，它会进行检查以确认广播的客户端有写入通道的权限，然后将交易转发（或者说是生产）到 Kafka 中合适的分区中。这个分区被 OSN 消费，将接受到的交易打包到本地区块，持久化保存在他们的本地账本，然后通过 ``Deliver`` RPC 将他们发送给接收客户端。底层的细节请参考 `the document that describes how we came to this design <https://docs.google.com/document/d/19JihmW-8blTzN99lAubOfseLUZqdrB6sBR0HsRgCAnY/edit>`_ ，图表 8 阐述了上述过程。

<<<<<<< HEAD
步骤
=======
每个通道映射到 Kafka 中一个单独的单分区 topic。当一个 OSN 通过 ``Broadcast`` RPC 
接收到交易时，它会进行检查以确认广播的客户端有写入通道的权限，然后将交易转发（或
者说是生产）到 Kafka 中合适的分区中。这个分区被 OSN 消费，将接受到的交易打包到本
地区块，持久化保存在他们的本地账本，然后通过 ``Deliver`` RPC 将他们发送给接收客户
端。底层的细节请参考 `the document that describes how we came to this design <https://docs.google.com/document/d/19JihmW-8blTzN99lAubOfseLUZqdrB6sBR0HsRgCAnY/edit>`_ — 
图表 8 阐述了上述过程。

Steps - 步骤
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
-----

使用 ``K`` 和 ``Z`` 表示 Kafka 和 ZooKeeperer 集群中的节点数量：


1. ``K`` 的最小值为4。（我们将在第4步中解释，这是崩溃错误容忍的最小节点数量，比如，有4个 broker，当有1个 broker 宕机的时候，仍然可以继续读写和创建新通道。）

2. ``Z`` 可以是3、5或者7。它应该是奇数个以防止脑裂的发生，并且多余1个以防止单点故障。多余7个 ZooKeeper 服务器就没有必要了。

具体过程如下：

<<<<<<< HEAD
3. Orderers： **Kafka 相关的信息编码在网络的创世区块中。** 如果你使用了 ``configtxgen``, 编辑 ``configtx.yaml``，或者使用一个系统通道创世区块的预配置文件，然后：

  * ``Orderer.OrdererType`` 设置为 ``kafka``。
  * ``Orderer.Kafka.Brokers`` 包含 *至少两个* 你集群中的 Kafka broker 的 ``IP:port`` 。列表中不需要是所有的节点。（这些是你的引导 broker 。）

4. Orderers: **设置最小区块大小。** 每个区块最大为 `Orderer.AbsoluteMaxBytes` 个字节（不包含头部），这个值你可以在 ``configtx.yaml`` 中设置。我们使用 ``A`` 来代表它，它将影响到我们在第6步对 Kafka broker 的配置。

5. Orderers： **创建创世区块。** 使用 ``configtxgen`` 。在第3步和第4步的设置是系统层级的设计，将影响到网络中所有的 OSN。记下创世区块的位置。

6. Kafka 集群： **合理的配置你的 Kafka brokers。** 确保每一个 Kafka broker 配置了这些关键项：

   * ``unclean.leader.election.enable = false`` — 数据持久化是区块链环境中的重要环节。我们不能在同步复制集合之外选择一个领导通道，或者我们冒着覆盖上一个领队产生的偏移量的风险，并因此重写排序节点产生的区块。

       * ``min.insync.replicas = M`` — 这里的值 ``M`` 设为 ``1 < M < N`` （查看下边的 ``default.replication.factor``）。 数据写入至少 ``M`` 个副本之后才认为被提交。其他情况下，写操作返回一个错误。然后：

         * 如果写入的 ``N`` 个副本中有 ``N-M`` 个不可用，操作仍可正常运行。

         * 如果有更多的副本不可用，Kafka 就不能维护 ISR 集合中的 ``M`` 个，所以它就会停止接受写入。读取是没有问题的。当重新同步到 ``M`` 个副本的时候，通道可以恢复写的功能。

   * ``default.replication.factor = N`` — 这里的值 ``N`` 设为 ``N < K`` 。 ``N`` 个副本意味着每个通道都会将它的数据备份到 ``N`` 个 broker。 这些是一个通道 ISR 集合的备份。就像我们在上边提到的 ``min.insync.replicas section`` 不是所有的节点一直都是可用的。``N`` 的值要设置的小于 ``K`` ，因为当少于 ``N`` 个 broker 运行的时候就不能创建通道了。所以，如果你设置为 ``N = K`` ，那么只要有一个 broker 宕机了，就意味着区块链网络就不能创建通道了，也就是说排序服务的崩溃容错就不存在了。

     基于我们上边所说的， ``M`` 和 ``N`` 的最小值分别为2和3。这样的配置可以保证新通道的创建，并且所有的通道都持续可写。``message.max.bytes`` 和 ``replica.fetch.max.bytes`` 的值应该设 ``A`` 的值大，在上边你在 ``Orderer.AbsoluteMaxBytes`` 中将 ``A`` 的值设为了4。再为头部数据增加一些空间（多余 1 MiB 就够了）。以下条件适用：

     ::

         Orderer.AbsoluteMaxBytes < replica.fetch.max.bytes <= message.max.bytes

      （为了完备性的考虑，我们要求 ``message.max.bytes`` 的值小于 ``socket.request.max.bytes`` ， ``socket.request.max.bytes`` 的默认值是 100 MiB。如果你希望区块容量大于100 MiB，你需要修改源码 ``fabric/orderer/kafka/config.go`` 中 ``brokerConfig.Producer.MaxMessageBytes`` 的值，然后重新编译。不建议这样的操作。）

7. Orderers： **将每一个 OSN 指向创世区块。** 编辑 ``orderer.yaml`` 中的 ``General.GenesisFile`` 来指定 Orderer 指向步骤5中创建的创世区块。（同时，要确保 YAML 文件中的其他键合理的配置。）

8. Orderers： **调整轮询间隔和超时。** （可选步骤。）


   * ``orderer.yaml`` 文件中的 ``Kafka.Retry`` 部分可以让你调整 metadata/producer/consumer 请求的频率和 socket 超时时间。（这里有你希望看到的 Kafka 生产者和消费者的全部信息。）

   * 另外，当创建一个新通道时，或者重新加载一个存在的通道时（比如重启一个排序节点），排序节点和 Kafka 集群的交互过程如下：

      * 排序节点为该通道相关的 Kafka 分区创建一个 Kafka 生产者（写入者）。
      * 排序节点使用生产者向分区发送一个无操作的 ``CONNECT`` 消息。 
      * 排序节点为分区创建一个 Kafka 消费者（读取者）。

      * 即使任意一个步骤失败了，你也可以通过调整重试的频率重复上边的步骤。他们将会每隔 ``Kafka.Retry.ShortInterval`` 所设置的时间进行 ``Kafka.Retry.ShortTotal`` 次尝试，和每隔 ``Kafka.Retry.LongInterval`` 所设置的时间进行 ``Kafka.Retry.LongTotal`` 次尝试，直到成功为止。注意，排序节点只有在上述步骤成功完成后才可以进行读写。

9. **设置 OSN 和 Kafka 之间的 SSL 通信。** （可选步骤，但是强烈建议。）参考 `the Confluent guide <https://docs.confluent.io/2.0.0/kafka/ssl.html>`_ 配置 Kafka 集群的设置，然后在每一个相关的 OSN 中设置 ``orderer.yaml`` 中 ``Kafka.TLS`` 的键值。

10. **以如下顺序启动节点：ZooKeeper 集群，Kafka 集群，排序服务节点。**

其他注意事项
-------------------------

1. **首选消息容量。** 在上边第4步中（查看 `Steps`_ 部分）你可以通过设置 ``Orderer.Batchsize.PreferredMaxBytes`` 来设定默认区块大小。Kafka 对于相对较小的消息有较高的吞吐量；所以该值不要大于1 MiB。

2. **使用环境变量覆盖设置。** 当使用 Fabric 提供的示例 Kafka 和 ZooKeeper Docker 镜像时（请查看 ``images/kafka`` 和 ``images/zookeeper`` 相关信息），你可以通过环境变量来覆盖 Kafka broker 或者 ZooKeeper 服务器的设置。将配置文件中的点替换为下划线，例如 ``KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false`` 将覆盖 ``unclean.leader.election.enable`` 的值。这将和 OSN *本地* 配置文件的效果是一样的，例如在 ``orderer.yaml`` 中的设置。例如 ``ORDERER_KAFKA_RETRY_SHORTINTERVAL=1s`` 将覆盖 ``Orderer.Kafka.Retry.ShortInterval`` 所设置的值。

Kafka 协议版本兼容性
=======
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

   #. ``default.replication.factor = N`` — 这里的值 ``N`` 设为 ``N < K`` 。 ``N`` 个副本意味
      着每个通道都会将它的数据备份到 ``N`` 个 broker。 这些是一个通道 ISR 集合的备份。就像我
      们在上边提到的 ``min.insync.replicas section`` 不是所有的节点一直都是可用的。 ``N`` 的
      值要设置的小于 ``K`` ，因为当少于 ``N`` 个 broker 运行的时候就不能创建通道了。所以，如
      果你设置为 ``N = K`` ，那么只要有一个 broker 宕机了，就意味着区块链网络就不能创建通道了，
      也就是说排序服务的崩溃容错就不存在了。

      Based on what we've described above, the minimum allowed values for ``M`` and ``N`` are 2 and 3 respectively. This configuration allows for the creation of new channels to go forward, and for all channels to continue to be writeable.

      基于我们上边所说的， ``M`` 和 ``N`` 的最小值分别为 2 和 3。这样的配置可以保证新通道的创
      建，并且所有的通道都持续可写。

   #. ``message.max.bytes`` and ``replica.fetch.max.bytes`` should be set to a value larger than ``A``, the value you picked in ``Orderer.AbsoluteMaxBytes`` in Step 4 above. Add some buffer to account for headers — 1 MiB is more than enough. The following condition applies:

   #. ``message.max.bytes`` 和 ``replica.fetch.max.bytes`` 的值应该设置的比 ``A`` 的值大，在上
      边你在 ``Orderer.AbsoluteMaxBytes`` 中将 ``A`` 的值设为了 4。再为头部数据增加一些空间 —— 
      多余 1 MiB 就够了。一下条件适用：

      ::

         Orderer.AbsoluteMaxBytes < replica.fetch.max.bytes <= message.max.bytes

      (For completeness, we note that ``message.max.bytes`` should be strictly smaller to ``socket.request.max.bytes`` which is set by default to 100 MiB. If you wish to have blocks larger than 100 MiB you will need to edit the hard-coded value in ``brokerConfig.Producer.MaxMessageBytes`` in ``fabric/orderer/kafka/config.go`` and rebuild the binary from source. This is not advisable.)

      （为了完备性的考虑，我们要求 ``message.max.bytes`` 的值小于 ``socket.request.max.bytes`` ， 
      ``socket.request.max.bytes`` 的默认值是 100 MiB。如果你希望区块容量大于 100 MiB，你需要修改
      源码 ``fabric/orderer/kafka/config.go`` 中 ``brokerConfig.Producer.MaxMessageBytes`` 的值，
      然后重新编译。不建议这样的操作。）

   #. ``log.retention.ms = -1``. Until the ordering service adds support for pruning of the Kafka logs, you should disable time-based retention and prevent segments from expiring. (Size-based retention —see ``log.retention.bytes``— is disabled by default in Kafka at the time of this writing, so there's no need to set it explicitly.)

   #. ``log.retention.ms = -1`` 。除非排序服务增加了对清除 Kafka 日志的支持，否则你应该取消 Kafka 
      日志基于时间的保留以阻止段失效。（基于容量的保存 —— 请查看 ``log.retention.bytes`` —— 在写这
      边文档的时候 Kafka 默认是取消的，所以不需要明确地设置。）

#. Orderers: **Point each OSN to the genesis block.** Edit ``General.GenesisFile`` in ``orderer.yaml`` so that it points to the genesis block created in Step 5 above. (While at it, ensure all other keys in that YAML file are set appropriately.)

#. Orderers： **将每一个 OSN 指向创世区块。** 编辑 ``orderer.yaml`` 中的 ``General.GenesisFile`` 来
   指定 Orderer 指向步骤 5 中创建的创世区块。（同时，要确保 YAML 文件中的其他键合理的配置。）

#. Orderers: **Adjust polling intervals and timeouts.** (Optional step.)

#. Orderers： **调整轮询间隔和超时。** （可选步骤。）

   #. The ``Kafka.Retry`` section in the ``orderer.yaml`` file allows you to adjust the frequency of the metadata/producer/consumer requests, as well as the socket timeouts. (These are all settings you would expect to see in a Kafka producer or consumer.)

   #. ``orderer.yaml`` 文件中的 ``Kafka.Retry`` 部分可以让你调整 metadata/producer/consumer 请
      求的频率和 socket 超时时间。（这里有你希望看到的 Kafka 生产者和消费者的全部信息。）

   #. Additionally, when a new channel is created, or when an existing channel is reloaded (in case of a just-restarted orderer), the orderer interacts with the Kafka cluster in the following ways:

   #. 另外，当创建一个新通道时，或者重新加载一个存在的通道时（比如重启一个排序节点），排序节点
      和 Kafka 集群的交互过程如下：

      #. It creates a Kafka producer (writer) for the Kafka partition that corresponds to the channel.

      #. 排序节点为该通道相关的 Kafka 分区创建一个 Kafka 生产者（写入者）。

      #. It uses that producer to post a no-op ``CONNECT`` message to that partition.

      #. 排序节点使用生产者向分区发送一个无操作的 ``CONNECT`` 消息。 

      #. It creates a Kafka consumer (reader) for that partition.

      #. 排序节点为分区创建一个 Kafka 消费者（读取者）。

      If any of these steps fail, you can adjust the frequency with which they are repeated. Specifically they will be re-attempted every ``Kafka.Retry.ShortInterval`` for a total of ``Kafka.Retry.ShortTotal``, and then every ``Kafka.Retry.LongInterval`` for a total of ``Kafka.Retry.LongTotal`` until they succeed. Note that the orderer will be unable to write to or read from a channel until all of the steps above have been completed successfully.

      即使任意一个步骤失败了，你也可以通过调整重试的频率重复上边的步骤。他们将会每隔 ``Kafka.Retry.ShortInterval`` 
      所设置的时间进行 ``Kafka.Retry.ShortTotal`` 次尝试，和每隔 ``Kafka.Retry.LongInterval`` 
      所设置的时间进行 ``Kafka.Retry.LongTotal`` 次尝试，直到成功为止。注意，排序节点只有在上
      述步骤成功完成后才可以进行读写。

#. **Set up the OSNs and Kafka cluster so that they communicate over SSL.** (Optional step, but highly recommended.) Refer to `the Confluent guide <https://docs.confluent.io/2.0.0/kafka/ssl.html>`_ for the Kafka cluster side of the equation, and set the keys under ``Kafka.TLS`` in ``orderer.yaml`` on every OSN accordingly.

#. **设置 OSN 和 Kafka 之间的 SSL 通信。** （可选步骤，但是强烈建议。）参考 `the Confluent guide <https://docs.confluent.io/2.0.0/kafka/ssl.html>`_ 
   配置 Kafka 集群的设置，然后在每一个相关的 OSN 中设置 ``orderer.yaml`` 中 ``Kafka.TLS`` 的键值。

#. **Bring up the nodes in the following order: ZooKeeper ensemble, Kafka cluster, ordering service nodes.**

#. **以如下顺序启动节点：ZooKeeper 集群，Kafka 集群，排序服务节点。**

Additional considerations - 其他注意事项
-------------------------

#. **Preferred message size.** In Step 4 above (see `Steps`_ section) you can also set the preferred size of blocks by setting the ``Orderer.Batchsize.PreferredMaxBytes`` key. Kafka offers higher throughput when dealing with relatively small messages; aim for a value no bigger than 1 MiB.

#. **首选消息容量。** 在上边第 4 步中（查看 `Steps`_ 部分）你可以通过设置 ``Orderer.Batchsize.PreferredMaxBytes`` 
   来设定默认区块大小。 Kafka 对于相对较小的消息有较高的吞吐量；所以该值不要大于 1 MiB。

#. **Using environment variables to override settings.** When using the sample Kafka and Zookeeper Docker images provided with Fabric (see ``images/kafka`` and ``images/zookeeper`` respectively), you can override a Kafka broker or a ZooKeeper server's settings by using environment variables. Replace the dots of the configuration key with underscores — e.g. ``KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false`` will allow you to override the default value of ``unclean.leader.election.enable``. The same applies to the OSNs for their *local* configuration, i.e. what can be set in ``orderer.yaml``. For example ``ORDERER_KAFKA_RETRY_SHORTINTERVAL=1s`` allows you to override the default value for ``Orderer.Kafka.Retry.ShortInterval``.

#. **使用环境变量覆盖设置。** 当使用 Fabric 提供的示例 Kafka 和 ZooKeeper Docker 镜像时（请查看 
   ``images/kafka`` 和 ``images/zookeeper`` 相关信息），你可以通过环境变量来覆盖 Kafka broker 或
   者 ZooKeeper 服务器的设置。将配置文件中的点替换为下划线 —— 例如 ``KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false`` 
   将覆盖 ``unclean.leader.election.enable`` 的值。这将和 OSN *本地* 配置文件的效果是一样的，例如
   在 ``orderer.yaml`` 中的设置。例如 ``ORDERER_KAFKA_RETRY_SHORTINTERVAL=1s`` 将覆盖 ``Orderer.Kafka.Retry.ShortInterval`` 
   所设置的值。

Kafka Protocol Version Compatibility - Kafka 协议版本兼容性
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
------------------------------------

Fabric 使用 `sarama client library <https://github.com/Shopify/sarama>`_ 支持 Kafka 0.10 到 1.0 的版本，同样还支持较老的版本。

<<<<<<< HEAD
使用 ``orderer.yaml`` 中的 ``Kafka.Version`` 键，你可以配置你使用哪个 Kafka 协议版本和 Kafka 集群的 brokers 通信。使用老协议版本的 Kafka 代理向后兼容。因为 Kafka 代理对老协议版本的向后兼容性，升级你的 Kafka 代理版本时不需要升级 ``Kafka.Version`` 的键值，但是 Kafka 集群使用老协议版本可能会出现 `性能损失 <https://kafka.apache.org/documentation/#upgrade_11_message_format>`_ 。

调试
=======
Fabric 使用 `sarama client library <https://github.com/Shopify/sarama>`_ 支持 Kafka 0.10 到 1.0 的
版本，同样还支持较老的版本。

Using the ``Kafka.Version`` key in ``orderer.yaml``, you can configure which version of the Kafka protocol is used to communicate with the Kafka cluster's brokers. Kafka brokers are backward compatible with older protocol versions. Because of a Kafka broker's backward compatibility with older protocol versions, upgrading your Kafka brokers to a new version does not require an update of the ``Kafka.Version`` key value, but the Kafka cluster might suffer a `performance penalty <https://kafka.apache.org/documentation/#upgrade_11_message_format>`_ while using an older protocol version.

使用 ``orderer.yaml`` 中的 ``Kafka.Version`` 键，你可以配置你使用哪个 Kafka 协议版本和 Kafka 集群
的 brokers 通信。使用老协议版本的 Kafka 代理向后兼容。因为 Kafka 代理对老协议版本的向后兼容性，升
级你的 Kafka 代理版本时不需要升级 ``Kafka.Version`` 的键值，但是 Kafka 集群使用老协议版本可能会出
现 `性能损失 <https://kafka.apache.org/documentation/#upgrade_11_message_format>`_ 。

Debugging - 调试
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
---------

将环境变量 ``FABRIC_LOGGING_SPEC`` 设置为 ``DEBUG`` 和 ``orderer.yaml`` 中的  `Kafka.Verbose`` 设置为 ``true`` 。

将环境变量 ``FABRIC_LOGGING_SPEC`` 设置为 ``DEBUG`` 和 ``orderer.yaml`` 中的 ``Kafka.Verbose`` 设置为 ``true`` 。

.. Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/
