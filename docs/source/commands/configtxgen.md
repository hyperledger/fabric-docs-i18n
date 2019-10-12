# configtxgen

`configtxgen`命令允许用户创建和查看通道配置相关部件。所生成的部件取决于`configtx.yaml`的内容。

## 语法

`configtxgen` 工具没有子命令，但是支持flags，通过设置flags可以完成不同的任务。

## configtxgen
```
Usage of configtxgen:
  -asOrg string
    	Performs the config generation as a particular organization (by name), only including values in the write set that org (likely) has privilege to set
  -channelCreateTxBaseProfile string
    	Specifies a profile to consider as the orderer system channel current state to allow modification of non-application parameters during channel create tx generation. Only valid in conjuction with 'outputCreateChannelTx'.
  -channelID string
    	The channel ID to use in the configtx
  -configPath string
    	The path containing the configuration to use (if set)
  -inspectBlock string
    	Prints the configuration contained in the block at the specified path
  -inspectChannelCreateTx string
    	Prints the configuration contained in the transaction at the specified path
  -outputAnchorPeersUpdate string
    	Creates an config update to update an anchor peer (works only with the default channel creation, and only for the first update)
  -outputBlock string
    	The path to write the genesis block to (if set)
  -outputCreateChannelTx string
    	The path to write a channel creation configtx to (if set)
  -printOrg string
    	Prints the definition of an organization as JSON. (useful for adding an org to a channel manually)
  -profile string
    	The profile from configtx.yaml to use for generation. (default "SampleInsecureSolo")
  -version
    	Show version information
```

## 用法

### 输出创世块

将一个创世块写到`genesis_block.pb`，指定通道 `orderer-system-channel`和profile `SampleSingleMSPSoloV1_1`

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPSoloV1_1 -channelID orderer-system-channel
```

### 输出创建通道的交易

将一个创建通道的交易写到 `create_chan_tx.pb`，指定profile`SampleSingleMSPChannelV1_1`。

```
configtxgen -outputCreateChannelTx create_chan_tx.pb -profile SampleSingleMSPChannelV1_1 -channelID application-channel-1
```

### 查看创世块

将创世块 `genesis_block.pb`以JSON的格式打印到屏幕上。

```
configtxgen -inspectBlock genesis_block.pb
```

### 查看创建通道交易

将创建通道交易 `create_chan_tx.pb`以JSON的格式打印到屏幕上。

```
configtxgen -inspectChannelCreateTx create_chan_tx.pb
```

### 打印组织定义

基于`configtx.yaml`里的配置项(比如MSPdir)来构建组织并以JSON格式打印到屏幕。(常用于创建通道时的重新配置，例如添加成员)

```
configtxgen -printOrg Org1
```

### 输出锚节点交易

将配置更新的交易输出到`anchor_peer_tx.pb`，具体就是将组织Org1的锚节点设置成`configtx.yaml`中 SampleSingleMSPChannelV1_1 所定义的。

```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

## 配置

configtxgen工具的输出大量依赖于`configtx.yaml`。`configtx.yaml`可在`FABRIC_CFG_PATH`下找到，且在`configtxgen`执行时必须存在。

`CONFIGTX_ORDERER_ORDERERTYPE=kafka`.
这个配置文件可以被编辑，或者通过重写环境变量的方式修改一些单独的属性，例如`CONFIGTX_ORDERER_ORDERERTYPE=kafka`.

对许多`configtxgen`的操作来说，必须提供配置名(profile name)。使用Profiles可以在一个文件里描述多条相似的配置。例如，一个profile中可以定义含有3个组织的通道，另一个profile可能定义了含4个组织的通道。`configtx.yaml`依赖YAML的锚点和引用特性从而避免文件变得繁重。配置中的基础部分使用锚点标记，例如`<<: *OrdererDefaults`，然后合并到一个profile的引用，例如 `<<: *OrdererDefaults`。要注意的是，当使用profile来执行`configtxgen`时，重写环境变量不必包含profile前缀，可以直接从引用profile的根元素开始引用。例如，不用指定
`CONFIGTX_PROFILE_SAMPLEINSECURESOLO_ORDERER_ORDERERTYPE`,
而是省略profile的细节，使用 `CONFIGTX`前缀，后面直接使用相对配置名后的元素，例如
`CONFIGTX_ORDERER_ORDERERTYPE`

参考Fabric中的示例 `configtx.yaml`可以查看所有可能的配置选项。
你可以在release版本的`config`文件夹，或者源码的`sampleconfig`文件夹找到这个配置文件。

