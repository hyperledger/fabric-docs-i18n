# Using the Fabric test network

Hyperledger FabricのDockerイメージとサンプルをダウンロードした後、
`fabric-samples`リポジトリで提供されているスクリプトを使用してテストネットワークをデプロイできます。
テストネットワークを使用して、ローカルマシンでノードを実行することにより、Fabricについて学習できます。
より経験豊富な開発者は、このテストネットワークを使用してスマートコントラクトとアプリケーションをテストできます。
このテストネットワークは、教育とテストのためのツールとしてのみ使用することを目的としています。
本番用ネットワークをデプロイするためのテンプレートとして使用しないでください。
テストネットワークは、`first-network`サンプルの長期的な代替としてFabric v2.0に導入されています。

このサンプルネットワークでは、Docker Composeを使用してFabricネットワークをデプロイします。
ノードはDocker Composeネットワーク内で分離されているため、テストネットワークは他の実行中のFabricのノードに接続するようには設定されていません。

**注:** これらの手順は、最新の安定版Dockerイメージと、提供されるtarファイル内のコンパイル済みセットアップユーティリティに対して動作することが確認されています。
現在のmasterブランチのイメージまたはツールを使用してこれらのコマンドを実行すると、エラーが発生する可能性があります。

## Before you begin

テストネットワークを実行する前に、`fabric-samples`リポジトリのクローンを作成し、
Fabricのイメージをダウンロードする必要があります。
その準備をするためには、[前提条件](prereqs.html) と[サンプル、バイナリ、Dockerイメージのインストール](install.html) を確認してください。

## Bring up the test network

ネットワークを起動するためのスクリプトは、``fabric-samples``リポジトリの`test-network`ディレクトリにあります。
次のコマンドを使用して、テストネットワークディレクトリに移動します:
```
cd fabric-samples/test-network
```

このディレクトリには、ローカルマシン上のDockerイメージを使用してFabricネットワークを立ち上げる注釈付きスクリプト``network.sh``があります。
``./network.sh -h``を実行して、スクリプトのヘルプテキストを表示できます:
```
Usage:
  network.sh <Mode> [Flags]
    <Mode>
      - 'up' - FabricのOrdererとピアノードを起動します。チャネルは作成されません。
      - 'up createChannel' - 1つのチャネルを持つFabricネットワークを起動します。
      - 'createChannel' - ネットワークが作られた後に、チャネルを作成して参加します。
      - 'deployCC' - fabcarチェーンコードをチャネル上にデプロイします。
      - 'down' - docker-compose downを用いてネットワークをクリアします。
      - 'restart' - ネットワークを再起動します。

    Flags:
    -ca <use CAs> - 暗号マテリアル (crypto material) を生成するための認証局(CA)を作成します。
    -c <channel name> - 使用するチャネル名 (デフォルトは"mychannel")
    -s <dbtype> - 使用するデータベースのバックエンド: goleveldb (デフォルト) or couchdb
    -r <max retry> - CLIは指定した回数の試行後にタイムアウトします (デフォルトは5)
    -d <delay> - 遅延時間 (秒単位で指定) (デフォルトは3)
    -l <language> - デプロイするチェーンコードのプログラミング言語: go (デフォルト), java, javascript, typescript
    -v <version>  - チェーンコードのバージョン。1, 2, 3などの整数でなければいけません。
    -i <imagetag> - ネットワークの起動に利用されるDockerイメージタグ (デフォルトは"latest")
    -cai <ca_imagetag> - CAに利用されるDockerイメージタグ (デフォルトは"1.4.6")
    -verbose - verboseモード
  network.sh -h (このメッセージを表示)

 Possible Mode and flags
  network.sh up -ca -c -r -d -s -i -verbose
  network.sh up createChannel -ca -c -r -d -s -i -verbose
  network.sh createChannel -c -r -d -verbose
  network.sh deployCC -l -v -r -d -verbose

 Taking all defaults:
	network.sh up

 Examples:
  network.sh up createChannel -ca -c mychannel -s couchdb -i 2.0.0
  network.sh createChannel -c channelName
  network.sh deployCC -l javascript
```

訳注: 暗号マテリアル (crypto material) は「証明書・公開鍵・秘密鍵といった暗号にかかわるファイル」のことを指しています。

`test-network`ディレクトリ内で、次のコマンドを実行して、以前に実行したコンテナやアーティファクトを削除します:
```
./network.sh down
```

訳注: アーティファクト (artifacts) は「本スクリプトの実行過程で生成されたファイル (ジェネシスブロックなど)」のことを指しています。

そして、次のコマンドを発行することでネットワークを立ち上げることができます。
もし別のディレクトリからスクリプトを実行しようとすると問題が発生します:
```
./network.sh up
```

このコマンドは、2つのピアノードと1つのOrdererノードからなるFabricネットワークを作成します。
`./network.sh up`を実行してもチャネルは作成されませんが、これについては[後のステップ](#creating-a-channel) で説明します。
コマンドが正常に完了すると、作成されたノードのログが表示されます:
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

上記のような結果が得られない場合は、[トラブルシューティング](#troubleshooting) に移動して、
何が間違っているのかを確認してください。デフォルトでは、ネットワークはcryptogenツールを使用してネットワークを起動します。
しかし、CAを使用することもできます ([認証局を使ったネットワークを立ち上げる](#bring-up-the-network-with-certificate-authorities) 参照)。

### The components of the test network

テストネットワークがデプロイされたら、しばらく時間をかけてそのコンポーネントを調べることができます。
次のコマンドを実行して、マシンで実行されているすべてのDockerコンテナを一覧表示します。`network.sh`スクリプトによって作成された3つのノードが表示されます:
```
docker ps -a
```

Fabricネットワーク上でやりとりする各ノードおよびユーザーは、
ネットワークメンバーである組織に所属する必要があります。
Fabricネットワークのメンバーである組織のグループは、しばしばコンソーシアムと呼ばれます。
テストネットワークには、Org1とOrg2の2つのコンソーシアムメンバーがいます。
また、ネットワークのオーダリングサービスを維持するオーダリング組織 (orderer organization) が1つ含まれています。

[ピア](peers/peers.html) は、あらゆるFabricネットワークの基本的なコンポーネントです。
ピアはブロックチェーン台帳を保存し、台帳にコミットする前にトランザクションを検証します。
ピアは、ブロックチェーン台帳上の資産を管理するために使用されるビジネスロジックを含むスマートコントラクトを実行します。

ネットワーク内のすべてのピアは、コンソーシアムのメンバーに属している必要があります。
テストネットワークでは、各組織がそれぞれ1つのピア`peer0.org1.example.com`と`peer0.org2.example.com`を動かしています。

すべてのFabricネットワークには、[オーダリングサービス](orderer/ordering_service.html) も含まれています。
ピアはトランザクションを検証し、トランザクションのブロックをブロックチェーン台帳に追加しますが、
トランザクションの順序を決定したり、トランザクションを新しいブロックに追加したりすることはありません。
分散ネットワークでは、ピアはお互いに離れた場所にあって、トランザクションがいつ作成されたかについて共通の見解を持っていないかもしれません。
トランザクションの順序について合意を得ることは、ピアのオーバーヘッドを生み出すコストのかかるプロセスです。

オーダリングサービスにより、ピアはトランザクションの検証と台帳へのコミットに集中できます。
オーダリングノードは、クライアントからエンドースされたトランザクションを受信した後、トランザクションの順序について合意に至り、ブロックに追加します。
その後、ブロックはピアノードに配布され、ピアノードがブロックチェーン台帳にブロックを追加します。
オーダリングノードは、ブロックの作成方法やノードが使用できるFabricのバージョンなど、Fabricネットワークのケーパビリティを定義するシステムチャネルも操作します。
システムチャネルは、どの組織がコンソーシアムのメンバーであるかを定義します。

今回のサンプルネットワークは、オーダリング組織によって運用されている単一ノードによるRaftオーダリングサービスを使用しています。
マシン上で実行されているオーダリングノードは`orderer.example.com`と表示されます。
テストネットワークは単一ノードのオーダリングサービスのみを使用しますが、実際のネットワークには複数のオーダリングノードがあり、
1つまたは複数のオーダリング組織によって運用されます。
複数のオーダリングノードは、Raft合意形成アルゴリズムを使用して、ネットワーク全体のトランザクションの順序について合意します。

## Creating a channel

マシン上ではピアノードとOrdererノードが実行されているので、
本スクリプトを使用して、Org1とOrg2の間のトランザクションを行うためのFabricのチャネルを作成できます。
チャネルは、特定のネットワークメンバー間の通信のプライベートレイヤーです。
チャネルは、チャネルに招待された組織のみが使用でき、ネットワークのその他のメンバーには見えません。
各チャネルには、個別のブロックチェーン台帳があります。
招待された組織は、ピアをチャネルに「参加」させて、チャネル台帳にデータを保存したり、チャネル上でのトランザクションを検証したりします。

`network.sh`スクリプトを使用して、Org1とOrg2間のチャネルを作成し、それらのピアをチャネルに参加させることができます。
次のコマンドを実行して、`mychannel`というデフォルトの名前でチャネルを作成します:
```
./network.sh createChannel
```
コマンドが成功した場合、コンソールログに以下のようなメッセージが表示されます:
```
========= Channel successfully joined ===========
```

チャネルフラグを使用して、名前をカスタマイズしたチャネルを作成することもできます。
例として、次のコマンドは`channel1`という名前のチャネルを作成します:
```
./network.sh createChannel -c channel1
```

チャネルフラグを使用すると、異なるチャネル名を指定して複数のチャネルを作成することもできます。
`mychannel`または`channel1`を作成した後、以下のコマンドを使用して、`channel2`という名前の2番目のチャネルを作成できます:
```
./network.sh createChannel -c channel2
```

1つのステップでネットワークを立ち上げてチャネルを作成したい場合は、`up`モードと`createChannel`モードを一緒に使用できます:
```
./network.sh up createChannel
```

## Starting a chaincode on the channel

チャネルを作成したら、[スマートコントラクト](smartcontract/smartcontract.html) を使用してチャネル台帳とやり取りできるようになります。
スマートコントラクトには、ブロックチェーン台帳上の資産を管理するビジネスロジックが含まれています。
ネットワークメンバーによって実行されるアプリケーションは、スマートコントラクトを呼び出して、台帳上に資産を作成したり、
それらの資産を変更および譲渡したりできます。
アプリケーションはまた、スマートコントラクトを参照して、台帳上のデータを読み取ります。

トランザクションが有効であることを保証するために、スマートコントラクトを使用して作成されたトランザクションは、
通常、チャネル台帳にコミットするために複数の組織によって署名される必要があります。
複数の署名は、Fabricの信頼モデルに不可欠です。
トランザクションに複数のエンドースメントを要求することで、チャネル上の1つの組織が台帳を改ざんしたり、合意されていないビジネスロジックを使用したりするのを防ぎます。
トランザクションに署名するには、各組織がピア上でスマートコントラクトを呼び出して実行する必要があり、ピアがトランザクションの出力に署名します。
出力に一貫性があり、十分な組織によって署名されている場合、トランザクションは台帳にコミットできます。
スマートコントラクトを実行する必要がある、チャネル上の設定された組織を指定するポリシーは、エンドースメントポリシーと呼ばれ、チェーンコード定義の一部としてチェーンコードごとに設定されます。

Fabricでは、スマートコントラクトはチェーンコードと呼ばれるパッケージでネットワークにデプロイされます。
チェーンコードは組織のピアにインストールされてからチャネルにデプロイされ、その後トランザクションをエンドースしてブロックチェーン台帳とやり取りするために使用できます。
チェーンコードをチャネルにデプロイする前に、チャネルのメンバーは、チェーンコードのガバナンスを確立するチェーンコード定義について合意する必要があります。
必要な数の組織が同意すると、チェーンコード定義をチャネルにコミットでき、チェーンコードを使用できるようになります。

`network.sh`を使用してチャネルを作成した後、次のコマンドを使用してチャネル上でチェーンコードを開始することができます:
```
./network.sh deployCC
```
`deployCC`サブコマンドは、 **fabcar** チェーンコードを``peer0.org1.example.com``と``peer0.org2.example.com``にインストールし、
チャネルフラグを使用して指定されたチャネルにチェーンコードをデプロイします (チャネルが指定されていない場合は`mychannel`)。
チェーンコードを初めてデプロイする場合、本スクリプトはチェーンコードの依存関係をインストールします。
デフォルトでは、本スクリプトはfabcarチェーンコードのGo版をインストールします。
ただし、言語フラグ `-l`を使用して、Javaまたはjavascript版のチェーンコードをインストールできます。
fabcarチェーンコードは、`fabric-samples`ディレクトリの`chaincode`フォルダにあります。
このフォルダには、例として提供され、チュートリアル内でFabricの機能を強調するために使用されるサンプルチェーンコードが含まれています。

**fabcar**のチェーンコード定義がチャネルにコミットされた後、
本スクリプトは`init`関数を呼び出してチェーンコードを初期化し、
チェーンコードを呼び出して車の初期リストを台帳に格納します。
次に、本スクリプトはチェーンコードを参照して、データが追加されたことを確認します。
チェーンコードが正しくインストール、デプロイ、呼び出しされた場合、ログに以下のような車のリストが表示されているはずです:
```
[{"Key":"CAR0", "Record":{"make":"Toyota","model":"Prius","colour":"blue","owner":"Tomoko"}},
{"Key":"CAR1", "Record":{"make":"Ford","model":"Mustang","colour":"red","owner":"Brad"}},
{"Key":"CAR2", "Record":{"make":"Hyundai","model":"Tucson","colour":"green","owner":"Jin Soo"}},
{"Key":"CAR3", "Record":{"make":"Volkswagen","model":"Passat","colour":"yellow","owner":"Max"}},
{"Key":"CAR4", "Record":{"make":"Tesla","model":"S","colour":"black","owner":"Adriana"}},
{"Key":"CAR5", "Record":{"make":"Peugeot","model":"205","colour":"purple","owner":"Michel"}},
{"Key":"CAR6", "Record":{"make":"Chery","model":"S22L","colour":"white","owner":"Aarav"}},
{"Key":"CAR7", "Record":{"make":"Fiat","model":"Punto","colour":"violet","owner":"Pari"}},
{"Key":"CAR8", "Record":{"make":"Tata","model":"Nano","colour":"indigo","owner":"Valeria"}},
{"Key":"CAR9", "Record":{"make":"Holden","model":"Barina","colour":"brown","owner":"Shotaro"}}]
===================== Query successful on peer0.org1 on channel 'mychannel' =====================
```

## Interacting with the network

テストネットワークを起動したら、`peer` CLIを使用してそのネットワークとやり取りできます。
`peer` CLIを使用すると、デプロイされたスマートコントラクトを呼び出したり、チャネルを更新したり、
CLIから新しいスマートコントラクトをインストールしてデプロイしたりできます。

`test-network`ディレクトリから操作していることを確認してください。
[サンプル、バイナリ、Dockerイメージのインストール](install.html) の手順に従った場合、`fabric-samples`リポジトリの`bin`フォルダに`peer`バイナリがあります。
次のコマンドを使用して、これらのバイナリをパスに追加します:
```
export PATH=${PWD}/../bin:$PATH
```
また、`fabric-samples`リポジトリ内の`core.yaml`ファイルを指すように`FABRIC_CFG_PATH`を設定する必要があります:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
以下で、`peer` CLIをOrg1として操作できるようにする環境変数を設定できます:
```
# Org1用の環境変数

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

`CORE_PEER_TLS_ROOTCERT_FILE` および `CORE_PEER_MSPCONFIGPATH` 環境変数は、`organizations` フォルダ内のOrg1の暗号マテリアルを指しています。

`./network.sh deployCC`を使用してfabcarチェーンコードをインストールして開始している場合、CLIから台帳にクエリを実行できます。
次のコマンドを実行して、チャネル台帳に追加された車のリストを取得します:
```
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'
```

このコマンドが成功した場合、スクリプトを実行したときにログに表示されたものと同じ車のリストを確認できるはずです:
```
[{"Key":"CAR0", "Record":{"make":"Toyota","model":"Prius","colour":"blue","owner":"Tomoko"}},
{"Key":"CAR1", "Record":{"make":"Ford","model":"Mustang","colour":"red","owner":"Brad"}},
{"Key":"CAR2", "Record":{"make":"Hyundai","model":"Tucson","colour":"green","owner":"Jin Soo"}},
{"Key":"CAR3", "Record":{"make":"Volkswagen","model":"Passat","colour":"yellow","owner":"Max"}},
{"Key":"CAR4", "Record":{"make":"Tesla","model":"S","colour":"black","owner":"Adriana"}},
{"Key":"CAR5", "Record":{"make":"Peugeot","model":"205","colour":"purple","owner":"Michel"}},
{"Key":"CAR6", "Record":{"make":"Chery","model":"S22L","colour":"white","owner":"Aarav"}},
{"Key":"CAR7", "Record":{"make":"Fiat","model":"Punto","colour":"violet","owner":"Pari"}},
{"Key":"CAR8", "Record":{"make":"Tata","model":"Nano","colour":"indigo","owner":"Valeria"}},
{"Key":"CAR9", "Record":{"make":"Holden","model":"Barina","colour":"brown","owner":"Shotaro"}}]
```

チェーンコードは、ネットワークメンバーが台帳の資産を譲渡または変更するときに呼び出されます。
次のコマンドを使用して、fabcarチェーンコードを呼び出して台帳上の車の所有者を変更します:
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"changeCarOwner","Args":["CAR9","Dave"]}'
```

このコマンドが成功した場合、以下の応答を確認できると思います:
```
2019-12-04 17:38:21.048 EST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
```

**注:** Javaチェーンコードをデプロイした場合には、上記の代わりに次の引数を指定してinvokeコマンドを実行してください：
`'{"function":"changeCarOwner","Args":["CAR009","Dave"]}'`
Javaで記述されたfabcarチェーンコードは、JavaScriptまたはGoで記述されたチェーンコードとは異なるインデックスを使用します。

fabcarチェーンコードのエンドースメントポリシーでは、トランザクションがOrg1とOrg2によって署名される必要があるため、
chaincode invokeコマンドは、 `--peerAddresses` フラグを用いて `peer0.org1.example.com` と `peer0.org2.example.com` の両方をターゲットにする必要があります。
ネットワークに対してTLSが有効になっているため、本コマンドは `--tlsRootCertFiles` フラグを使用して各ピアのTLS証明書も参照する必要があります。

チェーンコードを呼び出した後、別のクエリを使用して、呼び出しによってブロックチェーン台帳上のアセットがどのように変更されたかを確認できます。
すでにOrg1のピアにクエリを実行しているので、この機会にOrg2のピアで動いているチェーンコードをクエリしてみます。
Org2として動作するように、次のように環境変数を設定します:
```
# Org2用の環境変数

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

ここで、`peer0.org2.example.com`上で動いているfabcarチェーンコードにクエリします:
```
peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR9"]}'
```

結果は`"CAR9"`がDaveに譲渡されたことを示します:
```
{"make":"Holden","model":"Barina","colour":"brown","owner":"Dave"}
```

## Bring down the network

テストネットワークの使用が終了したら、次のコマンドを使用してネットワークを停止できます:
```
./network.sh down
```

このコマンドは、ノードとチェーンコードのコンテナを停止して削除し、
組織の暗号マテリアルを削除し、Dockerレジストリからチェーンコードイメージを削除します。
このコマンドは、以前に実行したときのチャネルアーティファクトとDockerボリュームも削除し、
何か問題が発生した場合に`./network.sh up`を再度実行できるようにします。

## Next steps

ここまでで、テストネットワークを使用してHyperledgerFabricをローカルマシンにデプロイしたので、
チュートリアルを使用してあなた自身のソリューションの開発を開始できます:

- [スマートコントラクトをチャネルにデプロイする](deploy_chaincode.html) チュートリアルを使用して、
あなた自身のスマートコントラクトをテストネットワークにデプロイする方法を学びます。
- [最初のアプリケーションの作成](write_first_app.html) チュートリアルにアクセスして、
Fabric SDKが提供するAPIを使用して、クライアントアプリケーションからスマートコントラクトを呼び出す方法を学習してください。
- より複雑なスマートコントラクトをネットワークにデプロイする準備ができている場合は、[コマーシャルペーパーチュートリアル](tutorial/commercial_paper.html)
に従って、2つの組織がブロックチェーンネットワークを使用してコマーシャルペーパーを取引するユースケースを探索してください。

Fabricのチュートリアルの完全なリストは、[チュートリアル](tutorials.html) ページにあります。

## Bring up the network with Certificate Authorities

Hyperledger Fabricは、公開鍵基盤 (Public Key Infrastructure, PKI) を使用して、
すべてのネットワーク参加者のアクションを検証します。
トランザクションを送信するすべてのノード、ネットワーク管理者、およびユーザーは、アイデンティティを検証するために公開証明書と秘密鍵を持っている必要があります。
これらのアイデンティティには、証明書がネットワークのメンバーである組織によって発行されたことを証明する、有効な信頼のルートが必要です。
`network.sh`スクリプトは、ピアノードとオーダリングノードを作成する前に、ネットワークをデプロイして運用するために必要なすべての暗号マテリアルを作成します。

デフォルトでは、本スクリプトはcryptogenツールを使用して証明書と鍵を作成します。
このツールは開発およびテスト用に提供されており、有効な信頼のルートを持つFabricの組織に必要な暗号マテリアルをすばやく作成できます。
`./network.sh up`を実行すると、cryptogenツールがOrg1、Org2、およびOrderer Orgの証明書と鍵を作成していることがわかります。

```
creating Org1, Org2, and ordering service organization with crypto from 'cryptogen'

/Usr/fabric-samples/test-network/../bin/cryptogen

##########################################################
##### Generate certificates using cryptogen tool #########
##########################################################

##########################################################
############ Create Org1 Identities ######################
##########################################################
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-org1.yaml --output=organizations
org1.example.com
+ res=0
+ set +x
##########################################################
############ Create Org2 Identities ######################
##########################################################
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-org2.yaml --output=organizations
org2.example.com
+ res=0
+ set +x
##########################################################
############ Create Orderer Org Identities ###############
##########################################################
+ cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output=organizations
+ res=0
+ set +x
```

ただし、テストネットワークのスクリプトには、認証局 (CA) を使用してネットワークを起動するオプションもあります。
本番用ネットワークでは、各組織は、組織に属するアイデンティティを作成するCA (または複数の中間CA) を運用します。
組織が運用する1つのCAが作成したすべてのアイデンティティは、同じ信頼のルートを共有します。
cryptogenを使用するよりも時間がかかりますが、CAを使用してテストネットワークを立ち上げると、ネットワークが本番環境にどのようにデプロイされるかがわかります。
CAをデプロイすると、クライアントのアイデンティティをFabric SDKに登録し、アプリケーションの証明書と秘密鍵を作成することもできます。

Fabric CAを使用してネットワークを立ち上げたい場合は、まず以下のコマンドを実行して、実行中のネットワークをすべて停止させます:
```
./network.sh down
```

そうすれば、CAフラグのついたネットワークを立ち上げることができます:
```
./network.sh up -ca
```

このコマンドを発行すると、ネットワーク内の組織ごとに1つずつ、合計3つのCAが表示されることが確認できます。
```
##########################################################
##### Generate certificates using Fabric CA's ############
##########################################################
Creating network "net_default" with the default driver
Creating ca_org2    ... done
Creating ca_org1    ... done
Creating ca_orderer ... done
```

CAがデプロイされた後、`./network.sh`スクリプトによって生成されたログを調べるのに時間をかける価値があります。
テストネットワークは、Fabric CAクライアントを使用して、ノードとユーザーのアイデンティティを各組織のCAに登録します。
次に、スクリプトはenrollコマンドを使用して、アイデンティティごとにMSPフォルダを生成します。
MSPフォルダには、各アイデンティティの証明書と秘密鍵が含まれており、CAを運用していた組織におけるアイデンティティの役割とメンバーシップを確立します。
次のコマンドを使用して、Org1の管理者ユーザーのMSPフォルダを調べることができます:
```
tree organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
```
このコマンドは、MSPフォルダの構造と設定ファイルを表示します:
```
organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
└── msp
    ├── IssuerPublicKey
    ├── IssuerRevocationPublicKey
    ├── cacerts
    │   └── localhost-7054-ca-org1.pem
    ├── config.yaml
    ├── keystore
    │   └── 58e81e6f1ee8930df46841bf88c22a08ae53c1332319854608539ee78ed2fd65_sk
    ├── signcerts
    │   └── cert.pem
    └── user
```
管理者ユーザーの証明書は`signcerts`フォルダにあり、
秘密鍵は`keystore`フォルダにあります。
MSPの詳細については、[メンバーシップサービスプロバイダ](membership/membership.html) のコンセプトトピックを参照してください。

cryptogenとFabric CAの両方が、`organizations`フォルダ内に各組織の暗号マテリアルを生成します。
ネットワークのセットアップに使用されるコマンドは、 `organizations/fabric-ca` ディレクトリの `registerEnroll.sh` スクリプト内にあります。
Fabric CAを使用してFabricネットワークをデプロイする方法の詳細については、[Fabric CA運用ガイド](https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html) にアクセスしてください。
[アイデンティティ](identity/identity.html) および[メンバーシップ](membership/membership.html) のコンセプトトピックにアクセスすると、FabricがPKIをどのように使用するかについて詳しく知ることができます。

## What's happening behind the scenes?

サンプルネットワークについて詳しく知りたい場合は、`test-network`ディレクトリにあるファイルとスクリプトを調べることができます。
以下の手順は、`./network.sh up`のコマンドを発行したときに何が起こるかについてのガイド付きツアーを提供します。

- `./network.sh` は、2つのピア組織とOrderer組織の証明書と鍵を作成します。
  デフォルトでは、スクリプトは `organizations/cryptogen` フォルダにある設定ファイルを用いてcryptogenツールを使用します。
  `-ca`フラグを使用して認証局を作成する場合、本スクリプトは `organizations/fabric-ca` フォルダにあるFabric CAサーバーの設定ファイルと `registerEnroll.sh` スクリプトを使用します。
  cryptogenとFabric CAの両方とも、`organizations`フォルダ内に3つの組織すべての暗号マテリアルとMSPフォルダを作成します。

- 本スクリプトはconfigtxgenツールを使用して、システムチャネルジェネシスブロックを作成します。configtxgenは `configtx/configtx.yaml` ファイルの `configtx/configtx.yaml` チャネルプロファイルを使用して、
  ジェネシスブロックを作成します。このブロックは `system-genesis-block` フォルダに保存されます。

- 組織の暗号マテリアルとシステムチャネルジェネシスブロックが生成されると、`network.sh`はネットワークのノードを起動できます。
  本スクリプトは、`docker` フォルダ内の ``docker-compose-test-net.yaml`` ファイルを使用して、ピアノードとOrdererノードを作成します。
  `docker` フォルダには、3つのFabric CAとともにネットワークのノードを起動する ``docker-compose-e2e.yaml`` ファイルも含まれています (※訳注: このファイルは既に存在していない。代わりにCAを作成するための``docker-compose-ca.yaml``が存在する)。
  このファイルは、Fabric SDKによるエンドツーエンドのテストを実行するために使用することを目的としています。これらのテストの実行の詳細については、[Node SDK](https://github.com/hyperledger/fabric-sdk-node) リポジトリを参照してください。

- `createChannel` サブコマンドを使用する場合、 `./network.sh` は `scripts` フォルダー内の `createChannel.sh` スクリプトを実行して、指定されたチャネル名を使用してチャネルを作成します。
  このスクリプトは `configtx.yaml` ファイルを使用して、チャネル作成トランザクションと2つのアンカーピア更新トランザクションを作成します。
  スクリプトはピア CLIを使用してチャネルを作成し、 ``peer0.org1.example.com`` と ``peer0.org2.example.com`` をチャネルに参加させ、両方のピアをアンカーピアにします。

- `deployCC` コマンドを発行すると、`./network.sh` は ``deployCC.sh`` スクリプトを実行して両方のピアに **fabcar** チェーンコードをインストールし、チャネルにチェーンコードを定義します。
  チェーンコード定義がチャネルにコミットされると、ピア CLIは `Init` を使用してチェーンコードを初期化し、チェーンコードを呼び出して初期データを台帳に格納します。

## Troubleshooting

チュートリアルで問題が発生した場合は、以下を確認してください:

-  ネットワークは常に新しく開始する必要があります。次のコマンドを使用して、過去の実行におけるアーティファクト、暗号マテリアル、コンテナ、Dockerボリューム、およびチェーンコードイメージを削除できます:
   ```
   ./network.sh down
   ```
   古いコンテナ、イメージ、およびボリュームを削除しないと、**エラーが発生します**。

-  Dockerエラーが表示された場合は、まずDockerのバージョン ([前提条件](prereqs.html)) を確認してから、Dockerプロセスを再起動してみてください。
   Dockerの問題は、すぐにはわからないことが多いです。例えば、ノードがコンテナ内にマウントされた暗号マテリアルにアクセスできないことが原因で発生するエラーが表示される場合があります。

   問題が解決しない場合は、以下の通りイメージを削除して一からやり直すことができます:
   ```
   docker rm -f $(docker ps -aq)
   docker rmi -f $(docker images -q)
   ```

-  もし、生成 (create)、承認 (approve)、コミット (commit)、呼び出し (invoke)、または参照 (query) コマンドでエラーが発生した場合は、
   チャネル名とチェーンコード名が適切に更新されていることを確認してください。提供されているサンプルコマンドには、プレースホルダー値があります。

-  以下のエラーが表示された場合:
   ```
   Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)
   ```

   前回の実行におけるチェーンコードイメージ (例: ``dev-peer1.org2.example.com-fabcar-1.0`` や ``dev-peer0.org1.example.com-fabcar-1.0``）が残っている可能性があります。それらを削除して、再試行してください。
   ```
   docker rmi -f $(docker images | grep dev-peer[0-9] | awk '{print $3}')
   ```

-  以下のエラーが表示された場合:

   ```
   [configtx/tool/localconfig] Load -> CRIT 002 Error reading configuration: Unsupported Config Type ""
   panic: Error reading configuration: Unsupported Config Type ""
   ```

   ``FABRIC_CFG_PATH`` 環境変数が適切に設定できていません。configtxgenツールは、 configtx.yaml を見つけるためにこの環境変数を必要とします。
   戻って ``export FABRIC_CFG_PATH=$PWD/configtx/configtx.yaml`` を実行してから、チャネルアーティファクトを再作成してください。

-  「アクティブなエンドポイント (active endpoints)」がまだあることを示すエラーが表示された場合は、Dockerネットワークを削除 (prune) します。
   これにより、前回のネットワークが消去され、新しい環境で開始されるようになります:
   ```
   docker network prune
   ```

   次のメッセージが表示されたら:
   ```
   WARNING! This will remove all networks not used by at least one container.
   Are you sure you want to continue? [y/N]
   ```
   ``y``を選んでください。

-  以下に似たエラーが表示された場合:
   ```
   /bin/bash: ./scripts/createChannel.sh: /bin/bash^M: bad interpreter: No such file or directory
   ```

   問題のファイル (この例では **createChannel.sh**) がUnix形式でエンコードされていることを確認してください。
   これは、Gitの設定で ``core.autocrlf`` を ``false`` に設定していないことが原因である可能性があります ([Windows extras](prereqs.html#windows-extras) 参照)。
   これを修正する方法はいくつかあります。例えば、Vimエディタにアクセスできる場合は、次のファイルを開きます:
   ```
   vim ./fabric-samples/test-network/scripts/createChannel.sh
   ```

   開いたら次のVimコマンドを実行してフォーマットを変更します:
   ```
   :set ff=unix
   ```

- Ordererが作成時に終了したり、またはオーダリングサービスに接続できないために create channel コマンドが失敗した場合は、`docker logs` コマンドを使用してOrdererノードのログを読み取ってください。
  以下のようなメッセージが表示されるかもしれません:
  ```
  PANI 007 [channel system-channel] config requires unsupported orderer capabilities: Orderer capability V2_0 is required but not supported: Orderer capability V2_0 is required but not supported
  ```
  これは、Fabricのバージョン1.4.xのdockerイメージを使用してネットワークを実行しようとしたときに発生します。テストネットワークは Fabricのバージョン2.xを使用して実行する必要があります。

引き続きエラーが発生する場合には、 [Hyperledger Rocket Chat](https://chat.hyperledger.org/home) または [StackOverflow](https://stackoverflow.com/questions/tagged/hyperledger-fabric) の **fabric-questions** チャネルでログを共有してください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
