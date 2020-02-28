在 Fabric 中使用私有数据
======================================

本教程将演示如何使用集合在区块链网络中授权的 Peer 节点上存储和检索私有数据。

本教程需要你已经掌握私有数据存储及其使用方法。更多信息，请查看 :doc:`private-data/private-data`。

.. note:: 本教程使用 Fabric-2.0 中新的链码生命管理周期操作。如果你想在之前的版本中使用私有数据，请参阅 v1.4 版本的教程`在 Fabric 中使用私有数据教程 <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__.

本教程将会根据以下步骤带你练习如何在 Fabric 中定义、配置和使用私有数据：

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

.. _pd-build-json:

创建集合定义的 JSON 文件
------------------------------------------

在通道中使用私有数据的第一步是定义集合以决定私有数据的访问权限。

该集合的定义描述了谁可以保存数据，数据要分发给多少个节点，需要多少个节点来进行数据分发，以及私有数据在私有数据库中的保存时间。之后，我们将会展示链码的 API：``PutPrivateData`` 和 ``GetPrivateData`` 将集合映射到私有数据以确保其安全。

集合定义由以下几个属性组成：

.. _blockToLive:

- ``name``: 集合的名称。

- ``policy``: 定义了哪些组织中的 Peer 节点能够存储集合数据。

- ``requiredPeerCount``: 私有数据要分发到的节点数，这是链码背书成功的条件之一。

- ``maxPeerCount``: 为了数据冗余，当前背书节点将尝试向其他节点分发数据的数量。如果当前背书节点发生故障，其他的冗余节点可以承担私有数据查询的任务。

- ``blockToLive``: 对于非常敏感的信息，比如价格或者个人信息，这个值代表书库可以在私有数据库中保存的时间。数据会在私有数据库中保存 ``blockToLive`` 个区块，之后就会被清除。如果要永久保留，将此值设置为 ``0`` 即可。

- ``memberOnlyRead``: 设置为 ``true`` 时，节点会自动强制集合中定义的成员组织内的客户端对私有数据仅拥有只读权限。

为了说明私有数据的用法，弹珠私有数据示例包含两个私有数据集合定义：``collectionMarbles和`` 和 ``collectionMarblePrivateDetails``。``collectionMarbles`` 定义中的 ``policy`` 属性允许通道的所有成员（Org1 和 Org2）在私有数据库中保存私有数据。``collectionMarblesPrivateDetails`` 集合仅允许 Org1 的成员在其私有数据库中保存私有数据。

关于 ``policy`` 属性的更多相关信息，请查看 :doc:`endorsement-policies`。

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

当链码被使用 `peer lifecycle chaincode commit 命令 <http://hyperledger-fabric.readthedocs.io/en/latest/commands/peerchaincode.html#peer-chaincode-instantiate>`__ 提交到通道中时，集合定义文件也会被部署到通道中。更多信息请看下面的第三节。

.. _pd-read-write-private-data:

使用链码 API 读写私有数据-- **REVIEWING** **REVIEWING** **REVIEWING**
------------------------------------------------

接下来演示在链码中如何定义私有数据。marbles 私有数据示例使用了如下的定义。
根据数据的不同访问权限，将私有数据分成两个定义部分：

.. code-block:: GO

 // Peers in Org1 and Org2 will have this private data in a side database
 // 组织1 和 组织2 的节点将会保存以下信息到 旁数据库（SideDB）
 type marble struct {
   ObjectType string `json:"docType"`
   Name       string `json:"name"`
   Color      string `json:"color"`
   Size       int    `json:"size"`
   Owner      string `json:"owner"`
 }

 // Only peers in Org1 will have this private data in a side database
 // 只有 组织1 中的节点 将会保存以下信息到 旁数据库
 type marblePrivateDetails struct {
   ObjectType string `json:"docType"`
   Name       string `json:"name"`
   Price      int    `json:"price"`
 }

对私有数据的访问将遵循以下策略：

- ``name, color, size, and owner`` 通道中所有节点都可见（组织1 和 组织2）
- ``price`` 仅对 组织1 中的节点可见

由此可见，marbles 示例中存在两组不同的私有数据定义。
这些数据存在于集合定义的访问策略将由 链码 APIs 进行控制。
具体讲，就是读取和修改私有数据将会使用 ``GetPrivateData()`` 和 ``PutPrivateData()``接口，
这两个接口会遵循集合的定义。
更多接口定义： `这里 <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_.

下图说明了 marbles 私有数据示例使用的私有数据模型。

.. image:: images/SideDB-org1-org2.png


读取集合数据，即私有数据
~~~~~~~~~~~~~~~~~~~~~~~~

使用链码接口 ``GetPrivateData()`` 去私有数据库访问私有数据。
``GetPrivateData()`` 有两个参数, **collection name**
和 data key. 加强记忆：集合  ``collectionMarbles`` 允许 Org1 和 Org2 访问, 集合
``collectionMarblePrivateDetails`` 只允许 Org1 访问。
有关接口的实现请查看 `marbles private data functions <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__:

 * **readMarble** 用来查询``name, color, size and owner``这些属性
 * **readMarblePrivateDetails** 用来查询 ``price`` 属性

下面教程中，使用 peer 命令进行查询的时候，会使用这两个函数。

写入私有数据
~~~~~~~~~~~~~~~~~~~~

使用链码接口 ``PutPrivateData()`` 将私有数据保存到私有数据库中。
该接口需要一个集合参数。
既然 marbles 示例中包含两个不同的私有数据集，这个接口在链码中会被调用两次。

1. 写入私有数据``name, color, size and owner`` 使用集合参数 ``collectionMarbles``.
2. 写入私有数据``price`` 使用集合参数  ``collectionMarblePrivateDetails``.

举例说明, 链码中的 ``initMarble`` 方法,如下所示，
``PutPrivateData()`` 被调用了两次，对应不同的私有数据集。

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

	// === Save marble to state === 重点1
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

    // 重点2
	err = stub.PutPrivateData("collectionMarblePrivateDetails", marbleInput.Name, marblePrivateDetailsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}


小结：在``collection.json``中定义的策略，允许 Org1 和 Org2 中的所有节点都能
对private data ``name, color, size, owner``进行操作；
但是只有 Org1 中的节点能够对 ``price`` 进行操作。

附加一点：当集合在使用时， 只有 私有数据的 hash 值会通过 orderer, 而数据本身不会参与 orderer 排序。
这样子，orderer 对 私有数据 也是不可见的。

启动 fabric 网络
-----------------

现在我们将经历一些 命令 用以展示 私有数据的具体用法。


:guilabel:`Try it yourself`

在安装、定义和使用 marbles 私有数据示例链码之前，
我们需要启动 fabric 测试网络。为了使本教程跟简单，我们将在一个知名的网络示例基础上进行演示。
接下来的命令将会杀死所有你的主机上正在运行的 docker， 并会清除一些之前的 MSP 证书等信息。
所以我们来运行一下， 清理干净上次的测试网络环境。**重要**

.. code:: bash

   cd fabric-samples/test-network
   ./network.sh down

如果你之前没有实验过本教程，你需要在我们部署链码钱 下载链码所需的的依赖。
使用如下命令：

.. code:: bash

    cd ../chaincode/marbles02_private/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network


如果你之前已经运行过本教程，你也需要删除之前的 marbles 私有数据链码的 链码容器。
使用如下命令：

.. code:: bash

   docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*.marblesp.*/) {print $1}')
   docker rmi -f $(docker images | awk '($1 ~ /dev-peer.*.marblesp.*/) {print $3}')

在 ``test-network`` 目录中, 你可以使用如下命令启动 Fabric 测试网络（使用CouchDB）：

.. code:: bash

   ./network.sh up createChannel -s couchdb

这个命令将会部署一个 Fabric 网络，拥有一个通道 ``mychannel``，两个组织（各拥有一个 peer 节点），
一个排序节点，peer 节点将使用 CouchDB 作为状态数据库。用默认的 LevelDB 也是可以的。
我们选用 couchDB 是用来演示如何使用私有数据的索引的。

.. note:: 为了保证私有数据集正常工作，需要正确地配置组织间的通信。
           根据我们的 gossip 文档 :doc:`gossip`,
           特别注意有关于 "anchor peers" 的章节. 本教程并没有特别展示相关内容,
           是因为 test-network 已经帮我们做好了工作。
           但当我们配置一个通道的时候， gossip 的 锚节点 是否被正确配置，
           对私有数据集的功能与否是至关重要的。

.. _pd-install-define_cc:

安装并定义一个带集合的链码
-------------------------------------------------

用户 APP 是通过 链码 与区块链进行数据交互的。
所以我们需要安装在每一个需要运行链码的、或需要背书的节点上安装链码。
然而，在我们与我们的链码进行交互前，通道内的成员需要审核链码的定义，
包括链码的管理和私有数据集的定义。
我们将要 打包、安装，以及在通道上定义链码，使用命令：:doc:`commands/peerlifecycle`。


链码安装前需要先进行打包操作。
我们可以用 `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ command
对 marbles 链码进行打包。

fabric 测试网络包含 两个组织，Org1 和 Org2，各自拥有一个节点。
所以要安装链码到两个节点上。

- peer0.org1.example.com
- peer0.org2.example.com

链码打包之后，我们可以使用 `peer lifecycle chaincode install <commands/peerlifecycle.html#peer-lifecycle-chaincode-install>`__
命令进行安装。

:guilabel:`Try it yourself`

假设你已经成功启动测试网络，复制粘贴如下环境变量信息到你的 命令行窗口。
用以使用 Org1 Admin 的身份与 fabric 测试网络进行交互。
确保你在 `test-network` 目录内操作。

.. code:: bash

    export PATH=${PWD}/../bin:${PWD}:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

1. 用以下命令打包 marbles 链码。

.. code:: bash

    peer lifecycle chaincode package marblesp.tar.gz --path ../chaincode/marbles02_private/go/ --lang golang --label marblespv1

这个命令将会生成一个链码包文件： marblesp.tar.gz.

2. 用以下命令在 peer0.org1 上安装 marbles 链码。
``peer0.org1.example.com``.

.. code:: bash

    peer lifecycle chaincode install marblesp.tar.gz

安装成功后会显示类似如下的输出信息:

.. code:: bash

    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nKmarblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd\022\nmarblespv1" >
    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd

3. 现在转换到 Org2 admin。复制粘贴如下代码到你的命令行窗口并运行：

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

4. 用以下命令在 peer0.org2 上安装 marbles 链码。

.. code:: bash

    peer lifecycle chaincode install marblesp.tar.gz


链码定义的审批
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

通道内的每一个成员，如果想要使用链码，都需要进行链码审批（以组织为单位）。
既然本例子中，两个组织都需要使用链码，
我们需要对两个组织都进行审批操作： `peer lifecycle chaincode approveformyorg <commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg>`__
本例子中的链码的定义同时也包含了私有数据集的定义，
我们将会在审批时加上 ``--collections-config`` 参数用来指定私有数据集文件的位置。


:guilabel:`Try it yourself`

运行如下代码来进行链码定义审批操作。

1. 使用如下命令来 查询你的链码 ID

.. code:: bash

    peer lifecycle chaincode queryinstalled

 这个命令将会返回一个 链码包的识别信息，你会看到类似如下的输出信息：


.. code:: bash

    Installed chaincodes on peer:
    Package ID: marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e, Label: marblespv1

2. 申明一个环境变量用来标识链码包 ID。粘贴上一步骤命令中返回的 ID 信息并写入环境变量。
链码包 ID 在不同用户中是不同的，你的 ID 可能与本教程种的不同，所以你需要自己在命令行上使用上一步骤的命令来查询你的链码包 ID。

.. code:: bash

    export CC_PACKAGE_ID=marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e

3. 确保我们在命令行中使用 Org1 的身份进行操作。复制粘贴如下信息并运行:


.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

4. 用如下命令进行 Org1 的链码定义的审批操作。此命令包含了一个集合文件的文件路径。


.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

当命令成功完成后，你会收到类似如下的返回信息：

.. code:: bash

    2020-01-03 17:26:55.022 EST [chaincodeCmd] ClientWait -> INFO 001 txid [06c9e86ca68422661e09c15b8e6c23004710ea280efda4bf54d501e655bafa9b] committed with status (VALID) at

5. 将命令行转换到 Org2。 复制粘贴如下信息并运行:

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

6. 用如下命令进行 Org2 的链码定义的审批操作:

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

提交链码定义
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当组织中大部分成员审批通过了链码定义，该组织才可以提交该链码定义到通道上。



使用 `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__
命令来提交链码定义。这个命令同样也会部署私有数据集到通道上。


在链码被提交后，我们就可以使用这个链码了。
因为 marbles 私有数据示例包含一个初始化方法，
我们在调用链码前，需要使用 `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__ 命令
去调用``Init()``初始化方法。

:guilabel:`Try it yourself`

1. 使用如下命令提交 marbles 链码定义到 ``mychannel``通道。

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --sequence 1 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA


 提交成功后，你会看到类似如下的输出信息：


.. code:: bash

    2020-01-06 16:24:46.104 EST [chaincodeCmd] ClientWait -> INFO 001 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:9051
    2020-01-06 16:24:46.184 EST [chaincodeCmd] ClientWait -> INFO 002 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:7051

2. 使用如下命令 调用 ``Init`` 方法初始化链码：

.. code:: bash

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --isInit --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA -c '{"Args":["Init"]}'

.. _pd-store-private-data:

存储私有数据
------------------

用已经被授权的 Org1 的身份, 去操作 marbles 链码中所有的私有数据，
切换回 Org1 peer 的身份，然后提交如下请求去添加一个 marble：


:guilabel:`Try it yourself`

在`test-network`的目录中，复制粘贴如下命令到命令行中执行：


.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

调用 ``initMarble`` 方法，将会使用私有数据创建一个 marble ---  name ``marble1`` owned by ``tom``
color ``blue``, size ``35`` and price of ``99``。还记得私有数据**price**
将会与以下私有数据**name, owner, color, size** 分开存储吗？
正是如此, ``initMarble`` 方法会调用 ``PutPrivateData()`` 接口两次用来分别存储两
个 集合。另外也需要注意，私有数据通过瞬态进行传递，用 ``--transient`` 参数。
作为瞬态的输入不会被记录到交易中，这有助于数据的隐私性。
瞬态数据在传递中会被作为二进制数据，所以在命令行中使用时，必须是 base64 编码过的。
我们设置一个环境变量来捕捉 base64 编码后的值，并使用 ``tr`` 命令来去掉 \n 的换行参数。

.. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

你会看到类似如下的输出结果:

.. code:: bash

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

.. _pd-query-authorized:

使用授权节点的身份进行私有数据查询
--------------------------------------------

我们的私有数据集允许所有的 Org1 和 Org2 的成员访问 ``name, color, size, owner``，
但是只有 Org1 内的成员才拥有对 ``price``私有数据的访问权限。
作为一个拥有全部权限的、Org1 的 peer 成员，我们将来查询所有的 私有数据集。

第一个 ``query`` 命令调用了 ``readMarble`` 方法，该方法传递了
``collectionMarbles`` 的参数。

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

第二个 ``query`` 命令 调用了 ``readMarblePrivateDetails`` 方法，
该方法传递了 ``collectionMarblePrivateDetails`` 的参数。

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

用 Org1 的 member 来查询 ``marble1``的如下私有属性``name, color, size and owner``。
注意：既然查询不会在账本（区块链）上留下踪迹，就不需要使用瞬态进行参数传递。

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

你会看到如下输出结果：

.. code:: bash

    {"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}

Query for the ``price`` private data of ``marble1`` as a member of Org1.

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

你会看到如下输出结果：

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

.. _pd-query-unauthorized:

使用未认证节点来访问私有数据集
----------------------------------------------

现在我们将要切换到 Org2 的成员进行操作。Org2 拥有对私有数据
``name, color, size, owner`` 的访问权限和存储 sideDB,  但是
Org2 的节点的 sideDB 中并不存储 ``price`` 数据。
我们来同时查询两套私有数据集。

切换到 Org2 的 peer 身份
~~~~~~~~~~~~~~~~~~~~~~~~

使用如下命令切换到 Org2 并进行查询：

:guilabel:`Try it yourself`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

查询 Org2 被授权的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2 内的 Peers 节点应该拥有第一套私有数据集的访问权限(``name,
color, size and owner``)，可以使用
``readMarble()`` 方法， 该方法使用了``collectionMarbles``
参数。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarble","marble1"]}'

你会看到类似如下的输出结果：

.. code:: json

    {"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}

查询 Org2 未被授权的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2 内的 Peers 节点的旁数据库中不存在 ``price`` 数据。
当你尝试查询这个数据时，将会返回一个公有状态中的 hash 值，但并不会返回私有数据本身。


:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

你会看到类似如下的输出结果：

.. code:: json

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Failed to get private details for marble1:
    GET_STATE failed: transaction ID: d9c437d862de66755076aeebe79e7727791981606ae1cb685642c93f102b03e5:
    tx creator does not have read access permission on privatedata in chaincodeName:marblesp collectionName: collectionMarblePrivateDetails\"}"

Org2 内的成员，将只能看到私有数据的 hash 值。

.. _pd-purge:

删除私有数据
------------------
对于一些案例，私有数据仅需在账本上保存到在链下数据库复制之后就可以了，
我们可以将 数据在过了一定数量的区块后进行 “清除”，
仅仅把数据的哈希作为不可篡改的证据保存下来。

私有数据可能会包含私人的或者机密的信息，比如我们例子中的``price`` 数据，
这是交易伙伴不想 让通道中的其他组织知道的。但是，它具有有限的生命周期，
就可以根据收集器定义中的，在 固定的区块数量之后清除。


我们的 ``collectionMarblePrivateDetails`` 中定义的 ``blockToLive``
值为3，  表明这个数据会在侧数据库中保存三个区块的时间，之后它就会被清除。
将所有内容放在一起，回想一下绑定了私有数据 ``price``的私有数据集  ``collectionMarblePrivateDetails``，
在函数 ``initMarble()`` 中，当调用 ``PutPrivateData()`` API 并传递了参数 ``collectionMarblePrivateDetails``。

我们将从在链上增加区块，然后来通过执行四笔新交易（创建一个新弹珠，然后转移三个 弹珠）看一看价格信息被清除的过程，
增加新交易的过程中会在链上增加四个新区块。在 第四笔交易完成之后（第三个弹珠转移后），我们将验证一下``price`` 数据是否被清除了。

:guilabel:`Try it yourself`

使用如下命令切换到 Org1 的 peer0 。复制和粘贴下边的一组命令到节点容器并执行：

.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

打开一个新终端窗口，通过运行如下命令来查看这个节点上私有数据日志：注意当前区块高度

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'



回到 peer 容器中，使用如下命令查询 ``price`` 属性
(查询并不会产生一笔新的交易)。

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

你将看到类似下边的信息：

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

``price`` 数据仍然存在于私有数据库上。

通过执行如下命令创建一个新的 marble2 。这个交易将在链上创建一个新区块。

.. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble2\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["initMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

返回到节点容器，再次运行如下命令查询 ``marble1`` 的 ``price`` 数据：

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

私有数据没有被清除，之前的查询也没有改变查询结果：

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

运行下边的命令将 marble2 转移给 “joe” 。这个交易将使链上增加第二个区块。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"joe\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

返回到节点容器，再次运行如下命令查询 ``marble1`` 的``price`` 数据：

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

你仍然可以看到 ``price`` 私有数据。

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

运行下边的命令将 ``marble2`` 转移给 “tom” 。这个交易将使链上增加第三个区块。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"tom\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

返回到节点容器，再次运行如下命令查询 ``marble1`` 的``price`` 数据：

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

你仍然可以看到 ``price`` 私有数据。

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

最后，运行下边的命令将 ``marble2`` 转移给 “jerry” 。这个交易将使链上增加第四个区块。在 此次交易之后， ``price`` 私有数据将会被清除。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"jerry\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["transferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

再次切换回终端窗口并查看节点的私有数据日志。你将看到区块高度增加了 1 。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

返回到节点容器，再次运行如下命令查询 ``marble1`` 的 ``price`` 数据：

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["readMarblePrivateDetails","marble1"]}'

因为 ``price`` 数据已经被清除了，你就查询不到了。你应该会看到类似下边的结果：

.. code:: bash

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Marble private details does not exist: marble1\"}"

.. _pd-indexes:

使用私有数据索引
-------------------------------

索引也可以用于私有数据数据集，可以通过打包链码旁边的索引 ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` 目录。
示例：`here <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ .

在生产环境下部署链码时，建议和链码一起定义索引，
这样当链码在通道中的节点上安 装和初始化时就可以自动作为一个单元进行安装。
当使用 --collections-config 标识 私有数据集的 JSON 文件路径时，
通道上链码初始化的时候相关的索引会自动被部署。


.. _pd-ref-material:

其他资源
--------------------

这里有一个额外的私有数据学习的视频。

.. note:: 这个视频用的是旧版本的链码生命周期管理（配合 1.4 版本使用的， 不建议在 2.0 版本使用）。

.. raw:: html

   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>

.. Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/
