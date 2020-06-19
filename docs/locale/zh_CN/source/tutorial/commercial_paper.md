# 商业票据教程

**受众**: 架构师，应用和智能合约开发者，管理员

本教程将向你展示如何安装和使用商业票据样例应用程序和智能合约。该主题是以任务为导向的，
因此它更侧重的是流程而不是概念。如果你想更深入地了解这些概念，可以阅读[开发应用程序](../developapps/developing_applications.html)主题。

![commercialpaper.tutorial](./commercial_paper.diagram.1.png)
*在本教程中，MagnetoCorp 和 DigiBank 这两个组织使用 Hyperledger Fabric 区块链网络 PaperNet 相互交易商业票据。*

一旦建立了一个基本的网络，你就将扮演 MagnetoCorp 的员工 Isabella，她将代表公司发行商业票据。然后，你将转换角色，担任 DigiBank 的员工 Balaji，他将购买此商业票据，持有一段时间，然后向 MagnetoCorp 兑换该商业票据，以获取小额利润。

你将扮演开发人员，最终用户和管理员，这些角色位于不同组织中，都将执行以下步骤，这些步骤旨在帮助你了解作为两个不同组织独立工作但要根据Hyperledger Fabric 网络中双方共同商定的规则来进行协作是什么感觉。

 * [组建机器](#准备阶段)和[下载示例](#下载示例)
 * [创建网络](#创建网络)
 * 理解[智能合约](#智能合约)的结构
 * 作为组织 [MagnetoCorp](#像 MagnetoCorp 一样工作) 来[安装](#安装合约)和[实例化](#实例化合约)智能合约
 * 理解 MagnetoCorp [应用](#应用结构)的结构，包括它的[依赖项](#应用依赖)
 * 配置并使用[钱包和身份](#钱包)
 * 启动 MagnetoCorp 的应用程序[发行商业票据](#发行应用)
 * 理解第二个组织 [Digibank](#像 DigiBank 一样工作) 是如何在它们的[应用](#Digibank 应用)中使用智能合约的
 * 作为 Digibank， [运行](#像 DigiBank 一样运行)购买和兑换商业票据的应用程序

本教程已经在 MacOS 和 Ubuntu 上进行了测试，应该可以在其他 Linux 发行版上运行。Windows版本的教程正在开发中。

## 先决条件

在开始之前，你必须安装本教程所需的一些必备技术。我们将必备技术控制在最低限度，以便你能快速开始。

你**必须**安装以下软件：

  * [**Node**](https://nodejs.org/en/about/) 版本 8.9.0 或更高版本。Node 是一个 Javascript 运行时，可用于运行应用程序和智能合约。推荐使用 node 的 TLS 版本。安装 node 看[这里](https://nodejs.org/en/)。
    
  * [**Docker**](https://www.docker.com/get-started) 版本 18.06 或更高版本。Docker 帮助开发人员和管理员创建标准环境，以构建和运行应用程序和智能合约。提供Hyperledger Fabric 是作为一组Docker 镜像的，PaperNet 智能合约将在 docker 容器中运行。安装 Docker 看[这里](https://www.docker.com/get-started)。

你**会**发现安装以下软件很有帮助：

  * 源码编辑器，如 [**Visual Studio Code**](https://code.visualstudio.com/) 版本 1.28，或更高版本。
    VS Code 将会帮助你开发和测试你的应用程序和智能合约。安装 VS Code 看[这里](https://code.visualstudio.com/Download)。

    许多优秀的代码编辑器都可以使用，包括 [Atom](https://atom.io/), [Sublime Text](http://www.sublimetext.com/) 和 [Brackets](http://www.sublimetext.com/)。

你**可能**会发现，随着你在应用程序和智能合约开发方面的经验越来越丰富，安装以下软件会很有帮助。 
首次运行教程时无需安装这些：

  * [**Node Version Manager**](https://github.com/creationix/nvm)。NVM 帮助你轻松切换不同版本的 node -- 如果你同时处理多个项目的话，那将非常有用。安装 NVM 看[这里](https://github.com/creationix/nvm#installation)。

## 下载示例

商业票据教程是在名为 `fabric-samples` 的公共 [Github](https://www.github.com) 仓库中保存的 Hyperledger Fabric [示例](https://github.com/hyperledger/fabric-samples)之一。当你要在你的机器上运行教程时，
你的首要任务是下载 `fabric-samples` 仓库。
![commercialpaper.download](./commercial_paper.diagram.2.png) *把 `fabric-samples` GitHub 仓库下载到你的本地机器*

`$GOPATH`  Hyperledger Fabric 中重要的环境变量；它识别了要安装的根目录。无论您使用哪种
编程语言，都必须正确行事！打开一个新的终端窗口，然后使用 `env` 命令检查一下你的 `$GOPATH`：

```
$ env
...
GOPATH=/Users/username/go
NVM_BIN=/Users/username/.nvm/versions/node/v8.11.2/bin
NVM_IOJS_ORG_MIRROR=https://iojs.org/dist
...
```

如果你的 `$GOPATH` 没有设置，请看这个[说明](https://github.com/golang/go/wiki/SettingGOPATH)。

现在，你可以创建一个相对于 `$GOPATH ` 的目录，将在其中安装 `fabric-samples`：

```
$ mkdir -p $GOPATH/src/github.com/hyperledger/
$ cd $GOPATH/src/github.com/hyperledger/
```

使用 [`git clone`](https://git-scm.com/docs/git-clone) 命令把 [`fabric-samples`](https://github.com/hyperledger/fabric-samples) 仓库复制到这个地址：

```
$ git clone https://github.com/hyperledger/fabric-samples.git
```

随意检查 `fabric-samples` 的目录结构：

```
$ cd fabric-samples
$ ls

CODE_OF_CONDUCT.md    balance-transfer            fabric-ca
CONTRIBUTING.md       basic-network               first-network
Jenkinsfile           chaincode                   high-throughput
LICENSE               chaincode-docker-devmode    scripts
MAINTAINERS.md        commercial-paper            README.md
fabcar
```

注意 `commercial-paper` 目录 -- 我们的示例就在这里！

现在你已经完成了教程的第一个阶段！随着你继续操作，你将为不同用户和组件打开多个命令窗口。例如：

* 以 Isabella 和 Balaji 的身份运行应用程序，他们将相互交易商业票据
* 以 MagnetoCorp 和 DigiBank 管理员的身份发行命令，包括安装和实例化智能合约
* 展示 peer， orderer 和 CA 的日志输出

当你应该从特定命令窗口运行一项命令时，我们将详细说明这一点。例如：

```
(isabella)$ ls
```

这表示你应该在 Isabella 的窗口中执行 `ls` 命令。

## 创建网络

这个教程目前使用的是基础网络；很快将会更新配置，从而更好的反映出 PaperNet 的多组织结构。
但就目前来说，这个网络已经能够满足向你展示如何开发应用程序和智能合约。

![commercialpaper.network](./commercial_paper.diagram.3.png) *The Hyperledger Fabric 基础网络的组成部分包括一个节点及该节点的账本数据库，一个排序服务和一个证书授权中心。以上每个组件都在 一个Docker 容器中运行。*

节点及其[账本](../ledger/ledger.html#world-state-database-options)，排序服务和 CA 都是在自己的docker 容器中运行。在生产环境中，组织通常使用的是与其他系统共享的现有 CA；它们并非专门用于 Fabric 网络的。

你可以使用 `fabric-samples\basic-network` 目录下的命令和配置来管理基础网络。让我们在你本地的机器上使用 `start.sh`脚本来启动网络：

```
$ cd fabric-samples/basic-network
$ ./start.sh

docker-compose -f docker-compose.yml up -d ca.example.com orderer.example.com peer0.org1.example.com couchdb
Creating network "net_basic" with the default driver
Pulling ca.example.com (hyperledger/fabric-ca:)...
latest: Pulling from hyperledger/fabric-ca
3b37166ec614: Pull complete
504facff238f: Pull complete
(...)
Pulling orderer.example.com (hyperledger/fabric-orderer:)...
latest: Pulling from hyperledger/fabric-orderer
3b37166ec614: Already exists
504facff238f: Already exists
(...)
Pulling couchdb (hyperledger/fabric-couchdb:)...
latest: Pulling from hyperledger/fabric-couchdb
3b37166ec614: Already exists
504facff238f: Already exists
(...)
Pulling peer0.org1.example.com (hyperledger/fabric-peer:)...
latest: Pulling from hyperledger/fabric-peer
3b37166ec614: Already exists
504facff238f: Already exists
(...)
Creating orderer.example.com ... done
Creating couchdb             ... done
Creating ca.example.com         ... done
Creating peer0.org1.example.com ... done
(...)
2018-11-07 13:47:31.634 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
2018-11-07 13:47:31.730 UTC [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

注意 `docker-compose -f docker-compose.yml up -d ca.example.com...` 命令如何从[DockerHub](https://hub.docker.com/)中拉取然后启动了4 个 Hyperledger Fabric 容器镜像。这些容器都使用了 Hyperledger Fabric 组件的最新版本软件。欢迎浏览 `basic-network` 目录 -- 我们将在本教程中使用该目录的大部分内容。


你可以使用 `docker ps` 命令列出运行基本网络组件的 docker 容器：


```
$ docker ps

CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                            NAMES
ada3d078989b        hyperledger/fabric-peer      "peer node start"        About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
1fa1fd107bfb        hyperledger/fabric-orderer   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                           orderer.example.com
53fe614274f7        hyperledger/fabric-couchdb   "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb
469201085a20        hyperledger/fabric-ca        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   0.0.0.0:7054->7054/tcp                           ca.example.com
```

看看你是否可以将这些容器映射到基本网络上(可能需要横向移动才能找到信息)：

* 节点 `peer0.org1.example.com` 在容器 `ada3d078989b` 中运行
* 排序服务 `orderer.example.com` 在容器 `1fa1fd107bfb` 中运行
* CouchDB 数据库 `couchdb` 在容器 `53fe614274f7` 中运行
* CA `ca.example.com` 在容器 `469201085a20` 中运行

所有这些容器构成了被称作 `net_basic` 的 [docker 网络](https://docs.docker.com/network/)。你可以使用 `docker network` 命令查看该网络：

```
$ docker network inspect net_basic

    {
        "Name": "net_basic",
        "Id": "62e9d37d00a0eda6c6301a76022c695f8e01258edaba6f65e876166164466ee5",
        "Created": "2018-11-07T13:46:30.4992927Z",
        "Containers": {
            "1fa1fd107bfbe61522e4a26a57c2178d82b2918d5d423e7ee626c79b8a233624": {
                "Name": "orderer.example.com",
                "IPv4Address": "172.20.0.4/16",
            },
            "469201085a20b6a8f476d1ac993abce3103e59e3a23b9125032b77b02b715f2c": {
                "Name": "ca.example.com",
                "IPv4Address": "172.20.0.2/16",
            },
            "53fe614274f7a40392210f980b53b421e242484dd3deac52bbfe49cb636ce720": {
                "Name": "couchdb",
                "IPv4Address": "172.20.0.3/16",
            },
            "ada3d078989b568c6e060fa7bf62301b4bf55bed8ac1c938d514c81c42d8727a": {
                "Name": "peer0.org1.example.com",
                "IPv4Address": "172.20.0.5/16",
            }
        },
        "Labels": {}
    }
```

看看这四个容器如何在作为单个docker网络一部分的同时使用不同的IP地址。（为了清晰起见，我们对输出进行了缩写。）

回顾一下: 你已经从 GitHub 下载了 Hyperledger Fabric 样本仓库，并且已经在本地机器上运行了基本的网络。现在让我们开始扮演 MagnetoCorp 的角色来交易商业票据。

## 像 MagnetoCorp 一样工作

为了监控 PaperNet 网络中的 MagnetoCorp 组件，管理员可以使用 `logspout` [工具](https://github.com/gliderlabs/logspout#logspout) 来查看一组 docker 容器日志的聚合结果。该工具可以将不同输出流采集到一个地方，从而在一个窗口中就可以轻松看到正在发生的事情。比如，对于正在安装智能合约的管理员或者正在调用智能合约的开发人员来说，这个工具确实很有帮助。

现在让我们作为 MagnetoCorp 的管理员来监控 PaperNet 网络。在 `fabric-samples` 目录下打开一个新窗口，找到并运行 `monitordocker.sh` 脚本，以启动与 docker 网络 `net_basic` 关联的 PaperNet docker 容器的 `logspout` 工具：

```
(magnetocorp admin)$ cd commercial-paper/organization/magnetocorp/configuration/cli/
(magnetocorp admin)$ ./monitordocker.sh net_basic
...
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
(...)
Starting monitoring on all containers on the network net_basic
b7f3586e5d0233de5a454df369b8eadab0613886fc9877529587345fc01a3582
```

注意，如果 `monitordocker.sh` 中的默认端口已经在使用，你可以向以上命令中传一个端口号码。

```
(magnetocorp admin)$ ./monitordocker.sh net_basic <port_number>
```

这个窗口将会显示 docker 容器的输出，所以让我们启动另一个终端窗口来让 MagnetoCorp 的管理员和
网络交互。


![commercialpaper.workmagneto](./commercial_paper.diagram.4.png) *MagnetoCorp 管理员通过一个 docker 容器和网络交互。*

为了和 PaperNet 交互，MagnetoCorp 管理员需要使用 Hyperledger Fabric `peer` 命令。而这些命令
都可以在 `hyperledger/fabric-tools` docker 镜像中预先构建，所以非常方便。

让我们使用 `docker-compose` [命令](https://docs.docker.com/compose/overview/)来为管理员启动一个 MagnetoCorp 特定的 docker 容器：

```
(magnetocorp admin)$ cd commercial-paper/organization/magnetocorp/configuration/cli/
(magnetocorp admin)$ docker-compose -f docker-compose.yml up -d cliMagnetoCorp

Pulling cliMagnetoCorp (hyperledger/fabric-tools:)...
latest: Pulling from hyperledger/fabric-tools
3b37166ec614: Already exists
(...)
Digest: sha256:058cff3b378c1f3ebe35d56deb7bf33171bf19b327d91b452991509b8e9c7870
Status: Downloaded newer image for hyperledger/fabric-tools:latest
Creating cliMagnetoCorp ... done
```

再次查看如何从 Docker Hub 中检索 `hyperledger/fabric-tools` docker 镜像并将其添加到网络中:

```
(magnetocorp admin)$ docker ps

CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                            NAMES
562a88b25149        hyperledger/fabric-tools     "/bin/bash"              About a minute ago   Up About a minute                                                    cliMagnetoCorp
b7f3586e5d02        gliderlabs/logspout          "/bin/logspout"          7 minutes ago        Up 7 minutes        127.0.0.1:8000->80/tcp                           logspout
ada3d078989b        hyperledger/fabric-peer      "peer node start"        29 minutes ago       Up 29 minutes       0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
1fa1fd107bfb        hyperledger/fabric-orderer   "orderer"                29 minutes ago       Up 29 minutes       0.0.0.0:7050->7050/tcp                           orderer.example.com
53fe614274f7        hyperledger/fabric-couchdb   "tini -- /docker-ent…"   29 minutes ago       Up 29 minutes       4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb
469201085a20        hyperledger/fabric-ca        "sh -c 'fabric-ca-se…"   29 minutes ago       Up 29 minutes       0.0.0.0:7054->7054/tcp                           ca.example.com
```

MagnetoCorp 管理员在容器 `562a88b25149` 中使用命令行和 PaperNet 交互。同样也注意 `logspout` 
容器 `b7f3586e5d02`；它将为 ` monitordocker.sh ` 命令捕获来自其他所有容器的输出。

现在让我们作为 MagnetoCorp 的管理员使用命令行和 PaperNet 交互吧。

## 智能合约

`issue`, `buy` 和 `redeem` 是 PaperNet 智能合约的三个核心功能。应用程序使用这些功能来提交交易，相应地，在账本上会发行、购买和赎回商业票据。我们接下来的任务就是检查这个智能合约。

打开一个新的终端窗口来代表 MagnetoCorp 开发人员，然后切换到包含 MagnetoCorp 的智能合约拷贝的目录，使用你选定的编辑器进行查看（这个教程用的是 VS Code）。

```
(magnetocorp developer)$ cd commercial-paper/organization/magnetocorp/contract
(magnetocorp developer)$ code .
```

在这个文件夹的 `lib` 目录下，你将看到 `papercontract.js` 文件 -- 其中包含了商业票据智能合约！


![commercialpaper.vscode1](./commercial_paper.diagram.10.png) *一个示例代码编辑器在 `papercontract.js` 文件中展示商业票据智能合约*

`papercontract.js` 是一个在 node.js 环境中运行的 JavaScript 程序。注意下面的关键程序行：


* `const { Contract, Context } = require('fabric-contract-api');`

  这个语句引入了两个关键的 Hyperledger Fabric 类 -- `Contract` 和 `Context`，它们被智能合约广泛使用。你可以在 [`fabric-shim` JSDOCS](https://fabric-shim.github.io/) 中了解到这些类的更多信息。



* `class CommercialPaperContract extends Contract {`

  这里基于内置的 Fabric `Contract` 类定义了智能合约类 `CommercialPaperContract` 。实现了 `issue`, `buy` 和 `redeem` 商业票据关键交易的方法被定义在该类中。


* `async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime...) {`

  这个方法为 PaperNet 定义了商业票据 `issue` 交易。传入的参数用于创建新的商业票据。找到并检查智能合约内的 `buy` 和 `redeem` 交易。



* `let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime...);`

  在 `issue` 交易内部，这个语句根据提供的交易输入使用 `CommercialPaper` 类在内存中创建了一个新的商业票据。检查 `buy` 和 `redeem` 交易看如何类似地使用该类。


* `await ctx.paperList.addPaper(paper);`

  这个语句使用 `ctx.paperList` 在账本上添加了新的商业票据，其中 `ctx.paperList` 是`PaperList` 类的一个实例，当智能合约场景 `CommercialPaperContext`
  被初始化时，就会创建出一个 `ctx.paperList`。再次检查 `buy` 和 `redeem` 方法，以了解这些方法是如何使用这一类的。


* `return paper.toBuffer();`

  该语句返回一个二进制缓冲区，作为来自 `issue` 交易的响应，供智能合约的调用者处理。

欢迎检查 `contract` 目录下的其他文件来理解智能合约是如何工作的，请仔细阅读智能合约[主题](https://hyperledger-fabric.readthedocs.io/en/latest/developapps/smartcontract.html)中 `papercontract.js` 是如何设计的。

## 安装合约

要想使应用程序能够调用 `papercontract` 合约，必须先在 PaperNet 中合适的peer节点上安装该合约。MagnetoCorp 和 DigiBank 的管理员能够将 `papercontract` 安装到他们各自拥有权限的节点上。

![commercialpaper.install](./commercial_paper.diagram.6.png) *MagnetoCorp 的管理员将 `papercontract` 的一个副本安装在 MagnetoCorp 的节点上。*

智能合约是应用开发的重点，它被包含在一个名为[链码](../chaincode.html)的 Hyperledger Fabric 组件中。在一个链码中可以定义一个或多个智能合约，安装链码就使得 PaperNet 中的不同组织可以使用其中的智能合约。这意味着只有管理员需要关注链码；其他人都只需关注智能合约。

MagnetoCorp 的管理员使用 `peer chaincode install` 命令将 `papercontract` 智能合约从他们的本地机器文件系统中复制到目标节点 docker 容器的文件系统中。一旦智能合约被安装在节点上且在通道上进行实例化，应用程序就可以调用 `papercontract` 智能合约，然后通过 Fabric 的 API [putState()](https://fabric-shim.github.io/release-1.3/fabric-shim.ChaincodeStub.html#putState__anchor) 和 [getState()](https://fabric-shim.github.io/release-1.3/fabric-shim.ChaincodeStub.html#getState__anchor) 与账本数据库进行交互。
检查一下 `StateList` 类是如何在 `ledger-api\statelist.js` 中使用这些 API 的。

现在让我们以 MagnetoCorp 的管理员身份来安装 `papercontract` 智能合约。在 MagnetoCorp 管理员的命令窗口中，使用 `docker exec` 命令在 `cliMagnetCorp` 容器中运行 `peer chaincode install` 命令：

```
(magnetocorp admin)$ docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0 -p /opt/gopath/src/github.com/contract -l node

2018-11-07 14:21:48.400 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2018-11-07 14:21:48.400 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2018-11-07 14:21:48.466 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >
```

`cliMagnetCorp` 容器设置了 `CORE_PEER_ADDRESS=peer0.org1.example.com:7051` 来将其命令指向 `peer0.org1.example.com`，`INFO 003 Installed remotely...` 表示 `papercontract` 已经成功安装在节点上。现在，MagnetoCorp 的管理员只需要在 MagentoCorp 的一个节点上安装 `papercontract` 的副本。

注意 `peer chaincode install` 命令是如何指定智能合约的路径的，`-p` 参数是相对于 `cliMagnetoCorp` 容器的文件系统：`/opt/gopath/src/github.com/contract`。这个路径已经通过 `magnetocorp/configuration/cli/docker-compose.yml` 文件映射到本地文件系统通道 `.../organization/magnetocorp/contract` 上。

```yaml
volumes:
    - ...
    - ./../../../../organization/magnetocorp:/opt/gopath/src/github.com/
    - ...
```

看一下 `volume` 指令是如何将 `organization/magnetocorp` 映射到 `/opt/gopath/src/github.com/` 中，从而向该容器提供访问你本地文件系统的权限，你的本地文件系统中存储了 MagnetoCorp 的 `papercontract` 智能合约副本。

你可以在[这里](https://docs.docker.com/compose/overview/)阅读更多关于 `docker compose` 命令的内容，在[这里](../commands/peerchaincode.html)阅读更多关于 `peer chaincode install` 命令的内容。


## 实例化合约

既然已经将包含 `CommercialPaper` 智能合约的 `papercontract` 链码安装在所需的 PaperNet 节点上， 管理员可以把它提供给不同的网络通道来使用，这样一来，连接到这些通道上的应用软件就能够调用此链码。因为我们在 PaperNet 中所用的是最基本的网络配置，所以只会把 `papercontract` 提供到 `mychannel` 这一个网络通道上。![commercialpaper.instant](./commercial_paper.diagram.7.png) *MagnetoCorp 的一名管理员将包含此智能合约的
`papercontract` 链码进行实例化。创建一个新的docker容器来运行`papercontract`。*

MagnetoCorp 的管理员使用 `peer chaincode instantiate` 命令来在 `mychannel` 上实例化 `papercontract` ：

```
(magnetocorp admin)$ docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0 -l node -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"

2018-11-07 14:22:11.162 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
2018-11-07 14:22:11.163 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default escc
2018-11-07 14:22:11.163 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default vscc
```

这个命令可能要花费几分钟时间。

`instantiate` 中最重要的参数之一是 `-P`。该参数为 `papercontract` 指明了[背书策略](../endorsement-policies.html)，它描述了在认定一项交易为有效之前必须对其背书（执行和签名）的一群组织。所有交易，无论有效与否，都将被记录在 [账本区块链](../ledger/ledger.html#blockchain)上，但仅有效交易会更新[世界状态](../ledger/ledger.html#world-state)。

在传递阶段，看看 `instantiate` 如何传递排序服务地址 `orderer.example.com:7050` 。这是因为`instantiate`  向排序服务额外提交了一项实例化交易，排序服务将把该交易包括到下一个区块中，并将其分布到所有加入了 `mychannel` 的节点上，使得所有节点都可以在各自独立的链码容器中执行此链码。注意，虽然多数节点一般都会安装`papercontract`，但是如果通道上将运行 `papercontract` ，则只需为该通道发布一次 `instantiate` 。

看看如何使用 `docker ps` 命令开启 `papercontract` 容器：

```
(magnetocorp admin)$ docker ps

CONTAINER ID        IMAGE                                              COMMAND                  CREATED             STATUS              PORTS          NAMES
4fac1b91bfda        dev-peer0.org1.example.com-papercontract-0-d96...  "/bin/sh -c 'cd /usr…"   2 minutes ago       Up 2 minutes                       dev-peer0.org1.example.com-papercontract-0
```

注意该容器名为 `dev-peer0.org1.example.com-papercontract-0-d96...` ，表明了哪个节点启用了它，以及容器正在运行 `papercontract` 版本 `0` 。

既然我们已经组件并运行了一个基本的 PaperNet网络，还安装和实例化了 `papercontract` ，现在就让我们把目光转向发行了一张商业票据的 MagnetoCorp 应用程序吧。

## 应用结构

包含在 `papercontract` 中的智能合约由MagnetoCorp的应用程序 `issue.js` 调用。Isabella 使用该程序向发行商业票据`00001`的账本提交一项交易。让我么来快速检验一下 `issue` 应用是怎么工作的。

![commercialpaper.application](./commercial_paper.diagram.8.png) *网关允许应用程序专注于交易的生成、提交和响应。它协调不同网络组件之间的交易提案、排序和通知处理。*

`issue` 应用程序代表Isabella提交交易，它通过从Isabella的[钱包](../developapps/wallet.html)中索取其X.509证书来开始运行，此证书可能储存在本地文件系统中或一个硬件安全模块[HSM](https://en.wikipedia.org/wiki/Hardware_security_module)里。随后，`issue` 应用程序就能够利用网关在通道上提交交易。Hyperledger Fabric的软件开发包（SDK）提供了一个[gateway](../developapps/gateway.html)抽象，因此应用程序在将网络交互托管给网关时能够专注于应用逻辑。网关和钱包使得编写Hyperledger Fabric应用程序变得很简单。

让我们来检验一下Isabella将要使用的 `issue` 应用程序，为其打开另一个终端窗口，在 `fabric-samples` 中找到MagnetoCorp的 `/application` 文件夹：

```
(magnetocorp user)$ cd commercial-paper/organization/magnetocorp/application/
(magnetocorp user)$ ls

addToWallet.js		issue.js		package.json
```

`addToWallet.js` 是Isabella将用来把自己的身份装进钱包的程序，而 `issue.js` 将使用这一身份通过调用 `papercontract` 来代表MagnetoCorp生成商业票据 `00001`。

切换至包含MagnetoCorp的 `issue.js` 应用程序副本的目录，并且使用你的代码编辑器来对此目录进行检测：

```
(magnetocorp user)$ cd commercial-paper/organization/magnetocorp/application
(magnetocorp user)$ code issue.js
```

检查该目录；目录包含了issue应用程序和其所有依赖项。

![commercialpaper.vscode2](./commercial_paper.diagram.11.png) *一个展示了商业票据应用程序目录内容的代码编辑器。*

注意以下在 `issue.js` 中的关键程序行：

* `const { FileSystemWallet, Gateway } = require('fabric-network');`

  该语句把两个关键的Hyperledger Fabric软件开发包（SDK）类代入了 `Wallet` 和 `Gateway` 的范畴。因为Isabella的X.509 证书位于本地文件系统中，所以应用程序使用的是`FileSystemWallet`。


* `const wallet = new FileSystemWallet('../identity/user/isabella/wallet');`

  该语句表明了应用程序在连接到区块链网络通道上时将使用 `Isabella` 钱包。应用程序会在`isabella` 钱包中选择一个特定的身份。（该钱包必须已经装有Isabella的 X.509 证书，这就是 `addToWallet.js` 的工作）


* `await gateway.connect(connectionProfile, connectionOptions);`

  此行代码使用 `connectionProfile` 识别的网关来连接到网络，使用 `ConnectionOptions` 当中引用的身份。
  

看看 `../gateway/networkConnection.yaml` 和 `User1@org1.example.com` 是如何分别被用于这些值的。


* `const network = await gateway.getNetwork('mychannel');`

  该语句是将应用程序连接到网络通道 `mychannel` 上， `papercontract`  之前就已经在该通道上实例化过了。


*  `const contract = await network.getContract('papercontract', 'org.papernet.comm...');`

  该语句是让应用程序可以访问由`papercontract` 中的`org.papernet.commercialpaper` 命名空间定义的智能合约。一旦应用程序发送了getContract，那么它就能提交任意在其内实现的交易。


* `const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001'...);`

  该行代码是使用在智能合约中定义的 `issue` 交易来向网络提交一项交易。`MagnetoCorp` ，`00001`... 都是被 `issue` 交易用来生成一个新的商业票据的值。
  
* `let paper = CommercialPaper.fromBuffer(issueResponse);`

  此语句是处理 `issue` 交易发来的响应。该响应需要从缓冲区被反序列化成 `paper` ，这是一个能够被应用程序准确解释的 `CommercialPaper` 对象。
  
  欢迎检查 `/application` 目录下的其他文档来了解 `issue.js` 是如何工作的，并仔细阅读应用程序[主题](../developapps/application.html)中关于如何实现 `issue.js` 的内容。

## 应用程序依赖项

`issue.js` 应用程序是用 JavaScript 编写的，旨在作为PaperNet 网络的客户端来在 node.js 环境中运行。按照惯例，会在多个网络外部的节点包上建立MagnetoCorp 的应用程序，以此来提升开发的质量和速度。考虑一下 `issue.js` 是如何纳入 `js-yaml`
[包装](https://www.npmjs.com/package/js-yaml) 来处理 YAML 网关连接配置文件的，或者`issue.js` 是如何纳入 `fabric-network` [包装](https://www.npmjs.com/package/fabric-network) 来访问 `Gateway` 和 `Wallet` 类的：

```JavaScript
const yaml = require('js-yaml');
const { FileSystemWallet, Gateway } = require('fabric-network');
```

需要使用 `npm install` 命令来将这些包装从 [npm](https://www.npmjs.com/) 下载到本地文件系统中。按照惯例，必须将包装安装进一个相对于应用程序的`/node_modules` 目录中，以供运行时使用。

检查 `package.json` 文件来看看 `issue.js` 是如何通过识别包装来下载自己的准确版本的：

```json
  "dependencies": {
    "fabric-network": "^1.4.0-beta",
    "fabric-client": "^1.4.0-beta",
    "js-yaml": "^3.12.0"
  },
```

**npm** 版本控制功能非常强大；点击[这里](https://docs.npmjs.com/getting-started/semantic-versioning)可以了解更多相关信息。

让我们使用 `npm install` 命令来安装这些包装，安装过程可能需要一分钟：

```
(magnetocorp user)$ npm install

(           ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

看看这个命令是如何更新目录的：

```
(magnetocorp user)$ ls

addToWallet.js		node_modules	      	package.json
issue.js	      	package-lock.json
```

检查 `node_modules` 目录，查看已经安装的包装。能看到很多已经安装了的包装，这是因为 `js-yaml` 和 `fabric-network` 本身都被搭建在其他 npm 包装中！ `package-lock.json`
[文件](https://docs.npmjs.com/files/package-lock.json) 能准确识别已安装的版本，如果你想精确地复制环境（以完成测试、诊断问题或者提交已验证的应用程序等任务）的话，那么这一点对你来说就极为重要。

## 钱包

Isabella 马上就能够运行 `issue.js` 来发行MagnetoCorp 商业票票据 `00001` 了；现在还剩最后一步！因为 `issue.js` 代表 Isabella，所以也就代表 MagnetoCorp， `issue.js` 将会使用 Isabella [钱包](../developapps/wallet.html)中反应以上事实的身份。现在我们需要执行这个一次性的活动，向 Isabella 的钱包中添 X.509 证书。 

在 Isabella 的终端窗口中运行 `addToWallet.js` 程序来把身份信息添加到她的钱包中：

~~~
(isabella)$ node addToWallet.js

done
~~~

```
(isabella)$ node addToWallet.js

done
```

虽然在我们的示例中 Isabella 只使用了  `User1@org.example.com` 这一个身份，但其实她可以在钱包中储存多个身份。目前与这个身份相关联的是基本网络，而不是更实际化的 PaperNet 配置，我们很快会更新此版教程。

`addToWallet.js` 是一个简单的文件复制程序，你可以在闲暇时检查该程序。它把一个身份从基本网络样本上转移到 Isabella 的钱包中。让我们专注于该程序的结果，也就是将被用来向 `PaperNet` 提交交易的钱包的内容：

```
(isabella)$ ls ../identity/user/isabella/wallet/

User1@org1.example.com
```

看看目录结构如何映射 `User1@org1.example.com` 身份——Isabella 使用的其他身份都会有自己的文件夹。在该目录中你会找到 `issue.js` 将代表 `isabella` 使用的身份信息：


```
(isabella)$ ls ../identity/user/isabella/wallet/User1@org1.example.com

User1@org1.example.com      c75bd6911a...-priv      c75bd6911a...-pub
```

注意：

* 使用秘钥 `c75bd6911a...-priv` 代表 Isabella 来签名交易，但始终把这个秘钥置于Isabella的控制之内。


* 公钥 `c75bd6911a...-pub` 与Isabella的私钥有密码联系，并且该公钥完全包含在 Isabella的X.509证书里。


* 在证书生成阶段，证书授权中心添加了`User1@org.example.com` 证书，其中包含了Isabella的公钥和其他 X.509 属性。该证书被分布至网络中，这样一来，不同操作者就能够在不同时间内对Isabella的私钥生成的信息进行密码验证。
  
  点击[此处](https://hyperledger-fabric.readthedocs.io/en/latest/identity/identity.html#digital-certificates)获取更多信息。在实践中，证书文档还包含一些Fabric专门的元数据，例如Isabella的组织和角色——在[钱包](../developapps/wallet.html)主题阅读更多内容。

## 发行应用

Isabella 现在可以用 `issue.js` 来提交一项交易，该交易将发行MagnetoCorp 商业票据 `00001`：

```
(isabella)$ node issue.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper issue transaction.
Process issue transaction response.
MagnetoCorp commercial paper : 00001 successfully issued for value 5000000
Transaction complete.
Disconnect from Fabric gateway.
Issue program complete.
```

`node` 命令初始化一个node.js 环境，并运行 `issue.js`。从程序输出我们能看到，系统发行了一张MagnetoCorp 商业票据 00001，面值为 500万美元。

如您所见，为实现这一点，应用程序调用了`papercontract.js` 中 `CommercialPaper` 智能合约里定义的 `issue` 交易。MagnetoCorp 管理员已经在网络上安装并实例化了`CommercialPaper` 智能合约。在世界状态里作为一个矢量状态来代表新的商业票据的是通过Fabric应用程序编码端口(API)来与账本交互的智能合约，其中最显著的API是 `putState()` 和 `getState()`。我们即将看到该矢量状态在随后是如何被 `buy` 和 `redeem` 交易来操作的，这两项交易同样也是定义在那个智能合约中。

潜在的Fabric软件开发包（SDK）一直都在处理交易的背书、排序和通知流程，使得应用程序的逻辑变得简单明了； SDK 用[网关](../developapps/gateway.html)提取出网络细节信息和[连接选项](../developapps/connectoptions.html) ，以此来声明更先进的流程策略，如交易重试。

现在让我们将重点转换到DigiBank（将购买商业票据），以遵循MagnetoCorp `00001` 的生命周期。

## 像 DigiBank 一样工作

既然MagnetoCorp已经发行了商业票据 `00001` ，现在让我们转换身份，作为DigiBank的雇员与PaperNet交互。首先，我们将作为一个管理员，生成一个操作台，该操作台是被用来与PaperNet交互的。随后我们将作为终端用户Balaji，利用 Digibank的 `buy` 交易来购买商业票据 `00001` ，从而将进程转换到其生命周期的下一阶段。

![commercialpaper.workdigi](./commercial_paper.diagram.5.png) *DigiBank管理员和应用程序与 PaperNet 网络交互。*

因为教程目前使用的是PaperNet基本网络，所以网络配置非常简单。管理员使用的操作台与MagnetoCorp的相似，但操作台是为Digibank的文件系统配置的。同样地，Digibank终端用户将使用和MagnetoCorp应用程序调取相同智能合约的应用程序，尽管它们包含了Digibank专门的逻辑和配置。无论受哪项交易调用，总是智能合约捕获了共享的商业流程，也总是账本维持了共享的商业数据。

让我们打开另外一个终端窗口来让DigiBank管理员与PaperNet交互。 在 `fabric-samples` 中：

```
(digibank admin)$ cd commercial-paper/organization/digibank/configuration/cli/
(digibank admin)$ docker-compose -f docker-compose.yml up -d cliDigiBank

(...)
Creating cliDigiBank ... done
```

该docker容器现在可供Digibank 管理员来与网络进行交互：

```(digibank admin)$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORT         NAMES
858c2d2961d4        hyperledger/fabric-tools         "/bin/bash"              18 seconds ago      Up 18 seconds                    cliDigiBank
```

在此教程中，你将使用名为 `cliDigiBank` 的命令行容器来代表Digibank与网络进行交互。我们尚未展示所有的docker容器，在现实中，DigiBank 用户只能看到它们有访问权限的网络组件（peer节点，排序节点和证书授权中心）。

因为PaperNet网络配置十分简单，所以目前在此教程中Digibank管理员的任务并不多。让我们把注意力转向Balaji。

## Digibank 应用

Balaji 使用 DigiBank 的 `buy` 应用程序来向账本提交一项交易，该账本将商业票据 `00001` 的所属权从MagnetoCorp 转向DigiBank。 `CommercialPaper` 智能合约与MagnetoCorp应用程序使用的相同，但是此次的交易不同，是 `buy` 交易而不是 `issue` 交易。让我们检查一下DigiBank 的应用程序是怎样工作的。 

为 Balaji 打开另一个终端窗口。 在 `fabric-samples` 中，切换到包含 `buy.js` 应用程序的DigiBank 应用程序目录，并用编辑器打开该目录：

```
(balaji)$ cd commercial-paper/organization/digibank/application/
(balaji)$ code buy.js
```

如你所见，该目录同时包含了Balaji将使用的 `buy` 和 `redeem` 应用程序 。

![commercialpaper.vscode3](./commercial_paper.diagram.12.png) *DigiBank的商业票据目录包含 `buy.js` 和 `redeem.js`
应用程序。*

DigiBank的 `buy.js` 应用程序在结构上与MagnetoCorp的
`issue.js` 十分相似，但存在两个重要的差异：


  * **身份**：用户是DigiBank的用户 `Balaji` 而不是MagnetoCorp的 `Isabella`
    
```JavaScript
    const wallet = new FileSystemWallet('../identity/user/balaji/wallet');`
    ```
    
看看应用程序在连接到PaperNet网络上时是如何使用 `balaji` 钱包的。`buy.js` 在 `balaji` 钱包里选择一个特定的身份。


  * **交易**：被调用的交易是 `buy` 而不是 `issue`

    ```JavaScript
    `const buyResponse = await contract.submitTransaction('buy', 'MagnetoCorp', '00001'...);`
    ```

    提交一项 `buy` 交易，其值为 `MagnetoCorp`, `00001`...， `CommercialPaper` 智能合约类使用这些值来将商业票据 `00001` 的所属权转换成DigiBank。

欢迎检查 `application` 目录下的其他文档来理解应用程序 的工作原理，并仔细阅读应用程序[主题](../developapps/application.html)中关于如何实现 `buy.js` 的内容。

## 像 DigiBank 一样运行

负责购买和赎回商业票据的DigiBank 应用程序的结构和 MagnetoCorp的发行交易十分相似。所以，我们来安装这些应用程序 的依赖项，并搭建Balaji的钱包，这样一来，Balaji就能使用这些应用程序购买和赎回商业票据。 

和 MagnetoCorp 一样， Digibank 必须使用 `npm install` 命令来安装规定的应用包，同时，安装时间也很短。

在DigiBank管理员窗口安装应用程序依赖项： 

```
(digibank admin)$ cd commercial-paper/organization/digibank/application/
(digibank admin)$ npm install

(            ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

在Balaji的终端窗口运行 `addToWallet.js` 程序，把身份信息添加到他的钱包中：

```
(balaji)$ node addToWallet.js

done
```

`addToWallet.js` 程序为 `balaji` 将其身份信息添加到他的钱包中， `buy.js` 和 `redeem.js` 将使用这些身份信息来向  `PaperNet` 提交交易。

虽然在我们的示例中，Balaji只使用了`Admin@org.example.com` 这一个身份，但是和Isabella一样， 他也可以在钱包中储存多个身份。`digibank/identity/user/balaji/wallet/Admin@org1.example.com` 中包含的Balaji的相应钱包结构与Isabella的十分相似，欢迎对其进行检查。

## 购买应用

Balaji现在可以使用 `buy.js` 来提交一项交易，该交易将会把MagnetoCorp 商业票据 `00001` 的所属权转换成DigiBank。

在Balaji的窗口运行 `buy` 应用程序： 

```
(balaji)$ node buy.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper buy transaction.
Process buy transaction response.
MagnetoCorp commercial paper : 00001 successfully purchased by DigiBank
Transaction complete.
Disconnect from Fabric gateway.
Buy program complete.
```

你可看到程序输出为：Balaji已经代表DigiBank成功购买了MagnetoCorp 商业票据 00001。 `buy.js` 调用了 `CommercialPaper` 智能合约中定义的 `buy` 交易，该智能合约使用Fabric 应用程序编程接口（API） `putState()` 和 `getState()` 在世界状态中更新了商业票据 `00001` 。如您所见，就智能合约的逻辑来说，购买和发行商业票据的应用程序逻辑彼此十分相似。

## 收回应用

商业票据 `00001` 生命周期的最后一步交易是DigiBank从MagnetoCorp那里收回商业票据。Balaji 使用 `redeem.js` 提交一项交易来执行智能合约中的收回逻辑。

在Balaji的窗口运行 `redeem` 交易：

```
(balaji)$ node redeem.js

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper redeem transaction.
Process redeem transaction response.
MagnetoCorp commercial paper : 00001 successfully redeemed with MagnetoCorp
Transaction complete.
Disconnect from Fabric gateway.
Redeem program complete.
```

同样地，看看当 `redeem.js` 调用了 `CommercialPaper` 中定义的 `redeem` 交易时，商业票据 00001 是如何被成功收回的。 `redeem` 交易在世界状态中更新了商业票据 `00001` ，以此来反映商业票据的所属权又归回其发行方MagnetoCorp。

## 下一步

要想更深入地理解以上教程中所介绍的应用程序和智能合约的工作原理，可以参照[开发应用程序](../developapps/developing_applications.html)。该主题将为您详细介绍商业票据场景、`PaperNet` 商业网络，网络操作者以及它们所使用的应用程序和智能合约的工作原理。

欢迎使用该样本来开始创造你自己的应用程序和智能合约！



<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
