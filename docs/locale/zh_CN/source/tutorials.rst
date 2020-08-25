教程
=========

Application developers can use the Fabric tutorials to get started building their
own solutions. Start working with Fabric by deploying the `test network <./test_network.html>`_
on your local machine. You can then use the steps provided by the :doc:`deploy_chaincode`
tutorial to deploy and test your smart contracts. The :doc:`write_first_app`
tutorial provides an introduction to how to use the APIs provided by the Fabric
SDKs to invoke smart contracts from your client applications. For an in depth
overview of how Fabric applications and smart contracts work together, you
can visit the :doc:`developapps/developing_applications` topic.

Network operators can use the :doc:`deploy_chaincode` tutorial and the
:doc:`create_channel/create_channel_overview` tutorial series to learn
important aspects of administering a running network. Both network operators and
application developers can use the tutorials on
`Private data <./private_data_tutorial.html>`_ and `CouchDB <./couchdb_tutorial.html>`_
to explore important Fabric features. When you are ready to deploy Hyperledger
Fabric in production, see the guide for :doc:`deployment_guide_overview`.

有两个更新通道的教程： :doc:`config_update` 和 :doc:`updating_capabilities` ， :doc:`upgrading_your_components` 展示了如何升级组件，如 Peer 节点、排序节点、SDK等。

最后，我们提供了一个如何写基础智能合约的介绍， :doc:`chaincode4ade`  。

.. note:: 如果本文档不能解决你的问题，或者你使用本教程的过程中遇到了其他问题，请阅读 :doc:`questions` 章节来寻求额外的帮助。


.. toctree::
   :maxdepth: 1
   :caption: Tutorials

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