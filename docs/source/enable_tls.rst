使用传输层安全性（TLS）保护通信
==========================================================

Fabric支持使用TLS的节点之间的安全通信。 TLS通信可以使用单向（仅服务器）和双向（服务器和客户端）身份验证。

为peer节点配置TLS
-------------------------------

peer节点既是TLS服务器又是TLS客户端。当另一个peer节点、应用程序或客户端与其建立连接时，它是前者；而当它与另一个peer节点或orderer节点建立连接时，则是后者。

要在peer节点上启用TLS，需要设置以下配置属性：
To enable TLS on a peer node set the following peer configuration properties:

 * ``peer.tls.enabled`` = ``true``
 * ``peer.tls.cert.file`` = 包含TLS服务器证书的文件的标准路径
 * ``peer.tls.key.file`` = 包含TLS服务器私钥的文件的标准路径
 * ``peer.tls.rootcert.file`` = 包含颁发TLS服务器证书的证书颁发机构（CA）的链上证书文件的标准路径

默认情况下，在peer节点上启用TLS时，TLS客户端身份验证是关闭的。这意味着在TLS握手期间，peer节点将不会验证客户端（另一个peer节点，应用程序或CLI）的证书。要在对等节点上启用TLS客户端身份验证，需要将peer配置中的属性``peer.tls.clientAuthRequired`` 设置为``true`` ，并将该``peer.tls.clientRootCAs.files`` 属性设置为包含CA证书链的CA链文件，该CA证书链为组织（organization）的客户端发布TLS证书。

默认情况下，per节点在充当TLS服务器和客户端时将使用相同的证书和私钥对。要在客户端使用其他证书和私钥对，请将 ``peer.tls.clientCert.file``和 ``peer.tls.clientKey.file``配置属性分别设置为客户端证书和密钥文件的标准路径。

也可以通过设置以下环境变量来启用具有客户端身份验证的TLS：

 * ``CORE_PEER_TLS_ENABLED`` = ``true``
 * ``CORE_PEER_TLS_CERT_FILE`` = 服务器证书的标准路径
 * ``CORE_PEER_TLS_KEY_FILE`` = 服务器私钥的标准路径
 * ``CORE_PEER_TLS_ROOTCERT_FILE`` = CA链文件的标准路径
 * ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``CORE_PEER_TLS_CLIENTROOTCAS_FILES`` = CA链文件的标准路径
 * ``CORE_PEER_TLS_CLIENTCERT_FILE`` = 客户证书的标准路径
 * ``CORE_PEER_TLS_CLIENTKEY_FILE`` = 客户端密钥的标准路径



在peer节点上启用客户端身份验证后，要求客户端在TLS握手期间发送其证书。如果客户端未发送其证书，则握手将失败，并且peer节点将关闭连接。

当peer节点加入通道时，将从通道的配置区块中读取通道成员的CA根证书链，并将其添加到TLS客户端和服务器CA数据结构中。因此，peer节点间通信和peer节点与orderer节点间通信应该无缝地工作。


为orderer节点配置TLS
---------------------------------

要在orderer节点上启用TLS，需要设置orderer节点的配置属性:

 * ``General.TLS.Enabled`` = ``true``
 * ``General.TLS.PrivateKey`` = 包含服务器私钥的文件的标准路径
 * ``General.TLS.Certificate`` = 包含服务器证书的文件的标准路径
 * ``General.TLS.RootCAs`` = 包含颁发TLS服务器证书的CA的证书链的文件的标准路径

默认情况下，与peer节点一样，orderer节点上的TLS客户端身份验证处于关闭状态。要启用TLS客户端身份验证，需要设置以下配置属性：

 * ``General.TLS.ClientAuthRequired`` = ``true``
 * ``General.TLS.ClientRootCAs`` = 包含颁发TLS服务器证书的CA的证书链的文件的标准路径

也可以通过设置以下环境变量来启用具有客户端身份验证的TLS：

 * ``ORDERER_GENERAL_TLS_ENABLED`` = ``true``
 * ``ORDERER_GENERAL_TLS_PRIVATEKEY`` = 包含服务器私钥的文件的标准路径
 * ``ORDERER_GENERAL_TLS_CERTIFICATE`` = 包含服务器证书的文件的标准路径
 * ``ORDERER_GENERAL_TLS_ROOTCAS`` = 包含颁发TLS服务器证书的CA的证书链的文件的标准路径
 * ``ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``ORDERER_GENERAL_TLS_CLIENTROOTCAS`` = 包含颁发TLS服务器证书的CA的证书链的文件的标准路径

为CLI节点配置TLS
--------------------------------

针对启用了TLS的peer节点运行CLI命令时，必须设置以下环境变量：

* ``CORE_PEER_TLS_ENABLED`` = ``true``
* ``CORE_PEER_TLS_ROOTCERT_FILE`` = 包含颁发TLS服务器证书的CA的证书链的文件的标准路径

如果在远程服务器上也启用了TLS客户端身份验证，则除上述变量外，还必须设置以下变量：

* ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
* ``CORE_PEER_TLS_CLIENTCERT_FILE`` = 客户端证书的标准路径
* ``CORE_PEER_TLS_CLIENTKEY_FILE`` = 客户端私钥的标准路径

当运行连接到orderer节点的命令时，例如`peer channel <create|update|fetch>`或 `peer chaincode <invoke>`，如果在orderer节点上启用了TLS，则还必须指定以下命令行参数：

* --tls
* --cafile <包含订购者CA的证书链的文件的标准路径>

如果在orderer节点上启用了TLS客户端身份验证，则还必须指定以下参数：

* --clientauth
* --keyfile <包含客户端私钥的文件的标准路径>
* --certfile <包含客户端证书的文件的标准路径>


调试TLS问题
--------------------

在调试TLS问题之前，建议同时在TLS客户端和服务器端启用 ``GRPC debug`` 以获取附加信息。要启用 ``GRPC debug``，需要在环境变量``FABRIC_LOGGING_SPEC`` 中加入 ``grpc=debug`` 。例如，如要将默认日志记录级别设置为``INFO`` ，将GRPC日志记录级别设置为 ``DEBUG``，则需先将日志记录规范设置为 ``grpc=debug:info``。

如果您在客户端看到错误消息``remote error: tls: bad certificate`` ，则通常表示TLS服务器已启用客户端身份验证，并且该服务器未收到正确的客户端证书，或者收到了不信任的客户端证书。确保客户端正在发送其证书，并且该证书已被peer节点或orderer节点信任的CA证书所签名。

如果在链码日志中看到错误消息``remote error: tls: bad certificate`` ，请确保链码是使用Fabric v1.1或更高版本的程序构建的。


.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
