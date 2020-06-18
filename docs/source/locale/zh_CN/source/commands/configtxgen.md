# configtxgen

`configtxgen` 命令允许用户创建和查看通道配置相关构件。所生成的构件取决于 `configtx.yaml` 的内容。

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
      configtx.yaml 中用于生成的轮廓。默认（“SampleInsecureSolo”）
  -version
      显示版本信息。
```

## 用法

### 输出创世区块

将通道 `orderer-system-channel` 和轮廓（Profile） `SampleSingleMSPSoloV1_1` 的创世区块写入 `genesis_block.pb` 。

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPSoloV1_1 -channelID orderer-system-channel
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

### 输出锚节点交易

将配置更新交易输出到 `anchor_peer_tx.pb`，就是将组织 Org1 的锚节点设置成 `configtx.yaml` 中轮廓 SampleSingleMSPChannelV1_1 所定义的。

```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

## 配置

`configtxgen` 工具的输出依赖于 `configtx.yaml`。`configtx.yaml` 可在 `FABRIC_CFG_PATH` 下找到，且在 `configtxgen` 执行时必须存在。

这个配置文件可以被编辑，或者通过重写环境变量的方式修改一些单独的属性，例如 `CONFIGTX_ORDERER_ORDERERTYPE=kafka`。

对许多 `configtxgen` 的操作来说，必须提供轮廓名（profile name）。使用轮廓可以在一个文件里描述多条相似的配置。例如，一个轮廓中可以定义含有3个组织的通道，另一个轮廓可能定义了含4个组织的通道。`configtx.yaml` 依赖 YAML 的锚点和引用特性从而避免文件变得繁重。配置中的基础部分使用锚点标记，例如 `&OrdererDefaults`，然后合并到一个轮廓的引用，例如 `<<: *OrdererDefaults`。要注意的是，当使用轮廓来执行 `configtxgen` 时，重写环境变量不必包含轮廓前缀，可以直接从引用轮廓的根元素开始引用。例如，不用指定 `CONFIGTX_PROFILE_SAMPLEINSECURESOLO_ORDERER_ORDERERTYPE`, 而是省略轮廓的细节，使用 `CONFIGTX` 前缀，后面直接使用相对配置名后的元素，例如 `CONFIGTX_ORDERER_ORDERERTYPE`。

参考 Fabric 中的示例 `configtx.yaml` 可以查看所有可能的配置选项。你可以在发布版本的 `config` 文件夹，或者源码的 `sampleconfig` 文件夹找到这个配置文件。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.