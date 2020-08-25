入门
===============

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install
   test_network

在我们开始之前，如果您还没有这样做，您可能希望检查您是否已经在将要开发区块链应用程序或运行 Hyperledger Fabric 的平台上安装了所有 :doc:`prereqs` 。

安装必备组件后，即可下载并安装 HyperLedger Fabric。在我们为Fabric 二进制文件开发真正的安装程序的同时，我们提供了一个脚本，可以将 :doc:`install` 到您的系统中。该脚本还将 Docker 镜像下载到本地注册表。

在你下载完 Fabric 示例以及 Docker 镜像到你本机之后，您就可以跟着 :doc:`test_network` 教程开始使用 Fabric 了。

Hyperledger Fabric 智能合约（链码） API
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric 提供了不同编程语言的 API 来支持开发智能合约（链码）。智能合约 API 可以使用 Go、Node.js 和 Java：

  * `Go 合约 API <https://github.com/hyperledger/fabric-contract-api-go>`__ 。
  * `Node.js 合约 API <https://github.com/hyperledger/fabric-chaincode-node>`__ and `Node.js 合约 API 文档 <https://hyperledger.github.io/fabric-chaincode-node/>`__ 。
  * `Java 合约 API <https://github.com/hyperledger/fabric-chaincode-java>`__ and `Java 合约 API 文档 <https://hyperledger.github.io/fabric-chaincode-java/>`__ 。

Hyperledge Fabric 应用程序 SDK
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric 提供了许多 SDK 来支持各种编程语言开发应用程序。SDK 有支持 Node.js 和 Java 语言的：

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ and `Node.js SDK 文档 <https://hyperledger.github.io/fabric-sdk-node/>`__ 。
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ and `Java SDK 文档 <https://hyperledger.github.io/fabric-gateway-java/>`__ 。

此外，还有两个尚未正式发布的 SDK（Python 和 Go），但它们仍可供下载和测试：

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

目前，Node.js、Java 和 Go 支持 Hyperledge Fabric 1.4 提供的新的应用程序编程模型。

Hyperledger Fabric CA
^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric 提供一个可选的 `证书授权服务 <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_ ，您可以选择使用该服务生成证书和密钥材料，以配置和管理区块链网络中的身份。然而，任何可以生成 ECDSA 证书的 CA 都是可以使用的。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/