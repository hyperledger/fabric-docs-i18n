教程
=========
Tutorials
=========

我们提供这个教程来帮助你开始学习 Hyperledger Fabric。第一部分是面向 Hyperledger Fabric **应用开发者** 的， :doc:`write_first_app` 。这一部分将带你体验使用 `Node SDK <https://github.com/hyperledger/fabric-sdk-node>`_ 开发你的第一个 Hyperledger Fabric 区块链应用。对于关注应用开发体验的开发者，请查看  :doc:`developapps/developing_applications`.

Application developers can use the Fabric tutorials to get started building their
own solutions. Start working with Fabric by deploying the `test network <./test_network.html>`_
on your local machine. You can then use the steps provided by the :doc:`deploy_chaincode`
tutorial to deploy and test your smart contracts. The :doc:`write_first_app`
tutorial provides an introduction to how to use the APIs provided by the Fabric
SDKs to invoke smart contracts from your client applications. For an in depth
overview of how Fabric applications and smart contracts work together, you
can visit the :doc:`developapps/developing_applications` topic.

我们还有一个面向 Hyperledger Fabric 网络管理员的教程， :doc:`build_network` 。这一部分将带你体验使用 Hyperledger Fabric 搭建一个区块链网络并提供了一个基础的应用示例来进行测试。

Network operators can use the :doc:`deploy_chaincode` tutorial and the
:doc:`create_channel/create_channel_overview` tutorial series to learn
important aspects of administering a running network. Both network operators and
application developers can use the tutorials on
`Private data <./private_data_tutorial.html>`_ and `CouchDB <./couchdb_tutorial.html>`_
to explore important Fabric features. When you are ready to deploy Hyperledger
Fabric in production, see the guide for :doc:`deployment_guide_overview`.

有两个更新通道的教程： :doc:`config_update` 和 :doc:`updating_capabilities` ， :doc:`upgrading_your_components` 展示了如何升级组件，如 Peer 节点、排序节点、SDK等。

There are two tutorials for updating a channel: :doc:`config_update` and
:doc:`updating_capabilities`, while :doc:`upgrading_your_components` shows how
to upgrade components like peers, ordering nodes, SDKs, and more.

最后，我们提供了两个链码教程。一个面向开发者 :doc:`chaincode4ade` ，另一个面向管理员 :doc:`chaincode4noah` 。

Finally, we provide an introduction to how to write a basic smart contract,
:doc:`chaincode4ade`.

.. note:: 如果本文档不能解决你的问题，或者你使用本教程的过程中遇到了其他问题，请阅读 :doc:`questions` 章节来寻求额外的帮助。

.. note:: If you have questions not addressed by this documentation, or run into
          issues with any of the tutorials, please visit the :doc:`questions`
          page for some tips on where to find additional help.

.. toctree::
   :maxdepth: 1
   :caption: Tutorials

   write_first_app
   tutorial/commercial_paper
   build_network
   config_update.md
   channel_update_tutorial
   private_data_tutorial
   chaincode
   chaincode4ade
   chaincode4noah
   couchdb_tutorial
   videos

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
