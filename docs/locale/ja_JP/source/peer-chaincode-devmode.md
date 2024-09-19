# Running chaincode in development mode

**対象読者:** アップデートするたびに必要なスマートコントラクトライフサイクルプロセスのオーバーヘッドをなくし、チェーンコードパッケージの開発とテストを繰り返し実施するスマートコントラクト開発者

スマートコントラクトを開発している間、チェーンコードライフサイクルコマンドを変更のたびに実施することなく、開発者は素早く且つ繰り返しチェーンコードパッケージをテストする方法を必要としています。このチュートリアルでは、Fabricバイナリを使用し、開発モード ("DevMode") でピアを立上げ、ピアを通してチェーンコードに接続します。これにより、ピアにチェーンコードをインストールすることなくチェーンコードを実行でき、チェーンコードが最初にチャネルにコミットされた後、ピアのライフサイクルチェーンコードコマンドを省くことができます。これにより、アップデートする際のピアのライフサイクルチェーンコードコマンドの再実行によるオーバーヘッドのない素早い開発、デバッグとアップデートが可能になります。

**Note:** ピアのDevModeモードフラグを使用するために、ネットワーク内の全てのノードのTLS通信は無効にしなければなりません。本番ネットワークではTLS通信が強く推奨されているため、本番環境においてピアをDevModeで稼働させてはいけません。このチュートリアルで使用するネットワークは、いかなる形態の本番ネットワークのテンプレートとして使用してはいけません。本番ネットワークのデプロイ方法の説明は、[Deploying a production network](deployment_guide_overview.html) を確認してください。また、Fabricチェーンコードライフサイクルプロセスを使用したチャネル上のスマートコントラクトパッケージのデプロイとアップデート方法を学ぶ際は、[Fabric test network](test_network.html) を参照してください。

このチュートリアル全体の、全コマンドは、 `fabric/` フォルダから実行されます。ピアとOrdererは全てデフォルト設定で、必要に応じてコマンドから環境変数を用いて設定が上書きされています。デフォルトのピアの `core.yaml` もしくは、Ordererの `orderer.yaml` ファイルは修正する必要はありません。

## Set up environment

1. Fabricのリポジトリである[GitHub](https://github.com/hyperledger/fabric)から、クローンしてください。また、必要に応じて、リリースブランチを選択してください。
2. Orderer、ピアとconfigtxgenのバイナリをビルドするために、以下のコマンドを実行してください: 
    ```
    make orderer peer configtxgen
    ```
    成功すると、以下の様な結果になります:
    ```
    Building build/bin/orderer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/orderer
    Building build/bin/peer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/peer
    Building build/bin/configtxgen
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/configtxgen
    ```
3. Ordererとピアのバイナリを含めるために、環境変数の `PATH` を設定してください:
    ```
    export PATH=$(pwd)/build/bin:$PATH
    ```
4. `sampleconfig` フォルダを指し示すために、環境変数の `FABRIC_CFG_PATH` を設定してください:
    ```
    export FABRIC_CFG_PATH=$(pwd)/sampleconfig
    ```
5. `/var` ディレクトリ内に、 `hyperledger` サブディレクトリを作成してください。これは、Ordererの `orderer.yaml` とピアの `core.yaml` ファイルに定義されたFabricがブロックを保存するために使用するデフォルトの場所です。 `hyperledger` サブディレクトリを作成するために、以下のコマンドを実行してください。なお、クエスチョンマークは、ユーザ名に置き換えてください:
    ```
    sudo mkdir /var/hyperledger
    sudo chown ????? /var/hyperledger
    ```
6. オーダリングサービスのためにジェネシスブロックを作成してください。ジェネシスブロックを作成するために以下のコマンドを実行し、 `$(pwd)/sampleconfig/genesisblock` に格納してください。次のステップでOrdererを立ち上げる際にこのブロックを使用します。
    ```
    configtxgen -profile SampleDevModeSolo -channelID syschannel -outputBlock genesisblock -configPath $FABRIC_CFG_PATH -outputBlock "$(pwd)/sampleconfig/genesisblock"
    ```

    When successful you should see results similar to:
    ```
    2020-09-14 17:36:37.295 EDT [common.tools.configtxgen] doOutputBlock -> INFO 004 Generating genesis block
    2020-09-14 17:36:37.296 EDT [common.tools.configtxgen] doOutputBlock -> INFO 005 Writing genesis block
    ```
## Start the orderer

`SampleDevModeSolo` プロファイルでのOrdererを立ち上げ、オーダリングサービスを実行するために、以下のコマンドを実行してください:

```
ORDERER_GENERAL_GENESISPROFILE=SampleDevModeSolo orderer
```
成功すると、以下の様な結果になります:
```
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00b Starting orderer:
 Version: 2.3.0
 Commit SHA: 298695ae2
 Go version: go1.15
 OS/Arch: darwin/amd64
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00c Beginning to serve requests
```

## Start the peer in DevMode

ピアの設定を上書きしピアを立ち上げるために、他のターミナルウィンドウを開いて必要な環境変数を設定してください。

**Note:** Ordererとピアを同一の環境(別々のコンテナではない環境)で保持する場合、環境変数の `CORE_OPERATIONS_LISTENADDRESS` のみを設定してください(ポート番号は9443以外の任意の値を設定してください)。
```
export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:9444
```

ピアをDevModeに設定する `--peer-chaincodedev=true` フラグを付与して、ピアを立ち上げてください。
```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true
```

**Reminder:** `DevMode` で立ち上げる場合、TLSは無効になります。

成功すると、以下の様な結果になります:
```
2020-09-14 17:38:45.324 EDT [nodeCmd] serve -> INFO 00e Running in chaincode development mode
...
2020-09-14 17:38:45.326 EDT [nodeCmd] serve -> INFO 01a Started peer with ID=[jdoe], network ID=[dev], address=[192.168.1.134:7051]
```

## Create channel and join peer

他のターミナルウィンドウを開いて、 `configtxgen` ツールを用いてチャネル作成トランザクションを作成するために以下のコマンドを実行してください。このコマンドは、 `SampleSingleMSPChannel` プロファイルを設定されたチャネル `ch1` を作成します:
```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
configtxgen -channelID ch1 -outputCreateChannelTx ch1.tx -profile SampleSingleMSPChannel -configPath $FABRIC_CFG_PATH
peer channel create -o 127.0.0.1:7050 -c ch1 -f ch1.tx
```

成功すると、以下の様な結果になります:
```
2020-09-14 17:42:56.931 EDT [cli.common] readBlock -> INFO 002 Received block: 0
```

以下のコマンドを実行することで、ピアはチャネルに参加します:

```
peer channel join -b ch1.block
```
成功すると、以下の様な結果になります:
```
2020-09-14 17:43:34.976 EDT [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

ピアは、チャネル `ch1` に参加しました。

## Build the chaincode

DevModeにてチェーンコードパッケージがどの様に実行するかを説明するために、 `fabric/integration/chaincode` ディレクトリにある **simple** チェーンコードを使用します。前のステップと同様に、同じターミナルウィンドウにおいて、チェーンコードをビルドするために以下のコマンドを実行してください:

```
go build -o simpleChaincode ./integration/chaincode/simple/cmd
```

## Start the chaincode

ピアの `DevMode` が有効な場合、環境変数の `CORE_CHAINCODE_ID_NAME` に `<CHAINCODE_NAME>`:`<CHAINCODE_VERSION>` を設定する必要があります。その設定をしないと、ピアはチェーンコードを見つけることができません。設定例としては、 `mycc:1.0` があります。チェーンコードを立ち上げてピアから接続するために、以下のコマンドを実行してください:

```
CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./simpleChaincode -peer.address 127.0.0.1:7052
```

ピアの起動時にデバッグログを設定しているので、チェーンコードの登録が成功したことを確認できます。ピアのログにおいて、以下の様な結果が表示されます:
```
2020-09-14 17:53:43.413 EDT [chaincode] sendReady -> DEBU 045 Changed to state ready for chaincode mycc:1.0
```
## Approve and commit the chaincode definition

そして、チェーンコード定義を承認しチャネルにコミットするために、以下のFabricチェーンコードライフサイクルコマンドを実行する必要があります:

```
peer lifecycle chaincode approveformyorg  -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --package-id mycc:1.0
peer lifecycle chaincode checkcommitreadiness -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')"
peer lifecycle chaincode commit -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --peerAddresses 127.0.0.1:7051
```

以下の様な結果になります:
```
2020-09-14 17:56:30.820 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [f22b3c25dfea7fe0b28af9ee818056db81e29a9421c83fe00eb22fa41d1d1e21] committed with status (VALID) at
Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel 'ch1' approval status by org:
SampleOrg: true
2020-09-14 17:57:43.295 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [fb803e8b0b4eae6b3a9ed35668f223753e1a34ffd2a7042f9e5bb516a383eb32] committed with status (VALID) at 127.0.0.1:7051
```

## Next steps

スマートコントラクトのロジックを検証するために、必要に応じてチェーンコードを呼び出しクエリするCLIコマンドを実行できます。例えば、3つのコマンドを実行します。1つ目はスマートコントラクトの初期化、2つ目はアセット `a` からアセット `b` に `10` 移動します。最後は正常に `100` から `90` に変わったことを検証するために、アセット `a` の値をクエリします。

```
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["init","a","100","b","200"]}' --isInit
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["invoke","a","b","10"]}'
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

以下の様な結果になります:
```
2020-09-14 18:15:00.034 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
2020-09-14 18:16:29.704 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
2020-09-14 18:17:42.101 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 payload:"90"
```

DevModeでピアを稼働するメリットとしては、スマートコントラクトを繰り返しアップデートし、変更を保存し、 [build](#build-the-chaincode) し、そして上述の手順で再度 [start](#start-the-chaincode) できるようになることです。チェーンコードを変更するたびにピアライフサイクルコマンドを実行し、アップデートする必要はありません。
