# 设置orderer节点

在本主题中，我们将描述引导 orderer 节点的过程。如果想了解更多有关不同 orderer 服务实现及其相对优缺点的信息，请查看[conceptual documentation about ordering](./orderer/ordering_service.html).

大致而言，该主题将涉及一些相互关联的步骤：


配置节点（使用 orderer.yaml ）
为订购系统通道创建创世块
引导orderer节点
1. 创建orderer节点所属的组织（如果尚未创建）
2. 配置节点 (使用 `orderer.yaml` )
3. 为orderer系统通道创建创世块
4. 引导orderer节点

注意：本主题假定您已从 docker hub 中提取了 Hyperledger Fabric orderer 镜像。


## 创建组织定义

像 peer 节点一样，所有 orderer 节点都必须属于创建于 orderer 之前的组织。该组织具有由[成员资格服务提供商](./membership/membership.html)(MSP)封装的定义，该定义由认证机构（CA）创建，该机构专门为该组织创建证书和 MSP 。

有关创建 CA 以及使用 CA 创建用户和 MSP 的信息，请参阅 [Fabric CA user's guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html).

## 配置节点

orderer 节点通过名为 `orderer.yaml` 的 `yaml` 文件来进行配置。 其中 `FABRIC_CFG_PATH` 环境变量需指向一个已经配置好的 `orderer.yaml` 文件，该文件将在文件系统中提取一系列文件和证书。

要阅读示例 `orderer.yaml` ，请查看 [`fabric-samples` github repo](https://github.com/hyperledger/fabric/blob/release-2.0/sampleconfig/orderer.yaml)，并在继续下一步之前**仔细阅读和研究** 。特别注意以下值：

* `LocalMSPID` --- 这是orderer组织的CA生成的MSP的名称，并在此列出orderer组织管理员的位置。

* `LocalMSPDir` --- 文件系统中本地MSP所在的位置。

*  `# TLS enabled`, `Enabled: false`. 在这里可以指定是否要[启用TLS](enable_tls.html). 如果将此值设置为 `true` , 则必须指定相关TLS证书的位置。请注意，这对于Raft节点是必需的。

* `BootstrapFile` --- 这是您将为此排序服务（Orderer节点）生成的创世块的名称。

* `BootstrapMethod` --- 引导区块的给出方法。目前，这里必须是 `BootstrapFile` 中所指定的文件

如果将此节点部署为集群的一部分（例如，作为Raft节点集群的一部分），请注意 `Cluster` 和 `Consensus` 部分。

如果想要部署基于Kafka的排序服务（Orderer），则需要完成 `Kafka` 部分。

## 创建 orderer 的创世区块

新创建通道的第一个区块称为“创世区块”。如果在创建**新网络**的过程中创建了创世区块 （换言之，如果正在创建的 orderer 节点不会加入现有 orderer 集群），则该创世区块将是 “orderer系统通道”（也称为“排序系统通道”），由 orderer 管理员管理的特殊通道，其中包括允许创建通道的组织的列表。*orderer系统通道的创世区块很特殊：必须先创建它并将其包含在节点的配置中，然后才能启动该节点。*

想要了解如何使用 `configtxgen` 创建创世区块，请查阅 [Channel Configuration (configtx)](configtx.html)


## 引导 ordering 节点

完成构建镜像，创建 MSP，配置 `orderer.yaml` 并创建了创世区块之后，就可以使用如下类似命令来启动 orderer 排序：


```
docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com
```

注意用本地 orderer 节点地址替换 `orderer.example.com`.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
