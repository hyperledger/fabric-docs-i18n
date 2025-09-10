# Create a channel using the test network

このチュートリアルとテストネットワークを使用して、チャネルジェネシスブロックを作成し、テストネットワークのピアが参加できる新しいアプリケーションチャネルを作成する方法を学びます。ordererをセットアップしたり、既存のordererからシステムチャネルを削除したりするのではなく、このチュートリアルは Fabric サンプルテストネットワークのノードを利用します。テストネットワークはオーダリングサービスとピアをデプロイしてくれるため、このチュートリアルではチャネルを作成するプロセスのみに焦点を当てます。テストネットワークには `createChannel` サブコマンドが含まれており、それを使ってチャネルを作成することができますが、このチュートリアルではそれを手動で行う方法を説明します。

Fabric v2.3では、システムチャネルを必要とせずにチャネルを作成する機能が導入され、プロセスから余分な管理レイヤが取り除かれました。このチュートリアルでは、 [configtxgen](../commands/configtxgen.html) ツールを使用してチャネルジェネシスブロックを作成し、 [osnadmin channel](../commands/osnadminchannel.html) コマンドを使用してチャネルを作成します。

**Note:**
- テストネットワークを使用しない場合は、 [how to deploy an ordering service without a system channel](create_channel_participation.html#deploy-a-new-set-of-orders) の手順に従ってください。Fabric v2.3のテストネットワークサンプルでは、シングルノードのオーダリングサービスがシステムチャネルを使わずにデプロイされます。
- システムチャネルを含むオーダリングサービス上でチャネルを作成する方法を知りたい場合は、Fabric v2.2の [Create a channel tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/create_channel/create_channel.html) を参照してください。Fabric v2.2のテストネットワークサンプルでは、シングルノードのオーダリングサービスがシステムチャネル付きで配置されています。

テストネットワークを使用してチャネルを作成するために、このチュートリアルでは以下のステップとコンセプトを説明します:
- [Prerequisites](#prerequisites)
- [Step one: Generate the genesis block of the channel](#step-one-generate-the-genesis-block-of-the-channel)
- [Step two: Create the application channel](#step-two-create-the-application-channel)
- [Next steps](#next-steps)

## Before you begin

テストネットワークを実行するには、`fabric-samples` リポジトリをクローンし、最新の製品版 Fabric イメージをダウンロードする必要があります。
また [Prerequisites](../prereqs.html) と [Installed the Samples, Binaries, and Docker Images](../install.html) がインストールされていることを確認してください。

**Note:** チャネルを作成し、そこにピアを参加させた後、サービスディスカバリとプライベートデータを動作させるために、アンカーピアをチャネルに追加する必要があります。チャネルにアンカーピアを設定する方法はこのチュートリアルに含まれていますが、 [jq tool](https://stedolan.github.io/jq/) がローカルマシンにインストールされている必要があります。

## Prerequisites

### Start the test network

新しいチャネルを作成するために、Fabricテストネットワークの実行中のインスタンスを使用します。既知の初期状態から操作することが重要であるため、以下のコマンドはアクティブなコンテナを破棄し、以前に生成されたアーティファクトを削除します。このチュートリアルでは、`fabric-samples` 内の `test-network` ディレクトリから操作します。まだそのディレクトリにいない場合は、以下のコマンドを使用してそのディレクトリに移動します:
```
cd fabric-samples/test-network
```
以下のコマンドを実行してネットワークを停止します:
```
./network.sh down
```
次に、以下のコマンドでテストネットワークを起動します:
```
./network.sh up
```
このコマンドは、2つのピア組織と単一のオーダリングノードのオーダリング組織でFabricネットワークを作成します。ピア組織はそれぞれ1つのピアを操作し、オーダリングサービス管理者は1つのオーダリングノードを操作します。コマンドを実行すると、スクリプトは作成されるノードを出力します:
```
Creating network "fabric_test" with the default driver
Creating volume "net_orderer.example.com" with default driver
Creating volume "net_peer0.org1.example.com" with default driver
Creating volume "net_peer0.org2.example.com" with default driver
Creating peer0.org2.example.com ... done
Creating orderer.example.com    ... done
Creating peer0.org1.example.com ... done
Creating cli                    ... done
CONTAINER ID   IMAGE                               COMMAND             CREATED         STATUS                  PORTS                                            NAMES
1667543b5634   hyperledger/fabric-tools:latest     "/bin/bash"         1 second ago    Up Less than a second                                                    cli
b6b117c81c7f   hyperledger/fabric-peer:latest      "peer node start"   2 seconds ago   Up 1 second             0.0.0.0:7051->7051/tcp                           peer0.org1.example.com
703ead770e05   hyperledger/fabric-orderer:latest   "orderer"           2 seconds ago   Up Less than a second   0.0.0.0:7050->7050/tcp, 0.0.0.0:7053->7053/tcp   orderer.example.com
718d43f5f312   hyperledger/fabric-peer:latest      "peer node start"   2 seconds ago   Up 1 second             7051/tcp, 0.0.0.0:9051->9051/tcp                 peer0.org2.example.com
```

ピアはポート `7051` と `9051` で動作しており、ordererはポート `7050` で動作しています。以降のコマンドではこれらのポートを使用します。

デフォルトでは、テストネットワークを開始したとき、そのネットワークにはチャネルが含まれていません。次の手順では、`channel1`という名前のチャネルをこのネットワークに追加する方法を示します。

### Set up the configtxgen tool

チャネルは、ジェネシスブロックでチャネル作成トランザクションを生成し、そのジェネシスブロックをjoinリクエストでオーダリングサービスノードに渡すことで作成されます。チャネル作成トランザクションはチャネルの初期設定を指定し、 [configtxgen](../commands/configtxgen.html) ツールで作成できます。このツールはチャネルの設定を定義する `configtx.yaml` ファイルを読み込み、関連する情報をチャネル作成トランザクションに書き込み、チャネル作成トランザクションを含むジェネシスブロックを出力します。[install Fabric](../install.html) を実行すると、`fabric-samples\bin`ディレクトリに `configtxgen` ツールがインストールされます。

`fabric-samples` のローカルクローンの `test-network` ディレクトリから操作していることを確認し、次のコマンドを実行します:

```
export PATH=${PWD}/../bin:$PATH
```

次に、`configtxgen` を使用する前に、`FABRIC_CFG_PATH` 環境変数に `configtx.yaml` ファイルを含むテストネットワークフォルダの場所を設定する必要があります。ここではテストネットワークを使うので、`configtx` フォルダを参照します:
```
export FABRIC_CFG_PATH=${PWD}/configtx
```

ここで、`configtxgen` のヘルプテキストを表示して、ツールを使用できることを確認してください:
```
configtxgen --help
```

### The configtx.yaml file

テストネットワークでは、`configtxgen` ツールは `configtx\configtx.yaml` ファイルで定義されたチャネルプロファイルを使用してチャネル設定を作成し、Fabric が参照可能な [protobuf format](https://developers.google.com/protocol-buffers) に書き込みます。

この `configtx.yaml` ファイルには、新しいチャネルを作成するために使用する以下の情報が含まれています:

- **Organizations:** チャネルのメンバとなることができるピア組織とオーダリング組織。各組織は [channel MSP](../membership/membership.html) を構築するために使用される暗号マテリアルへの参照情報を持ちます。
- **Ordering service:** どのオーダリングノードがネットワークのオーダリングサービスを形成し、共通の取引順序に合意するためにどのようなコンセンサス方法を用いるか。また、このセクションでは、オーダリングサービスの同意者セットの一部であるオーダリングノードを定義します。テストネットワークのサンプルでは、オーダリングノードは1つだけですが、本番ネットワークでは、2つのオーダリングノードがダウンしてもコンセンサスを維持できるように、**5つ**のオーダリングノードを推奨します。
    ```
    EtcdRaft:
        Consenters:
        - Host: orderer.example.com
          Port: 7050
          ClientTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
          ServerTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
    ```
- **Channel policies** ファイルのさまざまなセクションが連携して、組織がチャネルとどのようにやり取りするか、またどの組織がチャネルの更新を承認する必要があるかを管理するポリシーを定義します。このチュートリアルでは、Fabricで使用されているデフォルトのポリシーを使用します。
- **Channel profiles** 各チャネルプロファイルは `configtx.yaml` ファイルの他のセクションの情報を参照し、チャネル構成を構築します。プロファイルはアプリケーションチャネルのジェネシスブロックを作成するために使用されます。テストネットワークの `configtx.yaml` ファイルには、チャネルトランザクションの生成に使用する `TwoOrgsApplicationGenesis` という名前のプロファイルが1つ含まれています。
    ```yaml
    TwoOrgsApplicationGenesis:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *OrdererOrg
            Capabilities: *OrdererCapabilities
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Org1
                - *Org2
            Capabilities: *ApplicationCapabilities
    ```

このプロファイルには、`Org1` と `Org2` の2つのピア組織と、`OrdererOrg` というオーダリング組織が含まれます。追加のオーダリングノードとオーダリング組織は、チャネルの更新トランザクションを使用して、後で同意者セットに追加または削除することができます。

このファイルの詳細と、独自のチャネルアプリケーションプロファイルを作成する方法について知りたいですか? 詳しくは [Using configtx.yaml to create a channel genesis block](create_channel_config.html) チュートリアルを参照してください。今後のステップでこのファイルの一部を参照することになるでしょうが、とりあえず、チャネルを作成する運用の側面に戻ることにします。

## Step one: Generate the genesis block of the channel

Fabricテストネットワークを開始したので、新しいチャネルを作成する準備ができました。すでに `configtxgen` ツールを使うために必要な環境変数は設定されています。   

以下のコマンドを実行して `channel1` のチャネルジェネシスブロックを作成します:
```
configtxgen -profile TwoOrgsApplicationGenesis -outputBlock ./channel-artifacts/channel1.block -channelID channel1
```

- **`-profile`**: このコマンドは、テストネットワークがアプリケーションチャネルを作成するために使用する `configtx.yaml` ファイル内の `TwoOrgsApplicationGenesis:` プロファイルを参照するために `-profile` フラグを使用します。
- **`-outputBlock`**: このコマンドの出力は `-outputBlock ./channel-artifacts/channel1.block` に書き込まれるチャネルジェネシスブロックです。
- **`-channelID`**: `-channelID` パラメーターは、将来作成されるチャネルの名前になります。チャネルには任意の名前を指定できますが、このチュートリアルでは説明のため `channel1` を使用します。チャネル名はすべて小文字かつ250文字未満で、正規表現 ``[a-z][a-z0-9.-]*`` に一致する必要があります。

コマンドが成功すると、`configtxgen` が `configtx.yaml` ファイルをロードし、チャネル作成トランザクションを出力したログを見ることができます:
```
[common.tools.configtxgen] main -> INFO 001 Loading configuration
[common.tools.configtxgen.localconfig] completeInitialization -> INFO 002 orderer type: etcdraft
[common.tools.configtxgen.localconfig] completeInitialization -> INFO 003 Orderer.EtcdRaft.Options unset, setting to tick_interval:"500ms" election_tick:10 heartbeat_tick:1 max_inflight_blocks:5 snapshot_interval_size:16777216
[common.tools.configtxgen.localconfig] Load -> INFO 004 Loaded configuration: /Users/fabric-samples/test-network/configtx/configtx.yaml
[common.tools.configtxgen] doOutputBlock -> INFO 005 Generating genesis block
[common.tools.configtxgen] doOutputBlock -> INFO 006 Creating application channel genesis block
[common.tools.configtxgen] doOutputBlock -> INFO 007 Writing genesis block
```

## Step two: Create the application channel

これでチャネルのジェネシスブロックができたので、`osnadmin channel join` コマンドを使って簡単にチャネルを作成できます。後続のコマンドを簡単にするために、テストネットワーク内のノードの証明書の場所を設定するための環境変数もいくつか設定しておく必要があります:

```
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key
```

以下のコマンドを実行して、 `channel1` という名前のチャネルをオーダリングサービスに作成します。
```
osnadmin channel join --channelID channel1 --config-block ./channel-artifacts/channel1.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
```

- **`--channelID`**: チャネルジェネシスブロックの作成時に指定したアプリケーションチャネル名を指定します。
- **`--config-block`**: `configtxgen` コマンドで作成したチャネルジェネシスブロック、または最新のコンフィギュレーションブロックの場所を指定します。
- **`-o`**: orderer admin エンドポイントのホスト名とポートを指定します。テストネットワークのオーダリングノードは、`localhost:7053` に設定されています。

さらに、`osnadmin channel` コマンドは相互TLSを使用してオーダリングノードと通信するため、以下の証明書を提供する必要があります:
- **`--ca-file`**: オーダリング組織のTLS CAルート証明書の場所とファイル名を指定します。
- **`--client-cert`**: TLS CAからの管理者クライアント署名付き証明書の場所とファイル名を指定すします。
- **`--client-key`**: TLS CAからの管理者クライアント秘密鍵の場所とファイル名を指定します。

成功すると、コマンドの出力は以下のようになります:
```
Status: 201
{
	"name": "channel1",
	"url": "/participation/v1/channels/channel1",
	"consensusRelation": "consenter",
	"status": "active",
	"height": 1
}
```

チャネルがアクティブになり、ピアが参加できるようになりました。

### Consenter vs. Follower

オーダリングノードが `consensusRelation: "consenter"` を用いてチャネルに参加していることに注意してください。もし `configtx.yaml` ファイルの `Consenters:` のリスト (またはチャネル設定の consenter セット) に含まれていないオーダリングノードに対してコマンドを実行した場合、そのオーダリングノードは `follower` としてチャネルに追加されます。追加オーダリングノードを参加させる際の注意点については、 [Joining additional ordering nodes](create_channel_participation.html#step-three-join-additional-ordering-nodes) を参照してください。

### Active vs. onboarding

orderer はチャネルの **ジェネシスブロック** または **最新のコンフィギュレーションブロック** を提供することでチャネルに参加できます。最新のコンフィギュレーションブロックから参加した場合、チャネル台帳が指定したコンフィギュレーションブロックに追いつくまで、 orderer のステータスは `onboarding` に設定されます。この時点でチャネルの更新トランザクションを送信することで、 orderer をチャネルの同意者セットに追加することができ、 `consensusRelation` が `follower` から `consenter` に変更されます。

## Next steps

チャネルを作成したら、次のステップではチャネルにピアを参加させ、スマートコントラクトをデプロイします。このセクションでは、テストネットワークを使ってこれらのプロセスを説明します。

### List channels on an orderer

ピアをチャネルに参加させる前に、追加のチャネルを作成してみるとよいでしょう。さらにチャネルを作成すると、 `osnadmin channel list` コマンドはそのordererが所属しているチャネルを表示するのに便利です。ここでは、前ステップの `osnadmin channel join` コマンドと同じパラメータを使用します:
```
osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
```
このコマンドの出力は以下のようになります:

```
Status: 200
{
	"systemChannel": null,
	"channels": [
		{
			"name": "channel1",
			"url": "/participation/v1/channels/channel1"
		}
	]
}
```

### Join peers to the channel

テストネットワークには、それぞれ1つのピアを持つ2つのピア組織が含まれています。しかし、ピアCLIを使用する前に、どのユーザー(クライアントMSP)として行動し、どのピアをターゲットにしているかを指定するために、いくつかの環境変数を設定する必要があります。以下の環境変数設定は、Org1管理者として振る舞い、Org1ピアをターゲットにしていることを示します。

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

ピアCLIを使うためには、 `FABRIC_CONFIG_PATH` も変更する必要があります:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
`Org1` からチャネル `channel1` にテストネットワーク上のピアを参加させるには、参加リクエストでジェネシスブロックを渡すだけで大丈夫です:
```
peer channel join -b ./channel-artifacts/channel1.block
```
成功すると、このコマンドの出力は以下のようになります:
```
[channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
[channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

この手順を `Org2` ピアでも繰り返します。以下の環境変数を設定して、`Org2` の管理者として `peer` CLI を操作できるようにします。この環境変数は `Org2` のピア ``peer0.org2.example.com`` をターゲットピアとして設定します。
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```
次に、`Org2` から `channel1` に参加するためにコマンドを繰り返します:
```
peer channel join -b ./channel-artifacts/channel1.block
```
成功すると、このコマンドの出力は次のようになります:
```
[channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
[channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

## Set anchor peer

最後に、組織がピアをチャネルに参加させた後、それらのピアの中からアンカーピアとなるピアを**少なくとも1つ**選択する必要があります。 [Anchor peers](../gossip.html#anchor-peers) は、プライベートデータやサービスディスカバリーなどの機能を利用するために必要です。各組織は、冗長性のためにチャネル上に複数のアンカーピアを設定するべきです。ゴシップとアンカーピアの詳細については、 [Gossip data dissemination protocol](../gossip.html) を参照してください。

各組織のアンカーピアのエンドポイント情報はチャネル設定に含まれます。各チャネルのメンバは、チャネルを更新することでアンカーピアを指定できます。ここでは、 [configtxlator](../commands/configtxlator.html) ツールを使ってチャネルの設定を更新し、`Org1` と `Org2` のアンカーピアを選択します。

**Note:** [jq](https://stedolan.github.io/jq/) がまだローカルマシンにインストールされていない場合は、この手順を完了するために今すぐインストールする必要があります。

まず、 `Org1` からアンカーピアとなるピアを選択します。最初のステップでは、`peer channel fetch` コマンドを使用して、最新のチャネルコンフィギュレーションブロックを取得します。`Org1` の管理者として `peer` CLI を操作するために、以下の環境変数を設定します:
```
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

以下のコマンドでチャネル設定を取得できます:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile "$ORDERER_CA"
```
最新のチャネルコンフィギュレーションブロックはチャネルジェネシスブロックなので、コマンドはチャネルからブロック `0` を受け取ります。
```
[channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
[cli.common] readBlock -> INFO 002 Received block: 0
[channelCmd] fetch -> INFO 003 Retrieving last config block: 0
[cli.common] readBlock -> INFO 004 Received block: 0
```

チャネルコンフィギュレーションブロック `config_block.pb` は、更新プロセスを他のアーティファクトから分離するために、`channel-artifacts` フォルダーに格納されています。次のステップを実行するには、`channel-artifacts` フォルダに移動します:
```
cd channel-artifacts
```
これで `configtxlator` ツールを使ってチャネル設定の作業を開始できます。最初のステップは、protobufからブロックを読み込んで、編集可能なJSONオブジェクトにデコードすることです。同時に不要なブロックデータを取り除き、チャネル設定だけを残します。

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
```

これらのコマンドは、チャネルコンフィギュレーションブロックを、アップデートのベースラインとなる簡素化されたJSON、`config.json`に変換します。このファイルを直接編集したくないので、編集可能なコピーを作成します。後のステップでは、オリジナルのチャネル設定を使用します。
```
cp config.json config_copy.json
```

`jq` ツールを使って `Org1` アンカーピアをチャネル設定に追加します。
```
jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' config_copy.json > modified_config.json
```

このステップの後、更新されたJSONフォーマットのチャネル設定が `modified_config.json` ファイルに格納されます。これで、元のチャネル設定と変更後のチャネル設定の両方を protobuf フォーマットに変換して、その差分を計算できるようになりました。
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

`config_update.pb` という新しいprotobufは、チャネル構成に適用する必要のあるアンカーピアのアップデートを含んでいます。チャネル構成更新トランザクションを作成するために、トランザクションエンベロープで構成更新をラップします。

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

これで、チャネルを更新するための最終成果物である `config_update_in_envelope.pb` が使えるようになりました。 `test-network` ディレクトリに戻ります:
```
cd ..
```

新しいチャネル設定を `peer channel update` コマンドに渡すことで、アンカーピアを追加できます。ここでは `Org1` にのみ影響するチャネル設定の一部を更新するので、他のチャネルメンバはチャネルの更新を承認する必要はありません。
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

チャネルの更新が成功すると、以下のような応答が表示されるはずです:
```
[channelCmd] update -> INFO 002 Successfully submitted channel update
```

`Org2` のピアをアンカーピアに設定することもできます。2回目の手順を行うので、もう少し手短に説明します。 `Org2` の管理者として `peer` CLI を操作するための環境変数を設定します:
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

最新のチャネルコンフィギュレーションブロックを取得します。これは現在、チャネルの2番目のブロックです:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

`channel-artifacts`ディレクトリに戻ります:
```
cd channel-artifacts
```

その後、コンフィギュレーションブロックをデコードしてコピーします。
```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json
```

チャネルに参加している `Org2` ピアを、チャネル設定のアンカーピアとして追加します:
```
jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' config_copy.json > modified_config.json
```

これで、元のチャネル構成と更新されたチャネル構成の両方をprotobufフォーマットに戻し、その差を計算することができます。
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

チャネル構成更新トランザクションを作成するために、トランザクションエンベロープで構成更新をラップします:
```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

`test-network`ディレクトリに戻ります。
```
cd ..
```

以下のコマンドを実行してチャネルを更新し、 `Org2` アンカーピアを設定します:
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

チャネル更新リクエストの送信方法について詳しく知りたい場合は、 [update a channel configuration](../config_update.html) を参照してください。

`peer channel info` コマンドを実行することで、チャネルが正常に更新されたことを確認できます:
```
peer channel getinfo -c channel1
```
チャネルのジェネシスブロックに2つのチャネルコンフィギュレーションブロックを追加することでチャネルが更新され、チャネルの高さが3つになり、ハッシュも更新されました:
```
Blockchain info: {"height":3,"currentBlockHash":"GKqqk/HNi9x/6YPnaIUpMBlb0Ew6ovUnSB5MEF7Y5Pc=","previousBlockHash":"cl4TOQpZ30+d17OF5YOkX/mtMjJpUXiJmtw8+sON8a8="}
```

## Deploy a chaincode to the new channel

チャネルにチェーンコードをデプロイすることで、チャネルが正常に作成されたことを確認できます。 `network.sh` スクリプトを使って、Basic asset transfer チェーンコードを任意のテストネットワークチャネルにデプロイすることができます。以下のコマンドを使用して、新しいチャネルにチェーンコードをデプロイします:
```
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go/ -ccl go -c channel1
```

コマンドを実行すると、チャネルにチェーンコードがデプロイされたことがログに表示されるはずです。

```
Committed chaincode definition for chaincode 'basic' on channel 'channel1':
Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
Query chaincode definition successful on peer0.org2 on channel 'channel1'
Chaincode initialization is not required
```
次に以下のコマンドを実行して、台帳上のいくつかの資産を初期化します:
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "$ORDERER_CA" -C channel1 -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```
成功すると以下のメッセージが表示されます:
```
[chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
```

以下のクエリを発行して、資産が台帳に追加されたことを確認します:

```
peer chaincode query -C channel1 -n basic -c '{"Args":["getAllAssets"]}'
```

以下のようなメッセージが表示されるはずです:
```
[{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300},
{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400},
{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500},
{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600},
{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700},
{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}]
```

### Create a channel without the test network

このチュートリアルでは、`osnadmin channel join` コマンドを使ってテストネットワーク上にチャネルを作成する基本的な手順を説明しました。自分のネットワークを構築する準備ができたら、[Create a channel](create_channel_participation.html) チュートリアルの手順に従って `osnadmin channel` コマンドの使い方を学んでください。
<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
