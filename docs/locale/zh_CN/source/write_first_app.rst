编写你的第一个应用
==============================
Writing Your First Application
==============================

.. note:: 如果你对 Fabric 网络的基本架构还不熟悉，在继续本部分之前，你可能想先阅读 :doc:`key_concepts` 部分。

.. note:: If you're not yet familiar with the fundamental architecture of a
          Fabric network, you may want to visit the :doc:`key_concepts` section
          prior to continuing.

          本教程的价值仅限于介绍 Fabric 应用和使用简单的智能合约和应用。更深入的了解 Fabric 应用和智能合约请查看 :doc:`developapps/developing_applications` 或 :doc:`tutorial/commercial_paper` 部分。

          It is also worth noting that this tutorial serves as an introduction
          to Fabric applications and uses simple smart contracts and
          applications. For a more in-depth look at Fabric applications and
          smart contracts, check out our
          :doc:`developapps/developing_applications` section or the
          :doc:`tutorial/commercial_paper`.

本教程我们将通过手动开发一个简单的示例程序来演示 Fabric 应用是如何工作的。使用的这些应用和智能合约统称为 ``FabCar`` 。他们提供了理解 Hyperledger Fabric 区块链的一个很好的起点。我们将学习怎么写一个应用程序和智能合约来查询和更新账本，还有如何使用证书授权服务来生成一个 X.509 证书，应用程序将使用这个证书和授权区块链进行交互。

This tutorial provides an introduction to how Fabric applications interact
with deployed blockchain networks. The tutorial uses sample programs built using the
Fabric SDKs -- described in detail in the :doc:`/developapps/application` topic --
to invoke a smart contract which queries and updates the ledger with the smart
contract API -- described in detail in :doc:`/developapps/smartcontract`.
We will also use our sample programs and a deployed Certificate Authority to generate
the X.509 certificates that an application needs to interact with a permissioned
blockchain. 

我们将使用应用程序 SDK（详细介绍在 :doc:`/developapps/application`）使用智能合约 SDK 来执行智能合约的查询和更新账本（详细介绍在 :doc:`/developapps/smartcontract`）。

**About FabCar**

我们将按照以下三个步骤进行：

The FabCar sample demonstrates how to query `Car` (our sample business object) 
saved on the ledger, and how to update the ledger (add a new `Car` to the ledger). 
It involves following two components:

  **1. 搭建开发环境。** 我们的应用程序需要和网络交互，所以我们需要一个智能合约和
  应用程序使用的基础网络。

  1. Sample application: which makes calls to the blockchain network, invoking transactions
  implemented in the smart contracts.

  .. image:: images/AppConceptsOverview.png

  2. Smart contract itelf, implementing the transactions that involve interactions with the
  ledger.

  **2. 学习一个简单的智能合约， FabCar。**
  我们将查看智能合约来学习他们的交易，还有应用程序是怎么使用他们来进行查询和更新账本的。


  **3. 使用 FabCar 开发一个简单的应用程序。** 我们的应用程序将使用 FabCar 智能合约来查询和
  更新账本上的汽车资产。我们将进入到应用程序的代码和他们创建的交易，包括查询一辆汽车，
  查询一批汽车和创建一辆新车。

We’ll go through three principle steps:

在完成这个教程之后，你将基本理解一个应用是如何通过编程关联智能合约来和 Fabric 网络上的多个节点的账本的进行交互的。

  **1. Setting up a development environment.** Our application needs a network
  to interact with, so we'll deploy a basic network for our smart contracts and
  application.

.. note:: 这些应用程序也兼容 :doc:`discovery-overview` 和 :doc:`private-data/private-data` ，但是我们不会明确地展示如何使用这些功能。

  .. image:: images/AppConceptsOverview.png

设置区块链网络
-----------------------------

  **2. Explore a sample smart contract.**
  We’ll inspect the sample Fabcar smart contract to learn about the transactions within them,
  and how they are used by applications to query and update the ledger.

.. note:: 下边的部分需要进入你克隆到本地的 ``fabric-samples`` 仓库的 ``first-network`` 子目录。

  **3. Interact with the smart contract with a sample application.** Our application will
  use the FabCar smart contract to query and update car assets on the ledger.
  We'll get into the code of the apps and the transactions they create,
  including querying a car, querying a range of cars, and creating a new car.

如果你已经学习了 :doc:`build_network` ，你应该已经下载 ``fabric-samples`` 而且已经运行起来了一个网络。在你进行本教程之前，你必须停止这个网络：

After completing this tutorial you should have a basic understanding of how Fabric
applications and smart contracts work together to manage data on the distributed
ledger of a blockchain network.

.. code:: bash

Before you begin
----------------

  ./byfn.sh down

In addition to the standard :doc:`prereqs` for Fabric, this tutorial leverages the Hyperledger Fabric SDK for Node.js. See the Node.js SDK `README <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`__ for a up to date list of prerequisites.

如果你之前运行过这个教程，使用下边的命令关掉所有停止或者在运行的容器。注意，这将关掉你 **所有** 的容器，无论是否和 Fabric 有关。

- If you are using macOS, complete the following steps:

.. code:: bash

  1. Install `Homebrew <https://brew.sh/>`_.
  2. Check the Node SDK `prerequisites <https://github.com/hyperledger/fabric-sdk-node#build-and-test>`_ to find out what level of Node to install.
  3. Run ``brew install node`` to download the latest version of node or choose a specific version, for example: ``brew install node@10`` according to what is supported in the prerequisites.
  4. Run ``npm install``.

  docker rm -f $(docker ps -aq)
  docker rmi -f $(docker images | grep fabcar | awk '{print $3}')

- If you are on Windows,  you can install the `windows-build-tools <https://github.com/felixrieseberg/windows-build-tools#readme>`_ with npm which installs all required compilers and tooling by running the following command:

如果你没有网络和应用的开发环境和相关构件，访问 :doc:`prereqs` 页面，确保你已经在你的机器上安装了必要的依赖。

  .. code:: bash

然后，如果已经完成了这些，访问 :doc:`install` 页面，跟着上边的说明操作。当你克隆了 ``fabric-samples`` 仓库后返回本教程，然后下载最新的稳定版 Fabric 镜像和相关工具。

    npm install --global windows-build-tools

如果你使用的是 Mac OS 和 Mojava，你需要 `install Xcode<./tutorial/installxcode.html>`_.

- If you are on Linux, you need to install `Python v2.7 <https://www.python.org/download/releases/2.7/>`_, `make <https://www.gnu.org/software/make/>`_, and a C/C++ compiler toolchain such as `GCC <https://gcc.gnu.org/>`_. You can run the following command to install the other tools:

启动网络
^^^^^^^^^^^^^^^^^^

  .. code:: bash

.. note:: 下边的章节需要进入你克隆到本地的 ``fabric-samples`` 仓库的 ``fabcar`` 子目录。

    sudo apt install build-essentials

          这个教程展示了 Javascript 版本的 ``FabCar`` 智能合约和应用程序，但是 ``fabric-samples`` 仓库也包含 Go、Java 和 TypeScript 版本的样例。想尝试 Go、Java 或者 TypeScript 版本，改变下边的 ``./startFabric.sh`` 的 ``javascript`` 参数为 ``go``、 ``java`` 或者 ``typescript``，然后跟着介绍写到终端中。

Set up the blockchain network
-----------------------------

使用 ``startFabric.sh`` 启动你的网络。这个命令将启动一个区块链网络，这个网络由peer 节点、排序节点和证书授权服务等组成。同时也将安装和初始化 JavaScript 版的``FabCar`` 智能合约，我们的应用程序将通过它来控制账本。我们将通过本教程学习更多关于这些组件的内容。

If you've already run through :doc:`test_network` tutorial and have a network up
and running, this tutorial will bring down your running network before
bringing up a new one.

.. code:: bash


  ./startFabric.sh javascript

Launch the network
^^^^^^^^^^^^^^^^^^

好了，现在我们运行起来了一个示例网络，还有安装和初始化了 ``FabCar`` 智能合约。为了使用我们的应用程序，我们现在需要安装一些依赖，同时我们也看一下这些程序是如何一起工作的。

.. note:: This tutorial demonstrates the JavaScript versions of the FabCar
          smart contract and application, but the ``fabric-samples`` repo also
          contains Go, Java and TypeScript versions of this sample. To try the
          Go, Java or TypeScript versions, change the ``javascript`` argument
          for ``./startFabric.sh`` below to either ``go``, ``java`` or ``typescript``
          and follow the instructions written to the terminal.

安装应用程序
^^^^^^^^^^^^^^^^^^^^^^^

Navigate to the ``fabcar`` subdirectory within your local clone of the
``fabric-samples`` repo.

.. note:: 下边的章节需要进入你克隆到本地的 ``fabric-samples`` 仓库的 ``fabcar/javascript`` 子目录。

.. code:: bash

运行下边的命令来安装应用程序所需要的 Fabric 依赖。将要花费大约 1 分钟：

  cd fabric-samples/fabcar

.. code:: bash

Launch your network using the ``startFabric.sh`` shell script.

  npm install

.. code:: bash

这个指令将安装应用程序的主要依赖，这些依赖定义在 ``package.json`` 中。其中最重要的是 ``fabric-network`` 类；它使得应用程序可以使用身份、钱包和连接到通道的网关，以及提交交易和等待通知。本教程也将使用 ``fabric-ca-client`` 类来注册用户以及他们的授权证书，生成一个 ``fabric-network`` 在后边会用到的合法身份。

  ./startFabric.sh javascript

一旦 ``npm install`` 完成了，运行应用程序所需要的一切就准备好了。在这个教程中，你将主要使用 ``fabcar/javascript`` 目录下的 JavaScript 文件来操作应用程序。让我们来看一眼它里边有什么吧：

This command will deploy the Fabric test network with two peers and an ordering
service. Instead of using the cryptogen tool, we will bring up the test network
using Certificate Authorities. We will use one of these CAs to create the certificates
and keys that will be used by our applications in a future step. The ``startFabric.sh``
script will also deploy and initialize the JavaScript version of the FabCar smart
contract on the channel ``mychannel``, and then invoke the smart contract to
put initial data on the ledger.

.. code:: bash

Sample application
^^^^^^^^^^^^^^^^^^
First component of FabCar, the sample application, is available in following languages:

  ls

- `Golang <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/go>`__
- `Java <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/java>`__
- `JavaScript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/javascript>`__
- `Typescript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/fabcar/typescript>`__

你会看到下边的文件：

In this tutorial, we will explain the sample written in ``javascript`` for nodejs.

.. code:: bash

From the ``fabric-samples/fabcar`` directory, navigate to the
``javascript`` folder.

  enrollAdmin.js  node_modules       package.json  registerUser.js
  invoke.js       package-lock.json  query.js      wallet

.. code:: bash

里边也有一些其他编程语言的文件，比如在 ``fabcar/typescript`` 目录中。当你使用过 JavaScript 示例之后，你可以看一下它们，主要的内容都是一样的。

  cd javascript

如果你在使用 Mac OS 而且运行的是 Mojava ，你将需要 `install Xcode <./tutorial/installxcode.html>`_.

This directory contains sample programs that were developed using the Fabric
SDK for Node.js. Run the following command to install the application dependencies.
It will take about a minute to complete:

登记管理员用户
------------------------

.. code:: bash

.. note:: 下边的部分执行和证书授权服务器通讯。你在运行下边的程序时，你会发现，打开一个新终端，并运行 ``docker logs -f ca.example.com`` 来查看 CA 的日志流，会很有帮助。

  npm install

当我们创建网络的时候，一个管理员用户 --- 叫 ``admin`` --- 被证书授权服务器（CA）创建成了 **登记员** 。我们第一步要使用 ``enroll.js`` 程序为 ``admin`` 生成私钥、公钥和 x.509 证书。这个程序使用一个 **证书签名请求** (CSR) --- 现在本地生成公钥和私钥，然后把公钥发送到 CA ，CA 会发布会一个让应用程序使用的证书。这三个证书会保存在钱包中，以便于我们以管理员的身份使用 CA 。

This process is installing the key application dependencies defined in
``package.json``. The most important of which is the ``fabric-network`` class;
it enables an application to use identities, wallets, and gateways to connect to
channels, submit transactions, and wait for notifications. This tutorial also
uses the ``fabric-ca-client`` class to enroll users with their respective
certificate authorities, generating a valid identity which is then used by
``fabric-network`` class methods.

我们接下来会注册和登记一个新的应用程序用户，我们将使用这个用户来通过应用程序和区块链交互。

Once ``npm install`` completes, everything is in place to run the application.
Let's take a look at the sample JavaScript application files we will be using
in this tutorial:

我们登记一个 ``admin`` 用户：

.. code:: bash

.. code:: bash

  ls

  node enrollAdmin.js

You should see the following:

这个命令将 CA 管理员的证书保存在 ``wallet`` 目录。

.. code:: bash

注册和登记 ``user1``
-----------------------------

  enrollAdmin.js  node_modules       package.json  registerUser.js
  invoke.js       package-lock.json  query.js      wallet

注意我们在钱包里存放了管理员的证书，我们可以登记一个新用户 --- ``user1`` --- 他将被用来查询和更新账本：

There are files for other program languages, for example in the
``fabcar/java`` directory. You can read these once you've used the
JavaScript example -- the principles are the same.

.. code:: bash

Enrolling the admin user
------------------------

  node registerUser.js

.. note:: The following two sections involve communication with the Certificate
          Authority. You may find it useful to stream the CA logs when running
          the upcoming programs by opening a new terminal shell and running
          ``docker logs -f ca_org1``.

和管理员的登记类似，这个程序使用一个 CSR 来登记 ``user1`` 并把他的证书保存到 ``admin`` 所在的钱包里。我们现在有了两个独立的用户 --- ``admin`` 和 ``user1`` --- 他们将用于我们的应用程序。

When we created the network, an admin user --- literally called ``admin`` ---
was created as the **registrar** for the certificate authority (CA). Our first
step is to generate the private key, public key, and X.509 certificate for
``admin`` using the ``enroll.js`` program. This process uses a **Certificate
Signing Request** (CSR) --- the private and public key are first generated
locally and the public key is then sent to the CA which returns an encoded
certificate for use by the application. These credentials are then stored
in the wallet, allowing us to act as an administrator for the CA.

账本交互时间。。。

Let's enroll user ``admin``:

查询账本
-------------------

.. code:: bash

区块链网络中的每个节点都拥有一个账本的副本，应用程序可以通过执行智能合约查询账本上最新的数据来实现来查询账本，并将查询结果返回给应用程序。

  node enrollAdmin.js

这里是一个查询工作如何进行的简单说明：

This command stores the CA administrator's credentials in the ``wallet`` directory.
You can find administrator's certificate and private key in the ``wallet/admin.id``
file.

.. image:: tutorial/write_first_app.diagram.1.png

Register and enroll an application user
---------------------------------------

应用程序使用查询从 `ledger <./ledger/ledger.html>`_ 读取数据。最常用的查询是查寻账本中询当前的值 -- 也就是 `world state <./ledger/ledger.html#world-state>`_ 。世界状态是一个键值对的集合，应用程序可以根据一个键或者多个键来查询数据。而且，当键值对是以 JSON 值模式组织的时候，世界状态可以通过配置使用数据库（如 CouchDB ）来支持富查询。这对于查询所有资产来匹配特定的键的值是很有用的，比如查询一个人的所有汽车。

Our ``admin`` is used to work with the CA. Now that we have the administrator's
credentials in a wallet, we can create a new application user which will be used
to interact with the blockchain. Run the following command to register and enroll
a new user named ``appUser``:

首先，我们来运行我们的 ``query.js`` 程序来返回账本上所有汽车的侦听。这个程序使用我们的第二个身份 -- ``user1`` -- 来操作账本。

.. code:: bash

.. code:: bash

  node registerUser.js

  node query.js

Similar to the admin enrollment, this program uses a CSR to enroll ``appUser`` and
store its credentials alongside those of ``admin`` in the wallet. We now have
identities for two separate users --- ``admin`` and ``appUser`` --- that can be
used by our application.

输入结果应该类似下边：

Querying the ledger
-------------------

.. code:: json

Each peer in a blockchain network hosts a copy of the `ledger <./ledger/ledger.html>`_. An application
program can view the most recent data from the ledger using read only invocations of
a smart contract running on your peers called a query.

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

Here is a simplified representation of how a query works:

让我们更进一步看一下这个程序。使用一个编辑器（比如， atom 或 visual studio）打开 ``query.js`` 。

.. image:: tutorial/write_first_app.diagram.1.png

应用程序开始的时候就从 ``fabric-network`` 模块引入了两个关键的类``FileSystemWallet`` 和 ``Gateway`` 。这两个类将用于定位钱包中 ``user1`` 的身份，这个身份将用于连接网络。

The most common queries involve the current values of data in the ledger -- its
`world state <./ledger/ledger.html#world-state>`_. The world state is
represented as a set of key-value pairs, and applications can query data for a
single key or multiple keys. Moreover, you can use complex queries to read the
data on the ledger when you use CouchDB as your state database and model your data in JSON.
This can be very helpful when looking for all assets that match certain keywords
with particular values; all cars with a particular owner, for example.

.. code:: bash

First, let's run our ``query.js`` program to return a listing of all the cars on
the ledger. This program uses our second identity -- ``appUser`` -- to access the
ledger:

  const { FileSystemWallet, Gateway } = require('fabric-network');

.. code:: bash

应用程序通过网关连接网络：

  node query.js

.. code:: bash

The output should look like this:

  const gateway = new Gateway();
  await gateway.connect(ccp, { wallet, identity: 'user1' });

.. code:: json

这段代码创建了一个新网关，然后通过它让应用程序连接到网络。 ``cpp`` 描述了网关将通过 ``wallet`` 中的 ``user1`` 来使用网络。打开 ``../../first-network/connection.json`` 来查看 ``cpp`` 是如何解析一个 JSON 文件的：

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  [{"Key":"CAR0","Record":{"color":"blue","docType":"car","make":"Toyota","model":"Prius","owner":"Tomoko"}},
  {"Key":"CAR1","Record":{"color":"red","docType":"car","make":"Ford","model":"Mustang","owner":"Brad"}},
  {"Key":"CAR2","Record":{"color":"green","docType":"car","make":"Hyundai","model":"Tucson","owner":"Jin Soo"}},
  {"Key":"CAR3","Record":{"color":"yellow","docType":"car","make":"Volkswagen","model":"Passat","owner":"Max"}},
  {"Key":"CAR4","Record":{"color":"black","docType":"car","make":"Tesla","model":"S","owner":"Adriana"}},
  {"Key":"CAR5","Record":{"color":"purple","docType":"car","make":"Peugeot","model":"205","owner":"Michel"}},
  {"Key":"CAR6","Record":{"color":"white","docType":"car","make":"Chery","model":"S22L","owner":"Aarav"}},
  {"Key":"CAR7","Record":{"color":"violet","docType":"car","make":"Fiat","model":"Punto","owner":"Pari"}},
  {"Key":"CAR8","Record":{"color":"indigo","docType":"car","make":"Tata","model":"Nano","owner":"Valeria"}},
  {"Key":"CAR9","Record":{"color":"brown","docType":"car","make":"Holden","model":"Barina","owner":"Shotaro"}}]

.. code:: bash

Let's take a closer look at how `query.js` program uses the APIs provided by the
`Fabric Node SDK <https://hyperledger.github.io/fabric-sdk-node/>`__ to
interact with our Fabric network. Use an editor (e.g. atom or visual studio) to
open ``query.js``.

  const ccpPath = path.resolve(__dirname, '..', '..', 'first-network', 'connection.json');
  const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
  const ccp = JSON.parse(ccpJSON);

The application starts by bringing in scope two key classes from the
``fabric-network`` module; ``Wallets`` and ``Gateway``. These classes
will be used to locate the ``appUser`` identity in the wallet, and use it to
connect to the network:

如果你想了解更多关于连接配置文件的结构，和它是怎么定义网络的，请查阅 `the connection profile topic <./developapps/connectionprofile.html>`_ 。

.. code:: bash

一个网络可以被差分成很多通道，代码中下一个很重的一行是将应用程序连接到网络中特定的通道 ``mychannel`` 上：

  const { Gateway, Wallets } = require('fabric-network');

.. code:: bash

First, the program uses the Wallet class to get our application user from our file system.

  const network = await gateway.getNetwork('mychannel');

.. code:: bash

  const network = await gateway.getNetwork('mychannel');

  const identity = await wallet.get('appUser');

在这个通道中，我们可以通过 ``fabcar`` 智能合约来和账本进行交互：

Once the program has an identity, it uses the Gateway class to connect to our network.

.. code:: bash

  const contract = network.getContract('fabcar');

  const gateway = new Gateway();
  await gateway.connect(ccpPath, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

在 ``fabcar`` 中有许多不同的 **交易** ，我们的应用程序先使用 ``queryAllCars`` 交易来查询账本世界状态的值：

``ccpPath`` describes the path to the connection profile that our application will use
to connect to our network. The connection profile was loaded from inside the
``fabric-samples/test-network`` directory and parsed as a JSON file:

.. code:: bash

  const result = await contract.evaluateTransaction('queryAllCars');

  const ccpPath = path.resolve(__dirname, '..', '..', 'test-network','organizations','peerOrganizations','org1.example.com', 'connection-org1.json');

``evaluateTransaction`` 方法代表了一种区块链网络中和智能合约最简单的交互。它只是的根据配置文件中的定义连接一个节点，然后向节点发送请求，请求内容将在节点中执行。智能合约查询节点账本上的所有汽车，然后把结果返回给应用程序。这次交互没有导致账本的更新。

If you'd like to understand more about the structure of a connection profile,
and how it defines the network, check out
`the connection profile topic <./developapps/connectionprofile.html>`_.

FabCar 智能合约
-------------------------

A network can be divided into multiple channels, and the next important line of
code connects the application to a particular channel within the network,
``mychannel``, where our smart contract was deployed:

让我们看一看 ``FabCar`` 智能合约里的交易。进入 ``fabric-samples`` 下的子目录 ``chaincode/fabcar/javascript/lib`` ，然后用你的编辑器打开 ``fabcar.js`` 。

.. code:: bash

看一下我们的智能合约是如何通过 ``Contract`` 类来定义的：

  const network = await gateway.getNetwork('mychannel');

.. code:: bash

Within this channel, we can access the FabCar smart contract to interact
with the ledger:

  class FabCar extends Contract {...

.. code:: bash

在这个类结构中，你将看到定义了以下交易： ``initLedger``, ``queryCar``, ``queryAllCars``, ``createCar``, and ``changeCarOwner`` 。例如：

  const contract = network.getContract('fabcar');

.. code:: bash

Within FabCar there are many different **transactions**, and our application
initially uses the ``queryAllCars`` transaction to access the ledger world state
data:

  async queryCar(ctx, carNumber) {...}
  async queryAllCars(ctx) {...}

.. code:: bash

让我们更进一步看一下 ``queryAllCars`` ，看一下它是怎么和账本交互的。

  const result = await contract.evaluateTransaction('queryAllCars');

.. code:: bash

The ``evaluateTransaction`` method represents one of the simplest interactions
with a smart contract in blockchain network. It simply picks a peer defined in
the connection profile and sends the request to it, where it is evaluated. The
smart contract queries all the cars on the peer's copy of the ledger and returns
the result to the application. This interaction does not result in an update the
ledger.

  async queryAllCars(ctx) {

The FabCar smart contract
-------------------------
FabCar smart contract sample is available in following languages:

    const startKey = 'CAR0';
    const endKey = 'CAR999';

- `Golang <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/go>`__
- `Java <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/java>`__
- `JavaScript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/javascript>`__
- `Typescript <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/typescript>`__

    const iterator = await ctx.stub.getStateByRange(startKey, endKey);

Let's take a look at the transactions within the FabCar smart contract written in JavaScript. Open a
new terminal and navigate to the JavaScript version of the FabCar Smart contract
inside the ``fabric-samples`` repository:

这段代码定义了 ``queryAllCars`` 将要从账本获取的汽车的范围。从 ``CAR0`` 到 ``CAR999`` 的每一辆车——一共 1000 辆车，假定每个键都被合适地锚定了——将会作为查询结果被返回。代码中剩下的部分，通过迭代将查询结果打包成 JSON 并返回给应用。

.. code:: bash

下边将展示应用程序如何调用智能合约中的不同交易。每一个交易都使用一组 API 比如 ``getStateByRange`` 来和账本进行交互。了解更多 API 请阅读 `detail <https://fabric-shim.github.io/master/index.html?redirect=true>`_.

  cd fabric-samples/chaincode/fabcar/javascript/lib

.. image:: images/RunningtheSample.png

Open the ``fabcar.js`` file in a text editor editor.

你可以看到我们的 ``queryAllCars`` 交易，还有另一个叫做 ``createCar`` 。我们稍后将在教程中使用他们来更细账本，和添加新的区块。

See how our smart contract is defined using the ``Contract`` class:

但是在那之前，返回到 ``query`` 程序，更改 ``evaluateTransaction`` 的请求来查询 ``CAR4`` 。 ``query`` 程序现在看起来应该是这个样子：

.. code:: bash

.. code:: bash

  class FabCar extends Contract {...

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

Within this class structure, you'll see that we have the following
transactions defined: ``initLedger``, ``queryCar``, ``queryAllCars``,
``createCar``, and ``changeCarOwner``. For example:

保存程序，然后返回到 ``fabcar/javascript`` 目录。现在，再次运行 ``query`` 程序：


.. code:: bash

  node query.js

  async queryCar(ctx, carNumber) {...}
  async queryAllCars(ctx) {...}

你应该会看到如下：

Let's take a closer look at the ``queryAllCars`` transaction to see how it
interacts with the ledger.

.. code:: json

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}

  async queryAllCars(ctx) {

如果你回头去看一下 ``queryAllCars`` 的交易结果，你会看到 ``CAR4`` 是 Adriana 的黑色 Tesla model S，也就是这里返回的结果。

    const startKey = '';
    const endKey = '';

我们可以使用 ``queryCar`` 交易来查询任意汽车，使用它的键 （比如 ``CAR0`` ）得到车辆的制造商、型号、颜色和车主等相关信息。

    const iterator = await ctx.stub.getStateByRange(startKey, endKey);

很棒。现在你应该已经了解了智能合约中基础的查询交易，也手动修改了查询程序中的参数。


账本更新时间。。。

This code shows how to retrieve all cars from the ledger within a key range using
``getStateByRange``. Giving empty startKey & endKey is interpreted as all the keys from beginning to end.
As another example, if you use ``startKey = 'CAR0', endKey = 'CAR999'`` , then ``getStateByRange``
will retrieve cars with keys between ``CAR0`` (inclusive) and ``CAR999`` (exclusive) in lexical order. 
The remainder of the code iterates through the query results and packages them into
JSON for the sample application to use.

更新账本
-------------------

Below is a representation of how an application would call different
transactions in a smart contract. Each transaction uses a broad set of APIs such
as ``getStateByRange`` to interact with the ledger. You can read more about
these APIs in `detail
<https://hyperledger.github.io/fabric-chaincode-node/>`_.

现在我们已经完成一些账本的查询和添加了一些代码，我们已经准备好更新账本了。有很多的更新操作我们可以做，但是我们从创建一个 **新** 车开始。

.. image:: images/RunningtheSample.png

从一个应用程序的角度来说，更新一个账本很简单。应用程序向区块链网络提交一个交易，当交易被验证和提交后，应用程序会收到一个交易成功的提醒。但是在底层，区块链网络中各组件中不同的 **共识** 程序协同工作，来保证账本的每一个更新提案都是合法的，而且有一个大家一致认可的顺序。

We can see our ``queryAllCars`` transaction, and another called ``createCar``.
We will use this later in the tutorial to update the ledger, and add a new block
to the blockchain.

.. image:: tutorial/write_first_app.diagram.2.png

But first, go back to the ``query`` program and change the
``evaluateTransaction`` request to query ``CAR4``. The ``query`` program should
now look like this:

上图中，我们可以看到完成这项工作的主要组件。同时，多个节点中每一个节点都拥有一份账本的副本，并可选的拥有一份智能合约的副本，网络中也有一个排序服务。排序服务保证网络中交易的一致性；它也将连接到网络中不同的应用程序的交易以定义好的顺序生成区块。

.. code:: bash

我们对账本的的第一个更新是创建一辆新车。我们有一个单独的程序叫做 ``invoke.js`` ，用来更新账本。和查询一样，使用一个编辑器打开程序定位到我们构建和提交交易到网络的代码段：

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

.. code:: bash

Save the program and navigate back to your ``fabcar/javascript`` directory.
Now run the ``query`` program again:

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

.. code:: bash

看一下应用程序如何调用智能合约的交易 ``createCar`` 来创建一量车主为 Tom 的黑色 Honda Accord 汽车。我们使用 ``CAR12`` 作为这里的键，这也说明了我们不必使用连续的键。

  node query.js

保存并运行程序：

You should see the following:

.. code:: bash

.. code:: json

  node invoke.js

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"color":"black","docType":"car","make":"Tesla","model":"S","owner":"Adriana"}

如果执行成功，你将看到类似输出：

If you go back and look at the result from when the transaction was
``queryAllCars``, you can see that ``CAR4`` was Adriana’s black Tesla model S,
which is the result that was returned here.

.. code:: bash

We can use the ``queryCar`` transaction to query against any car, using its
key (e.g. ``CAR0``) and get whatever make, model, color, and owner correspond to
that car.

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  2018-12-11T14:11:40.935Z - info: [TransactionEventHandler]: _strategySuccess: strategy success for transaction "9076cd4279a71ecf99665aed0ed3590a25bba040fa6b4dd6d010f42bb26ff5d1"
  Transaction has been submitted

Great. At this point you should be comfortable with the basic query transactions
in the smart contract and the handful of parameters in the query program.

注意 ``inovke`` 程序是怎样使用 ``submitTransaction`` API 和区块链网络交互的，而不是 ``evaluateTransaction`` 。

Time to update the ledger...

.. code:: bash

Updating the ledger
-------------------

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

Now that we’ve done a few ledger queries and added a bit of code, we’re ready to
update the ledger. There are a lot of potential updates we could make, but
let's start by creating a **new** car.

``submitTransaction`` 比 ``evaluateTransaction`` 更加复杂。除了跟一个单独的 peer 进行互动外，SDK 会将 ``submitTransaction`` 提案发送给在区块链网络中的每个需要的组织的 peer。其中的每个 peer 将会使用这个提案来执行被请求的智能合约，以此来产生一个建议的回复，它会为这个回复签名并将其返回给 SDK。SDK 搜集所有签过名的交易反馈到一个单独的交易中，这个交易会被发送给排序节点。排序节点从每个应用程序那里搜集并将交易排序，然后打包进一个交易的区块中。接下来它会将这些区块分发给网络中的每个 peer，在那里每笔交易会被验证并提交。最后，SDK 会被通知，这允许它能够将控制返回给应用程序。

From an application perspective, updating the ledger is simple. An application
submits a transaction to the blockchain network, and when it has been
validated and committed, the application receives a notification that
the transaction has been successful. Under the covers this involves the process
of **consensus** whereby the different components of the blockchain network work
together to ensure that every proposed update to the ledger is valid and
performed in an agreed and consistent order.

.. note:: ``submitTransaction`` 也包含一个监听者，它会检查来确保交易被验证并提交到账本中。应用程序应该使用一个提交监听者，或者使用像 ``submitTransaction`` 这样的 API 来给你做这件事情。如果不做这个，你的交易就可能没有被成功地排序、验证以及提交到账本。

.. image:: tutorial/write_first_app.diagram.2.png

应用程序中的这些工作由 ``submitTransaction`` 完成！应用程序、智能合约、节点和排序服务一起工作来保证网络中账本一致性的程序被称为共识，它的详细解释在这里 `section <./peers/peers.html>`_ 。

Above, you can see the major components that make this process work. As well as
the multiple peers which each host a copy of the ledger, and optionally a copy
of the smart contract, the network also contains an ordering service. The
ordering service coordinates transactions for a network; it creates blocks
containing transactions in a well-defined sequence originating from all the
different applications connected to the network.

为了查看这个被写入账本的交易，返回到 ``query.js`` 并将参数 ``CAR4`` 更改为 ``CAR12`` 。

Our first update to the ledger will create a new car. We have a separate program
called ``invoke.js`` that we will use to make updates to the ledger. Just as with
queries, use an editor to open the program and navigate to the code block where
we construct our transaction and submit it to the network:

就是说，将：

.. code:: bash

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

See how the applications calls the smart contract transaction ``createCar`` to
create a black Honda Accord with an owner named Tom. We use ``CAR12`` as the
identifying key here, just to show that we don't need to use sequential keys.

改为：

Save it and run the program:

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR12');

  node invoke.js

再次保存，然后查询：

If the invoke is successful, you will see output like this:

.. code:: bash

  node query.js

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been submitted

应该返回这些：

Notice how the ``invoke`` application interacted with the blockchain network
using the ``submitTransaction`` API, rather than ``evaluateTransaction``.

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"Black","make":"Honda","model":"Accord","owner":"Tom"}

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

恭喜。你创建了一辆汽车并验证了它记录在账本上！

``submitTransaction`` is much more sophisticated than ``evaluateTransaction``.
Rather than interacting with a single peer, the SDK will send the
``submitTransaction`` proposal to every required organization's peer in the
blockchain network. Each of these peers will execute the requested smart
contract using this proposal, to generate a transaction response which it signs
and returns to the SDK. The SDK collects all the signed transaction responses
into a single transaction, which it then sends to the orderer. The orderer
collects and sequences transactions from every application into a block of
transactions. It then distributes these blocks to every peer in the network,
where every transaction is validated and committed. Finally, the SDK is
notified, allowing it to return control to the application.

现在我们已经完成了，我们假设 Tom 很大方，想把他的 Honda Accord 送给一个叫 Dave 的人。

.. note:: ``submitTransaction`` also includes a listener that checks to make
          sure the transaction has been validated and committed to the ledger.
          Applications should either utilize a commit listener, or
          leverage an API like ``submitTransaction`` that does this for you.
          Without doing this, your transaction may not have been successfully
          ordered, validated, and committed to the ledger.

为了完成这个，返回到 ``invoke.js`` 然后利用输入的参数，将智能合约的交易从 ``createCar`` 改为 ``changeCarOwner`` ：

``submitTransaction`` does all this for the application! The process by which
the application, smart contract, peers and ordering service work together to
keep the ledger consistent across the network is called consensus, and it is
explained in detail in this `section <./peers/peers.html>`_.

.. code:: bash

To see that this transaction has been written to the ledger, go back to
``query.js`` and change the argument from ``CAR4`` to ``CAR12``.

  await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');

In other words, change this:

第一个参数 --- ``CAR12`` --- 表示将要易主的车。第二个参数 --- ``Dave`` --- 表示车的新主人。

.. code:: bash

再次保存并执行程序：

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

.. code:: bash

To this:

  node invoke.js

.. code:: bash

现在我们来再次查询账本，以确定 Dave 和 ``CAR12`` 键已经关联起来了：

  const result = await contract.evaluateTransaction('queryCar', 'CAR12');

.. code:: bash

Save once again, then query:

  node query.js

.. code:: bash

将返回如下结果：

  node query.js

.. code:: bash

Which should return this:

   Wallet path: ...fabric-samples/fabcar/javascript/wallet
   Transaction has been evaluated, result is:
   {"colour":"Black","make":"Honda","model":"Accord","owner":"Dave"}

.. code:: bash

``CAR12`` 的主人已经从 Tom 变成了 Dave。

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"color":"Black","docType":"car","make":"Honda","model":"Accord","owner":"Tom"}

.. note:: In a real world application the smart contract would likely have some
          access control logic. For example, only certain authorized users may
          create new cars, and only the car owner may transfer the car to
          somebody else.

Congratulations. You’ve created a car and verified that its recorded on the
ledger!

.. note:: 在真实世界中的一个应用程序里，智能合约应该有一些访问控制逻辑。比如，只有某些有权限的用户能够创建新的 car，并且只有 car 的拥有者才能够将 car 交换给其他人。

So now that we’ve done that, let’s say that Tom is feeling generous and he
wants to give his Honda Accord to someone named Dave.

总结
-------

To do this, go back to ``invoke.js`` and change the smart contract transaction
from ``createCar`` to ``changeCarOwner`` with a corresponding change in input
arguments:

现在我们完成了一些查询和跟新，你应该已经比较了解如何通过智能合约和区块链网络进行交互来查询和更新账本。我们已经看过了查询和更新的基本角智能合约、API 和 SDK ，你也应该对如何在其他的商业场景和操作中使用不同应用有了一些认识。

.. code:: bash

其他资源
--------------------

  await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');

就像我们在介绍中说的，我们有一整套文章在 :doc:`developapps/developing_applications` 包含了关于智能合约、程序和数据设计的更多信息，一个更深入的使用商业票据的教程`tutorial <./tutorial/commercial_paper.html>`_ 和大量应用开发的相关资料。

The first argument --- ``CAR12`` --- identifies the car that will be changing
owners. The second argument --- ``Dave`` --- defines the new owner of the car.

Save and execute the program again:

.. code:: bash

  node invoke.js

Now let’s query the ledger again and ensure that Dave is now associated with the
``CAR12`` key:

.. code:: bash

  node query.js

It should return this result:

.. code:: bash

   Wallet path: ...fabric-samples/fabcar/javascript/wallet
   Transaction has been evaluated, result is:
   {"color":"Black","docType":"car","make":"Honda","model":"Accord","owner":"Dave"}

The ownership of ``CAR12`` has been changed from Tom to Dave.

.. note:: In a real world application the smart contract would likely have some
          access control logic. For example, only certain authorized users may
          create new cars, and only the car owner may transfer the car to
          somebody else.

Clean up
--------

When you are finished using the FabCar sample, you can bring down the test
network using ``networkDown.sh`` script.


.. code:: bash

  ./networkDown.sh

This command will bring down the CAs, peers, and ordering node of the network
that we created. It will also remove the ``admin`` and ``appUser`` crypto material stored
in the ``wallet`` directory. Note that all of the data on the ledger will be lost.
If you want to go through the tutorial again, you will start from a clean initial state.

Summary
-------

Now that we’ve done a few queries and a few updates, you should have a pretty
good sense of how applications interact with a blockchain network using a smart
contract to query or update the ledger. You’ve seen the basics of the roles
smart contracts, APIs, and the SDK play in queries and updates and you should
have a feel for how different kinds of applications could be used to perform
other business tasks and operations.

Additional resources
--------------------

As we said in the introduction, we have a whole section on
:doc:`developapps/developing_applications` that includes in-depth information on
smart contracts, process and data design, a tutorial using a more in-depth
Commercial Paper `tutorial <./tutorial/commercial_paper.html>`_ and a large
amount of other material relating to the development of applications.
