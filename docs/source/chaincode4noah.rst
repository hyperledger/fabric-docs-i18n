<<<<<<< HEAD
链码操作者教程
=======================

什么是链码？
------------------

=======
Chaincode for Operators - 链码操作者教程
=======================

What is Chaincode? - 什么是链码？
------------------

Chaincode is a program, written in `Go <https://golang.org>`_, `node.js <https://nodejs.org>`_,
or `Java <https://java.com/en/>`_ that implements a prescribed interface.
Chaincode runs in a secured Docker container isolated from the endorsing peer
process. Chaincode initializes and manages ledger state through transactions
submitted by applications.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
链码是一个程序，由 `Go <https://golang.org>`_  、 `node.js <https://nodejs.org>`_ 、或者 
`Java <https://java.com/en/>`_ 编写，来实现一些预定义的接口。链码运行在一个和背书节点进
程隔离的一个安全的 Docker 容器中。链码的实例化和账本状态的管理通过应用提交的交易来实现。

<<<<<<< HEAD
=======
A chaincode typically handles business logic agreed to by members of the
network, so it may be considered as a "smart contract". State created by a
chaincode is scoped exclusively to that chaincode and can't be accessed
directly by another chaincode. However, within the same network, given
the appropriate permission a chaincode may invoke another chaincode to
access its state.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
链码一般处理网络中的成员一致认可的商业逻辑，所以它类似于“智能合约”。链码创建的状态是被唯
一绑定在该链码上的，其他链码不能直接访问。然而，在同一个网络中，赋予适当的权限，一个链码
也可以调用其他链码来访问他的状态。

<<<<<<< HEAD
=======
In the following sections, we will explore chaincode through the eyes of a
blockchain network operator, Noah. For Noah's interests, we will focus
on chaincode lifecycle operations; the process of packaging, installing,
instantiating and upgrading the chaincode as a function of the chaincode's
operational lifecycle within a blockchain network.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
在下边的章节中，我们将以区块链操作员 Noah 的视角来解释链码。为了 Noah 的兴趣，我们将关注
链码操作的生命周期；打包、安装、实例化和升级链码的过程是区块链网络中链码操作的生命周期中的
方法。

<<<<<<< HEAD
链码生命周期
-------------------

=======
Chaincode lifecycle - 链码生命周期
-------------------

The Hyperledger Fabric API enables interaction with the various nodes
in a blockchain network - the peers, orderers and MSPs - and it also allows
one to package, install, instantiate and upgrade chaincode on the endorsing
peer nodes. The Hyperledger Fabric language-specific SDKs
abstract the specifics of the Hyperledger Fabric API to facilitate
application development, though it can be used to manage a chaincode's
lifecycle. Additionally, the Hyperledger Fabric API can be accessed
directly via the CLI, which we will use in this document.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
Hyperledger Fabric API 允许和区块链网络中的多种节点进行交互包括 peer 节点、排序节点、MSP，
它还允许在背书节点打包、安装、实例化和升级链码。 Hyperledger Fabric 特定语言的 SDK 将 
Hyperledger Fabric API 的功能抽象出来以方便应用开发，同样也可以用来管理链码生命周期。另外，
Hyperledger Fabric API 还可以直接通过 CLI 访问，本文档将使用这种方式。

<<<<<<< HEAD
我们提供了四个命令来管理链码的生命周期： ``package`` 、 ``install`` 、 ``instantiate`` 和 
``upgrade`` 。将来我们还打算引入 ``stop`` 和 ``start`` 交易来在不需要真正卸载的情况下取消
或者重启链码。在一个链码成功地安装和实例化之后，链码就在运行了，它可以通过 ``invoke`` 来处
理交易。链码可以在安装之的任何时间进行升级。

=======
We provide four commands to manage a chaincode's lifecycle: ``package``,
``install``, ``instantiate``, and ``upgrade``. In a future release, we are
considering adding ``stop`` and ``start`` transactions to disable and re-enable
a chaincode without having to actually uninstall it. After a chaincode has
been successfully installed and instantiated, the chaincode is active (running)
and can process transactions via the ``invoke`` transaction. A chaincode may be
upgraded any time after it has been installed.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

我们提供了四个命令来管理链码的生命周期： ``package`` 、 ``install`` 、 ``instantiate`` 和 
``upgrade`` 。将来我们还打算引入 ``stop`` 和 ``start`` 交易来在不需要真正卸载的情况下取消
或者重启链码。在一个链码成功地安装和实例化之后，链码就在运行了，它可以通过 ``invoke`` 来处
理交易。链码可以在安装之的任何时间进行升级。

.. _Package:

<<<<<<< HEAD
打包
=======
Packaging - 打包
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
---------

链码包包含三部分：

<<<<<<< HEAD
  - 链码，定义为 ``ChaincodeDeploymentSpec`` 或者 CDS 。 CDS 定义了链码包中的链码和其他属性，比如名字和版本，
  - 一个可选的实例化策略，它的语法和背书策略的语法一样，在 :doc:`endorsement-policies` 中有描述，
  - 链码拥有者的签名集合。

签名的目的如下：

  - 建立链码的所有权，
  - 允许包内容的验证，
  - 允许验证包的篡改。

在一个通道上链码的实例化交易的创建者，会被进行链码实例化策略验证。

创建包
=======
链码包包含三部分：

  - the chaincode, as defined by ``ChaincodeDeploymentSpec`` or CDS. The CDS
    defines the chaincode package in terms of the code and other properties
    such as name and version,
  - an optional instantiation policy which can be syntactically described
    by the same policy used for endorsement and described in
    :doc:`endorsement-policies`, and
  - a set of signatures by the entities that “own” the chaincode.

  - 链码，定义为 ``ChaincodeDeploymentSpec`` 或者 CDS 。 CDS 定义了链码包中的链码和其他属性，比如名字和版本，
  - 一个可选的实例化策略，它的语法和背书策略的语法一样，在 :doc:`endorsement-policies` 中有描述，
  - 链码拥有者的签名集合。

The signatures serve the following purposes:

签名的目的如下：

  - to establish an ownership of the chaincode,
  - to allow verification of the contents of the package, and
  - to allow detection of package tampering.

  - 建立链码的所有权，
  - 允许包内容的验证，
  - 允许验证包的篡改。

The creator of the instantiation transaction of the chaincode on a channel is
validated against the instantiation policy of the chaincode.

在一个通道上链码的实例化交易的创建者，会被进行链码实例化策略验证。

Creating the package - 创建包
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^

打包链码有两个建议。一个是当你想有一个多个所有者的链码时，链码包需要多个身份签名。
这个工作流需要我们初始创建一个签名的链码包（一个 ``SingedCDS`` ），然后把它发送给
其他所有者签名。

<<<<<<< HEAD
另外一个简单的工作流是，当你部署一个 SingedCDS 时，链码包仅包含要执行 ``安装`` 
交易的节点个体的签名。

我们将先处理更复杂的事情。你如果目前还不关心多所有者，可以调到 :ref:`install` 章节。

使用下边的命令创建签名链码包：
=======
打包链码有两个建议。一个是当你想有一个多个所有者的链码时，链码包需要多个身份签名。
这个工作流需要我们初始创建一个签名的链码包（一个 ``SingedCDS`` ），然后把它发送给
其他所有者签名。

The simpler workflow is for when you are deploying a SignedCDS that has only the
signature of the identity of the node that is issuing the ``install``
transaction.

另外一个简单的工作流是，当你部署一个 SingedCDS 时，链码包仅包含要执行 ``安装`` 
交易的节点个体的签名。

We will address the more complex case first. However, you may skip ahead to the
:ref:`install` section below if you do not need to worry about multiple owners
just yet.

我们将先处理更复杂的事情。你如果目前还不关心多所有者，可以调到 :ref:`install` 章节。

To create a signed chaincode package, use the following command:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

使用下边的命令创建签名链码包：

.. code:: bash

    peer chaincode package -n mycc -p github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd -v 0 -s -S -i "AND('OrgA.admin')" ccpack.out

<<<<<<< HEAD
``-s`` 选项创建一个可由多个所有者签名的包，而不是简单地创建原始 CDS。如果指定了 
``-s`` ，如果其他所有者要继续签名就必须也指定 ``-S`` 选项。

``-S`` 选项指明了包要使用 ``core.yaml`` 中的 ``localMspid`` 属性的 MSP 主体签名。
=======
The ``-s`` option creates a package that can be signed by multiple owners as
opposed to simply creating a raw CDS. When ``-s`` is specified, the ``-S``
option must also be specified if other owners are going to need to sign.
Otherwise, the process will create a SignedCDS that includes only the
instantiation policy in addition to the CDS.

``-s`` 选项创建一个可由多个所有者签名的包，而不是简单地创建原始 CDS。如果指定了 
``-s`` ，如果其他所有者要继续签名就必须也指定 ``-S`` 选项。

The ``-S`` option directs the process to sign the package
using the MSP identified by the value of the ``localMspid`` property in
``core.yaml``.

``-S`` 选项指明了包要使用 ``core.yaml`` 中的 ``localMspid`` 属性的 MSP 主体签名。

The ``-S`` option is optional. However if a package is created without a
signature, it cannot be signed by any other owner using the
``signpackage`` command.

``-S`` 选项是可选的。但是，如果一个包创建的时候没有签名，其他所有者就也不能使用 
``signpackage`` 命令签名。

The optional ``-i`` option allows one to specify an instantiation policy
for the chaincode. The instantiation policy has the same format as an
endorsement policy and specifies which identities can instantiate the
chaincode. In the example above, only the admin of OrgA is allowed to
instantiate the chaincode. If no policy is provided, the default policy
is used, which only allows the admin identity of the peer's MSP to
instantiate chaincode.

选项 ``-i`` 可以让用户给链码指定一个实例化的策略。初始策略和背书策略有相同的格式，
指明那些身份可以实例化链码。在上边的例子中，只有 OrgA 的管理员可以实例化链码。如
果没有提供策略，就是用默认策略，默认策略是只允许 peer 节点的管理员实例化链码。

Package signing - 包签名
^^^^^^^^^^^^^^^
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

``-S`` 选项是可选的。但是，如果一个包创建的时候没有签名，其他所有者就也不能使用 
``signpackage`` 命令签名。

<<<<<<< HEAD
选项 ``-i`` 可以让用户给链码指定一个实例化的策略。初始策略和背书策略有相同的格式，
指明那些身份可以实例化链码。在上边的例子中，只有 OrgA 的管理员可以实例化链码。如
果没有提供策略，就是用默认策略，默认策略是只允许 peer 节点的管理员实例化链码。

包签名
^^^^^^^^^^^^^^^
一个创建时被签名的链码包可以被其他所有者查看和签名。工作流支持链码包的带外签名。
=======
一个创建时被签名的链码包可以被其他所有者查看和签名。工作流支持链码包的带外签名。

The
`ChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/chaincode.proto#L78>`_
may be optionally be signed by the collective owners to create a
`SignedChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/signed_cc_dep_spec.proto#L26>`_
(or SignedCDS). The SignedCDS contains 3 elements:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

`ChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/chaincode.proto#L78>`_ 
可以可选地通过一个所有者集合的签名来创建一个 
`SignedChaincodeDeploymentSpec <https://github.com/hyperledger/fabric/blob/master/protos/peer/signed_cc_dep_spec.proto#L26>`_ 
（简称 SingedCDS）。SignedCDS 包含 3 个元素：

<<<<<<< HEAD
  1. CDS 包含源码、名字和链码版本。
  2. 链码的实例化策略，也就是背书策略。
  3. 链码的所有者列表，也就是（背书者）
     `Endorsement <https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal_response.proto#L111>`_.

.. note:: 注意，当链码在一些通道上实例化时，这个背书策略在带外确定，以提供适
          当的 MSP 主体。如果没有指定实例化策略，默认策略是通道中的任意 MSP 
          管理员。

每个所有者通过结合他的身份（比如，证书）和签名融合结果来背书 ChaincodeDeploymentSpec。

链码所有者可以使用如下命令来签名之前创建的已经签过名的包：
=======
  1. The CDS contains the source code, the name, and version of the chaincode.
  2. An instantiation policy of the chaincode, expressed as endorsement policies.
  3. The list of chaincode owners, defined by means of
     `Endorsement <https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal_response.proto#L111>`_.

  1. CDS 包含源码、名字和链码版本。
  2. 链码的实例化策略，也就是背书策略。
  3. 链码的所有者列表，也就是（背书者）
     `Endorsement <https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal_response.proto#L111>`_.

.. note:: Note that this endorsement policy is determined out-of-band to
          provide proper MSP principals when the chaincode is instantiated
          on some channels. If the instantiation policy is not specified,
          the default policy is any MSP administrator of the channel.

.. note:: 注意，当链码在一些通道上实例化时，这个背书策略在带外确定，以提供适
          当的 MSP 主体。如果没有指定实例化策略，默认策略是通道中的任意 MSP 
          管理员。

Each owner endorses the ChaincodeDeploymentSpec by combining it
with that owner's identity (e.g. certificate) and signing the combined
result.

每个所有者通过结合他的身份（比如，证书）和签名融合结果来背书 ChaincodeDeploymentSpec。

A chaincode owner can sign a previously created signed package using the
following command:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

链码所有者可以使用如下命令来签名之前创建的已经签过名的包：

.. code:: bash

    peer chaincode signpackage ccpack.out signedccpack.out

``ccpack.out`` 和 ``signedccpack.out`` 分别是输入和输出的包。 ``signedccpack.out`` 
额外包含本地 MSP 对包的签名。

``ccpack.out`` 和 ``signedccpack.out`` 分别是输入和输出的包。 ``signedccpack.out`` 
额外包含本地 MSP 对包的签名。

.. _Install:

<<<<<<< HEAD
安装链码
=======
Installing chaincode - 安装链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^^^^^^^

``install`` 交易，将链码源码打包至预定义格式 ``ChaincodeDeploymentSpec`` （简称 CDS）
并安装到将要运行链码的 peer 节点。

<<<<<<< HEAD
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
=======
``install`` 交易，将链码源码打包至预定义格式 ``ChaincodeDeploymentSpec`` （简称 CDS）
并安装到将要运行链码的 peer 节点。

.. note:: You must install the chaincode on **each** endorsing peer node
          of a channel that will run your chaincode.

.. note:: 你必须将链码安装在通道中的 **每一个** 背书节点上。

When the ``install`` API is given simply a ``ChaincodeDeploymentSpec``,
it will default the instantiation policy and include an empty owner list.

当 ``install`` API 收到一个 ``ChaincodeDeploymentSpec`` 的时候，它将使用默认
的实例化策略并包含一个空的所有者列表。

.. note:: Chaincode should only be installed on endorsing peer nodes of the
          owning members of the chaincode to protect the confidentiality of
          the chaincode logic from other members on the network. Those members
          without the chaincode, can't be the endorsers of the chaincode's
          transactions; that is, they can't execute the chaincode. However,
          they can still validate and commit the transactions to the ledger.

.. note:: 链码应该只安装在所有者成员的背书节点上，以保护链码逻辑的机密性。没有
          安装链码的成员，不能够对链码交易进行背书；也就是说他们不能执行链码。但
          是他们仍然可以验证并向账本提交交易。

To install a chaincode, send a `SignedProposal
<https://github.com/hyperledger/fabric/blob/master/protos/peer/proposal.proto#L104>`_
to the ``lifecycle system chaincode`` (LSCC) described in the `System Chaincode`_
section. For example, to install the **sacc** sample chaincode described
in section :ref:`simple asset chaincode`
using the CLI, the command would look like the following:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

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

<<<<<<< HEAD
=======
CLI 会在内部为 **sacc** 创建一个 SignedChaincodeDeploymentSpec 并将它发送到调用 LSCC 
的 ``Install`` 方法的本地 peer 节点上。 ``-p`` 参数指定了链码的路径，该路径必须在用户
的 ``GOPATH`` 目录下，比如 ``$GOPATH/src/sacc`` 。注意，如果使用 ``-l node`` 或者 
``-l java`` 来指定 node 链码或者 java 链码， ``-p`` 使用链码的绝对路径。命令的完整
描述请参考 :doc:`command_ref` 。

Note that in order to install on a peer, the signature of the SignedProposal
must be from 1 of the peer's local MSP administrators.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

注意，要在 peer 节点上安装链码， SignedProposal 必须是 peer 节点本地 MSP 的管理员之一。

.. _Instantiate:

<<<<<<< HEAD
实例化
^^^^^^^^^^^

=======
Instantiate -  实例化
^^^^^^^^^^^

The ``instantiate`` transaction invokes the ``lifecycle System Chaincode``
(LSCC) to create and initialize a chaincode on a channel. This is a
chaincode-channel binding process: a chaincode may be bound to any number of
channels and operate on each channel individually and independently. In other
words, regardless of how many other channels on which a chaincode might be
installed and instantiated, state is kept isolated to the channel to which
a transaction is submitted.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
``instantiate`` 交易调用 ``lifecycle System Chaincode`` （LSCC） 在通道上创建并
实例化链码。这是链码和通道绑定的过程：一个链码可以绑定在任意数量的通道上，并且在
每一个通道上的操作都是独立的。换句话说，无论链码在多少通道上安装并实例化了，状态
都值存在与交易所提交的通道。

<<<<<<< HEAD
=======
The creator of an ``instantiate`` transaction must satisfy the instantiation
policy of the chaincode included in SignedCDS and must also be a writer on the
channel, which is configured as part of the channel creation. This is important
for the security of the channel to prevent rogue entities from deploying
chaincodes or tricking members to execute chaincodes on an unbound channel.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
``instantiate`` 交易的创建者，必须满足 SignedCDS 中链码的实例化策略，并且必须是通
道的写入者，写入者在创建通道的时候配置的。这对通道的安全性很重要，可以避免骗子节点
部署链码和避免伪装的成员执行未在通道上绑定的链码。

<<<<<<< HEAD
=======
For example, recall that the default instantiation policy is any channel MSP
administrator, so the creator of a chaincode instantiate transaction must be a
member of the channel administrators. When the transaction proposal arrives at
the endorser, it verifies the creator's signature against the instantiation
policy. This is done again during the transaction validation before committing
it to the ledger.

>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
例如，强调默认的实例化策略是通道上任一 MSP 管理员，所以链码实例化交易的创建者必须是
通道管理员之一。当交易提案到达背书节点，它就会检查创建者的签名是否符合实例化策略。这
个过程会在提交到账本之前的交易验证过程完成。

<<<<<<< HEAD
实例化交易也设置了链码在通道上的背书策略。背书策略描述了通道上的成员接受一笔交易所需
要满足的条件。

例如，使用 CLI 来实例化 **sacc** 链码并使用 ``john`` 和 ``0`` 初始化状态，命令如下：

=======
The instantiate transaction also sets up the endorsement policy for that
chaincode on the channel. The endorsement policy describes the attestation
requirements for the transaction result to be accepted by members of the
channel.

实例化交易也设置了链码在通道上的背书策略。背书策略描述了通道上的成员接受一笔交易所需
要满足的条件。

For example, using the CLI to instantiate the **sacc** chaincode and initialize
the state with ``john`` and ``0``, the command would look like the following:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

例如，使用 CLI 来实例化 **sacc** 链码并使用 ``john`` 和 ``0`` 初始化状态，命令如下：

.. code:: bash

    peer chaincode instantiate -n sacc -v 1.0 -c '{"Args":["john","0"]}' -P "AND ('Org1.member','Org2.member')"

.. note:: 注意一下背书策略，需要 Org1 和 Org2 对所有发送到 **sacc** 都进行背书。也就是
          说，只有 Org1 和 Org2 都签名的 **sacc** 上 `Invoke` 的执行结果才是有效的。

<<<<<<< HEAD
实例化成功之后，链码在通道上就进入活跃状态，并且准备处理 
`ENDORSER_TRANSACTION <https://github.com/hyperledger/fabric/blob/master/protos/common/common.proto#L42>`_ 
类型的交易提案。交易会在到达背书节点的时候被处理。
=======
.. note:: 注意一下背书策略，需要 Org1 和 Org2 对所有发送到 **sacc** 都进行背书。也就是
          说，只有 Org1 和 Org2 都签名的 **sacc** 上 `Invoke` 的执行结果才是有效的。

After being successfully instantiated, the chaincode enters the active state on
the channel and is ready to process any transaction proposals of type
`ENDORSER_TRANSACTION <https://github.com/hyperledger/fabric/blob/master/protos/common/common.proto#L42>`_.
The transactions are processed concurrently as they arrive at the endorsing
peer.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

实例化成功之后，链码在通道上就进入活跃状态，并且准备处理 
`ENDORSER_TRANSACTION <https://github.com/hyperledger/fabric/blob/master/protos/common/common.proto#L42>`_ 
类型的交易提案。交易会在到达背书节点的时候被处理。

.. _Upgrade:

<<<<<<< HEAD
升级
=======
Upgrade - 升级
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^
链码可以在任何时间通过改变版本号来升级，版本号是 SignedCDS 的一部分。其他部分，
比如所有者和实例化策略是可选的。但是，链码名字必须一致，否则会被认为是不同的链
码。

在升级之前，新版本的链码必须被安装在必要的背书节点上。升级是和实例化类似的交易，
它是在通道上绑定一个新版本的链码。其他绑定旧版本链码的通道依旧运行旧的版本。换
句话说， ``upgrade`` 交易每次只影响提交交易的那一个通道。

.. note:: 注意到，同一时间可能有多个版本的链码在运行，升级程序不自动删除旧版本，
          所以暂时必须由用户管理。          

<<<<<<< HEAD

和 ``instantiate`` 交易相比有一点不同： ``upgrade`` 交易检查当前链码的实例化策略，
而不是新的策略（如果指定的话）。这就确保了只有在当前实例化策略下的成员才可以升级
链码。

.. note:: 注意，在升级的过程中，会调用链码的 ``Init`` 方法来更新或者重新实例化任何
          值，所以必须注意避免在链码升级的过程中重新设置状态。

=======
链码可以在任何时间通过改变版本号来升级，版本号是 SignedCDS 的一部分。其他部分，
比如所有者和实例化策略是可选的。但是，链码名字必须一致，否则会被认为是不同的链
码。

Prior to upgrade, the new version of the chaincode must be installed on
the required endorsers. Upgrade is a transaction similar to the instantiate
transaction, which binds the new version of the chaincode to the channel. Other
channels bound to the old version of the chaincode still run with the old
version. In other words, the ``upgrade`` transaction only affects one channel
at a time, the channel to which the transaction is submitted.

在升级之前，新版本的链码必须被安装在必要的背书节点上。升级是和实例化类似的交易，
它是在通道上绑定一个新版本的链码。其他绑定旧版本链码的通道依旧运行旧的版本。换
句话说， ``upgrade`` 交易每次只影响提交交易的那一个通道。

.. note:: Note that since multiple versions of a chaincode may be active
          simultaneously, the upgrade process doesn't automatically remove the
          old versions, so user must manage this for the time being.

.. note:: 注意到，同一时间可能有多个版本的链码在运行，升级程序不自动删除旧版本，
          所以暂时必须由用户管理。          

There's one subtle difference with the ``instantiate`` transaction: the
``upgrade`` transaction is checked against the current chaincode instantiation
policy, not the new policy (if specified). This is to ensure that only existing
members specified in the current instantiation policy may upgrade the chaincode.

和 ``instantiate`` 交易相比有一点不同： ``upgrade`` 交易检查当前链码的实例化策略，
而不是新的策略（如果指定的话）。这就确保了只有在当前实例化策略下的成员才可以升级
链码。

.. note:: Note that during upgrade, the chaincode ``Init`` function is called to
          perform any data related updates or re-initialize it, so care must be
          taken to avoid resetting states when upgrading chaincode.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

.. note:: 注意，在升级的过程中，会调用链码的 ``Init`` 方法来更新或者重新实例化任何
          值，所以必须注意避免在链码升级的过程中重新设置状态。

.. _Stop-and-Start:

<<<<<<< HEAD
停止和启动
=======
Stop and Start - 停止和启动
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
^^^^^^^^^^^^^^
注意， ``stop`` 和 ``start`` 生命周期交易还没有实现。所以，你必须通过手动删除每一
个背书节点上的链码容器和 SignedCDS 包来停止链码。也就是通过删除每一个背书节点所运
行的主机或者虚拟机上的链码容器和 SignedCDS 来完成。

<<<<<<< HEAD
.. note:: TODO - 为了删除 peer 节点上的 CDS，你必须先进入到 peer 节点的容器中。
          我们确实需要提供一个工具脚本实现这个功能。
=======
注意， ``stop`` 和 ``start`` 生命周期交易还没有实现。所以，你必须通过手动删除每一
个背书节点上的链码容器和 SignedCDS 包来停止链码。也就是通过删除每一个背书节点所运
行的主机或者虚拟机上的链码容器和 SignedCDS 来完成。

.. note:: TODO - in order to delete the CDS from the peer node, you would need
          to enter the peer node's container, first. We really need to provide
          a utility script that can do this.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

.. note:: TODO - 为了删除 peer 节点上的 CDS，你必须先进入到 peer 节点的容器中。
          我们确实需要提供一个工具脚本实现这个功能。

.. code:: bash

    docker rm -f <container id>
    rm /var/hyperledger/production/chaincodes/<ccname>:<ccversion>

“停止”在以受控方式进行升级的工作流中非常有用，当执行升级之前，可以停止通道上所有
节点的链码。

“停止”在以受控方式进行升级的工作流中非常有用，当执行升级之前，可以停止通道上所有
节点的链码。

.. _System Chaincode:

<<<<<<< HEAD
系统链码
=======
System chaincode - 系统链码
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f
----------------
系统链码有着相同的编程模型，除了它运行在 peer 进程而不是像普通链码一样在一个隔离
的容器中。因此，系统链码被编译进了 peer 可执行程序中而不遵守上边所描述的生命周期。
特别地， **install** 、 **instantiate** 和 **upgrade** 不使用与系统链码。

<<<<<<< HEAD
系统链码的目的是减少 peer 节点和链码 gRPC 通信的消耗和权衡管理的灵活性。例如，一个 
系统链码仅可以通过 peer 二进制文件来升级。它必须使用在编译时的 
`一组固定参数 <https://github.com/hyperledger/fabric/blob/master/core/scc/importsysccs.go>`_ 
进行注册，没有背书策略或者背书策略功能。

系统链码是 Hyperledger Fabric 中用来实现系统行为的，所以他们可以被系统集成人员替换
或修改。

现有的系统链码列表：
=======
系统链码有着相同的编程模型，除了它运行在 peer 进程而不是像普通链码一样在一个隔离
的容器中。因此，系统链码被编译进了 peer 可执行程序中而不遵守上边所描述的生命周期。
特别地， **install** 、 **instantiate** 和 **upgrade** 不使用与系统链码。

The purpose of system chaincode is to shortcut gRPC communication cost between
peer and chaincode, and tradeoff the flexibility in management. For example, a
system chaincode can only be upgraded with the peer binary. It must also
register with a `fixed set of parameters <https://github.com/hyperledger/fabric/blob/master/core/scc/importsysccs.go>`_
compiled in and doesn't have endorsement policies or endorsement policy
functionality.

系统链码的目的是减少 peer 节点和链码 gRPC 通信的消耗和权衡管理的灵活性。例如，一个 
系统链码仅可以通过 peer 二进制文件来升级。它必须使用在编译时的 
`一组固定参数 <https://github.com/hyperledger/fabric/blob/master/core/scc/importsysccs.go>`_ 
进行注册，没有背书策略或者背书策略功能。

System chaincode is used in Hyperledger Fabric to implement a number of
system behaviors so that they can be replaced or modified as appropriate
by a system integrator.

系统链码是 Hyperledger Fabric 中用来实现系统行为的，所以他们可以被系统集成人员替换
或修改。

The current list of system chaincodes:
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

现有的系统链码列表：

1. `LSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/lscc>`_
   生命周期链码，用来处理上边提到的生命周期请求。
2. `CSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/cscc>`_
   配置系统链码，在 peer 端处理通道配置。
3. `QSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/qscc>`_
   查询系统链码，提供账本查询 API，比如获取区块和交易。

<<<<<<< HEAD
之前的背书和验证系统链码被可插拔背书和验证方法所取代，描述文档请参阅  
:doc:`pluggable_endorsement_and_validation` 。

当修改和替换这些系统链码的时候必须十分消息，特别是 LSCC 。
=======
1. `LSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/lscc>`_
   生命周期链码，用来处理上边提到的生命周期请求。
2. `CSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/cscc>`_
   配置系统链码，在 peer 端处理通道配置。
3. `QSCC <https://github.com/hyperledger/fabric/tree/master/core/scc/qscc>`_
   查询系统链码，提供账本查询 API，比如获取区块和交易。

The former system chaincodes for endorsement and validation have been replaced
by the pluggable endorsement and validation function as described by the
:doc:`pluggable_endorsement_and_validation` documentation.

之前的背书和验证系统链码被可插拔背书和验证方法所取代，描述文档请参阅  
:doc:`pluggable_endorsement_and_validation` 。

Extreme care must be taken when modifying or replacing these system chaincodes,
especially LSCC.
>>>>>>> d73cda60e63d025d95cad3bfc2f54c542546c17f

当修改和替换这些系统链码的时候必须十分消息，特别是 LSCC 。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
