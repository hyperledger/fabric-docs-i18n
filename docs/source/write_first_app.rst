编写你的第一个应用
==============================

.. note:: 如果你对 Fabric 网络的基本架构还不熟悉，在继续本部分之前，你可能想先
          阅读 :doc:`key_concepts` 部分。
            
          本教程的价值仅限于介绍 Fabric 应用和使用简单的智能合约和应用。更深入
          的了解 Fabric 应用和智能合约请查看 :doc:`developapps/developing_applications` 
          或 :doc:`tutorial/commercial_paper` 部分。

本教程我们将通过手动开发一个简单的示例程序来演示 Fabric 应用是如何工作的。
使用的这些应用和智能合约统称为 ``FabCar`` 。他们提供了理解 Hyperledger Fabric 
区块链的一个很好的起点。我们将学习怎么写一个应用程序和智能合约来查询和更新账本，
还有如何使用证书授权服务来生成一个 X.509 证书，应用程序将使用这个证书和授权区块链
进行交互。

我们将使用应用程序 SDK —— 详细介绍在 :doc:`/developapps/application` —— 使用智能
合约 SDK 来执行智能合约的查询和更新账本 —— 详细介绍在 —— :doc:`/developapps/smartcontract` 。

我们将按照以下三个步骤进行：

  **1. 搭建开发环境。** 我们的应用程序需要和网络交互，所以我们需要一个智能合约和
  应用程序使用的基础网络。

  .. image:: images/AppConceptsOverview.png

  **2. 学习一个简单的智能合约， FabCar。** 我们使用一个 **JavaScript** 写的智能合约。
  我们将查看智能合约来学习他们的交易，还有应用程序是怎么使用他们来进行查询和更新账本的。

  **3. 使用 FabCar 开发一个简单的应用程序。** 我们的应用程序将使用 FabCar 智能合约来查询和
  更新账本上的汽车资产。我们将进入到应用程序的代码和他们创建的交易，包括查询一辆汽车，
  查询一批汽车和创建一辆新车。

在完成这个教程之后，你将基本理解一个应用是如何通过编程关联智能合约来和 Fabric 
网络上的多个节点的账本的进行交互的。

.. note:: 这些应用程序也兼容 :doc:`discovery-overview` 和 :doc:`private-data/private-data` ，
          但是我们不会明确地展示如何使用这些功能。

设置区块链网络
-----------------------------

.. note:: 下边的部分需要进入你克隆到本地的 ``fabric-samples`` 仓库的
          ``first-network`` 子目录。

如果你已经学习了 :doc:`build_network` ，你应该已经下载 ``fabric-samples`` 
而且已经运行起来了一个网络。在你进行本教程之前，你必须停止这个网络：

.. code:: bash

  ./byfn.sh down

如果你之前运行过这个教程，使用下边的命令关掉所有停止或者在运行的容器。注意，
这将关掉你 **所有** 的容器，无论是否和 Fabric 有关。

.. code:: bash

  docker rm -f $(docker ps -aq)
  docker rmi -f $(docker images | grep fabcar | awk '{print $3}')

如果你没有网络和应用的开发环境和相关构件，访问 :doc:`prereqs` 页面，确保你已经
在你的机器上安装了必要的依赖。

然后，如果已经完成了这些，访问 :doc:`install` 页面，跟着上边的说明操作。当你克隆
了 ``fabric-samples`` 仓库后返回本教程，然后下载最新的稳定版 Fabric 镜像和相关
工具。

如果你使用的是 Mac OS 和 Mojava，你需要 `install Xcode<./tutorial/installxcode.html>`_.

启动网络
^^^^^^^^^^^^^^^^^^

.. note:: 下边的章节需要进入你克隆到本地的 ``fabric-samples`` 仓库的 ``fabcar`` 
          子目录。

使用 ``startFabric.sh`` 启动你的网络。这个命令将启动一个区块链网络，这个网络由 
peer 节点、排序节点和证书授权服务等组成。同时也将安装和初始化 javascript 版的
``FabCar`` 智能合约，我们的应用程序将通过它来控制账本。我们将通过本教程学习更多
关于这些组件的内容。

.. code:: bash

  ./startFabric.sh javascript

好了，现在我们运行起来了一个示例网络，还有安装和初始化了 ``FabCar`` 智能合约。
为了使用我们的应用程序，我们现在需要安装一些依赖，同时我们也看一下这些程序是如
何一起工作的。

安装应用程序
^^^^^^^^^^^^^^^^^^^^^^^

.. note:: 下边的章节需要进入你克隆到本地的 ``fabric-samples`` 仓库的 
          ``fabcar/javascript`` 子目录。

运行下边的命令来安装应用程序所需要的 Fabric 依赖。将要花费大约 1 分钟：


.. code:: bash

  npm install

这个指令将安装应用程序的主要依赖，这些依赖定义在 ``package.json`` 中。其中最重要
的是 ``fabric-network`` 类；它使得应用程序可以使用身份、钱包和连接到通道的网关，
以及提交交易和等待通知。本教程也将使用 ``fabric-ca-client`` 类来注册用户以及他们
的授权证书，生成一个 ``fabric-network`` 在后边会用到的合法身份。

一旦 ``npm install`` 完成了，运行应用程序所需要的一切就准备好了。在这个教程中，
你将主要使用 ``fabcar/javascript`` 目录下的 JavaScript 文件来操作应用程序。
让我们来看一眼它里边有什么吧：

.. code:: bash

  ls

你会看到下边的文件：

.. code:: bash

  enrollAdmin.js  node_modules       package.json  registerUser.js
  invoke.js       package-lock.json  query.js      wallet

里边也有一些其他编程语言的文件，比如在 ``fabcar/typescript`` 目录中。当你使用
过 JavaScript 示例之后，你可以看一下它们，主要的内容都是一样的。

如果你在使用 Mac OS 而且运行的是 Mojava ，你将
需要 `install Xcode <./tutorial/installxcode.html>`_.

登记管理员用户
------------------------

.. note:: 下边的部分执行和证书授权服务器通讯。你在运行下边的程序时，你会发现，
          打开一个新终端，并运行 ``docker logs -f ca.example.com`` 来查看 CA 
          的日志流，会很有帮助。

当我们创建网络的时候，一个管理员用户 --- 叫 ``admin`` --- 被证书授权服务器（CA）
创建成了 **登记员** 。我们第一步要使用 ``enroll.js`` 程序为 ``admin`` 生成私钥、
公钥和 x.509 证书。这个程序使用一个 **证书签名请求** (CSR) --- 现在本地生成公钥
和私钥，然后把公钥发送到 CA ，CA 会发布会一个让应用程序使用的证书。这三个证书会
保存在钱包中，以便于我们以管理员的身份使用 CA 。

我们接下来会注册和登记一个新的应用程序用户，我们将使用这个用户来通过应用程序和
区块链交互。

我们登记一个 ``admin`` 用户：

.. code:: bash

  node enrollAdmin.js

这个命令将 CA 管理员的证书保存在 ``wallet`` 目录。

注册和登记 ``user1``
-----------------------------

注意我们在钱包里存放了管理员的证书，我们可以登记一个新用户 --- ``user1`` ---
他将被用来查询和更新账本：

.. code:: bash

  node registerUser.js

和管理员的登记类似，这个程序使用一个 CSR 来登记 ``user1`` 并把他的证书保存到 ``admin`` 
所在的钱包里。我们现在有了两个独立的用户 --- ``admin`` 和 ``user1`` --- 他们将用于
我们的应用程序。

账本交互时间。。。

查询账本
-------------------

区块链网络中的每个节点都拥有一个账本的副本，应用程序可以通过执行智能合约查询账本
上最新的数据来实现来查询账本，并将查询结果返回给应用程序。

这里是一个查询工作如何进行的简单说明：

.. image:: tutorial/write_first_app.diagram.1.png

应用程序使用查询从 `ledger <./ledger/ledger.html>`_ 读取数据。最常用的查询是查
寻账本中询当前的值 -- 也就是 `world state <./ledger/ledger.html#world-state>`_ 。
世界状态是一个键值对的集合，应用程序可以根据一个键或者多个键来查询数据。而且，
当键值对是以 JSON 值模式组织的时候，世界状态可以通过配置使用数据库（如 CouchDB ） 
来支持富查询。这对于查询所有资产来匹配特定的键的值是很有用的，比如查询一个人的所
有汽车。

首先，我们来运行我们的 ``query.js`` 程序来返回账本上所有汽车的侦听。这个程序使用
我们的第二个身份 -- ``user1`` -- 来操作账本。

.. code:: bash

  node query.js

输入结果应该类似下边：

.. code:: json

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  [{"Key":"CAR0", "Record":{"colour":"blue","make":"Toyota","model":"Prius","owner":"Tomoko"}},
  {"Key":"CAR1", "Record":{"colour":"red","make":"Ford","model":"Mustang","owner":"Brad"}},
  {"Key":"CAR2", "Record":{"colour":"green","make":"Hyundai","model":"Tucson","owner":"Jin Soo"}},
  {"Key":"CAR3", "Record":{"colour":"yellow","make":"Volkswagen","model":"Passat","owner":"Max"}},
  {"Key":"CAR4", "Record":{"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}},
  {"Key":"CAR5", "Record":{"colour":"purple","make":"Peugeot","model":"205","owner":"Michel"}},
  {"Key":"CAR6", "Record":{"colour":"white","make":"Chery","model":"S22L","owner":"Aarav"}},
  {"Key":"CAR7", "Record":{"colour":"violet","make":"Fiat","model":"Punto","owner":"Pari"}},
  {"Key":"CAR8", "Record":{"colour":"indigo","make":"Tata","model":"Nano","owner":"Valeria"}},
  {"Key":"CAR9", "Record":{"colour":"brown","make":"Holden","model":"Barina","owner":"Shotaro"}}]

让我们更进一步看一下这个程序。使用一个编辑器（比如， atom 或 visual studio）
打开 ``query.js`` 。

应用程序开始的时候就从 ``fabric-network`` 模块引入了两个关键的类
``FileSystemWallet`` 和 ``Gateway`` 。这两个类将用于定位钱包中 ``user1`` 
的身份，这个身份将用于连接网络。

.. code:: bash

  const { FileSystemWallet, Gateway } = require('fabric-network');

应用程序通过网关连接网络：

.. code:: bash

  const gateway = new Gateway();
  await gateway.connect(ccp, { wallet, identity: 'user1' });

这段代码创建了一个新网关，然后通过它让应用程序连接到网络。 ``cpp`` 描述了网关将
通过 ``wallet`` 中的 ``user1`` 来使用网络。打开 ``../../basic-network/connection.json`` 
来查看 ``cpp`` 是如何解析一个 JSON 文件的：

.. code:: bash

  const ccpPath = path.resolve(__dirname, '..', '..', 'basic-network', 'connection.json');
  const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
  const ccp = JSON.parse(ccpJSON);

如果你想了解更多关于连接配置文件的结构，和它是怎么定义网络的，请查阅
`the connection profile topic <./developapps/connectionprofile.html>`_ 。

一个网络可以被差分成很多通道，代码中下一个很重的一行是将应用程序连接到网络
中特定的通道 ``mychannel`` 上：

.. code:: bash
  const network = await gateway.getNetwork('mychannel');

  const network = await gateway.getNetwork('mychannel');

在这个通道中，我们可以通过 ``fabcar`` 智能合约来和账本进行交互：

.. code:: bash

  const contract = network.getContract('fabcar');

在 ``fabcar`` 中有许多不同的 **交易** ，我们的应用程序先使用 ``queryAllCars`` 交
易来查询账本世界状态的值：

.. code:: bash

  const result = await contract.evaluateTransaction('queryAllCars');

``evaluateTransaction`` 方法代表了一种区块链网络中和智能合约最简单的交互。它只是
的根据配置文件中的定义连接一个节点，然后向节点发送请求，请求内容将在节点中执行。
智能合约查询节点账本上的所有汽车，然后把结果返回给应用程序。这次交互没有导致账本
的更新。

FabCar 智能合约
-------------------------

让我们看一看 ``FabCar`` 智能合约里的交易。进入 ``fabric-samples`` 下的子目录
``chaincode/fabcar/javascript/lib`` ，然后用你的编辑器打开 ``fabcar.js`` 。

看一下我们的智能合约是如何通过 ``Contract`` 类来定义的：

.. code:: bash

  class FabCar extends Contract {...

在这个类结构中，你将看到定义了以下交易： ``initLedger``, ``queryCar``, 
``queryAllCars``, ``createCar``, and ``changeCarOwner`` 。例如：


.. code:: bash

  async queryCar(ctx, carNumber) {...}
  async queryAllCars(ctx) {...}

让我们更进一步看一下 ``queryAllCars`` ，看一下它是怎么和账本交互的。

.. code:: bash

  async queryAllCars(ctx) {

    const startKey = 'CAR0';
    const endKey = 'CAR999';

    const iterator = await ctx.stub.getStateByRange(startKey, endKey);


这段代码定义了 ``queryAllCars`` 将要从账本获取的汽车的范围。从 ``CAR0`` 到 ``CAR999`` 
的每一辆车 -- 一共 1000 辆车，假定每个键都被合适地锚定了 -- 将会作为查询结果被返回。
代码中剩下的部分，通过迭代将查询结果打包成 JSON 并返回给应用。

下边将展示应用程序如何调用智能合约中的不同交易。每一个交易都使用一组 API 比如
``getStateByRange`` 来和账本进行交互。了解更多 API 请阅读 `detail
<https://fabric-shim.github.io/master/index.html?redirect=true>`_.

.. image:: images/RunningtheSample.png

你可以看到我们的 ``queryAllCars`` 交易，还有另一个叫做 ``createCar`` 。我们稍后将
在教程中使用他们来更细账本，和添加新的区块。

但是在那之前，返回到 ``query`` 程序，更改 ``evaluateTransaction`` 的请求来查询
``CAR4`` 。 ``query`` 程序现在看起来应该是这个样子：

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

保存程序，然后返回到 ``fabcar/javascript`` 目录。现在，再次运行 ``query`` 程序：

.. code:: bash

  node query.js

你应该会看到如下：

.. code:: json

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}

如果你回头去看一下 ``queryAllCars`` 的交易结果，你会看到 ``CAR4`` 是 Adriana 的
黑色 Tesla model S，也就是这里返回的结果。

我们可以使用 ``queryCar`` 交易来查询任意汽车，使用它的键 （比如 ``CAR0`` ）得到车
辆的制造商、型号、颜色和车主等相关信息。

很棒。现在你应该已经了解了智能合约中基础的查询交易，也手动修改了查询程序中的参数。

账本更新时间。。。

更新账本
-------------------

现在我们已经完成一些账本的查询和添加了一些代码，我们已经准备好更新账本了。有很多
的更新操作我们可以做，但是我们从创建一个 **新** 车开始。

从一个应用程序的角度来说，更新一个账本很简单。应用程序向区块链网络提交一个交易，
当交易被验证和提交后，应用程序会收到一个交易成功的提醒。但是在底层，区块链网络中
各组件中不同的 **共识** 程序协同工作，来保证账本的每一个更新提案都是合法的，而且
有一个大家一致认可的顺序。
.. image:: tutorial/write_first_app.diagram.2.png

上图中，我们可以看到完成这项工作的主要组件。同时，多个节点中每一个节点都拥有一
份账本的副本，并可选的拥有一份智能合约的副本，网络中也有一个排序服务。排序服务
保证网络中交易的一致性；它也将连接到网络中不同的应用程序的交易以定义好的顺序生
成区块。

我们对账本的的第一个更新是创建一辆新车。我们有一个单独的程序叫做 ``invoke.js`` ，
用来更新账本。和查询一样，使用一个编辑器打开程序定位到我们构建和提交交易到网络的
代码段：

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

看一下应用程序如何调用智能合约的交易 ``createCar`` 来创建一量车主为 Tom 的黑
色 Honda Accord 汽车。我们使用 ``CAR12`` 作为这里的键，这也说明了我们不必使用
连续的键。

保存并运行程序：

.. code:: bash

  node invoke.js

如果执行成功，你将看到类似输出：

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  2018-12-11T14:11:40.935Z - info: [TransactionEventHandler]: _strategySuccess: strategy success for transaction "9076cd4279a71ecf99665aed0ed3590a25bba040fa6b4dd6d010f42bb26ff5d1"
  Transaction has been submitted

注意 ``inovke`` 程序是怎样使用 ``submitTransaction`` API 和区块链网络交互的，
而不是 ``evaluateTransaction`` 。


.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

``submitTransaction`` 比 ``evaluateTransaction`` 要复杂的多。不只是和单个节点
交互，SDK 将把 ``submitTransaction`` 提案发送到区块链网络中每一个必要的组织的
节点。每一个节点都将根据这个提案执行请求的智能合约，并生成一个该节点签名的交易
响应并返回给 SDK 。SDK 将所有经过签名的交易响应收集到一个交易中，这个交易将会
被发送到排序节点。排序节点搜集并排序每个应用的交易，并把这些交易放入到一个交易
区块。然后排序节点将这些区块分发到网络中的节点，每一笔交易都会在节点中进行验证
和提交。最后，SDK 会收到提醒，并把控制权返回给应用程序。

.. note:: ``submitTransaction`` 也包含一个监听者来检查交易是否已经通过验证并提交到账本。应用程序可以利用提交监听或者像 ``submitTransaction`` 这样的 API 来实现这个功能。如果没有这个功能，你的交易可能会没有被成功排序、验证或者提交到账本，而你却无法获知。

应用程序中的这些工作由 ``submitTransaction`` 完成！应用程序、智能合约、节点和
排序服务一起工作来保证网络中账本一致性的程序被称为共识，它的详细解释在这里
`section <./peers/peers.html>`_ 。

为了查看这个被写入账本的交易，返回到 ``query.js`` 并将参数 ``CAR4`` 更改为 ``CAR12`` 。

就是说，将：

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

改为：

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR12');

再次保存，然后查询：

.. code:: bash

  node query.js

应该返回这些：

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"Black","make":"Honda","model":"Accord","owner":"Tom"}

恭喜。你创建了一辆汽车并验证了它记录在账本上！

现在我们已经完成了，我们假设 Tom 很大方，想把他的 Honda Accord 送给一个
叫 Dave 的人。

为了完成这个，返回到 ``invoke.js`` 然后利用输入的参数，将智能合约的交易从
``createCar`` 改为 ``changeCarOwner`` ：

.. code:: bash

  await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');

第一个参数 --- ``CAR12`` --- 表示将要易主的车。第二个参数 --- ``Dave`` --- 表示 
车的新主人。

再次保存并执行程序：

.. code:: bash

  node invoke.js

现在我们来再次查询账本，以确定 Dave 和 ``CAR12`` 键已经关联起来了：

.. code:: bash

  node query.js

将返回如下结果：

.. code:: bash

   Wallet path: ...fabric-samples/fabcar/javascript/wallet
   Transaction has been evaluated, result is:
   {"colour":"Black","make":"Honda","model":"Accord","owner":"Dave"}

``CAR12`` 的主人已经从 Tom 变成了 Dave。

.. note:: 在真实实现的应用中，智能合约应该有一些权限控制。例如只有特定权限的用户才可以创建新车，只有车辆的拥有者才可以将车辆转移给他人。

总结
-------

现在我们完成了一些查询和跟新，你应该已经比较了解如何通过智能合约和区块链网络进
行交互来查询和更新账本。我们已经看过了查询和更新的基本角智能合约、API 和 SDK ，
你也应该对如何在其他的商业场景和操作中使用不同应用有了一些认识。

其他资源
--------------------

就像我们在介绍中说的，我们有一整套文章在 :doc:`developapps/developing_applications` 
包含了关于智能合约、程序和数据设计的更多信息，一个更深入的使用商业票据的教程
`tutorial <./tutorial/commercial_paper.html>`_ 和大量应用开发的相关资料。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
