使用 CouchDB
=============

本教程将讲述在 Hyperledger Fabric 中使用 CouchDB 作为状态数据库的步骤。现在，
你应该已经熟悉 Fabric 的概念并且已经浏览了一些示例和教程。

Using CouchDB
=============

.. note:: These instructions use the new Fabric chaincode lifecycle introduced
          in the Fabric v2.0 release. If you would like to use the previous
          lifecycle model to use indexes with chaincode, visit the v1.4
          version of the `Using CouchDB <https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html>`__.

This tutorial will describe the steps required to use the CouchDB as the state
database with Hyperledger Fabric. By now, you should be familiar with Fabric
concepts and have explored some of the samples and tutorials.

本教程将带你按如下步骤与学习：

.. note:: These instructions use the new Fabric chaincode lifecycle introduced
          in the Fabric v2.0 release. If you would like to use the previous
          lifecycle model to use indexes with chaincode, visit the v1.4
          version of the `Using CouchDB <https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html>`__.

#. :ref:`cdb-enable-couch`
#. :ref:`cdb-create-index`
#. :ref:`cdb-add-index`
#. :ref:`cdb-install-deploy`
#. :ref:`cdb-query`
#. :ref:`cdb-best`
#. :ref:`cdb-pagination`
#. :ref:`cdb-update-index`
#. :ref:`cdb-delete-index`

The tutorial will take you through the following steps:

想要更深入的研究 CouchDB 的话，请参阅 :doc:`couchdb_as_state_database` ，关于 Fabric 账
本的跟多信息请参阅 `Ledger <ledger/ledger.html>`_ 主题。下边的教程将详细讲述如何在你的区
块链网络中使用 CouchDB 。

#. :ref:`cdb-enable-couch`
#. :ref:`cdb-create-index`
#. :ref:`cdb-add-index`
#. :ref:`cdb-install-deploy`
#. :ref:`cdb-query`
#. :ref:`cdb-best`
#. :ref:`cdb-pagination`
#. :ref:`cdb-update-index`
#. :ref:`cdb-delete-index`

本教程将使用 `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__ 作为演示在 Fabric 中使用 CouchDB 的用例，并且将会把 Marbles 部署在 :doc:`build_network` （BYFN）教程网络上。

For a deeper dive into CouchDB refer to :doc:`couchdb_as_state_database`
and for more information on the Fabric ledger refer to the `Ledger <ledger/ledger.html>`_
topic. Follow the tutorial below for details on how to leverage CouchDB in your
blockchain network.

为什么是 CouchDB ？
~~~~~~~~~~~~

Throughout this tutorial, we will use the `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__
as our use case to demonstrate how to use CouchDB with Fabric and will deploy
Marbles to the Fabric test network. You should have completed the task
:doc:`install`.

Fabric 支持两种类型的节点数据库。LevelDB 是默认嵌入在 peer 节点的状态数据库。
LevelDB 用于将链码数据存储为简单的键-值对，仅支持键、键范围和复合键查询。CouchDB 是一
个可选的状态数据库，支持以 JSON 格式在账本上建模数据并支持富查询，以便您查询实际数据
内容而不是键。CouchDB 同样支持在链码中部署索引，以便高效查询和对大型数据集的支持。

Why CouchDB?
~~~~~~~~~~~~

为了发挥 CouchDB 的优势，也就是说基于内容的 JSON 查询，你的数据必须以 JSON 格式
建模。你必须在设置你的网络之前确定使用 LevelDB 还是 CouchDB 。由于数据兼容性的问
题，不支持节点从 LevelDB 切换为 CouchDB 。网络中的所有节点必须使用相同的数据库类
型。如果你想 JSON 和二进制数据混合使用，你同样可以使用 CouchDB ，但是二进制数据只
能根据键、键范围和复合键查询。

Fabric supports two types of peer databases. LevelDB is the default state
database embedded in the peer node. LevelDB stores chaincode data as simple
key-value pairs and only supports key, key range, and composite key queries.
CouchDB is an optional, alternate state database that allows you to model data
on the ledger as JSON and issue rich queries against data values rather than
the keys. CouchDB also allows you to deploy indexes with your chaincode to make
queries more efficient and enable you to query large datasets.

.. _cdb-enable-couch:

In order to leverage the benefits of CouchDB, namely content-based JSON
queries, your data must be modeled in JSON format. You must decide whether to use
LevelDB or CouchDB before setting up your network. Switching a peer from using
LevelDB to CouchDB is not supported due to data compatibility issues. All peers
on the network must use the same database type. If you have a mix of JSON and
binary data values, you can still use CouchDB, however the binary values can
only be queried based on key, key range, and composite key queries.

在 Hyperledger Fabric 中启用 CouchDB
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _cdb-enable-couch:

CouchDB 是独立于节点运行的一个数据库进程。在安装、管理和操作的时候有一些额外
的注意事项。有一个可用的 Docker 镜像 `CouchDB <https://hub.docker.com/_/couchdb/>`__
并且我们建议它和节点运行在同一个服务器上。我们需要在每一个节点上安装一个 CouchDB
容器，并且更新每一个节点的配置文件 ``core.yaml`` ，将节点指向 CouchDB 容器。
``core.yaml`` 文件的路径必须在环境变量 FABRIC_CFG_PATH 中指定：

Enable CouchDB in Hyperledger Fabric
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 对于 Docker 的部署，在节点容器中 ``FABRIC_CFG_PATH`` 指定的文件夹中的 ``core.yaml``
  是预先配置好的。如果你要使用 docker 环境，你可以通过重写 ``docker-compose-couch.yaml``
  中的环境变量来覆盖 core.yaml

CouchDB runs as a separate database process alongside the peer. There
are additional considerations in terms of setup, management, and operations.
A Docker image of `CouchDB <https://hub.docker.com/_/couchdb/>`__
is available and we recommend that it be run on the same server as the
peer. You will need to setup one CouchDB container per peer
and update each peer container by changing the configuration found in
``core.yaml`` to point to the CouchDB container. The ``core.yaml``
file must be located in the directory specified by the environment variable
FABRIC_CFG_PATH:

* 对于原生的二进制部署， ``core.yaml`` 包含在发布的构件中。

* For Docker deployments, ``core.yaml`` is pre-configured and located in the peer
  container ``FABRIC_CFG_PATH`` folder. However, when using Docker environments,
  you typically pass environment variables by editing the
  ``docker-compose-couch.yaml``  to override the core.yaml

编辑 ``core.yaml`` 中的 ``stateDatabase`` 部分。将 ``stateDatabase`` 指定为 ``CouchDB``
并且填写 ``couchDBConfig`` 相关的配置。在 Fabric 中配置 CouchDB 的更多细节，请参阅
`CouchDB 配置 <couchdb_as_state_database.html#couchdb-configuration>`__ 。

* For native binary deployments, ``core.yaml`` is included with the release artifact
  distribution.

.. _cdb-create-index:

Edit the ``stateDatabase`` section of ``core.yaml``. Specify ``CouchDB`` as the
``stateDatabase`` and fill in the associated ``couchDBConfig`` properties. For
more information, see `CouchDB configuration <couchdb_as_state_database.html#couchdb-configuration>`__.

创建一个索引
~~~~~~~~~~~~~~~

.. _cdb-create-index:

为什么索引很重要？

Create an index
~~~~~~~~~~~~~~~

索引可以让数据库不用在每次查询的时候都检查每一行，可以让数据库运行的更快和更高效。
一般来说，对频繁查询的数据进行索引可以使数据查询更高效。为了充分发挥 CouchDB 的优
势 -- 对 JSON 数据进行富查询的能力 -- 并不需要索引，但是为了性能考虑强烈建议建立
索引。另外，如果在一个查询中需要排序，CouchDB 需要在排序的字段有一个索引。

Why are indexes important?

.. note::

Indexes allow a database to be queried without having to examine every row
with every query, making them run faster and more efficiently. Normally,
indexes are built for frequently occurring query criteria allowing the data to
be queried more efficiently. To leverage the major benefit of CouchDB -- the
ability to perform rich queries against JSON data -- indexes are not required,
but they are strongly recommended for performance. Also, if sorting is required
in a query, CouchDB requires an index of the sorted fields.

   没有索引的情况下富查询也是可以使用的，但是会在 CouchDB 的日志中抛出一个没
   有找到索引的警告。如果一个富查询中包含了一个排序的说明，需要排序的那个字段
   就必须有索引；否则，查询将会失败并抛出错误。

.. note::

To demonstrate building an index, we will use the data from the `Marbles
sample <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__.
In this example, the Marbles data structure is defined as:

   Rich queries that do not have an index will work but may throw a warning
   in the CouchDB log that the index was not found. However, if a rich query
   includes a sort specification, then an index on that field is required;
   otherwise, the query will fail and an error will be thrown.

.. code:: javascript

To demonstrate building an index, we will use the data from the `Marbles
sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__.
In this example, the Marbles data structure is defined as:

  type marble struct {
	   ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	   Name       string `json:"name"`    //the field tags are needed to keep case from bouncing around
	   Color      string `json:"color"`
           Size       int    `json:"size"`
           Owner      string `json:"owner"`
  }

.. code:: javascript


  type marble struct {
	   ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	   Name       string `json:"name"`    //the field tags are needed to keep case from bouncing around
	   Color      string `json:"color"`
           Size       int    `json:"size"`
           Owner      string `json:"owner"`
  }

在这个结构体中，（ ``docType``, ``name``, ``color``, ``size``, ``owner`` ）属性
定义了和资产相关的账本数据。 ``docType`` 属性用来在链码中区分可能需要单独查询的
不同数据类型的模式。当时使用 CouchDB 的时候，建议包含 ``docType`` 属性来区分在链
码命名空间中的每一个文档。（每一个链码都需要有他们自己的 CouchDB 数据库，也就是
说，每一个链码都有它自己的键的命名空间。）


在 Marbles 数据结构的定义中， ``docType`` 用来识别这个文档或者资产是一个弹珠资产。
同时在链码数据库中也可能存在其他文档或者资产。数据库中的文档对于这些属性值来说都是
可查询的。

In this structure, the attributes (``docType``, ``name``, ``color``, ``size``,
``owner``) define the ledger data associated with the asset. The attribute
``docType`` is a pattern used in the chaincode to differentiate different data
types that may need to be queried separately. When using CouchDB, it
recommended to include this ``docType`` attribute to distinguish each type of
document in the chaincode namespace. (Each chaincode is represented as its own
CouchDB database, that is, each chaincode has its own namespace for keys.)

当为链码查询定义一个索引的时候，每一个索引都必须定义在一个扩展名为 ``*.json`` 的
文本文件中，并且索引定义的格式必须为 CouchDB 索引的 JSON 格式。

With respect to the Marbles data structure, ``docType`` is used to identify
that this document/asset is a marble asset. Potentially there could be other
documents/assets in the chaincode database. The documents in the database are
searchable against all of these attribute values.

需要以下三条信息来定义一个索引：

When defining an index for use in chaincode queries, each one must be defined
in its own text file with the extension `*.json` and the index definition must
be formatted in the CouchDB index JSON format.

  * `fields`: 这些是常用的查询字段
  * `name`: 索引名
  * `type`: 它的内容一般是 json

To define an index, three pieces of information are required:

例如，这是一个对字段 ``foo`` 的一个名为 ``foo-index`` 的简单索引。

  * `fields`: these are the frequently queried fields
  * `name`: name of the index
  * `type`: always json in this context

.. code:: json

For example, a simple index named ``foo-index`` for a field named ``foo``.

    {
        "index": {
            "fields": ["foo"]
        },
        "name" : "foo-index",
        "type" : "json"
    }

.. code:: json

可选地，设计文档（ design document ）属性 ``ddoc`` 可以写在索引的定义中。
`design document <http://guide.couchdb.org/draft/design.html>`__ 是 CouchDB 结构,
用于包含索引。索引可以以组的形式定义在设计文档中以提升效率，但是 CouchDB 建议每一
个设计文档包含一个索引。

    {
        "index": {
            "fields": ["foo"]
        },
        "name" : "foo-index",
        "type" : "json"
    }

.. tip:: 当定义一个索引的时候，最好将 ``ddoc`` 属性和值包含在索引内。包含这个
         属性以确保在你需要的时候升级索引，这是很重要的。它还使你能够明确指定
         要在查询上使用的索引。

Optionally the design document  attribute ``ddoc`` can be specified on the index
definition. A `design document <http://guide.couchdb.org/draft/design.html>`__ is
CouchDB construct designed to contain indexes. Indexes can be grouped into
design documents for efficiency but CouchDB recommends one index per design
document.

这里有另外一个使用 Marbles 示例定义索引的例子，在索引 ``indexOwner`` 使用了多个
字段 ``docType`` 和 ``owner`` 并且包含了 ``ddoc`` 属性：

.. tip:: When defining an index it is a good practice to include the ``ddoc``
         attribute and value along with the index name. It is important to
         include this attribute to ensure that you can update the index later
         if needed. Also it gives you the ability to explicitly specify which
         index to use on a query.

.. _indexExample:


.. code:: json

Here is another example of an index definition from the Marbles sample with
the index name ``indexOwner`` using multiple fields ``docType`` and ``owner``
and includes the ``ddoc`` attribute:

  {
    "index":{
        "fields":["docType","owner"] // Names of the fields to be queried
    },
    "ddoc":"indexOwnerDoc", // (optional) Name of the design document in which the index will be created.
    "name":"indexOwner",
    "type":"json"
  }

.. _indexExample:


.. code:: json

在上边的例子中，如果设计文档 ``indexOwnerDoc`` 不存在，当索引部署的时候会自动创建
一个。一个索引可以根据字段列表中指定的一个或者多个属性构建，而且可以定义任何属性的
组合。一个属性可以存在于同一个 docType 的多个索引中。在下边的例子中， ``index1``
只包含 ``owner`` 属性， ``index2`` 包含 ``owner 和 color`` 属性， ``index3`` 包含
``owner、 color 和 size`` 属性。另外，注意，根据 CouchDB 的建议，每一个索引的定义
都包含一个它们自己的 ``ddoc`` 值。
.. code:: json

  {
    "index":{
        "fields":["docType","owner"] // Names of the fields to be queried
    },
    "ddoc":"indexOwnerDoc", // (optional) Name of the design document in which the index will be created.
    "name":"indexOwner",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner"] // Names of the fields to be queried
    },
    "ddoc":"index1Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index1",
    "type":"json"
  }

In the example above, if the design document ``indexOwnerDoc`` does not already
exist, it is automatically created when the index is deployed. An index can be
constructed with one or more attributes specified in the list of fields and
any combination of attributes can be specified. An attribute can exist in
multiple indexes for the same docType. In the following example, ``index1``
only includes the attribute ``owner``, ``index2`` includes the attributes
``owner and color`` and ``index3`` includes the attributes ``owner, color and
size``. Also, notice each index definition has its own ``ddoc`` value, following
the CouchDB recommended practice.

  {
    "index":{
        "fields":["owner", "color"] // Names of the fields to be queried
    },
    "ddoc":"index2Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index2",
    "type":"json"
  }

.. code:: json

  {
    "index":{
        "fields":["owner", "color", "size"] // Names of the fields to be queried
    },
    "ddoc":"index3Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index3",
    "type":"json"
  }

  {
    "index":{
        "fields":["owner"] // Names of the fields to be queried
    },
    "ddoc":"index1Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index1",
    "type":"json"
  }

一般来说，你为索引字段建模应该匹配将用于查询过滤和排序的字段。对于以 JSON 格式
构建索引的更多信息请参阅 `CouchDB documentation <http://docs.couchdb.org/en/latest/api/database/find.html#db-index>`__ 。

  {
    "index":{
        "fields":["owner", "color"] // Names of the fields to be queried
    },
    "ddoc":"index2Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index2",
    "type":"json"
  }

关于索引最后要说的是，Fabric 在数据库中为文档建立索引的时候使用一种成为 ``索引升温
（index warming）`` 的模式。 CouchDB 直到下一次查询的时候才会索引新的或者更新的
文档。Fabric 通过在每一个数据区块提交完之后请求索引更新的方式，来确保索引处于 ‘热
（warm）’ 状态。这就确保了查询速度快，因为在运行查询之前不用索引文档。这个过程保
持了索引的现状，并在每次新数据添加到状态数据的时候刷新。

  {
    "index":{
        "fields":["owner", "color", "size"] // Names of the fields to be queried
    },
    "ddoc":"index3Doc", // (optional) Name of the design document in which the index will be created.
    "name":"index3",
    "type":"json"
  }

.. _cdb-add-index:



In general, you should model index fields to match the fields that will be used
in query filters and sorts. For more details on building an index in JSON
format refer to the `CouchDB documentation <http://docs.couchdb.org/en/latest/api/database/find.html#db-index>`__.

将索引添加到你的链码文件夹
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A final word on indexing, Fabric takes care of indexing the documents in the
database using a pattern called ``index warming``. CouchDB does not typically
index new or updated documents until the next query. Fabric ensures that
indexes stay 'warm' by requesting an index update after every block of data is
committed.  This ensures queries are fast because they do not have to index
documents before running the query. This process keeps the index current
and refreshed every time new records are added to the state database.

当你完成索引之后，你需要把它打包到你的链码中，以便于将它部署到合适的元数据文件夹。你可以使用 :doc:`commands/peerlifecycle` 命令安装链码。JSON 索引文件必须放在链码目录的 ``META-INF/statedb/couchdb/indexes`` 路径下。

.. _cdb-add-index:

下边的 `Marbles 示例 <https://github.com/hyperledger/fabric-samples/tree/master/chaincode/marbles02/go>`__ 展示了如何将索引打包到链码中。


.. image:: images/couchdb_tutorial_pkg_example.png
  :scale: 100%
  :align: center
  :alt: Marbles Chaincode Index Package

Add the index to your chaincode folder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This sample includes one index named indexOwnerDoc:

Once you finalize an index, you need to package it with your chaincode for
deployment by placing it in the appropriate metadata folder. You can install the
chaincode using the :doc:`commands/peerlifecycle` command. The JSON index files
must be located under the path ``META-INF/statedb/couchdb/indexes`` which is
located inside the directory where the chaincode resides.

.. code:: json

The `Marbles sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/chaincode/marbles02/go>`__  below illustrates how the index
is packaged with the chaincode.

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

.. image:: images/couchdb_tutorial_pkg_example.png
  :scale: 100%
  :align: center
  :alt: Marbles Chaincode Index Package


This sample includes one index named indexOwnerDoc:

启动网络
-----------------

.. code:: json

:guilabel:`Try it yourself`

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}


We will bring up the Fabric test network and use it to deploy the marbles
chainocde. Use the following command to navigate to the `test-network` directory
in the Fabric samples:

Start the network
-----------------

.. code:: bash

:guilabel:`Try it yourself`

    cd fabric-samples/test-network


For this tutorial, we want to operate from a known initial state. The following
command will kill any active or stale Docker containers and remove previously
generated artifacts:

We will bring up the Fabric test network and use it to deploy the marbles
chaincode. Use the following command to navigate to the `test-network` directory
in the Fabric samples:

.. code:: bash

    ./network.sh down

    cd fabric-samples/test-network

If you have not run through the tutorial before, you will need to vendor the
chaincode dependencies before we can deploy it to the network. Run the
following commands:

For this tutorial, we want to operate from a known initial state. The following
command will kill any active or stale Docker containers and remove previously
generated artifacts:

.. code:: bash

    cd ../chaincode/marbles02/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network

    ./network.sh down

From the `test-network` directory, deploy the test network with CouchDB with the
following command:

If you have not run through the tutorial before, you will need to vendor the
chaincode dependencies before we can deploy it to the network. Run the
following commands:

.. code:: bash

    ./network.sh up createChannel -s couchdb

    cd ../chaincode/marbles02/go
    GO111MODULE=on go mod vendor
    cd ../../../test-network

This will create two fabric peer nodes that use CouchDB as the state database.
It will also create one ordering node and a single channel named
``mychannel``.

From the `test-network` directory, deploy the test network with CouchDB with the
following command:

.. _cdb-install-deploy:

.. code:: bash

安装和定义链码
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ./network.sh up createChannel -s couchdb

客户端应用通过链码和区块链账本交互。所以我们需要在每一个执行和背书交易的节点
上安装链码。但是在我们和链码交互之前，通道中的成员需要一致同意链码的定义，以此
来建立链码的治理。在之前的章节中，我们演示了如何将索引添加到链码文件夹中以便索引和链码部署在一起。

This will create two fabric peer nodes that use CouchDB as the state database.
It will also create one ordering node and a single channel named
``mychannel``.

链码在安装到 Peer 节点之前需要打包。我们可以使用 `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ 命令来打包弹珠链码。

.. _cdb-install-deploy:

:guilabel:`Try it yourself`

Install and define the Chaincode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. After you start the test network, copy and paste the following environment
variables in your CLI to interact with the network as the Org1 admin. Make sure
that you are in the `test-network` directory.

Client applications interact with the blockchain ledger through chaincode.
Therefore we need to install a chaincode on every peer that will execute and
endorse our transactions. However, before we can interact with our chaincode,
the members of the channel need to agree on a chaincode definition that
establishes chaincode governance. In the previous section, we demonstrated how
to add the index to the chaincode folder so that the index is deployed with
the chaincode.

.. code:: bash

The chaincode needs to be packaged before it can be installed on our peers.
We can use the `peer lifecycle chaincode package <commands/peerlifecycle.html#peer-lifecycle-chaincode-package>`__ command
to package the marbles chaincode.

    export PATH=${PWD}/../bin:${PWD}:$PATH
    export FABRIC_CFG_PATH=${PWD}/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

:guilabel:`Try it yourself`

2. Use the following command to package the marbles chaincode:

1. After you start the test network, copy and paste the following environment
variables in your CLI to interact with the network as the Org1 admin. Make sure
that you are in the `test-network` directory.

.. code:: bash

    peer lifecycle chaincode package marbles.tar.gz --path ../chaincode/marbles02/go --lang golang --label marbles_1

    export PATH=${PWD}/../bin:$PATH
    export FABRIC_CFG_PATH=${PWD}/../config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051

This command will create a chaincode package named marbles.tar.gz.

2. Use the following command to package the marbles chaincode:

3. Use the following command to install the chaincode package onto the peer
``peer0.org1.example.com``:

.. code:: bash

.. code:: bash

    peer lifecycle chaincode package marbles.tar.gz --path ../chaincode/marbles02/go --lang golang --label marbles_1

    peer lifecycle chaincode install marbles.tar.gz

This command will create a chaincode package named marbles.tar.gz.

A successful install command will return the chaincode identifier, similar to
the response below:

3. Use the following command to install the chaincode package onto the peer
``peer0.org1.example.com``:

.. code:: bash

    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJmarbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3\022\tmarbles_1" >
    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3

    peer lifecycle chaincode install marbles.tar.gz

After installing the chaincode on ``peer0.org1.example.com``, we need to approve
a chaincode definition for Org1.

A successful install command will return the chaincode identifier, similar to
the response below:

4. Use the following command to query your peer for the package ID of the
installed chaincode.

.. code:: bash

.. code:: bash

    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJmarbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3\022\tmarbles_1" >
    2019-04-22 18:47:38.312 UTC [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: marbles_1:0907c1f3d3574afca69946e1b6132691d58c2f5c5703df7fc3b692861e92ecd3

    peer lifecycle chaincode queryinstalled

After installing the chaincode on ``peer0.org1.example.com``, we need to approve
a chaincode definition for Org1.

The command will return the same package identifier as the install command.
You should see output similar to the following:

4. Use the following command to query your peer for the package ID of the
installed chaincode.

.. code:: bash

    Installed chaincodes on peer:
    Package ID: marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787, Label: marbles_1

    peer lifecycle chaincode queryinstalled

5. Declare the package ID as an environment variable. Paste the package ID of
marbles_1 returned by the ``peer lifecycle chaincode queryinstalled`` command
into the command below. The package ID may not be the same for all users, so
you need to complete this step using the package ID returned from your console.

The command will return the same package identifier as the install command.
You should see output similar to the following:

.. code:: bash

    export CC_PACKAGE_ID=marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787

    Installed chaincodes on peer:
    Package ID: marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787, Label: marbles_1

6. Use the following command to approve a definition of the marbles chaincode
for Org1.

5. Declare the package ID as an environment variable. Paste the package ID of
marbles_1 returned by the ``peer lifecycle chaincode queryinstalled`` command
into the command below. The package ID may not be the same for all users, so
you need to complete this step using the package ID returned from your console.

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

    export CC_PACKAGE_ID=marbles_1:60ec9430b221140a45b96b4927d1c3af736c1451f8d432e2a869bdbf417f9787

When the command completes successfully you should see something similar to :

6. Use the following command to approve a definition of the marbles chaincode
for Org1.

.. code:: bash

    2020-01-07 16:24:20.886 EST [chaincodeCmd] ClientWait -> INFO 001 txid [560cb830efa1272c85d2f41a473483a25f3b12715d55e22a69d55abc46581415] committed with status (VALID) at

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA

We need a majority of organizations to approve a chaincode definition before
it can be committed to the channel. This implies that we need Org2 to approve
the chaincode definition as well. Because we do not need Org2 to endorse the
chaincode and did not install the package on any Org2 peers, we do not need to
provide a packageID as part of the chaincode definition.

When the command completes successfully you should see something similar to :

7. Use the CLI to operate as the Org2 admin. Copy and paste the following block
of commands as a group into the peer container and run them all at once.

.. code:: bash

.. code:: bash

    2020-01-07 16:24:20.886 EST [chaincodeCmd] ClientWait -> INFO 001 txid [560cb830efa1272c85d2f41a473483a25f3b12715d55e22a69d55abc46581415] committed with status (VALID) at

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

We need a majority of organizations to approve a chaincode definition before
it can be committed to the channel. This implies that we need Org2 to approve
the chaincode definition as well. Because we do not need Org2 to endorse the
chaincode and did not install the package on any Org2 peers, we do not need to
provide a packageID as part of the chaincode definition.

8. Use the following command to approve the chaincode definition for Org2:

7. Use the CLI to operate as the Org2 admin. Copy and paste the following block
of commands as a group into the peer container and run them all at once.

.. code:: bash

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --sequence 1 --tls true --cafile $ORDERER_CA

    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

9. We can now use the `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ command
to commit the chaincode definition to the channel:

8. Use the following command to approve the chaincode definition for Org2:

.. code:: bash

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --sequence 1 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --sequence 1 --tls --cafile $ORDERER_CA

When the commit transaction completes successfully you should see something
similar to:

9. We can now use the `peer lifecycle chaincode commit <commands/peerlifecycle.html#peer-lifecycle-chaincode-commit>`__ command
to commit the chaincode definition to the channel:

.. code:: bash

    2019-04-22 18:57:34.274 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org2.example.com:9051
    2019-04-22 18:57:34.709 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org1.example.com:7051

    export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --version 1.0 --sequence 1 --signature-policy "OR('Org1MSP.member','Org2MSP.member')" --init-required --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $ORG2_CA

10. Because the marbles chaincode contains an initialization function, we need to
use the `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-invoke>`__ command
to invoke ``Init()`` before we can use other functions in the chaincode:

When the commit transaction completes successfully you should see something
similar to:

.. code:: bash

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --isInit --tls true --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA -c '{"Args":["Init"]}'

    2019-04-22 18:57:34.274 UTC [chaincodeCmd] ClientWait -> INFO 001 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org2.example.com:9051
    2019-04-22 18:57:34.709 UTC [chaincodeCmd] ClientWait -> INFO 002 txid [3da8b0bb8e128b5e1b6e4884359b5583dff823fce2624f975c69df6bce614614] committed with status (VALID) at peer0.org1.example.com:7051

验证部署的索引
-------------------------

10. Because the marbles chaincode contains an initialization function, we need to
use the `peer chaincode invoke <commands/peerchaincode.html?%20chaincode%20instantiate#peer-chaincode-invoke>`__ command
to invoke ``Init()`` before we can use other functions in the chaincode:

当链码在节点上安装并且在通道上部署完成之后，索引会被部署到每一个节点的 CouchDB
状态数据库上。你可以通过检查 Docker 容器中的节点日志来确认 CouchDB 是否被创建成功。

.. code:: bash

:guilabel:`Try it yourself`

    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name marbles --isInit --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $ORG1_CA -c '{"Args":["Init"]}'

 为了查看节点 Docker 容器的日志，打开一个新的终端窗口，然后运行下边的命令来匹配索
 引被创建的确认信息。

Verify index was deployed
-------------------------

::

Indexes will be deployed to each peer's CouchDB state database once the
chaincode has been installed on the peer and deployed to the channel. You can
verify that the CouchDB index was created successfully by examining the peer log
in the Docker container.

   docker logs peer0.org1.example.com  2>&1 | grep "CouchDB index"

:guilabel:`Try it yourself`

你将会看到类似下边的结果：

To view the logs in the peer Docker container, open a new Terminal window and
run the following command to grep for message confirmation that the index was
created.

::

   [couchdb] CreateIndex -> INFO 0be Created CouchDB index [indexOwner] in state database [mychannel_marbles] using design document [_design/indexOwnerDoc]

   docker logs peer0.org1.example.com  2>&1 | grep "CouchDB index"

.. note:: 如果 Marbles 没有安装在节点 ``peer0.org1.example.com`` 上，你可
           能需要切换到其他的安装了 Marbles 的节点。


.. _cdb-query:

You should see a result that looks like the following:

查询 CouchDB 状态数据库
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

现在索引已经在 JSON 中定义了并且和链码部署在了一起，链码函数可以对 CouchDB 状态数据
库执行 JSON 查询，同时 peer 命令可以调用链码函数。

   [couchdb] CreateIndex -> INFO 0be Created CouchDB index [indexOwner] in state database [mychannel_marbles] using design document [_design/indexOwnerDoc]

在查询的时候指定索引的名字是可选的。如果不指定，同时索引已经在被查询的字段上存在了，
已存在的索引会自动被使用。

.. note:: If you installed Marbles on a different peer than ``peer0.org1.example.com``,
          you may need to replace it with the name of a different peer where
          Marbles was installed.

.. tip:: 在查询的时候使用 ``use_index`` 关键字包含一个索引名字是一个好的习惯。如果
         不使用索引名，CouchDB 可能不会使用最优的索引。而且 CouchDB 也可能会不使用
         索引，但是在测试期间数据少的化你很难意识到。只有在数据量大的时候，你才可能
         会意识到因为 CouchDB 没有使用索引而导致性能较低。

.. _cdb-query:

在链码中构建一个查询
----------------------------

Query the CouchDB State Database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

你可以使用链码中定义的富查询来查询账本上的数据。 `marbles02 示例 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__ 中包含了两个富查询方法：

Now that the index has been defined in the JSON file and deployed alongside the
chaincode, chaincode functions can execute JSON queries against the CouchDB
state database, and thereby peer commands can invoke the chaincode functions.

  * **queryMarbles** --

Specifying an index name on a query is optional. If not specified, and an index
already exists for the fields being queried, the existing index will be
automatically used.

      一个 **富查询** 示例。这是一个可以将一个（选择器）字符串传入函数的查询。
      这个查询对于需要在运行时动态创建他们自己的选择器的客户端应用程序很有用。
      跟多关于选择器的信息请参考 `CouchDB selector syntax <http://docs.couchdb.org/en/latest/api/database/find.html#find-selectors>`__ 。

.. tip:: It is a good practice to explicitly include an index name on a
         query using the ``use_index`` keyword. Without it, CouchDB may pick a
         less optimal index. Also CouchDB may not use an index at all and you
         may not realize it, at the low volumes during testing. Only upon
         higher volumes you may realize slow performance because CouchDB is not
         using an index and you assumed it was.

  * **queryMarblesByOwner** --


      一个查询逻辑保存在链码中的**参数查询**的示例。在这个例子中，函数值接受单个参数，
      就是弹珠的主人。然后使用 JSON 查询语法查询状态数据库中匹配 “marble” 的 docType
      和 拥有者 id 的 JSON 文档。

Build the query in chaincode
----------------------------

使用 peer 命令运行查询
------------------------------------

You can perform complex rich queries against the data on the ledger using
queries defined within your chaincode. The `marbles02 sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__
includes two rich query functions:

In absence of a client application, we can use the peer command to test the
queries defined in the chaincode. We will customize the `peer chaincode query <commands/peerchaincode.html?%20chaincode%20query#peer-chaincode-query>`__
command to use the Marbles index ``indexOwner`` and query for all marbles owned
by "tom" using the ``queryMarbles`` function.

  * **queryMarbles** --

:guilabel:`Try it yourself`

      Example of an **ad hoc rich query**. This is a query
      where a (selector) string can be passed into the function. This query
      would be useful to client applications that need to dynamically build
      their own selectors at runtime. For more information on selectors refer
      to `CouchDB selector syntax <http://docs.couchdb.org/en/latest/api/database/find.html#find-selectors>`__.


在查询数据库之前，我们应该添加一些数据。以 Org1 的身份运行下面的命令来创建一个拥有者为 “tom” 的弹珠：

  * **queryMarblesByOwner** --

.. code:: bash

      Example of a **parameterized query** where the
      query logic is baked into the chaincode. In this case the function accepts
      a single argument, the marble owner. It then queries the state database for
      JSON documents matching the docType of “marble” and the owner id using the
      JSON query syntax.

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble1","blue","35","tom"]}'


 当链码实例化后，然后部署索引，索引就可以自动被链码的查询使用。CouchDB 可以根
 据查询的字段决定使用哪个索引。如果这个查询准则存在索引，它就会被使用。但是建
 议在查询的时候指定 ``use_index`` 关键字。下边的 peer 命令就是一个如何通过在选
 择器语法中包含 ``use_index`` 关键字来明确地指定索引的例子：

Run the query using the peer command
------------------------------------

.. code:: bash

In absence of a client application, we can use the peer command to test the
queries defined in the chaincode. We will customize the `peer chaincode query <commands/peerchaincode.html?%20chaincode%20query#peer-chaincode-query>`__
command to use the Marbles index ``indexOwner`` and query for all marbles owned
by "tom" using the ``queryMarbles`` function.

   // Rich Query with index name explicitly specified:
   peer chaincode query -C mychannel -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}"]}'

:guilabel:`Try it yourself`

详细看一下上边的查询命令，有三个参数值得关注：

Before querying the database, we should add some data. Run the following
command as Org1 to create a marble owned by "tom":

*  ``queryMarbles``

.. code:: bash

  Marbles 链码中的函数名称。注意使用了一个 `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__
  ``shim.ChaincodeStubInterface`` 来访问和修改账本。 ``getQueryResultForQueryString()``
  传递 queryString 给 shim API ``getQueryResult()``.

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble1","blue","35","tom"]}'

.. code:: bash

After an index has been deployed when the chaincode is initialized, it will
automatically be utilized by chaincode queries. CouchDB can determine which
index to use based on the fields being queried. If an index exists for the
query criteria it will be used. However the recommended approach is to
specify the ``use_index`` keyword on the query. The peer command below is an
example of how to specify the index explicitly in the selector syntax by
including the ``use_index`` keyword:

  func (t *SimpleChaincode) queryMarbles(stub shim.ChaincodeStubInterface, args []string) pb.Response {

.. code:: bash

	  //   0
	  // "queryString"
	   if len(args) < 1 {
		   return shim.Error("Incorrect number of arguments. Expecting 1")
	   }

   // Rich Query with index name explicitly specified:
   peer chaincode query -C mychannel -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}"]}'

	   queryString := args[0]

Delving into the query command above, there are three arguments of interest:

	   queryResults, err := getQueryResultForQueryString(stub, queryString)
	   if err != nil {
		 return shim.Error(err.Error())
	   }
	   return shim.Success(queryResults)
  }

*  ``queryMarbles``

*  ``{"selector":{"docType":"marble","owner":"tom"}``

  Name of the function in the Marbles chaincode. Notice a `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__
  ``shim.ChaincodeStubInterface`` is used to access and modify the ledger. The
  ``getQueryResultForQueryString()`` passes the queryString to the shim API ``getQueryResult()``.

  这是一个 **ad hoc 选择器** 字符串的示例，用来查找所有 ``owner`` 属性值为 ``tom``
  的 ``marble`` 的文档。

.. code:: bash


  func (t *SimpleChaincode) queryMarbles(stub shim.ChaincodeStubInterface, args []string) pb.Response {

*  ``"use_index":["_design/indexOwnerDoc", "indexOwner"]``

	  //   0
	  // "queryString"
	   if len(args) < 1 {
		   return shim.Error("Incorrect number of arguments. Expecting 1")
	   }

  指定设计文档名 ``indexOwnerDoc`` 和索引名 ``indexOwner`` 。在这个示例中，查询
  选择器通过指定 ``use_index`` 关键字明确包含了索引名。回顾一下上边的索引定义 :ref:`cdb-create-index` ，
  它包含了设计文档， ``"ddoc":"indexOwnerDoc"`` 。在 CouchDB 中，如果你想在查询
  中明确包含索引名，在索引定义中必须包含 ``ddoc`` 值，然后它才可以被 ``use_index``
  关键字引用。

	   queryString := args[0]


	   queryResults, err := getQueryResultForQueryString(stub, queryString)
	   if err != nil {
		 return shim.Error(err.Error())
	   }
	   return shim.Success(queryResults)
  }

利用索引的查询成功后返回如下结果：

*  ``{"selector":{"docType":"marble","owner":"tom"}``

.. code:: json

  This is an example of an **ad hoc selector** string which finds all documents
  of type ``marble`` where the ``owner`` attribute has a value of ``tom``.

  Query Result: [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}}]


.. _cdb-best:

*  ``"use_index":["_design/indexOwnerDoc", "indexOwner"]``

查询和索引的最佳实践
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Specifies both the design doc name  ``indexOwnerDoc`` and index name
  ``indexOwner``. In this example the selector query explicitly includes the
  index name, specified by using the ``use_index`` keyword. Recalling the
  index definition above :ref:`cdb-create-index`, it contains a design doc,
  ``"ddoc":"indexOwnerDoc"``. With CouchDB, if you plan to explicitly include
  the index name on the query, then the index definition must include the
  ``ddoc`` value, so it can be referenced with the ``use_index`` keyword.

Queries that use indexes will complete faster, without having to scan the full
database in couchDB. Understanding indexes will allow you to write your queries
for better performance and help your application handle larger amounts
of data or blocks on your network.


It is also important to plan the indexes you install with your chaincode. You
should install only a few indexes per chaincode that support most of your queries.
Adding too many indexes, or using an excessive number of fields in an index, will
degrade the performance of your network. This is because the indexes are updated
after each block is committed. The more indexes need to be updated through
"index warming", the longer it will take for transactions to complete.

The query runs successfully and the index is leveraged with the following results:

The examples in this section will help demonstrate how queries use indexes and
what type of queries will have the best performance. Remember the following
when writing your queries:

.. code:: json

* All fields in the index must also be in the selector or sort sections of your query
  for the index to be used.
* More complex queries will have a lower performance and will be less likely to
  use an index.
* You should try to avoid operators that will result in a full table scan or a
  full index scan such as ``$or``, ``$in`` and ``$regex``.

  Query Result: [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}}]

In the previous section of this tutorial, you issued the following query against
the marbles chaincode:

.. _cdb-best:

.. code:: bash

Use best practices for queries and indexes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Example one: query fully supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

Queries that use indexes will complete faster, without having to scan the full
database in couchDB. Understanding indexes will allow you to write your queries
for better performance and help your application handle larger amounts
of data or blocks on your network.

The marbles chaincode was installed with the ``indexOwnerDoc`` index:

It is also important to plan the indexes you install with your chaincode. You
should install only a few indexes per chaincode that support most of your queries.
Adding too many indexes, or using an excessive number of fields in an index, will
degrade the performance of your network. This is because the indexes are updated
after each block is committed. The more indexes need to be updated through
"index warming", the longer it will take for transactions to complete.

.. code:: json

The examples in this section will help demonstrate how queries use indexes and
what type of queries will have the best performance. Remember the following
when writing your queries:

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

* All fields in the index must also be in the selector or sort sections of your query
  for the index to be used.
* More complex queries will have a lower performance and will be less likely to
  use an index.
* You should try to avoid operators that will result in a full table scan or a
  full index scan such as ``$or``, ``$in`` and ``$regex``.

Notice that both the fields in the query, ``docType`` and ``owner``, are
included in the index, making it a fully supported query. As a result this
query will be able to use the data in the index, without having to search the
full database. Fully supported queries such as this one will return faster than
other queries from your chaincode.

In the previous section of this tutorial, you issued the following query against
the marbles chaincode:

If you add extra fields to the query above, it will still use the index.
However, the query will additionally have to scan the indexed data for the
extra fields, resulting in a longer response time. As an example, the query
below will still use the index, but will take a longer time to return than the
previous example.

.. code:: bash

.. code:: bash

  // Example one: query fully supported by the index
  export CHANNEL_NAME=mychannel
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

  // Example two: query fully supported by the index with additional data
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\",\"color\":\"red\"}, \"use_index\":[\"/indexOwnerDoc\", \"indexOwner\"]}"]}'

The marbles chaincode was installed with the ``indexOwnerDoc`` index:

A query that does not include all fields in the index will have to scan the full
database instead. For example, the query below searches for the owner, without
specifying the the type of item owned. Since the ownerIndexDoc contains both
the ``owner`` and ``docType`` fields, this query will not be able to use the
index.

.. code:: json

.. code:: bash

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

  // Example three: query not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

Notice that both the fields in the query, ``docType`` and ``owner``, are
included in the index, making it a fully supported query. As a result this
query will be able to use the data in the index, without having to search the
full database. Fully supported queries such as this one will return faster than
other queries from your chaincode.

In general, more complex queries will have a longer response time, and have a
lower chance of being supported by an index. Operators such as ``$or``, ``$in``,
and ``$regex`` will often cause the query to scan the full index or not use the
index at all.

If you add extra fields to the query above, it will still use the index.
However, the query will additionally have to scan the indexed data for the
extra fields, resulting in a longer response time. As an example, the query
below will still use the index, but will take a longer time to return than the
previous example.

As an example, the query below contains an ``$or`` term that will search for every
marble and every item owned by tom.

.. code:: bash

.. code:: bash

  // Example two: query fully supported by the index with additional data
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\",\"color\":\"red\"}, \"use_index\":[\"/indexOwnerDoc\", \"indexOwner\"]}"]}'

  // Example four: query with $or supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{"\$or\":[{\"docType\:\"marble\"},{\"owner\":\"tom\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

A query that does not include all fields in the index will have to scan the full
database instead. For example, the query below searches for the owner, without
specifying the type of item owned. Since the ownerIndexDoc contains both
the ``owner`` and ``docType`` fields, this query will not be able to use the
index.

This query will still use the index because it searches for fields that are
included in ``indexOwnerDoc``. However, the ``$or`` condition in the query
requires a scan of all the items in the index, resulting in a longer response
time.

.. code:: bash

Below is an example of a complex query that is not supported by the index.

  // Example three: query not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"owner\":\"tom\"}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

.. code:: bash

In general, more complex queries will have a longer response time, and have a
lower chance of being supported by an index. Operators such as ``$or``, ``$in``,
and ``$regex`` will often cause the query to scan the full index or not use the
index at all.

  // Example five: Query with $or not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{"\$or\":[{\"docType\":\"marble\",\"owner\":\"tom\"},{"\color\":"\yellow\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

As an example, the query below contains an ``$or`` term that will search for every
marble and every item owned by tom.

The query searches for all marbles owned by tom or any other items that are
yellow. This query will not use the index because it will need to search the
entire table to meet the ``$or`` condition. Depending the amount of data on your
ledger, this query will take a long time to respond or may timeout.

.. code:: bash

While it is important to follow best practices with your queries, using indexes
is not a solution for collecting large amounts of data. The blockchain data
structure is optimized to validate and confirm transactions and is not suited
for data analytics or reporting. If you want to build a dashboard as part
of your application or analyze the data from your network, the best practice is
to query an off chain database that replicates the data from your peers. This
will allow you to understand the data on the blockchain without degrading the
performance of your network or disrupting transactions.

  // Example four: query with $or supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"$or\":[{\"docType\":\"marble\"},{\"owner\":\"tom\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'

You can use block or chaincode events from your application to write transaction
data to an off-chain database or analytics engine. For each block received, the block
listener application would iterate through the block transactions and build a data
store using the key/value writes from each valid transaction's ``rwset``. The
:doc:`peer_event_services` provide replayable events to ensure the integrity of
downstream data stores. For an example of how you can use an event listener to write
data to an external database, visit the `Off chain data sample <https://github.com/hyperledger/fabric-samples/tree/master/off_chain_data>`__
in the Fabric Samples.

This query will still use the index because it searches for fields that are
included in ``indexOwnerDoc``. However, the ``$or`` condition in the query
requires a scan of all the items in the index, resulting in a longer response
time.

.. _cdb-pagination:

Below is an example of a complex query that is not supported by the index.

在 CouchDB 状态数据库查询中使用分页
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code:: bash

当 CouchDB 的查询返回了一个很大的结果集时，有一些将结果分页的 API 可以提供给链码调用。分
页提供了一个将结果集合分区的机制，该机制指定了一个 ``pagesize`` 和起始点 -- 一个从结果集
合的哪里开始的 ``书签`` 。客户端应用程序以迭代的方式调用链码来执行查询，直到没有更多的结
果返回。更多信息请参考 `topic on pagination with CouchDB <couchdb_as_state_database.html#couchdb-pagination>`__ 。

  // Example five: Query with $or not supported by the index
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarbles", "{\"selector\":{\"$or\":[{\"docType\":\"marble\",\"owner\":\"tom\"},{\"color\":\"yellow\"}]}, \"use_index\":[\"indexOwnerDoc\", \"indexOwner\"]}"]}'


The query searches for all marbles owned by tom or any other items that are
yellow. This query will not use the index because it will need to search the
entire table to meet the ``$or`` condition. Depending the amount of data on your
ledger, this query will take a long time to respond or may timeout.

我们将使用 `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__
中的函数 ``queryMarblesWithPagination`` 来演示在链码和客户端应用程序中如何使用分页。

While it is important to follow best practices with your queries, using indexes
is not a solution for collecting large amounts of data. The blockchain data
structure is optimized to validate and confirm transactions and is not suited
for data analytics or reporting. If you want to build a dashboard as part
of your application or analyze the data from your network, the best practice is
to query an off chain database that replicates the data from your peers. This
will allow you to understand the data on the blockchain without degrading the
performance of your network or disrupting transactions.

* **queryMarblesWithPagination** --

You can use block or chaincode events from your application to write transaction
data to an off-chain database or analytics engine. For each block received, the block
listener application would iterate through the block transactions and build a data
store using the key/value writes from each valid transaction's ``rwset``. The
:doc:`peer_event_services` provide replayable events to ensure the integrity of
downstream data stores. For an example of how you can use an event listener to write
data to an external database, visit the `Off chain data sample <https://github.com/hyperledger/fabric-samples/tree/{BRANCH}/off_chain_data>`__
in the Fabric Samples.

    一个 **使用分页的 ad hoc 富查询** 的示例。这是一个像上边的示例一样，可以将一个（选择器）
    字符串传入函数的查询。在这个示例中，在查询中也包含了一个 ``pageSize`` 作为一个 ``标签`` 。

.. _cdb-pagination:

为了演示分页，需要更多的数据。本例假设你已经加入了 marble1 。在节点容器中执行下边的命令创建
4 个 “tom” 的弹珠，这样就创建了 5 个 “tom” 的弹珠：

Query the CouchDB State Database With Pagination
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:guilabel:`Try it yourself`

When large result sets are returned by CouchDB queries, a set of APIs is
available which can be called by chaincode to paginate the list of results.
Pagination provides a mechanism to partition the result set by
specifying a ``pagesize`` and a start point -- a ``bookmark`` which indicates
where to begin the result set. The client application iteratively invokes the
chaincode that executes the query until no more results are returned. For more information refer to
this `topic on pagination with CouchDB <couchdb_as_state_database.html#couchdb-pagination>`__.

.. code:: bash


    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble2","yellow","35","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble3","green","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble4","purple","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble5","blue","40","tom"]}'

We will use the `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__
function ``queryMarblesWithPagination`` to  demonstrate how
pagination can be implemented in chaincode and the client application.

除了上边示例中的查询参数， queryMarblesWithPagination 增加了 ``pagesize`` 和 ``bookmark`` 。
``PageSize`` 指定了每次查询返回结果的数量。 ``bookmark`` 是一个用来告诉 CouchDB 从每一页从
哪开始的 “锚（anchor）” 。（结果的每一页都返回一个唯一的书签）

* **queryMarblesWithPagination** --

*  ``queryMarblesWithPagination``

    Example of an **ad hoc rich query with pagination**. This is a query
    where a (selector) string can be passed into the function similar to the
    above example.  In this case, a ``pageSize`` is also included with the query as
    well as a ``bookmark``.

  Marbles 链码中函数的名称。注意 `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__
  ``shim.ChaincodeStubInterface`` 用于访问和修改账本。 ``getQueryResultForQueryStringWithPagination()``
  将 queryString 、 pagesize 和 bookmark 传递给 shim API ``GetQueryResultWithPagination()`` 。

In order to demonstrate pagination, more data is required. This example assumes
that you have already added marble1 from above. Run the following commands in
the peer container to create four more marbles owned by "tom", to create a
total of five marbles owned by "tom":


:guilabel:`Try it yourself`

.. code:: bash

  func (t *SimpleChaincode) queryMarblesWithPagination(stub shim.ChaincodeStubInterface, args []string) pb.Response {

    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble2","yellow","35","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble3","green","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble4","purple","20","tom"]}'
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile  ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n marbles -c '{"Args":["initMarble","marble5","blue","40","tom"]}'

  	//   0
  	// "queryString"
  	if len(args) < 3 {
  		return shim.Error("Incorrect number of arguments. Expecting 3")
  	}

In addition to the arguments for the query in the previous example,
queryMarblesWithPagination adds ``pagesize`` and ``bookmark``. ``PageSize``
specifies the number of records to return per query.  The ``bookmark`` is an
"anchor" telling couchDB where to begin the page. (Each page of results returns
a unique bookmark.)

  	queryString := args[0]
  	//return type of ParseInt is int64
  	pageSize, err := strconv.ParseInt(args[1], 10, 32)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	bookmark := args[2]

*  ``queryMarblesWithPagination``

  	queryResults, err := getQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	return shim.Success(queryResults)
  }

  Name of the function in the Marbles chaincode. Notice a `shim <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`__
  ``shim.ChaincodeStubInterface`` is used to access and modify the ledger. The
  ``getQueryResultForQueryStringWithPagination()`` passes the queryString along
  with the pagesize and bookmark to the shim API ``GetQueryResultWithPagination()``.


.. code:: bash

下边的例子是一个 peer 命令，以 pageSize 为 ``3`` 没有指定 boomark 的方式调用 queryMarblesWithPagination 。

  func (t *SimpleChaincode) queryMarblesWithPagination(stub shim.ChaincodeStubInterface, args []string) pb.Response {

.. tip:: 当没有指定 bookmark 的时候，查询从记录的“第一”页开始。

  	//   0
  	// "queryString"
  	if len(args) < 3 {
  		return shim.Error("Incorrect number of arguments. Expecting 3")
  	}

:guilabel:`Try it yourself`

  	queryString := args[0]
  	//return type of ParseInt is int64
  	pageSize, err := strconv.ParseInt(args[1], 10, 32)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	bookmark := args[2]

.. code:: bash

  	queryResults, err := getQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
  	if err != nil {
  		return shim.Error(err.Error())
  	}
  	return shim.Success(queryResults)
  }

  // Rich Query with index name explicitly specified and a page size of 3:
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3",""]}'


下边是接收到的响应（为清楚起见，增加了换行），返回了五个弹珠中的三个，因为 ``pagesize`` 设置成了 ``3`` 。

The following example is a peer command which calls queryMarblesWithPagination
with a pageSize of ``3`` and no bookmark specified.

.. code:: bash

.. tip:: When no bookmark is specified, the query starts with the "first"
         page of records.

  [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}},
   {"Key":"marble2", "Record":{"color":"yellow","docType":"marble","name":"marble2","owner":"tom","size":35}},
   {"Key":"marble3", "Record":{"color":"green","docType":"marble","name":"marble3","owner":"tom","size":20}}]
  [{"ResponseMetadata":{"RecordsCount":"3",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"}}]

:guilabel:`Try it yourself`

.. note::  Bookmark 是 CouchDB 每次查询的时候唯一生成的，并显示在结果集中。将返回的 bookmark 传递给迭代查询的子集中来获取结果的下一个集合。

.. code:: bash

下边是一个 pageSize 为 ``3`` 的调用 queryMarblesWithPagination 的 peer 命令。
注意一下这里，这次的查询包含了上次查询返回的 bookmark 。

  // Rich Query with index name explicitly specified and a page size of 3:
  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3",""]}'

:guilabel:`Try it yourself`

The following response is received (carriage returns added for clarity), three
of the five marbles are returned because the ``pagsize`` was set to ``3``:

.. code:: bash

  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"]}'

  [{"Key":"marble1", "Record":{"color":"blue","docType":"marble","name":"marble1","owner":"tom","size":35}},
   {"Key":"marble2", "Record":{"color":"yellow","docType":"marble","name":"marble2","owner":"tom","size":35}},
   {"Key":"marble3", "Record":{"color":"green","docType":"marble","name":"marble3","owner":"tom","size":20}}]
  [{"ResponseMetadata":{"RecordsCount":"3",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"}}]

下边是接收到的响应（为清楚起见，增加了换行），返回了五个弹珠中的三个，返回了剩下的两个记录：
.. code:: bash

.. note::  Bookmarks are uniquely generated by CouchDB for each query and
           represent a placeholder in the result set. Pass the
           returned bookmark on the subsequent iteration of the query to
           retrieve the next set of results.

  [{"Key":"marble4", "Record":{"color":"purple","docType":"marble","name":"marble4","owner":"tom","size":20}},
   {"Key":"marble5", "Record":{"color":"blue","docType":"marble","name":"marble5","owner":"tom","size":40}}]
  [{"ResponseMetadata":{"RecordsCount":"2",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

The following is a peer command to call queryMarblesWithPagination with a
pageSize of ``3``. Notice this time, the query includes the bookmark returned
from the previous query.

最后一个命令是调用 queryMarblesWithPagination 的 peer 命令，其中 pageSize 为 ``3`` ，bookmark 是前一次查询返回的结果。

:guilabel:`Try it yourself`


.. code:: bash

:guilabel:`Try it yourself`

  peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkGoOkOWDSOSANIFk2iCyIyVySn5uVBQAGEhRz"]}'

.. code:: bash

The following response is received (carriage returns added for clarity).  The
last two records are retrieved:

    peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"]}'

.. code:: bash

下边是接收到的响应（为清楚起见，增加了换行）。没有记录返回，说明所有的页
面都获取到了：

  [{"Key":"marble4", "Record":{"color":"purple","docType":"marble","name":"marble4","owner":"tom","size":20}},
   {"Key":"marble5", "Record":{"color":"blue","docType":"marble","name":"marble5","owner":"tom","size":40}}]
  [{"ResponseMetadata":{"RecordsCount":"2",
  "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

.. code:: bash

The final command is a peer command to call queryMarblesWithPagination with
a pageSize of ``3`` and with the bookmark from the previous query.

    []
    [{"ResponseMetadata":{"RecordsCount":"0",
    "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

:guilabel:`Try it yourself`

对于如何使用客户端应用程序使用分页迭代结果集，请在
`Marbles sample <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__ 。
中搜索 ``getQueryResultForQueryStringWithPagination`` 函数。

.. code:: bash

.. _cdb-update-index:

    peer chaincode query -C $CHANNEL_NAME -n marbles -c '{"Args":["queryMarblesWithPagination", "{\"selector\":{\"docType\":\"marble\",\"owner\":\"tom\"}, \"use_index\":[\"_design/indexOwnerDoc\", \"indexOwner\"]}","3","g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"]}'

升级索引
~~~~~~~~~~~~~~~

The following response is received (carriage returns added for clarity).
No records are returned, indicating that all pages have been retrieved:

可能需要随时升级索引。相同的索引可能会存在安装的链码的子版本中。为了索引的升级，
原来的索引定义必须包含在设计文档 ``ddoc`` 属性和索引名。为了升级索引定义，使用相
同的索引名并改变索引定义。简单编辑索引 JSON 文件并从索引中增加或者删除字段。 Fabric
只支持 JSON 类型的索引。不支持改变索引类型。升级后的索引定义在链码定义提交之后
会重新部署在节点的状态数据库中。

.. code:: bash

.. note:: 如果状态数据库有大量数据，重建索引的过程会花费较长时间，在此期间链码执
          行或者查询可能会失败或者超时。

    []
    [{"ResponseMetadata":{"RecordsCount":"0",
    "Bookmark":"g1AAAABLeJzLYWBgYMpgSmHgKy5JLCrJTq2MT8lPzkzJBYqz5yYWJeWkmoKkOWDSOSANIFk2iCyIyVySn5uVBQAGYhR1"}}]

迭代索引定义
----------------------------------

For an example of how a client application can iterate over
the result sets using pagination, search for the ``getQueryResultForQueryStringWithPagination``
function in the `Marbles sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__.

如果你在开发环境中访问你的节点的 CouchDB 状态数据库，你可以迭代测试各种索引以支
持你的链码查询。链码的任何改变都可能需要重新部署。使用 `CouchDB Fauxton interface <http://docs.couchdb.org/en/latest/fauxton/index.html>`__
或者命令行 curl 工具来创建和升级索引。

.. _cdb-update-index:

.. note:: Fauxton 是用于创建、升级和部署 CouchDB 索引的一个网页，如果你想尝试这个接口，
          有一个 Marbles 示例中索引的 Fauxton 版本格式的例子。如果你使用 CouchDB 部署了测试网络，可以通过在浏览器的导航栏中打开 ``http://localhost:5984/_utils`` 来
          访问 Fauxton 。

Update an Index
~~~~~~~~~~~~~~~

另外，如果你不想使用 Fauxton UI，下边是通过 curl 命令在 ``mychannel_marbles`` 数据库上创
建索引的例子：

It may be necessary to update an index over time. The same index may exist in
subsequent versions of the chaincode that gets installed. In order for an index
to be updated, the original index definition must have included the design
document ``ddoc`` attribute and an index name. To update an index definition,
use the same index name but alter the index definition. Simply edit the index
JSON file and add or remove fields from the index. Fabric only supports the
index type JSON. Changing the index type is not supported. The updated
index definition gets redeployed to the peer’s state database when the chaincode
definition is committed to the channel. Changes to the index name or ``ddoc``
attributes will result in a new index being created and the original index remains
unchanged in CouchDB until it is removed.

.. code:: bash

.. note:: If the state database has a significant volume of data, it will take
          some time for the index to be re-built, during which time chaincode
          invokes that issue queries may fail or timeout.

  // Index for docType, owner.
  // Example curl command line to define index in the CouchDB channel_chaincode database
   curl -i -X POST -H "Content-Type: application/json" -d
          "{\"index\":{\"fields\":[\"docType\",\"owner\"]},
            \"name\":\"indexOwner\",
            \"ddoc\":\"indexOwnerDoc\",
            \"type\":\"json\"}" http://hostname:port/mychannel_marbles/_index

Iterating on your index definition
----------------------------------

.. note:: 如果你在测试网络中配置了 CouchDB，请使用 ``localhost:5984`` 替换 hostname:port 。

If you have access to your peer's CouchDB state database in a development
environment, you can iteratively test various indexes in support of
your chaincode queries. Any changes to chaincode though would require
redeployment. Use the `CouchDB Fauxton interface <http://docs.couchdb.org/en/latest/fauxton/index.html>`__ or a command
line curl utility to create and update indexes.


.. note:: The Fauxton interface is a web UI for the creation, update, and
          deployment of indexes to CouchDB. If you want to try out this
          interface, there is an example of the format of the Fauxton version
          of the index in Marbles sample. If you have deployed the test network
          with CouchDB, the Fauxton interface can be loaded by opening a browser
          and navigating to ``http://localhost:5984/_utils``.

.. _cdb-delete-index:

Alternatively, if you prefer not use the Fauxton UI, the following is an example
of a curl command which can be used to create the index on the database
``mychannel_marbles``:

删除索引
~~~~~~~~~~~~~~~

.. code:: bash

Fabric 工具不能删除索引。如果你需要删除索引，就要手动使用 curl 命令或者 Fauxton 接
口操作数据库。

  // Index for docType, owner.
  // Example curl command line to define index in the CouchDB channel_chaincode database
   curl -i -X POST -H "Content-Type: application/json" -d
          "{\"index\":{\"fields\":[\"docType\",\"owner\"]},
            \"name\":\"indexOwner\",
            \"ddoc\":\"indexOwnerDoc\",
            \"type\":\"json\"}" http://hostname:port/mychannel_marbles/_index

删除索引的 curl 命令格式如下：

.. note:: If you are using the test network configured with CouchDB, replace
    hostname:port with ``localhost:5984``.

.. code:: bash

.. _cdb-delete-index:

   curl -X DELETE http://localhost:5984/{database_name}/_index/{design_doc}/json/{index_name} -H  "accept: */*" -H  "Host: localhost:5984"

Delete an Index
~~~~~~~~~~~~~~~


Index deletion is not managed by Fabric tooling. If you need to delete an index,
manually issue a curl command against the database or delete it using the
Fauxton interface.

要删除本教程中的索引，curl 命令应该是：

The format of the curl command to delete an index would be:

.. code:: bash

   curl -X DELETE http://localhost:5984/mychannel_marbles/_index/indexOwnerDoc/json/indexOwner -H  "accept: */*" -H  "Host: localhost:5984"

   curl -X DELETE http://localhost:5984/{database_name}/_index/{design_doc}/json/{index_name} -H  "accept: */*" -H  "Host: localhost:5984"



To delete the index used in this tutorial, the curl command would be:

.. code:: bash

   curl -X DELETE http://localhost:5984/mychannel_marbles/_index/indexOwnerDoc/json/indexOwner -H  "accept: */*" -H  "Host: localhost:5984"


