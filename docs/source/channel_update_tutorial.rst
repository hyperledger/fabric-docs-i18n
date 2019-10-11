向通道添加组织
==========================

.. note:: 确保你已经下载了 :doc:`install` 和 :doc:`prereqs` 中所罗列的和本文版
          本左边内容列表的底部可以查看）一致的镜像和二进制。特别注意，在你的版
          本中，``fabric-samples`` 文件夹必须包含 ``eyfn.sh`` （ “Extending 
          Your First Network” ）脚本以及和它相关的脚本。

本教程是 :doc:`build_network` （ BYFN ） 教程的扩展，将演示一个由 BYFN 自动生成的新
的组织 -- ``Org3`` -- 加入到应用通道 （ ``mychannel`` ） 的过程。本教程假设你对 BYFN 
有很好地理解，包括用法以及上面提及的工具的功能。

虽然我们在这里将只关注新组织的集成，但执行其他通道配置更新（如更新修改策略，调整块大小）
也可以采取相同的方式。要了解更多的通道配置更新的相关过程，请查看 :doc:`config_update` 。
值得注意的是，像本文演示的这些通道配置更新通常是组织管理者（而非链码或者应用开发者）的
职责。

.. note:: 在继续本文前先确保自动化脚本 ``byfn.sh`` 运行无误。如果你已经把你的二进
          制文件和相关工具(如 ``cryptogen``，``configtxgen`` 等）放在了 PATH 变量
          指定的路径下，你可以修改相应的命令而不使用全路径。

环境构建
~~~~~~~~~~~~~~~~~~~~~

你将从你克隆到本地的 ``fabric-samples`` 的子目录 ``first-network`` 进行操作。现在，
进入那个目录。你还要打开一些额外的终端窗口以便于使用。

首先，使用 ``byfn.sh`` 脚本清理环境。这个命令会清除运行、终止状态的容器，并且移除之前
生成的构件。关闭 Fabric 网络并非执行通道配置升级的 **必要** 步骤。但是为了本教程，我们
希望从一个已知的初始状态开始，因此让我们运行以下命令来清理之前的环境：

.. code:: bash

  ./byfn.sh down

现在生成默认的 BYFN 构件：

.. code:: bash

  ./byfn.sh generate

启动网络，并执行 CLI 容器内的脚本：

.. code:: bash

  ./byfn.sh up

现在你的机器上运行着一个干净的 BYFN 版本，你有两种不同的方式可选。第一种，我们提供
了一个有很好注释的脚本，来执行把 Org3 加入网络的配置交易更新。

我们也提供同样过程的“手动”版本，演示每一个步骤并解释它完成了什么（我们在之前演示了
如何停止你的网络，你可以先运行那个脚本，然后再来看每个步骤）。

使用脚本将 Org3 加入通道
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在 ``first-network`` 目录下，简单地执行以下命令来使用脚本：

.. code:: bash

  ./eyfn.sh up

此处的输出值得一读。你可以看到添加了 Org3 的加密材料，配置更新被创建和签名，然后安装
链码， Org3 就可以执行账本查询了。

如果一切顺利，你会看到以下信息：

.. code:: bash

  ========= All GOOD, EYFN test execution completed ===========

``eyfn.sh`` 可以像 ``byfn.sh`` 一样使用 Node.js 链码和数据库选项，如下所示
（替代 ``./byfn.sh up`` ）：

.. code:: bash

  ./byfn.sh up -c testchannel -s couchdb -l node

然后：

.. code:: bash

  ./eyfn.sh up -c testchannel -s couchdb -l node

对于想要详细了解该过程的人，文档的剩余部分会为你展示通道升级的每个命令，以及命令的
作用。

Bring Org3 into the Channel Manually
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: 下面的步骤均假设 ``CORE_LOGGING_LEVEL`` 变量在 ``cli`` 和 ``Org3cli`` 
          容器中设置为 ``DEBUG`` 。

          对于 ``cli`` 容器，你可以通过修改 ``first-network`` 目录下的
          ``docker-compose-cli.yaml`` 文件来配置。例如：

          .. code::

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

          对于 ``Org3cli`` 容器，你可以通过修改 ``first-network`` 目录下的 
          ``docker-compose-org3.yaml`` 文件来配置。例如：

          .. code::

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

如果你已经使用了 ``eyfn.sh`` 脚本，你需要先关闭你的网络。通过如下所示命令来完成：

.. code:: bash

  ./eyfn.sh down

这会关闭网络，删除所有的容器，并且撤销我们添加 Org3 的操作。

当网络停止后，再次将它启动起来。

.. code:: bash

  ./byfn.sh generate

然后：

.. code:: bash

  ./byfn.sh up

这会将你的网络恢复到你执行 ``eyfn.sh`` 脚本之前的状态。

现在我们可以手动添加 Org3 了。第一步，我们需要生成 Org3 的加密材料。

生成 Org3 加密材料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在另一个终端，切换到 ``first-network`` 的子目录 ``org3-artifacts`` 中。

.. code:: bash

  cd org3-artifacts

这里需要关注两个 ``yaml`` 文件： ``org3-crypto.yaml`` 和 ``configtx.yaml`` 。首先，
生成 Org3 的加密材料：

.. code:: bash

  ../../bin/cryptogen generate --config=./org3-crypto.yaml

该命令读取我们新的加密配置的 ``yaml`` 文件 -- ``org3-crypto.yaml`` -- 然后调用
``cryptogen`` 来为 Org3 CA 和其他两个绑定到这个新组织的节点生成秘钥和证书。就像 
BYFN 实现的，加密材料放到当前目录新生成的 ``crypto-config`` 文件夹下（在我们例子
中是 ``org3-artifacts`` ）。

现在使用 ``configtxgen`` 工具以 JSON 格式打印出 Org3 对应的配置材料。我们将在执
行命令时告诉这个工具去获取当前目录的 ``configtx.yaml`` 文件。

.. code:: bash

    export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json

上面的命令会创建一个 JSON 文件 -- ``org3.json`` -- 并把文件输出到 ``first-network`` 
的 ``channel-artifacts`` 子目录下。这个文件包含了 Org3 的策略定义，还有三个 base 64 
格式的重要的证书：管理员用户证书（之后作为 Org3 的管理员角色），一个根证书，一个 TLS 
根证书。之后的步骤我们会将这个 JSON 文件追加到通道配置。

我们最后的工作是拷贝排序节点的 MSP 材料到 Org3 的 ``crypto-config`` 目录下。我们
尤其关注排序节点的 TLS 根证书，它可以用于 Org3 的节点和网络的排序节点间的安全通信。

.. code:: bash

  cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/

Now we're ready to update the channel configuration...

现在我们准备开始升级通道配置。
~~~~~~~~~~~~~~~~~~~~~~~~~~~

更新的步骤需要用到配置转换工具 -- ``configtxlator`` 。这个工具提供了独立于 SDK 的
无状态 REST API。它还额外提供了 CLI，用于简化 Fabric 网络中的配置任务。这个工具对
不同的数据表示或格式间的转化提供了便利的功能（在这个例子中就是 protobufs 和 JSON 
格式的互转）。另外，这个工具能基于两个不同的通道配置计算出配置更新交易。

首先，进入到 CLI 容器。这个容器挂载了 BYFN 的 ``crypto-config`` 目录，允许我们访问之
前两个节点组作织和排序组织的 MSP 材料。默认的身份是 Org1 的管理员用户，所以如果我们
想作为 Org2 进行任何操作，需要设置和 MSP 相关的环境变量。


.. code:: bash

  docker exec -it cli bash

设置 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 变量：

.. code:: bash

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  && export CHANNEL_NAME=mychannel

检查并确保环境变量已正确设置：

.. code:: bash

  echo $ORDERER_CA && echo $CHANNEL_NAME

.. note:: 如果需要重启 CLI 容器，你需要重新设置 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 这两个
          环境变量。

获取配置
~~~~~~~~~~~~~~~~~~~~~~~

现在我们有了一个设置了 ``ORDERER_CA`` 和 ``CHANNEL_NAME`` 环境变量的 CLI 容器。让我们
获取通道 ``mychannel`` 的最新的配置区块。

我们必须拉取最新版本配置的原因是通道配置元素是版本化的。版本管理由于一些原因显得很重要。
它可以防止通道配置更新被重复或者重放攻击（例如，回退到带有旧的 CRLs 的通道配置将会产生
安全风险）。同时它保证了并行性（例如，如果你想从你的通道中添加新的组织后，再删除一个组
织 ，版本管理可以帮助你移除想移除的那个组织，并防止移除两个组织）。

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

这个命令将通道配置区块以二进制 protobuf 形式保存在 ``config_block.pb`` 。注意文件的
名字和扩展名可以任意指定。然而，为了便于识别，我们建议根据区块存储对象的类型和编码格
式（ protobuf 或 JSON ）进行命名。

当你执行 ``peer channel fetch`` 命令后，在终端上会有相当数量的打印输出。日志的最后一
行比较有意思：

.. code:: bash

  2017-11-07 17:17:57.383 UTC [channelCmd] readBlock -> DEBU 011 Received block: 2

这是告诉我们最新的 ``mychannel`` 的配置区块实际上是区块 2， **并非** 初始区块。 ``peer 
channel fetch config`` 命令默认返回目标通道最新的配置区块，在这个例子里是第三个区块。
这是因为 BYFN 脚本分别在两个不同通道更新交易中为两个组织 -- ``Org1`` 和 ``Org2`` -- 定
义了锚节点。

最终，我们有如下的配置块序列：

  * block 0: genesis block
  * block 1: Org1 anchor peer update
  * block 2: Org2 anchor peer update

将配置转换到 JSON 格式并裁剪
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在我们用 ``configtxlator`` 工具将这个通道配置解码为 JSON 格式（以便友好地被阅读
和修改）。我们也必须裁剪所有的头部、元数据、创建者签名等和我们将要做的修改无关的内
容。我们通过 ``jq`` 这个工具来完成裁剪：
.. code:: bash

  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

我们得到一个裁剪后的 JSON 对象 -- ``config.json`` ，放置在 ``fabric-samples`` 
下的 ``first-network`` 文件夹中 -- ``first-network`` 是我们配置更新的基准工作
目录。

花一些时间用你的文本编辑器（或者你的浏览器）打开这个文件。即使你已经完成了这个教程，
也值得研究下它，因为它揭示了底层配置结构，和能做的其它类型的通道更新升级。我们将在
:doc:`config_update` 更详细地讨论。

添加Org3加密材料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: 目前到这里你做的步骤和其他任何类型的配置升级所需步骤几乎是一致的。我们之
          所以选择在教程中添加一个组织，是因为这是能做的配置升级里最复杂的一个。

我们将再次使用 ``jq`` 工具去追加 Org3 的配置定义 -- ``org3.json`` -- 到通道的应用组
字段，同时定义输出文件是 -- ``modified_config.json`` 。

.. code:: bash

  jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json

现在，我们在 CLI 容器有两个重要的 JSON 文件 -- ``config.json`` 和 
``modified_config.json`` 。初始的文件包含 Org1 和 Org2 的材料，而 “modified” 文件包
含了总共 3 个组织。现在只需要将这 2 个 JSON 文件重新编码并计算出差异部分。

首先，将 ``config.json`` 文件倒回到 protobuf 格式，命名为 ``config.pb`` ：

.. code:: bash

  configtxlator proto_encode --input config.json --type common.Config --output config.pb

下一步，将 ``modified_config.json`` 编码成 ``modified_config.pb``:

.. code:: bash

  configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

现在使用 ``configtxlator`` 去计算两个protobuf 配置的差异。这条命令会输出一个新的
protobuf 二进制文件，命名为 ``org3_update.pb`` 。

.. code:: bash

  configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb

这个新的 proto 文件 -- ``org3_update.pb`` -- 包含了 Org3 的定义和指向 Org1 和 Org2 
材料的更高级别的指针。我们可以抛弃 Org1 和 Org2 相关的 MSP 材料和修改策略信息，因
为这些数据已经存在于通道的初始区块。因此，我们只需要两个配置的差异部分。

在我们提交通道更新前，我们执行最后做几个步骤。首先，我们将这个对象解码成可编辑的 
JSON 格式，并命名为 ``org3_update.json`` 。

.. code:: bash

  configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

现在，我们有了一个解码后的更新文件 -- ``org3_update.json`` -- 我们需要用信封消息来包装它。这
个步骤要把之前裁剪掉的头部信息还原回来。我们将命名这个新文件为 ``org3_update_in_envelope.json`` 。

 code:: bash

  echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

使用我们格式化好的 JSON -- ``org3_update_in_envelope.json`` -- 我们最后一次使用
``configtxlator`` 工具将他转换为 Fabric 需要的完整独立的 protobuf 格式。我们将最
后的更新对象命名为 ``org3_update_in_envelope.pb`` 。

.. code:: bash

  configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

签名并提交配置更新
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

差不多大功告成了！

我们现在有一个 protobuf 二进制文件 -- ``org3_update_in_envelope.pb`` -- 在我们的 CLI 容
器内。但是，在配置写入到账本前，我们需要来自必要的 Admin 用户的签名。我们通道应用组的修
改策略（mod_policy）设置为默认值 “MAJORITY”，这意味着我们需要大多数已经存在的组织管理员
去签名这个更新。因为我们只有两个组织 -- Org1 和 Org2 -- 所以两个的大多数也还是两个，我们
需要它们都签名。没有这两个签名，排序服务会因为不满足策略而拒绝这个交易。

首先，让我们以 Org1 管理员来签名这个更新 proto 。因为 CLI 容器是以 Org1 MSP 材料启动的，
所以我们只需要简单地执行 ``peer channel signconfigtx`` 命令：

.. code:: bash

  peer channel signconfigtx -f org3_update_in_envelope.pb

最后一步，我们将 CLI 容器的身份切换为 Org2 管理员。为此，我们通过导出和 Org2 MSP 相
关的 4 个环境变量。

.. note:: 切换不同的组织身份为配置交易签名（或者其他事情）不能反映真实世界里 Fabric 的操作。
          一个单一容器不可能挂载了整个网络的加密材料。相反地，配置更新需要在网络外安全地递交
          给 Org2 管理员来审查和批准。

导出 Org2 的环境变量：

.. code:: bash

  # you can issue all of these commands at once

  export CORE_PEER_LOCALMSPID="Org2MSP"

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

  export CORE_PEER_ADDRESS=peer0.org2.example.com:9051

最后，我们执行 ``peer channel update`` 命令。Org2 管理员在这个命令中会附带签名，因
此就没有必要对 protobuf 进行两次签名。

.. note:: 将要做的对排序服务的更新调用，会经历一系列的系统级签名和策略检查。你会发现
          通过检视排序节点的日志流会非常有用。在另外一个终端执行 
          ``docker logs -f orderer.example.com`` 命令就能展示它们了。

发起更新调用：

.. code:: bash

  peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

如果你的更新提交成功，将会看到一个类似如下的摘要提示信息：

.. code:: bash

  2018-02-24 18:56:33.499 UTC [msp/identity] Sign -> DEBU 00f Sign: digest: 3207B24E40DE2FAB87A2E42BC004FEAA1E6FDCA42977CB78C64F05A88E556ABA

你也会看到配置交易的提交：
.. code:: bash

  2018-02-24 18:56:33.499 UTC [channelCmd] update -> INFO 010 Successfully submitted channel update

成功的通道更新调用会返回一个新的区块 --  区块 5 -- 给所有在这个通道上的节点。你是否
还记得，区块 0-2 是初始的通道配置，而区块 3 和 4 是链码 ``mycc`` 的实例化和调用。所
以，区块 5 就是带有 Org3 定义的最新的通道配置。

查看 ``peer0.org1.example.com`` 的日志：

.. code:: bash

      docker logs -f peer0.org1.example.com

如果你想查看新的配置区块的内容，可以跟着示范的过程获取和解码配置区块

配置领导节点选举
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note:: 引入这个章节作为通用参考，是为了理解在完成网络通道配置初始化之后，增加
          组织时，领导节点选举的设置。这个例子中，默认设置为动态领导选举，这是在 
          ``peer-base.yaml`` 文件中为网络中所有的节点设置的。

新加入的节点是根据初始区块启动的，初始区块是不包含通道配置更新中新加入的组织信息
的。因此新的节点无法利用 gossip 协议，因为它们无法验证从自己组织里其他节点发送过
来的区块，除非它们接收到将组织加入到通道的那个配置交易。新加入的节点必须有以下配
置之一才能从排序服务接收区块：

1. 采用静态领导者模式，将节点配置为组织的领导者。

::

    CORE_PEER_GOSSIP_USELEADERELECTION=false
    CORE_PEER_GOSSIP_ORGLEADER=true


.. note:: 这个配置对于新加入到通道中的所有节点必须一致。

2. 采用动态领导者选举，配置节点采用领导选举的方式：

::

    CORE_PEER_GOSSIP_USELEADERELECTION=true
    CORE_PEER_GOSSIP_ORGLEADER=false


.. note:: 因为新加入组织的节点，无法生成成员关系视图，这个选项和静态配置类似，每
          个节点启动时宣称自己是领导者。但是，一旦它们更新到了将组织加入到通道的
          配置交易，组织中将只会有一个激活状态的领导者。因此，如果你想最终组织的
          节点采用领导选举，建议你采用这个配置。

将 Org3 加入通道
~~~~~~~~~~~~~~~~~~~~~~~~

此时，通道的配置已经更新并包含了我们新的组织 -- ``Org3`` -- 意味者这个组织下的节点可以加入
到 ``mychannel`` 。

首先，让我们部署 Org3 节点容器和 Org3-specific CLI容器。

打开一个新的终端并从 ``first-network`` 目录启动 Org3 docker compose ：

.. code:: bash

  docker-compose -f docker-compose-org3.yaml up -d

这个新的 compose 文件配置为桥接我们的初始网络，因此两个节点容器和 CLI 容器可以连
接到已经存在的节点和排序节点。当三个容器运行后，进入 Org3-specific CLI 容器：

.. code:: bash

  docker exec -it Org3cli bash

和我们之前初始化 CLI 容器一样，导出两个关键环境变量： ``ORDERER_CA`` 和 
``CHANNEL_NAME`` ：

.. code:: bash

  export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

检查确保环境变量已经正确设置：

.. code:: bash

  echo $ORDERER_CA && echo $CHANNEL_NAME

现在，我们向排序服务发送一个获取 ``mychannel`` 初始区块的请求。如果通道更新成
功执行，排序服务会成功校验这个请求中 Org3 的签名。如果 Org3 没有成功地添加到通
道配置中，排序服务会拒绝这个请求。

.. note:: 再次提醒，你会发现查看排序节点的签名和验签逻辑和策略检查的日志是
          很有用的

使用 ``peer channel fetch`` 命令来获取这个区块：

.. code:: bash

  peer channel fetch 0 mychannel.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

注意，我们传递了 ``0`` 去索引我们在这个通道账本上想要的区块（例如，初始区块）。如
果我们简单地执行 ``peer channel fetch config`` 命令，我们将会收到区块 5 -- 那个带
有 Org3 定义的更新后的配置。然而，我们的账本不能从一个下游的区块开始 -- 我们必须
从区块 0 开始。

执行 ``peer channel join`` 命令并指定初始区块 -- ``mychannel.block`` ：

.. code:: bash

  peer channel join -b mychannel.block

如果你想将第二个节点加入到 Org3 中，导出 ``TLS`` 和 ``ADDRESS`` 变量，再重新执
行 ``peer channel join command`` 。

.. code:: bash

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt && export CORE_PEER_ADDRESS=peer1.org3.example.com:12051

  peer channel join -b mychannel.block

.. _upgrade-and-invoke:

升级和调用链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

这个智力游戏的最后一部分是升级链码的版本，并升级背书策略以加入 Org3 。因为我们知
道马上要做的是升级，将无关紧要的安装版本 1 的链码的过程抛诸脑后吧。我们只关心新版
本，在新版本中 Org3 会成为背书策略的一部分，因此我们直接跳到链码的版本 2 。

从 Org3 CLI 执行：

.. code:: bash

  peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

如果你要在 Org3 的第二个节点上安装链码，请相应地修改环境变量并再次执行命令。注意第
二次安装并不是强制的，因为你只需要在背书节点或者和账本有交互行为(比如，只做查询)节
点上安装链码。即使没有运行链码容器，节点作为提交节点仍然会运行检验逻辑。

现在回到 **原始** CLI 容器，在 Org1 和 Org2 节点上安装新版本链码。我们使用 Org2 管理
员身份提交通道更新请求，所以容器仍然是代表 “peer0.Org2” ：

.. code:: bash

  peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

切回 ``peer0.org1`` 身份：

.. code:: bash

  export CORE_PEER_LOCALMSPID="Org1MSP"

  export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

  export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

然后再次安装：

.. code:: bash

  peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

现在我们已经准备好升级链码。底层的源代码没有任何变化，我们只是简单地在 ``mychannel`` 
通道上的链码 -- ``mycc`` -- 的背书策略中增加了 Org3 。

.. note:: 任何满足链码实例化策略的身份都可以执行升级调用。这些身份默认就是通道的管理者。

发送调用：

.. code:: bash

  peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

你可以看到上面的命令，我们用 ``v`` 标志指定了新的版本号。你也能看到背书策略修改为 
``-P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"`` ，说明 Org3 要被添加到
策略中。最后一部分注意的是我们的构造请求(用 ``c`` 标志指定)。

链码升级和实例化一样需要用到 ``init`` 方法。 **如果** 你的链码需要传递参数给 ``init`` 
方法，那你需要在这里添加。

升级调用使得通道的账本添加一个新的区块 -- 区块 6 -- 来允许 Org3 的节点在背书阶段执行
交易。回到 Org3 CLI 容器，并执行对 ``a`` 的查询。这需要花费一点时间，因为需要为目标节
点构建链码镜像，链码容器需要运行：

.. code:: bash

    peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

我们能看到 ``Query Result：90`` 的响应。

现在执行调用，从 ``a`` 转移 ``10`` 到 ``b`` ：

.. code:: bash

    peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'

最后查询一次：

.. code:: bash

    peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

我们能看到一个 ``Query Result: 80`` 的响应，准确反映了链码的世界状态的更新。

总结
~~~~~~~~~~

通道配置的更新过程是非常复杂的，但是仍然有一个诸多步骤对应的逻辑方法。终局就是为了构建
一个用 protobuf 二进制表达的差异化的交易对象，然后获取必要数量的管理员签名来满足通道的
修改策略。

``configtxlator`` 和 ``jq`` 工具，和不断使用的 ``peer channel`` 命令，为我们提供了完成
这个任务的基本功能。

Updating the Channel Config to include an Org3 Anchor Peer (Optional)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Org3 peers were able to establish gossip connection to the Org1 and Org2
peers since Org1 and Org2 had anchor peers defined in the channel configuration.
Likewise newly added organizations like Org3 should also define their anchor peers
in the channel configuration so that any new peers from other organizations can
directly discover an Org3 peer.

Continuing from the Org3 CLI, we will make a channel configuration update to
define an Org3 anchor peer. The process will be similar to the previous
configuration update, therefore we'll go faster this time.

As before, we will fetch the latest channel configuration to get started.
Inside the CLI container for Org3 fetch the most recent config block for the channel,
using the ``peer channel fetch`` command.

.. code:: bash

  peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

After fetching the config block we will want to convert it into JSON format. To do
this we will use the configtxlator tool, as done previously when adding Org3 to the
channel. When converting it we need to remove all the headers, metadata, and signatures
that are not required to update Org3 to include an anchor peer by using the jq
tool. This information will be reincorporated later before we proceed to update the
channel configuration.

.. code:: bash

    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

The ``config.json`` is the now trimmed JSON representing the latest channel configuration
that we will update.

Using the jq tool again, we will update the configuration JSON with the Org3 anchor peer we
want to add.

.. code:: bash

    jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 11051}]},"version": "0"}}' config.json > modified_anchor_config.json

We now have two JSON files, one for the current channel configuration,
``config.json``, and one for the desired channel configuration ``modified_anchor_config.json``.
Next we convert each of these back into protobuf format and calculate the delta between the two.

Translate ``config.json`` back into protobuf format as ``config.pb``

.. code:: bash

    configtxlator proto_encode --input config.json --type common.Config --output config.pb

Translate the ``modified_anchor_config.json`` into protobuf format as ``modified_anchor_config.pb``

.. code:: bash

    configtxlator proto_encode --input modified_anchor_config.json --type common.Config --output modified_anchor_config.pb

Calculate the delta between the two protobuf formatted configurations.

.. code:: bash

    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_anchor_config.pb --output anchor_update.pb

Now that we have the desired update to the channel we must wrap it in an envelope
message so that it can be properly read. To do this we must first convert the protobuf
back into a JSON that can be wrapped.

We will use the configtxlator command again to convert ``anchor_update.pb`` into ``anchor_update.json``

.. code:: bash

    configtxlator proto_decode --input anchor_update.pb --type common.ConfigUpdate | jq . > anchor_update.json

Next we will wrap the update in an envelope message, restoring the previously
stripped away header, outputting it to ``anchor_update_in_envelope.json``

.. code:: bash

    echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat anchor_update.json)'}}}' | jq . > anchor_update_in_envelope.json

Now that we have reincorporated the envelope we need to convert it
to a protobuf so it can be properly signed and submitted to the orderer for the update.

.. code:: bash

    configtxlator proto_encode --input anchor_update_in_envelope.json --type common.Envelope --output anchor_update_in_envelope.pb

Now that the update has been properly formatted it is time to sign off and submit it. Since this
is only an update to Org3 we only need to have Org3 sign off on the update. As we are
in the Org3 CLI container there is no need to switch the CLI containers identity, as it is
already using the Org3 identity. Therefore we can just use the ``peer channel update`` command
as it will also sign off on the update as the Org3 admin before submitting it to the orderer.

.. code:: bash

    peer channel update -f anchor_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

The orderer receives the config update request and cuts a block with the updated configuration.
As peers receive the block, they will process the configuration updates.

Inspect the logs for one of the peers. While processing the configuration transaction from the new block,
you will see gossip re-establish connections using the new anchor peer for Org3. This is proof
that the configuration update has been successfully applied!

.. code:: bash

    docker logs -f peer0.org1.example.com

.. code:: bash

    2019-06-12 17:08:57.924 UTC [gossip.gossip] learnAnchorPeers -> INFO 89a Learning about the configured anchor peers of Org1MSP for channel mychannel : [{peer0.org1.example.com 7051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89b Learning about the configured anchor peers of Org2MSP for channel mychannel : [{peer0.org2.example.com 9051}]
    2019-06-12 17:08:57.926 UTC [gossip.gossip] learnAnchorPeers -> INFO 89c Learning about the configured anchor peers of Org3MSP for channel mychannel : [{peer0.org3.example.com 11051}]

Congratulations, you have now made two configuration updates --- one to add Org3 to the channel,
and a second to define an anchor peer for Org3.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
