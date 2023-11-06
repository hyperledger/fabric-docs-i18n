# configtxlator

`configtxlator` コマンドは、ユーザーがFabricのデータ構造をプロトコルバッファとJSONの間で変換し、設定の更新ファイルを作成することができるコマンドです。
このコマンドは、RESTサーバーとしてHTTP経由で機能を受け付けることもできますし、コマンドラインツールとして直接使うこともできます。

## Syntax

`configtxlator` ツールには5つの下記のサブコマンドがあります。

  * start
  * proto_encode
  * proto_decode
  * compute_update
  * version

## configtxlator start
```
usage: configtxlator start [<flags>]

Start the configtxlator REST server

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --hostname="0.0.0.0"  The hostname or IP on which the REST server will listen
  --port=7059           The port on which the REST server will listen
  --CORS=CORS ...       Allowable CORS domains, e.g. '*' or 'www.example.com'
                        (may be repeated).
```


## configtxlator proto_encode
```
usage: configtxlator proto_encode --type=TYPE [<flags>]

Converts a JSON document to protobuf.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to encode to. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the JSON document.
  --output=/dev/stdout  A file to write the output to.
```


## configtxlator proto_decode
```
usage: configtxlator proto_decode --type=TYPE [<flags>]

Converts a proto message to JSON.

Flags:
  --help                Show context-sensitive help (also try --help-long and
                        --help-man).
  --type=TYPE           The type of protobuf structure to decode from. For
                        example, 'common.Config'.
  --input=/dev/stdin    A file containing the proto message.
  --output=/dev/stdout  A file to write the JSON document to.
```


## configtxlator compute_update
```
usage: configtxlator compute_update --channel_id=CHANNEL_ID [<flags>]

Takes two marshaled common.Config messages and computes the config update which
transitions between the two.

Flags:
  --help                   Show context-sensitive help (also try --help-long and
                           --help-man).
  --original=ORIGINAL      The original config message.
  --updated=UPDATED        The updated config message.
  --channel_id=CHANNEL_ID  The name of the channel for this update.
  --output=/dev/stdout     A file to write the JSON document to.
```


## configtxlator version
```
usage: configtxlator version

Show version information

Flags:
  --help  Show context-sensitive help (also try --help-long and --help-man).
```

## Examples

### Decoding

`fabric_block.pb`というブロックをJSONに変換し、標準出力に表示します。

```
configtxlator proto_decode --input fabric_block.pb --type common.Block
```

別の方法として、RESTサーバーを開始した後に、下記のcurlコマンドを実行することで、REST APIを介して同じ操作ができます。

```
curl -X POST --data-binary @fabric_block.pb "${CONFIGTXLATOR_URL}/protolator/decode/common.Block"
```

### Encoding

標準入力で与えるポリシーのJSONファイルを変換し、`policy.pb`というファイルに出力します。

```
configtxlator proto_encode --type common.Policy --output policy.pb
```

別の方法として、RESTサーバーを開始した後に、下記のcurlコマンドを実行することで、REST APIを介して同じ操作ができます。

```
curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/encode/common.Policy" > policy.pb
```

### Pipelines

`original_config.pb`から`modified_config.pb`への設定の更新差分を計算し、JSONにデコードして標準出力に表示します。

```
configtxlator compute_update --channel_id testchan --original original_config.pb --updated modified_config.pb | configtxlator proto_decode --type common.ConfigUpdate
```

別の方法として、RESTサーバーを開始した後に、下記のcurlコマンドを実行することで、REST APIを介して同じ操作ができます。

```
curl -X POST -F channel=testchan -F "original=@original_config.pb" -F "updated=@modified_config.pb" "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" | curl -X POST --data-binary /dev/stdin "${CONFIGTXLATOR_URL}/protolator/decode/common.ConfigUpdate"
```

## Additional Notes

このツールの名前は、 *configtx* と *translator* の混成語で、同じ内容の異なるデータ表現の間を単純変換するツールという意味を持たせる意図によるものです。このツールは、設定を生成しませんし、設定を送信することも取得することもありませんし、このツールだけでは設定の変更もしません。このツールは、configtxのフォーマットの異なる表現の間の全単射の操作を提供するだけのものです。

`configtxlator`には設定ファイルはありませんし、RESTサーバーには認証・認可の仕組みは含まれていません。
`configtxlator`は、データや鍵マテリアル、そのほかの機密となりうる情報へのアクセスを持っていないため、サーバーの所有者がこれを他のクライアントに公開することにリスクはありません。
ただし、ユーザーがRESTサーバーに送るデータは機密のものがありうるため、ユーザーはサーバーの管理者を信頼するか、ローカルのインスタンスを立ち上げるか、CLIによって操作する必要があります。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
