
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


