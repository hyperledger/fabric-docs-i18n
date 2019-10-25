# 设置排序节点

在这个主题里，我们将描述启动排序节点的过程。如果你想了解更多不同排序服务的实现和它们的相对
优势与弱点的更多信息，请查看我们的[排序关键概念文档](./orderer/ordering_service.html)。

大体上，本主题将涉及几个相关联的步骤：

1. 建立排序节点所属于的组织（如果你还没有完成这个）
2. 配置节点（使用 `orderer.yaml`）
3. 建立排序节点系统通道所使用的创世区块
4. 启动排序节点

注意：这个主题假定你已经从 docker hub 拉取了 Hyperledger Fabric 排序节点镜像。

## 建立组织定义

和对等节点相似，所有的排序节点必须从属于一个在建立其之前就建立的组织。这个组织具有由
[成员服务提供者](./membership/membership.html)（MSP）封装的定义，该定义由专门为
此组织创建证书和 MSP 的证书颁发机构创建。

关于创建 CA 并使用它创建用户和 MSP 的信息，请查看[Fabric CA 用户手册](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html)。

## 配置节点

排序节点的配置通过一个名为 `orderer.yaml` 的 `yaml` 文件来处理。环境变量 `FABRIC_CFG_PATH`
被用来指向你已经配置好的 `orderer.yaml` 文件，它将提取一系列文件系统上的文件和证书。

要查看示例 `orderer.yaml`，请查看[`fabric-samples` github 仓库](https://github.com/hyperledger/fabric/blob/release-1.4/sampleconfig/orderer.yaml)，
在继续之前**应仔细阅读、研究该文档**。
特别注意一些值：

* `LocalMSPID` --- 这是排序节点组织的 MSP 的名字，由你的 CA 生成。排序节点组织管理员
会被列表显示在这里。

* `LocalMSPDir` --- 文件系统中本地 MSP 所在的位置。

*  `# TLS enabled`, `Enabled: false`。指定是否要[启用 TLS](enable_tls.html)。如果
将值设为 `true`，你必须指定相关的 TLS 证书位置。注意，这对于 Raft 节点是必须的。

* `GenesisFile` --- 这是将为排序服务生成的创世区块的名字。

* `GenesisMethod` --- 创建创世区块的方法。可以是 `file`，指定 `GenesisFile` 中的文件，
或者是 `provisional`，使用 `GenesisProfile` 中的配置。

如果你要将这个节点部署为集群中的一个部分（例如，作为 Raft 集群中的一个部分），注意 `Cluster` 
和 `Consensus` 部分。

如果你计划部署一个基于 Kafka 的排序服务，你需要完成 `Kafka` 部分。

## 生成排序节点创世区块

新创建通道的第一个区块称为“创世区块”。如果创世区块作为**新网络**创建的一部分被创建（换句话说，
如果正创建的排序节点不会加入一个已经存在的排序节点集群），那么这个创世区块将成为“排序节点系统
通道”（即“排序系统通道”）中的第一个区块，排序系统通道是一个由排序节点管理员管理的特殊通道，包
括被允许创建通道的组织的列表。*排序节点系统通道的创世区块是特殊的：它必须先创建并被包含在节点
配置中，然后才能启动节点。*

学习如何使用 `configtxgen` 工具创建创世区块，请查看[通道配置（configtx）](configtx.html)。

## 启动排序节点

一旦你构建了镜像、创建了 MSP，配置了 `orderer.yaml`，并创建了创世区块，你就可以使用如下的命令
来启动排序节点：

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com
```

将 `orderer.example.com` 替换为你的排序节点地址。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
