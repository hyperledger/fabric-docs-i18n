#  Checklist for a production peer

本番のピアをビルドする準備をするときは、 [core.yaml](https://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/core.yaml) ファイルを編集して、設定をカスタマイズする必要があります。これは、Fabricバイナリファイルをダウンロードするときに `/config` ディレクトリにコピーされ、 `/etc/hyperledger/fabric/core.yaml` のFabricピアイメージ内で使用できます。

本番環境では、DockerコンテナまたはKubernetesジョブで `core.yaml` ファイルの環境変数を上書きすることができますが、これらの手順では `core.yaml` を編集する方法を示します。設定ファイルのパラメータと、そのファイル内の他のパラメータ設定への依存関係を理解することが重要です。環境変数を使用してある設定をやみくもに上書きすると、別の設定の機能に影響を与える可能性があります。そのため、ピアを開始する前に、設定ファイルの設定を変更して、使用可能な設定とその機能について理解することをお勧めします。その後、環境変数を使用してこれらのパラメータを上書きすることを選択できます。

このチェックリストは、本番ネットワークを設定するためのキー設定パラメータを対象にしています。もちろん、追加のパラメータや詳細については、core.yamlファイルをいつでも参照できます。また、どのパラメータを上書きすべきかについてのガイダンスも提供します。理解したほうが良いこのトピックで説明されているパラメータのリストには、次のものがあります。

- [peer.id](#peer-id)
- [peer.networkId](#peer-networkid)
- [peer.listenAddress](#peer-listenaddress)
- [peer.chaincodeListenAddress](#peer-chaincodelistenaddress)
- [peer.chaincodeAddress](#peer-chaincodeaddress)
- [peer.address](#peer-address)
- [peer.mspConfigPath](#peer-mspconfigpath)
- [peer.localMspId](#peer-localmspid)
- [peer.fileSystemPath](#peer-filesystempath)
- [peer.gossip.*](#peer-gossip)
- [peer.tls.*](#peer-tls)
- [peer.bccsp.*](#peer-bccsp)
- [chaincode.externalBuilders.*](#chaincode-externalbuilders)
- [ledger.*](#ledger)
- [operations.*](#operations)
- [metrics.*](#metrics)

## peer.id

```
# The peer id provides a name for this peer instance and is used when
# naming docker resources.
id: jdoe
```
- **`id`**: (デフォルト値を上書きする必要があります。) まずピアにIDを与えます（名前をつけるのと同じようなもの）。多くの場合、名前はピアが属する組織を示します。例えば、 `peer0.org1.example.com` です。ピアのチェーンコードイメージやコンテナの名前に使われます。

## peer.networkId

```
# The networkId allows for logical separation of networks and is used when
# naming docker resources.
networkId: dev
```

- **`networkId`**: (デフォルト値を上書きする必要があります。) 任意の名前を指定します。推奨される方法の1つは、予定された使用方法(例えば、“dev”、“staging”、“test”、”production”など)に基づいて名前を付けることによって、ネットワークを差別化することです。この値は、チェーンコードイメージやコンテナの名前をビルドするのにも使われます。

## peer.listenAddress

```
# The Address at local network interface this Peer will listen on.
# By default, it will listen on all network interfaces
listenAddress: 0.0.0.0:7051
```
- **`listenAddress`**: (デフォルト値を上書きする必要があります。) ピアがlistenするアドレスを指定します。例えば、 `0.0.0.0:7051` です。

## peer.chaincodeListenAddress

```
# The endpoint this peer uses to listen for inbound chaincode connections.
# If this is commented-out, the listen address is selected to be
# the peer's address (see below) with port 7052
chaincodeListenAddress: 0.0.0.0:7052
```

- **`chaincodeListenAddress`**: (デフォルト値を上書きする必要があります。) このパラメータのコメントアウトを外し、このピアがチェーンコード要求をlistenするアドレスを指定します。`peer.listenAddress` とは異なる必要があります。例えば、 `0.0.0.0:7052` です。

## peer.chaincodeAddress
```
# The endpoint the chaincode for this peer uses to connect to the peer.
# If this is not specified, the chaincodeListenAddress address is selected.
# And if chaincodeListenAddress is not specified, address is selected from
# peer address (see below). If specified peer address is invalid then it
# will fallback to the auto detected IP (local IP) regardless of the peer
# addressAutoDetect value.
chaincodeAddress: 0.0.0.0:7052
```
- **`chaincodeAddress`**: (デフォルト値を上書きする必要があります。) このパラメータのコメントアウトを外し、チェーンコードコンテナがこのピアに接続するために使用できるアドレスを指定します。例えば、 `peer0.org1.example.com:7052` です。

## peer.address
```
# When used as peer config, this represents the endpoint to other peers
# in the same organization. For peers in other organization, see
# gossip.externalEndpoint for more info.
# When used as CLI config, this means the peer's endpoint to interact with
address: 0.0.0.0:7051
```
- **`address`**: (デフォルト値を上書きする必要があります。) 組織内の他のピアがこのピアに接続するために使用するアドレスを指定します。例えば、 `peer0.org1.example.com:7051` です。

## peer.mspConfigPath
```
mspConfigPath: msp
```
- **`mspConfigPath`**: (デフォルト値を上書きする必要があります。) これはピアのローカルMSPへのパスであり、ピアをデプロイする前に作成する必要があります。パスは、絶対パスでも `FABRIC_CFG_PATH` に対する相対パスでもかまいません(デフォルトでは、ピアイメージにある `/etc/hyperledger/fabric` です)。「msp」以外の名前が付けられたフォルダへの絶対パスが指定されていない限り、ピアはデフォルトでそのパス(つまり `FABRIC_CFG_PATH/msp` )で「msp」という名前のフォルダを探し、ピアイメージを使用する場合は `/etc/hyperledger/fabric/msp` になります。[Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) トピックで説明されている推奨フォルダ構造を使用している場合、FABRIC_CFG_PATHに対する相対パスは次のようになります。
`config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp`
**ベストプラクティスはこのデータを永続ストレージに保存することです。** これにより、ピアコンテナが何らかの理由で破壊された場合にMSPが失われることを防ぎます。

## peer.localMspId
```
# Identifier of the local MSP
# ----!!!!IMPORTANT!!!-!!!IMPORTANT!!!-!!!IMPORTANT!!!!----
# Deployers need to change the value of the localMspId string.
# In particular, the name of the local MSP ID of a peer needs
# to match the name of one of the MSPs in each of the channel
# that this peer is a member of. Otherwise this peer's messages
# will not be identified as valid by other nodes.
localMspId: SampleOrg
```

- **`localMspId`**: (デフォルト値を上書きする必要があります。) これはピアが属する組織のMSP IDの値です。ピアは、ピアが属する組織がチャネルメンバーである場合にのみ、チャネルに参加できるため、このMSP IDは、このピアがメンバーである各チャネル内のMSPの少なくとも1つの名前と一致する必要があります。

## peer.fileSystemPath
```
# Path on the file system where peer will store data (eg ledger). This
# location must be access control protected to prevent unintended
# modification that might corrupt the peer operations.
fileSystemPath: /var/hyperledger/production
```
- **`fileSystemPath`**: (デフォルト値を上書きする必要があります。) これは台帳へのパスで、ピアのローカルファイルシステムにチェーンコードがインストールされています。`FABRIC_CFG_PATH` に対する絶対パスまたは相対パスを指定できます。デフォルトは `/var/hyperledger/production` です。ピアを実行しているユーザーは、このディレクトリを所有し、書き込みアクセスできる必要があります。 **ベストプラクティスはこのデータを永続ストレージに保存することです。** これにより、ピアコンテナが何らかの理由で破壊された場合に、台帳とインストールされているチェーンコードが失われることを防ぎます。

## peer.gossip.*

```
gossip:
    # Bootstrap set to initialize gossip with.
    # This is a list of other peers that this peer reaches out to at startup.
    # Important: The endpoints here have to be endpoints of peers in the same
    # organization, because the peer would refuse connecting to these endpoints
    # unless they are in the same organization as the peer.
    bootstrap: 127.0.0.1:7051

    # Overrides the endpoint that the peer publishes to peers
    # in its organization. For peers in foreign organizations
    # see 'externalEndpoint'
    endpoint:

    # This is an endpoint that is published to peers outside of the organization.
    # If this isn't set, the peer will not be known to other organizations.
    externalEndpoint:

    # NOTE: orgLeader and useLeaderElection parameters are mutual exclusive.
    # Setting both to true would result in the termination of the peer
    # since this is undefined state. If the peers are configured with
    # useLeaderElection=false, make sure there is at least 1 peer in the
    # organization that its orgLeader is set to true.

    # Defines whenever peer will initialize dynamic algorithm for
    # "leader" selection, where leader is the peer to establish
    # connection with ordering service and use delivery protocol
    # to pull ledger blocks from ordering service.
    useLeaderElection: false

    # Statically defines peer to be an organization "leader",
    # where this means that current peer will maintain connection
    # with ordering service and disseminate block across peers in
    # its own organization. Multiple peers or all peers in an organization
    # may be configured as org leaders, so that they all pull
    # blocks directly from ordering service.
    orgLeader: true

    # Gossip state transfer related configuration
    state:
        # indicates whenever state transfer is enabled or not
        # default value is true, i.e. state transfer is active
        # and takes care to sync up missing blocks allowing
        # lagging peer to catch up to speed with rest network
        enabled: false

    pvtData:
      implicitCollectionDisseminationPolicy:
          # requiredPeerCount defines the minimum number of eligible peers to which the peer must successfully
          # disseminate private data for its own implicit collection during endorsement. Default value is 0.
          requiredPeerCount: 0

          # maxPeerCount defines the maximum number of eligible peers to which the peer will attempt to
          # disseminate private data for its own implicit collection during endorsement. Default value is 1.
          maxPeerCount: 1
```

ピアは、スケーラブルな方法で台帳およびチャネルデータをブロードキャストするために、ゴシップデータ配布プロトコルを活用します。ゴシップメッセージングは継続的であり、チャネル上の各ピアは、複数のピアから現在の一貫した台帳データを常に受信しています。カスタマイズ可能なゴシップパラメータはたくさんありますが、少なくとも次の3つの設定グループに注意する必要があります。

* **Endpoints** ゴシップはサービスディスカバリとプライベートデータの配布に必須です。これらの機能を使用するには、ピアのチャネル設定の **少なくとも1つのアンカーピアの設定** に加えて、ゴシップの `bootstrap` 、 `endpoint` 、および `externalEndpoint` パラメーターを設定する必要があります。

  - **`bootstrap`**: (デフォルト値を上書きする必要があります。) この組織の他のピア [addresses](#address) のリストを提供します。

  - **`endpoint`**: (デフォルト値を上書きする必要があります。) _この組織_ の他のピアがこのピアに接続するために使用すべきアドレスを指定します。例えば、 `peer0.org1.example.com:7051` です。

  - **`externalEndpoint:`** (デフォルト値を上書きする必要があります。) _他の組織_ 内のピアがこのピアに接続するために使用するアドレスを指定します。例えば、 `peer0.org1.example.com:7051` です。

* **Block dissemination** ネットワークトラフィックを削減するために、ピアが組織内の他のピアからではなく、オーダリングサービスからブロックを取得することをお勧めします（Fabric v2.2から始まったデフォルト設定）。このセクションにある `useLeaderElection:` 、 `orgLeader:` 、 `state.enabled`パラメータの組み合わせにより、ピアがオーダリングサービスからブロックをプルすることが保証されます。

  - **`useLeaderElection:`** (v2.2のデフォルトは `false` です。これはピアがオーダリングサービスからブロックを取得するために推奨されます。) `useLeaderElection` がfalseに設定されている場合、 `peer.gossip.orgLeader` をtrueに設定して、少なくとも1つのピアを組織のリーダーにする必要があります。組織内のピア間でブロック配布にゴシップを使用するようにピアを設定する場合は、 `useLeaderElection` をtrueにします。

  - **`orgLeader:`** (v2.2のデフォルトは `true` です。これはピアがオーダリングサービスからブロックを取得するために推奨されます。) 組織内のピア間でブロック配布にゴシップを使用する場合は、この値を `false` に設定します。

  - **`state.enabled:`** (v2.2のデフォルトは `false` です。これはピアがオーダリングサービスからブロックを取得するために推奨されます。) ゴシップを使用して欠落したブロックを同期する場合は、この値を `true` に設定します。これにより、遅れているピアがネットワーク上の他のピアに追いつくことができます。

* **Implicit data**  Fabric v2.0では、ピア上のプライベートデータ暗黙的なコレクションの概念が導入されました。組織ごとのプライベートデータパターンを利用したい場合は、チェーンコードをFabric v2.*でデプロイするときはコレクションを定義する必要はありません。暗黙的な組織固有のコレクションは、事前の定義なしで使用できます。この新しい機能を利用する場合は、 `pvtData.implicitCollectionDisseminationPolicy.requiredPeerCount` と `pvtData.implicitCollectionDisseminationPolicy.maxPeerCount` の値を設定する必要があります。詳細は、 [Private data tutorial](../private_data_tutorial.html) をご覧ください。

  - **`pvtData.implicitCollectionDisseminationPolicy.requiredPeerCount`:** (プライベートデータの暗黙的コレクションを使用する場合は、この値を上書きすることをお勧めします。) **New in Fabric 2.0.** デフォルトは0ですが、組織に属するピアの数に基づいて増やす必要があります。この値は、トランザクションをエンドースした後にピアがダウンした場合にデータの冗長性を確保するために、データを配布する必要がある自分の組織内のピアの数を表します。

  - **`pvtData.implicitCollectionDisseminationPolicy.maxPeerCount`:** (プライベートデータの暗黙的コレクションを使用する場合は、この値を上書きすることをお勧めします。) **New in Fabric 2.0.** これは組織固有のコレクション設定で、このピアが要求をエンドースして何らかの理由でダウンした場合に、このプライベートデータが他の場所に確実に配布されことを確かめるために使用されます。 `requiredPeerCount` がデータを取得する必要があるピアの数を指定しますが、 `maxPeerCount` は試行されたピア配布の数です。デフォルトは `1` に設定されていますが、組織内に `n` 個のピアがある本番環境では、推奨設定は `n-1` です。

## peer.tls.*

```
tls:
# Require server-side TLS
enabled:  false
# Require client certificates / mutual TLS.
# Note that clients that are not configured to use a certificate will
# fail to connect to the peer.
clientAuthRequired: false
# X.509 certificate used for TLS server
cert:
    file: tls/server.crt
# Private key used for TLS server (and client if clientAuthEnabled
# is set to true
key:
    file: tls/server.key
# Trusted root certificate chain for tls.cert
rootcert:
    file: tls/ca.crt
# Set of root certificate authorities used to verify client certificates
clientRootCAs:
    files:
      - tls/ca.crt
```

ピアに対してTLSコミュニケーションを有効にするために、このセクションを設定します。TLSが有効になった後は、ピアとやりとりする全てのノードも、TLSを有効にする必要があります。ピアのTLS証明書を作成する方法の説明については、 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) にあるトピックを参照してください。

- **`enabled`:** (デフォルト値を上書きする必要があります。) 本番環境が安全であることを保証するには、設定ファイルの `tls` セクションにある `enabled: true` を設定して、すべてのノード間の通信でTLSが有効になっている必要があります。このフィールドはデフォルトでは無効にされていますが、テストのネットワークとしては受け入れられるかもしれませんが、本番では有効にする必要があります。この設定は、 **server-side TLS** を構成し、TLSが _サーバー_ のアイデンティティをクライアントへ保証し、それらに双方向の暗号化されたチャネルを提供することを意味します。

- **`cert.file`:** (デフォルト値を上書きする必要があります。) すべてのピアは、組織内の他のノードと安全にやりとりする前に、TLS CAに登録してエンロールする必要があります。そのため、ピアをデプロイする前に、まずピアのユーザーを登録し、ピアのアイデンティティをTLS CAにエンロールして、ピアのTLS署名付き証明書を生成する必要があります。 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) トピックの推奨フォルダ構造を使用している場合は、このファイルを  `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` にコピーする必要があります。

- **`key.file`:** (デフォルト値を上書きする必要があります。) `cert.file` と同様に、このピアに対して生成されたTLS秘密鍵の名前と場所を指定します。例：  `/msp/keystore/87bf5eff47d33b13d7aee81032b0e8e1e0ffc7a6571400493a7c_sk`。 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) トピックの推奨フォルダ構造を使用している場合は、このファイルを `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` にコピーする必要があります。 [HSM](#bccsp) を使用してピアの秘密鍵を格納する場合、このフィールドは空白になります。

- **`rootcert.file`:**  (デフォルト値を上書きする必要があります。) この値には、ピア組織のCAルート証明書の名前と場所が含まれています。 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) トピックの推奨フォルダ構造を使用している場合は、このファイルを `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` にコピーする必要があります。

次の2つのパラメータは、相互TLSが必須の場合にのみ指定する必要があります。

- **`clientAuthRequired`:** デフォルトは `false` です。 `true` に設定すると、 **相互TLS** を使用してセキュリティレベルを高くすることができ、クライアント側のTLS証明書の追加の検証ステップとして設定できます。サーバー側のTLSが最低限必要なセキュリティレベルであると考えられる場合、相互TLSは追加で任意のセキュリティレベルです。

- **`clientRootCAs.files`:** クライアント証明書の検証に使用できるクライアントルートCA証明書ファイルのリストを指定します。

## peer.bccsp.*

```
BCCSP:
        Default: SW
        # Settings for the SW crypto provider (i.e. when DEFAULT: SW)
        SW:
            # TODO: The default Hash and Security level needs refactoring to be
            # fully configurable. Changing these defaults requires coordination
            # SHA2 is hardcoded in several places, not only BCCSP
            Hash: SHA2
            Security: 256
            # Location of Key Store
            FileKeyStore:
                # If "", defaults to 'mspConfigPath'/keystore
                KeyStore:
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
```

(Optional) このセクションは、ブロックチェーン暗号プロバイダーを設定するために使用されます。

- **`BCCSP.Default:`** ハードウェアセキュリティモジュール(HSM)を使用する場合は、これを `PKCS11` に設定する必要があります。

- **`BCCSP.PKCS11.*:`** HSM設定に応じて、このパラメータセットを提供します。詳細については、HSMの [example]((../hsm.html) の設定を参照してください。

## chaincode.externalBuilders.*

```
# List of directories to treat as external builders and launchers for
    # chaincode. The external builder detection processing will iterate over the
    # builders in the order specified below.
    externalBuilders: []
        # - path: /path/to/directory
        #   name: descriptive-builder-name
        #   propagateEnvironment:
        #      - ENVVAR_NAME_TO_PROPAGATE_FROM_PEER
        #      - GOPROXY
```

(Optional) **New in Fabric 2.0.** このセクションは、チェーンコードビルダーが存在する一連のパスを設定するために使用します。各外部ビルダー定義には、名前(ロギングに使用)と、ビルダースクリプトを含む `bin` ディレクトリの親へのパスを含める必要があります。また、オプションで、外部ビルダースクリプトを呼び出すときに、ピアから伝播する環境変数名のリストを指定することもできます。詳細は、 [Configuring external builders and launchers](../cc_launcher.html) をご覧ください。

- **`externalBuilders.path:`** ビルダーへのパスを指定します。
- **`externalBuilders.name:`** このビルダーに名前をつけます。
- **`externalBuilders.propagateEnvironment:`** ピアに伝播する環境変数のリストを指定します。

## ledger.*

```
ledger:

  state:
    # stateDatabase - options are "goleveldb", "CouchDB"
    # goleveldb - default state database stored in goleveldb.
    # CouchDB - store state database in CouchDB
    stateDatabase: goleveldb

    couchDBConfig:
       # It is recommended to run CouchDB on the same server as the peer, and
       # not map the CouchDB container port to a server port in docker-compose.
       # Otherwise proper security must be provided on the connection between
       # CouchDB client (on the peer) and server.
       couchDBAddress: 127.0.0.1:5984

       # This username must have read and write authority on CouchDB
       username:

       # The password is recommended to pass as an environment variable
       # during start up (eg CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD).
       # If it is stored here, the file must be access control protected
       # to prevent unintended users from discovering the password.
       password:
```

このセクションは、台帳のデータベースタイプ( `goleveldb` または `CouchDB` )を選択するために使用します。エラーを回避するには、すべてのピアが同じデータベース **type** を使用する必要があります。JSONクエリが必須である場合、CouchDBが適切です。CouchDBは別のオペレーティングシステムプロセスで実行されますが、ピアノードとCouchDBインスタンスの間には依然として1:1の関係があります。つまり、各ピアは1つのデータベースを持ち、そのデータベースはそのピアにのみ関連付けられます。CouchDBの追加のJSONクエリケーパビリティ以外は、データベースの選択はスマートコントラクトには見えません。

- **`ledger.state.stateDatabase:`** (CouchDBを利用する場合は、この値を上書きします。) デフォルトはgoleveldbで、台帳の状態が単純なキーと値のペアである場合に適しています。LevelDBデータベースはピアノードプロセスに埋め込まれています。

- **`ledger.state.couchDBConfig.couchDBAddress:`** (CouchDB利用時は必須です。) CouchDBが実行しているアドレスとポートを指定します。

- **`ledger.state.couchDBConfig.username:`** (CouchDB利用時は必須です。) データベースへの読み込みおよび書き込みの権限を持つCouchDBユーザーを指定します。

- **`ledger.state.couchDBConfig.password:`** (CouchDB利用時は必須です。) データベースへの読み込みおよび書き込みの権限を持つCouchDBユーザーのパスワードを指定します。

## operations.*

```
operations:
    # host and port for the operations server
    listenAddress: 127.0.0.1:9443

    # TLS configuration for the operations endpoint
    tls:
        # TLS enabled
        enabled: false

        # path to PEM encoded server certificate for the operations server
        cert:
            file:

        # path to PEM encoded server key for the operations server
        key:
            file:

        # most operations service endpoints require client authentication when TLS
        # is enabled. clientAuthRequired requires client certificate authentication
        # at the TLS layer to access all resources.
        clientAuthRequired: false

        # paths to PEM encoded ca certificates to trust for client authentication
        clientRootCAs:
            files: []
```

運用サービスはピアのヘルス状態を監視するために使用され、通信を安全にするために相互TLSに依存しています。そのため、 `operations.tls.clientAuthRequired` を `true` に設定する必要があります。このパラメータが `true` に設定されている場合、ノードの状態を確認しようとするクライアントは、有効な認証の証明書を提供する必要があります。クライアントが証明書を提供していない場合や、サービスがクライアントの証明書を確認できない場合は、要求は拒否されます。つまり、クライアントはピアのTLS CAに登録し、そのリクエストにTLS署名証明書を提供する必要があります。詳細については [The Operations Service](../operations_service.html) を参照してください。

Prometheus [metrics](#metrics) を使用してピアを監視する場合は、この運用サービスを設定する必要があります。

あまりないことですが2つのピアが同じノードで実行されている場合は、2番目のピアのアドレスを変更して別のポートを使用する必要があります。そうでない場合、2番目のピアを開始すると、開始に失敗し、アドレスがすでに使用中であることが報告されます。

- **`operations.listenAddress:`** (運用サービスを利用する場合は必須です。) 運用サーバーのアドレスとポートを指定します。
- **`operations.tls.cert.file*:`** (運用サービスを利用する場合は必須です。) `peer.tls.cert.file` と同じファイルにすることができます。
- **`operations.tls.key.file*:`** (運用サービスを利用する場合は必須です。) `peer.tls.key.file` と同じファイルを指定できます。
- **`operations.tls.clientAuthRequired*:`** (運用サービスを利用する場合は必須です。) クライアントとサーバー間の相互TLSを有効にするために `true` に設定する必要があります。
- **`operations.tls.clientRootCAs.files*:`** (運用サービスを利用する場合は必須です。) [peer.tls.clientRootCAs.files](#tls)と同様に、クライアント証明書の検証に使用できるクライアントルートCA証明書のリストが含まれています。クライアントがピア組織のCAにエンロールされている場合、この値はピア組織ルートCA証明書です。

## metrics.*

```
metrics:
    # metrics provider is one of statsd, prometheus, or disabled
    provider: disabled
    # statsd configuration
    statsd:
        # network type: tcp or udp
        network: udp

        # statsd server address
        address: 127.0.0.1:8125
```
デフォルトではこれは無効ですが、ピアのメトリクスを監視したい場合は、メトリクスプロバイダとして `statsd` または `Prometheus` のいずれかを選ぶ必要があります。 `Statsd` は、"push"モデルを使用し、ピアから `statsd` エンドポイントにメトリクスをプッシュします。このため、運用サービス自体の設定は必要ありません。 [Available metrics for the peer](../metrics_reference.html#peer-metrics) の一覧を参照してください。

- **`provider`:** (ピアの `statsd` または `Prometheus` メトリクスで必須です。) Prometheusは"pull"モデルを使用しているため、運用サービスを利用できるようにする以上の設定は必要ありません。むしろ、Prometheusは利用可能なメトリクスをpullするために、運用URLにリクエストを送信します。
- **`address:`** ( `statsd` を使用する場合に必須です。) `statsd` が有効の場合、ピアがメトリクスの更新をプッシュできるように、statsdサーバーのホスト名とポートを設定する必要があります。

## Next steps

ピアの設定を決定したら、ピアをデプロイする準備はできています。ピアをデプロイする方法については、 [Deploy the peer](./peerdeploy.html) トピックの指示に従ってください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
