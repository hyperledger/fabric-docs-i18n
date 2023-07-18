# External Builders and Launchers

Hyperledger Fabric 2.0以前では、チェーンコードのビルドと起動に使用されるプロセスはピアの実装の一部であり、簡単にカスタマイズできませんでした。
ピアにインストールされたすべてのチェーンコードは、ピアにハードコーディングされた言語固有のロジックを使用して "ビルド" されます。
このビルドプロセスは、Dockerコンテナイメージを生成し、ピアにクライアントとして接続されたチェーンコードを実行するためにコンテナが起動されます。

このアプローチは、チェーンコードの実装を少数の言語に制限し、Dockerをデプロイメント環境の一部にする必要があり、チェーンコードを長時間実行するサーバプロセスとして実行することを妨げてきました。

Fabric 2.0から、外部ビルダーとランチャーは、これらの制限を解決します。運用者は、チェーンコードをビルド、起動、ディスカバリするプログラムを利用して、ピアを拡張できるようになります。
この機能を利用するには、独自のビルドパックを作成し、ピアのcore.yamlを変更して、外部ビルダーが使用可能であることをピアに知らせる新たな設定要素 `externalBuilder` を追加する必要があります。
以下のセクションでは、このプロセスの詳細を説明します。

設定された外部ビルダーがチェーンコードパッケージを要求しない場合、ピアのCLIやNode SDKなどの標準的なFabricのパッケージングツールで作成されたかのように、ピアがパッケージを処理しようとすることに注意してください。

**注:** これは高度な機能であり、ピアイメージのカスタムパッケージングが必要になる可能性があります。
例えば、次のサンプルでは `go` および `bash` を使用しますが、現在の公式の `fabric-peer` イメージには含まれていません。

## External builder model

Hyperledger Fabricの外部ビルダーとランチャーは、大まかにはHeroku [Buildpacks](https://devcenter.heroku.com/articles/buildpack-api)をベースにしています。
ビルドパックの実装は、アプリケーションアーティファクトを実行可能なものに変換するプログラムまたはスクリプトを集めたものです。
ビルドパックモデルは、チェーンコードパッケージに適用され、チェーンコードの実行とディスカバリをサポートするように拡張されました。

### External builder and launcher API

外部ビルダーおよびランチャーは、次の4つのプログラムまたはスクリプトで構成されています。

- `bin/detect`: このビルドパックを使用してチェーンコードパッケージをビルドし、起動するかどうかを決定します。
- `bin/build`: チェーンコードパッケージを実行可能なチェーンコードに変換します。
- `bin/release` (オプション): チェーンコードに関するメタデータをピアに提供します。
- `bin/run` (オプション): チェーンコードを実行します。

#### `bin/detect`

`bin/detect` スクリプトは、チェーンコードパッケージのビルドと起動を行うために、ビルドパックを使用するかどうかを決定します。
ピアは2つの引数と一緒に `detect` を呼び出します。

```sh
bin/detect CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR
```

`detect` が呼び出された時、 `CHAINCODE_SOURCE_DIR` はチェーンコードのソースを含み、`CHAINCODE_METADATA_DIR` は `metadata.json` ファイルを含んでいます。
これらは、ピアにインストールされたチェーンコードパッケージから取得されます。
`CHAINCODE_SOURCE_DIR` および `CHAINCODE_METADATA_DIR` は、読み込み専用の入力として扱われる必要があります。
ビルドパックをチェーンコードのソースパッケージに適用する場合、 `detect` は終了コード `0` を返す必要があります。
その他の終了コードは、ビルドパックを適用すべきでないことを示します。

以下に、goチェーンコード向けのシンプルな `detect` スクリプトの例を示します。

```sh
#!/bin/bash

CHAINCODE_METADATA_DIR="$2"

# use jq to extract the chaincode type from metadata.json and exit with
# success if the chaincode type is golang
if [ "$(jq -r .type "$CHAINCODE_METADATA_DIR/metadata.json" | tr '[:upper:]' '[:lower:]')" = "golang" ]; then
    exit 0
fi

exit 1
```

#### `bin/build`

`bin/build` scriptは、チェーンコードパッケージのコンテンツを `release` および `run` で利用できるように、ビルド、コンパイル、変換を行います。
ピアは、 `build` を3つの引数と一緒に呼び出します。

```sh
bin/build CHAINCODE_SOURCE_DIR CHAINCODE_METADATA_DIR BUILD_OUTPUT_DIR
```

`build` が呼び出された時、 `CHAINCODE_SOURCE_DIR` はチェーンコードのソースを含み、`CHAINCODE_METADATA_DIR` は `metadata.json` ファイルを含んでいます。
これらは、ピアにインストールされたチェーンコードパッケージから取得されます。
`BUILD_OUTPUT_DIR` は、`build` によって `release` および `run` に必要なアーティファクトが配置されるディレクトリです。
ビルドスクリプトは `CHAINCODE_SOURCE_DIR` および `CHAINCODE_METADATA_DIR` を読み込み専用ディレクトリとして扱う必要がありますが、 `BUILD_OUTPUT_DIR`は書き込み可能です。

`build` が終了コード `0` で完了すると、`BUILD_OUTPUT_DIR` のコンテンツはピアによって維持される永続ストレージにコピーされます。
他の終了コードは失敗と判断されます。

以下に、goチェーンコード向けのシンプルな `build` スクリプトの例を示します。

```sh
#!/bin/bash

CHAINCODE_SOURCE_DIR="$1"
CHAINCODE_METADATA_DIR="$2"
BUILD_OUTPUT_DIR="$3"

# extract package path from metadata.json
GO_PACKAGE_PATH="$(jq -r .path "$CHAINCODE_METADATA_DIR/metadata.json")"
if [ -f "$CHAINCODE_SOURCE_DIR/src/go.mod" ]; then
    cd "$CHAINCODE_SOURCE_DIR/src"
    go build -v -mod=readonly -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
else
    GO111MODULE=off go build -v  -o "$BUILD_OUTPUT_DIR/chaincode" "$GO_PACKAGE_PATH"
fi

# save statedb index metadata to provide at release
if [ -d "$CHAINCODE_SOURCE_DIR/META-INF" ]; then
    cp -a "$CHAINCODE_SOURCE_DIR/META-INF" "$BUILD_OUTPUT_DIR/"
fi
```

#### `bin/release`

`bin/release` スクリプトは、ピアにチェーンコードのメタデータを提供します。
`bin/release` はオプションです。指定されていない場合、このステップはスキップされます。
ピアは次の2つの引数と一緒に `release` を呼び出します。

```sh
bin/release BUILD_OUTPUT_DIR RELEASE_OUTPUT_DIR
```

`release` が呼び出された時、`BUILD_OUTPUT_DIR` は `build` プログラムによって生成されたアーティファクトを含んでおり、読み込み専用として扱う必要があります。
`RELEASE_OUTPUT_DIR` には、ピアが利用するアーティファクトが `release` によって配置されます。

`release` が完了すると、ピアは2つのタイプのメタデータを `RELEASE_OUTPUT_DIR` から取得します。

- CouchDB向けのステートデータベースのインデックス定義
- 外部チェーンコードサーバ接続情報(`chaincode/server/connection.json`)

CouchDBのインデックス定義がチェーンコードに必要な場合、 `release` は`RELEASE_OUTPUT_DIR` 配下の `statedb/couchdb/indexes` ディレクトリにインデックスを配置する必要があります。
インデックスの拡張子は `json` です。詳細は、[CouchDBインデックス](couchdb_as_state_database.html#couchdb-indexes)を参照してください。

チェーンコードのサーバ実装が使用されている場合、 `release` は、チェーンコードサーバのアドレス、および、チェーンコードと通信するためのTLS情報を `chaincode/server/connection.json` に設定する必要があります。
サーバ接続情報がピアに提供されると、 `run` は呼び出されません。
詳細は[Chaincode Server](https://jira.hyperledger.org/browse/FAB-14086)を参照してください。

以下に、goチェーンコード向けのシンプルな `release` スクリプトの例を示します。

```sh
#!/bin/bash

BUILD_OUTPUT_DIR="$1"
RELEASE_OUTPUT_DIR="$2"

# copy indexes from META-INF/* to the output directory
if [ -d "$BUILD_OUTPUT_DIR/META-INF" ] ; then
   cp -a "$BUILD_OUTPUT_DIR/META-INF/"* "$RELEASE_OUTPUT_DIR/"
fi
```

#### `bin/run`

`bin/run` scriptは、チェーンコードの実行を担当します。
ピアは次の2つの引数と一緒に `run` を呼び出します。

```sh
bin/run BUILD_OUTPUT_DIR RUN_METADATA_DIR
```

`run` が呼び出された時、 `BUILD_OUTPUT_DIR` は `build` プログラムに生成されたアーティファクト含み、 `RUN_METADATA_DIR` は、チェーンコードがピアに接続して登録するために必要な情報が含まれている `chaincode.json` を持っています。
`bin/run` スクリプトは、`BUILD_OUTPUT_DIR` および `RUN_METADATA_DIR` ディレクトリを読み込み専用入力として使用することに注意してください。
`chaincode.json` に含まれる項目は以下の通りです。

- `chaincode_id`: チェーンコードパッケージに関連付けられたユニークなID。
- `peer_address`: ピアによってホストされるgRPCサーバエンドポイント `ChaincodeSupport` のアドレス。フォーマットは `host:port` 。
- `client_cert`: ピアによって生成されるPEMエンコードTLSクライアント証明書。チェーンコードがピアへの接続を確立するときに使用する必要があります。
- `client_key`: ピアによって生成されるPEMエンコードされたクライアント鍵。チェーンコードがピアへの接続を確立するときに使用する必要があります。
- `root_cert`: ピアによってホストされるgRPCサーバエンドポイント `ChaincodeSupport` のPEMエンコードTLSルート証明書。
- `mspid`: ピアのローカルmspid。

`run` が終了した場合、ピアはチェーンコードが終了したと判断します。
別の要求がチェーンコードに到着すると、ピアは `run` を再度呼び出すことでチェーンコードの別のインスタンスを開始しようとします。
`chaincode.json` の内容は、呼び出し間でキャッシュされてはなりません。

以下に、goチェーンコード向けのシンプルな `run` スクリプトの例を示します。
```sh
#!/bin/bash

BUILD_OUTPUT_DIR="$1"
RUN_METADATA_DIR="$2"

# setup the environment expected by the go chaincode shim
export CORE_CHAINCODE_ID_NAME="$(jq -r .chaincode_id "$RUN_METADATA_DIR/chaincode.json")"
export CORE_PEER_TLS_ENABLED="true"
export CORE_TLS_CLIENT_CERT_FILE="$RUN_METADATA_DIR/client.crt"
export CORE_TLS_CLIENT_KEY_FILE="$RUN_METADATA_DIR/client.key"
export CORE_PEER_TLS_ROOTCERT_FILE="$RUN_METADATA_DIR/root.crt"
export CORE_PEER_LOCALMSPID="$(jq -r .mspid "$RUN_METADATA_DIR/chaincode.json")"

# populate the key and certificate material used by the go chaincode shim
jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_CERT_FILE"
jq -r .client_key  "$RUN_METADATA_DIR/chaincode.json" > "$CORE_TLS_CLIENT_KEY_FILE"
jq -r .root_cert   "$RUN_METADATA_DIR/chaincode.json" > "$CORE_PEER_TLS_ROOTCERT_FILE"
if [ -z "$(jq -r .client_cert "$RUN_METADATA_DIR/chaincode.json")" ]; then
    export CORE_PEER_TLS_ENABLED="false"
fi

# exec the chaincode to replace the script with the chaincode process
exec "$BUILD_OUTPUT_DIR/chaincode" -peer.address="$(jq -r .peer_address "$ARTIFACTS/chaincode.json")"
```

## Configuring external builders and launchers

外部ビルダーを使用するようにピアを設定するには、 `core.yaml` のチェーンコード設定ブロックにexternalBuilder要素を追加する必要があります。
それぞれの外部ビルダー定義は、名前(ロギングに使用される)とビルダースクリプトを含んでいる `bin` ディレクトリの親へのパスを含む必要があります。

外部ビルダースクリプトを呼び出すとき、ピアから伝播する環境変数名のオプションリストも提供できます。

次の例では、2つの外部ビルダーを定義します。

```yaml
chaincode:
  externalBuilders:
  - name: my-golang-builder
    path: /builders/golang
    propagateEnvironment:
    - GOPROXY
    - GONOPROXY
    - GOSUMDB
    - GONOSUMDB
  - name: noop-builder
    path: /builders/binary
```

この例では、"my-golang-builder"の実装は `/builders/golang` ディレクトリに含まれ、そのビルドスクリプトは `/builders/golang/bin` に配置されています。
ピアが"my-golang-builder"に関連付けられたビルドスクリプトのいずれかを呼び出すと、ピアは`propagateEnvironment`内の環境変数の値だけを伝搬します。

注: 次の環境変数は常に外部ビルダーに伝播されます。

- LD_LIBRARY_PATH
- LIBPATH
- PATH
- TMPDIR

`externalBuilder` の設定が存在する場合、ピアはビルダーのリストに対して提供された順序で繰り返し処理を行い、1つのビルダーが完了に成功するまで `bin/detect` を呼び出します。
どのビルダーも `detect` の完了に成功できない場合、ピアはピア内に実装されたレガシーのDockerビルドプロセスを使用するようにフォールバックします。
これは、外部ビルダーが完全にオプションであることを意味します。

上記の例では、ピアは"my-golang-builder"を使用し、続いて"noop-builder"を使用し、最後にピア内部のビルドプロセスを使用します。

## Chaincode packages

Fabric 2.0で導入された新しいライフサイクルの一部として、チェーンコードパッケージのフォーマットは、シリアライズされたプロトコルバッファメッセージからgzipで圧縮されたPOSIXのtape archive(tar)に変更されました。
`peer lifecycle chaincode package` で生成されたチェーンコードパッケージは、この新しい形式を使用します。

### Lifecycle chaincode package contents

ライフサイクルチェーンコードパッケージには2つのファイルが含まれています。
最初のファイルは `code.tar.gz` というgzipで圧縮されたPOSIXのtape archive(tar)です。
このファイルには、チェーンコードのソースアーティファクトが含まれています。
ピアのCLIによって作成されたパッケージは、チェーンコードの実装ソースを `src` ディレクトリに、チェーンコードのメタデータ(例えば、CouchDBインデックス)を `META-INF` ディレクトリに配置します。

2番目のファイル `metadata.json` は、3つのキーを持つJSONドキュメントです。
- `type`: チェーンコードタイプ(GOLANG、JAVA、NODEなど)
- `path`: goチェーンコードの場合、GOPATHまたはGOMODをメインチェーンコードパッケージへの相対パスで定義。その他のタイプの場合、未定義。
- `label`: パッケージIDの生成に使用されるチェーンコードラベル。パッケージは、新しいチェーンコードライフサイクルのプロセスで識別されます。

`type` および `path` フィールドは、Dockerプラットフォームのビルドのみで利用されることに注意してください。

### Chaincode packages and external builders

チェーンコードパッケージがピアにインストールされると、 `code.tar.gz` および`metadata.json` は、外部ビルダーを呼び出すまでは処理されません。
`label` フィールドは、新しいライフサイクルプロセスでパッケージIDを計算するために使用されます。
これにより、ユーザーは、外部のビルダーやランチャーによって処理されるソースやメタデータをパッケージ化する方法に大きな柔軟性を得ることができます。

例えば、`code.tar.gz` のチェーンコードの実装と `metadata.json` を一緒に事前コンパイルした、カスタムチェーンコードパッケージを作ることができます。
これにより、 _binary buildpack_ は、カスタムパッケージを検出し、バイナリのハッシュを検証し、プログラムをチェーンコードとして実行します。

別の例としては、ステートデータベースのインデックス定義と、外部ランチャーが実行中のチェーンコードサーバに接続するために必要なデータのみを含むチェーンコードパッケージがあります。
この場合、 `build` プロセスは単にプロセスからメタデータを抽出し、 `release` はそのメタデータをピアに渡します。

唯一の要件は、`code.tar.gz` は通常のファイルとディレクトリエントリのみを含むということです。
また、エントリには、チェーンコードパッケージのルートの外側にファイルが書き込まれるようなパスを含めることはできません。

<!---
Licensed under Creative Commons Attribution 4.0 International License https://creativecommons.org/licenses/by/4.0/
-->
