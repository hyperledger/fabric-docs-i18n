# Deploying a smart contract to a channel

エンドユーザはスマートコントラクトを呼び出すことでブロックチェーン台帳と対話します。Hyperledger Fabricでは、スマートコントラクトはチェーンコードと呼ばれるパッケージでデプロイされます。トランザクションの検証や台帳のクエリを行う組織は、チェーンコードをピアにインストールする必要があります。チャネルに参加したピアにチェーンコードがインストールされると、チャネルメンバーはチェーンコードをチャネルにデプロイし、チェーンコードのスマートコントラクトを使用して、チャネル台帳のアセットを作成または更新できます。

チェーンコードは、Fabricチェーンコードライフサイクルと呼ばれるプロセスを使用してチャネルにデプロイされます。Fabricチェーンコードのライフサイクルでは、トランザクションの作成に使用する前に、チェーンコードの操作方法について複数の組織が合意できます。例えば、エンドースメントポリシーは、トランザクションを検証するためにチェーンコードを実行する必要がある組織を指定しますが、チャネルメンバーは、チェーンコードエンドースメントポリシーに同意するためにFabricチェーンコードライフサイクルを使用する必要があります。チャネルでチェーンコードをデプロイおよび管理する方法の詳細については、[Fabricチェーンコードライフサイクル](./chaincode_lifecycle.html)を参照してください。

このチュートリアルでは、[peer lifecycle chaincode コマンド](./commands/peerlifecycle.html)を使用して、チェーンコードをFabricテストネットワークのチャネルにデプロイする方法について学習します。コマンドを理解したら、このチュートリアルの手順を使用して、独自のチェーンコードをテストネットワークにデプロイしたり、チェーンコードを実稼動ネットワークにデプロイすることができます。このチュートリアルでは、[最初のアプリケーション作成チュートリアル](./write_first_app.html)で使用するasset-transfer (basic)チェーンコードをデプロイします。

**注:** この手順では、v2.0リリースで導入されたFabricチェーンコードライフサイクルを使用します。以前のライフサイクルを使用してチェーンコードをインストールおよびインスタンス化する場合は、[v1.4バージョンのFabricのマニュアル](https://hyperledger-fabric.readthedocs.io/en/release-1.4)を参照してください。

## Start the network

まず、Fabricテストネットワークのインスタンスをデプロイします。作業を始める前に、[前提条件](prereqs.html)と[サンプル、バイナリ、Dockerイメージ](install.html)がインストールされていることを確認してください。次のコマンドを使用して、`fabric-samples`リポジトリのローカルクローン内のtest networkディレクトリに移動します:
```
cd fabric-samples/test-network
```
このチュートリアルでは、既知の初期状態から操作します。次のコマンドは、アクティブまたは古いDockerコンテナを削除し、以前に生成されたアーティファクトを削除します。
```
./network.sh down
```
次のコマンドを使用して、テストネットワークを起動できます:
```
./network.sh up createChannel
```

`createChannel`コマンドは、Org1とOrg2という2つのチャネルメンバを持つ``mychannel``という名前のチャネルを作成します。また、このコマンドは、各組織に属するピアをチャネルに参加させます。ネットワークとチャネルが正常に作成されると、次のメッセージがログに出力されます:
```
========= Channel successfully joined ===========
```

これで、ピアCLIを使用して、次の手順に従ってasset-transfer (basic)チェーンコードをチャネルにデプロイできます:


- [Step one: Package the smart contract](#package-the-smart-contract)
- [Step two: Install the chaincode package](#install-the-chaincode-package)
- [Step three: Approve a chaincode definition](#approve-a-chaincode-definition)
- [Step four: Committing the chaincode definition to the channel](#committing-the-chaincode-definition-to-the-channel)


## Setup Logspout (optional)

この手順は必須ではありませんが、チェーンコードのトラブルシューティングに非常に役立ちます。スマートコントラクトのログを監視するために、管理者は`logspout`[ツール](https://logdna.com/what-is-logspout/)を使用して、一連のDockerコンテナから集約された出力を表示することができます。このツールは、さまざまなDockerコンテナからの出力ストリームを1つの場所に集め、1つのウィンドウで何が起きているかを簡単に見ることができます。これは、管理者がスマートコントラクトをインストールするときに問題をデバッグしたり、開発者がスマートコントラクトを呼び出すときに問題をデバッグしたりするのに役立ちます。一部のコンテナの中には、スマートコントラクトを開始するためだけに作成され、短時間しか存在しない場合もあるため、ネットワークからすべてのログを収集すると便利です。

Logspoutをインストールして構成するスクリプト`monitordocker.sh`は、すでにFabricサンプルの`commercial-paper`サンプルに含まれています。このチュートリアルでも同じスクリプトを使用します。Logspoutツールは、端末に継続的にログをストリームするため、新しい端末ウィンドウを使用する必要があります。新しい端末を開き、`test-network`ディレクトリに移動します。
```
cd fabric-samples/test-network
```

`monitordocker.sh`スクリプトは、任意のディレクトリから実行できます。使いやすいように、`monitordocker.sh`スクリプトを`commercial-paper`のサンプルから作業ディレクトリにコピーします。
```
cp ../commercial-paper/organization/digibank/configuration/cli/monitordocker.sh .
# if you're not sure where it is
find . -name monitordocker.sh
```

次のコマンドを実行すると、Logspoutを起動できます:
```
./monitordocker.sh fabric_test
```
次のような出力が表示されます:
```
Starting monitoring on all containers on the network net_basic
Unable to find image 'gliderlabs/logspout:latest' locally
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
ad60f6b6c009: Pull complete
Digest: sha256:374e06b17b004bddc5445525796b5f7adb8234d64c5c5d663095fccafb6e4c26
Status: Downloaded newer image for gliderlabs/logspout:latest
1f99d130f15cf01706eda3e1f040496ec885036d485cb6bcc0da4a567ad84361

```
最初はログは表示されませんが、チェーンコードをデプロイすると変更されます。このターミナルウィンドウを広くして、フォントを小さくすると便利です。

## Package the smart contract

チェーンコードは、ピアにインストールする前にパッケージ化する必要があります。[Go](#go)、[JavaScript](#javascript)、または[TypeScript](#typescript)で作成されたスマートコントラクトをインストールする場合は、手順が異なります。

### Go

チェーンコードをパッケージ化する前に、チェーンコードの依存関係をインストールする必要があります。Goバージョンのasset-transfer (basic)チェーンコードが格納されているフォルダに移動します。
```
cd fabric-samples/asset-transfer-basic/chaincode-go
```

このサンプルでは、Goモジュールを使用してチェーンコードの依存関係をインストールします。依存関係は、`asset-transfer-basic/chaincode-go`ディレクトリの`go.mod`ファイルにリストされています。このファイルを確認してください。
```
$ cat go.mod
module github.com/hyperledger/fabric-samples/asset-transfer-basic/chaincode-go

go 1.14

require (
        github.com/golang/protobuf v1.3.2
        github.com/hyperledger/fabric-chaincode-go v0.0.0-20200424173110-d7076418f212
        github.com/hyperledger/fabric-contract-api-go v1.1.0
        github.com/hyperledger/fabric-protos-go v0.0.0-20200424173316-dd554ba3746e
        github.com/stretchr/testify v1.5.1
)
```
`go.mod`ファイルは、Fabric コントラクトAPIをスマートコントラクトパッケージにインポートします。`asset-transfer-basic/chaincode-go/chaincode/smartcontract.go`をテキストエディタで開き、スマートコントラクトの開始時にコントラクトAPIを使用して`SmartContract`タイプを定義する方法を確認します:
```
// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}
```

次に、``SmartContract``タイプを使用して、スマートコントラクト内で定義され、ブロックチェーン台帳にデータを読み書きする関数のトランザクションコンテキストを作成します。
```
// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
    exists, err := s.AssetExists(ctx, id)
    if err != nil {
        return err
    }
    if exists {
        return fmt.Errorf("the asset %s already exists", id)
    }

    asset := Asset{
        ID:             id,
        Color:          color,
        Size:           size,
        Owner:          owner,
        AppraisedValue: appraisedValue,
    }
    assetJSON, err := json.Marshal(asset)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState(id, assetJSON)
}
```
GoコントラクトAPIの詳細については、[APIドキュメント](https://github.com/hyperledger/fabric-contract-api-go)と[スマートコントラクト処理のトピック](developapps/smartcontract.html)を参照してください。

スマートコントラクトの依存関係をインストールするには、`asset-transfer-basic/chaincode-go`ディレクトリから次のコマンドを実行します。
```
GO111MODULE=on go mod vendor
```

コマンドが正常に実行されると、goパッケージは`vendor`フォルダ内にインストールされます。

これで依存関係ができたので、チェーンコードパッケージを作成することができます。`test-network`フォルダの作業ディレクトリに戻り、他のネットワークのアーティファクトと一緒にチェーンコードをパッケージ化できるようにします。
```
cd ../../test-network
```

`peer` CLIを使用して、必要な形式のチェーンコードパッケージを作成できます。`peer`バイナリは、`fabric-samples`リポジトリの`bin`フォルダにあります。これらのバイナリをCLIパスに追加するには、次のコマンドを使用します。
```
export PATH=${PWD}/../bin:$PATH
```
また、`fabric-samples`リポジトリの`core.yaml`ファイルをポイントするように`FABRIC_CFG_PATH`を設定する必要があります:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
`peer` CLIを使用できることを確認するには、バイナリのバージョンを確認します。このチュートリアルを実行するには、バイナリのバージョンが`2.0.0`以降である必要があります。
```
peer version
```

[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package)コマンドを使用して、チェーンコードパッケージを作成できるようになりました:
```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-go/ --lang golang --label basic_1.0
```

このコマンドは、現在のディレクトリに`basic.tar.gz`という名前のパッケージを作成します。`--lang`フラグはチェーンコード言語を指定するために使用され、`--path`フラグはスマートコントラクトコードの場所を提供します。パスは、完全修飾パスまたは現在の作業ディレクトリからの相対パスである必要があります。`--label`フラグを使用して、インストール後にチェーンコードを識別するチェーンコードラベルを指定します。ラベルには、チェーンコード名とバージョンを含めることをお勧めします。

これで、チェーンコードパッケージが作成されたので、テストネットワークのピアに[チェーンコードをインストール](#install-the-chaincode-package)できます。

### JavaScript

チェーンコードをパッケージ化する前に、チェーンコードの依存関係をインストールする必要があります。JavaScriptバージョンのasset-transfer (basic)チェーンコードが格納されているフォルダに移動します。
```
cd fabric-samples/asset-transfer-basic/chaincode-javascript
```

依存関係は、`asset-transfer-basic/chaincode-javascript`ディレクトリの`package.json`ファイルにリストされます。このファイルを確認してください。依存関係のセクションは次のとおりです。
```
"dependencies": {
		"fabric-contract-api": "^2.0.0",
		"fabric-shim": "^2.0.0"
```
`package.json`ファイルは、Fabricコントラクトクラスをスマートコントラクトパッケージにインポートします。`lib/assetTransfer.js`をテキストエディタで開くと、コントラクトクラスがスマートコントラクトにインポートされ、asset-transfer (basic)クラスの作成に使用されていることが確認できます。
```
const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {
	...
}

```

``AssetTransfer``クラスは、ブロックチェーン台帳へデータを読み書きするスマートコントラクト内で定義された関数のトランザクションコンテキストを提供します。
```
async CreateAsset(ctx, id, color, size, owner, appraisedValue) {
        const asset = {
            ID: id,
            Color: color,
            Size: size,
            Owner: owner,
            AppraisedValue: appraisedValue,
        };

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }
```
JavaScriptコントラクトAPIの詳細については、[APIドキュメント](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/)と[スマートコントラクト処理のトピック](developapps/smartcontract.html)を参照してください。

スマートコントラクトの依存関係をインストールするには、`asset-transfer-basic/chaincode-javascript`ディレクトリから次のコマンドを実行します。
```
npm install
```

コマンドが正常に実行されると、JavaScriptパッケージは`node_modules`フォルダ内にインストールされます。

これで依存関係ができたので、チェーンコードパッケージを作成することができます。`test-network`フォルダーの作業ディレクトリに戻り、他のネットワークのアーティファクトと一緒にチェーンコードをパッケージ化できるようにします。
```
cd ../../test-network
```

`peer` CLIを使用して、必要なフォーマットでチェーンコードパッケージを作成できます。`peer`バイナリは`fabric-samples`リポジトリの`bin`フォルダにあります。これらのバイナリをCLIパスに追加するには、次のコマンドを使用します:
```
export PATH=${PWD}/../bin:$PATH
```
また、`fabric-samples`リポジトリの`core.yaml`ファイルを指すように`FABRIC_CFG_PATH`を設定する必要があります:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
`peer` CLIを使用できることを確認するには、バイナリのバージョンをチェックしてください。このチュートリアルを実行するには、バイナリのバージョンが`2.0.0`以降である必要があります。
```
peer version
```

[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package)コマンドを使用して、チェーンコードパッケージを作成できるようになりました:
```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_1.0
```

このコマンドは、現在のディレクトリに``basic.tar.gz``という名前のパッケージを作成します。`--lang`フラグはチェーンコード言語を指定するために使用され、`--path`フラグはスマートコントラクトコードの場所を提供します。`--label`フラグを使用して、インストール後にチェーンコードを識別するチェーンコードラベルを指定します。ラベルには、チェーンコード名とバージョンを含めることをお勧めします。

これで、チェーンコードパッケージが作成されたので、テストネットワークのピアに[チェーンコードをインストール](#install-the-chaincode-package)できます。

## Typescript

チェーンコードをパッケージ化する前に、チェーンコードの依存関係をインストールする必要があります。Typescriptバージョンのasset-transfer (basic)チェーンコードが格納されているフォルダに移動します。
```
cd fabric-samples/asset-transfer-basic/chaincode-typescript
```

依存関係は`asset-transfer-basic/chaincode-typescript`ディレクトリにある`package.json`ファイルに記載されています。このファイルをよく調べてみてください。以下に表示する依存関係のセクションを見つけることができます。
```
"dependencies": {
               "fabric-contract-api": "^2.0.0",
               "fabric-shim": "^2.0.0"
```
`package.json` ファイルは、Fabric のコントラクトクラスをスマートコントラクトパッケージにインポートします。テキストエディタで `src/assetTransfer.ts` を開くと、スマートコントラクトにインポートされ、asset-transfer (basic)クラスを作成するために使用されたコントラクトクラスを確認することができます。また、Assetクラスは型定義ファイル `asset.ts` からインポートされていることに注意してください。
```
import { Context, Contract } from 'fabric-contract-api';
import { Asset } from './asset';

export class AssetTransfer extends Contract {
	...
}

```

``AssetTransfer`` クラスは、スマートコントラクト内で定義された、ブロックチェーン台帳へのデータの読み書きを行う関数にトランザクションコンテキストを提供します。
```
 // CreateAsset issues a new asset to the world state with given details.
    public async CreateAsset(ctx: Context, id: string, color: string, size: number, owner: string, appraisedValue: number) {
        const asset = {
            ID: id,
            Color: color,
            Size: size,
            Owner: owner,
            AppraisedValue: appraisedValue,
        };

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }

```
JavaScriptのコントラクトAPIについては、[API documentation](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/)や[smart contract processing topic](developapps/smartcontract.html)で詳細を確認することが可能です。

スマートコントラクトの依存関係をインストールするには、`asset-transfer-basic/chaincode-typescript`ディレクトリから次のコマンドを実行します。
```
npm install
```

コマンドが正常に実行されると、JavaScriptパッケージが `npm_modules` フォルダへインストールされます。

依存関係を解決したところで、チェーンコードパッケージを作成することができます。`test-network` フォルダの作業ディレクトリに戻り、他のネットワークのアーティファクトと一緒にチェーンコードをパッケージ化できるようにします。
```
cd ../../test-network
```

`peer` CLIを使用して、必要なフォーマットでチェーンコードパッケージを作成できます。`peer`バイナリは`fabric-samples`リポジトリの`bin`フォルダにあります。これらのバイナリをCLIパスに追加するには、次のコマンドを使用します:
```
export PATH=${PWD}/../bin:$PATH
```
また、`fabric-samples`リポジトリの`core.yaml`ファイルを指すように`FABRIC_CFG_PATH`を設定する必要があります:
```
export FABRIC_CFG_PATH=$PWD/../config/
```
`peer` CLIを使用できることを確認するには、バイナリのバージョンをチェックしてください。このチュートリアルを実行するには、バイナリのバージョンが`2.0.0`以降である必要があります。
```
peer version
```

[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package)コマンドを使用して、チェーンコードパッケージを作成できるようになりました:
```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-typescript/ --lang node --label basic_1.0
```

このコマンドは、現在のディレクトリに``basic.tar.gz``という名前のパッケージを作成します。`--lang`フラグはチェーンコード言語を指定するために使用され、`--path`フラグはスマートコントラクトコードの場所を提供します。`--label`フラグを使用して、インストール後にチェーンコードを識別するチェーンコードラベルを指定します。ラベルには、チェーンコード名とバージョンを含めることをお勧めします。

これで、チェーンコードパッケージが作成されたので、テストネットワークのピアに[チェーンコードをインストール](#install-the-chaincode-package)できます。

## Install the chaincode package

asset-transfer (basic)スマートコントラクトをパッケージ化したら、チェーンコードをピアにインストールできます。チェーンコードは、トランザクションを承認するすべてのピアにインストールする必要があります。ここでは、Org1とOrg2の両方からのエンドースメントを必要とするエンドースメントポリシーを設定するので、両方の組織が運営するピアにチェーンコードをインストールする必要があります:

- peer0.org1.example.com
- peer0.org2.example.com

最初に、Org1ピアにチェーンコードをインストールしましょう。`peer` CLIをOrg1管理ユーザとして操作するには、次の環境変数を設定します。`CORE_PEER_ADDRESS`は、Org1ピアである`peer0.org1.example.com`を指すように設定されます。
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

[peer lifecycle chaincode install](commands/peerlifecycle.html#peer-lifecycle-chaincode-install)コマンドを発行して、チェーンコードをピアにインストールします:
```
peer lifecycle chaincode install basic.tar.gz
```

コマンドが成功すると、ピアはパッケージ識別子を生成して返します。このパッケージIDは、次のステップでチェーンコードを承認するために使用されます。次のような出力が表示されます:
```
2020-07-16 10:09:57.534 CDT [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:e2db7f693d4aa6156e652741d5606e9c5f0de9ebb88c5721cb8248c3aead8123\022\tbasic_1.0" >
2020-07-16 10:09:57.534 CDT [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:e2db7f693d4aa6156e652741d5606e9c5f0de9ebb88c5721cb8248c3aead8123
```

これで、Org2ピアにチェーンコードをインストールできます。次の環境変数を設定して、Org2管理者として動作し、Org2ピアである`peer0.org2.example.com`をターゲットにします。
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

次のコマンドを発行して、チェーンコードをインストールします:
```
peer lifecycle chaincode install basic.tar.gz
```

チェーンコードは、チェーンコードのインストール時にピアによって構築されます。スマートコントラクトコードに問題がある場合、installコマンドはチェーンコードからビルドエラーを返します。

## Approve a chaincode definition

チェーンコードパッケージをインストールしたら、組織のチェーンコード定義を承認する必要があります。定義には、名前、バージョン、チェーンコードエンドースメントポリシーなど、チェーンコードガバナンスの重要なパラメータが含まれます。

デプロイする前にチェーンコードを承認する必要があるチャネルメンバのセットは、`/Channel/Application/LifecycleEndorsement`ポリシーによって管理されます。デフォルトでは、このポリシーでは、チャネルで使用する前に、チャネルメンバーの過半数がチェーンコードを承認する必要があります。チャネルには組織が2つしかなく、2の過半数が2であるため、Org1およびOrg2がasset-transfer (basic)のチェーンコード定義を承認する必要があります。

組織がチェーンコードをピアにインストールした場合、組織が承認したチェーンコード定義にパッケージIDを含める必要があります。パッケージIDは、ピアにインストールされたチェーンコードを承認済みのチェーンコード定義に関連付けるために使用され、組織がチェーンコードを使用してトランザクションをエンドースできるようにします。チェーンコードのパッケージIDを検索するには、[peer lifecycle chaincode queryinstalled](commands/peerlifecycle.html#peer-lifecycle-chaincode-queryinstalled)コマンドを使用してピアに照会します。
```
peer lifecycle chaincode queryinstalled
```

パッケージIDは、チェーンコードラベルとチェーンコードバイナリのハッシュの組み合わせです。すべてのピアが同じパッケージIDを生成します。次のような出力が表示されます:
```
Installed chaincodes on peer:
Package ID: basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: basic_1.0
```

パッケージIDは、チェーンコードを承認するときに使用するので、環境変数として保存します。 `peer lifecycle chaincode queryinstalled`から返されたパッケージIDを、次のコマンドに貼り付けます。**注:** パッケージIDはすべてのユーザで同じではないため、前の手順でコマンドウィンドウから返されたパッケージIDを使用してこの手順を完了する必要があります。
```
export CC_PACKAGE_ID=basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3
```

環境変数は`peer` CLIをOrg2管理者として動作するように設定されているため、asset-transfer (basic)のチェーンコード定義をOrg2として承認できます。チェーンコードは組織レベルで承認されるため、コマンドは1つのピアのみをターゲットにする必要があります。承認は、ゴシップを使用して組織内の他のピアに配布されます。次のように、[peer lifecycle chaincode approveformyorg](commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg)コマンドを使用して、チェーンコード定義を承認します:
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

上記のコマンドは、`--package-id`フラグを使用して、パッケージ識別子をチェーンコード定義に含めます。`--sequence`パラメータは、チェーンコードが定義または更新された回数を追跡する整数です。チェーンコードはチャネルに初めてデプロイされるため、シーケンス番号は1です。asset-transfer (basic)チェーンコードがアップグレードされると、シーケンス番号が2に増分されます。Fabric Chaincode Shim APIで提供される低レベルのAPIを使用している場合は、上記のコマンドに`--init-required`フラグを渡して、Init関数の実行を要求し、チェーンコードを初期化できます。チェーンコードの最初の呼び出しは、チェーンコードの他の関数を使用して台帳と対話する前に、Init関数をターゲットにし、`--isInit`フラグを含める必要があります。

`approveformyorg`コマンドに``--signature-policy``または``--channel-config-policy``引数を指定して、チェーンコードエンドースメントポリシーを指定できます。エンドースメントポリシーは、異なるチャネルメンバに属するいくつのピアが、当該のチェーンコードに対してトランザクションを検証する必要があるかを指定します。我々はポリシーを設定しなかったので、asset-transfer (basic) の定義ではデフォルトのエンドースメントポリシーを使用します。このポリシーでは、トランザクションが提出されたときに、存在しているチャネルメンバーの過半数によってトランザクションがエンドースされることが要求されます。つまり、新しい組織がチャネルに追加されたり、チャネルから削除されたりすると、エンドースメントポリシーが自動的に更新され、より多くのエンドースメントが必要になったり、より少ないエンドースメントが必要になったりします。このチュートリアルでは、デフォルトポリシーは2つのうちの2つの過半数を必要とし、トランザクションはOrg1とOrg2のピアによって承認される必要があります。ユーザー設定のエンドースメントポリシーを指定する場合は、[エンドースメントポリシー](endorsement-policies.html)操作ガイドを使用して、ポリシー構文について学習できます。

管理者ロールを持つアイデンティティでチェーンコード定義を承認する必要があります。その結果、`CORE_PEER_MSPCONFIGPATH`変数は、管理者アイデンティティを含むMSPフォルダをポイントする必要があります。チェーンコード定義は、クライアントユーザで承認することはできません。承認をオーダリングサービスに送信する必要があります。オーダリングサービスは管理者の署名を検証し、承認をピアに配布します。

チェーンコード定義をOrg1として承認する必要があります。Org1管理者として動作するように、次の環境変数を設定します:
```
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
```

これで、チェーンコード定義をOrg1として承認できます。
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

これで、チャネルにasset-transfer (basic)チェーンコードをデプロイする必要がある多数のユーザができました。(デフォルトのポリシーでは)組織の過半数だけがチェーンコード定義を承認する必要がありますが、すべての組織がチェーンコード定義を承認して、ピアでチェーンコードを開始する必要があります。チャネルメンバーがチェーンコードを承認する前に定義をコミットすると、組織はトランザクションをエンドースできなくなります。そのため、チェーンコード定義をコミットする前に、すべてのチャネルメンバがチェーンコードを承認することをお勧めします。

# Committing the chaincode definition to the channel

十分な数の組織がチェーンコード定義を承認すると、1つの組織がチェーンコード定義をチャネルにコミットできます。チャネルメンバの過半数が定義を承認した場合、コミットトランザクションは成功し、チェーンコード定義で合意されたパラメータがチャネルに実装されます。

[peer lifecycle chaincode checkcommitreadiness](commands/peerlifecycle.html#peer-lifecycle-chaincode-checkcommitreadiness)コマンドを使用すると、チャネルメンバが同じチェーンコード定義を承認しているかどうかをチェックできます。`checkcommitreadiness`コマンドで使用するフラグは、組織のチェーンコードを承認するために使用するフラグと同じです。ただし、`--package-id`フラグを含める必要はありません。
```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
```

このコマンドは、チャネルメンバが`checkcommitreadiness`コマンドで指定されたパラメータを承認したかどうかを表示するJSONマップを生成します:
```json
    {
            "Approvals": {
                    "Org1MSP": true,
                    "Org2MSP": true
            }
    }
```

チャネルのメンバーである両方の組織が同じパラメータを承認しているため、チェーンコード定義をチャネルにコミットする準備ができています。[peer lifecycle chaincode commit](commands/peerlifecycle.html#peer-lifecycle-chaincode-commit)コマンドを使用すると、チェーンコード定義をチャネルにコミットできます。commitコマンドは、組織の管理者がサブミットする必要もあります。
```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```

上記のトランザクションは、`--peerAddresses`フラグを使用して、Org1の`peer0.org1.example.com`とOrg2の`peer0.org2.example.com`をターゲットにします。`commit` トランザクションは、チャネルに参加しているピアにサブミットされ、ピアを運用する組織によって承認されたチェーンコード定義を照会します。このコマンドは、チェーンコードをデプロイするためのポリシーを満たすために、十分な数の組織からピアをターゲットにする必要があります。承認は各組織内に配布されるため、チャネルメンバーに属する任意のピアをターゲットにできます。

チャネルメンバによるチェーンコード定義のエンドースメントは、ブロックに追加し、チャネルに配布するために、オーダリングサービスに提出されます。次に、チャネル上のピアは、十分な数の組織がチェーンコード定義を承認したかどうかを検証します。`peer lifecycle chaincode commit`コマンドは、応答を返す前に、ピアからの検証を待ちます。

チェーンコード定義がチャネルにコミットされたことを確認するには、[peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted)コマンドを使用します。
```
peer lifecycle chaincode querycommitted --channelID mychannel --name basic --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
チェーンコードがチャネルに正常にコミットされた場合、`querycommitted`コマンドはチェーンコード定義のシーケンスとバージョンを返します:
```
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
```

## Invoking the chaincode

チェーンコード定義がチャネルにコミットされると、チェーンコードがインストールされたチャネルに参加しているピア上でチェーンコードが開始されます。これで、asset-transfer (basic)チェーンコードをクライアントアプリケーションから呼び出す準備ができました。次のコマンドを使用して、台帳にassetsの初期セットを作成します。invokeコマンドは、チェーンコードエンドースメントポリシーを満たすために十分な数のピアをターゲットにする必要があることに注意してください。
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
```
コマンドが正常に実行されると、次のような応答が返されます:
```
2020-02-12 18:22:20.576 EST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
```

クエリ関数を使用して、チェーンコードで作成されたassetsのセットを読み込むことができます:
```
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

クエリに対する応答は、次のassetsのリストになるはずです:
```
[{"Key":"asset1","Record":{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300}},
{"Key":"asset2","Record":{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400}},
{"Key":"asset3","Record":{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500}},
{"Key":"asset4","Record":{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600}},
{"Key":"asset5","Record":{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700}},
{"Key":"asset6","Record":{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}}]
```

## Upgrading a smart contract

同じFabricチェーンコードライフサイクルプロセスを使用して、チャネルに既にデプロイされているチェーンコードをアップグレードできます。チャネルメンバは、新しいチェーンコードパッケージをインストールし、新しいパッケージID、新しいチェーンコードバージョン、およびシーケンス番号を1つ増分したチェーンコード定義を承認することで、チェーンコードをアップグレードできます。新しいチェーンコードは、チェーンコード定義がチャネルにコミットされた後に使用できます。このプロセスにより、チャネルメンバーは、チェーンコードがアップグレードされるときに調整を行うことができ、チャネルにデプロイされる前に、十分な数のチャネルメンバーが新しいチェーンコードを使用する準備ができていることを確認できます。

チャネルメンバーは、アップグレードプロセスを使用して、チェーンコードエンドースメントポリシーを変更することもできます。新しいエンドースメントポリシーでチェーンコード定義を承認し、そのチェーンコード定義をチャネルにコミットすることで、チャネルメンバーは新しいチェーンコードパッケージをインストールすることなく、チェーンコードを管理するエンドースメントポリシーを変更できます。

デプロイしたばかりのasset-transfer (basic)チェーンコードをアップグレードするためのシナリオを提供するために、Org1とOrg2が別の言語で書かれたバージョンのチェーンコードをインストールしたいとします。これらの組織は、Fabricチェーンコードライフサイクルを使用してチェーンコードバージョンを更新し、新しいチェーンコードがチャネル上でアクティブになる前に両方の組織インストールされていることを確認します。

ここでは、Org1とOrg2が最初にasset-transfer (basic)チェーンコードのGOバージョンをインストールしたのち、JavaScriptで作成されたチェーンコードを使用する方が快適になったと想定します。最初のステップは、asset-transfer (basic)チェーンコードのJavaScriptバージョンをパッケージ化することです。チュートリアルの実行時にJavaScriptの指示に従ってチェーンコードをパッケージ化した場合は、[Go](#go) または [TypeScript](#typescript)で記述されたチェーンコードをパッケージ化する手順に従って、新しいチェーンコードバイナリをインストールできます。

チェーンコード依存関係をインストールするには、`test-network`ディレクトリから次のコマンドを発行します。
```
cd ../asset-transfer-basic/chaincode-javascript
npm install
cd ../../test-network
```
次に、以下のコマンドを実行して、`test-network`ディレクトリからJavaScriptチェーンコードをパッケージ化することができます。端末を閉じた場合に`peer` CLIを再度使用するために必要な環境変数を設定します。
```
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer lifecycle chaincode package basic_2.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_2.0
```
次のコマンドを実行して、`peer` CLIをOrg1管理者として操作します:
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```
次のコマンドを使用して、新しいチェーンコードパッケージをOrg1ピアにインストールできます。
```
peer lifecycle chaincode install basic_2.tar.gz
```

新しいチェーンコードパッケージは、新しいパッケージIDを作成します。ピアに照会することで、新しいパッケージIDを見つけることができます。
```
peer lifecycle chaincode queryinstalled
```
`queryinstalled`コマンドは、この出力のようにピアにインストールされているチェーンコードのリストを返します。
```
Installed chaincodes on peer:
Package ID: basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: basic_1.0
Package ID: basic_2.0:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4, Label: basic_2.0
```

パッケージラベルを使用して、新しいチェーンコードのパッケージIDを検索し、新しい環境変数として保存できます。このアウトプットは例ですので、あなたのパッケージICとは異なります。コピーペーストはしないでください。
```
export NEW_CC_PACKAGE_ID=basic_2.0:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841
```

Org1は、新しいチェーンコード定義を承認できるようになりました:
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
新しいチェーンコード定義では、JavaScriptチェーンコードパッケージのパッケージIDが使用され、チェーンコードバージョンが更新されます。シーケンスパラメータは、チェーンコードのアップグレードを追跡するためにFabricチェーンコードライフサイクルで使用されるため、Org1でもシーケンス番号を1から2に増分する必要があります。[peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted)コマンドを使用すると、チャネルに最後にコミットされたチェーンコードのシーケンスを検索できます。

ここで、チェーンコードパッケージをインストールし、チェーンコード定義をOrg2として承認して、チェーンコードをアップグレードする必要があります。次のコマンドを実行して、`peer` CLIをOrg2管理者として操作します:
```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```
次のコマンドを使用して、新しいチェーンコードパッケージをOrg2ピアにインストールできます。
```
peer lifecycle chaincode install basic_2.tar.gz
```
これで、Org2の新しいチェーンコード定義を承認できます。
```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
[peer lifecycle chaincode checkcommitreadiness](commands/peerlifecycle.html#peer-lifecycle-chaincode-checkcommitreadiness)コマンドを使用して、シーケンス2のチェーンコード定義がチャネルにコミットする準備ができているかどうかを確認します:
```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json
```

コマンドが次のJSONを返す場合、チェーンコードはアップグレードの準備ができています:
```json
    {
            "Approvals": {
                    "Org1MSP": true,
                    "Org2MSP": true
            }
    }
```

新しいチェーンコード定義がコミットされると、チャネル上のチェーンコードがアップグレードされます。それまでは、以前のチェーンコードは両方の組織のピア上で実行され続けます。Org2では、次のコマンドを使用してチェーンコードをアップグレードできます:
```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
```
コミットトランザクションが成功すると、新しいチェーンコードがすぐに開始されます。チェーンコード定義がエンドースメントポリシーを変更した場合、新しいポリシーが有効になります。

`docker ps`コマンドを使うと、新しいチェーンコードがピア上で起動したことを確認できます:
```
$ docker ps
CONTAINER ID        IMAGE                                                                                                                                                                    COMMAND                  CREATED             STATUS              PORTS                              NAMES
7bf2f1bf792b        dev-peer0.org1.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c-69c9e3e44ed18cafd1e58de37a70e2ec54cd49c7da0cd461fbd5e333de32879b   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org1.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c
985e0967c27a        dev-peer0.org2.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c-158e9c6a4cb51dea043461fc4d3580e7df4c74a52b41e69a25705ce85405d760   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org2.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c
31fdd19c3be7        hyperledger/fabric-peer:latest                                                                                                                                           "peer node start"        About an hour ago   Up About an hour    0.0.0.0:7051->7051/tcp             peer0.org1.example.com
1b17ff866fe0        hyperledger/fabric-peer:latest                                                                                                                                           "peer node start"        About an hour ago   Up About an hour    7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
4cf170c7ae9b        hyperledger/fabric-orderer:latest
```
`--init-required`フラグを使用した場合は、アップグレードしたチェーンコードを使用する前にInit関数を呼び出す必要があります。私たちはInitの実行を要求していないので、新しい車を作成することで新しいJavaScriptのチェーンコードをテストすることができます:
```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"CreateAsset","Args":["asset8","blue","16","Kelley","750"]}'
```
台帳のすべてのassetsを再度クエリして、新規のassetsを表示できます:
```
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

JavaScriptチェーンコードから次のような結果が得られます:
```
[{"Key":"asset1","Record":{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300}},
{"Key":"asset2","Record":{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400}},
{"Key":"asset3","Record":{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500}},
{"Key":"asset4","Record":{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600}},
{"Key":"asset5","Record":{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700}},
{"Key":"asset6","Record":{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}},
"Key":"asset8","Record":{"ID":"asset8","color":"blue","size":16,"owner":"Kelley","appraisedValue":750}}]
```

## Clean up

チェーンコードの使用が終了したら、次のコマンドを使用してLogspoutツールを削除することもできます。
```
docker stop logspout
docker rm logspout
```
次に、`test-network`ディレクトリから次のコマンドを発行して、テストネットワークを停止できます:
```
./network.sh down
```

## Next steps

スマートコントラクトを作成してチャネルにデプロイしたら、Fabric SDKが提供するAPIを使用して、クライアントアプリケーションからスマートコントラクトを呼び出すことができます。これにより、エンドユーザはブロックチェーン台帳上の資産と対話することができます。Fabric SDKを使い始めるには、[Writing Your first application tutorial](write_first_app.html)を参照してください。

## troubleshooting

### Chaincode not agreed to by this org

**問題:** 新しいチェーンコード定義をチャネルにコミットしようとすると、`peer lifecycle chaincode commit`コマンドが次のエラーで失敗します:
```
Error: failed to create signed transaction: proposal response was not successful, error code 500, msg failed to invoke backing implementation of 'CommitChaincodeDefinition': chaincode definition not agreed to by this org (Org1MSP)
```

**解決策:** このエラーを解決するには、`peer lifecycle chaincode checkcommitreadiness`コマンドを使用して、コミットしようとしているチェーンコード定義を承認したチャネルメンバをチェックします。チェーンコード定義のパラメータに異なる値を使用している組織がある場合、コミットトランザクションは失敗します。`peer lifecycle chaincode checkcommitreadiness`は、コミットしようとしているチェーンコード定義を承認しなかった組織を明らかにします:
```
{
	"approvals": {
		"Org1MSP": false,
		"Org2MSP": true
	}
}
```

### Invoke failure

**問題:** `peer lifecycle chaincode commit`トランザクションは成功しましたが、チェーンコードを初めて起動しようとすると、次のエラーで失敗します:
```
Error: endorsement failure during invoke. response: status:500 message:"make sure the chaincode asset-transfer (basic) has been successfully defined on channel mychannel and try again: chaincode definition for 'asset-transfer (basic)' exists, but chaincode is not installed"
```

**解決策:** チェーンコード定義を承認したときに、正しい`--package-id`を設定していない可能性があります。その結果、チャネルにコミットされたチェーンコード定義は、インストールしたチェーンコードパッケージに関連付けられず、チェーンコードはピア上で開始されませんでした。Dockerベースのネットワークを使っている場合は、`docker ps`コマンドを使って、チェーンコードが動作しているかどうかをチェックすることができます:
```
docker ps
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS              PORTS                              NAMES
7fe1ae0a69fa        hyperledger/fabric-orderer:latest   "orderer"           5 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp             orderer.example.com
2b9c684bd07e        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp             peer0.org1.example.com
39a3e41b2573        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
```

チェーンコードコンテナが一覧表示されない場合は、`peer lifecycle chaincode approveformyorg`コマンドを使用して、正しいパッケージIDでチェーンコード定義を承認します。


## Endorsement policy failure

**問題:** チェーンコード定義をチャネルにコミットしようとすると、トランザクションが次のエラーで失敗します:
```
2020-04-07 20:08:23.306 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [5f569e50ae58efa6261c4ad93180d49ac85ec29a07b58f576405b826a8213aeb] committed with status (ENDORSEMENT_POLICY_FAILURE) at localhost:7051
Error: transaction invalidated with status (ENDORSEMENT_POLICY_FAILURE)
```

**解決策:** このエラーは、コミットトランザクションがライフサイクルエンドースメントポリシーを満たすだけのエンドースメントを収集していないために発生します。この問題は、ポリシーを満たすのに十分な数のピアをターゲットとしていないトランザクションが原因で発生する可能性があります。これは、`configtx.yaml`ファイルでデフォルトの`/Channel/Application/Endorsement` ポリシーによって参照される署名ポリシー`Endorsement:`を含まない一部のピア組織の結果である可能性もあります。
```
Readers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
Writers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
Admins:
		Type: Signature
		Rule: "OR('Org2MSP.admin')"
Endorsement:
		Type: Signature
		Rule: "OR('Org2MSP.peer')"
```

[Fabric chaincodeライフサイクルを有効にする](enable_cc_lifecycle.html)場合は、チャネルを`V2_0`機能にアップグレードするだけでなく、新しいFabric2.0チャネルポリシーも使用する必要があります。チャネルには、新しい`/Channel/Application/LifecycleEndorsement`ポリシーと`/Channel/Application/Endorsement` ポリシーを含める必要があります:
```
Policies:
		Readers:
				Type: ImplicitMeta
				Rule: "ANY Readers"
		Writers:
				Type: ImplicitMeta
				Rule: "ANY Writers"
		Admins:
				Type: ImplicitMeta
				Rule: "MAJORITY Admins"
		LifecycleEndorsement:
				Type: ImplicitMeta
				Rule: "MAJORITY Endorsement"
		Endorsement:
				Type: ImplicitMeta
				Rule: "MAJORITY Endorsement"
```

チャネル設定に新しいチャネルポリシーを含めない場合、組織のチェーンコード定義を承認すると、次のエラーが発生します:
```
Error: proposal failed with status: 500 - failed to invoke backing implementation of 'ApproveChaincodeDefinitionForMyOrg': could not set defaults for chaincode definition in channel mychannel: policy '/Channel/Application/Endorsement' must be defined for channel 'mychannel' before chaincode operations can be attempted
```



<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
