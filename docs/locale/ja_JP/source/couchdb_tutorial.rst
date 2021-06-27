
Using CouchDB
=============

このチュートリアルでは、Hyperledger FabricでCouchDBをステートデータベースとして使用するために必要な手順を説明します。これまでに、Fabricの概念を理解し、サンプルとチュートリアルをいくつか確認できたはずです。

.. note:: この手順では、Fabric v2.0リリースで導入された新しいFabricチェーンコードライフサイクルを使用します。以前のライフサイクルモデルを使用したチェーンコードでインデックスを使用する場合は、v1.4バージョンの `Using CouchDB <https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html>`__ を参照してください。

このチュートリアルでは、次の手順を実行します:

#. :ref:`cdb-enable-couch`
#. :ref:`cdb-create-index`
#. :ref:`cdb-add-index`
#. :ref:`cdb-install-deploy`
#. :ref:`cdb-query`
#. :ref:`cdb-best`
#. :ref:`cdb-pagination`
#. :ref:`cdb-update-index`
#. :ref:`cdb-delete-index`

CouchDBの詳細については :doc:`couchdb_as_state_database` を、Fabric台帳の詳細については `Ledger <ledger/ledger.html>`__ トピックを参照してください。ブロックチェーンネットワークでCouchDBを活用する方法については、以下のチュートリアルを参照してください。

このチュートリアルでは、 `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__ をユースケースとして使用して、FabricでのCouchDBの使用方法を示し、MarblesをFabricテストネットワークにデプロイします。タスクの :doc:`install` が完了しているはずです。

Why CouchDB?
~~~~~~~~~~~~

Fabricでは、2種類のピアデータベースがサポートされています。LevelDBは、ピアノードに埋め込まれたデフォルトのステートデータベースです。LevelDBは、単純なキーと値のペアとしてチェーンコードデータを格納し、キー、キー範囲および複合キークエリのみをサポートしています。CouchDBはオプションの代替ステートデータベースで、JSONとして台帳のデータをモデル化し、キーではなくデータ値に対してリッチクエリを発行できます。また、CouchDBでは、チェーンコードとともにインデックスを配置してクエリをより効率的にし、大規模なデータセットにクエリを実行できます。

CouchDBの利点、つまりコンテンツベースのJSONクエリを活用するには、データをJSON形式でモデル化する必要があります。ネットワークを設定する前に、LevelDBとCouchDBのどちらを使用するかを決定する必要があります。LevelDBからCouchDBへのピアの切り替えは、データ互換性の問題によりサポートされていません。ネットワーク上のすべてのピアが同じデータベースタイプを使用する必要があります。JSONとバイナリデータ値が混在している場合でもCouchDBを使用できますが、バイナリ値はキー、キー範囲および複合キークエリに基づいてのみクエリできます。

.. _cdb-enable-couch:

Enable CouchDB in Hyperledger Fabric
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CouchDBは、ピアとは別のデータベースプロセスとして実行されます。セットアップ、管理、および操作の観点から、さらに考慮すべき点があります。 `CouchDB <https://hub.docker.com/_/couchdb/>`__ のDockerイメージが利用可能です。ピアと同じサーバー上で実行することをお薦めします。ピアごとに1つのCouchDBコンテナをセットアップし、 ``core.yaml`` の構成を変更して各ピアコンテナを更新し、CouchDBコンテナを指すようにする必要があります。 ``core.yaml`` ファイルは、環境変数FABRIC_CFG_PATHで指定されたディレクトリに配置する必要があります:

* Docker環境の場合、 ``core.yaml`` は事前に設定されており、ピアコンテナ ``FABRIC_CFG_PATH`` フォルダに置かれています。ただし、Docker環境を使用する場合は、一般的に ``docker-compose-couch.yaml`` を編集して環境変数を渡し、core.yamlを上書きします。
* ネイティブバイナリーを利用したデプロイメントの場合、 ``core.yaml`` はリリースアーティファクト配布に含まれています。

``core.yaml`` の ``stateDatabase`` セクションを編集します。 ``stateDatabase`` として ``CouchDB`` を指定し、関連する ``couchDBConfig`` プロパティに値を入力します。詳細については、 `CouchDB configuration <couchdb_as_state_database.html#couchdb-configuration>`__ を参照してください。

.. _cdb-create-index:

Create an index
~~~~~~~~~~~~~~~

なぜインデックスが重要なのでしょうか？

インデックスを使用すると、すべての行をすべてのクエリで検査することなくデータベースにクエリできるため、クエリの実行速度と効率が向上します。通常、インデックスは頻繁に発生するクエリ基準に対して構築されるため、データをより効率的にクエリできます。CouchDBの主な利点であるJSONデータに対して豊富なクエリを実行できる機能を利用するには、インデックスは必要ありませんが、パフォーマンスを向上させるためにインデックスを使用することを強くお薦めします。また、クエリでソートが必要な場合、CouchDBにはソートされたフィールドのインデックスが必要です。

.. note::

   インデックスを持たないリッチクエリは機能しますが、CouchDBログにインデックスが見つからなかったことを警告する可能性があります。ただし、リッチクエリにソート指定が含まれている場合は、そのフィールドのインデックスが必要です。そうでない場合、クエリは失敗し、エラーがスローされます。
  
インデックスの作成を示すために、 `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/%7BBRANCH%7D/chaincode/marbles02/go/marbles_chaincode.go>`__ のデータを使用します。この例では、Marblesデータ構造は次のように定義されています:

.. code:: javascript

  type marble struct {
	   ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	   Name       string `json:"name"`    //the field tags are needed to keep case from bouncing around
	   Color      string `json:"color"`
           Size       int    `json:"size"`
           Owner      string `json:"owner"`
  }


この構造では、属性( ``docType`` 、 ``name`` 、 ``color`` 、 ``size`` 、 ``owner`` )によって、資産に関連付けられた台帳データが定義されます。 ``docType`` 属性はチェーンコードで使用されるパターンで、個別にクエリする必要がある様々なデータ型を区別するために使用されます。CouchDBを使用する場合は、この ``docType`` 属性をチェーンコードネームスペース内の各タイプの文書を区別するために含めることをお薦めします(各チェーンコードは独自のCouchDBデータベースとして表されます。つまり、各チェーンコードには独自のキー用ネームスペースがあります)。

Marblesデータ構造に関して、 ``docType`` は、このドキュメント/アセットがMarblesアセットであることを識別するために使用されます。チェーンコードデータベースに他のドキュメント/アセットが存在する可能性があります。データベース内のドキュメントは、これらすべての属性値に対して検索可能です。

チェーンコードクエリで使用するインデックスを定義する場合は、それぞれのインデックスを `*.json` という拡張子を持つ独自のテキストファイルで定義し、インデックス定義をCouchDBインデックスJSONフォーマットでフォーマットする必要があります。

インデックスを定義するには、次の3つの情報が必要です:

  * `fields`: 頻繁にクエリされるフィールド
  * `name`: インデックスの名前
  * `type`: このコンテキストでは常にjson

たとえば、 ``foo`` という名前のフィールドの ``foo-index`` という名前の単純なインデックスです。

.. code:: json

    {
        "index": {
            "fields": ["foo"]
        },
        "name" : "foo-index",
        "type" : "json"
    }

オプションで、設計ドキュメント属性 ``ddoc`` をインデックス定義で指定できます。 `設計ドキュメント <http://guide.couchdb.org/draft/design.html>`__ は、インデックスを含むように設計されたCouchDB構造です。インデックスは、効率化のために設計ドキュメントにグループ化できますが、CouchDBは設計ドキュメントごとに1つのインデックスを推奨しています。

.. tip:: インデックスを定義する場合は、インデックス名とともに ``ddoc`` 属性および値を含めることをお薦めします。必要に応じて後でインデックスを更新できるように、この属性を含めることが重要です。また、クエリで使用するインデックスを明示的に指定できます。


複数のフィールド ``docType`` と ``owner`` を使用し、 ``ddoc`` 属性を含むインデックス名 ``indexOwner`` を持つMarblesサンプルのインデックス定義の別の例を次に示します:

.. _indexExample:

.. code:: json

  {
    "index":{
        "fields":["docType","owner"] // Names of the fields to be queried
    },
    "ddoc":"indexOwnerDoc", // (optional) Name of the design document in which the index will be created.
    "name":"indexOwner",
    "type":"json"
  }

前述の例では、設計ドキュメント ``indexOwnerDoc`` が存在しない場合、インデックスが配布されるときに自動的に作成されます。インデックスは、フィールドのリストに指定された1つ以上の属性を使用して構成でき、属性の任意の組合せを指定できます。1つの属性は、同じdocTypeの複数のインデックスに存在できます。次の例では、 ``index1`` には属性 ``owner`` のみが含まれ、 ``index2`` には属性 ``ownerおよびcolor`` が含まれ、 ``index3`` には属性 ``ownerとcolorおよびsize`` が含まれます。また、CouchDBの推奨プラクティスに従って、各インデックス定義に独自の ``ddoc`` 値があることに注意してください。

.. code:: json

  {
    "index":{
        "fields":["owner"] // Names of the fields to be queried
    },
    "ddoc":"index1Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index1",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner", "color"] // Names of the fields to be queried
    },
    "ddoc":"index2Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index2",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner", "color", "size"] // Names of the fields to be queried
    },
    "ddoc":"index3Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index3",
    "type":"json"
  }


一般に、クエリのフィルタや並べ替えに使用されるフィールドと一致するように、インデックスフィールドをモデル化する必要があります。JSONフォーマットでのインデックス作成の詳細については、 `CouchDBのドキュメント <http://docs.couchdb.org/en/latest/api/database/find.html#db-index>`__ を参照してください。

インデックスに関する最後のポイントとして、Fabricはデータベース内のドキュメントのインデックス付けを ``インデックスウォーミング`` と呼ばれるパターンを使用して行います。CouchDBは通常、次のクエリまで新しいドキュメントや更新されたドキュメントのインデックス付けを行いません。Fabricは、データブロックがコミットされるたびにインデックスの更新を要求することで、インデックスが 'ウォーム' のままであることを保証します。これにより、クエリを実行する前にドキュメントのインデックス付けが不要になるため、クエリが高速になります。このプロセスは、インデックスを最新の状態に保ち、ステートデータベースに新しいレコードが追加されるたびにリフレッシュされます。

.. _cdb-add-index:


Add the index to your chaincode folder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

インデックスを完成させたら、適切なメタデータフォルダに配置して、配布用のチェーンコードとともにパッケージ化する必要があります。このチェーンコードは、 :doc:`commands/peerlifecycle` コマンドを使用してインストールできます。JSONインデックスファイルは、チェーンコードが存在するディレクトリ内のパス ``META-INF/statedb/couchdb/indexes`` の下に配置する必要があります。

下の `Marblesのサンプル <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/chaincode/marbles02/go>`__ は、インデックスがチェーンコードと一緒にパッケージ化されている様子を示しています。

.. image:: images/couchdb_tutorial_pkg_example.png
  :scale: 100%
  :align: center
  :alt: Marbles Chaincode Index Package

このサンプルには、indexOwnerDocという名前のインデックスが1つ含まれています:

.. code:: json

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}


Start the network
-----------------

:guilabel:`Try it yourself`


Fabricテストネットワークを起動して、Marblesチェーンコードを展開します。次のコマンドを使用して、Fabricサンプル内の `test-network` ディレクトリに移動します:

.. code:: bash

    cd fabric-samples/test-network

このチュートリアルでは、既知の初期状態から操作します。次のコマンドは、アクティブまたは古いDockerコンテナを削除し、以前に生成されたアーティファクトを削除します:

.. code:: bash

    ./network.sh down

チュートリアルをまだ実行していない場合は、ネットワークに展開する前に、チェーンコードの依存関係をベンダーに提供する必要があります。次のコマンドを実行します:

.. code:: bash

    cd ../chaincode/marbles02/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network

`test-network` ディレクトリから、次のコマンドを使用して、CouchDBを使用するテストネットワークをデプロイします:

.. code:: bash

    ./network.sh up createChannel -s couchdb

これにより、ステートデータベースとしてCouchDBを使用する2つのFabricピアノードが作成されます。また、1つのオーダリングノードと ``mychannel`` という名前の1つのチャネルも作成されます。

.. _cdb-install-deploy:

Install and define the Chaincode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

クライアントアプリケーションは、チェーンコードを介してブロックチェーン台帳と対話します。したがって、トランザクションを実行してエンドースするすべてのピアにチェーンコードをインストールする必要があります。ただし、チェーンコードと対話する前に、チャネルのメンバーは、チェーンコードガバナンスを確立するチェーンコード定義に同意する必要があります。chaincodeフォルダにインデックスを追加し、インデックスがチェーンコードとともに展開されるようにする方法については、前のセクションで説明しました。

チェーンコードは、ピアにインストールする前にパッケージ化する必要があります。 `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ コマンドを使用してmarblesチェーンコードをパッケージ化できます。

:guilabel:`Try it yourself`

1. テストネットワークの開始後、次の環境変数をCLIにコピー&ペーストして、Org1管理者としてネットワークと対話します。この際、 `test-network` ディレクトリにいることを確認してください。

.. code:: bash

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=${PWD}/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

2. marblesプライベートデータチェーンコードをパッケージ化するには、次のコマンドを使用します:

.. code:: bash

    peer lifecycle chaincode package marbles.tar.gz --path ../chaincode/marbles02/go --lang golang --label marbles_1

このコマンドは、marbles.tar.gzという名前のチェーンコードパッケージを作成します。

3. 次のコマンドを使用して、チェーンコードパッケージをピア ``peer0.org1.example.com`` にインストールします:

.. code:: bash

    peer lifecycle chaincode install marbles.tar.gz

インストールに成功すると、次のようなチェーンコード識別子が返されます:

.. code:: bash

    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJmarbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3\022\tmarbles_1" >
    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3

``peer0.Org1.example.com`` にチェーンコードをインストールした後、Org1のチェーンコード定義を承認する必要があります。

4. 次のコマンドを使用して、インストールされているチェーンコードのパッケージIDをピアに照会します。

.. code:: bash

    peer lifecycle chaincode queryinstalled

このコマンドは、installコマンド実行時と同じパッケージ識別子を返します。次のような出力が表示されます:

.. code:: bash

    Installed chaincodes on peer:
    Package ID: marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787, Label: marbles_1

5. パッケージIDを環境変数として宣言します。 ``peer lifecycle chaincode queryinstalled`` コマンドによって返されたmarbles_1のパッケージIDを次のコマンドに貼り付けます。パッケージIDはすべてのユーザーで同じではない可能性があるため、コンソールから返されたパッケージIDを使用してこの手順を完了する必要があります。

.. code:: bash

    export CC_PACKAGE_ID=marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787

6.次のコマンドを使用して、Org1のmarblesプライベートデータチェーンコードの定義を承認します。

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

コマンドが正常に完了すると、次のようなメッセージが表示されます:

.. code:: bash

    2020-01-07 16:24:20.886 EST [chaincodeCmd] ClientWait -> INFO 001 txid [560cb830efa1272c85d2f41a473483a25f3b12715d55e22a69d55abc46581415] committed with status (VALID) at

チャネルにコミットする前に、過半数の組織がチェーンコード定義を承認する必要があります。これは、Org2もチェーンコード定義を承認する必要があることを意味します。Org2がチェーンコードをエンドースする必要はなく、Org2ピアにパッケージをインストールしていないので、チェーンコード定義の一部としてパッケージIDを提供する必要はありません。

7. CLIを使用してOrg2管理者として操作します。次のコマンドブロックをグループとしてピアコンテナにコピー&ペーストし、一度に実行します。

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

8. 次のコマンドを使用して、Org2のチェーンコード定義を承認します:

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --sequence 1 --tls --cafile $ORDERER_CA

9. `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ コマンドを使用して、チャネルにチェーンコード定義をコミットできるようになりました:

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --sequence 1 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

コミットトランザクションが正常に完了すると、次のようなメッセージが表示されます:

.. code:: bash

    2019-04-22 18:57:34.274 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org2.example.com:9051
    2019-04-22 18:57:34.709 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org1.example.com:7051

10. marblesチェーンコードには初期化関数が含まれているため、チェーンコード内の他の関数を使用する前に、 `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-invoke>`__ コマンドを使用して ``Init()`` を起動する必要があります:

.. code:: bash

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --isInit --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA -c '{"Args":["Init"]}'

Verify index was deployed
-------------------------

チェーンコードがピアにインストールされ、チャネルに展開されると、インデックスは、各ピアのCouchDBステートデータベースに展開されます。CouchDBインデックスが正常に作成されたことは、Dockerコンテナのピアログを調べることで確認できます。

:guilabel:`Try it yourself`

ピアDockerコンテナのログを表示するには、新しいターミナルウィンドウを開き、次のコマンドを実行してgrepを実行し、インデックスが作成されたことを確認します。

::

   docker logs peer0.org1.example.com  2>&1 | grep "CouchDB index"


次のような結果が表示されます:

::

   [couchdb] CreateIndex -> INFO 0be Created CouchDB index [indexOwner] in state database [mychannel_marbles] using design document [_design/indexOwnerDoc]

.. note:: ``peer0.org1.example.com`` 以外のピアにMarblesをインストールした場合は、Marblesをインストールした別のピアの名前に置き換える必要があります。

.. _cdb-query:

Query the CouchDB State Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

インデックスがJSONファイルで定義され、チェーンコードとともにデプロイされたので、チェーンコード関数はCouchDBステートデータベースに対してJSONクエリを実行することができ、それによってピアコマンドがチェーンコード関数を呼び出すことができます。

クエリでインデックス名を指定するかどうかはオプションです。指定しない場合、クエリ対象のフィールドに既にインデックスが存在すると、既存のインデックスが自動的に使用されます。

.. tip:: ``use_index`` キーワードを使用して、明示的にインデックス名をクエリに含めることをお勧めします。これがないと、CouchDBはあまり最適でないインデックスを選択する可能性があります。また、CouchDBはまったくインデックスを使用しない可能性があり、テスト中の低ボリュームではそれに気付かない可能性があります。CouchDBはインデックスを使用していないので、高ボリュームでのみパフォーマンスが低下する可能性があります。


Build the query in chaincode
----------------------------

連結コード内で定義されたクエリを使用して、台帳のデータに対して複雑なリッチクエリを実行できます。 `marbles02のサンプル <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__ には、2つのリッチクエリ関数が含まれています:

  * **queryMarbles** --

      **アドホックなリッチクエリ** の例です。これは、関数に(セレクタ)文字列を渡すことができるクエリです。このクエリは、実行時に独自のセレクタを動的に構築する必要があるクライアントアプリケーションに役立ちます。セレクタの詳細は、 `CouchDBセレクタ構文 <http://docs.couchdb.org/en/latest/api/database/find.html#find-selectors>`__ を参照してください。


  * **queryMarblesByOwner** --

      **パラメータ化されたクエリ** の例です。クエリロジックがチェーンコードに焼き付けられています。この例では、関数はmarbleの所有者という単一の引数を受け入れます。次に、JSONクエリ構文を使用して、 “marble” のdocTypeと所有者IDに一致するJSONドキュメントをステートデータベースにクエリします。


Run the query using the peer command
------------------------------------

クライアントアプリケーションが存在しない場合は、peerコマンドを使用してで定義されたクエリをテストできます。 `peer chaincode query <commands/peerchaincode.html?%20chaincode%20query#peer-chaincode-query>`__ コマンドをカスタマイズして、Marblesのインデックス ``indexOwner`` を使用し、 ``queryMarbles`` 関数を使用して "tom" が所有するすべてのmarblesをクエリするようにします。

:guilabel:`Try it yourself`

データベースを照会する前に、いくつかのデータを追加する必要があります。次のコマンドをOrg1として実行し、 "tom" が所有するmarblesを作成します:

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble1","blue","35","tom"]}'

チェーンコードの初期化時にインデックスが配布されると、そのインデックスはチェーンコードクエリで自動的に使用されます。CouchDBでは、クエリ対象のフィールドに基づいて使用するインデックスを決定できます。クエリ基準にインデックスが存在する場合は、そのインデックスが使用されます。ただし、クエリに ``use_index`` キーワードを指定することをお薦めします。次のpeerコマンドは、 ``use_index`` キーワードを含めることにより、セレクタ構文で明示的にインデックスを指定する方法の例です:

.. code:: bash

   // Rich Query with index name explicitly specified:
   peer chaincode query -C mychannel -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}"]}'

上記のqueryコマンドには、3つの興味深い引数があります:

*  ``queryMarbles``

  Marblesチェーンコード内の関数の名前。 `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__ ``shim.ChaincodeStubInterface`` は、台帳へのアクセスおよび変更に使用されます。 ``getQueryResultForQueryString()`` はqueryStringをshim API ``getQueryResult()`` に渡します。

.. code:: bash

  func (t *SimpleChaincode) queryMarbles(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	  //   0
	  // "queryString"
	   if len(args) < 1 {
		   return shim.Error("Incorrect number of arguments. Expecting 1")
	   }

	   queryString := args[0]

	   queryResults, err := getQueryResultForQueryString(stub, queryString)
	   if err != nil {
		 return shim.Error(err.Error())
	   }
	   return shim.Success(queryResults)
  }

*  ``{"selector":{"docType":"marble","owner":"tom"}``

  これは、 ``owner`` 属性の値が ``tom`` である ``marble`` タイプのすべてのドキュメントを検索する **アドホックセレクタ** 文字列の例です。


*  ``"use_index":["_design/indexOwnerDoc", "indexOwner"]``

  設計ドキュメント名 ``indexOwnerDoc`` とインデックス名 ``indexOwner`` の両方を指定します。この例では、セレクタクエリに ``use_index`` キーワードを使用して指定したインデックス名が明示的に含まれています。上のインデックス定義 :ref:`cdb-create-index` を思い出してください。これには設計ドキュメント ``"ddoc":"indexOwnerDoc"`` が含まれています。CouchDBでは、クエリにインデックス名を明示的に含める場合、インデックス定義に ``ddoc`` 値を含める必要があるため、 ``use_index`` キーワードを使用して参照できます。:ref:


クエリは正常に実行され、インデックスは次の結果で利用されます:

.. code:: json

  Query Result: [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}}]

.. _cdb-best:

Use best practices for queries and indexes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

インデックスを使用するクエリは、CouchDBでデータベース全体をスキャンすることなく、より高速に処理できます。インデックスを理解することで、クエリを作成してパフォーマンスを向上させることができ、アプリケーションがネットワーク上の大量のデータやブロックを処理できるようになります。

また、チェーンコードとともにインストールするインデックスを計画することも重要です。ほとんどのクエリをサポートするチェーンコードごとに、少数のインデックスのみをインストールする必要があります。追加するインデックスが多すぎるか、インデックス内のフィールドの数が多すぎると、ネットワークのパフォーマンスが低下します。これは、各ブロックがコミットされた後にインデックスが更新されるためです。 "インデックスウォーミング" によって更新するインデックスの数が多いほど、トランザクションの完了にかかる時間が長くなります。


この項の例は、クエリでインデックスがどのように使用されるか、およびどのタイプのクエリが最高のパフォーマンスを発揮するかを示すのに役立ちます。クエリを作成する場合は、次の点に注意してください:

* インデックス内のすべてのフィールドは、インデックスを使用するクエリのセレクタセクションまたは並べ替えセクションにも含まれている必要があります。
* 複雑なクエリではパフォーマンスが低下し、インデックスを使用する可能性が低くなります。
* ``$or`` 、 ``$in`` 、 ``$regex`` など、テーブル全体のスキャンやインデックス全体のスキャンを実行する演算子は避けてください。


このチュートリアルの前のセクションでは、marblesチェーンコードに対して次のクエリを実行しました:

.. code:: bash

  // Example one: query fully supported by the index
  export CHANNEL_NAME=mychannel
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

marblesのチェーンコードは、 ``indexOwnerDoc`` インデックスとともにインストールされました:

.. code:: json

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

``docType`` と ``owner`` の両方のフィールドがインデックスに含まれているため、完全にサポートされたクエリになります。その結果、このクエリは、データベース全体を検索することなく、インデックス内のデータを使用できるようになります。このような完全にサポートされたクエリは、チェーンコードからの他のクエリよりも高速に返されます。

上記のクエリにフィールドを追加しても、インデックスが使用されます。ただし、クエリでは追加したフィールド向けにインデックス付きデータをスキャンする必要があるため、応答時間が長くなります。たとえば、以下のクエリではインデックスが使用されますが、前の例よりも返されるまでの時間が長くなります。

.. code:: bash

  // Example two: query fully supported by the index with additional data
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\",\"color\":\"red\"}, \"use_index\":[\"/indexOwnerDoc\", \"indexOwner\"]}"]}'

インデックス内のすべてのフィールドが含まれていないクエリは、代わりにデータベース全体をスキャンする必要があります。たとえば、次のクエリは、所有されるアイテムの種類を指定せずに所有者を検索します。indexOwnerDocには ``owner`` フィールドと ``docType`` フィールドの両方が含まれているため、このクエリはインデックスを使用できません。

.. code:: bash

  // Example three: query not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

一般に、複雑なクエリほどレスポンス時間が長くなり、インデックスでサポートされる可能性が低くなります。 ``$or`` 、 ``$in`` および ``$regex`` などの演算子を使用すると、多くの場合、クエリでインデックス全体がスキャンされるか、インデックスがまったく使用されません。

たとえば、以下のクエリには、すべてのmarbleとtomが所有するすべてのアイテムを検索する ``$or`` という語が含まれています。

.. code:: bash

  // Example four: query with $or supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"$or\":[{\"docType\":\"marble\"},{\"owner\":\"tom\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

このクエリは、 ``indexOwnerDoc`` に含まれるフィールドを検索するため、インデックスを使用します。ただし、クエリの ``$or`` 条件では、インデックス内のすべてのアイテムをスキャンする必要があるため、応答時間が長くなります。

次に、インデックスでサポートされていない複雑なクエリの例を示します。

.. code:: bash

  // Example five: Query with $or not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"$or\":[{\"docType\":\"marble\",\"owner\":\"tom\"},{\"color\":\"yellow\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

このクエリでは、tomが所有するすべてのmarblesまたはその他の黄色のアイテムが検索されます。 ``$or`` 条件を満たすにはテーブル全体を検索する必要があるため、このクエリではインデックスは使用されません。台帳のデータ量によっては、このクエリの応答に時間がかかる場合やタイムアウトになる場合があります。

クエリのベストプラクティスに従うことは重要ですが、インデックスを使用することは大量のデータを収集するためのソリューションではありません。ブロックチェーンのデータ構造は、トランザクションを検証および確認するために最適化されており、データ分析やレポート作成には適していません。アプリケーションの一部としてダッシュボードを構築したり、ネットワークのデータを分析したりする場合は、ピアのデータを複製するオフチェーンデータベースにクエリを実行することをお勧めします。これにより、ネットワークのパフォーマンスを低下させたり、トランザクションを中断させたりすることなく、ブロックチェーン上のデータを理解することができます。

アプリケーションのブロックイベントまたはチェーンコードイベントを使用して、オフチェーンデータベースまたは分析エンジンにトランザクションデータを書き込むことができます。受信された各ブロックに対して、ブロックリスナーアプリケーションはブロックトランザクションを繰り返し処理し、各有効なトランザクションの ``rwset`` からのキー/値の書込みを使用してデータストアを構築します。 :doc:`peer_event_services` は、ダウンストリームデータストアの整合性を確保するために、再生可能なイベントを提供します。イベントリスナーを使用して外部データベースにデータを書き込む方法の例は、Fabric
Samplesの `オフチェーンデータサンプル <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/off_chain_data>`__ を参照してください。

.. _cdb-pagination:

Query the CouchDB State Database With Pagination
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CouchDBクエリによって大量の結果セットが返される場合、結果のリストをページ付けするためにチェーンコードによって呼び出すことができるAPIのセットが使用可能です。ページ付けは、 ``pagesize`` と ``bookmark`` (結果セット内の開始位置を示すブックマーク)を指定することによって結果セットを分割するメカニズムを提供します。クライアントアプリケーションは、結果が返されなくなるまで、クエリを実行するチェーンコードを繰り返し呼び出します。詳細は、 `CouchDBによるページ付けに関するこのトピック <couchdb_as_state_database.html#couchdb-pagination>`__ を参照してください。


`Marblesのサンプル <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__ 関数 ``queryMarblesWithPagination`` を使って、ページ付けをチェーンコードとクライアントアプリケーションに実装する方法を説明します。

* **queryMarblesWithPagination** --

    **ページ区切りを使用したアドホックリッチクエリ** の例です。これは、前述の例と同様に(セレクタ)文字列を関数に渡すことができるクエリです。この場合、 ``pagesize`` も ``bookmark`` と同様にクエリに含まれます。

ページ付けを説明するには、さらにデータが必要です。この例では、上記のmarble1がすでに追加されていることを前提としています。ピアコンテナで次のコマンドを実行して、 "tom" が所有するmarblesをさらに4つ作成し、 "tom" が所有するmarblesを合計5つ作成します:

:guilabel:`Try it yourself`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble2","yellow","35","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble3","green","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble4","purple","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble5","blue","40","tom"]}'

前の例のクエリの引数に加えて、queryMarblesWithPaginationは ``pagesize`` と ``bookmark`` を追加します。 ``pagesize`` は、クエリごとに戻されるレコード数を指定します。 ``bookmark`` は、ページの開始位置をcouchDBに指示する "アンカー" です(結果の各ページは一意のブックマークを戻します)。

*  ``queryMarblesWithPagination``

  Marblesチェーンコード内の関数の名前。 `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__ ``shim.ChaincodeStubInterface`` は、台帳へのアクセスおよび変更に使用されます。 ``getQueryResultForQueryStringWithPagination()`` は、queryStringをページサイズおよびブックマークとともにshim API ``GetQueryResultWithPagination()`` に渡します。

.. code:: bash

  func (t *SimpleChaincode) queryMarblesWithPagination(stub shim.ChaincodeStubInterface, args []string) pb.Response {

  	//   0
  	// "queryString"
  	if len(args) < 3 {
  		return shim.Error("Incorrect number of arguments. Expecting 3")
  	}

  	queryString := args[0]
  	//return type of ParseInt is int64
  	pageSize, err := strconv.ParseInt(args[1], 10, 32)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	bookmark := args[2]

  	queryResults, err := getQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	return shim.Success(queryResults)
  }


次の例は、ページサイズが ``3`` でブックマークが指定されていないqueryMarblesWithPaginationを呼び出すpeerコマンドです。

.. tip:: ブックマークが指定されていない場合、クエリはレコードの "最初の" ページから始まります。

:guilabel:`Try it yourself`

.. code:: bash

  // Rich Query with index name explicitly specified and a page size of 3:
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3",""]}'

次の応答が受信されます(わかりやすくするために改行が追加されています)。 ``pagesize`` が ``3`` に設定されているため、5つのmarblesのうち3つが返されます:

.. code:: bash

  [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}},
   {"Key":"marble2", "Record":{"color":"yellow","docType":"marble","name":"marble2","owner":"tom","size":35}},
   {"Key":"marble3", "Record":{"color":"green","docType":"marble","name":"marble3","owner":"tom","size":20}}]
  [{"ResponseMetadata":{"RecordsCount":"3",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"}}]

.. note::  ブックマークはクエリごとにCouchDBによって一意に生成され、結果セット内のプレースホルダを表します。返されたブックマークを後に続く繰り返しのクエリに渡して、次の結果セットを取得します。


次に、ページサイズが ``3`` のqueryMarblesWithPaginationを呼び出すためのpeerコマンドを示します。今回のクエリには、前のクエリから返されたブックマークが含まれています。

:guilabel:`Try it yourself`

.. code:: bash

  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"]}'

次の応答が受信されます(わかりやすくするために改行が追加されています)。最後の2つのレコードが取得されます:

.. code:: bash

  [{"Key":"marble4", "Record":{"color":"purple","docType":"marble","name":"marble4","owner":"tom","size":20}},
   {"Key":"marble5", "Record":{"color":"blue","docType":"marble","name":"marble5","owner":"tom","size":40}}]
  [{"ResponseMetadata":{"RecordsCount":"2",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

最後のコマンドは、ページサイズが ``3`` で、前のクエリのブックマークを持つqueryMarblesWithPaginationを呼び出すピアコマンドです。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"]}'

次の応答が受信されます(わかりやすくするために改行が追加されています)。何もレコードは返されませんでした。すなわち全てのページが取得されたことを示します:

.. code:: bash

    []
    [{"ResponseMetadata":{"RecordsCount":"0",
    "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

クライアントアプリケーションがページ付けを使用して結果セットを繰り返し処理する例として、 `Marblesサンプル <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__ の ``getQueryResultForQueryStringWithPagination`` 関数を検索してください。

.. _cdb-update-index:

Update an Index
~~~~~~~~~~~~~~~

インデックスは、時間の経過とともに更新する必要がある場合があります。インストールされるチェーンコードの後続バージョンに同じインデックスが存在する場合があります。インデックスを更新するには、元のインデックス定義に設計ドキュメントの ``ddoc`` 属性とインデックス名が含まれている必要があります。インデックス定義を更新するには、同じインデックス名を使用し、インデックス定義を変更します。インデックスJSONファイルを編集し、インデックスからフィールドを追加または削除するだけです。FabricではインデックスタイプJSONのみがサポートされています。インデックスタイプの変更はサポートされていません。チェーンコード定義がチャネルにコミットされると、更新されたインデックス定義がピアのステートデータベースに再配布されます。インデックス名または ``ddoc`` 属性を変更すると、新しいインデックスが作成され、元のインデックスは削除されるまでCouchDBで変更されません。

.. note:: ステートデータベースに大量のデータがある場合は、インデックスが再構築されるまでに時間がかかります。その時間の間に、チェーンコードが呼び出しを行うと、問い合わせが失敗したりタイムアウトしたりする可能性があります。

Iterating on your index definition
----------------------------------

開発環境でピアのCouchDBステートデータベースにアクセスできる場合は、チェーンコードクエリをサポートするさまざまなインデックスを反復的にテストできます。ただし、チェーンコードを変更する場合は、再デプロイが必要になります。インデックスを作成および更新するには、 `CouchDB Fauxtonインターフェース <http://docs.couchdb.org/en/latest/fauxton/index.html>`__ またはコマンドラインユーティリティーを使用してください。

.. note:: Fauxtonインターフェースは、CouchDBに対してインデックスを作成、更新、およびデプロイするためのWeb UIです。このインターフェースを試してみると、MarblesサンプルのインデックスのFauxtonバージョンのフォーマットの例があります。CouchDBを使用してテストネットワークをデプロイした場合は、ブラウザーを開いて ``http://localhost:5984/_utils`` に移動することにより、Fauxtonインターフェースをロードすることができます。

また、Fauxton UIを使用しない場合は、次のcurlコマンドを使用してデータベース ``mychannel_marbles`` にインデックスを作成できます:

.. code:: bash

  // Index for docType, owner.
  // Example curl command line to define index in the CouchDB channel_chaincode database
   curl -i -X POST -H "Content-Type: application/json" -d
          "{\"index\":{\"fields\":[\"docType\",\"owner\"]},
            \"name\":\"indexOwner\",
            \"ddoc\":\"indexOwnerDoc\",
            \"type\":\"json\"}" http://hostname:port/mychannel_marbles/_index

.. note:: CouchDBで構成されたテストネットワークを使用している場合は、hostname:portを ``localhost:5984`` に置き換えてください。

.. _cdb-delete-index:

Delete an Index
~~~~~~~~~~~~~~~

インデックスの削除はFabricツールで管理されません。インデックスを削除する必要がある場合は、データベースに対してcurlコマンドを手動で発行するか、Fauxtonインタフェースを使用して削除してください。

インデックスを削除するcurlコマンドの形式は次のようになります:

.. code:: bash

   curl -X DELETE http://localhost:5984/{database_name}/_index/{design_doc}/json/{index_name} -H  "accept: */*" -H  "Host: localhost:5984"


このチュートリアルで使用するインデックスを削除するには、curlコマンドを次のようにします:

.. code:: bash

   curl -X DELETE http://localhost:5984/mychannel_marbles/_index/indexOwnerDoc/json/indexOwner -H  "accept: */*" -H  "Host: localhost:5984"



.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
