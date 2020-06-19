# peer

## 描述


`peer` 命令有5个不同的子命令，每个命令都可以让指定的 peer 节点执行特定的一组任务。比如，你可以使用子命令 `peer channel` 让一个 peer 节点加入通道，或者使用 `peer chaincode` 命令把智能合约链码部署到 peer 节点上。

## 语法

`peer` 命令的5个子命令如下：

```
peer chaincode [option] [flags]
peer channel   [option] [flags]
peer logging   [option] [flags]
peer node      [option] [flags]
peer version   [option] [flags]
```

每一个子命令拥有不同的选项 (option)，并且会在它们专属的章节进行介绍。为了简便起见，我们说一个**命令**的时候，通常包含了 `peer` 命令，`channel` 子命令，以及 `fetch` 子命令选项。

如果使用子命令没有指定选项，会打印更高一级的帮助信息，下文的 `--help` 标记会进行描述。

## 标记

`peer` 的每个子命令都有一组标记，由于一些标记可以被所有子命令使用，所有它们设置为*全局性*的。这些标记会在 `peer` 的子命令中进行介绍。

顶层的 `peer` 命令有如下标记：

* `--help`

  使用`--help`可以获得 `peer` 命令的简要帮助信息。`--help` 标记非常有用，它统一可以获取子命令和选项的帮助信息。

  比如
  ```
  peer --help
  peer channel --help
  peer channel list --help
  ```
  各子命令的帮助信息细节见 `peer` 的个子命令。

## 用法

这是展示 `peer` 命令标记用法的样例：
* 在 `peer channel join` 命令上使用 `--help` 标记。

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
  这展示了 `peer channel join` 命令的简要帮助信息。
