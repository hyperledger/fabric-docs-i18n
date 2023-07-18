# configtxgen

`configtxgen` は、ユーザーがチャネル設定に関連するアーティファクトを作成したり中身を確認できるコマンドです。
`configtx.yaml` の内容によって、生成されるアーティファクトの内容が決まります。

## Syntax

`configtxgen` ツールにはサブコマンドはありませんが、いくつかのタスクを行うためのフラグをサポートしています。

## configtxgen
```
Usage of configtxgen:
  -asOrg string
    	Performs the config generation as a particular organization (by name), only including values in the write set that org (likely) has privilege to set
  -channelCreateTxBaseProfile string
    	Specifies a profile to consider as the orderer system channel current state to allow modification of non-application parameters during channel create tx generation. Only valid in conjunction with 'outputCreateChannelTx'.
  -channelID string
    	The channel ID to use in the configtx
  -configPath string
    	The path containing the configuration to use (if set)
  -inspectBlock string
    	Prints the configuration contained in the block at the specified path
  -inspectChannelCreateTx string
    	Prints the configuration contained in the transaction at the specified path
  -outputAnchorPeersUpdate string
    	[DEPRECATED] Creates a config update to update an anchor peer (works only with the default channel creation, and only for the first update)
  -outputBlock string
    	The path to write the genesis block to (if set)
  -outputCreateChannelTx string
    	The path to write a channel creation configtx to (if set)
  -printOrg string
    	Prints the definition of an organization as JSON. (useful for adding an org to a channel manually)
  -profile string
    	The profile from configtx.yaml to use for generation.
  -version
    	Show version information
```

## Usage

### Output a genesis block

プロファイル `SampleSingleMSPRaftV1_1` のチャネル `orderer-system-channel` のためのジェネシスブロックを `genesis_block.pb` として書き出します。

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPRaftV1_1 -channelID orderer-system-channel
```

### Output a channel creation tx

プロファイル `SampleSingleMSPChannelV1_1` のチャネル作成トランザクションを `create_chan_tx.pb` として書き出します。

```
configtxgen -outputCreateChannelTx create_chan_tx.pb -profile SampleSingleMSPChannelV1_1 -channelID application-channel-1
```

### Inspect a genesis block

`genesis_block.pb` という名前のジェネシスブロックの内容をスクリーンにJSON形式で出力します。

```
configtxgen -inspectBlock genesis_block.pb
```

### Inspect a channel creation tx

`create_chan_tx.pb` という名前のチャネル作成トランザクションの内容をスクリーンにJSON形式で出力します。

```
configtxgen -inspectChannelCreateTx create_chan_tx.pb
```

### Print an organization definition

パラメータ (例えば `configtx.yaml` 内のMSPDir など) に従って組織の定義を生成し、スクリーンにJSON形式で出力します。
(この出力は、メンバーを追加する場合など、チャネルを再設定するワークフローで役に立ちます)

```
configtxgen -printOrg Org1
```

### Output anchor peer tx (deprecated)

`configtx.yaml` 内のプロファイル `SampleSingleMSPChannelV1_1` とOrg1で定義されているアンカーピアをもとに、チャネル設定更新トランザクションを `anchor_peer_tx.pb` として出力します。このトランザクションは、Org1に対してそのチャネルでアンカーピアが設定されていなかった場合には、アンカーピアを設定します。

```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

この `-outputAnchorPeersUpdate` 出力フラグは非推奨です。チャネルのアンカーピアを設定するには、[configtxlator](configtxlator.html)を使ってチャネル設定を更新してください。

## Configuration

`configtxgen` ツールの出力の多くは、`configtx.yaml` の内容に左右されます。
このファイルは `FABRIC_CFG_PATH` から探され、`configtxgen` が動作するためには、このファイルが存在している必要があります。

設定可能な全オプションについては、Fabricに同梱している`configtx.yaml` サンプルを参照してください。
このファイルは、リリースのアーティファクトのtarファイル内の `config` ディレクトリ、もしくは、ソースからビルドする場合には `sampleconfig` フォルダにあります。


<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
