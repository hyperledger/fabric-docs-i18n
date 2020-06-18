v1.4 更新说明
==================

Hyperledger Fabric 的第一个长期支持发布版本
----------------------------------------------------

Hyperledger Fabric 从最初的v1.0发布开始就已经成熟了，Fabric 运维人员社区也是如此。Fabric 开发者和网络维护者一起合作发布了v1.4，该版本致力于稳定性和生产运营。同时，v1.4.x将是我们第一个长期支持发布版本。

我们目前的策略是为我们主要和次要版本提供 bug 修复版本，直到下一个主要或者次要版本发布。我们计划在后续的版本中继续实行这一原则。但是，对于 Hyperledger Fabric v1.4， Fabric 维护者们承诺将从发布之日起提供为期一年的 bug 修复。这将产生一系列的补丁版本（v1.4.1, v1.4.2等等），一个补丁版本会包含多个修复内容。

如果你正在使用 Hyperledger Fabric v1.4.x，你将可以安全地升级到后续的每个补丁版本中。当需要一些升级过程来修复缺陷时，我们将在补丁发布的时候提供升级步骤。

Raft 排序服务
---------------------

在 v1.4.1 中介绍过， `Raft <https://raft.github.io/raft.pdf>`_ 是一种崩溃容错（Crash Fault Tolerant，CFT）排序服务，它是 Raft 协议基于 `etcd <https://coreos.com/etcd/>`_ 的实现。Raft 使用了“领导者和跟随者”模型，领导者是（每个通道）选举出来的，他们的决定复制给跟随者。Raft 排序服务的配置和管理比基于 Kafka 的排序服务更容易，并且可以让分布在世界各地的组织为分散的排序服务贡献节点。

* :doc:`orderer/ordering_service`:
  讲解了 Fabric 中排序服务和目前三种可用的排序类型：Solo, Kafka 和 Raft。

* :doc:`raft_configuration`:
  演示了部署 Raft 排序服务时需要配置的参数和注意事项。

* :doc:`orderer_deploy`:
  讲解了部署排序节点的过程。部署排序节点并不意味着实现了排序服务。

* :doc:`build_network`:
  该教程中增加了启动一个使用 Raft 排序服务的示例网络的内容。

* :doc:`kafka_raft_migration`:
  如果你正在使用 Kafka 排序服务，这个文档演示了迁移到 Raft 的过程。v1.4.2以后可用。

可用性和可操作的改进
------------------------------------------

越来越多的 Hyperledger Fabric 网络进入了生产阶段，可用性和可操作性方便变得至关重要。 Fabric v1.4 在日志记录改进、健康检查和操作指标方面取得了巨大的进步。因此，Fabric v1.4是生产操作的推荐版本。

* :doc:`operations_service`:
  新的 RESTful 操作服务为操作者提供了三种服务来监控和管理 Peer 节点和排序节点：

  * 日志的 ``/logspec`` 可以让操作者获取和设置 Peer 节点和排序节点的日志级别。

  * ``/healthz`` 可以让操作者和容器业务流程服务检查 Peer 节点和排序节点的存活和健康状态。
  
  * ``/metrics`` 可以让操作者用 Prometheus 从 Peer 节点和排序节点拉取 Matrics（操作度量）。Matrics 也可以推送到 StatsD。

改进了应用开发编程模型
------------------------------------------------------

编写 DAPP 变得更简单了。Node.js SDK 和 Node.js 链码编程模型的改进使得 DAPP 的开发更加直观，使你能够专注于应用程序逻辑。

通过个商业票据业务网络场景的新文档帮你理解开发 Hyperledger Fabric DAPP 中的各种概念。

* :doc:`developapps/scenario`:
  以一个假设的业务网络作为案例来讲解编程模型，这个网络包含了六个组织，他们想要构建一个要一起进行交易的应用程序。

* :doc:`developapps/analysis`:
  描述了商业票据的结构和交易是如何随时间影响它的。演示了使用状态和交易进行建模，对理解和去中心化业务流程建模提供了精确的方法。

* :doc:`developapps/architecture`:
  展示了如何设计商业票据流程和相关的数据结构。

* :doc:`developapps/smartcontract`:
  展示了如何设计一个智能合约来管理去中心化业务流程中的发行、购买和赎回。

* :doc:`developapps/application`
  从概念上描述了使用 :doc:`developapps/smartcontract` 中描述的智能合约的客户端应用程序。

* :doc:`developapps/designelements`:
  描述了智能合约中命名空间、交易上下文、交易处理、连接配置、连接选项、钱包和网关的详细信息。

最后，一个教程和示例将商业票据场景带到了现实中：

* :doc:`tutorial/commercial_paper`

新教程
-------------

* :doc:`write_first_app`:
  该教程使用改进的 Node.js SDK 和链码模型进行了更新。教程中提供了 JavaScript 和 Typescript 版客户端程序和链码。
  
* :doc:`tutorial/commercial_paper`
  如上所述，这是新的应用开发文档附带的教程。

* :doc:`upgrade_to_newest_version`:
  使用 :doc:`build_network` 中的网络演示了从 v1.3 升级到 v1.4 过程。包含了脚本（可以作为升级的模板）和独立命令让你来理解升级中的每一步骤。

私有数据增强
-------------------------

* :doc:`private-data-arch`:
  从 Fabric v1.2 开始加入了私有数据特性，此版本做了两个新的增强：

  * **对账**，允许添加到私有数据集合的组织的节点为他们有权处理的先前事务检索私有数据。

  * **客户端访问控制**，根据客户端组织集合成员身份在链码内自动执行访问控制，而不必编写特定的链码逻辑。

发布说明
=============

发布说明为用户使用新版本提供更多细节，定点击下边的链接获取完整的版本变更日志。

* `Fabric v1.4.0 release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_.
* `Fabric v1.4.1 release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.1>`_.
* `Fabric v1.4.2 release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.2>`_.
* `Fabric CA v1.4.0 release notes <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.0>`_.
* `Fabric CA v1.4.1 release notes <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.1>`_.
* `Fabric CA v1.4.2 release notes <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.2>`_.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
