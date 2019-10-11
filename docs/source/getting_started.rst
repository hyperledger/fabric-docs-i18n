入门
===============

.. toctree::
   :maxdepth: 1
   :hidden:

   prereqs
   install

在我们开始之前，如果您还没有这样做，您可能希望检查您是否已经在将要开发区块链应用程序以及/或运行Hyperledger Fabric的平台上安装了所有先决条件(:doc:`prereqs`)。

安装必备组件后，即可下载并安装HyperLedger Fabric。 在我们为Fabric二进制文件开发真正的安装程序时，我们提供了一个脚本，可以将样例、二进制文件和Docker镜像安装(:doc:`install` )到您的系统中。 该脚本还将Docker镜像下载到本地注册表。

Hyperledger Fabric SDKs
^^^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric提供了许多SDK来支持各种编程语言。 有支持Node.js和Java 语言的两个正式发布的SDK：

  * `Hyperledger Fabric Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__ and `Node SDK documentation <https://fabric-sdk-node.github.io/>`__.
  * `Hyperledger Fabric Java SDK <https://github.com/hyperledger/fabric-sdk-java>`__.

此外，还有三个尚未正式发布的SDK（适用于Python，Go和REST），但它们仍可供下载和测试：

  * `Hyperledger Fabric Python SDK <https://github.com/hyperledger/fabric-sdk-py>`__.
  * `Hyperledger Fabric Go SDK <https://github.com/hyperledger/fabric-sdk-go>`__.
  * `Hyperledger Fabric REST SDK <https://github.com/hyperledger/fabric-sdk-rest>`__.

Hyperledger Fabric CA
^^^^^^^^^^^^^^^^^^^^^

Hyperledger Fabric提供一个可选的 `证书颁发机构服务 <http://hyperledger-fabric-ca.readthedocs.io/en/latest>`_ ，您可以选择使用该服务生成证书和密钥材料，以配置和管理区块链网络中的身份。然而，任何可以生成ECDSA证书的CA都是可以使用的.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
