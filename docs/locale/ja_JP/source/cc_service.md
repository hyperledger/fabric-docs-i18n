# Chaincode as an external service

Fabric v2.0 は、Fabric外部でのチェーンコードのデプロイと実行をサポートしており、ユーザーはピアから独立してチェーンコードのランタイムを管理できます。
これは、Kubernetesのようなクラウド環境にあるFabricにチェーンコードをデプロイすることを容易にするものです。
すべてのピアでチェーンコードをビルドして起動する代わりに、チェーンコードはFabricの外側でライフサイクルが管理されるサービスとして実行できるようになりました。
この機能は、Fabric v2.0の外部ビルダーとランチャーの機能を利用しており、運用者は、チェーンコードをビルド、起動、ディスカバリするためのプログラムでピアを拡張することができます。
このトピックを読む前に、[External Builder and Launcher](./cc_launcher.html) の内容をよく理解しておく必要があります。

外部ビルダーが利用可能になる前は、チェーンコードパッケージの内容は、チェーンコードバイナリとしてビルドして起動できる特定言語のソースコード・ファイルのセットであることが必要でした。
新しい外部ビルダーとランチャーの機能によって、ユーザーがオプションでビルドプロセスをカスタマイズすることができるようになりました。
チェーンコードを外部サービスとして実行することに関して、ビルドプロセスでは、チェーンコードが実行されているサーバーのエンドポイント情報を指定することができます。
従って、パッケージは単に外部で動いているチェーンコードサーバーのエンドポイント情報と、安全な接続のためのTLSアーティファクトから構成されます。
TLSはオプションですが、単純なテスト環境以外のすべての環境で強く推奨されます。

このトピックの残りの部分では、チェーンコードを外部サービスとして設定する方法について説明します。

* [Packaging chaincode](#packaging-chaincode)
* [Configuring a peer to process external chaincode](#configuring-a-peer-to-process-external-chaincode)
* [External builder and launcher sample scripts](#external-builder-and-launcher-sample-scripts)
* [Writing chaincode to run as an external service](#writing-chaincode-to-run-as-an-external-service)
* [Deploying the chaincode](#deploying-the-chaincode)
* [Running the chaincode as an external service](#running-the-chaincode-as-an-external-service)

**注意:** この機能は高度なものであり、ピアイメージのカスタムパッケージが必要になる可能性があります。
例えば、以下のサンプルでは `jq` と `bash` を使用していますが、これらは現在の公式の `fabric-peer` イメージには含まれていません。

## Packaging chaincode

Fabric v2.0 のチェーンコードライフサイクルでは、チェーンコードは [パッケージ化され](./cc_launcher.html#chaincode-packages)、 `.tar.gz` フォーマットでインストールされます。
以下の `myccpackage.tgz` アーカイブは、必要な構造を示しています。

```sh
$ tar xvfz myccpackage.tgz
metadata.json
code.tar.gz
```

チェーンコードパッケージは、外部のビルダーとランチャープロセスに次の2つの情報を提供するために使用されます。
* チェーンコードが外部サービスであるかどうかを識別します。
`bin/detect` セクションで、 `metadata.json` ファイルを使用したアプローチを説明します。
* release ディレクトリに置かれた `connection.json` ファイルで、チェーンコードのエンドポイント情報を提供します。
`bin/run` セクションで、`connection.json` ファイルについて説明します。

上記の情報を収集するための柔軟性は十分にあります。
[External builder and launcher sample scripts](#external-builder-and-launcher-sample-scripts) にあるサンプルスクリプトは、情報を提供するための簡単なアプローチを示しています。
柔軟性の例として、couchdb インデックスファイルのパッケージ化を考えてみましょう。
[Add the index to your chaincode folder](couchdb_tutorial.html#add-the-index-to-your-chaincode-folder) を参照してください。
以下のサンプルスクリプトは、ファイルを myccpackage.tar.gz にパッケージ化する方法を説明しています。

```
tar cfz code.tar.gz connection.json metadata
tar cfz myccpackage.tgz metadata.json code.tar.gz
```

## Configuring a peer to process external chaincode

このセクションでは、必要な設定について説明します。
* チェーンコードパッケージが外部チェーンコードサービスを識別しているかどうかを検出します。
* リリースディレクトリに `connection.json` ファイルを作成します。

### Modify the peer core.yaml to include the externalBuilder

スクリプトがピアの `bin` ディレクトリに以下のように置かれていると仮定します。
```
    <fully qualified path on the peer's env>
    └── bin
        ├── build
        ├── detect
        └── release
```

ピアの `core.yaml` ファイルの `chaincode` ブロックを変更し、`externalBuilders` 設定要素を追加します。

```yaml
externalBuilders:
     - name: myexternal
       path: <fully qualified path on the peer's env>   
```

### External builder and launcher sample scripts

チェーンコードを外部サービスとして動作させる場合、それぞれのスクリプトが何を含む必要があるかを理解するために、このセクションでは `bin/detect` `bin/build` `bin/release` `bin/run` スクリプトのサンプルを掲載します。

**注:** これらのサンプルでは、json をパースするために `jq` コマンドを使用します。
`jq --version` を実行すると、インストールされているかどうか確認できます。
そうでない場合、 `jq` をインストールするか、スクリプトを適切に修正してください。

#### bin/detect

`bin/detect script` は、チェーンコードパッケージをビルドして起動するために buildpack を使用すべきかどうかを判断する役割を担っています。
チェーンコードが外部サービスである場合、サンプルスクリプトは `metadata.json` ファイル内で `external` に設定された `type` プロパティを探します。

```json
{"path":"","type":"external","label":"mycc"}
```

ピアは2つの引数でdetectを呼び出します。

```
bin/detect CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR
```

`bin/detect` のサンプルスクリプトは以下のものを含みます。

```sh

#!/bin/bash

set -euo pipefail

METADIR=$2
#check if the "type" field is set to "external"
if [ "$(jq -r .type "$METADIR/metadata.json")" == "external" ]; then
    exit 0
fi

exit 1

```

#### bin/build

チェーンコードを外部サービスとして利用する場合、サンプルのビルドスクリプトは チェーンコードパッケージの `code.tar.gz` ファイルに `connection.json` が含まれていると仮定し、それを `BUILD_OUTPUT_DIR` にコピーします。
ピアは3つの引数でビルドスクリプトを呼び出します。

```
bin/build CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR BUILD_OUTPUT_DIR
```

A sample `bin/build` script could contain:

```sh

#!/bin/bash

set -euo pipefail

SOURCE=$1
OUTPUT=$3

#external chaincodes expect connection.json file in the chaincode package
if [ ! -f "$SOURCE/connection.json" ]; then
    >&2 echo "$SOURCE/connection.json not found"
    exit 1
fi

#simply copy the endpoint information to specified output location
cp $SOURCE/connection.json $OUTPUT/connection.json

if [ -d "$SOURCE/metadata" ]; then
    cp -a $SOURCE/metadata $OUTPUT/metadata
fi

exit 0

```

#### bin/release

外部サービスとしてのチェーンコードでは、 `bin/release` スクリプトが `connection.json` を `RELEASE_OUTPUT_DIR` に配置してピアに提供する役割を担います。
`connection.json` ファイルは以下のようなJSON構造になっています。

* **address** - ピアからアクセス可能なチェーンコード・サーバーのエンドポイントです。`<host>:<port>` 形式で指定する必要があります。
* **dial_timeout** - 接続が完了するのを待つ時間。時間単位と一緒に文字列で指定します (例: "10s"、"500ms"、"1m")。指定しない場合、デフォルトは“3s”です。
* **tls_required** - trueまたはfalse。falseの場合、"client_auth_required"、"client_key"、"client_cert"、"root_cert" は必要ありません。デフォルトは "true "です。
* **client_auth_required** - trueの場合、"client_key "と "client_cert "は必要です。デフォルトはfalseです。tls_requiredがfalseの場合、無視されます。
* **client_key** - PEM形式でエンコードされたクライアント秘密鍵の文字列。
* **client_cert** - PEM形式でエンコードされたクライアント証明書の文字列。
* **root_cert** - PEM形式でエンコードされたサーバー(ピア)ルート証明書の文字列。

例：

```json
{
  "address": "your.chaincode.host.com:9999",
  "dial_timeout": "10s",
  "tls_required": "true",
  "client_auth_required": "true",
  "client_key": "-----BEGIN EC PRIVATE KEY----- ... -----END EC PRIVATE KEY-----",
  "client_cert": "-----BEGIN CERTIFICATE----- ... -----END CERTIFICATE-----",
  "root_cert": "-----BEGIN CERTIFICATE---- ... -----END CERTIFICATE-----"
}
```

`bin/build` セクションで述べたように、このサンプルではチェーンコードパッケージが `connection.json` ファイルを直接含んでおり、ビルドスクリプトが `BUILD_OUTPUT_DIR` にコピーしているものと仮定しています。
ピアは2つの引数でリリーススクリプトを呼び出します。

```
bin/release BUILD_OUTPUT_DIR RELEASE_OUTPUT_DIR
```

`bin/release` のサンプルスクリプトは以下のものを含みます。


```sh

#!/bin/bash

set -euo pipefail

BLD="$1"
RELEASE="$2"

if [ -d "$BLD/metadata" ]; then
   cp -a "$BLD/metadata/"* "$RELEASE/"
fi

#external chaincodes expect artifacts to be placed under "$RELEASE"/chaincode/server
if [ -f $BLD/connection.json ]; then
   mkdir -p "$RELEASE"/chaincode/server
   cp $BLD/connection.json "$RELEASE"/chaincode/server

   #if tls_required is true, copy TLS files (using above example, the fully qualified path for these fils would be "$RELEASE"/chaincode/server/tls)

   exit 0
fi

exit 1
```    

## Writing chaincode to run as an external service

現在、外部サービスとしてのチェーンコードは、Go chaincode shimとNode.js chaincode shimでサポートされています。

### Go

Fabric v2.0 では、Go shim API が `ChaincodeServer` という型を提供するようになりました。
開発者はこれを用いてチェーンコードサーバを作成する必要があります。
`Invoke` と `Query` API は影響を受けません。
開発者は `shim.ChaincodeServer` API を利用して、チェーンコードをビルドして、任意の外部環境で実行する必要があります。
以下は、このパターンを説明するためのシンプルなチェーンコードプログラムのサンプルです。

```go

package main

import (
        "fmt"

        "github.com/hyperledger/fabric-chaincode-go/shim"
        pb "github.com/hyperledger/fabric-protos-go/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

func (s *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
        // init code
}

func (s *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
        // invoke code
}

//NOTE - parameters such as ccid and endpoint information are hard coded here for illustration. This can be passed in in a variety of standard ways
func main() {
       //The ccid is assigned to the chaincode on install (using the “peer lifecycle chaincode install <package>” command) for instance
        ccid := "mycc:fcbf8724572d42e859a7dd9a7cd8e2efb84058292017df6e3d89178b64e6c831"

        server := &shim.ChaincodeServer{
                        CCID: ccid,
                        Address: "myhost:9999"
                        CC: new(SimpleChaincode),
                        TLSProps: shim.TLSProperties{
                                Disabled: true,
                        },
                }
        err := server.Start()
        if err != nil {
                fmt.Printf("Error starting Simple chaincode: %s", err)
        }
}
```
チェーンコードを外部サービスとして動作させるためのポイントは `shim.ChaincodeServer` を使用することです。
これは新しい shim API `shim.ChaincodeServer` と以下に説明するチェーンコードサービスのプロパティを使用します。

* **CCID** (string)- CCIDはピア上のチェーンコードのパッケージ名と一致する必要があります。
これは `peer lifecycle chaincode install <package>` CLI コマンドによって返される、インストールされたチェーンコードに関連付けられた `CCID` です。
これはインストール後に "peer lifecycle chaincode queryinstalled" コマンドで取得することができます。
* **Address** (string) - アドレスは、チェーンコードサーバーのリッスンアドレスです。
* **CC** (Chaincode) - CCはInitとInvokeを処理するチェーンコードです。
* **TLSProps** (TLSProperties) - TLSPropsは、チェーンコードサーバーに渡されるTLSプロパティです。
* **KaOpts** (keepalive.ServerParameters) - KaOptsはキープアライブのオプションです。nil の場合、適切なデフォルトが提供されます。

以上により、各自のGo環境に適したチェーンコードをビルドします。

### Node.js

Node.js のチェーンコードのための `fabric-shim` パッケージは、チェーンコードを外部サービスとして動作させるための `shim.server` APIを提供します。
コントラクトAPIを使用している場合、外部サービスモードでコントラクトを実行するには、 `fabric-chaincode-node` CLI で提供されている `server` コマンドを使用するとよいでしょう。

以下は `fabric-shim` を使用したチェーンコードのサンプルです。
```javascript
const shim = require('fabric-shim');

class SimpleChaincode extends shim.ChaincodeInterface {
        async Init(stub) {
                // ... Init code
        }
        async Invoke(stub) {
                // ... Invoke code
        }
}

const server = shim.server(new SimpleChaincode(), {
        ccid: "mycc:fcbf8724572d42e859a7dd9a7cd8e2efb84058292017df6e3d89178b64e6c831",
        address: "0.0.0.0:9999"
});

server.start();
```

`fabric-contract` APIを用いてチェーンコードを外部サービスとして実行するには、 `fabric-chaincode-node start` の代わりに `fabric-chaincode-node server` を使用するだけです。
以下は `package.json` のサンプルです。
```javascript
{
        "scripts": {
                "start": "fabric-chaincode-node server"
        },
        ...
}
```

`fabric-chaincode-node server` を使用する場合、以下のオプションを引数または環境変数として設定する必要があります。
* **CORE_CHAINCODE_ID (--chaincode-id)**: Goチェーンコードの **CCID** を参照してください。
* **CORE_CHAINCODE_ADDRESS (--chaincode-address)**: Goチェーンコードの **アドレス** を参照してください。

TLSが有効な場合、以下の追加オプションが必要です。
* **CORE_CHAINCODE_TLS_CERT_FILE (--chaincode-tls-cert-file)**: 証明書へのパス。
* **CORE_CHAINCODE_TLS_KEY_FILE (--chaincode-tls-key-file)**: 秘密鍵へのパス。

相互TLSが有効な場合、 **CORE_CHAINCODE_TLS_CLIENT_CACERT_FILE (--chaincode-tls-client-cacert-file)** オプションを設定し、受け入れ可能なクライアント証明書に対するCA証明書のパスを指定する必要があります。

## Deploying the chaincode

チェーンコードのデプロイの準備ができたら、[Packaging chaincode](#packaging-chaincode) で説明したようにチェーンコードをパッケージ化し、[Fabric chaincode lifecycle](./chaincode_lifecycle.html) で説明したようにチェーンコードをデプロイすることができます。

## Running the chaincode as an external service

[Writing chaincode to run as an external service](#writing-chaincode-to-run-as-an-external-service) セクションで説明されているように、チェーンコードを作成します。
ビルドした実行ファイルを、Kubernetesなどのお好みの環境で実行するか、ピアマシンのプロセスとして直接実行します。

このように、チェーンコードを外部サービスモデルとして使用すると、各ピアにチェーンコードをインストールする必要がなくなります。
その代わりにチェーンコードのエンドポイントをピアにデプロイして、チェーンコードが動作していると、チェーンコードの定義をチャネルにコミットしてチェーンコードを呼び出すという通常のプロセスを続けることができます。

<!---
Licensed under Creative Commons Attribution 4.0 International License https://creativecommons.org/licenses/by/4.0/
-->
