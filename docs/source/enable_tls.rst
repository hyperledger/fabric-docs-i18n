利用传输层安全（TLS）进行安全通信
==========================================================

Fabric 支持在节点间使用 TLS 进行安全通信。 TLS 通信可以单向（仅服务端）也可以双向
（服务端和客户端）认证。

为 peer 节点配置 TLS
-------------------------------

peer 节点既可以是 TLS 服务端也可以是 TLS 客户端。当它和另外一个 peer 节点、应用或者 CLI 
连接时它是前者，当它和其他 peer 节点或者排序节点连接时它是后者。

为了在 peer 节点上启用 TLS ，需要设置下边这些节点配置的属性：

 * ``peer.tls.enabled`` = ``true``
 * ``peer.tls.cert.file`` = 包含 TLS 服务证书文件的完整路径
 * ``peer.tls.key.file`` = 包含 TLS 服务私钥文件的完整路径
 * ``peer.tls.rootcert.file`` = 包含用于授权 TLS 服务证书的证书链的完整路径

默认下，当在一个 peer 节点上启用 TLS 的时候 TLS 客户端授权是关闭的。这就意味着 peer 节点在 
TLS 握手期间不能验证客户端（另外一个 peer 节点、应用或者 CLI）的授权证书。为了在一个 peer 节
点上启用 TLS 客户端授权，将节点配置属性 ``peer.tls.clientAuthRequired`` 设置为 ``true`` 并且
将 ``peer.tls.clientRootCAs.files`` 属性设置为包含 CA 证书链的 CA 链文件，用于验证你组织中客
户端的 TLS 证书。

默认下，当一个 peer 节点同时作为 TLS 服务端和客户端的时候，都使用同一个证书和密钥对。如果要在
客户端侧使用不同的证书和密钥对，就分别设置 ``peer.tls.clientCert.file`` 和 
``peer.tls.clientKey.file`` 的配置属性为客户端证书和密钥文件的完整路径。    

客户端授权 TLS 也可以通过设置如下环境变量来启用：

 * ``CORE_PEER_TLS_ENABLED`` = ``true``
 * ``CORE_PEER_TLS_CERT_FILE`` = 服务端证书的完整路径
 * ``CORE_PEER_TLS_KEY_FILE`` = 服务端私钥的完整路径
 * ``CORE_PEER_TLS_ROOTCERT_FILE`` = CA 链文件的完整路径
 * ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``CORE_PEER_TLS_CLIENTROOTCAS_FILES`` = CA 链文件的完整路径
 * ``CORE_PEER_TLS_CLIENTCERT_FILE`` = 客户端证书的完整路径
 * ``CORE_PEER_TLS_CLIENTKEY_FILE`` = 客户端私钥的完整路径

当 peer 节点的客户端认证启动以后，客户端需要在 TLS 握手期间发送它的证书。如果客户端没有发送它
的证书，握手就会失败，并且节点会关闭连接。

当一个节点加入通道的时候，会从通道的配置区块中读取通道成员的根 CA 证书链并加入到 TLS 客户端和
服务端的根 CA 数据结构中。所以，peer 节点和 peer 节点之间的通信，peer 节点和排序节点的通信是无
缝连接的。

配置排序节点的 TLS
---------------------------------

启动排序节点的 TLS ，需要设置如下排序节点的配置属性：

 * ``General.TLS.Enabled`` = ``true``
 * ``General.TLS.PrivateKey`` = 包含服务端私钥文件的完整路径 
 * ``General.TLS.Certificate`` = 包含服务端证书的文件的完整路径e
 * ``General.TLS.RootCAs`` = 包含用于 TLS 服务端证书的 CA 证书链的完整路径

默认下，和 peer 节点一样，在排序节点上 TLS 客户端授权是关闭的。启用 TLS 客户端授权，需要设
置如下配置属性：

 * ``General.TLS.ClientAuthRequired`` = ``true``
 * ``General.TLS.ClientRootCAs`` = 包含 TLS 服务端证书所使用的 CA 证书链文件的完整路径

也可以通过设置下边的环境变量来启用客户端 TLS 认证：

 * ``ORDERER_GENERAL_TLS_ENABLED`` = ``true``
 * ``ORDERER_GENERAL_TLS_PRIVATEKEY`` = 包含服务端私钥文件的完整路径
 * ``ORDERER_GENERAL_TLS_CERTIFICATE`` = 包含服务端证书文件的完整路径
 * ``ORDERER_GENERAL_TLS_ROOTCAS`` = 包含 TLS 服务端证书所使用的 CA 证书链文件的完整路径
 * ``ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``ORDERER_GENERAL_TLS_CLIENTROOTCAS`` = 包含 TLS 客户端证书所使用的 CA 证书链文件的完整路径


为节点 CLI 配置 TLS
--------------------------------

当在一个启用了 TLS 的 peer 节点上运行 CLI 命令的时候必须设置下边的环境变量：

* ``CORE_PEER_TLS_ENABLED`` = ``true``
* ``CORE_PEER_TLS_ROOTCERT_FILE`` = 包含 TLS 服务端证书所使用的 CA 证书链文件的完整路径

如果服务器也启用了 TLS 客户端认证，下边的环境变量必须在上边的基础上进行配置：

* ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
* ``CORE_PEER_TLS_CLIENTCERT_FILE`` = 客户端证书完整路径 
* ``CORE_PEER_TLS_CLIENTKEY_FILE`` = 客户端私钥完整路径

当运行一个命令连接排序服务时，就像 `peer channel <create|update|fetch>` 或者 `peer chaincode <invoke|instantiate>` ，
如果排序节点启用了 TLS ，下边的命令行参数也必须提供：

* --tls
* --cafile <fully qualified path of the file that contains cert chain of the orderer CA>

如果排序节点启用了 TLS 客户端认证，下边的参数也必须提供：

* --clientauth
* --keyfile <fully qualified path of the file that contains the client private key>
* --certfile <fully qualified path of the file that contains the client certificate>


排查 TLS 问题
--------------------

在排查 TLS 问题之前，建议在 TLS 客户端和服务端都开启 ``GRPC debug`` 来获得额外的信息。
可以通过设置环境变量 ``FABRIC_LOGGING_SPEC`` 包含 ``grpc=debug`` 来开启 ``GRPC debug`` 。
例如，要设施默认的日志级别为 ``INFO`` 和 GRPC 日志界别为 ``DEBUG`` ，可以设置日志配置
为 ``grpc=debug:info`` 。

如果你在客户端侧看到错误信息 ``remote error: tls: bad certificate`` ，那一般来说就意味着，
TLS 服务端启用了客户端认证而且服务端没有收到正确的客户端证书或者它不信任收到的客户证书。确
认一下客户端发送了它的证书，并且它的证书被 peer 或者排序节点信任的 CA 证书签了名。

如果你在链码的日志中看到了错误信息 ``remote error: tls: bad certificate`` ，请确认你的链码
使用的是 v1.1 或者更新的 Fabric 版本的链码 shim 。如果你的链码不包含 shim 的副本，删除链码
容器并重启节点，这样就会使用当前版本的 shim 重新编译链码容器。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
