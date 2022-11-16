# Upgrading your components

*対象読者: ネットワーク管理者、ノード管理者*

Fabricの最新のリリースの特別な留意点については、 [Upgrading to the latest release of Fabric](./upgrade_to_newest_version.html) をご覧ください。

このトピックは、コンポーネントをアップグレードするためのプロセスのみを対象としています。チャネルを編集してチャネルのケーパビリティレベルを変更する方法については、 [Updating a channel capability](./updating_capabilities.html) を参照してください。

注意: Hyperledger Fabricで「アップグレード」という用語を使用する場合、コンポーネントのバージョンを変更することを指します(例えば、バイナリのとあるバージョンからその次のバージョンに移動すること)。一方、「アップデート」という用語は、バージョンではなく、チャネル設定やデプロイスクリプトの更新のような設定変更を意味します。Fabricでは、技術的にはデータ移行が行われていないため、ここでは「マイグレーション」または「マイグレート」という用語は使用しません。

## Overview

大まかに言うと、ノードのバイナリレベルをアップグレードするには、2つのステップがあります。

1. 台帳とMSPをバックアップします。
2. バイナリを最新バージョンにアップグレードします。

オーダリングノードとピアの両方を所有している場合は、最初にオーダリングノードをアップグレードするのがベストプラクティスです。もしピアが遅れたり、一時的にある程度のトランザクションの処理ができなくなったりしても、いつでも追いつくことができます。これに対して、十分な数のオーダリングノードがダウンすると、ネットワークは事実上機能を停止する可能性があります。

このトピックでは、これらの手順がDockerのCLIコマンドを使用して実行されることを前提としています。別のデプロイ方法(Rancher、Kubernetes、OpenShiftなど)を使用している場合は、それらのCLIの使用方法についてドキュメントを参考にしてください。

ネイティブなデプロイの場合は、ノードのYAML設定ファイル(例えば、 `orderer.yaml` ファイル)をリリースアーティファクトのものにアップデートする必要があります。

これを行うには、 `orderer.yaml` または `core.yaml` ファイル(ピア用)をバックアップし、リリースアーティファクトの `orderer.yaml` または `core.yaml` ファイルに置き換えます。次に、変更された変数を、バックアップされた `orderer.yaml` または `core.yaml` から新しい変数に変更します。 `diff` のようなユーティリティを使用すると便利な場合があります。古いYAMLファイルを更新するのではなく、リリースからYAMLファイルを更新することは、エラーが発生する可能性が低くなるため、 **ノードのYAMLファイルを更新することをお勧めします。**

このチュートリアルは、YAMLファイルがイメージに焼き付けられ、環境変数が設定ファイルのデフォルトを上書きするDockerデプロイを前提としています。

## Environment variables for the binaries

ピアやオーダリングノードをデプロイするときは、その設定に関連するいくつかの環境変数を設定する必要がありました。ベストプラクティスは、これらの環境変数のファイルを作成し、デプロイされるノードに関連する名前を付けて、ローカルファイルシステムのどこかに保存することです。これにより、ピアまたはオーダリングノードをアップグレードするときに、作成時に設定したのと同じ変数を使用できるようになります。

次に、ファイルにリストされている設定可能な **peer** 環境変数(とサンプル値 -- アドレスからわかるように、これらの環境変数はローカルに展開されたネットワーク用です)のいくつかを示します。これらの環境変数のすべてを設定する必要がある場合とない場合があります。

```
CORE_PEER_TLS_ENABLED=true
CORE_PEER_GOSSIP_USELEADERELECTION=true
CORE_PEER_GOSSIP_ORGLEADER=false
CORE_PEER_PROFILE_ENABLED=true
CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
CORE_PEER_ID=peer0.org1.example.com
CORE_PEER_ADDRESS=peer0.org1.example.com:7051
CORE_PEER_LISTENADDRESS=0.0.0.0:7051
CORE_PEER_CHAINCODEADDRESS=peer0.org1.example.com:7052
CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org1.example.com:7051
CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org1.example.com:7051
CORE_PEER_LOCALMSPID=Org1MSP
```

次に、ノードの環境変数ファイルにリストされる **ordering node** (これらもサンプル値です)変数をいくつか示します。ここでも、これらの環境変数のすべてを設定する必要がある場合とない場合があります。

```
ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
ORDERER_GENERAL_GENESISMETHOD=file
ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
ORDERER_GENERAL_LOCALMSPID=OrdererMSP
ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
ORDERER_GENERAL_TLS_ENABLED=true
ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
```

環境変数の設定方法にかかわらず、アップグレードするノードごとに設定する必要があることに注意してください。

## Ledger backup and restore

このチュートリアルで台帳データをバックアップするためのプロセスを示しますが、ピアまたはオーダリングノードの台帳データをバックアップすることは厳密には必要ではありません(ノードがオーダリングサービス内のノードのより大きなグループの一部であると想定しています)。これは、最悪の場合のピアの壊滅的な故障(ディスク故障など)であっても、ピアを全く台帳なしで立ち上げることができます。その後、ピアを目的のチャネルに再接続させることができます。その結果、ピアは自動的に各チャネルの台帳を作成し、オーダリングサービスまたはチャネル内の他のピアから通常のブロック転送メカニズムを介してブロックの受信を開始します。ピアがブロックを処理すると、ステートデータベースもビルドします。

しかし、台帳データをバックアップすることで、ジェネシスブロックからのブートストラップに関連する時間と計算コストをかけずにピアを復元し、すべてのトランザクションを再処理することができます。このプロセスは、台帳のサイズにもよりますが、数時間かかることがあります。さらに、台帳データのバックアップは、新しいピアの追加を迅速化するのに役立つ可能性があります。これは、1つのピアから台帳データをバックアップし、バックアップされた台帳データで新しいピアを開始することによって達成できます。

このチュートリアルは、台帳データへのファイルパスが、 `/var/hyperledger/production/` (ピアの場合)または `/var/hyperledger/production/orderer` (オーダリングノードの場合)のデフォルト値から変更されていないことを前提としています。ノードのこの場所が変更されている場合は、次のコマンドで台帳のデータへのパスを入力します。

このファイルの場所には、台帳コードとチェーンコードの両方のデータがあることに注意してください。両方をバックアップすることがベストプラクティスですが、 `/var/hyperledger/production/ledgersData` にある `stateLeveldb` 、 `historyLeveldb` 、 `chains/index` フォルダをスキップすることも可能です。これらのフォルダをスキップするとバックアップに必要なストレージが削減されますが、ピアが開始されるとこれらの台帳アーティファクトが再構築されるため、バックアップデータからのピアのリカバリには時間がかかる場合があります。

CouchDBをステートデータベースとして使用する場合、ステートデータベースデータはCouchDB内に保存されるため、 `stateLeveldb` ディレクトリはありません。しかし同様に、ピアが起動してCouchDBデータベースが見つからないか、ブロックの高さが下にあることがわかった場合(古いCouchDBバックアップを使用している場合)、ステートデータベースは自動的に再構築され、現在のブロックの高さに追いつくことができます。そのため、ピア台帳データとCouchDBデータを別々にバックアップする場合は、CouchDBのバックアップが常にピアバックアップよりも古いことを確認してください。

## Upgrade ordering nodes

ordererコンテナはローリング方式で(一度に1つずつ)アップグレードする必要があります。オーダリングノードのアップグレードプロセスの概要は次のとおりです。

1. オーダリングノードを止める
2. オーダリングノードの台帳とMSPをバックアップする
3. オーダリングノードコンテナを削除する
4. 関連するイメージタグを使用して新しいオーダリングノードコンテナを起動する

オーダリングサービス全体がアップグレードされるまで、オーダリングサービス内の各ノードに対してこのプロセスを繰り返します。

### Set command environment variables

オーダリングノードのアップグレードを試みる前に、次の環境変数をエクスポートしてください。

* `ORDERER_CONTAINER`: オーダリングノードコンテナの名前です。この変数は、アップグレード時にノードごとにエクスポートする必要があります。
* `LEDGERS_BACKUP`: バックアップする台帳を保存するローカルファイルシステム内の場所です。以下に示すように、バックアップされる各ノードには、その台帳を含む独自のサブフォルダがあり、このフォルダを作成する必要があります。
* `IMAGE_TAG`: アップグレード先のFabricバージョンです。例えば `2.0` などです。

開始するノードが正しいイメージを使用していることを確認するために、 **image tag** を設定する必要があることに注意してください。タグの設定に使用するプロセスは、デプロイ方法によって異なります。

### Upgrade containers

**ordererを停止して** アップグレードプロセスを始めましょう。

```
docker stop $ORDERER_CONTAINER
```

ordererが停止したら、 **その台帳とMSPをバックアップしましょう。**

```
docker cp $ORDERER_CONTAINER:/var/hyperledger/production/orderer/ ./$LEDGERS_BACKUP/$ORDERER_CONTAINER
```

次に、オーダリングノードコンテナ自体を削除します(新しいコンテナには古いものと同じ名前を付けるため)。

```
docker rm -f $ORDERER_CONTAINER
```

その後、次のコマンドを発行して、新しいオーダリングノードコンテナを起動します。

```
docker run -d -v /opt/backup/$ORDERER_CONTAINER/:/var/hyperledger/production/orderer/ \
            -v /opt/msp/:/etc/hyperledger/fabric/msp/ \
            --env-file ./env<name of node>.list \
            --name $ORDERER_CONTAINER \
            hyperledger/fabric-orderer:$IMAGE_TAG orderer
```

すべてのオーダリングノードが起動したら、ピアのアップグレードに進むことができます。

## Upgrade the peers

ピアは、オーダリングノードと同様に、ローリング方式で(一度に1つずつ)アップグレードする必要があります。オーダリングノードのアップグレードで述べたように、オーダリングノードとピアは並行してアップグレードすることができますが、このチュートリアルのために、そのプロセスを分離しました。大まかには、次の手順を実行します。

1. ピアを止めます。
2. ピアの台帳とMSPをバックアップします。
3. チェーンコードコンテナとイメージを削除します。
4. ピアコンテナを削除します。
5. 関連するイメージタグを使用して新しいピアコンテナを起動します。

### Set command environment variables

ピアをアップグレードしようとする前に、次の環境変数をエクスポートしてください。

* `PEER_CONTAINER`: ピアコンテナの名前です。この変数はノードごとに設定する必要があります。
* `LEDGERS_BACKUP`: バックアップする台帳を保存するローカルファイルシステムの場所です。以下に示すように、バックアップされる各ノードには、その台帳を含む独自のサブフォルダがあり、このフォルダを作成する必要があります。
* `IMAGE_TAG`: アップグレード先のFabricバージョンです。例えば `2.0` などです。

開始するノードが正しいイメージを使用していることを確認するために、 **image tag** を設定する必要があります。タグの設定に使用するプロセスは、デプロイ方法によって異なります。

すべてのノードがアップグレードされるまで、各ピアに対してこのプロセスを繰り返します。

### Upgrade containers

次のコマンドで **最初のピアを停止** しましょう。

```
docker stop $PEER_CONTAINER
```

その後、 **ピアの台帳とMSPをバックアップしましょう。**

```
docker cp $PEER_CONTAINER:/var/hyperledger/production ./$LEDGERS_BACKUP/$PEER_CONTAINER
```

ピアが停止し、台帳をバックアップしたので、 **ピアのチェーンコードコンテナを削除します。**

```
CC_CONTAINERS=$(docker ps | grep dev-$PEER_CONTAINER | awk '{print $1}')
if [ -n "$CC_CONTAINERS" ] ; then docker rm -f $CC_CONTAINERS ; fi
```

そしてピアチェーンコードイメージです。

```
CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_IMAGES" ] ; then docker rmi -f $CC_IMAGES ; fi
```

それから、ピアコンテナ自体を削除します(新しいコンテナには古いものと同じ名前を付けるため)。

```
docker rm -f $PEER_CONTAINER
```

その後、次のコマンドを発行して、新しいピアコンテナを起動します。

```
docker run -d -v /opt/backup/$PEER_CONTAINER/:/var/hyperledger/production/ \
            -v /opt/msp/:/etc/hyperledger/fabric/msp/ \
            --env-file ./env<name of node>.list \
            --name $PEER_CONTAINER \
            hyperledger/fabric-peer:$IMAGE_TAG peer node start
```

チェーンコードコンテナを再起動する必要はありません。ピアがチェーンコード(呼び出しまたはクエリ)の要求を取得すると、まずそのチェーンコードのコピーが実行されているかどうかがチェックされます。そうであれば、それを使用します。そうでなければ、この場合のように、ピアはチェーンコードを起動します(必要であればイメージを再構築します)。

### Verify peer upgrade completion

チェーンコード呼び出しでアップグレードがきちんと整備されていることを確認するためのベストプラクティスです。1つのピアが正常に更新されたことを検証するには、そのピアでホストされている台帳の1つを問い合せることで確認できるはずです。複数のピアがアップグレードされ、チェーンコードをアップグレードプロセスの一部としアップデートしていることを確認したい場合は、エンドースメントポリシーを満たすのに十分な組織のピアがアップグレードされるまで待つ必要があります。

これを試みる前に、エンドースメントポリシーを満たすのに十分な数の組織からピアをアップグレードしておくと良いでしょう。ただし、これはチェーンコードをアップグレードプロセスの一部としてアップデートする場合にのみ必須です。チェーンコードをアップグレードプロセスの一部としてアップデートしない場合は、異なるFabricのバージョンで実行されているピアからエンドースメントを取得することができます。

## Upgrade your CAs

Fabric CAサーバーのアップグレード方法については、 [CA documentation](http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server) をクリックしてください。

## Upgrade Node SDK clients

Node SDKクライアントをアップグレードする前に、FabricとFabric CAをアップグレードします。FabricとFabric CAは、古いSDKクライアントとの後方互換性がテストされています。新しいSDKクライアントは、多くの場合、古いFabricとFabric CAのリリースで動作しますが、古いFabricとFabric CAのリリースではまだ利用できない機能を公開し、完全な互換性がテストされていない可能性があります。

NPMを使用して任意の `Node.js` クライアントをアップグレードするには、アプリケーションのルートディレクトリで次のコマンドを実行します。

```
npm install fabric-client@latest

npm install fabric-ca-client@latest
```

これらのコマンドは、FabricクライアントとFabric CAクライアントの両方の新しいバージョンをインストールし、新しいバージョンを `package.json` に書き込みます。

## Upgrading CouchDB

CouchDBをステートデータベースとして利用する場合は、ピアのアップグレードと同時にピアのCouchDBをアップグレードする必要があります。

CouchDBをアップグレードする方法は以下のとおりです。

1. CouchDBを止めます。
2. CouchDBのデータディレクトリをバックアップします。
3. 新しいDockerイメージを使用するために、最新のCouchDBバイナリまたは更新デプロイスクリプトをインストールします。
4. CouchDBをリスタートします。

## Upgrade Node chaincode shim

Nodeチェーンコードシムの新しいバージョンに移行するには、開発者は次のことを行う必要があります。

1. チェーンコード `package.json` 内の `fabric-shim` のレベルを古いレベルから新しいレベルに変更します。
2. この新しいチェーンコードパッケージを再パッケージ化し、チャネルのすべてのエンドーシングピアにそれをインストールします。
3. この新しいチェーンコードへのアップグレードを実行します。その方法については、 [Peer chaincode commands](./commands/peerchaincode.html) を参照してください。

## Upgrade Chaincodes with vendored shim

特にv2.0リリースのためのGoチェーンコードshimのアップグレードについては、 [Chaincode shim changes](./upgrade_to_newest_version.html#chaincode-shim-changes) を参照してください。

チェーンコードshimをベンダーへ許可する多くのサードパーティツールが存在します。これらのツールのいずれかを使用した場合は、同じツールを使用して、ベンダリングされたチェーンコードshimを更新し、チェーンコードを再パッケージ化します。

チェーンコードがshimをベンダリングしている場合は、shimのバージョンをアップデートした後、すでにチェーンコードを持っているすべてのピアにインストールする必要があります。同じ名前でインストールしますが、新しいバージョンです。そして、このチェーンコードがデプロイされている各チャネルでチェーンコードのアップグレードを実行し、新しいバージョンに移行する必要があります。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
