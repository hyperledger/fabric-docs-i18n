# Checklist for a production ordering node

本番オーダリングサービス(または1つのオーダリングノード)をビルドする準備をするときは、 [orderer.yaml](https://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/orderer.yaml) ファイルを編集して設定をカスタマイズする必要があります。このファイルは、Fabricのバイナリをダウンロードするときに `/config` ディレクトリにコピーされており、 `/etc/hyperledger/fabric/orderer.yaml` のFabricオーダリングノードイメージ内で使用できます。

本番環境では、DockerコンテナまたはKubernetesジョブで ` orderer.yaml` ファイルの環境変数を上書きすることができますが、ここでは `orderer.yaml` を編集する方法を説明します。その設定ファイルのパラメータと、ファイル内の他のパラメータ設定へのそれらの依存関係を理解することが重要です。環境変数を使用して1つの設定をやみくもに上書きすると、別の設定の機能に影響を与える可能性があります。したがって、オーダリングノードを開始する前に、設定ファイルの設定を変更して、使用可能な設定とその動作方法に慣れることをお勧めします。その後、環境変数を使用してこれらのパラメータを上書きすることもできます。

このチェックリストは、本番のオーダリングサービスを設定するための重要な設定パラメータを対象としています。もちろん、追加のパラメータや詳細については、いつでもorderer.yamlファイルを参照できます。また、どのパラメータを上書きすべきかについてのガイダンスも提供します。理解する必要のあるこのトピックで説明されているパラメータのリストには、次のものがあります。

* [General.ListenAddress](#general-listenaddress)
* [General.ListenPort](#general-listenport)
* [General.TLS.*](#general-tls)
* [General.Keepalive.*](#general-keepalive)
* [General.Cluster.*](#general-cluster)
* [General.BoostrapMethod](#general-bootstrapmethod)
* [General.BoostrapFile](#general-bootstrapfile)
* [General.LocalMSPDir](#general-localmspdir)
* [General.LocalMSPID](#general-localmspid)
* [FileLedger.Location](#fileledger-location)
* [Operations.*](#operations)
* [Metrics.*](#metrics)
* [Consensus.*](#consensus)

## General.ListenAddress

```
# Listen address: The IP on which to bind to listen.
ListenAddress: 127.0.0.1
```

* **`ListenAddress`**: (デフォルト値を上書きする必要があります) これは、ordererがlistenする場所です(例: `0.0.0.0` )。注意:ピアとは異なり、 `orderer.yaml` はアドレスとポートを分けるため、 [General.ListenPort](#general-listenport) パラメータがあります。

## General.ListenPort

```
# Listen port: The port on which to bind to listen.
ListenPort: 7050
```

* **`ListenPort`**: (デフォルト値を上書きする必要があります) これはordererがlistenするポートです。

## General.TLS

```
Enabled: false
# PrivateKey governs the file location of the private key of the TLS certificate.
PrivateKey: tls/server.key
# Certificate governs the file location of the server TLS certificate.
Certificate: tls/server.crt
RootCAs:
  - tls/ca.crt
ClientAuthRequired: false
ClientRootCAs:
```

* **`Enabled`**: (デフォルト値を上書きする必要があります) 本番ネットワークでは、TLSで保護された通信を使用する必要があります。この値は `true` である必要があります。
* **`PrivateKey`**: このノードに対してTLS CAによって生成された秘密鍵へのパスとファイル名を指定します。
* **`Certificate`**: (デフォルト値を上書きする必要があります) このノードに対してTLS CAによって生成された公開証明書(署名証明書とも言われる)へのパスとファイル名を指定します。
* **`RootCAs`**: (コメントアウトする必要があります) このパラメータは、通常の利用ではたいていの場合設定されません。これは、アウトバウンド接続中に他のオーダリングノードの証明書を検証するために使用される追加のルート証明書へのパスのリストです。これは、各チャネル設定のMSPから入手可能なTLS CA証明書のセットを拡張するために使用できます。
* **`ClientAuthRequired`**: (相互TLSのみ) この値を "true" に設定すると、ネットワーク上で相互TLSが有効になります。これは、1つのノードだけでなく、ネットワーク全体に対して行う必要があります。
* **`ClientRootCAs`**: (相互TLSのみ) 相互TLSが無効な場合は空白のままにできます。相互TLSが有効になっている場合、これはクライアント接続の証明書を検証するために使用される追加のルート証明書へのパスのリストです。各チャネル設定のMSPから入手可能なTLS CA証明書のセットを拡張するために使用できます。

## General.KeepAlive

`KeepAlive` 値は、ネットワークのコンポーネント間にあるネットワークデバイスまたはソフトウェア(ファイアウォールやプロキシなど)との互換性を保つために調整する必要がある場合があります。理想的には、これらの設定はテストまたは試作環境で必要に応じて操作され、本番環境に合わせて設定します。

```
# ServerMinInterval is the minimum permitted time between client pings.
# If clients send pings more frequently, the server will
# disconnect them.
ServerMinInterval: 60s
# ServerInterval is the time between pings to clients.
ServerInterval: 7200s
# ServerTimeout is the duration the server waits for a response from
# a client before closing the connection.
ServerTimeout: 20s
```

* **`ServerMinInterval`**: (テストで必要と判断されない限り、デフォルト値を上書きしないでください)
* **`ServerInterval`**: (テストで必要と判断されない限り、デフォルト値を上書きしないでください)
* **`ServerTimeout`**: (テストで必要と判断されない限り、デフォルト値を上書きしないでください)

## General.Cluster

```
# SendBufferSize is the maximum number of messages in the egress buffer.
# Consensus messages are dropped if the buffer is full, and transaction
# messages are waiting for space to be freed.
SendBufferSize: 10
# ClientCertificate governs the file location of the client TLS certificate
# If not set, the server General.TLS.Certificate is re-used.
ClientCertificate:
# If not set, the server General.TLS.PrivateKey is re-used.
ClientPrivateKey:
# The below 4 properties should be either set together, or be unset together.
# If they are set, then the orderer node uses a separate listener for intra-cluster
# communication. If they are unset, then the general orderer listener is used.
# This is useful if you want to use a different TLS server certificates on the
# client-facing and the intra-cluster listeners.

# ListenPort defines the port on which the cluster listens to connections.
ListenPort:
# ListenAddress defines the IP on which to listen to intra-cluster communication.
ListenAddress:
# ServerCertificate defines the file location of the server TLS certificate used for intra-cluster
# communication.
ServerCertificate:
# ServerPrivateKey defines the file location of the private key of the TLS certificate.
ServerPrivateKey:
```

設定されていない場合、ordererが別のクラスタポートを使用するように設定されていないときは、 `ClientCertificate` および `ClientPrivateKey` は、サーバーの `General.TLS.Certificate` および `General.TLS.PrivateKey` をデフォルトにします。

* **`ClientCertificate`**: このノードに対してTLS CAによって生成された公開証明書(署名済み証明書とも呼ばれます)へのパスとファイル名を指定します。
* **`ClientPrivateKey`**: このノードに対してTLS CAによって生成された秘密鍵へのパスとファイル名を指定します。

一般に、これらの4つのパラメータを設定する必要があるのは、ピアクライアントとアプリケーションクライアントが利用するリスナーを使用するのではなく、(他のRaft ordererとの)クラスタ内通信のために個別のリスナーとTLS証明書を設定する場合だけです。これは高度なデプロイオプションです。これらの4つのパラメータは一緒に設定するか、未設定のままにしておく必要があります。設定する場合は、 `ClientCertificate` と `ClientPrivateKey` も設定する必要があることに注意してください。

* **`ListenPort`**
* **`ListenAddress`**
* **`ServerCertificate`**
* **`ServerPrivateKey`**

## General.BoostrapMethod

```
# Bootstrap method: The method by which to obtain the bootstrap block
# system channel is specified. The option can be one of:
#   "file" - path to a file containing the genesis block or config block of system channel
#   "none" - allows an orderer to start without a system channel configuration
BootstrapMethod: file
```

* **`BootstrapMethod`**: (デフォルト値を上書きしないでください) "file"以外のファイルタイプを使用する予定がない限り、この値はそのままにしておく必要があります。

## General.BoostrapFile

```
# Bootstrap file: The file containing the bootstrap block to use when
# initializing the orderer system channel and BootstrapMethod is set to
# "file".  The bootstrap file can be the genesis block, and it can also be
# a config block for late bootstrap of some consensus methods like Raft.
# Generate a genesis block by updating $FABRIC_CFG_PATH/configtx.yaml and
# using configtxgen command with "-outputBlock" option.
# Defaults to file "genesisblock" (in $FABRIC_CFG_PATH directory) if not specified.
BootstrapFile:
```

* **`BoostrapFile`**: (デフォルト値を上書きする必要があります) このノードが作成されるときに使用するシステムチャネルジェネシスブロックの場所と名前を指定します。

## General.LocalMSPDir

```
# LocalMSPDir is where to find the private crypto material needed by the
# orderer. It is set relative here as a default for dev environments but
# should be changed to the real location in production.
LocalMSPDir: msp
```

**`LocalMSPDir`**: (デフォルト値はしばしば上書きされます) これはオーダリングノードのローカルMSPへのパスであり、デプロイする前に作成する必要があります。パスは、`FABRIC_CFG_PATH` に対して絶対パスまたは相対パスにすることができます(デフォルトでは、ordererイメージ内の `/etc/hyperledger/fabric` です)。"msp"以外の名前のフォルダに絶対パスが指定されていない限り、オーダリングノードはデフォルトで"msp"という名前のフォルダをそのパス(つまり、 `FABRIC_CFG_PATH/msp` )で検索し、ordererイメージを使用する場合は `/etc/hyperledger/fabric/msp` を検索します。 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) で説明されている推奨されたフォルダ構造を使用している場合、 `FABRIC_CFG_PATH` への相対パスは、 `config/organizations/ordererOrganizations/org0.example.com/orderers/orderer0.org0.example.com/msp` のようになります。 **ベストプラクティスは、このデータを永続ストレージに保存することです。** これにより、何らかの理由でordererコンテナが破壊されても、MSPが失われることを防ぎます。

## General.LocalMSPID

```
# LocalMSPID is the identity to register the local MSP material with the MSP
# manager. IMPORTANT: The local MSP ID of an orderer needs to match the MSP
# ID of one of the organizations defined in the orderer system channel's
# /Channel/Orderer configuration. The sample organization defined in the
# sample configuration provided has an MSP ID of "SampleOrg".
LocalMSPID: SampleOrg
```

* **`LocalMSPID`**: (デフォルト値を上書きする必要があります) MSP IDは、システムチャネルの設定にあるオーダリング組織のMSP IDと一致する必要があります。つまり、そのMSP IDは、システムチャネルのジェネシスブロックを作成するために使用される `configtx.yaml` にリストされている(または、後でシステムチャネル管理者のリストに追加されている)必要があります。

## General.BCCSP.*

```
# Default specifies the preferred blockchain crypto service provider
        # to use. If the preferred provider is not available, the software
        # based provider ("SW") will be used.
        # Valid providers are:
        #  - SW: a software based crypto provider
        #  - PKCS11: a CA hardware security module crypto provider.
        Default: SW

        # SW configures the software based blockchain crypto provider.
        SW:
            # TODO: The default Hash and Security level needs refactoring to be
            # fully configurable. Changing these defaults requires coordination
            # SHA2 is hardcoded in several places, not only BCCSP
            Hash: SHA2
            Security: 256
            # Location of key store. If this is unset, a location will be
            # chosen using: 'LocalMSPDir'/keystore
            FileKeyStore:
                KeyStore:
```

(任意)このセクションは、ブロックチェーンの暗号プロバイダーを設定するために使用されます。

* **`BCCSP.Default:`** ハードウェアセキュリティモジュール(HSM)を使用する場合は、これを `PKCS11` に設定する必要があります。

```
# Settings for the PKCS#11 crypto provider (i.e. when DEFAULT: PKCS11)
        PKCS11:
            # Location of the PKCS11 module library
            Library:
            # Token Label
            Label:
            # User PIN
            Pin:
            Hash:
            Security:
            FileKeyStore:
                KeyStore:
```

* **`BCCSP.PKCS11.*:`** HSMの設定に応じて、このパラメータセットを提供します。詳細については、HSM設定のこの [例](../hsm.html) を参照してください。

## FileLedger.Location

```
# Location: The directory to store the blocks in.
Location: /var/hyperledger/production/orderer
```

* **`Location`**: (デフォルト値は、2つのオーダリングノードが同じノード上で実行されている可能性の低いイベントで上書きする必要があります) ノードが同意者であるすべてのチャネルは、この場所に独自のサブディレクトリを持ちます。ordererを運営するユーザーは、このディレクトリを所有し、書き込みアクセスできる必要があります。 **ベストプラクティスは、このデータを永続ストレージに保存します。** これにより、ordererコンテナが何らかの理由で破壊された場合に台帳が失われるのを防ぎます。

## Operations.*

運用サービスはオーダリングノードの健全性を監視するために使用され、通信をセキュアにするため相互TLSに依存しています。そのため、 `operations.tls.clientAuthRequired` を `true` に設定する必要があります。このパラメータが `true` に設定されている場合、ノードの健全性を確認しようとするクライアントは、認証に有効な証明書の提供を要求されます。クライアントが証明書を提供しない、またはサービスがクライアントの証明書を確認できない場合、そのリクエストは却下されます。これは、クライアントがオーダリングノードのTLS CAに登録し、リクエストに対してTLS署名証明書を提供する必要があることを意味します。詳細は、 [The Operations Service](../operations_service.html) を参照してください。

Prometheus [metrics](#metrics) を使用してオーダリングノードを監視する場合は、ここで運用サービスを設定する必要があります。

インフラストラクチャ上の同じノードで2つのオーダリングノードが実行されているという稀にあるケースでは、別のポートを使用するために2番目のオーダリングノードのアドレスを変更する必要があります。そうしないと、2番目のオーダリングノードを開始した際に、開始に失敗し、アドレスがすでに使用されていることが報告されます。

```
# host and port for the operations server
    ListenAddress: 127.0.0.1:8443

    # TLS configuration for the operations endpoint
    TLS:
        # TLS enabled
        Enabled: false

        # Certificate is the location of the PEM encoded TLS certificate
        Certificate:

        # PrivateKey points to the location of the PEM-encoded key
        PrivateKey:

        # Most operations service endpoints require client authentication when TLS
        # is enabled. ClientAuthRequired requires client certificate authentication
        # at the TLS layer to access all resources.
        ClientAuthRequired: false

        # Paths to PEM encoded ca certificates to trust for client authentication
        ClientRootCAs: []
```

* **`ListenAddress`**: (運用サービスを利用する場合は必須) 運用サーバーのアドレスとポートを指定します。
* **`Enabled`**: (運用サービスを利用する場合は必須) 運用サービスを利用する場合は `true` にする必要があります。
* **`Certificate`**: (運用サービスを利用する場合は必須) `General.TLS.Certificate` と同じファイルにすることができます。
* **`PrivateKey`**: (運用サービスを利用する場合は必須) `General.TLS.PrivateKey` と同じファイルにすることができます。
* **`ClientAuthRequired`**: (運用サービスを利用する場合は必須) クライアントとサーバー間の相互TLSを有効にするため `true` に設定する必要があります。
* **`ClientRootCAs`**: (運用サービスを利用する場合は必須) TLSのクライアントルートCA証明書ファイルと同様に、クライアント証明書の検証に使用できるクライアントルートCA証明書のリストが含まれています。クライアントがオーダリング組織CAに登録されている場合、この値はオーダリング組織ルートCA証明書です。

## Metrics.*

デフォルトではこれは無効ですが、ordererのメトリクスを監視する場合は、 `StatsD` または `Prometheus` をメトリクスプロバイダとして使用する必要があります。 `StatsD` は "push" モデルを使用し、メトリクスをオーダリングノードから `StatsD` エンドポイントにプッシュします。そのため、運用サービス自体の設定は必要ありません。一方、 `Prometheus` メトリクスはオーダリングノードからプルされます。

`Prometheus` メトリクスの詳細については、 [Prometheus](../metrics_reference.html#prometheus) をご覧ください。

利用可能な `StatsD` メトリクスの詳細については、 [StatsD](../metrics_reference.html#statsd) をご覧ください。

Prometheusは "pull" モデルを利用しているため、運用サービスを利用可能にする以外に必須の設定はありません。むしろ、Prometheusは操作URLにリクエストを送信して、利用可能なメトリクスをプルします。

```
    # The metrics provider is one of statsd, prometheus, or disabled
    Provider: disabled

    # The statsd configuration
    Statsd:
      # network type: tcp or udp
      Network: udp

      # the statsd server address
      Address: 127.0.0.1:8125

      # The interval at which locally cached counters and gauges are pushed
      # to statsd; timings are pushed immediately
      WriteInterval: 30s

      # The prefix is prepended to all emitted statsd metrics
      Prefix:
```

* **`Provider`**: `StatsD` を使用している場合はこの値を `statsd` に設定し、 `Prometheus` を使用している場合は `prometheus` に設定します。
* **`Statsd.Address`**: (オーダリングノードに `StatsD` メトリクスを使用する場合は必須) `StatsD` が有効の場合、オーダリングノードがメトリックの更新をプッシュできるように、 `StatsD` サーバーの `hostname` と `port` を設定する必要があります。

## Consensus.*

このセクションの値は合意形成プラグインによって異なります。以下の値は、 `etdraft` 合意形成プラグイン用です。別の合意形成プラグインを使用している場合は、許可されるキーと推奨される値について、そのドキュメントを参照してください。

```
# The allowed key-value pairs here depend on consensus plugin. For etcd/raft,
# we use following options:

# WALDir specifies the location at which Write Ahead Logs for etcd/raft are
# stored. Each channel will have its own subdir named after channel ID.
WALDir: /var/hyperledger/production/orderer/etcdraft/wal

# SnapDir specifies the location at which snapshots for etcd/raft are
# stored. Each channel will have its own subdir named after channel ID.
SnapDir: /var/hyperledger/production/orderer/etcdraft/snapshot
```

* **`WALDir`**: (デフォルト値を上書きする必要があります) これはオーダリングノードのローカルファイルシステムにあるログ先行書き込みへのパスです。 `FABRIC_CFG_PATH` に対する絶対パスまたは相対パスを指定できます。デフォルトは `/var/hyperledger/production/orderer/etcdraft/wal` です。各チャネルには、チャネルIDにちなんだ名前のサブディレクトリがあります。オーダリングノードを実行するユーザーは、このディレクトリを所有し、書き込みアクセスできる必要があります。 **ベストプラクティスはこのデータを永続ストレージに保存することです。** これにより、ordererコンテナが何らかの理由で破壊された場合に、ログ先行書き込みが失われることを防ぎます。
* **`SnapDir`**: (デフォルト値を上書きする必要があります) これはオーダリングノードのローカルファイルシステムにあるスナップショットへのパスです。Raftオーダリングサービスでスナップショットがどのように機能するかについての詳細は、 [Snapshots](../orderer/ordering_service.html#snapshots)/ を参照してください。 `FABRIC_CFG_PATH` に対する絶対パスまたは相対パスを指定できます。デフォルトは `/var/hyperledger/production/orderer/etcdraft/wal` です。各チャネルには、チャネルIDにちなんだ名前のサブディレクトリがあります。オーダリングノードを実行するユーザーは、このディレクトリを所有し、書き込みアクセスできる必要があります。 **ベストプラクティスは、このデータを永続ストレージに保存することです。** これにより、何らかの理由でordererコンテナが破壊された場合にスナップショットが失われることを防ぎます。

`orderer.yaml` では使用できないパラメータの設定方法など、オーダリングノード設定の詳細については、 [Configuring and operating a Raft ordering service](../raft_configuration.html) をご覧ください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
