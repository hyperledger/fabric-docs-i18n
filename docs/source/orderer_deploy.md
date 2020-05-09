# 设置排序节点

本章中，我们将介绍启动排序节点的过程。如果想了解更多有关不同排序服务实现及其优缺点的信息，请查看[conceptual documentation about ordering](./orderer/ordering_service.html)。

总体来说，本章将涉及以下步骤：

1. 创建排序节点所属的组织（如果尚未创建）
2. 配置节点 （使用 `orderer.yaml`）
3. 为排序系统通道创建创世块
4. 引导排序节点

注意：本章假定您已从 docker hub 中拉取了 Hyperledger Fabric orderer 镜像。

## 创建组织定义

和 Peer 节点一样，所有排序节点都必须属于已存在的组织。该组织拥有[成员服务提供者](./membership/membership.html)（MSP），MSP 由 CA（Certificate Authority）创建，CA 专门为该组织创建证书和 MSP 。

有关创建 CA 以及使用 CA 创建用户和 MSP 的信息，请参阅 [Fabric CA user's guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html)。

## 配置节点

排序节点通过名为 `orderer.yaml` 的 `yaml` 文件来进行配置。其中 `FABRIC_CFG_PATH` 环境变量需指向一个已经配置好的 `orderer.yaml` 文件，该文件将在文件系统中提取一系列文件和证书。

示例 `orderer.yaml` 请查看 [`fabric-samples` github repo](https://github.com/hyperledger/fabric/blob/release-2.0/sampleconfig/orderer.yaml)，在继续下一步之前**仔细阅读和研究** 。需要特别注意以下值：

* `LocalMSPID` —— 这是排序组织的 MSP 的名称，由 CA 生成，并在这里列出了排序组织管理员。

* `LocalMSPDir` —— 文件系统中本地 MSP 所在的位置。

*  `# TLS enabled`, `Enabled: false`。在这里可以指定是否要[启用 TLS ](enable_tls.html)。如果将此值设置为 `true` , 则必须指定相关 TLS 证书的位置。请注意，这对于 Raft 节点是必须的。

* `BootstrapFile` —— 这是您将为此排序服务生成的创世块的名称。

* `BootstrapMethod` —— 给定引导区块的方法。目前，这里只能是 `file`，引导文件是 `BootstrapFile` 中所指定的文件。

如果将此节点部署为集群的一部分（例如，作为 Raft 节点集群的一部分），请注意 `Cluster` 和 `Consensus` 部分。

如果想要部署基于 Kafka 的排序服务，则需要完成 `Kafka` 部分。

## 创建排序节点的创世区块

新创建通道的第一个区块称为“创世区块”。如果在创建**新网络**的过程中创建了创世区块（换言之，正在创建的排序节点不会加入现有的排序节点集群），则该创世区块将是“排序系统通道”的第一个区块，“排序系统通道”是一个特殊的通道，它由排序管理员管理，排序管理员包括了允许创建通道的组织列表。*排序系统通道的创世区块很特殊：必须先创建它并将其包含在节点的配置中，然后才能启动该节点。*

想要了解如何使用 `configtxgen` 创建创世区块，请查阅 [通道配置（configtx）](configtx.html)

## 引导排序节点

当您完成构建镜像，创建 MSP，配置 `orderer.yaml` 并创建了创世区块之后，就可以使用类似下面的命令来启动排序节点：

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com
```

注意用你的排序节点地址来替换 `orderer.example.com`。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
