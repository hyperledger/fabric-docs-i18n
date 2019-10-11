使用 CouchDB 作为状态数据库
=============================

状态数据库选项
----------------------

状态数据库选项包括 LevelDB 和 CouchDB 。LevelDB 是默认嵌入在 Peer 程序中的键-值数据库。 CouchDB 是一个可选的额外扩展的状态数据库。就像 LevelDB 键-值存储一样，CouchDB 可以存储任何在链码中建模的二进制数据（CouchDB 附件功能在内部用于非 JSON 二进制数据）。但是作为一个 JSON 文档存储数据库，当链码值（比如，资产）以 JSON 数据建模时，CouchDB 额外支持链码数据的富查询。

LevelDB 和 CouchDB 都支持链码操作，比如获取或者设置一个键（资产），以及基于键查询。键可以按范围查询，以复合键建模就可以支持针对多个参数的等效查询。比如一个复合键 ``owner,asset_id`` 就可以查询一个实体的所有资产。这些基于键的查询可以用来在账本上做只读查询，同样可以用于在交易中更新账本

如果你以 JSON 建模资产并使用 CouchDB，你就可以在链码中使用 CouchDB JSON 来使用富查询。这种方式对于理解账本上存了什么内容是非常好的。这些类型查询的提案响应对于客户端应用程序是很有用的，但是对于提交到排序服务的交易就不是太有价值了。事实上，无法保证在链码执行和提交的时候富查询的结果不被改变，因此富查询不适合用于账本更新的交易中，除非你的应用程序可以保证查询的结果不会被改变，并且在子交易中可以很好的处理潜在的变化。例如，如果你想以富查询的方式查询 Alice 所有的资产，然后转移给 Bob，在链码执行和提交期间可能会有其他交易向 Alice 发送新的资产，这时你就是是去这些“幻像”。

CouchDB 以独立的进程和 peer 一起运行，因此需要一些额外的配置来设置、管理和操作。也许你想以 LevelDB 开始，但是当你需要富查询的时候再更换到 CouchDB。以 JSON 的方式建模脸链码资产数据是一个好的方式，这样你就可以在需要富查询的时候进行切换了。

.. note:: 
      CouchDB JSON 文档只能包含合法的 UTF-8 字符串并且不能以下划线开头（“_”）。无论你使用 CouchDB 还是 LevelDB 都不要在键中使用 U+0000 （空字节）。

      CouchDB JSON 文档中不能使用一下值作为顶字段的名字。这些名字为内部保留字段。
      - ``任何以下划线开头的字段，“_”``
      - ``~version``

从链码中使用 CouchDB
----------------------------

链码查询
~~~~~~~~~~~~~~~~~

`链码 API <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim#ChaincodeStubInterface>`__ 中大部分方法在 LevelDB 或者 CouchDB 状态数据库中都可用，例如 ``GetState``、``PutState``、``GetStateByRange``、``GetStateByPartialCompositeKey``。另外当你使用 CouchDB 作为状态数据库并且在链码中以 JSON 建模资产的时候，你可以使用 ``GetQueryResult`` 通过向 CouchDB 发送查询字符串的方式使用富查询。查询字符串请参考 `CouchDB JSON 查询语法 <http://docs.couchdb.org/en/2.1.1/api/database/find.html>`__ 。

`marbles02 示例 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__ 演示了如何从链码中使用 CouchDB 查询。它包含了一个 ``queryMarblesByOwner()`` 方法，通过向链码传递所有者 id 来演示如何通过参数查询。它还使用 JSON 查询语法在状态数据中查询符合 “docType” 的弹珠的所有者 id：

.. code:: bash

  {"selector":{"docType":"marble","owner":<OWNER_ID>}}

.. couchdb-pagination:

CouchDB 分页
^^^^^^^^^^^^^^^^^^

Fabric 支持对富查询和范围查询结果的分页。API 支持范围查询和富查询使用页大小和书签进行分页。要支持高效的分页，必须使用 Fabric 的分页 API。特别地，CouchDB 不支持 ``limit`` 关键字，分页是由 Fabric 来管理并隐式地按照 pageSize 的设置进行分页。

如果是通过查询 API （``GetStateByRangeWithPagination()``、``GetStateByPartialCompositeKeyWithPagination()``、和 ``GetQueryResultWithPagination()``）来指定 pageSize 的，返回给链码的结果（以 pageSize 为范围）会带有一个书签。该书签会返回给调用链码的客户端，客户端可以根据这个书签来查询结果的下一“页”。

分页 API 只能用于只读交易中，查询结果旨在支持客户端分页的需求。对于需要读和写的交易，请使用不带分页的链码查询 API。在链码中，您通过迭代的方式来获取你想要的深度。

无论是否使用了分页 API，所有链码查询都受限于 ``core.yaml`` 中的 ``totalQueryLimit`` （默认 100000）。这是链码将要迭代并返回给客户端最多的结果数量，以防意外或者恶意地长时间查询。

.. note:: 
      无论链码中是否使用了分页，节点都会根据 ``core.yaml`` 中的 ``internalQueryLimit``（默认 1000） 来查询 CouchDB。 这样就保证了在执行链码的时候有合理大小的结果在节点和 CouchDB 之间，以及链码和客户端之间传播。


在 :doc:`couchdb_tutorial` 教程中有一个使用分页的示例。

CouchDB 索引
~~~~~~~~~~~~~~~

CouchDB 中的索引用来提升 JSON 查询的效率以及按顺序的 JSON 查询。索引可以在 ``/META-INF/statedb/couchdb/indexes`` 文件夹中和链码打包在一起。每一个索引文件必须定义在一个扩展名为 ``*.json`` 的文本文件中，文件内容符合 `CouchDB 索引 JSON 语法 <http://docs.couchdb.org/en/2.1.1/api/database/find.html#db-index>`__ 。例如，要想支持上边提到的弹珠查询，提供了一个 ``docType`` 和 ``owner`` 字段的简单索引文件：

.. code:: bash

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

索引文件可以在 `这里 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/META-INF/statedb/couchdb/indexes/indexOwner.json>`__ 找到。

在链码的 ``META-INF/statedb/couchdb/indexes`` 文件夹下的所有索引都会打包到链码中以便部署。当链码在 Peer 节点上安装和在通道上实例化后，索引会自动部署在 Peer 节点的通道和链码指定的状态数据库中（如果它被配置为使用 CoucbDB）。如果你先在 Peer 节点上安装了链码，之后才会在通道上实例化链码，索引会在链码 **实例化** 的时候部署。如果链码已经在通道上实例化了，你之后又在 Peer 节点上安装了链码，索引会在链码 **安装** 的时候部署。

部署之后，调用链码查询的时候会自动使用索引。CouchDB 会根据查询的字段选择使用哪个索引。或者，在查询选择器中通过 ``use_index`` 关键字指定要使用的索引。

安装的不同版本的链码可能会有相同版本的索引。要更改索引，需要使用相同的索引名称但是不同的索引定义。在安装或者实例化完成的时候，索引就会重新被部署到 Peer 节点的状态数据库了。

如果你已经有了大量的数据，然后才安装或者初始化链码，在安装或初始化的过程中索引的创建可能会花费一些时间。在索引创建的过程中请不要调用来嘛查询状态数据库。在交易的过程中，区块提交到账本后索引会自动更新。

CouchDB 配置
---------------------

通过在 ``stateDatabase`` 状态选项中将 goleveldb 切换为 CouchDB 可以启用 CouchDB 状态数据库。另外配置 ``couchDBAddress`` 来指向 Peer 节点所使用的 CouchDB。如果 CouchDB 设置了用户名和密码，也需要在配置中指定。其他的配置选项在 ``couchDBConfig`` 部分也都有相关说明。重启 Peer 节点就可以使 *core.yaml* 文件立马生效。

你也可以使用环境变量来覆盖 core.yaml 中的值，例如 ``CORE_LEDGER_STATE_STATEDATABASE`` 和 ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS`` 。

下边是 *core.yaml* 中的 ``stateDatabase`` 部分：

.. code:: bash

    state:
      # stateDatabase - options are "goleveldb", "CouchDB"
      # goleveldb - default state database stored in goleveldb.
      # CouchDB - store state database in CouchDB
      stateDatabase: goleveldb
      # Limit on the number of records to return per query
      totalQueryLimit: 10000
      couchDBConfig:
         # It is recommended to run CouchDB on the same server as the peer, and
         # not map the CouchDB container port to a server port in docker-compose.
         # Otherwise proper security must be provided on the connection between
         # CouchDB client (on the peer) and server.
         couchDBAddress: couchdb:5984
         # This username must have read and write authority on CouchDB
         username:
         # The password is recommended to pass as an environment variable
         # during start up (e.g. LEDGER_COUCHDBCONFIG_PASSWORD).
         # If it is stored here, the file must be access control protected
         # to prevent unintended users from discovering the password.
         password:
         # Number of retries for CouchDB errors
         maxRetries: 3
         # Number of retries for CouchDB errors during peer startup
         maxRetriesOnStartup: 10
         # CouchDB request timeout (unit: duration, e.g. 20s)
         requestTimeout: 35s
         # Limit on the number of records per each CouchDB query
         # Note that chaincode queries are only bound by totalQueryLimit.
         # Internally the chaincode may execute multiple CouchDB queries,
         # each of size internalQueryLimit.
         internalQueryLimit: 1000
         # Limit on the number of records per CouchDB bulk update batch
         maxBatchUpdateSize: 1000
         # Warm indexes after every N blocks.
         # This option warms any indexes that have been
         # deployed to CouchDB after every N blocks.
         # A value of 1 will warm indexes after every block commit,
         # to ensure fast selector queries.
         # Increasing the value may improve write efficiency of peer and CouchDB,
         # but may degrade query response time.
         warmIndexesAfterNBlocks: 1

Hyperledger Fabric 提供的 CouchDB docker 镜像可以通过 Docker Compose 脚本来定义 ``COUCHDB_USER`` 和 ``COUCHDB_PASSWORD`` 环境变量，从而设置 CouchDB 管理员的用户名和密码。

如果没有使用 Fabric 提供的 docker 镜像安装 CouchDB，必须编辑 `local.ini 文件
<http://docs.couchdb.org/en/2.1.1/config/intro.html#configuration-files>`__ 来设置管理员的用户名和密码。

Docker Compose 脚本只能在创建容器的时候设置用户名和密码。在容器创建之后，必须使用 *local.ini* 文件来修改用户名和密码。

.. note:: 每次 Peer 节点启动的时候都会读取 CouchDB 节点的选项。

查询练习
--------------------------

避免对将导致扫描整个 CouchDB 数据库的；链码查询。全长数据库扫描将导致较长的响应时间，并将降低您的网络性能。您可以采取以下一些步骤来避免长时间查询：

- 使用 JSON 查询：

    * 确保在链码包中创建了索引。
    * 不要使用 ``$or``、``$in`` 和 ``$regex`` 之类会扫描整个数据库的操作。

- 对于范围查询、复合键查询和 JSON 查询：

    * 使用分页查询（就像 v1.3 中所说），不要使用一个大的查询结果。

- 如果在您的应用中想创建一个仪表盘（dashboard）或者聚合数据，您可以将区块链数据复制到链下的数据库中，通过链下数据库来查询或分析区块链数据，以此来优化数据存储，并防止网络性能的降低或交易的终端。要实现这个功能，可以通过区块或链码事件将交易数据写入链下数据库或者分析引擎。对于每一个接收到的区块，区块监听应用将遍历区块中的每一个交易并根据每一个有效交易的 ``读写集`` 中的键值对构建一个数据存储。文档 :doc:`peer_event_services` 提供了可重放事件，以确保下游数据存储的完整性。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
