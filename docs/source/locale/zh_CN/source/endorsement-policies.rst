背书策略
====================

每个链码都有背书策略，指定通道上的一组 Peer 必须执行链码，并且为执行结果进行背书，证明交易是有效的。这些背书策略指定了必须为 Proposal 进行背书的组织。


.. 注解:: 回想 **state**, 通过键值对表示, 从区块链数据中分离开来。更多信息请查看 :doc:`ledger/ledger` 文档。

作为 Peer 进行交易验证的一部分，每个 Peer 的检查确保了交易保存了合适 **数量** 的背书，并且是指定背书节点的背书。这些背书结果的检查，同样确保了它们是有效的（比如，从有效的证书得到的有效签名）。


需要背书的2种方式
-------------------------------

默认的, 在某个通道上实例化或升级链码时会指定背书策略（即，一个背书策略会覆盖和某个链码关联的所有状态）。

然而，对于某些特殊的状态（特殊的键值对）场景下，需要不同的背书策略。**基于状态的背书策略**允许对特殊的 Key 覆盖链码默认的背书策略。

为了解释哪些情况下使用这两种背书策略，请考虑在通道上实现汽车交易的情况。创建（也称为“发行”）一辆汽车作为可交易的资产（即把一个键值对存到世界状态）需要满足链码级别的背书策略。下文将详细介绍链码级别的背书策略。

如果汽车需要特殊的背书策略，该背书策略可以在汽车创建或之后被定义。当下有很多为什么需要特定状态的背书策略的原因，汽车可能具有历史重要性或价值，因此有必要获得持牌估价师的认可。还有，汽车的主人(如果他们是通道的成员)可能还希望确保他们的同伴在交易上签名。这两种情况，**都需要为特殊资产指定，与当前链码默认背书策略不同的背书策略。**

我们将在后面介绍如何定义基于状态的背书策略。但首先，让我们看看如何设置链式代码级的背书策略。

设置链码级背书策略
--------------------------------------------

链码级背书策略可以在示例话时使用SDK（使用SDK的样例请查看 <https://github.com/hyperledger/fabric-sdk-node/blob/f8ffa90dc1b61a4a60a6fa25de760c647587b788/test/integration/e2e/e2eUtils.js#L178>`）或者在 Peer 的CLI里使用 ``-P`` 指定。 can be specified at 

.. 注解:: 现在不要担心背书策略语法 (比如 ``'Org1.member'``)，我们后面部分会介绍。

比如:

::

    peer chaincode instantiate -C <channelid> -n mycc -P "AND('Org1.member', 'Org2.member')"

该命令部署了链码 ``mycc`` ("my chaincode") 并指定背书策略
``AND('Org1.member', 'Org2.member')``，它要求 Org1 和 Org2的任一成员对交易进行签名。

注意，如果开启了身份分类 (见 :doc:`msp`), 可以使用 ``PEER`` 角色限定使用 Peer 进行背书。

比如:

::

    peer chaincode instantiate -C <channelid> -n mycc -P "AND('Org1.peer', 'Org2.peer')"

链码实例化后，新加入的组织可以查询链码（如果查询具有通道策略级别的授权以及链码所规定的应用层检查），但不能执行和未链码进行背书。需要修改背书策略，让新组织能够确认交易。

.. 注解:: 如果在实例化时未指定背书策略，背书策略默认为通道中任何组织的任何成员。比如，一个由 Org1 和 Org2 组成的通道，默认的背书策略是 "OR('Org1.member', 'Org2.member')"。

背书策略语法
~~~~~~~~~~~~~~~~~~~~~~~~~

正如你上面所看到了，策略是使用主体来表达的（主题是跟角色匹配的）。主体可以描述为 ``'MSP.ROLE'``， ``MSP`` 代表了 MSP ID， ``ROLE`` 是以下4个其中之一：``member``, ``admin``, ``client``, and
``peer``。

以下是几个有效的主体示例:

  - ``'Org0.admin'``:  ``Org0`` MSP 的任何管理员
  - ``'Org1.member'``: ``Org1`` MSP 的任何成员
  - ``'Org1.client'``: ``Org1`` MSP 的任何客户端
  - ``'Org1.peer'``: ``Org1`` MSP 的任何 Peer

语法是:

``EXPR(E[, E...])``

``EXPR`` 可以是 ``AND``, ``OR``, 或者 ``OutOf``, 并且 ``E`` 是一个以上语法的主体或者另外一个 ``EXPR``。

比如:
  - ``AND('Org1.member', 'Org2.member', 'Org3.member')`` 要求3个组织的都至少一个成员进行签名。
  - ``OR('Org1.member', 'Org2.member')`` 要求组织1或者组织2的任一成员进行签名。
  - ``OR('Org1.member', AND('Org2.member', 'Org3.member'))`` 要求组织1的任一成员签名，或者组织2和组织3的任一成员，分别进行签名。
  - ``OutOf(1, 'Org1.member', 'Org2.member')``, 等价于``OR('Org1.member', 'Org2.member')``。
  - 类似的, ``OutOf(2, 'Org1.member', 'Org2.member')`` 等价于
    ``AND('Org1.member', 'Org2.member')``, ``OutOf(2, 'Org1.member',
    'Org2.member', 'Org3.member')`` 等价于 ``OR(AND('Org1.member',
    'Org2.member'), AND('Org1.member', 'Org3.member'), AND('Org2.member',
    'Org3.member'))``.

.. _key-level-endorsement:

设置键级别的背书策略
--------------------------------------

设置背书策略跟对应的链码声明周期相关联。可以在通道实例化或者升级对应链码的时候进行设置。

对比来看, 键级别的背书策略可以在链码内更加细粒度的设置和修改。修改键级别的背书策略是常规交易读写集的一部分。

shim API提供了从常规Key设置和获取背书策略的功能。

.. 注解:: 下文中的 ``ep`` 代表背书策略，它可以用上文介绍的语法所描述，或者下文介绍的函数。每种方法都会生成，可以被 shim API 接受的二进制版本的背书策略。

.. code-block:: Go

    SetStateValidationParameter(key string, ep []byte) error
    GetStateValidationParameter(key string) ([]byte, error)

对于在 Collection 中属于 :doc:`private-data/private-data` 使用以下函数:

.. code-block:: Go

    SetPrivateDataValidationParameter(collection, key string, ep []byte) error
    GetPrivateDataValidationParameter(collection, key string) ([]byte, error)

为了帮助把背书策略序列化成有效的字节数组，shim提供了便利的函数供链码开发者，从组织 MSP 标示符的角度处理背书策略，详情见 `键背书策略 <https://godoc.org/github.com/hyperledger/fabric/core/chaincode/shim/ext/statebased#KeyEndorsementPolicy>`_:

.. code-block:: Go

    type KeyEndorsementPolicy interface {
        // Policy returns the endorsement policy as bytes
        Policy() ([]byte, error)

        // AddOrgs adds the specified orgs to the list of orgs that are required
        // to endorse
        AddOrgs(roleType RoleType, organizations ...string) error

        // DelOrgs delete the specified channel orgs from the existing key-level endorsement
        // policy for this KVS key. If any org is not present, an error will be returned.
        DelOrgs(organizations ...string) error

        // ListOrgs returns an array of channel orgs that are required to endorse changes
        ListOrgs() ([]string)
    }

比如，当两个组织要求为键值的改变背书时，需要设置键背书策略，通过把 ``MSPIDs`` 传递给 ``AddOrgs()`` 然后调用 ``Policy()`` 来构建字节数组格式的背书策略，之后传递给 ``SetStateValidationParameter()``。

把 shim 作为链码的依赖请参考:ref:`vendoring`。

验证
----------

commit交易时，设置键值的过程和设置键的背书策略的过程是一样的，都会更新键的状态并且使用相同的规则进行验证。

+---------------------+-----------------------------+--------------------------+
| 验证                 | 没有验证参数集合              | 验证参数集合               |
+=====================+=============================+==========================+
| 修改值               | 检查链码背书策略               | 检查键级别背书策略         |
+---------------------+-----------------------------+--------------------------+
| 修改键级别背书策略     | 检查链码背书策略               | 检查键级别背书策略         |
+---------------------+-----------------------------+--------------------------+

正如上面讨论的，如果一个键并改变了，并且没有键级别的背书策略，默认会使用链码级别的背书策略。设置键级别背书策略的时候，也是使用链码级背书策略，即新的键级别背书策略必须使用已存在的链码背书策略。

如果某个键被修改了，并且键级别的背书策略已经设置，键级别的背书策略就会覆盖链码背书策略。实际上，键级背书策略可以比链码背书策略宽松或者严格，因为设置键级背书策略必须满足链码背书策略，所以没有违反可信的假设。

如果某个键级背书策略被移除（或设为空），链码背书策略再次变为默认策略。

如果某个交易修改了多个键，并且这些键关联了多个键级背书策略，交易需要满足所有的键级策略才会有效。


.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
