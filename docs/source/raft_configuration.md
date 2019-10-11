# 配置并使用 Raft 排序服务

**受众**： *Raft 排序节点管理员*

## 概述

有关排序概念的整体概述以及排序服务（包括 Raft）是如何工作的，请查看我们关于[排序服务](./orderer/ordering_service.html)的概念文档。

要了解设置排序节点的过程（包括创建本地 MSP 和创建初始区块），请查看我们关于[设置排序节点的文档](orderer_deploy.html)。

## 配置

虽然必须将每个 Raft 节点添加到系统通道，但不需要将节点添加到每个应用程序通道。此外，您可以动态地从通道中删除和添加节点，而不会影响其他节点，下面的重新配置部分中描述了该过程。

Raft 节点使用 TLS pinning 技术互相识别，因此要假冒 Raft 节点，攻击者需要获取其 TLS 证书的私钥。所以如果没有有效的 TLS 配置，就无法运行 Raft 节点。

Raft 集群要在两个部分进行配置：

* **本地配置**：主要用于配置节点控制方面，如 TLS 通信、复制行为和文件存储。

* **通道配置**：定义相应通道的 Raft 集群成员，以及协议指定的参数，如心跳频率、领导节点超时等。

回想一下，每个通道都有自己的 Raft 协议实例运行。因此，必须在其所属的每个通道的配置中引用 Raft 节点，方法是将其服务器和客户端 TLS 证书（以 `PEM` 格式）添加到通道配置中。这确保了当其他节点接收到该节点的消息时，它们可以安全地确认发送消息的节点的身份。

下边是 `configtx.yaml` 中的一部分内容，展示了通道中三个 Raft 节点（也就是所谓的“共识者”）的配置：

```
       Consenters:
            - Host: raft0.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert0
              ServerTLSCert: path/to/ServerTLSCert0
            - Host: raft1.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert1
              ServerTLSCert: path/to/ServerTLSCert1
            - Host: raft2.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert2
              ServerTLSCert: path/to/ServerTLSCert2
```

注意：排序节点将被列为系统通道以及他们加入的任何应用程序通道的共识者。

当创建通道配置区块时，configtxgen 工具读取到 TLS 证书的路径，并将路径替换为相应的证书。

### 本地配置

`orderer.yaml` 中有两个部分和 Raft 排序节点的配置有关：

**Cluster**，决定了 TLS 通信的配置。和 **consensus**，决定了日志头和快照的存储位置。

**集群参数：**

默认情况下，Raft 服务与面向客户端的服务器（用于发送事务或拉取区块）运行在同一个 gRPC 服务器上，但它可以配置为单独的具有独立端口的 gRPC 服务器。

这对于希望组织 CA 颁发的 TLS 证书仅用于群集节点的相互通信，而公共 TLS CA 颁发的 TLS 证书用于面向客户端的 API 的情况是非常有用的。

* `ClientCertificate`, `ClientPrivateKey`：客户端 TLS 证书和相关私钥的文件路径。

* `ListenPort`：集群监听的端口。如果为空，该端口就和排序节点通用端口（general.listenPort）一致 。

* `ListenAddress`：集群服务监听的地址。

* `ServerCertificate`, `ServerPrivateKey`：TLS 服务器证书密钥对，当集群服务运行在单独的 gRPC 服务器（不同端口）上时使用。

* `SendBufferSize`：调节出口缓冲区中的消息数。

注意： `ListenPort`、`ListenAddress`、`ServerCertificate` 和 `ServerPrivateKey` 必须同时 或都不设置，如果没有设置它们，它们就会从 general TLS 部分继承，例如 `general.tls.{privateKey, certificate}`。

`general.cluster` 还有隐藏的配置参数，可用于进一步微调集群通信或复制机制：

* `DialTimeout`, `RPCTimeout`：指定创建连接和建立流的超时时间。

* `ReplicationBufferSize`：可以为从其他群集节点进行块复制的每个内存缓冲区分配的最大字节数。每个通道都有自己的内存缓冲区。默认为20971520，即20 MB。

* `PullTimeout`：排序节点等待接收区块的最长时间。默认为五秒。

* `ReplicationBackgroundRefreshInterval`：节点连续两次尝试复制其加入的通道，或无法复制通道的时间。默认为五分钟。

**共识参数：**

* `WALDir`：日志头为 `etcd/raft` 的日志的保存位置。每个通道都会有以通道 ID 为名的子目录。

* `SnapDir`：指定 `etcd/raft` 快照的存储位置。每个通道都会有以通道 ID 为名的子目录。

   还有一个隐藏配置参数可以加入到 `orderer.yaml` 的共识部分：

* `EvictionSuspicion`：通道驱逐嫌疑节点的时间，这会触发节点从其他节点拉取区块并查看它是否被通道驱逐以此来确认它的嫌疑。如果确认了它的嫌疑（被检查的区块没有包含节点 TLS 证书），该节点将终止对通道的操作。当一个节点不知道任何被选举的领导节点或者不能被选举为该通道中的领导节点时，它就有可能是被通道逐出了。默认十分钟。

### 通道配置

处理共识者（已经讨论过）之外，Raft 通道配置中还有一个 `Options` 部分和协议有关。目前，在节点运行的时候不能修改这些值。只能重新修改配置并重启节点。

只有 `SnapshotIntervalSize` 是例外，它可以在节点运行的时候修改。

注意：建议不要下边的这些配置，错误的配置可能会导致领导节点选举失败（比如，`TickInterval` 和 `ElectionTick` 设置的过小）。不能选举领导节点的情况是无法解决的，因为领导节点是动态改变的。由于这些危险，我们建议一般不要调整这些参数。

  * `TickInterval`: The time interval between two `Node.Tick` invocations.
  * `ElectionTick`: The number of `Node.Tick` invocations that must pass between
  elections. That is, if a follower does not receive any message from the leader
  of current term before `ElectionTick` has elapsed, it will become candidate
  and start an election.
  * `ElectionTick` must be greater than `HeartbeatTick`.
  * `HeartbeatTick`: The number of `Node.Tick` invocations that must pass between
  heartbeats. That is, a leader sends heartbeat messages to maintain its
  leadership every `HeartbeatTick` ticks.
  * `MaxInflightBlocks`: Limits the max number of in-flight append blocks during
  optimistic replication phase.
  * `SnapshotIntervalSize`: Defines number of bytes per which a snapshot is taken.

## Reconfiguration

The Raft orderer supports dynamic (meaning, while the channel is being serviced)
addition and removal of nodes as long as only one node is added or removed at a
time. Note that your cluster must be operational and able to achieve consensus
before you attempt to reconfigure it. For instance, if you have three nodes, and
two nodes fail, you will not be able to reconfigure your cluster to remove those
nodes. Similarly, if you have one failed node in a channel with three nodes, you
should not attempt to rotate a certificate, as this would induce a second fault.
As a rule, you should never attempt any configuration changes to the Raft
consenters, such as adding or removing a consenter, or rotating a consenter's
certificate unless all consenters are online and healthy.

If you do decide to change these parameters, it is recommended to only attempt
such a change during a maintenance cycle. Problems are most likely to occur when
a configuration is attempted in clusters with only a few nodes while a node is
down. For example, if you have three nodes in your consenter set and one of them
is down, it means you have two out of three nodes alive. If you extend the cluster
to four nodes while in this state, you will have only two out of four nodes alive,
which is not a quorum. The fourth node won't be able to onboard because nodes can
only onboard to functioning clusters (unless the total size of the cluster is
one or two).

So by extending a cluster of three nodes to four nodes (while only two are
alive) you are effectively stuck until the original offline node is resurrected.

Adding a new node to a Raft cluster is done by:

  1. **Adding the TLS certificates** of the new node to the channel through a
  channel configuration update transaction. Note: the new node must be added to
  the system channel before being added to one or more application channels.
  2. **Fetching the latest config block** of the system channel from an orderer node
  that's part of the system channel.
  3. **Ensuring that the node that will be added is part of the system channel**
  by checking that the config block that was fetched includes the certificate of
  (soon to be) added node.
  4. **Starting the new Raft node** with the path to the config block in the
  `General.GenesisFile` configuration parameter.
  5. **Waiting for the Raft node to replicate the blocks** from existing nodes for
  all channels its certificates have been added to. After this step has been
  completed, the node begins servicing the channel.
  6. **Adding the endpoint** of the newly added Raft node to the channel
  configuration of all channels.

It is possible to add a node that is already running (and participates in some
channels already) to a channel while the node itself is running. To do this, simply
add the node’s certificate to the channel config of the channel. The node will
autonomously detect its addition to the new channel (the default value here is
five minutes, but if you want the node to detect the new channel more quickly,
reboot the node) and will pull the channel blocks from an orderer in the
channel, and then start the Raft instance for that chain.

After it has successfully done so, the channel configuration can be updated to
include the endpoint of the new Raft orderer.

Removing a node from a Raft cluster is done by:

  1. Removing its endpoint from the channel config for all channels, including
  the system channel controlled by the orderer admins.
  2. Removing its entry (identified by its certificates) from the channel
  configuration for all channels. Again, this includes the system channel.
  3. Shut down the node.

Removing a node from a specific channel, but keeping it servicing other channels
is done by:

  1. Removing its endpoint from the channel config for the channel.
  2. Removing its entry (identified by its certificates) from the channel
  configuration.
  3. The second phase causes:
     * The remaining orderer nodes in the channel to cease communicating with
     the removed orderer node in the context of the removed channel. They might
     still be communicating on other channels.
     * The node that is removed from the channel would autonomously detect its
     removal either immediately or after `EvictionSuspicion` time has passed
     (10 minutes by default) and will shut down its Raft instance.

### TLS certificate rotation for an orderer node

All TLS certificates have an expiration date that is determined by the issuer.
These expiration dates can range from 10 years from the date of issuance to as
little as a few months, so check with your issuer. Before the expiration date,
you will need to rotate these certificates on the node itself and every channel
the node is joined to, including the system channel.

For each channel the node participates in:

  1. Update the channel configuration with the new certificates.
  2. Replace its certificates in the file system of the node.
  3. Restart the node.

Because a node can only have a single TLS certificate key pair, the node will be
unable to service channels its new certificates have not been added to during
the update process, degrading the capacity of fault tolerance. Because of this,
**once the certificate rotation process has been started, it should be completed
as quickly as possible.**

If for some reason the rotation of the TLS certificates has started but cannot
complete in all channels, it is advised to rotate TLS certificates back to
what they were and attempt the rotation later.

## Metrics

For a description of the Operations Service and how to set it up, check out
[our documentation on the Operations Service](operations_service.html).

For a list at the metrics that are gathered by the Operations Service, check out
our [reference material on metrics](metrics_reference.html).

While the metrics you prioritize will have a lot to do with your particular use
case and configuration, there are two metrics in particular you might want to
monitor:

* `consensus_etcdraft_is_leader`: identifies which node in the cluster is
   currently leader. If no nodes have this set, you have lost quorum.
* `consensus_etcdraft_data_persist_duration`: indicates how long write operations
   to the Raft cluster's persistent write ahead log take. For protocol safety,
   messages must be persisted durably, calling `fsync` where appropriate, before
   they can be shared with the consenter set. If this value begins to climb, this
   node may not be able to participate in consensus (which could lead to a
   service interruption for this node and possibly the network).

## Troubleshooting

* The more stress you put on your nodes, the more you might have to change certain
parameters. As with any system, computer or mechanical, stress can lead to a drag
in performance. As we noted in the conceptual documentation, leader elections in
Raft are triggered when follower nodes do not receive either a "heartbeat"
messages or an "append" message that carries data from the leader for a certain
amount of time. Because Raft nodes share the same communication layer across
channels (this does not mean they share data --- they do not!), if a Raft node is
part of the consenter set in many channels, you might want to lengthen the amount
of time it takes to trigger an election to avoid inadvertent leader elections.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
