The Operations Service
======================

ピアとOrdererは、RESTfulな「運用 (Operations)」APIを提供するHTTPサーバーをホストします。
このAPIはFabricネットワークサービスとは無関係であり、ネットワークの管理者や「ユーザー」ではなく、運用者が使用することを意図しています。

API は以下の機能を公開しています。

- ログレベル管理
- ヘルスチェック
- 運用メトリクスのPrometheusのターゲット (設定されている場合)
- バージョン情報を取得するためのエンドポイント

Configuring the Operations Service
----------------------------------

運用サービスには、次の2つの基本設定が必要です。

- Listenする **アドレス** および **ポート** 。
- 認証と暗号化に使用する **TLS証明書** と **鍵**。
  注：**これらの証明書は、個別の専用のCAによって生成される必要があります**。
  すべてのチャネル・組織のための証明書を発行するような (単一の) CAを使わないでください。

Peer
~~~~

ピアごとに、運用 (API) サーバーは  ``core.yaml`` の ``operations`` セクションで設定することができます:

.. code:: yaml

  operations:
    # 運用サーバーのホストとポート
    listenAddress: 127.0.0.1:9443

    # 運用サービスエンドポイントのTLS設定
    tls:
      # TLSが有効かどうか
      enabled: true

      # 運用サーバー用のPEMエンコードされたサーバー証明書へのパス
      cert:
        file: tls/server.crt

      # 運用サーバのPEMエンコードされたサーバ秘密鍵へのパス
      key:
        file: tls/server.key

      # TLSが有効になっている場合、ほとんどの運用サービスエンドポイントではクライアント認証が必要です。
      # clientAuthRequiredを有効にすると、すべてのリソースにアクセスするためにTLS層でクライアント証明書認証を必要とするようになります。
      clientAuthRequired: false

      # クライアント認証のために信頼する、PEMエンコードされたCA証明書へのパス
      clientRootCAs:
        files: []

``listenAddress`` キーは、運用サーバーがListenするホストとポートを定義します。サーバーがすべてのアドレスをListenする必要がある場合は、ホスト部分を省略できます。

``tls`` セクションは、運用サービスでTLSが有効になっているかどうか、サービスの証明書と秘密鍵の場所、
およびクライアント認証で信頼される認証局のルート証明書の場所を示すために使用されます。   ``enabled`` がtrueの場合、
ほとんどの運用サービスエンドポイントはクライアント認証を必要とするため、
``clientRootCAs.files`` を設定する必要があります。``clientAuthRequired`` が ``true`` の場合、
TLS層はクライアントがすべてのリクエストで認証用の証明書を提供することを要求します。
詳細については、以下のOperations Securityセクションを参照してください。

Orderer
~~~~~~~

Ordererごとに、運用サーバーは  ``orderer.yaml`` の `Operations` セクションで設定することができます:

.. code:: yaml

  Operations:
    # 運用サーバーのホストとポート
    ListenAddress: 127.0.0.1:8443

    # 運用サービスエンドポイントのTLS設定
    TLS:
      # TLSが有効かどうか
      Enabled: true

      # PrivateKey: 運用エンドポイントのPEMエンコードされたTLS秘密鍵
      PrivateKey: tls/server.key

      # 証明書は、サーバーのTLS証明書のファイルの場所を管理します
      Certificate: tls/server.crt

      # クライアント認証のために信頼する、PEMエンコードされたCA証明書へのパス
      ClientRootCAs: []

      # TLSが有効になっている場合、ほとんどの運用サービスエンドポイントではクライアント認証が必要です。
      # ClientAuthRequiredを有効にすると、すべてのリソースにアクセスするためにTLS層でクライアント証明書認証を必要とするようになります。
      ClientAuthRequired: false

``listenAddress`` キーは、運用サーバーがListenするホストとポートを定義します。サーバーがすべてのアドレスをListenする必要がある場合は、ホスト部分を省略できます。

``TLS`` セクション は、運用サービスでTLSが有効になっているかどうか、サービスの証明書と秘密鍵の場所、
およびクライアント認証で信頼される認証局のルート証明書の場所を示すために使用されます。   ``Enabled`` がtrueの場合、
ほとんどの運用サービスエンドポイントはクライアント認証を必要とするため、
``RootCAs`` を設定する必要があります。``ClientAuthRequired`` が ``true`` の場合、
TLS層はクライアントがすべてのリクエストで認証用の証明書を提供することを要求します。
詳細については、以下のOperations Securityセクションを参照してください。

Operations Security
~~~~~~~~~~~~~~~~~~~

運用サービスは運用に特化しており、
意図的にFabricネットワークとは無関係であるため、
アクセス制御にメンバーシップサービスプロバイダ (MSP) を使用しません。
代わりに、運用サービスはクライアント証明書認証による相互TLSに完全に依存しています。

TLSを無効にすると、認証がバイパスされ、運用エンドポイントに接続できるすべてのクライアントがAPIを使用できるようになります。

TLSが有効になっている場合、以下で特に明記がない限りすべてのリソースにアクセスするために、有効なクライアント証明書を提供する必要があります。

clientAuthRequiredも有効になっている場合、アクセスされるリソースに関係なく、TLS層は有効なクライアント証明書を要求します。

Log Level Management
~~~~~~~~~~~~~~~~~~~~

運用サービスは、運用者がピアまたはOrdererのアクティブなロギングスペック (logging spec) を管理するために使用できる ``/logspec`` リソースを提供します。
リソースは従来のRESTリソースであり、 ``GET`` および ``PUT`` リクエストをサポートします。

運用サービスが ``GET /logspec`` リクエストを受け取ると、現在のロギング仕様を含むJSONペイロードを返します:

.. code:: json

  {"spec":"info"}

運用サービスが ``PUT /logspec`` リクエストを受け取ると、ボディをJSONペイロードとして読み取ります。
ペイロードは、 ``spec`` という名前の単一の属性で構成されている必要があります。

.. code:: json

  {"spec":"chaincode=debug:info"}

スペックが正常にアクティブ化された場合、
サービスは ``204 "No Content"`` レスポンスを返します。
エラーが発生した場合、サービスは ``400 "Bad Request"`` とエラーペイロードを返します:

.. code:: json

  {"error":"error message"}

Health Checks
-------------

運用サービスは、運用者がピアやOrdererの生死と健康状態を判断するのに役立つ ``/healthz`` リソースを提供します。
リソースは、GETリクエストをサポートする従来のRESTリソースです。
この実装は、Kubernetesで使用されるliveness probeとの互換性を意図としていますが、他のコンテキストでも使用できます。

``GET /healthz`` リクエストを受け取ると、
運用サービスはプロセスに登録されているすべてのヘルスチェッカーを呼び出します。
すべてのヘルスチェッカーから成功が返ってきたら、運用サービスは ``200 "OK"`` と以下のようなJSONボディを返します:

.. code:: json

  {
    "status": "OK",
    "time": "2009-11-10T23:00:00Z"
  }

1つ以上のヘルスチェッカーがエラーを返した場合、
運用サービスは ``503 "Service Unavailable"`` と、どのヘルスチェッカーが失敗したかに関する情報を含むJSONボディで応答します。

.. code:: json

  {
    "status": "Service Unavailable",
    "time": "2009-11-10T23:00:00Z",
    "failed_checks": [
      {
        "component": "docker",
        "reason": "failed to connect to Docker daemon: invalid endpoint"
      }
    ]
  }

現在のバージョンでは、登録されているヘルスチェックはDockerのみです。
将来のバージョンでは、他のヘルスチェックが追加できるように拡張される予定です。

TLSが有効な場合、 ``clientAuthRequired`` が ``true`` に設定されていない限り、
このサービスを使用するために有効なクライアント証明書は必要ありません。

Metrics
-------

FabricのピアおよびOrdererの一部のコンポーネントは、
システムの動作に関する洞察を提供するのに役立つメトリクスを公開します。
運用者と管理者は、この情報を使用して、システムが時間経過とともにどのように動いているかをよりよく理解できます。

Configuring Metrics
~~~~~~~~~~~~~~~~~~~

Fabricは、Prometheusをベースにした **プル型 (pull)** モデルとStatsDをベースにした **プッシュ型 (push)** モデルの2つの方法でメトリクスを提供します。

Prometheus
~~~~~~~~~~

典型的なPrometheusデプロイメントは、
インストルメント化されたターゲットによって公開されたHTTPエンドポイントからメトリックスを要求することにより、
メトリックスをスクレイピングします。
Prometheusがメトリクスの要求をするため、プル型システムと見なされます。

設定されている場合、FabricのピアまたはOrdererは運用サービス上に ``/metrics`` リソースを提示します。

Peer
^^^^

ピアは、 ``core.yaml`` の ``metrics`` セクションでメトリックプロバイダを ``prometheus`` に設定することで、
Prometheusが ``metrics`` エンドポイントを公開してスクレイピングするように設定できます。

.. code:: yaml

  metrics:
    provider: prometheus

Orderer
^^^^^^^

Ordererは、 ``orderer.yaml`` の ``metrics`` セクションでメトリクスプロバイダを ``prometheus`` に設定することで、
Prometheusが ``metrics`` エンドポイントを公開してスクレイピングするように設定できます。

.. code:: yaml

  Metrics:
    Provider: prometheus

StatsD
~~~~~~

StatsDはシンプルな統計情報集約デーモンです。
メトリクスは ``statsd`` デーモンに送信され、
そこで収集、集約され、視覚化とアラートのためにバックエンドにプッシュされます。
このモデルでは、メトリックスデータをStatsDに送信するためにインストルメント化されたプロセスが必要であるため、
これはプッシュ型システムと見なされます。

Peer
^^^^

ピアは、 ``core.yaml`` の ``metrics`` セクションでメトリクスプロバイダを ``statsd`` に設定することにより、
メトリックスをStatsDに送信するように設定できます。
``statsd`` サブセクションはStatsDデーモンのアドレス、使用するネットワークタイプ ( ``tcp`` または ``udp``)、
およびメトリックスを送信する頻度で構成する必要もあります。
オプションの ``prefix`` を指定して、メトリックスのソースを区別することができます (たとえば、別のピアからのメトリックスと区別)。
このプレフィックスは生成されたすべてのメトリックスの前に付加されます。

.. code:: yaml

  metrics:
    provider: statsd
    statsd:
      network: udp
      address: 127.0.0.1:8125
      writeInterval: 10s
      prefix: peer-0

Orderer
^^^^^^^

Ordererは、 ``orderer.yaml`` の ``metrics`` セクションでメトリクスプロバイダを ``statsd`` に設定することにより、
メトリックスをStatsDに送信するように設定できます。
``statsd`` サブセクションはStatsDデーモンのアドレス、使用するネットワークタイプ ( ``tcp`` または ``udp``)、
およびメトリックスを送信する頻度で構成する必要もあります。
オプションの ``prefix`` を指定して、メトリックスのソースを区別することができます。

.. code:: yaml

  Metrics:
      Provider: statsd
      Statsd:
        Network: udp
        Address: 127.0.0.1:8125
        WriteInterval: 30s
        Prefix: org-orderer

生成されるさまざまなメトリックスについては、 :doc:`metrics_reference` を参照してください。

Version
-------

Ordererとピアの両方が ``/version`` エンドポイントを公開します。
このエンドポイントは、Ordererまたはピアのバージョンと、リリースが作成されたコミットSHAを含むJSONドキュメントを提供します。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
