成员服务提供者 (MSP)
==================================
Membership Service Providers (MSP)
==================================

本文档将详细说明MSP的建立并提供MSP的最佳实践。

The document serves to provide details on the setup and best practices for MSPs.

成员服务提供者（MSP）是 Hyperledger Fabric 的一个组件，旨在提供抽象的成员操作。

Membership Service Provider (MSP) is a Hyperledger Fabric component that offers
an abstraction of membership operations.

具体的，MSP将分发证书、验证证书和用户授权背后的所有加密机制和协议抽象出来。
MSP可以定义它们自己的身份概念，同样还可以定义管理(身份验证)和认证(签名生成和验证)这些身份的规则。

In particular, an MSP abstracts away all cryptographic mechanisms and protocols
behind issuing certificates, validating certificates, and user authentication.
An MSP may define its own notion of identity, and the rules by which those
identities are governed (identity validation) and authenticated (signature
generation and verification).

一个 Hyperledger Fabric区块链网络可以由一个或多个MSP管理。这提供了成员操作的模块化和不同成员标准和架构之间的互操作性。

A Hyperledger Fabric blockchain network can be governed by one or more MSPs.
This provides modularity of membership operations, and interoperability
across different membership standards and architectures.

此文档的剩余部分将详述MSP在Hyperledger Fabric的建立过程，然后讨论关于其使用的最佳实践。

In the rest of this document we elaborate on the setup of the MSP
implementation supported by Hyperledger Fabric, and discuss best practices
concerning its use.

MSP配置
-----------------

MSP Configuration
-----------------

为了建立一个MSP实体，每个peer和orderer需要指定其本地的配置文件(为了使peer和orderer可以进行签名)，
也为了在通道上使peer、orderer和client进行身份验证和通道成员之间的签名验证(认证)。

To setup an instance of the MSP, its configuration needs to be specified
locally at each peer and orderer (to enable peer and orderer signing),
and on the channels to enable peer, orderer, client identity validation, and
respective signature verification (authentication) by and for all channel
members.

首先，每个MSP必须指定一个名字以便该MSP在网络内被引用(例如 ``msp1``, ``org2``, 以及 ``org3.divA``)。
这是一个可以表述其所代表的在通道中联盟、组织或组织部门的名称。
这个名称也被称为 *MSP Identifier* 或 *MSP ID*。每个MSP的MSPID必须是唯一的。
例如，如果在系统通道建立时发现两个MSP的MSPID相同，orderer的建立将失败。

Firstly, for each MSP a name needs to be specified in order to reference that MSP
in the network (e.g. ``msp1``, ``org2``, and ``org3.divA``). This is the name under
which membership rules of an MSP representing a consortium, organization or
organization division is to be referenced in a channel. This is also referred
to as the *MSP Identifier* or *MSP ID*. MSP Identifiers are required to be unique per MSP
instance. For example, shall two MSP instances with the same identifier be
detected at the system channel genesis, orderer setup will fail.

在默认的MSP实现中，需指定一些参数来允许身份(证书)验证和签名验证。这些参数从这里导出：
`RFC5280 <http://www.ietf.org/rfc/rfc5280.txt>`_
,并包括:

In the case of the default MSP implementation, a set of parameters need to be
specified to allow for identity (certificate) validation and signature
verification. These parameters are deduced by
`RFC5280 <http://www.ietf.org/rfc/rfc5280.txt>`_, and include:

- 一个自签名（X.509） CA 证书列表来组成信任根（*root of trust*）
- 一个X.509证书列表来代表证书验证时需要考虑的中间证书，这些证书应该由某一个信任根颁发；中间证书是可选的参数
- 一个X.509证书列表，并拥有从某一信任根起可验证的 CA 证书路径，来代表该MSP的管理员证书；拥有管理员证书则代表拥有申请改变该MSP配置的权力(例如，根CA、中间CA)
- 一个组织单位列表，此列表应出现在该MSP的有效成员的X.509证书中；这是一个可选的配置参数，举例来说，可用于多组织使用相同信任根和中间CA，并给其成员预留OU信息
- 一个证书撤销列表(CRLs)，其中每一个对应一个列出的(根或中间)MSP CA；这是一个可选参数
- 一个自签(X.509)证书列表，用来组成TLS证书的信任根(*TLS root of trust*)
- 一个X.509证书列表来代表证书验证时需要考虑的TLS中间证书，这些证书应该由某一个TLS信任根颁发；TLS中间证书是可选的参数

- A list of self-signed (X.509) CA certificates to constitute the *root of
  trust*
- A list of X.509 certificates to represent intermediate CAs this provider
  considers for certificate validation; these certificates ought to be
  certified by exactly one of the certificates in the root of trust;
  intermediate CAs are optional parameters
- A list of X.509 certificates representing the administrators of this MSP with a
  verifiable certificate path to exactly one of the CA certificates of the
  root of trust; owners of these certificates are authorized to request changes
  to this MSP configuration (e.g. root CAs, intermediate CAs)
- A list of Organizational Units that valid members of this MSP should
  include in their X.509 certificate; this is an optional configuration
  parameter, used when, e.g., multiple organizations leverage the same
  root of trust, and intermediate CAs, and have reserved an OU field for
  their members
- A list of certificate revocation lists (CRLs) each corresponding to
  exactly one of the listed (intermediate or root) MSP Certificate
  Authorities; this is an optional parameter
- A list of self-signed (X.509) certificates to constitute the *TLS root of
  trust* for TLS certificates.
- A list of X.509 certificates to represent intermediate TLS CAs this provider
  considers; these certificates ought to be
  certified by exactly one of the certificates in the TLS root of trust;
  intermediate CAs are optional parameters.

该MSP的 *有效的* 身份需满足如下条件:

*Valid*  identities for this MSP instance are required to satisfy the following conditions:

- 它们以X.509证书的形式存在，并拥有从某一信任根起可验证的证书路径；
- 它们不在任何证书撤销列表(CRL)中；
- 它们在其X.509证书结构的 ``OU`` 域中 *列举* MSP配置中的一个或多个组织单位(OU)

- They are in the form of X.509 certificates with a verifiable certificate path to
  exactly one of the root of trust certificates;
- They are not included in any CRL;
- And they *list* one or more of the Organizational Units of the MSP configuration
  in the ``OU`` field of their X.509 certificate structure.

更多关于当前MSP实现中身份认证的信息，我们建议读者阅读文档 :doc:`msp-identity-validity-rules`

For more information on the validity of identities in the current MSP implementation,
we refer the reader to :doc:`msp-identity-validity-rules`.

除了认证相关的参数以外，为了使MSP启用对其进行实例化的节点进行签名或身份验证，需指定：

In addition to verification related parameters, for the MSP to enable
the node on which it is instantiated to sign or authenticate, one needs to
specify:

- 用于节点签名的签名密钥(当前只支持ECDSA密钥)
- 节点的X.509证书，这是在MSP的验证参数下一个有效的标识

- The signing key used for signing by the node (currently only ECDSA keys are
  supported), and
- The node's X.509 certificate, that is a valid identity under the
  verification parameters of this MSP.

值得注意的是MSP身份不会过期；它们只能被撤销(添加进证书撤销列表CRLs)。此外，目前没有支持TLS证书的撤销。

It is important to note that MSP identities never expire; they can only be revoked
by adding them to the appropriate CRLs. Additionally, there is currently no
support for enforcing revocation of TLS certificates.

如何生成MSP证书以及它们的签名密钥？
--------------------------------------------------------

How to generate MSP certificates and their signing keys?
--------------------------------------------------------

为了生成MSP配置所需的X.509证书，可以使用
`Openssl <https://www.openssl.org/>`_
。需要强调的是Hyperledger Fabric不支持包含RSA密钥的证书。

`Openssl <https://www.openssl.org/>`_ can be used to generate X.509
certificates and keys. Please note that Hyperledger Fabric does not support
RSA key and certificates.

另外也可以用 ``cryptogen`` 工具，它相关的操作请查看文档 :doc:`getting_started`

Alternatively, the ``cryptogen`` tool can be used as described in
:doc:`getting_started`.

`Hyperledger Fabric CA <http://hyperledger-fabric-ca.readthedocs.io/en/latest/>`_
也可以用来生成配置MSP的证书和密钥。

`Hyperledger Fabric CA <http://hyperledger-fabric-ca.readthedocs.io/en/latest/>`_
can also be used to generate the keys and certificates needed to configure an MSP.

在Peer和Orderer端建立MSP
------------------------------------

MSP setup on the peer & orderer side
------------------------------------

为了建立(Peer或Orderer的)本地MSP，管理员应当建立目录(例如，``$MY_PATH/mspconfig``)，其中包含一个文件和八个子目录：

To set up a local MSP (for either a peer or an orderer), the administrator
should create a folder (e.g. ``$MY_PATH/mspconfig``) that contains six subfolders
and a file:

1. 一个 ``admincerts`` 目录，其中包含PEM文件，每个PEM文件对应一个管理员证书
2. 一个 ``cacerts`` 目录，其中包含PEM文件，每个PEM文件对应一个根CA证书
3. (可选的)一个 ``intermediatecerts`` 目录，其中包含PEM文件，每个PEM文件对应一个中间CA证书
4. (可选的)一个文件 ``config.yaml``，用来配置所支持的组织单位(OU)和身份分类(参见下面对应的部分)
5. (可选的)一个 ``crls`` 目录，包含证书撤销列表(CRLs)
6. 一个 ``keystore`` 目录，包含一个PEM文件，代表该节点的签名密钥，我们强调当前不支持RSA的密钥形式
7. 一个 ``signcerts`` 目录，包含一个PEM文件，代表该节点的X.509证书
8. (可选的)一个 ``tlscacerts`` 目录，其中包含PEM文件，每个PEM文件对应一个TLS根CA证书
9. (可选的)一个 ``tlsintermediatecerts`` 目录，其中包含PEM文件，每个PEM文件对应一个TLS中间CA证书

1. a folder ``admincerts`` to include PEM files each corresponding to an
   administrator certificate
2. a folder ``cacerts`` to include PEM files each corresponding to a root
   CA's certificate
3. (optional) a folder ``intermediatecerts`` to include PEM files each
   corresponding to an intermediate CA's certificate
4. (optional) a file ``config.yaml`` to configure the supported Organizational Units
   and identity classifications (see respective sections below).
5. (optional) a folder ``crls`` to include the considered CRLs
6. a folder ``keystore`` to include a PEM file with the node's signing key;
   we emphasise that currently RSA keys are not supported
7. a folder ``signcerts`` to include a PEM file with the node's X.509
   certificate
8. (optional) a folder ``tlscacerts`` to include PEM files each corresponding to a TLS root
   CA's certificate
9. (optional) a folder ``tlsintermediatecerts`` to include PEM files each
   corresponding to an intermediate TLS CA's certificate

在节点的配置文件(对Peer来说是core.yaml，对Orderer来说是orderer.yaml)中，必须指定mspconfig目录的路径和节点MSP的MSPID。
mspconfig目录的路径应该是环境变量FABRIC_CFG_PATH的相对路径，并且是Peer端 ``mspConfigPath`` 对应的参数，或是Orderer端 ``LocalMSPDir`` 对应的参数。
节点的MSPID由Peer端 ``localMspId`` 指定，或由Orderer端 ``LocalMSPID`` 指定。这些变量可以被环境变量重写，在Peer端使用CORE前缀(例如，CORE_PEER_LOCALMSPID)，在Orderer端使用ORDERER前缀(例如，ORDERER_GENERAL_LOCALMSPID)。
值得一提的是，在Orderer建立阶段，需要生成并提供给Orderer系统通道的创世块。创世块中所需的MSP配置信息将在下部分详细说明。

In the configuration file of the node (core.yaml file for the peer, and
orderer.yaml for the orderer), one needs to specify the path to the
mspconfig folder, and the MSP Identifier of the node's MSP. The path to the
mspconfig folder is expected to be relative to FABRIC_CFG_PATH and is provided
as the value of parameter ``mspConfigPath`` for the peer, and ``LocalMSPDir``
for the orderer. The identifier of the node's MSP is provided as a value of
parameter ``localMspId`` for the peer and ``LocalMSPID`` for the orderer.
These variables can be overridden via the environment using the CORE prefix for
peer (e.g. CORE_PEER_LOCALMSPID) and the ORDERER prefix for the orderer (e.g.
ORDERER_GENERAL_LOCALMSPID). Notice that for the orderer setup, one needs to
generate, and provide to the orderer the genesis block of the system channel.
The MSP configuration needs of this block are detailed in the next section.

如果想要 *重新配置* 一个 "本地" MSP，目前只能手动操作，并且Peer或Orderer需要重启。在后续版本我们计划提供在线/动态的重新配置方式(例如，不需要中止节点，使用一个受节点管理的系统链码)。

*Reconfiguration* of a "local" MSP is only possible manually, and requires that
the peer or orderer process is restarted. In subsequent releases we aim to
offer online/dynamic reconfiguration (i.e. without requiring to stop the node
by using a node managed system chaincode).

组织单元(OU)
--------------------

Organizational Units
--------------------

为了配置在该MSP有效用户的证书中的OU列表，``config.yaml`` 文件需指定组织单位标识。例如：

In order to configure the list of Organizational Units that valid members of this MSP should
include in their X.509 certificate, the ``config.yaml`` file
needs to specify the organizational unit (OU, for short) identifiers. You can find an example
below:

::

   OrganizationalUnitIdentifiers:
     - Certificate: "cacerts/cacert1.pem"
       OrganizationalUnitIdentifier: "commercial"
     - Certificate: "cacerts/cacert2.pem"
       OrganizationalUnitIdentifier: "administrators"

上面的例子声明了两个组织单位标识：**commercial** 和 **administrators**。
如果MSP拥有至少其中一个组织单位标识，它才是有效的。
``Certificate`` 域代表拥有有效标识应具有的CA证书或中间CA证书路径。
该路径是相对MSP根目录的，并且不能为空。

The above example declares two organizational unit identifiers: **commercial** and **administrators**.
An MSP identity is valid if it carries at least one of these organizational unit identifiers.
The ``Certificate`` field refers to the CA or intermediate CA certificate path
under which identities, having that specific OU, should be validated.
The path is relative to the MSP root folder and cannot be empty.

身份类型
-----------------------

Identity Classification
-----------------------

The default MSP implementation allows organizations to further classify identities into clients,
admins, peers, and orderers based on the OUs of their x509 certificates.

* An identity should be classified as a **client** if it transacts on the network.
* An identity should be classified as an **admin** if it handles administrative tasks such as
  joining a peer to a channel or signing a channel configuration update transaction.
* An identity should be classified as a **peer** if it endorses or commits transactions.
* An identity should be classified as an **orderer** if belongs to an ordering node.

In order to define the clients, admins, peers, and orderers of a given MSP, the ``config.yaml`` file
needs to be set appropriately. You can find an example NodeOU section of the ``config.yaml`` file
below:

::

   NodeOUs:
     Enable: true
     ClientOUIdentifier:
       Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "client"
     AdminOUIdentifier:
       Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "admin"
     PeerOUIdentifier:
       Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "peer"
     OrdererOUIdentifier:
       Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "orderer"

   NodeOUs:
     Enable: true
     # For each identity classification that you would like to utilize, specify
     # an OU identifier.
     # You can optionally configure that the OU identifier must be issued by a specific CA
     # or intermediate certificate from your organization. However, it is typical to NOT
     # configure a specific Certificate. By not configuring a specific Certificate, you will be
     # able to add other CA or intermediate certs later, without having to reissue all credentials.
     # For this reason, the sample below comments out the Certificate field.
     ClientOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "client"
     AdminOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "admin"
     PeerOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "peer"
     OrdererOUIdentifier:
       # Certificate: "cacerts/cacert.pem"
       OrganizationalUnitIdentifier: "orderer"

Identity classification is enabled when ``NodeOUs.Enable`` is set to ``true``. Then the client
(admin, peer, orderer) organizational unit identifier is defined by setting the properties of
the ``NodeOUs.ClientOUIdentifier`` (``NodeOUs.AdminOUIdentifier``, ``NodeOUs.PeerOUIdentifier``,
``NodeOUs.OrdererOUIdentifier``) key:

a. ``OrganizationalUnitIdentifier``: Is the OU value that the x509 certificate needs to contain
   to be considered a client (admin, peer, orderer respectively). If this field is empty, then the classification
   is not applied.
b. ``Certificate``: Set this to the path of the CA or intermediate CA certificate under which client
   (peer, admin or orderer) identities should be validated. The field is relative to the MSP root
   folder. This field is optional. You can leave this field blank and allow the certificate to be
   validated under any CA defined in the MSP configuration.

a. ``OrganizationalUnitIdentifier``: Is the OU value that the x509 certificate needs to contain
   to be considered a client (admin, peer, orderer respectively). If this field is empty, then the classification
   is not applied.
b. ``Certificate``: (Optional) Set this to the path of the CA or intermediate CA certificate
   under which client (peer, admin or orderer) identities should be validated.
   The field is relative to the MSP root folder. Only a single Certificate can be specified.
   If you do not set this field, then the identities are validated under any CA defined in
   the organization's MSP configuration, which could be desirable in the future if you need
   to add other CA or intermediate certificates.

Notice that if the ``NodeOUs.ClientOUIdentifier`` section (``NodeOUs.AdminOUIdentifier``,
``NodeOUs.PeerOUIdentifier``, ``NodeOUs.OrdererOUIdentifier``) is missing, then the classification
is not applied. If ``NodeOUs.Enable`` is set to ``true`` and no classification keys are defined,
then identity classification is assumed to be disabled.

Identities can use organizational units to be classified as either a client, an admin, a peer, or an
orderer. The four classifications are mutually exclusive.
The 1.1 channel capability needs to be enabled before identities can be classified as clients
or peers. The 1.4.3 channel capability needs to be enabled for identities to be classified as an
admin or orderer.

Classification allows identities to be classified as admins (and conduct administrator actions)
without the certificate being stored in the ``admincerts`` folder of the MSP. Instead, the
``admincerts`` folder can remain empty and administrators can be created by enrolling identities
with the admin OU. Certificates in the ``admincerts`` folder will still grant the role of
administrator to their bearer, provided that they possess the client or admin OU.

通道 MSP 设置
-----------------

Channel MSP setup
-----------------

在系统创世阶段，需要指定出现在网络中的所有MSP的验证参数，并保存到系统通道的创世块。
回顾一下，MSP验证参数包含MSP标识、根证书列表、中间CA证书和管理员证书列表、OU信息和证书撤销列表CRLs。
在Orderer建立阶段，系统创世块将被提供给Orderer，使Orderer可以认证通道建立请求。
如果系统创世块包含有两个相同标识的MSP，Orderer将拒绝该创世块，从而导致网络启动失败。

At the genesis of the system, verification parameters of all the MSPs that
appear in the network need to be specified, and included in the system
channel's genesis block. Recall that MSP verification parameters consist of
the MSP identifier, the root of trust certificates, intermediate CA and admin
certificates, as well as OU specifications and CRLs.
The system genesis block is provided to the orderers at their setup phase,
and allows them to authenticate channel creation requests. Orderers would
reject the system genesis block, if the latter includes two MSPs with the same
identifier, and consequently the bootstrapping of the network would fail.

对于应用通道，通道的创世块只需包含通道管理者的MSP验证信息。
需强调的是，在将peer加入通道之前保证通道创世块(或最近的配置块)包含正确的MSP配置信息是 **应用自己的责任**。

For application channels, the verification components of only the MSPs that
govern a channel need to reside in the channel's genesis block. We emphasize
that it is **the responsibility of the application** to ensure that correct
MSP configuration information is included in the genesis blocks (or the
most recent configuration block) of a channel prior to instructing one or
more of their peers to join the channel.

当使用configtxgen工具启动通道时，可以通过将MSP验证参数包含进mspconfig目录
并在 ``configtx.yaml`` 相应部分设置其路径的方式配置通道MSP。

When bootstrapping a channel with the help of the configtxgen tool, one can
configure the channel MSPs by including the verification parameters of MSP
in the mspconfig folder, and setting that path in the relevant section in
``configtx.yaml``.

通道上MSP的 *重新配置*，MSP管理员证书的持有者在创建 ``config_update`` 事务时，
将声明与该MSP的已获得CA的证书相关的证书撤销列表。随后被管理员控制的客户端应用将在MSP出现的通道上声明这次update。

*Reconfiguration* of an MSP on the channel, including announcements of the
certificate revocation lists associated to the CAs of that MSP is achieved
through the creation of a ``config_update`` object by the owner of one of the
administrator certificates of the MSP. The client application managed by the
admin would then announce this update to the channels in which this MSP appears.

最佳实践
--------------

Best Practices
--------------

在这部分我们将详细说明对MSP配置的通用场景下的最佳实践

In this section we elaborate on best practices for MSP
configuration in commonly met scenarios.

**1) 组织/企业 和 MSP 之间的映射**

**1) Mapping between organizations/corporations and MSPs**

我们建议组织和MSP之间是一对一映射的。
如果要使用其他类型的映射，需考虑以下情况：

We recommend that there is a one-to-one mapping between organizations and MSPs.
If a different type of mapping is chosen, the following needs to be to
considered:

- **一个组织使用多个MSP.**
  这对应的情况是一个组织有多个部门，每个MSP代表一个部门，
  出现这种情况可以是独立管理的原因，也可能出于隐私考虑。
  在这种情况下，一个peer节点只能被单一MSP拥有，
  并且不能将其他MSP下peer识别成同组织的peer。
  这意味着peer节点可以通过gossip组织域将数据分享给同部门内的其他peer节点，
  但不能分享给组成实际组织的全体。
- **多组织使用一个MSP.**
  这对应的情况是多个组织组成联盟，每个组织都被类似的成员架构管理。
  要知道，不论是否属于同一实际组织，peer的组织域消息将传播给同MSP下的其他peer节点。
  这将限制MSP定义和(或)peer配置的粒度。

- **One organization employing various MSPs.** This corresponds to the
  case of an organization including a variety of divisions each represented
  by its MSP, either for management independence reasons, or for privacy reasons.
  In this case a peer can only be owned by a single MSP, and will not recognize
  peers with identities from other MSPs as peers of the same organization. The
  implication of this is that peers may share through gossip organization-scoped
  data with a set of peers that are members of the same subdivision, and NOT with
  the full set of providers constituting the actual organization.
- **Multiple organizations using a single MSP.** This corresponds to a
  case of a consortium of organizations that are governed by similar
  membership architecture. One needs to know here that peers would propagate
  organization-scoped messages to the peers that have an identity under the
  same MSP regardless of whether they belong to the same actual organization.
  This is a limitation of the granularity of MSP definition, and/or of the peer’s
  configuration.


**2) One organization has different divisions (say organizational units), to**
**which it wants to grant access to different channels.**

**2) 一个组织有不同分部(组织单元)，想要授予不同通道访问权**

Two ways to handle this:

两种处理方法：

- **Define one MSP to accommodate membership for all organization’s members**.
  Configuration of that MSP would consist of a list of root CAs,
  intermediate CAs and admin certificates; and membership identities would
  include the organizational unit (``OU``) a member belongs to. Policies can then
  be defined to capture members of a specific ``role`` (should be one of: peer, admin,
  client, orderer, member), and these policies may constitute the read/write policies
  of a channel or endorsement policies of a chaincode. Specifying custom OUs in
  the profile section of ``configtx.yaml`` is currently not configured.
  A limitation of this approach is that gossip peers would
  consider peers with membership identities under their local MSP as
  members of the same organization, and would consequently gossip
  with them organization-scoped data (e.g. their status).
- **Defining one MSP to represent each division**.  This would involve specifying for each
  division, a set of certificates for root CAs, intermediate CAs, and admin
  Certs, such that there is no overlapping certification path across MSPs.
  This would mean that, for example, a different intermediate CA per subdivision
  is employed. Here the disadvantage is the management of more than one
  MSPs instead of one, but this circumvents the issue present in the previous
  approach.  One could also define one MSP for each division by leveraging an OU
  extension of the MSP configuration.

- **定义一个可以容纳所有组织成员的MSP**.
  该MSP的配置将由根CA、中间CA和管理员证书列表；
  以及成员标识包括成员所属的组织单元(``OU``)组成。
  随后定义策略来捕获某一特定 ``OU`` 的成员，
  这些策略将组成通道的读/写策略或链码的背书策略。
  这种方法的局限性是gossip peer节点将把拥有和其相同成员标识的peer当成同组织成员，
  并因此与它们传播组织域信息(例如状态信息)。
- **给每一个分部定义一个MSP**.
  这涉及到给每个分部指定一组证书，包含根CA证书、中间CA证书和管理员证书，
  这样能够做到MSP之间没有重复的证书路径。
  这意味着，每个分部采用不同的中间CA。
  这么做的缺点是需要管理多个MSP，但是确实绕开了上面方法出现的问题。
  我们也可以使用MSP配置里的OU扩展项来实现对每个分部定义一个MSP。

**3) Separating clients from peers of the same organization.**

**3) 区分同一组织下的client和peer**

In many cases it is required that the “type” of an identity is retrievable
from the identity itself (e.g. it may be needed that endorsements are
guaranteed to have derived by peers, and not clients or nodes acting solely
as orderers).

在很多情况下，会要求一个身份的 "type" 是可以被检索的
(例如，可能有需求要求背书必须由peer节点提供，不能是client或单独的orderer节点)。

There is limited support for such requirements.

对这种要求的支持是有限的。

One way to allow for this separation is to create a separate intermediate
CA for each node type - one for clients and one for peers/orderers; and
configure two different MSPs - one for clients and one for peers/orderers.
Channels this organization should be accessing would need to include
both MSPs, while endorsement policies will leverage only the MSP that
refers to the peers. This would ultimately result in the organization
being mapped to two MSP instances, and would have certain consequences
on the way peers and clients interact.

实现这种区分的一种方式是为每种节点类型创建单独的中间CA，
一个给client，一个给peer或orderer，并分别配置两个不同的MSP。
组织加入到的通道需要同时包含两个MSP，但背书策略只部署在peer的MSP。
这将最终导致组织被映射到两个MSP实例，并且对peer和client的交互产生一些后果。

Gossip would not be drastically impacted as all peers of the same organization
would still belong to one MSP. Peers can restrict the execution of certain
system chaincodes to local MSP based policies. For
example, peers would only execute “joinChannel” request if the request is
signed by the admin of their local MSP who can only be a client (end-user
should be sitting at the origin of that request). We can go around this
inconsistency if we accept that the only clients to be members of a
peer/orderer MSP would be the administrators of that MSP.

由于同一组织的所有peer还是属于同一个MSP，Gossip不会被严重的影响。
Peer可以基于本地MSP策略来约束特定系统链码的执行。
例如，peer可以只执行 "joinChannel"请求，
如果这个请求是被一个只能是client的本地MSP的管理员签名的(终端用户应该是请求的起点)。
我们可以绕过这个矛盾，只要我们接受该MSP的管理员是该peer/orderer的唯一client。

Another point to be considered with this approach is that peers
authorize event registration requests based on membership of request
originator within their local MSP. Clearly, since the originator of the
request is a client, the request originator is always deemed to belong
to a different MSP than the requested peer and the peer would reject the
request.

这种方法要考虑的另一个点是peer基于请求发起者本地MSP的资格来授权事件注册请求。
很明显，由于请求发起者是一个client，它经常被当作是属于与该peer不同的MSP，
因此peer将拒绝请求。

**4) Admin and CA certificates.**

**4) 管理员和CA证书**

It is important to set MSP admin certificates to be different than any of the
certificates considered by the MSP for ``root of trust``, or intermediate CAs.
This is a common (security) practice to separate the duties of management of
membership components from the issuing of new certificates, and/or validation of existing ones.

将MSP管理员证书设成与该MSP的 ``root of trust`` 或中间CA的证书不同非常重要。
将管理成员组件和分发新和(或)验证证书的职责分开是常规(安全的)做法。

**5) Blocking an intermediate CA.**

**5) 将一个中间CA列入黑名单**

As mentioned in previous sections, reconfiguration of an MSP is achieved by
reconfiguration mechanisms (manual reconfiguration for the local MSP instances,
and via properly constructed ``config_update`` messages for MSP instances of a channel).
Clearly, there are two ways to ensure an intermediate CA considered in an MSP is no longer
considered for that MSP's identity validation:

前面提到，可以通过重新配置机制(对本地MSP实例手动重新配置，
并对通道的MSP适当的构建 ``config_update`` 消息)对MSP进行重新配置。
很明显，有两种方式将一个中间CA列入黑名单：

1. Reconfigure the MSP to no longer include the certificate of that
   intermediate CA in the list of trusted intermediate CA certs. For the
   locally configured MSP, this would mean that the certificate of this CA is
   removed from the ``intermediatecerts`` folder.
2. Reconfigure the MSP to include a CRL produced by the root of trust
   which denounces the mentioned intermediate CA's certificate.

1. 重新配置MSP，使其中间CA证书列表不再包含该中间CA。对本地已配置的MSP来说，
   这意味着这个CA的证书将从 ``intermediatecerts`` 目录移除。
2. 重新配置MSP,使其包含一个由信任根颁发的证书撤销列表，该列表包含提到的中间CA的证书。

In the current MSP implementation we only support method (1) as it is simpler
and does not require blocking the no longer considered intermediate CA.

当前的MSP实现中，我们只支持方式(1)，因为其更简单，并且不要求将不再考虑的中间CA列入黑名单。

**6) CAs and TLS CAs**

**6) CA和TLS CA**

MSP identities' root CAs and MSP TLS certificates' root CAs (and relative intermediate CAs)
need to be declared in different folders. This is to avoid confusion between
different classes of certificates. It is not forbidden to reuse the same
CAs for both MSP identities and TLS certificates but best practices suggest
to avoid this in production.

MSP身份的根CA和MSP TLS根CA(以及相关的中间CA)需要在不同的目录被定义。
这是为了避免不同类证书之间产生混淆。虽然没有禁止MSP身份和TLS证书使用相同的CA，
但这里建议避免在生成环境这样做。

