# peer node

管理员可以通过 `peer node` 命令来启动 Peer 节点或者检查节点状态。

## 语法

`peer node` 命令有如下子命令：

  * start
  * status

## peer node start
```
启动一个和网络交互的节点。

Usage:
  peer node start [flags]

Flags:
  -h, --help                start 的帮助
      --peer-chaincodedev   是否启动链码开发者模式
```

## peer node status
```
返回正在运行的节点的状态。

Usage:
  peer node status [flags]

Flags:
  -h, --help   status 的帮助
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

### peer node start example

下边的命令：

```
peer node start --peer-chaincodedev
```

以开发者模式启动 Peer 节点。一般来说链码容器由 Peer 节点启动和维护。但是在链码的开发者模式下，链码通过用户来编译和启动。这个模式在链码开发阶段很有帮助。更多信息请查看开发模式下的[链码教程](../chaincode4ade.html)。

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.
