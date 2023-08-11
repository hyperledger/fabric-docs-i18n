在 Fabric 中使用私有数据
======================================

本教程将演示如何使用私有数据集合 (PDC) 来提供存储以及为授权同行检索区块链网络上的私有数据的组织。 该集合是使用包含管理该集合的策略的集合定义文件来指定的。

本教程需要你已经掌握私有数据存储及其使用方法。更多信息，请查看 :doc:`private-data/private-data`。

.. note:: 本教程使用 Fabric-2.0 中新的链码生命管理周期操作。如果你想在之前的版本中使用私有数据，请参阅 v1.4 版本的教程`在 Fabric 中使用私有数据教程 <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__.

本教程将引导您完成以下步骤来练习定义，使用 Fabric 配置和使用私有数据：

#. :ref:`pd-use-case`
#. :ref:`pd-build-json`
#. :ref:`pd-read-write-private-data`
#. :ref:`pd-install-define_cc`
#. :ref:`pd-register-identities`
#. :ref:`pd-store-private-data`
#. :ref:`pd-query-authorized`
#. :ref:`pd-query-unauthorized`
#. :ref:`pd-transfer-asset`
#. :ref:`pd-purge`
#. :ref:`pd-indexes`
#. :ref:`pd-ref-material`

本教程将部署 `资产传输私有数据示例<https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-private-data/chaincode-go>`__
到结构测试网络，以演示如何创建、部署和使用私人数据。
您应该已完成任务 :doc:`install`。

.. _pd-use-case:

资产转移私有数据示例用例
-------------------------------------------

此示例演示了如何使用三个私有数据集合 ``assetCollection``, ``Org1MSPPrivateCollection`` 和 ``Org2MSPPrivateCollection`` 在 Org1 和 Org2 之间传输资产，使用以下用例：

Org1 的成员创建了一项新资产，此后称为所有者。 资产的公开详细信息，包括所有者的身份，都存储在名为 ``assetCollection`` 的私有数据集合中。 
该资产也是通过评估创建的所有者提供的价值。 评估价值用于各参与者同意资产的转让，并且仅存储在所有者组织的集合中。 在我们的例子中，所有者同意的初始评估值存储``Org1MSPPrivateCollection``中。

要购买资产，买方需要同意与资产相同的评估价值资产所有者。 在此步骤中，买方（Org2 的成员）创建协议使用智能合约功能 ``'AgreeToTransfer'`` 进行交易并同意评估价值。该值存储在 ``'Org2MSPPrivateCollection'`` 集合中。 现在，资产所有者可以使用智能合约功能 ``'TransferAsset'`` 将资产转移给买方。 ``'TransferAsset'`` 函数使用通道分类账上的哈希来确认业主和买家已同意相同的评估价值在转移资产之前。

在介绍传输场景之前，我们将讨论组织如何在 Fabric 中使用私有数据集合。

.. _pd-build-json:

构建集合定义 JSON 文件
---------------------------------------

在一组组织可以使用私有数据进行交易之前，所有组织在通道上需要构建一个集合定义文件来定义私有与每个链码关联的数据集合。
存储在私有数据中的数据数据收集仅分发给某些组织的同行该频道的所有成员。 集合定义文件描述了所有组织可以从链码中读取和写入的私有数据集合。

每个集合由以下属性定义：

.. _blockToLive:

- ``name``: 集合的名称。

- ``policy``: 定义了哪些组织中的 Peer 节点能够存储集合数据。

- ``requiredPeerCount``: 私有数据要分发到的节点数，这是链码背书成功的条件之一。

- ``maxPeerCount``: 为了数据冗余，当前背书节点将尝试向其他节点分发数据的数量。如果当前背书节点发生故障，其他的冗余节点可以承担私有数据查询的任务。

- ``blockToLive``: 对于非常敏感的信息，比如价格或者个人信息，这个值代表书库可以在私有数据库中保存的时间。数据会在私有数据库中保存 ``blockToLive`` 个区块，之后就会被清除。如果要永久保留，将此值设置为 ``0`` 即可。

- ``memberOnlyRead``: 设置为 ``true`` 时，节点会自动强制集合中定义的成员组织内的客户端对私有数据仅拥有只读权限。

- ``memberOnlyWrite``: 值 ``true`` 表示节点自动强制只有属于集合成员组织之一的客户允许对私有数据进行写访问。

- ``endorsementPolicy``: 定义了需要满足的背书政策命令写入私有数据集合。 收藏级背书政策覆盖链码级别策略。 有关制定政策的更多信息定义请参阅 :doc:`endorsement-policies` 主题。

所有组织都需要部署相同的集合定义文件使用链码，即使组织不属于任何集合。 在除了集合文件中明确定义的集合之外，每个组织都可以访问其对等方的隐式集合，该集合只能由他们的组织阅读。 
对于使用隐式数据集合的示例，请参阅:doc:`secured_asset_transfer/secured_private_asset_transfer_tutorial`。

资产转移私有数据示例包含文件 `collections_config.json` ，文件中定义了三个私有数据集合定义： ``assetCollection`` 、 ``Org1MSPPrivateCollection``、和 ``Org2MSPPrivateCollection``。

.. code:: json

 // collections_config.json

 [
    {
    "name": "assetCollection",
    "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
    "requiredPeerCount": 1,
    "maxPeerCount": 1,
    "blockToLive":1000000,
    "memberOnlyRead": true,
    "memberOnlyWrite": true
    },
    {
    "name": "Org1MSPPrivateCollection",
    "policy": "OR('Org1MSP.member')",
    "requiredPeerCount": 0,
    "maxPeerCount": 1,
    "blockToLive":3,
    "memberOnlyRead": true,
    "memberOnlyWrite": false,
    "endorsementPolicy": {
        "signaturePolicy": "OR('Org1MSP.member')"
    }
    },
    {
    "name": "Org2MSPPrivateCollection",
    "policy": "OR('Org2MSP.member')",
    "requiredPeerCount": 0,
    "maxPeerCount": 1,
    "blockToLive":3,
    "memberOnlyRead": true,
    "memberOnlyWrite": false,
    "endorsementPolicy": {
        "signaturePolicy": "OR('Org2MSP.member')"
    }
    }
 ]


``assetCollection`` 定义中的 ``plolicy``属性指定 Org1 和 Org2 可以将集合存储在其对等方上。 ``memberOnlyRead`` 和 ``memberOnlyWrite`` 参数用于指定只有 Org1 和 Org2 客户端可以读取和写入此集合。

``Org1MSPPrivateCollection`` 集合仅允许 Org1 的对等方拥有其私有数据库中的私人数据，而 ``Org2MSPPrivateCollection`` 集合只能由 Org2 的对等方存储。 ``endorsementPolicy`` 参数
用于创建特定于集合的认可策略。每次更新 ``Org1MSPPrivateCollection”或“Org2MSPPrivateCollection`` 需要背书由将集合存储在其对等方上的组织提供。我们将看到如何这些集合用于在本教程过程中传输资产。

当链码被使用 `peer lifecycle chaincode commit 命令 <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ 提交到通道中时，集合定义文件也会被部署到通道中。更多信息请看下面的第三节。

.. _pd-read-write-private-data:

使用链码 API 读写私有数据
------------------------------------------------

了解如何将渠道上的数据私有化的下一步是构建链码中的数据定义。资产转移私有数据示例根据数据的访问方式将私有数据分为三个单独的数据定义。

.. code-block:: GO

 // Peers in Org1 and Org2 will have this private data in a side database
 type Asset struct {
	Type  string `json:"objectType"` //Type is used to distinguish the various types of objects in state database
	ID    string `json:"assetID"`
	Color string `json:"color"`
	Size  int    `json:"size"`
	Owner string `json:"owner"`
 }

 // AssetPrivateDetails describes details that are private to owners

 // Only peers in Org1 will have this private data in a side database
 type AssetPrivateDetails struct {
	ID             string `json:"assetID"`
	AppraisedValue int    `json:"appraisedValue"`
 }

 // Only peers in Org2 will have this private data in a side database
 type AssetPrivateDetails struct {
	ID             string `json:"assetID"`
	AppraisedValue int    `json:"appraisedValue"`
 }

 具体而言，对私人数据的访问将受到以下限制：

- ``objectType, color, size, and owner`` 都存储在 ``AssetCollection`` 中。因此根据集合策略（Org1 和 Org2）中的定义，该渠道的成员将可见。 
- ``AppraisedValue``的资产存储在集合 ``Org1MSPPrivateCollection`` 或 ``Org2MSPPrivateCollection``中。取决于资产的所有者，该值仅适用于属于可以存储该集合的组织的用户。

The following diagram illustrates the private data model used by the private data
sample. Note that Org3 is only shown in the diagram to illustrate that if
there were any other organizations on the channel, they would not have access to *any*
of the private data collections that were defined in the configuration.

.. image:: images/SideDB-org1-org2.png

资产传输私有数据样本智能创建的所有数据智能合同存储在PDC中。 
智能合约使用链码API中的 ``GetPrivateData()`` 和 ``PutPrivateData()`` 函数来读写私有数据和私有数据集合。
您可以在 `这里 <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_ 找到有关这些功能的更多信息。
此私有数据存储在对等方的私有状态数据库中（与公共状态数据库分开），并通过gossip协议在授权的对等方之间传播。

下图说明了私有数据使用的私有数据模型样本。请注意，图中仅显示 Org3 以说明如果频道上还有任何其他组织，他们无法访问 *任何* 配置中定义的私有数据集合。

.. image:: images/SideDB-org1-org2.png

读取集合数据
~~~~~~~~~~~~~~~~~~~~~~~~

智能合约使用链码 API ``GetPrivateData()`` 在数据库中访问私有数据。 ``GetPrivateData()`` 有两个参数, **集合名(collection name)** 和 **数据键（data key）**。 
重申一下，集合 ``assetCollection`` 允许 Org1 和 Org2 的成员在侧数据库中保存私有数据，集合 ``Org1MSPPrivateCollection`` 只允许 Org1 在侧数据库中保存私有数据, 集合 ``Org2MSPPrivateCollection`` 只允许 Org2 在侧数据库中保存私有数据。
有关接口的实现详情请查看两个 `资产转移私有数据函数 <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-private-data/chaincode-go/chaincode/asset_queries.go>`__ ：

 * **ReadAsset** 用来查询 ``assetID, color, size and owner`` 属性的值。
 * **ReadAssetPrivateDetails** 用来查询 ``appraisedValue`` 属性的值。

当我们在本教程后面使用同行命令发出数据库查询时，我们将调用这两个函数。

写入私有数据
~~~~~~~~~~~~~~~~~~~~

智能合约使用链码API接口 ``PutPrivateData()`` 将私有数据保存到私有数据库中。该API接口也需要集合名称。

注意资产转移私有数据中包含三个不同的私有数据集，但这个接口在链码中会被调用两次 （在这个场景作为Org1）。

1. 使用集合 ``assetCollection`` 写入私有数据 ``assetID, color, size and owner``。
2. 使用集合  ``Org1MSPPrivateCollection`` 写入私有数据 ``appraisedValue``。

如果我们作用于Org2，我们应该将 ``Org1MSPPrivateCollection`` 替换为 ``Org2MSPPrivateCollection``。
例如, 在链码的 ``initMaCreateAssetrble`` 方法片段中,``PutPrivateData()`` 被调用了两次，每个私有数据调用一次。

.. code-block:: GO

    // 创建资产通过将主要资产详细信息放置在资产集合中来创建新资产
    // 两个组织都可以阅读。评估值存储在所有者组织特定的集合中。
    func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface) error {

        // 从瞬态地图获取新资产
        transientMap, err := ctx.GetStub().GetTransient()
        if err != nil {
            return fmt.Errorf("error getting transient: %v", err)
        }

        // 资产属性是私有的，因此它们在瞬态字段中传递，而不是在函数参数中传递
        transientAssetJSON, ok := transientMap["asset_properties"]
        if !ok {
            //打印错误到 stdout
            return fmt.Errorf("asset not found in the transient map input")
        }

        type assetTransientInput struct {
            Type           string `json:"objectType"` //Type is used to distinguish the various types of objects in state database
            ID             string `json:"assetID"`
            Color          string `json:"color"`
            Size           int    `json:"size"`
            AppraisedValue int    `json:"appraisedValue"`
        }

        var assetInput assetTransientInput
        err = json.Unmarshal(transientAssetJSON, &assetInput)
        if err != nil {
            return fmt.Errorf("failed to unmarshal JSON: %v", err)
        }

        if len(assetInput.Type) == 0 {
            return fmt.Errorf("objectType field must be a non-empty string")
        }
        if len(assetInput.ID) == 0 {
            return fmt.Errorf("assetID field must be a non-empty string")
        }
        if len(assetInput.Color) == 0 {
            return fmt.Errorf("color field must be a non-empty string")
        }
        if assetInput.Size <= 0 {
            return fmt.Errorf("size field must be a positive integer")
        }
        if assetInput.AppraisedValue <= 0 {
            return fmt.Errorf("appraisedValue field must be a positive integer")
        }

        // 检查资产是否已存在
        assetAsBytes, err := ctx.GetStub().GetPrivateData(assetCollection, assetInput.ID)
        if err != nil {
            return fmt.Errorf("failed to get asset: %v", err)
        } else if assetAsBytes != nil {
            fmt.Println("Asset already exists: " + assetInput.ID)
            return fmt.Errorf("this asset already exists: " + assetInput.ID)
        }

        // 获取提交客户端标识的 ID
        clientID, err := submittingClientIdentity(ctx)
        if err != nil {
            return err
        }

        // 验证客户端是否正在向其组织中的对等方提交请求
        // 这是为了确保来自另一个组织的客户端不会尝试读取或
        // 从此对等方写入私有数据。
        err = verifyClientOrgMatchesPeerOrg(ctx)
        if err != nil {
            return fmt.Errorf("CreateAsset cannot be performed: Error %v", err)
        }

        // 使提交客户端成为所有者
        asset := Asset{
            Type:  assetInput.Type,
            ID:    assetInput.ID,
            Color: assetInput.Color,
            Size:  assetInput.Size,
            Owner: clientID,
        }
        assetJSONasBytes, err := json.Marshal(asset)
        if err != nil {
            return fmt.Errorf("failed to marshal asset into JSON: %v", err)
        }

        // 将资产保存到私有数据收集典型的记录器，记录到结构托管 docker 容器中的 stdout/file，
        // 运行此链码查找容器名称，如 dev-peer0.org1.example.com-{chaincodename_version}-xyz
        log.Printf("CreateAsset Put: collection %v, ID %v, owner %v", assetCollection, assetInput.ID, clientID)

        err = ctx.GetStub().PutPrivateData(assetCollection, assetInput.ID, assetJSONasBytes)
        if err != nil {
            return fmt.Errorf("failed to put asset into private data collection: %v", err)
        }

        // 将资产详细信息保存到拥有组织可见的集合
        assetPrivateDetails := AssetPrivateDetails{
            ID:             assetInput.ID,
            AppraisedValue: assetInput.AppraisedValue,
        }

        assetPrivateDetailsAsBytes, err := json.Marshal(assetPrivateDetails) // marshal asset details to JSON
        if err != nil {
            return fmt.Errorf("failed to marshal into JSON: %v", err)
        }

        // 获取此组织的集合名称。
        orgCollection, err := getCollectionName(ctx)
        if err != nil {
            return fmt.Errorf("failed to infer private collection name for the org: %v", err)
        }

        // 将资产评估价值放入所有者组织特定的私人数据收集中
        log.Printf("Put: collection %v, ID %v", orgCollection, assetInput.ID)
        err = ctx.GetStub().PutPrivateData(orgCollection, assetInput.ID, assetPrivateDetailsAsBytes)
        if err != nil {
            return fmt.Errorf("failed to put asset private details: %v", err)
        }
        return nil
    }

总结一下，上面的策略定义对于我们的 ``collections_config.json`` 允许 Org1 和 Org2 中的所有 peer 将资产转移私有数据 ``assetID, color, size, owner`` 存储和交易在他们的私有数据库中。
但只有 Org1 中的 peer 可以将 Org1 集合 ``Org1MSPPrivateCollection`` 中的 ``appraisedValue`` 关键数据存储和交易，只有 Org2 中的 peer 可以将 Org2 集合 ``Org2MSPPrivateCollection`` 中的 ``appraisedValue`` 关键数据存储和交易。

作为额外的数据隐私保护，由于使用了集合，只有私有数据的 *哈希* 通过排序器，而不是私有数据本身，保持私有数据对排序器的机密性。



From the ``test-network`` directory, you can use the following command to start
up the Fabric test network with Certificate Authorities and CouchDB:

.. code:: bash

   ./network.sh up createChannel -ca -s couchdb

This command will deploy a Fabric network consisting of a single channel named
``mychannel`` with two organizations (each maintaining one peer node), certificate authorities, and an
ordering service while using CouchDB as the state database. Either LevelDB or
CouchDB may be used with collections. CouchDB was chosen to demonstrate how to
use indexes with private data.

.. note:: For collections to work, it is important to have cross organizational
           gossip configured correctly. Refer to our documentation on :doc:`gossip`,
           paying particular attention to the section on "anchor peers". Our tutorial
           does not focus on gossip given it is already configured in the test network,
           but when configuring a channel, the gossip anchors peers are critical to
           configure for collections to work properly.

.. _pd-install-define_cc:

启动网络
-----------------

现在我们准备使用一些命令来如何使用私有数据。

:guilabel:`Try it yourself`

在安装、定义和使用私有数据智能合约前，我们需要启动 Fabric 测试网络。为了大家可以正确使用本教程，我们将从一个已知的初始化状态开始操作。
接下来的命令将会停止你主机上所有正在运行的 Docker 容器，并会清除之前生成的构件。所以我们运行以下命令来清除之前的环境。

.. code:: bash

   cd fabric-samples/test-network
   ./network.sh down

从 ``测试网络`` 目录中，您可以使用以下命令启动使用证书颁发机构和 CouchDB 建立结构测试网络：

.. code:: bash
   
   ./network.sh up createChannel -ca -s couchdb

这个命令将会部署一个 Fabric 网络。该网络包括一个名为 ``mychannel`` 的通道。 该通道包含两个组织（各维护一个 Peer 节点），证书颁发机构和
排序服务（排序服务使用 CouchDB 作为状态数据库）。用默认的 LevelDB 和 CouchDB 都可以使用私有数据集合。我们选择 CouchDB 来演示如何使用私有数据的索引。

.. note:: 为了保证私有数据集正常工作，需要正确地配置组织间的 gossip 通信。请参考文档 :doc:`gossip`，需要特别注意 "锚节点（anchor peers）" 章节。本教程不关注 gossip，它在测试网络中已经配置好了。但当我们配置通道的时候，gossip 的锚节点是否被正确配置影响到私有数据集能否正常工作。

.. _pd-install-define_cc:

将私有数据智能合约部署到通道
-----------------------------------------------------

我们现在可以使用测试网络脚本将智能合约部署到通道。从测试网络目录运行以下命令。

.. code:: bash

   ./network.sh deployCC -ccn private -ccp ../asset-transfer-private-data/chaincode-go/ -ccl go -ccep "OR('Org1MSP.peer','Org2MSP.peer')" -cccg ../asset-transfer-private-data/chaincode-go/collections_config.json

As part of deploying the chaincode to the channel, both organizations
on the channel must pass identical private data collection definitions as part
of the :doc:`chaincode_lifecycle`. We are also deploying the smart contract
with a chaincode level endorsement policy of ``"OR('Org1MSP.peer','Org2MSP.peer')"``.

请注意，我们需要传递私有数据收集定义文件的路径到以上命令。作为将链码部署到通道的一部分，两个组织在通道上必须传递相同的专用数据收集定义作为一部分的文档:doc:`chaincode_lifecycle`。
我们还在部署智能合约链码级别的背书策略为 ``"OR('Org1MSP.peer','Org2MSP.peer')"``。
这允许 Org1 和 Org2 创建资产，而无需获得来自另一个组织的背书。您可以看到部署链码所需的步骤发出上述命令后打印在日志中。

当两个组织都使用 `Peer Lifecycle Chaincode Approveformyorg <command/peerlifecycle.html#peer-lifecycle -chaincode-approveformyorg>`__ 命令时，链码定义包括了私有数据收集的路径，该路径使用 ``--collections-config`` 标志进行定义。
您可以查看以下 `approveformyorg` 命令打印在终端中：

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name private --version 1.0 --collections-config ../asset-transfer-private-data/chaincode-go/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

在通道成员同意将私有数据收集作为链码定义的一部分之后，使用命令 `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`进行数据收集并提交到通道。
命令。如果在日志中查找 commit 命令，可以看到它使用相同的 ``--collections-config`` 标志，以提供集合定义的路径。

.. code:: bash

    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name private --version 1.0 --sequence 1 --collections-config ../asset-transfer-private-data/chaincode-go/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

.. _pd-register-identities:

注册身份标识
-------------------

私有数据传输智能合约支持属于网络的个人身份的所有权。在我们的场景中，资产的所有者将是 Org1 的成员，而买方将属于 Org2。
为了突出显示接口API ``GetClientIdentity().GetID()`` 和用户证书中的信息，我们将使用 Org1 和 Org2 证书颁发机构 (CA) 注册两个新身份，然后使用 CA 生成每个身份的证书和私钥。

首先，我们需要设置以下环境变量以使用 Fabric CA 客户端：

.. code :: bash

    export PATH=${PWD}/../bin:${PWD}:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/

我们将使用 Org1 CA 创建标识资产所有者。将结构 CA 客户端主页设置为 Org1 CA 管理员的 MSP（此标识由测试网络脚本生成）：

.. code:: bash

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

您可以使用工具 `fabric-ca-client` 注册新的所有者客户端身份：

.. code:: bash

    fabric-ca-client register --caname ca-org1 --id.name owner --id.secret ownerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"

现在，您可以通过向 enroll 命令提供注册名称和密钥来生成身份证书和 MSP 文件夹：

.. code:: bash

    fabric-ca-client enroll -u https://owner:ownerpw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org1/tls-cert.pem"

运行以下命令，将节点 OU 配置文件复制到所有者身份 MSP 文件夹中。

.. code:: bash

    cp "${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp/config.yaml"

现在，我们可以使用 Org2 CA 创建买方身份。将结构 CA 客户端主页设置为 Org2 CA 管理员：

.. code:: bash

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.example.com/

您可以使用工具 `fabric-ca-client` 注册新的所有者客户端身份：

.. code:: bash

    fabric-ca-client register --caname ca-org2 --id.name buyer --id.secret buyerpw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"

我们现在可以注册以生成标识 MSP 文件夹：

.. code:: bash

    fabric-ca-client enroll -u https://buyer:buyerpw@localhost:8054 --caname ca-org2 -M "${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/org2/tls-cert.pem"

运行以下命令，将节点 OU 配置文件复制到买家身份 MSP 文件夹中。

.. code:: bash

    cp "${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp/config.yaml"

.. _pd-store-private-data:

在私有数据中创建资产
-------------------------------

现在我们已经创建了资产所有者的身份，我们可以调用私人数据智能合约创建新资产。 复制并粘贴以下内容在 `test-network` 目录中的终端中输入一组命令：

:guilabel:`Try it yourself`

.. code :: bash

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051


我们将使用 ``CreateAsset`` 函数创建一个存储在私有数据中的资产，assetID为 ``asset1`` ，颜色为 ``green``，大小为 ``20``，appraisedValue 值为 ``100``。 回想一下私有数据 **appraisedValue** 将与私有数据 **assetID, color, size** 是分开存储的。
因此， ``CreateAsset``  函数调用 ``PutPrivateData()``API两次保存私有数据，每个集合调用一次。 另请注意私有数据使用 ``--transient`` 标志传递。 通过瞬态数据的输入不会保留在事务transaction中以保持数据私有。 
瞬态数据作为二进制数据传递，因此当使用终端时，它必须是 base64 编码的。 我们使用环境变量捕获base64编码值，并使用 ``tr``命令去除 linux base64 命令添加的有问题的换行符。

运行下列命令来创建资产：

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset1\",\"color\":\"green\",\"size\":20,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

你应该看到类似的结果：

.. code:: bash

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

请注意，上面的命令仅针对 Org1 对等方。 事务 ``CreateAsset``写入 ``assetCollection`` 和 ``Org1MSPPrivateCollection`` 这两个集合。
``Org1MSPPrivateCollection`` 需要 Org1 对等点的背书才能写入集合，而 ``assetCollection`` 继承链码的背书策略， ``"OR('Org1MSP.peer','Org2MSP.peer')"`` 。
来自 Org1 对等方的背书可以满足两种背书策略，并且能够在没有 Org2 背书的情况下创建资产。

.. _pd-query-authorized:

以授权对等方身份查询私有数据
--------------------------------------------

我们的集合定义允许 Org1 和 Org2 的所有对等方在其侧数据库中拥有私有数据 ``assetID, color, size, and owner``,
但只有 Org1 中的同级才能在其侧数据库中拥有 Org1 对其私有数据 ``appraisedValue`` 的看法。 作为 Org1 中的授权对等方，我们将查询两组私有数据。
第一个 ``query`` 命令调用 ``ReadAsset``函数，该函数传递 ``assetCollection``作为参数。

.. code-block:: GO

   // 读取资产从集合中读取信息
   func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, assetID string) (*Asset, error) {

        log.Printf("ReadAsset: collection %v, ID %v", assetCollection, assetID)
        assetJSON, err := ctx.GetStub().GetPrivateData(assetCollection, assetID) //get the asset from chaincode state
        if err != nil {
            return nil, fmt.Errorf("failed to read asset: %v", err)
        }

        //未找到资产，返回空响应
        if assetJSON == nil {
            log.Printf("%v does not exist in collection %v", assetID, assetCollection)
            return nil, nil
        }

        var asset *Asset
        err = json.Unmarshal(assetJSON, &asset)
        if err != nil {
            return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
        }

        return asset, nil

    }

第二个 ``query`` 命令调用 ``ReadAssetPrivateDetails`` 并传递 ``Org1MSPPrivateDetails`` 作为参数的函数。

.. code-block:: GO

   // 读取资产私有详细信息读取组织特定集合中的资产私有详细信息
   func (s *SmartContract) ReadAssetPrivateDetails(ctx contractapi.TransactionContextInterface, collection string, assetID string) (*AssetPrivateDetails, error) {
        log.Printf("ReadAssetPrivateDetails: collection %v, ID %v", collection, assetID)
        assetDetailsJSON, err := ctx.GetStub().GetPrivateData(collection, assetID) // 从链码状态获取资产
        if err != nil {
            return nil, fmt.Errorf("failed to read asset details: %v", err)
        }
        if assetDetailsJSON == nil {
            log.Printf("AssetPrivateDetails for %v does not exist in collection %v", assetID, collection)
            return nil, nil
        }

        var assetDetails *AssetPrivateDetails
        err = json.Unmarshal(assetDetailsJSON, &assetDetails)
        if err != nil {
            return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
        }

        return assetDetails, nil
    }

现在 :guilabel:`自己试试吧`

我们可以使用 `ReadAsset` 函数查询 `assetCollection` 集合作为 Org1 来读取创建的资产的主要详细信息：

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

成功后，该命令将返回以下结果：

.. code:: bash

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,"owner":"x509::CN=appUser1,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=ca.org1.example.com,O=org1.example.com,L=Durham,ST=North Carolina,C=US"}

资产的 `"owner"`是通过调用智能合约创建资产的身份。 私有数据智能合约使用API  ``GetClientIdentity().GetID()`` 读取身份证书的名称和颁发者。 您可以在所有者属性中查看身份证书的名称和颁发者。

查询作为 Org1 成员的 ``asset1`` 的 私有数据 ``appraisedValue``。

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'

你应该看到以下的结果：

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

.. _pd-query-unauthorized:

将私有数据作为未经授权的对等方进行查询
----------------------------------------------

现在我们将操作来自 Org2 的用户。Org2 在其侧数据库中具有资产传输私有数据 ``assetID, color, size, owner``，如策略 ``assetCollection`` 中定义的那样，
但不存储 Org1 中的资产 ``appraisedValue``数据。我们将查询这两组私有数据。

切换到 Org2 中的对等方
~~~~~~~~~~~~~~~~~~~~~~~~

运行以下命令以 Org2 成员身份运行并查询 Org2 对等方。

:guilabel:`自己试试吧`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

查询私有数据 Org2 授权情况
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2 中的对等方应该在其端数据库中拥有第一组资产传输私有数据(``assetID, color, size and owner``)，并且可以使用函数 ``ReadAsset()`` 访问它。
该函数使用参数 ``assetCollection`` 来调用。

:guilabel:`自己试试吧`

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

成功后，应看到类似于以下结果的内容：

.. code:: json

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,
    "owner":"x509::CN=appUser1,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=ca.org1.example.com,O=org1.example.com,L=Durham,ST=North Carolina,C=US" }

查询 Org2 无权访问的私有数据
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Because the asset was created by Org1, the ``appraisedValue`` associated with
``asset1`` is stored in the ``Org1MSPPrivateCollection`` collection. The value is
not stored by peers in Org2. Run the following command to demonstrate that the
asset's ``appraisedValue`` is not stored in the ``Org2MSPPrivateCollection``
on the Org2 peer:

由于该资产是由 Org1 创建的，因此与 ``asset1`` 关联的 ``appraisedValue`` 存储在 ``Org1MSPPrivateCollection`` 集合中。 Org2 中的同级不存储该值。 
运行以下命令来演示资产的 ``appraisedValue`` 未存储在 Org2 对等方的 ``Org2MSPPrivateCollection`` 中：

:guilabel:`自己试试吧`

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

The empty response shows that the asset1 private details do not exist in buyer
(Org2) private collection.

空响应表明 asset1 的私有详细信息在买家 (Org2) 的私有集合中不存在。

Org2 中的用户也无法读取 Org1 私有数据集合：

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'

通过在集合配置文件中设置 ``"memberOnlyRead": true``，我们指定只有 Org1 中的客户端才能从集合中读取数据。 
当Org2 客户端尝试读取该集合时，只会得到以下响应：

.. code:: json

    Error: endorsement failure during query. response: status:500 message:"failed to
    read asset details: GET_STATE failed: transaction ID: d23e4bc0538c3abfb7a6bd4323fd5f52306e2723be56460fc6da0e5acaee6b23: tx
    creator does not have read access permission on privatedata in chaincodeName:private collectionName: Org1MSPPrivateCollection"

Org2 的用户只能看到私有数据的公共哈希值。

.. _pd-transfer-asset:

转移资产
------------------

让我们看看将 ``asset1`` 转移到org2所需的内容。 
您可能想知道，如果 Org1 将他们对 ``appraisedValue`` 的意见保留在他们的私有数据库中，他们如何达成一致。
为此，让我们继续。

:guilabel:`自己试试吧`

使用我们的对等 CLI 切换回终端。

要转移资产，买方（接收方）需要通过调用链码函数 ``AgreeToTransfer``来同意与资产所有者相同的 ``appraisedValue``。
约定的值将存储在 Org2 对等方上的 ``Org2MSPDetailsCollection`` 集合中。运行以下命令以同意 Org2的评估值为100：

.. code:: bash

    export ASSET_VALUE=$(echo -n "{\"assetID\":\"asset1\",\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"AgreeToTransfer","Args":[]}' --transient "{\"asset_value\":\"$ASSET_VALUE\"}"


买方现在可以查询他们在 Org2 私有数据收集中同意的值：

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

调用将返回以下值：

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

既然买方已同意以评估价值购买资产，所有者可以转让Org2 的资产。
资产需要由拥有资产的身份转移， 所以让我们充当 Org1：

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_ADDRESS=localhost:7051

来自 Org1 的所有者可以读取由 `AgreeToTransfer` 交易添加的数据，以查看买方身份：

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadTransferAgreement","Args":["asset1"]}'

.. code:: bash

    {"assetID":"asset1","buyerID":"eDUwOTo6Q049YnV5ZXIsT1U9Y2xpZW50LE89SHlwZXJsZWRnZXIsU1Q9Tm9ydGggQ2Fyb2xpbmEsQz1VUzo6Q049Y2Eub3JnMi5leGFtcGxlLmNvbSxPPW9yZzIuZXhhbXBsZS5jb20sTD1IdXJzbGV5LFNUPUhhbXBzaGlyZSxDPVVL"}

我们现在拥有转移资产所需的一切。
智能合约使用 ``GetPrivateDataHash（）``函数来检查 ``Org1MSPPrivateCollection``中资产评估值的哈希值是否与 ``Org2MSPPrivateCollection``中评估值的哈希值匹配。
如果哈希相同，则确认所有者和感兴趣的买方已同意相同的资产价值。
如果满足条件，转账函数将获取买家的客户ID从转让协议中，并使买方成为资产的新所有者。
转移功能还将从前所有者的收藏中删除资产评估值，以及从 ``assetCollection`` 中删除转让协议。
运行以下命令以传输资产。所有者需要提供资产 ID 和买方到转移交易的组织 MSP ID：

.. code:: bash

    export ASSET_OWNER=$(echo -n "{\"assetID\":\"asset1\",\"buyerMSP\":\"Org2MSP\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"TransferAsset","Args":[]}' --transient "{\"asset_owner\":\"$ASSET_OWNER\"}" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"

您可以查询 ``asset1`` 以查看传输结果：

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

结果将显示买方身份现在拥有资产：

.. code:: bash

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,"owner":"x509::CN=appUser2, OU=client + OU=org2 + OU=department1::CN=ca.org2.example.com, O=org2.example.com, L=Hursley, ST=Hampshire, C=UK"}

The `"owner"` of the asset now has the buyer identity.

您还可以确认转移从 Org1 集合中删除了私有详细信息：

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'

查询将返回空结果，因为资产私有数据已从 Org1 私有数据收集中删除。

.. _pd-purge:

清除私有数据
------------------

对于私有数据只需要保留一小段时间的用例，可以在一定数量的块后“清除”数据，只留下作为交易不可变证据的数据哈希。
如果数据包含另一个事务使用但不再需要的敏感信息，或者数据正在复制到链下数据库中，则组织可以决定清除私有数据。

我们示例中的 ``appraisedValue`` 数据包含一个专用协议，组织可能希望在一段时间后过期。
因此，它的寿命有限，并且可以使用集合定义中的属性 ``blockToLive`` 在区块链上未更改后清除指定数量的块。

``Org2MSPPrivateCollection``的定义具有 ``blockToLive`` 属性值为 ``3``，这意味着此数据将在端数据库中存在三个块，然后将被清除。
如果我们在通道上创建额外的块，Org2 同意的 ``appraisedValue`` 将最终被清除。
我们可以创建 3 个新块来演示：

:guilabel:`自己试试吧`

在终端中运行以下命令，切换回作为 Org2 成员运行并面向 Org2 对等方：

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

我们仍然可以查询 ``Org2MSPPrivateCollection`` 中的 ``appraisedValue``：

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

您应该会看到日志中打印的值：

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

由于我们需要跟踪在清除私有数据之前添加的块数，打开一个新的终端窗口并运行以下命令以查看 Org2 对等方的私有数据日志。记下最高的块号。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

现在返回到我们作为 Org2 成员的终端并运行以下命令以创建三个新资产。每个命令将创建一个新块。

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset2\",\"color\":\"blue\",\"size\":30,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset3\",\"color\":\"red\",\"size\":25,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset4\",\"color\":\"orange\",\"size\":15,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"


返回到另一个终端并运行以下命令以确认新资产导致创建了三个新块：

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

``appraisedValue`` 现已从 ``Org2MSPDetailsCollection`` 私有数据收集中清除。从 Org2 终端再次发出查询以查看响应是否为空。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'


.. _pd-indexes:

使用带有私有数据的索引
-------------------------------

通过将索引与链代码一起打包在 ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` 目录中，索引也可以应用于私有数据集合。 
示例索引位于 `此处 <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}//asset-transfer-private-data/chaincode-go/META-INF/statedb/couchdb/collections/assetCollection/indexes/indexOwner.json>`__ 。

要将链代码部署到生产环境，建议与链代码一起定义任何索引，以便一旦链代码安装在对等节点上并在通道上实例化，链代码和支持索引就会作为一个单元自动部署。 
当指定 ``--collections-config`` 标志指向集合 JSON 文件的位置时，关联的索引会在通道上的链代码实例化时自动部署。

.. note:: 不可能创建用于隐式私有数据集合的索引。
          隐式集合基于组织名称并自动创建。 名称的格式为 ``_implicit_org_<OrgsMSPid>``
          更多信息，请查看 `FAB-17916 <https://jira.hyperledger.org/browse/FAB-17916>`__.

清理
--------

当您使用完私有数据智能合约后，您可以使用 ``network.sh`` 脚本关闭测试网络。

.. code:: bash

  ./network.sh down

此命令将关闭我们创建的网络的 CA、对等点和排序节点。 请注意，分类帐上的所有数据都将丢失。
如果您想再次完成本教程，您将从干净的初始状态开始。

.. _pd-ref-material:

其他资源
--------------------

对于其他私人数据教育，我们创建了视频教程。

.. note:: 该视频使用之前的生命周期模型通过链码安装私有数据集合。

.. raw:: html

   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>



.. 根据 Creative Commons Attribution 4.0 International License 获得许可
   https://creativecommons.org/licenses/by/4.0/
