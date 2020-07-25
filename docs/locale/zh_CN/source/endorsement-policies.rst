背书策略
====================
Endorsement policies
====================

每个链码都有背书策略，背书策略指定了通道上的一组 Peer 节点必须执行链码，并且为执行结果进行背书，以此证明交易是有效的。这些背书策略指定了必须为提案进行背书的组织。

Every chaincode has an endorsement policy which specifies the set of peers on
a channel that must execute chaincode and endorse the execution results in
order for the transaction to be considered valid. These endorsement policies
define the organizations (through their peers) who must "endorse" (i.e., approve
of) the execution of a proposal.

.. note:: 回想一下 **状态**，从区块链数据中分离出来，用键值对表示。更多信息请查看 :doc:`ledger/ledger` 文档。

.. note :: Recall that **state**, represented by key-value pairs, is separate
           from blockchain data. For more on this, check out our :doc:`ledger/ledger`
           documentation.

作为 Peer 节点进行交易验证的一部分，每个 Peer 节点的检查确保了交易保存了合适 **数量** 的背书，并且是指定背书节点的背书。这些背书结果的检查，同样确保了它们是有效的（比如，从有效的证书得到的有效签名）。

As part of the transaction validation step performed by the peers, each validating
peer checks to make sure that the transaction contains the appropriate **number**
of endorsements and that they are from the expected sources (both of these are
specified in the endorsement policy). The endorsements are also checked to make
sure they're valid (i.e., that they are valid signatures from valid certificates).

需要背书的多种方式
------------------------------------

Multiple ways to require endorsement
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

To illustrate the circumstances in which the various types of endorsement policies
might be used, consider a channel on which cars are being exchanged. The "creation"
--- also known as "issuance" -- of a car as an asset that can be traded (putting
the key-value pair that represents it into the world state, in other words) would
have to satisfy the chaincode-level endorsement policy. To see how to set a
chaincode-level endorsement policy, check out the section below.

如果代表汽车的键需要特殊的背书策略，该背书策略可以在汽车创建或之后被定义。当下有很多为什么需要特定状态的背书策略的原因，汽车可能具有历史重要性或价值，因此有必要获得持牌估价师的认可。还有，汽车的主人(如果他们是通道的成员)可能还希望确保他们的同伴在交易上签名。这两种情况，**都需要为特殊资产指定，与当前链码默认背书策略不同的背书策略。**

If the key representing the car requires a specific endorsement policy, it can be
defined either when the car is created or afterwards. There are a number of reasons
why it might be necessary or preferable to set a state-specific endorsement policy. The
car might have historical importance or value that makes it necessary to have the
endorsement of a licensed appraiser. Also, the owner of the car (if they're a
member of the channel) might also want to ensure that their peer signs off on a
transaction. In both cases, **an endorsement policy is required for a particular
asset that is different from the default endorsement policies for the other
assets associated with that chaincode.**

我们将在后面介绍如何定义基于状态的背书策略。但首先，让我们看看如何设置链式代码级的背书策略。

We'll show you how to define a state-based endorsement policy in a subsequent
section. But first, let's see how we set a chaincode-level endorsement policy.

设置链码级背书策略
--------------------------------------------

Setting chaincode-level endorsement policies
--------------------------------------------

Chaincode-level endorsement policies are agreed to by channel members when they
approve a chaincode definition for their organization. A sufficient number of
channel members need to approve a chaincode definition to meet the
``Channel/Application/LifecycleEndorsement`` policy, which by default is set to
a majority of channel members, before the definition can be committed to the
channel. Once the definition has been committed, the chaincode is ready to use.
Any invoke of the chaincode that writes data to the ledger will need to be
validated by enough channel members to meet the endorsement policy.

You can specify an endorsement policy for a chainocode using the Fabric SDKs.
For an example, visit the `How to install and start your chaincode <https://hyperledger.github.io/fabric-sdk-node/master/tutorial-chaincode-lifecycle.html>`_
in the Node.js SDK documentation. You can also create an endorsement policy from
your CLI when you approve and commit a chaincode definition with the Fabric peer
binaries by using the ``—-signature-policy`` flag.

You can specify an endorsement policy for a chaincode using the Fabric SDKs.
For an example, visit the `How to install and start your chaincode <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-chaincode-lifecycle.html>`_
in the Node.js SDK documentation. You can also create an endorsement policy from
your CLI when you approve and commit a chaincode definition with the Fabric peer
binaries by using the ``--signature-policy`` flag.

.. note:: 现在不要担心背书策略语法 (比如 ``'Org1.member'``)，我们后面部分会介绍。

.. note:: Don't worry about the policy syntax (``'Org1.member'``, et all) right
          now. We'll talk more about the syntax in the next section.

例如:

For example:

::

    peer lifecycle chaincode approveformyorg --channelID mychannel —-signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

The above command approves the chaincode definition of ``mycc`` with the policy
``AND('Org1.member', 'Org2.member')`` which would require that a member of both
Org1 and Org2 sign the transaction. After a sufficient number of channel members
approve a chaincode definition for ``mycc``, the definition and endorsement
policy can be committed to the channel using the command below:

::

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel —-signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

    peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID mychannel --signature-policy "AND('Org1.member', 'Org2.member')" --name mycc --version 1.0 --sequence 1 --init-required --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

注意，如果开启了身份类型 (见 :doc:`msp`), 可以使用 ``PEER`` 角色限定使用 Peer 进行背书。

Notice that, if the identity classification is enabled (see :doc:`msp`), one can
use the ``PEER`` role to restrict endorsement to only peers.

例如:

For example:


::

    peer lifecycle chaincode approveformyorg --channelID mychannel —-signature-policy "AND('Org1.peer', 'Org2.peer')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

    peer lifecycle chaincode approveformyorg --channelID mychannel --signature-policy "AND('Org1.peer', 'Org2.peer')" --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

In addition to the specifying an endorsement policy from the CLI or SDK, a
chaincode can also use policies in the channel configuration as endorsement
policies. You can use the ``--channel-config-policy``flag to select a channel policy with
format used by the channel configuration and by ACLs.

In addition to the specifying an endorsement policy from the CLI or SDK, a
chaincode can also use policies in the channel configuration as endorsement
policies. You can use the ``--channel-config-policy`` flag to select a channel policy with
format used by the channel configuration and by ACLs.

例如：

For example:

::

    peer lifecycle chaincode approveformyorg --channelID mychannel --channel-config-policy Channel/Application/Admins --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

    peer lifecycle chaincode approveformyorg --channelID mychannel --channel-config-policy Channel/Application/Admins --name mycc --version 1.0 --package-id mycc_1:3a8c52d70c36313cfebbaf09d8616e7a6318ababa01c7cbe40603c373bcfe173 --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --waitForEvent

If you do not specify a policy, the chaincode definition will use the
``Channel/Application/Endorsement`` policy by default, which requires that a
transaction be validated by a majority of channel members. This policy depends on
the membership of the channel, so it will be updated automatically when organizations
are added or removed from a channel. One advantage of using channel policies is
that they can be written to be updated automatically with channel membership.

If you specify an endorsement policy using the ``—-signature-policy`` flag or
the SDK, you will need to update the policy when organizations join or leave the
channel. A new organization added to the channel after the chaincode has been defined
will be able to query a chaincode (provided the query has appropriate authorization as
defined by channel policies and any application level checks enforced by the
chaincode) but will not be able to execute or endorse the chaincode. Only
organizations listed in the endorsement policy syntax will be able sign
transactions.

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

Endorsement policy syntax
~~~~~~~~~~~~~~~~~~~~~~~~~

正如你上面所看到了，策略是使用主体来表达的（主题是跟角色匹配的）。主体可以描述为 ``'MSP.ROLE'``， ``MSP`` 代表了 MSP ID， ``ROLE`` 是以下4个其中之一：``member``, ``admin``, ``client``, and
``peer``。

As you can see above, policies are expressed in terms of principals
("principals" are identities matched to a role). Principals are described as
``'MSP.ROLE'``, where ``MSP`` represents the required MSP ID and ``ROLE``
represents one of the four accepted roles: ``member``, ``admin``, ``client``, and
``peer``.

以下是几个有效的主体示例:

Here are a few examples of valid principals:

  - ``'Org0.admin'``:  ``Org0`` MSP 的任何管理员
  - ``'Org1.member'``: ``Org1`` MSP 的任何成员
  - ``'Org1.client'``: ``Org1`` MSP 的任何客户端
  - ``'Org1.peer'``: ``Org1`` MSP 的任何 Peer

  - ``'Org0.admin'``: any administrator of the ``Org0`` MSP
  - ``'Org1.member'``: any member of the ``Org1`` MSP
  - ``'Org1.client'``: any client of the ``Org1`` MSP
  - ``'Org1.peer'``: any peer of the ``Org1`` MSP

语法是:

The syntax of the language is:

``EXPR(E[, E...])``

``EXPR`` 可以是 ``AND``, ``OR``, 或者 ``OutOf``, 并且 ``E`` 是一个以上语法的主体或者另外一个 ``EXPR``。

Where ``EXPR`` is either ``AND``, ``OR``, or ``OutOf``, and ``E`` is either a
principal (with the syntax described above) or another nested call to ``EXPR``.

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

For example:
  - ``AND('Org1.member', 'Org2.member', 'Org3.member')`` requests one signature
    from each of the three principals.
  - ``OR('Org1.member', 'Org2.member')`` requests one signature from either one
    of the two principals.
  - ``OR('Org1.member', AND('Org2.member', 'Org3.member'))`` requests either one
    signature from a member of the ``Org1`` MSP or one signature from a member
    of the ``Org2`` MSP and one signature from a member of the ``Org3`` MSP.
  - ``OutOf(1, 'Org1.member', 'Org2.member')``, which resolves to the same thing
    as ``OR('Org1.member', 'Org2.member')``.
  - Similarly, ``OutOf(2, 'Org1.member', 'Org2.member')`` is equivalent to
    ``AND('Org1.member', 'Org2.member')``, and ``OutOf(2, 'Org1.member',
    'Org2.member', 'Org3.member')`` is equivalent to ``OR(AND('Org1.member',
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

Setting key-level endorsement policies
--------------------------------------

设置链码级别或者集合级别的背书策略跟对应的链码生命周期有关。可以在通道实例化或者升级对应链码的时候进行设置。

Setting regular chaincode-level or collection-level endorsement policies is tied to
the lifecycle of the corresponding chaincode. They can only be set or modified when
defining the chaincode on a channel.

对比来看, 键级别的背书策略可以在链码内更加细粒度的设置和修改。修改键级别的背书策略是常规交易读写集的一部分。

In contrast, key-level endorsement policies can be set and modified in a more
granular fashion from within a chaincode. The modification is part of the
read-write set of a regular transaction.

shim API提供了从常规Key设置和获取背书策略的功能。

The shim API provides the following functions to set and retrieve an endorsement
policy for/from a regular key.

.. 注解:: 下文中的 ``ep`` 代表背书策略，它可以用上文介绍的语法所描述，或者下文介绍的函数。每种方法都会生成，可以被 shim API 接受的二进制版本的背书策略。

.. note:: ``ep`` below stands for the "endorsement policy", which can be expressed
          either by using the same syntax described above or by using the
          convenience function described below. Either method will generate a
          binary version of the endorsement policy that can be consumed by the
          basic shim API.

.. code-block:: Go

    SetStateValidationParameter(key string, ep []byte) error
    GetStateValidationParameter(key string) ([]byte, error)

对于在 Collection 中属于 :doc:`private-data/private-data` 使用以下函数:

For keys that are part of :doc:`private-data/private-data` in a collection the
following functions apply:

.. code-block:: Go

    SetPrivateDataValidationParameter(collection, key string, ep []byte) error
    GetPrivateDataValidationParameter(collection, key string) ([]byte, error)

为了帮助把背书策略序列化成有效的字节数组，shim提供了便利的函数供链码开发者，从组织 MSP 标示符的角度处理背书策略，详情见 `键背书策略 <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/statebased#KeyEndorsementPolicy>`_:

To help set endorsement policies and marshal them into validation
parameter byte arrays, the Go shim provides an extension with convenience
functions that allow the chaincode developer to deal with endorsement policies
in terms of the MSP identifiers of organizations, see `KeyEndorsementPolicy <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/statebased#KeyEndorsementPolicy>`_:

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

For example, to set an endorsement policy for a key where two specific orgs are
required to endorse the key change, pass both org ``MSPIDs`` to ``AddOrgs()``,
and then call ``Policy()`` to construct the endorsement policy byte array that
can be passed to ``SetStateValidationParameter()``.

把 shim 作为链码的依赖请参考:ref:`vendoring`。

To add the shim extension to your chaincode as a dependency, see :ref:`vendoring`.

验证
----------

Validation
----------

commit交易时，设置键值的过程和设置键的背书策略的过程是一样的，都会更新键的状态并且使用相同的规则进行验证。

At commit time, setting a value of a key is no different from setting the
endorsement policy of a key --- both update the state of the key and are
validated based on the same rules.

+---------------------+------------------------------------+--------------------------+
| Validation          | no validation parameter set        | validation parameter set |
+=====================+====================================+==========================+
| modify value        | check chaincode or collection ep   | check key-level ep       |
+---------------------+------------------------------------+--------------------------+
| modify key-level ep | check chaincode or collection ep   | check key-level ep       |
+---------------------+------------------------------------+--------------------------+

正如上面讨论的，如果一个键并改变了，并且没有键级别的背书策略，默认会使用链码级别或集合级别的背书策略。设置键级别背书策略的时候，也是使用链码级背书策略，即新的键级别背书策略必须使用已存在的链码背书策略。

As we discussed above, if a key is modified and no key-level endorsement policy
is present, the chaincode-level or collection-level endorsement policy applies by default.
This is also true when a key-level endorsement policy is set for a key for the first time
--- the new key-level endorsement policy must first be endorsed according to the
pre-existing chaincode-level or collection-level endorsement policy.

如果某个键被修改了，并且键级别的背书策略已经设置，键级别的背书策略就会覆盖链码级别或集合级别背书策略。实际上，键级背书策略可以比链码级别或集合级别背书策略宽松或者严格，因为设置键级背书策略必须满足链码级别或集合级别背书策略，所以没有违反可信的假设。

If a key is modified and a key-level endorsement policy is present, the key-level
endorsement policy overrides the chaincode-level or collection-level endorsement policy.
In practice, this means that the key-level endorsement policy can be either less restrictive
or more restrictive than the chaincode-level or collection-level endorsement policies.
Because the chaincode-level or collection-level endorsement policy must be satisfied in order
to set a key-level endorsement policy for the first time, no trust assumptions have been violated.

如果某个键级背书策略被移除（或设为空），链码级别或集合级别背书策略再次变为默认策略。

If a key's endorsement policy is removed (set to nil), the chaincode-level
or collection-level endorsement policy becomes the default again.

如果某个交易修改了多个键，并且这些键关联了多个键级背书策略，交易需要满足所有的键级策略才会有效。

If a transaction modifies multiple keys with different associated key-level
endorsement policies, all of these policies need to be satisfied in order
for the transaction to be valid.

