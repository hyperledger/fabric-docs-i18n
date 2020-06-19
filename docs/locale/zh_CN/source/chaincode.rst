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
他们将使用 Hyperledger Fabric 的 API 来安装、实例化和升级链码，但是在开发链码应用的
过程很少调用链码。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/