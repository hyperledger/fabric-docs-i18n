# peer node

管理员可以通过 `peer node` 命令来启动 Peer 节点，将节点中的所有通道重置为创世区块，或者将某个通道回滚到给定区块号。

## 语法

`peer node` 命令有如下子命令：

  * start
  * reset
  * rollback

## peer node start
```
启动一个和网络交互的节点。

Usage:
  peer node start [flags]

Flags:
  -h, --help                help for start
      --peer-chaincodedev   start peer in chaincode development mode
```


## peer node reset
```
将通道重置到创世区块。执行该命令时，节点必须是离线的。当节点在重置之后启动时，它将会从排序节点或者其他 Peer 节点从1号区块开始获取区块，并重建区块存储和状态数据库。

Usage:
  peer node reset [flags]

Flags:
  -h, --help   reset 的帮助
```

## peer node rollback
```
从指定的区块号回滚通道。执行该命令时，节点必须是离线的。当节点在回滚之后启动时，它将会从排序节点或者其他 Peer 节点获取回滚过程中删除的区块，并重建区块存储和状态数据库。


Usage:
  peer node rollback [flags]

Flags:
  -b, --blockNumber uint   通道要回滚的区块序号
  -c, --channelID string   要回滚的通道
  -h, --help               rollback 的帮助
```

## 示例用法

### peer node start 示例

下边的命令：

```
peer node start --peer-chaincodedev
```

以开发者模式启动 Peer 节点。一般来说链码容器由 Peer 节点启动和维护。但是在链码的开发者模式下，链码通过用户来编译和启动。这个模式在链码开发阶段很有帮助。

### peer node reset 示例

```
peer node reset
```

将peer节点中的所有通道重置为创世块，即通道中的第一个区块。
该命令还会记录文件系统中每个通道重置前的高度。
注意，在执行此命令时，peer节点进程应该被停止。
如果peer节点进程正在运行，该命令会检测到并返回一个错误，而不是继续执行重置。
在peer节点执行重置后启动时，
peer节点将为每个通道获取因重置命令而移除的区块(从其他peer节点或排序节点)，
并提交这些区块直到重置前的高度。
在所有通道达到重置前的高度之前，peer节点不会背书任何交易。

### peer node rollback 示例

The following command:

```
peer node rollback -c ch1 -b 150
```

回滚通道ch1的账本到第150号区块。该命令也记录文件系统中通道ch1回滚前的高度。
注意，在执行此命令时，peer节点进程应该被停止。
如果peer节点进程正在运行，该命令会检测到并返回一个错误，而不是继续执行回滚。
在peer节点执行回滚后启动时，peer节点将(从其他peer节点或排序节点)获取通道ch1被回滚命令移除的区块，
并且peer节点将提交这些区块到回滚前的高度。
在通道ch1达到回滚前的高度之前，peer节点不会为任何通道背书任何交易。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
