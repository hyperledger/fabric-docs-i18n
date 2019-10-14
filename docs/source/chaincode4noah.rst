链码操作者教程
=======================

什么是链码？
------------------

链码是一个程序，由 `Go <https://golang.org>`_  、 `node.js <https://nodejs.org>`_ 、或者 
`Java <https://java.com/en/>`_ 编写，来实现一些预定义的接口。链码运行在一个和背书节点进
程隔离的一个安全的 Docker 容器中。链码的实例化和账本状态的管理通过应用提交的交易来实现。

链码一般处理网络中的成员一致认可的商业逻辑，所以它类似于“智能合约”。链码创建的状态是被唯
一绑定在该链码上的，其他链码不能直接访问。然而，在同一个网络中，赋予适当的权限，一个链码
也可以调用其他链码来访问他的状态。

在下边的章节中，我们将以区块链操作员 Noah 的视角来解释链码。为了 Noah 的兴趣，我们将关注
链码操作的生命周期；打包、安装、实例化和升级链码的过程是区块链网络中链码操作的生命周期中的
方法。

链码生命周期
-------------------

Hyperledger Fabric API 允许和区块链网络中的多种节点进行交互包括 peer 节点、排序节点、MSP，
它还允许在背书节点打包、安装、实例化和升级链码。 Hyperledger Fabric 特定语言的 SDK 将 
Hyperledger Fabric API 的功能抽象出来以方便应用开发，同样也可以用来管理链码生命周期。另外，
Hyperledger Fabric API 还可以直接通过 CLI 访问，本文档将使用这种方式。

我们提供了四个命令来管理链码的生命周期： ``package`` 、 ``install`` 、 ``instantiate`` 和 
``upgrade`` 。将来我们还打算引入 ``stop`` 和 ``start`` 交易来在不需要真正卸载的情况下取消
或者重启链码。在一个链码成功地安装和实例化之后，链码就在运行了，它可以通过 ``invoke`` 来处
理交易。链码可以在安装之的任何时间进行升级。


.. _Package:

打包
---------

链码包包含三部分：

  - 链码，定义为 ``ChaincodeDeploymentSpec`` 或者 CDS 。 CDS 定义了链码包中的链码和其他属性，比如名字和版本，
  - 一个可选的实例化策略，它的语法和背书策略的语法一样，在 :doc:`endorsement-policies` 中有描述，
  - 链码拥有者的签名集合。

签名的目的如下：

  - 建立链码的所有权，
  - 允许包内容的验证，
  - 允许验证包的篡改。

在一个通道上链码的实例化交易的创建者，会被进行链码实例化策略验证。

创建包
^^^^^^^^^^^^^^^^^^^^

打包链码有两个建议。一个是当你想有一个多个所有者的链码时，链码包需要多个身份签名。
这个工作流需要我们初始创建一个签名的链码包（一个 ``SingedCDS`` ），然后把它发送给
其他所有者签名。

另外一个简单的工作流是，当你部署一个 SingedCDS 时，链码包仅包含要执行 ``安装`` 
交易的节点个体的签名。

我们将先处理更复杂的事情。你如果目前还不关心多所有者，可以调到 :ref:`install` 章节。

使用下边的命令创建签名链码包：

.. code:: bash

    peer chaincode package -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd -v 0 -s -S -i "AND('OrgA.admin')" ccpack.out

``-s`` 选项创建一个可由多个所有者签名的包，而不是简单地创建原始 CDS。如果指定了 
``-s`` ，如果其他所有者要继续签名就必须也指定 ``-S`` 选项。

``-S`` 选项指明了包要使用 ``core.yaml`` 中的 ``localMspid`` 属性的 MSP 主体签名。

``-S`` 选项是可选的。但是，如果一个包创建的时候没有签名，其他所有者就也不能使用 
``signpackage`` 命令签名。

选项 ``-i`` 可以让用户给链码指定一个实例化的策略。初始策略和背书策略有相同的格式，
指明那些身份可以实例化链码。在上边的例子中，只有 OrgA 的管理员可以实例化链码。如
果没有提供策略，就是用默认策略，默认策略是只允许 peer 节点的管理员实例化链码。

包签名
^^^^^^^^^^^^^^^
一个创建时被签名的链码包可以被其他所有者查看和签名。工作流支持链码包的带外签名。

`ChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/chaincode.proto#L78>`_ 
可以可选地通过一个所有者集合的签名来创建一个 
`SignedChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/signed_cc_dep_spec.proto#L26>`_ 
（简称 SingedCDS）。SignedCDS 包含 3 个元素：

  1. CDS 包含源码、名字和链码版本。
  2. 链码的实例化策略，也就是背书策略。
  3. 链码的所有者列表，也就是（背书者）
     `Endorsement <https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal_response.proto#L111>`_.

.. note:: 注意，当链码在一些通道上实例化时，这个背书策略在带外确定，以提供适
          当的 MSP 主体。如果没有指定实例化策略，默认策略是通道中的任意 MSP 
          管理员。

每个所有者通过结合他的身份（比如，证书）和签名融合结果来背书 ChaincodeDeploymentSpec。

链码所有者可以使用如下命令来签名之前创建的已经签过名的包：

.. code:: bash

    peer chaincode signpackage ccpack.out signedccpack.out

``ccpack.out`` 和 ``signedccpack.out`` 分别是输入和输出的包。 ``signedccpack.out`` 
额外包含本地 MSP 对包的签名。

.. _Install:

安装链码
^^^^^^^^^^^^^^^^^^^^

``install`` 交易，将链码源码打包至预定义格式 ``ChaincodeDeploymentSpec`` （简称 CDS）
并安装到将要运行链码的 peer 节点。

.. note:: 你必须将链码安装在通道中的 **每一个** 背书节点上。

当 ``install`` API 收到一个 ``ChaincodeDeploymentSpec`` 的时候，它将使用默认
的实例化策略并包含一个空的所有者列表。

.. note:: 链码应该只安装在所有者成员的背书节点上，以保护链码逻辑的机密性。没有
          安装链码的成员，不能够对链码交易进行背书；也就是说他们不能执行链码。但
          是他们仍然可以验证并向账本提交交易。

要安装链码，就要向 ``lifecycle system chaincode`` （LSCC） 发送一个 
`SignedProposal<https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal.proto#L104>`_ 
,LSCC 的介绍在 `System Chaincode`_ 章节有介绍。例如，要使用 CLI 安装 :ref:`simple asset chaincode` 章节的  
**sacc** 示例链码，命令如下：

.. code:: bash

    peer chaincode install -n asset_mgmt -v 1.0 -p sacc

CLI 会在内部为 **sacc** 创建一个 SignedChaincodeDeploymentSpec 并将它发送到调用 LSCC 
的 ``Install`` 方法的本地 peer 节点上。 ``-p`` 参数指定了链码的路径，该路径必须在用户
的 ``GOPATH`` 目录下，比如 ``$GOPATH/src/sacc`` 。注意，如果使用 ``-l node`` 或者 
``-l java`` 来指定 node 链码或者 java 链码， ``-p`` 使用链码的绝对路径。命令的完整
描述请参考 :doc:`command_ref` 。

注意，要在 peer 节点上安装链码， SignedProposal 必须是 peer 节点本地 MSP 的管理员之一。


.. _Instantiate:

实例化
^^^^^^^^^^^

``instantiate`` 交易调用 ``lifecycle System Chaincode`` （LSCC） 在通道上创建并
实例化链码。这是链码和通道绑定的过程：一个链码可以绑定在任意数量的通道上，并且在
每一个通道上的操作都是独立的。换句话说，无论链码在多少通道上安装并实例化了，状态
都值存在与交易所提交的通道。

``instantiate`` 交易的创建者，必须满足 SignedCDS 中链码的实例化策略，并且必须是通
道的写入者，写入者在创建通道的时候配置的。这对通道的安全性很重要，可以避免骗子节点
部署链码和避免伪装的成员执行未在通道上绑定的链码。

例如，强调默认的实例化策略是通道上任一 MSP 管理员，所以链码实例化交易的创建者必须是
通道管理员之一。当交易提案到达背书节点，它就会检查创建者的签名是否符合实例化策略。这
个过程会在提交到账本之前的交易验证过程完成。

实例化交易也设置了链码在通道上的背书策略。背书策略描述了通道上的成员接受一笔交易所需
要满足的条件。

例如，使用 CLI 来实例化 **sacc** 链码并使用 ``john`` 和 ``0`` 初始化状态，命令如下：


.. code:: bash

    peer chaincode instantiate -n sacc -v 1.0 -c '{"Args":["john","0"]}' -P "AND ('Org1.member','Org2.member')"

.. note:: 注意一下背书策略，需要 Org1 和 Org2 对所有发送到 **sacc** 都进行背书。也就是
          说，只有 Org1 和 Org2 都签名的 **sacc** 上 `Invoke` 的执行结果才是有效的。

实例化成功之后，链码在通道上就进入活跃状态，并且准备处理 
`ENDORSER_TRANSACTION <https://github.com/hyperledger/fabric/blob/master/protos/common/common.proto#L42>`_ 
类型的交易提案。交易会在到达背书节点的时候被处理。

.. _Upgrade:

升级
^^^^^^^
链码可以在任何时间通过改变版本号来升级，版本号是 SignedCDS 的一部分。其他部分，
比如所有者和实例化策略是可选的。但是，链码名字必须一致，否则会被认为是不同的链
码。

在升级之前，新版本的链码必须被安装在必要的背书节点上。升级是和实例化类似的交易，
它是在通道上绑定一个新版本的链码。其他绑定旧版本链码的通道依旧运行旧的版本。换
句话说， ``upgrade`` 交易每次只影响提交交易的那一个通道。

.. note:: 注意到，同一时间可能有多个版本的链码在运行，升级程序不自动删除旧版本，
          所以暂时必须由用户管理。          


和 ``instantiate`` 交易相比有一点不同： ``upgrade`` 交易检查当前链码的实例化策略，
而不是新的策略（如果指定的话）。这就确保了只有在当前实例化策略下的成员才可以升级
链码。

.. note:: 注意，在升级的过程中，会调用链码的 ``Init`` 方法来更新或者重新实例化任何
          值，所以必须注意避免在链码升级的过程中重新设置状态。


.. _Stop-and-Start:

停止和启动
^^^^^^^^^^^^^^
注意， ``stop`` 和 ``start`` 生命周期交易还没有实现。所以，你必须通过手动删除每一
个背书节点上的链码容器和 SignedCDS 包来停止链码。也就是通过删除每一个背书节点所运
行的主机或者虚拟机上的链码容器和 SignedCDS 来完成。

.. note:: TODO - 为了删除 peer 节点上的 CDS，你必须先进入到 peer 节点的容器中。
          我们确实需要提供一个工具脚本实现这个功能。

.. code:: bash

    docker rm -f <container id>
    rm /var/hyperledger/production/chaincodes/<ccname>:<ccversion>

“停止”在以受控方式进行升级的工作流中非常有用，当执行升级之前，可以停止通道上所有
节点的链码。

.. _System Chaincode:

系统链码
----------------
系统链码有着相同的编程模型，除了它运行在 peer 进程而不是像普通链码一样在一个隔离
的容器中。因此，系统链码被编译进了 peer 可执行程序中而不遵守上边所描述的生命周期。
特别地， **install** 、 **instantiate** 和 **upgrade** 不使用与系统链码。

系统链码的目的是减少 peer 节点和链码 gRPC 通信的消耗和权衡管理的灵活性。例如，一个 
系统链码仅可以通过 peer 二进制文件来升级。它必须使用在编译时的 
`一组固定参数 <https://github.com/hyperledger/fabric/blob/master/core/scc/importsysccs.go>`_ 
进行注册，没有背书策略或者背书策略功能。

系统链码是 Hyperledger Fabric 中用来实现系统行为的，所以他们可以被系统集成人员替换
或修改。

现有的系统链码列表：

1. `LSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/lscc>`_
   生命周期链码，用来处理上边提到的生命周期请求。
2. `CSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/cscc>`_
   配置系统链码，在 peer 端处理通道配置。
3. `QSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/qscc>`_
   查询系统链码，提供账本查询 API，比如获取区块和交易。

之前的背书和验证系统链码被可插拔背书和验证方法所取代，描述文档请参阅  
:doc:`pluggable_endorsement_and_validation` 。

当修改和替换这些系统链码的时候必须十分消息，特别是 LSCC 。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
