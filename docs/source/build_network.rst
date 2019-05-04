Building Your First Network - 创建你的第一个fabric网络
===========================

.. note:: These instructions have been verified to work against the
          latest stable Docker images and the pre-compiled
          setup utilities within the supplied tar file. If you run
          these commands with images or tools from the current master
          branch, it is possible that you will see configuration and panic
          errors.

.. note:: 这些说明已经被验证，它可以在最新稳定版的 docker 镜像和提供的预编译
          的设置工具 tar 文件下工作。如果你使用当前 master 分支下的镜像或者工
          具使用这些命令，你可能会遇到配置或者 panic 错误。

The build your first network (BYFN) scenario provisions a sample Hyperledger
Fabric network consisting of two organizations, each maintaining two peer
nodes. It also will deploy a "Solo" ordering service by default, though other
ordering service implementations are available.

Install prerequisites - 安装准备
---------------------

Before we begin, if you haven't already done so, you may wish to check that
you have all the :doc:`prereqs` installed on the platform(s) on which you'll be
developing blockchain applications and/or operating Hyperledger Fabric.

在我们开始之前，如果你之前没有操作过，你应该在你将要开发区块链应用或者
操作 Hyperledger Fabric 的平台上，检查你是否安装了全部的 :doc:`prereqs`。

You will also need to :doc:`install`. You will notice that there are a number of
samples included in the ``fabric-samples`` repository. We will be using the
``first-network`` sample. Let's open that sub-directory now.

你还需要去 :doc:`install` 。你会发现 ``fabric-samples`` 仓库中包含了许多示例。
我们将使用 ``first-network`` 作为例子。现在我们一起打开这个子目录。

.. code:: bash

  cd fabric-samples/first-network

.. note:: The supplied commands in this documentation **MUST** be run from your
          ``first-network`` sub-directory of the ``fabric-samples`` repository
          clone.  If you elect to run the commands from a different location,
          the various provided scripts will be unable to find the binaries.

.. note:: 这个文档里提供的命令 **必须** 要运行在你克隆的 ``fabric-samples`` 项目的
          子目录 ``first-network`` 里。如果你选择从不同的位置运行命令，
          提供的那些脚本将无法找到二进制文件。

Want to run it now? - 想要现在运行吗？
-------------------

We provide a fully annotated script --- ``byfn.sh`` --- that leverages these Docker
images to quickly bootstrap a Hyperledger Fabric network that by default is
comprised of four peers representing two different organizations, and an orderer
node. It will also launch a container to run a scripted execution that will join
peers to a channel, deploy a chaincode and drive execution of transactions
against the deployed chaincode.

Here's the help text for the ``byfn.sh`` script:

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
    -l <language> - the chaincode language: golang (default), node, or java"
    -o <consensus-type> - the consensus-type of the ordering service: solo (default), kafka, or etcdraft"
    -i <imagetag> - the tag to be used to launch the network (defaults to \"latest\")"
    -v - verbose mode"
  byfn.sh -h (print this message)"

  Typically, one would first generate the required certificates and
  genesis block, then bring up the network. e.g.:"

    byfn.sh generate -c mychannel"
    byfn.sh up -c mychannel -s couchdb"
    byfn.sh up -c mychannel -s couchdb -i 1.4.0"
    byfn.sh up -l node"
    byfn.sh down -c mychannel"
    byfn.sh upgrade -c mychannel"

  Taking all defaults:"
  	byfn.sh generate"
  	byfn.sh up"
  	byfn.sh down"

If you choose not to supply a flag, the script will use default values.

Generate Network Artifacts
^^^^^^^^^^^^^^^^^^^^^^^^^^

Ready to give it a go? Okay then! Execute the following command:

准备好了没？OK，执行下面的命令：

.. code:: bash

  ./byfn.sh generate

You will see a brief description as to what will occur, along with a yes/no command line
prompt. Respond with a ``y`` or hit the return key to execute the described action.

你会看到将要发生什么的一个简要说明，同时会有一个命令行提示 yes/no。
输入 Y 或者回车键来执行描述的动作。

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

This first step generates all of the certificates and keys for our various
network entities, the ``genesis block`` used to bootstrap the ordering service,
and a collection of configuration transactions required to configure a
:ref:`Channel`.

第一步为我们各种网络实体生成证书和秘钥。初始区块 ``genesis block`` 用于引导排序服务，
也包含了一组用于配置 :ref:`Channel` 所需要的一组配置交易集合。

Bring Up the Network - 启动网络
^^^^^^^^^^^^^^^^^^^^

Next, you can bring the network up with one of the following commands:

接下来，你可以用下面的命令启动网络：

.. code:: bash

  ./byfn.sh up

The above command will compile Golang chaincode images and spin up the corresponding
containers. Go is the default chaincode language, however there is also support
for `Node.js <https://fabric-shim.github.io/>`_ and `Java <https://fabric-chaincode-java.github.io/>`_
chaincode. If you'd like to run through this tutorial with node chaincode, pass
the following command instead:

上面的命令会编译 Golang 智能合约的镜像并且启动相应的容器。
Go 语言是默认的链码语言，但是它也支持 
`Node.js <https://fabric-shim.github.io/>`_ 和 `Java <https://fabric-chaincode-java.github.io/>`_ 的链码。
如果你想要在这个教程里运行 node 链码，你可以通过下面的命令替代：

.. code:: bash

  # we use the -l flag to specify the chaincode language
  # forgoing the -l flag will default to Golang

  ./byfn.sh up -l node

.. note:: For more information on the Node.js shim, please refer to its
          `documentation <https://fabric-shim.github.io/ChaincodeInterface.html>`_.

.. note:: 查看 `documentation <https://fabric-shim.github.io/fabric-shim.ChaincodeInterface.html>`_ 
          获取更多关于 Node.js shim 的信息。

.. note:: For more information on the Java shim, please refer to its
          `documentation <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_.
          
.. note:: 查看 `documentation <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_ 
          获取更多关于 Java shim 的信息。

Тo make the sample run with Java chaincode, you have to specify ``-l java`` as follows:

为了能够让例子运行 Java 链码，你需要像下边这样指定 ``-l java``:

.. code:: bash

  ./byfn.sh up -l java

.. note:: Do not run both of these commands. Only one language can be tried unless
          you bring down and recreate the network between.

In addition to support for multiple chaincode languages, you can also issue a
flag that will bring up a five node Raft ordering service or a Kafka ordering
service instead of the one node Solo orderer. For more information about the
currently supported ordering service implementations, check out :doc:`orderer/ordering_service`.

To bring up the network with a Raft ordering service, issue:

.. code:: bash

  ./byfn.sh up -o etcdraft

To bring up the network with a Kafka ordering service, issue:

.. code:: bash

  ./byfn.sh up -o kafka

Once again, you will be prompted as to whether you wish to continue or abort.
Respond with a ``y`` or hit the return key:

再一次，您将被提示是否要继续或中止。用 y 或者按下回车键来响应。

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

The logs will continue from there. This will launch all of the containers, and
then drive a complete end-to-end application scenario. Upon successful
completion, it should report the following in your terminal window:

日志会从那里继续。这一步会启动所有的容器，然后驱动一个完整的 end-to-end 应用场景。
完成后，它应该在您的终端窗口中报告以下内容:

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

You can scroll through these logs to see the various transactions. If you don't
get this result, then jump down to the :ref:`Troubleshoot` section and let's see
whether we can help you discover what went wrong.

你可以滚动这些日志去查看各种交易。如果你没有获得这个结果，
请移步疑难解答部分 :ref:`Troubleshoot` ，看看我们是否可以帮助你发现问题。

Bring Down the Network - 关闭网络
^^^^^^^^^^^^^^^^^^^^^^

Finally, let's bring it all down so we can explore the network setup one step
at a time. The following will kill your containers, remove the crypto material
and four artifacts, and delete the chaincode images from your Docker Registry:

最后，让我们把他停下来，这样我们可以一步步探索网络设置。
接下来的命令会结束掉你所有的容器，移除加密的材料和四个构件，并且从 Docker 仓库删除链码镜像。

.. code:: bash

  ./byfn.sh down

Once again, you will be prompted to continue, respond with a ``y`` or hit the return key:

再一次，您将被提示是否要继续或中止，用 y 或者按下回车键表示响应。

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

If you'd like to learn more about the underlying tooling and bootstrap mechanics,
continue reading.  In these next sections we'll walk through the various steps
and requirements to build a fully-functional Hyperledger Fabric network.

如果你想要了解更多关于底层工具和引导机制的信息，继续阅读。
在接下来的章节，我们将浏览构建一个功能完整的 Hyperledger Fabric 网络的各个步骤和要求。

.. note:: The manual steps outlined below assume that the ``FABRIC_LOGGING_SPEC`` in
          the ``cli`` container is set to ``DEBUG``. You can set this by modifying
          the ``docker-compose-cli.yaml`` file in the ``first-network`` directory.
          e.g.

.. note:: 下面列出的手动步骤设置假设在 ``cli`` 容器中的 ``CORE_LOGGING_SPEC`` 设置为 ``DEBUG`` 。
          你可以通过修改 ``first-network`` 中的 ``docker-compose-cli.yaml`` 文件来设置。例如：

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

Crypto Generator - 加密生成器
----------------

We will use the ``cryptogen`` tool to generate the cryptographic material
(x509 certs and signing keys) for our various network entities.  These certificates are
representative of identities, and they allow for sign/verify authentication to
take place as our entities communicate and transact.

我们将使用 ``cryptogen`` 工具为我们的网络实体生成各种加密材料（ x509 证书和签名秘钥）。
这些证书是身份的代表，在实体之间交流和交易的时候，它们允许对身份验证进行签名和验证。

How does it work? - 它是怎么工作的？
^^^^^^^^^^^^^^^^^

Cryptogen consumes a file --- ``crypto-config.yaml`` --- that contains the network
topology and allows us to generate a set of certificates and keys for both the
Organizations and the components that belong to those Organizations.  Each
Organization is provisioned a unique root certificate (``ca-cert``) that binds
specific components (peers and orderers) to that Org.  By assigning each
Organization a unique CA certificate, we are mimicking a typical network where
a participating :ref:`Member` would use its own Certificate Authority.
Transactions and communications within Hyperledger Fabric are signed by an
entity's private key (``keystore``), and then verified by means of a public
key (``signcerts``).

Cryptogen 通过一个包含网络拓扑的文件 ``crypto-config.yaml`` ，为所有组织和
属于这些组织的组件生成一组证书和秘钥。每一个组织被分配一个唯一的根证书（ ``ca-cert`` ），
它绑定该组织的特定组件（ peer 节点和排序节点）。通过为每个组织分配一个惟一的 CA 证书，
我们模拟了一个参与 :ref:`Member` 将使用它自己的认证授权的典型的网络。
超级账本中的事务和通信是由一个实体的私钥（ ``keystore`` ）签名的，然后通过公钥（ ``signcerts`` ）验证。

You will notice a ``count`` variable within this file.  We use this to specify
the number of peers per Organization; in our case there are two peers per Org.
We won't delve into the minutiae of `x.509 certificates and public key
infrastructure <https://en.wikipedia.org/wiki/Public_key_infrastructure>`_
right now. If you're interested, you can peruse these topics on your own time.

After we run the ``cryptogen`` tool, the generated certificates and keys will be
saved to a folder titled ``crypto-config``. Note that the ``crypto-config.yaml``
file lists five orderers as being tied to the orderer organization. While the
``cryptogen`` tool will create certificates for all five of these orderers, unless
the Raft or Kafka ordering services are being used, only one of these orderers
will be used in a Solo ordering service implementation and be used to create the
system channel and ``mychannel``.

Configuration Transaction Generator - 配置交易生成器
-----------------------------------

The ``configtxgen`` tool is used to create four configuration artifacts:

  * orderer ``genesis block``,
  * channel ``configuration transaction``,
  * and two ``anchor peer transactions`` - one for each Peer Org.

``configtxgen`` 工具用来创建四个配置构件:

  * 排序节点的 ``初始区块``,
  * 通道 ``配置交易``,
  * 两个 ``锚节点交易`` - 一个对应一个 Peer 组织。

Please see :doc:`commands/configtxgen` for a complete description of this tool's functionality.

有关此工具的完整说明，请参阅 :doc:`commands/configtxgen`

The orderer block is the :ref:`Genesis-Block` for the ordering service, and the
channel configuration transaction file is broadcast to the orderer at :ref:`Channel` creation
time.  The anchor peer transactions, as the name might suggest, specify each
Org's :ref:`Anchor-Peer` on this channel.

排序区块是排序服务的 :ref:`Genesis-Block` ，通道配置交易在 :ref:`Channel` 创建的时候广播给排序服务。
锚节点交易，正如名称所示，指定了每个组织在此通道上的 :ref:`Anchor-Peer` 。

How does it work? - 它是怎么工作的？
^^^^^^^^^^^^^^^^^

Configtxgen consumes a file - ``configtx.yaml`` - that contains the definitions
for the sample network. There are three members - one Orderer Org (``OrdererOrg``)
and two Peer Orgs (``Org1`` & ``Org2``) each managing and maintaining two peer nodes.
This file also specifies a consortium - ``SampleConsortium`` - consisting of our
two Peer Orgs.  Pay specific attention to the "Profiles" section at the bottom of
this file. You will notice that we have several unique profiles. A few are worth
noting:

* ``TwoOrgsOrdererGenesis``: generates the genesis block for a Solo ordering
  service.

* ``SampleMultiNodeEtcdRaft``: generates the genesis block for a Raft ordering
  service. Only used if you issue the ``-o`` flag and specify ``etcdraft``.

* ``SampleDevModeKafka``: generates the genesis block for a Kafka ordering
  service. Only used if you issue the ``-o`` flag and specify ``kafka``.

* ``TwoOrgsChannel``: generates the genesis block for our channel, ``mychannel``.

These headers are important, as we will pass them in as arguments when we create
our artifacts.

.. note:: Notice that our ``SampleConsortium`` is defined in
          the system-level profile and then referenced by
          our channel-level profile.  Channels exist within
          the purview of a consortium, and all consortia
          must be defined in the scope of the network at
          large.

.. note:: 注意我们的 ``SampleConsortium`` 在系统级配置文件中定义，并且在通道级的配置文件中关联引用。
          通道存在于联盟的范围内，所有的联盟必须定义在整个网络范围内。

This file also contains two additional specifications that are worth
noting. Firstly, we specify the anchor peers for each Peer Org
(``peer0.org1.example.com`` & ``peer0.org2.example.com``).  Secondly, we point to
the location of the MSP directory for each member, in turn allowing us to store the
root certificates for each Org in the orderer genesis block.  This is a critical
concept. Now any network entity communicating with the ordering service can have
its digital signature verified.

该文件还包含两个值得注意的附加规范。第一，我们为每个组织指定了锚节点
（ ``peer0.org1.example.com`` & ``peer0.org2.example.com`` ）。
第二，我们为每个成员指定 MSP 文件位置，进而让我们可以在排序节点的初始区块中存储每个组织的根证书。
这是一个关键概念。现在每个和排序服务通信的网络实体都有它自己的被验证过的数字签名。

Run the tools - 运行工具
-------------

You can manually generate the certificates/keys and the various configuration
artifacts using the ``configtxgen`` and ``cryptogen`` commands. Alternately,
you could try to adapt the byfn.sh script to accomplish your objectives.

你可以用 ``configtxgen`` 和 ``cryptogen`` 命令来手动生成证书/密钥和各种配置。
或者，你可以尝试使用 byfn.sh 脚本来完成你的目标。

Manually generate the artifacts - 手动生成构件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can refer to the ``generateCerts`` function in the byfn.sh script for the
commands necessary to generate the certificates that will be used for your
network configuration as defined in the ``crypto-config.yaml`` file. However,
for the sake of convenience, we will also provide a reference here.

你可以参考 byfn.sn 脚本中的 ``generateCerts`` 函数，
这个函数是生成在 ``crypto-config.yaml`` 定义的证书的命令，
这些证书将被作为你的网络配置使用。然而,为了方便起见，我们在这里也提供一个参考。

First let's run the ``cryptogen`` tool.  Our binary is in the ``bin``
directory, so we need to provide the relative path to where the tool resides.

首先，让我们来运行 ``cryptogen`` 工具。我们的这个二进制文件
存放在 ``bin`` 文件目录下，所以我们需要提供工具所在的相对路径。

.. code:: bash

    ../bin/cryptogen generate --config=./crypto-config.yaml

You should see the following in your terminal:

你会在你的终端中看到下面的内容：

.. code:: bash

  org1.example.com
  org2.example.com

The certs and keys (i.e. the MSP material) will be output into a directory - ``crypto-config`` -
at the root of the ``first-network`` directory.

证书和秘钥 （例如 MSP 材料）将会输出在文件夹 - ``crypto-config`` - 
在 ``first-network`` 文件夹的根目录。

Next, we need to tell the ``configtxgen`` tool where to look for the
``configtx.yaml`` file that it needs to ingest.  We will tell it look in our
present working directory:

接下来，我们需要告诉 ``configtxgen`` 工具去哪儿去寻找它需要提取内容的 ``configtx.yaml`` 文件。
我们会告诉它在我们当前所在工作目录：

.. code:: bash

    export FABRIC_CFG_PATH=$PWD

Then, we'll invoke the ``configtxgen`` tool to create the orderer genesis block:

然后我们会调用 ``configtxgen`` 工具去创建初始区块：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

To output a genesis block for a Raft ordering service, this command should be:

.. code:: bash

  ../bin/configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

Note the ``SampleMultiNodeEtcdRaft`` profile being used here.

To output a genesis block for a Kafka ordering service, issue:

.. code:: bash

  ../bin/configtxgen -profile SampleDevModeKafka -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

If you are not using Raft or Kafka, you should see an output similar to the
following:

.. code:: bash

  2017-10-26 19:21:56.301 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
  2017-10-26 19:21:56.309 EDT [common/tools/configtxgen] doOutputBlock -> INFO 002 Generating genesis block
  2017-10-26 19:21:56.309 EDT [common/tools/configtxgen] doOutputBlock -> INFO 003 Writing genesis block

.. note:: The orderer genesis block and the subsequent artifacts we are about to create
          will be output into the ``channel-artifacts`` directory at the root of this
          project. The `channelID` in the above command is the name of the system channel.

.. note:: 我们创建的排序节点初始区块和随后的网络构件将会输出在这个项目的根目录的 ``channel-artifacts`` 文件夹下。在上边命令种的 `channelID` 是系统通道的名字。

.. _createchanneltx:

Create a Channel Configuration Transaction - 创建通道配置交易
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Next, we need to create the channel transaction artifact. Be sure to replace ``$CHANNEL_NAME`` or
set ``CHANNEL_NAME`` as an environment variable that can be used throughout these instructions:

接下来，我们需要去创建通道的交易构件。请确保替换 ``$CHANNEL_NAME`` 或者
将 ``CHANNEL_NAME`` 设置为整个说明中可以使用的环境变量：

.. code:: bash

    # The channel.tx artifact contains the definitions for our sample channel

    export CHANNEL_NAME=mychannel  && ../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

Note that you don't have to issue a special command for the channel if you are
using a Raft or Kafka ordering service. The ``TwoOrgsChannel`` profile will use
the ordering service configuration you specified when creating the genesis block
for the network.

If you are not using a Raft or Kafka ordering service, you should see an output
similar to the following in your terminal:

.. code:: bash

  2017-10-26 19:24:05.324 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 002 Generating new channel configtx
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 003 Writing new channel tx

Next, we will define the anchor peer for Org1 on the channel that we are
constructing. Again, be sure to replace ``$CHANNEL_NAME`` or set the environment
variable for the following commands.  The terminal output will mimic that of the
channel transaction artifact:

接下来，我们会为我们构建的通道上的 Org1 定义锚节点。
请再次确认 ``$CHANNEL_NAME`` 已被替换或者为以下命令设置了环境变量：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

Now, we will define the anchor peer for Org2 on the same channel:

现在，我们将在同一个通道上为 Org2 定义锚节点：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

Start the network - 启动网络
-----------------

.. note:: If you ran the ``byfn.sh`` example above previously, be sure that you
          have brought down the test network before you proceed (see
          `Bring Down the Network`_).

.. note:: 如果之前启动了 ``byfn.sh`` 例子，再继续之前确认一下你
          已经把这个测试网络关掉了(查看 `Bring Down the Network`_ )。

We will leverage a script to spin up our network. The
docker-compose file references the images that we have previously downloaded,
and bootstraps the orderer with our previously generated ``genesis.block``.

我们将使用一个脚本启动我们的网络。docker-compose 文件关联了我们之前下载的镜像，
然后通过我们之前生成的初始区块 ``genesis.block`` 引导排序节点。

We want to go through the commands manually in order to expose the
syntax and functionality of each call.

我们想要通过手动运行那些命令，目的是为了发现探索每个语法和调用的功能。

First let's start our network:

首先，启动我们的网络：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml up -d

If you want to see the realtime logs for your network, then do not supply the ``-d`` flag.
If you let the logs stream, then you will need to open a second terminal to execute the CLI calls.

如果你想要实时查看你的网络日志，请不要加 ``-d`` 标识。
如果你想要日志流，你需要打开第二个终端来执行 CLI 命令。

.. _peerenvvars:

Create & Join Channel
^^^^^^^^^^^^^^^^^^^^^

Recall that we created the channel configuration transaction using the
``configtxgen`` tool in the :ref:`createchanneltx` section, above. You can
repeat that process to create additional channel configuration transactions,
using the same or different profiles in the ``configtx.yaml`` that you pass
to the ``configtxgen`` tool. Then you can repeat the process defined in this
section to establish those other channels in your network.

回想一下，我们在 :ref:`createchanneltx` 章节中使用 ``configtxgen`` 工具创建通道配置交易。
你可以使用在 ``configtx.yaml`` 中相同或者不同的传给 ``configtxgen`` 工具的配置，
重复之前的过程来创建一个额外的通道配置交易。然后你可以重复在本章
节中的过程去在你的网络中创建其他通道。

We will enter the CLI container using the ``docker exec`` command:

我们可以使用 ``docker exec`` 输入 CLI 容器命令:

.. code:: bash

        docker exec -it cli bash

If successful you should see the following:

成功的话你会看到下面的输出：

.. code:: bash

        root@0d78bb69300d:/opt/gopath/src/github.com/hyperledger/fabric/peer#

For the following CLI commands against ``peer0.org1.example.com`` to work, we need
to preface our commands with the four environment variables given below.  These
variables for ``peer0.org1.example.com`` are baked into the CLI container,
therefore we can operate without passing them. **HOWEVER**, if you want to send
calls to other peers or the orderer, keep the CLI container defaults targeting
``peer0.org1.example.com``, but override the environment variables as seen in the
example below when you make any CLI calls:

.. code:: bash

    # Environment variables for PEER0

    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

Next, we are going to pass in the generated channel configuration transaction
artifact that we created in the :ref:`createchanneltx` section (we called
it ``channel.tx``) to the orderer as part of the create channel request.

接下来，我们会把在 :ref:`createchanneltx` 章节中创建的通道配置交易配置
（我们称之为 ``channel.tx`` ）作为创建通道请求的一部分传递给排序节点。

We specify our channel name with the ``-c`` flag and our channel configuration
transaction with the ``-f`` flag. In this case it is ``channel.tx``, however
you can mount your own configuration transaction with a different name.  Once again
we will set the ``CHANNEL_NAME`` environment variable within our CLI container so that
we don't have to explicitly pass this argument. Channel names must be all lower
case, less than 250 characters long and match the regular expression
``[a-z][a-z0-9.-]*``.

我们使用 ``-c`` 标志指定通道的名称， ``-f`` 标志指定通道配置交易。
在这个例子中它是 ``channel.tx`` ，当然你也可以使用不同的名称挂载你自己的交易配置。
我们将再次在 CLI 容器中设置 ``CHANNEL_NAME`` 环境变量，这样我们就不要显示的传递这个参数。
通道的名称必须全部是消息字母，小于 250 个字符，并且匹配正则表达式 ``[a-z][a-z0-9.-]*`` 。

.. code:: bash

        export CHANNEL_NAME=mychannel

        # the channel.tx file is mounted in the channel-artifacts directory within your CLI container
        # as a result, we pass the full path for the file
        # we also pass the path for the orderer ca-cert in order to verify the TLS handshake
        # be sure to export or replace the $CHANNEL_NAME variable appropriately

        peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. note:: Notice the ``--cafile`` that we pass as part of this command.  It is
          the local path to the orderer's root cert, allowing us to verify the
          TLS handshake.

This command returns a genesis block - ``<CHANNEL_NAME.block>`` - which we will use to join the channel.
It contains the configuration information specified in ``channel.tx``  If you have not
made any modifications to the default channel name, then the command will return you a
proto titled ``mychannel.block``.

这个命令返回一个初始区块 - ``<channel-ID.block>`` 。我们将会用它来加入通道。
它包含了 ``channel.tx`` 中的配置信息。如果你没有修改默认的通道名称，
命令会返回给你一个叫 ``mychannel.block`` 的样例。

.. note:: You will remain in the CLI container for the remainder of
          these manual commands. You must also remember to preface all commands
          with the corresponding environment variables when targeting a peer other than
          ``peer0.org1.example.com``.

.. note:: 你将在 CLI 容器中继续执行这些手动命令的其余部分。当你的目标是 ``peer0.org1.example.com`` 节点之外的 peer 时，你必须记住用相应的环境变量作为所有命令的前言。

Now let's join ``peer0.org1.example.com`` to the channel.

现在让我们把 ``peer0.org1.example.com`` 加入通道。

.. code:: bash

        # By default, this joins ``peer0.org1.example.com`` only
        # the <CHANNEL_NAME.block> was returned by the previous command
        # if you have not modified the channel name, you will join with mychannel.block
        # if you have created a different channel name, then pass in the appropriately named block

         peer channel join -b mychannel.block

You can make other peers join the channel as necessary by making appropriate
changes in the four environment variables we used in the :ref:`peerenvvars`
section, above.

你可以通过适当的修改在 :ref:`peerenvvars` 章节中的四个环境变量来让其他的节点加入通道。

Rather than join every peer, we will simply join ``peer0.org2.example.com`` so that
we can properly update the anchor peer definitions in our channel.  Since we are
overriding the default environment variables baked into the CLI container, this full
command will be the following:

不是加入每一个节点，我们只是简单的加入 ``peer0.org2.example.com`` 以便我们可以更新定义在
通道中的锚节点。由于我们正在覆盖 CLI 容器中融入的默认的环境变量，整个命令将会是这样：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:9051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

Alternatively, you could choose to set these environment variables individually
rather than passing in the entire string.  Once they've been set, you simply need
to issue the ``peer channel join`` command again and the CLI container will act
on behalf of ``peer0.org2.example.com``.

或者，您可以选择单独设置这些环境变量而不是传递整个字符串。
设置完成后，只需再次执行 ``peer channel join`` 命令，
然后 CLI 容器会代表 ``peer0.org2.example.com`` 起作用。

Update the anchor peers - 更新锚节点
^^^^^^^^^^^^^^^^^^^^^^^

The following commands are channel updates and they will propagate to the definition
of the channel.  In essence, we adding additional configuration information on top
of the channel's genesis block.  Note that we are not modifying the genesis block, but
simply adding deltas into the chain that will define the anchor peers.

接下来的命令是通道更新，它会传递到通道的定义中去。实际上，我们在通道的创世区块的头部添加了
额外的配置信息。注意我们没有编辑初始区块，但是简单的把将会定义锚节点的增量添加到了链中。

Update the channel definition to define the anchor peer for Org1 as ``peer0.org1.example.com``:

更新通道定义，将 Org1 的锚节点定义为 ``peer0.org1.example.com`` 。

.. code:: bash

  peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Now update the channel definition to define the anchor peer for Org2 as ``peer0.org2.example.com``.
Identically to the ``peer channel join`` command for the Org2 peer, we will need to
preface this call with the appropriate environment variables.

现在更新通道定义，将 Org2 的锚节点定义为 ``peer0.org2.example.com`` 。
与执行 Org2 节点的 ``peer channel join`` 命令相同，我们需要使用为这个命令配置合适的环境变量。

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:9051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. _install-define-chaincode:

Install and define a chaincode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: We will utilize a simple existing chaincode. To learn how to write
          your own chaincode, see the :doc:`chaincode4ade` tutorial.

.. note:: These instructions use the Fabric chaincode lifecycle introduced in
          the v2.0 Alpha release. If you would like to use the previous
          lifecycle to install and instantiate a chaincode, visit the v1.4
          version of the `Building your first network tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html>`__.

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
    peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/node/ --lang node --label mycc_1

**Java**

.. code:: bash

    # this packages a java chaincode
    # make note of the --lang flag to indicate "java" chaincode
    # for java chaincode --path takes the absolute path to the java chaincode
    # The --label flag is used to create the package label
    peer lifecycle chaincode package mycc.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/java/ --lang java --label mycc_1

Each of the above commands will create a chaincode package named ``mycc.tar.gz`,
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

    # this returns the details of the packages installed on your peers
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

The endorsement policy of ``mycc`` will be set to require endorsements from a
peer in both Org1 and Org2. Therefore, we also need to install the chaincode on
a peer in Org2.

Modify the following four environment variables to issue the install command
as Org2:

.. code:: bash

   # Environment variables for PEER0 in Org2

   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   CORE_PEER_ADDRESS=peer0.org2.example.com:9051
   CORE_PEER_LOCALMSPID="Org2MSP"
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

Now install the chaincode package onto peer0 of Org2. The following command
will install the chaincode and return same identifier as the install command we
issued as Org1.

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
Org2. The approval is distributed within each organization using gossip, so
the command does not need to target every peer within an organization.

.. code:: bash

    # this approves a chaincode definition for your org
    # make note of the --package-id flag that provides the package ID
    # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

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
    peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

Once a sufficient number of channel members have approved a chaincode definition,
one member can commit the definition to the channel. By default a majority of
channel members need to approve a definition before it can be committed. It is
possible to discover the approval status for the chanincode definition across all
organizations by issuing the following query:

.. code:: bash

    # the flags used for this command are identical to those used for approveformyorg
    # except for --package-id which is not required since it is not stored as part of
    # the definition
    peer lifecycle chaincode queryapprovalstatus --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

The command will produce as output a JSON map showing if the organizations in the
channel have approved the chaincode definition provided in the queryapprovalstatus
command. In this case, given that both organizations have approved, we obtain:

.. code:: bash

    {
            "Approved": {
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
    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --waitForEvent

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

Query - 查询
^^^^^

Let's query the chaincode to make sure that the container was properly started
and the state DB was populated. The syntax for query is as follows:

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

Invoke - 调用
^^^^^^

Now let’s move ``10`` from ``a`` to ``b``. This transaction will cut a new block
and update the state DB. The syntax for invoke is as follows:

.. code:: bash

  # be sure to set the -C and -n flags appropriately
  peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}' --waitForEvent

Query - 查询
^^^^^

Let's confirm that our previous invocation executed properly. We initialized the
key ``a`` with a value of ``100`` and just removed ``10`` with our previous
invocation. Therefore, a query against ``a`` should return ``90``. The syntax
for query is as follows.

我们来确认一下我们之前的调用正确执行了。我们为键 ``a`` 初始化一个 100 的值，
通过刚才的调用减少了 ``10`` 。这样查询出的值应该是 ``90`` ，查询的语法是这样的：

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

We should see the following:

我们会看到下面的结果：

.. code:: bash

   Query Result: 90

Install the chaincode on an additional peer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you want additional peers to interact with the ledger, then you will need to
join them to the channel and install the same chaincode package on the peers.
You only need to approve the chaincode definition once from your organization.
A chaincode container will be launched for each peer as soon as they try to
interact with that specific chaincode. Again, be cognizant of the fact that the
Node.js images will be slower to build and start upon the first invoke.

We will install the chaincode on a third peer, peer1 in Org2. Modify the
following four environment variables to issue the install command against peer1
in Org2:

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

Query
^^^^^

Let's confirm that we can issue the query to Peer1 in Org2. We initialized the
key ``a`` with a value of ``100`` and just removed ``10`` with our previous
invocation. Therefore, a query against ``a`` should still return ``90``.

Peer1 in Org2 must first join the channel before it can respond to queries. The
channel can be joined by issuing the following command:

Org2 的 peer1 必须先加入通道才可以响应查询。下边的命令可以让它加入通道：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer1.org2.example.com:10051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

After the join command returns, the query can be issued. The syntax for query is
as follows.

在加入通道的命令返回之后，查询就可以执行了。下边是执行查询的语法。

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

We should see the following:

我们会看到下面的结果：

.. code:: bash

   Query Result: 90

If you received an error, it may be because it takes a few seconds for the
peer to join and catch up to the current blockchain height. You may
re-query as needed. Feel free to perform additional invokes as well.

.. _behind-scenes:

What's happening behind the scenes? - 幕后发生了什么？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: These steps describe the scenario in which
          ``script.sh`` is run by './byfn.sh up'.  Clean your network
          with ``./byfn.sh down`` and ensure
          this command is active.  Then use the same
          docker-compose prompt to launch your network again
          
.. note:: 这些步骤描述了在 ``script.sh`` 脚本中的场景，它是由 './byfn.sh up' 启动的。
          通过 ``./byfn.sh down`` 清除你的网络，确保此命令处于活动状态。
          然后用同样的 docker-compose 提示去再次启动你的网络。         

-  A script - ``script.sh`` - is baked inside the CLI container. The
   script drives the ``createChannel`` command against the supplied channel name
   and uses the channel.tx file for channel configuration.

-  一个脚本 - ``script.sh`` - 被保存在 CLI 容器中。这个脚本通过提供的通道名称和通道配
   置文件 channel.tx 来执行创建通道 ``createChannel`` 的命令。

-  The output of ``createChannel`` is a genesis block -
   ``<your_channel_name>.block`` - which gets stored on the peers' file systems and contains
   the channel configuration specified from channel.tx.

-  ``createChannel`` 的输出是一个初始区块 - ``<你的通道名>.block`` - 
   它被存储在节点文件系统上并包含有来自 channel.tx 的通道配置。

-  The ``joinChannel`` command is exercised for all four peers, which takes as
   input the previously generated genesis block.  This command instructs the
   peers to join ``<your_channel_name>`` and create a chain starting with ``<your_channel_name>.block``.
   
-  ``joinChannel`` 命令被所有的四个节点执行，作为之前产生初始区块的输入。
   这个命令指示那些节点去加入通道 ``<你的通道名>`` 并且通过 ``<你的通道名>.block`` 开始创建一条链。

-  Now we have a channel consisting of four peers, and two
   organizations.  This is our ``TwoOrgsChannel`` profile.

-  现在我们有一个由四个节点，两个组织组成的通道，这是我们 ``TwoOrgsChannel`` 的结构。

-  ``peer0.org1.example.com`` and ``peer1.org1.example.com`` belong to Org1;
   ``peer0.org2.example.com`` and ``peer1.org2.example.com`` belong to Org2

-  ``peer0.org1.example.com`` 和 ``peer1.org1.example.com`` 属于 Org1;
   ``peer0.org2.example.com`` 和 ``peer1.org2.example.com`` 属于 Org2

-  These relationships are defined through the ``crypto-config.yaml`` and
   the MSP path is specified in our docker compose.

-  这些关系在 ``crypto-config.yaml`` 中定义，MSP 的路径在我们的 docker compose 中指定。

-  The anchor peers for Org1MSP (``peer0.org1.example.com``) and
   Org2MSP (``peer0.org2.example.com``) are then updated.  We do this by passing
   the ``Org1MSPanchors.tx`` and ``Org2MSPanchors.tx`` artifacts to the ordering
   service along with the name of our channel.

-  A chaincode - **abstore** - is packaged and installed on ``peer0.org1.example.com``
   and ``peer0.org2.example.com``

-  The chaincode is then separately approved by Org1 and Org2, and then committed
   on the channel. Since an endorsement policy was not specified, the channel's
   default endorsement policy of a majority of organizations will get utilized,
   meaning that any transaction must be endorsed by a peer tied to Org1 and Org2.

-  The chaincode Init is then called which starts the container for the target peer,
   and initializes the key value pairs associated with the chaincode.  The initial
   values for this example are ["a","100" "b","200"]. This first invoke results
   in a container by the name of ``dev-peer0.org2.example.com-mycc-1.0`` starting.

-  A query against the value of "a" is issued to ``peer0.org2.example.com``.
   A container for Org2 peer0 by the name of ``dev-peer0.org2.example.com-mycc-1.0``
   was started when the chaincode was initialized. The result of the query is
   returned. No write operations have occurred, so a query against "a" will
   still return a value of "100".

-  An invoke is sent to ``peer0.org1.example.com`` and ``peer0.org2.example.com``
   to move "10" from "a" to "b"

-  A query is sent to ``peer0.org2.example.com`` for the value of "a". A
   value of 90 is returned, correctly reflecting the previous
   transaction during which the value for key "a" was modified by 10.

-  The chaincode - **abstore** - is installed on ``peer1.org2.example.com``

-  A query is sent to ``peer1.org2.example.com`` for the value of "a". This starts a
   third chaincode container by the name of ``dev-peer1.org2.example.com-mycc-1.0``. A
   value of 90 is returned, correctly reflecting the previous
   transaction during which the value for key "a" was modified by 10.
   
-  向 ``peer1.org2.example.com`` 发送一次对 “a” 的值的查询。
   启动了第三个名为 ``dev-peer1.org2.example.com-mycc-1.0`` 的链码容器。
   返回值为 90，正确反映了之前交易期间，键 “a” 的值被转走了 10。

What does this demonstrate? - 这表明了什么？
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Chaincode **MUST** be installed on a peer in order for it to
successfully perform read/write operations against the ledger.
Furthermore, a chaincode container is not started for a peer until an ``init`` or
traditional transaction - read/write - is performed against that chaincode (e.g. query for
the value of "a"). The transaction causes the container to start. Also,
all peers in a channel maintain an exact copy of the ledger which
comprises the blockchain to store the immutable, sequenced record in
blocks, as well as a state database to maintain a snapshot of the current state.
This includes those peers that do not have chaincode installed on them
(like ``peer1.org1.example.com`` in the above example) . Finally, the chaincode is accessible
after it is installed (like ``peer1.org2.example.com`` in the above example) because its
definition has already been committed on the channel.

How do I see these transactions?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Check the logs for the CLI Docker container.

检查 CLI 容器的日志。

.. code:: bash

        docker logs -f cli

You should see the following output:

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

You can scroll through these logs to see the various transactions.

你可以滚动这些日志来查看各种交易。

How can I see the chaincode logs? - 我如何查看链码日志？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Inspect the individual chaincode containers to see the separate
transactions executed against each container. Here is the combined
output from each container:

检查每个独立的链码服务容器来分别查看每个容器内的交易。
下面是每个链码服务容器的日志的综合输出：

.. code:: bash

        $ docker logs dev-peer0.org2.example.com-mycc-1.0
        04:30:45.947 [BCCSP_FACTORY] DEBU : Initialize BCCSP [SW]
        ex02 Init
        Aval = 100, Bval = 200

        $ docker logs dev-peer0.org1.example.com-mycc-1.0
        04:31:10.569 [BCCSP_FACTORY] DEBU : Initialize BCCSP [SW]
        ex02 Invoke
        Query Response:{"Name":"a","Amount":"100"}
        ex02 Invoke
        Aval = 90, Bval = 210

        $ docker logs dev-peer1.org2.example.com-mycc-1.0
        04:31:30.420 [BCCSP_FACTORY] DEBU : Initialize BCCSP [SW]
        ex02 Invoke
        Query Response:{"Name":"a","Amount":"90"}

You can also see the peer logs to view chaincode invoke messages
and block commit messages:

.. code:: bash

          $ docker logs peer0.org1.example.com

Understanding the Docker Compose topology
-----------------------------------------

The BYFN sample offers us two flavors of Docker Compose files, both of which
are extended from the ``docker-compose-base.yaml`` (located in the ``base``
folder).  Our first flavor, ``docker-compose-cli.yaml``, provides us with a
CLI container, along with an orderer, four peers.  We use this file
for the entirety of the instructions on this page.

BYFN 示例给我们提供了两种风格的 Docker Compose 文件，它们都继承自 ``docker-compose-base.yaml`` 
（在 ``base`` 目录下）。我们的第一种类型， ``docker-compose-cli.yaml`` ，给我们提供了一个 CLI 容器，
以及一个 orderer 容器，四个 peer 容器。我们用此文件来展开这个页面上的所有说明。

.. note:: the remainder of this section covers a docker-compose file designed for the
          SDK.  Refer to the `Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__
          repo for details on running these tests.

.. note:: 本节的剩余部分涵盖了为 SDK 设计的 docker-compose 文件。有关运行这些测试的详细信息，
          请参阅 `Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__ 仓库。

The second flavor, ``docker-compose-e2e.yaml``, is constructed to run end-to-end tests
using the Node.js SDK.  Aside from functioning with the SDK, its primary differentiation
is that there are containers for the fabric-ca servers.  As a result, we are able
to send REST calls to the organizational CAs for user registration and enrollment.

第二种风格是 `docker-compose-e2e.yaml` ，被构造为使用 Node.js SDK 来运行端到端测试。
除了 SDK 的功能之外，它主要的区别在于它有运行 fabric-ca 服务的容器。因此，
我们能够向组织的 CA 节点发送用于注册和登记用户的 REST 请求。

If you want to use the ``docker-compose-e2e.yaml`` without first running the
byfn.sh script, then we will need to make four slight modifications.
We need to point to the private keys for our Organization's CA's.  You can locate
these values in your crypto-config folder.  For example, to locate the private
key for Org1 we would follow this path - ``crypto-config/peerOrganizations/org1.example.com/ca/``.
The private key is a long hash value followed by ``_sk``.  The path for Org2
would be - ``crypto-config/peerOrganizations/org2.example.com/ca/``.

如果你在没有运行 `byfn.sh` 脚本的情况下，想使用 `docker-compose-e2e.yaml` ，
我们需要进行四个轻微的修改。我们需要指出本组织 CA 的私钥。你可以在 `crypto-config` 
文件夹中找到这些值。举个例子，为了定位 Org1 的私钥，我们将使用 
`crypto-config/peerOrganizations/org1.example.com/ca/` 。Org2 的路径为 
`crypto-config/peerOrganizations/org2.example.com/ca/` 。

In the ``docker-compose-e2e.yaml`` update the FABRIC_CA_SERVER_TLS_KEYFILE variable
for ca0 and ca1.  You also need to edit the path that is provided in the command
to start the ca server.  You are providing the same private key twice for each
CA container.

在 `docker-compose-e2e.yaml` 里为 ca0 和 ca1 更新 FABRIC_CA_SERVER_TLS_KEYFILE 变量。
你同样需要编辑 command 中启动 ca server 的路径。你为每个 CA 容器提供了两次同样的私钥。


Using CouchDB - 使用CouchDB
-------------

The state database can be switched from the default (goleveldb) to CouchDB.
The same chaincode functions are available with CouchDB, however, there is the
added ability to perform rich and complex queries against the state database
data content contingent upon the chaincode data being modeled as JSON.

.. note:: The Fabric chaincode lifecycle that is being introduced in the v2.0
          Alpha release does not support using indexes with CouchDB. However,
          you can still use CouchDB as the state database and follow the steps
          below.

To use CouchDB instead of the default database (goleveldb), follow the same
procedures outlined earlier for generating the artifacts, except when starting
the network pass ``docker-compose-couch.yaml`` as well:

使用 CouchDB 代替默认的数据库（goleveldb），除了在启动网络的时侯传递 `docker-compose-couch.yaml` 
之外，请遵循前面提到的生成配置文件的过程：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d

**abstore** should now work using CouchDB underneath.

.. note::  If you choose to implement mapping of the fabric-couchdb container
           port to a host port, please make sure you are aware of the security
           implications. Mapping of the port in a development environment makes the
           CouchDB REST API available, and allows the
           visualization of the database via the CouchDB web interface (Fauxton).
           Production environments would likely refrain from implementing port mapping in
           order to restrict outside access to the CouchDB containers.

.. note::  如果你选择将 fabric-couchdb 容器端口映射到主机端口，请确保你意识到了安全性的影响。
           在开发环境中映射端口可以使 CouchDB REST API 可用，并允许通过 CouchDB Web 界面（Fauxton）
           对数据库进行可视化。生产环境将避免端口映射，以限制对 CouchDB 容器的外部访问。
	   
You can use **abstore** chaincode against the CouchDB state database
using the steps outlined above, however in order to exercise the CouchDB query
capabilities you will need to use a chaincode that has data modeled as JSON.
The sample chaincode **marbles02** has been written to demostrate the queries
you can issue from your chaincode if you are using a CouchDB database. You can
locate the **marbles02** chaincode in the ``fabric/examples/chaincode/go``
directory.

We will follow the same process to create and join the channel as outlined in the
:ref:`peerenvvars` section above.  Once you have joined your peer(s) to the
channel, use the following steps to interact with the **marbles02** chaincode:


- Package and install the chaincode on ``peer0.org1.example.com``:

.. code:: bash

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

       # be sure to modify the $CHANNEL_NAME variable accordingly for the instantiate command

       peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name marbles --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

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

       # be sure to modify the $CHANNEL_NAME variable accordingly for the instantiate command

       peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name marbles --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent
       peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name marbles --version 1.0 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --waitForEvent

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

-  If you chose to map the CouchDB ports in docker-compose, you can now view
   the state database through the CouchDB web interface (Fauxton) by opening
   a browser and navigating to the following URL:

   ``http://localhost:5984/_utils``

-  如果你选择在 docker-compose 文件中映射你的 CouchDB 的端口，
   那么你现在就可以用浏览器打开下面的 URL 来使用 CouchDB Web 界面（Fauxton）：

   ``http://localhost:5984/_utils``

You should see a database named ``mychannel`` (or your unique channel name) and
the documents inside it.

你应该可以看到一个名为 `mychannel` （或者你唯一的通道名字）的数据库以及它的文档在里面：

.. note:: For the below commands, be sure to update the $CHANNEL_NAME variable appropriately.

.. note:: 对于下面的命令，请确定 $CHANNEL_NAME 变量被更新了。

You can run regular queries from the CLI (e.g. reading ``marble2``):

你可以 CLI 中运行常规的查询（例如读取 ``marble2`` ）：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["readMarble","marble2"]}'

The output should display the details of ``marble2``:

``marble2`` 的详细输出应该显示为：

.. code:: bash

       Query Result: {"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}

You can retrieve the history of a specific marble - e.g. ``marble1``:

你可以检索特定玻璃球的历史记录 - 例如 ``marble1``:

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["getHistoryForMarble","marble1"]}'

The output should display the transactions on ``marble1``:

关于 ``marble1`` 的交易的输出：

.. code:: bash

      Query Result: [{"TxId":"1c3d3caf124c89f91a4c0f353723ac736c58155325f02890adebaa15e16e6464", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}},{"TxId":"755d55c281889eaeebf405586f9e25d71d36eb3d35420af833a20a2f53a3eefd", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"jerry"}},{"TxId":"819451032d813dde6247f85e56a89262555e04f14788ee33e28b232eef36d98f", "Value":}]

You can also perform rich queries on the data content, such as querying marble fields by owner ``jerry``:

你还可以对数据内容执行丰富的查询，例如通过拥有者 ``jerry`` 查询玻璃球：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesByOwner","jerry"]}'

The output should display the two marbles owned by ``jerry``:

输出应该显示出两个属于 ``jerry`` 的玻璃球：

.. code:: bash

       Query Result: [{"Key":"marble2", "Record":{"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}},{"Key":"marble3", "Record":{"color":"blue","docType":"marble","name":"marble3","owner":"jerry","size":70}}]


Why CouchDB - 为什么是 CouchDB
-------------
CouchDB is a kind of NoSQL solution. It is a document-oriented database where document fields are stored as key-value maps. Fields can be either a simple key-value pair, list, or map.

CouchDB 是一种 NoSQL 解决方案。它是一个面向文档的数据库，
其中文档字段存储为键值映射。字段可以是简单的键值对、列表或映射。

In addition to keyed/composite-key/key-range queries which are supported by LevelDB, CouchDB also supports full data rich queries capability, such as non-key queries against the whole blockchain data,
since its data content is stored in JSON format and fully queryable. Therefore, CouchDB can meet chaincode, auditing, reporting requirements for many use cases that not supported by LevelDB.

除了 LevelDB 支持的键值、复合键、键范围查询外，CouchDB 还支持完整数据的富查询功能，
例如针对整个区块链数据的无键查询，因为其数据内容以 JSON 格式存储所以是可查询的。
因此，CouchDB 可以用于链码，审计和需求报告等许多 LevelDB 不支持的用例。

CouchDB can also enhance the security for compliance and data protection in the blockchain. As it is able to implement field-level security through the filtering and masking of individual attributes within a transaction, and only authorizing the read-only permission if needed.

CouchDB 还可以增强区块链中的合规性和数据保护的安全性。 
因为它能够通过过滤和屏蔽事务中的各个属性来实现字段级安全性，并且在需要时只授权只读权限。

In addition, CouchDB falls into the AP-type (Availability and Partition Tolerance) of the CAP theorem. It uses a master-master replication model with ``Eventual Consistency``.
More information can be found on the
`Eventual Consistency page of the CouchDB documentation <http://docs.couchdb.org/en/latest/intro/consistency.html>`__.

此外，CouchDB 属于 CAP 定理的 AP 类型（可用性和分区容错性）。
它使用具有 ``最终一致性`` 的主-主复制模型。更多的信息可以在这里找到： 
`Eventual Consistency page of the CouchDB documentation <http://docs.couchdb.org/en/latest/intro/consistency.html>`__ 。

However, under each fabric peer, there is no database replicas, writes to database are guaranteed consistent and durable (not ``Eventual Consistency``).

但是，在每一个 fabric 节点下，没有复制数据库，写入数据是保证一致性和持久性的（不是 ``最终一致性`` ）。

CouchDB is the first external pluggable state database for Fabric, and there could and should be other external database options. For example, IBM enables the relational database for its blockchain.
And the CP-type (Consistency and Partition Tolerance) databases may also in need, so as to enable data consistency without application level guarantee.

CouchDB 是 Fabric 的第一个外部可插拔状态数据库，可能也应该有其他外部数据库选项。 
例如，IBM 为其区块链启用了关系数据库。并且 CP 类型（一致性和分区容错性）数据库也可能需要，
以便在没有应用程序级别保证的情况下实现数据一致性。

A Note on Data Persistence - 关于数据持久化的提示
--------------------------

If data persistence is desired on the peer container or the CouchDB container,
one option is to mount a directory in the docker-host into a relevant directory
in the container. For example, you may add the following two lines in
the peer container specification in the ``docker-compose-base.yaml`` file:

如果需要在节点容器或者 CouchDB 容器进行数据持久化，一种选择是将 docker 容器内相应的目录挂载到
容器所在的宿主机的一个目录中。例如，你可以添加下列的两行到 ``docker-compose-base.yaml`` 文件中
指定节点容器的配置中：

.. code:: bash

       volumes:
        - /var/hyperledger/peer0:/var/hyperledger/production

For the CouchDB container, you may add the following two lines in the CouchDB
container specification:

对于 CouchDB 容器，你可以在 CouchDB 的约定中添加两行：

.. code:: bash

       volumes:
        - /var/hyperledger/couchdb0:/opt/couchdb/data

.. _Troubleshoot:

Troubleshooting - 故障排除
---------------

-  Always start your network fresh.  Use the following command
   to remove artifacts, crypto, containers and chaincode images:

-  始终保持你的网络是全新的。
   使用以下命令来移除之前生成的构件，证书文件，容器以及链码镜像：

   .. code:: bash

      ./byfn.sh down

   .. note:: You **will** see errors if you do not remove old containers
             and images.
             
   .. note:: 你 **将会** 看到错误信息，如果你不移除旧的容器和镜像

-  If you see Docker errors, first check your docker version (:doc:`prereqs`),
   and then try restarting your Docker process.  Problems with Docker are
   oftentimes not immediately recognizable.  For example, you may see errors
   resulting from an inability to access crypto material mounted within a
   container.
   
-  如果你看到相关的 Docker 错误信息，首先检查你的版本（ :doc:`prereqs` ），
   然后重启你的 Docker 进程。Docker 的问题通常不会被立即识别。
   例如，你可能看到由于容器内未能找到密钥材料导致的错误。

   If they persist remove your images and start from scratch:

   如果坚持删除你的镜像，并从头开始：
   
   .. code:: bash

       docker rm -f $(docker ps -aq)
       docker rmi -f $(docker images -q)

-  If you see errors on your create, approve, commit, invoke or query commands,
   make sure you have properly updated the channel name and chaincode name.
   There are placeholder values in the supplied sample commands.

-  If you see the below error:

-  如果你看到如下错误：

   .. code:: bash

       Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)

   You likely have chaincode images (e.g. ``dev-peer1.org2.example.com-mycc-1.0`` or
   ``dev-peer0.org1.example.com-mycc-1.0``) from prior runs. Remove them and try
   again.

   你可能有以前运行的链码镜像（例如 ``dev-peer1.org2.example.com-mycc-1.0`` 或 
   ``dev-peer0.org1.example.com-mycc-1.0`` ）。删除它们，然后重试。

   .. code:: bash

       docker rmi -f $(docker images | grep peer[0-9]-peer[0-9] | awk '{print $3}')

-  If you see something similar to the following:

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

      Error connecting: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure
      Error: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure

   Make sure you are running your network against the "1.0.0" images that have
   been retagged as "latest".

   请确保你的 fabric 网络运行在被标记为 “latest” 的 “1.0.0” 镜像上。

-  If you see the below error:

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

     [configtx/tool/localconfig] Load -> CRIT 002 Error reading configuration: Unsupported Config Type ""
     panic: Error reading configuration: Unsupported Config Type ""

   Then you did not set the ``FABRIC_CFG_PATH`` environment variable properly.  The
   configtxgen tool needs this variable in order to locate the configtx.yaml.  Go
   back and execute an ``export FABRIC_CFG_PATH=$PWD``, then recreate your
   channel artifacts.

   那么你没有正确设置 ``FABRIC_CFG_PATH`` 环境变量。configtxgen 工具需要这个
   变量才能找到 configtx.yaml。返回并执行 ``export FABRIC_CFG_PATH=$PWD`` ，
   然后重新创建通道构件。

-  To cleanup the network, use the ``down`` option:

-  要清理网络，请使用 ``down`` 选项：

   .. code:: bash

       ./byfn.sh down

-  If you see an error stating that you still have "active endpoints", then prune
   your Docker networks.  This will wipe your previous networks and start you with a
   fresh environment:

-  如果你看到一条指示你依然有 “active endpoints” ，然后你应该清理你的 Docker 网络。
   这将会清除你之前的网络并且给你一个全新的环境：

   .. code:: bash

        docker network prune

   You will see the following message:
   
   你会看到下面的内容：

   .. code:: bash

      WARNING! This will remove all networks not used by at least one container.
      Are you sure you want to continue? [y/N]

   Select ``y``.
   
   选择 ``y`` 。

-  If you see an error similar to the following:

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

      /bin/bash: ./scripts/script.sh: /bin/bash^M: bad interpreter: No such file or directory

   Ensure that the file in question (**script.sh** in this example) is encoded
   in the Unix format. This was most likely caused by not setting
   ``core.autocrlf`` to ``false`` in your Git configuration (see
   :ref:`windows-extras`). There are several ways of fixing this. If you have
   access to the vim editor for instance, open the file:

   请确保问题中的文件（本例是 **script.sh** ）被编码为 Unix 格式。
   这主要可能是由于你的 Git 配置没有设置 ``core.autocrlf`` 为 ``false`` 。
   有几种方法解决。例如，如果您有权访问 vim 编辑器，打开这个文件：

   .. code:: bash

      vim ./fabric-samples/first-network/scripts/script.sh

   Then change its format by executing the following vim command:

   通过下面的命令改变它的编码：

   .. code:: bash

      :set ff=unix

.. note:: If you continue to see errors, share your logs on the
          **fabric-questions** channel on
          `Hyperledger Rocket Chat <https://chat.hyperledger.org/home>`__
          or on `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger-fabric>`__.
   
.. note:: 如果你仍旧看到了错误，请把你的日志分享在 
          `Hyperledger Rocket Chat <https://chat.hyperledger.org/home>`__ **fabric-questions** 频道上或者
          `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger-fabric>`__ 。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
