What's new in v1.4 - v1.4中的新功能
==================

Hyperledger Fabric has matured since the initial v1.0 release, and so has the
community of Fabric operators and developers. The Fabric developers have been
working with network operators and application developers to deliver v1.4 with
a focus on production operations and developer ease of use. The two major
release themes for Hyperledger Fabric v1.4 revolve around these two areas:

Hyperledger Fabric从最初的v1.0发布开始就已经成熟了，Fabric运维人员和开发人员也是如此。Fabric开发人员一直与网络运维人员以及应用程序开发人员合作实现v1.4版本，该版本重点关注生产运维和开发人员的易用性。Hyperledger Fabric v1.4的两个主要发布主题围绕下面这两个方面：

* **Serviceability and Operations**: As more Hyperledger Fabric networks get
  deployed and enter a production state, serviceability and operational aspects
  are critical. Fabric v1.4 takes a giant leap forward with logging improvements,
  health checks, and operational metrics. Along with a focus on stability
  and fixes, Fabric v1.4 is the recommended release for production operations.
  Future fixes will be delivered on the v1.4.x stream, while new features are
  being developed in the v2.0 stream.

* **可维护性和运维**：随着更多Hyperledger Fabric网络的部署并进入生产状态，可维护性和运维方面是至关重要的。 Fabric v1.4通过改进日志记录，添加运行状况检查和运维指标等实现了巨大飞跃。除了聚焦稳定性和问题修复，同时Fabric v1.4是生产运作的推荐版本。 未来修复的问题将在v1.4.x系列版本上发布，而v2.0系列版本中正在开发新功能。

* **Improved programming model for developing applications**: Writing
  decentralized applications has just gotten easier. Programming model
  improvements in the Node.js SDK and Node.js chaincode makes the development
  of decentralized applications more intuitive, allowing you to focus
  on your application logic. The existing npm packages are still available for
  use, while the new npm packages provide a layer of abstraction to improve
  developer productivity and ease of use.

* **改进开发应用程序编程模型**：编写去中心化应用程序变得更加容易。 Node.js SDK和Node.js链码中的编程模型改进使得去中心化应用程序的开发更加直观，使您可以专注于应用程序逻辑。 现有的npm软件包仍可供使用，而新的npm软件包提供了一层抽象，以提高开发人员的工作效率和易用性。

Serviceability and operations improvements - 可维护性和运维改进
------------------------------------------

* :doc:`operations_service`:
  The new RESTful operations service provides operators with three
  services to monitor and manage peer and orderer node operations:

  * The logging ``/logspec`` endpoint allows operators to dynamically get and set
    logging levels for the peer and orderer nodes.

  * The ``/healthz`` endpoint allows operators and container orchestration services to
    check peer and orderer node liveness and health.

  * The ``/metrics`` endpoint allows operators to utilize Prometheus to pull operational
    metrics from peer and orderer nodes. Metrics can also be pushed to StatsD.


* :doc:`运维服务`:
  新的RESTful运维服务为运维人员提供三种服务来监控和管理peer节点和orderer节点：

  * 日志接口 ``/logspec`` 允许操作员动态获取和peer节点和orderer节点的日志级别。

  * ``/healthz`` 接口允许操作人员和容器编排服务检查peer节点和orderer节点的活跃度和健康状态。

  * ``/metrics`` 接口允许操作人员利用Prometheus从peer节点和orderer节点拉取运维指标。 指标也可以推送到StatsD。

Improved programming model for developing applications - 改进开发应用程序的编程模型
------------------------------------------------------

The new Node.js SDK and chaincode programming model makes developing decentralized
applications easier and improves developer productivity. New documentation helps you
understand the various aspects of creating a decentralized application for
Hyperledger Fabric, using a commercial paper business network scenario.

* :doc:`developapps/scenario`:
  Describes a hypothetical business network involving six organizations who want
  to build an application to transact together that will serve as a use case
  to describe the programming model.

* :doc:`developapps/analysis`:
  Describes the structure of a commercial paper and how transactions affect it
  over time. Demonstrates that modeling using states and transactions
  provides a precise way to understand and model the decentralized business process.

* :doc:`developapps/architecture`:
  Shows how to design the commercial paper processes and their related data
  structures.

* :doc:`developapps/smartcontract`:
  Shows how a smart contract governing the decentralized business process of
  issuing, buying and redeeming commercial paper should be designed.

* :doc:`developapps/application`
  Conceptually describes a client application that would leverage the smart contract
  described in :doc:`developapps/smartcontract`.

* :doc:`developapps/designelements`:
  Describes the details around contract namespaces, transaction context,
  transaction handlers, connection profiles, connection options, wallets, and
  gateways.

And finally, a tutorial and sample that brings the commercial paper scenario to life:

* :doc:`tutorial/commercial_paper`

新的Node.js SDK和链码编程模型使开发去中心化应用程序更加容易，同时提交开发人员生产效率。新的文档通过使用商业票据网络场景帮助您理解创建Hyperledger Fabric去中心化应用的各方面。

* :doc:`场景`：
  假设一个包括六个组织的业务网络，这些组织他们希望构建一个应用程序进行交易，使用这个案例来描述编程模型。

* :doc:`分析`：
  描述了商业票据的结构以及交易如何影响它。 证明使用状态和事务进行建模提供了一种精确的方法来理解和模型化去中心化的业务流程。

* :doc:`流程和数据设计`：
  展示了怎样设计商业票据流程以及它们相关的数据结构。

* :doc:`智能合约处理`：
  展示了如何设计一个用来管理发行、购买和赎回商业票据的去中心化业务流程的智能合约。

* :doc:`应用程序`：
  从概念上描述了一个客户端应用程序，该应用程序将利用以下所述的智能合约:doc:`智能合约处理`。

* :doc:`应用程序元素设计`:
  描述围绕着合约命名空间、交易上下文、交易处理程序、连接配置文件、连接选项、钱包和网关等的具体内容。

最后，一个商业票据现实场景的教程和样例：
* :doc:`商业票据教程`


New tutorials
-------------

* :doc:`write_first_app`:
  This tutorial has been updated to leverage the improved Node.js SDK and chaincode
  programming model. The tutorial has both JavaScript and Typescript examples of
  the client application and chaincode.

* :doc:`tutorial/commercial_paper`
  As mentioned above, this is the tutorial that accompanies the new Developing
  Applications documentation.

* :doc:`upgrade_to_newest_version`:
  Leverages the network from :doc:`build_network` to demonstrate an upgrade from
  v1.3 to v1.4. Includes both a script (which can serve as a template for upgrades),
  as well as the individual commands so that you can understand every step of an
  upgrade.

新教程
-------------

* :doc:`编写您的第一个应用程序`：
  本教程已更新，以利用改进的Node.js SDK和链码编程模型。本教程包含JavaScript和Typescript对应的客户端应用程序和链码的示例。

* :doc:`商业票据教程`：
  如上所述，这是新开发应用程序文档附带的教程。

* :doc:`升级到最新版本Fabric`：
  利用基于教程:doc:`构建网络`中的网络来演示从v1.3到v1.4的升级。 包括脚本（可用作升级模板）以及各个命令，以便您可以了解升级的每个步骤。

Private data enhancements
-------------------------

* :doc:`private-data-arch`:
  The Private data feature has been a part of Fabric since v1.2, and this release
  debuts two new enhancements:

  * **Reconciliation**, which allows peers for organizations that are added
    to private data collections to retrieve the private data for prior
    transactions to which they now are entitled.

  * **Client access control** to automatically enforce access control within
    chaincode based on the client organization collection membership without having
    to write specific chaincode logic.

Private data enhancements - 私有数据加强
-------------------------

* :doc:`私有数据`:
  私有数据功能自从v1.2开始成为Fabric的一部分，此版本推出了两个新的增强功能：

  * **协调**, 允许添加了私有数据集合的组织peer节点获取其现在有权使用的先前交易的私有数据。

  * **客户端访问控制**， 可根据客户端组织集合成员资格在链码中自动实施访问控制，而无需编写特定的链码逻辑。

Release notes - 发行说明
=============

The release notes provide more details for users moving to the new release, along
with a link to the full release change log.

* `Fabric release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_.
* `Fabric CA release notes <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.0>`_.

发行说明为迁移到新版本的用户提供了更多详细信息，以及指向完整版本变更日志的链接。

* `Fabric 发行说明 <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_.
* `Fabric CA 发行说明 <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.0>`_.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
