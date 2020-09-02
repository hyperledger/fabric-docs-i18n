# configtxgen

`configtxgen` 命令允许用户创建和查看通道配置相关构件。所生成的构件取决于 `configtx.yaml` 的内容。

The `configtxgen` command allows users to create and inspect channel config
related artifacts.  The content of the generated artifacts is dictated by the
contents of `configtx.yaml`.

## 语法

`configtxgen` 工具没有子命令，但是支持标识（flag），通过设置标识可以完成不同的任务。

## configtxgen
```
Usage of configtxgen:
  -asOrg string
      以特定组织（按名称）执行配置生成，仅包括组织（可能）有权设置的写集中的值。
  -channelCreateTxBaseProfile string
      指定要视为排序系统通道当前状态的轮廓（profile），以允许在通道创建交易生成期间修改非应用程序参数。仅在与 “outputCreateChannelTX”  结合时有效。
  -channelID string
      配置交易中使用的通道 ID。
  -configPath string
      包含所用的配置的路径。（如果设置的话）
  -inspectBlock string
      打印指定路径的区块中包含的配置。
  -inspectChannelCreateTx string
      打印指定路径的交易中包含的配置。
  -outputAnchorPeersUpdate string
      创建一个更新锚节点的配置更新（仅在默认通道创建时有效，并仅用于第一次更新）。
  -outputBlock string
      写入创世区块的路径。（如果设置的话）
  -outputCreateChannelTx string
      写入通道创建交易的路径。（如果设置的话）
  -printOrg string
      以 JSON 方式打印组织的定义。（手动向通道中添加组织时很有用）
  -profile string
      configtx.yaml 中用于生成的轮廓。
  -version
      显示版本信息。
```

## 用法

### 输出初始区块

将通道 `orderer-system-channel` 和轮廓（Profile） `SampleSingleMSPRaftV1_1` 的创世区块写入 `genesis_block.pb` 。

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPRaftV1_1 -channelID orderer-system-channel
```

### 输出创建通道的交易


将轮廓 `SampleSingleMSPChannelV1_1` 的通道创建交易写入 `create_chan_tx.pb`。

```
configtxgen -outputCreateChannelTx create_chan_tx.pb -profile SampleSingleMSPChannelV1_1 -channelID application-channel-1
```

### 查看创世区块

将创世区块 `genesis_block.pb` 以 JSON 格式打印到屏幕上。

```
configtxgen -inspectBlock genesis_block.pb
```

### 查看创建通道交易

将通道创建交易 `create_chan_tx.pb` 以 JSON 的格式打印到屏幕上。

```
configtxgen -inspectChannelCreateTx create_chan_tx.pb
```

### 打印组织定义

基于 `configtx.yaml` 的配置项（比如 MSPdir）来构建组织并以 JSON 格式打印到屏幕。（常用于创建通道时的重新配置，例如添加成员）

```
configtxgen -printOrg Org1
```

### 输出锚节点交易（弃用）

将配置更新交易输出到 `anchor_peer_tx.pb`，就是将组织 Org1 的锚节点设置成 `configtx.yaml` 中轮廓 SampleSingleMSPChannelV1_1 所定义的。
```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

The `-outputAnchorPeersUpdate` output flag has been deprecated. To set anchor
peers on the channel, use [configtxlator](configtxlator.html) to update the
channel configuration.

## 配置

`configtxgen` 工具的输出依赖于 `configtx.yaml`。`configtx.yaml` 可在 `FABRIC_CFG_PATH` 下找到，且在 `configtxgen` 执行时必须存在。

Refer to the sample `configtx.yaml` shipped with Fabric for all possible
configuration options.  You may find this file in the `config` directory of
the release artifacts tar, or you may find it under the `sampleconfig` folder
if you are building from source.

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
