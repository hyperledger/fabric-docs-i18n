# peer version

`peer version` 命令可以查看 peer 的版本信息。它会显示版本号、Commit SHA、Go 的版本、操作系统及架构和链码信息。例如：

The `peer version` command displays the version information of the peer. It
displays version, Commit SHA, Go version, OS/architecture, and chaincode
information. For example:

```
 peer:
   Version: 1.4.0
   Commit SHA: 0efc897
   Go version: go1.11.1
   OS/Arch: linux/amd64
   Chaincode:
    Base Image Version: 0.4.14
    Base Docker Namespace: hyperledger
    Base Docker Label: org.hyperledger.fabric
    Docker Namespace: hyperledger
```

```
 peer:
   Version: 2.1.0
   Commit SHA: b78d79b
   Go version: go1.14.1
   OS/Arch: linux/amd64
   Chaincode:
    Base Docker Label: org.hyperledger.fabric
    Docker Namespace: hyperledger
```

## 语法

## Syntax

`peer version` 命令没有参数。

The `peer version` command takes no arguments.

## peer version
```
Print current version of the fabric peer server.

Usage:
  peer version [flags]

Flags:
  -h, --help   help for version
```

