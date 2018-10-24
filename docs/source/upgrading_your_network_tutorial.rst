Upgrading Your Network Components-升级网络组件
==============================================

Note

When we use the term “upgrade” in this documentation, we’re primarily referring to changing the version of a component (for example, going from a v1.1 binary to a v1.2 binary). The term “update,” on the other hand, refers not to versions but to configuration changes, such as updating a channel configuration or a deployment script. As there is no data migration, technically speaking, in Fabric, we will not use the term “migration” or “migrate” here.

注意：当我们在本文档中使用“升级”这个术语时，我们主要是指更改组件的版本（例如从1.1版本二进制文件转升级到1.2版本的二进制文件）。另一方面来讲，术语“更新”不是指版本更新，而是指配置更新，例如更新通道配置或者启动脚本。因为从技术上讲，没有数据迁移，在Fabric中，我们不会在这里使用术语“迁移”或“迁移”。





## Overview-概述

Because the [:doc:`build_network`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id1) (BYFN) tutorial defaults to the “latest” binaries, if you have run it since the release of v1.2, your machine will have v1.2 binaries and tools installed on it and you will not be able to upgrade them.

因为:doc:`build_network` (BYFN) 教程默认使用的是最新的二进制文件，如果你自v1.2发布以来已经运行它，你的机器上将会已经安装v1.1二进制文件和工具，你就不可能升级它们。

As a result, this tutorial will provide a network based on Hyperledger Fabric v1.1 binaries as well as the v1.2 binaries you will be upgrading to. In addition, we will show how to update channel configurations to the new v1.2 capability that will allows peers to properly handle [private data](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/private-data/private-data.html) and [:doc:`access_control`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id3). For more information about capabilities, check out our[:doc:`capability_requirements`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id5) documentation.

因此，本教程将提供基于Hyperledger Fabric v1.1二进制文件的网络以及您要升级到的v1.2二进制文件。此外，我们将展示如何将通道配置更新为V1.2新的功能，它可以让peers正确处理私有数据`private data <private-data/private-data.html>`_and访问控制  :doc:`access_control` 。获取关于这些新功能的更多信息，下载我们的:doc:`capability_requirements` 文档。

Note

If your network is not yet at Fabric v1.1, follow the instructions for [Upgrading Your Network to v1.1](http://hyperledger-fabric.readthedocs.io/en/release-1.1/upgrading_your_network_tutorial.html). The instructions in this documentation only cover moving from v1.1 to v1.2, not from any other version to v1.2.

注意：如果你的网络还不是Fabric1.1版本，查看下面的介绍`Upgrading Your Network to v1.1 <http://hyperledger-fabric.readthedocs.io/en/release-1.1/upgrading_your_network_tutorial.html>`_ 。这个文档的介绍只会从1.1版本覆盖到1.2版本，而不是从任何版本到1.2版本。

Because BYFN does not support the following components, our script for upgrading BYFN will not cover them:

但是，由于BYFN不支持以下组件，因此我们用于升级BYFN的脚本不会涵盖它们：

- **Fabric CA**
- **Kafka**
- **CouchDB**
- **SDK**

The process for upgrading these components --- if necessary --- will be covered in a section following the tutorial.

升级这些组件的过程--如果有必要--将在本教程后面的部分中介绍。

At a high level, our upgrade tutorial will perform the following steps:

1. Back up the ledger and MSPs.
2. Upgrade the orderer binaries to Fabric v1.2.
3. Upgrade the peer binaries to Fabric v1.2.
4. Enable the new v1.2 capability.

在较高级别，我们的升级教程将执行以下步骤：

1. 备份账本和MSP。
2. 将orderer节点的二进制文件升级到Fabric v1.2。
3. 将peer节点的二进制文件升级到Fabric v1.2。
4. 启用1.2版本的新功能.   	

Note

In production environments, the orderers and peers can simultaneously be upgraded on a rolling basis. In other words, you can upgrade the binaries in any order, without bringing down the network. Because BYFN uses a "SOLO" ordering service (one orderer), our script brings down the entire network. But this is not necessary in a production environment.

注意：在生产环境中orderer节点和peer节点可以同时滚动升级。换句话说，你可以在不关闭网络的情况下升级任何order节点的二进制文件。因为BNFN网络使用的是"SOLO"排序服务（一个orderer节点），我们的脚本关闭了整个网络。但这在生产环境中不是必须的。

However, it is important to make sure that enabling capabilities will not create issues with the versions of orderers and peers that are currently running. For v1.2, the new capability is in the application group, which governs peer related functionalities, and as a result does not conflict with the ordering service.

然而，确保启用的这些功能不会对当前在正在运行的peer和order造成版本问题非常重要。对于1.2版本来说，新的功能在应用程序中，它管理的是peer相关的函数功能，因而不会对order排序服务产生冲突、

This tutorial will demonstrate how to perform each of these steps individually with CLI commands.

本教程将演示如何使用CLI命令单独执行每个步骤。



### Prerequisites-先决条件

If you haven’t already done so, ensure you have all of the dependencies on your machine as described in [:doc:`prereqs`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id7).

如果您还没有这样做，请确保您机器上拥有所有依赖项，如 *：doc：`prereqs`* 中所述。

## Launch a v1.1 network-启动1.1版本网络

To begin, we will provision a basic network running Fabric v1.1 images. This network will consist of two organizations, each maintaining two peer nodes, and a “solo” ordering service.

We will be operating from the `first-network` subdirectory within your local clone of `fabric-samples`. Change into that directory now. You will also want to open a few extra terminals for ease of use.

首先，我们将提供运行Fabric v1.1镜像的基本网络。 该网络将由两个组织组成，每个组织维护两个节点，以及一个“独立”的order排序服务。

我们将在您的本地 `fabric-samples` 克隆中的  `first-network`  子目录中运行。 立即切换到该目录。 您还需要打开一些额外的终端以方便使用。

### Clean up - 清理

We want to operate from a known state, so we will use the `byfn.sh` script to initially tidy up. This command will kill any active or stale docker containers and remove any previously generated artifacts. Run the following command:

我们希望在已知状态下运行，因此我们将使用 `byfn.sh` 脚本进行初步整理。 此命令将终止所有活动或过时的docker容器，并删除任何以前生成的构件。 运行以下命令：

```
./byfn.sh down
```

### Generate the crypto and bring up the network-生成Crypto并启动Network

With a clean environment, launch our v1.1 BYFN network using these four commands:

以干净的环境使用以下四个命令启动我们的v1.1 BYFN网络：

```
git fetch origin

git checkout v1.1.0

./byfn.sh generate

./byfn.sh up -t 3000 -i 1.1.0
```

Note

If you have locally built v1.1 images, then they will be used by the example. If you get errors, please consider cleaning up your locally build v1.1 images and running the example again. This will download v1.1 images from docker hub.

注意： 如果您已经本地构建v1.1映像，则示例将使用它们。如果出现错误，请考虑清理v1.1镜像并再次运行该示例。 这将从docker hub下载1.1镜像。

If BYFN has launched properly, you will see:

如果BYFN正确启动，你会看到：

```
===================== All GOOD, BYFN execution completed =====================
```

We are now ready to upgrade our network to Hyperledger Fabric v1.2.

我们现在准备将我们的网络升级到Hyperledger Fabric v1.2。



### Get the newest samples-获取最新样本

Note

The instructions below pertain to whatever is the most recently published version of v1.2.x. Please substitute 1.2.x with the version identifier of the published release that you are testing. In other words, replace '1.2.x' with '1.2.0' if you are testing the first release candidate.

注意：以下说明适用于最新发布的v1.2.x版本。请将1.2.x替换为您正测试的已发布版本的版本标识符。也就是说，如果你正在测试第一个候选版本，请将 '1.2.x' 替换为 '1.2.0'。

Before completing the rest of the tutorial, it's important to get the v1.2.x version of the samples, you can do this by:

在完成本教程的其余部分之前，获取样本的v1.2.x版本非常重要，您可以通过以下方式执行此操作：

```
git fetch origin

git checkout v1.2.x
```





### Want to upgrade now?-想立即升级吗？

We have a script that will upgrade all of the components in BYFN as well as enabling capabilities. If you are running a production network, or are an administrator of some part of a network, this script can serve as a template for performing your own upgrades.

我们有一个脚本可以升级BYFN中的所有组件以及启用功能。如果你实在运行一个生产环境，或者你是一个网络一部分的管理员，这个脚本可以作为一个模板完成你自己的升级。

Afterwards, we will walk you through the steps in the script and describe what each piece of code is doing in the upgrade process.

然后，我们将引导您完成脚本中的步骤，并描述每个代码在升级过程中所执行的操作。

To run the script, issue these commands:

要运行该脚本，请发出以下命令：

```
# Note, replace '1.2.x' with a specific version, for example '1.2.0'.
# Don't pass the image flag '-i 1.2.x' if you prefer to default to 'latest' images.

./byfn.sh upgrade -i 1.2.x
```

If the upgrade is successful, you should see the following:

如果升级成功，你会看到：

```
===================== All GOOD, End-2-End UPGRADE Scenario execution completed =====================
```

if you want to upgrade the network manually, simply run `./byfn.sh down` again and perform the steps up to --- but not including --- `./byfn.sh upgrade -i 1.2.x`. Then proceed to the next section.

如果你想手动升级网络，只需再次运行 `./byfn.sh -m down` 并执行以下步骤 - 但不包括 - ``./byfn.sh upgrade -i 1.1.x.`  然后继续下一部分。

Note

Many of the commands you'll run in this section will not result in any output. In general, assume no output is good output.

注意：

您将在本节中运行的许多命令不会产生任何输出。 通常，假设没有输出就是好的输出。

## Upgrade the orderer containers-升级order容器

Orderer containers should be upgraded in a rolling fashion (one at a time). At a high level, the orderer upgrade process goes as follows:

1. Stop the orderer.
2. Back up the orderer’s ledger and MSP.
3. Restart the orderer with the latest images.
4. Verify upgrade completion.

Orderer节点容器应以滚动方式升级（一次一个）。 在较高级别，背书节点升级过程如下：

1. 停止背书节点。
2. 备份orderer的账本和MSP。
3. 用最新的镜像重启orderer。
4. 验证升级完成。

As a consequence of leveraging BYFN, we have a solo orderer setup, therefore, we will only perform this process once. In a Kafka setup, however, this process will have to be performed for each orderer.

由于使用BYFN，我们有一个独立的orderer节点的设置，因此，我们只会执行一次此过程。 但是，在Kafka设置中，必须为每个orderer节点执行此过程。

Note

This tutorial uses a docker deployment. For native deployments, replace the file `orderer` with the one from the release artifacts. Backup the `orderer.yaml` and replace it with the `orderer.yaml` file from the release artifacts. Then port any modified variables from the backed up `orderer.yaml` to the new one. Utilizing a utility like `diff` may be helpful. There are no new `orderer.yaml` configuration parameters in v1.2, but it is still best practice to port changes into the new config file as part of an upgrade process.

注意：本教程使用docker部署。对于本地部署，请用一个发布构件中的替换文件`orderer` 。备份`orderer.yaml` 并将其替换为发布构件``orderer.yaml`` 文件。然后将备份的``orderer.yaml`` 中的任何已经修改的变量移植到新的变量。使用像 `diff` 这样的实用程序可能会有所帮助。在1.2中，`orderer.yaml`配置没有新的参数，但是，作为升级过程的一部分，将更改移植到新配置文件中仍然是最佳做法。

Let’s begin the upgrade process by **bringing down the orderer**:

让我们通过 **停止order节点（bringing down the orderer）** 来开始升级过程： .. code:: bash

```
docker stop orderer.example.com

export LEDGERS_BACKUP=./ledgers-backup

# Note, replace '1.2.x' with a specific version, for example '1.2.0'.
# Set IMAGE_TAG to 'latest' if you prefer to default to the images tagged 'latest' on your system.

export IMAGE_TAG=$(go env GOARCH)-1.2.0-stable
```

We have created a variable for a directory to put file backups into, and exported the `IMAGE_TAG` we'd like to move to.

我们为目录创建了一个变量，用于将文件备份放入，并导出我们想要移动到的 `IMAGE_TAG`。

Once the orderer is down, you'll want to **backup its ledger and MSP**:

一旦orderer节点停机后，您需要 **备份其账本和MSP：**

```
mkdir -p $LEDGERS_BACKUP

docker cp orderer.example.com:/var/hyperledger/production/orderer/ ./$LEDGERS_BACKUP/orderer.example.com
```

In a production network this process would be repeated for each of the Kafka-based orderers in a rolling fashion.

在生产网络中，将以滚动方式为每个基于Kafka的orderer节点重复该过程。

Now **download and restart the orderer** with our new fabric image:

现在使用我们新的镜像 **下载并重新启动orderer节点**：

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com
```

Because our sample uses a "solo" ordering service, there are no other orderers in the network that the restarted orderer must sync up to. However, in a production network leveraging Kafka, it will be a best practice to issue `peer channel fetch <blocknumber>` after restarting the orderer to verify that it has caught up to the other orderers.

因为我们的示例使用的是”solo“模式的排序服务，所以在网络中没有别的orderer节点需要重启的orderer节点去同步。但是，在利用Kafka的生产网络中，最佳做法是在重新启动orderer节点之后执行 `peer channel fetch <blocknumber>`，以验证它是否已经跟其他orderer节点同步。

## Upgrade the peer containers-更新peer容器

Next, let's look at how to upgrade peer containers to Fabric v1.2. Peer containers should, like the orderers, be upgraded in a rolling fashion (one at a time). As mentioned during the orderer upgrade, orderers and peers may be upgraded in parallel, but for the purposes of this tutorial we’ve separated the processes out. At a high level, we will perform the following steps:

接下来，我们来看看如何将节点容器升级到Fabric v1.2。 与背书节点一样，节点容器应以滚动方式升级（一次一个）。 正如orderer节点升级期间提到的那样，orderer节点和peers节点可以并行升级，但是为了本教程的目的，我们已经将这些进程分开了。 在较高级别，我们将执行以下步骤：

1. Stop the peer.
2. Back up the peer’s ledger and MSP.
3. Remove chaincode containers and images.
4. Restart the peer with latest image.
5. Verify upgrade completion.

1. 停止peer节点.
2. 备份peer的账本和MSP.
3. 移除链码容器和镜像.
4. 用最新的镜像重启peer节点.
5. 验证升级完成.

We have four peers running in our network. We will perform this process once for each peer, totaling four upgrades.

我们的网络中有四个节点。 我们将为每个节点执行一次此过程，总共进行四次升级。

Note

Again, this tutorial utilizes a docker deployment. For **native** deployments, replace the file `peer` with the one from the release artifacts. Backup your `core.yaml` and replace it with the one from the release artifacts. Port any modified variables from the backed up `core.yaml` to the new one. Utilizing a utility like `diff` may be helpful.

注意： 同样，本教程使用了docker部署。对于 **本机** 部署，请将 `peer` 文件替换为发布工件中的文件。备份您的 `core.yaml` 并将其替换为发布工件中的那个。 将备份的``core.yaml`` 中的任何已修改变量移植到新的变量。使用像 `diff` 这样的实用程序可能会有所帮助。

Let’s **bring down the first peer** with the following command:

让我们使用下面命令把第一个peer节点停止：

```
export PEER=peer0.org1.example.com

docker stop $PEER
```

We can then **backup the peer’s ledger and MSP**:

然后 **备份节点的账本和MSP**

```
mkdir -p $LEDGERS_BACKUP

docker cp $PEER:/var/hyperledger/production ./$LEDGERS_BACKUP/$PEER
```

With the peer stopped and the ledger backed up, **remove the peer chaincode containers**:

在节点停止并备份账本后，**删除节点链码容器：**

```
CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_CONTAINERS" ] ; then docker rm -f $CC_CONTAINERS ; fi
```

And the peer chaincode images:

然后是节点链码镜像：

```
CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_IMAGES" ] ; then docker rmi -f $CC_IMAGES ; fi
```

Now we'll re-launch the peer using the v1.2 image tag:

现在我们将使用v1.2镜像标记重新启动节点：

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps $PEER
```

Note

Although, BYFN supports using CouchDB, we opted for a simpler implementation in this tutorial. If you are using CouchDB, however, issue this command instead of the one above:

注意：尽管BYFN支持使用CouchDB，但是，如果您使用的是CouchDB，发出此命令而不是上面的命令：

```
docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d --no-deps $PEER
```

Note

You do not need to relaunch the chaincode container. When the peer gets a request for a chaincode, (invoke or query), it first checks if it has a copy of that chaincode running. If so, it uses it. Otherwise, as in this case, the peer launches the chaincode (rebuilding the image if required).

注意:你不需要重启运行链码容器。当peer节点获得链码请求（调用或查询）时，它首先检查它是否有运行该链码的副本。 如果有，它就会使用它。否则就像这种情况下，peer会启动链码（如果需要，重新building镜像）。





### Verify upgrade completion-验证升级完成

We’ve completed the upgrade for our first peer, but before we move on let’s check to ensure the upgrade has been completed properly with a chaincode invoke. Let’s move `10` from `a` to `b` using these commands:

我们已完成第一个节点的升级，但在我们进行之前，请通过正确调用链码以确保完成了升级。 让我们使用以下命令将 `10` 从 `a` 移动到 `b`：

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps cli

docker exec -it cli bash

peer chaincode invoke -o orderer.example.com:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  -C mychannel -n mycc -c '{"Args":["invoke","a","b","10"]}'
```

Our query earlier revealed a to have a value of `90` and we have just removed `10` with our invoke. Therefore, a query against `a` should reveal `80`. Let’s see:

我们之前的查询显示a值为 `90`，我们刚刚使用调用移动了 `10`。 因此，对a的查询应该显示 `80`.让我们看看：

```
peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
```

We should see the following:

我们会看到：

```
Query Result: 80
```

After verifying the peer was upgraded correctly, make sure to issue an `exit` to leave the container before continuing to upgrade your peers. You can do this by repeating the process above with a different peer name exported.

在验证节点已正确升级后，请确保在继续升级节点之前执行退出以离开容器。 您可以通过重复上述过程并导出不同的节点名称来完成此操作。

```
export PEER=peer1.org1.example.com
export PEER=peer0.org2.example.com
export PEER=peer1.org2.example.com
```

Note

All peers must be upgraded BEFORE enabling the v1.2 capability.

注意： 在启用1.2V功能之前，必须升级所有节点。





## Enable the new v1.2 capability-启用V1.2新功能

Although Fabric binaries can and should be upgraded in a rolling fashion, it is important to finish upgrading binaries before enabling capabilities. Any peers not upgraded to v1.2 before the new capability is enabled may intentionally crash to indicate a potential misconfiguration which might result in a state forl. If orderers are not upgraded to v1.2, they will not crash, nor will state forks be created (unlike the upgrade from v1.0.x to v1.1). Nevertheless, it remains a best practice to upgrade all peer and orderer binaries to v1.2 prior to enabling the new capability.

尽管Fabric二进制文件可以并且应该以滚动方式进行升级，在启用功能之前，完成二进制文件升级依然很重要。在启用新功能之前未升级到v1.2的任何peer可能会故意崩溃，以指示可能导致状态为forl的错误配置。如果peer未升级到v1.2，则不会崩溃，也不会创建状态分叉（与从v1.0.x升级到v1.1不同）。尽管如此，在启用新功能之前，将所有peer和orderer二进制文件升级到v1.2仍然是最佳做法。

Once a capability has been enabled, it becomes part of the permanent record for that channel. This means that even after disabling the capability, old binaries will not be able to participate in the channel because they cannot process beyond the block which enabled the capability to get to the block which disables it. As a result, once a capability has been enabled, disabling it is not recommended or supported.

一旦一个功能启用后，它将成为该通道的永久记录的一部分。这意味着即使稍后关闭了该功能，旧的二进制将不能参与到通道，因为它们不能跨过没有这个功能但是启用了这个功能的块。因此，一旦一个功能被启用，就不建议或不支持禁用它。

For this reason, think of enabling channel capabilities as a point of no return. Please experiment with the new capabilities in a test setting and be confident before proceeding to enable them in production.

因此，将通道功能视为一条不归路。 请在测试设置中尝试新功能，并在继续在生产中启用它们之前充满信心。

Capabilities are enabled through a channel configuration transaction. For more information on updating channel configs, check out [:doc:`channel_update_tutorial`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id9) or the doc on [:doc:`config_update`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id11).

这些功能通过通道配置事物启用。获取更多更新通道配置的信息，查看  [:doc:`channel_update_tutorial`](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id9 ) 或者 [:doc:`config_update `](https://github.com/hyperledger/fabric/blob/release-1.2/docs/source/upgrading_your_network_tutorial.rst#id11).

The new capability for v1.2 is in the `Application` channel group (which affects **peer network** behavior, such as how transactions are handled by the peer). As with any channel config update, we will have to follow this process:

1. Get the latest channel config
2. Create a modified channel config
3. Create a config update transaction

v1.2的新功能位于“应用程序”通道组中（这会影响**peer网络**的行为，例如peer如何处理事务）。 与任何通道配置更新一样，我们必须遵循以下流程：

1. 获取最新的通道配置
2. 创建修改后的通道配置
3. 创建配置更新事务

Get into the `cli` container by reissuing `docker exec -it cli bash`.

通过 `docker exec -it cli bash`进入  `cli`容器。







### Application group-应用组

To change the configuration of the application group, set the environment variables as Org1:

为了改变应用组的配置，将环境变量设置为Org1。

```
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CH_NAME="mychannel"
```

Next, get the latest channel config:

接下来，获取最新的通道配置。

```
peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME --tls --cafile $ORDERER_CA

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

jq .data.data[0].payload.data.config config_block.json > config.json
```

Create a modified channel config:

创建修改后的通道配置：

```
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"Capabilities": .[1]}}}}}' config.json ./scripts/capabilities.json > modified_config.json
```

Note what we’re changing here: `Capabilities` are being added as a `value` of the `Application` group under `channel_group`(in `mychannel`).

注意我们在这里做了什么改变：`Capabilities`  被作为一个 `值` 加入到 `channel_group` 下的 应用组。

Create a config update transaction:

创建一个更新事务的配置：

```
configtxlator proto_encode --input config.json --type common.Config --output config.pb

configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb
```

Package the config update into a transaction:

将配置更新打包到事务中:

```
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
```

Org1 signs the transaction:

Org1 签名交易： 

```
peer channel signconfigtx -f config_update_in_envelope.pb
```

Set the environment variables as Org2:

将环境变量设置为Org2：

```
export CORE_PEER_LOCALMSPID="Org2MSP"

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
```

Org2 submits the config update transaction with its signature:

Org2使用其签名提交配置更新事务：

```
peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA
```

Congratulations! You have now enabled the v1.2 capability.

恭喜！你现在开启了V1.2的新功能。





### Re-verify upgrade completion-重新验证升级完成

Let's make sure the network is still running by moving another `10` from `a` to `b`:

让我们通过将另一个“10”从“a”移动到“b”来确保网络仍在运行：

```
peer chaincode invoke -o orderer.example.com:7050  --tls --cafile $ORDERER_CA  -C $CH_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
```

And then querying the value of `a`, which should reveal a value of `70`. Let’s see:

在查询`a` 的值，应该是`70`。我们来看：

```
peer chaincode query -C $CH_NAME -n mycc -c '{"Args":["query","a"]}'
```

We should see the following:

我们会看到：

```
Query Result: 70
```

Note

Although all peer binaries in the network should have been upgraded prior to this point, enabling capability requirements on a channel to which a v1.1.x peer is joined will result in a crash of the peer. This crashing behavior is deliberate because it indicates a misconfiguration which might result in a state fork.

注意：虽然网络中的所有peer二进制文件都应该在此之前进行升级，但是在加入v1.1.xpeer的通道上启用功能要求将导致peer崩溃。 这种崩溃行为是故意的，因为它表明可能导致状态分叉的配置错误。





## Upgrading components BYFN does not support-升级BYFN不支持的组件

Although this is the end of our update tutorial, there are other components that exist in production networks that are not supported by the BYFN sample. In this section, we’ll talk through the process of updating them.

虽然这是我们的更新教程的结束，但生产网络中还存在BYFN示例不支持的其他组件。 在本节中，我们将讨论更新它们的过程。

### Fabric CA container

To learn how to upgrade your Fabric CA server, click over to the [CA documentation.](http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server)

了解如何升级Fabric CA服务器，请单击 [CA文档.](http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server)。

### Upgrade Node SDK clients-升级节点Node SDK客户端

Note

Upgrade Fabric CA before upgrading Node SDK clients.

注意： 升级Node SDK客户端之前升级Fabric CA。

Use NPM to upgrade any `Node.js` client by executing these commands in the root directory of your application:

使用NPM，通过在应用程序的根目录中执行以下命令来升级任何 `Node.js` 客户端：

```
npm install fabric-client@1.2

npm install fabric-ca-client@1.2
```

These commands install the new version of both the Fabric client and Fabric-CA client and write the new versions `package.json`.

这些命令安装了Fabric客户端和Fabric-CA客户端的新版本，并编写新版本 `package.json`。



### Upgrading the Kafka cluster-升级Kafka集群

It is not required, but it is recommended that the Kafka cluster be upgraded and kept up to date along with the rest of Fabric. Newer versions of Kafka support older protocol versions, so you may upgrade Kafka before or after the rest of Fabric.

这不是必需的，但建议升级Kafka集群并与Fabric的其余部分保持同步。 较新版本的Kafka支持较旧的协议版本，因此您可以在Fabric的其余部分之前或之后升级Kafka。

If you followed the [Upgrading Your Network to v1.1 tutorial](http://hyperledger-fabric.readthedocs.io/en/release-1.1/upgrading_your_network_tutorial.html), your Kafka cluster should be at v1.0.0. If it isn't, refer to the official Apache Kafka documentation on [upgrading Kafka from previous versions](https://kafka.apache.org/documentation/#upgrade) to upgrade the Kafka cluster brokers.

如果你参考的是文档 [Upgrading Your Network to v1.1 tutorial](http://hyperledger-fabric.readthedocs.io/en/release-1.1/upgrading_your_network_tutorial.html), 你的Kafka集群应该是V1.0.0版本。如果不是，请参阅[upgrading Kafka from previous versions](https://kafka.apache.org/documentation/#upgrade)以升级Kafka集群代理。



#### Upgrading Zookeeper-升级Zookeeper

An Apache Kafka cluster requires an Apache Zookeeper cluster. The Zookeeper API has been stable for a long time and, as such, almost any version of Zookeeper is tolerated by Kafka. Refer to the [Apache Kafka upgrade](https://kafka.apache.org/documentation/#upgrade) documentation in case there is a specific requirement to upgrade to a specific version of Zookeeper. If you would like to upgrade your Zookeeper cluster, some information on upgrading Zookeeper cluster can be found in the [Zookeeper FAQ](https://cwiki.apache.org/confluence/display/ZOOKEEPER/FAQ).

Apache Kafka集群需要Apache Zookeeper集群。Zookeeper API已经稳定了很长时间，因此，Kafka几乎可以容忍任何版本的Zookeeper。 如果有特定要求升级到特定版本的Zookeeper，请参阅 [Apache Kafka upgrade](https://kafka.apache.org/documentation/#upgrade) 升级文档。 如果您想升级Zookeeper集群，可以在 [Zookeeper FAQ](https://cwiki.apache.org/confluence/display/ZOOKEEPER/FAQ)  中找到有关升级Zookeeper集群的一些信息。



### Upgrading CouchDB-升级CouchDB

If you are using CouchDB as state database, you should upgrade the peer's CouchDB at the same time the peer is being upgraded. Because both v1.1 and v1.2 ship with CouchDB v2.1.1, if you have followed the steps for Upgrading to v1.1, your CouchDB should be up to date.

如果您使用CouchDB作为状态数据库，请在升级peer节点的同时升级节点的CouchDB。 因为v1.1和v1.2都附带了CouchDB v2.1.1，如果你按照升级到v1.1的步骤进行操作，那么你的CouchDB应该是最新的。



### Upgrade Chaincodes With vendored shim-使用Vendored Shim升级Chaincodes

Note

The v1.1.0 shim is compatible with the v1.2 peer, but, it is still best practice to upgrade the chaincode shim to match the current level of the peer.

注意：V1.1.0 shim对v1.2peer是兼容的。但是，最佳做法是升级链码shim以匹配peer的当前级别。

A number of third party tools exist that will allow you to vendor a chaincode shim. If you used one of these tools, use the same one to update your vendoring and re-package your chaincode.

存在许多第三方工具，允许您提供chaincode shim。 如果您使用其中一种工具，请使用相同的工具更新您的vendoring 并重新打包您的链码。

If your chaincode vendors the shim, after updating the shim version, you must install it to all peers which already have the chaincode. Install it with the same name, but a newer version. Then you should execute a chaincode upgrade on each channel where this chaincode has been deployed to move to the new version.

如果你的chaincode vendor是shim，在更新shim版本之后，你必须将它安装到已经拥有链码的所有节点中。 使用相同的名称安装它，但是更新版本。 然后，您应该在已部署此链代码的每个信道上执行链代码升级，以转移到新版本。

If you did not vendor your chaincode, you can skip this step entirely.

如果您没有提供链码，则可以完全跳过此步骤。
