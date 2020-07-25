# configtxgen

`configtxgen` 命令允许用户创建和查看通道配置相关构件。所生成的构件取决于 `configtx.yaml` 的内容。

The `configtxgen` command allows users to create and inspect channel config
related artifacts.  The content of the generated artifacts is dictated by the
contents of `configtx.yaml`.

## 语法

## Syntax

`configtxgen` 工具没有子命令，但是支持标识（flag），通过设置标识可以完成不同的任务。

The `configtxgen` tool has no sub-commands, but supports flags which can be set
to accomplish a number of tasks.

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

## 用法

## Usage

### 输出创世区块

### Output a genesis block

将通道 `orderer-system-channel` 和轮廓（Profile） `SampleSingleMSPRaftV1_1` 的创世区块写入 `genesis_block.pb` 。

Write a genesis block to `genesis_block.pb` for channel `orderer-system-channel`
for profile `SampleSingleMSPRaftV1_1`.

```
configtxgen -outputBlock genesis_block.pb -profile SampleSingleMSPRaftV1_1 -channelID orderer-system-channel
```

### 输出创建通道的交易

### Output a channel creation tx

将轮廓 `SampleSingleMSPChannelV1_1` 的通道创建交易写入 `create_chan_tx.pb`。

Write a channel creation transaction to `create_chan_tx.pb` for profile
`SampleSingleMSPChannelV1_1`.

```
configtxgen -outputCreateChannelTx create_chan_tx.pb -profile SampleSingleMSPChannelV1_1 -channelID application-channel-1
```

### 查看创世区块

### Inspect a genesis block

将创世区块 `genesis_block.pb` 以 JSON 格式打印到屏幕上。

Print the contents of a genesis block named `genesis_block.pb` to the screen as
JSON.

```
configtxgen -inspectBlock genesis_block.pb
```

### 查看创建通道交易

### Inspect a channel creation tx

将通道创建交易 `create_chan_tx.pb` 以 JSON 的格式打印到屏幕上。

Print the contents of a channel creation tx named `create_chan_tx.pb` to the
screen as JSON.

```
configtxgen -inspectChannelCreateTx create_chan_tx.pb
```

### 打印组织定义

### Print an organization definition

基于 `configtx.yaml` 的配置项（比如 MSPdir）来构建组织并以 JSON 格式打印到屏幕。（常用于创建通道时的重新配置，例如添加成员）

Construct an organization definition based on the parameters such as MSPDir
from `configtx.yaml` and print it as JSON to the screen. (This output is useful
for channel reconfiguration workflows, such as adding a member).

```
configtxgen -printOrg Org1
```

### 输出锚节点交易

### Output anchor peer tx (deprecated)

将配置更新交易输出到 `anchor_peer_tx.pb`，就是将组织 Org1 的锚节点设置成 `configtx.yaml` 中轮廓 SampleSingleMSPChannelV1_1 所定义的。

Output a channel configuration update transaction `anchor_peer_tx.pb`  based on
the anchor peers defined for Org1 and channel profile SampleSingleMSPChannelV1_1
in `configtx.yaml`. Transaction will set anchor peers for Org1 if no anchor peers
have been set on the channel.
```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

```
configtxgen -outputAnchorPeersUpdate anchor_peer_tx.pb -profile SampleSingleMSPChannelV1_1 -asOrg Org1
```

The `-outputAnchorPeersUpdate` output flag has been deprecated. To set anchor
peers on the channel, use [configtxlator](configtxlator.html) to update the
channel configuration.

## 配置

## Configuration

`configtxgen` 工具的输出依赖于 `configtx.yaml`。`configtx.yaml` 可在 `FABRIC_CFG_PATH` 下找到，且在 `configtxgen` 执行时必须存在。

The `configtxgen` tool's output is largely controlled by the content of
`configtx.yaml`.  This file is searched for at `FABRIC_CFG_PATH` and must be
present for `configtxgen` to operate.

这个配置文件可以被编辑，或者通过重写环境变量的方式修改一些单独的属性，例如 `CONFIGTX_ORDERER_ORDERERTYPE=kafka`。

Refer to the sample `configtx.yaml` shipped with Fabric for all possible
configuration options.  You may find this file in the `config` directory of
the release artifacts tar, or you may find it under the `sampleconfig` folder
if you are building from source.

