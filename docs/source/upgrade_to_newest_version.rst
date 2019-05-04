Upgrading to the Newest Version of Fabric - 升级到最新版 Fabric
=========================================

At a high level, upgrading a Fabric network from v1.3 to v1.4 can be performed
by following these steps:

总的来说，将 Fabric 网络从 v1.3 升级到 v1.4 有如下步骤：

 * Upgrade the binaries for the ordering service, the Fabric CA, and the peers.
   These upgrades may be done in parallel.
 * 更新排序服务、 Fabric CA 、和 peer 的二进制文件。这些可以并行完成。
 * Upgrade client SDKs.
 * 升级 SDK 客户端。
 * (Optional) Upgrade the Kafka cluster.
 * （可选）升级 Kafka 集群

To help understand this process, we've created the :doc:`upgrading_your_network_tutorial`
tutorial that will take you through most of the major upgrade steps, including
upgrading peers and orderers. We've included both a
script as well as the individual steps to achieve these upgrades.

为了帮助你理解这个过程，我们编写了 :doc:`upgrading_your_network_tutorial` 教程来
带你体验主要的升级步骤，包括升级 peer 节点和排序节点。为了达到升级的目的，文档中
包含了脚本和单独的步骤。

Because our tutorial leverages the :doc:`build_network` (BYFN) sample, it has
certain limitations (it does not use Fabric CA, for example). Therefore we have
included a section at the end of the tutorial that will show how to upgrade
your CA, Kafka clusters, CouchDB, Zookeeper, vendored chaincode shims, and Node
SDK clients.

因为我们的教程依赖 :doc:`build_network` (BYFN) 示例，它确实有一些限制（比如没有使
用 Fabric CA）。所以我们在章节的最后增加了一部分内容来演示如何升级 CA、Kafka 集群、
CouchDB、Zookeeper、链码依赖和 Node SDK 客户端。

Because there are no new :doc:`capability_requirements` in v1.4, the upgrade
process does not require any channel configuration transactions.

因为在 v1.4 中没有更新 :doc:`capability_requirements` ，所以更新过程不需要通道配置
交易。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
