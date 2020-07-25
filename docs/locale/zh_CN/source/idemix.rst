使用身份混合器（Identity Mixer）的 MSP 实现
==========================================================================
MSP Implementation with Identity Mixer
======================================

什么是 Idemix？
---------------

What is Idemix?
---------------

Idemix 是一个加密协议套件，提供了强大的身份验证和隐私保护功能，比如，**匿名（anonymity）**，这是一个不用明示交易者的身份即可执行交易的功能；还有，**不可链接性（unlinkability**），该特性可以使一个身份发送多个交易时，不能显示出这些交易是由同一个身份发出的。

Idemix is a cryptographic protocol suite, which provides strong authentication as
well as privacy-preserving features such as **anonymity**, the ability to transact
without revealing the identity of the transactor, and **unlinkability**, the
ability of a single identity to send multiple transactions without revealing
that the transactions were sent by the same identity.

在 Idemix 流程中包括三中角色： **用户（user）**、**发布者（issuer）** 和 **验证者（verifier）**。

There are three actors involved in an Idemix flow: **user**, **issuer**, and
**verifier**.

.. image:: images/idemix-overview.png

* 发布者以数字证书的形式发布一组用户属性，以下称此证书为“凭证（credential）”。
* 用户随后会生成一个 “`零知识证明 <https://en.wikipedia.org/wiki/Zero-"knowledge_proof>`_” 来证明自己拥有这个凭证，并且只选择性的公开自己想公开的属性。这个证明，因为是零知识的，所以不会向验证者、发布者或任何人透露任何额外信息。

* An issuer certifies a set of user's attributes are issued in the form of a
  digital certificate, hereafter called "credential".
* The user later generates a "`zero-knowledge proof <https://en.wikipedia.org/wiki/Zero-knowledge_proof>`_"
  of possession of the credential and also selectively discloses only the
  attributes the user chooses to reveal. The proof, because it is zero-knowledge,
  reveals no additional information to the verifier, issuer, or anyone else.

例如，假设 “Alice” 需要向 Bob（商店职员）证明她有机动车管理局（DMV）发给她的驾照。

As an example, suppose "Alice" needs to prove to Bob (a store clerk) that she has
a driver's license issued to her by the DMV.

在这个场景中，Alice 是用户，机动车管理局是发布者，Bob 是验证者。为了向 Bob 证明 Alice 有驾驶执照，她可以给他看。但是，这样 Bob 就可以看到 Alice 的名字、地址、确切年龄等等，这比 Bob 有必要知道的信息多得多。

In this scenario, Alice is the user, the DMV is the issuer, and Bob is the
verifier. In order to prove to Bob that Alice has a driver's license, she could
show it to him. However, Bob would then be able to see Alice's name, address,
exact age, etc. --- much more information than Bob needs to know.

换句话说，Alice 可以使用 Idemix 为 Bob 生成一个“零知识证明”，该证明只显示她拥有有效的驾照，除此之外什么都没有。

Instead, Alice can use Idemix to generate a "zero-knowledge proof" for Bob, which
only reveals that she has a valid driver's license and nothing else.

所以，从这个证明中：

So from the proof:

* Bob 只知道 Alice 有一个有效的执照，除此之外他没有了解到关于 Alice 的任何其他信息（匿名性）。
* 如果 Alice 多次访问商店并每次都为 Bob 生成一个证明，Bob 将无法从这些证明中看出这是同一个人（不可链接性）。

* Bob does not learn any additional information about Alice other than the fact
  that she has a valid license (anonymity).
* If Alice visits the store multiple times and generates a proof each time for Bob,
  Bob would not be able to tell from the proof that it was the same person
  (unlinkability).

Idemix 身份验证技术提供了与标准 X.509 证书类似的信任模型和安全保证，但是使用了底层加密算法，有效地提供了高级隐私特性，包括上面描述的特性。在下面的技术部分中，我们将详细比较 Idemix 和 X.509 技术。

Idemix authentication technology provides the trust model and security
guarantees that are similar to what is ensured by standard X.509 certificates but
with underlying cryptographic algorithms that efficiently provide advanced
privacy features including the ones described above. We'll compare Idemix and
X.509 technologies in detail in the technical section below.

如何使用 Idemix
-----------------------------

How to use Idemix
-----------------

要了解如何在 Hyperledger Fabric 中使用 Idemix，我们需要查看哪些 Fabric 组件对应于 Idemix 中的用户、发布者和验证者。

To understand how to use Idemix with Hyperledger Fabric, we need to see which
Fabric components correspond to the user, issuer, and verifier in Idemix.

* Fabric Java SDK 是 **用户** 的 API 。在将来，其他 Fabric SDK 也会支持 Idemix 。

* The Fabric Java SDK is the API for the **user**. In the future, other Fabric
  SDKs will also support Idemix.

* Fabric 提供了两种可能的 Idemix **发布者** ：

* Fabric provides two possible Idemix **issuers**:

   a) Fabric CA 支持生产环境和开发环境
   b) :doc:`idemixgen <idemixgen>` 工具支持开发环境。

   a) Fabric CA for production environments or development, and
   b) the :doc:`idemixgen <idemixgen>` tool for development environments.

* **验证者** 在 Fabric 中是 Idemix MSP 。

* The **verifier** is an Idemix MSP in Fabric.

为了在超级账本 Fabric 中使用 Idemix ，需要以下三个基本步骤：

In order to use Idemix in Hyperledger Fabric, the following three basic steps
are required:

.. image:: images/idemix-three-steps.png

*对比这个图和上面那个图中的角色。*

*Compare the roles in this image to the ones above.*

1. 考虑发布者。

1. Consider the issuer.

   Fabric CA（1.3 或更高版本）改进后可自动充当 Idemix 发布者。当启动 ``fabric-ca-server`` 时（或通过 ``fabric-ca-server init`` 命令初始化时），将在 ``fabric-ca-server`` 的主目录中自动创建以下两个文件：``IssuerPublicKey`` 和 ``IssuerRevocationPublicKey``。步骤 2 需要这些文件。

   Fabric CA (version 1.3 or later) has been enhanced to automatically function
   as an Idemix issuer. When ``fabric-ca-server`` is started (or initialized via
   the ``fabric-ca-server init`` command), the following two files are
   automatically created in the home directory of the ``fabric-ca-server``:
   ``IssuerPublicKey`` and ``IssuerRevocationPublicKey``. These files are
   required in step 2.

   对于开发环境，如果你还没使用 Fabric CA，你可以使用 ``idemixgen`` 创建这些文件。

   For a development environment and if you are not using Fabric CA, you may use
   ``idemixgen`` to create these files.

2. 考虑验证者。

2. Consider the verifier.

   您需要使用步骤1中的 ``IssuerPublicKey`` 和 ``IssuerRevocationPublicKey`` 创建 Idemix MSP。

   You need to create an Idemix MSP using the ``IssuerPublicKey`` and
   ``IssuerRevocationPublicKey`` from step 1.

   例如，考虑下面的这些摘自 `Hyperledger Java SDK 示例中 configtx.yaml <https://github.com/hyperledger/fabric-sdk-java/blob/master/src/test/fixture/sdkintegration/e2e-2Orgs/v1.3/configtx.yaml>`_ 的片段：

   For example, consider the following excerpt from
   `configtx.yaml in the Hyperledger Java SDK sample <https://github.com/hyperledger/fabric-sdk-java/blob/{BRANCH}/src/test/fixture/sdkintegration/e2e-2Orgs/v1.3/configtx.yaml>`_:

   .. code:: bash

      - &Org1Idemix
          # defaultorg defines the organization which is used in the sampleconfig
          # of the fabric.git development environment
          name: idemixMSP1

          # id to load the msp definition as
          id: idemixMSPID1

          msptype: idemix
          mspdir: crypto-config/peerOrganizations/org3.example.com

   ``msptype`` 设为 ``idemix``，并且目录 ``mspdir``（本例中是 ``crypto-config/peerOrganizations/org3.example.com/msp``）的内容包含 ``IssuerPublicKey`` 和 ``IssuerRevocationPublicKey`` 文件。

   The ``msptype`` is set to ``idemix`` and the contents of the ``mspdir``
   directory (``crypto-config/peerOrganizations/org3.example.com/msp`` in this
   example) contains the ``IssuerPublicKey`` and ``IssuerRevocationPublicKey``
   files.

   注意，在本例中，``Org1Idemix`` 代表 ``Org1``（未显示）的 Idemix MSP，``Org1`` 还有一个 X509 MSP 。

   Note that in this example, ``Org1Idemix`` represents the Idemix MSP for ``Org1``
   (not shown), which would also have an X509 MSP.

3. 考虑用户。回想一下，Java SDK 是用户的 API。

3. Consider the user. Recall that the Java SDK is the API for the user.

   要使用 Java SDK 的 Idemix，只需要额外调用 ``org.hyperledger.fabric_ca.sdk.HFCAClient`` 类中的 ``idemixEnroll`` 方法。例如，假设 ``hfcaClient`` 是你的 HFCAClient 对象，``x509Enrollment`` 是与你的 X509 证书相关联的 ``org.hyperledger.fabric.sdk.Enrollment``。

   There is only a single additional API call required in order to use Idemix
   with the Java SDK: the ``idemixEnroll`` method of the
   ``org.hyperledger.fabric_ca.sdk.HFCAClient`` class. For example, assume
   ``hfcaClient`` is your HFCAClient object and ``x509Enrollment`` is your
   ``org.hyperledger.fabric.sdk.Enrollment`` associated with your X509 certificate.

   下面的调用将会返回一个和你的 Idemix 凭证相关联的 ``org.hyperledger.fabric.sdk.Enrollment`` 对象。

   The following call will return an ``org.hyperledger.fabric.sdk.Enrollment``
   object associated with your Idemix credential.

   .. code:: bash

      IdemixEnrollment idemixEnrollment = hfcaClient.idemixEnroll(x509enrollment, "idemixMSPID1");

   还需要注意，``IdemixEnrollment`` 实现了 ``org.hyperledger.fabric.sdk.Enrollment`` 接口，因此可以像使用 X509 注册对象一样使用它，当然 Idemix 自动提供了改进的隐私保护功能。

   Note also that ``IdemixEnrollment`` implements the ``org.hyperledger.fabric.sdk.Enrollment``
   interface and can, therefore, be used in the same way that one uses the X509
   enrollment object, except, of course, that this automatically provides the
   privacy enhancing features of Idemix.

Idemix 和链码
--------------------

Idemix and chaincode
--------------------

从验证者的角度来看，还有一个角色需要考虑：链码。当使用 Idemix 凭证时，链码可以获取有关交易参与者的哪些信息？

From a verifier perspective, there is one more actor to consider: chaincode.
What can chaincode learn about the transactor when an Idemix credential is used?

当使用 Idemix 凭证时，`cid (Client Identity) 库<https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/cid>`_ （只支持 golang ）已扩展支持 ``GetAttributeValue`` 方法。但是，像下面“当前限制”模块提到的那样，在 Idemix 的情况下，只有两个展示出来的属性：``ou`` 和 ``role``。

The `cid (Client Identity) library <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/pkg/cid>`_
(for Go only) has been extended to support the ``GetAttributeValue`` function
when an Idemix credential is used. However, as mentioned in the "Current
limitations" section below, there are only two attributes which are disclosed in
the Idemix case: ``ou`` and ``role``.

如果 Fabric CA 是凭证发布者：

If Fabric CA is the credential issuer:

* `ou` 属性的值是身份的 **从属（affiliation）**（例如，“org1.department1”）；
* ``role`` 属性的值将是 ‘member’ 或 ‘admin’。‘admin’ 表示该身份是 MSP 管理员。默认情况下，Fabric CA 创建的身份将返回 ‘member’ 角色。要创建一个 ‘admin’ 身份，使用值为 ``2`` 的 ``role`` 属性注册身份。

* the value of the `ou` attribute is the identity's **affiliation** (e.g.
  "org1.department1");
* the value of the ``role`` attribute will be either 'member' or 'admin'. A
  value of 'admin' means that the identity is an MSP administrator. By default,
  identities created by Fabric CA will return the 'member' role. In order to
  create an 'admin' identity, register the identity with the ``role`` attribute
  and a value of ``2``.

用 Java SDK 设置从属的例子，请查看 `示例 <https://github.com/hyperledger/fabric-sdk-java/blob/master/src/test/java/org/hyperledger/fabric/sdkintegration/End2endIdemixIT.java#L121>`_ 。

For an example of setting an affiliation in the Java SDK see this `sample <https://github.com/hyperledger/fabric-sdk-java/blob/{BRANCH}/src/test/java/org/hyperledger/fabric/sdkintegration/End2endIdemixIT.java#L121>`_.

在 go 链码中使用 CID 库来检索属性的例子，请查看 `go 链码<https://github.com/hyperledger/fabric-sdk-java/blob/master/src/test/fixture/sdkintegration/gocc/sampleIdemix/src/github.com/example_cc/example_cc.go#L88>`_ 。

For an example of using the CID library in go chaincode to retrieve attributes,
see this `go chaincode <https://github.com/hyperledger/fabric-sdk-java/blob/{BRANCH}/src/test/fixture/sdkintegration/gocc/sampleIdemix/src/github.com/example_cc/example_cc.go#L88>`_.

Idemix organizations cannot be used to endorse a chaincode or approve a chaincode
definition. This needs to be taken into account when you set the
LifecycleEndorsement and Endorsement policies on your channels. For more
information, see the limitations section below.

当前限制
-------------------

Current limitations
-------------------

Idemix 的当前版本有一些限制。

The current version of Idemix does have a few limitations.

* **Idemix organizations and endorsement policies**

  Idemix organizations cannot be used to endorse a chaincode transaction or
  approve a chaincode definition. By default, the
  ``Channel/Application/LifecycleEndorsement`` and
  ``Channel/Application/Endorsement`` policies will require signatures from a
  majority of organizations active on the channel. This implies that a channel
  that contains a large number of Idemix organizations may not be able to
  reach the majority needed to fulfill the default policy. For example, if a
  channel has two MSP Organizations and two Idemix organizations, the channel
  policy will require that three out of four organizations approve a chaincode
  definition to commit that definition to the channel. Because Idemix
  organizations cannot approve a chaincode definition, the policy will only be
  able to validate two out of four signatures.

  If your channel contains a sufficient number of Idemix organizations to affect
  the endorsement policy, you can use a signature policy to explicitly specify
  the required MSP organizations.

* **固定的属性集合**

* **Fixed set of attributes**

  还不支持发布 Idemix 凭证的自定义属性。自定义属性在将来会支持。

  It not yet possible to issue or use an Idemix credential with custom attributes.
  Custom attributes will be supported in a future release.

  下面的四个属性是支持的：

  The following four attributes are currently supported:

  1. 组织单元（Organizational Unit）属性（\"ou\"）：

  1. Organizational Unit attribute ("ou"):

   - 用法：和 X.509 一样
   - 类型：String
   - 显示（Revealed）：总是

   - Usage: same as X.509
   - Type: String
   - Revealed: always

  2. 角色（Role） 属性（\"role\"）：

  2. Role attribute ("role"):

   - 用法：和 X.509 一样
   - 类型：integer
   - 显示（Revealed）：总是

   - Usage: same as X.509
   - Type: integer
   - Revealed: always

  3. 注册 ID（Enrollment ID）属性：

  3. Enrollment ID attribute

   - 用法：用户的唯一身份，即属于同一用户的所有注册凭证都是相同的（在将来的版本中用于审计）
   - 类型：BIG
   - 显示（Revealed）：不在签名中使用，只在为 Fabric CA 生成身份验证 token 时使用

   - Usage: uniquely identify a user --- same in all enrollment credentials that
     belong to the same user (will be used for auditing in the future releases)
   - Type: BIG
   - Revealed: never in the signature, only when generating an authentication token for Fabric CA

  4. 撤销句柄（Revocation Handle）属性：

  4. Revocation Handle attribute

   - 用法：唯一性身份凭证（在将来的版本中用于撤销）
   - 类型：integer
   - 显示：从不

   - Usage: uniquely identify a credential (will be used for revocation in future releases)
   - Type: integer
   - Revealed: never

* **还不支持撤销**

* **Revocation is not yet supported**

   尽管存在上面提到的撤销句柄属性，可以看出撤销框架的大部分已经就绪，但是还不支持撤销 Idemix 凭证。

   Although much of the revocation framework is in place as can be seen by the
   presence of a revocation handle attribute mentioned above, revocation of an
   Idemix credential is not yet supported.

* **节点背书时不使用 Idemix**

* **Peers do not use Idemix for endorsement**

   目前 Idemix MSP 只被节点用来验证签名。只完成了在Client SDK 中使用 Idemix 签名。未来会支持更多角色（包括 ‘peer’ 角色）使用 Idemix MSP 。

   Currently, Idemix MSP is used by the peers only for signature verification.
   Signing with Idemix is only done via Client SDK. More roles (including a
   'peer' role) will be supported by Idemix MSP.

技术总结
-----------------

Technical summary
-----------------

对比 Idemix 凭证和 X.509 证书
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comparing Idemix credentials to X.509 certificates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Idemix 和 X.509 中的证书/凭证的概念、颁发过程，非常相似：一组属性使用不能伪造的数字签名进行签名，并且有一个利用密码学绑定的密钥。

The certificate/credential concept and the issuance process are very similar in
Idemix and X.509 certs: a set of attributes is digitally signed with a signature
that cannot be forged and there is a secret key to which a credential is
cryptographically bound.

标准 X.509 证书和 Identity Mixer 证书之间的主要区别是用于验证属性的签名方案。Identity Mixer 系统下的签名能够使其有效地证明所有者拥有该签名和相应的属性，而无需揭示签名和（选择的）属性值本身。我们使用零知识证明来确保这些“知识”或“信息”不会被泄露，同时确保属性上的签名有效，并且确保用户拥有相应的凭证密钥。

The main difference between a standard X.509 certificate and an Identity Mixer
credential is the signature scheme that is used to certify the attributes. The
signatures underlying the Identity Mixer system allow for efficient proofs of the
possession of a signature and the corresponding attributes without revealing the
signature and (selected) attribute values themselves. We use zero-knowledge proofs
to ensure that such "knowledge" or "information" is not revealed while ensuring
that the signature over some attributes is valid and the user is in possession
of the corresponding credential secret key.

这样的证明，比如 X.509 证书，可以使用最初签署证书的机构的公钥进行验证，并且无法成功伪造。只有知道凭证密钥的用户才能生成凭证及其属性的证明。

Such proofs, like X.509 certificates, can be verified with the public key of
the authority that originally signed the credential and cannot be successfully
forged. Only the user who knows the credential secret key can generate the proofs
about the credential and its attributes.

关于不可链接性，当提供 X.509 证书时，必须显示所有属性来验证证书签名。这意味着所有用于签署交易的证书的用法都是可链接的。

With regard to unlinkability, when an X.509 certificate is presented, all attributes
have to be revealed to verify the certificate signature. This implies that all
certificate usages for signing transactions are linkable.

为了避免这种可链接性，每次都需要使用新的 X.509 证书，这会导致复杂的密钥管理、通信和存储开销。此外，在某些情况下，即使颁发证书的 CA 也不应该将所有交易链接到用户，这一点很重要。

To avoid such linkability, fresh X.509 certificates need to be used every time,
which results in complex key management and communication and storage overhead.
Furthermore, there are cases where it is important that not even the CA issuing
the certificates is able to link all the transactions to the user.

Idemix 有助于避免 CA 和验证者之间的可链接性，因为即使是 CA 也不能将证明链接到原始凭证。发布者或验证者都不能分辨两种证明是否是来自同一凭证。

Idemix helps to avoid linkability with respect to both the CA and verifiers,
since even the CA is not able to link proofs to the original credential. Neither
the issuer nor a verifier can tell whether two proofs were derived from the same
credential (or from two different ones).

这篇文章详细介绍了 Identity Mixer 技术的概念和特点 `Concepts and Languages for Privacy-Preserving Attribute-Based Authentication<https://link.springer.com/chapter/10.1007%2F978-3-642-37282-7_4>`_ 。

More details on the concepts and features of the Identity Mixer technology are
described in the paper `Concepts and Languages for Privacy-Preserving Attribute-Based Authentication <https://link.springer.com/chapter/10.1007%2F978-3-642-37282-7_4>`_.

拓扑信息
~~~~~~~~~~~~~~~~~~~~

Topology Information
~~~~~~~~~~~~~~~~~~~~

鉴于上述限制，建议每个通道仅使用一个基于 Idemix 的 MSP，或者在极端情况下，每个网络使用一个基于 Idemix 的 MSP。实际上，如果每个通道有多个基于 Idemix 的 MSP，那么任意参与方读取该通道的账本，即可区分出来各个交易分别是由哪个 Idemix MSP 签署的。这是因为，每个交易都会泄漏签名者的 MSP-ID 。换句话说，Idemix 目前只提供同一组织（MSP）中客户端的匿名性。

Given the above limitations, it is recommended to have only one Idemix-based MSP
per channel or, at the extreme, per network. Indeed, for example, having multiple Idemix-based MSPs
per channel would allow a party, reading the ledger of that channel, to tell apart
transactions signed by parties belonging to different Idemix-based MSPs. This is because,
each transaction leak the MSP-ID of the signer.
In other words, Idemix currently provides only anonymity of clients among the same organization (MSP).

将来，Idemix 可以扩展为支持基于 Idemix 的多层匿名结构的认证机构体系，这些机构认证的凭证可以通过使用唯一的公钥进行验证，从而实现跨组织的匿名性（MSP）。这将允许多个基于 Idemix 的 MSP 在同一个通道中共存。

In the future, Idemix could be extended to support anonymous hierarchies of Idemix-based
Certification Authorities whose certified credentials can be verified by using a unique public-key,
therefore achieving anonymity across organizations (MSPs).
This would allow multiple Idemix-based MSPs to coexist in the same channel.

在主体中，可以将通道配置为具有单个基于 Idemix 的 MSP 和多个基于 X.509 的 MSP。当然，这些 MSP 之间的交互可能会泄露信息。对泄露的信息需要逐案进行评估。

In principal, a channel can be configured to have a single Idemix-based MSP and multiple
X.509-based MSPs. Of course, the interaction between these MSP can potential
leak information. An assessment of the leaked information need to be done case by case.wq

底层加密协议
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Underlying cryptographic protocols
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Idemix 技术是建立在一个盲签名方案的基础上的，该方案支持签名拥有多个消息和有效的的零知识证明。Idemix 的所有密码构建模块都在顶级会议和期刊上发表了，并得到了科学界的验证。

Idemix technology is built from a blind signature scheme that supports multiple
messages and efficient zero-knowledge proofs of signature possession. All of the
cryptographic building blocks for Idemix were published at the top conferences
and journals and verified by the scientific community.

Fabric 的这个特定 Idemix 实现使用了一个 pairing-based 的签名方案，该方案由 `Camenisch 和 Lysyanskaya https://link.springer.com/chapter/10.1007/978-3-540-28628-8_4>`_ 简要提出，并由 `Au et al. <https://link.springer.com/chapter/10.1007/11832072_8>`_ 详细描述。使用了在零知识证明 `Camenisch et al. <https://eprint.iacr.org/2016/663.pdf>`_ 中证明签名的知识的能力。

This particular Idemix implementation for Fabric uses a pairing-based
signature scheme that was briefly proposed by `Camenisch and Lysyanskaya <https://link.springer.com/chapter/10.1007/978-3-540-28628-8_4>`_
and described in detail by `Au et al. <https://link.springer.com/chapter/10.1007/11832072_8>`_.
The ability to prove knowledge of a signature in a zero-knowledge proof
`Camenisch et al. <https://eprint.iacr.org/2016/663.pdf>`_ was used.
