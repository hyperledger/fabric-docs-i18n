升级你的网络组件
=================================

.. note:: 在本文中所说的“升级”，是指改变组件的版本（比如，将 v1.3 的二进制文件升
          级到 v1.4 ）。另外，“更新”不是指版本，而是指改变配置，比如更新一个通道
          配置或者部署脚本。因为在 Fabric 中没有技术层面所说的数据迁移，所以我们
          不用“迁移”的说法。

.. note:: 另外，如果你的网络不是使用 Fabric v1.3 ，参照教程 `Upgrading Your Network 
          to v1.3 <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_ 。
          本文仅适用与从 v1.3 到 v1.4 的升级，并不适用其他版本到 v1.4 。

概览
--------

While upgrade to v1.4.0 does not require any capabilities to be enabled,
v1.4.2 offers new capabilities at the orderer, channel, and application levels.
Specifically, the new v1.4.2 capabilities enable the following features:

 * Migration from Kafka to Raft consensus (requires v1.4.2 orderer and channel capabilities)
 * Ability to specify orderer endpoints per organization (requires v1.4.2 channel capability)
 * Ability to store private data for invalidated transactions (requires v1.4.2 application capability)

Because not all users need these new features, enabling the v1.4.2 capabilities
is considered optional (though recommended), and will be detailed in a section
after the main body of this tutorial.

因为 :doc:`build_network` （BYFN）教程默认使用的是“最新”的程序，如果你是在 v1.4 发
布之后运行的，那你的机器上就运行的是 v1.4 的程序和工具，就不用再升级他们了。

所以，本教程将提供一个基于 Hyperledger Fabric v1.3 程序的网络，然后来升级到 v1.4。

整体来看，我们的升级教程有如下步骤：

1. Backup the ledger and MSPs.
2. Upgrade the orderer binaries to Fabric v1.4.x.
3. Upgrade the peer binaries to Fabric v1.4.x.
4. Update channel capabilities to 1.4.2 (optional).

This tutorial will demonstrate how to perform each of these steps individually
with CLI commands. Instructions for both scripted execution and manual execution
are included.

.. note:: 因为 BYFN 使用的是 “SOLO” 排序服务（只有一个排序节点），我们的脚本会下载
          整个网络。但是在生产环境中，排序节点和节点可以同时进行滚动升级。也就是说，
          我们可以在任何一个排序节点升级程序而不需要关闭网络。

          因为 BYFN 不包含下边的组件，所以我们升级 BYFN 的脚本也不包含他们：

          * **Fabric CA**
          * **Kafka**
          * **CouchDB**
          * **SDK**

          这些组件的更新过程 --- 如果必要的话 --- 将会包含在本教程后边的章节中。
          我们还会演示怎么升级 Node 链码。

从操作的角度来说，值得注意的是 v1.4 改变了收集日志的方式，从 ``CORE_LOGGING_LEVEL`` 
（节点的）和 ``ORDERER_GENERAL_LOGLEVEL`` (排序节点的) 变成了 ``FABRIC_LOGGING_SPEC`` 
（新的操作服务的）。更多信息请查阅 `Fabric release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_ 。

前提
~~~~~~~~~~~~~

If you haven’t already done so, ensure you have all of the dependencies on your
machine as described in :doc:`prereqs`. This will include pulling the latest
binaries, which you will use when upgrading.

启动一个 v1.3 的网络 
---------------------

在你要升级到 v1.4.x 之前，你必须先准备一个运行 Fabric v1.3 镜像的网络。

就像 BYFN 教程那样，我们将在你克隆到本地的 ``fabric-samples`` 的子目录 ``first-network`` 
中进行操作。现在要切换到那个目录。你也需要打开几个终端以备使用。

清除
~~~~~~~~

我们希望在一个已知的环境中操作，所以我们将使用 ``byfn.sh`` 脚本来结束所有活动的
或者现有的 docker 容器并删除所有之前生成的构件。运行：

.. code:: bash

  ./byfn.sh down

生成密钥并启动网络
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在一个干净的环境中，使用如下四个命令启动我们的 v1.3 BYFN 网络：

.. code:: bash

  git fetch origin

  git checkout v1.3.0

  ./byfn.sh generate

  ./byfn.sh up -t 3000 -i 1.3.0

.. note:: 如果你本地已编译 v1.3 的镜像，它们将被示例程序直接使用。如果你遇到了错误，请清
          除你本地编译的 v1.3 的镜像，并重新运行示例程序。这将从 docker hub 下载 v1.3 的
          镜像。

如果 BYFN 正常启动，你将看到：

.. code:: bash

  ===================== All GOOD, BYFN execution completed =====================

我们现在就可以准备升级我们的网络到 Hyperledger Fabric v1.4.x 了。

获取最新的示例程序
~~~~~~~~~~~~~~~~~~~~~~

.. note:: The instructions below pertain to whatever is the most recently
          published version of v1.4.x. Please substitute 1.4.x with the version
          identifier of the published release that you are testing, for example,
          replace '1.4.x' with '1.4.2'.

Before completing the rest of the tutorial, it's important to switch to the v1.4.x
(for example, 1.4.2) version of the samples you are upgrading to. For v1.4.2,
this would be:

.. code:: bash

  git checkout v1.4.2

 想现在升级么？
~~~~~~~~~~~~~~~~~~~~

我们有一个脚本可以升级 BYFN 的所有并开启所有能力（注意，在 v1.4 中不需要新的
能力）。如果你在运行一个生产环境的网络，或者你是网络中一些部分的管理员，这个
脚本可以为你的升级工作提供一个模板。

接下来，我们将带你熟悉脚本的每一步，并讲解代码中的每一部分是如何完成升级操作的。

To run the script to upgrade from v1.3 to v1.4.x, issue this command (substituting
your preferred release number for ``x``). Note that the script to upgrade to v1.4.2
will also upgrade the channel capabilities.

.. code:: bash

  ./byfn.sh upgrade -i 1.4.2

如果升级成功，你将看到如下信息：

.. code:: bash

  ===================== All GOOD, End-2-End UPGRADE Scenario execution completed =====================

If you want to upgrade the network manually, simply run ``./byfn.sh down`` again
and perform the steps up to --- but not including --- the ``./byfn.sh upgrade``
step. Then proceed to the next section.

Note that many of the commands you'll run in this section will not result in any
output. In general, assume no output is good output.

Upgrade the orderer containers
------------------------------

排序容器应该以滚动方式升级（每次升级一个）。从上层来说，排序的升级过程如下：

1. 停止排序节点。
2. 备份排序节点的账本和 MSP 。
3. 使用最新镜像重启排序节点。
4. 验证升级完整性。

As a consequence of leveraging BYFN, we have a Solo orderer setup, therefore, we
will only perform this process once. In a Kafka or Raft setup, however, this
process will have to be repeated on each orderer.

.. note:: 本教程使用 docker 部署。对于原生的部署，需要将 ``orderer`` 文件替换为
          新发布的。备份 ``orderer.yaml`` ，并使用新发布的构件中的 ``orderer.yaml`` 
          替换。然后使用旧 ``orderer.yaml`` 文件中的变量替换新文件。你可以使用 
          ``diff`` 之类的工具帮你比较。

现在我们从 **关闭排序节点** 开始升级过程：

.. code:: bash

  docker stop orderer.example.com

  export LEDGERS_BACKUP=./ledgers-backup

  # Note, replace '1.4.x' with a specific version, for example '1.4.2'.
  # Set IMAGE_TAG to 'latest' if you prefer to default to the images tagged 'latest' on your system.

  export IMAGE_TAG=$(go env GOARCH)-1.4.x

我们创建了一个存放备份文件的目录的环境变量，并导出了我们想到升级到的 ``IMAGE_TAG`` 。

当排序节点关闭之后，你就需要 **备份账本和 MSP** ：

.. code:: bash

  mkdir -p $LEDGERS_BACKUP

  docker cp orderer.example.com:/var/hyperledger/production/orderer/ ./$LEDGERS_BACKUP/orderer.example.com

在生产环境中，这个过程需要在每一个基于 Raft 的排序节点上以滚动的方式重复。

现在 **下载并重启排序节点** 的新 Fabric 镜像：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com

因为我们的示例中使用的是 “solo” 类型的排序服务，所以在网络中没有其他的排序节点需要和重启后
的排序节点进行同步。然而，在使用 Kafka 的生产网络中，最好先执行 ``peer channel fetch <blocknumber>`` ，
以验证排序节点在重启后是否同步到了其他排序节点上的数据。

升级节点容器
---------------------------

下一步，我们来看一下怎么将节点容器升级到 Fabric v1.4.x 。节点容器和排序节点容器一样也需要以
滚动的方式升级（每次升级一个）。就像在升级排序节点时提要的一样，排序节点和节点可以同时升级，
但是本教程我们单独来做。从上层来说，我们的操作步骤如下：

1. 停止节点。
2. 备份节点账本和 MSP 。
3. 删除链码容器和镜像。
4. 使用最新的镜像重启节点。
5. 验证升级完整性。

我们的网络中运行了四个节点。我们将在每一个节点上进行一次操作，一共四次升级。

.. note:: 再说一次，本教程使用了 docker 部署。对于 **原生** 的部署，需要将 ``peer`` 
          文件替换为发布版构件。备份 ``core.yaml`` ，并使用新发布的构件中的 ``core.yaml`` 
          替换。然后使用旧 ``core.yaml`` 文件中的变量替换新文件。你可以使用 
          ``diff`` 之类的工具帮你比较。

我们使用如下命令 **关闭第一个节点** ：

.. code:: bash

   export PEER=peer0.org1.example.com

   docker stop $PEER

然后 **备份节点的账本和 MSP** 

.. code:: bash

  mkdir -p $LEDGERS_BACKUP

  docker cp $PEER:/var/hyperledger/production ./$LEDGERS_BACKUP/$PEER

当节点停止并备份好账本之后， **删除节点链码容器** ：

.. code:: bash

  CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
  if [ -n "$CC_CONTAINERS" ] ; then docker rm -f $CC_CONTAINERS ; fi

和节点链码镜像：

.. code:: bash

  CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
  if [ -n "$CC_IMAGES" ] ; then docker rmi -f $CC_IMAGES ; fi

我们将重新使用 v1.4.x 镜像标签重启节点：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml up -d --no-deps $PEER

.. note:: 而且 BYFN 支持使用 CouchDB，本教程的操作仅仅是一个简单的示例。如果
          你使用 CouchDB，请执行下边的命令：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d --no-deps $PEER

.. note:: 你不需要重启链码容器。当节点获得一个链码请求的时候（ invoke 或者 
          query ） ，它会先检查是否运行了链码的拷贝。如果是，就使用它。反之，
          就像本例中一样，节点会重新加载链码（需要的话会重新编译镜像）。

验证节点升级完整性
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

我们已经升级完了我们的第一个节点，但是在继续之前，我们要执行一下链码以确保升级成功。

.. note:: 在我们尝试这个之前，你可能需要升级足够组织的节点以满足背书策略。而且，如
          果你升级的过程中更新了链码，这就是必须的。如果你升级的过程中没有更新链码，
          运行在不同 Fabric 版本上的节点也可以背书成功。

在我们进入 CLI 容器并执行 invoke 之前，使用以下命令确定 CLI 更新到了当前版本：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml stop cli

  docker-compose -f docker-compose-cli.yaml up -d --no-deps cli

Then, get back into the CLI container:

.. code:: bash

  docker exec -it cli bash

现在你需要设置两个环境变量 --- 通道名和 ``ORDERER_CA`` 名：

.. code:: bash

  CH_NAME=mychannel

  ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

现在你可以执行 invoke ：

.. code:: bash

  peer chaincode invoke -o orderer.example.com:7050 --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --tls --cafile $ORDERER_CA -C $CH_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'

我们之前查询 ``a`` 的结果是 ``90`` ，而且我们在 invoke 的时候转移了 ``10`` ，所以 
``a`` 的查询结果应该是 ``80`` 。我们看一下：

.. code:: bash

  peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

你应该看到如下：

.. code:: bash

  Query Result: 80

当成功验证节点的升级候，继续执行升级节点前，请确认执行了 ``exit`` 离开容器。
你可以通过导出不同的节点名字来重复执行上边的步骤。

.. code:: bash

  export PEER=peer1.org1.example.com
  export PEER=peer0.org2.example.com
  export PEER=peer1.org2.example.com

Update channel capabilities to v1.4.2 (optional)
------------------------------------------------

.. note:: A reminder that while we show how to enable v1.4.2 capabilities as part of
          this tutorial, this is an optional step UNLESS you are leveraging
          the v1.4.2 features that require the capabilities.

Although Fabric binaries can and should be upgraded in a rolling fashion, it is
important to finish upgrading binaries before enabling capabilities. Any binaries
which are not upgraded to v1.4.2 before enabling the new v1.4.2 capabilities may
intentionally crash to indicate a misconfiguration which could otherwise result
in a forked blockchain.

Once a capability has been enabled, it becomes part of the permanent record for
that channel. This means that even after disabling the capability, old binaries
will not be able to participate in the channel because they cannot process
beyond the block which enabled the capability to get to the block which disables
it. As a result, once a capability has been enabled, disabling it is neither
recommended nor supported.

For this reason, think of enabling channel capabilities as a point of no return.
Please experiment with the new capabilities in a test setting and be confident
before proceeding to enable them in production.

Capabilities are enabled through a channel configuration transaction. For more
information on updating channel configs, check out :doc:`channel_update_tutorial`
or the doc on :doc:`config_update`.

To learn about what the new capabilities are in v1.4.2 and what they enable, refer
back to the Overview_.

We will enable these capabilities in the following order:

1. Orderer System Channel

  a. Orderer Group
  b. Channel Group

2. Individual Channels

  a. Orderer Group
  b. Channel Group
  c. Application Group

Updating a channel configuration is a three step process:

1. Get the latest channel config
2. Create a modified channel config
3. Create a config update transaction

.. note:: In a real world production network, these channel config updates would
          be handled by the admins for each channel. Because BYFN all exists on
          a single machine, it is possible for us to update each of these
          channels.

For more information on updating channel configs, click on :doc:`channel_update_tutorial`
or the doc on :doc:`config_update`.

Orderer System Channel Capabilities
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Because only ordering organizations admins can update the ordering system channel,
we need set environment variables for the system channel that will allow us to
carry out these tasks. Issue each of these commands:

.. code:: bash

  CORE_PEER_LOCALMSPID="OrdererMSP"

  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp

  ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

If we're upgrading from v1.3 to v1.4.2, we need to set the system channel name
to ``testchainid``:

.. code:: bash

  CH_NAME=testchainid

If we're upgrading from v1.4.1 to v1.4.2, we need to set the system channel name
to ``byfn-sys-channel``:

.. code:: bash

  CH_NAME=byfn-sys-channel

Orderer Group
^^^^^^^^^^^^^

The first step in updating a channel configuration is getting the latest config
block:

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME --tls --cafile $ORDERER_CA

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > config.json

Next, add capabilities to the orderer group. The following command will create a
copy of the config file and change the capability level:

.. code:: bash

  jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1]}}}}}' config.json ./scripts/capabilities.json > modified_config.json

Now we can create the config update:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

  configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb

Package the config update into a transaction:

.. code:: bash

  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

Submit the config update transaction:

.. code:: bash

  peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA

Our config update transaction represents the difference between the original
config and the modified one, but the ordering service will translate this into a
full channel config.

Channel Group
^^^^^^^^^^^^^

Now let’s move on to updating the capability level for the channel group at the
orderer system level.

The first step, as before, is to get the latest channel configuration.

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME --tls --cafile $ORDERER_CA

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > config.json

Next, create a modified channel config:

.. code:: bash

  jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1]}}}' config.json ./scripts/capabilities.json > modified_config.json

Create the config update transaction:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

  configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb

Package the config update into a transaction:

.. code:: bash

  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

Submit the config update transaction:

.. code:: bash

  peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA

Enabling Capabilities on Existing Channels
------------------------------------------

Now that we have updating the capabilities on the ordering system channel, we
need to updating the configuration of any existing application channels. We only
have one application channel: ``mychannel``. So let's set that name as an
environment variable.

.. code:: bash

  CH_NAME=mychannel

Orderer Group
~~~~~~~~~~~~~

Like the ordering system channel, our application channel also has an orderer
group.

Get the channel config:

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME  --tls --cafile $ORDERER_CA

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > config.json

Change the capability level of the orderer group:

.. code:: bash

  jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1]}}}}}' config.json ./scripts/capabilities.json > modified_config.json

Create the config update:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

  configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb

Package the config update into a transaction:

.. code:: bash

  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

Submit the config update transaction:

.. code:: bash

  peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA

Channel Group
~~~~~~~~~~~~~

Now we need to change the capability of the ``channel`` group of our application
channel.

As before, fetch, decode, and scope the config:

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME --tls --cafile $ORDERER_CA

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > config.json

Create a modified config:

.. code:: bash

  jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1]}}}' config.json ./scripts/capabilities.json > modified_config.json

Create the config update:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

  configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb

Package the config update into a transaction:

.. code:: bash

  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

Because we're updating the config of the ``channel`` group, the relevant orgs ---
Org1, Org2, and the OrdererOrg --- need to sign it. This task would usually
be performed by the individual org admins, but in BYFN, as we've said, this task
falls to us.

First, switch into Org1 and sign the update:

.. code:: bash

  CORE_PEER_LOCALMSPID="Org1MSP"

  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

  CORE_PEER_ADDRESS=peer0.org1.example.com:7051

  peer channel signconfigtx -f config_update_in_envelope.pb

And do the same as Org2:

.. code:: bash

  CORE_PEER_LOCALMSPID="Org2MSP"

  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

  CORE_PEER_ADDRESS=peer0.org1.example.com:7051

  peer channel signconfigtx -f config_update_in_envelope.pb

And as the OrdererOrg:

.. code:: bash

  CORE_PEER_LOCALMSPID="OrdererMSP"

  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp

  peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA

Application Group
~~~~~~~~~~~~~~~~~

For the application group, we will need to reset the environment variables as
one organization:

.. code:: bash

  CORE_PEER_LOCALMSPID="Org1MSP"

  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

  CORE_PEER_ADDRESS=peer0.org1.example.com:7051

Now, get the latest channel config (this process should be very familiar by now):

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CH_NAME --tls --cafile $ORDERER_CA

  configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

  jq .data.data[0].payload.data.config config_block.json > config.json

Create a modified channel config:

.. code:: bash

  jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"Capabilities": .[1]}}}}}' config.json ./scripts/capabilities.json > modified_config.json

Note what we’re changing here: ``Capabilities`` are being added as a ``value``
of the ``Application`` group under ``channel_group`` (in ``mychannel``).

Create a config update transaction:

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

  configtxlator compute_update --channel_id $CH_NAME --original config.pb --updated modified_config.pb --output config_update.pb

Package the config update into a transaction:

.. code:: bash

  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CH_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json

  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

Org1 signs the transaction:

.. code:: bash

  peer channel signconfigtx -f config_update_in_envelope.pb

Set the environment variables as Org2:

.. code:: bash

  export CORE_PEER_LOCALMSPID="Org2MSP"

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

  export CORE_PEER_ADDRESS=peer0.org2.example.com:7051

Org2 submits the config update transaction with its signature:

.. code:: bash

  peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA

Congratulations! You have now enabled capabilities on all of your channels.

Verify a transaction after Capabilities have been Enabled
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

But let's test just to make sure by moving ``10`` from ``a`` to ``b``, as before:

.. code:: bash

  peer chaincode invoke -o orderer.example.com:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  -C mychannel -n mycc -c '{"Args":["invoke","a","b","10"]}'

And then querying the value of ``a``, which should reveal a value of ``70``.
Let’s see:

.. code:: bash

  peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

We should see the following:

.. code:: bash

  Query Result: 70

In which case we have successfully added capabilities to all of our channels.

Upgrading components BYFN does not support
------------------------------------------

Although this is the end of our update tutorial, there are other components that
exist in production networks that are not covered in this tutorial. In this
section, we’ll talk through the process of updating them.

Fabric CA container
~~~~~~~~~~~~~~~~~~~

To learn how to upgrade your Fabric CA server, click over to the
`CA documentation <http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server>`_.

Upgrade Node SDK clients
~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: Upgrade Fabric and Fabric CA before upgrading Node SDK clients.
          Fabric and Fabric CA are tested for backwards compatibility with
          older SDK clients. While newer SDK clients often work with older
          Fabric and Fabric CA releases, they may expose features that
          are not yet available in the older Fabric and Fabric CA releases,
          and are not tested for full compatibility.

Use NPM to upgrade any ``Node.js`` client by executing these commands in the
root directory of your application:

..  code:: bash

  npm install fabric-client@latest

  npm install fabric-ca-client@latest

These commands install the new version of both the Fabric client and Fabric-CA
client and write the new versions ``package.json``.

升级 Kafka 集群
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: If you intend to migrate from a Kafka-based ordering service to a Raft-based
          ordering service, check out :doc:`kafka_raft_migration`.

这并不是必须的，但是建议将 Kafka 集群升级并和其他 Fabric 保持一致。新版本的 Kafka 
支持旧版本的协议，所以你可以在升级完其他 Fabric 之前或之后再升级 Kafka。

如果你学习了 `Upgrading Your Network to v1.3 tutorial <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_ ，
你的 Kafka 集群应该是 v1.0.0 。如果不是，参考官方 Apache Kafka 文档 `upgrading Kafka from previous versions`__ 
来升级 Kafka 集群的 brokers 。


.. __: https://kafka.apache.org/documentation/#upgrade

升级 Zookeeper
^^^^^^^^^^^^^^^^^^^

一个 Apache Kafka 集群需要一个 Apache Zookeeper 集群。Zookeeper API 在很长一段时
间内都很稳定，并且 Kafka 几乎兼容所有版本的 Zookeeper 。参考 `Apache Kafka upgrade`__ 
文档中升级 Zookeeper 到指定版本的依赖。如果你想升级你的 Zookeeper 集群，可以在 
`Zookeeper FAQ`__ 上找到升级 Zookeeper 集群的一些信息。

.. _Apache Kafka upgrade: https://kafka.apache.org/documentation/#upgrade
.. _Zookeeper FAQ: https://cwiki.apache.org/confluence/display/ZOOKEEPER/FAQ

升级 CouchDB
~~~~~~~~~~~~~~~~~

如果你使用 CouchDB 作为状态数据库，你需要在升级节点的同时升级节点的 CouchDB 。
CouchDB v2.2.0 在 Fabric v1.4.x 中已经被测试过了。

升级 CouchDB ：

1. 停止 CouchDB 。
2. 备份 CouchDB 数据目录。
3. 安装 CouchDB v2.2.0 二进制或者更新部署脚本来使用新的 Docker 镜像 （Fabric v1.4 中提供
   了预配置 CouchDB v2.2.0 的 Docker 镜像）。
4. 重启 CouchDB 。

升级 Node 链码 shim
~~~~~~~~~~~~~~~~~~~~~~~~~~~

为了更新到新版本的 Node 链码 shim ，开发者需要：

1. 在链码的 ``package.json`` 中将 ``fabric-shim`` 级别从 1.3 改为 1.4.x 。
2. 重新打包新的链码包，并在通道中所有的背书节点安装。
3. 执行升级链码。如何升级链码，请参考 :doc:`commands/peerchaincode` 。

.. note:: 这个流程并不针对从 1.3 升级到 1.4.x 。它同样适用与将 node Fabric shim 升
          级到任何新增版本。

使用 vendored shim 升级链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: v1.4 节点兼容 v1.3.0 shim ，但是，最好将链码 shim 升级到匹配当前级别的
          节点的版本。

有很多第三方工具可以让你 vendor 链码的 shim 。如果你使用了这些工具，就在更新和重打包
链码的时候使用同一个工具。

如果你的链码在升级 shim 之后引用了 shim，你必须在所有已经有了链码的节点上安装它。使用同
样的名字和新的版本安装。然后你要在每一个部署了这个链码的通道上执行链码升级，才可以升级到
新版本。

如果你没有 vendor 你的链码，你完全可以跳过这一步。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
