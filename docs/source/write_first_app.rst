Writing Your First Application - 编写你的第一个应用
==============================

.. note:: If you're not yet familiar with the fundamental architecture of a
          Fabric network, you may want to visit the :doc:`key_concepts` section
          prior to continuing.

          It is also worth noting that this tutorial serves as an introduction
          to Fabric applications and uses simple smart contracts and
          applications. For a more in-depth look at Fabric applications and
          smart contracts, check out our
          :doc:`developapps/developing_applications` section or the
          :doc:`tutorial/commercial_paper`.

.. note:: 如果你对 Fabric 网络的基本架构还不熟悉请，在继续本部分之前，你可能想先阅读 :doc:`key_concepts` 部分。
            
          本教程的价值仅限于介绍 Fabric 应用和使用简单的智能合约和应用。更深入的了解 Fabric 应用和智能合约请查看 :doc:`developapps/developing_applications` 或 :doc:`tutorial/commercial_paper` 部分

In this tutorial we'll be looking at a handful of sample programs to see how
Fabric apps work. These applications and the smart contracts they use are
collectively known as ``FabCar``. They provide a great starting point to
understand a Hyperledger Fabric blockchain. You'll learn how to write an
application and smart contract to query and update a ledger, and how to use a
Certificate Authority to generate the X.509 certificates used by applications
which interact with a permissioned blockchain.

本教程我们将通过手动开发一个简单的示例程序来演示 Fabric 应用是如何工作的。
使用的这些应用和智能合约统称为 ``FabCar`` 。他们提供了理解 Hyperledger Fabric 
区块链的一个很好的起点。我们将学犀怎么写一个应用和智能合约来查询和更新账本，
还有如何使用证书授权服务来生成一个 X.509 证书，应用将使用这个证书和授权区块链
进行交互。

We will use the application SDK --- described in detail in the
:doc:`/developapps/application` topic -- to invoke a smart contract which
queries and updates the ledger using the smart contract SDK --- described in
detail in section :doc:`/developapps/smartcontract`.

我们将使用应用 SDK —— 详细介绍在 :doc:`/developapps/application` —— 使用智能
合约 SDK 来执行智能合约的查询和更新账本 —— 详细介绍在 —— :doc:`/developapps/smartcontract` 。

We’ll go through three principle steps:

我们将按照一下三个步骤进行：

  **1. Setting up a development environment.** Our application needs a network
  to interact with, so we'll get a basic network our smart contracts and
  application will use.

  **1. 搭建开发环境。** 我们的应用需要和网络交互，所以我们需要一个智能合约和应用使用的基础网络。

  .. image:: images/AppConceptsOverview.png

  **2. Learning about a sample smart contract, FabCar.**
  We use a smart contract written in **JavaScript** . We’ll
  inspect the smart contract to learn about the transactions within them, and
  how they are used by applications to query and update the ledger.

  **2. 学习一个简单的智能合约， FabCar。** 我们使用一个 **JavaScript** 写的智能合约。
  我们将查看智能合约来学习他们的交易，还有应用是怎么使用他们来进行查询和更新账本的。

  **3. Develop a sample application which uses FabCar.** Our application will
  use the FabCar smart contract to query and update car assets on the ledger.
  We'll get into the code of the apps and the transactions they create,
  including querying a car, querying a range of cars, and creating a new car.

  **3. 使用 FabCar 开发一个简单的应用。** 我们的应用将使用 FabCar 智能合约来查询和
  更新账本上的汽车资产。我们将进入到应用的代码和他们创建的交易，包括查询一辆汽车，
  查询一批汽车和创建一辆新车。

After completing this tutorial you should have a basic understanding of how an
application is programmed in conjunction with a smart contract to interact with
the ledger hosted and replicated on the peers in a Fabric network.

在完成这个教程之后，你将基本理解一个应用是如何通过编程关联智能合约来和 Fabric 
网络上的多个节点的账本的进行交互的。

.. note:: These applications are also compatible with :doc:`discovery-overview`
          and :doc:`private-data/private-data`, though we won't explicitly show
          how to use our apps to leverage those features.

.. note:: 这些应用也兼容 :doc:`discovery-overview` 和 :doc:`private-data/private-data` ，
          但是我们不会明确地展示如何使用这些功能。

Set up the blockchain network - 设置区块链网络
-----------------------------

.. note:: This next section requires you to be in the ``first-network``
          subdirectory within your local clone of the ``fabric-samples`` repo.

.. note:: 下边的部分需要你进入你克隆到本地的 ``fabric-samples`` 仓库的
          ``first-network`` 子目录。

If you've already run through :doc:`build_network`, you will have downloaded
``fabric-samples`` and have a network up and running. Before you run this
tutorial, you must stop this network:

如果你已经学习了 :doc:`build_network` ，你应该已经下载 ``fabric-samples`` 
而且已经运行起来了一个网络。在你进行本教程之前，你必须停止这个网络：

.. code:: bash

  ./byfn.sh down

If you have run through this tutorial before, use the following commands to
kill any stale or active containers. Note, this will take down **all** of your
containers whether they're Fabric related or not.

如果你之前运行过这个教程，使用下边的命令关掉所有停止或者在运行的容器。注意，
这将关掉你 **所有** 的容器，无论是否和 Fabric 有关。

.. code:: bash

  docker rm -f $(docker ps -aq)
  docker rmi -f $(docker images | grep fabcar | awk '{print $3}')

If you don't have a development environment and the accompanying artifacts for
the network and applications, visit the :doc:`prereqs` page and ensure you have
the necessary dependencies installed on your machine.

如果你没有网络和应用的开发环境和相关构件，访问 :doc:`prereqs` 页面，确保你已经
在你的机器上安装了必要的依赖。

Next, if you haven't done so already, visit the :doc:`install` page and follow
the provided instructions. Return to this tutorial once you have cloned the
``fabric-samples`` repository, and downloaded the latest stable Fabric images
and available utilities.

下一步，如果已经完成了，访问 :doc:`install` 页面，跟着上边的说明操作。当你克隆
了 ``fabric-samples`` 仓库返回本教程，然后下载最新的稳定版 Fabric 镜像和相关工具。

If you are using Mac OS and running Mojave, you will need to `install Xcode
<./tutorial/installxcode.html>`_.

如果你使用的是 Mac OS 和 Mojava，你需要 `install Xcode<./tutorial/installxcode.html>`_.

Launch the network - 启动网络
^^^^^^^^^^^^^^^^^^

.. note:: This next section requires you to be in the ``fabcar``
          subdirectory within your local clone of the ``fabric-samples`` repo.

.. note:: 下边的章节需要你进入你克隆到本地的 ``fabric-samples`` 仓库的 ``fabcar`` 
          子目录。

Launch your network using the ``startFabric.sh`` shell script. This command will
spin up a blockchain network comprising peers, orderers, certificate
authorities and more.  It will also install and instantiate a javascript version
of the ``FabCar`` smart contract which will be used by our application to access
the ledger. We'll learn more about these components as we go through the
tutorial.

使用 ``startFabric.sh`` 启动你的网络。这个命令将启动一个区块链网络，这个网络由 
peer 节点，排序节点，证书授权服务等组成。同时也将安装和初始化 javascript 版的
``FabCar`` 智能合约，我们的应用将通过它来控制账本。我们将通过本教程学习更多关于
这些组件的内容。

.. code:: bash

  ./startFabric.sh javascript

Alright, you’ve now got a sample network up and running, and the ``FabCar``
smart contract installed and instantiated. Let’s install our application
pre-requisites so that we can try it out, and see how everything works together.

好了，现在我们运行起来了一个示例网络，还有安装和初始化了 ``FabCar`` 智能合约。
为了使用我们的应用程序，我们现在需要安装一些依赖，同时我们也看一下这些程序是如
何一起工作的。

Install the application - 安装应用程序
^^^^^^^^^^^^^^^^^^^^^^^

.. note:: The following instructions require you to be in the
          ``fabcar/javascript`` subdirectory within your local clone of the
          ``fabric-samples`` repo.


.. note:: 下边的章节需要你进入你克隆到本地的 ``fabric-samples`` 仓库的 
          ``fabcar/javascript`` 子目录。

Run the following command to install the Fabric dependencies for the
applications. It will take about a minute to complete:

运行下边的命令来安装应用程序所需要的 Fabric 依赖。将要花费大约 1 分钟：

.. code:: bash

  npm install

This process is installing the key application dependencies defined in
``package.json``. The most important of which is the ``fabric-network`` class;
it enables an application to use identities, wallets, and gateways to connect to
channels, submit transactions, and wait for notifications. This tutorial also
uses the ``fabric-ca-client`` class to enroll users with their respective
certificate authorities, generating a valid identity which is then used by
``fabric-network`` class methods.

这个指令将安装应用程序的主要依赖，这些依赖定义在 ``package.json`` 中。其中最重要
的是 ``fabric-network`` 类；它使得应用程序可以使用身份、钱包和连接到通道的网关，
以及提交交易和等待通知。本教程也将使用 ``fabric-ca-client`` 类来注册用户以及他们
的授权证书，生成一个 ``fabric-network`` 在后边会用到的合法身份。

Once ``npm install`` completes, everything is in place to run the application.
For this tutorial, you'll primarily be using the application JavaScript files in
the ``fabcar/javascript`` directory. Let's take a look at what's inside:

一旦 ``npm install`` 完成了，运行应用程序所需要的一切就准备好了。在这个教程中，
你将主要使用 ``fabcar'/javascript`` 目录下的 JavaScript 文件来操作应用程序。
让我们来看一眼它里边有什么吧：

.. code:: bash

  ls

You should see the following:

你会看到下边的文件：

.. code:: bash

  enrollAdmin.js  node_modules       package.json  registerUser.js
  invoke.js       package-lock.json  query.js      wallet

There are files for other program languages, for example in the
``fabcar/typescript`` directory. You can read these once you've used the
JavaScript example -- the principles are the same.

里边也有一些其他编程语言的文件，比如在 ``fabcar/typescript`` 目录中。当你使用
过 JavaScript 示例之后，你可以看一下他们，主要的内容都是一样的。

If you are using Mac OS and running Mojave, you will need to `install Xcode
<./tutorial/installxcode.html>`_.

如果你在使用 Mac OS 而且运行的是 Mojava ，你将需要 `install Xcode <./tutorial/installxcode.html>`_.

Enrolling the admin user
------------------------

.. note:: The following two sections involve communication with the Certificate
          Authority. You may find it useful to stream the CA logs when running
          the upcoming programs by opening a new terminal shell and running
          ``docker logs -f ca.example.com``.

When we created the network, an admin user --- literally called ``admin`` ---
was created as the **registrar** for the certificate authority (CA). Our first
step is to generate the private key, public key, and X.509 certificate for
``admin`` using the ``enroll.js`` program. This process uses a **Certificate
Signing Request** (CSR) --- the private and public key are first generated
locally and the public key is then sent to the CA which returns an encoded
certificate for use by the application. These three credentials are then stored
in the wallet, allowing us to act as an administrator for the CA.

We will subsequently register and enroll a new application user which will be
used by our application to interact with the blockchain.

Let's enroll user ``admin``:

.. code:: bash

  node enrollAdmin.js

This command has stored the CA administrator's credentials in the ``wallet``
directory.

Register and enroll ``user1``
-----------------------------

Now that we have the administrator's credentials in a wallet, we can enroll a
new user --- ``user1`` --- which will be used to query and update the ledger:

.. code:: bash

  node registerUser.js

Similar to the admin enrollment, this program uses a CSR to enroll ``user1`` and
store its credentials alongside those of ``admin`` in the wallet. We now have
identities for two separate users --- ``admin`` and ``user1`` --- and these are
used by our application.

Time to interact with the ledger...

Querying the ledger
-------------------

Each peer in a blockchain network hosts a copy of the ledger, and an application
program can query the ledger by invoking a smart contract which queries the most
recent value of the ledger and returns it to the application.

Here is a simplified representation of how a query works:

.. image:: tutorial/write_first_app.diagram.1.png

Applications read data from the `ledger <./ledger/ledger.html>`_ using a query.
The most common queries involve the current values of data in the ledger -- its
`world state <./ledger/ledger.html#world-state>`_. The world state is
represented as a set of key-value pairs, and applications can query data for a
single key or multiple keys. Moreover, the ledger world state can be configured
to use a database like CouchDB which supports complex queries when key-values
are modeled as JSON data. This can be very helpful when looking for all assets
that match certain keywords with particular values; all cars with a particular
owner, for example.

First, let's run our ``query.js`` program to return a listing of all the cars on
the ledger. This program uses our second identity -- ``user1`` -- to access the
ledger:

.. code:: bash

  node query.js

The output should look like this:

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

Let's take a closer look at this program. Use an editor (e.g. atom or visual
studio) and open ``query.js``.

The application starts by bringing in scope two key classes from the
``fabric-network`` module; ``FileSystemWallet`` and ``Gateway``. These classes
will be used to locate the ``user1`` identity in the wallet, and use it to
connect to the network:

.. code:: bash

  const { FileSystemWallet, Gateway } = require('fabric-network');

The application connects to the network using a gateway:

.. code:: bash

  const gateway = new Gateway();
  await gateway.connect(ccp, { wallet, identity: 'user1' });

This code creates a new gateway and then uses it to connect the application to
the network. ``ccp`` describes the network that the gateway will access with the
identity ``user1`` from ``wallet``. See how the ``ccp`` has been loaded from
``../../basic-network/connection.json`` and parsed as a JSON file:

.. code:: bash

  const ccpPath = path.resolve(__dirname, '..', '..', 'basic-network', 'connection.json');
  const ccpJSON = fs.readFileSync(ccpPath, 'utf8');
  const ccp = JSON.parse(ccpJSON);

If you'd like to understand more about the structure of a connection profile,
and how it defines the network, check out
`the connection profile topic <./developapps/connectionprofile.html>`_. 

A network can be divided into multiple channels, and the next important line of
code connects the application to a particular channel within the network,
``mychannel``:

.. code:: bash
  const network = await gateway.getNetwork('mychannel');

  const network = await gateway.getNetwork('mychannel');

Within this channel, we can access the smart contract ``fabcar`` to interact
with the ledger:

.. code:: bash

  const contract = network.getContract('fabcar');

Within ``fabcar`` there are many different **transactions**, and our application
initially uses the ``queryAllCars`` transaction to access the ledger world state
data:

.. code:: bash

  const result = await contract.evaluateTransaction('queryAllCars');

The ``evaluateTransaction`` method represents one of the simplest interaction
with a smart contract in blockchain network. It simply picks a peer defined in
the connection profile and sends the request to it, where it is evaluated. The
smart contract queries all the cars on the peer's copy of the ledger and returns
the result to the application. This interaction does not result in an update the
ledger.

The FabCar smart contract
-------------------------

Let's take a look at the transactions within the ``FabCar`` smart contract.
Navigate to the ``chaincode/fabcar/javascript/lib`` subdirectory at the root of
``fabric-samples`` and open ``fabcar.js`` in your editor.

See how our smart contract is defined using the ``Contract`` class:

.. code:: bash

  class FabCar extends Contract {...

Within this class structure, you'll see that we have the following
transactions defined: ``initLedger``, ``queryCar``, ``queryAllCars``,
``createCar``, and ``changeCarOwner``. For example:


.. code:: bash

  async queryCar(ctx, carNumber) {...}
  async queryAllCars(ctx) {...}

Let's take a closer look at the ``queryAllCars`` transaction to see how it
interacts with the ledger.

.. code:: bash

  async queryAllCars(ctx) {

    const startKey = 'CAR0';
    const endKey = 'CAR999';

    const iterator = await ctx.stub.getStateByRange(startKey, endKey);


This code defines the range of cars that ``queryAllCars`` will retrieve from the
ledger. Every car between ``CAR0`` and ``CAR999`` -- 1,000 cars in all, assuming
every key has been tagged properly -- will be returned by the query. The
remainder of the code iterates through the query results and packages them into
JSON for the application.

Below is a representation of how an application would call different
transactions in a smart contract. Each transaction uses a broad set of APIs such
as ``getStateByRange`` to interact with the ledger. You can read more about
these APIs in `detail
<https://fabric-shim.github.io/master/index.html?redirect=true>`_.

.. image:: images/RunningtheSample.png

We can see our ``queryAllCars`` transaction, and another called ``createCar``.
We will use this later in the tutorial to update the ledger, and add a new block
to the blockchain.

But first, go back to the ``query`` program and change the
``evaluateTransaction`` request to query ``CAR4``. The ``query`` program should
now look like this:

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

Save the program and navigate back to your ``fabcar/javascript`` directory.
Now run the ``query`` program again:

.. code:: bash

  node query.js

You should see the following:

.. code:: json

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"black","make":"Tesla","model":"S","owner":"Adriana"}

If you go back and look at the result from when the transaction was
``queryAllCars``, you can see that ``CAR4`` was Adriana’s black Tesla model S,
which is the result that was returned here.

We can use the ``queryCar`` transaction to query against any car, using its
key (e.g. ``CAR0``) and get whatever make, model, color, and owner correspond to
that car.

Great. At this point you should be comfortable with the basic query transactions
in the smart contract and the handful of parameters in the query program.

Time to update the ledger...

Updating the ledger
-------------------

Now that we’ve done a few ledger queries and added a bit of code, we’re ready to
update the ledger. There are a lot of potential updates we could make, but
let's start by creating a **new** car.

From an application perspective, updating the ledger is simple. An application
submits a transaction to the blockchain network, and when it has been
validated and committed, the application receives a notification that
the transaction has been successful. Under the covers this involves the process
of **consensus** whereby the different components of the blockchain network work
together to ensure that every proposed update to the ledger is valid and
performed in an agreed and consistent order.

.. image:: tutorial/write_first_app.diagram.2.png

Above, you can see the major components that make this process work. As well as
the multiple peers which each host a copy of the ledger, and optionally a copy
of the smart contract, the network also contains an ordering service. The
ordering service coordinates transactions for a network; it creates blocks
containing transactions in a well-defined sequence originating from all the
different applications connected to the network.

Our first update to the ledger will create a new car. We have a separate program
called ``invoke.js`` that we will use to make updates to the ledger. Just as with
queries, use an editor to open the program and navigate to the code block where
we construct our transaction and submit it to the network:

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

See how the applications calls the smart contract transaction ``createCar`` to
create a black Honda Accord with an owner named Tom. We use ``CAR12`` as the
identifying key here, just to show that we don't need to use sequential keys.

Save it and run the program:

.. code:: bash

  node invoke.js

If the invoke is successful, you will see output like this:

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  2018-12-11T14:11:40.935Z - info: [TransactionEventHandler]: _strategySuccess: strategy success for transaction "9076cd4279a71ecf99665aed0ed3590a25bba040fa6b4dd6d010f42bb26ff5d1"
  Transaction has been submitted

Notice how the ``invoke`` application interacted with the blockchain network
using the ``submitTransaction`` API, rather than ``evaluateTransaction``.

.. code:: bash

  await contract.submitTransaction('createCar', 'CAR12', 'Honda', 'Accord', 'Black', 'Tom');

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

``submitTransaction`` does all this for the application! The process by which
the application, smart contract, peers and ordering service work together to
keep the ledger consistent across the network is called consensus, and it is
explained in detail in this `section <./peers/peers.html>`_.

To see that this transaction has been written to the ledger, go back to
``query.js`` and change the argument from ``CAR4`` to ``CAR12``.

In other words, change this:

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR4');

To this:

.. code:: bash

  const result = await contract.evaluateTransaction('queryCar', 'CAR12');

Save once again, then query:

.. code:: bash

  node query.js

Which should return this:

.. code:: bash

  Wallet path: ...fabric-samples/fabcar/javascript/wallet
  Transaction has been evaluated, result is:
  {"colour":"Black","make":"Honda","model":"Accord","owner":"Tom"}

Congratulations. You’ve created a car and verified that its recorded on the
ledger!

So now that we’ve done that, let’s say that Tom is feeling generous and he
wants to give his Honda Accord to someone named Dave.

To do this, go back to ``invoke.js`` and change the smart contract transaction
from ``createCar`` to ``changeCarOwner`` with a corresponding change in input
arguments:

.. code:: bash

  await contract.submitTransaction('changeCarOwner', 'CAR12', 'Dave');

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
   {"colour":"Black","make":"Honda","model":"Accord","owner":"Dave"}

The ownership of ``CAR12`` has been changed from Tom to Dave.

.. note:: In a real world application the smart contract would likely have some
          access control logic. For example, only certain authorized users may
          create new cars, and only the car owner may transfer the car to
          somebody else.

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

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
