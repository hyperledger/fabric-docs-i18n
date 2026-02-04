教程
=========

应用开发人员可以使用 Fabric 教程来开始构建他们自己的解决方案。
你可以先在本地机器上部署 `测试网络 <./test_network.html>`， 来开始使用 Fabric。
随后，你可以按照 :doc:`deploy_chaincode` 教程提供的步骤来部署和测试智能合约。
:doc:`write_first_app` 教程提供了一个入门指南，介绍如何使用 Fabric SDK 提供的 API，从客户端应用程序中调用智能合约。
如需深入了解 Fabric 应用程序和智能合约如何协同工作，可以参考 :doc:`developapps/developing_applications` 。

网络运维人员可以通过 :doc:`deploy_chaincode` 教程和 :doc:`create_channel/create_channel_overview` 系列教程来学习管理运行中网络的重要知识。
无论是网络运维还是应用开发人员，都可以通过 `私有数据 <./private_data_tutorial.html>` 和 `CouchDB <./couchdb_tutorial.html>` 教程来探索 Fabric 的重要功能。
当你准备在生产环境中部署 Hyperledger Fabric 时，请参考 :doc:`deployment_guide_overview` 指南。

有两个关于更新通道的教程：:doc:`config_update` 和 :doc:`updating_capabilities`。
此外，:doc:`upgrading_your_components` 展示了如何升级组件，例如 Peer 节点、排序节点、SDK 等。

最后，我们提供了一个关于如何编写基础智能合约的介绍：:doc:`chaincode4ade`。

.. note:: 如果本文档不能解决你的问题，或者在使用本教程的过程中遇到了其他问题，请阅读 :doc:`questions` 章节来寻求额外的帮助。


.. toctree::
   :maxdepth: 1
   :caption: 教程

   test_network
   deploy_chaincode.md
   write_first_app
   tutorial/commercial_paper
   private_data_tutorial
   couchdb_tutorial
   create_channel/create_channel_overview.md
   channel_update_tutorial
   config_update.md
   chaincode4ade
   videos

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/