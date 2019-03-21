Upgrading Your Network Components - 升级你的网络组件
=================================

.. note:: When we use the term “upgrade” in this documentation, we’re primarily
          referring to changing the version of a component (for example, going
          from a v1.3 binary to a v1.4 binary). The term “update,” on the other
          hand, refers not to versions but to configuration changes, such as
          updating a channel configuration or a deployment script. As there is
          no data migration, technically speaking, in Fabric, we will not use
          the term "migration" or "migrate" here.

.. note:: 在本文中所说的“升级”，是指改变组件的版本（比如，将 v1.3 的二进制文件升
          级到 v1.4 ）。另外，“更新”不是指版本，而是指改变配置，比如更新一个通道
          配置或者部署脚本。因为在 Fabric 中没有技术层面所说的数据迁移，所以我们
          不用“迁移”的说法。

.. note:: Also, if your network is not yet at Fabric v1.3, follow the instructions for
          `Upgrading Your Network to v1.3 <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_.
          The instructions in this documentation only cover moving from v1.3 to
          v1.4, not from any other version to v1.4.

.. note:: 另外，如果你的网络不是使用 Fabric v1.3 ，参照教程 `Upgrading Your Network 
          to v1.3 <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_ 。
          本文仅适用与从 v1.3 到 v1.4 的升级，并不适用其他版本到 v1.4 。

Overview - 概览
--------

Because the :doc:`build_network` (BYFN) tutorial defaults to the “latest” binaries,
if you have run it since the release of v1.4, your machine will have v1.4 binaries
and tools installed on it and you will not be able to upgrade them.

因为 :doc:`build_network` （BYFN）教程默认使用的是“最新”的程序，如果你是在 v1.4 发
布之后运行的，那你的机器上就运行的是 v1.4 的程序和工具，就不用再升级他们了。

As a result, this tutorial will provide a network based on Hyperledger Fabric
v1.3 binaries as well as the v1.4 binaries you will be upgrading to.

所以，本教程将提供一个基于 Hyperledger Fabric v1.3 程序的网络，然后来升级到 v1.4。

At a high level, our upgrade tutorial will perform the following steps:

整体来看，我们的升级教程有如下步骤：

1. Backup the ledger and MSPs.
2. Upgrade the orderer binaries to Fabric v1.4.
3. Upgrade the peer binaries to Fabric v1.4.

1. 备份账本和 MSP 。
2. 升级 orderer 程序到 Fabric v1.4 。
3. 升级 peer 程序到 Fabric v1.4 。

.. note:: There are no new :doc:`capability_requirements` in v1.4. As a result,
          we do not have to update any channel configurations as part of an
          upgrade to v1.4.

.. note:: 在 v1.4 中没有新的 :doc:`capability_requirements` 。所以，在升级到 
          v1.4 的过程中不需要跟新通道配置。

This tutorial will demonstrate how to perform each of these steps individually
with CLI commands. We will also describe how the CLI ``tools`` image can be
updated.

本教程将演示如何使用 CLI 命令完成这些步骤。我们也会说明如何更新 CLI ``工具`` 
镜像。

.. note:: Because BYFN uses a "SOLO" ordering service (one orderer), our script
          brings down the entire network. However, in production environments,
          the orderers and peers can be upgraded simultaneously and on a rolling
          basis. In other words, you can upgrade the binaries in any order without
          bringing down the network.

.. note:: 因为 BYFN 使用的是 “SOLO” 排序服务（只有一个排序节点），我们的脚本会下载
          整个网络。但是在生产环境中，排序节点和节点可以同时进行滚动升级。也就是说，
          我们可以在任何一个排序节点升级程序而不需要关闭网络。

          Because BYFN is not compatible with the following components, our script for
          upgrading BYFN will not cover them:

          因为 BYFN 不包含下边的组件，所以我们升级 BYFN 的脚本也不包含他们：

          * **Fabric CA**
          * **Kafka**
          * **CouchDB**
          * **SDK**

          The process for upgrading these components --- if necessary --- will
          be covered in a section following the tutorial. We will also show how
          to upgrade the Node chaincode shim.

          这些组件的更新过程 --- 如果必要的话 --- 将会包含在本教程后边的章节中。
          我们还会演示怎么升级 Node 链码。

From an operational perspective, it's worth noting that the process for gathering
logs has changed in v1.4, from ``CORE_LOGGING_LEVEL`` (for the peer) and
``ORDERER_GENERAL_LOGLEVEL`` (for the orderer) to ``FABRIC_LOGGING_SPEC`` (the new
operations service). For more information, check out the
`Fabric release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_.

从操作的角度来说，值得注意的是 v1.4 改变了收集日志的方式，从 ``CORE_LOGGING_LEVEL`` 
（节点的）和 ``ORDERER_GENERAL_LOGLEVEL`` (排序节点的) 变成了 ``FABRIC_LOGGING_SPEC`` 
（新的操作服务的）。更多信息请查阅 `Fabric release notes <https://github.com/hyperledger/fabric/releases/tag/v1.4.0>`_ 。

Prerequisites - 前提
~~~~~~~~~~~~~

If you haven’t already done so, ensure you have all of the dependencies on your
machine as described in :doc:`prereqs`.

如果你还没有这样做，确保你的机器上安装了 :doc:`prereqs` 中所描述的所有依赖。

Launch a v1.3 network - 启动一个 v1.3 的网络 
---------------------

Before we can upgrade to v1.4, we must first provision a network running Fabric
v1.3 images.

在你要升级到 v1.4 之前，你必须先准备一个运行 Fabric v1.3 镜像的网络。

Just as in the BYFN tutorial, we will be operating from the ``first-network``
subdirectory within your local clone of ``fabric-samples``. Change into that
directory now. You will also want to open a few extra terminals for ease of use.

就像 BYFN 教程那样，我们将在你克隆到本地的 ``fabric-samples`` 的子目录 ``first-network`` 
中进行操作。现在要切换到那个目录。你也需要打开几个终端以备使用。

Clean up - 清除
~~~~~~~~

We want to operate from a known state, so we will use the ``byfn.sh`` script to
kill any active or stale docker containers and remove any previously generated
artifacts. Run:

我们希望在一个已知的环境中操作，所以我们将使用 ``byfn.sh`` 脚本来结束所有活动的
或者现有的 docker 容器并删除所有之前生成的构件。运行：

.. code:: bash

  ./byfn.sh down

Generate the crypto and bring up the network - 生成密钥并启动网络
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With a clean environment, launch our v1.3 BYFN network using these four commands:

在一个干净的环境中，使用如下四个命令启动我们的 v1.3 BYFN 网络：

.. code:: bash

  git fetch origin

  git checkout v1.3.0

  ./byfn.sh generate

  ./byfn.sh up -t 3000 -i 1.3.0

.. note:: If you have locally built v1.3 images, they will be used by the example.
          If you get errors, please consider cleaning up your locally built v1.3 images
          and running the example again. This will download v1.3 images from docker hub.

.. note:: 如果你本地已编译 v1.3 的镜像，它们将被示例程序直接使用。如果你遇到了错误，请清
          除你本地编译的 v1.3 的镜像，并重新运行示例程序。这将从 docker hub 下载 v1.3 的
          镜像。

If BYFN has launched properly, you will see:

如果 BYFN 正常启动，你将看到：

.. code:: bash

  ===================== All GOOD, BYFN execution completed =====================

We are now ready to upgrade our network to Hyperledger Fabric v1.4.

我们现在就可以准备升级我们的网络到 Hyperledger Fabric v1.4 了。

Get the newest samples - 获取最新的示例程序
~~~~~~~~~~~~~~~~~~~~~~

.. note:: The instructions below pertain to whatever is the most recently
          published version of v1.4.x. Please substitute 1.4.x with the version
          identifier of the published release that you are testing. In other
          words, replace '1.4.x' with '1.4.0' if you are testing the first
          release.

.. note:: 下边的内容基于最新发布的 v1.4.x 版本。请使用你想测试的发布版本的版本号
          替换 1.4.x 。换句话说，如果你想测试第一个发布版本，就使用 '1.4.0' 替换
          '1.4.x' 。

Before completing the rest of the tutorial, it's important to get the v1.4.x
version of the samples, you can do this by issuing:

在完成剩余的教程之前，获取最新的 v1.4.x 版本的示例程序很重要，你可以执行下边的命
令来获取：

.. code:: bash

  git fetch origin

  git checkout v1.4.x

Want to upgrade now? - 想现在升级么？
~~~~~~~~~~~~~~~~~~~~

We have a script that will upgrade all of the components in BYFN as well as
enable any capabilities (note, no new capabilities are required for v1.4).
If you are running a production network, or are an
administrator of some part of a network, this script can serve as a template
for performing your own upgrades.

我们有一个脚本可以升级 BYFN 的所有并开启所有能力（注意，在 v1.4 中不需要新的
能力）。如果你在运行一个生产环境的网络，或者你是网络中一些部分的管理员，这个
脚本可以为你的升级工作提供一个模板。

Afterwards, we will walk you through the steps in the script and describe what
each piece of code is doing in the upgrade process.

接下来，我们将带你熟悉脚本的每一步，并讲解代码中的每一部分是如何完成升级操作的。

To run the script, issue these commands:

运行下面的命令来执行脚本：

.. code:: bash

  # Note, replace '1.4.x' with a specific version, for example '1.4.0'.
  # Don't pass the image flag '-i 1.4.x' if you prefer to default to 'latest' images.

  ./byfn.sh upgrade -i 1.4.x

If the upgrade is successful, you should see the following:

如果升级成功，你将看到如下信息：

.. code:: bash

  ===================== All GOOD, End-2-End UPGRADE Scenario execution completed =====================

If you want to upgrade the network manually, simply run ``./byfn.sh down`` again
and perform the steps up to --- but not including --- ``./byfn.sh upgrade -i 1.4.x``.
Then proceed to the next section.

如果你想手动升级网络，简单的再执行一下 ``./byfn.sh down`` 然后执行上边除 
``./byfn.sh upgrade -i 1.4.x`` 以外的步骤。然后执行下边章节中的内容。

.. note:: Many of the commands you'll run in this section will not result in any
          output. In general, assume no output is good output.

.. note:: 本章节中的很多命令，你在运行的时候没有任何输出结果。一般来说，没有输出
          才是最好的输出。

Upgrade the orderer containers - 升级排序节点容器
------------------------------

Orderer containers should be upgraded in a rolling fashion (one at a time). At a
high level, the orderer upgrade process goes as follows:

排序容器应该以滚动方式升级（每次升级一个）。从上层来说，排序的升级过程如下：

1. Stop the orderer.
2. Back up the orderer’s ledger and MSP.
3. Restart the orderer with the latest images.
4. Verify upgrade completion.

1. 停止排序节点。
2. 备份排序节点的账本和 MSP 。
3. 使用最新镜像重启排序节点。
4. 验证升级完整性。

As a consequence of leveraging BYFN, we have a solo orderer setup, therefore, we
will only perform this process once. In a Kafka setup, however, this process will
have to be repeated on each orderer.

基于 BYFN 网络，由于我们设置了一个 solo 类型的排序节点，所以我们只需要处理一次就
可以了。对于 Kafka 的设置，这个处理过程需要在每一个排序节点上重复。

.. note:: This tutorial uses a docker deployment. For native deployments,
          replace the file ``orderer`` with the one from the release artifacts.
          Backup the ``orderer.yaml`` and replace it with the ``orderer.yaml``
          file from the release artifacts. Then port any modified variables from
          the backed up ``orderer.yaml`` to the new one. Utilizing a utility
          like ``diff`` may be helpful.

.. note:: 本教程使用 docker 部署。对于原生的部署，需要将 ``orderer`` 文件替换为
          新发布的。备份 ``orderer.yaml`` ，并使用新发布的构件中的 ``orderer.yaml`` 
          替换。然后使用旧 ``orderer.yaml`` 文件中的变量替换新文件。你可以使用 
          ``diff`` 之类的工具帮你比较。

Let’s begin the upgrade process by **bringing down the orderer**:

现在我们从 **关闭排序节点** 开始升级过程：

.. code:: bash

  docker stop orderer.example.com

  export LEDGERS_BACKUP=./ledgers-backup

  # Note, replace '1.4.x' with a specific version, for example '1.4.0'.
  # Set IMAGE_TAG to 'latest' if you prefer to default to the images tagged 'latest' on your system.

  export IMAGE_TAG=$(go env GOARCH)-1.4.x

We have created a variable for a directory to put file backups into, and
exported the ``IMAGE_TAG`` we'd like to move to.

我们创建了一个存放备份文件的目录的环境变量，并导出了我们想到升级到的 ``IMAGE_TAG`` 。

Once the orderer is down, you'll want to **backup its ledger and MSP**:

当排序节点关闭之后，你就需要 **备份账本和 MSP** ：

.. code:: bash

  mkdir -p $LEDGERS_BACKUP

  docker cp orderer.example.com:/var/hyperledger/production/orderer/ ./$LEDGERS_BACKUP/orderer.example.com

In a production network this process would be repeated for each of the Kafka-based
orderers in a rolling fashion.

在生产环境中，这个过程需要在每一个基于 Kafka 的排序节点上以滚动的方式重复。

Now **download and restart the orderer** with our new fabric image:

现在 **下载并重启排序节点** 的新 Fabric 镜像：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com

Because our sample uses a "solo" ordering service, there are no other orderers in the
network that the restarted orderer must sync up to. However, in a production network
leveraging Kafka, it will be a best practice to issue ``peer channel fetch <blocknumber>``
after restarting the orderer to verify that it has caught up to the other orderers.

因为我们的示例中使用的是 “solo” 类型的排序服务，所以在网络中没有其他的排序节点需要和重启后
的排序节点进行同步。然而，在使用 Kafka 的生产网络中，最好先执行 ``peer channel fetch <blocknumber>`` ，
以验证排序节点在重启后是否同步到了其他排序节点上的数据。

Upgrade the peer containers - 升级节点容器
---------------------------

Next, let's look at how to upgrade peer containers to Fabric v1.4. Peer containers should,
like the orderers, be upgraded in a rolling fashion (one at a time). As mentioned
during the orderer upgrade, orderers and peers may be upgraded in parallel, but for
the purposes of this tutorial we’ve separated the processes out. At a high level,
we will perform the following steps:

下一步，我们来看一下怎么将节点容器升级到 Fabric v1.4 。节点容器和排序节点容器一样也需要以
滚动的方式升级（每次升级一个）。就像在升级排序节点时提要的一样，排序节点和节点可以同时升级，
但是本教程我们单独来做。从上层来说，我们的操作步骤如下：

1. Stop the peer.
2. Back up the peer’s ledger and MSP.
3. Remove chaincode containers and images.
4. Restart the peer with latest image.
5. Verify upgrade completion.

1. 停止节点。
2. 备份节点账本和 MSP 。
3. 删除链码容器和镜像。
4. 使用最新的镜像重启节点。
5. 验证升级完整性。

We have four peers running in our network. We will perform this process once for
each peer, totaling four upgrades.

我们的网络中运行了四个节点。我们将在每一个节点上进行一次操作，一共四次升级。

.. note:: Again, this tutorial utilizes a docker deployment. For **native**
          deployments, replace the file ``peer`` with the one from the release
          artifacts. Backup your ``core.yaml`` and replace it with the one from
          the release artifacts. Port any modified variables from the backed up
          ``core.yaml`` to the new one. Utilizing a utility like ``diff`` may be
          helpful.

.. note:: 再说一次，本教程使用了 docker 部署。对于 **原生** 的部署，需要将 ``peer`` 
          文件替换为发布版构件。备份 ``core.yaml`` ，并使用新发布的构件中的 ``core.yaml`` 
          替换。然后使用旧 ``core.yaml`` 文件中的变量替换新文件。你可以使用 
          ``diff`` 之类的工具帮你比较。

Let’s **bring down the first peer** with the following command:

我们使用如下命令 **关闭第一个节点** ：

.. code:: bash

   export PEER=peer0.org1.example.com

   docker stop $PEER

We can then **backup the peer’s ledger and MSP**:

然后 **备份节点的账本和 MSP** ：

.. code:: bash

  mkdir -p $LEDGERS_BACKUP

  docker cp $PEER:/var/hyperledger/production ./$LEDGERS_BACKUP/$PEER

With the peer stopped and the ledger backed up, **remove the peer chaincode
containers**:

当节点停止并备份好账本之后， **删除节点链码容器** ：

.. code:: bash

  CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
  if [ -n "$CC_CONTAINERS" ] ; then docker rm -f $CC_CONTAINERS ; fi

And the peer chaincode images:

和节点链码镜像：

.. code:: bash

  CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
  if [ -n "$CC_IMAGES" ] ; then docker rmi -f $CC_IMAGES ; fi

Now we'll re-launch the peer using the v1.4 image tag:

我们将重新使用 v1.4 镜像标签重启节点：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml up -d --no-deps $PEER

.. note:: Although, BYFN supports using CouchDB, we opted for a simpler
          implementation in this tutorial. If you are using CouchDB, however,
          issue this command instead of the one above:

.. note:: 而且 BYFN 支持使用 CouchDB，本教程的操作仅仅是一个简单的示例。如果
          你使用 CouchDB，请执行下边的命令：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml -f docker-compose-couch.yaml up -d --no-deps $PEER

.. note:: You do not need to relaunch the chaincode container. When the peer gets
          a request for a chaincode, (invoke or query), it first checks if it has
          a copy of that chaincode running. If so, it uses it. Otherwise, as in
          this case, the peer launches the chaincode (rebuilding the image if
          required).

.. note:: 你不需要重启链码容器。当节点获得一个链码请求的时候（ invoke 或者 
          query ） ，它会先检查是否运行了链码的拷贝。如果是，就使用它。反之，
          就像本例中一样，节点会重新加载链码（需要的话会重新编译镜像）。
          
Verify peer upgrade completion - 验证节点升级完整性
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We’ve completed the upgrade for our first peer, but before we move on let’s check
to ensure the upgrade has been completed properly with a chaincode invoke.

我们已经升级完了我们的第一个节点，但是在继续之前，我们要执行一下链码以确保升级成功。

.. note:: Before you attempt this, you may want to upgrade peers from
          enough organizations to satisfy your endorsement policy.
          Although, this is only mandatory if you are updating your chaincode
          as part of the upgrade process. If you are not updating your chaincode
          as part of the upgrade process, it is possible to get endorsements
          from peers running at different Fabric versions.

.. note:: 在我们尝试这个之前，你可能需要升级足够组织的节点以满足背书策略。而且，如
          果你升级的过程中更新了链码，这就是必须的。如果你升级的过程中没有更新链码，
          运行在不同 Fabric 版本上的节点也可以背书成功。

Before we get into the CLI container and issue the invoke, make sure the CLI is
updated to the most current version by issuing:

在我们进入 CLI 容器并执行 invoke 之前，使用以下命令确定 CLI 更新到了当前版本：

.. code:: bash

  docker-compose -f docker-compose-cli.yaml stop cli

  docker-compose -f docker-compose-cli.yaml up -d --no-deps cli

If you specifically want the v1.3 version of the CLI, issue:

如果你想使用 v1.3 版本的 CLI ，执行：

.. code:: bash

  IMAGE_TAG=$(go env GOARCH)-1.3.x docker-compose -f docker-compose-cli.yaml up -d --no-deps cli

Once you have the version of the CLI you want, get into the CLI container:

当你得到想要的那个 CLI 版本之后，进入 CLI 容器：

.. code:: bash

  docker exec -it cli bash

Now you'll need to set two environment variables --- the name of the channel and
the name of the ``ORDERER_CA``:

现在你需要设置两个环境变量 --- 通道名和 ``ORDERER_CA`` 名：

.. code:: bash

  CH_NAME=mychannel

  ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

Now you can issue the invoke:

现在你可以执行 invoke ：

.. code:: bash

  peer chaincode invoke -o orderer.example.com:7050 --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --tls --cafile $ORDERER_CA  -C $CH_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'

Our query earlier revealed ``a`` to have a value of ``90`` and we have just removed
``10`` with our invoke. Therefore, a query against ``a`` should reveal ``80``.
Let’s see:

我们之前查询 ``a`` 的结果是 ``90`` ，而且我们在 invoke 的时候转移了 ``10`` ，所以 
``a`` 的查询结果应该是 ``80`` 。我们看一下：

.. code:: bash

  peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'

We should see the following:

你应该看到如下：

.. code:: bash

  Query Result: 80

After verifying the peer was upgraded correctly, make sure to issue an ``exit``
to leave the container before continuing to upgrade your peers. You can
do this by repeating the process above with a different peer name exported.

当成功验证节点的升级候，继续执行升级节点前，请确认执行了 ``exit`` 离开容器。
你可以通过导出不同的节点名字来重复执行上边的步骤。

.. code:: bash

  export PEER=peer1.org1.example.com
  export PEER=peer0.org2.example.com
  export PEER=peer1.org2.example.com

Upgrading components BYFN does not support - 升级 BYFN 不支持的组件
------------------------------------------

Although this is the end of our update tutorial, there are other components that
exist in production networks that are not compatible with the BYFN sample. In this
section, we’ll talk through the process of updating them.

在升级教程的最后，还有一些其他会在生产环境中的组件并没有包含在 BYFN 示例内。这一节
我们将看一下如何升级他们。

Fabric CA container - Fabric CA 容器
~~~~~~~~~~~~~~~~~~~

To learn how to upgrade your Fabric CA server, click over to the
`CA documentation <http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server>`_.

学习怎么升级你的 Fabric CA 服务，请查看 
`CA documentation <http://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#upgrading-the-server>`_ 。

Upgrade Node SDK clients - 升级 Node SDK 客户端
~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: Upgrade Fabric and Fabric CA before upgrading Node SDK clients.
          Fabric and Fabric CA are tested for backwards compatibility with
          older SDK clients. While newer SDK clients often work with older
          Fabric and Fabric CA releases, they may expose features that
          are not yet available in the older Fabric and Fabric CA releases,
          and are not tested for full compatibility.

.. note:: 在升级 Node SDK 客户端之前，需要升级 Fabric 和 Fabric CA 。Fabric 和
          Fabric CA 是经过测试兼容旧的 SDK 客户端的。然而新的 SDK 客户端经常和
          旧版本的 Fabric 和 Fabric CA 一起使用，它们可能有些特性不支持旧版本的
          Fabric 和 Fabric CA，而且他们没有经过兼容性测试。

Use NPM to upgrade any ``Node.js`` client by executing these commands in the
root directory of your application:

在你的应用的根目录下使用如下命令，利用 NPM 升级你的 ``Node.js`` 客户端：

..  code:: bash

  npm install fabric-client@latest

  npm install fabric-ca-client@latest

These commands install the new version of both the Fabric client and Fabric-CA
client and write the new versions ``package.json``.

这些命令安装了在新版本 ``package.json`` 中所编写的新版本的 Fabric 客户端和 Fabric-CA 客户端。

Upgrading the Kafka cluster - 升级 Kafka 集群
~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is not required, but it is recommended that the Kafka cluster be upgraded and
kept up to date along with the rest of Fabric. Newer versions of Kafka support
older protocol versions, so you may upgrade Kafka before or after the rest of
Fabric.

这并不是必须的，但是建议将 Kafka 集群升级并和其他 Fabric 保持一致。新版本的 Kafka 
支持旧版本的协议，所以你可以在升级完其他 Fabric 之前或之后再升级 Kafka。

If you followed the `Upgrading Your Network to v1.3 tutorial <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_,
your Kafka cluster should be at v1.0.0. If it isn't, refer to the official Apache
Kafka documentation on `upgrading Kafka from previous versions`__ to upgrade the
Kafka cluster brokers.

如果你学习了 `Upgrading Your Network to v1.3 tutorial <http://hyperledger-fabric.readthedocs.io/en/release-1.3/upgrading_your_network_tutorial.html>`_ ，
你的 Kafka 集群应该是 v1.0.0 。如果不是，参考官方 Apache Kafka 文档 `upgrading Kafka from previous versions`__ 
来升级 Kafka 集群的 brokers 。

.. __: https://kafka.apache.org/documentation/#upgrade

Upgrading Zookeeper - 升级 Zookeeper
^^^^^^^^^^^^^^^^^^^
An Apache Kafka cluster requires an Apache Zookeeper cluster. The Zookeeper API
has been stable for a long time and, as such, almost any version of Zookeeper is
tolerated by Kafka. Refer to the `Apache Kafka upgrade`_ documentation in case
there is a specific requirement to upgrade to a specific version of Zookeeper.
If you would like to upgrade your Zookeeper cluster, some information on
upgrading Zookeeper cluster can be found in the `Zookeeper FAQ`_.

一个 Apache Kafka 集群需要一个 Apache Zookeeper 集群。Zookeeper API 在很长一段时
间内都很稳定，并且 Kafka 几乎兼容所有版本的 Zookeeper 。参考 `Apache Kafka upgrade`__ 
文档中升级 Zookeeper 到指定版本的依赖。如果你想升级你的 Zookeeper 集群，可以在 
`Zookeeper FAQ`__ 上找到升级 Zookeeper 集群的一些信息。


.. _Apache Kafka upgrade: https://kafka.apache.org/documentation/#upgrade
.. _Zookeeper FAQ: https://cwiki.apache.org/confluence/display/ZOOKEEPER/FAQ

Upgrading CouchDB - 升级 CouchDB
~~~~~~~~~~~~~~~~~

If you are using CouchDB as state database, you should upgrade the peer's
CouchDB at the same time the peer is being upgraded. CouchDB v2.2.0 has
been tested with Fabric v1.4.

如果你使用 CouchDB 作为状态数据库，你需要在升级节点的同时升级节点的 CouchDB 。
CouchDB v2.2.0 在 Fabric v1.4 中已经被测试过了。


To upgrade CouchDB:

升级 CouchDB ：

1. Stop CouchDB.
2. Backup CouchDB data directory.
3. Install CouchDB v2.2.0 binaries or update deployment scripts to use a new Docker image
   (CouchDB v2.2.0 pre-configured Docker image is provided alongside Fabric v1.4).
4. Restart CouchDB.

1. 停止 CouchDB 。
2. 备份 CouchDB 数据目录。
3. 安装 CouchDB v2.2.0 二进制或者更新部署脚本来使用新的 Docker 镜像 （Fabric v1.4 中提供
   了预配置 CouchDB v2.2.0 的 Docker 镜像）。
4. 重启 CouchDB 。

Upgrade Node chaincode shim - 升级 Node 链码 shim
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To move to the new version of the Node chaincode shim a developer would need to:

为了更新到新版本的 Node 链码 shim ，开发者需要：

1. Change the level of ``fabric-shim`` in their chaincode ``package.json`` from
   1.3 to 1.4.
2. Repackage this new chaincode package and install it on all the endorsing peers
   in the channel.
3. Perform an upgrade to this new chaincode. To see how to do this, check out :doc:`commands/peerchaincode`.

1. 在链码的 ``package.json`` 中将 ``fabric-shim`` 级别从 1.3 改为 1.4 。
2. 重新打包新的链码包，并在通道中所有的背书节点安装。
3. 执行升级链码。如何升级链码，请参考 :doc:`commands/peerchaincode` 。

.. note:: This flow isn't specific to moving from 1.3 to 1.4. It is also how
          one would upgrade from any incremental version of the node fabric shim.

.. note:: 这个流程并不针对从 1.3 升级到 1.4 。它同样适用与将 node Fabric shim 升
          级到任何新增版本。

Upgrade Chaincodes with vendored shim - 使用 vendored shim 升级链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: The v1.3.0 shim is compatible with the v1.4 peer, but, it is still
          best practice to upgrade the chaincode shim to match the current level
          of the peer.

.. note:: v1.4 节点兼容 v1.3.0 shim ，但是，最好将链码 shim 升级到匹配当前级别的
          节点的版本。

A number of third party tools exist that will allow you to vendor a chaincode
shim. If you used one of these tools, use the same one to update your vendoring
and re-package your chaincode.

有很多第三方工具可以让你 vendor 链码的 shim 。如果你使用了这些工具，就在更新和重打包
链码的时候使用同一个工具。

If your chaincode vendors the shim, after updating the shim version, you must install
it to all peers which already have the chaincode. Install it with the same name, but
a newer version. Then you should execute a chaincode upgrade on each channel where
this chaincode has been deployed to move to the new version.

如果你的链码在升级 shim 之后引用了 shim，你必须在所有已经有了链码的节点上安装它。使用同
样的名字和新的版本安装。然后你要在每一个部署了这个链码的通道上执行链码升级，才可以升级到
新版本。

If you did not vendor your chaincode, you can skip this step entirely.

如果你没有 vendor 你的链码，你完全可以跳过这一步。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
