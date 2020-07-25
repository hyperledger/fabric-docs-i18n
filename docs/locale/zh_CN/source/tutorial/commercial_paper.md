# 商业票据教程
# Commercial paper tutorial

*注意：本教程使用 [1.4.x 或者更老的生命周期处理](https://hyperledger-fabric.readthedocs.io/en/release-1.4/chaincode4noah.html)，其中链码在通道中实例化的过程不适用于 Fabric 2.0 版本。商业票据教程稍后会更新为使用多组织网络和新的链码生命周期。*

**Audience:** Architects, application and smart contract developers,
administrators

**受众**: 架构师，应用和智能合约开发者，管理员

This tutorial will show you how to install and use a commercial paper sample
application and smart contract. It is a task-oriented topic, so it emphasizes
procedures above concepts. When you’d like to understand the concepts in more
detail, you can read the
[Developing Applications](../developapps/developing_applications.html) topic.

本教程将向你展示如何安装和使用商业票据样例应用程序和智能合约。该主题是以任务为导向的，
因此它更侧重的是流程而不是概念。如果你想更深入地了解这些概念，可以阅读[开发应用程序](../developapps/developing_applications.html)主题。

![commercialpaper.tutorial](./commercial_paper.diagram.1.png) *In this tutorial
two organizations, MagnetoCorp and DigiBank, trade commercial paper with each
other using PaperNet, a Hyperledger Fabric blockchain network.*

![commercialpaper.tutorial](./commercial_paper.diagram.1.png)
*在本教程中，MagnetoCorp 和 DigiBank 这两个组织使用 Hyperledger Fabric 区块链网络 PaperNet 相互交易商业票据。*

Once you've set up the test network, you'll act as Isabella, an employee of
MagnetoCorp, who will issue a commercial paper on its behalf. You'll then switch
roles to take the role of Balaji, an employee of DigiBank, who will buy this
commercial paper, hold it for a period of time, and then redeem it with
MagnetoCorp for a small profit.

一旦建立了一个基本的网络，你就将扮演 MagnetoCorp 的员工 Isabella，她将代表公司发行商业票据。然后，你将转换角色，担任 DigiBank 的员工 Balaji，他将购买此商业票据，持有一段时间，然后向 MagnetoCorp 兑换该商业票据，以获取小额利润。

You'll act as a developer, end user, and administrator, each in different
organizations, performing the following steps designed to help you understand
what it's like to collaborate as two different organizations working
independently, but according to mutually agreed rules in a Hyperledger Fabric
network.

你将扮演开发人员，最终用户和管理员，这些角色位于不同组织中，都将执行以下步骤，这些步骤旨在帮助你了解作为两个不同组织独立工作但要根据Hyperledger Fabric 网络中双方共同商定的规则来进行协作是什么感觉。

* [Set up machine](#prerequisites) and [download samples](#download-samples)
* [Create the network](#create-the-network)
* [Examine the commercial paper smart contract](#examine-the-commercial-paper-smart-contract)
* [Deploy the smart contract to the channel](#deploy-the-smart-contract-to-the-channel)
  by approving the chaincode definition as MagnetoCorp and Digibank.
* Understand the structure of a MagnetoCorp [application](#application-structure),
  including its [dependencies](#application-dependencies)
* Configure and use a [wallet and identities](#wallet)
* Run a MagnetoCorp application to [issue a commercial paper](#issue-application)
* Understand how DigiBank uses the smart contract in their [applications](#digibank-applications)
* As Digibank, run applications that
  [buy](#buy-application) and [redeem](#redeem-application) commercial paper

 * [组建机器](#准备阶段)和[下载示例](#下载示例)
 * [创建网络](#创建网络)
 * 理解[智能合约](#智能合约)的结构
 * 作为组织 [MagnetoCorp](#像 MagnetoCorp 一样工作) 来[安装](#安装合约)和[实例化](#实例化合约)智能合约
 * 理解 MagnetoCorp [应用](#应用结构)的结构，包括它的[依赖项](#应用依赖)
 * 配置并使用[钱包和身份](#钱包)
 * 启动 MagnetoCorp 的应用程序[发行商业票据](#发行应用)
 * 理解第二个组织 [Digibank](#像 DigiBank 一样工作) 是如何在它们的[应用](#Digibank 应用)中使用智能合约的
 * 作为 Digibank， [运行](#像 DigiBank 一样运行)购买和兑换商业票据的应用程序

This tutorial has been tested on MacOS and Ubuntu, and should work on other
Linux distributions. A Windows version is under development.

本教程已经在 MacOS 和 Ubuntu 上进行了测试，应该可以在其他 Linux 发行版上运行。Windows版本的教程正在开发中。

## Prerequisites

## 先决条件

Before you start, you must install some prerequisite technology required by the
tutorial. We've kept these to a minimum so that you can get going quickly.

在开始之前，你必须安装本教程所需的一些必备技术。我们将必备技术控制在最低限度，以便你能快速开始。

You **must** have the following technologies installed:

你**必须**安装以下软件：

  * [**Node**](https://github.com/hyperledger/fabric-sdk-node#build-and-test)
    The Node.js SDK README contains the up to date list of prerequisites.

  * [**Node**](https://nodejs.org/en/about/) 版本 8.9.0 或更高版本。Node 是一个 Javascript 运行时，可用于运行应用程序和智能合约。推荐使用 node 的 TLS 版本。安装 node 看[这里](https://nodejs.org/en/)。
    
  * [**Docker**](https://www.docker.com/get-started) 版本 18.06 或更高版本。Docker 帮助开发人员和管理员创建标准环境，以构建和运行应用程序和智能合约。提供Hyperledger Fabric 是作为一组Docker 镜像的，PaperNet 智能合约将在 docker 容器中运行。安装 Docker 看[这里](https://www.docker.com/get-started)。

You **will** find it helpful to install the following technologies:

你**会**发现安装以下软件很有帮助：

  * A source code editor, such as
    [**Visual Studio Code**](https://code.visualstudio.com/) version 1.28, or
    higher. VS Code will help you develop and test your application and smart
    contract. Install VS Code [here](https://code.visualstudio.com/Download).

  * 源码编辑器，如 [**Visual Studio Code**](https://code.visualstudio.com/) 版本 1.28，或更高版本。
    VS Code 将会帮助你开发和测试你的应用程序和智能合约。安装 VS Code 看[这里](https://code.visualstudio.com/Download)。

    Many excellent code editors are available including
    [Atom](https://atom.io/), [Sublime Text](http://www.sublimetext.com/) and
    [Brackets](http://www.sublimetext.com/).

    许多优秀的代码编辑器都可以使用，包括 [Atom](https://atom.io/), [Sublime Text](http://www.sublimetext.com/) 和 [Brackets](http://www.sublimetext.com/)。

You **may** find it helpful to install the following technologies as you become
more experienced with application and smart contract development. There's no
requirement to install these when you first run the tutorial:

你**可能**会发现，随着你在应用程序和智能合约开发方面的经验越来越丰富，安装以下软件会很有帮助。 
首次运行教程时无需安装这些：

  * [**Node Version Manager**](https://github.com/creationix/nvm). NVM helps you
    easily switch between different versions of node -- it can be really helpful
    if you're working on multiple projects at the same time. Install NVM
    [here](https://github.com/creationix/nvm#installation).

  * [**Node Version Manager**](https://github.com/creationix/nvm)。NVM 帮助你轻松切换不同版本的 node -- 如果你同时处理多个项目的话，那将非常有用。安装 NVM 看[这里](https://github.com/creationix/nvm#installation)。

## Download samples

## 下载示例

The commercial paper tutorial is one of the samples in the `fabric-samples`
repository. Before you begin this tutorial, ensure that you have followed the
instructions to install the Fabric [Prerequisites](../prereqs.html) and
[Download the Samples, Binaries and Docker Images](../install.html).
When you are finished, you will have cloned the `fabric-samples` repository that
contains the tutorial scripts, smart contract, and application files.

商业票据教程是在名为 `fabric-samples` 的公共 [Github](https://www.github.com) 仓库中保存的 Hyperledger Fabric [示例](https://github.com/hyperledger/fabric-samples)之一。当你要在你的机器上运行教程时，
你的首要任务是下载 `fabric-samples` 仓库。
![commercialpaper.download](./commercial_paper.diagram.2.png) *把 `fabric-samples` GitHub 仓库下载到你的本地机器*

![commercialpaper.download](./commercial_paper.diagram.2.png) *Download the
`fabric-samples` GitHub repository to your local machine.*

`$GOPATH`  Hyperledger Fabric 中重要的环境变量；它识别了要安装的根目录。无论您使用哪种
编程语言，都必须正确行事！打开一个新的终端窗口，然后使用 `env` 命令检查一下你的 `$GOPATH`：

After downloading, feel free to examine the directory structure of `fabric-samples`:

```
$ env
...
GOPATH=/Users/username/go
NVM_BIN=/Users/username/.nvm/versions/node/v8.11.2/bin
NVM_IOJS_ORG_MIRROR=https://iojs.org/dist
...
```

```
$ cd fabric-samples
$ ls

如果你的 `$GOPATH` 没有设置，请看这个[说明](https://github.com/golang/go/wiki/SettingGOPATH)。

CODEOWNERS			    SECURITY.md			        first-network
CODE_OF_CONDUCT.md		chaincode			        high-throughput
CONTRIBUTING.md			chaincode-docker-devmode	interest_rate_swaps
LICENSE				    ci				            off_chain_data
MAINTAINERS.md			commercial-paper		    test-network
README.md			    fabcar
```

现在，你可以创建一个相对于 `$GOPATH ` 的目录，将在其中安装 `fabric-samples`：

Notice the `commercial-paper` directory -- that's where our sample is located!

```
$ mkdir -p $GOPATH/src/github.com/hyperledger/
$ cd $GOPATH/src/github.com/hyperledger/
```

You've now completed the first stage of the tutorial! As you proceed, you'll
open multiple command windows for different users and components. For example:

使用 [`git clone`](https://git-scm.com/docs/git-clone) 命令把 [`fabric-samples`](https://github.com/hyperledger/fabric-samples) 仓库复制到这个地址：

* To show peer, orderer and CA log output from your network.
* To approve the chaincode as an administrator from MagnetoCorp and as an
  administrator from DigiBank.
* To run applications on behalf of Isabella and Balaji, who will use the smart
  contract to trade commercial paper with each other.

```
$ git clone https://github.com/hyperledger/fabric-samples.git
```

We'll make it clear when you should run a command from particular command
window; for example:

随意检查 `fabric-samples` 的目录结构：

```
(isabella)$ ls
```

```
$ cd fabric-samples
$ ls

indicates that you should run the `ls` command from Isabella's window.

CODE_OF_CONDUCT.md    balance-transfer            fabric-ca
CONTRIBUTING.md       basic-network               first-network
Jenkinsfile           chaincode                   high-throughput
LICENSE               chaincode-docker-devmode    scripts
MAINTAINERS.md        commercial-paper            README.md
fabcar
```

## Create the network

注意 `commercial-paper` 目录 -- 我们的示例就在这里！

This tutorial will deploy a smart contract using the Fabric test network.
The test network consists of two peer organizations and one ordering organization.
The two peer organizations operate one peer each, while the ordering organization
operates a single node Raft ordering service. We will also use the test network
to create a single channel named `mychannel` that both peer organizations
will be members of.

现在你已经完成了教程的第一个阶段！随着你继续操作，你将为不同用户和组件打开多个命令窗口。例如：

![commercialpaper.network](./commercial_paper.diagram.testnet.png)
*The Fabric test network is comprised of two peer organizations, Org1 and Org2,
and one ordering organization. Each component runs as a Docker container.*

* 以 Isabella 和 Balaji 的身份运行应用程序，他们将相互交易商业票据
* 以 MagnetoCorp 和 DigiBank 管理员的身份发行命令，包括安装和实例化智能合约
* 展示 peer， orderer 和 CA 的日志输出

Each organization runs their own Certificate Authority. The two peers, the
[state databases](../ledger/ledger.html#world-state-database-options), the ordering service node,
and each organization CA each run in their own Docker container. In production
environments, organizations typically use existing CAs that are shared with other
systems; they're not dedicated to the Fabric network.

当你应该从特定命令窗口运行一项命令时，我们将详细说明这一点。例如：

The two organizations of the test network allow us to interact with a blockchain
ledger as two organizations that operate separate peers. In this tutorial,
we will operate Org1 of the test network as DigiBank and Org2 as MagnetoCorp.

```
(isabella)$ ls
```

You can start the test network and create the channel with a script provided in
the commercial paper directory. Change to the `commercial-paper` directory in
the `fabric-samples`:
```
cd fabric-samples/commercial-paper
```
Then use the script to start the test network:
```
./network-starter.sh
```

这表示你应该在 Isabella 的窗口中执行 `ls` 命令。

While the script is running, you will see logs of the test network being deployed.
When the script is complete, you can use the `docker ps` command to see the
Fabric nodes running on your local machine:
```
$ docker ps

## 创建网络

CONTAINER ID        IMAGE                               COMMAND                  CREATED              STATUS              PORTS                                        NAMES
a86f50ca1907        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   7051/tcp, 0.0.0.0:9051->9051/tcp             peer0.org2.example.com
77d0fcaee61b        hyperledger/fabric-peer:latest      "peer node start"        About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp                       peer0.org1.example.com
7eb5f64bfe5f        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp   couchdb0
2438df719f57        hyperledger/fabric-couchdb          "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:7984->5984/tcp   couchdb1
03373d116c5a        hyperledger/fabric-orderer:latest   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                       orderer.example.com
6b4d87f65909        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:8054->8054/tcp             ca_org2
7b01f5454832        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   7054/tcp, 0.0.0.0:9054->9054/tcp             ca_orderer
87aef6062f23        hyperledger/fabric-ca:latest        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   0.0.0.0:7054->7054/tcp                       ca_org1
```

这个教程目前使用的是基础网络；很快将会更新配置，从而更好的反映出 PaperNet 的多组织结构。
但就目前来说，这个网络已经能够满足向你展示如何开发应用程序和智能合约。

See if you can map these containers to the nodes of the test network (you may
need to horizontally scroll to locate the information):
* The Org1 peer, `peer0.org1.example.com`, is running in container `a86f50ca1907`
* The Org2 peer, `peer0.org2.example.com`, is running in container `77d0fcaee61b`
* The CouchDB database for the Org1 peer, `couchdb0`, is running in container `7eb5f64bfe5f`
* The CouchDB database for the Org2 peer, `couchdb1`, is running in container `2438df719f57`
* The Ordering node, `orderer.example.com`, is running in container `03373d116c5a`
* The Org1 CA, `ca_org1`, is running in container `87aef6062f23`
* The Org2 CA, `ca_org2`, is running in container `6b4d87f65909`
* The Ordering Org CA, `ca_orderer`, is running in container `7b01f5454832`

![commercialpaper.network](./commercial_paper.diagram.3.png) *The Hyperledger Fabric 基础网络的组成部分包括一个节点及该节点的账本数据库，一个排序服务和一个证书授权中心。以上每个组件都在 一个Docker 容器中运行。*

These containers all form a [Docker network](https://docs.docker.com/network/)
called `net_test`. You can view the network with the `docker network` command:

节点及其[账本](../ledger/ledger.html#world-state-database-options)，排序服务和 CA 都是在自己的docker 容器中运行。在生产环境中，组织通常使用的是与其他系统共享的现有 CA；它们并非专门用于 Fabric 网络的。

```
$ docker network inspect net_test

你可以使用 `fabric-samples\basic-network` 目录下的命令和配置来管理基础网络。让我们在你本地的机器上使用 `start.sh`脚本来启动网络：

  [
      {
          "Name": "net_test",
          "Id": "f4c9712139311004b8f7acc14e9f90170c5dcfd8cdd06303c7b074624b44dc9f",
          "Created": "2020-04-28T22:45:38.525016Z",
          "Containers": {
              "03373d116c5abf2ca94f6f00df98bb74f89037f511d6490de4a217ed8b6fbcd0": {
                  "Name": "orderer.example.com",
                  "EndpointID": "0eed871a2aaf9a5dbcf7896aa3c0f53cc61f57b3417d36c56747033fd9f81972",
                  "MacAddress": "02:42:c0:a8:70:05",
                  "IPv4Address": "192.168.112.5/20",
                  "IPv6Address": ""
              },
              "2438df719f57a597de592cfc76db30013adfdcfa0cec5b375f6b7259f67baff8": {
                  "Name": "couchdb1",
                  "EndpointID": "52527fb450a7c80ea509cb571d18e2196a95c630d0f41913de8ed5abbd68993d",
                  "MacAddress": "02:42:c0:a8:70:06",
                  "IPv4Address": "192.168.112.6/20",
                  "IPv6Address": ""
              },
              "6b4d87f65909afd335d7acfe6d79308d6e4b27441b25a829379516e4c7335b88": {
                  "Name": "ca_org2",
                  "EndpointID": "1cc322a995880d76e1dd1f37ddf9c43f86997156124d4ecbb0eba9f833218407",
                  "MacAddress": "02:42:c0:a8:70:04",
                  "IPv4Address": "192.168.112.4/20",
                  "IPv6Address": ""
              },
              "77d0fcaee61b8fff43d33331073ab9ce36561a90370b9ef3f77c663c8434e642": {
                  "Name": "peer0.org1.example.com",
                  "EndpointID": "05d0d34569eee412e28313ba7ee06875a68408257dc47e64c0f4f5ef4a9dc491",
                  "MacAddress": "02:42:c0:a8:70:08",
                  "IPv4Address": "192.168.112.8/20",
                  "IPv6Address": ""
              },
              "7b01f5454832984fcd9650f05b4affce97319f661710705e6381dfb76cd99fdb": {
                  "Name": "ca_orderer",
                  "EndpointID": "057390288a424f49d6e9d6f788049b1e18aa28bccd56d860b2be8ceb8173ef74",
                  "MacAddress": "02:42:c0:a8:70:02",
                  "IPv4Address": "192.168.112.2/20",
                  "IPv6Address": ""
              },
              "7eb5f64bfe5f20701aae8a6660815c4e3a81c3834b71f9e59a62fb99bed1afc7": {
                  "Name": "couchdb0",
                  "EndpointID": "bfe740be15ec9dab7baf3806964e6b1f0b67032ce1b7ae26ac7844a1b422ddc4",
                  "MacAddress": "02:42:c0:a8:70:07",
                  "IPv4Address": "192.168.112.7/20",
                  "IPv6Address": ""
              },
              "87aef6062f2324889074cda80fec8fe014d844e10085827f380a91eea4ccdd74": {
                  "Name": "ca_org1",
                  "EndpointID": "a740090d33ca94dd7c6aaf14a79e1cb35109b549ee291c80195beccc901b16b7",
                  "MacAddress": "02:42:c0:a8:70:03",
                  "IPv4Address": "192.168.112.3/20",
                  "IPv6Address": ""
              },
              "a86f50ca19079f59552e8674932edd02f7f9af93ded14db3b4c404fd6b1abe9c": {
                  "Name": "peer0.org2.example.com",
                  "EndpointID": "6e56772b4783b1879a06f86901786fed1c307966b72475ce4631405ba8bca79a",
                  "MacAddress": "02:42:c0:a8:70:09",
                  "IPv4Address": "192.168.112.9/20",
                  "IPv6Address": ""
              }
          },
          "Options": {},
          "Labels": {}
      }
  ]
```

```
$ cd fabric-samples/basic-network
$ ./start.sh

See how the eight containers use different IP addresses, while being part of a
single Docker network. (We've abbreviated the output for clarity.)

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

Because we are operating the test network as DigiBank and MagnetoCorp,
`peer0.org1.example.com` will belong to the DigiBank organization while
`peer0.org2.example.com` will be operated by MagnetoCorp. Now that the test
network is up and running, we can refer to our network as PaperNet from this point
forward.

注意 `docker-compose -f docker-compose.yml up -d ca.example.com...` 命令如何从[DockerHub](https://hub.docker.com/)中拉取然后启动了4 个 Hyperledger Fabric 容器镜像。这些容器都使用了 Hyperledger Fabric 组件的最新版本软件。欢迎浏览 `basic-network` 目录 -- 我们将在本教程中使用该目录的大部分内容。

To recap: you've downloaded the Hyperledger Fabric samples repository from
GitHub and you've got a Fabric network running on your local machine. Let's now
start to play the role of MagnetoCorp, who wishes to issue and trade commercial paper.

你可以使用 `docker ps` 命令列出运行基本网络组件的 docker 容器：

## Monitor the network as MagnetoCorp

```
$ docker ps

The commercial paper tutorial allows you to act as two organizations by
providing two separate folders for DigiBank and MagnetoCorp. The two folders
contain the smart contracts and application files for each organization. Because
the two organizations have different roles in the trading of the commercial paper,
the application files are different for each organization. Open a new window in
the `fabric-samples` repository and use the following command to change into
the MagnetoCorp directory:
```
cd commercial-paper/organization/magnetocorp
```
The first thing we are going to do as MagnetoCorp is monitor the components
of PaperNet. An administrator can view the aggregated output from a set
of Docker containers using the `logspout` [tool](https://github.com/gliderlabs/logspout#logspout).
The tool collects the different output streams into one place, making it easy
to see what's happening from a single window. This can be really helpful for
administrators when installing smart contracts or for developers when invoking
smart contracts, for example.

CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                            NAMES
ada3d078989b        hyperledger/fabric-peer      "peer node start"        About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0.org1.example.com
1fa1fd107bfb        hyperledger/fabric-orderer   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                           orderer.example.com
53fe614274f7        hyperledger/fabric-couchdb   "tini -- /docker-ent…"   About a minute ago   Up About a minute   4369/tcp, 9100/tcp, 0.0.0.0:5984->5984/tcp       couchdb
469201085a20        hyperledger/fabric-ca        "sh -c 'fabric-ca-se…"   About a minute ago   Up About a minute   0.0.0.0:7054->7054/tcp                           ca.example.com
```

In the MagnetoCorp directory, run the following command to run the
`monitordocker.sh`  script and start the `logspout` tool for the containers
associated with PaperNet running on `net_test`:
```
(magnetocorp admin)$ ./configuration/cli/monitordocker.sh net_test
...
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
(...)
Starting monitoring on all containers on the network net_test
b7f3586e5d0233de5a454df369b8eadab0613886fc9877529587345fc01a3582
```

看看你是否可以将这些容器映射到基本网络上(可能需要横向移动才能找到信息)：

Note that you can pass a port number to the above command if the default port in `monitordocker.sh` is already in use.
```
(magnetocorp admin)$ ./monitordocker.sh net_test <port_number>
```

* 节点 `peer0.org1.example.com` 在容器 `ada3d078989b` 中运行
* 排序服务 `orderer.example.com` 在容器 `1fa1fd107bfb` 中运行
* CouchDB 数据库 `couchdb` 在容器 `53fe614274f7` 中运行
* CA `ca.example.com` 在容器 `469201085a20` 中运行

This window will now show output from the Docker containers for the remainder of the
tutorial, so go ahead and open another command window. The next thing we will do is
examine the smart contract that MagnetoCorp will use to issue to the commercial
paper.

所有这些容器构成了被称作 `net_basic` 的 [docker 网络](https://docs.docker.com/network/)。你可以使用 `docker network` 命令查看该网络：

## Examine the commercial paper smart contract

```
$ docker network inspect net_basic

`issue`, `buy` and `redeem` are the three functions at the heart of the commercial
paper smart contract. It is used by applications to submit transactions which
correspondingly issue, buy and redeem commercial paper on the ledger. Our next
task is to examine this smart contract.

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

Open a new terminal in the `fabric-samples` directory and change into the
MagnetoCorp folder to act as the MagnetoCorp developer.
```
cd commercial-paper/organization/magnetocorp
```
You can then view the smart contract in the `contract` directory using your chosen
editor (VS Code in this tutorial):
```
(magnetocorp developer)$ code contract
```

看看这四个容器如何在作为单个docker网络一部分的同时使用不同的IP地址。（为了清晰起见，我们对输出进行了缩写。）

In the `lib` directory of the folder, you'll see `papercontract.js` file -- this
contains the commercial paper smart contract!

回顾一下: 你已经从 GitHub 下载了 Hyperledger Fabric 样本仓库，并且已经在本地机器上运行了基本的网络。现在让我们开始扮演 MagnetoCorp 的角色来交易商业票据。

![commercialpaper.vscode1](./commercial_paper.vscode.papercontract.png) *An
example code editor displaying the commercial paper smart contract in `papercontract.js`*

## 像 MagnetoCorp 一样工作

`papercontract.js` is a JavaScript program designed to run in the Node.js
environment. Note the following key program lines:

为了监控 PaperNet 网络中的 MagnetoCorp 组件，管理员可以使用 `logspout` [工具](https://github.com/gliderlabs/logspout#logspout) 来查看一组 docker 容器日志的聚合结果。该工具可以将不同输出流采集到一个地方，从而在一个窗口中就可以轻松看到正在发生的事情。比如，对于正在安装智能合约的管理员或者正在调用智能合约的开发人员来说，这个工具确实很有帮助。

* `const { Contract, Context } = require('fabric-contract-api');`

现在让我们作为 MagnetoCorp 的管理员来监控 PaperNet 网络。在 `fabric-samples` 目录下打开一个新窗口，找到并运行 `monitordocker.sh` 脚本，以启动与 docker 网络 `net_basic` 关联的 PaperNet docker 容器的 `logspout` 工具：

  This statement brings into scope two key Hyperledger Fabric classes that will
  be used extensively by the smart contract  -- `Contract` and `Context`. You
  can learn more about these classes in the
  [`fabric-shim` JSDOCS](https://hyperledger.github.io/fabric-chaincode-node/).

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

* `class CommercialPaperContract extends Contract {`

```
(magnetocorp admin)$ ./monitordocker.sh net_basic <port_number>
```

  This defines the smart contract class `CommercialPaperContract` based on the
  built-in Fabric `Contract` class.  The methods which implement the key
  transactions to `issue`, `buy` and `redeem` commercial paper are defined
  within this class.

这个窗口将会显示 docker 容器的输出，所以让我们启动另一个终端窗口来让 MagnetoCorp 的管理员和
网络交互。


![commercialpaper.workmagneto](./commercial_paper.diagram.4.png) *MagnetoCorp 管理员通过一个 docker 容器和网络交互。*

* `async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime...) {`

为了和 PaperNet 交互，MagnetoCorp 管理员需要使用 Hyperledger Fabric `peer` 命令。而这些命令
都可以在 `hyperledger/fabric-tools` docker 镜像中预先构建，所以非常方便。

  This method defines the commercial paper `issue` transaction for PaperNet. The
  parameters that are passed to this method will be used to create the new
  commercial paper.

让我们使用 `docker-compose` [命令](https://docs.docker.com/compose/overview/)来为管理员启动一个 MagnetoCorp 特定的 docker 容器：

  Locate and examine the `buy` and `redeem` transactions within the smart
  contract.

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

* `let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime...);`

再次查看如何从 Docker Hub 中检索 `hyperledger/fabric-tools` docker 镜像并将其添加到网络中:

  Within the `issue` transaction, this statement creates a new commercial paper
  in memory using the `CommercialPaper` class with the supplied transaction
  inputs. Examine the `buy` and `redeem` transactions to see how they similarly
  use this class.

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

* `await ctx.paperList.addPaper(paper);`

MagnetoCorp 管理员在容器 `562a88b25149` 中使用命令行和 PaperNet 交互。同样也注意 `logspout` 
容器 `b7f3586e5d02`；它将为 ` monitordocker.sh ` 命令捕获来自其他所有容器的输出。

  This statement adds the new commercial paper to the ledger using
  `ctx.paperList`, an instance of a `PaperList` class that was created when the
  smart contract context `CommercialPaperContext` was initialized. Again,
  examine the `buy` and `redeem` methods to see how they use this class.

现在让我们作为 MagnetoCorp 的管理员使用命令行和 PaperNet 交互吧。


## 智能合约

* `return paper;`

`issue`, `buy` 和 `redeem` 是 PaperNet 智能合约的三个核心功能。应用程序使用这些功能来提交交易，相应地，在账本上会发行、购买和赎回商业票据。我们接下来的任务就是检查这个智能合约。

  This statement returns a binary buffer as response from the `issue`
  transaction for processing by the caller of the smart contract.

打开一个新的终端窗口来代表 MagnetoCorp 开发人员，然后切换到包含 MagnetoCorp 的智能合约拷贝的目录，使用你选定的编辑器进行查看（这个教程用的是 VS Code）。


```
(magnetocorp developer)$ cd commercial-paper/organization/magnetocorp/contract
(magnetocorp developer)$ code .
```

Feel free to examine other files in the `contract` directory to understand how
the smart contract works, and read in detail how `papercontract.js` is
designed in the [smart contract processing](../developapps/smartcontract.html)
topic.

在这个文件夹的 `lib` 目录下，你将看到 `papercontract.js` 文件 -- 其中包含了商业票据智能合约！

## Deploy the smart contract to the channel

![commercialpaper.vscode1](./commercial_paper.diagram.10.png) *一个示例代码编辑器在 `papercontract.js` 文件中展示商业票据智能合约*

Before `papercontract` can be invoked by applications, it must be installed onto
the appropriate peer nodes of the test network and then defined on the channel
using the [Fabric chaincode lifecycle](../chaincode_lifecycle.html#chaincode-lifecycle). The Fabric chaincode
lifecycle allows multiple organizations to agree to the parameters of a chaincode
before the chaincode is deployed to a channel. As a result, we need to install
and approve the chaincode as administrators of both MagnetoCorp and DigiBank.

`papercontract.js` 是一个在 node.js 环境中运行的 JavaScript 程序。注意下面的关键程序行：

![commercialpaper.install](./commercial_paper.diagram.install.png)  *A MagnetoCorp
administrator installs a copy of the `papercontract` onto a MagnetoCorp peer.*


Smart contracts are the focus of application development, and are contained
within a Hyperledger Fabric artifact called [chaincode](../chaincode.html). One
or more smart contracts can be defined within a single chaincode, and installing
a chaincode will allow them to be consumed by the different organizations in
PaperNet. It means that only administrators need to worry about chaincode;
everyone else can think in terms of smart contracts.

* `const { Contract, Context } = require('fabric-contract-api');`

### Install and approve the smart contract as MagnetoCorp

  这个语句引入了两个关键的 Hyperledger Fabric 类 -- `Contract` 和 `Context`，它们被智能合约广泛使用。你可以在 [`fabric-shim` JSDOCS](https://fabric-shim.github.io/) 中了解到这些类的更多信息。

We will first install and approve the smart contract as the MagnetoCorp admin. Make
sure that you are operating from the `magnetocorp` folder, or navigate back to that
folder using the following command:
```
cd commercial-paper/organization/magnetocorp
```

* `class CommercialPaperContract extends Contract {`

A MagnetoCorp administrator can interact with PaperNet using the `peer` CLI. However,
the administrator needs to set certain environment variables in their command
window to use the correct set of `peer` binaries, send commands to the address
of the MagnetoCorp peer, and sign requests with the correct cryptographic material.

  这里基于内置的 Fabric `Contract` 类定义了智能合约类 `CommercialPaperContract` 。实现了 `issue`, `buy` 和 `redeem` 商业票据关键交易的方法被定义在该类中。

You can use a script provided by the sample to set the environment variables in
your command window. Run the following command in the `magnetocorp` directory:
```
source magnetocorp.sh
```

* `async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime...) {`

You will see the full list of environment variables printed in your window. We
can now use this command window to interact with PaperNet as the MagnetoCorp
administrator.

  这个方法为 PaperNet 定义了商业票据 `issue` 交易。传入的参数用于创建新的商业票据。找到并检查智能合约内的 `buy` 和 `redeem` 交易。

The first step is to install the `papercontract` smart contract. The smart
contract can be packaged into a chaincode using the
`peer lifecycle chaincode package` command. In the MagnetoCorp administrator's
command window, run the following command to create the chaincode package:
```
(magnetocorp admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
The MagnetoCorp admin can now install the chaincode on the MagnetoCorp peer using
the `peer lifecycle chaincode install` command:
```
(magnetocorp admin)$ peer lifecycle chaincode install cp.tar.gz
```
When the chaincode package is installed, you will see messages similar to the following
printed in your terminal:
```
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEcp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c\022\004cp_0" >
2020-01-30 18:32:33.762 EST [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```
Because the MagnetoCorp admin has set `CORE_PEER_ADDRESS=localhost:9051` to
target its commands to `peer0.org2.example.com`, the `INFO 001 Installed remotely...`
indicates that `papercontract` has been successfully installed on this peer.

* `let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime...);`

After we install the smart contract, we need to approve the chaincode definition
for `papercontract` as MagnetoCorp. The first step is to find the packageID of
the chaincode we installed on our peer. We can query the packageID using the
`peer lifecycle chaincode queryinstalled` command:
```
peer lifecycle chaincode queryinstalled
```

  在 `issue` 交易内部，这个语句根据提供的交易输入使用 `CommercialPaper` 类在内存中创建了一个新的商业票据。检查 `buy` 和 `redeem` 交易看如何类似地使用该类。

The command will return the same package identifier as the install command. You
should see output similar to the following:
```
Installed chaincodes on peer:
Package ID: cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c, Label: cp_0
```

* `await ctx.paperList.addPaper(paper);`

We will need the package ID in the next step, so we will save it as an environment
variable. The package ID may not be the same for all users, so you need to
complete this step using the package ID returned from your command window.
```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

  这个语句使用 `ctx.paperList` 在账本上添加了新的商业票据，其中 `ctx.paperList` 是`PaperList` 类的一个实例，当智能合约场景 `CommercialPaperContext`
  被初始化时，就会创建出一个 `ctx.paperList`。再次检查 `buy` 和 `redeem` 方法，以了解这些方法是如何使用这一类的。

The admin can now approve the chaincode definition for MagnetoCorp using the
`peer lifecycle chaincode approveformyorg` command:
```
(magnetocorp admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

* `return paper.toBuffer();`

One of the most important chaincode parameters that channel members need to
agree to using the chaincode definition is the chaincode [endorsement policy](../endorsement-policies.html).
The endorsement policy describes the set of organizations that must endorse
(execute and sign) a transaction before it can be determined to be valid. By
approving the `papercontract` chaincode without the ``--policy`` flag, the
MagnetoCorp admin agrees to using the channel's default `Endorsement` policy,
which in the case of the `mychannel` test channel requires a
majority of organizations on the channel to endorse a transaction. All transactions,
whether valid or invalid, will be recorded on the [ledger blockchain](../ledger/ledger.html#blockchain),
but only valid transactions will update the [world state](../ledger/ledger.html#world-state).

  该语句返回一个二进制缓冲区，作为来自 `issue` 交易的响应，供智能合约的调用者处理。

### Install and approve the smart contract as DigiBank

欢迎检查 `contract` 目录下的其他文件来理解智能合约是如何工作的，请仔细阅读智能合约[主题](https://hyperledger-fabric.readthedocs.io/en/latest/developapps/smartcontract.html)中 `papercontract.js` 是如何设计的。

Based on the `mychannel` `LifecycleEndorsement` policy, the Fabric Chaincode lifecycle
will require a majority of organizations on the channel to agree to the chaincode
definition before the chaincode can be committed to the channel.
This implies that we need to approve the `papernet` chaincode as both MagnetoCorp
and DigiBank to get the required majority of 2 out of 2. Open a new terminal
window in the `fabric-samples` and navigate to the folder that contains the
DigiBank smart contract and application files:
```
(digibank admin)$ cd commercial-paper/organization/digibank/
```
Use the script in the DigiBank folder to set the environment variables that will
allow you to act as the DigiBank admin:
```
source digibank.sh
```

## 安装合约

We can now install and approve `papercontract` as the DigiBank. Run the following
command to package the chaincode:
```
(digibank admin)$ peer lifecycle chaincode package cp.tar.gz --lang node --path ./contract --label cp_0
```
The admin can now install the chaincode on the DigiBank peer:
```
(digibank admin)$ peer lifecycle chaincode install cp.tar.gz
```
We then need to query and save the packageID of the chaincode that was just
installed:
```
(digibank admin)$ peer lifecycle chaincode queryinstalled
```
Save the package ID as an environment variable. Complete this step using the
package ID returned from your console.
```
export PACKAGE_ID=cp_0:ffda93e26b183e231b7e9d5051e1ee7ca47fbf24f00a8376ec54120b1a2a335c
```

要想使应用程序能够调用 `papercontract` 合约，必须先在 PaperNet 中合适的peer节点上安装该合约。MagnetoCorp 和 DigiBank 的管理员能够将 `papercontract` 安装到他们各自拥有权限的节点上。

The Digibank admin can now approve the chaincode definition of `papercontract`:
```
(digibank admin)$ peer lifecycle chaincode approveformyorg --orderer localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name papercontract -v 0 --package-id $PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA
```

![commercialpaper.install](./commercial_paper.diagram.6.png) *MagnetoCorp 的管理员将 `papercontract` 的一个副本安装在 MagnetoCorp 的节点上。*

### Commit the chaincode definition to the channel

智能合约是应用开发的重点，它被包含在一个名为[链码](../chaincode.html)的 Hyperledger Fabric 组件中。在一个链码中可以定义一个或多个智能合约，安装链码就使得 PaperNet 中的不同组织可以使用其中的智能合约。这意味着只有管理员需要关注链码；其他人都只需关注智能合约。

Now that DigiBank and MagnetoCorp have both approved the `papernet` chaincode, we
have the majority we need (2 out of 2) to commit the chaincode definition to the
channel. Once the chaincode is successfully defined on the channel, the
`CommercialPaper` smart contract inside the `papercontract` chaincode can be
invoked by client applications on the channel. Since either organization can
commit the chaincode to the channel, we will continue operating as the
DigiBank admin:

MagnetoCorp 的管理员使用 `peer chaincode install` 命令将 `papercontract` 智能合约从他们的本地机器文件系统中复制到目标节点 docker 容器的文件系统中。一旦智能合约被安装在节点上且在通道上进行实例化，应用程序就可以调用 `papercontract` 智能合约，然后通过 Fabric 的 API [putState()](https://fabric-shim.github.io/release-1.4/fabric-shim.ChaincodeStub.html#putState__anchor) 和 [getState()](https://fabric-shim.github.io/release-1.4/fabric-shim.ChaincodeStub.html#getState__anchor) 与账本数据库进行交互。
检查一下 `StateList` 类是如何在 `ledger-api\statelist.js` 中使用这些 API 的。

![commercialpaper.commit](./commercial_paper.diagram.commit.png)  *After the DigiBank administrator commits the definition of the `papercontract` chaincode to the channel, a new Docker chaincode container will be created to run `papercontract` on both PaperNet peers*

现在让我们以 MagnetoCorp 的管理员身份来安装 `papercontract` 智能合约。在 MagnetoCorp 管理员的命令窗口中，使用 `docker exec` 命令在 `cliMagnetCorp` 容器中运行 `peer chaincode install` 命令：

The DigiBank administrator uses the `peer lifecycle chaincode commit` command
to commit the chaincode definition of `papercontract` to `mychannel`:
```
(digibank admin)$ peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} --channelID mychannel --name papercontract -v 0 --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
```
The chaincode container will start after the chaincode definition has been
committed to the channel. You can use the `docker ps` command to see
`papercontract` container starting on both peers.

```
(magnetocorp admin)$ docker exec cliMagnetoCorp peer chaincode install -n papercontract -v 0 -p /opt/gopath/src/github.com/contract -l node

```
(digibank admin)$ docker ps

2018-11-07 14:21:48.400 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 001 Using default escc
2018-11-07 14:21:48.400 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default vscc
2018-11-07 14:21:48.466 UTC [chaincodeCmd] install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >
```

CONTAINER ID        IMAGE                                                                                                                                                               COMMAND                  CREATED             STATUS              PORTS                                        NAMES
d4ba9dc9c55f        dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535-05cf67c20543ee1c24cf7dfe74abce99785374db15b3bc1de2da372700c25608   "docker-entrypoint.s…"   30 seconds ago      Up 28 seconds                                                    dev-peer0.org1.example.com-cp_0-ebef35e7f1f25eea1dcc6fcad5019477cd7f434c6a5dcaf4e81744e282903535
a944c0f8b6d6        dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec-1a147b6fd2a8bd2ae12db824fad8d08a811c30cc70bc5b6bc49a2cbebc2e71ee   "docker-entrypoint.s…"   31 seconds ago      Up 28 seconds                                                    dev-peer0.org2.example.com-cp_0-1487670371e56d107b5e980ce7f66172c89251ab21d484c7f988c02912ddeaec
```

`cliMagnetCorp` 容器设置了 `CORE_PEER_ADDRESS=peer0.org1.example.com:7051` 来将其命令指向 `peer0.org1.example.com`，`INFO 003 Installed remotely...` 表示 `papercontract` 已经成功安装在节点上。现在，MagnetoCorp 的管理员只需要在 MagentoCorp 的一个节点上安装 `papercontract` 的副本。

Notice that the containers are named to indicate the peer that started it, and
the fact that it's running `papercontract` version `0`.

注意 `peer chaincode install` 命令是如何指定智能合约的路径的，`-p` 参数是相对于 `cliMagnetoCorp` 容器的文件系统：`/opt/gopath/src/github.com/contract`。这个路径已经通过 `magnetocorp/configuration/cli/docker-compose.yml` 文件映射到本地文件系统通道 `.../organization/magnetocorp/contract` 上。

Now that we have deployed the `papercontract` chaincode to the channel, we can
use the MagnetoCorp application to issue the commercial paper. Let's take a
moment to examine the application structure.

```yaml
volumes:
    - ...
    - ./../../../../organization/magnetocorp:/opt/gopath/src/github.com/
    - ...
```

## Application structure

看一下 `volume` 指令是如何将 `organization/magnetocorp` 映射到 `/opt/gopath/src/github.com/` 中，从而向该容器提供访问你本地文件系统的权限，你的本地文件系统中存储了 MagnetoCorp 的 `papercontract` 智能合约副本。

The smart contract contained in `papercontract` is called by MagnetoCorp's
application `issue.js`. Isabella uses this application to submit a transaction
to the ledger which issues commercial paper `00001`. Let's quickly examine how
the `issue` application works.

你可以在[这里](https://docs.docker.com/compose/overview/)阅读更多关于 `docker compose` 命令的内容，在[这里](../commands/peerchaincode.html)阅读更多关于 `peer chaincode install` 命令的内容。

![commercialpaper.application](./commercial_paper.diagram.8.png) *A gateway
allows an application to focus on transaction generation, submission and
response. It coordinates transaction proposal, ordering and notification
processing between the different network components.*

## 实例化合约

Because the `issue` application submits transactions on behalf of Isabella, it
starts by retrieving Isabella's X.509 certificate from her
[wallet](../developapps/wallet.html), which might be stored on the local file
system or a Hardware Security Module
[HSM](https://en.wikipedia.org/wiki/Hardware_security_module). The `issue`
application is then able to utilize the gateway to submit transactions on the
channel. The Hyperledger Fabric SDK provides a
[gateway](../developapps/gateway.html) abstraction so that applications can
focus on application logic while delegating network interaction to the
gateway. Gateways and wallets make it straightforward to write Hyperledger
Fabric applications.

既然已经将包含 `CommercialPaper` 智能合约的 `papercontract` 链码安装在所需的 PaperNet 节点上， 管理员可以把它提供给不同的网络通道来使用，这样一来，连接到这些通道上的应用软件就能够调用此链码。因为我们在 PaperNet 中所用的是最基本的网络配置，所以只会把 `papercontract` 提供到 `mychannel` 这一个网络通道上。

So let's examine the `issue` application that Isabella is going to use. Open a
separate terminal window for her, and in `fabric-samples` locate the MagnetoCorp
`/application` folder:

![commercialpaper.instant](./commercial_paper.diagram.7.png) *MagnetoCorp 的一名管理员将包含此智能合约的 `papercontract` 链码进行实例化。创建一个新的 docker 容器来运行`papercontract`。*

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ ls

MagnetoCorp 的管理员使用 `peer chaincode instantiate` 命令来在 `mychannel` 上实例化 `papercontract` ：

enrollUser.js		issue.js		package.json
```

```
(magnetocorp admin)$ docker exec cliMagnetoCorp peer chaincode instantiate -n papercontract -v 0 -l node -c '{"Args":["org.papernet.commercialpaper:instantiate"]}' -C mychannel -P "AND ('Org1MSP.member')"

`addToWallet.js` is the program that Isabella is going to use to load her
identity into her wallet, and `issue.js` will use this identity to create
commercial paper `00001` on behalf of MagnetoCorp by invoking `papercontract`.

2018-11-07 14:22:11.162 UTC [chaincodeCmd] InitCmdFactory -> INFO 001 Retrieved channel (mychannel) orderer endpoint: orderer.example.com:7050
2018-11-07 14:22:11.163 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 002 Using default escc
2018-11-07 14:22:11.163 UTC [chaincodeCmd] checkChaincodeCmdParams -> INFO 003 Using default vscc
```
这个命令可能要花费几分钟时间。

Change to the directory that contains MagnetoCorp's copy of the application
`issue.js`, and use your code editor to examine it:

`instantiate` 中最重要的参数之一是 `-P`。该参数为 `papercontract` 指明了[背书策略](../endorsement-policies.html)，它描述了在认定一项交易为有效之前必须对其背书（执行和签名）的一群组织。所有交易，无论有效与否，都将被记录在 [账本区块链](../ledger/ledger.html#blockchain)上，但仅有效交易会更新[世界状态](../ledger/ledger.html#world-state)。

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application
(isabella)$ code issue.js
```

在传递阶段，看看 `instantiate` 如何传递排序服务地址 `orderer.example.com:7050` 。这是因为 `instantiate` 向排序服务额外提交了一项实例化交易，排序服务将把该交易包括到下一个区块中，并将其分布到所有加入了 `mychannel` 的节点上，使得所有节点都可以在各自独立的链码容器中执行此链码。注意， `instantiate` 只需要在运行 `papercontract` 的通道上执行一次，即使很多节点都安装了 `papercontract`。

Examine this directory; it contains the issue application and all its
dependencies.

看看如何使用 `docker ps` 命令开启 `papercontract` 容器：

![commercialpaper.vscode2](./commercial_paper.vscode.issue.png) *A code editor
displaying the contents of the commercial paper application directory.*

```
(magnetocorp admin)$ docker ps

Note the following key program lines in `issue.js`:

CONTAINER ID        IMAGE                                              COMMAND                  CREATED             STATUS              PORTS          NAMES
4fac1b91bfda        dev-peer0.org1.example.com-papercontract-0-d96...  "/bin/sh -c 'cd /usr…"   2 minutes ago       Up 2 minutes                       dev-peer0.org1.example.com-papercontract-0
```

* `const { Wallets, Gateway } = require('fabric-network');`

注意该容器名为 `dev-peer0.org1.example.com-papercontract-0-d96...` ，表明了哪个节点启用了它，以及容器正在运行 `papercontract` 版本 `0` 。

  This statement brings two key Hyperledger Fabric SDK classes into scope --
  `Wallet` and `Gateway`.

既然我们已经组件并运行了一个基本的 PaperNet网络，还安装和实例化了 `papercontract` ，现在就让我们把目光转向发行了一张商业票据的 MagnetoCorp 应用程序吧。


## 应用结构

* `const wallet = await Wallets.newFileSystemWallet('../identity/user/isabella/wallet');`

包含在 `papercontract` 中的智能合约由MagnetoCorp的应用程序 `issue.js` 调用。Isabella 使用该程序向发行商业票据`00001`的账本提交一项交易。让我么来快速检验一下 `issue` 应用是怎么工作的。

  This statement identifies that the application will use `isabella` wallet when
  it connects to the blockchain network channel. Because Isabella's X.509 certificate
  is in the local file system, the application creates a new `FileSystemWallet`. The
  application will select a particular identity within `isabella` wallet.

![commercialpaper.application](./commercial_paper.diagram.8.png) *网关允许应用程序专注于交易的生成、提交和响应。它协调不同网络组件之间的交易提案、排序和通知处理。*


`issue` 应用程序代表Isabella提交交易，它通过从Isabella的[钱包](../developapps/wallet.html)中索取其X.509证书来开始运行，此证书可能储存在本地文件系统中或一个硬件安全模块[HSM](https://en.wikipedia.org/wiki/Hardware_security_module)里。随后，`issue` 应用程序就能够利用网关在通道上提交交易。Hyperledger Fabric的软件开发包（SDK）提供了一个[gateway](../developapps/gateway.html)抽象，因此应用程序在将网络交互托管给网关时能够专注于应用逻辑。网关和钱包使得编写Hyperledger Fabric应用程序变得很简单。

* `await gateway.connect(connectionProfile, connectionOptions);`

让我们来检验一下 Isabella 将要使用的 `issue` 应用程序，为其打开另一个终端窗口，在 `fabric-samples` 中找到MagnetoCorp的 `/application` 文件夹：

  This line of code connects to the network using the gateway identified by
  `connectionProfile`, using the identity referred to in `ConnectionOptions`.

```
(magnetocorp user)$ cd commercial-paper/organization/magnetocorp/application/
(magnetocorp user)$ ls

  See how `../gateway/networkConnection.yaml` and `User1@org1.example.com` are
  used for these values respectively.

addToWallet.js		issue.js		package.json
```


`addToWallet.js` 是 Isabella 将用来把自己的身份装进钱包的程序，而 `issue.js` 将使用这一身份通过调用 `papercontract` 来代表 MagnetoCorp 生成商业票据 `00001`。

* `const network = await gateway.getNetwork('mychannel');`

切换至包含 MagnetoCorp 的 `issue.js` 应用程序副本的目录，并且使用你的代码编辑器来对此目录进行检测：

  This connects the application to the network channel `mychannel`, where the
  `papercontract` was previously deployed.

```
(magnetocorp user)$ cd commercial-paper/organization/magnetocorp/application
(magnetocorp user)$ code issue.js
```


检查该目录；目录包含了 issue 应用程序和其所有依赖项。

* `const contract = await network.getContract('papercontract');`

![commercialpaper.vscode2](./commercial_paper.diagram.11.png) *一个展示了商业票据应用程序目录内容的代码编辑器。*

  This statement gives the application access to the `papercontract` chaincode.
  Once an application has issued getContract, it can submit to any smart contract
  transaction implemented within the chaincode.

注意以下在 `issue.js` 中的关键程序行：

* `const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001', ...);`

* `const { FileSystemWallet, Gateway } = require('fabric-network');`

  This line of code submits the a transaction to the network using the `issue`
  transaction defined within the smart contract. `MagnetoCorp`, `00001`... are
  the values to be used by the `issue` transaction to create a new commercial
  paper.

  该语句把两个关键的Hyperledger Fabric软件开发包（SDK）类代入了 `Wallet` 和 `Gateway` 的范畴。因为Isabella的X.509 证书位于本地文件系统中，所以应用程序使用的是`FileSystemWallet`。

* `let paper = CommercialPaper.fromBuffer(issueResponse);`

* `const wallet = new FileSystemWallet('../identity/user/isabella/wallet');`

  This statement processes the response from the `issue` transaction. The
  response needs to deserialized from a buffer into `paper`, a `CommercialPaper`
  object which can interpreted correctly by the application.

  该语句表明了应用程序在连接到区块链网络通道上时将使用 `Isabella` 钱包。应用程序会在 `isabella` 钱包中选择一个特定的身份。（该钱包必须已经装有 Isabella 的 X.509 证书，这就是 `addToWallet.js` 的工作）


* `await gateway.connect(connectionProfile, connectionOptions);`

Feel free to examine other files in the `/application` directory to understand
how `issue.js` works, and read in detail how it is implemented in the
application [topic](../developapps/application.html).

  此行代码使用 `connectionProfile` 识别的网关来连接到网络，使用 `ConnectionOptions` 当中引用的身份。

## Application dependencies

看看 `../gateway/networkConnection.yaml` 和 `User1@org1.example.com` 是如何分别被用于这些值的。

The `issue.js` application is written in JavaScript and designed to run in the
Node.js environment that acts as a client to the PaperNet network.
As is common practice, MagnetoCorp's application is built on many
external node packages --- to improve quality and speed of development. Consider
how `issue.js` includes the `js-yaml`
[package](https://www.npmjs.com/package/js-yaml) to process the YAML gateway
connection profile, or the `fabric-network`
[package](https://www.npmjs.com/package/fabric-network) to access the `Gateway`
and `Wallet` classes:

* `const network = await gateway.getNetwork('mychannel');`

```JavaScript
const yaml = require('js-yaml');
const { Wallets, Gateway } = require('fabric-network');
```

  该语句是将应用程序连接到网络通道 `mychannel` 上， `papercontract`  之前就已经在该通道上实例化过了。

These packages have to be downloaded from [npm](https://www.npmjs.com/) to the
local file system using the `npm install` command. By convention, packages must
be installed into an application-relative `/node_modules` directory for use at
runtime.

*  `const contract = await network.getContract('papercontract', 'org.papernet.comm...');`

Open the `package.json` file to see how `issue.js` identifies the packages to
download and their exact versions by examining the "dependencies" section of the file.

  该语句是让应用程序可以访问由`papercontract` 中的`org.papernet.commercialpaper` 命名空间定义的智能合约。一旦应用程序发送了getContract，那么它就能提交任意在其内实现的交易。

**npm** versioning is very powerful; you can read more about it
[here](https://docs.npmjs.com/getting-started/semantic-versioning).

* `const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001'...);`

Let's install these packages with the `npm install` command -- this may take up
to a minute to complete:

  该行代码是使用在智能合约中定义的 `issue` 交易来向网络提交一项交易。`MagnetoCorp` ，`00001`... 都是被 `issue` 交易用来生成一个新的商业票据的值。
  
* `let paper = CommercialPaper.fromBuffer(issueResponse);`

```
(isabella)$ cd commercial-paper/organization/magnetocorp/application/
(isabella)$ npm install

  此语句是处理 `issue` 交易发来的响应。该响应需要从缓冲区被反序列化成 `paper` ，这是一个能够被应用程序准确解释的 `CommercialPaper` 对象。
  
  欢迎检查 `/application` 目录下的其他文档来了解 `issue.js` 是如何工作的，并仔细阅读应用程序[主题](../developapps/application.html)中关于如何实现 `issue.js` 的内容。

(           ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

## 应用程序依赖项

See how this command has updated the directory:

`issue.js` 应用程序是用 JavaScript 编写的，旨在作为 PaperNet 网络的客户端来在 node.js 环境中运行。按照惯例，会在多个网络外部的节点包上建立 MagnetoCorp 的应用程序，以此来提升开发的质量和速度。考虑一下 `issue.js` 是如何纳入 `js-yaml`
[包装](https://www.npmjs.com/package/js-yaml) 来处理 YAML 网关连接配置文件的，或者 `issue.js` 是如何纳入 `fabric-network` [包装](https://www.npmjs.com/package/fabric-network) 来访问 `Gateway` 和 `Wallet` 类的：

```
(isabella)$ ls

```JavaScript
const yaml = require('js-yaml');
const { FileSystemWallet, Gateway } = require('fabric-network');
```

enrollUser.js 		node_modules	      	package.json
issue.js	      	package-lock.json
```

需要使用 `npm install` 命令来将这些包装从 [npm](https://www.npmjs.com/) 下载到本地文件系统中。按照惯例，必须将包装安装进一个相对于应用程序的 `/node_modules` 目录中，以供运行时使用。

Examine the `node_modules` directory to see the packages that have been
installed. There are lots, because `js-yaml` and `fabric-network` are themselves
built on other npm packages! Helpfully, the `package-lock.json`
[file](https://docs.npmjs.com/files/package-lock.json) identifies the exact
versions installed, which can prove invaluable if you want to exactly reproduce
environments; to test, diagnose problems or deliver proven applications for
example.

检查 `package.json` 文件来看看 `issue.js` 是如何通过识别包装来下载自己的准确版本的：

## Wallet

```json
  "dependencies": {
    "fabric-network": "~1.4.0",
    "fabric-client": "~1.4.0",
    "js-yaml": "^3.12.0"
  },
```

Isabella is almost ready to run `issue.js` to issue MagnetoCorp commercial paper
`00001`; there's just one remaining task to perform! As `issue.js` acts on
behalf of Isabella, and therefore MagnetoCorp, it will use identity from her
[wallet](../developapps/wallet.html) that reflects these facts. We now need to
perform this one-time activity of generating the appropriate X.509 credentials
to her wallet.

**npm** 版本控制功能非常强大；点击[这里](https://docs.npmjs.com/getting-started/semantic-versioning)可以了解更多相关信息。

The MagnetoCorp Certificate Authority running on PaperNet, `ca_org2`, has an
application user that was registered when the network was deployed. Isabella
can use the identity name and secret to generate the X.509 cryptographic material
for the `issue.js` application. The process of using a CA to generate client side
cryptographic material is referred to as **enrollment**. In a real word scenario,
a network operator would provide the name and secret of a client identity that
was registered with the CA to an application developer. The developer would then
use the credentials to enroll their application and interact with the network.

让我们使用 `npm install` 命令来安装这些包装，安装过程可能需要一分钟：

The `enrollUser.js` program uses the `fabric-ca-client` class to generate a private
and public key pair, and then issues a **Certificate Signing Request** to the CA.
If the identiy name and secret submitted by Isabella match the credentials
registered with the CA, the CA will issue and sign a certificate that encodes the
public key, establishing that Isabella belongs to MagnetoCorp. When the signing
request is complete, `enrollUser.js` stores the private key and signing certificate
in Isabella's wallet. You can examine the `enrollUser.js` file to learn more about
how the Node SDK uses the `fabric-ca-client` class to complete these tasks.

```
(magnetocorp user)$ cd commercial-paper/organization/magnetocorp/application/
(magnetocorp user)$ npm install

In Isabella's terminal window, run the `enrollUser.js` program to add identity
information to her wallet:

(           ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

```
(isabella)$ node enrollUser.js

看看这个命令是如何更新目录的：

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/magnetocorp/identity/user/isabella/wallet
Successfully enrolled client user "isabella" and imported it into the wallet
```

```
(magnetocorp user)$ ls

We can now turn our focus to the result of this program --- the contents of the
wallet which will be used to submit transactions to PaperNet:

addToWallet.js		node_modules	      	package.json
issue.js	      	package-lock.json
```

```
(isabella)$ ls ../identity/user/isabella/wallet/

检查 `node_modules` 目录，查看已经安装的包装。能看到很多已经安装了的包装，这是因为 `js-yaml` 和 `fabric-network` 本身都被搭建在其他 npm 包装中！ `package-lock.json`
[文件](https://docs.npmjs.com/files/package-lock.json) 能准确识别已安装的版本，如果你想精确地复制环境（以完成测试、诊断问题或者提交已验证的应用程序等任务）的话，那么这一点对你来说就极为重要。

isabella.id
```

## 钱包

Isabella can store multiple identities in her wallet, though in our example, she
only uses one. The `wallet` folder contains an `isabella.id` file that provides
the information that Isabella needs to connect to the network. Other identities
used by Isabella would have their own file. You can open this file to see the
identity information that `issue.js` will use on behalf of Isabella inside a JSON
file. The output has been formatted for clarity.
```
(isabella)$  cat ../identity/user/isabella/wallet/*

Isabella 马上就能够运行 `issue.js` 来发行 MagnetoCorp 商业票票据 `00001` 了；现在还剩最后一步！因为 `issue.js` 代表 Isabella，所以也就代表 MagnetoCorp， `issue.js` 将会使用 Isabella [钱包](../developapps/wallet.html)中反应以上事实的身份。现在我们需要执行这个一次性的活动，向 Isabella 的钱包中添 X.509 证书。 

{
  "credentials": {
    "certificate": "-----BEGIN CERTIFICATE-----\nMIICKTCCAdCgAwIBAgIQWKwvLG+sqeO3LwwQK6avZDAKBggqhkjOPQQDAjBzMQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMi5leGFtcGxlLmNvbTEcMBoGA1UEAxMTY2Eu\nb3JnMi5leGFtcGxlLmNvbTAeFw0yMDAyMDQxOTA5MDBaFw0zMDAyMDExOTA5MDBa\nMGwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T\nYW4gRnJhbmNpc2NvMQ8wDQYDVQQLEwZjbGllbnQxHzAdBgNVBAMMFlVzZXIxQG9y\nZzIuZXhhbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAT4TnTblx0k\ngfqX+NN7F76Me33VTq3K2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYl\nt20yU7n/53dbo00wSzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADArBgNV\nHSMEJDAigCDOCdm4irsZFU3D6Hak4+84QRg1N43iwg8w1V6DRhgLyDAKBggqhkjO\nPQQDAgNHADBEAiBhzKix1KJcbUy9ey5ulWHRUMbqdVCNHe/mRtUdaJagIgIgYpbZ\nXf0CSiTXIWOJIsswN4Jp+ZxkJfFVmXndqKqz+VM=\n-----END CERTIFICATE-----\n",
    "privateKey": "-----BEGIN PRIVATE KEY-----\nMIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQggs55vQg2oXi8gNi8\nNidE8Fy5zenohArDq3FGJD8cKU2hRANCAAT4TnTblx0kgfqX+NN7F76Me33VTq3K\n2NUWZRreoJzq6bAuvdDR+iFvVPKXbdORnVvRSATcXsYlt20yU7n/53db\n-----END PRIVATE KEY-----\n"
  },
  "mspId": "Org2MSP",
  "type": "X.509",
  "version": 1
}
```

在 Isabella 的终端窗口中运行 `addToWallet.js` 程序来把身份信息添加到她的钱包中：

In the file you can notice the following:

```
(isabella)$ node addToWallet.js

* a `"privateKey":` used to sign transactions on Isabella's behalf, but not
  distributed outside of her immediate control.

done
```

* a `"certificate":` which contains Isabella's public key and other X.509
  attributes added by the Certificate Authority at certificate creation. This
  certificate is distributed to the network so that different actors at different
  times can cryptographically verify information created by Isabella's private key.

虽然在我们的示例中 Isabella 只使用了  `User1@org.example.com` 这一个身份，但其实她可以在钱包中储存多个身份。目前与这个身份相关联的是基本网络，而不是更实际化的 PaperNet 配置，我们很快会更新此版教程。

You can Learn more about certificates [here](../identity/identity.html#digital-certificates). In practice, the
certificate file also contains some Fabric-specific metadata such as
Isabella's organization and role -- read more in the [wallet](../developapps/wallet.html) topic.

`addToWallet.js` 是一个简单的文件复制程序，你可以在闲暇时检查该程序。它把一个身份从基本网络样本上转移到 Isabella 的钱包中。让我们专注于该程序的结果，也就是将被用来向 `PaperNet` 提交交易的钱包的内容：

## Issue application

```
(isabella)$ ls ../identity/user/isabella/wallet/

Isabella can now use `issue.js` to submit a transaction that will issue
MagnetoCorp commercial paper `00001`:

User1@org1.example.com
```

```
(isabella)$ node issue.js

看看目录结构如何映射 `User1@org1.example.com` 身份—— Isabella 使用的其他身份都会有自己的文件夹。在该目录中你会找到 `issue.js` 将代表 `isabella` 使用的身份信息：

Connect to Fabric gateway.
Use network channel: mychannel.
Use org.papernet.commercialpaper smart contract.
Submit commercial paper issue transaction.
Process issue transaction response.{"class":"org.papernet.commercialpaper","key":"\"MagnetoCorp\":\"00001\"","currentState":1,"issuer":"MagnetoCorp","paperNumber":"00001","issueDateTime":"2020-05-31","maturityDateTime":"2020-11-30","faceValue":"5000000","owner":"MagnetoCorp"}
MagnetoCorp commercial paper : 00001 successfully issued for value 5000000
Transaction complete.
Disconnect from Fabric gateway.
Issue program complete.
```

```
(isabella)$ ls ../identity/user/isabella/wallet/User1@org1.example.com

The `node` command initializes a Node.js environment, and runs `issue.js`. We
can see from the program output that MagnetoCorp commercial paper 00001 was
issued with a face value of 5M USD.

User1@org1.example.com      c75bd6911a...-priv      c75bd6911a...-pub
```

As you've seen, to achieve this, the application invokes the `issue` transaction
defined in the `CommercialPaper` smart contract within `papercontract.js`.
The smart contract interacts with the ledger via the
Fabric APIs, most notably `putState()` and `getState()`, to represent the new
commercial paper as a vector state within the world state. We'll see how this
vector state is subsequently manipulated by the `buy` and `redeem` transactions
also defined within the smart contract.

注意：

All the time, the underlying Fabric SDK handles the transaction endorsement,
ordering and notification process, making the application's logic
straightforward; the SDK uses a [gateway](../developapps/gateway.html) to
abstract away network details and
[connectionOptions](../developapps/connectoptions.html) to declare more advanced
processing strategies such as transaction retry.

* 使用秘钥 `c75bd6911a...-priv` 代表 Isabella 来签名交易，但始终把这个秘钥置于 Isabella 的控制之内。

Let's now follow the lifecycle of MagnetoCorp 00001 by switching our emphasis
to an employee of DigiBank, Balaji, who will buy the commercial paper using a
DigiBank application.

* 公钥 `c75bd6911a...-pub` 与 Isabella 的私钥有密码联系，并且该公钥完全包含在 Isabella 的 X.509 证书里。

## Digibank applications

* 在证书生成阶段，证书授权中心添加了 `User1@org.example.com` 证书，其中包含了Isabella的公钥和其他 X.509 属性。该证书被分布至网络中，这样一来，不同操作者就能够在不同时间内对 Isabella 的私钥生成的信息进行密码验证。
  
  点击[此处](https://hyperledger-fabric.readthedocs.io/en/latest/identity/identity.html#digital-certificates)获取更多信息。在实践中，证书文档还包含一些 Fabric 专门的元数据，例如 Isabella 的组织和角色——在[钱包](../developapps/wallet.html)主题阅读更多内容。

Balaji uses DigiBank's `buy` application to submit a transaction to the ledger
which transfers ownership of commercial paper `00001` from MagnetoCorp to
DigiBank. The `CommercialPaper` smart contract is the same as that used by
MagnetoCorp's application, however the transaction is different this time --
it's `buy` rather than `issue`. Let's examine how DigiBank's application works.

## 发行应用

Open a separate terminal window for Balaji. In `fabric-samples`, change to the
DigiBank application directory that contains the application, `buy.js`, and open
it with your editor:

Isabella 现在可以用 `issue.js` 来提交一项交易，该交易将发行 MagnetoCorp 商业票据 `00001`：

```
(balaji)$ cd commercial-paper/organization/digibank/application/
(balaji)$ code buy.js
```

```
(isabella)$ node issue.js

As you can see, this directory contains both the `buy` and `redeem` applications
that will be used by Balaji.

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


`node` 命令初始化一个 node.js 环境，并运行 `issue.js`。从程序输出我们能看到，系统发行了一张 MagnetoCorp 商业票据 00001，面值为 500 万美元。

![commercialpaper.vscode3](./commercial_paper.diagram.12.png) *DigiBank's
commercial paper directory containing the `buy.js` and `redeem.js`
applications.*

如您所见，为实现这一点，应用程序调用了 `papercontract.js` 中 `CommercialPaper` 智能合约里定义的 `issue` 交易。MagnetoCorp 管理员已经在网络上安装并实例化了 `CommercialPaper` 智能合约。在世界状态里作为一个矢量状态来代表新的商业票据的是通过 Fabric 应用程序编码端口(API)来与账本交互的智能合约，其中最显著的 API 是 `putState()` 和 `getState()`。我们即将看到该矢量状态在随后是如何被 `buy` 和 `redeem` 交易来操作的，这两项交易同样也是定义在那个智能合约中。

DigiBank's `buy.js` application is very similar in structure to MagnetoCorp's
`issue.js` with two important differences:

潜在的 Fabric 软件开发包（SDK）一直都在处理交易的背书、排序和通知流程，使得应用程序的逻辑变得简单明了； SDK 用[网关](../developapps/gateway.html)提取出网络细节信息和[连接选项](../developapps/connectoptions.html) ，以此来声明更先进的流程策略，如交易重试。


现在让我们将重点转换到 DigiBank（将购买商业票据），以遵循 MagnetoCorp `00001` 的生命周期。

  * **Identity**: the user is a DigiBank user `Balaji` rather than MagnetoCorp's
    `Isabella`

## 像 DigiBank 一样工作

    ```JavaScript
    const wallet = await Wallets.newFileSystemWallet('../identity/user/balaji/wallet');
    ```

既然 MagnetoCorp 已经发行了商业票据 `00001` ，现在让我们转换身份，作为 DigiBank 的雇员与 PaperNet 交互。首先，我们将作为一个管理员，生成一个操作台，该操作台是被用来与 PaperNet 交互的。随后我们将作为终端用户 Balaji，利用 Digibank 的 `buy` 交易来购买商业票据 `00001` ，从而将进程转换到其生命周期的下一阶段。

    See how the application uses the `balaji` wallet when it connects to the
    PaperNet network channel. `buy.js` selects a particular identity within
    `balaji` wallet.

![commercialpaper.workdigi](./commercial_paper.diagram.5.png) *DigiBank管理员和应用程序与 PaperNet 网络交互。*


因为教程目前使用的是 PaperNet 基本网络，所以网络配置非常简单。管理员使用的操作台与 MagnetoCorp 的相似，但操作台是为 Digibank 的文件系统配置的。同样地，Digibank 终端用户将使用和 MagnetoCorp 应用程序调取相同智能合约的应用程序，尽管它们包含了 Digibank 专门的逻辑和配置。无论受哪项交易调用，总是智能合约捕获了共享的商业流程，也总是账本维持了共享的商业数据。

  * **Transaction**: the invoked transaction is `buy` rather than `issue`

让我们打开另外一个终端窗口来让 DigiBank 管理员与 PaperNet 交互。 在 `fabric-samples` 中：

    ```JavaScript
    const buyResponse = await contract.submitTransaction('buy', 'MagnetoCorp', '00001', ...);
    ```

```
(digibank admin)$ cd commercial-paper/organization/digibank/configuration/cli/
(digibank admin)$ docker-compose -f docker-compose.yml up -d cliDigiBank

    A `buy` transaction is submitted with the values `MagnetoCorp`, `00001`, ...,
    that are used by the `CommercialPaper` smart contract class to transfer
    ownership of commercial paper `00001` to DigiBank.

(...)
Creating cliDigiBank ... done
```

Feel free to examine other files in the `application` directory to understand
how the application works, and read in detail how `buy.js` is implemented in
the application [topic](../developapps/application.html).

该 docker 容器现在可供 Digibank 管理员来与网络进行交互：

## Run as DigiBank

```(digibank admin)$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORT         NAMES
858c2d2961d4        hyperledger/fabric-tools         "/bin/bash"              18 seconds ago      Up 18 seconds                    cliDigiBank
```

The DigiBank applications which buy and redeem commercial paper have a very
similar structure to MagnetoCorp's issue application. Therefore, let’s install
their dependencies and set up Balaji's wallet so that he can use these
applications to buy and redeem commercial paper.

在此教程中，你将使用名为 `cliDigiBank` 的命令行容器来代表 Digibank 与网络进行交互。我们尚未展示所有的 docker 容器，在现实中，DigiBank 用户只能看到它们有访问权限的网络组件（Peer 节点，排序节点和证书授权中心）。

Like MagnetoCorp, Digibank must the install the required application packages
using the ``npm install`` command, and again, this make take a short time to
complete.

因为 PaperNet 网络配置十分简单，所以目前在此教程中 Digibank 管理员的任务并不多。让我们把注意力转向 Balaji。

In the DigiBank administrator window, install the application dependencies:

## Digibank应用

```
(digibank admin)$ cd commercial-paper/organization/digibank/application/
(digibank admin)$ npm install

Balaji 使用 DigiBank 的 `buy` 应用程序来向账本提交一项交易，该账本将商业票据 `00001` 的所属权从 MagnetoCorp 转向 DigiBank。 `CommercialPaper` 智能合约与 MagnetoCorp 应用程序使用的相同，但是此次的交易不同，是 `buy` 交易而不是 `issue` 交易。让我们检查一下 DigiBank 的应用程序是怎样工作的。 

(            ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

为 Balaji 打开另一个终端窗口。 在 `fabric-samples` 中，切换到包含 `buy.js` 应用程序的 DigiBank 应用程序目录，并用编辑器打开该目录：

In Balaji's command window, run the `enrollUser.js` program to generate a
certificate and private key and them to his wallet:
```
(balaji)$ node enrollUser.js

```
(balaji)$ cd commercial-paper/organization/digibank/application/
(balaji)$ code buy.js
```

Wallet path: /Users/nikhilgupta/fabric-samples/commercial-paper/organization/digibank/identity/user/balaji/wallet
Successfully enrolled client user "balaji" and imported it into the wallet
```

如你所见，该目录同时包含了 Balaji 将使用的 `buy` 和 `redeem` 应用程序 。

The `addToWallet.js` program has added identity information for `balaji`, to his
wallet, which will be used by `buy.js` and `redeem.js` to submit transactions to
`PaperNet`.

![commercialpaper.vscode3](./commercial_paper.diagram.12.png) *DigiBank 的商业票据目录包含 `buy.js` 和 `redeem.js` 应用程序。*

Like Isabella, Balaji can store multiple identities in his wallet, though in our
example, he only uses one. His corresponding id file at
`digibank/identity/user/balaji/wallet/balaji.id` is very similar Isabella's ---
feel free to examine it.

DigiBank 的 `buy.js` 应用程序在结构上与 MagnetoCorp的
`issue.js` 十分相似，但存在两个重要的差异：

## Buy application


Balaji can now use `buy.js` to submit a transaction that will transfer ownership
of MagnetoCorp commercial paper 00001 to DigiBank.

  * **身份**：用户是 DigiBank 的用户 `Balaji` 而不是MagnetoCorp的 `Isabella`
    
    ```JavaScript
    `const wallet = new FileSystemWallet('../identity/user/balaji/wallet');`
    ```
    
看看应用程序在连接到 PaperNet 网络上时是如何使用 `balaji` 钱包的。`buy.js` 在 `balaji` 钱包里选择一个特定的身份。

Run the `buy` application in Balaji's window:


```
(balaji)$ node buy.js

  * **交易**：被调用的交易是 `buy` 而不是 `issue`

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

    ```JavaScript
    `const buyResponse = await contract.submitTransaction('buy', 'MagnetoCorp', '00001'...);`
    ```

You can see the program output that MagnetoCorp commercial paper 00001 was
successfully purchased by Balaji on behalf of DigiBank. `buy.js` invoked the
`buy` transaction defined in the `CommercialPaper` smart contract which updated
commercial paper `00001` within the world state using the `putState()` and
`getState()` Fabric APIs. As you've seen, the application logic to buy and issue
commercial paper is very similar, as is the smart contract logic.

    提交一项 `buy` 交易，其值为 `MagnetoCorp`, `00001`...， `CommercialPaper` 智能合约类使用这些值来将商业票据 `00001` 的所属权转换成 DigiBank。

## Redeem application

欢迎检查 `application` 目录下的其他文档来理解应用程序 的工作原理，并仔细阅读应用程序[主题](../developapps/application.html)中关于如何实现 `buy.js` 的内容。

The final transaction in the lifecycle of commercial paper 00001 is for
DigiBank to redeem it with MagnetoCorp. Balaji uses `redeem.js` to submit a
transaction to perform the redeem logic within the smart contract.

## 像 DigiBank 一样运行

Run the `redeem` transaction in Balaji's window:

负责购买和赎回商业票据的 DigiBank 应用程序的结构和 MagnetoCorp 的发行交易十分相似。所以，我们来安装这些应用程序 的依赖项，并搭建 Balaji 的钱包，这样一来，Balaji 就能使用这些应用程序购买和赎回商业票据。 

```
(balaji)$ node redeem.js

和 MagnetoCorp 一样， Digibank 必须使用 `npm install` 命令来安装规定的应用包，同时，安装时间也很短。

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

在DigiBank 管理员窗口安装应用程序依赖项： 

Again, see how the commercial paper 00001 was successfully redeemed when
`redeem.js` invoked the `redeem` transaction defined in `CommercialPaper`.
Again, it updated commercial paper `00001` within the world state to reflect
that the ownership returned to MagnetoCorp, the issuer of the paper.

```
(digibank admin)$ cd commercial-paper/organization/digibank/application/
(digibank admin)$ npm install

## Clean up

(            ) extract:lodash: sill extract ansi-styles@3.2.1
(...)
added 738 packages in 46.701s
```

When you are finished using the Commercial Paper tutorial, you can use a script
to clean up your environment. Use a command window to navigate back to the root
directory of the commercial paper sample:
```
cd fabric-samples/commercial-paper
```
You can then bring down the network with the following command:
```
./network-clean.sh
```
This command will bring down the peers, CouchDB containers, and ordering node of the network, in addition to the logspout tool. It will also remove the identities that we created for Isabella and Balaji. Note that all of the data on the ledger will be lost. If you want to go through the tutorial again, you will start from a clean initial state.

在 Balaji 的终端窗口运行 `addToWallet.js` 程序，把身份信息添加到他的钱包中：

## Further reading

```
(balaji)$ node addToWallet.js

To understand how applications and smart contracts shown in this tutorial work
in more detail, you'll find it helpful to read
[Developing Applications](../developapps/developing_applications.html). This
topic will give you a fuller explanation of the commercial paper scenario, the
PaperNet business network, its actors, and how the applications and smart
contracts they use work in detail.

done
```

Also feel free to use this sample to start creating your own applications and
smart contracts!

`addToWallet.js` 程序为 `balaji` 将其身份信息添加到他的钱包中， `buy.js` 和 `redeem.js` 将使用这些身份信息来向  `PaperNet` 提交交易。

虽然在我们的示例中，Balaji 只使用了`Admin@org.example.com` 这一个身份，但是和 Isabella 一样， 他也可以在钱包中储存多个身份。`digibank/identity/user/balaji/wallet/Admin@org1.example.com` 中包含的 Balaji 的相应钱包结构与 Isabella 的十分相似，欢迎对其进行检查。

## 购买应用

Balaji 现在可以使用 `buy.js` 来提交一项交易，该交易将会把 MagnetoCorp 商业票据 `00001` 的所属权转换成 DigiBank。

在 Balaji 的窗口运行 `buy` 应用程序： 

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

你可看到程序输出为：Balaji 已经代表 DigiBank 成功购买了 MagnetoCorp 商业票据 00001。 `buy.js` 调用了 `CommercialPaper` 智能合约中定义的 `buy` 交易，该智能合约使用 Fabric 应用程序编程接口（API） `putState()` 和 `getState()` 在世界状态中更新了商业票据 `00001` 。如您所见，就智能合约的逻辑来说，购买和发行商业票据的应用程序逻辑彼此十分相似。

## 收回应用

商业票据 `00001` 生命周期的最后一步交易是 DigiBank 从 MagnetoCorp 那里收回商业票据。Balaji 使用 `redeem.js` 提交一项交易来执行智能合约中的收回逻辑。

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

要想更深入地理解以上教程中所介绍的应用程序和智能合约的工作原理，可以参照 [开发应用程序](../developapps/developing_applications.html)。该主题将为您详细介绍商业票据场景、`PaperNet` 商业网络，网络操作者以及它们所使用的应用程序和智能合约的工作原理。

欢迎使用该样本来开始创造你自己的应用程序和智能合约！
