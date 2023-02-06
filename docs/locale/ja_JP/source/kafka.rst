Bringing up a Kafka-based Ordering Service
===========================================

.. _kafka-caveat:

Caveat emptor
-------------

このドキュメントは、読者がKafkaクラスタとZooKeeperアンサンブルをセットアップして、
一般的な利用のために不正アクセスを防いで安全に維持する方法を知っていることを仮定しています。
このガイドの目的は、Kafkaクラスタを使用してHyperledger Fabricのオーダリングサービスノード(OSN)を構築し、
ブロックチェーンネットワークにオーダリングサービスを提供するために必要なステップを明らかにすることです。

ネットワークやトランザクションフローにおけるOrdererの役割については、 :doc:`orderer/ordering_service` ドキュメントを参照してください。

オーダリングノードのセットアップ方法については、 :doc:`orderer_deploy` ドキュメントを参照してください。

Raft オーダリングサービスの設定については、 :doc:`raft_configuration` を参照してください。

Big picture
-----------

各チャネルはKafkaで個別のシングルパーティショントピックにマッピングされます。
OSNが ``Broadcast`` RPC経由でトランザクションを受信すると、
ブロードキャストするクライアントがチャネルへの書き込み権限を持っていることを確認し、
Kafkaの適切なパーティションにトランザクションをリレー(つまり生成)します。
このパーティションはOSNでも使用され、受信したトランザクションをローカルでブロックにグループ化し、
ローカル台帳に保存し、 ``Deliver`` RPCを経由して受信するクライアントに提供されます。
低レベルの詳細については、
`the document that describes how we came to this design <https://docs.google.com/document/d/19JihmW-8blTzN99lAubOfseLUZqdrB6sBR0HsRgCAnY/edit>`_
を参照してください。
**図8** は、上記のプロセスを模式的に表したものです。

Steps
-----

``K`` と ``Z`` は、それぞれKafkaクラスタとZooKeeperアンサンブルのノード数を示すとします。

1. 最低でも ``K`` を4に設定する必要があります。
   (以下のステップ4で説明するように、これはクラッシュ故障耐性を示すために必要な最小ノード数です。
   つまり、4つのブローカーがあれば、1つのブローカーがダウンしても、
   すべてのチャネルは書き込みと読み込みが可能で、新しいチャネルを作成できます)。

2. ``Z`` は3、5、7のいずれかになります。
   これはスプリットブレインシナリオを避けるため、奇数にする必要があります。
   また、単一障害点を避けるため、1より大きい数でなければなりません。
   7台以上のZooKeeperサーバーは過剰とみなされます。

それから、次のように進めます。:

3. Orderers: **Kafkaに関連する情報をネットワークのジェネシスブロックにエンコードします。**
   ``configtxgen`` を使用している場合、 ``configtx.yaml`` を編集します。
   または、システムチャネルのジェネシスブロックでプリセットプロファイルを選択します。

   * ``Orderer.OrdererType`` を ``kafka`` に設定します。
   * ``Orderer.Kafka.Brokers`` には、クラスタ内の *少なくとも2つの* Kafkaブローカーのアドレスを ``IP:port`` 形式で指定します。
     このリストは完全である必要はありません。(これらはブートストラップ・ブローカーです。)

4. Orderers: **最大ブロックサイズを設定します。**
   各ブロックは最大で ``Orderer.AbsoluteMaxBytes`` バイト(ヘッダーを除く)であり、
   この値は ``configtx.yaml`` で設定できます。
   ここで選んだ値を ``A`` とし、メモしておいてください。
   これは、ステップ6でのKafkaブローカーの設定に影響します。

5. Orderers: **ジェネシスブロックを作成します。**
   ``configtxgen`` を使用します。
   上記のステップ3と4で選んだ設定は、システム全体の設定です。
   つまり、すべてのOSNに対するネットワーク全体に適用されます。
   ジェネシスブロックの場所をメモしておきます。

6. Kafka cluster: **Kafkaブローカーを適切に設定します。**
   すべてのKafkaブローカーに以下の項目が設定されていることを確認します。

   * ``unclean.leader.election.enable = false`` — ブロックチェーン環境では、データの一貫性が重要です。
     同期しているレプリカセットの外部からチャネルリーダーを選ぶことはできません。
     さもないと、前のリーダーが作成したオフセットを上書きするリスクがあります。
     その結果、Ordererが作成するブロックチェーンを書き換えてしまいます。

   * ``min.insync.replicas = M`` — ``M`` が ``1 < M < N`` となる値を指定します。
     (以下の ``default.replication.factor`` を参照してください。)
     データは、少なくとも ``M`` のレプリカに書き込まれた時点でコミットされたとみなされます。
     (このとき、これらのレプリカは同期中とみなされ、同期中レプリカセット(ISR)に属します。)
     それ以外の場合、書き込み操作はエラーを返します。
     それから:

     * チャネルデータの書き込み先である ``N`` のうち、最大で ``N-M`` のレプリカが利用できなくなった場合まで、運用は正常に続行されます。

     * さらに多くのレプリカが利用できなくなると、Kafka は ``M`` のISRセットを維持できなくなり、書き込みの受付を停止します。
       読み込みは問題なく行えます。
       ``M`` のレプリカが同期すると、チャネルは再び書き込み可能になります。

   * ``default.replication.factor = N`` — ``N`` が ``N < K`` となる値を指定します。
     レプリケーションファクターが ``N`` の場合、各チャネルは ``N`` 個のブローカーにデータを複製します。
     これらはチャネルのISRセットの候補です。
     上記の ``min.insync.replicas section`` で述べたように、すべてのブローカーが常に利用可能である必要はありません。
     ``N`` は ``K`` よりも *小さく* 設定する必要があります。
     なぜなら、ブローカーが ``N`` よりも少ない場合は、チャネルの作成を続行できないからです。
     つまり、 ``N = K`` と設定すると、ブローカーが1つでもダウンすると、ブロックチェーンネットワーク上に新しいチャネルを作成できなくなります。
     — オーダリングサービスのクラッシュ故障耐性が無くなります。

     ここまで説明した内容から、 ``M`` と ``N`` の最小許容値はそれぞれ2と3になります。
     この設定により、新しいチャネルの作成が進み、すべてのチャネルが書き込み可能な状態を維持します。

   * ``message.max.bytes`` と ``replica.fetch.max.bytes`` には、
     上記のステップ4で ``Orderer.AbsoluteMaxBytes`` に設定した ``A`` より大きな値を設定してください。
     ヘッダを考慮したバッファを追加してください --- 1 MiBあれば十分です。
     次のような条件があります。

     ::

         Orderer.AbsoluteMaxBytes < replica.fetch.max.bytes <= message.max.bytes

     (完全を期すために、 ``message.max.bytes`` は ``socket.request.max.bytes`` よりも必ず小さくなるように注意してください。
     デフォルトでは100MiBに設定されています。
     もし100MiBより大きなブロックを持ちたい場合は、 ``fabric/orderer/kafka/config.go`` の
     ``brokerConfig.Producer.MaxMessageBytes`` にハードコードされている値を編集し、
     バイナリをソースからリビルドする必要があります。
     これは推奨されません。)

   * ``log.retention.ms = -1`` 。オーダリングサービスがKafkaログのプルーニングをサポートするまでは、
     時間ベースの保持を無効にして、セグメントが期限切れになることを防ぎます。
     (サイズベースの保持 — ``log.retention.bytes`` を参照 — は、
     執筆時点ではKafkaのデフォルトで無効になっているので、明示的に設定する必要はありません。)

7. Orderers: **それぞれのOSNをジェネシスブロックに指定します。**
   ``orderer.yaml`` の ``General.BootstrapFile`` を編集し、上記のステップ5で作成したジェネシスブロックを指定します。
   ついでに、そのYAMLファイルの他のすべてのキーが適切に設定されていることを確認します。

8. Orderers: **ポーリング間隔とタイムアウトを調整します。** (オプションのステップ)

   * ``orderer.yaml`` ファイルの ``Kafka.Retry`` セクションでは、
     メタデータ/プロデューサー/コンシューマーの要求頻度や、ソケットのタイムアウトを調整できます
     (これらはすべて、Kafka プロデューサーまたはコンシューマーで見られる設定です。)

   * なお、新たなチャネルが作成された時、および、既存チャネルがリロードされた時
     (再起動したばかりのOrdererの場合)、Ordererは以下の方法でKafkaクラスタとやり取りします。

     * チャネルに対応するKafkaパーティションに対して、Kafkaプロデューサー(ライター)を作成します。
       そのプロデューサーを使用して、パーティションに ``CONNECT`` メッセージをポストします。
       そのパーティションに対して、Kafkaコンシューマー(リーダー)を作成します。

     * これらのステップのいずれかが失敗した場合、繰り返す頻度を調整できます。
       具体的には、 ``Kafka.Retry.ShortInterval`` ごとに再試行し、合計で ``Kafka.Retry.ShortTotal`` となります。
       そして、成功するまで、 ``Kafka.Retry.LongInterval`` ごとに、合計 ``Kafka.Retry.LongTotal`` となります。
       上記のすべてのステップが正常に完了するまで、Ordererがチャネルへの読み書きをできなくなることに注意してください。

9. **OSNとKafkaクラスタがSSLで通信するようにセットアップします。**
   (オプションのステップですが、強くお勧めします。)
   Kafkaクラスタ側については、 `the Confluent guide <https://docs.confluent.io/2.0.0/kafka/ssl.html>`_  を参照し、
   各OSNの ``orderer.yaml`` 内の ``Kafka.TLS`` 配下のキーを設定します。

10. **以下の順番でノードを立ち上げます: ZooKeeperアンサンブル、Kafkaクラスタ、オーダリングサービスノード。**

Additional considerations
-------------------------

1. **好ましいメッセージサイズ**
   上記のステップ4(`Steps`_ セクション参照)では、 ``Orderer.Batchsize.PreferredMaxBytes``
   キーを設定することで、ブロックサイズを好みで設定できます。
   Kafkaは比較的小さなメッセージを扱うときに高いスループットを発揮します。
   1MiB以下の値を心掛けてください。

2. **環境変数による設定の上書き**
   Fabricに付属するKafkaとZookeeperのサンプルDockerイメージ
   (それぞれ ``images/kafka`` と ``images/zookeeper`` を参照) を使用すると、
   KafkaブローカーとZooKeeperサーバーの設定を環境変数で上書きできます。
   設定キーのドットをアンダースコアに置き換えます。
   例えば、 ``KAFKA_UNCLEAN_LEADER_ELECTION_ENABLE=false`` とすると、
   デフォルト値の ``unclean.leader.election.enable`` を上書きできます。
   同じことが、OSNの *ローカル* 設定、つまり ``orderer.yaml`` で設定できる内容にも当てはまります。
   例えば、 ``ORDER_KAFKA_RETRY_SHORTINTERVAL=1s`` とすると、
   ``Orderer.Kafka.Retry.ShortInterval`` のデフォルト値を上書きできます。

Kafka Protocol Version Compatibility
------------------------------------

Fabricは `sarama client library <https://github.com/Shopify/sarama>`_ を使用し、
Kafka 0.10 から 1.0 をサポートするバージョンをベンダリングしていますが、
古いバージョンでも動作することが確認されています。

``orderer.yaml`` の ``Kafka.Version`` キーを使用すると、
Kafkaクラスタのブローカーとの通信に使用するKafkaプロトコルのバージョンを設定できます。
Kafkaブローカーは古いプロトコルのバージョンと下位互換性があります。
Kafkaブローカーは古いプロトコルのバージョンと下位互換性があるため、
Kafkaブローカーを新しいバージョンにアップグレードしても、
``Kafka.Version`` キーの値を更新する必要はありませんが、
古いプロトコルのバージョンを使用していると、Kafkaクラスタは
`performance penalty <https://kafka.apache.org/documentation/#upgrade_11_message_format>`_ を被ることがあります。

Debugging
---------

環境変数 ``FABRIC_LOGGING_SPEC`` に ``DEBUG`` を設定し、 ``orderer.yaml`` で ``Kafka.Verbose`` に ``true`` を設定してください。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
