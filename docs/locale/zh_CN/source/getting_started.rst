入门
===============
Getting Started
===============

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install
   test_network

在我们开始之前，如果您还没有这样做，您可能希望检查您是否已经在将要开发区块链应用程序或运行 Hyperledger Fabric 的平台上安装了所有 :doc:`prereqs` 。

Before we begin, if you haven't already done so, you may wish to check that
you have all the :doc:`prereqs` installed on the platform(s)
on which you'll be developing blockchain applications and/or operating
Hyperledger Fabric.

安装必备组件后，即可下载并安装 HyperLedger Fabric。在我们为Fabric 二进制文件开发真正的安装程序的同时，我们提供了一个脚本，可以将 :doc:`install` 到您的系统中。该脚本还将 Docker 镜像下载到本地注册表。

Once you have the prerequisites installed, you are ready to download and
install HyperLedger Fabric. While we work on developing real installers for the
Fabric binaries, we provide a script that will :doc:`install` to your system.
The script also will download the Docker images to your local registry.

在你下载完 Fabric 示例以及 Docker 镜像到你本机之后，您就可以跟着 :doc:`test_network` 教程开始使用 Fabric 了。

After you have downloaded the Fabric Samples and Docker images to your local
machine, you can get started working with Fabric with the
:doc:`test_network` tutorial.

Hyperledger Fabric 智能合约（链码） SDK
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric smart contract (chaincode) APIs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric 提供了不同编程语言的 SDK 来支持开发智能合约（链码）。智能合约 SDK 可以使用 Go、Node.js 和 Java：

Hyperledger Fabric offers a number of APIs to support developing smart contracts (chaincode)
in various programming languages. Smart contract APIs are available for Go, Node.js, and Java:

  * `Go 合约 API <https://github.com/hyperledger/fabric-contract-api-go>`__.
  * `Node.js 合约 API <https://github.com/hyperledger/fabric-chaincode-node>`__ and `Node.js 合约 API 文档 <https://fabric-shim.github.io/>`__.
  * `Java 合约 API <https://github.com/hyperledger/fabric-chaincode-java>`__ and `Java 合约 API 文档 <https://hyperledger.github.io/fabric-chaincode-java/>`__.

  * `Go contract-api <https://github.com/hyperledger/fabric-contract-api-go>`__.
  * `Node.js contract API <https://github.com/hyperledger/fabric-chaincode-node>`__ and `Node.js contract API documentation <https://hyperledger.github.io/fabric-chaincode-node/>`__.
  * `Java contract API <https://github.com/hyperledger/fabric-chaincode-java>`__ and `Java contract API documentation <https://hyperledger.github.io/fabric-chaincode-java/>`__.

Hyperledge Fabric 应用程序 SDK
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric application SDKs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric 提供了许多 SDK 来支持各种编程语言开发应用程序。SDK 有支持 Node.js 和 Java 语言的：

Hyperledger Fabric offers a number of SDKs to support developing applications in various programming languages. SDKs are available for Node.js and Java:

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ and `Node.js SDK 文档 <https://hyperledger.github.io/fabric-sdk-node/>`__.
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ and `Java SDK 文档 <https://hyperledger.github.io/fabric-gateway-java/>`__.

  * `Node.js SDK <https://github.com/hyperledger/fabric-sdk-node>`__ and `Node.js SDK documentation <https://hyperledger.github.io/fabric-sdk-node/>`__.
  * `Java SDK <https://github.com/hyperledger/fabric-gateway-java>`__ and `Java SDK documentation <https://hyperledger.github.io/fabric-gateway-java/>`__.

此外，还有两个尚未正式发布的 SDK（适用于Python 和 Go），但它们仍可供下载和测试：

  Prerequisites for developing with the SDKs can be found in the Node.js SDK `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ and Java SDK `README <https://github.com/hyperledger/fabric-gateway-java/blob/master/README.md>`__.

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

In addition, there are two more application SDKs that have not yet been officially released
(for Python and Go), but they are still available for downloading and testing:

目前，Node.js 和 Java 支持 Hyperledge Fabric 1.4 提供的新的应用程序编程模型。对 Go 的支持会在之后的发布版中提供。

  * `Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.

Hyperledger Fabric CA
^^^^^^^^^^^^^^^^^^^^^

Currently, Node.js, Java and Go support the new application programming model delivered in Hyperledger Fabric v1.4.

Hyperledger Fabric 提供一个可选的 `证书授权服务 <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_ ，您可以选择使用该服务生成证书和密钥材料，以配置和管理区块链网络中的身份。然而，任何可以生成 ECDSA 证书的 CA 都是可以使用的。

Hyperledger Fabric CA
^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric provides an optional
`certificate authority service <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_
that you may choose to use to generate the certificates and key material
to configure and manage identity in your blockchain network. However, any CA
that can generate ECDSA certificates may be used.
