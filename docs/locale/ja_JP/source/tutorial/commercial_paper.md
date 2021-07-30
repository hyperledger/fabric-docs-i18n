# Commercial paper tutorial

**対象読者:** アーキテクト、アプリケーション開発者、スマートコントラクト開発者、管理者

このチュートリアルでは、コマーシャルペーパー(訳注:短期の無担保手形)のサンプルアプリケーションおよびスマートコントラクトをインストールして使用する方法について説明します。これはタスク指向のトピックであるため、概念よりも手順が強調されています。概念をより詳細に理解するには、[Developing Applications](../developapps/developing_applications.html)トピックを参照してください。

![commercialpaper.tutorial](./commercial_paper.diagram.1.png) *このチュートリアルでは、MagnetoCorpとDigiBankの2つの組織が、Hyperledger FabricブロックチェーンネットワークであるPaperNetを使用してコマーシャルペーパーを相互に取引します。*

テストネットワークを設定したら、MagnetoCorpの従業員であるIsabellaの役を演じます。Isabellaの代わりにコマーシャルペーパーを発行します。次に、DigiBankの従業員であるBalajiの役を演じるように役割を切り替えます。Balajiはコマーシャルペーパーを購入し、一定期間保持した後、少しの利益をMagnetoCorpで償還します。

開発者、エンドユーザー、および管理者として、それぞれ異なる組織で作業します。次の手順を実行して、Hyperledger Fabricネットワークで相互に合意したルールに従って、独立して作業する2つの異なる組織として共同作業することの意味を理解します。

* [マシンのセットアップ](#prerequisites)と[サンプルのダウンロード](#download-samples)
* [ネットワークを作成](#create-the-network)
* [コマーシャルペーパースマートコントラクトの実装を確認](#examine-the-commercial-paper-smart-contract)
* チェーンコード定義をMagnetoCorpおよびDigibankとして承認することで、[チャネルにスマートコントラクトをデプロイ](#deploy-the-smart-contract-to-the-channel)
* [依存関係](#application-dependencies)を含むMagnetoCorp[アプリケーション](#application-structure)の構造理解
* [ウォレットとID](#wallet)の構成と使用
* [コマーシャルペーパーを発行](#issue-application)するMagnetoCorpアプリケーションを実行
* DigiBankが[アプリケーション](#digibank-applications)でスマートコントラクトを使用する方法を理解
* Digibankで、コマーシャルペーパーを[購入](#buy-application)および[償還](#redeem-application)するアプリケーションを実行

このチュートリアルは、MacOSおよびUbuntuでテストされており、他のLinuxディストリビューションでも動作するはずです。Windows版は開発中です。

## Prerequisites

作業を開始する前に、チュートリアルで必要な前提条件となるテクノロジをいくつかインストールする必要があります。読者が迅速に作業を進められるように、これらは最小限にしています。

次のテクノロジがインストールされている**必要**があります:

  * [**Node**](https://github.com/hyperledger/fabric-sdk-node#build-and-test)
    The Node.js SDK READMEには、前提条件の最新のリストが含まれています。

次のテクノロジをインストールすると**便利**です:

  * [Visual Studio Code](https://code.visualstudio.com/)バージョン1.28以降などのソースコードエディタ。VS Codeは、アプリケーションとスマートコントラクトの開発とテストに役立ちます。[ここ](https://code.visualstudio.com/Download)からVS Codeをインストールしてください。

    [Atom](https://atom.io/)、[Sublime Text](http://www.sublimetext.com/)、[Brackets](http://brackets.io/)など、多くの優れたコードエディターが利用可能です。

アプリケーションおよびスマートコントラクト開発の経験が深まるにつれて、次のテクノロジをインストールすると**便利な場合があります**。チュートリアルを最初に実行するときに、これらをインストールする必要はありません:

  * [Nodeバージョンマネージャ](https://github.com/creationix/nvm)。NVMを使用すると、異なるバージョンのNodeを簡単に切り替えることができます。複数のプロジェクトで同時に作業する場合に便利です。[ここ](https://github.com/creationix/nvm#installation)からNVMをインストールします。

## Download samples

コマーシャルペーパーチュートリアルは、`fabric-samples`リポジトリ内のサンプルの1つです。
このチュートリアルを開始する前に、Fabric [Prerequisites](../prereqs.html)をインストールし、
[Download the Samples, Binaries and Docker Images](../install.html)の手順に従っていることを確認してください。
その手順が完了すると、チュートリアルスクリプト、スマートコントラクトおよびアプリケーションファイルを含む`fabric-samples`リポジトリのクローンが作成されます。

![commercialpaper.download](./commercial_paper.diagram.2.png) *`fabric-samples` GitHubリポジトリをローカルマシンにダウンロードしてください。*

ダウンロードしたら、`fabric-samples`のディレクトリ構造を自由に確認してください:

```
$ cd fabric-samples
$ ls

CODEOWNERS			    SECURITY.md			        first-network
CODE_OF_CONDUCT.md		chaincode			        high-throughput
CONTRIBUTING.md			chaincode-docker-devmode	interest_rate_swaps
LICENSE				    ci				            off_chain_data
MAINTAINERS.md			commercial-paper		    test-network
README.md			    fabcar
```

`commercial-paper`ディレクトリに注目してください。ここに我々のサンプルが格納されています!

これで、チュートリアルの第1段階が完了しました。次に、異なるユーザーおよびコンポーネントの複数のコマンドウィンドウを開きます。次に例を示します:

* ネットワーク経由でピア、orderer、およびCAのログを出力するためのウィンドウ
* MagnetoCorpの管理者およびDigiBankの管理者として、チェーンコードを承認するためのウィンドウ
* スマートコントラクトを利用して、コマーシャルペーパーを相互に交換するIsabellaとBalajiの代理でアプリケーションを実行するためのウィンドウ

特定のコマンドウィンドウからコマンドを実行するタイミングを明確にします。たとえば、次のようになります:

```
(isabella)$ ls
```

上記は、Isabellaのウィンドウから`ls`コマンドを実行する必要があることを示しています。

## Create the network

このチュートリアルでは、Fabricテストネットワークを使用してスマートコントラクトをデプロイします。テストネットワークは、2つのピア組織と1つのオーダリング組織で構成されます。2つのピア組織はそれぞれ1つのピアを運営し、オーダー組織は単一ノードのRaftオーダリングサービスを運営します。また、テストネットワークを使用して、`mychannel`という名前の単一チャネルを作成し、両方のピア組織をメンバーにします。

![commercialpaper.network](./commercial_paper.diagram.testnet.png)
*Fabricテストネットワークは、Org1とOrg2の2つのピア組織
と1つのオーダー組織で構成されます。各コンポーネントはDockerコンテナとして動作します。*

各組織は独自の認証局を実行します。2つのピア、[ステートデータベース](../ledger/ledger.html#world-state-database-options)、オーダリングサービスノード、および各組織のCAは、それぞれ独自のDockerコンテナで実行されます。本番環境では、組織は通常、他のシステムと共有されている既存のCAを使用します。そのCAはFabricネットワーク専用ではありません。

テストネットワークの2つの組織を使用すると、ブロックチェーン台帳を、別々のピアを操作する2つの組織として操作できます。このチュートリアルでは、テストネットワークのOrg1をDigiBank、Org2をMagnetoCorpとして操作します。

コマーシャルペーパーディレクトリに用意されているスクリプトを使用して、テストネットワークを開始し、チャネルを作成できます。`fabric-samples`の`commercial-paper`ディレクトリに移動します:
```
cd fabric-samples/commercial-paper
```
次に、スクリプトを使用してテストネットワークを起動します:
```
./network-starter.sh
```
スクリプトの実行中に、デプロイされているテストネットワークのログが表示されます。スクリプトが完了したら、`docker ps`コマンドを使用して、ローカルマシン上で実行されているFabricノードを表示できます:
```
$ docker ps

CONTAINER ID        IMAGE                               COMMAND                  CREATED              STATUS              PORTS                                        NAMES
a86f50ca1907        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   7051/tcp, 0.0.0.0:9051->9051/tcp             peer0.org2.example.com
77d0fcaee61b        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp                       peer0.org1.example.com
7eb5f64bfe5f        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp   couchdb0
2438df719f57        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp   couchdb1
03373d116c5a        hyperledger/fabric-orderer:latest   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                       orderer.example.com
6b4d87f65909        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:8054->8054/tcp             ca_org2
7b01f5454832        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:9054->9054/tcp             ca_orderer
87aef6062f23        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   0.0.0.0:7054->7054/tcp                       ca_org1
```

これらのコンテナをテストネットワークのノードにマッピングできるかどうかを確認します(情報を検索するには、水平方向にスクロールする必要があります):

* Org1ピア `peer0.org1.example.com` がコンテナ `a86f50ca1907`で実行されている
* Org2ピア `peer0.org2.example.com` がコンテナ `77d0fcaee61b`で実行されている
* Org1ピアのCouchDBデータベース `couchdb0` がコンテナ `7eb5f64bfe5f`で実行されている
* Org2ピアのCouchDBデータベース `couchdb1` がコンテナ `2438df719f57`で実行されている
* Orderingノード `orderer.example.com` がコンテナ `03373d116c5a`で実行されている 
* Org1CA `ca_org1` がコンテナ `87aef6062f23`で実行されている 
* Org2CA `ca_org2` がコンテナ `6b4d87f65909`で実行されている 
* オーダリング組織CA `ca_orderer` がコンテナ `7b01f5454832`で実行されている

これらのコンテナはすべて`net_test`という[Dockerネットワーク](https://docs.docker.com/network/)を形成しています。ネットワークを表示するには、`docker network`コマンドを使用します:

```
$ docker network inspect net_test

  [
      {
          "Name": "net_test",
          "Id": "f4c9712139311004b8f7acc14e9f90170c5dcfd8cdd06303c7b074624b44dc9f",
          "Created": "2020-04-28T22:45:38.525016Z",
          "Containers": {
              "03373d116c5abf2ca94f6f00df98bb74f89037f511d6490de4a217ed8b6fbcd0": {
                  "Name": "orderer.example.com",
                  "EndpointID": "0eed871a2aaf9a5dbcf7896aa3c0f53cc61f57b3417d36c56747033fd9f81972",
                  "MacAddress": "02:42:c0:a8:70:05",
                  "IPv4Address": "192.168.112.5/20",
                  "IPv6Address": ""
              },
              "2438df719f57a597de592cfc76db30013adfdcfa0cec5b375f6b7259f67baff8": {
                  "Name": "couchdb1",
                  "EndpointID": "52527fb450a7c80ea509cb571d18e2196a95c630d0f41913de8ed5abbd68993d",
                  "MacAddress": "02:42:c0:a8:70:06",
                  "IPv4Address": "192.168.112.6/20",
                  "IPv6Address": ""
              },
              "6b4d87f65909afd335d7acfe6d79308d6e4b27441b25a829379516e4c7335b88": {
                  "Name": "ca_org2",
                  "EndpointID": "1cc322a995880d76e1dd1f37ddf9c43f86997156124d4ecbb0eba9f833218407",
                  "MacAddress": "02:42:c0:a8:70:04",
                  "IPv4Address": "192.168.112.4/20",
                  "IPv6Address": ""
              },
              "77d0fcaee61b8fff43d33331073ab9ce36561a90370b9ef3f77c663c8434e642": {
                  "Name": "peer0.org1.example.com",
                  "EndpointID": "05d0d34569eee412e28313ba7ee06875a68408257dc47e64c0f4f5ef4a9dc491",
                  "MacAddress": "02:42:c0:a8:70:08",
                  "IPv4Address": "192.168.112.8/20",
                  "IPv6Address": ""
              },
              "7b01f5454832984fcd9650f05b4affce97319f661710705e6381dfb76cd99fdb": {
                  "Name": "ca_orderer",
                  "EndpointID": "057390288a424f49d6e9d6f788049b1e18aa28bccd56d860b2be8ceb8173ef74",
                  "MacAddress": "02:42:c0:a8:70:02",
                  "IPv4Address": "192.168.112.2/20",
                  "IPv6Address": ""
              },
              "7eb5f64bfe5f20701aae8a6660815c4e3a81c3834b71f9e59a62fb99bed1afc7": {
                  "Name": "couchdb0",
                  "EndpointID": "bfe740be15ec9dab7baf3806964e6b1f0b67032ce1b7ae26ac7844a1b422ddc4",
                  "MacAddress": "02:42:c0:a8:70:07",
                  "IPv4Address": "192.168.112.7/20",
                  "IPv6Address": ""
              },
              "87aef6062f2324889074cda80fec8fe014d844e10085827f380a91eea4ccdd74": {
                  "Name": "ca_org1",
                  "EndpointID": "a740090d33ca94dd7c6aaf14a79e1cb35109b549ee291c80195beccc901b16b7",
                  "MacAddress": "02:42:c0:a8:70:03",
                  "IPv4Address": "192.168.112.3/20",
                  "IPv6Address": ""
              },
              "a86f50ca19079f59552e8674932edd02f7f9af93ded14db3b4c404fd6b1abe9c": {
                  "Name": "peer0.org2.example.com",
                  "EndpointID": "6e56772b4783b1879a06f86901786fed1c307966b72475ce4631405ba8bca79a",
                  "MacAddress": "02:42:c0:a8:70:09",
                  "IPv4Address": "192.168.112.9/20",
                  "IPv6Address": ""
              }
          },
          "Options": {},
          "Labels": {}
      }
  ]
```

1つのDockerネットワークの一部でありながら、8つのコンテナがどのように異なるIPアドレスを使用しているかを見てください。(わかりやすくするために出力を省略しています)。

私たちはテストネットワークをDigiBankとMagnetoCorpとして運営しているので、`peer0.org1.example.com`はDigiBank組織に属し、`peer0.org2.example.com`はMagnetoCorpによって運営されます。テストネットワークが稼動しているので、私たちのネットワークはこの時点からPaperNetと呼ぶことができます。

要約すると: GitHubからHyperledger Fabricサンプルリポジトリをダウンロードして、ローカルマシン上でFabricネットワークを稼働させています。それでは、コマーシャルペーパーの発行取引を行うMagnetoCorpの役割を果たしてみましょう。

## Monitor the network as MagnetoCorp

コマーシャルペーパーチュートリアルでは、DigiBankとMagnetoCorpの2つの個別フォルダを提供することで、2つの組織として機能できます。2つのフォルダには、各組織のスマートコントラクトおよびアプリケーションファイルが含まれます。2つの組織はコマーシャルペーパーの取引で異なる役割を持つため、アプリケーションファイルは組織ごとに異なります。`fabric-samples`リポジトリで新しいウィンドウを開き、次のコマンドを使用してMagnetoCorpディレクトリに移動します:

```
cd commercial-paper/organization/magnetocorp
```
MagnetoCorpとして最初にやることは、PaperNetのコンポーネントをモニターすることです。管理者は`logspout`[ツール](https://github.com/gliderlabs/logspout#logspout)を使って、Dockerコンテナの集合からの集約出力を見ることができます。このツールは、異なる出力ストリームを1つの場所に集め、1つのウィンドウで何が起きているかを簡単に見ることができます。これは、スマートコントラクトをインストールする管理者や、スマートコントラクトを起動する開発者にとって、非常に便利です。

MagnetoCorpディレクトリで、次のコマンドを実行して`monitordocker.sh`スクリプトを実行し、`net_test`で実行されているPaperNetに関連付けられたコンテナの`logspout`ツールを起動します:
```
(magnetocorp admin)$ ./configuration/cli/monitordocker.sh net_test
...
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
(...)
Starting monitoring on all containers on the network net_test
b7f3586e5d0233de5a454df369b8eadab0613886fc9877529587345fc01a3582
```

`monitordocker.sh`のデフォルトポートがすでに使用されている場合は、上記のコマンドにポート番号を渡すことができます。
```
(magnetocorp admin)$ ./monitordocker.sh net_test <port_number>
```

このウィンドウには、チュートリアルの残りの部分で使用するDockerコンテナの出力が表示されるので、別のコマンドウィンドウを開きます。次に、MagnetoCorpがコマーシャルペーパーに発行するために使用するスマートコントラクトを見ていきます。

## Examine the commercial paper smart contract

`issue`、`buy`および`redeem`は、コマーシャルペーパースマートコントラクトの中心となる3つの機能です。これらはそれぞれ台帳でコマーシャルペーパーを発行、購買および償却するためのトランザクションをサブミットするのにアプリケーションで使用されます。次のタスクは、このスマートコントラクトの中身を確認します。

`fabric-samples`ディレクトリで新しい端末を開き、MagnetoCorpフォルダに移動してMagnetoCorp開発者として操作します。
```
cd commercial-paper/organization/magnetocorp
```
次に、選択したエディタ(このチュートリアルではVS Code)を使用して、`contract`ディレクトリ内のスマートコントラクトを表示できます:
```
(magnetocorp developer)$ code contract
```

そのフォルダの`lib`ディレクトリには、`papercontract.js`ファイルがあります。これにはコマーシャルペーパーのスマートコントラクトが含まれています!

![commercialpaper.vscode1](./commercial_paper.vscode.papercontract.png) *`papercontract.js`のコマーシャルペーパースマートコントラクトを表示するサンプルコードエディタ*

`papercontract.js`は、Node.js環境で実行するように設計されたJavaScriptプログラムです。次の主要なプログラム行に注目してください:

* `const { Contract, Context } = require('fabric-contract-api');`

  このステートメントは、スマートコントラクトで広く使用される2つの主要なHyperledger
  Fabricクラス(`Contract`と`Context`)を利用可能にします。これらのクラスの詳細については、[`fabric-shim`
  JSDOCS](https://hyperledger.github.io/fabric-chaincode-node/)を参照してください。


* `class CommercialPaperContract extends Contract {`

  これにより、組込みFabric `Contract`クラスに基づいてスマートコントラクトクラス`CommercialPaperContract`が定義されます。コマーシャルペーパーの`issue`、`buy`および`redeem`のための主要トランザクションを実装するメソッドは、このクラス内で定義されます。


* `async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime...) {`

  このメソッドは、PaperNetのコマーシャルペーパー`issue`トランザクションを定義します。このメソッドに渡されたパラメータは、新しいコマーシャルペーパーの作成に使用されます。

  スマートコントラクト内の`buy`トランザクションと`redeem`トランザクションを検索して確認します。


* `let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime...);`

  `issue`トランザクション内で、この文により指定されたトランザクション入力を持つ`CommercialPaper`クラスを使用して、メモリー内に新しいコマーシャルペーパーを作成します。このクラスを同様に使用する方法を確認するには、`buy`トランザクションと`redeem`トランザクションを調べます。


* `await ctx.paperList.addPaper(paper);`

  この文は、`ctx.paperList`(スマートコントラクトコンテキスト`CommercialPaperContext`が初期化されたときに作成された`PaperList`クラスのインスタンス)を使用して、新しいコマーシャルペーパーを台帳に追加します。このクラスの使用方法を確認するには、再度、`buy`メソッドと`redeem`メソッドを調べます。


* `return paper;`

  この文は、`issue`トランザクションからの応答としてバイナリバッファを返し、スマートコントラクトの呼び出し側で処理します。


`contract`ディレクトリ内の他のファイルを自由に調べてスマートコントラクトの仕組みを理解し、`papercontract.js`が[スマートコントラクト処理](../developapps/smartcontract.html)のトピックでどのように設計されているかを詳しく読んでください。

## Deploy the smart contract to the channel

`papercontract`をアプリケーションから起動するには、テストネットワークの適切なピアノードにインストールしてから、[Fabric chaincode lifecycle](../chaincode_lifecycle.html#chaincode-lifecycle)を使用してチャネル上で定義する必要があります。Fabric チェーンコードライフサイクルを使用すると、チャネルにチェーンコードを配布する前に、複数の組織がチェーンコードのパラメータに同意できます。その結果、MagnetoCorpとDigiBankの両方の管理者としてチェーンコードをインストールして承認する必要があります。

![commercialpaper.install](./commercial_paper.diagram.install.png)  *MagnetoCorp管理者は、`papercontract`のコピーをMagnetoCorpピアにインストールします。*

スマートコントラクトはアプリケーション開発の焦点であり、[chaincode](../chaincode4ade.html)と呼ばれるHyperledger
Fabricアーティファクト内に含まれています。1つ以上のスマートコントラクトを単一のチェーンコード内で定義でき、チェーンコードをインストールすると、PaperNetの様々な組織でそれらを使用できます。つまり、管理者のみがチェーンコードについて心配する必要があり、他のすべての人がスマートコントラクトについて考えることができます。

### Install and approve the smart contract as MagnetoCorp

まず、MagnetoCorp管理者としてスマートコントラクトをインストールし、承認します。`magnetocorp`フォルダから操作していることを確認するか、次のコマンドを使用してそのフォルダに戻ります:

```
cd commercial-paper/organization/magnetocorp
```

MagnetoCorp管理者は、`peer` CLIを使用してPaperNetと対話できます。ただし、管理者は、コマンドウィンドウで特定の環境変数を設定して、正しい`peer`バイナリセットを使用し、MagnetoCorpピアのアドレスにコマンドを送信し、正しい暗号化マテリアルで要求に署名する必要があります。

サンプルで提供されているスクリプトを使用して、コマンドウィンドウで環境変数を設定できます。`magnetocorp`のディレクトリで次のコマンドを実行します:
```
source magnetocorp.sh
```

環境変数の完全なリストがウィンドウに表示されます。このコマンドウィンドウを使用して、MagnetoCorp管理者としてPaperNetと対話できます。

最初のステップは、`papercontract`スマートコントラクトをインストールすることです。スマートコントラクトは、`peer lifecycle chaincode package`コマンドを使用して、チェーンコードにパッケージ化できます。MagnetoCorp管理者のコマンドウィンドウで、次のコマンドを実行して、チェーンコードパッケージを作成します:
```
(magnetocorp admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
MagnetoCorp管理者は、`peer lifecycle chaincode install`コマンドを使用して、MagnetoCorpピアにチェーンコードをインストールできるようになりました:
```
(magnetocorp admin)$ peer lifecycle chaincode install cp.tar.gz
```
チェーンコードパッケージをインストールすると、次のようなメッセージが端末に出力されます:
```
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEcp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c\022\004cp_0" >
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```
MagnetoCorp管理者は`CORE_PEER_ADDRESS=localhost:9051`を設定して、コマンドのターゲットを`peer0.org2.example.com`に設定しているため、`INFO 001 Installed remotely...`は、`papercontract`がこのピアに正常にインストールされたことを示します。

スマートコントラクトをインストールした後、`papercontract`のチェーンコード定義をMagnetoCorpとして承認する必要があります。最初のステップは、ピアにインストールしたチェーンコードのパッケージIDを検索することです。`peer lifecycle chaincode queryinstalled`コマンドを使用してパッケージIDを照会できます:
```
peer lifecycle chaincode queryinstalled
```

このコマンドは、installコマンド実行時と同じパッケージ識別子(パッケージID)を返します。次のような出力が表示されます:
```
Installed chaincodes on peer:
Package ID: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c, Label: cp_0
```

次の手順ではパッケージIDが必要になるため、パッケージIDを環境変数として保存します。パッケージIDはすべてのユーザーで同じではない可能性があるため、あなたのコマンドウィンドウから返されたパッケージIDを使用してこのステップを完了する必要があります。

```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

管理者は、`peer lifecycle chaincode approveformyorg`コマンドを使用して、MagnetoCorpのチェーンコード定義を承認できるようになりました:
```
(magnetocorp admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

チャネルメンバーがチェーンコード定義の使用に同意する必要がある最も重要なチェーンコードパラメータの1つは、チェーンコード[エンドースメントポリシー](../endorsement-policies.html)です。エンドースメントポリシーは、トランザクションが有効であると判断する前にトランザクションをエンドース(実行および署名)する必要がある組織のセットを記述します。``--policy``フラグを使用せずに`papercontract`チェーンコードを承認すると、MagnetoCorp管理者はチャネルのデフォルトの`エンドースメント`ポリシーを使用することに同意します。これは、`mychannel`テストチャネルの場合、チャネル上の過半数の組織がトランザクションを保証することを要求します。すべてのトランザクションは、有効か無効かにかかわらず[台帳ブロックチェーン](../ledger/ledger.html#blockchain)に記録されますが、有効なトランザクションのみが[ワールドステート](../ledger/ledger.html#world-state)を更新します。
### Install and approve the smart contract as DigiBank

`mychannel`の`LifecycleEndorsement`ポリシーに基づくと、Fabric
チェーンコードライフサイクルでは、チャネルにチェーンコードをコミットする前に、チャネル上の過半数の組織がチェーンコード定義に同意する必要があります。これは、2つのうちの2つの必要な過半数を取得するために、MagnetoCorpとDigiBankの両方で`papernet`チェーンコードを承認する必要があることを意味します。`fabric-samples`で新しいターミナルウィンドウを開き、DigiBankスマートコントラクトファイルとアプリケーションファイルが格納されているフォルダに移動します:
```
(digibank admin)$ cd commercial-paper/organization/digibank/
```
DigiBankフォルダのスクリプトを使用して、DigiBank管理者として機能するための環境変数を設定します:
```
source digibank.sh
```

これで、`papercontract`をDigiBankとしてインストールし、承認することができます。次のコマンドを実行して、チェーンコードをパッケージ化します:
```
(digibank admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
これで、管理者はDigiBankピアにチェーンコードをインストールできます:
```
(digibank admin)$ peer lifecycle chaincode install cp.tar.gz
```
次に、インストールされたばかりのチェーンコードのパッケージIDを照会して保存する必要があります:
```
(digibank admin)$ peer lifecycle chaincode queryinstalled
```
パッケージIDを環境変数として保存します。コンソールから返されたパッケージIDを使用して、この手順を完了します。
```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

Digibankの管理者は、`papercontract`のチェーンコード定義を承認できるようになりました:
```
(digibank admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

### Commit the chaincode definition to the channel

DigiBankとMagnetoCorpの両方が`papernet`チェーンコードを承認したので、チャネルにチェーンコード定義をコミットするために必要な過半数(2つのうち2つ)の承認があります。チャネルでチェーンコードが正常に定義されると、`papercontract`チェーンコード内の`CommercialPaper`のスマートコントラクトをチャネルのクライアントアプリケーションから起動できます。どちらの組織でもチェーンコードをチャネルにコミットできるため、DigiBank管理者として操作を続行します:

![commercialpaper.commit](./commercial_paper.diagram.commit.png)  *DigiBank管理者が`papercontract`チェーンコードの定義をチャネルにコミットした後、新しいDockerチェーンコードコンテナが、PaperNetの両方のピア上で`papercontract`を実行するために作成されます*

DigiBank管理者は、`peer lifecycle chaincode commit`コマンドを使用して、`papercontract`のチェーンコード定義を`mychannel`にコミットします:
```
(digibank admin)$ peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} --channelID mychannel --name papercontract -v 0 --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
```
チェーンコードコンテナは、チェーンコード定義がチャネルにコミットされた後に起動します。`docker ps`コマンドを使用すると、`papercontract`コンテナが両方のピアで起動されているのを確認できます。

```
(digibank admin)$ docker ps

CONTAINER ID        IMAGE                                                                                                                                                               COMMAND                  CREATED             STATUS              PORTS                                        NAMES
d4ba9dc9c55f        dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535-05cf67c20543ee1c24cf7dfe74abce99785374db15b3bc1de2da372700c25608   "docker-entrypoint.s…"   30 seconds ago      Up 28 seconds                                                    dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535
a944c0f8b6d6        dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec-1a147b6fd2a8bd2ae12db824fad8d08a811c30cc70bc5b6bc49a2cbebc2e71ee   "docker-entrypoint.s…"   31 seconds ago      Up 28 seconds                                                    dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec
```

コンテナには、そのコンテナを起動したピア、そして`papercontract`バージョン`0`を実行していることを示す名前が付けられることに注意してください。

チャネルに`papercontract`チェーンコードをデプロイしたので、MagnetoCorpアプリケーションを使用してコマーシャルペーパーを発行できます。アプリケーションの構造を確認します。

## Application structure

`papercontract`に含まれるスマートコントラクトは、MagnetoCorpのアプリケーション`issue.js`によって呼び出されます。Isabellaはこのアプリケーションを使用して、コマーシャルペーパー`00001`を発行するトランザクションを台帳にサブミットします。`issue`アプリケーションがどのように機能するかを簡単に調べてみましょう。

![commercialpaper.application](./commercial_paper.diagram.8.png) *ゲートウェイを使用すると、アプリケーションはトランザクションの生成、送信、および応答に集中できます。ゲートウェイは、異なるネットワークコンポーネント間でトランザクションの提案、順序付け、および通知処理を調整します。*

`issue`アプリケーションは、Isabellaに代わってトランザクションをサブミットするため、まずIsabellaの[ウォレット](../developapps/wallet.html)からX.509証明書を取得します。この証明書は、ローカルファイルシステムまたはハードウェアセキュリティモジュール[HSM](https://en.wikipedia.org/wiki/Hardware_security_module)に格納されている可能性があります。`issue`アプリケーションは、ゲートウェイを使用してチャネル上のトランザクションをサブミットできます。Hyperledger Fabric SDKは[ゲートウェイ](../developapps/gateway.html)抽象化を提供するため、アプリケーションはアプリケーションロジックに集中しながら、ゲートウェイにネットワーク間の対話を委任できます。ゲートウェイとウォレットを使用すると、Hyperledger Fabricアプリケーションを簡単に記述できます。

では、Isabellaが使用する`issue`アプリケーションを調べてみましょう。Isabella用に別のターミナルウィンドウを開き、`fabric-samples`でMagnetoCorp`/application`フォルダを見つけます:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ ls

addToWallet.js		enrollUser.js		issue.js		package.json
```

`addToWallet.js`は、Isabellaが自分のアイデンティティをウォレットにロードするために使用するプログラムで、`issue.js`はこのアイデンティティを使用して、`papercontract`を呼び出すことでMagnetoCorpの代わりにコマーシャルペーパー`00001`を作成します。

アプリケーション`issue.js`のMagnetoCorpのコピーを含むディレクトリに移動し、コードエディタを使用して確認します:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application
(isabella)$ code issue.js
```

このディレクトリには、issueアプリケーションとそのすべての依存関係が含まれています。

![commercialpaper.vscode2](./commercial_paper.vscode.issue.png) *コマーシャルペーパーアプリケーションディレクトリの内容を表示するコードエディタ。*

`issue.js`の以下の主要なプログラム行に注意してください:

* `const { Wallets, Gateway } = require('fabric-network');`

  このステートメントは、`Wallet`と`Gateway`という2つの主要なHyperledger Fabric SDKクラスをスコープに入れます。


* `const wallet = await Wallets.newFileSystemWallet('../identity/user/isabella/wallet');`

  この文は、アプリケーションがブロックチェーンネットワークチャネルに接続するときに、`isabella`のウォレットを使用することを示します。`Isabella`のX.509証明書はローカルファイルシステムにあるため、アプリケーションは新規`FileSystemWallet`を作成します。アプリケーションは、isabellaのウォレット内の特定のアイデンティティを選択します。


* `await gateway.connect(connectionProfile, connectionOptions);`

  このコード行は、`ConnectionOptions`で参照される識別を使用して、`connectionProfile`で識別されるゲートウェイを使用してネットワークに接続します。

  これらの値に`../gateway/networkConnection.yaml`および`User1@org1.example.com`がどのように使われているか参照してください。


* `const network = await gateway.getNetwork('mychannel');`

  これにより、アプリケーションがネットワークチャネル`mychannel`に接続されます。mychannelには、以前に`papercontract`がデプロイされています。


* `const contract = await network.getContract('papercontract');`

  このステートメントは、アプリケーションに`papercontract`チェーンコードへのアクセスを許可します。アプリケーションがgetContractを発行すると、チェーンコード内に実装されたスマートコントラクトトランザクションにサブミットできます。

* `const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001', ...);`

  このコード行では、スマートコントラクト内で定義された`issue`トランザクションを使用して、ネットワークにトランザクションをサブミットします。`MagnetoCorp`、`00001`... は、新しいコマーシャルペーパーを作成するために`issue`トランザクションで使用される値です。

* `let paper = CommercialPaper.fromBuffer(issueResponse);`

  この文は、`issue`トランザクションからの応答を処理します。応答は、バッファから`ペーパー`(アプリケーションが正しく解釈できる`CommercialPaper`オブジェクト)にデシリアライズする必要があります。


`/application`ディレクトリにある他のファイルを調べて、`issue.js`がどのように動作するかを理解し、アプリケーション[トピック](../developapps/application.html)でその実装方法を詳しく読んでください。

## Application dependencies

`issue.js`アプリケーションはJavaScriptで作成され、PaperNetネットワークのクライアントとして機能するNode.js環境で実行されるように設計されています。一般的に、MagnetoCorpのアプリケーションは多くの外部Node.jsパッケージ上に構築され、開発の品質と速度が向上しています。YAMLゲートウェイコネクションプロファイルを処理する`js-yaml`[パッケージ](https://www.npmjs.com/package/js-yaml)、または`Gateway`および`Wallet`クラスにアクセスする`fabric-network`[パッケージ](https://www.npmjs.com/package/fabric-network)が、`issue.js`にどのように含まれているかを考慮してください:

```JavaScript
const yaml = require('js-yaml');
const { Wallets, Gateway } = require('fabric-network');
```

これらのパッケージは、`npm install`コマンドを使用して[npm](https://www.npmjs.com/)からローカルファイルシステムにダウンロードする必要があります。通常、パッケージは実行時に使用するために、アプリケーションディレクトリからの相対パスで`/node_modules`ディレクトリにインストールする必要があります。

`package.json`ファイルを開き、ファイルの"dependencies"セクションを調べて、`issue.js`がダウンロードするパッケージとその正確なバージョンを識別する方法を確認します。

**npm**のバージョン管理は非常に強力です。詳しくは[こちら](https://docs.npmjs.com/getting-started/semantic-versioning)をご覧ください。

`npm install`コマンドを使用して、これらのパッケージをインストールしてみましょう。インストールが完了するまで、1分ほどかかる場合があります:

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ npm install

(           ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

このコマンドでディレクトリが更新されたことを確認してください:

```
(isabella)$ ls

enrollUser.js 		node_modules	      	package.json
issue.js	      	package-lock.json
```

`node_modules`ディレクトリを調べて、インストールされているパッケージを確認します。`js-yaml`と`fabric-network`はそれ自体が他のnpmパッケージ上に構築されているので、たくさんあります! `package-lock.json`[ファイル](https://docs.npmjs.com/files/package-lock.json)はインストールされている正確なバージョンを識別するので、テストや問題の診断、実績のあるアプリケーションの提供など、環境を正確に再現したい場合には非常に役立ちます。

## Wallet

Isabellaは、`issue.js`を実行してMagnetoCorpのコマーシャルペーパー`00001`を発行する準備がほぼ整いました。実行するタスクはあと1つだけ残っています。`issue.js`はIsabellaの代理として動作するため、MagnetoCorpはこれらの事実を反映する彼女の[wallet](../developapps/wallet.html)からのアイデンティティを使用します。ここで、ウォレットに適切なX.509資格証明を生成する、この1回限りのアクティビティを実行する必要があります。

PaperNet上のMagnetoCorpの証明機関`ca_org2`には、ネットワークのデプロイ時に登録されたアプリケーションユーザーがあります。Isabellaは、アイデンティティ名とシークレットを使用して、`issue.js`アプリケーションのX.509暗号化マテリアルを生成できます。CAを使用してクライアント側の暗号化マテリアルを生成するプロセスは、**エンロールメント**と呼ばれます。実際のシナリオでは、ネットワークオペレータが、CAに登録されたクライアントアイデンティティの名前とシークレットをアプリケーション開発者に提供します。開発者は、資格証明を使用してアプリケーションをエンロールし、ネットワークと対話します。

`enrollUser.js`プログラムは`fabric-ca-client`クラスを使用して秘密鍵と公開鍵のペアを生成し、認証局に**証明書署名要求**を発行します。Isabellaによって送信されたアイデンティティの名とシークレットが認証局に登録された資格証明と一致した場合、認証局は公開鍵をエンコードする証明書を発行して署名し、IsabellaがMagnetoCorpに属していることを証明します。署名要求が完了すると、`enrollUser.js`はIsabellaのウォレットに秘密鍵と署名証明書を格納します。Node SDKが`fabric-ca-client`クラスを使用してこれらのタスクを完了する方法については、`enrollUser.js`ファイルを参照してください。

Isabellaのターミナルウィンドウで、`enrollUser.js`プログラムを実行して、Isabellaのウォレットにアイデンティティ情報を追加します:

```
(isabella)$ node enrollUser.js

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/magnetocorp/identity/user/isabella/wallet
Successfully enrolled client user "isabella" and imported it into the wallet
```

次に、このプログラムの結果、つまりPaperNetへのトランザクションのサブミットに使用されるウォレットの内容に注目します:

```
(isabella)$ ls ../identity/user/isabella/wallet/

isabella.id
```

Isabellaは複数のアイデンティティをウォレットに格納できますが、この例では1つのアイデンティティしか使用しません。`wallet`フォルダには、Isabellaがネットワークに接続するために必要な情報を提供する`isabella.id`ファイルが含まれています。Isabellaが使用する他のIDには、独自のファイルがあります。このファイルを開くと、`issue.js`がIsabellaに代わって使用するアイデンティティ情報をJSONファイル内で確認できます。出力はわかりやすいようにフォーマットされています。
```
(isabella)$  cat ../identity/user/isabella/wallet/*

{
  "credentials": {
    "certificate": "-----BEGIN CERTIFICATE-----\nMIICKTCCAdCgAwIBAgIQWKwvLG+sqeO3LwwQK6avZDAKBggqhkjOPQQDAjBzMQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMi5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eu\nb3JnMi5leGFtcGxlLmNvbTAeFw0yMDAyMDQxOTA5MDBaFw0zMDAyMDExOTA5MDBa\nMGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T\nYW4gRnJhbmNpc2NvMQ8wDQYDVQQLEwZjbGllbnQxHzAdBgNVBAMMFlVzZXIxQG9y\nZzIuZXhhbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4TnTblx0k\ngfqX+NN7F76Me33VTq3K2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYl\nt20yU7n/53dbo00wSzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNV\nHSMEJDAigCDOCdm4irsZFU3D6Hak4+84QRg1N43iwg8w1V6DRhgLyDAKBggqhkjO\nPQQDAgNHADBEAiBhzKix1KJcbUy9ey5ulWHRUMbqdVCNHe/mRtUdaJagIgIgYpbZ\nXf0CSiTXIWOJIsswN4Jp+ZxkJfFVmXndqKqz+VM=\n-----END CERTIFICATE-----\n",
    "privateKey": "-----BEGIN PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQggs55vQg2oXi8gNi8\nNidE8Fy5zenohArDq3FGJD8cKU2hRANCAAT4TnTblx0kgfqX+NN7F76Me33VTq3K\n2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYlt20yU7n/53db\n-----END PRIVATE KEY-----\n"
  },
  "mspId": "Org2MSP",
  "type": "X.509",
  "version": 1
}
```

このファイルでは、次のことがわかります:

* `"privateKey":` Isabellaに代わってトランザクションに署名するために使用されるが、彼女の直接のコントロールの外には配布されません。

* `"証明書":` 証明書の作成時に認証局によって追加されたIsabellaの公開鍵と他のX.509属性を含みます。この証明書はネットワークに配布されます。これにより、異なる時に異なるアクターが、Isabellaの秘密鍵によって作成された情報を暗号で検証できます。

証明書の詳細については、[こちら](../identity/identity.html#digital-certificates)から更に学ぶことができます。実際には、証明書ファイルには、Isabellaの組織や役割などのFabric固有のメタデータも含まれています。詳細については、[ウォレット](../developapps/wallet.html)のトピックを参照してください。

## Issue application

Isabellaは、`issue.js`を使って、MagnetoCorpのコマーシャルペーパー`00001`を発行するトランザクションをサブミットすることができるようになりました:

```
(isabella)$ node issue.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper issue transaction.
Process issue transaction response.{"class":"org.papernet.commercialpaper","key":"\"MagnetoCorp\":\"00001\"","currentState":1,"issuer":"MagnetoCorp","paperNumber":"00001","issueDateTime":"2020-05-31","maturityDateTime":"2020-11-30","faceValue":"5000000","owner":"MagnetoCorp"}
MagnetoCorp commercial paper : 00001 successfully issued for value 5000000
Transaction complete.
Disconnect from Fabric gateway.
Issue program complete.
```

`node`コマンドは、Node.js環境を初期化し、`issue.js`を実行します。プログラムの出力から、MagnetoCorpコマーシャルペーパー 00001 が額面500万米ドルで発行されたことがわかります。

ここまで見てきた通り、これを実現するために、アプリケーションは`papercontract.js`内の`CommercialPaper`スマートコントラクトで定義された`issue`トランザクションを起動します。スマートコントラクトは、Fabric APIを介して台帳と対話し、特に`putState()`および`getState()`を使用して、新しいコマーシャルペーパーをワールドステート内のベクトル状態として表します。このベクトル状態が、スマートコントラクト内で定義された`buy`トランザクションおよび`redeem`トランザクションによって後でどのように操作されるかについて説明します。

常に、基盤となるFabric SDKがトランザクションのエンドースメント、順序付け、通知プロセスを処理し、アプリケーションのロジックを単純化します。SDKは[ゲートウェイ](../developapps/gateway.html)を使用してネットワークの詳細を抽象化し、[connectionOptions](../developapps/connectionoptions.html)を使用してトランザクションの再試行などのより高度な処理戦略を宣言します。

次に、DigiBankアプリケーションを使用してコマーシャルペーパーを購入するDigiBankの従業員であるBalajiに重点を置き、MagnetoCorp 00001 のライフサイクルを見てみましょう。

## Digibank applications

Balajiは、DigiBankの`buy`アプリケーションを使用して、コマーシャルペーパー`00001`の所有権をMagnetoCorpからDigiBankに譲渡するトランザクションを台帳にサブミットします。`CommercialPaper`のスマート契約は、MagnetoCorpの申請で使用されるものと同じですが、今回はトランザクションが異なります。`issue`ではなく`buy`です。DigiBankのアプリケーションがどのように機能するかを調べてみましょう。

Balaji用の別のターミナルウィンドウを開きます。`fabric-samples`で、アプリケーション`buy.js`が格納されているDigiBankアプリケーションディレクトリに移動し、エディタでそれを開きます:

```
(balaji)$ cd commercial-paper/organization/digibank/application/
(balaji)$ code buy.js
```

ご覧のように、このディレクトリには、Balajiが使用する`buy`アプリケーションと`redeem`アプリケーションの両方が含まれています。


![commercialpaper.vscode3](./commercial_paper.diagram.12.png) *`buy.js`と`redeem.js`のアプリケーションを含むDigiBankのコマーシャルペーパーディレクトリ。*

DigiBankの`buy.js`アプリケーションは、MagnetoCorpの`issue.js`と構造がよく似ていますが、2つの重要な違いがあります:


  * **アイデンティティ**: ユーザーがMagnetoCorpの`Isabella`ではなくDigiBankのユーザーである`Balaji`

    ```JavaScript
    const wallet = await Wallets.newFileSystemWallet('../identity/user/balaji/wallet');
    ```

    アプリケーションがPaperNetのネットワークチャネルに接続するときに、`baraji`のウォレットをどのように使用するかを見てください。`buy.js`は`baraji`ウォレット内の特定のアイデンティティを選択します。


  * **トランザクション**: 起動されたトランザクションは、`issue`ではなく`buy`です

    ```JavaScript
    const buyResponse = await contract.submitTransaction('buy', 'MagnetoCorp', '00001', ...);
    ```

    `MagnetoCorp`,`00001`, ...の値を持つ`buy`トランザクションがサブミットされ、これらの値は、コマーシャルペーパー`00001`の所有権をDigiBankに移転するために`CommercialPaper`スマートコントラクトクラスによって使用されます。

`application`ディレクトリにある他のファイルを調べて、アプリケーションの動作を理解し、アプリケーション[トピック](../developapps/application.html)で`buy.js`がどのように実装されているかを詳細に読んでください。

## Run as DigiBank

コマーシャルペーパーを購入および償還するDigiBankのアプリケーションは、MagnetoCorpのissueアプリケーションと非常によく似た構造を持っています。したがって、これらのアプリケーションをコマーシャルペーパーの購入および償還に使用できるように、これらのアプリケーションの依存関係をインストールし、Balajiのウォレットを設定します。

MagnetoCorpの場合と同様に、Digibankは``npm install``コマンドを使用して必要なアプリケーションパッケージをインストールする必要がありますが、これも短時間で完了します。

DigiBank管理者ウィンドウで、アプリケーションの依存関係をインストールします:

```
(digibank admin)$ cd commercial-paper/organization/digibank/application/
(digibank admin)$ npm install

(            ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

Balajiのコマンドウィンドウで、`enrollUser.js`プログラムを実行して証明書と秘密鍵を生成し、ウォレットに渡します:
```
(balaji)$ node enrollUser.js

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/digibank/identity/user/balaji/wallet
Successfully enrolled client user "balaji" and imported it into the wallet
```

`addToWallet.js`プログラムは、彼のウォレットに`balaji`のアイデンティティ情報を追加し、`buy.js`と`redeem.js`が`PaperNet`にトランザクションを送信するために使用します。

Isabellaと同様に、Balajiも複数のアイデンティティをウォレットに格納できますが、この例では1つのアイデンティティしか使用していません。`digibank/identity/user/balaji/wallet/balaji.id`にある対応するIDファイルは、Isabellaと非常によく似ています。自由に調べてみてください。

## Buy application

Balajiは`buy.js`を使ってMagnetoCorpのコマーシャルペーパー 00001 の所有権をDigiBankに譲渡するトランザクションを行うことが今できる状態です。

Balajiのウィンドウで`buy`アプリケーションを実行します:

```
(balaji)$ node buy.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper buy transaction.
Process buy transaction response.
MagnetoCorp commercial paper : 00001 successfully purchased by DigiBank
Transaction complete.
Disconnect from Fabric gateway.
Buy program complete.
```

MagnetoCorpのコマーシャルペーパー 00001 がDigiBankの代理としてBalajiによって正常に購入されたというプログラム出力を見ることができます。`buy.js`は、`CommercialPaper`のスマートコントラクトで定義された`buy`トランザクションを呼び出しました。このスマートコントラクトでは、`putState()`と`getState()`のFabric APIを使用して、ワールドステート内でコマーシャルペーパー`00001`を更新しました。これまで見てきたように、コマーシャルペーパーを購入して発行するアプリケーションロジックは、スマートコントラクトロジックと非常によく似ています。

## Redeem application

コマーシャルペーパー 00001 のライフサイクルにおける最後のトランザクションは、DigiBankがそれをMagnetoCorpで償還することです。Balajiは、スマートコントラクト内で償還ロジックを実行するために、`redeem.js`を使用してトランザクションをサブミットします。

Balajiのウィンドウで`redeem`トランザクションを実行します:

```
(balaji)$ node redeem.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper redeem transaction.
Process redeem transaction response.
MagnetoCorp commercial paper : 00001 successfully redeemed with MagnetoCorp
Transaction complete.
Disconnect from Fabric gateway.
Redeem program complete.
```

ここでも、`redeem.js`が`CommercialPaper`で定義された`redeem`トランザクションを起動したときに、コマーシャルしてコマーシャルペーパー 00001 が正常に償還されたかを見てください。ここでも、ワールドステート内のコマーシャルペーパー`00001`を更新して、所有権がそのペーパーの発行者であるMagnetoCorpに戻ったことを反映しています。

## Clean up

コマーシャルペーパーのチュートリアルを終了する時には、スクリプトを使用して環境をクリーンアップできます。コマンドウィンドウを使用して、コマーシャルペーパーのサンプルのルートディレクトリに戻ります:
```
cd fabric-samples/commercial-paper
```
その後、次のコマンドを使用してネットワークを停止できます:
```
./network-clean.sh
```
このコマンドは、logspoutツールに加えて、ネットワークのピア、CouchDBコンテナ、およびオーダリングノードを停止します。また、IsabellaとBalajiのために作成したアイデンティティも削除します。台帳のデータはすべて失われることに注意してください。チュートリアルをもう一度実行する場合は、クリーンな初期状態から開始します。

## Further reading

このチュートリアルで示されているアプリケーションとスマートコントラクトがどのように機能するかを詳細に理解するには、[Developing Applications](../developapps/developing_applications.html)を参照してください。このトピックでは、コマーシャルペーパーのシナリオ、 PaperNet のビジネスネットワーク、その関係者、およびアプリケーションとスマートコントラクトがどのように機能するかについて詳しく説明します。

また、このサンプルを使用して、独自のアプリケーションやスマートコントラクトの作成を開始することもできます!
<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
