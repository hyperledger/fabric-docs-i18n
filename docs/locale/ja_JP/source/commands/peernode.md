# peer node

`peer node` コマンドは、管理者がピアノードを起動したり、ピア内のすべてのチャネルをジェネシスブロックにリセットしたり、
チャネルを指定されたブロック番号にロールバックしたりすることを可能にします。

## Syntax

`peer node` コマンドには以下のサブコマンドがあります:

  * start
  * reset
  * rollback

## peer node start
```
Starts a node that interacts with the network.

Usage:
  peer node start [flags]

Flags:
  -h, --help                help for start
      --peer-chaincodedev   start peer in chaincode development mode
```


## peer node reset
```
Resets all channels to the genesis block. When the command is executed, the peer must be offline. When the peer starts after the reset, it will receive blocks starting with block number one from an orderer or another peer to rebuild the block store and state database.

Usage:
  peer node reset [flags]

Flags:
  -h, --help   help for reset
```


## peer node rollback
```
Rolls back a channel to a specified block number. When the command is executed, the peer must be offline. When the peer starts after the rollback, it will receive blocks, which got removed during the rollback, from an orderer or another peer to rebuild the block store and state database.

Usage:
  peer node rollback [flags]

Flags:
  -b, --blockNumber uint   Block number to which the channel needs to be rolled back to.
  -c, --channelID string   Channel to rollback.
  -h, --help               help for rollback
```

## Example Usage

### peer node start example

以下のコマンドを実行すると:

```
peer node start --peer-chaincodedev
```

コマンドは、ピアノードをチェーンコード開発モードで起動します。
通常、チェーンコードコンテナはピアによって起動され管理されます。
しかしチェーンコード開発モードでは、チェーンコードはユーザーによってビルドされ開始されます。
このモードは、チェーンコードの開発フェーズにおいて、反復的な開発のために有用です。

### peer node reset example

```
peer node reset
```

上記のコマンドは、ピアのすべてのチャネルをジェネシスブロック、つまりチャネルの最初のブロックにリセットします。
このコマンドは、ファイルシステム内の各チャネルのリセット前のブロックの高さも記録します。
このコマンドを実行している間は、ピアプロセスを停止しておく必要があることに注意してください。
ピアプロセスが実行中の場合、このコマンドはそれを検出し、リセットを実行する代わりにエラーを返します。
リセットの実行後にピアが起動すると、ピアは、リセットコマンドによって削除された各チャネルのブロックを（他のピアまたはOrdererから）取得し、
リセット前の高さまでブロックをコミットします。
すべてのチャネルがリセット前の高さに達するまで、ピアはいかなるトランザクションもエンドースしません。

### peer node rollback example

以下のコマンドを実行すると:

```
peer node rollback -c ch1 -b 150
```

コマンドは、チャネルch1をブロック番号150にロールバックします。
このコマンドは、ファイルシステムにチャネルch1のロールバック前のブロックの高さを記録します。
このコマンドを実行している間は、ピアを停止しておく必要があることに注意してください。
ピアプロセスが実行中の場合、このコマンドはそれを検出し、ロールバックを実行する代わりにエラーを返します。
ロールバックを実行した後にピアが起動すると、ピアはロールバックコマンドによって削除されたチャネルch1のブロックを（他のピアまたはOrdererから）取得し、
ロールバック前の高さまでブロックをコミットします。チャネルch1がロールバック前の高さに達するまで、
ピアはいかなるチャネルのトランザクションもエンドースしません。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
