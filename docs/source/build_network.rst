Building Your First Network - 创建你的第一个fabric网络
===========================

.. note:: These instructions have been verified to work against the
          latest stable Docker images and the pre-compiled
          setup utilities within the supplied tar file. If you run
          these commands with images or tools from the current master
          branch, it is possible that you will see configuration and panic
          errors.

.. note:: 这些说明已经被验证，它可以在最新稳定版的docker镜像和提供tar文件的预编译的安装实用程序中工作。如果你在当前分支下，通过镜像或者工具使用这些命令，可能会有一些配置或者panic错误。

The build your first network (BYFN) scenario provisions a sample Hyperledger
Fabric network consisting of two organizations, each maintaining two peer
nodes, and a "solo" ordering service.

在你构建的第一个网络(BYFN)场景中，提供了一个包含两个组织的Hyperledger Fabric网络。每个组织包含两个peer节点，一个"solo"模式的排序服务。

Install prerequisites - 安装准备
---------------------

Before we begin, if you haven't already done so, you may wish to check that
you have all the :doc:`prereqs` installed on the platform(s)
on which you'll be developing blockchain applications and/or operating
Hyperledger Fabric.

在我们开始之前，如果你什么都没做，你也许应该在你想要部署学习区块链和/或者操作Hyperledger Fabric网络的平台上，检查你是否做了预置环境的安装 :doc:`prereqs`。

You will also need to :doc:`install`. You will notice
that there are a number of samples included in the ``fabric-samples``
repository. We will be using the ``first-network`` sample. Let's open that
sub-directory now.

你还需要去安装一些示例，二进制文件和docker镜像 :doc:`install`。`fabric-samples`中包含了许多示例。我们将使用 `first-network`作为例子。现在我们一起打开这个子目录。

.. code:: bash

  cd fabric-samples/first-network

.. note:: The supplied commands in this documentation
          **MUST** be run from your ``first-network`` sub-directory
          of the ``fabric-samples`` repository clone.  If you elect to run the
          commands from a different location, the various provided scripts
          will be unable to find the binaries.

.. note:: 这个文档里提供的命令 **必须** 要运行在你克隆的``fabric-samples``项目的子目录 ``first-network``里。如果你选择从不同的位置运行命令，提供的那些脚本将无法找到二进制文件。

Want to run it now? - 想要现在运行吗？
-------------------

We provide a fully annotated script - ``byfn.sh`` - that leverages these Docker
images to quickly bootstrap a Hyperledger Fabric network comprised of 4 peers
representing two different organizations, and an orderer node. It will also
launch a container to run a scripted execution that will join peers to a
channel, deploy and instantiate chaincode and drive execution of transactions
against the deployed chaincode.

我们提供了一个被全部注释的脚本 - ``byfn.sh`` - 它可以通过镜像快速启动一个Hyperledger Fabric网络，这个网络由代表两个组织的四个peer节点，一个排序节点组成。它还将启动一个容器用于运行一个将peer节点加入channel、部署并且实例化链码服务以及驱动已经部署的链码执行交易的脚本。

Here's the help text for the ``byfn.sh`` script:

以下是该脚本 ``byfn.sh``的帮助文档：

.. code:: bash

  Usage:
    byfn.sh <mode> [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>] [-l <language>] [-i <imagetag>] [-v]
      <mode> - one of 'up', 'down', 'restart', 'generate' or 'upgrade'
        - 'up' - bring up the network with docker-compose up
        - 'down' - clear the network with docker-compose down
        - 'restart' - restart the network
        - 'generate' - generate required certificates and genesis block
        - 'upgrade'  - upgrade the network from v1.0.x to v1.1
      -c <channel name> - channel name to use (defaults to "mychannel")
      -t <timeout> - CLI timeout duration in seconds (defaults to 10)
      -d <delay> - delay duration in seconds (defaults to 3)
      -f <docker-compose-file> - specify which docker-compose file use (defaults to docker-compose-cli.yaml)
      -s <dbtype> - the database backend to use: goleveldb (default) or couchdb
      -l <language> - the chaincode language: golang (default), node or java
      -i <imagetag> - the tag to be used to launch the network (defaults to "latest")
      -v - verbose mode
    byfn.sh -h (print this message)

  Typically, one would first generate the required certificates and
  genesis block, then bring up the network. e.g.:

	  byfn.sh generate -c mychannel
	  byfn.sh up -c mychannel -s couchdb
          byfn.sh up -c mychannel -s couchdb -i 1.1.0-alpha
	  byfn.sh up -l node
	  byfn.sh down -c mychannel
          byfn.sh upgrade -c mychannel

  Taking all defaults:
	  byfn.sh generate
	  byfn.sh up
	  byfn.sh down

If you choose not to supply a channel name, then the
script will use a default name of ``mychannel``.  The CLI timeout parameter
(specified with the -t flag) is an optional value; if you choose not to set
it, then the CLI will give up on query requests made after the default
setting of 10 seconds.

如果你选择不提供通道名称，脚本会使用默认的通道名称mychannel。CLI的超时参数(用-t标志标识)是可选的.如果你不设置它，Cli 会放弃在默认设置的十秒之后进行查询请求

Generate Network Artifacts - 生成网络构件
^^^^^^^^^^^^^^^^^^^^^^^^^^

Ready to give it a go? Okay then! Execute the following command:

准备好了没？OK，执行下面的命令：

.. code:: bash

  ./byfn.sh generate

You will see a brief description as to what will occur, along with a yes/no command line
prompt. Respond with a ``y`` or hit the return key to execute the described action.

伴随命令行提示yes/no，你会看到将要发生什么的一些简要说明。输入Y或者返回键来执行描述的动作。

.. code:: bash

  Generating certs and genesis block for with channel 'mychannel' and CLI timeout of '10'
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

第一步为我们各种网络实体生成证书和秘钥。初始区块 ``genesis block``用于引导排序服务，也包含了一组用于配置 :ref:`Channel` 所需要的一组配置交易集合。

Bring Up the Network - 启动网络
^^^^^^^^^^^^^^^^^^^^

Next, you can bring the network up with one of the following commands:

接下来，你可以用下面的命令启动网络：

.. code:: bash

  ./byfn.sh up

The above command will compile Golang chaincode images and spin up the corresponding
containers.  Go is the default chaincode language, however there is also support
for `Node.js <https://fabric-shim.github.io/>`_ and `Java <https://fabric-chaincode-java.github.io/>`_
chaincode.  If you'd like to run through this tutorial with node
chaincode, pass the following command instead:

上面的命令会编译Golang智能合约的镜像并且在对应的镜像中启动。Go语言是默认的智能合约语言，但是它也支持Node.js`Node.js <https://fabric-shim.github.io/>`_ 和 `Java <https://fabric-chaincode-java.github.io/>`_的 chaincode.如果你想要在这个教程里运行node智能合约，你可以通过下面的命令替代：

.. code:: bash

  # we use the -l flag to specify the chaincode language
  # forgoing the -l flag will default to Golang

  ./byfn.sh up -l node

.. note:: For more information on the Node.js shim, please refer to its
          `documentation <https://fabric-shim.github.io/ChaincodeInterface.html>`_.

.. note:: 查看 `documentation <https://fabric-shim.github.io/fabric-shim.ChaincodeInterface.html>`_ 获取更多关于node.js 智能合约的 shim API 信息。

.. note:: For more information on the Java shim, please refer to its
          `documentation <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_.
          
.. note:: 查看 `documentation <https://fabric-chaincode-java.github.io/org/hyperledger/fabric/shim/Chaincode.html>`_ 获取更多关于 Java 智能合约的 shim API 信息。

Тo make the sample run with Java chaincode, you have to specify ``-l java`` as follows:

为了能够让例子运行并使用 Java chaincode，你需要像下边这样指定 ``-l java``:

.. code:: bash

  ./byfn.sh up -l java

.. note:: Do not run both of these commands. Only one language can be tried unless
          you bring down and recreate the network between.

Once again, you will be prompted as to whether you wish to continue or abort.
Respond with a ``y`` or hit the return key:

再一次，您将被提示是否要继续或中止。用y或者按下返回键表示响应。

.. code:: bash

  Starting with channel 'mychannel' and CLI timeout of '10'
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

日志会从那里继续。这一步会启动所有的容器，然后驱动一个完整的 end-to-end 应用场景。完成后，它应该在您的终端窗口中报告以下内容:

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

你可以滚动这些日志去查看各种交易。如果你没有获得这个结果，请移步疑难解答部分 :ref:`Troubleshoot`，看看我们是否可以帮助你发现问题。

Bring Down the Network - 关闭网络
^^^^^^^^^^^^^^^^^^^^^^

Finally, let's bring it all down so we can explore the network setup one step
at a time. The following will kill your containers, remove the crypto material
and four artifacts, and delete the chaincode images from your Docker Registry:

最后，让我们把他停下来，这样我们可以一步步探索网络设置。接下来的命令会结束掉你所有的容器，移除加密的材料和4个配置信息。并且从Docker仓库删除chinacode镜像。

.. code:: bash

  ./byfn.sh down

Once again, you will be prompted to continue, respond with a ``y`` or hit the return key:

再一次，您将被提示是否要继续或中止。用y或者按下返回键表示响应。

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

如果你想要了解更多关于底层工具和引导材料的信息，继续阅读。在接下来的章节，我们将浏览构建一个功能完整的Hyperledger Fabric 网络的各个步骤和要求。

.. note:: The manual steps outlined below assume that the ``FABRIC_LOGGING_SPEC`` in
          the ``cli`` container is set to ``DEBUG``. You can set this by modifying
          the ``docker-compose-cli.yaml`` file in the ``first-network`` directory.
          e.g.

.. note:: 下面列出的手动步骤设置假想在 ``cli``容器中的 ``CORE_LOGGING_LEVEL``设置为``DEBUG``。你可以通过编辑 在``first-network``中的``docker-compose-cli.yaml``文件来设置他。

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

我们将使用``cryptogen``工具生成各种网络实体的加密材料（x509证书）。这些证书是身份的代表，在实体之间交流和交易的时候，它们允许对身份验证进行签名/验证。

How does it work? - 它是怎么工作的？
^^^^^^^^^^^^^^^^^

Cryptogen consumes a file - ``crypto-config.yaml`` - that contains the network
topology and allows us to generate a set of certificates and keys for both the
Organizations and the components that belong to those Organizations.  Each
Organization is provisioned a unique root certificate (``ca-cert``) that binds
specific components (peers and orderers) to that Org.  By assigning each
Organization a unique CA certificate, we are mimicking a typical network where
a participating :ref:`Member` would use its own Certificate Authority.
Transactions and communications within Hyperledger Fabric are signed by an
entity's private key (``keystore``), and then verified by means of a public
key (``signcerts``).

Cryptogen 通过一个包含网络拓扑的文件``crypto-config.yaml``，为所有组织和属于这些组织的组件生成一组证书和秘钥。每一个组织被分配一个唯一的根证书(``ca-cert``)，它绑定该组织的特定组件(peers and orderers)。通过为每个组织分配一个惟一的CA证书，我们模拟了一个参与人员  :ref:`Member` 将使用它自己的认证授权的典型的网络。超级账本中的事务和通信是由一个实体的私钥（(``keystore``）签名的，然后通过公钥（``signcerts``）验证。

You will notice a ``count`` variable within this file.  We use this to specify
the number of peers per Organization; in our case there are two peers per Org.
We won't delve into the minutiae of `x.509 certificates and public key
infrastructure <https://en.wikipedia.org/wiki/Public_key_infrastructure>`__
right now. If you're interested, you can peruse these topics on your own time.

在这个文件里你会发现一个 ``count``变量。我们通过它来指定每个组织的peer节点数量。在我们的案例里每隔组织有两个peer节点。我们现在不会深入研究`x.509 certificates and public key
infrastructure <https://en.wikipedia.org/wiki/Public_key_infrastructure>`__细节。如果你有兴趣，你可以在自己的时间细读这些主题。

Before running the tool, let's take a quick look at a snippet from the
``crypto-config.yaml``. Pay specific attention to the "Name", "Domain"
and "Specs" parameters under the ``OrdererOrgs`` header:

在运行该工具之前，我们快速浏览一下``crypto-config.yaml``的一段代码。特别注意``OrdererOrgs`` 头结点下“Name”，Domain"和 "Specs"参数。

.. code:: bash

  OrdererOrgs:
  #---------------------------------------------------------
  # Orderer
  # --------------------------------------------------------
  - Name: Orderer
    Domain: example.com
    CA:
        Country: US
        Province: California
        Locality: San Francisco
    #   OrganizationalUnit: Hyperledger Fabric
    #   StreetAddress: address for org # default nil
    #   PostalCode: postalCode for org # default nil
    # ------------------------------------------------------
    # "Specs" - See PeerOrgs below for complete description
  # -----------------------------------------------------
    Specs:
      - Hostname: orderer
  # -------------------------------------------------------
  # "PeerOrgs" - Definition of organizations managing peer nodes
   # ------------------------------------------------------
  PeerOrgs:
  # -----------------------------------------------------
  # Org1
  # ----------------------------------------------------
  - Name: Org1
    Domain: org1.example.com
    EnableNodeOUs: true

The naming convention for a network entity is as follows -
"{{.Hostname}}.{{.Domain}}".  So using our ordering node as a
reference point, we are left with an ordering node named -
``orderer.example.com`` that is tied to an MSP ID of ``Orderer``.  This file
contains extensive documentation on the definitions and syntax.  You can also
refer to the :doc:`msp` documentation for a deeper dive on MSP.

网络实体的命名约定如下:“{{. hostname}}.{{. domain}}”。因此，使用我们的order节点作为参考点，我们只剩下一个order节点—``orderer.example.com``，它与Orderer的MSP ID绑定在一起。

After we run the ``cryptogen`` tool, the generated certificates and keys will be
saved to a folder titled ``crypto-config``.

在我们运行``cryptogen``工具之后，生成的证书和密钥将是保存到一个名为``crypto-config``的文件夹中。

Configuration Transaction Generator - 配置交易生成器
-----------------------------------

The ``configtxgen`` tool is used to create four configuration artifacts:

  * orderer ``genesis block``,
  * channel ``configuration transaction``,
  * and two ``anchor peer transactions`` - one for each Peer Org.

``configtxgen`` 工具用来创建四个配置构件:

- order节点的初始区块 ``genesis block``,
- 通道配置事务``configuration transaction``,
- 两个锚节点交易 ``anchor peer transactions`` - 一个对应一个Peer组织。

Please see :doc:`commands/configtxgen` for a complete description of this tool's functionality.

有关此工具的完整说明，请参阅 :doc:`commands/configtxgen`

The orderer block is the :ref:`Genesis-Block` for the ordering service, and the
channel configuration transaction file is broadcast to the orderer at :ref:`Channel` creation
time.  The anchor peer transactions, as the name might suggest, specify each
Org's :ref:`Anchor-Peer` on this channel.

order block 是 排序服务的初始区块`Genesis-Block`，channel configuration transaction在 :ref:`Channel` 创建的时候广播给排序服务。 anchor peer transactions，正如名称所示，指定了每个组织在此channel上的 :ref:`Anchor-Peer` 。

How does it work? -它是怎么工作的？
^^^^^^^^^^^^^^^^^

Configtxgen consumes a file - ``configtx.yaml`` - that contains the definitions
for the sample network. There are three members - one Orderer Org (``OrdererOrg``)
and two Peer Orgs (``Org1`` & ``Org2``) each managing and maintaining two peer nodes.
This file also specifies a consortium - ``SampleConsortium`` - consisting of our
two Peer Orgs.  Pay specific attention to the "Profiles" section at the top of
this file.  You will notice that we have two unique headers. One for the orderer genesis
block - ``TwoOrgsOrdererGenesis`` - and one for our channel - ``TwoOrgsChannel``.

Configtxgen 使用一个文件- ``configtx.yaml``，这个文件包含了一个示例网络的定义。它拥有三个成员：一个Order组织（``OrdererOrg``） 和两个 Peer 组织(``Org1`` & ``Org2``)，这两个peer组织每个都管理和维护两个peer节点。

These headers are important, as we will pass them in as arguments when we create
our artifacts.

这些标题很重要，因为在我们创建我们的网络各项构件的时侯它们将作为传递的参数。

.. note:: Notice that our ``SampleConsortium`` is defined in
          the system-level profile and then referenced by
          our channel-level profile.  Channels exist within
          the purview of a consortium, and all consortia
          must be defined in the scope of the network at
          large.

.. note:: 注意我们的 ``SampleConsortium`` 在系统级配置文件中定义，并且在通道级的配置文件中关联引用。管道存在于联盟的范围内，所有的联盟必须定义在整个网络范围内。

This file also contains two additional specifications that are worth
noting. Firstly, we specify the anchor peers for each Peer Org
(``peer0.org1.example.com`` & ``peer0.org2.example.com``).  Secondly, we point to
the location of the MSP directory for each member, in turn allowing us to store the
root certificates for each Org in the orderer genesis block.  This is a critical
concept. Now any network entity communicating with the ordering service can have
its digital signature verified.

该文件还包含两个值得注意的附加规范。第一，我们为每个组织指定了锚节点（``peer0.org1.example.com`` & ``peer0.org2.example.com``）。第二，我们为每个成员指定MSP文件位置，进而让我们可以在order的初始区块中存储每个组织的根证书。这是一个关键概念。现在每个和order service 服务通信的网络实体都有它自己的被验证过的数字签名证书。

Run the tools - 运行工具
-------------

You can manually generate the certificates/keys and the various configuration
artifacts using the ``configtxgen`` and ``cryptogen`` commands. Alternately,
you could try to adapt the byfn.sh script to accomplish your objectives.

你可以用`configtxgen`和`cryptogen`命令来手动生成证书/密钥和各种配置文件。或者，你可以尝试使用`byfn.sh`脚本来完成你的目标。


Manually generate the artifacts - 手动生成构件
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can refer to the ``generateCerts`` function in the byfn.sh script for the
commands necessary to generate the certificates that will be used for your
network configuration as defined in the ``crypto-config.yaml`` file. However,
for the sake of convenience, we will also provide a reference here.

你可以参考 byfn.sn脚本中的``generateCerts`` 函数，生成证书所需要的命令。它将会在 ``crypto-config.yaml``文件中被定义，作为你的网络配置使用。然而,为了方便起见，我们在这里也提供一个参考。

First let's run the ``cryptogen`` tool.  Our binary is in the ``bin``
directory, so we need to provide the relative path to where the tool resides.

首先，让我们来运行``cryptogen`` 工具。我们的这个二进制文件存放在 ``bin`` 文件目录下，所以我们需要提供工具所在的相对路径。

.. code:: bash

    ../bin/cryptogen generate --config=./crypto-config.yaml

You should see the following in your terminal:

你会在你的终端中看到下面的内容：

.. code:: bash

  org1.example.com
  org2.example.com

The certs and keys (i.e. the MSP material) will be output into a directory - ``crypto-config`` -
at the root of the ``first-network`` directory.

证书和秘钥 (i.e. the MSP material)将会输出在文件夹- ``crypto-config`` 。位置在 ``first-network``文件夹的根目录。

Next, we need to tell the ``configtxgen`` tool where to look for the
``configtx.yaml`` file that it needs to ingest.  We will tell it look in our
present working directory:

接下来，我们需要告诉`configtxgen`工具去哪儿去寻找 它需要提取内容的`configtx.yaml`文件。我们会告诉它在我们当前所在工作目录：

.. code:: bash

    export FABRIC_CFG_PATH=$PWD

Then, we'll invoke the ``configtxgen`` tool to create the orderer genesis block:

然后我们会调用``configtxgen`` 工具去创建初始区块：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsOrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

You should see an output similar to the following in your terminal:

你可以在你的终端看到相似的输出：

.. code:: bash

  2017-10-26 19:21:56.301 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
  2017-10-26 19:21:56.309 EDT [common/tools/configtxgen] doOutputBlock -> INFO 002 Generating genesis block
  2017-10-26 19:21:56.309 EDT [common/tools/configtxgen] doOutputBlock -> INFO 003 Writing genesis block

.. note:: The orderer genesis block and the subsequent artifacts we are about to create
          will be output into the ``channel-artifacts`` directory at the root of this
          project. The `channelID` in the above command is the name of the system channel.

.. note:: 我们创建的 orderer初始区块和随后的网络构件将会输出在这个项目的根目录， ``channel-artifacts`` 文件夹下。

.. _createchanneltx:

Create a Channel Configuration Transaction - 创建通道配置交易
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Next, we need to create the channel transaction artifact. Be sure to replace ``$CHANNEL_NAME`` or
set ``CHANNEL_NAME`` as an environment variable that can be used throughout these instructions:

接下来，我们需要去创建通道的交易构件。请确保替换`$CHANNEL_NAME`或者将`CHANNEL_NAME`设置为整个说明中可以使用的环境变量：

.. code:: bash

    # The channel.tx artifact contains the definitions for our sample channel

    export CHANNEL_NAME=mychannel  && ../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

You should see an output similar to the following in your terminal:

你可以在终端中看到一份相似的输出：

.. code:: bash

  2017-10-26 19:24:05.324 EDT [common/tools/configtxgen] main -> INFO 001 Loading configuration
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 002 Generating new channel configtx
  2017-10-26 19:24:05.329 EDT [common/tools/configtxgen] doOutputChannelCreateTx -> INFO 003 Writing new channel tx

Next, we will define the anchor peer for Org1 on the channel that we are
constructing. Again, be sure to replace ``$CHANNEL_NAME`` or set the environment variable
for the following commands.  The terminal output will mimic that of the channel transaction artifact:

接下来，我们会为我们构建的通道上的Org1定义锚节点。请再次确认$CHANNEL_NAME已被替换或者为以下命令设置了环境变量：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

Now, we will define the anchor peer for Org2 on the same channel:

现在，我们将在同一个通道上为Org2定义锚节点 `anchor peer`：

.. code:: bash

    ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP

Start the network - 启动网络
-----------------

.. note:: If you ran the ``byfn.sh`` example above previously, be sure that you
          have brought down the test network before you proceed (see
          `Bring Down the Network`_).

.. note:: 如果之前启动了 ``byfn.sh``例子，再继续之前确认一下你已经把这个测试网络关掉了(查看 `Bring Down the Network`_)。

We will leverage a script to spin up our network. The
docker-compose file references the images that we have previously downloaded,
and bootstraps the orderer with our previously generated ``genesis.block``.

我们将使用一个脚本启动我们的网络。docker-compose file关联了我们之前下载的镜像，然后通过我们之前生成的初始区块``genesis.block``引导orderer。

We want to go through the commands manually in order to expose the
syntax and functionality of each call.

我们想要通过手动运行那些命令，目的是为了发现语法和每个调用的功能。

First let's start our network:

首先启动我们的网络：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml up -d

If you want to see the realtime logs for your network, then do not supply the ``-d`` flag.
If you let the logs stream, then you will need to open a second terminal to execute the CLI calls.

如果你想要实时查看你的网络日志，请不要加  ``-d``标识。如果你想要日志流，你需要打开第二个终端来执行CLI命令。

.. _peerenvvars:

Environment variables - 环境变量
^^^^^^^^^^^^^^^^^^^^^

For the following CLI commands against ``peer0.org1.example.com`` to work, we need
to preface our commands with the four environment variables given below.  These
variables for ``peer0.org1.example.com`` are baked into the CLI container,
therefore we can operate without passing them.  **HOWEVER**, if you want to send
calls to other peers or the orderer, then you can provide these
values accordingly by editing the  ``docker-compose-base.yaml`` before starting the
container. Modify the following four environment variables to use a different
peer and org.

为了使针对`peer0.org1.example.com`的CLI命令起作用，我们需要使用下面给出四个环境变量来介绍我们的命令。这些关于``peer0.org1.example.com`` 的命令已经被拷贝到CLI容器中，因此我们不需要复制他们就能使用。然而如果你想发送调用到别的peers或者orderers，你就需要再启动容器之前，通过编辑 ``docker-compose-base.yaml``文件来提供这些值。修改下面的环境变量可以使用不同的peer和org。

.. code:: bash

    # Environment variables for PEER0

    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

.. _createandjoin:

Create & Join Channel - 创建和加入通道
^^^^^^^^^^^^^^^^^^^^^

Recall that we created the channel configuration transaction using the
``configtxgen`` tool in the :ref:`createchanneltx` section, above. You can
repeat that process to create additional channel configuration transactions,
using the same or different profiles in the ``configtx.yaml`` that you pass
to the ``configtxgen`` tool. Then you can repeat the process defined in this
section to establish those other channels in your network.

回想一下，我们在:ref:`createchanneltx`章节中使用``configtxgen`` 工具创建通道配置交易。你可以使用在``configtx.yaml``中相同或者不同的传给``configtxgen``工具的配置，重复之前的过程来创建一个额外的通道配置交易。然后你可以重复在章节中的过程去发布一个另外的通道到你的网络中。

We will enter the CLI container using the ``docker exec`` command:

我们可以使用 ``docker exec`` 输入CLI容器命令:

.. code:: bash

        docker exec -it cli bash

If successful you should see the following:

成功的话你会看到下面的输出：

.. code:: bash

        root@0d78bb69300d:/opt/gopath/src/github.com/hyperledger/fabric/peer#

If you do not want to run the CLI commands against the default peer
``peer0.org1.example.com``, replace the values of ``peer0`` or ``org1`` in the
four environment variables and run the commands:

如果你不想对默认的peer``peer0.org1.example.com``运行cli命令，替换在四个环境变量中的 ``peer0`` or ``org1`` 值，然后运行命令：

.. code:: bash

    # Environment variables for PEER0

    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

Next, we are going to pass in the generated channel configuration transaction
artifact that we created in the :ref:`createchanneltx` section (we called
it ``channel.tx``) to the orderer as part of the create channel request.

接下来，我们会把在:ref:`createchanneltx`章节中创建的通道配置交易构件（我们称之为``channel.tx``）作为创建通道请求的一部分传递给orderer。

We specify our channel name with the ``-c`` flag and our channel configuration
transaction with the ``-f`` flag. In this case it is ``channel.tx``, however
you can mount your own configuration transaction with a different name.  Once again
we will set the ``CHANNEL_NAME`` environment variable within our CLI container so that
we don't have to explicitly pass this argument. Channel names must be all lower
case, less than 250 characters long and match the regular expression
``[a-z][a-z0-9.-]*``.

我们使用 ``-c`` 标志指定通道的名称，``-f``标志指定通道配置交易。在这个例子中它是 ``channel.tx``，当然你也可以使用不同的名称，挂载你自己的交易配置。我们将再次在CLI容器中设置``CHANNEL_NAME``环境变量，这样我们就不要显示的传递这个参数。通道的名称必须全部是消息字母，小于250个字符，并且匹配正则表达式``[a-z][a-z0-9.-]*``。

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

.. note:: 注意``--cafile``会作为命令的一部分。这是orderer的根证书的本地路径，允许我们去验证TLS握手。

This command returns a genesis block - ``<channel-ID.block>`` - which we will use to join the channel.
It contains the configuration information specified in ``channel.tx``  If you have not
made any modifications to the default channel name, then the command will return you a
proto titled ``mychannel.block``.

这个命令返回一个初始区块- ``<channel-ID.block>``。我们将会用它来加入通道。它包含了 ``channel.tx`` 中的配置信息。

.. note:: You will remain in the CLI container for the remainder of
          these manual commands. You must also remember to preface all commands
          with the corresponding environment variables when targeting a peer other than
          ``peer0.org1.example.com``.

.. note:: 你将在CLI容器中继续执行这些手动命令的其余部分。在针对``peer0.org1.example.com``节点之外的peer时，你必须记住用相应的环境变量作为所有命令的前言。

Now let's join ``peer0.org1.example.com`` to the channel.

现在让我们加入`peer0.org1.example.com`通道。

.. code:: bash

        # By default, this joins ``peer0.org1.example.com`` only
        # the <channel-ID.block> was returned by the previous command
        # if you have not modified the channel name, you will join with mychannel.block
        # if you have created a different channel name, then pass in the appropriately named block

         peer channel join -b mychannel.block

You can make other peers join the channel as necessary by making appropriate
changes in the four environment variables we used in the :ref:`peerenvvars`
section, above.

你可以通过适当的修改在:ref:`peerenvvars`章节中的四个环境变量来让其他的节点加入通道。

Rather than join every peer, we will simply join ``peer0.org2.example.com`` so that
we can properly update the anchor peer definitions in our channel.  Since we are
overriding the default environment variables baked into the CLI container, this full
command will be the following:

不是加入每一个peer，我们只是简单的加入 ``peer0.org2.example.com``以便我们可以更新定义在通道中的锚节点。由于我们正在覆盖CLI容器中融入的默认的环境变量，整个命令将会是这样：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

Alternatively, you could choose to set these environment variables individually
rather than passing in the entire string.  Once they've been set, you simply need
to issue the ``peer channel join`` command again and the CLI container will act
on behalf of ``peer0.org2.example.com``.

或者，您可以选择单独设置这些环境变量而不是传递整个字符串。设置完成后，只需再次发出``peer channel join`` 命令，然后CLI容器会代表``peer0.org2.example.com``起作用。

Update the anchor peers - 更新锚节点
^^^^^^^^^^^^^^^^^^^^^^^

The following commands are channel updates and they will propagate to the definition
of the channel.  In essence, we adding additional configuration information on top
of the channel's genesis block.  Note that we are not modifying the genesis block, but
simply adding deltas into the chain that will define the anchor peers.

接下来的命令是通道更新，它会传递到通道的定义中去。实际上，我们在通道的创世区块的头部添加了额外的配置信息。注意我们没有编辑初始区块，但是简单的将增量添加到将会定义锚节点的链中。

Update the channel definition to define the anchor peer for Org1 as ``peer0.org1.example.com``:

更新通道定义，将Org1的锚节点定义为``peer0.org1.example.com``。

.. code:: bash

  peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Now update the channel definition to define the anchor peer for Org2 as ``peer0.org2.example.com``.
Identically to the ``peer channel join`` command for the Org2 peer, we will need to
preface this call with the appropriate environment variables.

现在更新通道定义，将Org2的锚节点定义为``peer0.org2.example.com``。与Org2 peer ``peer channel join`` 命令相同，我们需要使用合适的环境变量作为这个命令的前言。

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Install & Instantiate Chaincode - 安装和实例化链码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: We will utilize a simple existing chaincode. To learn how to write
          your own chaincode, see the :doc:`chaincode4ade` tutorial.

.. note:: 我们将利用现有的一个简单链码来学习怎么编写你自己的链码。请参考:doc:`chaincode4ade`

Applications interact with the blockchain ledger through ``chaincode``.  As
such we need to install the chaincode on every peer that will execute and
endorse our transactions, and then instantiate the chaincode on the channel.

应用程序和区块链账本通过链码``chaincode``互相起作用。因此，我们需要在每个会执行以及背书我们交易的peer节点安装chaincode，然后在通道上实例化chaincode。

First, install the sample Go, Node.js or Java chaincode onto the peer0
node in Org1. These commands place the specified source
code flavor onto our peer's filesystem.

首先，安装Go，Node.js 或者 Java 链码在四个peer节点中的一个。这些命令把指定的源码放在我们的peer的文件系统里。

.. note:: You can only install one version of the source code per chaincode name
          and version.  The source code exists on the peer's file system in the
          context of chaincode name and version; it is language agnostic.  Similarly
          the instantiated chaincode container will be reflective of whichever
          language has been installed on the peer.

.. note:: 每个链码的一个版本的源码，你只能安装一个名称和版本。源码存在于peer的文件系统上的链码名称和版本的上下文里。它与语言无关。同样，被实例化的链码容器将反映出事什么语言被安装在peer上。

**Golang**

.. code:: bash

    # this installs the Go chaincode. For go chaincode -p takes the relative path from $GOPATH/src
    # 这里安装 Go 语言的链码。 -p 是 go 链码的相对于 $GOPATH/src 的路径
    peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

**Node.js**

.. code:: bash

    # this installs the Node.js chaincode
    # 这里是安装 Node.js 链码
    # make note of the -l flag to indicate "node" chaincode
    # 注意 -l 后边标记为 “node” 链码 
    # for node chaincode -p takes the absolute path to the node.js chaincode
    # 对于 node 链码 -p 是 node.js 链码的绝对路径
    peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/

**Java**

.. code:: bash

    # make note of the -l flag to indicate "java" chaincode
    #  注意 -l 后边标记为 “java” 链码 
    # for java chaincode -p takes the absolute path to the java chaincode
    # 对于 java 链码 -p 是 java 链码的绝对路径
    peer chaincode install -n mycc -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/chaincode_example02/java/

When we instantiate the chaincode on the channel, the endorsement policy will be
set to require endorsements from a peer in both Org1 and Org2. Therefore, we
also need to install the chaincode on a peer in Org2.

当我们在通道上实例化链码之后，背书策略被设定为需要 Org1 和 Org2 的节点都背书。所以，我们需要在 Org2 的节点上也安装链码。

Modify the following four environment variables to issue the install command
against peer0 in Org2:

为了执行在 Org2 的 peer0 上安装命令，需要修改以下四个环境变量：

.. code:: bash

   # Environment variables for PEER0 in Org2

   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   CORE_PEER_ADDRESS=peer0.org2.example.com:7051
   CORE_PEER_LOCALMSPID="Org2MSP"
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

Now install the sample Go, Node.js or Java chaincode onto a peer0
in Org2. These commands place the specified source
code flavor onto our peer's filesystem.

现在在 Org2 peer0 上安装 Go, Node.js 或者 Java 的示例链码。这些命令将源代码安装到节点的文件系统上。

**Golang**

.. code:: bash

    # this installs the Go chaincode. For go chaincode -p takes the relative path from $GOPATH/src
    peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

**Node.js**

.. code:: bash

    # this installs the Node.js chaincode
    # make note of the -l flag to indicate "node" chaincode
    # for node chaincode -p takes the absolute path to the node.js chaincode
    peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/

**Java**

.. code:: bash

    # make note of the -l flag to indicate "java" chaincode
    # for java chaincode -p takes the absolute path to the java chaincode
    peer chaincode install -n mycc -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/chaincode_example02/java/


Next, instantiate the chaincode on the channel. This will initialize the
chaincode on the channel, set the endorsement policy for the chaincode, and
launch a chaincode container for the targeted peer.  Take note of the ``-P``
argument. This is our policy where we specify the required level of endorsement
for a transaction against this chaincode to be validated.

接下来，在通道上实例化链码。这会在通道上初始化链码，为链码指定背书策略，然后为目标的peer节点启动链码容器。注意``-P``这个参数。这是我们的策略，我们在此策略中指定针对要验证的此链码的交易所需的背书级别。

In the command below you’ll notice that we specify our policy as
``-P "AND ('Org1MSP.peer','Org2MSP.peer')"``. This means that we need
“endorsement” from a peer belonging to Org1 **AND** Org2 (i.e. two endorsement).
If we changed the syntax to ``OR`` then we would need only one endorsement.

在下面的命令里你将会注意到我们指定``-P "AND ('Org1MSP.peer','Org2MSP.peer')"``作为策略。这表明我们需要一个属于Org1和Org2(i.e. two endorsement)的peer节点”背书“。如果我们把语法改成``OR``，那我们将只需要一个背书节点。

**Golang**

.. code:: bash

    # be sure to replace the $CHANNEL_NAME environment variable if you have not exported it
    # if you did not install your chaincode with a name of mycc, then modify that argument as well

    peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

**Node.js**

.. note::  The instantiation of the Node.js chaincode will take roughly a minute.
           The command is not hanging; rather it is installing the fabric-shim
           layer as the image is being compiled.

.. note::  Node.js链码实例化大约需要一分钟，命令任务没有挂掉，而是在编译 fabric-shim层镜像。

.. code:: bash

    # be sure to replace the $CHANNEL_NAME environment variable if you have not exported it
    # if you did not install your chaincode with a name of mycc, then modify that argument as well
    # notice that we must pass the -l flag after the chaincode name to identify the language

    peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -l node -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

**Java**

.. note:: Please note, Java chaincode instantiation might take time as it compiles chaincode and
          downloads docker container with java environment.

.. code:: bash

    peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -l java -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"

See the `endorsement
policies <http://hyperledger-fabric.readthedocs.io/en/latest/endorsement-policies.html>`__
documentation for more details on policy implementation.

查看背书策略`endorsement
policies <http://hyperledger-fabric.readthedocs.io/en/latest/endorsement-policies.html>`__获取更多策略实现的内容。

If you want additional peers to interact with ledger, then you will need to join
them to the channel, and install the same name, version and language of the
chaincode source onto the appropriate peer's filesystem.  A chaincode container
will be launched for each peer as soon as they try to interact with that specific
chaincode.  Again, be cognizant of the fact that the Node.js images will be slower
to compile.

如果你想添加另外的peers与超极账本交互，你需要加入它们的通道，然后安装一样名字版本语言的链码在适当的对等文件系统。一旦它们尝试与特定的链代码进行交互，就会为每一个peer启动一个链码容器。再一次，要认识到Node.js镜像的编译速度会慢一些。

Once the chaincode has been instantiated on the channel, we can forgo the ``l``
flag.  We need only pass in the channel identifier and name of the chaincode.

一旦链码在通道上实例化，我们可以放弃 ``l`` 标志。我们只需传递通道标识符和链码的名称。

Query - 查询
^^^^^

Let's query for the value of ``a`` to make sure the chaincode was properly
instantiated and the state DB was populated. The syntax for query is as follows:

让我们查询``a`` 的值，以确保链码被正确实例化并且state DB被填充。查询的语法是这样的：

.. code:: bash

  # be sure to set the -C and -n flags appropriately
  
  # 确保正确的设置了 -C 和 -n 标志。

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

Invoke - 调用
^^^^^^

Now let's move ``10`` from ``a`` to ``b``.  This transaction will cut a new block and
update the state DB. The syntax for invoke is as follows:

我们先在从 ``a`` 账户向 ``b`` 账户转账 10 。这个交易将会削减一个新的区块并且更新 state DB 。调用的语法是这样的：

.. code:: bash

    # be sure to set the -C and -n flags appropriately

    peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'

Query - 查询
^^^^^

Let's confirm that our previous invocation executed properly. We initialized the
key ``a`` with a value of ``100`` and just removed ``10`` with our previous
invocation. Therefore, a query against ``a`` should return ``90``. The syntax
for query is as follows.

我们来确认一下我们之前的调用正确执行了。我们为键 ``a`` 初始化一个 100 的值，通过刚才的调用移除掉了 ``10``。这样查询出的值应该是 ``90``，查询的语法是这样的：

.. code:: bash

  # be sure to set the -C and -n flags appropriately
  
  # 确保正确的设置了 -C 和 -n 标志。

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

We should see the following:

我们会看到下面的结果：

.. code:: bash

   Query Result: 90

Feel free to start over and manipulate the key value pairs and subsequent
invocations.

随意重新开始并操纵键值对和后续调用。

Install - 安装 
^^^^^^^

Now we will install the chaincode on a third peer, peer1 in Org2. Modify the
following four environment variables to issue the install command
against peer1 in Org2:

现在我们将在第三个节点上安装链码， Org2 的 peer1 。为了执行在 Org2 的 peer1 上的安装命令，需要改变以下四个环境变量：

.. code:: bash

   # Environment variables for PEER1 in Org2
   
   # Org2 的 PEER1 的环境变量

   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   CORE_PEER_ADDRESS=peer1.org2.example.com:7051
   CORE_PEER_LOCALMSPID="Org2MSP"
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

Now install the sample Go, Node.js or Java chaincode onto peer1
in Org2. These commands place the specified source
code flavor onto our peer's filesystem.

现在在 Org2 的 peer1 上安装 Go ，Node.js 或者 Java 的示例链码。这些命令会安装指定的源码到节点的文件系统上。

**Golang**

.. code:: bash

    # this installs the Go chaincode. For go chaincode -p takes the relative path from $GOPATH/src
    peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/

**Node.js**

.. code:: bash

    # this installs the Node.js chaincode
    # make note of the -l flag to indicate "node" chaincode
    # for node chaincode -p takes the absolute path to the node.js chaincode
    peer chaincode install -n mycc -v 1.0 -l node -p /opt/gopath/src/github.com/chaincode/chaincode_example02/node/

**Java**

.. code:: bash

    # make note of the -l flag to indicate "java" chaincode
    # for java chaincode -p takes the absolute path to the java chaincode
    peer chaincode install -n mycc -v 1.0 -l java -p /opt/gopath/src/github.com/chaincode/chaincode_example02/java/

Query - 查询
^^^^^

Let's confirm that we can issue the query to Peer1 in Org2. We initialized the
key ``a`` with a value of ``100`` and just removed ``10`` with our previous
invocation. Therefore, a query against ``a`` should still return ``90``. 

让我们确认以下我们可以执行对 Org2 的 Peer1 的查询。我们把键 ``a`` 的值初始化为 ``100`` 而且上一个操作转移了 ``10`` 。所以对 ``a`` 的查询结果仍应该是 ``90`` 。

peer1 in Org2 must first join the channel before it can respond to queries. The
channel can be joined by issuing the following command:

Org2 的 peer1 必须先加入通道才可以响应查询。下边的命令可以让它加入通道：

.. code:: bash

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer1.org2.example.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt peer channel join -b mychannel.block

After the join command returns, the query can be issued. The syntax
for query is as follows.

在加入通道的命令返回之后，就可以执行查询了。下边是执行查询的语法。

.. code:: bash

  # be sure to set the -C and -n flags appropriately

  peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

We should see the following:

.. code:: bash

   Query Result: 90

Feel free to start over and manipulate the key value pairs and subsequent
invocations.

随意重新开始并操纵键值对和后续调用。

.. _behind-scenes:

What's happening behind the scenes? - 幕后发生了什么？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: These steps describe the scenario in which
          ``script.sh`` is run by './byfn.sh up'.  Clean your network
          with ``./byfn.sh down`` and ensure
          this command is active.  Then use the same
          docker-compose prompt to launch your network again
          
.. note:: 这些步骤描述了在 ``script.sh`` 脚本中的场景，它是由 './byfn.sh up' 启动的。通过 ``./byfn.sh down`` 清除你的网络，确保此命令处于活动状态。然后用同样的 docker-compose 提示去再次启动你的网络。         

-  A script - ``script.sh`` - is baked inside the CLI container. The
   script drives the ``createChannel`` command against the supplied channel name
   and uses the channel.tx file for channel configuration.

- 一个脚本 - ``script.sh`` - 被复制在 CLI 容器中。这个脚本通过提供的通道名称和使用 channel.tx 文件作为通道配置来执行创建通道 ``createChannel`` 的命令。

-  The output of ``createChannel`` is a genesis block -
   ``<your_channel_name>.block`` - which gets stored on the peers' file systems and contains
   the channel configuration specified from channel.tx.

-  ``createChannel`` 的输出是一个初始区块 - ``<你通道名字>.block`` - 它被存储在 peer 的文件系统上并包含有来自 channel.tx 的通道配置。

-  The ``joinChannel`` command is exercised for all four peers, which takes as
   input the previously generated genesis block.  This command instructs the
   peers to join ``<your_channel_name>`` and create a chain starting with ``<your_channel_name>.block``.
   
-  ``joinChannel`` 加入通道的命令被所有的四个 peer 执行，作为之前产生初始区块的输出。这个命令指示那些 peer 去加入通道 ``<your_channel_name>`` 并且通过 ``<你的通道名称>.block`` 开始创建一条链。

-  Now we have a channel consisting of four peers, and two
   organizations.  This is our ``TwoOrgsChannel`` profile.

-  现在我们有一个由四个 peer，两个组织组成的通道，这是我们两个组织通道 ``TwoOrgsChannel`` 的结构。

-  ``peer0.org1.example.com`` and ``peer1.org1.example.com`` belong to Org1;
   ``peer0.org2.example.com`` and ``peer1.org2.example.com`` belong to Org2

-  ``peer0.org1.example.com`` 和 ``peer1.org1.example.com`` 属于组织 Org1;
   ``peer0.org2.example.com`` 和 ``peer1.org2.example.com`` 属于组织 Org2

-  These relationships are defined through the ``crypto-config.yaml`` and
   the MSP path is specified in our docker compose.

- 这些关系在 ``crypto-config.yaml`` 中定义，MSP 的路径在我们的 docker compose 中指定。

-  The anchor peers for Org1MSP (``peer0.org1.example.com``) and
   Org2MSP (``peer0.org2.example.com``) are then updated.  We do this by passing
   the ``Org1MSPanchors.tx`` and ``Org2MSPanchors.tx`` artifacts to the ordering
   service along with the name of our channel.

-  Org1MSP (``peer0.org1.example.com``) 和 Org2MSP (``peer0.org2.example.com``) 的锚节点将会被更新。我们通过把 ``Org1MSPanchors.tx`` 和 ``Org2MSPanchors.tx`` 构件一起加上通道名称传给排序节点来做到这一点。

-  A chaincode - **chaincode_example02** - is installed on ``peer0.org1.example.com`` and
   ``peer0.org2.example.com``

-  一个链码 - **chaincode_example02** - 被安装在 ``peer0.org1.example.com`` 和 ``peer0.org2.example.com``

-  The chaincode is then "instantiated" on ``mychannel``. Instantiation
   adds the chaincode to the channel, starts the container for the target peer,
   and initializes the key value pairs associated with the chaincode.  The initial
   values for this example are ["a","100" "b","200"]. This "instantiation" results
   in a container by the name of ``dev-peer0.org2.example.com-mycc-1.0`` starting.

-  链码将会被实例化在 ``peer0.org2.example.com``。实例化过程是新增链码到通道，为目标 peer 启动容器，初始化链码相关的键值对。对于本例来说初始化的值是 ["a","100" "b","200"]。这个初始化的结果是名为 ``dev-peer0.org2.example.com-mycc-1.0`` 的容器启动了。

-  The instantiation also passes in an argument for the endorsement
   policy. The policy is defined as
   ``-P "AND ('Org1MSP.peer','Org2MSP.peer')"``, meaning that any
   transaction must be endorsed by a peer tied to Org1 and Org2.

-  这个实例化过程也给背书策略传递了一个参数。这个策略被定义为 ``-P "AND ('Org1MSP.peer','Org2MSP.peer')"``。意思是任何交易都要两个分别属于 Org1 和 Org2 的 peer 节点背书。

-  A query against the value of "a" is issued to ``peer0.org2.example.com``.
   A container for Org2 peer0 by the name of ``dev-peer0.org2.example.com-mycc-1.0``
   was started when the chaincode was instantiated. The result
   of the query is returned. No write operations have occurred, so
   a query against "a" will still return a value of "100".

-  对 ``peer0.org2.example.com`` 发出针对键 “a” 的值的查询。在链码实例化的时候，为 Org2 peer0 启动了一个名为 ``dev-peer0.org2.example.com-mycc-1.0`` 的容器。查询结果返回了，没有对 “a” 执行写操作，所以返回的值仍为 “100” 。

-  An invoke is sent to ``peer0.org1.example.com`` and ``peer0.org2.example.com``
   to move "10" from "a" to "b"

-  发生了一次对 ``peer0.org1.example.com`` 和 ``peer0.org2.example.com`` 的调用，目的是从 “a” 转账 “10” 到 “b”。

-  A query is sent to ``peer0.org2.example.com`` for the value of "a". A
   value of 90 is returned, correctly reflecting the previous
   transaction during which the value for key "a" was modified by 10.

-  向 ``peer0.org2.example.com`` 发送一次对 “a” 的值的查询。返回值为 90，正确反映了之前交易期间，键 “a” 的值被转走了 10。

-  The chaincode - **chaincode_example02** - is installed on ``peer1.org2.example.com``

-  链码 - **chaincode_example02** - 被安装在 ``peer1.org2.example.com``

-  A query is sent to ``peer1.org2.example.com`` for the value of "a". This starts a
   third chaincode container by the name of ``dev-peer1.org2.example.com-mycc-1.0``. A
   value of 90 is returned, correctly reflecting the previous
   transaction during which the value for key "a" was modified by 10.
   
   向 ``peer1.org2.example.com`` 发送一次对 “a” 的值的查询。这启动了第三个名为 ``dev-peer1.org2.example.com-mycc-1.0`` 的链码容器。返回值为 90，正确反映了之前交易期间，键 “a” 的值被转走了 10。

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
after it is installed (like ``peer1.org2.example.com`` in the above example) because it
has already been instantiated.

链码必须安装在peer上才能实现对账本的读写操作。此外,一个链码容器不会在peer里启动，除非 ``init``或者传统的事务交易（读写）针对该链码完成（例如查询“a”的值）。交易导致容器的启动。当然，所有通道中的节点都持有以块的形式顺序存储的不可变的账本精确的备份，以及状态数据库来保存当前状态的快照。这包括了没有在其上安装链码服务的peer节点（例如上面例子中的 ``peer1.org1.example.com`` ）。最后，链码在被安装后将是可达状态（例如上面例子中的 ``peer1.org2.example.com`` ），因为它已经被实例化了。

How do I see these transactions? - 我如何查看这些交易？
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Check the logs for the CLI Docker container.

检查CLI容器的日志。

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

检查每个独立的链码服务容器来查看每个容器内的分隔的交易。下面是每个链码服务容器的日志的综合输出：

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

Understanding the Docker Compose topology - 了解 Docker Compose 技术
-----------------------------------------

The BYFN sample offers us two flavors of Docker Compose files, both of which
are extended from the ``docker-compose-base.yaml`` (located in the ``base``
folder).  Our first flavor, ``docker-compose-cli.yaml``, provides us with a
CLI container, along with an orderer, four peers.  We use this file
for the entirety of the instructions on this page.

BYFN 示例给我们提供了两种风格的 Docker Compose 文件，它们都继承自 ``docker-compose-base.yaml``（在 ``base`` 目录下）。我们的第一种类型，``docker-compose-cli.yaml``，给我们提供了一个 CLI 容器，以及一个 orderer 容器，四个 peer 容器。我们用此文件来展开这个页面上的所有说明。

.. note:: the remainder of this section covers a docker-compose file designed for the
          SDK.  Refer to the `Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__
          repo for details on running these tests.

.. note:: 本节的剩余部分涵盖了为SDK设计的docker-compose文件。有关运行这些测试的详细信息，请参阅`Node SDK <https://github.com/hyperledger/fabric-sdk-node>`__仓库。

The second flavor, ``docker-compose-e2e.yaml``, is constructed to run end-to-end tests
using the Node.js SDK.  Aside from functioning with the SDK, its primary differentiation
is that there are containers for the fabric-ca servers.  As a result, we are able
to send REST calls to the organizational CAs for user registration and enrollment.

第二种风格是`docker-compose-e2e.yaml`，被构造为使用Node.js SDK来运行端到端测试。除了SDK的功能之外，它主要的区别在于它有运行fabric-ca服务的容器。因此，我们能够向组织的CA节点发送REST的请求用于注册和登记。

If you want to use the ``docker-compose-e2e.yaml`` without first running the
byfn.sh script, then we will need to make four slight modifications.
We need to point to the private keys for our Organization's CA's.  You can locate
these values in your crypto-config folder.  For example, to locate the private
key for Org1 we would follow this path - ``crypto-config/peerOrganizations/org1.example.com/ca/``.
The private key is a long hash value followed by ``_sk``.  The path for Org2
would be - ``crypto-config/peerOrganizations/org2.example.com/ca/``.

如果你在没有运行`byfn.sh`脚本的情况下，想使用`docker-compose-e2e.yaml`，我们需要进行4个轻微的修改。我们需要指出本组织CA的私钥。你可以在`crypto-config`文件夹中找到这些值。举个例子，为了定位Org1的私钥，我们将使用`crypto-config/peerOrganizations/org1.example.com/ca/`。Org2的路径为`crypto-config/peerOrganizations/org2.example.com/ca/`。

In the ``docker-compose-e2e.yaml`` update the FABRIC_CA_SERVER_TLS_KEYFILE variable
for ca0 and ca1.  You also need to edit the path that is provided in the command
to start the ca server.  You are providing the same private key twice for each
CA container.

在`docker-compose-e2e.yaml`里为ca0和ca1更新FABRIC_CA_SERVER_TLS_KEYFILE变量。你同样需要编辑command中去启动ca server的路径。你为每个CA容器提供了2次同样的私钥。


Using CouchDB - 使用CouchDB
-------------

The state database can be switched from the default (goleveldb) to CouchDB.
The same chaincode functions are available with CouchDB, however, there is the
added ability to perform rich and complex queries against the state database
data content contingent upon the chaincode data being modeled as JSON.

状态数据库可以从默认的 `goleveldb` 切换到 `CouchDB`。链码功能同样能使用 `CouchDB`。但是，`CouchDB` 提供了额外的能力来根据 JSON 形式的链码服务数据提供更加丰富以及复杂的查询。

To use CouchDB instead of the default database (goleveldb), follow the same
procedures outlined earlier for generating the artifacts, except when starting
the network pass ``docker-compose-couch.yaml`` as well:

使用CouchDB代替默认的数据库（goleveldb），除了在启动网络的时侯传递`docker-compose-couch.yaml`之外，请遵循前面提到的生成配置文件的过程：

.. code:: bash

    docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d

**chaincode_example02** should now work using CouchDB underneath.

**chaincode_example02** 现在应该使用下面的 CouchDB。

.. note::  If you choose to implement mapping of the fabric-couchdb container
           port to a host port, please make sure you are aware of the security
           implications. Mapping of the port in a development environment makes the
           CouchDB REST API available, and allows the
           visualization of the database via the CouchDB web interface (Fauxton).
           Production environments would likely refrain from implementing port mapping in
           order to restrict outside access to the CouchDB containers.

.. note::  如果你选择将 fabric-couchdb 容器端口映射到主机端口，请确保你意识到了安全性的影响。在开发环境中映射端口可以使 CouchDB REST API 可用，并允许通过 CouchDB Web 界面（Fauxton）对数据库进行可视化。生产环境将避免端口映射，以限制对 CouchDB 容器的外部访问。

You can use **chaincode_example02** chaincode against the CouchDB state database
using the steps outlined above, however in order to exercise the CouchDB query
capabilities you will need to use a chaincode that has data modeled as JSON,
(e.g. **marbles02**). You can locate the **marbles02** chaincode in the
``fabric/examples/chaincode/go`` directory.

你可以使用上面列出的步骤使用 CouchDB 来执行 chaincode_example02，然而为了执行执行 CouchDB 的查询能力，你将需要使用被格式化为 JSON 的数据（例如 marbles02）。你可以在 `fabric/examples/chaincode/go` 目录中找到 `marbles02` 链码服务。

We will follow the same process to create and join the channel as outlined in the
:ref:`createandjoin` section above.  Once you have joined your peer(s) to the
channel, use the following steps to interact with the **marbles02** chaincode:

我们将按照上述创建和加入频道:ref:`createandjoin`部分所述的相同过程创建和加入信道。一旦你将peer节点加入到了信道，请使用以下步骤与marbles02链码交互：

-  Install and instantiate the chaincode on ``peer0.org1.example.com``:
-  在 `peer0.org1.example.com` 上安装和实例化链：

.. code:: bash

       # be sure to modify the $CHANNEL_NAME variable accordingly for the instantiate command

       peer chaincode install -n marbles -v 1.0 -p github.com/chaincode/marbles02/go
       peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org0MSP.peer','Org1MSP.peer')"

-  Create some marbles and move them around:
-  创建一些 marbles 并移动它们：

.. code:: bash

        # be sure to modify the $CHANNEL_NAME variable accordingly

        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["initMarble","marble1","blue","35","tom"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["initMarble","marble2","red","50","tom"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["initMarble","marble3","blue","70","tom"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["transferMarble","marble2","jerry"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["transferMarblesBasedOnColor","blue","jerry"]}'
        peer chaincode invoke -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n marbles -c '{"Args":["delete","marble1"]}'

-  If you chose to map the CouchDB ports in docker-compose, you can now view
   the state database through the CouchDB web interface (Fauxton) by opening
   a browser and navigating to the following URL:

   ``http://localhost:5984/_utils``

-  如果你选择在 docker-compose 文件中映射你的 CouchDB 的端口，那么你现在就可以通过 CouchDB Web 界面（Fauxton）通过打开浏览器导航下列 URL：

   ``http://localhost:5984/_utils``

You should see a database named ``mychannel`` (or your unique channel name) and
the documents inside it.

你应该可以看到一个名为 `mychannel`（或者你的唯一的信道名字）的数据库以及它的文档在里面：

.. note:: For the below commands, be sure to update the $CHANNEL_NAME variable appropriately.

.. note:: 对于下面的命令，请确定 $CHANNEL_NAME 变量被更新了。

You can run regular queries from the CLI (e.g. reading ``marble2``):

你可以CLI中运行常规的查询（例如读取 ``marble2``）：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["readMarble","marble2"]}'

The output should display the details of ``marble2``:

``marble2`` 的详细输出应该显示为如下：

.. code:: bash

       Query Result: {"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}

You can retrieve the history of a specific marble - e.g. ``marble1``:

你可以检索特定 marble 的历史记录 - 例如 ``marble1``:

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["getHistoryForMarble","marble1"]}'

The output should display the transactions on ``marble1``:

关于 ``marble1`` 的交易的输出：

.. code:: bash

      Query Result: [{"TxId":"1c3d3caf124c89f91a4c0f353723ac736c58155325f02890adebaa15e16e6464", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"tom"}},{"TxId":"755d55c281889eaeebf405586f9e25d71d36eb3d35420af833a20a2f53a3eefd", "Value":{"docType":"marble","name":"marble1","color":"blue","size":35,"owner":"jerry"}},{"TxId":"819451032d813dde6247f85e56a89262555e04f14788ee33e28b232eef36d98f", "Value":}]

You can also perform rich queries on the data content, such as querying marble fields by owner ``jerry``:

你还可以对数据内容执行丰富的查询，例如通过拥有者 ``jerry`` 查询 marble：

.. code:: bash

      peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesByOwner","jerry"]}'

The output should display the two marbles owned by ``jerry``:

输出应该显示出 2 个属于 ``jerry`` 的 marble：

.. code:: bash

       Query Result: [{"Key":"marble2", "Record":{"color":"red","docType":"marble","name":"marble2","owner":"jerry","size":50}},{"Key":"marble3", "Record":{"color":"blue","docType":"marble","name":"marble3","owner":"jerry","size":70}}]


Why CouchDB - 为什么是 CouchDB
-------------
CouchDB is a kind of NoSQL solution. It is a document-oriented database where document fields are stored as key-value maps. Fields can be either a simple key-value pair, list, or map.

CouchDB 是一种 NoSQL 解决方案。它是一个面向文档的数据库，其中文档字段存储为键值映射。 字段可以是简单的键值对，列表或映射。

In addition to keyed/composite-key/key-range queries which are supported by LevelDB, CouchDB also supports full data rich queries capability, such as non-key queries against the whole blockchain data,
since its data content is stored in JSON format and fully queryable. Therefore, CouchDB can meet chaincode, auditing, reporting requirements for many use cases that not supported by LevelDB.

除了 LevelDB 支持的键控/复合键/键范围查询外，CouchDB 还支持完全数据丰富的查询功能，例如针对整个区块链数据的无键查询，因为其数据内容以 JSON 格式存储， 完全可查询。 因此，CouchDB 可以满足 LevelDB 不支持的许多用例的链代码，审计和报告要求。

CouchDB can also enhance the security for compliance and data protection in the blockchain. As it is able to implement field-level security through the filtering and masking of individual attributes within a transaction, and only authorizing the read-only permission if needed.

CouchDB 还可以增强区块链中的合规性和数据保护的安全性。 因为它能够通过过滤和屏蔽事务中的各个属性来实现字段级安全性，并且在需要时只授权只读权限。

In addition, CouchDB falls into the AP-type (Availability and Partition Tolerance) of the CAP theorem. It uses a master-master replication model with ``Eventual Consistency``.
More information can be found on the
`Eventual Consistency page of the CouchDB documentation <http://docs.couchdb.org/en/latest/intro/consistency.html>`__.

此外，CouchDB 属于 CAP 定理的 AP 类型（可用性和分区容错性）。它使用具有最终一致性 ``Eventual Consistency`` 的主-主复制模型。更多的信息可以在这里找到：CouchDB 文档的最终一致性页面 `Eventual Consistency page of the CouchDB documentation <http://docs.couchdb.org/en/latest/intro/consistency.html>`__

However, under each fabric peer, there is no database replicas, writes to database are guaranteed consistent and durable (not ``Eventual Consistency``).

CouchDB is the first external pluggable state database for Fabric, and there could and should be other external database options. For example, IBM enables the relational database for its blockchain.
And the CP-type (Consistency and Partition Tolerance) databases may also in need, so as to enable data consistency without application level guarantee.

CouchDB 是 Fabric 的第一个外部可插拔状态数据库，可能也应该有其他外部数据库选项。 例如，IBM 为其区块链启用了关系数据库。并且 CP 类型（一致性和分区容错性）数据库也可能需要，以便在没有应用程序级别保证的情况下实现数据一致性。

A Note on Data Persistence - 关于数据持久化的提示
--------------------------

If data persistence is desired on the peer container or the CouchDB container,
one option is to mount a directory in the docker-host into a relevant directory
in the container. For example, you may add the following two lines in
the peer container specification in the ``docker-compose-base.yaml`` file:

如果需要在 peer 容器或者 CouchDB 容器进行数据持久化，一种选择是将 docker 容器内相应的目录挂载到容器所在的宿主机的一个目录中。例如，你可以添加下列的两行到 ``docker-compose-base.yaml`` 文件中指定 peer 容器的约定中：

.. code:: bash

       volumes:
        - /var/hyperledger/peer0:/var/hyperledger/production

For the CouchDB container, you may add the following two lines in the CouchDB
container specification:

对于CouchDB容器，你可以在CouchDB的约定中添加两行：

.. code:: bash

       volumes:
        - /var/hyperledger/couchdb0:/opt/couchdb/data

.. _Troubleshoot:

Troubleshooting - 故障排除
---------------

-  Always start your network fresh.  Use the following command
   to remove artifacts, crypto, containers and chaincode images:

-  始终保持你的网络是全新的。使用以下命令来移除之前生成的 artifacts, crypto, containers 以及 chaincode images：

   .. code:: bash

      ./byfn.sh down

   .. note:: You **will** see errors if you do not remove old containers
             and images.
             
   .. note:: 你将会看到错误信息，如果你不移除容器和镜像

-  If you see Docker errors, first check your docker version (:doc:`prereqs`),
   and then try restarting your Docker process.  Problems with Docker are
   oftentimes not immediately recognizable.  For example, you may see errors
   resulting from an inability to access crypto material mounted within a
   container.
   
-  如果你看到相关的 Docker 错误信息，首先检查你的版本（:doc:`prereqs`），然后重启你的 Docker 进程。Docker 的问题通常不会被立即识别。例如，你可能看到由于容器内加密材料导致的错误。

   If they persist remove your images and start from scratch:

   如果它们坚持删除你的镜像，并从头开始：
   
   .. code:: bash

       docker rm -f $(docker ps -aq)
       docker rmi -f $(docker images -q)

-  If you see errors on your create, instantiate, invoke or query commands, make
   sure you have properly updated the channel name and chaincode name.  There
   are placeholder values in the supplied sample commands.

-  如果你发现你的创建、实例化，调用或者查询命令，请确保你已经更新了通道和链码的名字。提供的示例命令中有占位符。

-  If you see the below error:

-  如果你看到如下错误：

   .. code:: bash

       Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)

   You likely have chaincode images (e.g. ``dev-peer1.org2.example.com-mycc-1.0`` or
   ``dev-peer0.org1.example.com-mycc-1.0``) from prior runs. Remove them and try
   again.

   你可能有以前运行的链码服务（例如 ``dev-peer1.org2.example.com-mycc-1.0`` 或 ``dev-peer0.org1.example.com-mycc-1.0``）。删除它们，然后重试。

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

   那么你没有正确设置 ``FABRIC_CFG_PATH`` 环境变量。configtxgen 工具需要这个变量才能找到 configtx.yaml。返回并执行 ``export FABRIC_CFG_PATH=$PWD``，然后重新创建 channel 配置。

-  To cleanup the network, use the ``down`` option:

-  要清理网络，请使用`down`选项：

   .. code:: bash

       ./byfn.sh down

-  If you see an error stating that you still have "active endpoints", then prune
   your Docker networks.  This will wipe your previous networks and start you with a
   fresh environment:

-  如果你看到一条指示你依然有 “active endpoints”，然后你应该清理你的 Docker 网络。这将会清除你之前的网络并且给你一个全新的环境：

   .. code:: bash

        docker network prune

   You will see the following message:
   
   你会看到下面的内容：

   .. code:: bash

      WARNING! This will remove all networks not used by at least one container.
      Are you sure you want to continue? [y/N]

   Select ``y``.
   
   选择 ``y``。

-  If you see an error similar to the following:

-  如果你看到类似以下内容的错误信息：

   .. code:: bash

      /bin/bash: ./scripts/script.sh: /bin/bash^M: bad interpreter: No such file or directory

   Ensure that the file in question (**script.sh** in this example) is encoded
   in the Unix format. This was most likely caused by not setting
   ``core.autocrlf`` to ``false`` in your Git configuration (see
   :ref:`windows-extras`). There are several ways of fixing this. If you have
   access to the vim editor for instance, open the file:

   请确保问题中的文件（本例是 **script.sh**）被编码为 Unix 格式。这主要可能是由于你的 Git 配置没有设置 ``core.autocrlf`` 为 ``false``。有几种方法解决。例如，如果您有权访问 vim 编辑器，打开这个文件：

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
   
.. note:: 如果你仍旧看到了错误，请把你的日志分享在 `Hyperledger Rocket Chat <https://chat.hyperledger.org/home>`__ **fabric-questions** 频道上或者 `StackOverflow <https://stackoverflow.com/questions/tagged/hyperledger-fabric>`__。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
