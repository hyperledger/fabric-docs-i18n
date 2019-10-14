<<<<<<< HEAD
系统链码插件
=======
System Chaincode Plugins - 系统链码插件
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
========================


系统链码是特殊的链码，作为 peer 进程的一部分运行，而不是像用户链码一样运行在独立的 
docker 容器中。所以，它们有更高的权限访问 peer 中的资源来实现用户链码难以实现或者
不能实现的功能。示例系统链码包括 QSCC （Query System Chaincode, 查询系统链码）提供
账本或者 Fabric 相关的查询， CSCC （Configuration System Chaincode， 配置系统链码）
帮助管理访问控制，和 LSCC （Lifecycle System Chaincode，生命周期系统链码）。
System chaincodes are specialized chaincodes that run as part of the peer process
as opposed to user chaincodes that run in separate docker containers. As
such they have more access to resources in the peer and can be used for
implementing features that are difficult or impossible to be implemented through
user chaincodes. Examples of System Chaincodes include QSCC (Query System Chaincode)
for ledger and other Fabric-related queries, CSCC (Configuration System Chaincode)
which helps regulate access control, ``_lifecycle`` (which regulates the Fabric
chaincode lifecycle), and the legacy LSCC (Lifecycle System Chaincode) which
regulated the previous chaincode lifecycle.

<<<<<<< HEAD
和用户链码不同，系统链码不使用 SDK 或者 CLI 的提案安装和实例化。它在 peer 节点启动
的时候注册和部署。

系统链码可以通过两种方式链接到 peer 节点：静态连接和使用 Go 插件动态连接。本教程将讲
解如何以插件方式开发和加载系统链码。

开发插件
=======
系统链码是特殊的链码，作为 peer 进程的一部分运行，而不是像用户链码一样运行在独立的 
docker 容器中。所以，它们有更高的权限访问 peer 中的资源来实现用户链码难以实现或者
不能实现的功能。示例系统链码包括 QSCC （Query System Chaincode, 查询系统链码）提供
账本或者 Fabric 相关的查询， CSCC （Configuration System Chaincode， 配置系统链码）
帮助管理访问控制，和 LSCC （Lifecycle System Chaincode，生命周期系统链码）。

Unlike a user chaincode, a system chaincode is not installed and instantiated
using proposals from SDKs or CLI. It is registered and deployed by the peer at
start-up.

和用户链码不同，系统链码不使用 SDK 或者 CLI 的提案安装和实例化。它在 peer 节点启动
的时候注册和部署。

System chaincodes can be linked to a peer in two ways: statically, and dynamically
using Go plugins. This tutorial will outline how to develop and load system chaincodes
as plugins.

系统链码可以通过两种方式链接到 peer 节点：静态连接和使用 Go 插件动态连接。本教程将讲
解如何以插件方式开发和加载系统链码。

Developing Plugins - 开发插件
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
------------------

系统链码的程序使用 `Go <https://golang.org>`_ 编写，并使用 `plugin <https://golang.org/pkg/plugin>`_ 
包加载。

一个插件包含一个带有导出符号的 main 包，并通过 ``go build -buildmode=plugin`` 命令编译。

每一个系统链码必须实现 `Chaincode Interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_ 
并导出一个复合 mian 包中 ``func New() shim.Chaincode`` 签名的构造方法。可以在仓库中的
``examples/plugin/scc`` 找到一个示例。

<<<<<<< HEAD
已有的链码，比如 QSCC 也可以作为一些特征的模板，比如访问控制，它们就是通过系统链码实现的。
已有的系统链码同样可以作为日志和测试的参考。


.. note:: 在导入包的时候：插件导入的 Go 的标准包必须和主程序（在这里就是 Fabric）导入的包
          的版本一致。


配置插件
=======
系统链码的程序使用 `Go <https://golang.org>`_ 编写，并使用 `plugin <https://golang.org/pkg/plugin>`_ 
包加载。

A plugin includes a main package with exported symbols and is built with the command
``go build -buildmode=plugin``.

一个插件包含一个带有导出符号的 main 包，并通过 ``go build -buildmode=plugin`` 命令编译。

Every system chaincode must implement the `Chaincode Interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_
and export a constructor method that matches the signature ``func New() shim.Chaincode``
in the main package. An example can be found in the repository at ``examples/plugin/scc``.

每一个系统链码必须实现 `Chaincode Interface <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#Chaincode>`_ 
并导出一个复合 mian 包中 ``func New() shim.Chaincode`` 签名的构造方法。可以在仓库中的
``examples/plugin/scc`` 找到一个示例。

Existing chaincodes such as the QSCC can also serve as templates for certain
features, such as access control, that are typically implemented through
system chaincodes. The existing system chaincodes also serve as a reference for
best-practices on things like logging and testing.

已有的链码，比如 QSCC 也可以作为一些特征的模板，比如访问控制，它们就是通过系统链码实现的。
已有的系统链码同样可以作为日志和测试的参考。

.. note:: On imported packages: the Go standard library requires that a plugin must
          include the same version of imported packages as the host application
          (Fabric, in this case).

.. note:: 在导入包的时候：插件导入的 Go 的标准包必须和主程序（在这里就是 Fabric）导入的包
          的版本一致。

Configuring Plugins - 配置插件
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
-------------------

插件在 ``core.yaml`` 的 ``chaincode.systemPlugin`` 部分配置：

插件在 ``core.yaml`` 的 ``chaincode.systemPlugin`` 部分配置：

.. code-block:: bash

  chaincode:
    systemPlugins:
      - enabled: true
        name: mysyscc
        path: /opt/lib/syscc.so
        invokableExternal: true
        invokableCC2CC: true


系统链码也必须在 ``core.yaml`` 中 ``chaincode.system`` 的白名单中：

系统链码也必须在 ``core.yaml`` 中 ``chaincode.system`` 的白名单中：

.. code-block:: bash

  chaincode:
    system:
      mysyscc: enable


.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
