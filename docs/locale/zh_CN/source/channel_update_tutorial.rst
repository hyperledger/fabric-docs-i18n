向通道添加组织
==========================
Adding an Org to a Channel
==========================

.. note:: 确保你已经下载了 :doc:`install` 和 :doc:`prereqs` 中所罗列的和本文版
          本左边内容列表的底部可以查看）一致的镜像和二进制。特别注意，在你的版
          本中，``fabric-samples`` 文件夹必须包含 ``eyfn.sh`` （ “Extending
          Your First Network” ）脚本以及和它相关的脚本。

.. note:: Ensure that you have downloaded the appropriate images and binaries
          as outlined in :doc:`install` and :doc:`prereqs` that conform to the
          version of this documentation (which can be found at the bottom of the
          table of contents to the left).

本教程是 :doc:`build_network` （ BYFN ） 教程的扩展，将演示一个由 BYFN 自动生成的新
的组织 -- ``Org3`` -- 加入到应用通道 （ ``mychannel`` ） 的过程。本教程假设你对 BYFN
有很好地理解，包括用法以及上面提及的工具的功能。

This tutorial extends the Fabric test network by adding a new organization
-- Org3 -- to an application channel.

虽然我们在这里将只关注新组织的集成，但执行其他通道配置更新（如更新修改策略，调整块大小）
也可以采取相同的方式。要了解更多的通道配置更新的相关过程，请查看 :doc:`config_update` 。
值得注意的是，像本文演示的这些通道配置更新通常是组织管理者（而非链码或者应用开发者）的
职责。

While we will focus on adding a new organization to the channel, you can use a
similar process to make other channel configuration updates (updating modification
policies or altering batch size, for example). To learn more about the process
and possibilities of channel config updates in general, check out :doc:`config_update`).
It's also worth noting that channel configuration updates like the one
demonstrated here will usually be the responsibility of an organization admin
(rather than a chaincode or application developer).

.. note:: 在继续本文前先确保自动化脚本 ``byfn.sh`` 运行无误。如果你已经把你的二进
          制文件和相关工具(如 ``cryptogen``，``configtxgen`` 等）放在了 PATH 变量
          指定的路径下，你可以修改相应的命令而不使用全路径。

Setup the Environment
~~~~~~~~~~~~~~~~~~~~~

环境构建
~~~~~~~~~~~~~~~~~~~~~

We will be operating from the root of the ``test-network`` subdirectory within
your local clone of ``fabric-samples``. Change into that directory now.

你将从你克隆到本地的 ``fabric-samples`` 的子目录 ``first-network`` 进行操作。现在，
进入那个目录。你还要打开一些额外的终端窗口以便于使用。

.. code:: bash

首先，使用 ``byfn.sh`` 脚本清理环境。这个命令会清除运行、终止状态的容器，并且移除之前
生成的构件。关闭 Fabric 网络并非执行通道配置升级的 **必要** 步骤。但是为了本教程，我们
希望从一个已知的初始状态开始，因此让我们运行以下命令来清理之前的环境：

   cd fabric-samples/test-network

.. code:: bash

First, use the ``network.sh`` script to tidy up. This command will kill any active
or stale Docker containers and remove previously generated artifacts. It is by no
means **necessary** to bring down a Fabric network in order to perform channel
configuration update tasks. However, for the sake of this tutorial, we want to operate
from a known initial state. Therefore let's run the following command to clean up any
previous environments:

  ./byfn.sh down

.. code:: bash

现在生成默认的 BYFN 构件：

  ./network.sh down

.. code:: bash

You can now use the script to bring up the test network with one channel named
``mychannel``:

  ./byfn.sh generate

.. code:: bash

启动网络，并执行 CLI 容器内的脚本：

  ./network.sh up createChannel

.. code:: bash

If the command was successful, you can see the following message printed in your
logs:

  ./byfn.sh up

.. code:: bash

现在你的机器上运行着一个干净的 BYFN 版本，你有两种不同的方式可选。第一种，我们提供
了一个有很好注释的脚本，来执行把 Org3 加入网络的配置交易更新。

  ========= Channel successfully joined ===========

我们也提供同样过程的“手动”版本，演示每一个步骤并解释它完成了什么（我们在之前演示了
如何停止你的网络，你可以先运行那个脚本，然后再来看每个步骤）。


使用脚本将 Org3 加入通道
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now that you have a clean version of the test network running on your machine, we
can start the process of adding a new org to the channel we created. First, we are
going use a script to add Org3 to the channel to confirm that the process works.
Then, we will go through the step by step process of adding Org3 by updating the
channel configuration.

在 ``first-network`` 目录下，简单地执行以下命令来使用脚本：

Bring Org3 into the Channel with the Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

You should be in the ``test-network`` directory. To use the script, simply issue
the following commands:

  ./eyfn.sh up

.. code:: bash

此处的输出值得一读。你可以看到添加了 Org3 的加密材料，配置更新被创建和签名，然后安装
链码， Org3 就可以执行账本查询了。

  cd addOrg3
  ./addOrg3.sh up

如果一切顺利，你会看到以下信息：

The output here is well worth reading. You'll see the Org3 crypto material being
generated, the Org3 organization definition being created, and then the channel
configuration being updated, signed, and then submitted to the channel.

.. code:: bash

If everything goes well, you'll get this message:

  ========= All GOOD, EYFN test execution completed ===========

.. code:: bash

``eyfn.sh`` 可以像 ``byfn.sh`` 一样使用 Node.js 链码和数据库选项，如下所示
（替代 ``./byfn.sh up`` ）：

  ========= Finished adding Org3 to your test network! =========

.. code:: bash

Now that we have confirmed we can add Org3 to our channel, we can go through the
steps to update the channel configuration that the script completed behind the
scenes.

  ./byfn.sh up -c testchannel -s couchdb -l node

Bring Org3 into the Channel Manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

然后：

If you just used the ``addOrg3.sh`` script, you'll need to bring your network down.
The following command will bring down all running components and remove the crypto
material for all organizations:

.. code:: bash

  ./eyfn.sh up -c testchannel -s couchdb -l node

  ./addOrg3.sh down

对于想要详细了解该过程的人，文档的剩余部分会为你展示通道升级的每个命令，以及命令的
作用。

After the network is brought down, bring it back up again:

Bring Org3 into the Channel Manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

.. note:: 下面的步骤均假设 ``CORE_LOGGING_LEVEL`` 变量在 ``cli`` 和 ``Org3cli``
          容器中设置为 ``DEBUG`` 。

  cd ..
  ./network.sh up createChannel

          对于 ``cli`` 容器，你可以通过修改 ``first-network`` 目录下的
          ``docker-compose-cli.yaml`` 文件来配置。例如：

This will bring your network back to the same state it was in before you executed
the ``addOrg3.sh`` script.

          .. code::

Now we're ready to add Org3 to the channel manually. As a first step, we'll need
to generate Org3's crypto material.

            cli:
              container_name: cli
              image: hyperledger/fabric-tools:$IMAGE_TAG
              tty: true
              stdin_open: true
              environment:
                - GOPATH=/opt/gopath
                - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
                #- FABRIC_LOGGING_SPEC=INFO
                - FABRIC_LOGGING_SPEC=DEBUG

Generate the Org3 Crypto Material
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

          对于 ``Org3cli`` 容器，你可以通过修改 ``first-network`` 目录下的
          ``docker-compose-org3.yaml`` 文件来配置。例如：

In another terminal, change into the ``addOrg3`` subdirectory from
``test-network``.

          .. code::

.. code:: bash

            Org3cli:
              container_name: Org3cli
              image: hyperledger/fabric-tools:$IMAGE_TAG
              tty: true
              stdin_open: true
              environment:
                - GOPATH=/opt/gopath
                - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
                #- FABRIC_LOGGING_SPEC=INFO
                - FABRIC_LOGGING_SPEC=DEBUG

  cd addOrg3

如果你已经使用了 ``eyfn.sh`` 脚本，你需要先关闭你的网络。通过如下所示命令来完成：

First, we are going to create the certificates and keys for the Org3 peer, along
with an application and admin user. Because we are updating an example channel,
we are going to use the cryptogen tool instead of using a Certificate Authority.
The following command uses cryptogen  to read the ``org3-crypto.yaml`` file
and generate the Org3 crypto material in a new ``org3.example.com`` folder:

.. code:: bash

  ./eyfn.sh down

  ../../bin/cryptogen generate --config=org3-crypto.yaml --output="../organizations"

这会关闭网络，删除所有的容器，并且撤销我们添加 Org3 的操作。

You can find the generated Org3 crypto material alongside the certificates and
keys for Org1 and Org2 in the ``test-network/organizations/peerOrganizations``
directory.

当网络停止后，再次将它启动起来。

Once we have created the Org3 crypto material, we can use the configtxgen
tool to print out the Org3 organization definition. We will preface the command
by telling the tool to look in the current directory for the ``configtx.yaml``
file that it needs to ingest.

.. code:: bash

  ./byfn.sh generate

    export FABRIC_CFG_PATH=$PWD
    ../../bin/configtxgen -printOrg Org3MSP > ../organizations/peerOrganizations/org3.example.com/org3.json

然后：

The above command creates a JSON file -- ``org3.json`` -- and writes it to the
``test-network/organizations/peerOrganizations/org3.example.com`` folder. The
organization definition contains the policy definitions for Org3, as well as three
important certificates encoded in base64 format:

.. code:: bash

  * a CA root cert, used to establish the organizations root of trust
  * a TLS root cert, used by the gossip protocol to identify Org3 for block dissemination and service discovery
  * The admin user certificate (which will be needed to act as the admin of Org3 later on)

  ./byfn.sh up

We will add Org3 to the channel by appending this organization definition to
the channel configuration.

这会将你的网络恢复到你执行 ``eyfn.sh`` 脚本之前的状态。

Bring up Org3 components
~~~~~~~~~~~~~~~~~~~~~~~~

现在我们可以手动添加 Org3 了。第一步，我们需要生成 Org3 的加密材料。

After we have created the Org3 certificate material, we can now bring up the
Org3 peer. From the ``addOrg3`` directory, issue the following command:

生成 Org3 加密材料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

在另一个终端，切换到 ``first-network`` 的子目录 ``org3-artifacts`` 中。

  docker-compose -f docker/docker-compose-org3.yaml up -d

.. code:: bash

If the command is successful, you will see the creation of the Org3 peer and
an instance of the Fabric tools container named Org3CLI:

  cd org3-artifacts

.. code:: bash

这里需要关注两个 ``yaml`` 文件： ``org3-crypto.yaml`` 和 ``configtx.yaml`` 。首先，
生成 Org3 的加密材料：

  Creating peer0.org3.example.com ... done
  Creating Org3cli                ... done

.. code:: bash

This Docker Compose file has been configured to bridge across our initial network,
so that the Org3 peer and Org3CLI resolve with the existing peers and ordering
node of the test network. We will use the Org3CLI container to communicate with
the network and issue the peer commands that will add Org3 to the channel.

  ../../bin/cryptogen generate --config=./org3-crypto.yaml


该命令读取我们新的加密配置的 ``yaml`` 文件 -- ``org3-crypto.yaml`` -- 然后调用
``cryptogen`` 来为 Org3 CA 和其他两个绑定到这个新组织的节点生成秘钥和证书。就像
BYFN 实现的，加密材料放到当前目录新生成的 ``crypto-config`` 文件夹下（在我们例子
中是 ``org3-artifacts`` ）。

Prepare the CLI Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在使用 ``configtxgen`` 工具以 JSON 格式打印出 Org3 对应的配置材料。我们将在执
行命令时告诉这个工具去获取当前目录的 ``configtx.yaml`` 文件。

The update process makes use of the configuration translator tool -- configtxlator.
This tool provides a stateless REST API independent of the SDK. Additionally it
provides a CLI tool that can be used to simplify configuration tasks in Fabric
networks. The tool allows for the easy conversion between different equivalent
data representations/formats (in this case, between protobufs and JSON).
Additionally, the tool can compute a configuration update transaction based on
the differences between two channel configurations.

.. code:: bash

Use the following command to exec into the Org3CLI container:

    export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json

.. code:: bash

上面的命令会创建一个 JSON 文件 -- ``org3.json`` -- 并把文件输出到 ``first-network``
的 ``channel-artifacts`` 子目录下。这个文件包含了 Org3 的策略定义，还有三个 base 64
格式的重要的证书：管理员用户证书（之后作为 Org3 的管理员角色），一个根证书，一个 TLS
根证书。之后的步骤我们会将这个 JSON 文件追加到通道配置。

  docker exec -it Org3cli bash

我们最后的工作是拷贝排序节点的 MSP 材料到 Org3 的 ``crypto-config`` 目录下。我们
尤其关注排序节点的 TLS 根证书，它可以用于 Org3 的节点和网络的排序节点间的安全通信。

This container has been mounted with the ``organizations`` folder, giving us
access to the crypto material and TLS certificates for all organizations and the
Orderer Org. We can use environment variables to operate the Org3CLI container
as the admin of Org1, Org2, or Org3. First, we need to set the environment
variables for the orderer TLS certificate and the channel name:

.. code:: bash

  cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CHANNEL_NAME=mychannel

Now we're ready to update the channel configuration...

Check to make sure the variables have been properly set:

现在我们准备开始升级通道配置
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

更新的步骤需要用到配置转换工具 -- ``configtxlator`` 。这个工具提供了独立于 SDK 的
无状态 REST API。它还额外提供了 CLI，用于简化 Fabric 网络中的配置任务。这个工具对
不同的数据表示或格式间的转化提供了便利的功能（在这个例子中就是 protobufs 和 JSON
格式的互转）。另外，这个工具能基于两个不同的通道配置计算出配置更新交易。

  echo $ORDERER_CA && echo $CHANNEL_NAME

首先，进入到 CLI 容器。这个容器挂载了 BYFN 的 ``crypto-config`` 目录，允许我们访问之
前两个节点组作织和排序组织的 MSP 材料。默认的身份是 Org1 的管理员用户，所以如果我们
想作为 Org2 进行任何操作，需要设置和 MSP 相关的环境变量。

.. note:: If for any reason you need to restart the Org3CLI container, you will also need to
          re-export the two environment variables -- ``ORDERER_CA`` and ``CHANNEL_NAME``.


Fetch the Configuration
~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

Now we have the Org3CLI container with our two key environment variables -- ``ORDERER_CA``
and ``CHANNEL_NAME`` exported.  Let's go fetch the most recent config block for the
channel -- ``mychannel``.

  docker exec -it cli bash

The reason why we have to pull the latest version of the config is because channel
config elements are versioned. Versioning is important for several reasons. It prevents
config changes from being repeated or replayed (for instance, reverting to a channel config
with old CRLs would represent a security risk). Also it helps ensure concurrency (if you
want to remove an Org from your channel, for example, after a new Org has been added,
versioning will help prevent you from removing both Orgs, instead of just the Org you want
to remove).

设置 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 变量：

Because Org3 is not yet a member of the channel, we need to operate as the admin
of another organization to fetch the channel config. Because Org1 is a member of the channel, the
Org1 admin has permission to fetch the channel config from the ordering service.
Issue the following commands to operate as the Org1 admin.

.. code:: bash

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  && export CHANNEL_NAME=mychannel

  # you can issue all of these commands at once

检查并确保环境变量已正确设置：

  export CORE_PEER_LOCALMSPID="Org1MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

.. code:: bash

We can now issue the command to fetch the latest config block:

  echo $ORDERER_CA && echo $CHANNEL_NAME

.. code:: bash

.. note:: 如果需要重启 CLI 容器，你需要重新设置 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 这两个
          环境变量。

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

获取配置
~~~~~~~~~~~~~~~~~~~~~~~

This command saves the binary protobuf channel configuration block to
``config_block.pb``. Note that the choice of name and file extension is arbitrary.
However, following a convention which identifies both the type of object being
represented and its encoding (protobuf or JSON) is recommended.

现在我们有了一个设置了 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 环境变量的 CLI 容器。让我们
获取通道 ``mychannel`` 的最新的配置区块。

When you issued the ``peer channel fetch`` command, the following output is
displayed in your logs:

我们必须拉取最新版本配置的原因是通道配置元素是版本化的。版本管理由于一些原因显得很重要。
它可以防止通道配置更新被重复或者重放攻击（例如，回退到带有旧的 CRLs 的通道配置将会产生
安全风险）。同时它保证了并行性（例如，如果你想从你的通道中添加新的组织后，再删除一个组
织 ，版本管理可以帮助你移除想移除的那个组织，并防止移除两个组织）。

.. code:: bash

.. code:: bash

  2017-11-07 17:17:57.383 UTC [channelCmd] readBlock -> DEBU 011 Received block: 2

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

This is telling us that the most recent configuration block for ``mychannel`` is
actually block 2, **NOT** the genesis block. By default, the ``peer channel fetch config``
command returns the most **recent** configuration block for the targeted channel, which
in this case is the third block. This is because the test network script, ``network.sh``, defined anchor
peers for our two organizations -- ``Org1`` and ``Org2`` -- in two separate channel update
transactions. As a result, we have the following configuration sequence:

这个命令将通道配置区块以二进制 protobuf 形式保存在 ``config_block.pb`` 。注意文件的
名字和扩展名可以任意指定。然而，为了便于识别，我们建议根据区块存储对象的类型和编码格
式（ protobuf 或 JSON ）进行命名。

  * block 0: genesis block
  * block 1: Org1 anchor peer update
  * block 2: Org2 anchor peer update

当你执行 ``peer channel fetch`` 命令后，在终端上会有相当数量的打印输出。日志的最后一
行比较有意思：

Convert the Configuration to JSON and Trim It Down
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

Now we will make use of the ``configtxlator`` tool to decode this channel
configuration block into JSON format (which can be read and modified by humans).
We also must strip away all of the headers, metadata, creator signatures, and
so on that are irrelevant to the change we want to make. We accomplish this by
means of the ``jq`` tool:

  2017-11-07 17:17:57.383 UTC [channelCmd] readBlock -> DEBU 011 Received block: 2

.. code:: bash

这是告诉我们最新的 ``mychannel`` 的配置区块实际上是区块 2， **并非** 初始区块。 ``peer
channel fetch config`` 命令默认返回目标通道最新的配置区块，在这个例子里是第三个区块。
这是因为 BYFN 脚本分别在两个不同通道更新交易中为两个组织 -- ``Org1`` 和 ``Org2`` -- 定
义了锚节点。

  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

最终，我们有如下的配置块序列：

This command leaves us with a trimmed down JSON object -- ``config.json`` -- which
will serve as the baseline for our config update.

  * block 0: genesis block
  * block 1: Org1 anchor peer update
  * block 2: Org2 anchor peer update

Take a moment to open this file inside your text editor of choice (or in your
browser). Even after you're done with this tutorial, it will be worth studying it
as it reveals the underlying configuration structure and the other kind of channel
updates that can be made. We discuss them in more detail in :doc:`config_update`.

将配置转换到 JSON 格式并裁剪
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add the Org3 Crypto Material
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在我们用 ``configtxlator`` 工具将这个通道配置解码为 JSON 格式（以便友好地被阅读
和修改）。我们也必须裁剪所有的头部、元数据、创建者签名等和我们将要做的修改无关的内
容。我们通过 ``jq`` 这个工具来完成裁剪：
.. code:: bash

.. note:: The steps you've taken up to this point will be nearly identical no matter
          what kind of config update you're trying to make. We've chosen to add an
          org with this tutorial because it's one of the most complex channel
          configuration updates you can attempt.

  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

We'll use the ``jq`` tool once more to append the Org3 configuration definition
-- ``org3.json`` -- to the channel's application groups field, and name the output
-- ``modified_config.json``.

我们得到一个裁剪后的 JSON 对象 -- ``config.json`` ，放置在 ``fabric-samples``
下的 ``first-network`` 文件夹中 -- ``first-network`` 是我们配置更新的基准工作
目录。

.. code:: bash

花一些时间用你的文本编辑器（或者你的浏览器）打开这个文件。即使你已经完成了这个教程，
也值得研究下它，因为它揭示了底层配置结构，和能做的其它类型的通道更新升级。我们将在
:doc:`config_update` 更详细地讨论。

  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./organizations/peerOrganizations/org3.example.com/org3.json > modified_config.json

添加Org3加密材料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now, within the Org3CLI container we have two JSON files of interest -- ``config.json``
and ``modified_config.json``. The initial file contains only Org1 and Org2 material,
whereas the "modified" file contains all three Orgs. At this point it's simply
a matter of re-encoding these two JSON files and calculating the delta.

.. note:: 目前到这里你做的步骤和其他任何类型的配置升级所需步骤几乎是一致的。我们之
          所以选择在教程中添加一个组织，是因为这是能做的配置升级里最复杂的一个。

First, translate ``config.json`` back into a protobuf called ``config.pb``:

我们将再次使用 ``jq`` 工具去追加 Org3 的配置定义 -- ``org3.json`` -- 到通道的应用组
字段，同时定义输出文件是 -- ``modified_config.json`` 。

.. code:: bash

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json

Next, encode ``modified_config.json`` to ``modified_config.pb``:

现在，我们在 CLI 容器有两个重要的 JSON 文件 -- ``config.json`` 和
``modified_config.json`` 。初始的文件包含 Org1 和 Org2 的材料，而 “modified” 文件包
含了总共 3 个组织。现在只需要将这 2 个 JSON 文件重新编码并计算出差异部分。

.. code:: bash

首先，将 ``config.json`` 文件倒回到 protobuf 格式，命名为 ``config.pb`` ：

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

.. code:: bash

Now use ``configtxlator`` to calculate the delta between these two config
protobufs. This command will output a new protobuf binary named ``org3_update.pb``:

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

.. code:: bash

下一步，将 ``modified_config.json`` 编码成 ``modified_config.pb``:

  configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb

.. code:: bash

This new proto -- ``org3_update.pb`` -- contains the Org3 definitions and high
level pointers to the Org1 and Org2 material. We are able to forgo the extensive
MSP material and modification policy information for Org1 and Org2 because this
data is already present within the channel's genesis block. As such, we only need
the delta between the two configurations.

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

Before submitting the channel update, we need to perform a few final steps. First,
let's decode this object into editable JSON format and call it ``org3_update.json``:

现在使用 ``configtxlator`` 去计算两个protobuf 配置的差异。这条命令会输出一个新的
protobuf 二进制文件，命名为 ``org3_update.pb`` 。

.. code:: bash

.. code:: bash

  configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

  configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb

Now, we have a decoded update file -- ``org3_update.json`` -- that we need to wrap
in an envelope message. This step will give us back the header field that we stripped away
earlier. We'll name this file ``org3_update_in_envelope.json``:

这个新的 proto 文件 -- ``org3_update.pb`` -- 包含了 Org3 的定义和指向 Org1 和 Org2
材料的更高级别的指针。我们可以抛弃 Org1 和 Org2 相关的 MSP 材料和修改策略信息，因
为这些数据已经存在于通道的初始区块。因此，我们只需要两个配置的差异部分。

.. code:: bash

在我们提交通道更新前，我们执行最后做几个步骤。首先，我们将这个对象解码成可编辑的
JSON 格式，并命名为 ``org3_update.json`` 。

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

.. code:: bash

Using our properly formed JSON -- ``org3_update_in_envelope.json`` -- we will
leverage the ``configtxlator`` tool one last time and convert it into the
fully fledged protobuf format that Fabric requires. We'll name our final update
object ``org3_update_in_envelope.pb``:

  configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

.. code:: bash

现在，我们有了一个解码后的更新文件 -- ``org3_update.json`` -- 我们需要用信封消息来包装它。这
个步骤要把之前裁剪掉的头部信息还原回来。我们将命名这个新文件为 ``org3_update_in_envelope.json`` 。

  configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

 code:: bash

Sign and Submit the Config Update
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

Almost done!

使用我们格式化好的 JSON -- ``org3_update_in_envelope.json`` -- 我们最后一次使用
``configtxlator`` 工具将他转换为 Fabric 需要的完整独立的 protobuf 格式。我们将最
后的更新对象命名为 ``org3_update_in_envelope.pb`` 。

We now have a protobuf binary -- ``org3_update_in_envelope.pb`` -- within the
Org3CLI container. However, we need signatures from the requisite Admin users
before the config can be written to the ledger. The modification policy (mod_policy)
for our channel Application group is set to the default of "MAJORITY", which means that
we need a majority of existing org admins to sign it. Because we have only two orgs --
Org1 and Org2 -- and the majority of two is two, we need both of them to sign. Without
both signatures, the ordering service will reject the transaction for failing to
fulfill the policy.

.. code:: bash

First, let's sign this update proto as Org1. Remember that we exported the
necessary environment variables to operate the Org3CLI container as the Org1 admin.
As a result, the following ``peer channel signconfigtx`` command will sign the update as Org1.

  configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

.. code:: bash

签名并提交配置更新
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  peer channel signconfigtx -f org3_update_in_envelope.pb

差不多大功告成了！

The final step is to switch the container's identity to reflect the Org2 Admin
user. We do this by exporting four environment variables specific to the Org2 MSP.

我们现在有一个 protobuf 二进制文件 -- ``org3_update_in_envelope.pb`` -- 在我们的 CLI 容
器内。但是，在配置写入到账本前，我们需要来自必要的 Admin 用户的签名。我们通道应用组的修
改策略（mod_policy）设置为默认值 “MAJORITY”，这意味着我们需要大多数已经存在的组织管理员
去签名这个更新。因为我们只有两个组织 -- Org1 和 Org2 -- 所以两个的大多数也还是两个，我们
需要它们都签名。没有这两个签名，排序服务会因为不满足策略而拒绝这个交易。

.. note:: Switching between organizations to sign a config transaction (or to do anything
          else) is not reflective of a real-world Fabric operation. A single container
          would never be mounted with an entire network's crypto material. Rather, the
          config update would need to be securely passed out-of-band to an Org2
          Admin for inspection and approval.

首先，让我们以 Org1 管理员来签名这个更新 proto 。因为 CLI 容器是以 Org1 MSP 材料启动的，
所以我们只需要简单地执行 ``peer channel signconfigtx`` 命令：

Export the Org2 environment variables:

.. code:: bash

  peer channel signconfigtx -f org3_update_in_envelope.pb

  # you can issue all of these commands at once

最后一步，我们将 CLI 容器的身份切换为 Org2 管理员。为此，我们通过导出和 Org2 MSP 相
关的 4 个环境变量。

  export CORE_PEER_LOCALMSPID="Org2MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

.. note:: 切换不同的组织身份为配置交易签名（或者其他事情）不能反映真实世界里 Fabric 的操作。
          一个单一容器不可能挂载了整个网络的加密材料。相反地，配置更新需要在网络外安全地递交
          给 Org2 管理员来审查和批准。

Lastly, we will issue the ``peer channel update`` command. The Org2 Admin signature
will be attached to this call so there is no need to manually sign the protobuf a
second time:

导出 Org2 的环境变量：

.. note:: The upcoming update call to the ordering service will undergo a series
          of systematic signature and policy checks. As such you may find it
          useful to stream and inspect the ordering node's logs. You can issue a
          ``docker logs -f orderer.example.com`` command from a terminal outside
          the Org3CLI container to display them.

.. code:: bash

Send the update call:

  # you can issue all of these commands at once

.. code:: bash

  export CORE_PEER_LOCALMSPID="Org2MSP"

  peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

You should see a message similar to the following if your update has been submitted successfully:

  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

.. code:: bash

  export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

  2020-01-09 21:30:45.791 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update

最后，我们执行 ``peer channel update`` 命令。Org2 管理员在这个命令中会附带签名，因
此就没有必要对 protobuf 进行两次签名。

The successful channel update call returns a new block -- block 3 -- to all of the
peers on the channel. If you remember, blocks 0-2 are the initial channel
configurations. Block 3 serves as the most recent channel configuration with
Org3 now defined on the channel.

.. note:: 将要做的对排序服务的更新调用，会经历一系列的系统级签名和策略检查。你会发现
          通过检视排序节点的日志流会非常有用。在另外一个终端执行
          ``docker logs -f orderer.example.com`` 命令就能展示它们了。

You can inspect the logs for ``peer0.org1.example.com`` by navigating to a terminal
outside the Org3CLI container and issuing the following command:

发起更新调用：

.. code:: bash

.. code:: bash

      docker logs -f peer0.org1.example.com

  peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA


如果你的更新提交成功，将会看到一个类似如下的摘要提示信息：

Join Org3 to the Channel
~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

At this point, the channel configuration has been updated to include our new
organization -- Org3 -- meaning that peers attached to it can now join ``mychannel``.

  2018-02-24 18:56:33.499 UTC [msp/identity] Sign -> DEBU 00f Sign: digest: 3207B24E40DE2FAB87A2E42BC004FEAA1E6FDCA42977CB78C64F05A88E556ABA

Inside the Org3CLI container, export the following environment variables to operate
as the Org3 Admin:

你也会看到配置交易的提交：
.. code:: bash

.. code:: bash

  2018-02-24 18:56:33.499 UTC [channelCmd] update -> INFO 010 Successfully submitted channel update

  # you can issue all of these commands at once

成功的通道更新调用会返回一个新的区块 --  区块 5 -- 给所有在这个通道上的节点。你是否
还记得，区块 0-2 是初始的通道配置，而区块 3 和 4 是链码 ``mycc`` 的实例化和调用。所
以，区块 5 就是带有 Org3 定义的最新的通道配置。

  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org3.example.com:11051

查看 ``peer0.org1.example.com`` 的日志：

Now let's send a call to the ordering service asking for the genesis block of
``mychannel``. As a result of the successful channel update, the ordering service
will verify that Org3 can pull the genesis block and join the channel. If Org3 had not
been successfully appended to the channel config, the ordering service would
reject this request.

.. code:: bash

.. note:: Again, you may find it useful to stream the ordering node's logs
          to reveal the sign/verify logic and policy checks.

      docker logs -f peer0.org1.example.com

Use the ``peer channel fetch`` command to retrieve this block:

如果你想查看新的配置区块的内容，可以跟着示范的过程获取和解码配置区块

.. code:: bash

配置领导节点选举
~~~~~~~~~~~~~~~~~~~~~~~~~~~

  peer channel fetch 0 mychannel.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

.. note:: 引入这个章节作为通用参考，是为了理解在完成网络通道配置初始化之后，增加
          组织时，领导节点选举的设置。这个例子中，默认设置为动态领导选举，这是在
          ``peer-base.yaml`` 文件中为网络中所有的节点设置的。

Notice, that we are passing a ``0`` to indicate that we want the first block on
the channel's ledger; the genesis block. If we simply passed the
``peer channel fetch config`` command, then we would have received block 3 -- the
updated config with Org3 defined. However, we can't begin our ledger with a
downstream block -- we must start with block 0.

新加入的节点是根据初始区块启动的，初始区块是不包含通道配置更新中新加入的组织信息
的。因此新的节点无法利用 gossip 协议，因为它们无法验证从自己组织里其他节点发送过
来的区块，除非它们接收到将组织加入到通道的那个配置交易。新加入的节点必须有以下配
置之一才能从排序服务接收区块：

If successful, the command returned the genesis block to a file named ``mychannel.block``.
We can now use this block to join the peer to the channel. Issue the
``peer channel join`` command and pass in the genesis block to join the Org3
peer to the channel:

1. 采用静态领导者模式，将节点配置为组织的领导者。

.. code:: bash

::

  peer channel join -b mychannel.block

    CORE_PEER_GOSSIP_USELEADERELECTION=false
    CORE_PEER_GOSSIP_ORGLEADER=true



Configuring Leader Election
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: 这个配置对于新加入到通道中的所有节点必须一致。

.. note:: This section is included as a general reference for understanding
          the leader election settings when adding organizations to a network
          after the initial channel configuration has completed. This sample
          defaults to dynamic leader election, which is set for all peers in the
          network.

2. 采用动态领导者选举，配置节点采用领导选举的方式：

Newly joining peers are bootstrapped with the genesis block, which does not
contain information about the organization that is being added in the channel
configuration update. Therefore new peers are not able to utilize gossip as
they cannot verify blocks forwarded by other peers from their own organization
until they get the configuration transaction which added the organization to the
channel. Newly added peers must therefore have one of the following
configurations so that they receive blocks from the ordering service:

::

1. To utilize static leader mode, configure the peer to be an organization
leader:

    CORE_PEER_GOSSIP_USELEADERELECTION=true
    CORE_PEER_GOSSIP_ORGLEADER=false

::


    CORE_PEER_GOSSIP_USELEADERELECTION=false
    CORE_PEER_GOSSIP_ORGLEADER=true

.. note:: 因为新加入组织的节点，无法生成成员关系视图，这个选项和静态配置类似，每
          个节点启动时宣称自己是领导者。但是，一旦它们更新到了将组织加入到通道的
          配置交易，组织中将只会有一个激活状态的领导者。因此，如果你想最终组织的
          节点采用领导选举，建议你采用这个配置。


将 Org3 加入通道
~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: This configuration must be the same for all new peers added to the
          channel.

此时，通道的配置已经更新并包含了我们新的组织 -- ``Org3`` -- 意味者这个组织下的节点可以加入
到 ``mychannel`` 。

2. To utilize dynamic leader election, configure the peer to use leader
election:

首先，让我们部署 Org3 节点容器和 Org3-specific CLI容器。

::

打开一个新的终端并从 ``first-network`` 目录启动 Org3 docker compose ：

    CORE_PEER_GOSSIP_USELEADERELECTION=true
    CORE_PEER_GOSSIP_ORGLEADER=false

.. code:: bash


  docker-compose -f docker-compose-org3.yaml up -d

.. note:: Because peers of the newly added organization won't be able to form
          membership view, this option will be similar to the static
          configuration, as each peer will start proclaiming itself to be a
          leader. However, once they get updated with the configuration
          transaction that adds the organization to the channel, there will be
          only one active leader for the organization. Therefore, it is
          recommended to leverage this option if you eventually want the
          organization's peers to utilize leader election.

这个新的 compose 文件配置为桥接我们的初始网络，因此两个节点容器和 CLI 容器可以连
接到已经存在的节点和排序节点。当三个容器运行后，进入 Org3-specific CLI 容器：


.. code:: bash

.. _upgrade-and-invoke:

  docker exec -it Org3cli bash

Install, define, and invoke chaincode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

和我们之前初始化 CLI 容器一样，导出两个关键环境变量： ``ORDERER_CA`` 和
``CHANNEL_NAME`` ：

We can confirm that Org3 is a member of ``mychannel`` by installing and invoking
a chaincode on the channel. If the existing channel members have already committed
a chaincode definition to the channel, a new organization can start using the
chaincode by approving the chaincode definition.

.. code:: bash

.. note:: These instructions use the Fabric chaincode lifecycle introduced in
          the v2.0 release. If you would like to use the previous lifecycle to
          install and instantiate a chaincode, visit the v1.4 version of the
          `Adding an org to a channel tutorial <https://hyperledger-fabric.readthedocs.io/en/release-1.4/channel_update_tutorial.html>`__.

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

Before we install a chaincode as Org3, we can use the ``./network.sh`` script to
deploy the Fabcar chaincode on the channel. Open a new terminal outside the
Org3CLI container and navigate to the ``test-network`` directory. You can then use
use the ``test-network`` script to deploy the Fabcar chaincode:

检查确保环境变量已经正确设置：

.. code:: bash

.. code:: bash

  cd fabric-samples/test-network
  ./network.sh deployCC

  echo $ORDERER_CA && echo $CHANNEL_NAME

The script will install the Fabcar chaincode on the Org1 and Org2 peers, approve
the chaincode definition for Org1 and Org2, and then commit the chaincode
definition to the channel. Once the chaincode definition has been committed to
the channel, the Fabcar chaincode is initialized and invoked to put initial data
on the ledger. The commands below assume that we are still using the channel
``mychannel``.

现在，我们向排序服务发送一个获取 ``mychannel`` 初始区块的请求。如果通道更新成
功执行，排序服务会成功校验这个请求中 Org3 的签名。如果 Org3 没有成功地添加到通
道配置中，排序服务会拒绝这个请求。

After the chaincode has been to deployed we can use the following steps to use
invoke Fabcar chaincode as Org3. These steps can be completed from the
``test-network`` directory, without having to exec into Org3CLI container. Copy
and paste the following environment variables in your terminal in order to interact
with the network as the Org3 admin:

.. note:: 再次提醒，你会发现查看排序节点的签名和验签逻辑和策略检查的日志是
          很有用的

.. code:: bash

使用 ``peer channel fetch`` 命令来获取这个区块：

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=$PWD/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051

.. code:: bash

The first step is to package the Fabcar chaincode:

  peer channel fetch 0 mychannel.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

.. code:: bash

注意，我们传递了 ``0`` 去索引我们在这个通道账本上想要的区块（例如，初始区块）。如
果我们简单地执行 ``peer channel fetch config`` 命令，我们将会收到区块 5 -- 那个带
有 Org3 定义的更新后的配置。然而，我们的账本不能从一个下游的区块开始 -- 我们必须
从区块 0 开始。

    peer lifecycle chaincode package fabcar.tar.gz --path ../chaincode/fabcar/go/ --lang golang --label fabcar_1

执行 ``peer channel join`` 命令并指定初始区块 -- ``mychannel.block`` ：

This command will create a chaincode package named ``fabcar.tar.gz``, which we can
install on the Org3 peer. Modify the command accordingly if the channel is running a
chaincode written in Java or Node.js. Issue the following command to install the
chaincode package ``peer0.org3.example.com``:

.. code:: bash

  peer channel join -b mychannel.block

    peer lifecycle chaincode install fabcar.tar.gz

如果你想将第二个节点加入到 Org3 中，导出 ``TLS`` 和 ``ADDRESS`` 变量，再重新执
行 ``peer channel join command`` 。


.. code:: bash

The next step is to approve the chaincode definition of Fabcar as Org3. Org3
needs to approve the same definition that Org1 and Org2 approved and committed
to the channel. In order to invoke the chaincode, Org3 needs to include the
package identifier in the chaincode definition. You can find the package
identifier by querying your peer:

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt && export CORE_PEER_ADDRESS=peer1.org3.example.com:12051

.. code:: bash

  peer channel join -b mychannel.block

    peer lifecycle chaincode queryinstalled

.. _upgrade-and-invoke:

You should see output similar to the following:

安装、定义和调用链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

一旦你加入了通道，就可以在Org3中打包和安装链码了。接下来你需要认可Org3中的链码定义，因为这份链码已经在你加入的通道中提交了。
在确认链码后，你就可以使用链码了。

      Get installed chaincodes on peer:
      Package ID: fabcar_1:25f28c212da84a8eca44d14cf12549d8f7b674a0d8288245561246fa90f7ab03, Label: fabcar_1

.. note:: 这些链码生命周期指令是在v2.0 release版本中引入的。如果你想要使用先前的生命周期去安装和实例化链码，可参考v1.4版本的
          `向通道添加组织 <https://hyperledger-fabric.readthedocs.io/en/release-1.4/channel_update_tutorial.html>`__.

We are going to need the package ID in a future command, so lets go ahead and
save it as an environment variable. Paste the package ID returned by the
``peer lifecycle chaincode queryinstalled`` command into the command below. The
package ID may not be the same for all users, so you need to complete this step
using the package ID returned from your console.

第一步是在Org3的CLI中打包链码：

.. code:: bash

.. code:: bash

   export CC_PACKAGE_ID=fabcar_1:25f28c212da84a8eca44d14cf12549d8f7b674a0d8288245561246fa90f7ab03

    peer lifecycle chaincode package mycc.tar.gz --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ --lang golang --label mycc_1

Use the following command to approve a definition of the Fabcar chaincode
for Org3:

这个命令会创建一个链码包，命名为``mycc.tar.gz``，我们用它来在我们的peer上安装链码。
这个命令中，你需要提供一个链码包的标签来描述链码。如果通道中运行的是java或者Node.js语言写的链码，
需要根据实际情况修改这个命令。

.. code:: bash

输入下面的命令在Org3中的peer0上安装链码：

    # use the --package-id flag to provide the package identifier
    # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name fabcar --version 1 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. code:: bash


    # this command installs a chaincode package on your peer
    peer lifecycle chaincode install mycc.tar.gz

You can use the ``peer lifecycle chaincode querycommitted`` command to check if
the chaincode definition you have approved has already been committed to the
channel.

如果你想要在Org3的第二个peer上安装链码，你也可以修改环境变量后，重新使用这个命令。需要指出的是，多次安装不是必须的。
你只需要在那些需要提供背书或用账本提供其他接口(比如查询服务)的peer上安装。没有链码容器的peer作为记账节点，仍然会运行验证逻辑。

.. code:: bash

下一步是以Org3的身份批准链码``mycc``定义。Org3需要批准与Org1和Org2同样的链码定义，然后提交到通道中。链码定义需要包含包标识。
你可以在你的peer中查到包标识：

    # use the --name flag to select the chaincode whose definition you want to query
    peer lifecycle chaincode querycommitted --channelID mychannel --name fabcar --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

.. code:: bash

A successful command will return information about the committed definition:

    # this returns the details of the packages installed on your peers
    peer lifecycle chaincode queryinstalled

.. code:: bash

你应该会看到类似下面的输出：

    Committed chaincode definition for chaincode 'fabcar' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true, Org3MSP: true]

.. code:: bash

Org3 can use the Fabcar chaincode after it approves the chaincode definition
that was committed to the channel. The chaincode definition uses the default endorsement
policy, which requires a majority of organizations on the channel endorse a transaction.
This implies that if an organization is added to or removed from the channel, the
endorsement policy will be updated automatically. We previously needed endorsements
from Org1 and Org2 (2 out of 2). Now we need endorsements from two organizations
out of Org1, Org2, and Org3 (2 out of 3).

      Get installed chaincodes on peer:
      Package ID: mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173, Label: mycc_1

You can query the chaincode to ensure that it has started on the Org3 peer. Note
that you may need to wait for the chaincode container to start.

我们后面的命令中会需要这个包标识。所以让我们继续把它保存到环境变量。把`peer lifecycle chaincode queryinstalled`返回的包标识粘贴到下面的命令中。
这个包标识每个用户可能都不一样，所以需要使用从你控制台返回的包标识完成下一步。

.. code:: bash

.. code:: bash

    peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryAllCars"]}'

   # Save the package ID as an environment variable.

You should see the initial list of cars that were added to the ledger as a
response.

   CC_PACKAGE_ID=mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173

Now, invoke the chaincode to add a new car to the ledger. In the command below,
we target a peer in Org1 and Org3 to collect a sufficient number of endorsements.

使用下面的命令来为Org3批准链码``mycc``定义:

.. code:: bash

.. code:: bash

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n fabcar --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:11051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt -c '{"function":"createCar","Args":["CAR11","Honda","Accord","Black","Tom"]}'

    # this approves a chaincode definition for your org
    # use the --package-id flag to provide the package identifier
    # use the --init-required flag to request the ``Init`` function be invoked to initialize the chaincode
    peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name mycc --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

We can query again to see the new car, "CAR11" on the our the ledger:

你可以使用``peer lifecycle chaincode querycommitted`` 命令来检查你批准的链码定义是否已经提交到通道中。

.. code:: bash

.. code:: bash

    peer chaincode query -C mychannel -n fabcar -c '{"Args":["queryCar","CAR11"]}'

    # use the --name flag to select the chaincode whose definition you want to query
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name mycc --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


成功的命令结果会返回关于被提交的链码定义的信息:

Conclusion
~~~~~~~~~~

.. code:: bash

The channel configuration update process is indeed quite involved, but there is a
logical method to the various steps. The endgame is to form a delta transaction object
represented in protobuf binary format and then acquire the requisite number of admin
signatures such that the channel configuration update transaction fulfills the channel's
modification policy.

    Committed chaincode definition for chaincode 'mycc' on channel 'mychannel':
    Version: 1, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc

The ``configtxlator`` and ``jq`` tools, along with the ``peer channel``
commands, provide us with the functionality to accomplish this task.

既然链码定义已经批准并提交，你可以准备好去使用``mycc``这个链码了。链码定义使用默认的背书策略，一个交易需要通道中大多数组织背书。
这就要求通道中添加或删除组织，背书策略会自动更新。我们之前需要Org1和Org2背书(2/2)。现在我们需要Org1，Org2和Org3中的两个组织背书(2/3)。

Updating the Channel Config to include an Org3 Anchor Peer (Optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

查询链码来确确保链码已经启动。需要说明的是你可能需要等待链码容器启动完成。

The Org3 peers were able to establish gossip connection to the Org1 and Org2
peers since Org1 and Org2 had anchor peers defined in the channel configuration.
Likewise newly added organizations like Org3 should also define their anchor peers
in the channel configuration so that any new peers from other organizations can
directly discover an Org3 peer. In this section, we will make a channel
configuration update to define an Org3 anchor peer. The process will be similar
to the previous configuration update, therefore we'll go faster this time.

.. code:: bash

If you don't have it open, exec back into the Org3CLI container:

    peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

.. code:: bash

我们能看到 ``Query Result：90`` 的响应。

  docker exec -it Org3cli bash

现在执行调用，从 ``a`` 转移 ``10`` 到 ``b``。 在下面的命令中，我们找到Org1和Org3中的peer来收集足够数量的背书。

Export the $ORDERER_CA and $CHANNEL_NAME variables if they are not already set:

.. code:: bash

    peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CHANNEL_NAME=mychannel

最后查询一次：

As before, we will fetch the latest channel configuration to get started.
Inside the Org3CLI container, fetch the most recent config block for the channel,
using the ``peer channel fetch`` command.

.. code:: bash

    peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

我们能看到一个 ``Query Result: 80`` 的响应，准确反映了链码的世界状态的更新。

After fetching the config block we will want to convert it into JSON format. To do
this we will use the configtxlator tool, as done previously when adding Org3 to the
channel. When converting it we need to remove all the headers, metadata, and signatures
that are not required to update Org3 to include an anchor peer by using the jq
tool. This information will be reincorporated later before we proceed to update the
channel configuration.

总结
~~~~~~~~~~

.. code:: bash

通道配置的更新过程是非常复杂的，但是仍然有一个诸多步骤对应的逻辑方法。终局就是为了构建
一个用 protobuf 二进制表达的差异化的交易对象，然后获取必要数量的管理员签名来满足通道的
修改策略。

    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

``configtxlator`` 和 ``jq`` 工具，和不断使用的 ``peer channel`` 命令，为我们提供了完成
这个任务的基本功能。

The ``config.json`` is the now trimmed JSON representing the latest channel configuration
that we will update.

更新通道配置包括Org3的锚节点（可选）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Using the jq tool again, we will update the configuration JSON with the Org3 anchor peer we
want to add.

应为Org1和Org2在通道配置中已经定义了锚节点，所以Org3的节点可以与Org1和Org2的节点通过
gossip协议进行连接。同样，像Org3这样新添加的组织也应该在通道配置中定义它们的锚节点，
以便来自其他组织的任何新节点可以直接发现Org3节点。

.. code:: bash

下面通过Org3的CLI，我们会做一个通道更新来定义Org3锚节点。这个过程与之前通道更新类似，因此这次我们加快一些。

    jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json

和以前一样，我们开始会获取最新的通道配置。在Org3的CLI容器中获取通道中最近的配置区块，
使用``peer channel fetch``命令。

We now have two JSON files, one for the current channel configuration,
``config.json``, and one for the desired channel configuration ``modified_anchor_config.json``.
Next we convert each of these back into protobuf format and calculate the delta between the two.

.. code:: bash

Translate ``config.json`` back into protobuf format as ``config.pb``

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

.. code:: bash

在获取到配置区块后，我们将要把它转换成JSON格式。为此我们会使用configtxlator工具，正如前面在通道中加入Org3一样。
当转换时，我们需要删除所有更新Org3不需要的头部、元数据和签名，使用jq工具添加一个锚节点。这些信息会在更新通道配置前重新合并。

    configtxlator proto_encode --input config.json --type common.Config --output config.pb

.. code:: bash

Translate the ``modified_anchor_config.json`` into protobuf format as ``modified_anchor_config.pb``

    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

.. code:: bash

``config.json``就是现在修剪后的JSON文件，代表我们要更新的最新的通道配置。

    configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

再使用jq工具，我们将想要添加的Org3锚节点更新在JSON配置中。

Calculate the delta between the two protobuf formatted configurations.

.. code:: bash

    jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json

    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

现在我们有两个JSON文件了，一个是当前的通道配置``config.json``，另外一个是期望的通道配置``modified_anchor_config.json``。
接下来我们依次转换成protobuf根式，计算他们之间的增量。

Now that we have the desired update to the channel we must wrap it in an envelope
message so that it can be properly read. To do this we must first convert the protobuf
back into a JSON that can be wrapped.

把``config.json``翻译回protobuf格式``config.pb``。

We will use the configtxlator command again to convert ``anchor_update.pb`` into ``anchor_update.json``

.. code:: bash

    configtxlator proto_encode --input config.json --type common.Config --output config.pb

    configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate | jq . > anchor_update.json

把``modified_anchor_config.json``翻译回protobuf格式``modified_anchor_config.pb``。

Next we will wrap the update in an envelope message, restoring the previously
stripped away header, outputting it to ``anchor_update_in_envelope.json``

.. code:: bash

    configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

    echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json

计算这两个protubuf格式配置的增量。

Now that we have reincorporated the envelope we need to convert it
to a protobuf so it can be properly signed and submitted to the orderer for the update.

.. code:: bash

    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

    configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

现在我们已经有了期望的通道更新，下面必须把它包在一个信封消息里以便正确读取。要做到这一点，
我们先把protobuf格式转换回JSON格式才能被包装。

Now that the update has been properly formatted it is time to sign off and submit it. Since this
is only an update to Org3 we only need to have Org3 sign off on the update. Run the following
commands to make sure that we are operating as the Org3 admin:

我们再使用configtxlator命令，把``anchor_update.pb``转换成``anchor_update.json``。

.. code:: bash

.. code:: bash

  # you can issue all of these commands at once

    configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate | jq . > anchor_update.json

  export CORE_PEER_LOCALMSPID="Org3MSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
  export CORE_PEER_ADDRESS=peer0.org3.example.com:11051

接下来我们来把更新包在信封消息里，恢复先前去掉的头，输出到``anchor_update_in_envelope.json``中。

We can now just use the ``peer channel update`` command to sign the update as the
Org3 admin before submitting it to the orderer.

.. code:: bash

    echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json

    peer channel update -f anchor_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

现在我们已经重新合并了信封，我们需要把它装换成protobuf格式以便正确签名并提交到orderer进行更新。

The orderer receives the config update request and cuts a block with the updated configuration.
As peers receive the block, they will process the configuration updates.

.. code:: bash

Inspect the logs for one of the peers. While processing the configuration transaction from the new block,
you will see gossip re-establish connections using the new anchor peer for Org3. This is proof
that the configuration update has been successfully applied!

    configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

.. code:: bash

现在更新已经被正确根式化，是时候签名并提交了。因为这只是对Org3做更新，我们只需要Org3对更新签名。既然我们已经在Org3的CLI容器里，用的就是Org3的身份，
所以不需要切换容器身份了。因此我们仅需使用``peer channel update``命令，这也会在提交到orderer前用Org3的admin身份对更新进行签名。

    docker logs -f peer0.org1.example.com

.. code:: bash

    peer channel update -f anchor_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

    2019-06-12 17:08:57.924 UTC [gossip.gossip] learnAnchorPeers -> INFO 89a Learning about the configured anchor peers of Org1MSP for channel mychannel : [{peer0.org1.example.com 7051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89b Learning about the configured anchor peers of Org2MSP for channel mychannel : [{peer0.org2.example.com 9051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89c Learning about the configured anchor peers of Org3MSP for channel mychannel : [{peer0.org3.example.com 11051}]

orderer接收到配置更新请求，用这个配置更新切分成区块。当节点接收到区块后，他们就会处理配置更新了。

Congratulations, you have now made two configuration updates --- one to add Org3 to the channel,
and a second to define an anchor peer for Org3.

检查其中一个节点的日志。当处理新区块带来的配置更新时，你会看到gossip使用新的Org3的锚节点重新建立连接。这就证明了配置更新已经成功应用。

.. code:: bash

    docker logs -f peer0.org1.example.com

.. code:: bash

    2019-06-12 17:08:57.924 UTC [gossip.gossip] learnAnchorPeers -> INFO 89a Learning about the configured anchor peers of Org1MSP for channel mychannel : [{peer0.org1.example.com 7051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89b Learning about the configured anchor peers of Org2MSP for channel mychannel : [{peer0.org2.example.com 9051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89c Learning about the configured anchor peers of Org3MSP for channel mychannel : [{peer0.org3.example.com 11051}]

恭喜，你已经成功做了两次配置更新 --- 一个是向通道加入组织，另一个是在组织中定义锚节点。
