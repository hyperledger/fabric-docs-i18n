编写一个 Fabric 应用
############################

.. note:: 如果你对 Fabric 网络的基本架构还不熟悉，在继续本部分之前，你可能想先阅读 :doc:`key_concepts` 部分。

          本你还应该熟悉Fabric Gateway服务以及它与应用程序交易流程的关系,详细信息可以在 :doc:'gateway' 章节。

本教程介绍了Fabric应用程序与已部署区块链网络的交互方式。本教程使用使用Fabric Gateway客户端API构建的示例程序来调用智能合约,
使用智能合约API查询和更新账本, 详细信息在 :doc:'deploy_chaincode'.

**关于资产转移**

资产转移(基本）样例展示了如何创建，更新和查询资产。它包括下面两个组件：

  1. **示例应用程序** 调用区块链网络，调用智能合约中实现的交易。这个应用位于 'fabric-samples'目录里：
  .. code-block:: text

    asset-transfer-basic/application-gateway-typescript

  2. **智能合约:** 实现了涉及与账本交互的交易。智能合约位于下面''fabric-samples''目录里：
  
  .. code-block:: text

    asset-transfer-basic/chaincode-(typescript, go, java) 

在这个例子里，我们将用 TypeScript 智能合约。

本教程包含两个重要部分：

  1. **搭建链块网络.** 
  我们的应用程序需要和区块链网络交互，所以我们启动基础网络和部署一个智能合约给我们的应用程序使用。

  .. image:: images/AppConceptsOverview.png

  2. **运行实例和智能合约互动.**
  我们的应用将使用assetTransfer智能合约在账本上创建、查询和更新资产。我们将逐步分析应用程序的代码以及它所调用的交易,
  包括创建一些初始资产、查询一个资产、查询一系列资产、创建新资产以及将资产转让给新所有者。

完成本教程后,您应该对Fabric应用程序和智能合约如何协同工作来管理区块链网络的分布式账本数据有基本的理解.

开始之前
================
在你能运行样例应用前，你需要在你的环境里安装 Fabric Sampple. 根据 :doc:'getting_started' 的指令安装必要的软件。

本教程中的样例应用在节点上使用了 Fabric Gateway client API。要获取最新支持的编程语言运行时和依赖项的列表,
请参考 `文档 <https://hyperledger.github.io/fabric-gateway/>`_ 。

- 请确保已安装适当版本的Node。有关安装Node的说明,请参 `Node.js 文档 <https://nodejs.dev/learn/how-to-install-nodejs>`_.

设置区块链网络
-----------------------------
如果你已经学习了 :doc:`test_network` 而且已经运行起来了一个网络，本教程将在启动一个新网络之前关闭正在运行的网络。

启动区块链网络
=============================
在你本地 ''fabric-samples''代码库的本地拷贝里，导航到 ''test-network''子目录。

.. code-block:: bash

  cd fabric-samples/test-network


如果你已经有个测试网络可以运行，请将它关闭以确保环境是干净的。

.. code-block:: bash

  ./network.sh up createChannel -c mychannel -ca


该命令将部署具有两个对等方、一个排序服务和三个证书颁发机构(Orderer、Org1、Org2) 的Fabric测试网络。
与使用cryptogen工具不同.我们使用证书颁发机构来启动测试网络，因此使用了‘-ca'标志。此外，
在启动证书颁发机构时还会初始化组织管理员用户的注册。

部署智能合约
-------------------------
.. note:: 本教程演示了Asset Transfer智能合约和应用程序的TypeScript版本,
          但您可以将TypeScript应用程序示例与任何智能合约语言示例一起使用
          (例如TypeScript应用程序调用Go智能合约函数或TypeScript应用程序调用Java智能合约函数等)。
           要尝试Go或Java版本的智能合约,请将下面的''./network.sh deployCC -ccl typescript''命令中的
           ''typescript''参数更改为''go''或''java'',然后按照终端上的说明进行操作。

接下来，让我们通过调用''./network.sh'' 脚本并提供链码名称和语言选项来部署包含智能合约的链码包。

.. code-block:: bash

  ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript/ -ccl typescript


此脚本使用链码生命周期来打包、安装、查询已安装的链码、为Org1和Org2批准链码,最后提交链码。

如果链码包成功部署，终端输出的末尾应该类似于以下内容：

.. code-block:: text

  Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
  Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
  Query chaincode definition successful on peer0.org2 on channel 'mychannel'
  Chaincode initialization is not required

准备样例应用
------------------------------
现在,让我们准备样本的Asset Transfer 'TypeScript 应用程序<https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-basic/application-gateway-typescript>'_ ,
该应用程序将用于与已部署的智能合约进行交互。

打开一个新的终端，然后导航到''application-gateway-typescript''目录。

.. code-block:: bash

  cd asset-transfer-basic/application-gateway-typescript

该目录包含一个使用Fabric Gateway客户端API for Node开发的示例应用程序。

运行以下命令来安装依赖并构建应用程序。这可能需要一些时间来完成：

.. code:: bash

  npm install


这个过程会安装应用程序在''package.json''中定义的依赖项。其中最重要的是''@hyperledger/fabric-gateway''' Node.js包,
它提供了用于连接到Fabric Gateway并使用特定客户身份提交和评估事务以及接收事件的Fabric Gateway客户端API。

一旦完成 ``npm install`` ，运行应用程序所需要的一切就准备好了。

让我们来看一眼教程中使用的示例 TypeScript 应用文件。运行下面命令，列出所以在此目录的文件：

.. code:: bash

  ls

你会看到下边的文件：

.. code-block:: text

  dist
  node_modules
  package-lock.json
  package.json
  src
  tsconfig.json

''src''目录包含客户端应用程序的源代码。在安装过程中从这些源代码生成的JavaScript输出位于''dist''目录中，可以忽略。

运行样例应用
==========================
在本教程的前面部分,我们启动了Fabric测试网络,使用证书颁发机构创建了几个身份。其中包括每个组织的用户身份。
应用程序将使用这些用户身份中的一个来与区块链网络交互。

让我们运行该应用程序,然后逐步了解与智能合约函数的每次交互。
从''asset-transfer-basic/application-gateway-typescript''目录,运行以下命令:

.. code-block:: bash

  npm start

首先,建立与Gateway的gRPC连接
-------------------------------------------------
客户端应用程序建立了与将用于与区块链网络交互的Fabric Gateway服务的'gRPC <https://grpc.io/>'_连接。
为此,它只需要Fabric Gateway的终端地址,以及如果配置为使用TLS,则需要适当的TLS证书。
在这个示例中,网关终端地址是对等方的地址,它提供了Fabric Gateway服务。

.. note:: 建立gRPC连接涉及到相当大的开销,因此应用程序应该保留这个连接,并用它来进行与Fabric Gateway的所有交互。

.. warning:: 为了保护交易中使用的任何私有数据的安全,应用程序应连接到与客户身份所属组织相同的Fabric Gateway。
             如果客户身份所属的组织不托管任何网关,则应使用另一个组织的受信任网关。

TypeScript应用程序使用签名证书颁发机构的TLS证书来创建gRPC连接,以便验证网关的TLS证书的真实性。

为了成功建立TLS连接,客户端使用的终端地址必须与网关的TLS证书中的地址匹配。由于客户端访问网关的Docker容器时使用的是'localhost'地址,
因此需要指定一个gRPC选项,强制将此终端地址解释为网关的配置主机名。

.. code-block:: TypeScript

  const peerEndpoint = 'localhost:7051';

  async function newGrpcConnection(): Promise<grpc.Client> {
      const tlsRootCert = await fs.readFile(tlsCertPath);
      const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
      return new grpc.Client(peerEndpoint, tlsCredentials, {
          'grpc.ssl_target_name_override': 'peer0.org1.example.com',
      });
  }


其次,创建Gateway连接
-----------------------------------
然后,应用程序创建一个''Gateway''连接,用于访问Fabric Gateway可访问的任何''Networks''(类似于通道),
以及随后在这些网络上部署的智能'Contracts'。''Gateway''连接具有三个要求:

  1. 与Fabric Gateway的gRPC连接。
  2. 用于与网络交互的客户身份。
  3. 用于为客户身份生成数字签名的签名实现。
示例应用程序使用Org1用户的X.509证书作为客户身份，以及基于该用户的私钥的签名实现。

.. code-block:: TypeScript

  const client = await newGrpcConnection();

  const gateway = connect({
      client,
      identity: await newIdentity(),
      signer: await newSigner(),
  });

  async function newIdentity(): Promise<Identity> {
      const credentials = await fs.readFile(certPath);
      return { mspId: 'Org1MSP', credentials };
  }

  async function newSigner(): Promise<Signer> {
      const privateKeyPem = await fs.readFile(keyPath);
      const privateKey = crypto.createPrivateKey(privateKeyPem);
      return signers.newPrivateKeySigner(privateKey);
  }


第三，访问要调用的智能合约
----------------------------------------------
示例应用程序使用''Gateway''连接获取对''Network''的引用,然后获取该网络上部署的默认''Contract''。

.. code-block:: TypeScript

  const network = gateway.getNetwork(channelName);
  const contract = network.getContract(chaincodeName);

当一个链码包包括多个智能合约时,可以将链码的名称和特定智能合约的名称作为
'getContract() <https://hyperledger.github.io/fabric-gateway/main/api/node/interfaces/Network.html#getContract>`_的参数传递。
例如：

.. code-block:: TypeScript

  const contract = network.getContract(chaincodeName, smartContractName);


第四，使用样本资产填充账本
在初始部署链码包之后,账本是空的。应用程序使用''submitTransaction()''来调用''InitLedger''事务函数,
该函数将账本填充了一些样本资产。''submitTransaction()''将使用Fabric Gateway来执行以下操作:

 1. 对事务提案进行背书。
 2. 将已背书的事务提交到订购服务。
 3. 等待事务提交，更新账本状态。

示例应用程序的''InitLedger''调用如下：

. code-block:: TypeScript

  await contract.submitTransaction('InitLedger');


第五，调用事务函数以读取和写入资产
------------------------------------------------------------
现在应用程序已准备好执行业务逻辑，通过调用智能合约上的事务函数来查询、创建额外资产以及修改账本上的资产。

查询所有资产
~~~~~~~~~~~~~~~~
应用程序使用``evaluateTransaction()``通过执行只读事务调用来查询账本。``evaluateTransaction()``
将使用Fabric Gateway来调用事务函数并返回其结果。该事务不会被发送到订购服务,也不会导致账本更新。

以下是示例应用程序获取在之前的步骤中我们填充账本时创建的所有资产。

示例应用程序的``GetAllAssets``调用如下：

.. code-block:: TypeScript

  const resultBytes = await contract.evaluateTransaction('GetAllAssets');

  const resultJson = utf8Decoder.decode(resultBytes);
  const result = JSON.parse(resultJson);
  console.log('*** Result:', result);


**note:** 事务函数的结果始终以字节返回,因为事务函数可以返回任何类型的数据。
          通常,事务函数返回字符串;或者在上面的情况下,返回JSON数据的UTF-8编码字符串。
          应用程序有责任正确解析结果字节。

终端输出应该看起来如此：

.. code-block:: text

  *** Result: [
    {
      AppraisedValue: 300,
      Color: 'blue',
      ID: 'asset1',
      Owner: 'Tomoko',
      Size: 5,
      docType: 'asset'
    },
    {
      AppraisedValue: 400,
      Color: 'red',
      ID: 'asset2',
      Owner: 'Brad',
      Size: 5,
      docType: 'asset'
    },
    {
      AppraisedValue: 500,
      Color: 'green',
      ID: 'asset3',
      Owner: 'Jin Soo',
      Size: 10,
      docType: 'asset'
    },
    {
      AppraisedValue: 600,
      Color: 'yellow',
      ID: 'asset4',
      Owner: 'Max',
      Size: 10,
      docType: 'asset'
    },
    {
      AppraisedValue: 700,
      Color: 'black',
      ID: 'asset5',
      Owner: 'Adriana',
      Size: 15,
      docType: 'asset'
    },
    {
      AppraisedValue: 800,
      Color: 'white',
      ID: 'asset6',
      Owner: 'Michel',
      Size: 15,
      docType: 'asset'
    }
  ]

创建新资产
~~~~~~~~~~~~~~~~~~
示例应用程序提交一个事务来创建新资产

示例应用程序的``CreateAsset``调用如下：

.. code-block:: TypeScript

  const assetId = `asset${Date.now()}`;

  await contract.submitTransaction(
      'CreateAsset',
      assetId,
      'yellow',
      '5',
      'Tom',
      '1300',
  );


**note:** 在上面的应用程序片段中，重要的是要注意，``CreateAsset``事务使用与链码期望的相同类型和数量的参数以及正确的顺序进行提交。
           在这种情况下，正确排序的参数如下：

          .. code-block:: text
          
            assetId, "yellow", "5", "Tom", "1300"
          
          相应的智能合约的``CreateAsset``事务函数期望以下顺序的参数来定义资产对象:
          
          .. code-block:: text

            ID, Color, Size, Owner, AppraisedValue


更新资产
~~~~~~~~~~~~~~~
示例应用程序提交一个事务来转移新创建资产的所有权。这次，使用``submitAsync()``调用事务，
该调用在成功提交已背书的事务给订购服务后返回，而不是等待事务提交到账本。这允许应用程序在等待事务提交时使用事务结果执行工作。

示例应用程序的``TransferAsset``调用如下：

.. code-block:: TypeScript

  const commit = await contract.submitAsync('TransferAsset', {
      arguments: [assetId, 'Saptha'],
  });
  const oldOwner = utf8Decoder.decode(commit.getResult());

  console.log(`*** Successfully submitted transaction to transfer ownership from ${oldOwner} to Saptha`);
  console.log('*** Waiting for transaction commit');

  const status = await commit.getStatus();
  if (!status.successful) {
      throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${status.code}`);
  }

  console.log('*** Transaction committed successfully');


终端输出：

.. code-block:: text

  *** Successfully submitted transaction to transfer ownership from Tom to Saptha
  *** Waiting for transaction commit
  *** Transaction committed successfully

查询更新后的资产
~~~~~~~~~~~~~~~~~~~~~~~
示例应用程序然后评估了已转移资产的查询，显示它是如何根据描述创建的，然后随后转移到新所有者。

示例应用程序的''ReadAsset''调用如下:

.. code-block:: TypeScript

  const resultBytes = await contract.evaluateTransaction('ReadAsset', assetId);

  const resultJson = utf8Decoder.decode(resultBytes);
  const result = JSON.parse(resultJson);
  console.log('*** Result:', result);

终端输出：

.. code-block:: text

  *** Result: {
      AppraisedValue: 1300,
      Color: 'yellow',
      ID: 'asset1639084597466',
      Owner: 'Saptha',
      Size: 5
  }



处理事务错误
~~~~~~~~~~~~~~~~~~~~~~~~~
序列的最后部分演示了提交事务时发生错误。在这个示例中，应用程序尝试提交一个``UpdateAsset``事务,
但指定了一个不存在的资产ID。事务函数返回错误响应,``submitTransaction()``调用失败。

``submitTransaction()``的失败可能会生成多种不同类型的错误，指示错误发生在提交流程的哪个点，
并包含附加信息以使应用程序能够适当地响应。请参考`API文档<https://hyperledger.github.io/fabric-gateway/main/api/node/interfaces/Contract.html#submitTransaction>`_
以获取可能生成的不同错误类型的详细信息。

示例应用程序中失败的``UpdateAsset``调用如下：

.. code-block:: TypeScript

  try {
      await contract.submitTransaction(
          'UpdateAsset',
          'asset70',
          'blue',
          '5',
          'Tomoko',
          '300',
      );
      console.log('******** FAILED to return an error');
  } catch (error) {
      console.log('*** Successfully caught the error: \n', error);
  }

终端输出（为了清晰起见，已删除堆栈跟踪）：

.. code-block:: text

  *** Successfully caught the error: 
  EndorseError: 10 ABORTED: failed to endorse transaction, see attached details for more info
      at ... {
    code: 10,
    details: [
      {
        address: 'peer0.org1.example.com:7051',
        message: 'error in simulation: transaction returned with failure: Error: The asset asset70 does not exist',
        mspId: 'Org1MSP'
      }
    ],
    cause: Error: 10 ABORTED: failed to endorse transaction, see attached details for more info
        at ... {
      code: 10,
      details: 'failed to endorse transaction, see attached details for more info',
      metadata: Metadata { internalRepr: [Map], options: {} }
    },
    transactionId: 'a92980d41eef1d6492d63acd5fbb6ef1db0f53252330ad28e548fedfdb9167fe'
  }
''EndorseError''类型表示在认可过程中发生了故障,而''ABORTED''' gRPC状态代码_ 表示应用程序成功调用了Fabric Gateway,
但在认可过程中发生了故障。''UNAVAILABLE''或''DEADLINE_EXCEEDED'' gRPC状态代码可能表明Fabric Gateway不可访问或未及时收到响应,因此可能需要重试该操作。

清理
========
当您完成使用资产转移示例后，可以使用''network.sh'' 脚本关闭测试网络：
.. code-block:: bash

  ./network.sh down


该命令将关闭我们创建的区块链网络的证书颁发机构、对等节点和排序节点。
请注意，将丢失帐本上的所有数据。如果您想再次运行教程，您将从干净的初始状态开始。

总结
=======
您已经学会了如何通过启动测试网络和部署智能合约来建立区块链网络。然后,
您运行了一个客户端应用程序,并检查了应用程序代码,以了解它如何使用Fabric Gateway
客户端API连接到Fabric Gateway并调用已部署的智能合约的事务功能来查询和更新帐本。
这个教程为您提供了与Hyperledger Fabric一起工作的亲身体验。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
