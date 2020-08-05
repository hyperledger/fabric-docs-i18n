创建通道
==================

为了在Hyperledger Fabric网络上创建和转移资产，一个组织需要加入一个通道。
通道是特定组织间交流的私有层并且对其它网络成员不可见。每个通道由单独的分隔的帐本组成，该分隔的帐本只能
被通道成员读取和写入，他们的节点被允许加入到该通道并接收
来自排序服务的新交易块。而在Peer节点、节点和
CA构成的物理基础网络中，通道是组织间和组织内部交流的过程。

由于通道在Fabric运营和治理中发挥的基础性作用，我们提供一系列的教程，将涵盖如何创建通道的不同方面
。:doc:`create_channel`教程描述了网络管理员需要执行的操作步骤。
:doc:`create_channel_config`教程介绍了创建一个通道的概念
，然后单独讨论:doc：'channel_policies'。 

.. toctree::
   :maxdepth: 1

   create_channel.md
   create_channel_config.md
   channel_policies.md

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
