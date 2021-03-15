Using Private Data in Fabric
============================

このチュートリアルでは、コレクションを使用して、ブロックチェーンネットワーク上のプライベートデータを認可された組織のピア上に格納および取得する方法について説明します。

このチュートリアルの情報は、プライベートデータストアとその使用例に関する知識を前提としています。詳細については、 :doc:`private-data/private-data` を参照してください。

.. note:: この手順では、Fabric v2.0リリースで導入された新しいFabricチェーンコードライフサイクルを使用します。以前のライフサイクルモデルを使用したチェーンコードでプライベートデータを使用する場合は、v1.4バージョンのチュートリアル `Using Private Data in Fabric tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/private_data_tutorial.html>`__ を参照してください。

このチュートリアルでは、次の手順に従って、Fabricでプライベートデータを定義、構成、使用する方法について学習します:

#. :ref:`pd-build-json`
#. :ref:`pd-read-write-private-data`
#. :ref:`pd-install-define_cc`
#. :ref:`pd-store-private-data`
#. :ref:`pd-query-authorized`
#. :ref:`pd-query-unauthorized`
#. :ref:`pd-purge`
#. :ref:`pd-indexes`
#. :ref:`pd-ref-material`

このチュートリアルでは、 `marbles private data sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/chaincode/marbles02_private>`__ をFabricテストネットワークに展開し、プライベートデータのコレクションを作成、展開、および使用する方法を示します。タスク :doc:`install` が完了している必要があります。

.. _pd-build-json:

Build a collection definition JSON file
---------------------------------------

チャネル上のデータをプライベート化する最初のステップは、プライベートデータへのアクセスを定義するコレクション定義を構築することです。

コレクション定義には、データを保持できるユーザー、データが配布されるピアの数、プライベートデータの広めるのに必要なピアの数、プライベートデータがプライベートデータベースに保持される期間が記述されます。後で、チェーンコードAPI ``PutPrivateData`` および ``GetPrivateData`` を使用して、保護されるプライベートデータにコレクションをマップする方法について説明します。

コレクション定義は、次のプロパティで構成されます:

.. _blockToLive:

- ``name`` : コレクションの名前。

- ``policy`` : コレクションデータの保持を許可する組織ピアを定義します。

- ``requiredPeerCount`` : チェーンコードのエンドースメントの条件としてプライベートデータを広めるために必要なピア数

- ``maxPeerCount`` : データの冗長性のために、現在のエンドースピアがデータの配布を試行する他のピアの数。エンドースピアが停止した場合、プライベートデータのプル要求があると、コミット時にこれらの他のピアが使用可能になります。

- ``blockToLive`` : 価格設定や個人情報などの機密性の高い情報の場合、この値は、データがプライベートデータベースでブロック単位で存続する期間を表します。データは、プライベートデータベースで指定したブロック数の間存続し、その後パージされて、このデータはネットワーク上からなくなります。プライベートデータを無期限に保持する、つまりプライベートデータをパージしないようにするには、 ``blockToLive`` プロパティを ``0`` に設定します。

- ``memberOnlyRead`` : 値が ``true`` の場合、ピアは、コレクションメンバー組織の1つに属するクライアントだけがプライベートデータへの読み取りアクセスを許可されるように自動的に強制します。

プライベートデータの使用方法を説明するために、marblesプライベートデータの例には、 ``collectionMarbles`` と ``collectionMarblePrivateDetails`` という2つのプライベートデータコレクション定義が含まれています。 ``collectionMarbles`` 定義の ``policy`` プロパティでは、チャネルのすべてのメンバー(Org1およびOrg2)がプライベートデータベース内にプライベートデータを保持できます。 ``collectionMarblesPrivateDetails`` のコレクションでは、Org1のメンバーのみがプライベートデータベース内にプライベートデータを保持できます。

ポリシー定義の作成の詳細については、 :doc:`endorsement-policies` トピックを参照してください。

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

これらのポリシーによって保護されるデータは、チェーンコードでマップされ、チュートリアルの後半で参照します。

このコレクション定義ファイルは、チェーンコード定義が `peer lifecycle chaincode commit command <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ を使用してチャネルにコミットされるときに展開されます。このプロセスの詳細については、以下のセクション3で説明します。

.. _pd-read-write-private-data:

Read and Write private data using chaincode APIs
------------------------------------------------

チャネル上のデータをプライベート化する方法を理解するための次のステップは、チェーンコード内にデータ定義を構築することです。marblesプライベートデータサンプルは、データへのアクセス方法に従って、プライベートデータを2つの個別のデータ定義に分割します。

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

特に、プライベートデータへのアクセスは以下のように制限されます:

- ``名前、色、サイズ、および所有者`` は、チャネルのすべてのメンバー(Org1およびOrg2)に表示されます
- ``価格`` はOrg1のメンバーにのみ表示される

したがって、2つの異なるプライベートデータセットがmarbleプライベートデータサンプルに定義されます。このデータのアクセスを制限するコレクションポリシーへのマッピングは、チェーンコードAPIによって制御されます。特に、コレクション定義を使用したプライベートデータの読取りおよび書込みは、 ``GetPrivateData()`` および ``PutPrivateData()`` をコールすることによって実行されます。このメソッドは、`ここ <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub>`_ にあります。

次の図は、marbleプライベートデータサンプルで使用されるプライベートデータモデルを示しています。

.. image:: images/SideDB-org1-org2.png


Reading collection data
~~~~~~~~~~~~~~~~~~~~~~~~

データベース内のプライベートデータを問い合せるには、chaincode API ``GetPrivateData()`` を使用します。 ``GetPrivateData()`` は、 **コレクション名** とデータキーの2つの引数を取ります。コレクション ``collectionMarble`` sでは、Org1とOrg2のメンバーがサイドデータベース内にプライベートデータを持つことができ、コレクション ``collectionMarblePrivateDetails`` では、Org1のメンバーのみがサイドデータベース内にプライベートデータを持つことができます。実装の詳細は、次の2つの `marbles private data functions <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02_private/go/marbles_chaincode_private.go>`__ を参照してください:

 * ``名前、色、サイズ、所有者`` 属性の値を問い合わせる **readMarble**
 * ``価格`` 属性の値を問い合わせる **readMarblePrivateDetails**

このチュートリアルの後半でpeerコマンドを使用してデータベースクエリーを発行する際、これらの2つの関数を呼び出します。

Writing private data
~~~~~~~~~~~~~~~~~~~~

プライベートデータをプライベートデータベースに格納するには、chaincode API ``PutPrivateData()`` を使用します。APIにはコレクションの名前も必要です。marbleプライベートデータサンプルには2つの異なるコレクションが含まれているため、chaincodeでは2回呼び出されます:

1. ``collectionMarbles`` というコレクションを使って、プライベートデータの ``名前、色、サイズ、所有者`` を書き込む。
2. ``collectionMarblePrivateDetails`` というコレクションを使って、プライベートデータの ``価格`` を書き込む。

たとえば、次の ``initMarble`` 関数のスニペットでは、 ``PutPrivateData()`` がプライベートデータのセットごとに1回ずつ、2回呼び出されます。

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


以上をまとめると、 ``collection.json`` のポリシー定義では、Org1とOrg2のすべてのピアが、それぞれのプライベートデータベースにマーブルプライベートデータの ``名前、色、サイズ、所有者`` を格納して取引ができます。しかし、Org1のピアのみが、プライベートデータベースに ``価格`` プライベートデータを格納して取引できます。

追加のデータプライバシーの利点として、コレクションが使用されるので、プライベートデータハッシュのみがordererを通過し、プライベートデータ自体は通過せず、ordererからプライベートデータを秘密に保てます。

Start the network
-----------------

これで、プライベートデータの使用方法を示すいくつかのコマンドについて説明する準備が整いました。

:guilabel:`Try it yourself`

以下のmarblesプライベートデータチェーンコードをインストール、定義、使用する前に、Fabricテストネットワークを起動する必要があります。このチュートリアルでは、既知の初期状態から操作します。次のコマンドは、アクティブまたは古いDockerコンテナを削除し、以前に生成されたアーティファクトを削除します。したがって、次のコマンドを実行して、以前の環境をクリーンアップします:

.. code:: bash

   cd fabric-samples/test-network
   ./network.sh down

チュートリアルをまだ実行していない場合は、ネットワークに展開する前に、チェーンコードの依存関係をベンダーに提供する必要があります。次のコマンドを実行します:

.. code:: bash

    cd ../chaincode/marbles02_private/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network


このチュートリアルをすでに実行している場合は、marblesのプライベートデータチェーンコードの基礎となるDockerコンテナも削除します。次のコマンドを実行して、以前の環境をクリーンアップします:

.. code:: bash

   docker rm -f $(docker ps -a | awk '($2 ~ /dev-peer.*.marblesp.*/) {print $1}')
   docker rmi -f $(docker images | awk '($1 ~ /dev-peer.*.marblesp.*/) {print $3}')

``test-network`` ディレクトリから、次のコマンドを使用してcouchDBを使用するFabricテストネットワークを起動できます:

.. code:: bash

   ./network.sh up createChannel -s couchdb

このコマンドは、CouchDBを状態データベースとして使用しながら、 ``mychannel`` という名前の単一チャネルと2つの組織(それぞれが1つのピアノードを持つ)と1つのorderingサービスで構成されるFabricネットワークをデプロイします。コレクションではLevelDBまたはCouchDBを使用できます。CouchDBは、プライベートデータでインデックスを使用する方法を示すために選択しています。

.. note:: コレクションを機能させるためには、組織間のゴシップを正しく設定することが重要です。 :doc:`gossip` に関するドキュメントを参照し、特に「アンカーピア」のセクションに注意してください。このチュートリアルではゴシップについては説明せず、ゴシップはテストネットワークですでに設定されているものとしますが、チャネルを設定する場合、ゴシップアンカーピアはコレクションが正しく機能するように設定するために重要です。

.. _pd-install-define_cc:

Install and define a chaincode with a collection
-------------------------------------------------

クライアントアプリケーションは、チェーンコードを介してブロックチェーン元帳と対話します。したがって、トランザクションを実行して承認するすべてのピアにチェーンコードをインストールする必要があります。ただし、チェーンコードと対話する前に、チャネルのメンバーは、プライベートデータコレクション構成を含むチェーンコードガバナンスを確立するチェーンコード定義に同意する必要があります。 :doc:`commands/peerlifecycle` を使用して、チャネルのチェーンコードをパッケージ化してインストールし、定義しいきます。

チェーンコードは、ピアにインストールする前にパッケージ化する必要があります。 `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ コマンドを使用してmarblesチェーンコードをパッケージ化できます。

テストネットワークにはOrg1とOrg2の2つの組織が含まれ、それぞれに1つのピアがあります。したがって、chaincodeパッケージは2つのピアにインストールする必要があります:

- peer0.org1.example.com
- peer0.org2.example.com

チェーンコードがパッケージ化されたら、 `peer lifecycle chaincode install <commands/peerlifecycle.html#peer-lifecycle-chaincode-install>`__ コマンドを使用して、各ピアにMarblesチェーンコードをインストールできます。

:guilabel:`Try it yourself`

テストネットワークを開始しているとして、次の環境変数をCLIにコピー&ペーストしてネットワークと対話し、Org1管理者として動作します。この際、 `test-network` ディレクトリにいることを確認してください。

.. code:: bash

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

1. marblesプライベートデータチェーンコードをパッケージ化するには、次のコマンドを使用します。

.. code:: bash

    peer lifecycle chaincode package marblesp.tar.gz --path ../chaincode/marbles02_private/go/ --lang golang --label marblespv1

このコマンドは、marblesp.tar.gzという名前のチェーンコードパッケージを作成します。

2.次のコマンドを使用して、chaincodeパッケージをpeer ``peer0.org1.example.com`` にインストールします。

.. code:: bash

    peer lifecycle chaincode install marblesp.tar.gz

インストールに成功すると、次のようなチェーンコード識別子が返されます:

.. code:: bash

    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nKmarblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd\022\nmarblespv1" >
    2019-04-22 19:09:04.336 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marblespv1:57f5353b2568b79cb5384b5a8458519a47186efc4fcadb98280f5eae6d59c1cd

3.ここで、CLIをOrg2管理者として使用します。次のコマンドブロックをグループとしてコピーして貼り付け、一度に実行します:

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

4. 次のコマンドを実行して、Org2ピアにchaincodeをインストールします:

.. code:: bash

    peer lifecycle chaincode install marblesp.tar.gz


Approve the chaincode definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

チェーンコードを使用する各チャネルメンバーは、組織のチェーンコード定義を承認する必要があります。このチュートリアルでは両方の組織がチェーンコードを使用するため、 `peer lifecycle chaincode approveformyorg <commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg>`__ コマンドを使用して、Org1とOrg2のチェーンコード定義を承認する必要があります。チェーンコード定義には、 ``marbles02_private`` サンプルに付随するプライベートデータコレクション定義も含まれています。 ``--collections-config`` フラグを使用してコレクションJSONファイルへのパスを提供します。

:guilabel:`Try it yourself`

``test-network`` ディレクトリから次のコマンドを実行して、Org1とOrg2の定義を承認します。

1. 次のコマンドを使用して、インストールされているチェーンコードのパッケージIDをピアに照会します。

.. code:: bash

    peer lifecycle chaincode queryinstalled

このコマンドは、installコマンドと同じパッケージ識別子を返します。次のような出力が表示されます:

.. code:: bash

    Installed chaincodes on peer:
    Package ID: marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e, Label: marblespv1

2. パッケージIDを環境変数として宣言します。 ``peer lifecycle chaincode queryinstalled`` によって返されたmarblespv1のパッケージIDを次のコマンドに貼り付けます。パッケージIDはすべてのユーザーで同じではない可能性があるため、コンソールから返されたパッケージIDを使用してこの手順を完了する必要があります。

.. code:: bash

    export CC_PACKAGE_ID=marblespv1:f8c8e06bfc27771028c4bbc3564341887881e29b92a844c66c30bac0ff83966e

3. CLIがOrg1として実行されていることを確認します。次のコマンドブロックをグループとしてピアコンテナにコピー&ペーストし、一度に実行します:

.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

4. 次のコマンドを使用して、Org1のmarblesプライベートデータチェーンコードの定義を承認します。このコマンドには、コレクション定義ファイルへのパスが含まれています。

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

コマンドが正常に完了すると、次のようなメッセージが表示されます:

.. code:: bash

    2020-01-03 17:26:55.022 EST [chaincodeCmd] ClientWait -> INFO 001 txid [06c9e86ca68422661e09c15b8e6c23004710ea280efda4bf54d501e655bafa9b] committed with status (VALID) at

5. ここで、CLIを使用してOrg2に切り替えます。次のコマンドブロックをグループとしてピアコンテナにコピー&ペーストし、一度に実行します。

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

6. これで、Org2のチェーンコード定義を承認できます:

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

Commit the chaincode definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

十分な数の組織(この場合は過半数)がチェーンコード定義を承認すると、1つの組織が定義をチャネルにコミットできます。

チェーンコード定義をコミットするには、 `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ コマンドを使用します。このコマンドは、コレクション定義もチャネルに配布します。

チェーンコード定義がチャネルにコミットされた後、チェーンコードを使用する準備ができました。marblesプライベートデータチェーンコードには開始関数が含まれているため、チェーンコード内の他の関数を使用する前に、 `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-instantiate>`__ コマンドを使用して ``Init()`` を呼び出す必要があります。

:guilabel:`Try it yourself`

1. 次のコマンドを実行して、marblesプライベートデータチェーンコードの定義をチャネル ``mychannel`` にコミットします。

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marblesp --version 1.0 --sequence 1 --collections-config ../chaincode/marbles02_private/collections_config.json --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA


コミットトランザクションが正常に完了すると、次のようなメッセージが表示されます:

.. code:: bash

    2020-01-06 16:24:46.104 EST [chaincodeCmd] ClientWait -> INFO 001 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:9051
    2020-01-06 16:24:46.184 EST [chaincodeCmd] ClientWait -> INFO 002 txid [4a0d0f5da43eb64f7cbfd72ea8a8df18c328fb250cb346077d91166d86d62d46] committed with status (VALID) at localhost:7051

.. _pd-store-private-data:

Store private data
------------------

marblesプライベートデータサンプル内のすべてのプライベートデータを処理する権限を持つOrg1のメンバーとして、Org1ピアに戻り、marbleの追加要求を発行します:

:guilabel:`Try it yourself`

次のコマンドセットをコピーし、 `test-network` ディレクトリのCLIに貼り付けます:

.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

marbles ``initMarble`` 関数を起動して、 ``marble1`` という ``tom`` によって所有され、色は ``blue`` 、サイズは ``35`` 、価格は ``99`` のmarbleをプライベートデータとして作成します。プライベートデータの**価格**はプライベートデータの**名前、所有者、色、サイズ**とは別に格納されることに注意してください。このため、 ``initMarble`` 関数は ``PutPrivateData()`` APIをコレクションごとに1回ずつ2回呼び出してプライベートデータを保持します。また、プライベートデータは ``--transient`` フラグを使用して渡されます。一時データとして渡された入力は、データをプライベートに保つためにトランザクションで永続化されません。一時データはバイナリデータとして渡されるため、CLIを使用する場合はbase64でエンコードする必要があります。環境変数を使用してbase64でエンコードされた値をキャプチャし、 ``tr`` コマンドを使用して、linux base64コマンドで追加される問題のある改行文字を取り除きます。

.. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble1\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["InitMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

次のような結果が表示されます:

.. code:: bash

    [chaincodeCmd] chaincodeInvokeOrQuery->INFO 001 Chaincode invoke successful. result: status:200

.. _pd-query-authorized:

Query the private data as an authorized peer
--------------------------------------------

このコレクション定義では、Org1とOrg2のすべてのメンバーがサイドデータベースに ``名前、色、サイズ、所有者`` のプライベートデータを持つことができますが、 ``価格`` プライベートデータをサイドデータベースに持つことができるのはOrg1のピアのみです。Org1の認可ピアとして、両方のプライベートデータセットを問い合せます。

最初の ``query`` コマンドは、引数として ``collectionMarbles`` を渡す ``readMarble`` 関数を呼び出します。

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

2番目の ``query`` コマンドは、引数として ``collectionMarblePrivateDetails`` を渡す ``readMarblePrivateDetails`` 関数を呼び出します。

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

Org1のメンバーとして ``marble1`` の ``名前、色、サイズおよび所有者`` のプライベートデータを問い合せます。問合せは台帳に記録されないため、一時入力としてmarble名を渡す必要はありません。

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarble","marble1"]}'

次のような結果が表示されます:

.. code:: bash

    {"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}

Org1のメンバーとして ``marble1`` の ``価格`` プライベートデータを問い合せます。

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

次のような結果が表示されます:

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

.. _pd-query-unauthorized:

Query the private data as an unauthorized peer
----------------------------------------------

次に、Org2のメンバーに切り替えます。Org2のサイドデータベースにmarblesプライベートデータの ``名前、色、サイズ、所有者`` がありますが、marbels ``価格`` データは格納されません。両方のプライベートデータセットを問い合せます。

Switch to a peer in Org2
~~~~~~~~~~~~~~~~~~~~~~~~

次のコマンドを実行して、Org2管理者として動作し、Org2ピアを照会します。

:guilabel:`Try it yourself`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

Query private data Org2 is authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2のピアは、自分のサイドデータベースにmarblesのプライベートデータ( ``名前、色、サイズ、所有者`` )の最初のセットを持っていて、それに ``collectionMarbles`` 引数で呼ばれる ``readMarble()`` 関数を使ってアクセスできるはずです。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarble","marble1"]}'

次のような結果が表示されます:

.. code:: json

    {"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}

Query private data Org2 is not authorized to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Org2のピアは、サイドデータベースにmarbles ``価格`` のプライベートデータを持っていません。このデータをクエリーしようとすると、パブリックステートに一致するキーのハッシュを返しますが、プライベートステートは含まれません。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

次のような結果が表示されます:

.. code:: json

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Failed to get private details for marble1:
    GET_STATE failed: transaction ID: d9c437d862de66755076aeebe79e7727791981606ae1cb685642c93f102b03e5:
    tx creator does not have read access permission on privatedata in chaincodeName:marblesp collectionName: collectionMarblePrivateDetails\"}"

Org2のメンバーは、プライベートデータの公開ハッシュだけを見ることができます。

.. _pd-purge:

Purge Private Data
------------------

プライベートデータがオフチェーンデータベースにレプリケートされるまで台帳にのみ存在する必要があるユースケースでは、特定のセット数のブロックが生成された後にデータを"削除"し、トランザクションのイミュータブルな証拠として機能するプライベートデータのハッシュのみを残すことができます。

取引当事者がチャネル上の他の組織に開示することを望まない個人情報または秘密情報を含むプライベートデータが存在する可能性があります。したがって、プライベートデータは寿命が限られており、コレクション定義の ``blockToLive`` プロパティを使用された、指定ブロック数分ブロックチェーン上に変更されずに存在した後で削除できます。

``collectionMarblePrivateDetails`` 定義には、 ``blockToLive`` プロパティ値として3があります。つまり、このデータは3ブロック追加されるまでサイドデータベースに保存され、その後消去されます。すべての部分を結び付けて、このコレクション定義 ``collectionMarblePrivateDetails`` は、 ``PutPrivateData()`` APIを呼び出して ``collectionMarblePrivateDetails`` を引数として渡すことで、 ``initMarble()`` 関数において、 ``価格`` プライベートデータに関連付けられていることを思い出してください。

チェーンにブロックを追加する手順を実行します。次に、チェーンに4つの新規ブロックを追加する4つの新規トランザクション(3つのmarble転送に続いて、新規のmarbleを作成)を発行して、価格情報が消去されるのを確認します。4番目のトランザクション(3番目のmarble転送)の後、価格プライベートデータが消去されることを確認します。

:guilabel:`Try it yourself`

次のコマンドを使用して、Org1に戻ります。次のコードブロックをコピーして貼り付け、ピアコンテナ内で実行します:

.. code :: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

新しいターミナルウィンドウを開き、次のコマンドを実行して、このピアのプライベートデータログを表示します。最大のブロック番号に注目してください。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'


ピアコンテナに戻り、次のコマンドを実行して **marble1** 価格データを問い合せます。(データが取引されないため、問合せでは台帳に新規トランザクションは作成されません)

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

次のような結果が表示されます:

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

``価格`` データはまだプライベートデータ台帳にあります。

次のコマンドを実行して、新しい **marble2** を作成します。このトランザクションはチェーン上に新しいブロックを作成します。

.. code:: bash

    export MARBLE=$(echo -n "{\"name\":\"marble2\",\"color\":\"blue\",\"size\":35,\"owner\":\"tom\",\"price\":99}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["InitMarble"]}' --transient "{\"marble\":\"$MARBLE\"}"

ターミナルウィンドウに戻り、このピアのプライベートデータログをもう一度表示します。ブロックの高さが1だけ増加します。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

ピアコンテナに戻り、次のコマンドを実行して、 **marble1** の価格データを再度問い合わせます:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

プライベートデータは削除されていないため、結果は前の問い合せ結果と同じです:

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

次のコマンドを実行して、marble2を"joe"に転送します。このトランザクションは、チェーンに2つ目の新しいブロックを追加します。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"joe\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

ターミナルウィンドウに戻り、このピアのプライベートデータログをもう一度表示します。ブロックの高さが1だけ増加します。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

ピアコンテナに戻り、次のコマンドを実行してmarble1の価格データを照会します:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

価格のプライベートデータはまだ表示されるはずです。

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

次のコマンドを実行して、marble2を「tom」に転送します。このトランザクションにより、チェーン上に3つ目の新しいブロックが作成されます。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"tom\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

ターミナルウィンドウに戻り、このピアのプライベートデータログをもう一度表示します。ブロックの高さが1だけ増加します。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

ピアコンテナに戻り、次のコマンドを実行してmarble1の価格データを照会します:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

価格データはまだ表示されます。

.. code:: bash

    {"docType":"marblePrivateDetails","name":"marble1","price":99}

最後に、次のコマンドを実行してmarble2を"jerry"に転送します。このトランザクションでは、チェーン上に4つ目の新規ブロックが作成されます。 ``価格`` プライベートデータは、このトランザクション後に消去する必要があります。

.. code:: bash

    export MARBLE_OWNER=$(echo -n "{\"name\":\"marble2\",\"owner\":\"jerry\"}" | base64 | tr -d \\n)
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marblesp -c '{"Args":["TransferMarble"]}' --transient "{\"marble_owner\":\"$MARBLE_OWNER\"}"

ターミナルウィンドウに戻り、このピアのプライベートデータログをもう一度表示します。ブロックの高さが1だけ増加します。

.. code:: bash

    docker logs peer0.org1.example.com 2>&1 | grep -i -a -E 'private|pvt|privdata'

ピアコンテナに戻り、次のコマンドを実行してmarble1の価格データを照会します:

.. code:: bash

    peer chaincode query -C mychannel -n marblesp -c '{"Args":["ReadMarblePrivateDetails","marble1"]}'

価格データが削除されているため、表示できなくなります。次のような情報が表示されます:

.. code:: bash

    Error: endorsement failure during query. response: status:500
    message:"{\"Error\":\"Marble private details does not exist: marble1\"}"

.. _pd-indexes:

Using indexes with private data
-------------------------------

インデックスは、チェーンコードとともに ``META-INF/statedb/couchdb/collections/<collection_name>/indexes`` ディレクトリにインデックスをパッケージ化することで、プライベートデータコレクションにも適用できます。インデックスの例は `ここ <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`__ にあります。

実稼働環境へのチェーンコードの配置では、チェーンコードがピアにインストールされ、チャネル上でインスタンス化された後に、チェーンコードとサポートするインデックスが自動的に1つの単位として配置されるように、チェーンコードとともにインデックスを定義することをお勧めします。関連付けられたインデックスは、コレクションJSONファイルの場所を示す ``--collections-config`` フラグが指定されることによって、チャネル上でのチェーンコードのインスタンス化タイミングで自動的に配置されます。


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
