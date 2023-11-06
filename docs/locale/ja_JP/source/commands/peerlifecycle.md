# peer lifecycle chaincode

`peer lifecycle chaincode` サブコマンドを使うと、管理者は チェーンコードライフサイクル (Fabric chaincode lifecycle) を用いて、
チェーンコードをパッケージ化し、それをその組織のピアにインストールし、
その組織のためにチェーンコード定義を承認し、その定義をチャネルにコミットすることができます。
チェーンコードは、その定義がチャネルに正常にコミットされた後に、使用できるようにになります。
詳細は、[Fabric chaincode lifecycle](../chaincode_lifecycle.html) をご覧ください。

*注：これらの手順では、v2.0リリースで導入された (新しい) チェーンコードライフサイクル (Fabric chaincode lifecycle) を使用しています。
古いライフサイクルを使ってチェーンコードのインストールとインスタンス化を行いたい場合は、[peer chaincode](peerchaincode.html) コマンドリファレンスをご覧ください*。

## Syntax

`peer lifecycle chaincode` コマンドには、以下のサブコマンドがあります:

  * package
  * install
  * queryinstalled
  * getinstalledpackage
  * approveformyorg
  * queryapproved
  * checkcommitreadiness
  * commit
  * querycommitted

各 peer lifecycle chaincode サブコマンドは、このトピックの各セクションでそのオプションとともに説明されています。

## peer lifecycle
```
Perform _lifecycle operations

Usage:
  peer lifecycle [command]

Available Commands:
  chaincode   Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Flags:
  -h, --help   help for lifecycle

Use "peer lifecycle [command] --help" for more information about a command.
```


## peer lifecycle chaincode
```
Perform chaincode operations: package|install|queryinstalled|getinstalledpackage|approveformyorg|queryapproved|checkcommitreadiness|commit|querycommitted

Usage:
  peer lifecycle chaincode [command]

Available Commands:
  approveformyorg      Approve the chaincode definition for my org.
  checkcommitreadiness Check whether a chaincode definition is ready to be committed on a channel.
  commit               Commit the chaincode definition on the channel.
  getinstalledpackage  Get an installed chaincode package from a peer.
  install              Install a chaincode.
  package              Package a chaincode
  queryapproved        Query an org's approved chaincode definition from its peer.
  querycommitted       Query the committed chaincode definitions by channel on a peer.
  queryinstalled       Query the installed chaincodes on a peer.

Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
  -h, --help                                help for chaincode
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint

Use "peer lifecycle chaincode [command] --help" for more information about a command.
```


## peer lifecycle chaincode package
```
Package a chaincode and write the package to a file.

Usage:
  peer lifecycle chaincode package [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for package
      --label string                   The package label contains a human-readable description of the package
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -p, --path string                    Path to the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode install
```
Install a chaincode on a peer.

Usage:
  peer lifecycle chaincode install [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for install
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode queryinstalled
```
Query the installed chaincodes on a peer.

Usage:
  peer lifecycle chaincode queryinstalled [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryinstalled
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode getinstalledpackage
```
Get an installed chaincode package from a peer.

Usage:
  peer lifecycle chaincode getinstalledpackage [outputfile] [flags]

Flags:
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for getinstalledpackage
      --output-directory string        The output directory to use when writing a chaincode install package to disk. Default is the current working directory.
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode approveformyorg
```
Approve the chaincode definition for my organization.

Usage:
  peer lifecycle chaincode approveformyorg [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for approveformyorg
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --package-id string              The identifier of the chaincode install package
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode queryapproved
```
Query an organization's approved chaincode definition from its peer.

Usage:
  peer lifecycle chaincode queryapproved [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for queryapproved
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode checkcommitreadiness
```
Check whether a chaincode definition is ready to be committed on a channel.

Usage:
  peer lifecycle chaincode checkcommitreadiness [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for checkcommitreadiness
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode commit
```
Commit the chaincode definition on the channel.

Usage:
  peer lifecycle chaincode commit [flags]

Flags:
      --channel-config-policy string   The endorsement policy associated to this chaincode specified as a channel config policy reference
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -E, --endorsement-plugin string      The name of the endorsement plugin to be used for this chaincode
  -h, --help                           help for commit
      --init-required                  Whether the chaincode requires invoking 'init'
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --sequence int                   The sequence number of the chaincode definition for the channel
      --signature-policy string        The endorsement policy associated to this chaincode specified as a signature policy
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -V, --validation-plugin string       The name of the validation plugin to be used for this chaincode
  -v, --version string                 Version of the chaincode
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the transaction has been committed successfully (default true)
      --waitForEventTimeout duration   Time to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully (default 30s)

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## peer lifecycle chaincode querycommitted
```
Query the committed chaincode definitions by channel on a peer. Optional: provide a chaincode name to query a specific definition.

Usage:
  peer lifecycle chaincode querycommitted [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       The fully qualified path to the connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for querycommitted
  -n, --name string                    Name of the chaincode
  -O, --output string                  The output format for query results. Default is human-readable plain-text. json is currently the only supported format.
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag

Global Flags:
      --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
      --clientauth                          Use mutual TLS when communicating with the orderer endpoint
      --connTimeout duration                Timeout for client to connect (default 3s)
      --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
  -o, --orderer string                      Ordering service endpoint
      --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer
      --tls                                 Use TLS when communicating with the orderer endpoint
      --tlsHandshakeTimeShift duration      The amount of time to shift backwards for certificate expiration checks during TLS handshakes with the orderer endpoint
```


## Example Usage

### peer lifecycle chaincode package example

chaincode はピアにインストールする前にパッケージ化する必要があります。
以下のコマンド例では、`peer lifecycle chaincode package` コマンドを使って Go 言語で記述されたチェーンコードをパッケージ化しています。

  * チェーンコードの配置場所を示すために `--path` フラグを使用します。
    path は完全修飾パスか、現在の作業ディレクトリからの相対パスである必要があります。
  * 各組織内でチェーンコードパッケージを識別するためのチェーンコードパッケージラベルを指定するには、 `--label` フラグを使用します。
    この例では `myccv1` という名前のパッケージラベルを指定しています。

    ```
    peer lifecycle chaincode package mycc.tar.gz --path $CHAINCODE_DIR --lang golang --label myccv1
    ```

### peer lifecycle chaincode install example

チェーンコードをパッケージ化した後に、`peer chaincode install` コマンドを使ってピアにチェーンコードをインストールできます。

  * 以下の例では、`mycc.tar.gz ` パッケージを `peer0.org1.example.com:7051` (`--peerAddresses` で指定されたピア) にインストールします。

    ```
    peer lifecycle chaincode install mycc.tar.gz --peerAddresses peer0.org1.example.com:7051
    ```
    成功すると、コマンドは以下のようにチェーンコードパッケージIDを返します。
    パッケージIDは、パッケージラベルと、ピアによって取得されたチェーンコードパッケージのハッシュ値を組み合わせたものです。
    ```
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEmycc:ebd89878c2bbccf62f68c36072626359376aa83c36435a058d453e8dbfd894cc" >
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: mycc:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9
    ```

### peer lifecycle chaincode queryinstalled example

あなたの組織のためにチェーンコード定義を承認する際には、チェーンコードパッケージIDを使う必要があります。
あなたがインストールしたチェーンコードのパッケージIDは、`peer lifecycle chaincode queryinstalled` コマンドを使うことで調べることができます:

```
peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051
```

コマンドに成功すると、パッケージラベルに関連付けられたパッケージIDが返されます。

```
Get installed chaincodes on peer:
Package ID: myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9, Label: myccv1
```

  * また `--output` フラグを使用するとJSONフォーマットで出力することができます。

    ```
    peer lifecycle chaincode queryinstalled --peerAddresses peer0.org1.example.com:7051 --output json
    ```

    成功すると、コマンドは以下のようなJSON形式でインストール済チェーンコードを返します。

    ```
    {
      "installed_chaincodes": [
        {
          "package_id": "mycc_1:aab9981fa5649cfe25369fce7bb5086a69672a631e4f95c4af1b5198fe9f845b",
          "label": "mycc_1",
          "references": {
            "mychannel": {
              "chaincodes": [
                {
                  "name": "mycc",
                  "version": "1"
                }
              ]
            }
          }
        }
      ]
    }
    ```

### peer lifecycle chaincode getinstalledpackage example

ピアにインストールされたチェーンコードパッケージを取得するには、 `peer lifecycle chaincode getinstalledpackage` コマンドを使用します。
`queryinstalled` が返すパッケージIDを使用してください。

  * チェーンコードパッケージIDを指定するために `--package-id` フラグを使用します。
  チェーンコードパッケージをどこに書き込むかを指定するために `output-directory` フラグを使います。
  出力ディレクトリが指定されていない場合、チェーンコードパッケージはカレントディレクトリに書き込まれます。

  ```
  peer lifecycle chaincode getinstalledpackage --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --output-directory /tmp --peerAddresses peer0.org1.example.com:7051
  ```


### peer lifecycle chaincode approveformyorg example

チェーンコードパッケージがあなたのピアにインストールされたら、あなたの組織のためのチェーンコード定義を承認することができます。
チェーンコード定義は、チェーンコードの名前、バージョン、エンドースメントポリシーを含むチェーンコードガバナンスの重要なパラメータを含んでいます。

以下は `peer lifecycle chaincode approveformyorg` コマンドの例で、
チャネル `mychannel` 上で名前が `mycc` でバージョン `1.0` のチェーンコード定義を承認しています。

  * パッケージIDを指定するためには、`--package-id` フラグを使用します。
  `signature-policy` フラグを使用して、チェーンコードのエンドースメントポリシーを定義します。
  `init-required` フラグを使用して、チェーンコードを初期化するために `Init` 関数を実行するように要求します。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode approveformyorg  -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --signature-policy "AND ('Org1MSP.peer','Org2MSP.peer')"

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

  * また、`--channel-config-policy` フラグを使用すると、チャネル設定内のポリシーをチェーンコードのエンドースメントポリシーとして使用することができます。
    デフォルトのエンドースメントポリシーは `Channel/Application/Endorsement` です。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode approveformyorg -o orderer.example.com:7050 --tls --cafile $ORDERER_CA --channelID mychannel --name mycc --version 1.0 --init-required --package-id myccv1:a7ca45a7cc85f1d89c905b775920361ed089a364e12a9b6d55ba75c965ddd6a9 --sequence 1 --channel-config-policy Channel/Application/Admins

    2019-03-18 16:04:09.046 UTC [cli.lifecycle.chaincode] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
    2019-03-18 16:04:11.253 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [efba188ca77889cc1c328fc98e0bb12d3ad0abcda3f84da3714471c7c1e6c13c] committed with status (VALID) at peer0.org1.example.com:7051
    ```

### peer lifecycle chaincode queryapproved example

組織の承認済みチェーンコード定義をクエリするために、`peer lifecycle chaincode queryapproved` コマンドを使用します。
このコマンドを使うと、承認されたチェーンコード定義の詳細（パッケージIDを含む）を見ることができます。

  * 以下は `peer lifecycle chaincode queryapproved` コマンドで、チャネル `mychannel` 上の
    名前が `mycc` でシーケンス番号 `1` の承認済みチェーンコード定義を問い合わせる例です。

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 1, version: 1, init-required: true, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```
    承認済み定義にパッケージが指定されていない場合には、このコマンドは空のパッケージIDを表示します。

  * また、最新の承認済み定義を問い合わせるために、シーケンス番号を指定せずにこのコマンドを使用することも可能です
    (最新: 現在のシーケンス番号 (コミット済) か次のシーケンス番号 (承認済) の新しいほう)。

    ```
    peer lifecycle chaincode queryapproved -C mychannel -n mycc

    Approved chaincode definition for chaincode 'mycc' on channel 'mychannel':
    sequence: 3, version: 3, init-required: false, package-id: mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830, endorsement plugin: escc, validation plugin: vscc
    ```

  * また `--output` フラグを使用するとJSONフォーマットで出力することができます。

    - パッケージが指定されている承認済チェーンコード定義をクエリする場合の例

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 1 --output json
      ```

      成功すると、指定されたチャネル `mychannel` 上のシーケンス番号 `1` のチェーンコード `mycc` の承認済チェーンコード定義に関して以下のような JSON が返されます。

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "source": {
          "Type": {
            "LocalPackage": {
              "package_id": "mycc_1:d02f72000e7c0f715840f51cb8d72d70bc1ba230552f8445dded0ec8b6e0b830"
            }
          }
        }
      }
      ```

    - パッケージが指定されていない承認済チェーンコード定義をクエリする場合の例

      ```
      peer lifecycle chaincode queryapproved -C mychannel -n mycc --sequence 2 --output json
      ```

      成功すると、指定されたチャネル `mychannel` 上のシーケンス番号 `2` のチェーンコード `mycc` の承認済チェーンコード定義に関して以下のような JSON が返されます。

      ```
      {
        "sequence": 2,
        "version": "2",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "source": {
          "Type": {
            "Unavailable": {}
          }
        }
      }
      ```

### peer lifecycle chaincode checkcommitreadiness example

チェーンコード定義がコミットできる状態かどうかを確認するために `peer lifecycle chaincode checkcommitreadiness` コマンドを使います。
このコマンドは、その定義に対するその後のコミットが成功すると期待される場合に成功を返します。
さらに、どの組織がチェーンコード定義を承認したかどうかも出力します。
もし、ある組織がこのコマンドで指定されたチェーンコード定義を承認していれば、このコマンドは true の値を返します。
このコマンドを使用すると、チャネルに定義をコミットする前に、`Application/Channel/Endorsement` ポリシー（デフォルトでは過半数）を満たすだけのチャネルメンバーがチェーンコード定義を承認しているかどうかを知ることができます。

  * 以下は `peer lifecycle chaincode checkcommitreadiness` コマンドで、チャネル `mychannel` 上の
    名前が `mycc` でバージョン `1.0` のチェーンコードの状態をチェックする例です。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1
    ```

    成功すると、このコマンドはチェーンコード定義を承認した組織を返します。

    ```
    Chaincode definition for chaincode 'mycc', version '1.0', sequence '1' on channel
    'mychannel' approval status by org:
    Org1MSP: true
    Org2MSP: true
    ```

  * また `--output` フラグを使用するとJSONフォーマットで出力することができます。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode checkcommitreadiness -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --name mycc --version 1.0 --init-required --sequence 1 --output json
    ```

    成功すると、ある組織がチェーンコード定義を承認したかどうかを示すJSONマップが返されます。

    ```
    {
       "Approvals": {
          "Org1MSP": true,
          "Org2MSP": true
       }
    }
    ```

### peer lifecycle chaincode commit example

十分な数の組織が自分たちの組織のためのチェーンコード定義を承認したら (デフォルトでは過半数)、
1つの組織が `peer lifecycle chaincode commit` コマンドを使用してチャネルにその定義をコミットすることができます:
  * このコマンドでは、チャネル上の他組織のピアをターゲットとして、その定義に関する各組織からのエンドースメントを収集する必要があります。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051

    2019-03-18 16:14:27.258 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org2.example.com:9051
    2019-03-18 16:14:27.321 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [b6f657a14689b27d69a50f39590b3949906b5a426f9d7f0dcee557f775e17882] committed with status (VALID) at peer0.org1.example.com:7051
    ```

### peer lifecycle chaincode querycommitted example

チャネルにコミットされたチェーンコード定義をクエリするために `peer lifecycle chaincode querycommitted` コマンドを使用します。
このコマンドは、チェーンコードをアップグレードする前に、現在の定義のシーケンス番号を問い合わせるために使うことができます。

  * 特定のチェーンコード定義とそれを承認した組織をクエリするために、
    チェーンコード名とチャネル名を指定する必要があります。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definition for chaincode 'mycc' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Approvals: [Org1MSP: true, Org2MSP: true]
    ```

  * また、チャネル名だけを指定して、そのチャネル上のすべてのチェーンコード定義をクエリすることもできます。

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

    peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051

    Committed chaincode definitions on channel 'mychannel':
    Name: mycc, Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc
    Name: yourcc, Version: 2, Sequence: 3, Endorsement Plugin: escc, Validation Plugin: vscc
    ```

  * また `--output` フラグを使用するとJSONフォーマットで出力することができます。

    - 特定のチェーンコード定義をクエリする場合

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --name mycc --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      成功すると、チャネル `mychannel` 上のチェーンコード `mycc` に対するコミット済チェーンコード定義の JSON が返されます。

      ```
      {
        "sequence": 1,
        "version": "1",
        "endorsement_plugin": "escc",
        "validation_plugin": "vscc",
        "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
        "collections": {},
        "init_required": true,
        "approvals": {
          "Org1MSP": true,
          "Org2MSP": true
        }
      }
      ```

      ここで `validation_parameter` は base64 でエンコードされています。
      これをデコードするコマンドの例は以下の通りです。

      ```
      echo EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA== | base64 -d

       /Channel/Application/Endorsement
      ```

    - チャネル上のすべてのチェーンコード定義をクエリする場合

      ```
      export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

      peer lifecycle chaincode querycommitted -o orderer.example.com:7050 --channelID mychannel --tls --cafile $ORDERER_CA --peerAddresses peer0.org1.example.com:7051 --output json
      ```

      成功すると、チャネル `mychannel` 上のすべてのコミット済チェーンコード定義の JSON が返されます。

      ```
      {
        "chaincode_definitions": [
          {
            "name": "mycc",
            "sequence": 1,
            "version": "1",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {},
            "init_required": true
          },
          {
            "name": "yourcc",
            "sequence": 3,
            "version": "2",
            "endorsement_plugin": "escc",
            "validation_plugin": "vscc",
            "validation_parameter": "EiAvQ2hhbm5lbC9BcHBsaWNhdGlvbi9FbmRvcnNlbWVudA==",
            "collections": {}
          }
        ]
      }
      ```


<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
