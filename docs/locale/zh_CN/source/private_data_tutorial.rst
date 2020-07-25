在 Fabric 中使用私有数据
======================================
Using Private Data in Fabric
============================

本教程将演示如何使用集合在区块链网络中授权的 Peer 节点上存储和检索私有数据。

This tutorial will demonstrate the use of collections to provide storage
and retrieval of private data on the blockchain network for authorized peers
of organizations.

本教程需要你已经掌握私有数据存储及其使用方法。更多信息，请查看 :doc:`private-data/private-data`。

The information in this tutorial assumes knowledge of private data
stores and their use cases. For more information, check out :doc:`private-data/private-data`.

.. note:: 本教程使用 Fabric-2.0 中新的链码生命管理周期操作。如果你想在之前的版本中使用私有数据，请参阅 v1.4 版本的教程`在 Fabric 中使用私有数据教程 <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__.

.. note:: These instructions use the new Fabric chaincode lifecycle introduced
          in the Fabric v2.0 release. If you would like to use the previous
          lifecycle model to use private data with chaincode, visit the v1.4
          version of the `Using Private Data in Fabric tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__.

本教程将会根据以下步骤带你练习如何在 Fabric 中定义、配置和使用私有数据：

The tutorial will take you through the following steps to practice defining,
configuring and using private data with Fabric:

#. :ref:`pd-build-json`
#. :ref:`pd-read-write-private-data`
#. :ref:`pd-install-define_cc`
#. :ref:`pd-store-private-data`
#. :ref:`pd-query-authorized`
#. :ref:`pd-query-unauthorized`
#. :ref:`pd-purge`
#. :ref:`pd-indexes`
#. :ref:`pd-ref-material`

本教程将会在 Fabric Building Your First Network （BYFN）教程网络中使用 `弹珠私有数据示例 <https://github.com/hyperledger/fabric-samples/tree/master/chaincode/marbles02_private>`__ 来演示如何创建、部署以及 使用私有数据合集。你应该先完成 fabric 的安装 :doc:`install`。

This tutorial will deploy the `marbles private data sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/chaincode/marbles02_private>`__
to the Fabric test network to demonstrate how to create, deploy, and use a collection of
private data. You should have completed the task :doc:`install`.

.. _pd-build-json:

创建集合定义的 JSON 文件
------------------------------------------

Build a collection definition JSON file
---------------------------------------

在通道中使用私有数据的第一步是定义集合以决定私有数据的访问权限。

The first step in privatizing data on a channel is to build a collection
definition which defines access to the private data.

该集合的定义描述了谁可以保存数据，数据要分发给多少个节点，需要多少个节点来进行数据分发，以及私有数据在私有数据库中的保存时间。之后，我们将会展示链码的接口：``PutPrivateData`` 和 ``GetPrivateData`` 将集合映射到私有数据以确保其安全。

The collection definition describes who can persist data, how many peers the
data is distributed to, how many peers are required to disseminate the private
data, and how long the private data is persisted in the private database. Later,
we will demonstrate how chaincode APIs ``PutPrivateData`` and ``GetPrivateData``
are used to map the collection to the private data being secured.

集合定义由以下几个属性组成：

A collection definition is composed of the following properties:

.. _blockToLive:

- ``name``: 集合的名称。

- ``name``: Name of the collection.

- ``policy``: 定义了哪些组织中的 Peer 节点能够存储集合数据。

- ``policy``: Defines the organization peers allowed to persist the collection data.

- ``requiredPeerCount``: 私有数据要分发到的节点数，这是链码背书成功的条件之一。

- ``requiredPeerCount``: Number of peers required to disseminate the private data as
  a condition of the endorsement of the chaincode

- ``maxPeerCount``: 为了数据冗余，当前背书节点将尝试向其他节点分发数据的数量。如果当前背书节点发生故障，其他的冗余节点可以承担私有数据查询的任务。

- ``maxPeerCount``: For data redundancy purposes, the number of other peers
  that the current endorsing peer will attempt to distribute the data to.
  If an endorsing peer goes down, these other peers are available at commit time
  if there are requests to pull the private data.

- ``blockToLive``: 对于非常敏感的信息，比如价格或者个人信息，这个值代表书库可以在私有数据库中保存的时间。数据会在私有数据库中保存 ``blockToLive`` 个区块，之后就会被清除。如果要永久保留，将此值设置为 ``0`` 即可。

- ``blockToLive``: For very sensitive information such as pricing or personal information,
  this value represents how long the data should live on the private database in terms
  of blocks. The data will live for this specified number of blocks on the private database
  and after that it will get purged, making this data obsolete from the network.
  To keep private data indefinitely, that is, to never purge private data, set
  the ``blockToLive`` property to ``0``.

- ``memberOnlyRead``: 设置为 ``true`` 时，节点会自动强制集合中定义的成员组织内的客户端对私有数据仅拥有只读权限。

- ``memberOnlyRead``: a value of ``true`` indicates that peers automatically
  enforce that only clients belonging to one of the collection member organizations
  are allowed read access to private data.

为了说明私有数据的用法，弹珠私有数据示例包含两个私有数据集合定义：``collectionMarbles和`` 和 ``collectionMarblePrivateDetails``。``collectionMarbles`` 定义中的 ``policy`` 属性允许通道的所有成员（Org1 和 Org2）在私有数据库中保存私有数据。``collectionMarblesPrivateDetails`` 集合仅允许 Org1 的成员在其私有数据库中保存私有数据。

To illustrate usage of private data, the marbles private data example contains
two private data collection definitions: ``collectionMarbles``
and ``collectionMarblePrivateDetails``. The ``policy`` property in the
``collectionMarbles`` definition allows all members of  the channel (Org1 and
Org2) to have the private data in a private database. The
``collectionMarblesPrivateDetails`` collection allows only members of Org1 to
have the private data in their private database.

关于 ``policy`` 属性的更多相关信息，请查看 :doc:`endorsement-policies`。

For more information on building a policy definition refer to the :doc:`endorsement-policies`
topic.

.. code:: json

 // collections_config.json

 [
   {
        "name": "collectionMarbles",
        "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
        "requiredPeerCount": 0,
        "maxPeerCount": 3,
        "blockToLive":1000000,
        "memberOnlyRead": true
   },

   {
        "name": "collectionMarblePrivateDetails",
        "policy": "OR('Org1MSP.member')",
        "requiredPeerCount": 0,
        "maxPeerCount": 3,
        "blockToLive":3,
        "memberOnlyRead": true
   }
 ]

由这些策略保护的数据将会在链码中映射出来，在本教程后半段将有说明。

The data to be secured by these policies is mapped in chaincode and will be
shown later in the tutorial.

当链码被使用 `peer lifecycle chaincode commit 命令 <http://hyperledger-fabric.readthedocs.io/en/latest/commands/peerchaincode.html#peer-chaincode-instantiate>`__ 提交到通道中时，集合定义文件也会被部署到通道中。更多信息请看下面的第三节。

This collection definition file is deployed when the chaincode definition is
committed to the channel using the `peer lifecycle chaincode commit command <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__.
More details on this process are provided in Section 3 below.

.. _pd-read-write-private-data:

使用链码 API 读写私有数据
------------------------------------------------

Read and Write private data using chaincode APIs
------------------------------------------------

接下来将通过在链码中构建数据定义来让您理解数据在通道中的私有化。弹珠私有数据示例将私有数据拆分为两个数据定义来进行数据权限控制。

The next step in understanding how to privatize data on a channel is to build
the data definition in the chaincode. The marbles private data sample divides
the private data into two separate data definitions according to how the data will
be accessed.

.. code-block:: GO

 // Peers in Org1 and Org2 will have this private data in a side database
 type marble struct {
   ObjectType string `json:"docType"`
   Name       string `json:"name"`
   Color      string `json:"color"`
   Size       int    `json:"size"`
   Owner      string `json:"owner"`
 }

 // Only peers in Org1 will have this private data in a side database
 type marblePrivateDetails struct {
   ObjectType string `json:"docType"`
   Name       string `json:"name"`
   Price      int    `json:"price"`
 }

对私有数据的访问将遵循以下策略：

Specifically access to the private data will be restricted as follows:

- ``name, color, size, and owner`` 通道中所有成员都可见（Org1 和 Org2）
- ``price`` 仅对 Org1 中的成员可见

- ``name, color, size, and owner`` will be visible to all members of the channel (Org1 and Org2)
- ``price`` only visible to members of Org1

弹珠示例中有两个不同的私有数据定义。这些数据和限制访问权限的集合策略将由链码接口进行控制。具体来说，就是读取和写入带有集合定义的私有数据需要使用 ``GetPrivateData()`` 和 ``PutPrivateData()`` 接口，你可以在 `这里 <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_ 找到他们。

Thus two different sets of private data are defined in the marbles private data
sample. The mapping of this data to the collection policy which restricts its
access is controlled by chaincode APIs. Specifically, reading and writing
private data using a collection definition is performed by calling ``GetPrivateData()``
and ``PutPrivateData()``, which can be found `here <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_.

下图说明了弹珠私有数据示例中使用的私有数据模型。

The following diagram illustrates the private data model used by the marbles
private data sample.

.. image:: images/SideDB-org1-org2.png


读取集合数据
~~~~~~~~~~~~~~~~~~~~~~~~

Reading collection data
~~~~~~~~~~~~~~~~~~~~~~~~

使用链码 API ``GetPrivateData()`` 在数据库中访问私有数据。 ``GetPrivateData()`` 有两个参数，**集合名（collection name）** 和 **数据键（data key）**。 重申一下，集合 ``collectionMarbles`` 允许 Org1 和 Org2 的成员在侧数据库中保存私有数据，集合 ``collectionMarblePrivateDetails`` 只允许 Org1 在侧数据库中保存私有数据。有关接口的实现详情请查看 `弹珠私有数据方法 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__ ：

Use the chaincode API ``GetPrivateData()`` to query private data in the
database.  ``GetPrivateData()`` takes two arguments, the **collection name**
and the data key. Recall the collection  ``collectionMarbles`` allows members of
Org1 and Org2 to have the private data in a side database, and the collection
``collectionMarblePrivateDetails`` allows only members of Org1 to have the
private data in a side database. For implementation details refer to the
following two `marbles private data functions <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__:

 * **readMarble** 用来查询 ``name, color, size and owner`` 这些属性
 * **readMarblePrivateDetails** 用来查询 ``price`` 属性

 * **readMarble** for querying the values of the ``name, color, size and owner`` attributes
 * **readMarblePrivateDetails** for querying the values of the ``price`` attribute

下面教程中，使用 peer 命令查询数据库的时候，会使用这两个方法。

When we issue the database queries using the peer commands later in this tutorial,
we will call these two functions.

写入私有数据
~~~~~~~~~~~~~~~~~~~~

Writing private data
~~~~~~~~~~~~~~~~~~~~

使用链码接口 ``PutPrivateData()`` 将私有数据保存到私有数据库中。该接口需要集合名称。由于弹珠私有数据示例中包含两个不同的私有数据集，因此这个接口在链码中会被调用两次。

Use the chaincode API ``PutPrivateData()`` to store the private data
into the private database. The API also requires the name of the collection.
Since the marbles private data sample includes two different collections, it is called
twice in the chaincode:

1. 使用集合 ``collectionMarbles`` 写入私有数据 ``name, color, size 和 owner``。
2. 使用集合  ``collectionMarblePrivateDetails`` 写入私有数据``price``。

1. Write the private data ``name, color, size and owner`` using the
   collection named ``collectionMarbles``.
2. Write the private data ``price`` using the collection named
   ``collectionMarblePrivateDetails``.

例如,在链码的 ``initMarble`` 方法片段中,``PutPrivateData()`` 被调用了两次，每个私有数据调用一次。

For example, in the following snippet of the ``initMarble`` function,
``PutPrivateData()`` is called twice, once for each set of private data.

.. code-block:: GO

  // ==== Create marble object, marshal to JSON, and save to state ====
	marble := &marble{
		ObjectType: "marble",
		Name:       marbleInput.Name,
		Color:      marbleInput.Color,
		Size:       marbleInput.Size,
		Owner:      marbleInput.Owner,
	}
	marbleJSONasBytes, err := json.Marshal(marble)
	if err != nil {
		return shim.Error(err.Error())
	}

	// === Save marble to state ===
	err = stub.PutPrivateData("collectionMarbles", marbleInput.Name, marbleJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	// ==== Create marble private details object with price, marshal to JSON, and save to state ====
	marblePrivateDetails := &marblePrivateDetails{
		ObjectType: "marblePrivateDetails",
		Name:       marbleInput.Name,
		Price:      marbleInput.Price,
	}
	marblePrivateDetailsBytes, err := json.Marshal(marblePrivateDetails)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutPrivateData("collectionMarblePrivateDetails", marbleInput.Name, marblePrivateDetailsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

总结一下，在上边的 ``collection.json`` 中定义的策略，允许 Org1 和 Org2 中的所有成员都能在他们的私有数据库中对私有数据 ``name, color, size, owner`` 进行存储和交易。但是只有 Org1 中的成员才能够对 ``price`` 进行存储和交易。


数据私有化的另一个好处就是，使用集合时，只有私有数据的哈希值会通过排序节点, 而数据本身不会参与排序。这样就保证了私有数据对排序节点的保密性。

To summarize, the policy definition above for our ``collection.json``
allows all peers in Org1 and Org2 to store and transact
with the marbles private data ``name, color, size, owner`` in their
private database. But only peers in Org1 can store and transact with
the ``price`` private data in its private database.

启动网络
-----------------

As an additional data privacy benefit, since a collection is being used,
only the private data hashes go through orderer, not the private data itself,
keeping private data confidential from orderer.

现在我们准备使用一些命令来如何使用私有数据。

Start the network
-----------------

:guilabel:`动手试一试`

Now we are ready to step through some commands which demonstrate how to use
private data.

在安装、定义和使用弹珠私有数据示例链码之前，我们需要启动 Fabric 测试网络。为了大家可以正确使用本教程，我们将从一个已知的初始化状态开始操作。接下来的命令将会停止你主机上所有正在运行的 Docker 容器，并会清除之前生成的构件。所以我们运行以下命令来清除之前的环境。

:guilabel:`Try it yourself`

.. code:: bash

Before installing, defining, and using the marbles private data chaincode below,
we need to start the Fabric test network. For the sake of this tutorial, we want
to operate from a known initial state. The following command will kill any active
or stale Docker containers and remove previously generated artifacts.
Therefore let's run the following command to clean up any previous
environments:

   cd fabric-samples/test-network
   ./network.sh down

.. code:: bash

如果你之前没有运行过本教程，你需要在我们部署链码前下载链码所需的依赖。运行如下命令：

   cd fabric-samples/test-network
   ./network.sh down

.. code:: bash

If you have not run through the tutorial before, you will need to vendor the
chaincode dependencies before we can deploy it to the network. Run the
following commands:

    cd ../chaincode/marbles02_private/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network

.. code:: bash


    cd ../chaincode/marbles02_private/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network

如果你之前已经运行过本教程，你也需要删除之前弹珠私有数据链码的 Docker 容器。运行如下命令：


.. code:: bash

If you've already run through this tutorial, you'll also want to delete the
underlying Docker containers for the marbles private data chaincode. Let's run
the following commands to clean up previous environments:

   docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*.marblesp.*/) {print $1}')
   docker rmi -f $(docker images | awk '($1 ~ /dev-peer.*.marblesp.*/) {print $3}')

.. code:: bash

在 ``test-network`` 目录中，你可以使用如下命令启动使用 CouchDB 的 Fabric 测试网络：

   docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*.marblesp.*/) {print $1}')
   docker rmi -f $(docker images | awk '($1 ~ /dev-peer.*.marblesp.*/) {print $3}')

.. code:: bash

From the ``test-network`` directory, you can use the following command to start
up the Fabric test network with CouchDB:

   ./network.sh up createChannel -s couchdb

.. code:: bash

这个命令将会部署一个 Fabric 网络，包括一个名为的通道 ``mychannel``，两个组织（各拥有一个 Peer 节点），Peer 节点将使用 CouchDB 作为状态数据库。用默认的 LevelDB 和 CouchDB 都可以使用私有数据集合。我们选择 CouchDB 来演示如何使用私有数据的索引。

   ./network.sh up createChannel -s couchdb

.. note:: 为了保证私有数据集正常工作，需要正确地配置组织间的 gossip 通信。请参考文档 :doc:`gossip`，需要特别注意 "锚节点（anchor peers）" 章节。本教程不关注 gossip，它在测试网络中已经配置好了。但当我们配置通道的时候，gossip 的锚节点是否被正确配置影响到私有数据集能否正常工作。

This command will deploy a Fabric network consisting of a single channel named
``mychannel`` with two organizations (each maintaining one peer node) and an
ordering service while using CouchDB as the state database. Either LevelDB or
CouchDB may be used with collections. CouchDB was chosen to demonstrate how to
use indexes with private data.

.. _pd-install-define_cc:

.. note:: For collections to work, it is important to have cross organizational
           gossip configured correctly. Refer to our documentation on :doc:`gossip`,
           paying particular attention to the section on "anchor peers". Our tutorial
           does not focus on gossip given it is already configured in the test network,
           but when configuring a channel, the gossip anchors peers are critical to
           configure for collections to work properly.

安装并定义一个带集合的链码
-------------------------------------------------

.. _pd-install-define_cc:

客户端应用程序是通过链码与区块链账本进行数据交互的。因此我们需要在每个节点上安装链码，用他们来执行和背书我们的交易。然而，在我们与链码进行交互之前，通道中的成员需要一致同意链码的定义，以此来建立链码的治理，当然还包括链私有数据集合的定义。我们将要使用命令：:doc:`commands/peerlifecycle` 打包、安装，以及在通道上定义链码。

Install and define a chaincode with a collection
-------------------------------------------------

链码安装到 Peer 节点之前需要先进行打包操作。我们可以用 `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ 命令对弹珠链码进行打包。

Client applications interact with the blockchain ledger through chaincode.
Therefore we need to install a chaincode on every peer that will execute and
endorse our transactions. However, before we can interact with our chaincode,
the members of the channel need to agree on a chaincode definition that
establishes chaincode governance, including the private data collection
configuration. We are going to package, install, and then define the chaincode
on the channel using :doc:`commands/peerlifecycle`.

测试网络包含两个组织，Org1 和 Org2，各自拥有一个节点。所以要安装链码包到两个节点上：

The chaincode needs to be packaged before it can be installed on our peers.
We can use the `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ command
to package the marbles chaincode.

- peer0.org1.example.com
- peer0.org2.example.com

The test network includes two organizations, Org1 and Org2, with one peer each.
Therefore, the chaincode package has to be installed on two peers:

链码打包之后，我们可以使用 `peer lifecycle chaincode install <commands/peerlifecycle.html#peer-lifecycle-chaincode-install>`__ 命令将弹珠链码安装到每个节点上。

- peer0.org1.example.com
- peer0.org2.example.com

:guilabel:`动手试一试`

After the chaincode is packaged, we can use the `peer lifecycle chaincode install <commands/peerlifecycle.html#peer-lifecycle-chaincode-install>`__
command to install the Marbles chaincode on each peer.

如果你已经成功启动测试网络，复制粘贴如下环境变量到你的 CLI 以 Org1 管理员的身份与测试网络进行交互。请确保你在 `test-network` 目录中。

:guilabel:`Try it yourself`

.. code:: bash

Assuming you have started the test network, copy and paste the following
environment variables in your CLI to interact with the network and operate as
the Org1 admin. Make sure that you are in the `test-network` directory.

    export PATH=${PWD}/../bin:${PWD}:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

.. code:: bash

1. 用以下命令打包弹珠私有数据链码。

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

.. code:: bash

1. Use the following command to package the marbles private data chaincode.

    peer lifecycle chaincode package marblesp.tar.gz --path ../chaincode/marbles02_private/go/ --lang golang --label marblespv1

.. code:: bash

这个命令将会生成一个链码包文件 marblesp.tar.gz。

    peer lifecycle chaincode package marblesp.tar.gz --path ../chaincode/marbles02_private/go/ --lang golang --label marblespv1

2. 用以下命令在节点 ``peer0.org1.example.com`` 上安装链码包。

This command will create a chaincode package named marblesp.tar.gz.

.. code:: bash

2. Use the following command to install the chaincode package onto the peer
``peer0.org1.example.com``.

    peer lifecycle chaincode install marblesp.tar.gz

.. code:: bash

安装成功会返回链码标识，类似如下响应：

    peer lifecycle chaincode install marblesp.tar.gz

.. code:: bash

A successful install command will return the chaincode identifier, similar to
the response below:

    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nKmarblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd\022\nmarblespv1" >
    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd

.. code:: bash

3. 现在在 CLI 中切换到 Org2 管理员。复制粘贴如下代码到你的命令行窗口并运行：

    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nKmarblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd\022\nmarblespv1" >
    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd

.. code:: bash

3. Now use the CLI as the Org2 admin. Copy and paste the following block of
commands as a group and run them all at once:

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

.. code:: bash

4. 用以下命令在 Org2 的节点上安装链码：

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

.. code:: bash

4. Run the following command to install the chaincode on the Org2 peer:

    peer lifecycle chaincode install marblesp.tar.gz

.. code:: bash


    peer lifecycle chaincode install marblesp.tar.gz

审批链码定义
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


每个通道中的成员想要使用链码，都需要为他们的组织审批链码定义。由于本教程中的两个组织都要使用链码，所以我们需要使用 `peer lifecycle chaincode approveformyorg <commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg>`__ 为Org1 和 Org2 审批链码定义。链码定义也包含私有数据集合的定义，它们都在 ``marbles02_private`` 示例中。我们会使用 ``--collections-config`` 参数来指明私有数据集 JSON 文件的路径。

Approve the chaincode definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:guilabel:`动手试一试`

Each channel member that wants to use the chaincode needs to approve a chaincode
definition for their organization. Since both organizations are going to use the
chaincode in this tutorial, we need to approve the chaincode definition for both
Org1 and Org2 using the `peer lifecycle chaincode approveformyorg <commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg>`__
command. The chaincode definition also includes the private data collection
definition that accompanies the ``marbles02_private`` sample. We will provide
the path to the collections JSON file using the ``--collections-config`` flag.

在 ``test-network`` 目录下运行如下命令来为 Org1 和 Org2 审批链码定义。

:guilabel:`Try it yourself`

1. 使用如下命令来查询节点上已安装链码包的 ID。

Run the following commands from the ``test-network`` directory to approve a
definition for Org1 and Org2.

.. code:: bash

1. Use the following command to query your peer for the package ID of the
installed chaincode.

    peer lifecycle chaincode queryinstalled

.. code:: bash

这个命令将返回和安装命令一样的链码包的标识，你会看到类似如下的输出信息：

    peer lifecycle chaincode queryinstalled

.. code:: bash

The command will return the same package identifier as the install command.
You should see output similar to the following:

    Installed chaincodes on peer:
    Package ID: marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e, Label: marblespv1

.. code:: bash

2. 将包 ID 声明为一个环境变量。粘贴 ``peer lifecycle chaincode queryinstalled`` 命令返回的包 ID 到下边的命令中。包 ID 在不同用户中是不一样的，所以你的 ID 可能与本教程中的不同，所以你需要使用你的终端中返回的包 ID 来完成这一步。

    Installed chaincodes on peer:
    Package ID: marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e, Label: marblespv1

.. code:: bash

2. Declare the package ID as an environment variable. Paste the package ID of
marblespv1 returned by the ``peer lifecycle chaincode queryinstalled`` into
the command below. The package ID may not be the same for all users, so you
need to complete this step using the package ID returned from your console.

    export CC_PACKAGE_ID=marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e

.. code:: bash

3. 为了确保我们在以 Org1 的身份运行 CLI。复制粘贴如下信息到节点容器中并执行：

    export CC_PACKAGE_ID=marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e

.. code :: bash

3. Make sure we are running the CLI as Org1. Copy and paste the following block
of commands as a group into the peer container and run them all at once:

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

.. code :: bash

4. 用如下命令审批 Org1 的弹珠私有数据链码定义。此命令包含了一个集合文件的路径。

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

.. code:: bash

4. Use the following command to approve a definition of the marbles private data
chaincode for Org1. This command includes a path to the collection definition
file.

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

.. code:: bash

当命令成功完成后，你会收到类似如下的返回信息：

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

.. code:: bash

When the command completes successfully you should see something similar to:

    2020-01-03 17:26:55.022 EST [chaincodeCmd] ClientWait -> INFO 001 txid [06c9e86ca68422661e09c15b8e6c23004710ea280efda4bf54d501e655bafa9b] committed with status (VALID) at

.. code:: bash

5. 将 CLI 转换到 Org2。复制粘贴如下信息到节点容器中并执行：

    2020-01-03 17:26:55.022 EST [chaincodeCmd] ClientWait -> INFO 001 txid [06c9e86ca68422661e09c15b8e6c23004710ea280efda4bf54d501e655bafa9b] committed with status (VALID) at

.. code:: bash

5. Now use the CLI to switch to Org2. Copy and paste the following block of commands
as a group into the peer container and run them all at once.

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

.. code:: bash

6. 现在你可以为 Org2 审批链码定义：

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

.. code:: bash

6. You can now approve the chaincode definition for Org2:

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

.. code:: bash

提交链码定义
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

当组织中大部分成员审批通过了链码定义，该组织才可以提交该链码定义到通道上。

Commit the chaincode definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

使用 `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ 命令来提交链码定义。这个命令同样也会部署私有数据集合到通道上。

Once a sufficient number of organizations (in this case, a majority) have
approved a chaincode definition, one organization can commit the definition to
the channel.

在链码定义被提交到通道后，我们就可以使用这个链码了。因为弹珠私有数据示例包含一个初始化方法，我们在调用链码中的其他方法前，需要使用 `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__ 命令
去调用 ``Init()`` 方法。

Use the `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__
command to commit the chaincode definition. This command will also deploy the
collection definition to the channel.

:guilabel:`动手试一试`

We are ready to use the chaincode after the chaincode definition has been
committed to the channel. Because the marbles private data chaincode contains an
initiation function, we need to use the `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__ command
to invoke ``Init()`` before we can use other functions in the chaincode.

1. 运行如下命令提交弹珠私有数据示例链码定义到 ``mychannel`` 通道。

:guilabel:`Try it yourself`

.. code:: bash

1. Run the following commands to commit the definition of the marbles private
data chaincode to the channel ``mychannel``.

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --sequence 1 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

.. code:: bash


    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --sequence 1 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

 提交成功后，你会看到类似如下的输出信息：



When the commit transaction completes successfully you should see something
similar to:

.. code:: bash

    2020-01-06 16:24:46.104 EST [chaincodeCmd] ClientWait -> INFO 001 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:9051
    2020-01-06 16:24:46.184 EST [chaincodeCmd] ClientWait -> INFO 002 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:7051

2. 运行如下命令，调用 ``Init`` 方法初始化链码：

.. _pd-store-private-data:

.. code:: bash

Store private data
------------------

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --isInit --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA -c '{"Args":["Init"]}'

Acting as a member of Org1, who is authorized to transact with all of the private data
in the marbles private data sample, switch back to an Org1 peer and
submit a request to add a marble:

.. _pd-store-private-data:

:guilabel:`Try it yourself`

存储私有数据
------------------

Copy and paste the following set of commands into your CLI in the `test-network`
directory:

Org1 的成员已经被授权使用弹珠私有数据示例中的所有私有数据进行交易，切换回 Org1 节点并提交添加一个弹珠的请求：

.. code :: bash

:guilabel:`动手试一试`

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

在 CLI 的 `test-network` 的目录中，复制粘贴如下命令：

Invoke the marbles ``initMarble`` function which
creates a marble with private data ---  name ``marble1`` owned by ``tom`` with a color
``blue``, size ``35`` and price of ``99``. Recall that private data **price**
will be stored separately from the private data **name, owner, color, size**.
For this reason, the ``initMarble`` function calls the ``PutPrivateData()`` API
twice to persist the private data, once for each collection. Also note that
the private data is passed using the ``--transient`` flag. Inputs passed
as transient data will not be persisted in the transaction in order to keep
the data private. Transient data is passed as binary data and therefore when
using CLI it must be base64 encoded. We use an environment variable
to capture the base64 encoded value, and use ``tr`` command to strip off the
problematic newline characters that linux base64 command adds.


.. code:: bash

.. code :: bash

    export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["InitMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

You should see results similar to:

调用 ``initMarble`` 方法，将会创建一个带有私有数据的弹珠，该弹珠名为 ``marble1``，所有者为 ``tom``，颜色为 ``blue``，尺寸为 ``35``，价格为 ``99``。重申一下，私有数据 **price** 将会和私有数据 **name, owner, color, size** 分开存储。因此, ``initMarble`` 方法会调用 ``PutPrivateData()`` 接口两次来存储私有数据。另外注意，传递私有数据时使用 ``--transient`` 参数。作为瞬态的输入不会被记录到交易中，以此来保证数据的隐私性。瞬态数据会以二进制的方式被传输，所以在 CLI 中使用时，必须使用 base64 编码。我们设置一个环境变量来获取 base64 编码后的值，并使用 ``tr`` 命令来去掉 linux base64 命令添加的换行符。

.. code:: bash

.. code:: bash

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

    export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

.. _pd-query-authorized:

你会看到类似如下的输出结果:

Query the private data as an authorized peer
--------------------------------------------

.. code:: bash

Our collection definition allows all members of Org1 and Org2
to have the ``name, color, size, owner`` private data in their side database,
but only peers in Org1 can have the ``price`` private data in their side
database. As an authorized peer in Org1, we will query both sets of private data.

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

The first ``query`` command calls the ``readMarble`` function which passes
``collectionMarbles`` as an argument.

.. _pd-query-authorized:

.. code-block:: GO

授权节点查询私有数据
--------------------------------------------

   // ===============================================
   // readMarble - read a marble from chaincode state
   // ===============================================

我们的集合定义定义允许 Org1 和 Org2 的所有成员在他们的侧数据库中保存 ``name, color, size, owner`` 私有数据，但是只有 Org1 的成员才可以在他们的侧数据库中保存 ``price``私有数据。作为一个已授权的 Org1 的节点，我们可以查询两个私有数据集。

   func (t *SimpleChaincode) readMarble(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error
   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

第一个 ``query`` 命令调用了 ``readMarble`` 方法并将 ``collectionMarbles`` 作为参数传入。

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarbles", name) //get the marble from chaincode state

.. code-block:: GO

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get state for " + name + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}

   // ===============================================
   // readMarble - read a marble from chaincode state
   // ===============================================

   	return shim.Success(valAsbytes)
   }

   func (t *SimpleChaincode) readMarble(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error
   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

The second ``query`` command calls the ``readMarblePrivateDetails``
function which passes ``collectionMarblePrivateDetails`` as an argument.

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarbles", name) //get the marble from chaincode state

.. code-block:: GO

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get state for " + name + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}

   // ===============================================
   // readMarblePrivateDetails - read a marble private details from chaincode state
   // ===============================================

   	return shim.Success(valAsbytes)
   }

   func (t *SimpleChaincode) readMarblePrivateDetails(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error

第二个 ``query`` 命令调用了 ``readMarblePrivateDetails`` 方法，
并将 ``collectionMarblePrivateDetails`` 作为参数传入。

   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

.. code-block:: GO

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarblePrivateDetails", name) //get the marble private details from chaincode state

   // ===============================================
   // readMarblePrivateDetails - read a marble private details from chaincode state
   // ===============================================

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get private details for " + name + ": " + err.Error() + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble private details does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}
   	return shim.Success(valAsbytes)
   }

   func (t *SimpleChaincode) readMarblePrivateDetails(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error

Now :guilabel:`Try it yourself`

   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

Query for the ``name, color, size and owner`` private data of ``marble1`` as a member of Org1.
Note that since queries do not get recorded on the ledger, there is no need to pass
the marble name as a transient input.

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarblePrivateDetails", name) //get the marble private details from chaincode state

.. code:: bash

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get private details for " + name + ": " + err.Error() + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble private details does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}
   	return shim.Success(valAsbytes)
   }

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarble","marble1"]}'

Now :guilabel:`动手试一试`

You should see the following result:

用 Org1 的成员来查询 ``marble1`` 的私有数据 ``name, color, size 和 owner``。注意，因为查询操作不会在账本上留下记录，因此没必要以瞬态的方式传入弹珠名称。

.. code:: bash

.. code:: bash

    {"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

Query for the ``price`` private data of ``marble1`` as a member of Org1.

你会看到如下输出结果：

.. code:: bash

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

    {"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}

You should see the following result:

Query for the ``price`` private data of ``marble1`` as a member of Org1.

.. code:: bash

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

.. _pd-query-unauthorized:

你会看到如下输出结果：

Query the private data as an unauthorized peer
----------------------------------------------

.. code:: bash

Now we will switch to a member of Org2. Org2 has the marbles private data
``name, color, size, owner`` in its side database, but does not store the
marbles ``price`` data. We will query for both sets of private data.

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

Switch to a peer in Org2
~~~~~~~~~~~~~~~~~~~~~~~~

.. _pd-query-unauthorized:

Run the following commands to operate as the Org2 admin and query the Org2 peer.

未授权节点查询私有数据
-----------------------------------------------------

:guilabel:`Try it yourself`

现在我们将切换到 Org2 的成员。Org2 在侧数据库中存有私有数据 ``name, color, size, owner``，但是不存储弹珠的 ``price`` 数据。我们来同时查询两个私有数据集。

.. code:: bash

切换到 Org2 的节点
~~~~~~~~~~~~~~~~~~~~~~~~

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

运行如下命令以 Org2 管理员的身份操作并查询 Org2 节点：

Query private data Org2 is authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:guilabel:`动手试一试`

Peers in Org2 should have the first set of marbles private data (``name,
color, size and owner``) in their side database and can access it using the
``readMarble()`` function which is called with the ``collectionMarbles``
argument.

.. code:: bash

:guilabel:`Try it yourself`

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

.. code:: bash

查询 Org2 被授权的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarble","marble1"]}'

Org2 的节点应该拥有第一个私有数据集（``name, color, size and owner``）的访问权限，可以使用 ``readMarble()`` 方法，该方法使用了 ``collectionMarbles`` 参数。

You should see something similar to the following result:

:guilabel:`动手试一试`

.. code:: json

.. code:: bash

    {"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

Query private data Org2 is not authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

你会看到类似如下的输出结果：

Peers in Org2 do not have the marbles ``price`` private data in their side database.
When they try to query for this data, they get back a hash of the key matching
the public state but will not have the private state.

.. code:: json

:guilabel:`Try it yourself`

    {"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}

.. code:: bash

查询 Org2 未被授权的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

Org2 的节点的侧数据库中不存在 ``price`` 数据。当你尝试查询这个数据时，将会返回一个公共状态中对应键的 hash 值，但并不会返回私有状态。

You should see a result similar to:

:guilabel:`动手试一试`

.. code:: json

.. code:: bash

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Failed to get private details for marble1:
    GET_STATE failed: transaction ID: d9c437d862de66755076aeebe79e7727791981606ae1cb685642c93f102b03e5:
    tx creator does not have read access permission on privatedata in chaincodeName:marblesp collectionName: collectionMarblePrivateDetails\"}"

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

Members of Org2 will only be able to see the public hash of the private data.

你会看到类似如下的输出结果：

.. _pd-purge:

.. code:: json

Purge Private Data
------------------

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Failed to get private details for marble1:
    GET_STATE failed: transaction ID: d9c437d862de66755076aeebe79e7727791981606ae1cb685642c93f102b03e5:
    tx creator does not have read access permission on privatedata in chaincodeName:marblesp collectionName: collectionMarblePrivateDetails\"}"

For use cases where private data only needs to be on the ledger until it can be
replicated into an off-chain database, it is possible to "purge" the data after
a certain set number of blocks, leaving behind only hash of the data that serves
as immutable evidence of the transaction.

Org2 的成员，将只能看到私有数据的公共 hash。

There may be private data including personal or confidential
information, such as the pricing data in our example, that the transacting
parties don't want disclosed to other organizations on the channel. Thus, it
has a limited lifespan, and can be purged after existing unchanged on the
blockchain for a designated number of blocks using the ``blockToLive`` property
in the collection definition.

.. _pd-purge:

Our ``collectionMarblePrivateDetails`` definition has a ``blockToLive``
property value of three meaning this data will live on the side database for
three blocks and then after that it will get purged. Tying all of the pieces
together, recall this collection definition  ``collectionMarblePrivateDetails``
is associated with the ``price`` private data in the  ``initMarble()`` function
when it calls the ``PutPrivateData()`` API and passes the
``collectionMarblePrivateDetails`` as an argument.

清除私有数据
------------------

We will step through adding blocks to the chain, and then watch the price
information get purged by issuing four new transactions (Create a new marble,
followed by three marble transfers) which adds four new blocks to the chain.
After the fourth transaction (third marble transfer), we will verify that the
price private data is purged.

对于一些案例，私有数据仅需在账本上保存到在链下数据库复制之后就可以了，我们可以将 数据在过了一定数量的区块后进行“清除”，仅仅把数据的哈希作为交易不可篡改的证据保存下来。

:guilabel:`Try it yourself`

私有数据可能会包含私人的或者机密的信息，比如我们例子中的价格数据，这是交易伙伴不想让通道中的其他组织知道的。而且，它具有有限的生命周期，就可以根据集合定义中的 ``blockToLive`` 属性在固定的区块数量之后清除。

Switch back to Org1 using the following commands. Copy and paste the following code
block and run it inside your peer container:

我们的 ``collectionMarblePrivateDetails`` 中定义的 ``blockToLive`` 值为3，表明这个数据会在侧数据库中保存三个区块的时间，之后它就会被清除。将所有内容放在一起，回想一下绑定了私有数据 ``price`` 的私有数据集 ``collectionMarblePrivateDetails``，在函数 ``initMarble()`` 中，当调用 ``PutPrivateData()`` API 并传递了参数 ``collectionMarblePrivateDetails``。

.. code :: bash

我们将在链上增加区块，然后来通过执行四笔新交易（创建一个新弹珠，然后转移三个 弹珠）看一看价格信息被清除的过程，增加新交易的过程中会在链上增加四个新区块。在第四笔交易完成之后（第三个弹珠转移后），我们将验证一下价格私有数据是否被清除了。

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

:guilabel:`动手试一试`

Open a new terminal window and view the private data logs for this peer by
running the following command. Note the highest block number.

使用如下命令切换到 Org1 。复制和粘贴下边的一组命令到节点容器并执行：

.. code:: bash

.. code :: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051


打开一个新终端窗口，通过运行如下命令来查看这个节点上私有数据日志。注意当前区块高度。

Back in the peer container, query for the **marble1** price data by running the
following command. (A Query does not create a new transaction on the ledger
since no data is transacted).

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

回到节点容器中，使用如下命令查询 **marble1** 的 ``price`` 数据（查询并不会产生一笔新的交易）。

You should see results similar to:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

你将看到类似下边的结果：

The ``price`` data is still in the private data ledger.

.. code:: bash

Create a new **marble2** by issuing the following command. This transaction
creates a new block on the chain.

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

.. code:: bash

``price`` 数据仍然存在于私有数据库上。

    export MARBLE=$(echo -n "{\"name\":\"marble2\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["InitMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

执行如下命令创建一个新的 **marble2**。这个交易将在链上创建一个新区块。

Switch back to the Terminal window and view the private data logs for this peer
again. You should see the block height increase by 1.

.. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble2\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1。

Back in the peer container, query for the **marble1** price data again by
running the following command:

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

返回到节点容器，运行如下命令查询 **marble1** 的价格数据：

The private data has not been purged, therefore the results are unchanged from
previous query:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

私有数据没有被清除，查询结果也没有改变：

Transfer marble2 to "joe" by running the following command. This transaction
will add a second new block on the chain.

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"joe\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

运行下边的命令将 marble2 转移给 “joe” 。这个交易将使链上增加第二个区块。

Switch back to the Terminal window and view the private data logs for this peer
again. You should see the block height increase by 1.

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"joe\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

Back in the peer container, query for the marble1 price data by running the
following command:

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

You should still be able to see the price private data.

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

你仍然可以看到价格。

Transfer marble2 to "tom" by running the following command. This transaction
will create a third new block on the chain.

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"tom\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

运行下边的命令将 marble2 转移给 “tom” 。这个交易将使链上增加第三个区块。

Switch back to the Terminal window and view the private data logs for this peer
again. You should see the block height increase by 1.

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"tom\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

Back in the peer container, query for the marble1 price data by running the
following command:

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

You should still be able to see the price data.

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

你仍然可以看到价格数据。

Finally, transfer marble2 to "jerry" by running the following command. This
transaction will create a fourth new block on the chain. The ``price`` private
data should be purged after this transaction.

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"jerry\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

最后，运行下边的命令将 marble2 转移给 “jerry” 。这个交易将使链上增加第四个区块。在此次交易之后，``price`` 私有数据将会被清除。

Switch back to the Terminal window and view the private data logs for this peer
again. You should see the block height increase by 1.

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"jerry\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

Back in the peer container, query for the marble1 price data by running the following command:

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

Because the price data has been purged, you should no longer be able to see it.
You should see something similar to:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Marble private details does not exist: marble1\"}"

因为价格数据已经被清除了，所以你就查询不到了。你应该会看到类似下边的结果：

.. _pd-indexes:

.. code:: bash

Using indexes with private data
-------------------------------

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Marble private details does not exist: marble1\"}"

Indexes can also be applied to private data collections, by packaging indexes in
the ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` directory
alongside the chaincode. An example index is available `here <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ .

.. _pd-indexes:

For deployment of chaincode to production environments, it is recommended
to define any indexes alongside chaincode so that the chaincode and supporting
indexes are deployed automatically as a unit, once the chaincode has been
installed on a peer and instantiated on a channel. The associated indexes are
automatically deployed upon chaincode instantiation on the channel when
the  ``--collections-config`` flag is specified pointing to the location of
the collection JSON file.

使用私有数据索引
-------------------------------


可以通过打包链码目录中的索引 ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` 目录，将索引也用于私有数据数据集。`这里 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ 有一个可用的索引示例。

.. _pd-ref-material:

在生产环境中部署链码时，建议在链码目录中定义所有索引，这样当链码在通道中的节点上安装和初始化的时候就可以自动作为一个单元自动部署。当使用 ``--collections-config`` 标识私有数据集的 JSON 文件路径时，通道上链码初始化的时候相关的索引会自动被部署。

Additional resources
--------------------

.. _pd-ref-material:

For additional private data education, a video tutorial has been created.

其他资源
--------------------

.. note:: The video uses the previous lifecycle model to install private data
          collections with chaincode.

这里有一个额外的私有数据学习的视频。

.. raw:: html

.. note:: 这个视频用的是旧版本的生命周期模型安装私有数据集合。

   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>

.. raw:: html

   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>
