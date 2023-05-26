# peer chaincode

`peer chaincode` コマンドは、管理者がピアに対してチェーンコードに関連する操作、
例えば、インストール、インスタンス化、呼び出し、パッケージング、クエリ、アップグレードを行うことを可能にします。

## Syntax

`peer chaincode` コマンドには以下のサブコマンドがあります:

  * install
  * instantiate
  * invoke
  * list
  * package
  * query
  * signpackage
  * upgrade

それぞれのサブコマンドオプション（install、instantiate...）は、ピアに関連する異なるチェーンコード操作に関連しています。
例えば、ピアにチェーンコードをインストールするには `peer chaincode install` サブコマンドオプションを使用し、
ピアの台帳の現在の値をチェーンコードに問い合わせる (クエリする) には `peer chaincode query` サブコマンドオプションを使用します。

いくつかのサブコマンドはフラグ `--ctor` を取り、その値はキー 'Args' または 'Function' と 'Args' を持つ JSON 文字列でなければなりません。
これらのキーは大文字と小文字を区別しません。

JSON 文字列が Args キーだけを持つ場合、キーの値は配列であり、配列の最初の要素が呼び出す対象の関数名で、
それ以降の要素はその関数の引数です。
JSON 文字列が 'Function' と 'Args' の両方を持つ場合、Function の値は呼び出す対象の関数名で、
Args の値はその関数の引数の配列となります。
例えば、`{"Args":["GetAllAssets"]}` は `{"Function": "GetAllAssets", "Args":[]}` と等価です。

peer chaincode の各サブコマンドは、このトピックの各セクションでそのオプションとともに説明されています。

## Flags

それぞれの `peer chaincode` サブコマンドには、
個々のサブコマンドに固有のフラグと、
すべての `peer chaincode` サブコマンドに関連するグローバルフラグの両方があります。
すべてのサブコマンドがこれらのフラグを使用するわけではありません。
例えば、`query` サブコマンドは `--orderer` フラグを必要としません。

個々のフラグについては、関連するサブコマンドで説明します。
グローバルフラグは以下の通りです。

* `--cafile <string>`

  オーダリングサービスのエンドポイントのための PEM エンコードされた信頼できる証明書を含むファイルへのパス

* `--certfile <string>`

  オーダリングサービスのエンドポイントとの相互 TLS 通信に使用する PEM エンコードされた X509 公開鍵を含むファイルへのパス

* `--keyfile <string>`

  オーダリングサービスのエンドポイントとの相互 TLS 通信に使用する PEM エンコードされた秘密鍵を含むファイルへのパス

* `-o` or `--orderer <string>`
  `<hostname or IP address>:<port>` で指定されたオーダリングサービスのエンドポイント

* `--ordererTLSHostnameOverride <string>`

  オーダリングサービスのエンドポイントとの TLS 接続を検証する際に使用するホスト名オーバーライド

* `--tls`

  オーダリングサービスのエンドポイントとの通信に TLS を使用するかどうか

* `--transient <string>`

  JSON エンコーディングによる引数のTransient Map

## peer chaincode install
```
Install a chaincode on a peer. This installs a chaincode deployment spec package (if provided) or packages the specified chaincode before subsequently installing it.

Usage:
  peer chaincode install [flags]

Flags:
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
  -h, --help                           help for install
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -n, --name string                    Name of the chaincode
  -p, --path string                    Path to chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -v, --version string                 Version of the chaincode specified in install/instantiate/upgrade commands

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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode instantiate
```
Deploy the specified chaincode to the network.

Usage:
  peer chaincode instantiate [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
  -E, --escc string                    The name of the endorsement system chaincode to be used for this chaincode
  -h, --help                           help for instantiate
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
  -P, --policy string                  The endorsement policy associated to this chaincode
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -v, --version string                 Version of the chaincode specified in install/instantiate/upgrade commands
  -V, --vscc string                    The name of the verification system chaincode to be used for this chaincode

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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode invoke
```
Invoke the specified chaincode. It will try to commit the endorsed transaction to the network.

Usage:
  peer chaincode invoke [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
  -h, --help                           help for invoke
  -I, --isInit                         Is this invocation for init (useful for supporting legacy chaincodes in the new lifecycle)
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
      --waitForEvent                   Whether to wait for the event from each peer's deliver filtered service signifying that the 'invoke' transaction has been committed successfully
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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode list
```
Get the instantiated chaincodes in the channel if specify channel, or get installed chaincodes on the peer

Usage:
  peer chaincode list [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -h, --help                           help for list
      --installed                      Get the installed chaincodes on a peer
      --instantiated                   Get the instantiated chaincodes on a channel
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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode package
```
Package a chaincode and write the package to a file.

Usage:
  peer chaincode package [outputfile] [flags]

Flags:
  -s, --cc-package                  create CC deployment spec for owner endorsements instead of raw CC deployment spec
  -c, --ctor string                 Constructor message for the chaincode in JSON format (default "{}")
  -h, --help                        help for package
  -i, --instantiate-policy string   instantiation policy for the chaincode
  -l, --lang string                 Language the chaincode is written in (default "golang")
  -n, --name string                 Name of the chaincode
  -p, --path string                 Path to chaincode
  -S, --sign                        if creating CC deployment spec package for owner endorsements, also sign it with local MSP
  -v, --version string              Version of the chaincode specified in install/instantiate/upgrade commands

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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode query
```
Get endorsed result of chaincode function call and print it. It won't generate transaction.

Usage:
  peer chaincode query [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
  -h, --help                           help for query
  -x, --hex                            If true, output the query value byte array in hexadecimal. Incompatible with --raw
  -n, --name string                    Name of the chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
  -r, --raw                            If true, output the query value as raw bytes, otherwise format as a printable string
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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode signpackage
```
Sign the specified chaincode package

Usage:
  peer chaincode signpackage [flags]

Flags:
  -h, --help   help for signpackage

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
      --transient string                    Transient map of arguments in JSON encoding
```


## peer chaincode upgrade
```
Upgrade an existing chaincode with the specified one. The new chaincode will immediately replace the existing chaincode upon the transaction committed.

Usage:
  peer chaincode upgrade [flags]

Flags:
  -C, --channelID string               The channel on which this command should be executed
      --collections-config string      The fully qualified path to the collection JSON file including the file name
      --connectionProfile string       Connection profile that provides the necessary connection information for the network. Note: currently only supported for providing peer connection information
  -c, --ctor string                    Constructor message for the chaincode in JSON format (default "{}")
  -E, --escc string                    The name of the endorsement system chaincode to be used for this chaincode
  -h, --help                           help for upgrade
  -l, --lang string                    Language the chaincode is written in (default "golang")
  -n, --name string                    Name of the chaincode
  -p, --path string                    Path to chaincode
      --peerAddresses stringArray      The addresses of the peers to connect to
  -P, --policy string                  The endorsement policy associated to this chaincode
      --tlsRootCertFiles stringArray   If TLS is enabled, the paths to the TLS root cert files of the peers to connect to. The order and number of certs specified should match the --peerAddresses flag
  -v, --version string                 Version of the chaincode specified in install/instantiate/upgrade commands
  -V, --vscc string                    The name of the verification system chaincode to be used for this chaincode

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
      --transient string                    Transient map of arguments in JSON encoding
```

## Example Usage

### peer chaincode instantiate examples

以下は `peer chaincode instantiate` コマンドの例で、
チャネル `mychannel` に `mycc` という名前のチェーンコードをバージョン `1.0` でインスタンス化します：

  * TLSが有効なネットワークでチェーンコードをインスタンス化するには、グローバルフラグ `--tls` と `--cafile` を使用します:

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

    2018-02-22 16:33:53.324 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
    2018-02-22 16:33:53.324 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
    2018-02-22 16:34:08.698 UTC [main] main -> INFO 003 Exiting.....

    ```

  * TLSが無効なネットワークでチェーンコードをインスタンス化するには、コマンド固有のオプションのみを使用します:

    ```
    peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"


    2018-02-22 16:34:09.324 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
    2018-02-22 16:34:09.324 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
    2018-02-22 16:34:24.698 UTC [main] main -> INFO 003 Exiting.....
    ```

### peer chaincode invoke example

以下は、`peer chaincode invoke`コマンドの例です:

  * `peer0.org1.example.com:7051` と `peer0.org2.example.com:9051` (`--peerAddresses` で定義されるピア) のチャネル `mychannel` 上の
    バージョン `1.0` の `mycc` というチェーンコードを呼び出して、変数 `a` から変数 `b` へ 10 ユニットを移動することをリクエストします:

    ```
    peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --peerAddresses peer0.org2.example.com:9051 -c '{"Args":["invoke","a","b","10"]}'

    2018-02-22 16:34:27.069 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
    2018-02-22 16:34:27.069 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
    .
    .
    .
    2018-02-22 16:34:27.106 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> DEBU 00a ESCC invoke result: version:1 response:<status:200 message:"OK" > payload:"\n \237mM\376? [\214\002 \332\204\035\275q\227\2132A\n\204&\2106\037W|\346#\3413\274\022Y\nE\022\024\n\004lscc\022\014\n\n\n\004mycc\022\002\010\003\022-\n\004mycc\022%\n\007\n\001a\022\002\010\003\n\007\n\001b\022\002\010\003\032\007\n\001a\032\00290\032\010\n\001b\032\003210\032\003\010\310\001\"\013\022\004mycc\032\0031.0" endorsement:<endorser:"\n\007Org1MSP\022\262\006-----BEGIN CERTIFICATE-----\nMIICLjCCAdWgAwIBAgIRAJYomxY2cqHA/fbRnH5a/bwwCgYIKoZIzj0EAwIwczEL\nMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG\ncmFuY2lzY28xGTAXBgNVBAoTEG9yZzEuZXhhbXBsZS5jb20xHDAaBgNVBAMTE2Nh\nLm9yZzEuZXhhbXBsZS5jb20wHhcNMTgwMjIyMTYyODE0WhcNMjgwMjIwMTYyODE0\nWjBwMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMN\nU2FuIEZyYW5jaXNjbzETMBEGA1UECxMKRmFicmljUGVlcjEfMB0GA1UEAxMWcGVl\ncjAub3JnMS5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABDEa\nWNNniN3qOCQL89BGWfY39f5V3o1pi//7JFDHATJXtLgJhkK5KosDdHuKLYbCqvge\n46u3AC16MZyJRvKBiw6jTTBLMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAA\nMCsGA1UdIwQkMCKAIN7dJR9dimkFtkus0R5pAOlRz5SA3FB5t8Eaxl9A7lkgMAoG\nCCqGSM49BAMCA0cAMEQCIC2DAsO9QZzQmKi8OOKwcCh9Gd01YmWIN3oVmaCRr8C7\nAiAlQffq2JFlbh6OWURGOko6RckizG8oVOldZG/Xj3C8lA==\n-----END CERTIFICATE-----\n" signature:"0D\002 \022_\342\350\344\231G&\237\n\244\375\302J\220l\302\345\210\335D\250y\253P\0214:\221e\332@\002 \000\254\361\224\247\210\214L\277\370\222\213\217\301\r\341v\227\265\277\336\256^\217\336\005y*\321\023\025\367" >
    2018-02-22 16:34:27.107 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 00b Chaincode invoke successful. result: status:200
    2018-02-22 16:34:27.107 UTC [main] main -> INFO 00c Exiting.....

    ```

    以下のようなログメッセージにより、invoke が正常に送信されたことを確認することができます:

    ```
    2018-02-22 16:34:27.107 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 00b Chaincode invoke successful. result: status:200

    ```
    成功したレスポンスはトランザクションが正常にオーダリングのために提出されたことを示します。
    その後、トランザクションはブロックに追加され、最後にチャネル上の各ピアによって有効化または無効化されます。

以下は、チェーンコードパッケージに複数のスマートコントラクトが含まれている場合の、`peer chaincode invoke` コマンドのフォーマット記述方法の例です:

  * [contract-api](https://www.npmjs.com/package/fabric-contract-api) を使用している場合、`super("MyContract")` に渡す名前をプレフィックスとして使用することができます。

    ```
    peer chaincode invoke -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{ "Args": ["MyContract:methodName", "{}"] }'

    peer chaincode invoke -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{ "Args": ["MyOtherContract:methodName", "{}"] }'

    ```


### peer chaincode list example

以下は、`peer chaincode list` コマンドの例です：

  * ピアにインストールされているチェーンコードを一覧表示するには、`--installed`フラグを使用します。

    ```
    peer chaincode list --installed

    Get installed chaincodes on peer:
    Name: mycc, Version: 1.0, Path: github.com/hyperledger/fabric-samples/chaincode/abstore/go, Id: 8cc2730fdafd0b28ef734eac12b29df5fc98ad98bdb1b7e0ef96265c3d893d61
    2018-02-22 17:07:13.476 UTC [main] main -> INFO 001 Exiting.....
    ```

    ピアは、バージョン `1.0` の `mycc` というチェーンコードをインストールしていることがわかります。

  * `instantiated` と `-C`（チャネルID）フラグを併用することで、チャネルにインスタンス化されたチェーンコードを一覧表示することができます。

    ```
    peer chaincode list --instantiated -C mychannel

    Get instantiated chaincodes on channel mychannel:
    Name: mycc, Version: 1.0, Path: github.com/hyperledger/fabric-samples/chaincode/abstore/go, Escc: escc, Vscc: vscc
    2018-02-22 17:07:42.969 UTC [main] main -> INFO 001 Exiting.....

    ```

    バージョン `1.0` のチェーンコード `mycc` がチャネル `mychannel` にインスタンス化されていることがわかります。

### peer chaincode package example

以下は `peer chaincode package` コマンドの例で、`mycc` という名前のチェーンコードをバージョン `1.1` でパッケージし、
チェーンコードデプロイメントスペック (訳注: v1.xのパッケージ形式) を作成し、ローカル MSP を使ってパッケージに署名し、`ccpack.out` として出力しています:

  ```
    peer chaincode package ccpack.out -n mycc -p github.com/hyperledger/fabric-samples/chaincode/abstore/go -v 1.1 -s -S
    .
    .
    .
    2018-02-22 17:27:01.404 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2018-02-22 17:27:01.405 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    .
    .
    .
    2018-02-22 17:27:01.879 UTC [chaincodeCmd] chaincodePackage -> DEBU 011 Packaged chaincode into deployment spec of size <3426>, with args = [ccpack.out]
    2018-02-22 17:27:01.879 UTC [main] main -> INFO 012 Exiting.....

  ```

### peer chaincode query example

以下は `peer chaincode query` コマンドの例です。ピアの台帳に対して、バージョン `1.0` の `mycc` という名前のチェーンコードの変数 `a` の値をクエリします:

  * 出力から、クエリ実行時に変数 `a` の値が90であったことがわかると思います。

    ```
    peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

    2018-02-22 16:34:30.816 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
    2018-02-22 16:34:30.816 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
    Query Result: 90

    ```

### peer chaincode signpackage example

ここでは、`peer chaincode signpackage`コマンドの例を示します。このコマンドは、既存の署名付きパッケージを受け取り、ローカルMSPの署名が付加された新しいパッケージを作成します。

  ```
  peer chaincode signpackage ccwith1sig.pak ccwith2sig.pak
  Wrote signed package to ccwith2sig.pak successfully
  2018-02-24 19:32:47.189 EST [main] main -> INFO 002 Exiting.....
  ```

### peer chaincode upgrade example

以下は `peer chaincode upgrade` コマンドの例で、チャネル `mychannel` の `mycc` という名前のチェーンコードをバージョン `1.1` にアップグレードし、新しい変数 `c` を含むバージョン `1.2` にアップグレードします:

  * TLS が有効なネットワークでチェーンコードをアップグレードするには、グローバルフラグ `--tls` と `--cafile` を使います:

    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer chaincode upgrade -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n mycc -v 1.2 -c '{"Args":["init","a","100","b","200","c","300"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"
    .
    .
    .
    2018-02-22 18:26:31.433 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2018-02-22 18:26:31.434 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2018-02-22 18:26:31.435 UTC [chaincodeCmd] getChaincodeSpec -> DEBU 005 java chaincode enabled
    2018-02-22 18:26:31.435 UTC [chaincodeCmd] upgrade -> DEBU 006 Get upgrade proposal for chaincode <name:"mycc" version:"1.1" >
    .
    .
    .
    2018-02-22 18:26:46.687 UTC [chaincodeCmd] upgrade -> DEBU 009 endorse upgrade proposal, get response <status:200 message:"OK" payload:"\n\004mycc\022\0031.1\032\004escc\"\004vscc*,\022\014\022\n\010\001\022\002\010\000\022\002\010\001\032\r\022\013\n\007Org1MSP\020\003\032\r\022\013\n\007Org2MSP\020\0032f\n \261g(^v\021\220\240\332\251\014\204V\210P\310o\231\271\036\301\022\032\205fC[|=\215\372\223\022 \311b\025?\323N\343\325\032\005\365\236\001XKj\004E\351\007\247\265fu\305j\367\331\275\253\307R\032 \014H#\014\272!#\345\306s\323\371\350\364\006.\000\356\230\353\270\263\215\217\303\256\220i^\277\305\214: \375\200zY\275\203}\375\244\205\035\340\226]l!uE\334\273\214\214\020\303\3474\360\014\234-\006\315B\031\022\010\022\006\010\001\022\002\010\000\032\r\022\013\n\007Org1MSP\020\001" >
    .
    .
    .
    2018-02-22 18:26:46.693 UTC [chaincodeCmd] upgrade -> DEBU 00c Get Signed envelope
    2018-02-22 18:26:46.693 UTC [chaincodeCmd] chaincodeUpgrade -> DEBU 00d Send signed envelope to orderer
    2018-02-22 18:26:46.908 UTC [main] main -> INFO 00e Exiting.....
    ```

  * TLS が無効なネットワークでチェーンコードをアップグレードするにはコマンド固有のオプションのみを使用します:

    ```
    peer chaincode upgrade -o orderer.example.com:7050 -C mychannel -n mycc -v 1.2 -c '{"Args":["init","a","100","b","200","c","300"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"
    .
    .
    .
    2018-02-22 18:28:31.433 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default escc
    2018-02-22 18:28:31.434 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 004 Using default vscc
    2018-02-22 18:28:31.435 UTC [chaincodeCmd] getChaincodeSpec -> DEBU 005 java chaincode enabled
    2018-02-22 18:28:31.435 UTC [chaincodeCmd] upgrade -> DEBU 006 Get upgrade proposal for chaincode <name:"mycc" version:"1.1" >
    .
    .
    .
    2018-02-22 18:28:46.687 UTC [chaincodeCmd] upgrade -> DEBU 009 endorse upgrade proposal, get response <status:200 message:"OK" payload:"\n\004mycc\022\0031.1\032\004escc\"\004vscc*,\022\014\022\n\010\001\022\002\010\000\022\002\010\001\032\r\022\013\n\007Org1MSP\020\003\032\r\022\013\n\007Org2MSP\020\0032f\n \261g(^v\021\220\240\332\251\014\204V\210P\310o\231\271\036\301\022\032\205fC[|=\215\372\223\022 \311b\025?\323N\343\325\032\005\365\236\001XKj\004E\351\007\247\265fu\305j\367\331\275\253\307R\032 \014H#\014\272!#\345\306s\323\371\350\364\006.\000\356\230\353\270\263\215\217\303\256\220i^\277\305\214: \375\200zY\275\203}\375\244\205\035\340\226]l!uE\334\273\214\214\020\303\3474\360\014\234-\006\315B\031\022\010\022\006\010\001\022\002\010\000\032\r\022\013\n\007Org1MSP\020\001" >
    .
    .
    .
    2018-02-22 18:28:46.693 UTC [chaincodeCmd] upgrade -> DEBU 00c Get Signed envelope
    2018-02-22 18:28:46.693 UTC [chaincodeCmd] chaincodeUpgrade -> DEBU 00d Send signed envelope to orderer
    2018-02-22 18:28:46.908 UTC [main] main -> INFO 00e Exiting.....
    ```

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
