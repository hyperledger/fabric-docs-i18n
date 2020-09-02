背书策略
====================

每个链码都有背书策略，背书策略指定了通道上的一组 Peer 节点必须执行链码，并且为执行结果进行背书，以此证明交易是有效的。这些背书策略指定了必须为提案进行背书的组织。

.. note :: 回想一下 **状态**，从区块链数据中分离出来，用键值对表示。更多信息请查看 :doc:`ledger/ledger` 文档。

作为 Peer 节点进行交易验证的一部分，每个 Peer 节点的检查确保了交易保存了合适 **数量** 的背书，并且是指定背书节点的背书。这些背书结果的检查，同样确保了它们是有效的（比如，从有效的证书得到的有效签名）。

需要背书的多种方式
------------------------------------

By default, endorsement policies are specified in the chaincode definition,
which is agreed to by channel members and then committed to a channel (that is,
one endorsement policy covers all of the state associated with a chaincode).

For private data collections, you can also specify an endorsement policy
at the private data collection level, which would override the chaincode
level endorsement policy for any keys in the private data collection, thereby
further restricting which organizations can write to a private data collection.

Finally, there are cases where it may be necessary for a particular public
channel state or private data collection state (a particular key-value pair,
in other words) to have a different endorsement policy.
This **state-based endorsement** allows the chaincode-level or collection-level
endorsement policies to be overridden by a different policy for the specified keys.

为了解释哪些情况下使用这多种背书策略，请考虑在通道上实现汽车交易的情况。创建（也称为“发行”）一辆汽车作为可交易的资产（即把一个键值对存到世界状态）需要满足链码级别的背书策略。下文将详细介绍链码级别的背书策略。

如果代表汽车的键需要特殊的背书策略，该背书策略可以在汽车创建或之后被定义。当下有很多为什么需要特定状态的背书策略的原因，汽车可能具有历史重要性或价值，因此有必要获得持牌估价师的认可。还有，汽车的主人(如果他们是通道的成员)可能还希望确保他们的同伴在交易上签名。这两种情况，**都需要为特殊资产指定，与当前链码默认背书策略不同的背书策略。**

我们将在后面介绍如何定义基于状态的背书策略。但首先，让我们看看如何设置链式代码级的背书策略。

设置链码级背书策略
--------------------------------------------

Chaincode-level endorsement policies are agreed to by channel members when they
approve a chaincode definition for their organization. A sufficient number of
channel members need to approve a chaincode definition to meet the
``Channel/Application/LifecycleEndorsement`` policy, which by default is set to
a majority of channel members, before the definition can be committed to the
channel. Once the definition has been committed, the chaincode is ready to use.
Any invoke of the chaincode that writes data to the ledger will need to be
validated by enough channel members to meet the endorsement policy.

You can specify an endorsement policy for a chaincode using the Fabric SDKs.
For an example, visit the `How to install and start your chaincode <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-chaincode-lifecycle.html>`_
in the Node.js SDK documentation. You can also create an endorsement policy from
your CLI when you approve and commit a chaincode definition with the Fabric peer
binaries by using the ``--signature-policy`` flag.

.. note:: 现在不要担心背书策略语法 (比如 ``'Org1.member'``)，我们后面部分会介绍。

例如:

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

The above command approves the chaincode definition of ``mycc`` with the policy
``AND('Org1.member', 'Org2.member')`` which would require that a member of both
Org1 and Org2 sign the transaction. After a sufficient number of channel members
approve a chaincode definition for ``mycc``, the definition and endorsement
policy can be committed to the channel using the command below:

::

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

注意，如果开启了身份类型 (见 :doc:`msp`), 可以使用 ``PEER`` 角色限定使用 Peer 进行背书。

例如:

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.peer', 'Org2.peer')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

In addition to the specifying an endorsement policy from the CLI or SDK, a
chaincode can also use policies in the channel configuration as endorsement
policies. You can use the ``--channel-config-policy`` flag to select a channel policy with
format used by the channel configuration and by ACLs.

例如：

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --channel-config-policy Channel/Application/Admins --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

If you do not specify a policy, the chaincode definition will use the
``Channel/Application/Endorsement`` policy by default, which requires that a
transaction be validated by a majority of channel members. This policy depends on
the membership of the channel, so it will be updated automatically when organizations
are added or removed from a channel. One advantage of using channel policies is
that they can be written to be updated automatically with channel membership.

If you specify an endorsement policy using the ``--signature-policy`` flag or
the SDK, you will need to update the policy when organizations join or leave the
channel. A new organization added to the channel after the chaincode has been defined
will be able to query a chaincode (provided the query has appropriate authorization as
defined by channel policies and any application level checks enforced by the
chaincode) but will not be able to execute or endorse the chaincode. Only
organizations listed in the endorsement policy syntax will be able sign
transactions.

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

Setting collection-level endorsement policies
---------------------------------------------
Similar to chaincode-level endorsement policies, when you approve and commit
a chaincode definition, you can also specify the chaincode's private data collections
and corresponding collection-level endorsement policies. If a collection-level
endorsement policy is set, transactions that write to a private data collection
key will require that the specified organization peers have endorsed the transaction.

You can use collection-level endorsement policies to restrict which organization
peers can write to the private data collection key namespace, for example to
ensure that non-authorized organizations cannot write to a collection, and to
have confidence that any state in a private data collection has been endorsed
by the required collection organization(s).

The collection-level endorsement policy may be less restrictive or more restrictive
than the chaincode-level endorsement policy and the collection's private data
distribution policy.  For example a majority of organizations may be required
to endorse a chaincode transaction, but a specific organization may be required
to endorse a transaction that includes a key in a specific collection.

The syntax for collection-level endorsement policies exactly matches the syntax
for chaincode-level endorsement policies --- in the collection configuration
you can specify an ``endorsementPolicy`` with either a ``signaturePolicy`` or
``channelConfigPolicy``. For more details see :doc:`private-data-arch`.

.. _key-level-endorsement:

设置键级别的背书策略
--------------------------------------

设置链码级别或者集合级别的背书策略跟对应的链码生命周期有关。可以在通道实例化或者升级对应链码的时候进行设置。

对比来看, 键级别的背书策略可以在链码内更加细粒度的设置和修改。修改键级别的背书策略是常规交易读写集的一部分。

shim API提供了从常规Key设置和获取背书策略的功能。

.. note:: 下文中的 ``ep`` 代表背书策略，它可以用上文介绍的语法所描述，或者下文介绍的函数。每种方法都会生成，可以被 shim API 接受的二进制版本的背书策略。

.. code-block:: Go

    SetStateValidationParameter(key string, ep []byte) error
    GetStateValidationParameter(key string) ([]byte, error)

对于在 Collection 中属于 :doc:`private-data/private-data` 使用以下函数:

.. code-block:: Go

    SetPrivateDataValidationParameter(collection, key string, ep []byte) error
    GetPrivateDataValidationParameter(collection, key string) ([]byte, error)

为了帮助把背书策略序列化成有效的字节数组，shim提供了便利的函数供链码开发者，从组织 MSP 标示符的角度处理背书策略，详情见 `键背书策略 <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/statebased#KeyEndorsementPolicy>`_:

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

把 shim 作为链码的依赖请参考 :ref:`vendoring`。

验证
----------

commit交易时，设置键值的过程和设置键的背书策略的过程是一样的，都会更新键的状态并且使用相同的规则进行验证。

+---------------------+------------------------------------+--------------------------+
| Validation          | no validation parameter set        | validation parameter set |
+=====================+====================================+==========================+
| modify value        | check chaincode or collection ep   | check key-level ep       |
+---------------------+------------------------------------+--------------------------+
| modify key-level ep | check chaincode or collection ep   | check key-level ep       |
+---------------------+------------------------------------+--------------------------+

正如上面讨论的，如果一个键并改变了，并且没有键级别的背书策略，默认会使用链码级别或集合级别的背书策略。设置键级别背书策略的时候，也是使用链码级背书策略，即新的键级别背书策略必须使用已存在的链码背书策略。

如果某个键被修改了，并且键级别的背书策略已经设置，键级别的背书策略就会覆盖链码级别或集合级别背书策略。实际上，键级背书策略可以比链码级别或集合级别背书策略宽松或者严格，因为设置键级背书策略必须满足链码级别或集合级别背书策略，所以没有违反可信的假设。

如果某个键级背书策略被移除（或设为空），链码级别或集合级别背书策略再次变为默认策略。

如果某个交易修改了多个键，并且这些键关联了多个键级背书策略，交易需要满足所有的键级策略才会有效。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
