CouchDB as the State Database
=============================

State Database options
----------------------

現時点でピアのステートデータベースのオプションは、LevelDBとCouchDBです。
LevelDBはピアのプロセスに組み込まれたデフォルトのキーバリューストアデータベースです。
CouchDBは代替の外部ステートデータベースです。
LevelDBのキーバリューストアと同様に、CouchDBはチェーンコードでモデル化された任意のバイナリデータを保存できます (JSON以外のデータに対しては、CouchDBのアタッチメントが内部的に使用されます)。
ドキュメントオブジェクトストアとして、CouchDBを使用すると、データをJSON形式で保存し、データに対してJSONクエリを発行し、クエリにインデックスを使用できます。

LevelDBとCouchDBはどちらも、キー(アセット)の取得と更新、および、キーに基づくクエリなどのコアチェーンコードの操作をサポートしています。
キーは範囲でクエリでき、複合キーをモデル化すると、複数のパラメータに対して等価なクエリを実行できます。
たとえば、 ``owner,asset_id`` という複合キーを使用して、特定のエンティティが所有するすべてのアセットをクエリできます。
これらのキーに基づくクエリは、台帳に対する読み込み専用クエリだけでなく、台帳を更新するトランザクションにも使用できます。

JSONでデータをモデル化すると、キーをクエリするだけでなく、データの値に対してJSONクエリを発行できます。
これにより、アプリケーションとチェーンコードがブロックチェーン台帳に保存されているデータを簡単に読み取ることができます。
CouchDBを使用すると、LevelDBではサポートされていない多くのユースケースに関わる監査とレポーティングの要件を満たすことができます。
CouchDBを使用してデータをJSONでモデル化する場合、チェーンコードでインデックスをデプロイすることもできます。
インデックスを使用すると、クエリがより柔軟かつ効率的になり、チェーンコードから大規模なデータセットをクエリできるようになります。

CouchDBは、ピアと並行する独立したデータベースプロセスとして実行されるため、設定、管理、および、運用に関して追加の検討事項があります。
アセットデータをJSONとしてモデル化することをお勧めします。これにより、将来必要になった場合に複雑なJSONクエリを実行できるようになります。

.. note:: CouchDBのJSONドキュメントのキーには、有効なUTF-8文字列のみを含めることができ、アンダースコア ("_") で始めることはできません。
   CouchDBとLevelDBのどちらを使用している場合でも、キーにU+0000 (nilバイト) を使用しないでください。

   CouchDBのJSONドキュメントは、最上位のフィールド名として次の値を使用できません。
   これらの値は、内部使用のために予約されています。

   - ``アンダースコア "_" で始まる任意のフィールド``
   - ``~version``

   LevelDBとCouchDBの間には、データの非互換性があるため、
   本番環境のピアをデプロイする前に、データベースの選択を確定する必要があります。
   データベースを後で変換することはできません。

Using CouchDB from Chaincode
----------------------------

Reading and writing JSON data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

JSONデータの値をCouchDBに書き込み (例: ``PutState`` を使用)、その後のチェーンコードリクエストでJSONを読み込む (例: ``GetState`` を使用) 場合、
JSONの仕様により、JSONの形式とJSONフィールドの順序は保証されません。
したがって、データを操作する前にチェーンコードでJSONをアンマーシャリングする必要があります。
同様に、JSONをマーシャリングするときは、決定論的な結果を保証するライブラリを利用して、
提案されたチェーンコードの書き込みとクライアントへの応答がエンドーシングピア間で同じになるようにします
(Goの ``json.Marshal()`` は決定論的にキーをソートしますが、 他の言語では、正規のJSONライブラリが必要になる場合があります)。

Chaincode queries
~~~~~~~~~~~~~~~~~

ほとんどの `chaincode shim APIs <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__
は、LevelDBとCouchDBのどちらのステートデータベースでも利用できます。
例えば、 ``GetState`` 、 ``PutState`` 、 ``GetStateByRange`` 、 ``GetStateByPartialCompositeKey`` 。
さらに、ステートデータベースとしてCouchDBを利用し、かつ、チェーンコードでアセットをJSONとしてモデル化すると、
``GetQueryResult`` APIを利用してCouchDBのクエリ文字列を渡すと、ステートデータベース内のデータに対してJSONクエリを実行できます。
クエリ文字列は、 `CouchDB JSON query syntax <http://docs.couchdb.org/en/2.1.1/api/database/find.html>`__ に従います。

`asset transfer Fabric sample <https://github.com/hyperledger/fabric-samples/blob/master/asset-transfer-ledger-queries/chaincode-go/asset_transfer_ledger_chaincode.go>`__
は、チェーンコードからCouchDBクエリを利用する方法を説明します。
これには、所有者IDをチェーンコードに渡すことによってクエリをパラメータ化した ``queryAssetsByOwner()`` 関数が含まれています。
JSONクエリ構文を使用して、"asset"のdocTypeと所有者IDが一致するJSONドキュメントのステートデータをクエリします。

.. code:: bash

  {"selector":{"docType":"asset","owner":<OWNER_ID>}}

JSONクエリへの応答は、台帳のデータを理解するのに役立ちます。
ただし、JSONクエリの結果セットがチェーンコードの実行時とコミット時の間で変わらないという保証はありません。
そのため、1つのトランザクションの中で、JSONクエリを使用して、チャネル台帳を更新することは避けてください。
例えば、Aliceが所有するすべてのアセットに対してJSONクエリを実行し、それらをBobに移転すると、
チェーンコードの実行とコミットの間に、別のトランザクションによって新しいアセットがAliceに割り当てられる可能性があります。


.. couchdb-pagination:

CouchDB pagination
^^^^^^^^^^^^^^^^^^

Fabricは、JSONクエリとキー範囲クエリのクエリ結果に対して、ページネーションをサポートしています。
ページネーションをサポートするAPIを使用すると、キー範囲とJSONクエリの両方でページサイズとブックマークを使用できます。
効率的なページネーションをサポートするには、FabricのページネーションAPIを使用する必要があります。
具体的には、CouchDBの ``limit`` キーワードはCouchDBクエリでは利用できません。
その理由は、Fabric自体がクエリ結果のページネーションを管理し、CouchDBに渡すpageSizeの上限を暗黙的に設定するためです。

ページネーションクエリAPI (``GetStateByRangeWithPagination()`` 、
``GetStateByPartialCompositeKeyWithPagination()`` および ``GetQueryResultWithPagination()``)
でpageSizeが指定されている場合、
(pageSizeで区切られた) 結果セットがブックマークと一緒にチェーンコードに返されます。
チェーンコードから呼び出し元のクライアントにブックマークを返すことができます。
呼び出し元のクライアントは、後続のクエリでブックマークを使用して、結果の次の"ページ"を受け取ることができます。

ページネーションAPIは、読み込み専用トランザクションのみで使用されます。
クエリ結果は、クライアントのページネーション要件をサポートすることを目的としています。
読み書きが必要なトランザクションの場合、ページネーションの無いチェーンコードクエリAPIを使用します。
チェーンコード内で、結果セットを目的の深さまで反復処理できます。

ページネーションAPIが使用されているかどうかに関係なく、
すべてのチェーンコードクエリは ``core.yaml`` の ``totalQueryLimit`` (デフォルトは100000) で頭打ちになります。
これは、偶発的または悪意のある長時間実行クエリを回避するために、チェーンコードが反復処理を行いクライアントに返す結果の最大数です。

.. note:: チェーンコードがページネーションクエリを使用するかどうかに関わらず、
          ピアは ``core.yaml`` の ``internalQueryLimit`` (デフォルトは1000) に基づいてバッチで CouchDBをクエリします。
          この動作により、チェーンコードの実行時に妥当なサイズの結果セットがピアとCouchDBの間で渡され、
          チェーンコードと呼び出し元のクライアントに対して透過的になります。

ページネーションを利用した例は、 :doc:`couchdb_tutorial` チュートリアルに含まれています。

CouchDB indexes
~~~~~~~~~~~~~~~

CouchDBのインデックスは、JSONを効率的にクエリするために必要であり、すべてのソートを伴うJSONクエリに必要です。
インデックスを使用すると、台帳に大量のデータがある場合に、チェーンコードからデータをクエリできます。
インデックスはチェーンコードと共に ``/META-INF/statedb/couchdb/indexes`` ディレクトリにパッケージ化できます。
インデックスは、 `CouchDB index JSON syntax <http://docs.couchdb.org/en/3.1.1/api/database/find.html#db-index>`__
に従ってJSONでフォーマットされたインデックス定義を含む ``*.json`` 拡張子のテキストファイルで定義する必要があります。
たとえば、上記のマーブルクエリをサポートするには、 ``docType`` と ``owner`` のインデックスを以下のように提供します。

.. code:: bash

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

サンプルインデックスは `こちら <https://github.com/hyperledger/fabric-samples/blob/master/asset-transfer-ledger-queries/chaincode-go/META-INF/statedb/couchdb/indexes/indexOwner.json>`__ で参照できます。

チェーンコードの ``META-INF/statedb/couchdb/indexes`` ディレクトリ内のすべてのインデックスは、
デプロイ時にチェーンコードと一緒にパッケージ化されます。
チェーンコードパッケージがピアにインストールされ、チェーンコード定義がチャネルにコミットされると、
インデックスはピアのチャネルおよびチェーンコード固有のデータベースにデプロイされます。
最初にチェーンコードをインストールしてからチェーンコード定義をチャネルにコミットすると、
コミット時にインデックスがデプロイされます。
もし、チェーンコードがチャネルで既に定義されており、その後でチャネルに参加しているピアにチェーンコードパッケージがインストールされた場合、
インデックスはチェーンコード **インストール** 時にデプロイされます。

デプロイすると、インデックスはチェーンコードクエリによって自動的に利用されます。
CouchDBは、クエリで使用されているフィールドに基づいて、使用するインデックスを自動的に決定します。
別の方法として、selectorクエリでは、 ``use_index`` キーワードを使用してインデックスを指定できます。

同じインデックスが、後からインストールされるチェーンコードに存在する場合があります。
インデックスを変更するには、同じインデックス名を使用しつつ、インデックス定義を変更します。
インストール/インスタンス化時に、インデックス定義がピアのステートデータベースに再デプロイされます。

すでに大量のデータがあり、チェーンコードを後からインストールする場合、
インストール時のインデックス作成に時間がかかる場合があります。
同様に、すでに大量のデータがあり、後続のチェーンコードバージョンの定義をコミットする場合、
インデックス作成に時間がかかる場合があります。
インデックスの初期化中にチェーンコードクエリがタイムアウトになる可能性があるため、
これらの時点では、ステートデータベースをクエリするチェーンコード関数を呼び出さないようにしてください。
トランザクション処理中、ブロックが台帳にコミットされると、インデックスは自動的に更新されます。
チェーンコードのインストール中にピアがクラッシュすると、couchdbのインデックスが作成されない場合があります。
その場合、チェーンコードを再インストールしてインデックスを作成する必要があります。

CouchDB Configuration
---------------------

CouchDB は、 ``stateDatabase`` 設定オプションを goleveldb から CouchDB に変更することで、ステートデータベースとして有効になります。
さらに、ピアが使用するCouchDBを指すように ``couchDBAddress`` を設定する必要があります。
usernameとpasswordのプロパティには、管理者のユーザー名とパスワードを入力する必要があります。
追加のオプションは ``couchDBConfig`` セクションで提供され、適切に記述されています。
*core.yaml* への変更は、ピアを再起動した直後に有効になります。

core.yamlの値を上書きするために、dockerに環境変数を渡すこともできます。
例えば、 ``CORE_LEDGER_STATE_STATEDATABASE`` と ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS`` 。

*core.yaml* の ``stateDatabase`` セクションを以下に示します。:

.. code:: bash

    state:
      # stateDatabase - options are "goleveldb", "CouchDB"
      # goleveldb - default state database stored in goleveldb.
      # CouchDB - store state database in CouchDB
      stateDatabase: goleveldb
      # Limit on the number of records to return per query
      totalQueryLimit: 10000
      couchDBConfig:
         # It is recommended to run CouchDB on the same server as the peer, and
         # not map the CouchDB container port to a server port in docker-compose.
         # Otherwise proper security must be provided on the connection between
         # CouchDB client (on the peer) and server.
         couchDBAddress: couchdb:5984
         # This username must have read and write authority on CouchDB
         username:
         # The password is recommended to pass as an environment variable
         # during start up (e.g. LEDGER_COUCHDBCONFIG_PASSWORD).
         # If it is stored here, the file must be access control protected
         # to prevent unintended users from discovering the password.
         password:
         # Number of retries for CouchDB errors
         maxRetries: 3
         # Number of retries for CouchDB errors during peer startup
         maxRetriesOnStartup: 10
         # CouchDB request timeout (unit: duration, e.g. 20s)
         requestTimeout: 35s
         # Limit on the number of records per each CouchDB query
         # Note that chaincode queries are only bound by totalQueryLimit.
         # Internally the chaincode may execute multiple CouchDB queries,
         # each of size internalQueryLimit.
         internalQueryLimit: 1000
         # Limit on the number of records per CouchDB bulk update batch
         maxBatchUpdateSize: 1000
         # Warm indexes after every N blocks.
         # This option warms any indexes that have been
         # deployed to CouchDB after every N blocks.
         # A value of 1 will warm indexes after every block commit,
         # to ensure fast selector queries.
         # Increasing the value may improve write efficiency of peer and CouchDB,
         # but may degrade query response time.
         warmIndexesAfterNBlocks: 1

Hyperledger Fabricで提供されるdockerコンテナでホストされるCouchDBには、
Docker Composeのスクリプトを使用して、環境変数 ``COUCHDB_USER`` および ``COUCHDB_PASSWORD``
で渡される環境変数でCouchDBのユーザー名とパスワードを設定する機能があります。

Fabricで提供されるDockerイメージ以外のCouchDBをインストールする場合、
`local.ini file of that installation
<http://docs.couchdb.org/en/3.1.1/config/intro.html#configuration-files>`__
を編集して、管理者のユーザー名とパスワードを設定する必要があります。

Docker Composeのスクリプトは、コンテナ作成時にのみユーザー名とパスワードを設定します。
コンテナ作成後にユーザー名またはパスワードを変更する場合、*local.ini* ファイルを編集する必要があります。

fabric-couchdbコンテナのポートをホストのポートにマップすることを選択した場合、
セキュリティへの影響を確認してください。
開発環境でCouchDBコンテナのポートをマッピングすると、CouchDBのREST APIが公開され、
CouchDBのWebインタフェース(Fauxton)を介してデータベースを視覚化できるようになります。
本番環境では、CouchDBコンテナへのアクセスを制限するため、ホストのポートをマッピングすることは控えてください。
ピアのみがCouchDBコンテナにアクセスできます。

.. note:: ピアのCouchDBオプションは、各ピアの起動時に読み取られます。

Good practices for queries
--------------------------

CouchDBデータベース全体をスキャンするクエリにチェーンコードを使用しないでください。
データベース全体をスキャンすると、応答時間が長くなり、ネットワークのパフォーマンスが低下します。
以下の手順に従うと、長時間クエリを回避できます。:

- JSONクエリを使用する時:

    * チェーンコードパッケージにインデックスを作成します。
    * データベース全体のスキャンにつながる ``$or`` 、 ``$in`` 、 ``$regex`` などのクエリ演算子を避けます。

- 範囲クエリ、復号キークエリ、JSONクエリの場合:

    * 1つの大きな結果セットではなく、ページネーション機能を利用します。

- アプリケーションの一部で、ダッシュボードを構築したり、集計データを収集したりする場合、
  ブロックチェーンネットワークからデータを複製したオフチェーンデータベースでクエリを実行できます。
  これにより、ネットワークのパフォーマンス低下やトランザクションの中断をせずに、
  ニーズに最適化されたデータストアでブロックチェーンデータのクエリと分析を行うことができます。
  これを実現するために、アプリケーションはブロックイベントまたはチェーンコードイベントを使用して、
  トランザクションデータをオフチェーンデータベースまたは分析エンジンに書き込みます。
  ブロックを受信する度に、アプリケーションのブロックリスナーはブロックトランザクションを反復処理し、
  有効なトランザクションの ``rwset`` からキー/バリューの書き込みを使用してデータストアを構築します。
  :doc:`peer_event_services` は、再生可能なイベントを提供して、ダウンストリームのデータストアの整合性を保証します。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
