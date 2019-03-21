Securing Communication With Transport Layer Security (TLS) - 利用传输层安全（TLS）进行安全通信
==========================================================

Fabric supports for secure communication between nodes using TLS.  TLS communication
can use both one-way (server only) and two-way (server and client) authentication.

Fabric 支持在节点间使用 TLS 进行安全通信。 TLS 通信可以单向（仅服务端）也可以双向
（服务端和客户端）认证。

Configuring TLS for peers nodes - 为 peer 节点配置 TLS
-------------------------------

A peer node is both a TLS server and a TLS client. It is the former when another peer
node, application, or the CLI makes a connection to it and the latter when it makes
a connection to another peer node or orderer.

peer 节点既可以是 TLS 服务端也可以是 TLS 客户端。当它和另外一个 peer 节点、应用或者 CLI 
连接时它是前者，当它和其他 peer 节点或者排序节点连接时它是后者。

To enable TLS on a peer node set the following peer configuration properties:

为了在 peer 节点上启用 TLS ，需要设置下边这些节点配置的属性：

 * ``peer.tls.enabled`` = ``true``
 * ``peer.tls.cert.file`` = fully qualified path of the file that contains the TLS server
   certificate
 * ``peer.tls.cert.file`` = 包含 TLS 服务证书文件的完整路径
 * ``peer.tls.key.file`` = fully qualified path of the file that contains the TLS server
   private key
 * ``peer.tls.key.file`` = 包含 TLS 服务私钥文件的完整路径
 * ``peer.tls.rootcert.file`` = fully qualified path of the file that contains the
   certificate chain of the certificate authority(CA) that issued TLS server certificate
 * ``peer.tls.rootcert.file`` = 包含用于授权 TLS 服务证书的证书链的完整路径

By default, TLS client authentication is turned off when TLS is enabled on a peer node.
This means that the peer node will not verify the certificate of a client (another peer
node, application, or the CLI) during a TLS handshake. To enable TLS client authentication
on a peer node, set the peer configuration property ``peer.tls.clientAuthRequired`` to
``true`` and set the ``peer.tls.clientRootCAs.files`` property to the CA chain file(s) that
contain(s) the CA certificate chain(s) that issued TLS certificates for your organization's
clients.

默认下，当在一个 peer 节点上启用 TLS 的时候 TLS 客户端授权是关闭的。这就意味着 peer 节点在 
TLS 握手期间不能验证客户端（另外一个 peer 节点、应用或者 CLI）的授权证书。为了在一个 peer 节
点上启用 TLS 客户端授权，将节点配置属性 ``peer.tls.clientAuthRequired`` 设置为 ``true`` 并且
将 ``peer.tls.clientRootCAs.files`` 属性设置为包含 CA 证书链的 CA 链文件，用于验证你组织中客
户端的 TLS 证书。

By default, a peer node will use the same certificate and private key pair when acting as a
TLS server and client.  To use a different certificate and private key pair for the client
side, set the ``peer.tls.clientCert.file`` and ``peer.tls.clientKey.file`` configuration
properties to the fully qualified path of the client certificate and key file,
respectively.

默认下，当一个 peer 节点同时作为 TLS 服务端和客户端的时候，都使用同一个证书和密钥对。如果要在
客户端侧使用不同的证书和密钥对，就分别设置 ``peer.tls.clientCert.file`` 和 
``peer.tls.clientKey.file`` 的配置属性为客户端证书和密钥文件的完整路径。    

TLS with client authentication can also be enabled by setting the following environment
variables:

客户端授权 TLS 也可以通过设置如下环境变量来启用：

 * ``CORE_PEER_TLS_ENABLED`` = ``true``
 * ``CORE_PEER_TLS_CERT_FILE`` = fully qualified path of the server certificate
 * ``CORE_PEER_TLS_CERT_FILE`` = 服务端证书的完整路径
 * ``CORE_PEER_TLS_KEY_FILE`` = fully qualified path of the server private key
 * ``CORE_PEER_TLS_KEY_FILE`` = 服务端私钥的完整路径
 * ``CORE_PEER_TLS_ROOTCERT_FILE`` = fully qualified path of the CA chain file
 * ``CORE_PEER_TLS_ROOTCERT_FILE`` = CA 链文件的完整路径
 * ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``CORE_PEER_TLS_CLIENTROOTCAS_FILES`` = fully qualified path of the CA chain file
 * ``CORE_PEER_TLS_CLIENTROOTCAS_FILES`` = CA 链文件的完整路径
 * ``CORE_PEER_TLS_CLIENTCERT_FILE`` = fully qualified path of the client certificate
 * ``CORE_PEER_TLS_CLIENTCERT_FILE`` = 客户端证书的完整路径
 * ``CORE_PEER_TLS_CLIENTKEY_FILE`` = fully qualified path of the client key
 * ``CORE_PEER_TLS_CLIENTKEY_FILE`` = 客户端私钥的完整路径

When client authentication is enabled on a peer node, a client is required to send its
certificate during a TLS handshake. If the client does not send its certificate, the
handshake will fail and the peer will close the connection.

当 peer 节点的客户端认证启动以后，客户端需要在 TLS 握手期间发送它的证书。如果客户端没有发送它
的证书，握手就会失败，并且节点会关闭连接。

When a peer joins a channel, root CA certificate chains of the channel members are
read from the config block of the channel and are added to the TLS client and server
root CAs data structure. So, peer to peer communication, peer to orderer communication
should work seamlessly.

当一个节点加入通道的时候，会从通道的配置区块中读取通道成员的根 CA 证书链并加入到 TLS 客户端和
服务端的根 CA 数据结构中。所以，peer 节点和 peer 节点之间的通信，peer 节点和排序节点的通信是无
缝连接的。

Configuring TLS for orderer nodes - 配置排序节点的 TLS
---------------------------------

To enable TLS on an orderer node, set the following orderer configuration properties:

启动排序节点的 TLS ，需要设置如下排序节点的配置属性：

 * ``General.TLS.Enabled`` = ``true``
 * ``General.TLS.PrivateKey`` = fully qualified path of the file that contains the server
   private key
 * ``General.TLS.PrivateKey`` = 包含服务端私钥文件的完整路径 
 * ``General.TLS.Certificate`` = fully qualified path of the file that contains the server
   certificate
 * ``General.TLS.Certificate`` = 包含服务端证书的文件的完整路径
 * ``General.TLS.RootCAs`` = fully qualified path of the file that contains the certificate
   chain of the CA that issued TLS server certificate
 * ``General.TLS.RootCAs`` = 包含用于 TLS 服务端证书的 CA 证书链的完整路径

By default, TLS client authentication is turned off on orderer, as is the case with peer.
To enable TLS client authentication, set the following config properties:

默认下，和 peer 节点一样，在排序节点上 TLS 客户端授权是关闭的。启用 TLS 客户端授权，需要设
置如下配置属性：

 * ``General.TLS.ClientAuthRequired`` = ``true``
 * ``General.TLS.ClientRootCAs`` = fully qualified path of the file that contains the
   certificate chain of the CA that issued the TLS server certificate
 * ``General.TLS.ClientRootCAs`` = fully qualified path of the file that contains the

TLS with client authentication can also be enabled by setting the following environment
variables:

 * ``ORDERER_GENERAL_TLS_ENABLED`` = ``true``
 * ``ORDERER_GENERAL_TLS_PRIVATEKEY`` = fully qualified path of the file that contains the
   server private key
 * ``ORDERER_GENERAL_TLS_CERTIFICATE`` = fully qualified path of the file that contains the
   server certificate
 * ``ORDERER_GENERAL_TLS_ROOTCAS`` = fully qualified path of the file that contains the
   certificate chain of the CA that issued TLS server certificate
 * ``ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``ORDERER_GENERAL_TLS_CLIENTROOTCAS`` = fully qualified path of the file that contains
   the certificate chain of the CA that issued TLS server certificate

Configuring TLS for the peer CLI
--------------------------------

The following environment variables must be set when running peer CLI commands against a
TLS enabled peer node:

* ``CORE_PEER_TLS_ENABLED`` = ``true``
* ``CORE_PEER_TLS_ROOTCERT_FILE`` = fully qualified path of the file that contains cert chain
  of the CA that issued the TLS server cert

If TLS client authentication is also enabled on the remote server, the following variables
must to be set in addition to those above:

* ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
* ``CORE_PEER_TLS_CLIENTCERT_FILE`` = fully qualified path of the client certificate
* ``CORE_PEER_TLS_CLIENTKEY_FILE`` = fully qualified path of the client private key

When running a command that connects to orderer service, like `peer channel <create|update|fetch>`
or `peer chaincode <invoke|instantiate>`, following command line arguments must also be specified
if TLS is enabled on the orderer:

* --tls
* --cafile <fully qualified path of the file that contains cert chain of the orderer CA>

If TLS client authentication is enabled on the orderer, the following arguments must be specified
as well:

* --clientauth
* --keyfile <fully qualified path of the file that contains the client private key>
* --certfile <fully qualified path of the file that contains the client certificate>


Debugging TLS issues
--------------------

Before debugging TLS issues, it is advisable to enable ``GRPC debug`` on both the TLS client
and the server side to get additional information. To enable ``GRPC debug``, set the
environment variable ``FABRIC_LOGGING_SPEC`` to include ``grpc=debug``. For example, to
set the default logging level to ``INFO`` and the GRPC logging level to ``DEBUG``, set
the logging specification to ``grpc=debug:info``.

If you see the error message ``remote error: tls: bad certificate`` on the client side, it
usually means that the TLS server has enabled client authentication and the server either did
not receive the correct client certificate or it received a client certificate that it does
not trust. Make sure the client is sending its certificate and that it has been signed by one
of the CA certificates trusted by the peer or orderer node.

If you see the error message ``remote error: tls: bad certificate`` in your chaincode logs,
ensure that your chaincode has been built using the chaincode shim provided with Fabric v1.1
or newer. If your chaincode does not contain a vendored copy of the shim, deleting the
chaincode container and restarting its peer will rebuild the chaincode container using the
current shim version.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
