What's new in v1.4 - v1.4中的新功能
==================

Hyperledger Fabric has matured since the initial v1.0 release, and so has the
community of Fabric operators and developers. The Fabric developers have been
working with network operators and application developers to deliver v1.4 with
a focus on production operations and developer ease of use. The two major
release themes for Hyperledger Fabric v1.4 revolve around these two areas:

Hyperledger Fabric从最初的v1.0发布开始就已经成熟了，Fabric维护人员和开发人员也是如此。Fabric开发人员一直与网络维护人员以及应用程序开发人员合作实现v1.4版本，该版本重点关注生产维护人员和开发人员的易用性。 Hyperledger Fabric v1.4的两个主要发布主题围绕下面这两个方面：

* **Serviceability and Operations**: As more Hyperledger Fabric networks get
  deployed and enter a production state, serviceability and operational aspects
  are critical. Fabric v1.4 takes a giant leap forward with logging improvements,
  health checks, and operational metrics. Along with a focus on stability
  and fixes, Fabric v1.4 is the recommended release for production operations.
  Future fixes will be delivered on the v1.4.x stream, while new features are
  being developed in the v2.0 stream.

* **可维护性和操作**：随着更多Hyperledger Fabric网络的部署并进入生产状态，可维护性和操作方面是至关重要的。 Fabric v1.4通过改进日志记录，添加运行状况检查和运营指标等实现了巨大飞跃。 除了关注稳定性和修复，Fabric v1.4是生产运作的推荐版本。 未来的修复问题将在v1.4.x系列版本上发布，而v2.0系列版本中正在开发新功能。

* **Improved programming model for developing applications**: Writing
  decentralized applications has just gotten easier. Programming model
  improvements in the Node.js SDK and Node.js chaincode makes the development
  of decentralized applications more intuitive, allowing you to focus
  on your application logic. The existing npm packages are still available for
  use, while the new npm packages provide a layer of abstraction to improve
  developer productivity and ease of use.

* **改进开发应用程序编程模型**：编写去中心化应用程序变得更加容易。 Node.js SDK和Node.js链码中的编程模型改进使得去中心化应用程序的开发更加直观，使您可以专注于应用程序逻辑。 现有的npm软件包仍可供使用，而新的npm软件包提供了一层抽象，以提高开发人员的工作效率和易用性。

Serviceability and operations improvements - 可维护性和操作改进
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

* :doc:`操作服务`:
  新的RESTful操作服务为操作人员提供三种服务来监控和管理peer节点和orderer节点：

  * 日志接口 ``/logspec`` 允许操作员动态获取和peer节点和orderer节点的日志级别。

  * ``/healthz`` 接口允许操作人员和容器编排服务检查peer节点和orderer节点的活跃度和健康状态。

  * ``/metrics`` 接口允许操作人员利用Prometheus从peer节点和orderer节点拉取运营指标。 指标也可以推送到StatsD。

Improved programming model for developing applications
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

Release notes
=============

The release notes provide more details for users moving to the new release, along
with a link to the full release change log.

* `Fabric release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_.
* `Fabric CA release notes <https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.0>`_.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
