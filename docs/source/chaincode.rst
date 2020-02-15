链码教程
===================

什么是链码？
------------------

链码是一个程序，可以使用 `Go <https://golang.org>`_ 、`node.js <https://nodejs.org>`_ 、
或者 `Java <https://java.com/en/>`_ 来实现预定义的接口。链码运行在一个和背书节点进程相
隔离的安全的容器中。通过应用程序提交交易来初始化链码和管理账本状态。

一个链码一般用来处理由网络中成员一致认可的商业逻辑，所以可以认为它就是一个“智能合约”。
链码创建的状态仅限于该链码范围内，其他链码不能直接访问。但是在同一个网络中，通过合理
的授权，链码可以让其他链码访问的它状态数据。

两种角色
------------

我们提供了从两种视角来看链码。第一中，从区块链应用或者解决方案开发这的视角的标题为
:doc:`chaincode4ade` 另外一个 :doc:`chaincode4noah` 面向管理区块链网络的维护人员，
他们将使用 Hyperledger Fabric 的 API 来安装、治理链码，但是在开发链码应用的
过程很少调用链码。

Fabric 链码生命周期
------------------------------

The Fabric Chaincode Lifecycle is responsible for managing the installation
of chaincodes and the definition of their parameters before a chaincode is
used on a channel. Starting with Fabric 2.0, governance for chaincodes is fully
decentralized: multiple organizations can use the Fabric Chaincode Lifecycle to
come to agreement on the parameters of a chaincode, such as the chaincode
endorsement policy, before the chaincode is used to interact with the ledger.

The new model offers several improvements over the previous lifecycle:

* **Multiple organizations must agree to the parameters of a chaincode:** In
  the release 1.x versions of Fabric, one organization had the ability to set
  parameters of a chaincode (for instance the endorsement policy) for all other
  channel members. The new Fabric chaincode lifecycle is more flexible since
  it supports both centralized trust models (such as that of the previous
  lifecycle model) as well as decentralized models requiring a sufficient number
  of organizations to agree on an endorsement policy before it goes into effect.

* **Safer chaincode upgrade process:** In the previous chaincode lifecycle,
  the upgrade transaction could be issued by a single organization, creating a
  risk for a channel member that had not yet installed the new chaincode. The
  new model allows for a chaincode to be upgraded only after a sufficient
  number of organizations have approved the upgrade.

* **Easier endorsement policy updates:** Fabric lifecycle allows you to change
  an endorsement policy without having to repackage or reinstall the chaincode.
  Users can also take advantage of a new default policy that requires endorsement
  from a majority of members on the channel. This policy is updated automatically
  when organizations are added or removed from the channel.

* **Inspectable chaincode packages:** The Fabric lifecycle packages chaincode in
  easily readable tar files. This makes it easier to inspect the chaincode
  package and coordinate installation across multiple organizations.

* **Start multiple chaincodes on a channel using one package:** The previous
  lifecycle defined each chaincode on the channel using a name and version that
  was specified when the chaincode package was installed. You can now use a
  single chaincode package and deploy it multiple times with different names
  on the same or different channel.

To learn how more about the new Fabric Lifecycle, visit :doc:`chaincode4noah`.

You can use the Fabric chaincode lifecycle by creating a new channel and setting
the channel capabilities to V2_0. You will not be able to use the old lifecycle
to install, instantiate, or update a chaincode on channels with V2_0 capabilities
enabled. However, you can still invoke chaincode installed using the previous
lifecycle model after you enable V2_0 capabilities.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
