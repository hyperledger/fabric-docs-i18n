升级到最新版 Fabric
=========================================

总的来说，将 Fabric 网络从 v1.3 升级到 v1.4 有如下步骤：

 * 更新排序服务、 Fabric CA 、和 peer 的二进制文件。这些可以并行完成。
 * 升级 SDK 客户端。
 * （可选）升级 Kafka 集群

为了帮助你理解这个过程，我们编写了 :doc:`upgrading_your_network_tutorial` 教程来
带你体验主要的升级步骤，包括升级 peer 节点和排序节点。为了达到升级的目的，文档中
包含了脚本和单独的步骤。

因为我们的教程依赖 :doc:`build_network` (BYFN) 示例，它确实有一些限制（比如没有使
用 Fabric CA）。所以我们在章节的最后增加了一部分内容来演示如何升级 CA、Kafka 集群、
CouchDB、Zookeeper、链码依赖和 Node SDK 客户端。

因为在 v1.4 中没有更新 :doc:`capability_requirements` ，所以更新过程不需要通道配置
交易。


.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/