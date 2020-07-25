构建你的第一个网络
=================================
Building Your First Network
===========================

.. note:: 本文内容已经过验证，它可以在最新稳定版的 docker 镜像和 tar 包中的提供的预编译的工具下工作。如果你使用 master 分支下的镜像或者工具使用这些命令，你可能会遇到配置或者 panic 错误。

.. note:: The Build your first network (BYFN) tutorial has been removed.
   If you are getting started with Hyperledger Fabric and would like to deploy
   a basic network, see :doc:`test_network`.
   If you are deploying Fabric in production, see the guide for :doc:`deployment_guide_overview`.

在构建你的第一个网络（BYFN）场景中，提供了一个包含两个组织的 Hyperledger Fabric 网络，每个组织包含两个 Peer 节点。它也默认会部署一个 Raft 排序服务。

   You can still find the BYFN tutorial in earlier Fabric documentation versions:

安装准备
---------------------

   - `Fabric 2.1 <https://hyperledger-fabric.readthedocs.io/en/release-2.1/build_network.html>`_
   - `Fabric 1.4 <https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html>`_

如果你之前没有操作过，在我们开始之前，你应该检查你将要开发区块链应用或者操作 Hyperledger Fabric 的平台上是否安装了全部的 :doc:`prereqs`。


你还需要 :doc:`install` 。``fabric-samples`` 仓库中包含了许多示例。我们将使用 ``first-network`` 作为例子。现在我们一起打开这个子目录。


.. code:: bash

  cd fabric-samples/first-network

.. note:: 这个文档里提供的命令 **必须** 在你克隆的 ``fabric-samples`` 项目的子目录 ``first-network`` 里运行。如果你选择从其他位置运行命令，提供的脚本将无法找到二进制文件。

想要现在运行吗？
-------------------

我们提供了一个有完整注释的脚本——``byfn.sh``，它可以通过镜像快速启动一个 Hyperledger Fabric 网络，这个网络由代表两个组织的四个 Peer 节点和一个 Raft 排序服务组成。它还将启动一个容器用于运行一个将 Peer 节点加入通道，部署并且实例化链码以及驱动已经部署的链码执行交易的脚本。

以下是该脚本 ``byfn.sh`` 的帮助文档：

.. code:: bash

  Usage:
  byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-o <consensus-type>] [-i <imagetag>] [-v]"
    <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'"
      - 'up' - bring up the network with docker-compose up"
      - 'down' - clear the network with docker-compose down"
      - 'restart' - restart the network"
      - 'generate' - generate required certificates and genesis block"
      - 'upgrade'  - upgrade the network from version 1.3.x to 1.4.0"
    -c <channel name> - channel name to use (defaults to \"mychannel\")"
    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
    -d <delay> - delay duration in seconds (defaults to 3)"
    -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)"
    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
    -l <language> - the chaincode language: golang (default), javascript, or java"
    -a - launch certificate authorities (no certificate authorities are launched by default)
    -n - do not deploy chaincode (abstore chaincode is deployed by default)
    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
    -v - verbose mode"
  byfn.sh -h (print this message)"

  Typically, one would first generate the required certificates and
  genesis block, then bring up the network. e.g.:"

    byfn.sh generate -c mychannel"
    byfn.sh up -c mychannel -s couchdb"
    byfn.sh up -c mychannel -s couchdb -i 1.4.0"
    byfn.sh up -l javascript"
    byfn.sh down -c mychannel"
    byfn.sh upgrade -c mychannel"

  Taking all defaults:"
  	byfn.sh generate"
  	byfn.sh up"
  	byfn.sh down"

如果你不设置启动参数，脚本会使用默认值。

生成网络构件
^^^^^^^^^^^^^^^^^^^^^^^^^^

准备好了没？OK，执行下面的命令：


.. code:: bash

  ./byfn.sh generate

你会看到一个简要说明，同时会有一个命令行提示 yes/no。输入 Y 或者回车键来继续执行。

.. code:: bash

  Generating certs and genesis block for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
  Continue? [Y/n] y
  proceeding ...
  /Users/xxx/dev/fabric-samples/bin/cryptogen

  ##########################################################
  ##### Generate certificates using cryptogen tool #########
  ##########################################################
  org1.example.com
  2017-06-12 21:01:37.334 EDT [bccsp] GetDefault -> WARN 001 Before using BCCSP, please call InitFactories(). Falling back to bootBCCSP.
  ...

  /Users/xxx/dev/fabric-samples/bin/configtxgen
  ##########################################################
  #########  Generating Orderer Genesis block ##############
  ##########################################################
  2017-06-12 21:01:37.558 EDT [common/configtx/tool] main -> INFO 001 Loading configuration
  2017-06-12 21:01:37.562 EDT [msp] getMspConfig -> INFO 002 intermediate certs folder not found at [/Users/xxx/dev/byfn/crypto-config/ordererOrganizations/example.com/msp/intermediatecerts]. Skipping.: [stat /Users/xxx/dev/byfn/crypto-config/ordererOrganizations/example.com/msp/intermediatecerts: no such file or directory]
  ...
  2017-06-12 21:01:37.588 EDT [common/configtx/tool] doOutputBlock -> INFO 00b Generating genesis block
  2017-06-12 21:01:37.590 EDT [common/configtx/tool] doOutputBlock -> INFO 00c Writing genesis block

  #################################################################
  ### Generating channel configuration transaction 'channel.tx' ###
  #################################################################
  2017-06-12 21:01:37.634 EDT [common/configtx/tool] main -> INFO 001 Loading configuration
  2017-06-12 21:01:37.644 EDT [common/configtx/tool] doOutputChannelCreateTx -> INFO 002 Generating new channel configtx
  2017-06-12 21:01:37.645 EDT [common/configtx/tool] doOutputChannelCreateTx -> INFO 003 Writing new channel tx

  #################################################################
  #######    Generating anchor peer update for Org1MSP   ##########
  #################################################################
  2017-06-12 21:01:37.674 EDT [common/configtx/tool] main -> INFO 001 Loading configuration
  2017-06-12 21:01:37.678 EDT [common/configtx/tool] doOutputAnchorPeersUpdate -> INFO 002 Generating anchor peer update
  2017-06-12 21:01:37.679 EDT [common/configtx/tool] doOutputAnchorPeersUpdate -> INFO 003 Writing anchor peer update

  #################################################################
  #######    Generating anchor peer update for Org2MSP   ##########
  #################################################################
  2017-06-12 21:01:37.700 EDT [common/configtx/tool] main -> INFO 001 Loading configuration
  2017-06-12 21:01:37.704 EDT [common/configtx/tool] doOutputAnchorPeersUpdate -> INFO 002 Generating anchor peer update
  2017-06-12 21:01:37.704 EDT [common/configtx/tool] doOutputAnchorPeersUpdate -> INFO 003 Writing anchor peer update

第一步为我们的各种网络实体生成证书和秘钥。创世区块 ``genesis block`` 用于引导排序服务，也包含了一组配置 :ref:`Channel` 所需要的配置交易集合。

启动网络
^^^^^^^^^^^^^^^^^^^^

接下来，你可以用下面的命令启动网络：

.. code:: bash

  ./byfn.sh up

上面的命令会编译 Golang 智能合约的镜像并且启动相应的容器。Go 语言是默认的链码语言，但是它也支持
`Node.js <https://fabric-shim.github.io/>`_ 和 `Java <<https://hyperledger.github.io/fabric-chaincode-java/>`_ 的链码。如果你想要在这个教程里运行 node 链码，你可以使用下面的命令：

.. code:: bash

  # we use the -l flag to specify the chaincode language
  # forgoing the -l flag will default to Golang

  ./byfn.sh up -l javascript

.. note:: 更多关于 Node.js shim 的信息，请查看这个 `文档 <https://fabric-shim.github.io/fabric-shim.ChaincodeInterface.html>`_ 。

.. note:: 更多关于 Java shim 的信息，请查看这个 `文档 <https://hyperledger.github.io/fabric-chaincode-java/master/api/org/hyperledger/fabric/shim/Chaincode.html>`_ 。

要让示例运行 Java 链码，你需要指定 ``-l java``:

.. code:: bash

  ./byfn.sh up -l java

.. note:: 不要同时运行这两个命令。除非你停止并重新创建了网络，否则只能尝试一种语言。

您将被提示要继续或中止。输入 ``y`` 或者按下回车键来继续执行：

.. code:: bash

  Starting for channel 'mychannel' with CLI timeout of '10' seconds and CLI delay of '3' seconds
  Continue? [Y/n]
  proceeding ...
  Creating network "net_byfn" with the default driver
  Creating peer0.org1.example.com
  Creating peer1.org1.example.com
  Creating peer0.org2.example.com
  Creating orderer.example.com
  Creating peer1.org2.example.com
  Creating cli


   ____    _____      _      ____    _____
  / ___|  |_   _|    / \    |  _ \  |_   _|
  \___ \    | |     / _ \   | |_) |   | |
   ___) |   | |    / ___ \  |  _ <    | |
  |____/    |_|   /_/   \_\ |_| \_\   |_|

  Channel name : mychannel
  Creating channel...

日志会从那里继续。这一步会启动所有的容器，然后启动一个完整的 end-to-end 应用场景。完成后，它应该在您的终端窗口中显示以下内容:

.. code:: bash

    Query Result: 90
    2017-05-16 17:08:15.158 UTC [main] main -> INFO 008 Exiting.....
    ===================== Query successful on peer1.org2 on channel 'mychannel' =====================

    ===================== All GOOD, BYFN execution completed =====================


     _____   _   _   ____
    | ____| | \ | | |  _ \
    |  _|   |  \| | | | | |
    | |___  | |\  | | |_| |
    |_____| |_| \_| |____/

你可以滚动这些日志去查看各种交易。如果你没有获得这个结果，请移步疑难解答部分 :ref:`Troubleshoot` ，看看我们是否可以帮助你发现问题。

关闭网络
^^^^^^^^^^^^^^^^^^^^^^

最后，让我们把他停下来，这样我们可以一步步探索网络设置。接下来的命令会结束掉你所有的容器，移除加密的材料和四个构件，并且从 Docker 仓库删除链码镜像。

.. code:: bash

  ./byfn.sh down

您将再一次被提示要继续或中止，输入 ``y`` 或者按下回车键来继续执行：

.. code:: bash

  Stopping with channel 'mychannel' and CLI timeout of '10'
  Continue? [Y/n] y
  proceeding ...
  WARNING: The CHANNEL_NAME variable is not set. Defaulting to a blank string.
  WARNING: The TIMEOUT variable is not set. Defaulting to a blank string.
  Removing network net_byfn
  468aaa6201ed
  ...
  Untagged: dev-peer1.org2.example.com-mycc-1.0:latest
  Deleted: sha256:ed3230614e64e1c83e510c0c282e982d2b06d148b1c498bbdcc429e2b2531e91
  ...

如果你想要了解更多关于底层工具和引导机制的信息，请继续阅读。在接下来的章节，我们将浏览构建一个功能完整的 Hyperledger Fabric 网络的各个步骤和要求。

.. note:: 下面列出的手动步骤假设 ``cli`` 容器中的 ``FABRIC_LOGGING_SPEC`` 设置为 ``DEBUG`` 。你可以通过修改 ``first-network`` 中的 ``docker-compose-cli.yaml`` 文件来设置。例如：

          .. code::

            cli:
              container_name: cli
              image: hyperledger/fabric-tools:$IMAGE_TAG
              tty: true
              stdin_open: true
              environment:
                - GOPATH=/opt/gopath
                - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
                - FABRIC_LOGGING_SPEC=DEBUG
                #- FABRIC_LOGGING_SPEC=INFO

密钥生成器
----------------

我们将使用 ``cryptogen`` 工具为我们的网络实体生成各种加密材料（ x509 证书和签名秘钥）。这些证书是身份的代表，在实体之间通信和交易的时候，它们允许对身份验证进行签名和验证。

它是怎么工作的？
^^^^^^^^^^^^^^^^^

Cryptogen 通过一个包含网络拓扑的文件 ``crypto-config.yaml``，为所有组织和属于这些组织的组件生成一组证书和秘钥。每一个组织被分配一个唯一的根证书（``ca-cert``），它绑定该组织的特定组件（Peer 节点和排序节点）。通过为每个组织分配一个唯一的 CA 证书，我们模拟了一个典型的网络，网络中的成员可以使用它自己的证书授权中心。Fabric 中的事务和通信由一个实体的私钥（``keystore``）签名，然后通过公钥（``signcerts``）验证。

在这个文件里你会发现一个 ``count`` 变量。我们通过它来指定每个组织的 Peer 节点数量。在我们的案例里每个组织有两个 Peer 节点。我们现在不会深入研究 `x.509 证书和公钥结构 <https://en.wikipedia.org/wiki/Public_key_infrastructure>`__ 的细节。如果有兴趣，你可以仔细阅读一下这些主题。

在我们运行 ``cryptogen`` 工具之后，生成的证书和密钥将保存到一个名为 ``crypto-config`` 的文件夹中。注意， ``crypto-config.yaml`` 文件在排序组织中设置了五个排序节点。``cryptogen`` 会为这五个排序节点生成证书。这些排序节点将使用 etcdraft 排序服务实现并用来创建系统通道和 ``mychannel``。

配置交易生成器
-----------------------------------

``configtxgen`` 工具用来创建四个配置构件:

  * 排序节点的 ``创世区块``,
  * 通道 ``配置交易``,
  * 两个 ``锚节点交易``，一个对应一个 Peer 组织。

有关此工具的完整说明，请参阅 :doc:`commands/configtxgen`

排序区块是排序服务的创世区块，通道配置交易在通道创建的时候广播给排序服务。锚节点交易，指定了每个组织在此通道上的锚节点。

它是怎么工作的？
^^^^^^^^^^^^^^^^^

Configtxgen 使用一个文件——``configtx.yaml``，这个文件包含了一个示例网络的定义。它拥有三个成员：一个排序组织（``OrdererOrg``）和两个 Peer 组织(``Org1`` & ``Org2``)，这两个 Peer 组织每个都管理和维护两个 Peer 节点。这个文件还定义了一个联盟——``SampleConsortium``，包含了我们的两个 Peer 组织。注意一下文件中 “Profiles” 部分的最下边。你会看到我们有一些特别的标题。其中有一些值得注意：

* ``SampleMultiNodeEtcdRaft``: 为 Raft 排序服务生成创世区块。只有将 ``-o`` 参数指定为 ``etcdraft`` 时才可用。

* ``TwoOrgsChannel``: 为我们的通道 ``mychannel`` 生成创世区块。

这些标题很重要，因为在我们创建网络各项构件的时侯，需要将它们将作为参数传入。

.. note:: 注意我们的 ``SampleConsortium`` 在系统级配置项中定义，并且在通道级的配置项中引用。通道存在于联盟的范围内，所有的联盟必须定义在整个网络范围内。

该文件还包含两个值得注意的附加规范。第一，我们为每个组织指定了锚节点（``peer0.org1.example.com`` & ``peer0.org2.example.com``）。第二，我们为每个成员指定 MSP 文件位置，进而我们可以在排序节点的创世区块中存储每个组织的根证书。这是一个关键概念。现在每个和排序服务通信的网络实体都可以验证它们的数字签名。

运行工具
-------------

你可以用 ``configtxgen`` 和 ``cryptogen`` 命令来手动生成证书/密钥和各种配置。或者，你可以尝试使用 byfn.sh 脚本来完成你的目标。

手动生成构件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

你可以参考 byfn.sn 脚本中的 ``generateCerts`` 函数，这个函数包含了生成 ``crypto-config.yaml`` 中所定义的证书的必要命令，这些证书将被作为你的网络配置。然而,为了方便起见，我们在这里也提供一个参考。

首先，让我们来运行 ``cryptogen`` 工具。这个二进制文件存放在 ``bin`` 文件目录下，所以我们需要提供工具所在的相对路径。

.. code:: bash

    ../bin/cryptogen generate --config=./crypto-config.yaml

你会在你的终端中看到下面的内容：

.. code:: bash

  org1.example.com
  org2.example.com

证书和秘钥（例如 MSP 材料）将会保存在 ``first-network`` 目录的 ``crypto-config`` 文件夹中。

接下来，我们需要告诉 ``configtxgen`` 工具去哪儿寻找它需要的 ``configtx.yaml`` 文件。我们会告诉它在当前的工作目录：

.. code:: bash

    export FABRIC_CFG_PATH=$PWD

然后我们会调用 ``configtxgen`` 工具去创建排序通道创世区块：

.. code:: bash

  ../bin/configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

.. note:: 排序通道创世区块和其他生成的构件都保存在当前项目根目录 ``first-network`` 目录的 ``channel-artifacts`` 文件夹。上边命令中的 `channelID` 是系统通道的名字。

.. note:: The orderer genesis block and the subsequent artifacts we are about to create
          will be output into the ``channel-artifacts`` directory at the root of the
          ``first-network`` directory. The `channelID` in the above command is the
          name of the system channel.

.. _createchanneltx:

创建通道配置交易
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

接下来，我们需要去创建通道的交易构件。请确保替换 ``$CHANNEL_NAME`` 或者将 ``CHANNEL_NAME`` 设置为整个说明中可以使用的环境变量：

.. code:: bash

    # The channel.tx artifact contains the definitions for our sample channel

    export CHANNEL_NAME=mychannel  && ../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

注意，``TwoOrgsChannel`` 选项会使用你指定的排序服务配置为网络创建创世区块。

你会看到类似下边的输出：

.. code:: bash

  2017-10-26 19:24:05.324 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 002 Generating new channel configtx
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 003 Writing new channel tx

接下来，我们会为构建的通道上的 Org1 定义锚节点。请再次确认 ``$CHANNEL_NAME`` 已被替换或者设置了环境变量。终端输出类似通道交易构件：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

现在，我们将在同一个通道上为 Org2 定义锚节点：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

启动网络
-----------------

.. note:: 如果之前启动了 ``byfn.sh`` 示例，再继续之前确认你已经把这个测试网络关掉了（查看 `Bring Down the Network`_ ）。

我们将使用一个脚本启动我们的网络。docker-compose 文件关联了我们之前下载的镜像，然后通过我们之前生成的创世区块 ``genesis.block`` 引导排序节点。

我们要手动运行那些命令，目的是为了探索每个语法和调用的功能。

首先，启动我们的网络：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml up -d

如果你想要实时查看你的网络日志，请不要加 ``-d`` 标识。如果你想要查看日志流，你需要打开第二个终端来执行 CLI 调用。

.. _peerenvvars:

创建和加入通道
^^^^^^^^^^^^^^^^^^^^^

回想一下，我们在 :ref:`createchanneltx` 章节中使用 ``configtxgen`` 工具创建通道配置交易。你可以使用相同的方式创建额外的通道配置交易，使用 ``configtx.yaml`` 中相同或者不同的选项传给 ``configtxgen`` 工具。然后你可以重复在本章节中的过程在你的网络中创建其他通道。

我们可以使用 ``docker exec`` 输入 CLI 容器命令:

.. code:: bash

        docker exec -it cli bash

成功的话你会看到下面的输出：

.. code:: bash

        bash-5.0#

要想运行后边用于 ``peer0.org1.example.com`` 的 CLI 命令，我们需要使用下边的命令来设置四个环境变量。这些 ``peer0.org1.example.com`` 的环境变量已经在 CLI 容器中设置过了，所以不用再设置了。**但是**，如果你想向其他 Peer 节点或者排序节点发送调用，继续在 ``peer0.org1.example.com`` 的 CLI 容器中，但是在你发送任何 CLI 调用的时候都需要像下边的命令一样覆盖这些环境变量：

.. code:: bash

    # Environment variables for PEER0

    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

接下来，我们会把在 :ref:`createchanneltx` 章节中创建的通道配置交易配置（``channel.tx``）作为创建通道请求的一部分传递给排序节点。

我们使用 ``-c`` 标志指定通道的名称，``-f`` 标志指定通道配置交易，在这个例子中它是 ``channel.tx``，当然你也可以使用不同的名称挂载你自己的交易配置。我们将再次在 CLI 容器中设置 ``CHANNEL_NAME`` 环境变量，这样我们就不用显式的传递这个参数。通道的名称必须全部是消息字母，小于 250 个字符，并且匹配正则表达式 ``[a-z][a-z0-9.-]*`` 。

.. code:: bash

        export CHANNEL_NAME=mychannel

        # the channel.tx file is mounted in the channel-artifacts directory within your CLI container
        # as a result, we pass the full path for the file
        # we also pass the path for the orderer ca-cert in order to verify the TLS handshake
        # be sure to export or replace the $CHANNEL_NAME variable appropriately

        peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. note:: 注意 ``--cafile`` 会作为命令的一部分。这是排序节点的根证书的本地路径，允许我们去验证 TLS 握手。

这个命令返回一个创世区块，``<channel-ID.block>``。我们将会用它来加入通道。它包含了 ``channel.tx`` 中的配置信息。如果你没有修改默认的通道名称，命令会返回给你一个叫 ``mychannel.block`` 的 proto。

.. note:: 你将在 CLI 容器中继续执行这些手动命令的其余部分。当你的目标是 ``peer0.org1.example.com`` 节点之外的 peer 时，你必须记住用相应的环境变量作为所有命令的前言。

现在让我们把 ``peer0.org1.example.com`` 加入通道。

.. code:: bash

        # By default, this joins ``peer0.org1.example.com`` only
        # the <CHANNEL_NAME.block> was returned by the previous command
        # if you have not modified the channel name, you will join with mychannel.block
        # if you have created a different channel name, then pass in the appropriately named block

         peer channel join -b mychannel.block

你可以通过适当的修改在 :ref:`peerenvvars` 章节中的四个环境变量来让其他的节点加入通道。

不是加入每一个节点，我们只是简单的加入 ``peer0.org2.example.com`` 以便我们可以更新定义在通道中的锚节点。由于我们正在覆盖 CLI 容器中默认的环境变量，整个命令将会是这样：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:9051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

或者，您可以选择单独设置这些环境变量而不是传递整个字符串。设置完成后，只需再次执行 ``peer channel join`` 命令，然后 CLI 容器会代表 ``peer0.org2.example.com`` 起作用。

更新锚节点
^^^^^^^^^^^^^^^^^^^^^^^

接下来的命令是通道更新，它会传递到通道的定义中去。实际上，我们在通道创世区块的头部添加了额外的配置信息。注意我们没有编辑创世区块，但是简单的把将会定义锚节点的增量添加到了链中。

更新通道定义，将 Org1 的锚节点定义为 ``peer0.org1.example.com`` 。

.. code:: bash

  peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

现在更新通道定义，将 Org2 的锚节点定义为 ``peer0.org2.example.com`` 。与执行 Org2 节点的 ``peer channel join`` 命令相同，我们需要为这个命令配置合适的环境变量。

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:9051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. _install-define-chaincode:

安装和实例化链码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: 我们将利用现有的一个简单链码。要学习怎么编写你自己的链码，请参考 :doc:`chaincode4ade` 教程。

.. note:: These instructions use the Fabric chaincode lifecycle introduced in
          the v2.0 release. If you would like to use the previous lifecycle to
          install and instantiate a chaincode, visit the v1.4 version of the
          `Building your first network tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html>`__.

Applications interact with the blockchain ledger through ``chaincode``.
Therefore we need to install a chaincode on every peer that will execute and
endorse our transactions. However, before we can interact with our chaincode,
the members of the channel need to agree on a chaincode definition that
establishes chaincode governance.

We need to package the chaincode before it can be installed on our peers. For
each package you create, you need to provide a chaincode package label as a
description of the chaincode. Use the following commands to package a sample
Go, Node.js or Java chaincode.

**Golang**

.. code:: bash

    # before packaging Golang chaincode, vendoring Go dependencies is required like the following commands.
    cd /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/go
    GO111MODULE=on go mod vendor
    cd -

    # this packages a Golang chaincode.
    # make note of the --lang flag to indicate "golang" chaincode
    # for go chaincode --path takes the relative path from $GOPATH/src
    # The --label flag is used to create the package label
    peer lifecycle chaincode package mycc.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ --lang golang --label mycc_1

**Node.js**

.. code:: bash

    # this packages a Node.js chaincode
    # make note of the --lang flag to indicate "node" chaincode
    # for node chaincode --path takes the absolute path to the node.js chaincode
    # The --label flag is used to create the package label
    peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/javascript/ --lang node --label mycc_1

**Java**

.. code:: bash

    # this packages a java chaincode
    # make note of the --lang flag to indicate "java" chaincode
    # for java chaincode --path takes the absolute path to the java chaincode
    # The --label flag is used to create the package label
    peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/java/ --lang java --label mycc_1

Each of the above commands will create a chaincode package named ``mycc.tar.gz``,
which we can use to install the chaincode on our peers. Issue the following
command to install the package on peer0 of Org1.

.. code:: bash

    # this command installs a chaincode package on your peer
    peer lifecycle chaincode install mycc.tar.gz

A successful install command will return a chaincode package identifier. You
should see output similar to the following:

.. code:: bash

    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nEmycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173" >
    2019-03-13 13:48:53.691 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173

You can also find the chaincode package identifier by querying your peer for
information about the packages you have installed.

.. code:: bash

    # this returns the details of the chaincode packages installed on your peers
    peer lifecycle chaincode queryinstalled

The command above will return the same package identifier as the install command.
You should see output similar to the following:

.. code:: bash

      Get installed chaincodes on peer:
      Package ID: mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173, Label: mycc_1

We are going to need the package ID for future commands, so let's go ahead and
save it as an environment variable. Paste the package ID returned by the
`peer lifecycle chaincode queryinstalled` command into the command below. The
package ID may not be the same for all users, so you need to complete this step
using the package ID returned from your console.

.. code:: bash

   # Save the package ID as an environment variable.

   CC_PACKAGE_ID=mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173

``mycc`` 的背书策略被设定为需要 Org1 和 Org2 的节点都背书。所以，我们需要在 Org2 的节点上也安装链码。

为了执行在 Org2 上安装命令，需要修改以下四个环境变量：

.. code:: bash

   # Environment variables for PEER0 in Org2

   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   CORE_PEER_ADDRESS=peer0.org2.example.com:9051
   CORE_PEER_LOCALMSPID="Org2MSP"
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

现在在 Org2 peer0 上安装链码包。这些命令将安装链码并返回一些标识符，就像我们在 Org1 上执行的安装命令一样。

.. code:: bash

    # this installs a chaincode package on your peer
    peer lifecycle chaincode install mycc.tar.gz

After you install the package, you need to approve a chaincode definition
for your organization. The chaincode definition includes the important
parameters of chaincode governance, including the chaincode name and version.
The definition also includes the package identifier used to associate the
chaincode package installed on your peers with a chaincode definition approved
by your organization.

Because we set the environment variables to operate as Org2, we can use the
following command to approve a definition of the ``mycc`` chaincode for
Org2. The approval is distributed to peers within each organization, so
the command does not need to target every peer within an organization.

.. code:: bash

    # this approves a chaincode definition for your org
    # make note of the --package-id flag that provides the package ID
    # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

We could have provided a ``--signature-policy`` or ``--channel-config-policy``
argument to the command above to set the chaincode endorsement policy. The
endorsement policy specifies how many peers belonging to different channel
members need to validate a transaction against a given chaincode. Because we did
not set a policy, the definition of ``mycc`` will use the default endorsement
policy, which requires that a transaction be endorsed by a majority of channel
members present when the transaction is submitted. This implies that if new
organizations are added to or removed from the channel, the endorsement policy
is updated automatically to require more or fewer endorsements. In this tutorial,
the default policy will require an endorsement from a peer belonging to Org1
**AND** Org2 (i.e. two endorsements). See the :doc:`endorsement-policies`
documentation for more details on policy implementation.

All organizations need to agree on the definition before they can use the
chaincode. Modify the following four environment variables to operate as Org1:

.. code:: bash

    # Environment variables for PEER0

    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

You can now approve a definition for the ``mycc`` chaincode as Org1. Chaincode is
approved at the organization level. You can issue the command once even if you
have multiple peers.

.. code:: bash

    # this defines a chaincode for your org
    # make note of the --package-id flag that provides the package ID
    # use the --init-required flag to request the Init function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Once a sufficient number of channel members have approved a chaincode definition,
one member can commit the definition to the channel. By default a majority of
channel members need to approve a definition before it can be committed. It is
possible to check whether the chaincode definition is ready to be committed and
view the current approvals by organization by issuing the following query:

.. code:: bash

    # the flags used for this command are identical to those used for approveformyorg
    # except for --package-id which is not required since it is not stored as part of
    # the definition
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

The command will produce as output a JSON map showing if the organizations in the
channel have approved the chaincode definition provided in the checkcommitreadiness
command. In this case, given that both organizations have approved, we obtain:

.. code:: bash

    {
            "Approvals": {
                    "Org1MSP": true,
                    "Org2MSP": true
            }
    }

Since both channel members have approved the definition, we can now commit it to
the channel using the following command. You can issue this command as either
Org1 or Org2. Note that the transaction targets peers in Org1 and Org2 to
collect endorsements.

.. code:: bash

    # this commits the chaincode definition to the channel
    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

Invoking the chaincode
^^^^^^^^^^^^^^^^^^^^^^

After a chaincode definition has been committed to a channel, we are ready to
invoke the chaincode and start interacting with the ledger. We requested the
execution of the ``Init`` function in the chaincode definition using the
``--init-required`` flag. As a result, we need to pass the ``--isInit`` flag to
its first invocation and supply the arguments to the ``Init`` function. Issue the
following command to initialize the chaincode and put the initial data on the
ledger.

.. code:: bash

    # be sure to set the -C and -n flags appropriately
    # use the --isInit flag if you are invoking an Init function
    peer chaincode invoke -o orderer.example.com:7050 --isInit --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["Init","a","100","b","100"]}' --waitForEvent

The first invoke will start the chaincode container. We may need to wait for the
container to start. Node.js images will take longer.

Query
^^^^^

Let's query the chaincode to make sure that the container was properly started
and the state DB was populated. The syntax for query is as follows:

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

调用
^^^^^^

现在我们从 ``a`` 账户向 ``b`` 账户转账 10 。这个交易将会产生一个新的区块并更新状态数据库。
调用的语法是这样的：

.. code:: bash

  # be sure to set the -C and -n flags appropriately
  peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}' --waitForEvent

查询
^^^^^

我们来确认一下我们之前的调用正确执行了。我们为键 ``a`` 初始化一个 100 的值，
通过刚才的调用减少了 ``10``。这样查询出的值应该是 ``90``，查询的语法是这样的：

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

我们会看到下面的结果：

.. code:: bash

   Query Result: 90

安装链码到其他节点
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you want additional peers to interact with the ledger, then you will need to
join them to the channel and install the same chaincode package on the peers.
You only need to approve the chaincode definition once from your organization.
A chaincode container will be launched for each peer as soon as they try to
interact with that specific chaincode. Again, be cognizant of the fact that the
Node.js images will be slower to build and start upon the first invoke.

我们将在第三个节点上安装链码， Org2 的 peer1 。为了执行在 Org2 的 peer1 上的安装命令，需要改变以下四个环境变量：

.. code:: bash

   # Environment variables for PEER1 in Org2

   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   CORE_PEER_ADDRESS=peer1.org2.example.com:10051
   CORE_PEER_LOCALMSPID="Org2MSP"
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

Now install the ``mycc`` package on peer1 of Org2:

.. code:: bash

    # this command installs a chaincode package on your peer
    peer lifecycle chaincode install mycc.tar.gz

查询
^^^^^

让我们确认一下我们可以执行对 Org2 的 Peer1 的查询。我们把键 ``a`` 的值初始化为 ``100`` 而且上一个操作转移了 ``10`` 。所以对 ``a`` 的查询结果仍应该是 ``90`` 。

Org2 的 peer1 必须先加入通道才可以响应查询。下边的命令可以让它加入通道：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer1.org2.example.com:10051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

在加入通道的命令返回之后，查询就可以执行了。下边是执行查询的语法。

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

我们会看到下面的结果：

.. code:: bash

   Query Result: 90

If you received an error, it may be because it takes a few seconds for the
peer to join and catch up to the current blockchain height. You may
re-query as needed. Feel free to perform additional invokes as well.

.. _behind-scenes:

幕后发生了什么？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: 这些步骤描述了在 ``script.sh`` 脚本中的场景，它是由 ``./byfn.sh up`` 启动的。通过 ``./byfn.sh down`` 清除你的网络，确保此命令处于活动状态。然后用同样的 docker-compose 去再次启动你的网络。

-  脚本 ``script.sh`` 被保存在 CLI 容器中。这个脚本通过提供的通道名称和通道配置文件 channel.tx 来执行创建通道 ``createChannel`` 的命令。

-  ``createChannel`` 的输出是一个创世区块 —— ``<你的通道名>.block``，它被存储在节点文件系统上并包含有来自 channel.tx 的通道配置。

-  ``joinChannel`` 命令被所有的四个节点执行，作为之前产生创世区块的输入。这个命令指示那些节点去加入通道 ``<你的通道名>`` 并且通过 ``<你的通道名>.block`` 开始创建一条链。

-  现在我们有一个由四个节点，两个组织组成的通道，这是我们 ``TwoOrgsChannel`` 的结构。

-  ``peer0.org1.example.com`` 和 ``peer1.org1.example.com`` 属于 Org1;
   ``peer0.org2.example.com`` 和 ``peer1.org2.example.com`` 属于 Org2

-  这些关系在 ``crypto-config.yaml`` 中定义，MSP 的路径在我们的 docker compose 中指定。

-  Org1MSP（``peer0.org1.example.com``） 和 Org2MSP（``peer0.org2.example.com``） 的锚节点将会被更新。我们通过把 ``Org1MSPanchors.tx`` 和 ``Org2MSPanchors.tx`` 加上通道名称一起传给排序节点来做到这一点。

   -  链码 **abstore** 被安装在 ``peer0.org1.example.com`` 和 ``peer0.org2.example.com``

-  The chaincode is then separately approved by Org1 and Org2, and then committed
   on the channel. Since an endorsement policy was not specified, the channel's
   default endorsement policy of a majority of organizations will get utilized,
   meaning that any transaction must be endorsed by a peer tied to Org1 and Org2.

-  The chaincode Init is then called which starts the container for the target peer,
   and initializes the key value pairs associated with the chaincode.  The initial
   values for this example are ["a","100" "b","200"]. This first invoke results
   in a container by the name of ``dev-peer0.org2.example.com-mycc-1.0`` starting.

-  向 ``peer0.org2.example.com`` 发出针对键 “a” 的值的查询。在链码实例化的时候，为 Org2 peer0 启动了一个名为 ``dev-peer0.org2.example.com-mycc-1.0`` 的容器。查询结果返回了。没有对 “a” 执行写操作，所以返回的值仍为 “100” 。

-  向 ``peer0.org1.example.com`` 和 ``peer0.org2.example.com`` 发送了一次调用，来从 “a” 向 “b” 转账 “10”。

-  向 ``peer0.org2.example.com`` 发送一次对 “a” 的值的查询。返回值为 90，正确反映了之前交易期间，键 “a” 的值被转走了 10。

-  链码 **abstore** 被安装在 ``peer1.org2.example.com``

-  向 ``peer1.org2.example.com`` 发送一次对 “a” 的值的查询。启动了第三个名为 ``dev-peer1.org2.example.com-mycc-1.0`` 的链码容器。返回值为 90，正确反映了之前交易期间，键 “a” 的值被转走了 10。

这表明了什么？
^^^^^^^^^^^^^^^^^^^^^^^^^^^

链码 **必须** 安装在节点上才能实现对账本的读写操作。此外,一个链码容器不会在节点里启动，除非让链码执行 ``init`` 或者交易，（例如查询“a”的值）。交易导致容器的启动。当然，所有通道中的节点都持有以块的形式顺序存储的不可变的账本精确的备份，以及用来保存当前状态的快照状态数据库。这包括了没有在其上安装链码的节点（例如上面例子中的 ``peer1.org1.example.com``）。最后，链码在被安装后将是可用状态（例如上面例子中的 ``peer1.org2.example.com``），因为它的实例化已经提交被到通道了。

我如何查看这些交易？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

检查 CLI 容器的日志。

.. code:: bash

        docker logs -f cli

你会看到下面的输出：

.. code:: bash

      2017-05-16 17:08:01.366 UTC [msp] GetLocalMSP -> DEBU 004 Returning existing local MSP
      2017-05-16 17:08:01.366 UTC [msp] GetDefaultSigningIdentity -> DEBU 005 Obtaining default signing identity
      2017-05-16 17:08:01.366 UTC [msp/identity] Sign -> DEBU 006 Sign: plaintext: 0AB1070A6708031A0C08F1E3ECC80510...6D7963631A0A0A0571756572790A0161
      2017-05-16 17:08:01.367 UTC [msp/identity] Sign -> DEBU 007 Sign: digest: E61DB37F4E8B0D32C9FE10E3936BA9B8CD278FAA1F3320B08712164248285C54
      Query Result: 90
      2017-05-16 17:08:15.158 UTC [main] main -> INFO 008 Exiting.....
      ===================== Query successful on peer1.org2 on channel 'mychannel' =====================

      ===================== All GOOD, BYFN execution completed =====================


       _____   _   _   ____
      | ____| | \ | | |  _ \
      |  _|   |  \| | | | | |
      | |___  | |\  | | |_| |
      |_____| |_| \_| |____/

你可以滚动这些日志来查看各种交易。

我如何查看链码日志？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can inspect the individual chaincode containers to see the separate
transactions executed against each container. Use the following command to find
the list of running containers to find your chaincode containers:

.. code:: bash

    $ docker ps -a
    CONTAINER ID        IMAGE                                                                                                                                                                 COMMAND                  CREATED              STATUS              PORTS                                NAMES
    7aa7d9e199f5        dev-peer1.org2.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8-2eba360c66609a3ba78327c2c86bc3abf041c78f5a35553191a1acf1efdd5a0d   "chaincode -peer.add…"   About a minute ago   Up About a minute                                        dev-peer1.org2.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8
    82ce129c0fe6        dev-peer0.org2.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8-1297906045aa77086daba21aba47e8eef359f9498b7cb2b010dff3e2a354565a   "chaincode -peer.add…"   About a minute ago   Up About a minute                                        dev-peer0.org2.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8
    eaef1a8f7acf        dev-peer0.org1.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8-00d8dbefd85a4aeb9428b7df95df9744be1325b2a60900ac7a81796e67e4280a   "chaincode -peer.add…"   2 minutes ago        Up 2 minutes                                             dev-peer0.org1.example.com-mycc_1-27ef99cb3cbd1b545063f018f3670eddc0d54f40b2660b8f853ad2854c49a0d8
    da403175b785        hyperledger/fabric-tools:latest                                                                                                                                       "/bin/bash"              4 minutes ago        Up 4 minutes                                             cli
    c62a8d03818f        hyperledger/fabric-peer:latest                                                                                                                                        "peer node start"        4 minutes ago        Up 4 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp     peer0.org2.example.com
    06593c4f3e53        hyperledger/fabric-peer:latest                                                                                                                                        "peer node start"        4 minutes ago        Up 4 minutes        0.0.0.0:7051->7051/tcp               peer0.org1.example.com
    4ddc928ebffe        hyperledger/fabric-orderer:latest                                                                                                                                     "orderer"                4 minutes ago        Up 4 minutes        0.0.0.0:7050->7050/tcp               orderer.example.com
    6d79e95ec059        hyperledger/fabric-peer:latest                                                                                                                                        "peer node start"        4 minutes ago        Up 4 minutes        7051/tcp, 0.0.0.0:10051->10051/tcp   peer1.org2.example.com
    6aad6b40fd30        hyperledger/fabric-peer:latest                                                                                                                                        "peer node start"        4 minutes ago        Up 4 minutes        7051/tcp, 0.0.0.0:8051->8051/tcp     peer1.org1.example.com

The chaincode containers are the images starting with `dev-peer`. You can then
use the container ID to find the logs from each chaincode container.

.. code:: bash

        $ docker logs 7aa7d9e199f5
        ABstore Init
        Aval = 100, Bval = 100
        ABstore Invoke
        Aval = 90, Bval = 110

        $ docker logs eaef1a8f7acf
        ABstore Init
        Aval = 100, Bval = 100
        ABstore Invoke
        Query Response:{"Name":"a","Amount":"100"}
        ABstore Invoke
        Aval = 90, Bval = 110
        ABstore Invoke
        Query Response:{"Name":"a","Amount":"90"}

You can also see the peer logs to view chaincode invoke messages
and block commit messages:

.. code:: bash

          $ docker logs peer0.org1.example.com

了解 Docker Compose 技术
-----------------------------------------

BYFN 示例给我们提供了两种风格的 Docker Compose 文件，它们都继承自 ``docker-compose-base.yaml`` （在 ``base`` 目录下）。我们的第一种类型， ``docker-compose-cli.yaml`` ，给我们提供了一个 CLI 容器，以及一个 orderer 容器，四个 Peer 容器。我们用此文件来展开这个页面上的所有说明。

.. note:: 本节的剩余部分涵盖了为 SDK 设计的 docker-compose 文件。有关运行这些测试的详细信息，
          请参阅 `Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__ 仓库。

第二种风格是 ``docker-compose-e2e.yaml`` ，被构造为使用 Node.js SDK 来运行端到端测试。除了 SDK 的功能之外，它主要的区别在于它有运行 fabric-ca 服务的容器。因此，我们能够向组织的 CA 节点发送用于注册和登记用户的 REST 请求。

如果你在没有运行 ``byfn.sh`` 脚本的情况下，想使用 ``docker-compose-e2e.yaml`` ，我们需要进行四个轻微的修改。我们需要指出本组织 CA 的私钥。你可以在 ``crypto-config`` 文件夹中找到这些值。举个例子，为了定位 Org1 的私钥，我们将使用 ``crypto-config/peerOrganizations/org1.example.com/ca/`` 。Org2 的路径为 ``crypto-config/peerOrganizations/org2.example.com/ca/`` 。

在 ``docker-compose-e2e.yaml`` 里为 ca0 和 ca1 更新 FABRIC_CA_SERVER_TLS_KEYFILE 变量。你同样需要编辑 command 中启动 ca server 的路径。你为每个 CA 容器提供了两次同样的私钥。

使用CouchDB
-------------

状态数据库可以从默认的 ``goleveldb`` 切换到 ``CouchDB`` 。链码就可以使用 ``CouchDB`` 的功能了， ``CouchDB`` 提供了额外的能力来根据 JSON 形式的链码服务数据提供更加丰富以及复杂的查询。

使用 CouchDB 代替默认的数据库（goleveldb），除了在启动网络的时侯传递 ``docker-compose-couch.yaml``  之外，请遵循前面提到的生成配置文件的过程：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml -f docker-compose-etcdraft2.yaml up -d

**abstore** 现在在使用 CouchDB。

.. note::  如果你选择将 fabric-couchdb 容器端口映射到主机端口，请确保你意识到了安全性的影响。在开发环境中映射端口可以使 CouchDB REST API 可用，并允许通过 CouchDB Web 界面（Fauxton）对数据库进行可视化。生产环境将避免端口映射，以限制对 CouchDB 容器的外部访问。

You can use **abstore** chaincode against the CouchDB state database
using the steps outlined above, however in order to exercise the CouchDB query
capabilities you will need to use a chaincode that has data modeled as JSON.
The sample chaincode **marbles02** has been written to demostrate the queries
you can issue from your chaincode if you are using a CouchDB database. You can
locate the **marbles02** chaincode in the ``fabric/examples/chaincode/go``
directory.你可以按照上面列出的步骤使用 CouchDB 来执行 **chaincode_example02** ，然而为了联系 CouchDB 的查询能力，你将需要使用被格式化为 JSON 的数据（例如 marbles02）。你可以在 ``fabric/examples/chaincode/go`` 目录中找到 ``marbles02`` 链码。

我们将同样按照 :ref:``peerenvvars`` 部分的过程创建和加入通道。一旦你将 Peer 节点加入到了通道，请使用以下步骤与 marbles02 链码交互：

- Package and install the chaincode on ``peer0.org1.example.com``:

.. code:: bash

       # before packaging Golang chaincode, vendoring Go dependencies is required like the following commands.
       cd /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/marbles02/go
       GO111MODULE=on go mod vendor
       cd -

       # packages and installs the Golang chaincode
       peer lifecycle chaincode package marbles.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/marbles02/go/ --lang golang --label marbles_1
       peer lifecycle chaincode install marbles.tar.gz

The install command will return a chaincode packageID that you will use to
approve a chaincode definition.

.. code:: bash

      2019-04-08 20:10:32.568 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJmarbles_1:cfb623954827aef3f35868764991cc7571b445a45cfd3325f7002f14156d61ae\022\tmarbles_1" >
      2019-04-08 20:10:32.568 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marbles_1:cfb623954827aef3f35868764991cc7571b445a45cfd3325f7002f14156d61ae

- Save the packageID as an environment variable so you can pass it to future
  commands:

  .. code:: bash

      CC_PACKAGE_ID=marbles_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173

- Approve a chaincode definition as Org1:

.. code:: bash

       # be sure to modify the $CHANNEL_NAME variable accordingly for the command

       peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name marbles --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

- Install the chaincode on ``peer0.org2.example.com``:

.. code:: bash

      CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
      CORE_PEER_ADDRESS=peer0.org2.example.com:9051
      CORE_PEER_LOCALMSPID="Org2MSP"
      CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
      peer lifecycle chaincode install marbles.tar.gz

- Approve a chaincode definition as Org2, and then commit the definition to the
  channel:

.. code:: bash

       # be sure to modify the $CHANNEL_NAME variable accordingly for the command

       peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name marbles --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
       peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name marbles --version 1.0 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

- We can now create some marbles. The first invoke of the chaincode will start
  the chaincode container. You may need to wait for the container to start.

.. code:: bash

       # be sure to modify the $CHANNEL_NAME variable accordingly

       peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["initMarble","marble1","blue","35","tom"]}'

Once the container has started, you can issue additional commands to create
some marbles and move them around:

.. code:: bash

        # be sure to modify the $CHANNEL_NAME variable accordingly

        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["initMarble","marble2","red","50","tom"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["initMarble","marble3","blue","70","tom"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["transferMarble","marble2","jerry"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["transferMarblesBasedOnColor","blue","jerry"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["delete","marble1"]}'

-  如果你选择在 docker-compose 文件中映射你的 CouchDB 的端口，那么你现在就可以用浏览器打开下面的 URL 来使用 CouchDB Web 界面（Fauxton）：

   ``http://localhost:5984/_utils``

你应该可以看到一个名为 ``mychannel`` （或者你唯一的通道名字）的数据库以及它的文档在里面：

.. note:: 对于下面的命令，请确定 $CHANNEL_NAME 变量被更新了。

你可以 CLI 中运行常规的查询（例如读取 ``marble2`` ）：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["readMarble","marble2"]}'

``marble2`` 的详细输出应该显示为：

.. code:: bash

       Query Result: {"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}

你可以检索特定 marble 的历史记录，例如 ``marble1``:

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["getHistoryForMarble","marble1"]}'

关于 ``marble1`` 的交易的输出：

.. code:: bash

      Query Result: [{"TxId":"1c3d3caf124c89f91a4c0f353723ac736c58155325f02890adebaa15e16e6464", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}},{"TxId":"755d55c281889eaeebf405586f9e25d71d36eb3d35420af833a20a2f53a3eefd", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"jerry"}},{"TxId":"819451032d813dde6247f85e56a89262555e04f14788ee33e28b232eef36d98f", "Value":}]

你还可以对数据内容执行富查询，例如通过拥有者 ``jerry`` 查询 marble：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesByOwner","jerry"]}'

输出应该显示出两个属于 ``jerry`` 的 marble：

.. code:: bash

       Query Result: [{"Key":"marble2", "Record":{"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}},{"Key":"marble3", "Record":{"color":"blue","docType":"marble","name":"marble3","owner":"jerry","size":70}}]


为什么是 CouchDB
-------------
CouchDB 是一种 NoSQL 解决方案。它是一个面向文档的数据库，其中文档字段存储为键值映射。字段可以是简单的键值对、列表或映射。除了 LevelDB 支持的键值、复合键、键范围查询外，CouchDB 还支持完整数据的富查询功能，例如针对整个区块链数据的无键查询，因为其数据内容以 JSON 格式存储所以是可查询的。因此，CouchDB 可以用于链码，审计和需求报告等许多 LevelDB 不支持的用例。

CouchDB 还可以增强区块链中的合规性和数据保护的安全性。因为它能够通过过滤和屏蔽事务中的各个属性来实现字段级安全性，并且在需要时只授权只读权限。

关于数据持久化的提示
--------------------------

如果需要在节点容器或者 CouchDB 容器进行数据持久化，一种选择是将 docker 容器内相应的目录挂载到容器所在的宿主机的一个目录中。例如，你可以添加下列的两行到 ``docker-compose-base.yaml`` 文件中指定节点容器的配置中：

.. code:: bash

       volumes:
        - /var/hyperledger/peer0:/var/hyperledger/production

对于 CouchDB 容器，你可以在 CouchDB 的约定中添加两行：

.. code:: bash

       volumes:
        - /var/hyperledger/couchdb0:/opt/couchdb/data

.. _Troubleshoot:

故障排除
---------------

-  始终保持你的网络是全新的。使用以下命令来移除之前生成的构件、证书文件、容器以及链码镜像：

   .. code:: bash

      ./byfn.sh down

   .. note:: 如果你不移除旧的容器和镜像，你 **将会** 看到错误信息

-  如果你看到相关的 Docker 错误信息，首先检查你的版本（ :doc:`prereqs` ），然后重启你的 Docker 进程。Docker 的问题通常不会被立即识别。例如，你可能看到由于容器内未能找到密钥材料导致的错误。

   如果坚持删除你的镜像，并从头开始：

   .. code:: bash

       docker rm -f $(docker ps -aq)
       docker rmi -f $(docker images -q)

-  如果在你创建、提案、提交、调用或者查询的时候报错，请确保你已经更新了通道和链码的名字。提供的示例命令中有占位符。

-  如果你看到如下错误：

   .. code:: bash

       Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)

   你可能有以前运行的链码镜像（例如 ``dev-peer1.org2.example.com-mycc-1.0`` 或 ``dev-peer0.org1.example.com-mycc-1.0`` ）。删除它们，然后重试。

   .. code:: bash

       docker rmi -f $(docker images | grep peer[0-9]-peer[0-9] | awk '{print $3}')

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

      Error connecting: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure
      Error: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure

   请确保你的 fabric 网络运行在被标记为 “latest” 的 “1.0.0” 镜像上。

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

     [configtx/tool/localconfig] Load -> CRIT 002 Error reading configuration: Unsupported Config Type ""
     panic: Error reading configuration: Unsupported Config Type ""

   那么你没有正确设置 ``FABRIC_CFG_PATH`` 环境变量。configtxgen 工具需要这个变量才能找到 configtx.yaml。返回并执行 ``export FABRIC_CFG_PATH=$PWD``，然后重新创建通道构件。

-  要清理网络，请使用 ``down`` 选项：

   .. code:: bash

       ./byfn.sh down

-  如果你看到一条指示你依然有 “active endpoints” ，然后你应该清理你的 Docker 网络。这将会清除你之前的网络并且给你一个全新的环境：

   .. code:: bash

        docker network prune

   你会看到下面的内容：

   .. code:: bash

      WARNING! This will remove all networks not used by at least one container.
      Are you sure you want to continue? [y/N]

   选择 ``y`` 。

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

      /bin/bash: ./scripts/script.sh: /bin/bash^M: bad interpreter: No such file or directory

   请确保问题中的文件（本例是 **script.sh** ）被编码为 Unix 格式。这主要可能是由于你的 Git 配置没有设置 ``core.autocrlf`` 为 ``false`` 。有几种方法解决。例如，如果您有权访问 vim 编辑器，打开这个文件：

   .. code:: bash

      vim ./fabric-samples/first-network/scripts/script.sh

   通过下面的命令改变它的编码：

   .. code:: bash

      :set ff=unix

.. note:: 如果你仍旧看到了错误，请把你的日志分享在 `Hyperledger Rocket Chat <https://chat.hyperledger.org/home>`__ **fabric-questions** 频道上或者 `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger-fabric>`__ 。
