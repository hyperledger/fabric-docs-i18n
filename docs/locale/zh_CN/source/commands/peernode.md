# peer node

管理员可以通过 `peer node` 命令来启动 Peer 节点，将节点中的所有通道重置为创世区块，或者将某个通道回滚到给定区块号。

The `peer node` command allows an administrator to start a peer node,
reset all channels in a peer to the genesis block, or rollback a
channel to a given block number.

## 语法

## Syntax

`peer node` 命令有如下子命令：

The `peer node` command has the following subcommands:

  * start
  * reset
  * rollback

## peer node start
```
启动一个和网络交互的节点。

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
将通道重置到创世区块。执行该命令时，节点必须是离线的。当节点在重置之后启动时，它将会从排序节点或者其他 Peer 节点从1号区块开始获取区块，并重建区块存储和状态数据库。

## peer node reset
```
Resets all channels to the genesis block. When the command is executed, the peer must be offline. When the peer starts after the reset, it will receive blocks starting with block number one from an orderer or another peer to rebuild the block store and state database.

Usage:
  peer node reset [flags]

Flags:
  -h, --help   reset 的帮助
```

Flags:
  -h, --help   help for reset
```

## peer node rollback
```
从指定的区块号回滚通道。执行该命令时，节点必须是离线的。当节点在回滚之后启动时，它将会从排序节点或者其他 Peer 节点获取回滚过程中删除的区块，并重建区块存储和状态数据库。


Usage:
  peer node rollback [flags]

## peer node rollback
```
Rolls back a channel to a specified block number. When the command is executed, the peer must be offline. When the peer starts after the rollback, it will receive blocks, which got removed during the rollback, from an orderer or another peer to rebuild the block store and state database.

Flags:
  -b, --blockNumber uint   通道要回滚的区块序号
  -c, --channelID string   要回滚的通道
  -h, --help               rollback 的帮助
```

Usage:
  peer node rollback [flags]

## 示例用法

Flags:
  -b, --blockNumber uint   Block number to which the channel needs to be rolled back to.
  -c, --channelID string   Channel to rollback.
  -h, --help               help for rollback
```

### peer node start example

## Example Usage

下边的命令：

### peer node start example

```
peer node start --peer-chaincodedev
```

The following command:

以开发者模式启动 Peer 节点。一般来说链码容器由 Peer 节点启动和维护。但是在链码的开发者模式下，链码通过用户来编译和启动。这个模式在链码开发阶段很有帮助。更多信息请查看开发模式下的[链码教程](../chaincode4ade.html)。

```
peer node start --peer-chaincodedev
```

### peer node reset example

starts a peer node in chaincode development mode. Normally chaincode containers are started
and maintained by peer. However in chaincode development mode, chaincode is built and started by the user. This mode is useful during chaincode development phase for iterative development.

```
peer node reset
```

### peer node reset example

resets all channels in the peer to the genesis block, i.e., the first block in the channel. The command also records the pre-reset height of each channel in the file system. Note that the peer process should be stopped while executing this command. If the peer process is running, this command detects that and returns an error instead of performing the reset. When the peer is started after performing the reset, the peer will fetch the blocks for each channel which were removed by the reset command (either from other peers or orderers) and commit the blocks up to the pre-reset height. Until all channels reach the pre-reset height, the peer will not endorse any transactions.

```
peer node reset
```

### peer node rollback example

resets all channels in the peer to the genesis block, i.e., the first block in the channel. The command also records the pre-reset height of each channel in the file system. Note that the peer process should be stopped while executing this command. If the peer process is running, this command detects that and returns an error instead of performing the reset. When the peer is started after performing the reset, the peer will fetch the blocks for each channel which were removed by the reset command (either from other peers or orderers) and commit the blocks up to the pre-reset height. Until all channels reach the pre-reset height, the peer will not endorse any transactions.

The following command:

### peer node rollback example

```
peer node rollback -c ch1 -b 150
```

The following command:

rolls back the channel ch1 to block number 150. The command also records the pre-rolled back height of channel ch1 in the file system. Note that the peer should be stopped while executing this command. If the peer process is running, this command detects that and returns an error instead of performing the rollback. When the peer is started after performing the rollback, the peer will fetch the blocks for channel ch1 which were removed by the rollback command (either from other peers or orderers) and commit the blocks up to the pre-rolled back height. Until the channel ch1 reaches the pre-rolled back height, the peer will not endorse any transaction for any channel.

```
peer node rollback -c ch1 -b 150
```

rolls back the channel ch1 to block number 150. The command also records the pre-rolled back height of channel ch1 in the file system. Note that the peer should be stopped while executing this command. If the peer process is running, this command detects that and returns an error instead of performing the rollback. When the peer is started after performing the rollback, the peer will fetch the blocks for channel ch1 which were removed by the rollback command (either from other peers or orderers) and commit the blocks up to the pre-rolled back height. Until the channel ch1 reaches the pre-rolled back height, the peer will not endorse any transaction for any channel.
