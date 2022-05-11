Using Private Data in Fabric
============================

このチュートリアルでは、プライベートデータコレクション(Private Data Collections, PDC)を使用して、ブロックチェーンネットワーク上のプライベートデータを認可された組織のピア上に格納および取得する方法について説明します。
コレクションに対するポリシーが含まれるコレクション定義ファイルによって、コレクションを指定します。

このチュートリアルの情報は、プライベートデータストアとその使用例に関する知識を前提としています。詳細については、 :doc:`private-data/private-data` を参照してください。

.. note:: この手順では、Fabric v2.0リリースで導入された新しいFabricチェーンコードライフサイクルを使用します。以前のライフサイクルモデルを使用したチェーンコードでプライベートデータを使用する場合は、v1.4バージョンのチュートリアル `Using Private Data in Fabric tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__ を参照してください。

このチュートリアルでは、次の手順に従って、Fabricでプライベートデータを定義、構成、使用する方法について学習します:

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

このチュートリアルでは、 `asset transfer private data sample <https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-private-data/chaincode-go>`__ をFabricテストネットワークに展開し、プライベートデータのコレクションを作成、展開、および使用する方法を示します。タスク :doc:`install` が完了している必要があります。

.. _pd-use-case:

Asset transfer private data sample use case
-------------------------------------------

このサンプルでは、 ``assetCollection``, ``Org1MSPPrivateCollection``, ``Org2MSPPrivateCollection`` の3つのプライベートデータコレクションを用いて、Org1とOrg2の間の資産の譲渡をデモします。サンプルでは、次のようなユースケースを用います。

Org1のメンバーが新たに資産を作成し、そのため、その所有者となります。所有者のアイデンティティなどの、資産の公開している詳細情報は、 ``assetCollection`` という名前のプライベートコレクションに格納されます。
資産は作成時に、所有者によって評価額の情報も与えられます。
評価額は、資産の譲渡の合意のために各参加者によって使用され、所有者の組織のコレクションにのみ格納されます。
今回のケースでは、所有者が合意した最初の評価額は、 ``Org1MSPPrivateCollection`` に格納されます。

この資産を購入するために、購入者は資産の所有者と同じ評価額に合意しなければなりません。
このステップでは、購入者 (Org2のメンバー) は、 ``'AgreeToTransfer'`` というスマートコントラクトの関数を利用して、評価額に合意し取引をする合意書を作成します。
この額は、 ``Org2MSPPrivateCollection`` に格納されます。
これで、 ``'TransferAsset'`` というスマートコントラクトの関数を利用して、資産の所有者は、購入者に資産を譲渡することができるようになります。
この ``'TransferAsset'`` という関数は、チャネルの台帳にあるハッシュ値を使って、資産の譲渡の前に所有者と購入者が同じ評価額に合意していることを確認します。

譲渡のシナリオを詳しく見る前に、Fabricにおいて組織がどのようにプライベートデータコレクションを使うことができるかを議論しましょう。

.. _pd-build-json:

Build a collection definition JSON file
---------------------------------------

プライベートデータを用いて複数の組織がやりとりできるようになるには、各チェーンコードに関連付けられたプライベートデータコレクションを定義するコレクション定義ファイルを、チャネル上のすべての組織が構築する必要があります。
プライベートデータコレクションに格納されたデータは、チャネルのすべてのメンバではなく、特定の組織のピアにのみ分散されます。
コレクション定義ファイルは、組織がチェーンコードから読み書きすることができるプライベートデータコレクションの全てを記述します。

各コレクションは、次のプロパティによって定義されます。

.. _blockToLive:

- ``name`` : コレクションの名前。

- ``policy`` : コレクションデータの保持を許可する組織ピアを定義します。

- ``requiredPeerCount`` : チェーンコードのエンドースメントの条件としてプライベートデータを広めるために必要なピア数

- ``maxPeerCount`` : データの冗長性のために、現在のエンドースピアがデータの配布を試行する他のピアの数。エンドースピアが停止した場合、プライベートデータのプル要求があると、コミット時にこれらの他のピアが使用可能になります。

- ``blockToLive`` : 価格設定や個人情報などの機密性の高い情報の場合、この値は、データがプライベートデータベースでブロック単位で存続する期間を表します。データは、プライベートデータベースで指定したブロック数の間存続し、その後パージされて、このデータはネットワーク上からなくなります。プライベートデータを無期限に保持する、つまりプライベートデータをパージしないようにするには、 ``blockToLive`` プロパティを ``0`` に設定します。

- ``memberOnlyRead`` : 値が ``true`` の場合、ピアは、コレクションメンバー組織の1つに属するクライアントだけがプライベートデータへの読み取りアクセスを許可されるように自動的に強制します。

- ``memberOnlyWrite`` : 値が ``true`` の場合、ピアは、コレクションメンバー組織の1つに属するクライアントだけがプライベートデータへの書き込みアクセスを許可されるように自動的に強制します。

- ``endorsementPolicy`` : このプライベートデータコレクションへの書き込みのために、満たさなければいけないエンドースメントポリシーを定義します。コレクションレベルのエンドースメントポリシーは、チェーンコードレベルのポリシーを上書きします。ポリシー定義の作成の詳細については、 :doc:`endorsement-policies` トピックを参照してください。

チェーンコードを使用するすべての組織は、たとえその組織がどのコレクションに属していなくとも、同じコレクション定義ファイルをデプロイする必要があります。
コレクションファイルに明示的に定義されたコレクションに加えて、各組織は、自組織だけが読むことのできる、それぞれのピアにある暗黙的なコレクションにアクセスすることができます。
暗黙的なデータコレクションを用いた例については、 :doc:`secured_asset_transfer/secured_private_asset_transfer_tutorial` を参照してください。

asset transfer private dataの例には、 ``assetCollection`` 、 ``Org1MSPPrivateCollection`` 、 ``Org2MSPPrivateCollection`` の3つのデータコレクションを定義する `collections_config.json` ファイルがあります。

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

``assetCollection`` の定義の ``policy`` プロパティは、Org1とOrg2の両組織が、そのピアにコレクションを保持できることを指定しています。
``memberOnlyRead`` と ``memberOnlyWrite`` パラメータは、 Org1とOrg2の組織のみがこのコレクションに読み書きをできることを指定するために使われています。

``Org1MSPPrivateCollection`` コレクションは、Org1のピアのみに、そのピアのプライベートデータベースにこのプライベートデータを持つことを許可し、 ``Org2MSPPrivateCollection`` コレクションはOrg2のピアだけが格納することがでます。
``endorsementPolicy`` パラメータは、コレクションごとのエンドースメントポリシーを作成するのに使われます。
``Org1MSPPrivateCollection`` や ``Org2MSPPrivateCollection`` への更新は、ピアがそのコレクションを保有している組織によるエンドースが必要となります。
チュートリアルの中で、資産の譲渡にこれらのコレクションがどのように使われているかをみていきます。

このコレクション定義ファイルは、チェーンコード定義が `peer lifecycle chaincode commit command <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ を使用してチャネルにコミットされるときに展開されます。このプロセスの詳細については、以下のセクション3で説明します。

.. _pd-read-write-private-data:

Read and Write private data using chaincode APIs
------------------------------------------------

チャネル上のデータをプライベート化する方法を理解するための次のステップは、チェーンコード内にデータ定義を構築することです。asset transfer private dataサンプルは、データへのアクセス方法に従って、プライベートデータを3つの個別のデータ定義に分割します。

.. code-block:: GO

 // Org1とOrg2のピアは、サイドデータベースにこのプライベートデータを保有します
 type Asset struct {
	Type  string `json:"objectType"` // Typeは、ステートデータベース内の様々なオブジェクトの種類を識別するのに使われます
	ID    string `json:"assetID"`
	Color string `json:"color"`
	Size  int    `json:"size"`
	Owner string `json:"owner"`
 }

 // AssetPrivateDetailsは、所有者のみが見られる詳細を保持します

 // Org1のピアだけが、サイドデータベースにこのプライベートデータを持ちます
 type AssetPrivateDetails struct {
	ID             string `json:"assetID"`
	AppraisedValue int    `json:"appraisedValue"`
 }

 // Org2のピアだけが、サイドデータベースにこのプライベートデータを持ちます
 type AssetPrivateDetails struct {
	ID             string `json:"assetID"`
	AppraisedValue int    `json:"appraisedValue"`
 }

具体的には、プライベートデータへのアクセスは以下のように制限されます:

- ``objectType, color, size, owner`` は、 ``assetCollection`` に格納され、コレクションのポリシーの定義に従い、チャネルのメンバー(Org1とOrg2)が見ることができます
- 資産の ``AppraisedValue`` は、資産の所有者によって、 ``Org1MSPPrivateCollection`` もしくは ``Org2MSPPrivateCollection`` というコレクションに格納されます。この値には、コレクションを保持できる組織に属するユーザーのみがアクセス可能です。

asset transfer private data サンプルのスマートコントラクトで作られるすべてのデータは、PDC(プライベートデータコレクション)に格納されます。
スマートコントラクトは、Fabric chaincode APIの ``GetPrivateData()`` と ``PutPrivateData()`` 関数を用いてプライベートデータコレクションにプライベートデータを読み書きします。
これらの関数についての詳細は、`ここ <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_ にあります。
プライベートデータは、(パブリックなステートデータベースとは別の)ピアのプライベートステートデータベースに格納され、許可されたピアの間でゴシッププロトコルによって配布されます。

次の図はプライベートデータサンプルで用いられているプライベートデータモデルを図解しています。
この図においてOrg3は、もしチャネルに他の組織が存在するとしたら、それは設定で定義されたプライベートデータコレクションの *どれにもアクセスできない* ということを示すためのものです。

.. image:: images/SideDB-org1-org2.png


Reading collection data
~~~~~~~~~~~~~~~~~~~~~~~~

スマートコントラクトは、データベース内のプライベートデータをクエリするために、chaincode API ``GetPrivateData()`` を使用します。 ``GetPrivateData()`` は、 **コレクション名** とデータキーの2つの引数を取ります。コレクション ``assetCollection`` では、Org1とOrg2のメンバーがサイドデータベース内にプライベートデータを持つことができ、 ``Org1MSPPrivateCollection`` は、Org1のピアのみがサイドデータベースにそのプライベートデータを持つことができ、
``Org2MSPPrivateCollection`` は、Org2のピアのみがサイドデータベースにそのプライベートデータを持つことができることを思い出してください。
実装の詳細は、次の2つの `asset transfer private data functions <https://github.com/hyperledger/fabric-samples/blob/main/asset-transfer-private-data/chaincode-go/chaincode/asset_queries.go>`__ を参照してください:

 * ``assetID, color, size, owner`` 属性の値を問い合わせる **ReadAsset**
 * ``appraisedValue`` 属性の値を問い合わせる **ReadAssetPrivateDetails**

このチュートリアルの後半でpeerコマンドを使用してデータベースクエリーを発行する際、これらの2つの関数を呼び出します。

Writing private data
~~~~~~~~~~~~~~~~~~~~

スマートコントラクトは、プライベートデータをプライベートデータベースに格納するために、chaincode API ``PutPrivateData()`` を使用します。
APIにはコレクションの名前も必要です。
asset transfer private data sampleには、3つの異なるプライベートデータを含んでいますが、チェーンコードから(Org1として動く下記のシナリオでは)2回このAPIが呼ばれることに注意してください。

1. ``assetCollection`` というコレクションを使って、プライベートデータの ``assetID, color, size, owner`` を書き込む。
2. ``Org1MSPPrivateCollection`` というコレクションを使って、プライベートデータの ``appraisedValue`` を書き込む。

もしOrg2として動くときには、 ``Org1MSPPrivateCollection`` を ``Org2PrivateCollection`` に置き換えます。

例えば、以下に示す ``CreateAsset`` 関数の抜粋では、 ``PutPrivateData()`` は、それぞれのプライベートデータに対して、合計2回呼ばれています。

.. code-block:: GO

    // CreateAsset creates a new asset by placing the main asset details in the assetCollection
    // that can be read by both organizations. The appraisal value is stored in the owners org specific collection.
    func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface) error {

        // Get new asset from transient map
        transientMap, err := ctx.GetStub().GetTransient()
        if err != nil {
            return fmt.Errorf("error getting transient: %v", err)
        }

        // Asset properties are private, therefore they get passed in transient field, instead of func args
        transientAssetJSON, ok := transientMap["asset_properties"]
        if !ok {
            //log error to stdout
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

        // Check if asset already exists
        assetAsBytes, err := ctx.GetStub().GetPrivateData(assetCollection, assetInput.ID)
        if err != nil {
            return fmt.Errorf("failed to get asset: %v", err)
        } else if assetAsBytes != nil {
            fmt.Println("Asset already exists: " + assetInput.ID)
            return fmt.Errorf("this asset already exists: " + assetInput.ID)
        }

        // Get ID of submitting client identity
        clientID, err := submittingClientIdentity(ctx)
        if err != nil {
            return err
        }

        // Verify that the client is submitting request to peer in their organization
        // This is to ensure that a client from another org doesn't attempt to read or
        // write private data from this peer.
        err = verifyClientOrgMatchesPeerOrg(ctx)
        if err != nil {
            return fmt.Errorf("CreateAsset cannot be performed: Error %v", err)
        }

        // Make submitting client the owner
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

        // Save asset to private data collection
        // Typical logger, logs to stdout/file in the fabric managed docker container, running this chaincode
        // Look for container name like dev-peer0.org1.example.com-{chaincodename_version}-xyz
        log.Printf("CreateAsset Put: collection %v, ID %v, owner %v", assetCollection, assetInput.ID, clientID)

        err = ctx.GetStub().PutPrivateData(assetCollection, assetInput.ID, assetJSONasBytes)
        if err != nil {
            return fmt.Errorf("failed to put asset into private data collecton: %v", err)
        }

        // Save asset details to collection visible to owning organization
        assetPrivateDetails := AssetPrivateDetails{
            ID:             assetInput.ID,
            AppraisedValue: assetInput.AppraisedValue,
        }

        assetPrivateDetailsAsBytes, err := json.Marshal(assetPrivateDetails) // marshal asset details to JSON
        if err != nil {
            return fmt.Errorf("failed to marshal into JSON: %v", err)
        }

        // Get collection name for this organization.
        orgCollection, err := getCollectionName(ctx)
        if err != nil {
            return fmt.Errorf("failed to infer private collection name for the org: %v", err)
        }

        // Put asset appraised value into owners org specific private data collection
        log.Printf("Put: collection %v, ID %v", orgCollection, assetInput.ID)
        err = ctx.GetStub().PutPrivateData(orgCollection, assetInput.ID, assetPrivateDetailsAsBytes)
        if err != nil {
            return fmt.Errorf("failed to put asset private details: %v", err)
        }
        return nil
    }


以上をまとめると、 ``collection_config.json`` のポリシー定義では、Org1とOrg2のすべてのピアが、それぞれのプライベートデータベースにasset transferプライベートデータの ``assetID, color, size, owner`` を格納してやりとりができます。しかし、Org1のピアのみがOrg1のコレクションである ``Org1MSPPrivateCollection`` に ``appraisedValue`` のキーのデータを格納してやりとりでき、Org2のピアのみがOrg2のコレクションである ``Org2MSPPrivateCollection`` に ``appraisedValue`` のキーのデータを格納してやりとりすることができます。

追加のデータプライバシーの利点として、コレクションが使用されるので、プライベートデータ *ハッシュ* のみがordererを通過し、プライベートデータ自体は通過せず、ordererからプライベートデータを秘密に保てます。

Start the network
-----------------

これで、プライベートデータの使用方法を示すいくつかのコマンドについて説明する準備が整いました。

:guilabel:`Try it yourself`

プライベートデータチェーンコードをインストール、定義、使用する前に、Fabricテストネットワークを起動する必要があります。このチュートリアルでは、既知の初期状態から操作します。次のコマンドは、アクティブまたは古いDockerコンテナを削除し、以前に生成されたアーティファクトを削除します。したがって、次のコマンドを実行して、以前の環境をクリーンアップします:

.. code:: bash

   cd fabric-samples/test-network
   ./network.sh down

``test-network`` ディレクトリから、次のコマンドを使用して認証局(CA)とCouchDBを使用するFabricテストネットワークを起動できます:

.. code:: bash

   ./network.sh up createChannel -ca -s couchdb

このコマンドは、CouchDBをステートデータベースとして使用しながら、 ``mychannel`` という名前の単一チャネルと2つの組織(それぞれが1つのピアノードを持つ)と認証局と1つのorderingサービスで構成されるFabricネットワークをデプロイします。コレクションではLevelDBまたはCouchDBを使用できます。CouchDBは、プライベートデータでインデックスを使用する方法を示すために選択しています。

.. note:: コレクションを機能させるためには、組織間のゴシップを正しく設定することが重要です。 :doc:`gossip` に関するドキュメントを参照し、特に「アンカーピア」のセクションに注意してください。このチュートリアルではゴシップについては説明せず、ゴシップはテストネットワークですでに設定されているものとしますが、チャネルを設定する場合、ゴシップアンカーピアはコレクションが正しく機能するように設定するために重要です。

.. _pd-install-define_cc:

Deploy the private data smart contract to the channel
-----------------------------------------------------

これで、テストネットワークのスクリプトを用いて、チャネルにスマートコントラクトをデプロイすることができます。
テストネットワークのディレクトリで、次のコマンドを実行してください。

.. code:: bash

   ./network.sh deployCC -ccn private -ccp ../asset-transfer-private-data/chaincode-go/ -ccl go -ccep "OR('Org1MSP.peer','Org2MSP.peer')" -cccg ../asset-transfer-private-data/chaincode-go/collections_config.json

コマンドには、プライベートデータコレクション定義ファイルへのパスを渡す必要があることに注意してください。
チャネルにチェーンコードをデプロイするときに、チャネルの両方の組織は、同一のプライベートデータコレクション定義を :doc:`chaincode_lifecycle` の一部として渡さなくてなりません。
ここではスマートコントラクトのチェーンコードレベルのエンドースメントポリシーを ``"OR('Org1MSP.peer','Org2MSP.peer')"`` としてデプロイしています。
これにより、Org1とOrg2は、他の組織からエンドースメントを得ることなしに、資産を作成することができます。
チェーンコードをデプロイするのに必要な手順は、上記のコマンドを実行した後にログに表示されるのを確認することができます。

両方の組織が `peer lifecycle chaincode approveformyorg <commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg>`__ コマンドによってチェーンコード定義を承認するときには、 ``--collections-config`` フラグによってプライベートデータコレクション定義へのパスがチェーンコード定義に含まれます。
次の `approveformyorg` コマンドがターミナルに表示されるのがわかるでしょう。

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name private --version 1.0 --collections-config ../asset-transfer-private-data/chaincode-go/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

チャネルメンバーがチェーンコード定義の一部としてプライベートデータコレクションに合意すると、データコレクションは、 `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ コマンドでチャネルへコミットされます。
ログからコミットコマンドを探すと、 ``--collections-config`` フラグによって、コレクション定義へのパスが与えられていることがわかるでしょう。

.. code:: bash

    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name private --version 1.0 --sequence 1 --collections-config ../asset-transfer-private-data/chaincode-go/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA


.. _pd-register-identities:

Register identities
-------------------

Private data transferスマートコントラクトは、ネットワークに属する個々のアイデンティによる所有関係をサポートしています。
ここでのシナリオでは、資産の所有者はOrg1のメンバーであり、購入者はOrg2に属すことになるでしょう。
``GetClientIdentity().GetID()`` APIとユーザーの証明書内の情報の関連を強調するために、Org1とOrg2の証明局(CA)を用いて、新たに2つアイデンティティを登録し、それぞれのアイデンティティの証明書と秘密鍵を生成していきましょう。

まず、Fabric CAクライアントを使用するために、下記の環境変数を設定する必要があります。

.. code :: bash

    export PATH=${PWD}/../bin:${PWD}:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/

資産の所有者のアイデンティティを作成するために、Org1のCAを使います。Fabric CAクライアントのホームをOrg1のCAのadmin(このアイデンティティはテストネットワークのスクリプトによって生成されています)のMSPに設定します。

.. code:: bash

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.example.com/

`fabric-ca-client` ツールを使って新しい所有者のクライアントアイデンティティを登録できます。

.. code:: bash

    fabric-ca-client register --caname ca-org1 --id.name owner --id.secret ownerpw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem

これで、エンロール名とシークレットをenrollコマンドに指定することで、アイデンティティの証明書とMSPフォルダの生成することができます。

.. code:: bash

    fabric-ca-client enroll -u https://owner:ownerpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem

次のコマンドを実行して、Node OUの設定ファイルを所有者のアイデンティティMSPフォルダにコピーします。

.. code:: bash

    cp ${PWD}/organizations/peerOrganizations/org1.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp/config.yaml

次にOrg2 CAを使って、購入者のアイデンティティを作成します。Fabric CAクライアントのホームをOrg2 CAのadminに設定します。

.. code:: bash

    export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.example.com/

`fabric-ca-client` ツールを使って新しい所有者のクライアントアイデンティティを登録できます。

.. code:: bash

    fabric-ca-client register --caname ca-org2 --id.name buyer --id.secret buyerpw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem


エンロールして、アイデンティティMSPフォルダを生成できます。

.. code:: bash

    fabric-ca-client enroll -u https://buyer:buyerpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem

次のコマンドを実行して、Node OUの設定ファイルを購入者のアイデンティティMSPフォルダにコピーします。

.. code:: bash

    cp ${PWD}/organizations/peerOrganizations/org2.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp/config.yaml

.. _pd-store-private-data:

Create an asset in private data
-------------------------------

資産の所有者のアイデンティティを作成したので、private dataスマートコントクラトを実行して、新しい資産を作成することができます。
`test-network` ディレクトリのターミナルに、次の複数のコマンドを貼り付けます。

:guilabel:`Try it yourself`


.. code :: bash

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

``CreateFunction`` 関数を使って、assetID(資産ID)が ``asset1`` で、color(色)が ``green`` で、size(サイズ)が ``20`` でappraisedValue(評価額)が ``100`` となるプライベートデータに格納される資産を作成します。
プライベートデータの **appraisedValue** は、 **assetID, color, size** とは別に格納されることに注意してください。
このため、 ``CreateAsset`` 関数は ``PutPrivateData()`` APIをコレクションごとに1回ずつ2回呼び出してプライベートデータを保持します。また、プライベートデータは ``--transient`` フラグを使用して渡されます。一時データとして渡された入力は、データをプライベートに保つためにトランザクションで永続化されません。一時データはバイナリデータとして渡されるため、ターミナルを使用する場合はbase64でエンコードする必要があります。環境変数を使用してbase64でエンコードされた値をキャプチャし、 ``tr`` コマンドを使用して、linux base64コマンドで追加される問題のある改行文字を取り除きます。

次のコマンドを実行して資産を作成します。

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset1\",\"color\":\"green\",\"size\":20,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

次のような結果が表示されます:

.. code:: bash

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

上記のコマンドはOrg1のピアのみを対象にしていることに注意してください。
``CreateAsset`` トランザクションは、 ``assetCollection`` と ``Org1MSPPrivateCollection`` という2つのコレクションに書き込みます。
``Org1MSPPrivateCollection`` は、コレクションへの書き込みにOrg1のピアからのエンドースメントを必要とするいぽ欧で、 ``assetCollection`` はチェーンコードのエンドースメントポリシーである ``"OR('Org1MSP.peer','Org2MSP.peer')"`` を引き継ぎます。
Org1のピアからのエンドースメントは両方のエンドースメントポリシーを満たし、Org2からのエンドースメントなしに資産を作成することができます。

.. _pd-query-authorized:

Query the private data as an authorized peer
--------------------------------------------

このコレクション定義では、Org1とOrg2のすべてのピアがサイドデータベースに ``assetID, color, size, owner`` のプライベートデータを持つことができますが、Org1の考えである ``appraisedValue`` プライベートデータをサイドデータベースに持つことができるのはOrg1のピアのみです。Org1に認められたピアとして、両方のプライベートデータセットを問い合せます。

最初の ``query`` コマンドは、引数として ``assetCollection`` を渡す ``ReadAsset`` 関数を呼び出します。

.. code-block:: GO

   // ReadAsset reads the information from collection
   func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, assetID string) (*Asset, error) {

        log.Printf("ReadAsset: collection %v, ID %v", assetCollection, assetID)
        assetJSON, err := ctx.GetStub().GetPrivateData(assetCollection, assetID) //get the asset from chaincode state
        if err != nil {
            return nil, fmt.Errorf("failed to read asset: %v", err)
        }

        //No Asset found, return empty response
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

2番目の ``query`` コマンドは、引数として ``Org1MSPPrivateDetails`` を渡す ``ReadAssetPrivateDetails`` 関数を呼び出します。

.. code-block:: GO

   // ReadAssetPrivateDetails reads the asset private details in organization specific collection
   func (s *SmartContract) ReadAssetPrivateDetails(ctx contractapi.TransactionContextInterface, collection string, assetID string) (*AssetPrivateDetails, error) {
        log.Printf("ReadAssetPrivateDetails: collection %v, ID %v", collection, assetID)
        assetDetailsJSON, err := ctx.GetStub().GetPrivateData(collection, assetID) // Get the asset from chaincode state
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

では :guilabel:`Try it yourself`

`ReadAsset` 関数を使って、作成された資産の主な詳細を読み取り、Org1として `assetCollection` コレクションにクエリを行います。

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

成功すると、コマンドは次のような結果を返します。

.. code:: bash

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,"owner":"x509::CN=appUser1,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=ca.org1.example.com,O=org1.example.com,L=Durham,ST=North Carolina,C=US"}

資産の `"owner"` は、スマートコントラクトを実行して資産を作成したアイデンティティです。
private dataスマートコントラクトは、 ``GetClientIdentity().GetID()`` APIを使用して、アイデンティティの証明書の名前と発行者を読み取ります。
アイデンティティの証明書の名前と発行者がowner属性にあることを確認できます。

Org1のメンバーとして ``asset1`` の ``appraisedValue`` プライベートデータを問い合せます。

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'

次のような結果が表示されます:

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

.. _pd-query-unauthorized:

Query the private data as an unauthorized peer
----------------------------------------------

次に、Org2のユーザーを操作します。
Org2は、 ``assetCollection`` ポリシーで定義されるように、asset transferのプライベートデータの ``assetID, color, size, owner`` をOrg2のサイドデータベースに持ちますが、Org1の資産の ``appraisedValue`` データは持っていません。
両方のプライベートデータセットを問い合せます。

Switch to a peer in Org2
~~~~~~~~~~~~~~~~~~~~~~~~

次のコマンドを実行して、Org2メンバーとして操作し、Org2ピアにクエリします。

:guilabel:`Try it yourself`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

Query private data Org2 is authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2のピアは、自分のサイドデータベースにasset transferのプライベートデータ( ``assetID, color, size, owner`` )の最初のセットを持っていて、それに ``assetCollection`` 引数で呼ばれる ``ReadAsset()`` 関数を使ってアクセスできるはずです。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

次のような結果が表示されます:

.. code:: json

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,
    "owner":"x509::CN=appUser1,OU=admin,O=Hyperledger,ST=North Carolina,C=US::CN=ca.org1.example.com,O=org1.example.com,L=Durham,ST=North Carolina,C=US" }

Query private data Org2 is not authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

この資産はOrg1によって作られたので、 ``asset1`` に関連付けられた ``appraisedValue`` は、 ``Org1MSPPrivateCollection`` コレクションに格納されています。
この値は、Org2のピアには格納されていません。
次のコマンドを実行して、この資産の ``appraisedValue`` がOrg2ピアの ``Org2MSPPrivateCollection`` に格納されていないことを実際に見てみます。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

空の応答は、asset1のプライベートな詳細は、購入者(Org2)のプライベートコレクションに存在しないことを示しています。

また、Org2のユーザーは、Org1のプライベートデータコレクションから読むこともできません。

.. code:: bash

    peer chaincode query -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'


``"memberOnlyRead": true`` をコレクション設定ファイルで設定したことで、Org1のクライアントのみがコレクションからデータを読むことができると指定しています。
このコレクションから読み込みをしようとしたOrg2のクライアントは、次のような応答を得るだけでしょう。

.. code:: json

    Error: endorsement failure during query. response: status:500 message:"failed to
    read asset details: GET_STATE failed: transaction ID: d23e4bc0538c3abfb7a6bd4323fd5f52306e2723be56460fc6da0e5acaee6b23: tx
    creator does not have read access permission on privatedata in chaincodeName:private collectionName: Org1MSPPrivateCollection"

Org2のユーザーは、プライベートデータの公開ハッシュのみを見ることができます。

.. _pd-transfer-asset:

Transfer the Asset
------------------

``asset1``をOrg2に譲渡するのに何が必要か見てみましょう。
この場合、Org2はOrg1から資産を購入することに同意し、ともに ``appraisedValue`` に合意しなければなりません。
Org1がOrg1の考える ``appraisedValue`` をプライベートデータベースにとどめているのに、どうやったら合意できるのかと思っているかもしれません。
この疑問に答えるために、続けましょう。

:guilabel:`Try it yourself`

ピアのCLIがある端末に戻りましょう。

資産を譲渡するには、購入者(受取人)が、 ``AgreeToTransfer`` チェーンコード関数を呼ぶことで、資産の所有者と同じ ``appraisedValue`` に同意する必要があります。
同意した値は、Org2のピアの ``Org2MSPDetailsCollection`` コレクションに格納されます。
Org2として次のコマンドを実行して、100の評価額に同意します。

.. code:: bash

    export ASSET_VALUE=$(echo -n "{\"assetID\":\"asset1\",\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"AgreeToTransfer","Args":[]}' --transient "{\"asset_value\":\"$ASSET_VALUE\"}"


購入者は、Org2プライベートデータコレクションにある同意した値をクエリすることができます。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

この呼び出しで次の値が返ります。

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

購入者がこの評価額で資産を購入することに合意したので、所有者は資産をOrg2に譲渡することができます。
資産は、資産を所有するアイデンティティによって譲渡する必要があるので、Org1として操作しましょう。

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/owner@org1.example.com/msp
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_ADDRESS=localhost:7051

Org1の所有者は `AgreeToTransfer` トランザクションで追加されたデータを読んで、購入者のアイデンティティを見ることができます。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadTransferAgreement","Args":["asset1"]}'

.. code:: bash

    {"assetID":"asset1","buyerID":"eDUwOTo6Q049YnV5ZXIsT1U9Y2xpZW50LE89SHlwZXJsZWRnZXIsU1Q9Tm9ydGggQ2Fyb2xpbmEsQz1VUzo6Q049Y2Eub3JnMi5leGFtcGxlLmNvbSxPPW9yZzIuZXhhbXBsZS5jb20sTD1IdXJzbGV5LFNUPUhhbXBzaGlyZSxDPVVL"}

これで資産を譲渡するのに必要なものがすべてそろいました。
スマートコントラクトは、 ``GetPrivateDataHash()`` 関数を使って ``Org1MSPPrivateCollection`` の資産の評価額のハッシュが、 ``Org2MSPPrivateCollection`` の評価額のハッシュと一致することを確かめます。
もし、ハッシュが一致したら、所有者とこの購入者が同じ資産価値で合意したことが確認されます。
条件が満たされた場合、譲渡関数は、購入者のクライアントIDを譲渡の合意から読み取り、購入者を資産の新しい所有者にします。
譲渡の関数は、もとの所有者のコレクションから資産の評価額を削除も行い、さらに ``assetCollection`` から譲渡の合意を削除します。

次のコマンドを実行して、資産を譲渡します。
所有者は資産のIDと購入者の組織のMSP IDを譲渡のトランザクションに指定する必要があります。

.. code:: bash

    export ASSET_OWNER=$(echo -n "{\"assetID\":\"asset1\",\"buyerMSP\":\"Org2MSP\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"TransferAsset","Args":[]}' --transient "{\"asset_owner\":\"$ASSET_OWNER\"}" --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

譲渡の結果を見るために、 ``asset1`` をクエリすることができます。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAsset","Args":["asset1"]}'

結果は、購入者のアイデンティティが資産を所有していることを表すでしょう。

.. code:: bash

    {"objectType":"asset","assetID":"asset1","color":"green","size":20,"owner":"x509::CN=appUser2, OU=client + OU=org2 + OU=department1::CN=ca.org2.example.com, O=org2.example.com, L=Hursley, ST=Hampshire, C=UK"}

資産の `"owner"` が購入者のアイデンティティになっています。

またプライベートな詳細情報がOrg1のコレクションから削除されていることも確かめることができます。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org1MSPPrivateCollection","asset1"]}'

資産のプライベートデータがOrg1のプライベートデータコレクションから削除されているため、このクエリは空の結果を返すでしょう。


.. _pd-purge:

Purge Private Data
------------------

プライベートデータが短い期間の間しか保持しなくてもよいようなユースケースのために、一定のブロック数の後にデータを"削除"することができます。このとき、トランザクションのイミュータブルな証拠として、データのハッシュ値のみが残されます。
もしデータが機密情報を含んでいて、あるトランザクションで過去に使われたが、今は必要がなくなったとき、あるいはデータがオフチェーンのデータベースに複製されとき、組織はプライベートデータを削除しようとすることがあるでしょう。

ここでの例における ``appraisedValue`` のデータはプライベートな合意を含んでおり、組織は一定時間後に消滅してほしいと思うかもしれません。
したがって、これは限られた生存期間を持つということであり、コレクション定義の ``blockToLive`` プロパティを用いて、ブロックチェーンに一定のブロック数存在したのちに削除することができます。

``Org2MSPPrivateCollection`` の定義では、 ``blockToLive`` プロパティの値は ``3`` となっています。
これはこのデータがサイドデータベースで3ブロックの間だけ存在し、その後削除されるということを意味しています。
もし、チャネルでさらなるブロックを作成した場合、 Org2が同意した ``appraisedValue`` は最終的に削除されます。
3ブロックを新たに作成して、次のようにして実際に確かめることができます。

:guilabel:`Try it yourself`

ターミナルで次のコマンドを実行して、Org2のメンバーを操作しOrg2のピアを対象にします。

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/buyer@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

``Org2MSPPrivateCollection`` の ``appraisedValue`` はまだクエリすることができます。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'

ログに値が表示されるのがわかるはずです。

.. code:: bash

    {"assetID":"asset1","appraisedValue":100}

プライベートデータが削除されるまでにどれだけのブロックを追加したのかを把握する必要があるので、新しいターミナルウィンドウを開き、次のコマンドを実行してOrg2ピアのプライベートデータのログを表示してください。
一番高いブロック番号に注目してください。


.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

では、Org2のメンバーとして操作していたターミナルに戻り、3つ新しいアセットを作るために次のコマンドを実行してください。
各コマンドが1つずつブロックを作成します。

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset2\",\"color\":\"blue\",\"size\":30,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset3\",\"color\":\"red\",\"size\":25,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

.. code:: bash

    export ASSET_PROPERTIES=$(echo -n "{\"objectType\":\"asset\",\"assetID\":\"asset4\",\"color\":\"orange\",\"size\":15,\"appraisedValue\":100}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"CreateAsset","Args":[]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}"

もう一つのターミナルに戻り、次のコマンドを実行して、新しい資産によって3つのブロックが作成されたことを確認しましょう。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

これで、 ``appriasedValue`` は ``Org2MSPDetailsCollection`` から削除されてしまいました。
クエリをもう一回発行して、応答が空であることを確認しましょう。

.. code:: bash

    peer chaincode query -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n private -c '{"function":"ReadAssetPrivateDetails","Args":["Org2MSPPrivateCollection","asset1"]}'


.. _pd-indexes:

Using indexes with private data
-------------------------------

インデックスは、チェーンコードとともに ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` ディレクトリにインデックスをパッケージ化することで、プライベートデータコレクションにも適用できます。インデックスの例は `ここ <https://github.com/hyperledger/fabric-samples/blob/main/asset-transfer-private-data/chaincode-go/META-INF/statedb/couchdb/collections/assetCollection/indexes/indexOwner.json>`__ にあります。

実稼働環境へのチェーンコードの配置では、チェーンコードがピアにインストールされ、チャネル上でインスタンス化された後に、チェーンコードとサポートするインデックスが自動的に1つの単位として配置されるように、チェーンコードとともにインデックスを定義することをお勧めします。関連付けられたインデックスは、コレクションJSONファイルの場所を示す ``--collections-config`` フラグが指定されることによって、チャネル上でのチェーンコードのインスタンス化タイミングで自動的に配置されます。

.. note:: 暗黙的なプライベートデータコレクションに対してインデックスを作成することはできません。
          暗黙的なコレクションは組織名に基づき自動的に作られます。
          名前のフォーマットは、 ``_implicit_org_<OrgsMSPid>`` です。
          詳細については、 `FAB-17916 <https://jira.hyperledger.org/browse/FAB-17916>`__ を参照してください。

Clean up
--------

プライベートデータスマートコントラクトを使い終わったら、 ``network.sh`` スクリプトを用いてテストネットワークを削除することができます。


.. code:: bash

  ./network.sh down

このコマンドは、作成したCAやピアやオーダリングノードを削除します。
台帳のすべてのデータが失われることに注意しましょう。
もし、またチュートリアルをやり直したい場合には、きれいな初期状態から始めることになります。

.. _pd-ref-material:

Additional resources
--------------------

その他のプライベートデータに関する教育については、ビデオチュートリアルが作成されています。

.. note:: このビデオでは、以前のライフサイクルモデルを使用して、チェーンコードを含むプライベートデータコレクションをインストールしています。

.. raw:: html



   <br/><br/>
   <iframe width="560" height="315" src="https://www.youtube.com/embed/qyjDi93URJE" frameborder="0" allowfullscreen></iframe>
   <br/><br/>

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
