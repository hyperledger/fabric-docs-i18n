
使用 CouchDB
=============

本教程将讲述使用CouchDB作为Hyperledger Fabric的状态数据库的步骤。到目前为止，您应该已经熟悉Fabric的概念并且动手实践了一些示例和教程。

.. note::  这个教程使用了Fabric v2.0版本中引入的新链码生命周期。
          如果您想要使用以前版本的生命周期模型来操作链码的索引功能，
          访问 v1.4 版本的 `使用 CouchDB <https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html>`__ .

本教程将带您按如下步骤学习：

#. :ref:`cdb-enable-couch`
#. :ref:`cdb-create-index`
#. :ref:`cdb-add-index`
#. :ref:`cdb-install-deploy`
#. :ref:`cdb-query`
#. :ref:`cdb-best`
#. :ref:`cdb-pagination`
#. :ref:`cdb-update-index`
#. :ref:`cdb-delete-index`

想要更深入的研究 CouchDB，请参阅 :doc:`couchdb_as_state_database` ，关于 Fabric 账本的更多信息请参阅 `Ledger <ledger/ledger.html>`_ 主题。
下边的教程将详细讲述如何在您的区块链网络中使用 CouchDB 。

本教程将使用 `Asset transfer ledger queries sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-ledger-queries/chaincode-go>`__ 
作为例子，演示如何在 Fabric 中使用 CouchDB，包括针对状态数据库执行JSON查询。
开始之前，您应该已经完成了任务 :doc:`install`。

为什么使用 CouchDB ？
~~~~~~~~~~~~

Fabric 支持两种类型的节点状态数据库。LevelDB 是默认嵌入在 peer 节点的状态数据库。
LevelDB 将链码数据存为简单的键值对，仅支持键、键范围和复合键查询。
CouchDB 是一个可选的、可替换的状态数据库，支持将账本的数据转为 JSON 格式，并数据内容的富查询，而不仅仅是基于 key 的查询。
CouchDB 同样支持在链码中部署索引，以实现高效查询和对大数据集的查询。

为了发挥 CouchDB 的优势，即基于内容的 JSON 查询，您的数据必须以 JSON 格式存储。
在设置网络之前，必须确定使用 LevelDB 还是 CouchDB 。由于数据兼容性的问题，暂不支持节点从 LevelDB 切换为 CouchDB 。
网络中的所有节点必须使用相同的数据库类型。
如果您想将 JSON 和二进制数据混合使用，同样可以使用 CouchDB ，但只能基于键、键范围和复合键来查询二进制数据。

.. _cdb-enable-couch:

在 Hyperledger Fabric 中启用 CouchDB
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CouchDB 是独立于节点运行的一个数据库进程。在安装、管理和操作的时候需要另加考虑。可以用 CouchDB 的 Docker 镜像 `CouchDB <https://hub.docker.com/_/couchdb/>`__
，并且我们建议将它和节点运行在同一服务器上。您需要为每个节点设置一个 CouchDB 容器，并且更新每个节点上的配置文件 ``core.yaml`` ，将节点指向 CouchDB 容器。
core.yaml 文件的路径必须位于环境变量 FABRIC_CFG_PATH 指定的目录中：

* 对于 Docker 的部署，``core.yaml`` 已经预先配置好，位于节点容器的 ``FABRIC_CFG_PATH`` 指定的文件夹中 。然而，当使用Docker环境时，您也可以通过传递环境变量来覆盖core.yaml 的属性，例如通过 ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS`` 来设置CouchDB地址。

* 对于原生的二进制部署， ``core.yaml`` 包含在发布的构件中。

编辑 ``core.yaml`` 中的 ``stateDatabase`` 部分。将 ``stateDatabase`` 指定为 ``CouchDB`` ，并且填写 ``couchDBConfig`` 相关的配置。更多细节，请参阅
`CouchDB 配置 <couchdb_as_state_database.html#couchdb-configuration>`__ 。

.. _cdb-create-index:

创建索引
~~~~~~~~~~~~~~~

为什么索引很重要？

有了索引，在查询数据库时，不用每次都检索每一行，从而使数据库运行得更快、更高效。
一般来说，针对频繁查询的条件进行索引，可以使数据查询更高效。为了充分利用 CouchDB 的优势（支持对 JSON 数据的富查询）， 并不需要索引，
但是为了性能考虑强烈建议创建索引。另外，如果在查询中需要排序，CouchDB 需要在排序的字段上加一个索引。

.. note::

   没有索引的情况下 JSON 查询也可以执行，但在 peer 日志中会抛出一个没有找到索引的警告。如果一个富查询中包含了一个排序规范，则要求该排序字段
   必须有索引；否则，查询操作执行失败并抛出异常。


为了演示如何创建索引，我们使用 `Asset transfer ledger queries sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-ledger-queries/chaincode-go/asset_transfer_ledger_chaincode.go>`__ 中的数据。
在这个例子中， Asset 的数据结构定义如下：

.. code:: javascript

    type Asset struct {
            DocType        string `json:"docType"` //docType is used to distinguish the various types of objects in state database
            ID             string `json:"ID"`      //the field tags are needed to keep case from bouncing around
            Color          string `json:"color"`
            Size           int    `json:"size"`
            Owner          string `json:"owner"`
            AppraisedValue int    `json:"appraisedValue"`
    }

在此结构中，属性（ ``docType``, ``ID``, ``color``, ``size``, ``owner``, ``appraisedValue`` ）定义了和资产相关的账本数据。
属性 ``docType`` 可以在 chaincode 中使用，以区分链码命名空间中需要单独查询的不同数据类型。
使用 CouchDB 时，每个 chaincode 都有自己的 CouchDB 数据库，也就是说，每个 chaincode 都有自己的键的命名空间。

在 Asset 数据结构中， ``docType`` 用来标识该 JSON 文档代表资产。
在链码命名空间中可能存在其他 JSON 文档。CouchDB JSON 查询可以检索任意 JSON 字段。

在定义用于链码查询的索引时，每个索引都必须在文本文件中定义，按照 CouchDB 索引的 JSON 格式，文件扩展名为 *.json 格式。

需要以下三条信息来定义一个索引：

  * `fields`: 查询的字段
  * `name`: 索引名
  * `type`: 格式是 json

例如，以下是对字段 ``foo`` 构建的名为 ``foo-index`` 索引。

.. code:: json

    {
        "index": {
            "fields": ["foo"]
        },
        "name" : "foo-index",
        "type" : "json"
    }

可以把设计文档（ design document ）属性 ``ddoc`` 写在索引的定义中。`design document <http://guide.couchdb.org/draft/design.html>`__ 是旨在包含索引的 CouchDB 结构。为了提高效率，索引可以分组写到设计文档中，但 CouchDB 建议每个设计文档只包含一个索引。

.. tip:: 定义索引时，最好将 ``ddoc`` 属性和值与索引名称包含在一起。
        包含这个属性非常重要，可以确保后期根据需要更新索引。它还能便于显示指定在查询中使用的索引。

以下是以“资产转移账本查询”为例，定义的另一种索引方式，索引名称为 ``indexOwner``，使用多个字段 ``docType`` 和 ``owner`` ，并且包括 ``ddoc`` 属性：

.. _indexExample:

.. code:: json

  {
    "index":{
        "fields":["docType","owner"] // Names of the fields to be queried
    },
    "ddoc":"indexOwnerDoc", // (optional) Name of the design document in which the index will be created.
    "name":"indexOwner",
    "type":"json"
  }

在上边的例子中，如果未指定设计文档 ``indexOwnerDoc`` ，则在部署索引时会自动创建。
可以根据字段列表中指定的一个或多个属性，或指定属性的任意组合，来构建索引。
一个属性可以存在于同一个 docType 的多个索引中。
在下边的例子中， ``index1``只包含 ``owner`` 属性， ``index2`` 包含 ``owner 和 color`` 属性， 
``index3`` 包含``owner``、 ``color`` 和 ``size`` 属性。
另外，遵循 CouchDB 推荐的规范，每个索引的定义都有自己的 ``ddoc`` 值。

.. code:: json

  {
    "index":{
        "fields":["owner"] // Names of the fields to be queried
    },
    "ddoc":"index1Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index1",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner", "color"] // Names of the fields to be queried
    },
    "ddoc":"index2Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index2",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner", "color", "size"] // Names of the fields to be queried
    },
    "ddoc":"index3Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index3",
    "type":"json"
  }

一般来说，您应该为索引字段建模，以匹配在查询过滤器和排序中可能会使用的字段。
关于以 JSON 格式构建索引的更多信息，请参阅 `CouchDB documentation <http://docs.couchdb.org/en/latest/api/database/find.html#db-index>`__ 。

.. _cdb-add-index:


将索引添加到链码文件夹
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

构建索引之后，把它放到到适当的元数据文件夹下，将其与 chaincode 一起打包部署。您可以使用 :doc:`commands/peerlifecycle` 命令打包并安装 chaincode。JSON 索引文件必须放在链码目录的 ``META-INF/statedb/couchdb/indexes`` 路径下。

下边的 `Asset transfer ledger queries sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/asset-transfer-ledger-queries/chaincode-go>`__ 展示了索引是如何与 chaincode 一起打包。

.. image:: images/couchdb_tutorial_pkg_example.png
  :scale: 100%
  :align: center
  :alt: Marbles Chaincode Index Package

这个例子包含了一个名为 indexOwnerDoc 的索引，以支持资产所有者的查询:

.. code:: json

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}


启动网络
-----------------

:guilabel:`Try it yourself`


我们将启动 Fabric 测试网络，并使用它来部署资产转移账本查询的 chaincode。
使用下面的命令定位到 Fabric samples 中的目录 `test-network` ：

.. code:: bash

    cd fabric-samples/test-network


对于这个教程，我们希望从一个已知的初始状态开始操作。
下面的命令会删除还在运行的或历史的 docker 容器，并且清除之前生成的构件：

.. code:: bash

    ./network.sh down

如果您之前从没运行过这个教程，则需要先安装链码的依赖项，才能将其部署到网络。
运行以下命令：

.. code:: bash

    cd ../asset-transfer-ledger-queries/chaincode-go
    GO111MODULE=on go mod vendor
    cd ../../test-network

在 `test-network` 目录中，使用以下命令部署带有 CouchDB 的测试网络：

.. code:: bash

    ./network.sh up createChannel -s couchdb

运行这个命令会创建两个 fabric peer 节点，都使用 CouchDB 作为状态数据库。
同时也会创建一个排序节点和一个名为 ``mychannel`` 的通道。

.. _cdb-install-deploy:

部署智能合约
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

可以使用测试网络脚本，将资产转移查询的智能合约部署到以上的通道。运行以下命令将智能合约部署到 ``mychannel`` ：

.. code:: bash

  ./network.sh deployCC -ccn ledger -ccp ../asset-transfer-ledger-queries/chaincode-go/ -ccl go -ccep "OR('Org1MSP.peer','Org2MSP.peer')"

请注意，我们使用“-ccep”标志来部署智能合约，它的背书策略是`“OR（'Org1MSP.ppeer'，'Org2MSP.ppeer'）”`。这允许一个组织可以在没有得到另一个组织背书的情况下，创建资产。


验证部署的索引
-------------------------

将 chaincde 安装到节点并部署在通道上，索引就会被部署到每个对等节点的 CouchDB 状态数据库上。
可以通过检查 Docker 容器中的节点日志来验证 CouchDB 索引是否已创建成功。

:guilabel:`Try it yourself`

 为了查看节点上 Docker 容器的日志，请打开一个新的终端窗口，然后运行下边的命令，并过滤日志，用于确认索引已被创建。

::

   docker logs peer0.org1.example.com  2>&1 | grep "CouchDB index"


您将会看到类似下边的结果：

::

   [couchdb] createIndex -> INFO 072 Created CouchDB index [indexOwner] in state database [mychannel_ledger] using design document [_design/indexOwnerDoc]


.. _cdb-query:

查询 CouchDB 状态数据库
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

已经在 JSON 文件中定义索引，并且和 chaincode 一并部署了，可以调用 chaincode 函数对 CouchDB 状态数据库执行 JSON 查询。

在查询的时候指定索引名称是可选的。如果不指定，被查询的字段已经设定了索引，则自动使用已有的索引。

.. tip:: 在查询的时候使用 ``use_index`` 关键字，显示包含索引名字是一个好习惯。
          如果未指定使用索引名，CouchDB 可能会选择使用不太理想的索引。
          有时候 CouchDB 也可能根本不使用索引，这在测试期间且数据少的情况下，你很难意识到。
          只有在数据量大的时候，你才可能发现性能较低，因为 CouchDB 根本没有使用索引。


在 chaincode 中构建查询
----------------------------

您可以使用 chaincode 中定义的查询方法，对账本上的数据执行 JSON 查询。 `Asset transfer ledger queries sample
<https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-ledger-queries/chaincode-go/asset_transfer_ledger_chaincode.go>`__ 中包含了两个 JSON 查询方法：

  * **QueryAssets** --

      **即席 JSON 查询** 示例。这种查询方式，可以将一个选择器 JSON 查询字符串传递到函数中。
      这类查询方式，对于需要在运行时动态创建自己的查询的客户端应用程序非常有用。
      更多关于选择器的信息请参考 `CouchDB selector syntax <http://docs.couchdb.org/en/latest/api/database/find.html#find-selectors>`__ 。

  * **QueryAssetsByOwner** --

      **参数化查询** 示例，查询逻辑已在链码中定义，但允许传入查询参数。
      这类查询方式，函数接受单个查询参数，即资产所有者。    
      然后使用 JSON 查询语法，查询状态数据库中与 “asset” 的 docType 和拥有者 id 相匹配的 JSON 文档。


使用 peer 命令运行查询
------------------------------------

如果没有客户端程序，我们可以使用 peer 命令来测试链码中定义的查询函数。我们将执行 `peer chaincode query <commands/peerchaincode.html?%20chaincode%20query#peer-chaincode-query>`__ 命令，调用 ``QueryAssets`` 函数，并使用 Assets 的 ``indexOwner`` 索引，查询拥有者是 "tom" 的所有资产。

:guilabel:`Try it yourself`

在查询数据库之前，我们先添加些数据。以 Org1 的身份运行下面的命令，创建一个拥有者是 "tom" 的资产：

.. code:: bash

    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset1","blue","5","tom","35"]}'

之后，查询所有属于 tom 的资产

.. code:: bash

   // Rich Query with index name explicitly specified:
   peer chaincode query -C mychannel -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}"]}'

详细看一下上边的查询命令，有3个参数值得注意：

*  ``QueryAssets``

  Assets 链码中的函数名称。 正如下面的链码函数中看到的， QueryAssets() 调用``getQueryResultForQueryString()``，然后将 queryString 传递给 getQueryResult() shim API, 该 API 对状态数据库执行 JSON 查询。


.. code:: bash

    func (t *SimpleChaincode) QueryAssets(ctx contractapi.TransactionContextInterface, queryString string) ([]*Asset, error) {
            return getQueryResultForQueryString(ctx, queryString)
    }

*  ``{"selector":{"docType":"asset","owner":"tom"}``

  这是一个 **ad hoc 选择器** 字符串的示例，用来查找所有 ``owner`` 属性值为 ``tom``  的 ``asset`` 的文档。

*  ``"use_index":["_design/indexOwnerDoc", "indexOwner"]``

  指定设计文档名 ``indexOwnerDoc`` 和索引名 ``indexOwner`` 。在这个示例中，查询选择器通过指定 ``use_index`` 关键字显式包含了索引名。
  回顾一下上边的索引定义 :ref:`cdb-create-index` ，它包含一个设计文档 ``"ddoc":"indexOwnerDoc"`` 。
  在 CouchDB 中，如果您想在查询中显式包含索引名，则在索引定义中必须包含 ``ddoc`` 值，然后它才可以被 ``use_index`` 关键字引用。


利用索引的查询成功后返回如下结果：

.. code:: json

  [{"docType":"asset","ID":"asset1","color":"blue","size":5,"owner":"tom","appraisedValue":35}]


.. _cdb-best:

使用查询和索引的最佳实践
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果使用索引，查询的速度会更快，而不必扫描 CouchDB 中的所有数据。 理解索引的机制，可以帮助您编写更高性能的查询语句，并帮助应用程序处理更多的数据量。

规划使用链码安装的索引也很重要。应该为每个 chaincode 只创建少数几个索引，用来支持大多数的查询。添加过多的索引或在索引中使用过多的字段，会降低网络性能。这是每提交一个区块，都会自动更新索引。

本章节的案例有助于演示查询该如何使用索引、什么类型的查询拥有最好的性能。编写查询时请记住下面几点：

* 要查询的索引字段，必须包含在查询的选择器中或排序部分。
* 越复杂的查询性能越低，并且使用索引的几率也越低。
* 您应该尽量避免会引起全表查询或全索引查询的操作符，比如： ``$or``, ``$in`` and ``$regex`` 。

在教程的前面章节，您已经对 assets 链码执行了下面的查询：

.. code:: bash

  // Example one: query fully supported by the index
  export CHANNEL_NAME=mychannel
  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

已经为 asset 转移查询链码创建了 ``indexOwnerDoc`` 索引：

.. code:: json

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

注意，查询中的字段 ``docType`` 和 ``owner`` 都已包含在索引中，这使得该查询成为一个完全受支持的查询。
因此这个查询能使用索引中的数据，不需要搜索整个数据库。像这样的完全支持查询比链码中的其他查询返回得更快。

如果在上述查询中添加了额外的字段，它仍会使用索引。但是，该查询必须扫描数据库以查找额外字段，从而导致响应时间更长。
下面例子中的查询仍然使用索引，但是查询的返回时间比前面的更长。

.. code:: bash

  // Example two: query fully supported by the index with additional data
  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\",\"color\":\"blue\"}, \"use_index\":[\"/indexOwnerDoc\", \"indexOwner\"]}"]}'

如果查询不包含索引中的所有字段，则查询会扫描整个数据库。例如，下面的查询搜索所有者 owner，但没有指定该项拥有的类型。
由于索引 ownerIndexDoc 包含两个字段 ``owner`` 和 ``docType`` ，所以该查询不会使用索引。

.. code:: bash

  // Example three: query not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

一般来说，越复杂的查询返回的时间就越长，并且使用索引的概率也越低。 ``$or``, ``$in`` 和 ``$regex`` 等运算符通常会使得查询搜索整个索引，或者根本不使用索引。

举个例子，下面的查询包含了 ``$or`` 运算符，使得查询会搜索 tom 拥有的每个资产及每个项目。

.. code:: bash

  // Example four: query with $or supported by the index
  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"$or\":[{\"docType\":\"asset\"},{\"owner\":\"tom\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

这个查询仍然会使用索引，因为它查找的字段都包含在索引 ``indexOwnerDoc`` 中。
然而查询中的条件 ``$or`` 需要扫描索引中的所有项，导致响应时间变长。 

下面是索引不支持的复杂查询的一个例子。

.. code:: bash

  // Example five: Query with $or not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssets", "{\"selector\":{\"$or\":[{\"docType\":\"asset\",\"owner\":\"tom\"},{\"color\":\"yellow\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

这个查询搜索 tom 拥有的所有资产，或颜色是黄色的其他项目。 这个查询不会使用索引，因为它需要查找整个表来匹配条件 ``$or``。
根据账本的数据量，这个查询需要很久才会响应，也可能超时。

虽然遵循查询的最佳实践非常重要，但是使用索引不是查询大量数据的解决方案。区块链的数据结构为验证和确认交易做了优化，但不适合数据分析或报告。
如果您想要构建一个仪表盘（ dashboard ）作为应用程序的一部分或分析来自网络的数据，最佳实践是复制一个 peer 节点的账本转存为离线数据库，查询这个离线数据库。
这样可以了解区块链上的数据，并且不会降低区块链网络的性能或中断交易。

可以使用应用程序的区块或链码事件，将交易数据写入一个链下链数据库或分析引擎。
对于接收到的每一个区块，区块监听应用将遍历区块中的每一个交易，并根据每一个有效交易的 ``读写集`` 中的键/值对构建一个数据存储。
文档 :doc:`peer_event_services` 提供了可重放事件，以确保链下数据存储的完整性。
有关如何使用事件监听器将数据写入外部数据库的例子，
访问 Fabric Samples 的 `Off chain data sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/off_chain_data>`__

.. _cdb-pagination:

在 CouchDB 状态数据库查询中使用分页
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当 CouchDB 查询返回结果的数据量很大时，可以通过链代码调用一组 API 对结果列表进行分页。
分页提供了一个将结果集分区的机制，该机制指定了一个 ``pagesize`` 和起始点（一个从结果集合的哪里开始的 ``bookmark`` ）。
客户端应用程序以迭代的方式调用链码来执行查询，直到没有更多的结果返回。更多信息请参考 `topic on pagination with CouchDB <couchdb_as_state_database.html#couchdb-pagination>`__ 。

我们将使用 `Asset transfer ledger queries sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-ledger-queries/chaincode-go/asset_transfer_ledger_chaincode.go>`__
中的函数 ``QueryAssetsWithPagination`` 来演示在链码和客户端应用程序中如何使用分页。

* **QueryAssetsWithPagination** --

    一个 **使用分页的 ad hoc JSON 查询** 的示例。跟上边的示例一样，这个查询可以将一个选择器字符串传入函数。
    在这个示例中， ``pageSize`` 和 ``bookmark`` 都包含在查询中。

为了演示分页，需要更多的数据。本例假设已经按照上面的样例添加了 asset1。
在节点的容器中，运行以下命令创建另外四个 “tom” 拥有的资产，这样 “tom” 共拥有五项资产：

:guilabel:`Try it yourself`

.. code:: bash

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset2","yellow","5","tom","35"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset3","green","6","tom","20"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset4","purple","7","tom","20"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n ledger -c '{"Args":["CreateAsset","asset5","blue","8","tom","40"]}'

除了上边示例中的查询参数， QueryAssetsWithPagination 增加了 ``pagesize`` 和 ``bookmark`` 。
``PageSize`` 指定了每次查询返回结果的数量。 ``bookmark`` 是一个“锚（anchor）”，用来告诉 CouchDB 当前页从哪开始。
（结果的每一页都返回一个唯一的书签）

*  ``QueryAssetsWithPagination``

   正如下面的链码函数中所示，QueryAssetsWithPagination() 调用 ``getQueryResultForQueryStringWithPagination()`` 函数，将 queryString 、bookmark 和 pagesize 传递给 ``GetQueryResultWithPagination()`` shim API，该 API 对状态数据库执行分页的 JSON 查询。。

.. code:: bash

    func (t *SimpleChaincode) QueryAssetsWithPagination(
            ctx contractapi.TransactionContextInterface,
            queryString,
            pageSize int,
            bookmark string) (*PaginatedQueryResult, error) {

            return getQueryResultForQueryStringWithPagination(ctx, queryString, int32(pageSize), bookmark)
    }


下边是一个以 peer 命令调用 QueryAssetsWithPagination 的例子， pageSize 为 ``3`` ，未指定 boomark 。

.. tip:: 当没有指定 bookmark 的时候，查询从记录的 “第一” 页开始。

:guilabel:`Try it yourself`

.. code:: bash

  // Rich Query with index name explicitly specified and a page size of 3:
  peer chaincode query -C mychannel -n ledger -c '{"Args":["QueryAssetsWithPagination", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3",""]}'

下边是接收到的响应（为清楚起见，增加了换行），返回了5个资产中的3个，因为 ``pagesize`` 设置成了 ``3`` 。

.. code:: bash

  {
    "records":[
      {"docType":"asset","ID":"asset1","color":"blue","size":5,"owner":"tom","appraisedValue":35},
      {"docType":"asset","ID":"asset2","color":"yellow","size":5,"owner":"tom","appraisedValue":35},
      {"docType":"asset","ID":"asset3","color":"green","size":6,"owner":"tom","appraisedValue":20}],
    "fetchedRecordsCount":3,
    "bookmark":"g1AAAABJeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzJRYXp5YYg2Q5YLI5IPUgSVawJIjFXJKfm5UFANozE8s"
  }


.. note::  Bookmark 是由 CouchDB 为每个查询唯一生成的，代表结果集中的占位符。将返回的 bookmark 传递给后续迭代的查询中，以检索下一组结果。

下边是在 peer 节点上调用 QueryAssetsWithPagination 的命令，其中 pageSize 为 ``3`` 。
注意，这次的查询包含了上次查询返回的 bookmark 。

:guilabel:`Try it yourself`

.. code:: bash

  peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssetsWithPagination", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABJeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzJRYXp5YYg2Q5YLI5IPUgSVawJIjFXJKfm5UFANozE8s"]}'

下边是接收到的响应（为清楚起见，增加了换行），返回了5个资产中的3个，返回了剩下的2个记录：

.. code:: bash

  {
    "records":[
      {"docType":"asset","ID":"asset4","color":"purple","size":7,"owner":"tom","appraisedValue":20},
      {"docType":"asset","ID":"asset5","color":"blue","size":8,"owner":"tom","appraisedValue":40}],
    "fetchedRecordsCount":2,
    "bookmark":"g1AAAABJeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzJRYXp5aYgmQ5YLI5IPUgSVawJIjFXJKfm5UFANqBE80"
  }

返回的书签标记结果集的结束。如果我们试图用这个书签进行查询，不会返回任何结果。

:guilabel:`Try it yourself`

.. code:: bash

    peer chaincode query -C $CHANNEL_NAME -n ledger -c '{"Args":["QueryAssetsWithPagination", "{\"selector\":{\"docType\":\"asset\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABJeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqzJRYXp5aYgmQ5YLI5IPUgSVawJIjFXJKfm5UFANqBE80"]}'

有关客户端应用程序如何迭代 JSON 查询结果集进行分页的例子，搜索  `Asset transfer ledger queries sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/asset-transfer-ledger-queries/chaincode-go/asset_transfer_ledger_chaincode.go>`__ 中的  ``getQueryResultForQueryStringWithPagination`` 函数。
