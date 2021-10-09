# Creating a new channel

このチュートリアルでは、[configtxgen](../commands/configtxgen.html) CLIツールを使用して新しいチャネルを作成し、[peer channel](../commands/peerchannel.html)コマンドを使用してピアをチャネルに参加させる方法を学習できます。このチュートリアルでは、Fabricテストネットワークを利用して新しいチャネルを作成しますが、このチュートリアルの手順は、本番環境のネットワークオペレータも使用できます。

チャネル作成の過程で、このチュートリアルでは次の手順と概念について説明します:

- [Setting up the configtxgen tool](#setting-up-the-configtxgen-tool)
- [Using the configtx.yaml file](#the-configtx-yaml-file)
- [The orderer system channel](#the-orderer-system-channel)
- [Creating an application channel](#creating-an-application-channel)
- [Joining peers to the channel](#join-peers-to-the-channel)
- [Setting anchor peers](#set-anchor-peers)


## Before you begin

**重要:**このチュートリアルでは、Fabricテストネットワークを使用し、テストネットワークサンプルのv2.2.x以下と互換性があります。[前提条件](../getting_started.html)をインストールした後、必要なバージョンの[hyperledger/fabric samples](https://github.com/hyperledger/fabric-samples)リポジトリのクローンを作成し、正しいバージョンタグをチェックアウトするために、**次のコマンドを実行する必要があります。**。このコマンドは、Hyperledger Fabricプラットフォーム固有のバイナリと該当のバージョンの設定ファイルを`fabric-samples`の`/bin`および`/config`ディレクトリにインストールし、テストネットワークを実行できるようにします。

```
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.2 1.4.9
```

## Setting up the configtxgen tool

チャネルは、チャネル作成トランザクションを作成し、そのトランザクションをオーダリングサービスに発行することによって作成されます。チャネル作成トランザクションは、チャネルの初期構成を指定し、オーダリングサービスがチャネルのジェネシスブロックを書き込むために使用します。チャネル作成トランザクションファイルを手動で作成することは可能ですが、[configtxgen](../commands/configtxgen.html)ツールを使用する方が簡単です。このツールは、チャネルの構成を定義する`configtx.yaml`ファイルを読み取り、関連情報をチャネル作成トランザクションに書き込むことによって機能します。`configtxgen`ツールは前のステップで`curl`コマンドを実行したときにインストールされました。

このチュートリアルでは、`fabric-samples`内の`test-network`ディレクトリから操作します。次のコマンドを使用して、そのディレクトリに移動します:
```
cd fabric-samples/test-network
```
これ以降のチュートリアルでは、`test-network`ディレクトリから操作します。次のコマンドを使用して、configtxgenツールをCLIパスに追加します:
```
export PATH=${PWD}/../bin:$PATH
```

`configtxgen`を使用するには、`FABRIC_CFG_PATH`環境変数を`configtx.yaml`ファイルのローカルコピーが格納されているディレクトリのパスに設定する必要があります。このチュートリアルでは、`configtx`フォルダ内のFabricテストネットワークの設定に使用される`configtx.yaml`を参照します:
```
export FABRIC_CFG_PATH=${PWD}/configtx
```

`configtxgen`のヘルプテキストを表示することで、このツールを使用できることを確認できます:
```
configtxgen --help
```


## The configtx.yaml file

``configtx.yaml``ファイルは、新規チャネルの**チャネル構成**を指定します。チャネル構成の構築に必要な情報は、`configtx.yaml`ファイル内読取りおよび編集可能な形式で指定されます。`configtxgen`ツールは、`configtx.yaml`ファイルで定義されたチャネルプロファイルを使用してチャネル構成を作成し、Fabricで読取り可能な[protobuf形式](https://developers.google.com/protocol-buffers)に書き込みます.

テストネットワークのデプロイに使用される`configtx.yaml`ファイルは、`test-network`ディレクトリの`configtx`フォルダにあります。このファイルには、新規チャネルの作成に使用する次の情報が含まれています:

- **組織:** チャネルのメンバーになることができる組織。各組織には、[チャネルMSP](../membership/membership.html)の構築に使用される暗号関連ファイルへの参照があります。
- **オーダリングサービス:**ネットワークのオーダリングサービスを形成するオーダリングノードと、共通のトランザクション順について同意とるために使用する合意方法。このファイルには、オーダリングサービス管理者になる組織も含まれています。 ネットワークのオーダリングサービスを形成するオーダリングノードと、共通のトランザクション順について同意とるために使用する合意方法。このファイルには、オーダリングサービス管理者になる組織も含まれています。
- **チャネルポリシー:** ファイルのさまざまなセクションが連携して、組織とチャネルとの相互作用方法およびチャネルの更新を承認する必要がある組織を規定するポリシーを定義します。このチュートリアルでは、Fabricで使用されるデフォルトのポリシーを使用します。
- **チャネルプロファイル:** 各チャネルプロファイルは、`configtx.yaml`ファイルの他のセクションの情報を参照してチャネル構成を構築します。プロファイルは、ordererシステムチャネルのジェネシスブロックの作成およびピア組織によって使用されるチャネルに使用されます。システムチャネルと区別するために、ピア組織によって使用されるチャネルは、アプリケーションチャネルと呼ばれることがあります。

  `configtxgen`ツールは、`configtx.yaml`ファイルを使用して、システムチャネルの完全なジェネシスブロックを作成します。その結果、システムチャネルプロファイルでは、完全なシステムチャネル構成を指定する必要があります。チャネル作成トランザクションの作成に使用されるチャネルプロファイルには、アプリケーションチャネルの作成に必要な追加構成情報のみを含める必要があります。

このファイルの詳細については、[Using configtx.yaml to build a channel configuration](create_channel_config.html)チュートリアルを参照してください。ここからは、チャネル作成の操作方法に関する説明に話を戻します。ただし、このファイルの一部は今後の手順で参照します。

## Start the network

Fabricテストネットワークの実行中のインスタンスを使用して、新しいチャネルを作成します。このチュートリアルでは、既知の初期状態から操作をしたいと思います。次のコマンドを使用すると、アクティブなコンテナが強制終了され、以前に生成されたファイルが削除されます。`fabric-samples`のローカルクローンの`test-network`ディレクトリから操作していることを確認してください。
```
./network.sh down
```
次のコマンドを使用して、テストネットワークを起動できます:
```
./network.sh up
```
このコマンドは、`configtx.yaml`ファイルで定義された2つのピア組織と単一のオーダリング組織を使用して、Fabricネットワークを作成します。ピア組織はそれぞれ1つのピアを操作し、オーダリングサービス管理者は単一のオーダリングノードを操作します。コマンドを実行すると、作成中のノードのログが出力されます:
```
Creating network "net_test" with the default driver
Creating volume "net_orderer.example.com" with default driver
Creating volume "net_peer0.org1.example.com" with default driver
Creating volume "net_peer0.org2.example.com" with default driver
Creating orderer.example.com    ... done
Creating peer0.org2.example.com ... done
Creating peer0.org1.example.com ... done
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS                  PORTS                              NAMES
8d0c74b9d6af        hyperledger/fabric-orderer:latest   "orderer"           4 seconds ago       Up Less than a second   0.0.0.0:7050->7050/tcp             orderer.example.com
ea1cf82b5b99        hyperledger/fabric-peer:latest      "peer node start"   4 seconds ago       Up Less than a second   0.0.0.0:7051->7051/tcp             peer0.org1.example.com
cd8d9b23cb56        hyperledger/fabric-peer:latest      "peer node start"   4 seconds ago       Up 1 second             7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
```

テストネットワークのインスタンスは、アプリケーションチャネルを作成せずに配置されました。ただし、テストネットワークスクリプトは、`./network.sh up`コマンドを発行するとシステムチャネルを作成します。このスクリプトの内部では、`configtxgen`ツールと`configtx.yaml`ファイルを使用して、システムチャネルのジェネシスブロックが作成されます。システムチャネルは他のチャネルの作成に使用されるため、アプリケーションチャネルを作成する前に、Ordererのシステムチャネルを理解するために時間が必要です。

## The orderer system channel

Fabricネットワークで最初に作成されるチャネルは、システムチャネルです。システムチャネルは、オーダリングサービスを形成する一連のオーダリングノードと、オーダリングサービス管理者として機能する一連の組織を定義します。

システムチャネルには、ブロックチェーン[コンソーシアム](../glossary.html#consortium)のメンバーである組織も含まれます。コンソーシアムは、システムチャネルに属しているが、オーダリングサービスの管理者ではないピア組織のセットです。コンソーシアムメンバーは、新規チャネルを作成し、他のコンソーシアム組織をチャネルメンバーとして含めることができます。

システムチャネルのジェネシスブロックは、新規のオーダリングサービスを展開するために必要です。テストネットワークスクリプトは、`./network.sh up`コマンドを発行したときにすでにシステムチャネルジェネシスブロックを作成しています。ジェネシスブロックは、単一のオーダリングノードを展開するために使用されました。このノードは、ブロックを使用してシステムチャネルを作成し、ネットワークのオーダリングサービスを形成しました。`./network.sh`スクリプトの出力を調べると、ジェネシスブロックを作成したコマンドがログに記録されています。
```
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
```

`configtxgen`ツールは、`configtx.yaml`の`TwoOrgsOrdererGenesis`チャネルプロファイルを使用して、ジェネシスブロックを書き込み、`system-genesis-block`フォルダに格納しました。`TwoOrgsOrdererGenesis`プロファイルは次の通りです:
```yaml
TwoOrgsOrdererGenesis:
    <<: *ChannelDefaults
    Orderer:
        <<: *OrdererDefaults
        Organizations:
            - *OrdererOrg
        Capabilities:
            <<: *OrdererCapabilities
    Consortiums:
        SampleConsortium:
            Organizations:
                - *Org1
                - *Org2
```

プロファイルの`Orderer:`セクションでは、テストネットワークで使用される単一ノードのRaftオーダリングサービスが作成され、オーダリングサービス管理者は`OrdererOrg`になります。プロファイルの`Consortiums`セクションでは、`SampleConsortium:`という名称のピア組織のコンソーシアムが作成されます。両方のピア組織(Org1およびOrg2)はコンソーシアムのメンバーです。その結果、テストネットワークによって作成された新規チャネルに両方の組織を含めることができます。別の組織をコンソーシアムに追加せずにチャネルメンバーとして追加したい場合は、最初にOrg1およびOrg2を使用してチャネルを作成し、次に[チャネル構成を更新すること](../channel_update_tutorial.html)によって他の組織を追加する必要があります。


## Creating an application channel

これで、ネットワークのノードをデプロイし、`network.sh`スクリプトを使用してordererシステムチャネルを作成したので、ピア組織用の新しいチャネルの作成プロセスを開始できます。`configtxgen`ツールの使用に必要な環境変数はすでに設定されています。次のコマンドを実行して、`channel1`のチャネル作成トランザクションを作成します:
```
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel1.tx -channelID channel1
```

`-channelID`は、将来のチャネルの名前になります。チャネル名はすべて小文字で、250文字未満で、正規表現``[a-z][a-z0-9.-]*``と一致する必要があります。このコマンドは、`-profile`フラグを使用して`configtx.yaml`から`TwoOrgsChannel:`プロファイルを参照します。このプロファイルは、アプリケーションチャネルを作成するためにテストネットワークによって使用されます:
```yaml
TwoOrgsChannel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
        <<: *ApplicationDefaults
        Organizations:
            - *Org1
            - *Org2
        Capabilities:
            <<: *ApplicationCapabilities
```

プロファイルでは、システムチャネルの`SampleConsortium`名が参照され、チャネルメンバーとしてコンソーシアムの両方のピア組織が含まれます。システムチャネルはアプリケーションチャネルを作成するためのテンプレートとして使用されるため、システムチャネルで定義されたオーダリングノードは新規チャネルのデフォルトの同意者セットになり、オーダリングサービスの管理者はチャネルのOrderer管理者になります。オーダリングノードおよびオーダリング組織は、チャネルの更新を使用して[同意者セット](../glossary.html#consenter-set)に追加または削除できます。

コマンドが成功した場合は、`configtx.yaml`ファイルをロードしてチャネル作成トランザクションを出力する`configtxgen`のログが表示されます:
```
2020-03-11 16:37:12.695 EDT [common.tools.configtxgen] main -> INFO 001 Loading configuration
2020-03-11 16:37:12.738 EDT [common.tools.configtxgen.localconfig] Load -> INFO 002 Loaded configuration: /Usrs/fabric-samples/test-network/configtx/configtx.yaml
2020-03-11 16:37:12.740 EDT [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 003 Generating new channel configtx
2020-03-11 16:37:12.789 EDT [common.tools.configtxgen] doOutputChannelCreateTx -> INFO 004 Writing new channel tx
```

`peer` CLIを使用して、チャネル作成トランザクションをオーダリングサービスに送信できます。`peer` CLIを使用するには、`fabric-samples/config`ディレクトリにある`core.yaml`ファイルに`FABRIC_CFG_PATH`を設定する必要があります。次のコマンドを実行して、`FABRIC_CFG_PATH`環境変数を設定します:
```
export FABRIC_CFG_PATH=$PWD/../config/
```

オーダリングサービスは、チャネルを作成する前に、リクエストを送信したアイデンティティの許可をチェックします。デフォルトでは、システムチャネルコンソーシアムに属する組織の管理者アイデンティティのみが新規チャネルを作成できます。次のコマンドを発行して、`peer` CLIをOrg1の管理者ユーザーとして操作します:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

次のコマンドを使用してチャネルを作成できるようになりました:
```
peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel1 -f ./channel-artifacts/channel1.tx --outputBlock ./channel-artifacts/channel1.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

上記のコマンドは、`-f`フラグを使用してチャネル作成トランザクションファイルへのパスを提供し、`-c`フラグを使用してチャネル名を指定します。`-o`フラグは、チャネルの作成に使用されるオーダリングノードを選択するために使用されます。`--cafile`は、オーダリングノードのTLS証明書へのパスです。`peer channel create`コマンドを実行すると、`peer` CLIは次の応答を生成します:
```
2020-03-06 17:33:49.322 EST [channelCmd] InitCmdFactory -> INFO 00b Endorser and orderer connections initialized
2020-03-06 17:33:49.550 EST [cli.common] readBlock -> INFO 00c Received block: 0
```
Raftオーダリングサービスを使用しているため、安全に無視できるステータス使用不可メッセージが表示される場合があります。このコマンドは、新しいチャネルのジェネシスブロックを`--outputBlock`フラグで指定された場所に戻します。

## Join peers to the channel

チャネルが作成された後、ピアがチャネルに参加できます。チャネルのメンバーである組織は、[peer channel fetch](../commands/peerchannel.html#peer-channel-fetch)コマンドを使用して、チャネルジェネシスブロックをオーダリングサービスからフェッチできます。組織は、次に、ジェネシスブロックを使用して、[peer channel join](../commands/peerchannel.html#peer-channel-join)コマンドを使用してピアをチャネルに結合できます。ピアがチャネルに結合されると、ピアは、オーダリングサービスからチャネル上の他のブロックを取得して、ブロックチェーン台帳を作成します。

すでに`peer` CLIをOrg1管理者として操作しているので、Org1ピアをチャネルに参加させます。Org1がチャネル作成トランザクションを発行したので、ファイルシステムにはすでにチャネルジェネシスブロックがあります。次のコマンドを使用して、Org1ピアをチャネルに参加させます。
```
peer channel join -b ./channel-artifacts/channel1.block
```

`CORE_PEER_ADDRESS`環境変数がターゲット`peer0.org1.example.com`に設定されています。コマンドが正常に実行されると、チャネルに参加する`peer0.org1.example.com`からの応答が生成されます:
```
2020-03-06 17:49:09.903 EST [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-03-06 17:49:10.060 EST [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

peer channel getinfoコマンドを使用して、ピアがチャネルに[peer channel getinfo](../commands/peerchannel.html#peer-channel-getinfo)コマンドを使用します:
```
peer channel getinfo -c channel1
```
このコマンドは、チャネルのブロック高さと最新のブロックのハッシュを一覧表示します。ジェネシスブロックはチャネル上の唯一のブロックであるため、チャネルの高さは1になります:
```
2020-03-13 10:50:06.978 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
Blockchain info: {"height":1,"currentBlockHash":"kvtQYYEL2tz0kDCNttPFNC4e6HVUFOGMTIDxZ+DeNQM="}
```

これで、Org2ピアをチャネルに参加させることができます。次の環境変数を設定して、`peer` CLIをOrg2管理者として動作させます。環境変数により、Org2ピアである``peer0.org2.example.com``もターゲットピアとして設定されます。
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

ファイルシステム上にまだチャネルジェネシスブロックがありますが、より現実的なシナリオでは、Org2は注文サービスからブロックをフェッチします。例として、`peer channel fetch`コマンドを使用して、Org2のジェネシスブロックを取得します:
```
peer channel fetch 0 ./channel-artifacts/channel_org2.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

このコマンドは`0`を使用して、チャネルの結合に必要なジェネシスブロックをフェッチする必要があることを指定します。コマンドが正常に実行されると、次のような出力が表示されます:
```
2020-03-13 11:32:06.309 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-03-13 11:32:06.336 EDT [cli.common] readBlock -> INFO 002 Received block: 0
```

このコマンドは、チャネルジェネシスブロックを戻し、`channel_Org2.block`という名前を付けて、org1によってプルされたブロックと区別します。このブロックを使用して、Org2ピアをチャネルに参加させることができます:
```
peer channel join -b ./channel-artifacts/channel_org2.block
```

## Set anchor peers

組織がピアをチャネルに参加させた後、少なくとも1つのピアを選択してアンカーピアにする必要があります。[アンカーピア](../gossip.html#anchor-peers)は、プライベートデータやサービスディスカバリなどの機能を利用するために必要です。各組織は、冗長性を確保するために1つのチャネルに複数のアンカーピアを設定する必要があります。ゴシップおよびアンカーピアの詳細は、[ゴシップデータ配布プロトコル](../gossip.html)を参照してください。

各組織のアンカーピアのエンドポイント情報は、チャネル構成に含まれます。各チャネルメンバーは、チャネルを更新することでアンカーピアを指定できます。チャネル構成を更新し、Org1およびOrg2のアンカーピアを選択するには、[configtxlator](../commands/configtxlator.html)ツールを使用します。アンカーピアを設定するプロセスは、他のチャネルの更新に必要なステップと類似しており、`configtxlator`を使用して[チャネル構成を更新する](../config_update.html)方法の概要を示します。また、[jqツール](https://stedolan.github.io/jq/)をローカルマシンにインストールする必要があります。

まず、アンカーピアをOrg1として選択します。最初のステップは、`peer channel fetch`コマンドを使用して、最新のチャネル設定ブロックをプルすることです。`peer` CLIをOrg1管理者として動作させるには、次の環境変数を設定します:
```
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

次のコマンドを使用して、チャネル設定を取得できます:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
最新のチャネル設定ブロックはチャネルジェネシスブロックであるため、コマンドがチャネルからブロック0を返します。
```
2020-04-15 20:41:56.595 EDT [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2020-04-15 20:41:56.603 EDT [cli.common] readBlock -> INFO 002 Received block: 0
2020-04-15 20:41:56.603 EDT [channelCmd] fetch -> INFO 003 Retrieving last config block: 0
2020-04-15 20:41:56.608 EDT [cli.common] readBlock -> INFO 004 Received block: 0
```

チャネル構成ブロックは、更新プロセスを他の生成されたファイルから分離するために、`channel-artifacts`フォルダに格納されています。`channel-artifacts`フォルダに移動して、次の手順を完了します:
```
cd channel-artifacts
```
これで、`configtxlator`ツールを使用してチャネル構成の処理を開始できます。最初のステップは、protobufからのブロックをデコードして、読み取りと編集が可能なJSONオブジェクトにすることです。また、不要なブロックデータを除去して、チャネル構成のみを残します。

```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
```

これらのコマンドは、チャネル構成ブロックを合理化されたJSON `config.json` に変換します。このJSONは、更新のベースラインとして使用されます。このファイルを直接編集したくないので、編集可能なコピーを作成します。今後の手順では、元のチャネル構成を使用します。
```
cp config.json config_copy.json
```

`jq`ツールを使用して、Org1アンカーピアをチャネル設定に追加できます。
```
jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' config_copy.json > modified_config.json
```

このステップの後、`modified_config.json`ファイルにJSON形式のチャネル構成の更新バージョンが作成されます。元のチャネル構成と変更されたチャネル構成の両方をprotobuf形式に変換して、それらの差分を計算できるようになりました。
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

`channel_update.pb`という名前の新しいprotobufには、チャネル構成に適用する必要があるアンカーピアの更新が含まれています。構成の更新をトランザクションエンベロープにラップして、チャネル構成の更新トランザクションを作成できます。

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

チャネルの更新に使用できる最終的な生成ファイル`config_update_in_envelope.pb`を使用できるようになりました。`test-network`ディレクトリに戻ります:
```
cd ..
```

新しいチャネル設定を`peer channel update`コマンドに指定することで、アンカーピアを追加できます。Org1にのみ影響するチャネル設定のセクションを更新するため、チャネル更新を他のチャネルメンバーが承認する必要はありません。
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

チャネル更新が成功した場合、以下の応答を確認できると思います:
```
2020-01-09 21:30:45.791 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
```

Org2のアンカーピアを設定できます。このプロセスは2回目なので、駆け足で手順を見ていきます。`peer` CLIをOrg2管理者として動作させるために、環境変数を設定します:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

最新のチャネル設定ブロックを取得します。これは、チャネル上の2番目のブロックです:
```
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

`channel-artifacts`ディレクトリに戻ります:
```
cd channel-artifacts
```

設定ブロックをデコードしてコピーできます。
```
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json > config.json
cp config.json config_copy.json
```

チャネルにアンカーピアとして参加するOrg2ピアをチャネル設定に追加します:
```
jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' config_copy.json > modified_config.json
```

これで、元のチャネル構成と更新されたチャネル構成の両方をprotobuf形式に戻して、それらの差分を計算できます。
```
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id channel1 --original config.pb --updated modified_config.pb --output config_update.pb
```

構成更新をトランザクションエンベロープにラップして、チャネル構成更新トランザクションを作成します:
```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

`test-network`ディレクトリに戻ります。
```
cd ..
```

次のコマンドを発行して、チャネルを更新し、Org2アンカーピアを設定します:
```
peer channel update -f channel-artifacts/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

次の`peer channel info`コマンドを実行すると、チャネルが正常に更新されたことを確認できます:
```
peer channel getinfo -c channel1
```
チャネルがチャネルジェネシスブロックに2つのチャネル構成ブロックを追加することによって更新されたので、チャネルの高さは3に増加しています:
```
Blockchain info: {"height":3,"currentBlockHash":"eBpwWKTNUgnXGpaY2ojF4xeP3bWdjlPHuxiPCTIMxTk=","previousBlockHash":"DpJ8Yvkg79XHXNfdgneDb0jjQlXLb/wxuNypbfHMjas="}
```

## Deploy a chaincode to the new channel

チェーンコードをチャネルに展開することで、チャネルが正常に作成されたことを確認できます。`network.sh`スクリプトを使用して、the Basic asset transferチェーンコードを任意のテストネットワークチャネルに展開できます。次のコマンドを使用して、新しいチャネルにチェーンコードを展開します:
```
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go/ -ccl go -c channel1 -cci InitLedger
```

コマンドを実行した後、チェーンコードがチャネルに展開されていることがログに表示されます。チェーンコードは、チャネル台帳にデータを追加するために起動されます。

```
2020-08-18 09:23:53.741 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
===================== Invoke transaction successful on peer0.org1 peer0.org2 on channel 'channel1' =====================
```

以下のクエリでデータが追加されたことを確認できます。

```
peer chaincode query -C channel1 -n basic -c '{"Args":["getAllAssets"]}'
```

クエリを実行した後、アセットがチャネル台帳に追加されたことが分かります。
```
[{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300},
{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400},
{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500},
{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600},
{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700},
{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}]
```

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
