Creating a channel
==================

Hyperledger Fabricのネットワークでアセットを作成して転送するには、組織がチャネルに参加する必要があります。
チャネルは、特定の組織間の通信のプライベート・レイヤーであり、ネットワークの他の組織からは見えません。
各チャネルは、チャネルに参加している組織のみが読取りおよび書込みできる個別の台帳で構成されます。
チャネルの参加組織はチャネルにピアを加入し、オーダリングサービスから新しいトランザクションブロックを受け取れます。
ピア、オーダリングノード、CAがネットワークの物理的なインフラストラクチャを形成する一方で、チャネルは組織が相互に接続してやりとりするプロセスです。

チャネルはFabricの運用と管理において基本的な役割を果たすため、チャネルの作成方法についてさまざまな側面から説明する一連のチュートリアルを紹介します。
:doc:`Creating a new channel <create_channel>` では、ネットワーク管理者が実行する必要がある操作手順について説明します。
:doc:`Using configtx.yaml to build a channel configuration <create_channel_config>` では、チャネルの作成に関する概念について説明した後、
:doc:`Channel Policies <channel_policies>` について個別に説明します。


.. toctree::
   :maxdepth: 1

   create_channel.md
   create_channel_config.md
   channel_policies.md

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
