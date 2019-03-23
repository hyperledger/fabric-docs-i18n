
Using Private Data in Fabric - 在 Fabric 中使用私有数据
============================

This tutorial will demonstrate the use of collections to provide storage
and retrieval of private data on the blockchain network for authorized peers
of organizations.

本教程将演示收集器（collection）的使用，收集器为区块链网络上已授权的组织节点
提供私有数据的存储和检索。

The information in this tutorial assumes knowledge of private data
stores and their use cases. For more information, check out :doc:`private-data/private-data`.

本教程假设您已了解私有数据的存储和他们的用例。更多的信息请参阅 :doc:`private-data/private-data` 。

The tutorial will take you through the following steps to practice defining,
configuring and using private data with Fabric:

本教程将带你通过以下步骤练习在 Fabric 中定义、配置和使用私有数据：

#. :ref:`pd-build-json`
#. :ref:`pd-read-write-private-data`
#. :ref:`pd-install-instantiate_cc`
#. :ref:`pd-store-private-data`
#. :ref:`pd-query-authorized`
#. :ref:`pd-query-unauthorized`
#. :ref:`pd-purge`
#. :ref:`pd-indexes`
#. :ref:`pd-ref-material`

This tutorial will use the `marbles private data sample <https://github.com/hyperledger/fabric-samples/tree/master/chaincode/marbles02_private>`__
--- running on the Building Your First Network (BYFN) tutorial network --- to
demonstrate how to create, deploy, and use a collection of private data.
The marbles private data sample will be deployed to the :doc:`build_network`
(BYFN) tutorial network. You should have completed the task :doc:`install`;
however, running the BYFN tutorial is not a prerequisite for this tutorial.
Instead the necessary commands are provided throughout this tutorial to use the
network. We will describe what is happening at each step, making it possible to
understand the tutorial without actually running the sample.

本教程将使用 `弹珠私有数据示例（marbles private data sample） <https://github.com/hyperledger/fabric-samples/tree/master/chaincode/marbles02_private>`__ 
--- 运行在“构建你的第一个网络（BYFN）”教程的网络上 --- 来演示创建、部署和使用私有数
据收集器。弹珠私有数据示例将部署在 :doc:`build_network` （BYFN）教程的网络上。你
需要先完成 :doc:`install` 任务；但是在本教程中不需要运行 BYFN 教程。除了本教程中提
供的使用网络所必须的命令，我们还会讲解每一步都发生了什么，让你不运行示例也可以理解
每一步的意义。

.. _pd-build-json:

Build a collection definition JSON file - 创建一个收集器的 JSON 定义文件
------------------------------------------

The first step in privatizing data on a channel is to build a collection
definition which defines access to the private data.

在通道中数据私有化的第一步是创建一个定义了私有数据权限的收集器。

The collection definition describes who can persist data, how many peers the
data is distributed to, how many peers are required to disseminate the private
data, and how long the private data is persisted in the private database. Later,
we will demonstrate how chaincode APIs ``PutPrivateData`` and ``GetPrivateData``
are used to map the collection to the private data being secured.

收集器定义描述了谁可以持有数据、数据要分发到多少个节点上、多少节点可以传播私有数据
和私有数据要在私有数据库中存放多久。然后，我们将演示链码 API ``PutPrivateData`` 和 
``GetPrivateData`` 是如何将收集器映射到受保护的私有数据的。

A collection definition is composed of the following properties:

收集器的定义包括一下属性：

.. _blockToLive:

- ``name``: Name of the collection.
  
- ``name`` ： 收集器的名字。

- ``policy``: Defines the organization peers allowed to persist the collection data.

- ``policy`` ：定义了可以持有数据收集器的组织节点。

- ``requiredPeerCount``: Number of peers required to disseminate the private data as
  a condition of the endorsement of the chaincode

- ``requiredPeerCount`` ： 作为链码的背书条件，需要将私有数据传播到的节点数量。

- ``maxPeerCount``: For data redundancy purposes, the number of other peers
  that the current endorsing peer will attempt to distribute the data to.
  If an endorsing peer goes down, these other peers are available at commit time
  if there are requests to pull the private data.

- ``maxPeerCount`` ： 为了数据冗余，现有背书节点需要尝试将数据分发到其他节点的数量。如
  果背书节点发生故障，当有请求提取私有数据时，则其他节点在提交时可用。

- ``blockToLive``: For very sensitive information such as pricing or personal information,
  this value represents how long the data should live on the private database in terms
  of blocks. The data will live for this specified number of blocks on the private database
  and after that it will get purged, making this data obsolete from the network.
  To keep private data indefinitely, that is, to never purge private data, set
  the ``blockToLive`` property to ``0``.

- ``blockToLive`` ： 对于非常敏感的信息，比如价格或者个人信息，这个值表示在数据要以区块
  的形式在私有数据库中存放的时间。数据将在私有数据库中存在指定数量的区块数然后会被清除，
  也就是数据会从网络中废弃。要永久保存私有数据，永远不被清除，就设置 ``blockToLive`` 为 ``0`` 。

- ``memberOnlyRead``: a value of ``true`` indicates that peers automatically
  enforce that only clients belonging to one of the collection member organizations
  are allowed read access to private data.

- ``memberOnlyRead`` ： 值为 ``true`` 则表示节点会自动强制只有属于收集器成员组织的客户端才
  有读取私有数据的权限。

To illustrate usage of private data, the marbles private data example contains
two private data collection definitions: ``collectionMarbles``
and ``collectionMarblePrivateDetails``. The ``policy`` property in the
``collectionMarbles`` definition allows all members of  the channel (Org1 and
Org2) to have the private data in a private database. The
``collectionMarblesPrivateDetails`` collection allows only members of Org1 to
have the private data in their private database.

为了说明私有数据的用法，弹珠私有数据示例包含了两个私有数据收集器的定义： ``collectionMarbles`` 
和 ``collectionMarblePrivateDetails`` 。在 ``collectionMarbles`` 中的 ``policy`` 属性
定义了允许通道中（Org1 和 Org2）所有成员使用私有数据库中的私有数据。 ``collectionMarblePrivateDetails`` 
收集器只允许 Org1 的成员使用私有数据库中的私有数据。

For more information on building a policy definition refer to the :doc:`endorsement-policies`
topic.

创建策略定义的更多信息请参考 :doc:`endorsement-policies` 主题。

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

The data to be secured by these policies is mapped in chaincode and will be
shown later in the tutorial.

被这些策略保护的数据会被映射到链码，教程的后边会进行介绍。

This collection definition file is deployed on the channel when its associated
chaincode is instantiated on the channel using the `peer chaincode instantiate command <http://hyperledger-fabric.readthedocs.io/en/latest/commands/peerchaincode.html#peer-chaincode-instantiate>`__.
More details on this process are provided in Section 3 below.

当和它关联的链码在通道上参照 
`节点链码初始化命令（peer chaincode instantiate command） <http://hyperledger-fabric.readthedocs.io/en/latest/commands/peerchaincode.html#peer-chaincode-instantiate>`__ 
初始化以后，这个收集器定义文件会被部署到通道上。更多的细节会在下边的三个部分讲解。

.. _pd-read-write-private-data:

Read and Write private data using chaincode APIs - 使用链码 API 读写私有数据
------------------------------------------------

The next step in understanding how to privatize data on a channel is to build
the data definition in the chaincode.  The marbles private data sample divides
the private data into two separate data definitions according to how the data will
be accessed.

理解如何在通道上私有化数据的下一步工作是构建链码的数据定义。弹珠私有数据示例根据数
据的使用权限将私有数据分成了两个部分。

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

Specifically access to the private data will be restricted as follows:

私有数据的特定权限将会被限制为如下：

- ``name, color, size, and owner`` will be visible to all members of the channel (Org1 and Org2)

- ``name, color, size, and owner`` 通道中所有成员可见（Org1 and Org2）

- ``price`` only visible to members of Org1 

- ``price`` 只有 Org1 的成员可见

Thus two different sets of private data are defined in the marbles private data
sample. The mapping of this data to the collection policy which restricts its
access is controlled by chaincode APIs. Specifically, reading and writing
private data using a collection definition is performed by calling ``GetPrivateData()``
and ``PutPrivateData()``, which can be found `here <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/interfaces.go#L179>`_.

在弹珠私有数据示例中定义了两个不同的私有数据收集器。数据映射到收集器策略（权
限限制）是通过链码 API 控制的。特别地，使用收集器定义进行读和写私有数据是通过调用 
``GetPrivateData()`` 和 ``PutPrivateData()`` 来实现的，你可以在 
`这里 <https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/interfaces.go#L179>`_ 
找到。

The following diagrams illustrate the private data model used by the marbles
private data sample.

下边的图片阐明了弹珠私有数据示例所使用的私有数据模型。

 .. image:: images/SideDB-org1.png

 .. image:: images/SideDB-org2.png


Reading collection data - 读取收集器数据
~~~~~~~~~~~~~~~~~~~~~~~~

Use the chaincode API ``GetPrivateData()`` to query private data in the
database.  ``GetPrivateData()`` takes two arguments, the **collection name**
and the data key. Recall the collection  ``collectionMarbles`` allows members of
Org1 and Org2 to have the private data in a side database, and the collection
``collectionMarblePrivateDetails`` allows only members of Org1 to have the
private data in a side database. For implementation details refer to the
following two `marbles private data functions <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__:

使用链码 API ``GetPrivateData()`` 来查询数据库中的私有数据。 ``GetPrivateData()`` 
需要两个参数， **收集器名** 和数据的键值。再说一下收集器 ``collectionMarbles`` 允许 
Org1 和 Org2 的成员使用侧数据库中的私有数据，收集器 ``collectionMarblePrivateDetails`` 
只允许 Org1 的成员使用侧数据库中的私有数据。详情请参阅下边的两个 
`弹珠私有数据函数（marbles private data functions） <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__ ：

 * **readMarble** for querying the values of the ``name, color, size and owner`` attributes
 * **readMarble** 用于查询 ``name, color, size and owner`` 属性的值
 * **readMarblePrivateDetails** for querying the values of the ``price`` attribute
 * **readMarblePrivateDetails** 用于查询 ``price`` 属性的值

When we issue the database queries using the peer commands later in this tutorial,
we will call these two functions.

本教程后边在节点上执行数据库查询的命令时，我们就是调用这两个函数。

Writing private data - 写入私有数据
~~~~~~~~~~~~~~~~~~~~

Use the chaincode API ``PutPrivateData()`` to store the private data
into the private database. The API also requires the name of the collection.
Since the marbles private data sample includes two different collections, it is called
twice in the chaincode:

使用链码 API ``PutPrivateData()`` 将私有数据存入私有数据库。这个 API 同样需要收集器的
名字。因为弹珠私有数据示例包含两个不同的收集器，它在链码中会被调用两次：

1. Write the private data ``name, color, size and owner`` using the
   collection named ``collectionMarbles``.
2. Write the private data ``price`` using the collection named
   ``collectionMarblePrivateDetails``.

1. 使用名为 ``collectionMarbles`` 的收集器写入私有数据 ``name, color, size and owner`` 。 
2. 使用名为 ``collectionMarblePrivateDetails`` 的收集器写入私有数据 ``price`` 。 

For example, in the following snippet of the ``initMarble`` function,
``PutPrivateData()`` is called twice, once for each set of private data.

例如，在下边的 ``initMarble`` 函数片段中， ``PutPrivateData()`` 被调用了两次，
每个私有数据集合各一次。

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


To summarize, the policy definition above for our ``collection.json``
allows all peers in Org1 and Org2 to store and transact
with the marbles private data ``name, color, size, owner`` in their
private database. But only peers in Org1 can store and transact with
the ``price`` private data in its private database.

总结一下，上边我们为 ``collection.json`` 定义的策略允许 Org1 和 Org2 的所有
节点在他们的私有数据库中存储和交易弹珠的私有数据 ``name, color, size, owner`` 。
但是只有 Org1 的节点可以在他的私有数据库中存储和交易 ``price`` 私有数据。

As an additional data privacy benefit, since a collection is being used,
only the private data hashes go through orderer, not the private data itself,
keeping private data confidential from orderer.

数据私有的一个额外的好处是，当使用了收集器以后，只有私有数据的哈希会通过排序节点，
而不是私有数据本身，从排序方面保证了私有数据的机密性。

Start the network - 启动网络
-----------------

Now we are ready to step through some commands which demonstrate using private
data.

现在我们准备通过一些命令来演示使用私有数据。

 :guilabel:`Try it yourself`

 Before installing and instantiating the marbles private data chaincode below,
 we need to start the BYFN network. For the sake of this tutorial, we want to
 operate from a known initial state. The following command will kill any active
 or stale docker containers and remove previously generated artifacts.
 Therefore let's run the following command to clean up any previous
 environments:

 在安装和初始化弹珠私有数据链码之前，我们需要启动 BYFN 网络。为了本教程，我们需要
 在一个已知的初始化环境下操作。下边的命令会关闭所有活动状态的或者存在的 docker 容
 器并删除之前生成的构件。让我们运行下边的命令来清理之前的环境：

 .. code:: bash

    cd fabric-samples/first-network
    ./byfn.sh down


 If you've already run through this tutorial, you'll also want to delete the
 underlying docker containers for the marbles private data chaincode. Let's
 run the following commands to clean up previous environments:

 如果你之前运行过本教程，你需要删除弹珠私有数据链码的 docker 容器。让我们运行下边
 的命令清理之前的环境：

 .. code:: bash

    docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*.marblesp.*/) {print $1}')
    docker rmi -f $(docker images | awk '($1 ~ /dev-peer.*.marblesp.*/) {print $3}')

 Start up the BYFN network with CouchDB by running the following command:

 运行下边的命令来启动使用了 CouchDB 的 BYFN 网络：

 .. code:: bash

    ./byfn.sh up -c mychannel -s couchdb

 This will create a simple Fabric network consisting of a single channel named
 ``mychannel`` with two organizations (each maintaining two peer nodes) and an
 ordering service while using CouchDB as the state database. Either LevelDB
 or CouchDB may be used with collections. CouchDB was chosen to demonstrate
 how to use indexes with private data.

 这会创建一个简单的 Fabric 网络，包含一个名为 ``mychannel`` 的通道，其中有两个组织
 （每个组织有两个 peer 节点）和一个排序服务，同时使用 CouchDB 作为状态数据库。LevelDB 
 或者 CouchDB 都可以使用收集器。这里使用 CouchDB 来演示如何对私有数据进行索引。

 .. note:: For collections to work, it is important to have cross organizational
           gossip configured correctly. Refer to our documentation on :doc:`gossip`,
           paying particular attention to the section on "anchor peers". Our tutorial
           does not focus on gossip given it is already configured in the BYFN sample,
           but when configuring a channel, the gossip anchors peers are critical to
           configure for collections to work properly.

 .. note:: 为了让收集器能够工作，正确配置跨组织的 gossip 是很重要的。参考文档 :doc:`gossip` ，
           重点关注 "锚节点" 部分。我们的教程不关注 gossip ，它已经在 BYFN 示例中配置过了，
           但是当配置通道的时候，gossip 锚节点的配置对于收集器的正常工作是很重要的。

.. _pd-install-instantiate_cc:

Install and instantiate chaincode with a collection - 安装和初始化带有收集器的链码
---------------------------------------------------

Client applications interact with the blockchain ledger through chaincode. As
such we need to install and instantiate the chaincode on every peer that will
execute and endorse our transactions. Chaincode is installed onto a peer and
then instantiated onto the channel using :doc:`peer-commands`.

客户端应用通过链码和区块链账本交互。所以我们需要在每一个要执行和背书交易的节点
上安装和初始化链码。链码安装在节点上然后在通道上使用 :doc:`peer-commands` 进行初始化。

Install chaincode on all peers - 在所有节点上安装链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As discussed above, the BYFN network includes two organizations, Org1 and Org2,
with two peers each. Therefore the chaincode has to be installed on four peers:

就像上边讨论的，BYFN 网络包含两个组织， Org1 和 Org2 ，每个组织有两个节点。所以
链码需要安装在四个节点上：

- peer0.org1.example.com
- peer1.org1.example.com
- peer0.org2.example.com
- peer1.org2.example.com

Use the `peer chaincode install <http://hyperledger-fabric.readthedocs.io/en/master/commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-install>`__ command to install the Marbles chaincode on each peer.

使用 `peer chaincode install <http://hyperledger-fabric.readthedocs.io/en/master/commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-install>`__ 
命令在每一个节点上安装弹珠链码。

 :guilabel:`Try it yourself`

 Assuming you have started the BYFN network, enter the CLI container.

 如果你已经启动了 BYFN 网络，进入 CLI 容器。

 .. code:: bash

    docker exec -it cli bash

 Your command prompt will change to something similar to:

 你的终端会变成类似这样的：

 ``root@81eac8493633:/opt/gopath/src/github.com/hyperledger/fabric/peer#``

 1. Use the following command to install the Marbles chaincode from the git
    repository onto the peer ``peer0.org1.example.com`` in your BYFN network.
    (By default, after starting the BYFN network, the active peer is set to:
    ``CORE_PEER_ADDRESS=peer0.org1.example.com:7051``):

 1. 使用下边的命令在 BYFN 网络上，安装 git 仓库的弹珠链码到节点 ``peer0.org1.example.com`` 
    （默认情况下，启动 BYFN 网络以后，激活的节点被设置成了
    ``CORE_PEER_ADDRESS=peer0.org1.example.com:7051`` ）：

    .. code:: bash

       peer chaincode install -n marblesp -v 1.0 -p github.com/chaincode/marbles02_private/go/

    When it is complete you should see something similar to:

    当完成之后，你会看到类似输出：

    .. code:: bash

       install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >

 2. Use the CLI to switch the active peer to the second peer in Org1 and
    install the chaincode. Copy and paste the following entire block of
    commands into the CLI container and run them.

 2. 利用 CLI 切换当前节点为 Org1 的第二个节点并安装链码。复制和粘贴下边的命令
    到 CLI 容器并运行他们。

    .. code:: bash

       export CORE_PEER_ADDRESS=peer1.org1.example.com:7051
       peer chaincode install -n marblesp -v 1.0 -p github.com/chaincode/marbles02_private/go/

 3. Use the CLI to switch to Org2. Copy and paste the following block of
    commands as a group into the peer container and run them all at once.

 3. 利用 CLI 切换到 Org2 。复制和粘贴下边的一组命令到节点容器并执行。

    .. code:: bash

       export CORE_PEER_LOCALMSPID=Org2MSP
       export PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
       export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
       export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

 4. Switch the active peer to the first peer in Org2 and install the chaincode:

 4. 切换当前节点为 Org2 的第一个节点并安装链码：

    .. code:: bash

       export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
       peer chaincode install -n marblesp -v 1.0 -p github.com/chaincode/marbles02_private/go/

 5. Switch the active peer to the second peer in org2 and install the chaincode:

 5. 切换当前节点为 Org2 的第二个节点并安装链码：

    .. code:: bash

       export CORE_PEER_ADDRESS=peer1.org2.example.com:7051
       peer chaincode install -n marblesp -v 1.0 -p github.com/chaincode/marbles02_private/go/

Instantiate the chaincode on the channel - 在通道上初始化链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `peer chaincode instantiate <http://hyperledger-fabric.readthedocs.io/en/master/commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__
command to instantiate the marbles chaincode on a channel. To configure
the chaincode collections on the channel, specify the flag ``--collections-config``
along with the name of the collections JSON file, ``collections_config.json`` in our
example.

使用 `peer chaincode instantiate <http://hyperledger-fabric.readthedocs.io/en/master/commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__ 
命令在通道上初始化弹珠链码。为了在通道上配置链码收集器，使用 ``--collections-config`` 
标识来指定收集器的 JSON 文件，我们的示例中是 ``collections_config.json`` 。

 :guilabel:`Try it yourself`

 Run the following commands to instantiate the marbles private data
 chaincode on the BYFN channel ``mychannel``.

 在 BYFN 的 ``mychannel`` 通道上运行下边的命令来初始化弹珠私有数据链码。

 .. code:: bash

   export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
   peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n marblesp -v 1.0 -c '{"Args":["init"]}' -P "OR('Org1MSP.member','Org2MSP.member')" --collections-config  $GOPATH/src/github.com/chaincode/marbles02_private/collections_config.json

 .. note:: When specifying the value of the ``--collections-config`` flag, you will
           need to specify the fully qualified path to the collections_config.json file.
           For example: ``--collections-config  $GOPATH/src/github.com/chaincode/marbles02_private/collections_config.json``

 .. note:: 当指定了 ``--collections-config`` 的时候，你需要指明 collections_config.json 
           文件完整清晰的路径。 例如： ``--collections-config  $GOPATH/src/github.com/chaincode/marbles02_private/collections_config.json``

 When the instantiation completes successfully you should see something similar to:

 当成功初始化完成的时候，你可能看到类似下边这些：

 .. code:: bash

    [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
    [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc

 .. _pd-store-private-data:

Store private data - 存储私有数据
------------------

Acting as a member of Org1, who is authorized to transact with all of the private data
in the marbles private data sample, switch back to an Org1 peer and
submit a request to add a marble:

以 Org1 成员的身份操作，Org1 的成员被授权可以交易弹珠私有数据示例中的所有私有数据，切换
回 Org1 的节点并提交一个增加一个弹珠的请求：

 :guilabel:`Try it yourself`

 Copy and paste the following set of commands to the CLI command line.

 复制并粘贴下边的一组命令到 CLI 命令行。

 .. code:: bash

    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

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
 to capture the base64 encoded value.

 调用 ``initMarble`` 函数来创建一个带有私有数据的弹珠 --- 名字为 ``marble1`` ，
 拥有者为 ``tom`` ，颜色为 ``blue`` ，尺寸为 ``35`` ，价格为 ``99`` 。重申一下，私
 有数据 **price** 将会和私有数据 **name, owner, color, size** 分开存储。因为这个原
 因， ``initMarble`` 函数存储私有数据的时候调用两次 ``PutPrivateData()`` API ，每个
 收集器一次。同样要注意到，私有数据传输的时候使用了 ``--transient`` 标识。为了保证
 数据的隐私性，作为临时数据传递的输入不会保存在交易中。临时数据以二进制的方式传输，
 但是当使用 CLI 的时候，必须先进行 base64 编码。我们使用一个环境变量来获得 base64 
 编码的值。

 .. code:: bash

   export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64)
   peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}'  --transient "{\"marble\":\"$MARBLE\"}"

 You should see results similar to:

 你应该会看到类似下边的结果：

 ``[chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200``

.. _pd-query-authorized:

Query the private data as an authorized peer - 使用一个授权节点查询私有数据
--------------------------------------------

Our collection definition allows all members of Org1 and Org2
to have the ``name, color, size, owner`` private data in their side database,
but only peers in Org1 can have the ``price`` private data in their side
database. As an authorized peer in Org1, we will query both sets of private data.

我们收集器的定义允许 Org1 和 Org2 的所有成员在他们的侧数据库中使用 ``name, color, 
size, owner`` 私有数据，但是只有 Org1 的节点可以在他们的侧数据库中保存 ``price`` 
私有数据。作为一个 Org1 中的授权节点，我们将查询两个私有数据集合。

The first ``query`` command calls the ``readMarble`` function which passes
``collectionMarbles`` as an argument.

第一个 ``query`` 命令调用传递了 ``collectionMarbles`` 作为参数的 ``readMarble`` 函数。

.. code-block:: GO

   // ===============================================
   // readMarble - read a marble from chaincode state
   // ===============================================

   func (t *SimpleChaincode) readMarble(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error
   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarbles", name) //get the marble from chaincode state

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get state for " + name + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}

   	return shim.Success(valAsbytes)
   }

The second ``query`` command calls the ``readMarblePrivateDetails``
function which passes ``collectionMarblePrivateDetails`` as an argument.

第二个 ``query`` 命令调用传递了 ``collectionMarblePrivateDetails`` 作为参数
的 ``readMarblePrivateDetails`` 函数。

.. code-block:: GO

   // ===============================================
   // readMarblePrivateDetails - read a marble private details from chaincode state
   // ===============================================

   func (t *SimpleChaincode) readMarblePrivateDetails(stub shim.ChaincodeStubInterface, args []string) pb.Response {
   	var name, jsonResp string
   	var err error

   	if len(args) != 1 {
   		return shim.Error("Incorrect number of arguments. Expecting name of the marble to query")
   	}

   	name = args[0]
   	valAsbytes, err := stub.GetPrivateData("collectionMarblePrivateDetails", name) //get the marble private details from chaincode state

   	if err != nil {
   		jsonResp = "{\"Error\":\"Failed to get private details for " + name + ": " + err.Error() + "\"}"
   		return shim.Error(jsonResp)
   	} else if valAsbytes == nil {
   		jsonResp = "{\"Error\":\"Marble private details does not exist: " + name + "\"}"
   		return shim.Error(jsonResp)
   	}
   	return shim.Success(valAsbytes)
   }

Now :guilabel:`Try it yourself`

 Query for the ``name, color, size and owner`` private data of ``marble1`` as a member of Org1.
 Note that since queries do not get recorded on the ledger, there is no need to pass
 the marble name as a transient input.

 以 Org1 成员的身份查询 ``marble1`` 的私有数据 ``name, color, size and owner`` 。
 注意，由于查询动作不记录在账本上，所以没必要将弹珠名作为临时输入传递。

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

 You should see the following result:

 你应该会看到如下结果：

 .. code:: bash

    {"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}

 Query for the ``price`` private data of ``marble1`` as a member of Org1.

 以 Org1 成员的身份查询 ``marble1`` 的私有数据 ``price`` 。

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 You should see the following result:

 你应该会看到如下结果：

 .. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

.. _pd-query-unauthorized:

Query the private data as an unauthorized peer - 以授权节点的身份查询私有数据
----------------------------------------------

Now we will switch to a member of Org2 which has the marbles private data
``name, color, size, owner`` in its side database, but does not have the
marbles ``price`` private data in its side database. We will query for both
sets of private data.

现在我们将切换到 Org2 成员，在它的侧数据库中有弹珠私有数据的 ``name， color， 
size， owner`` ，但是没有私有数据 ``price`` 。我们将查询两个私有数据集合。

Switch to a peer in Org2 - 切换到 Org2 的节点
~~~~~~~~~~~~~~~~~~~~~~~~

From inside the docker container, run the following commands to switch to
the peer which is unauthorized to access the marbles ``price`` private data.

在 docker 容器内，运行下边的命令切换到有权限访问弹珠私有数据 ``price`` 的节点。

 :guilabel:`Try it yourself`

 .. code:: bash

    export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
    export CORE_PEER_LOCALMSPID=Org2MSP
    export PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

Query private data Org2 is authorized to - 查询 Org2 有权访问的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Peers in Org2 should have the first set of marbles private data (``name,
color, size and owner``) in their side database and can access it using the
``readMarble()`` function which is called with the ``collectionMarbles``
argument.

Org2 的节点在它们的数据库中有弹珠私有数据的第一个集合 （ ``name， color， size and owner`` ）
并且有权限使用 ``readMarble()`` 函数和 ``collectionMarbles`` 参数访问它。

 :guilabel:`Try it yourself`

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

 You should see something similar to the following result:

 你应该会看到类似下边的输出结果：

 .. code:: json

    {"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}

Query private data Org2 is not authorized to - 查询 Org2 没有权限的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Peers in Org2 do not have the marbles ``price`` private data in their side database.
When they try to query for this data, they get back a hash of the key matching
the public state but will not have the private state.

在 Org2 的节点侧数据库中没有弹珠的私有数据 ``price`` 。当它们尝试查询这个数据的时候，
它们会得到符合公共状态键的哈希但是得不到私有数据。

 :guilabel:`Try it yourself`

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 You should see a result similar to:

 你应该会看到如下结果：

 .. code:: json

    {"Error":"Failed to get private details for marble1: GET_STATE failed:
    transaction ID: b04adebbf165ddc90b4ab897171e1daa7d360079ac18e65fa15d84ddfebfae90:
    Private data matching public hash version is not available. Public hash
    version = &version.Height{BlockNum:0x6, TxNum:0x0}, Private data version =
    (*version.Height)(nil)"}

Members of Org2 will only be able to see the public hash of the private data.

Org2 的成员只能看到私有数据的公共哈希。

.. _pd-purge:

Purge Private Data - 清除私有数据
------------------

For use cases where private data only needs to be on the ledger until it can be
replicated into an off-chain database, it is possible to "purge" the data after
a certain set number of blocks, leaving behind only hash of the data that serves
as immutable evidence of the transaction.

对于一些案例，私有数据仅需在账本上保存到在链下数据库复制之后就可以了，我们可以将
数据在过了一定数量的区块后进行 “清除”，仅仅把数据的哈希作为不可篡改的证据保存下来。

There may be private data including personal or confidential
information, such as the pricing data in our example, that the transacting
parties don't want disclosed to other organizations on the channel. Thus, it
has a limited lifespan, and can be purged after existing unchanged on the
blockchain for a designated number of blocks using the ``blockToLive`` property
in the collection definition.

私有数据可能会包含私人的或者机密的信息，比如我们例子中的价格数据，这是交易伙伴不想
让通道中的其他组织知道的。但是，它具有有限的生命周期，就可以根据收集器定义中的，在
固定的区块数量之后清除。 

Our ``collectionMarblePrivateDetails`` definition has a ``blockToLive``
property value of three meaning this data will live on the side database for
three blocks and then after that it will get purged. Tying all of the pieces
together, recall this collection definition  ``collectionMarblePrivateDetails``
is associated with the ``price`` private data in the  ``initMarble()`` function
when it calls the ``PutPrivateData()`` API and passes the
``collectionMarblePrivateDetails`` as an argument.

我们的 ``collectionMarblePrivateDetails`` 中定义 ``blockToLive`` 属性的值为 3 ，
表明这个数据会在侧数据库中保存三个区块的时间，之后它就会被清除。将所有内容放在一
起，回想一下绑定了私有数据 ``price`` 的收集器 ``collectionMarblePrivateDetails`` ，
在函数 ``initMarble()`` 中，当调用 ``PutPrivateData()`` API 并传递了参数 
``collectionMarblePrivateDetails`` 。

We will step through adding blocks to the chain, and then watch the price
information get purged by issuing four new transactions (Create a new marble,
followed by three marble transfers) which adds four new blocks to the chain.
After the fourth transaction (third marble transfer), we will verify that the
price private data is purged.

我们将从在链上增加区块，然后来通过执行四笔新交易（创建一个新弹珠，然后转移三个
弹珠）看一看价格信息被清除的过程，增加新交易的过程中会在链上增加四个新区块。在
第四笔交易完成之后（第三个弹珠转移后），我们将验证一下价格数据是否被清除了。

 :guilabel:`Try it yourself`

 Switch back to peer0 in Org1 using the following commands. Copy and paste the
 following code block and run it inside your peer container:

 使用如下命令切换到 Org1 的 peer0 。复制和粘贴下边的一组命令到节点容器并执行：

 .. code:: bash

    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

 Open a new terminal window and view the private data logs for this peer by
 running the following command:

 打开一个新终端窗口，通过运行如下命令来查看这个节点上私有数据日志：

 .. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

 You should see results similar to the following. Note the highest block number
 in the list. In the example below, the highest block height is ``4``.

 你将看到类似下边的信息。注意列表中最高的区块号。在下边的例子中，最高的区块高度是 ``4`` 。

 .. code:: bash

    [pvtdatastorage] func1 -> INFO 023 Purger started: Purging expired private data till block number [0]
    [pvtdatastorage] func1 -> INFO 024 Purger finished
    [kvledger] CommitWithPvtData -> INFO 022 Channel [mychannel]: Committed block [0] with 1 transaction(s)
    [kvledger] CommitWithPvtData -> INFO 02e Channel [mychannel]: Committed block [1] with 1 transaction(s)
    [kvledger] CommitWithPvtData -> INFO 030 Channel [mychannel]: Committed block [2] with 1 transaction(s)
    [kvledger] CommitWithPvtData -> INFO 036 Channel [mychannel]: Committed block [3] with 1 transaction(s)
    [kvledger] CommitWithPvtData -> INFO 03e Channel [mychannel]: Committed block [4] with 1 transaction(s)

 Back in the peer container, query for the **marble1** price data by running the
 following command. (A Query does not create a new transaction on the ledger
 since no data is transacted).

 返回到节点容器，使用如下命令查询 ``marble1`` 的价格数据。（因为没有发送数据，所
 以查询操作不会在账本上创建新的交易。）

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 You should see results similar to:

 你将看到类似下边的信息：

 .. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

 The ``price`` data is still in the private data ledger.

 ``price`` 数据仍然在私有数据账本上。

 Create a new **marble2** by issuing the following command. This transaction
 creates a new block on the chain.

 通过执行如下命令创建一个新的 **marble2** 。这个交易将在链上创建一个新区块。

 .. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble2\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64)
    peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

 Switch back to the Terminal window and view the private data logs for this peer
 again. You should see the block height increase by 1.

 再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

 .. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

 Back in the peer container, query for the **marble1** price data again by
 running the following command:

 返回到节点容器，再次运行如下命令查询 **marble1** 的价格数据：

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 The private data has not been purged, therefore the results are unchanged from
 previous query:

 私有数据没有被清除，之前的查询也没有改变查询结果：

 .. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

 Transfer marble2 to "joe" by running the following command. This transaction
 will add a second new block on the chain.

 运行下边的命令将 marble2 转移给 “joe” 。这个交易将使链上增加第二个区块。

 .. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"joe\"}" | base64)
    peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

 Switch back to the Terminal window and view the private data logs for this peer
 again. You should see the block height increase by 1.

 再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

 .. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

 Back in the peer container, query for the marble1 price data by running
 the following command:

 返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 You should still be able to see the price private data.

 你将看到价格私有数据。

 .. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

 Transfer marble2 to "tom" by running the following command. This transaction
 will create a third new block on the chain.

 运行下边的命令将 marble2 转移给 “tom” 。这个交易将使链上增加第三个区块。

 .. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"tom\"}" | base64)
    peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

 Switch back to the Terminal window and view the private data logs for this peer
 again. You should see the block height increase by 1.

 再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

 .. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

 Back in the peer container, query for the marble1 price data by running
 the following command:

 返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 You should still be able to see the price data.

 你将看到价格数据。

 .. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

 Finally, transfer marble2 to "jerry" by running the following command. This
 transaction will create a fourth new block on the chain. The ``price`` private
 data should be purged after this transaction.

 最后，运行下边的命令将 marble2 转移给 “jerry” 。这个交易将使链上增加第四个区块。在
 此次交易之后， ``price`` 私有数据将会被清除。

 .. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"jerry\"}" | base64)
    peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

 Switch back to the Terminal window and view the private data logs for this peer
 again. You should see the block height increase by 1.

 再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。
 
 .. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

 Back in the peer container, query for the marble1 price data by running the following command:

 返回到节点容器，再次运行如下命令查询 marble1 的价格数据：

 .. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

 Because the price data has been purged, you should no longer be able to see
 it. You should see something similar to:

 因为价格数据已经被清除了，你就查询不到了。你应该会看到类似下边的结果：

 .. code:: bash

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Marble private details does not exist: marble1\"}"

.. _pd-indexes:

Using indexes with private data - 使用私有数据索引
-------------------------------

Indexes can also be applied to private data collections, by packaging indexes in
the ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` directory
alongside the chaincode. An example index is available `here <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ .

索引也可以用于私有数据收集器，可以通过打包链码旁边的索引  ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` 
来使用。有一个索引的例子在 `这里 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ 。

For deployment of chaincode to production environments, it is recommended
to define any indexes alongside chaincode so that the chaincode and supporting
indexes are deployed automatically as a unit, once the chaincode has been
installed on a peer and instantiated on a channel. The associated indexes are
automatically deployed upon chaincode instantiation on the channel when
the  ``--collections-config`` flag is specified pointing to the location of
the collection JSON file.

在生产环境下部署链码时，建议和链码一起定义索引，这样当链码在通道中的节点上安
装和初始化时就可以自动作为一个单元进行安装。当使用 ``--collections-config`` 标识
指定收集器 JSON 文件路径时，通道上链码初始化的时候相关的索引会自动被部署。


.. _pd-ref-material:

Additional resources - 其他资源
--------------------

For additional private data education, a video tutorial has been created.

这里有一个额外的私有数据学习的视频。

.. raw:: html

   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
