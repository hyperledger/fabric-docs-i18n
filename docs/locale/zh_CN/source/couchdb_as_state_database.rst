使用 CouchDB 作为状态数据库
=============================
CouchDB as the State Database
=============================

状态数据库选项
----------------------

State Database options
----------------------

The current options for the peer state database are LevelDB and CouchDB. LevelDB is the default
key-value state database embedded in the peer process. CouchDB is an alternative external state database.
Like the LevelDB key-value store, CouchDB can store any binary data that is modeled in chaincode
(CouchDB attachment functionality is used internally for non-JSON binary data). But as a document
object store, CouchDB allows you to store data in JSON format, issue rich queries against your data,
and use indexes to support your queries.

The current options for the peer state database are LevelDB and CouchDB. LevelDB is the default
key-value state database embedded in the peer process. CouchDB is an alternative external state database.
Like the LevelDB key-value store, CouchDB can store any binary data that is modeled in chaincode
(CouchDB attachments are used internally for non-JSON data). As a document object store,
CouchDB allows you to store data in JSON format, issue rich queries against your data,
and use indexes to support your queries.

Both LevelDB and CouchDB support core chaincode operations such as getting and setting a key
(asset), and querying based on keys. Keys can be queried by range, and composite keys can be
modeled to enable equivalence queries against multiple parameters. For example a composite
key of ``owner,asset_id`` can be used to query all assets owned by a certain entity. These key-based
queries can be used for read-only queries against the ledger, as well as in transactions that
update the ledger.

Modeling your data in JSON allows you to issue rich queries against the values of your data,
instead of only being able to query the keys. This makes it easier for your applications and
chaincode to read the data stored on the blockchain ledger. Using CouchDB can help you meet
auditing and reporting requirements for many use cases that are not supported by LevelDB. If you use
CouchDB and model your data in JSON, you can also deploy indexes with your chaincode.
Using indexes makes queries more flexible and efficient and enables you to query large
datasets from chaincode.

CouchDB runs as a separate database process alongside the peer, therefore there are additional
considerations in terms of setup, management, and operations. You may consider starting with the
default embedded LevelDB, and move to CouchDB if you require the additional complex rich queries.
It is a good practice to model asset data as JSON, so that you have the option to perform
complex rich queries if needed in the future.

.. note::
      CouchDB JSON 文档只能包含合法的 UTF-8 字符串并且不能以下划线开头（“_”）。无论你使用 CouchDB 还是 LevelDB 都不要在键中使用 U+0000 （空字节）。

.. note:: The key for a CouchDB JSON document can only contain valid UTF-8 strings and cannot begin
   with an underscore ("_"). Whether you are using CouchDB or LevelDB, you should avoid using
   U+0000 (nil byte) in keys.

      CouchDB JSON 文档中不能使用一下值作为顶字段的名字。这些名字为内部保留字段。
      - ``任何以下划线开头的字段，“_”``
      - ``~version``

   JSON documents in CouchDB cannot use the following values as top level field names. These values
   are reserved for internal use.

从链码中使用 CouchDB
----------------------------

   - ``Any field beginning with an underscore, "_"``
   - ``~version``

链码查询
~~~~~~~~~~~~~~~~~

Using CouchDB from Chaincode
----------------------------

`链码 API <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__ 中大部分方法在 LevelDB 或者 CouchDB 状态数据库中都可用，例如 ``GetState``、``PutState``、``GetStateByRange``、``GetStateByPartialCompositeKey``。另外当你使用 CouchDB 作为状态数据库并且在链码中以 JSON 建模资产的时候，你可以使用 ``GetQueryResult`` 通过向 CouchDB 发送查询字符串的方式使用富查询。查询字符串请参考 `CouchDB JSON 查询语法 <http://docs.couchdb.org/en/2.1.1/api/database/find.html>`__ 。

Chaincode queries
~~~~~~~~~~~~~~~~~

`marbles02 示例 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/marbles_chaincode.go>`__ 演示了如何从链码中使用 CouchDB 查询。它包含了一个 ``queryMarblesByOwner()`` 方法，通过向链码传递所有者 id 来演示如何通过参数查询。它还使用 JSON 查询语法在状态数据中查询符合 “docType” 的弹珠的所有者 id：

Most of the `chaincode shim APIs <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__
can be utilized with either LevelDB or CouchDB state database, e.g. ``GetState``, ``PutState``,
``GetStateByRange``, ``GetStateByPartialCompositeKey``. Additionally when you utilize CouchDB as
the state database and model assets as JSON in chaincode, you can perform rich queries against
the JSON in the state database by using the ``GetQueryResult`` API and passing a CouchDB query string.
The query string follows the `CouchDB JSON query syntax <http://docs.couchdb.org/en/2.1.1/api/database/find.html>`__.

.. code:: bash

The `marbles02 fabric sample <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__
demonstrates use of CouchDB queries from chaincode. It includes a ``queryMarblesByOwner()`` function
that demonstrates parameterized queries by passing an owner id into chaincode. It then queries the
state data for JSON documents matching the docType of “marble” and the owner id using the JSON query
syntax:

  {"selector":{"docType":"marble","owner":<OWNER_ID>}}

.. code:: bash

The responses to rich queries are useful for understanding the data on the ledger. However,
there is no guarantee that the result set for a rich query will be stable between
the chaincode execution and commit time. As a result, you should not use a rich query and
update the channel ledger in a single transaction. For example, if you perform a
rich query for all assets owned by Alice and transfer them to Bob, a new asset may
be assigned to Alice by another transaction between chaincode execution time
and commit time.

  {"selector":{"docType":"marble","owner":<OWNER_ID>}}


The responses to rich queries are useful for understanding the data on the ledger. However,
there is no guarantee that the result set for a rich query will be stable between
the chaincode execution and commit time. As a result, you should not use a rich query and
update the channel ledger in a single transaction. For example, if you perform a
rich query for all assets owned by Alice and transfer them to Bob, a new asset may
be assigned to Alice by another transaction between chaincode execution time
and commit time.

.. couchdb-pagination:


CouchDB 分页
^^^^^^^^^^^^^^^^^^

.. couchdb-pagination:

Fabric 支持对富查询和范围查询结果的分页。API 支持范围查询和富查询使用页大小和书签进行分页。要支持高效的分页，必须使用 Fabric 的分页 API。特别地，CouchDB 不支持 ``limit`` 关键字，分页是由 Fabric 来管理并隐式地按照 pageSize 的设置进行分页。

CouchDB pagination
^^^^^^^^^^^^^^^^^^

如果是通过查询 API （``GetStateByRangeWithPagination()``、``GetStateByPartialCompositeKeyWithPagination()``、和 ``GetQueryResultWithPagination()``）来指定 pageSize 的，返回给链码的结果（以 pageSize 为范围）会带有一个书签。该书签会返回给调用链码的客户端，客户端可以根据这个书签来查询结果的下一“页”。

Fabric supports paging of query results for rich queries and range based queries.
APIs supporting pagination allow the use of page size and bookmarks to be used for
both range and rich queries. To support efficient pagination, the Fabric
pagination APIs must be used. Specifically, the CouchDB ``limit`` keyword will
not be honored in CouchDB queries since Fabric itself manages the pagination of
query results and implicitly sets the pageSize limit that is passed to CouchDB.

分页 API 只能用于只读交易中，查询结果旨在支持客户端分页的需求。对于需要读和写的交易，请使用不带分页的链码查询 API。在链码中，您通过迭代的方式来获取你想要的深度。

If a pageSize is specified using the paginated query APIs (``GetStateByRangeWithPagination()``,
``GetStateByPartialCompositeKeyWithPagination()``, and ``GetQueryResultWithPagination()``),
a set of results (bound by the pageSize) will be returned to the chaincode along with
a bookmark. The bookmark can be returned from chaincode to invoking clients,
which can use the bookmark in a follow on query to receive the next "page" of results.

无论是否使用了分页 API，所有链码查询都受限于 ``core.yaml`` 中的 ``totalQueryLimit`` （默认 100000）。这是链码将要迭代并返回给客户端最多的结果数量，以防意外或者恶意地长时间查询。

The pagination APIs are for use in read-only transactions only, the query results
are intended to support client paging requirements. For transactions
that need to read and write, use the non-paginated chaincode query APIs. Within
chaincode you can iterate through result sets to your desired depth.

.. note::
      无论链码中是否使用了分页，节点都会根据 ``core.yaml`` 中的 ``internalQueryLimit``（默认 1000） 来查询 CouchDB。 这样就保证了在执行链码的时候有合理大小的结果在节点和 CouchDB 之间，以及链码和客户端之间传播。

Regardless of whether the pagination APIs are utilized, all chaincode queries are
bound by ``totalQueryLimit`` (default 100000) from ``core.yaml``. This is the maximum
number of results that chaincode will iterate through and return to the client,
in order to avoid accidental or malicious long-running queries.

在 :doc:`couchdb_tutorial` 教程中有一个使用分页的示例。

.. note:: Regardless of whether chaincode uses paginated queries or not, the peer will
          query CouchDB in batches based on ``internalQueryLimit`` (default 1000)
          from ``core.yaml``. This behavior ensures reasonably sized result sets are
          passed between the peer and CouchDB when executing chaincode, and is
          transparent to chaincode and the calling client.

CouchDB 索引
~~~~~~~~~~~~~~~

An example using pagination is included in the :doc:`couchdb_tutorial` tutorial.

CouchDB 中的索引用来提升 JSON 查询的效率以及按顺序的 JSON 查询。索引可以让你在账本中有大量数据时进行查询。 索引可以在 ``/META-INF/statedb/couchdb/indexes`` 文件夹中和链码打包在一起。每一个索引文件必须定义在一个扩展名为 ``*.json`` 的文本文件中，文件内容符合 `CouchDB 索引 JSON 语法 <http://docs.couchdb.org/en/2.1.1/api/database/find.html#db-index>`__ 。例如，要想支持上边提到的弹珠查询，提供了一个 ``docType`` 和 ``owner`` 字段的简单索引文件：

CouchDB indexes
~~~~~~~~~~~~~~~

.. code:: bash

Indexes in CouchDB are required in order to make JSON queries efficient and are required for
any JSON query with a sort. Indexes enable you to query data from chaincode when you have
a large amount of data on your ledger. Indexes can be packaged alongside chaincode
in a ``/META-INF/statedb/couchdb/indexes`` directory. Each index must be defined in
its own text file with extension ``*.json`` with the index definition formatted in JSON
following the `CouchDB index JSON syntax <http://docs.couchdb.org/en/2.1.1/api/database/find.html#db-index>`__.
For example, to support the above marble query, a sample index on the ``docType`` and ``owner``
fields is provided:

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

.. code:: bash

索引文件可以在 `这里 <https://github.com/hyperledger/fabric-samples/blob/master/chaincode/marbles02/go/META-INF/statedb/couchdb/indexes/indexOwner.json>`__ 找到。

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

Any index in the chaincode’s ``META-INF/statedb/couchdb/indexes`` directory
will be packaged up with the chaincode for deployment. The index will be deployed
to a peers channel and chaincode specific database when the chaincode package is
installed on the peer and the chaincode definition is committed to the channel. If you
install the chaincode first and then commit the the chaincode definition to the
channel, the index will be deployed at commit time. If the chaincode has already
been defined on the channel and the chaincode package subsequently installed on
a peer joined to the channel, the index will be deployed at chaincode
**installation** time.

The sample index can be found `here <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/META-INF/statedb/couchdb/indexes/indexOwner.json>`__.

部署之后，调用链码查询的时候会自动使用索引。CouchDB 会根据查询的字段选择使用哪个索引。或者，在查询选择器中通过 ``use_index`` 关键字指定要使用的索引。

Any index in the chaincode’s ``META-INF/statedb/couchdb/indexes`` directory
will be packaged up with the chaincode for deployment. The index will be deployed
to a peers channel and chaincode specific database when the chaincode package is
installed on the peer and the chaincode definition is committed to the channel. If you
install the chaincode first and then commit the chaincode definition to the
channel, the index will be deployed at commit time. If the chaincode has already
been defined on the channel and the chaincode package subsequently installed on
a peer joined to the channel, the index will be deployed at chaincode
**installation** time.

安装的不同版本的链码可能会有相同版本的索引。要更改索引，需要使用相同的索引名称但是不同的索引定义。在安装或者实例化完成的时候，索引就会重新被部署到 Peer 节点的状态数据库了。

Upon deployment, the index will automatically be utilized by chaincode queries. CouchDB can automatically
determine which index to use based on the fields being used in a query. Alternatively, in the
selector query the index can be specified using the ``use_index`` keyword.

如果你已经有了大量的数据，然后才安装或者初始化链码，在安装或初始化的过程中索引的创建可能会花费一些时间。 同样，如果你已经有了大量的数据，然后提交后续版本的链码定义，也会花费一些时间创建索引。. 在索引创建的过程中请不要调用来嘛查询状态数据库。在交易的过程中，区块提交到账本后索引会自动更新。如果安装链码的过程中 Peer 节点崩溃了，couchdb 的索引可能就没有创建成功。这种情况下，你需要重新安装链码来创建索引。

The same index may exist in subsequent versions of the chaincode that gets installed. To change the
index, use the same index name but alter the index definition. Upon installation/instantiation, the index
definition will get re-deployed to the peer’s state database.

CouchDB 配置
---------------------

If you have a large volume of data already, and later install the chaincode, the index creation upon
installation may take some time. Similarly, if you have a large volume of data already and commit the
definition of a subsequent chaincode version, the index creation may take some time. Avoid calling chaincode
functions that query the state database at these times as the chaincode query may time out while the
index is getting initialized. During transaction processing, the indexes will automatically get refreshed
as blocks are committed to the ledger. If the peer crashes during chaincode installation, the couchdb
indexes may not get created. If this occurs, you need to reinstall the chaincode to create the indexes.

通过在 ``stateDatabase`` 状态选项中将 goleveldb 切换为 CouchDB 可以启用 CouchDB 状态数据库。另外配置 ``couchDBAddress`` 来指向 Peer 节点所使用的 CouchDB。如果 CouchDB 设置了用户名和密码，也需要在配置中指定。其他的配置选项在 ``couchDBConfig`` 部分也都有相关说明。重启 Peer 节点就可以使 *core.yaml* 文件立马生效。

CouchDB Configuration
---------------------

你也可以使用环境变量来覆盖 core.yaml 中的值，例如 ``CORE_LEDGER_STATE_STATEDATABASE`` 和 ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS`` 。

CouchDB is enabled as the state database by changing the ``stateDatabase`` configuration option from
goleveldb to CouchDB. Additionally, the ``couchDBAddress`` needs to configured to point to the
CouchDB to be used by the peer. The username and password properties should be populated with
an admin username and password if CouchDB is configured with a username and password. Additional
options are provided in the ``couchDBConfig`` section and are documented in place. Changes to the
*core.yaml* will be effective immediately after restarting the peer.

下边是 *core.yaml* 中的 ``stateDatabase`` 部分：

You can also pass in docker environment variables to override core.yaml values, for example
``CORE_LEDGER_STATE_STATEDATABASE`` and ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS``.

.. code:: bash

Below is the ``stateDatabase`` section from *core.yaml*:

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

.. code:: bash

Hyperledger Fabric 提供的 CouchDB docker 镜像可以通过 Docker Compose 脚本来定义 ``COUCHDB_USER`` 和 ``COUCHDB_PASSWORD`` 环境变量，从而设置 CouchDB 管理员的用户名和密码。

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

如果没有使用 Fabric 提供的 docker 镜像安装 CouchDB，必须编辑 `local.ini 文件
<http://docs.couchdb.org/en/2.1.1/config/intro.html#configuration-files>`__ 来设置管理员的用户名和密码。

CouchDB hosted in docker containers supplied with Hyperledger Fabric have the
capability of setting the CouchDB username and password with environment
variables passed in with the ``COUCHDB_USER`` and ``COUCHDB_PASSWORD`` environment
variables using Docker Compose scripting.

Docker Compose 脚本只能在创建容器的时候设置用户名和密码。在容器创建之后，必须使用 *local.ini* 文件来修改用户名和密码。

For CouchDB installations outside of the docker images supplied with Fabric,
the
`local.ini file of that installation
<http://docs.couchdb.org/en/2.1.1/config/intro.html#configuration-files>`__
must be edited to set the admin username and password.

If you choose to map the fabric-couchdb container port to a host port, make sure you
are aware of the security implications. Mapping the CouchDB container port in a
development environment exposes the CouchDB REST API and allows you to visualize
the database via the CouchDB web interface (Fauxton). In a production environment
you should refrain from mapping the host port to restrict access to the CouchDB
container. Only the peer will be able to access the CouchDB container.

Docker compose scripts only set the username and password at the creation of
the container. The *local.ini* file must be edited if the username or password
is to be changed after creation of the container.

.. note:: 每次 Peer 节点启动的时候都会读取 CouchDB 节点的选项。

If you choose to map the fabric-couchdb container port to a host port, make sure you
are aware of the security implications. Mapping the CouchDB container port in a
development environment exposes the CouchDB REST API and allows you to visualize
the database via the CouchDB web interface (Fauxton). In a production environment
you should refrain from mapping the host port to restrict access to the CouchDB
container. Only the peer will be able to access the CouchDB container.

查询练习
--------------------------

.. note:: CouchDB peer options are read on each peer startup.

避免对将导致扫描整个 CouchDB 数据库的；链码查询。全长数据库扫描将导致较长的响应时间，并将降低您的网络性能。您可以采取以下一些步骤来避免长时间查询：

Good practices for queries
--------------------------

- 使用 JSON 查询：

Avoid using chaincode for queries that will result in a scan of the entire
CouchDB database. Full length database scans will result in long response
times and will degrade the performance of your network. You can take some of
the following steps to avoid long queries:

    * 确保在链码包中创建了索引。
    * 不要使用 ``$or``、``$in`` 和 ``$regex`` 之类会扫描整个数据库的操作。

- When using JSON queries:

- 对于范围查询、复合键查询和 JSON 查询：

    * Be sure to create indexes in the chaincode package.
    * Avoid query operators such as ``$or``, ``$in`` and ``$regex``, which lead
      to full database scans.

    * 使用分页查询，不要使用一个大的查询结果。

- For range queries, composite key queries, and JSON queries:

- 如果在您的应用中想创建一个仪表盘（dashboard）或者聚合数据，您可以将区块链数据复制到链下的数据库中，通过链下数据库来查询或分析区块链数据，以此来优化数据存储，并防止网络性能的降低或交易的终端。要实现这个功能，可以通过区块或链码事件将交易数据写入链下数据库或者分析引擎。对于每一个接收到的区块，区块监听应用将遍历区块中的每一个交易并根据每一个有效交易的 ``读写集`` 中的键值对构建一个数据存储。文档 :doc:`peer_event_services` 提供了可重放事件，以确保下游数据存储的完整性。

    * Utilize paging support instead of one large result set.

- If you want to build a dashboard or collect aggregate data as part of your
  application, you can query an off-chain database that replicates the data
  from your blockchain network. This will allow you to query and analyze the
  blockchain data in a data store optimized for your needs, without degrading
  the performance of your network or disrupting transactions. To achieve this,
  applications may use block or chaincode events to write transaction data
  to an off-chain database or analytics engine. For each block received, the block
  listener application would iterate through the block transactions and build a
  data store using the key/value writes from each valid transaction's ``rwset``.
  The :doc:`peer_event_services` provide replayable events to ensure the
  integrity of downstream data stores.
