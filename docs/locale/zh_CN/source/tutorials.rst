教程
=========

应用开发人员可以通过Fabric教程开始构建自己的解决方案。首先在本地机器上部署`测试网络 <./test_network.html>`_，
开始使用Fabric。然后，您可以按照:doc:`deploy_chaincode`教程的步骤部署和测试智能合约。
:doc:`write_first_app`教程介绍了如何使用Fabric SDK提供的API从客户端应用程序调用智能合约。
如需深入了解Fabric应用程序与智能合约如何协同工作，您可以参阅:doc:`developapps/developing_applications`主题。

网络运维人员可以使用:doc:`deploy_chaincode`教程和:doc:`create_channel/create_channel_overview`教程系列
学习管理运行中网络的重要知识。无论是网络运维人员还是应用开发人员，都可以通过`私有数据 <./private_data_tutorial.html>`_
和`CouchDB <./couchdb_tutorial.html>`_教程探索Fabric的重要功能。当您准备在生产环境中部署Hyperledger Fabric时，
请参阅:doc:`deployment_guide_overview`指南。

有两个关于更新通道的教程：:doc:`config_update`和:doc:`updating_capabilities`。:doc:`upgrading_your_components`展示了如何升级组件，
例如Peer节点、排序节点、SDK等。

最后，我们提供了一个如何写基础智能合约的介绍， :doc:`chaincode4ade`  。

.. note:: 如果本文档不能解决你的问题，或者你使用本教程的过程中遇到了其他问题，请阅读 :doc:`questions` 章节来寻求额外的帮助。


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

.. 本文档采用知识共享署名 4.0 国际许可协议授权
   https://creativecommons.org/licenses/by/4.0/