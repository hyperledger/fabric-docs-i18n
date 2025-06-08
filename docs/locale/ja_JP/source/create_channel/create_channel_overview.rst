Creating a channel
==================

Hyperledger Fabricのネットワークでアセットを作成して転送するには、組織がチャネルに参加する必要があります。
チャネルは、特定の組織間の通信のプライベート・レイヤーであり、ネットワークの他の組織からは見えません。
各チャネルは、チャネルに参加している組織のみが読取りおよび書込みできる個別の台帳で構成されます。
チャネルの参加組織はチャネルにピアを加入し、オーダリングサービスから新しいトランザクションブロックを受け取れます。
ピア、オーダリングノード、CAがネットワークの物理的なインフラストラクチャを形成する一方で、チャネルは組織が相互に接続してやりとりするプロセスです。

チャネルはFabricの運用と管理において基本的な役割を果たすため、チャネルの作成方法についてさまざまな側面から説明する一連のチュートリアルを紹介します。
Fabric v2.3では、システムチャネルを必要とせずにチャネルを作成する機能が追加され、プロセスから余分な管理レイヤーが削除されました。
**Create a channel** チュートリアルでは、新しいフローについて説明します。
ネットワークがまだない場合やテストネットワークを使用したい場合は、**Create a channel using the test network** をご覧ください。
システムチャネルを基にチャネルを作成する従来のプロセスは引き続きサポートされており、Fabric v2.2の `Create a channel tutorial <https://hyperledger-fabric.readthedocs.io/en/release-2.2/create_channel/create_channel.html>`_ で説明しています。
各チュートリアルでは、ネットワーク管理者がチャネルを作成するために必要な操作手順について説明しています。より詳細な内容については、 :doc:`create_channel_config` チュートリアルでチャネルの作成に関する概念について説明した後、 :doc:`channel_policies` について個別に説明します。


.. toctree::
   :maxdepth: 1

   create_channel_participation.md
   create_channel_test_net.md
   create_channel_config.md
   channel_policies.md

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
