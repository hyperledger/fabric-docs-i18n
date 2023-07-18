Securing Communication With Transport Layer Security (TLS)
==========================================================

Fabricは、TLSを用いたノード間のセキュアな通信をサポートしています。
TLS通信は、一方向(サーバのみ)および双方向(サーバとクライアント)の両方の認証を使用できます。

Configuring TLS for peers nodes
-------------------------------

ピアノードは、TLSサーバーであると同時にTLSクライアントでもあります。
他のピアノード、アプリケーション、またはCLIがピアノードに接続するときは前者で、ピアノードが他のピアノードやOrdererに接続するときは後者です。

ピアノードでTLSを有効にするには、以下のピア設定プロパティを設定します。

 * ``peer.tls.enabled`` = ``true``
 * ``peer.tls.cert.file`` = TLSサーバ証明書を含んでいるファイルの完全修飾パス
 * ``peer.tls.key.file`` = TLSサーバの秘密鍵を含んでいるファイルの完全修飾パス
 * ``peer.tls.rootcert.file`` = TLSサーバ証明書を発行した認証局(CA)の証明書チェーンを含むファイルの完全修飾パス

デフォルトでは、ピアノードでTLSを有効にすると、TLSクライアント認証はオフになります。
これは、ピアノードがTLSハンドシェイク中にクライアント(別のピアノード、アプリケーション、またはCLI)の証明書を検証しないことを意味します。
ピアノードでTLSクライアント認証を有効にするには、ピア設定プロパティ ``peer.tls.clientAuthRequired`` を ``true`` に設定し、 ``peer.tls.clientRootCAs.files`` プロパティを、組織のクライアント用にTLS証明書を発行した認証局の証明書チェーンを含む認証局チェーンファイルに設定します。

デフォルトでは、ピアノードは同じ証明書と秘密鍵のペアを使用して、TLSサーバーとクライアントとして動作します。
クライアント側で別の証明書と秘密鍵のペアを使用するには、 ``peer.tls.clientCert.file`` と ``peer.tls.clientKey.file`` 設定プロパティに、クライアント証明書と秘密鍵の完全修飾パスをそれぞれ設定します。

クライアント認証付きTLSは、以下の環境変数を設定して有効にすることもできます。

 * ``CORE_PEER_TLS_ENABLED`` = ``true``
 * ``CORE_PEER_TLS_CERT_FILE`` = サーバ証明書の完全修飾パス
 * ``CORE_PEER_TLS_KEY_FILE`` = サーバー秘密鍵の完全修飾パス
 * ``CORE_PEER_TLS_ROOTCERT_FILE`` = 認証局チェーンファイルの完全修飾パス
 * ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``CORE_PEER_TLS_CLIENTROOTCAS_FILES`` = 認証局チェーンファイルの完全修飾パス
 * ``CORE_PEER_TLS_CLIENTCERT_FILE`` = クライアント証明書の完全修飾パス
 * ``CORE_PEER_TLS_CLIENTKEY_FILE`` = クライアント秘密鍵の完全修飾パス

ピアノードでクライアント認証が有効な場合、クライアントはTLSハンドシェイク中にその証明書を送信することが要求されます。
クライアントが証明書を送信しない場合、ハンドシェイクは失敗し、ピアは接続を終了します。

ピアがチャネルに参加すると、チャネルメンバーのルートCA証明書チェーンがチャネルのコンフィギュレーションブロックから読み込まれ、TLSクライアントとサーバーのルートCAのデータ構造に追加されます。
これにより、ピアとピアの通信、および、ピアとOrdererの通信は、シームレスに動作します。

Configuring TLS for orderer nodes
---------------------------------

オーダリングノードでTLSを有効にするには、以下のOrderer設定プロパティを設定します。

 * ``General.TLS.Enabled`` = ``true``
 * ``General.TLS.PrivateKey`` = サーバー秘密鍵を含んでいるファイルの完全修飾パス
 * ``General.TLS.Certificate`` = サーバ証明書を含んでいるファイルの完全修飾パス
 * ``General.TLS.RootCAs`` = TLSサーバ証明書を発行した認証局の証明書チェーンを含むファイルの完全修飾パス

デフォルトでは、TLSクライアント認証はピアと同様にOrdererではオフになっています。
TLSクライアント認証を有効にするには、以下の設定プロパティを設定します。

 * ``General.TLS.ClientAuthRequired`` = ``true``
 * ``General.TLS.ClientRootCAs`` = TLSサーバ証明書を発行した認証局の証明書チェーンを含むファイルの完全修飾パス

クライアント認証付きTLSは、以下の環境変数を設定して有効にすることもできます。

 * ``ORDERER_GENERAL_TLS_ENABLED`` = ``true``
 * ``ORDERER_GENERAL_TLS_PRIVATEKEY`` = サーバー秘密鍵を含んでいるファイルの完全修飾パス
 * ``ORDERER_GENERAL_TLS_CERTIFICATE`` = サーバ証明書を含んでいるファイルの完全修飾パス
 * ``ORDERER_GENERAL_TLS_ROOTCAS`` = TLSサーバ証明書を発行した認証局の証明書チェーンを含むファイルの完全修飾パス
 * ``ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED`` = ``true``
 * ``ORDERER_GENERAL_TLS_CLIENTROOTCAS`` = TLSサーバ証明書を発行した認証局の証明書チェーンを含むファイルの完全修飾パス

Configuring TLS for the peer CLI
--------------------------------

TLS が有効なピアノードに対してピアCLIコマンドを実行する場合、以下の環境変数を設定する必要があります。

* ``CORE_PEER_TLS_ENABLED`` = ``true``
* ``CORE_PEER_TLS_ROOTCERT_FILE`` = TLSサーバ証明書を発行した認証局の証明書チェーンを含むファイルの完全修飾パス

リモートサーバーでTLSクライアント認証も有効になっている場合、上記の変数に加えて、以下の変数を設定する必要があります。

* ``CORE_PEER_TLS_CLIENTAUTHREQUIRED`` = ``true``
* ``CORE_PEER_TLS_CLIENTCERT_FILE`` = クライアント証明書の完全修飾パス
* ``CORE_PEER_TLS_CLIENTKEY_FILE`` = クライアント秘密鍵の完全修飾パス

`peer channel <create|update|fetch>` または `peer chaincode <invoke>` のように、Ordererサービスに接続するコマンドを実行するとき、OrdererでTLS が有効な場合は以下のコマンドライン引数も指定する必要があります。

* --tls
* --cafile <Orderer認証局の証明書チェーンを含むファイルの完全修飾パス>

OrdererでTLSクライアント認証が有効な場合、以下の引数も指定する必要があります。

* --clientauth
* --keyfile <クライアント秘密鍵を含むファイルの完全修飾パス>
* --certfile <クライアント証明書を含むファイルの完全修飾パス>


Debugging TLS issues
--------------------

TLS の問題をデバッグする前に、追加情報を得るために、TLSクライアントとサーバーの両方で ``GRPC debug`` を有効にすることを推奨します。
``GRPC debug`` を有効にするには、環境変数 ``FABRIC_LOGGING_SPEC`` に ``grpc=debug`` を設定します。
例えば、デフォルトのロギングレベルを ``INFO`` に設定し、GRPCのロギングレベルを ``DEBUG`` に設定するには、ロギング設定を ``grpc=debug:info`` に設定します。

クライアント側で ``remote error: tls: bad certificate`` というエラーメッセージが表示されたら、それはTLSサーバーがクライアント認証を有効にしていて、サーバーが正しいクライアント証明書を受け取らなかったか、信頼できないクライアント証明書を受け取ってしまったということを意味します。
クライアントが証明書を送信していることと、それがピアノードまたはオーダリングノードに信頼されているCA証明書のうちの1つによって署名されていることを確認してください。

チェーンコードのログに ``remote error: tls: bad certificate`` というエラーメッセージが表示されたら、チェーンコードがFabric v1.1 以降で提供される chaincode shim を使ってビルドされているかを確認してください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
