# peer

## Description

 `peer` コマンドには5つのサブコマンドがあり、それぞれ管理者がピアに関連する特定のタスクを実行できるようになっています。
 例えば、ピアをチャネルに参加させるには `peer channel` サブコマンドを、
 スマートコントラクトのチェーンコードをピアにデプロイするには `peer chaincode` コマンドを使用します。

## Syntax

`peer`コマンドは、その中に5つのサブコマンドを持っています:

```
peer chaincode [option] [flags]
peer channel   [option] [flags]
peer node      [option] [flags]
peer version   [option] [flags]
```

各サブコマンドにはそれぞれ異なるオプションがあり、
それらについては専用のトピックで説明します。
説明を簡潔にするために、コマンド (`peer`) やサブコマンド (`channel`)、
サブコマンドオプション (`fetch`) を単に **command** と呼ぶことがあります。

サブコマンドがオプションなしで指定された場合、
以下の `--help` フラグで説明されているような、
高レベルのヘルプテキストを返します。

## Flags

それぞれの `peer` サブコマンドには、それに関連する特定のフラグセットがあります。
その多くは *global* と呼ばれ、これらはすべてのサブコマンドオプションで使用できます。
それぞれのフラグについては、関連する `peer` サブコマンドで説明されています。

トップレベルの `peer` コマンドには以下のフラグがあります:

* `--help`

  任意の `peer` コマンドの簡単なヘルプテキストを取得するには `--help` を使用します。
  `--help` フラグは非常に便利で、コマンドのヘルプ、サブコマンドのヘルプ、そしてオプションのヘルプまで得ることができます。

  利用例:
  ```
  peer --help
  peer channel --help
  peer channel list --help

  ```
  詳細は、個々の `peer` サブコマンドを参照してください。

## Usage

以下は、`peer` コマンドで利用可能なフラグを使用した例です。

* `peer channel join` コマンドで `--help` フラグを使用する。

  ```
  peer channel join --help

  Joins the peer to a channel.

  Usage:
    peer channel join [flags]

  Flags:
    -b, --blockpath string   Path to file containing genesis block
    -h, --help               help for join

  Global Flags:
        --cafile string                       Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
        --certfile string                     Path to file containing PEM-encoded X509 public key to use for mutual TLS communication with the orderer endpoint
        --clientauth                          Use mutual TLS when communicating with the orderer endpoint
        --connTimeout duration                Timeout for client to connect (default 3s)
        --keyfile string                      Path to file containing PEM-encoded private key to use for mutual TLS communication with the orderer endpoint
    -o, --orderer string                      Ordering service endpoint
        --ordererTLSHostnameOverride string   The hostname override to use when validating the TLS connection to the orderer.
        --tls                                 Use TLS when communicating with the orderer endpoint

  ```
  これは `peer channel join` コマンドの簡単なヘルプシンタックスを表示します。
