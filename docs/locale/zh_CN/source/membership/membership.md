# 成员
# Membership Service Provider (MSP)

如果你已经阅读了[身份](../identity/identity.html)文档，那么你应该已经看到了 PKI 是如何通过信任链来提供可验证身份信息的。现在让我们看一下这些身份信息是如何被用来代表这些区块链网络中可信任成员的。

## Why do I need an MSP?

这就需要**成员服务提供者（MSP）**上场了，通过列出成员的身份信息，或者通过识别哪些授权 CA 可以为成员来颁发有效身份信息（通常会两者结合），**它会识别哪些可信的根 CA 和中间 CA 可以定义一个可信的成员，比如，一个组织**。

Because Fabric is a permissioned network, blockchain participants need a way to prove their identity to the rest of the network in order to transact on the network. If you've read through the documentation on [Identity](../identity/identity.html)
you've seen how a Public Key Infrastructure (PKI) can provide verifiable identities through a chain of trust. How is that chain of trust used by the blockchain network?

MSP 的能力远远不止简单地罗列谁是网络参与者或者通道成员。MSP 能够识别操作者可能会扮演的特定**角色**，无论是在 MSP 代表的组织（比如，管理员或者子组织的成员）范围内，还是在网络和通道（比如通道管理员、读取者和写入者）的上下文中设置基础的**访问权限**。

Certificate Authorities issue identities by generating a public and private key which forms a key-pair that can be used to prove identity. Because a private key can never be shared publicly, a mechanism is required to enable that proof which is where the MSP comes in. For example, a peer uses its private key to digitally sign, or endorse, a transaction.  The MSP on the ordering service contains the peer's public key which is then used to verify that the signature attached to the transaction is valid. The private key is used to produce a signature on a transaction that only the corresponding public key, that is part of an MSP, can match. Thus, the MSP is the mechanism that allows that identity to be trusted and recognized by the rest of the network without ever revealing the member’s private key.

MSP 的配置文件会被广播到相应组织的成员参与的所有通道中(以**通道 MSP** 的形式)。除了通道 MSP，Peer 节点、排序节点以及客户端也维护一个**本地 MSP**，来为通道上下文之外的成员消息进行授权和为特定组件定义权限（比如，谁有能力在 Peer 节点上安装链码）。

Recall from the credit card scenario in the Identity topic that the Certificate Authority is like a card provider — it dispenses many different types of verifiable identities. An MSP, on the other hand, determines which credit card providers are accepted at the store. In this way, the MSP turns an identity (the credit card) into a role (the ability to buy things at the store).

另外，MSP 能够识别已经被收回的身份信息列表，就像在[身份](../identity/identity.html)文档里讨论的那样，但是我们将会聊一下那个过程是如何扩展到 MSP 中的。

This ability to turn verifiable identities into roles is fundamental to the way Fabric networks function, since it allows organizations, nodes, and channels the ability establish MSPs that determine who is allowed to do what at the organization, node, and channel level.

我们等下会讨论更多关于本地和通道 MSP 的问题。现在，让我们整体上看一下 MSP 都在做什么。

![MSP1a](./membership.msp.diagram.png)

### 将 MSP 映射到组织

*Identities are similar to your credit cards that are used to prove you can pay. The MSP is similar to the list of accepted credit cards.*

**组织**是管理成员的组。它可以是一个大的跨国的企业或者小鲜花商店。通常一个组织会被表示一个单独的 MSP。请注意，这和 X.509 证书中定义的组织概念是不同的，我们会在稍后讨论。

Consider a consortium of banks that operate a blockchain network. Each bank operates peer and ordering nodes, and the peers endorse transactions submitted to the network. However, each bank would also have departments and account holders. The account holders would belong to each organization, but would not run nodes on the network. They would only interact with the system from their mobile or web application. So how does the network recognize and differentiate these identities? A CA was used to create the identities, but like the card example, those identities can't just be issued, they need to be recognized by the network. MSPs are used to define the organizations that are trusted by the network members. MSPs are also the mechanism that provide members with a set of roles and permissions within the network. Because the MSPs defining these organizations are known to the members of a network, they can then be used to validate that network entities that attempt to perform actions are allowed to.

组织和它的 MSP 间独有的关系使其很自然地将使用组织来命名 MSP，这种规则你在大多数的策略配置中都能找到。比如，组织 `ORG1` 会可能有一个被称为类似于 `ORG1-MSP` 的 MSP。在一些情况中，一个组织可能会需要多个成员组，比如，在不同的组织间 通道会被用来执行不同的业务。在这些情况下，拥有多个 MSP 并且为它们起对应的名字是有意义的，比如，`ORG2-MSP-NATIONAL` 和 `ORG2-MSP-GOVERNMENT`，这个反应了在 `NATIONAL` 销售通道和 `GOVERNMENT` 监管通道中 `ORG2` 不同的成员信任根。

Finally, consider if you want to join an _existing_ network, you need a way to turn your identity into something that is recognized by the network. The MSP is the mechanism that enables you to participate on a permissioned blockchain network. To transact on a Fabric network a member needs to:

![MSP1](./membership.diagram.3.png)

1. Have an identity issued by a CA that is trusted by the network.
2. Become a member of an _organization_ that is recognized and approved by the network members. The MSP is how the identity is linked to the membership of an organization. Membership is achieved by adding the member's public key (also known as certificate, signing cert, or signcert) to the organization’s MSP.
3. Add the MSP to either a [consortium](../glossary.html#consortium) on the network or a channel.
4. Ensure the MSP is included in the [policy](../policies/policies.html) definitions on the network.

*一个组织的两个不同 MSP 配置。第一个配置显示了 MSP 和组织间的典型的关系——一个单独的 MSP 定义了一个组织的成员列表。在第二个配置中，不同的 MSP 被用来代表具有不同国内的、国际的以及政府相关的组织*

## What is an MSP?

#### 组织单位以及 MSP

Despite its name, the Membership Service Provider does not actually provide anything. Rather, the implementation of the MSP requirement is a set of folders that are added to the configuration of the network and is used to define an organization both inwardly (organizations decide who its admins are) and outwardly (by allowing other organizations to validate that entities have the authority to do what they are attempting to do).  Whereas Certificate Authorities generate the certificates that represent identities, the MSP contains a list of permissioned identities.

一个组织通常会被分成多个**组织单位**（OUs），其中每一个都具有某些特定的职责。比如 `ORG1` 这个组织可能会有 `ORG1-MANUFACTURING` 和 `ORG1-DISTRIBUTION` 两个 OUs 来对应这些分离的业务线。当 CA 颁发 X.509 证书的时候，证书中的 `OU` 字段指定了这个身份信息所归属的业务线。

The MSP identifies which Root CAs and Intermediate CAs are accepted to define the members of a trust domain by listing the identities of their members, or by identifying which CAs are authorized to issue valid identities for their members.

我们在后边会看到 OUs 是如何帮助管控区块链网络中组织的各部分的。比如，只有 `ORG1-MANUFACTURING` OU 的身份信息才能访问通道，但是 `ORG1-DISTRIBUTION` 却不能。

But the power of an MSP goes beyond simply listing who is a network participant or member of a channel. It is the MSP that turns an identity into a **role** by identifying specific privileges an actor has on a node or channel. Note that when a user is registered with a Fabric CA, a role of admin, peer, client, orderer, or member must be associated with the user. For example, identities registered with the "peer" role should, naturally, be given to a peer. Similarly, identities registered with the "admin" role should be given to organization admins. We'll delve more into the significance of these roles later in the topic.

最终，尽管这是一个不正确的使用 OUs 的例子，但是他们有时可以被联盟中不同的组织用来区分彼此。在这种情况下，不同的组织对于他们信任链使用相同的根 CA 和中间 CA，但是会使用 `OU` 字段来识别每个组织的成员。我们会在稍后看到如何配置 MSP 来实现这个。

In addition, an MSP can allow for the identification of a list of identities that have been revoked --- as discussed in the [Identity](../identity/identity.html) documentation --- but we will talk about how that process also extends to an MSP.

### 本地和通道 MSP

## MSP domains

MSP 在一个区块链网络中会出现在两个地方：
*在通道配置（**通道 MSP**）
*在一个操作者的节点本地（**本地 MSP**)

MSPs occur in two domains in a blockchain network:

**本地 MSP 是为客户端（用户）以及节点（Peer 节点和排序节点）定义的**。节点本地 MSP 定义了节点的权限（比如，谁是节点管理员）。用户的本地 MSP 允许用户在交易中证明自己是通道的成员（比如在链码交易中），或者系统中指定角色的所有者（比如，在配置交易中的组织管理员）。

* Locally on an actor's node (**local MSP**)
* In channel configuration (**channel MSP**)

**每个节点和用户必须定义一个本地 MSP**，它定义了在那个级别谁具有管理员或者参与者的权利(Peer 节点管理员并没有必要是通道管理员，反过来也一样）。

The key difference between local and channel MSPs is not how they function -- both turn identities into roles -- but their **scope**. Each MSP lists roles and permissions at a particular level of administration.

相反，**通道 MSP 定义了在通道级别的管理员和参与者的权利**。对于每一个参与到通道的组织，必须要为它定义一个 MSP。在通道中的 Peer 节点和排序节点将会共享相同的通道 MSP 视图，并且因此能够正确的识别通道的参与者。这意味着如果一个组织希望加入到一个通道，就需要把和组织成员信任链相关的 MSP 包含到通道的配置中。否则，这个组织的身份发来的交易就会被拒绝。

### Local MSPs

这里，在本地和通道的 MSP 主要的不同不是它们的功能（都是将身份变为角色），而是他们的**范围**。

**Local MSPs are defined for clients and for nodes (peers and orderers)**.
Local MSPs define the permissions for a node (who are the peer admins who can operate the node, for example). The local MSPs of clients (the account holders in the banking scenario above), allow the user to authenticate itself in its transactions as a member of a channel (e.g. in chaincode transactions), or as the owner of a specific role into the system such as an organization admin, for example, in configuration transactions.

<a name="msp2img"></a>

**Every node must have a local MSP defined**, as it defines who has administrative or participatory rights at that level (peer admins will not necessarily be channel admins, and vice versa).  This allows for authenticating member messages outside the context of a channel and to define the permissions over a particular node (who has the ability to install chaincode on a peer, for example). Note that one or more nodes can be owned by an organization. An MSP defines the organization admins. And the organization, the admin of the organization, the admin of the node, and the node itself should all have the same root of trust.

![MSP2](./membership.diagram.4.png)

An orderer local MSP is also defined on the file system of the node and only applies to that node. Like peer nodes, orderers are also owned by a single organization and therefore have a single MSP to list the actors or nodes it trusts.

*本地和通道MSP。每个 Peer 节点的信任域 (比如，组织) 是由 Peer 节点的本地 MSP 来定义的，比如 ORG1 或者 ORG2。对于通道上的一个组织的表示，是通过将组织的 MSP 添加到通道配置中的方式来实现的。比如，这个图中的通道是由 ORG1 和 ORG2 来管理的。类似的概念可以应用在网络、排序节点和用户上，但是为了简单，这些在这里并没有表示出来。*

### Channel MSPs

通过观察[上图](#msp2img)所展示的，区块链管理员安装和实例化智能合约时都发生了什么，你会发现这对理解如何使用本地和通道 MSP 是很有帮助的。

In contrast, **channel MSPs define administrative and participatory rights at the channel level**. Peers and ordering nodes on an application channel share the same view of channel MSPs, and will therefore be able to correctly authenticate the channel participants. This means that if an organization wishes to join the channel, an MSP incorporating the chain of trust for the organization's members would need to be included in the channel configuration. Otherwise transactions originating from this organization's identities will be rejected. Whereas local MSPs are represented as a folder structure on the file system, channel MSPs are described in a channel configuration.

管理员 `B` 使用一个由 `RCA1` 颁发的身份信息连接到了 Peer 节点，并存储到了他们的本地 MSP 中。当 `B` 尝试在 Peer 节点上安装一个智能合约的时候，Peer 节点会检查他的本地 MSP `ORG1-MSP` 来验证 `B` 的身份确实是 `ORG1` 的成员。确认成功才允许安装命令成功完成。接下来，`B` 希望在通道上实例化智能合约。因为这是一个通道的操作，需要通道上的所有组织都同意。因此，在这个命令被成功提交之前，Peer 节点必须要检查通道的 MSP。 (也会发生一些其他的事情，但是现在我们主要关注上边说的这些事情。)

![MSP1d](./ChannelMSP.png)

**本地 MSP 只会定义在它们要被应用的节点或者用户的文件系统上**。因此，每一个节点或用户在物理上和逻辑上只有一个本地 MSP。然而，因为通道 MSP 对于通道中所有节点都是可用的，所以他们只会在通道配置中被逻辑地定义一次。但是，**通道 MSP 也会在通道中每个节点的文件系统上被初始化并且通过共识保持同步**。所以尽管在每个节点的本地文件系统上都有每个通道 MSP 的副本，但是逻辑上通道 MSP 是存在于通道或者网络上并且由通道或者网络来维护的。

*Snippet from a channel config.json file that includes two organization MSPs.*

### MSP 级别

**Channel MSPs identify who has authorities at a channel level**.
The channel MSP defines the _relationship_ between the identities of channel members (which themselves are MSPs) and the enforcement of channel level policies. Channel MSPs contain the MSPs of the organizations of the channel members.

对于通道和本地 MSP 的分离体现了组织对于管理他们本地资源的需求，比如 Peer 节点或者排序节点，以及他们的通道资源，比如账本、智能合约，和在通道或者网络级别上进行操作的联盟。将这些 MSP 理解为处在不同的**级别**上是非常有用的，**高级别的 MSP 处理网络管理问题**，**低级别的 MSP 处理管理私有资源的身份问题**。MSP 对于每个级别的管理工作都是必须的，也就是说必须要为网络、通道、Peer 节点、排序节点和用户定义 MSP。

**Every organization participating in a channel must have an MSP defined for it**. In fact, it is recommended that there is a one-to-one mapping between organizations and MSPs. The MSP defines which members are empowered to act on behalf of the organization. This includes configuration of the MSP itself as well as approving administrative tasks that the organization has role, such as adding new members to a channel. If all network members were part of a single organization or MSP, data privacy is sacrificed. Multiple organizations facilitate privacy by segregating ledger data to only channel members. If more granularity is required within an organization, the organization can be further divided into organizational units (OUs) which we describe in more detail later in this topic.

![MSP3](./membership.diagram.2.png)

**The system channel MSP includes the MSPs of all the organizations that participate in an ordering service.** An ordering service will likely include ordering nodes from multiple organizations and collectively these organizations run the ordering service, most importantly managing the consortium of organizations and the default policies that are inherited by the application channels.

*MSP 级别。Peer 节点和排序节点的 MSP 是本地的，但是通道（包括网络配置通道）的 MSP 会共享给通道的所有参与者。在这个图中，网络配置通道是由 ORG1 来管理的，但是另外一个应用通道可以由 ORG1 和 ORG2 来管理。这个 Peer 节点是 ORG2 的成员并由 ORG2 来管理，ORG1 管理图中的排序节点。ORG1 相信来自 RCA1 的身份，而 ORG2 相信来自 RCA2 的身份。注意，这些是管理者身份，表示谁能管理这些组件。所以尽管 ORG1 管理着网络，但是 ORG2.MSP 却不在网络定义中。*

**Local MSPs are only defined on the file system of the node or user** to which they apply. Therefore, physically and logically there is only one local MSP per
node. However, as channel MSPs are available to all nodes in the channel, they are logically defined once in the channel configuration. However, **a channel MSP is also instantiated on the file system of every node in the channel and kept synchronized via consensus**. So while there is a copy of each channel MSP on the local file system of every node, logically a channel MSP resides on and is maintained by the channel or the network.

 * **网络 MSP：** 网络配置通过定义参与组织的 MSP 定义了谁是这个网络的成员，并且定义了授权哪些成员执行管理任务（比如，创建通道）。

The following diagram illustrates how local and channel MSPs coexist on the network:  

 * **通道 MSP：** 通道单独维护着它的成员的 MSP，这个非常重要。通道在指定的一系列组织间提供了私有的通信方式，这些组织又管理着这个通道。在通道 MSP 上下文中的通道策略定义了谁有能力参与通道上的某些操作，比如，添加组织，或者实例化链码。注意，在管理通道的权限和管理网络配置通道（或者其他任何通道） 之间没有必然的联系。管理的权利存在于什么被管理的范围中（除非规则已经被制定，否则请查看下边对于 `ROLE` 属性的讨论）。

![MSP3](./membership.diagram.2.png)

 * **Peer 节点MSP：** 这个本地 MSP 定义在每个 Peer 节点的文件系统上，并且对于每个 Peer 节点都有一个单独的 MSP 实例。概念上讲，它同通道 MSP 执行着完全一样的操作，但是具有这些操作只能应用到它被定义的那个 Peer 节点上。使用 Peer 节点本地 MSP 来判定谁被授权操作的例子就是在 Peer 节点上安装链码。

*The MSPs for the peer and orderer are local, whereas the MSPs for a channel (including the network configuration channel, also known as the system channel) are global, shared across all participants of that channel. In this figure, the network system channel is administered by ORG1, but another application channel can be managed by ORG1 and ORG2. The peer is a member of and managed by ORG2, whereas ORG1 manages the orderer of the figure. ORG1 trusts identities from RCA1, whereas ORG2 trusts identities from RCA2. It is important to note that these are administration identities, reflecting who can administer these components. So while ORG1 administers the network, ORG2.MSP does exist in the network definition.*

 * **排序节点 MSP：** 就像 Peer 节点MSP，排序节点本地 MSP 也定义在节点的文件系统上，并且只会应用于该节点。就像 Peer 节点，排序节点也是由一个单独的组织所有，因此具有一个单独的 MSP 来列出它所信任的操作者或者节点。

## What role does an organization play in an MSP?

### MSP 结构

An **organization** is a logical managed group of members. This can be something as big as a multinational corporation or a small as a flower shop. What's most important about organizations (or **orgs**) is that they manage their members under a single MSP. The MSP allows an identity to be linked to an organization. Note that this is different from the organization concept defined in an X.509 certificate, which we mentioned above.

目前为止，你所看到的对于 MSP 最为重要的元素就是对根或者中间 CA 的声明，这些 CA 被用来在对应的组织中建立一个参与者或者节点的成员身份。然而这里还有更多的元素和这两个元素一起使用来帮助实现成员功能。

The exclusive relationship between an organization and its MSP makes it sensible to name the MSP after the organization, a convention you'll find adopted in most policy configurations. For example, organization `ORG1` would likely have an MSP called something like `ORG1-MSP`. In some cases an organization may require multiple membership groups --- for example, where channels are used to perform very different business functions between organizations. In these cases it makes sense to have multiple MSPs and name them accordingly, e.g., `ORG2-MSP-NATIONAL` and `ORG2-MSP-GOVERNMENT`, reflecting the different membership roots of trust within `ORG2` in the `NATIONAL` sales channel compared to the `GOVERNMENT` regulatory channel.

![MSP4](./membership.diagram.5.png)

### Organizational Units (OUs) and MSPs

*上边的图片展示了本地 MSP 是如何被存储到本地文件系统上的。尽管通道 MSP 不是像这样被物理地构建起来，但是这仍有助于你的理解。*

An organization can also be divided into multiple **organizational units**, each of which has a certain set of responsibilities, also referred to as `affiliations`. Think of an OU as a department inside an organization. For example, the `ORG1` organization might have both `ORG1.MANUFACTURING` and `ORG1.DISTRIBUTION` OUs to reflect these separate lines of business. When a CA issues X.509 certificates, the `OU` field in the certificate specifies the line of business to which the identity belongs. A benefit of using OUs like this is that these values can then be used in policy definitions in order to restrict access or in smart contracts for attribute-based access control. Otherwise, separate MSPs would need to be created for each organization.

就像你看到的那样，一个 MSP 有九个元素。将这些元素按照目录结构的方式理解会更简单，在这个目录结构中，MSP 名字是根文件夹，它下边有代表 MSP 配置的不同元素的子文件夹。

Specifying OUs is optional. If OUs are not used, all of the identities that are part of an MSP --- as identified by the Root CA and Intermediate CA folders --- will be considered members of the organization.

让我们更详细地描述一下这些文件夹，并且看看他们为什么如此重要。

### Node OU Roles and MSPs

* **Root CAs（根 CA）：** 这个文件夹包含了这个 MSP 所代表的组织信任的根证书的自签名 X.509 证书列表。在这个 MSP 文件夹中至少要有一个根 CA X.509 证书。
  
  这是最重要的一个文件夹，因为它是用来识别组织成员的所有其他证书的来源的 CA。

Additionally, there is a special kind of OU, sometimes referred to as a `Node OU`, that can be used to confer a role onto an identity. These Node OU roles are defined in the `$FABRIC_CFG_PATH/msp/config.yaml` file and contain a list of organizational units whose members are considered to be part of the organization represented by this MSP. This is particularly useful when you want to restrict the members of an organization to the ones holding an identity (signed by one of MSP designated CAs) with a specific Node OU role in it. For example, with node OU's you can implement a more granular endorsement policy that requires Org1 peers to endorse a transaction, rather than any member of Org1.

* **Intermediate CAs（中间 CA）：** 这个文件夹包含了由这个组织所信任的中间 CA 对应的 X.509 证书列表。每个证书必须要由这个 MSP 中的根 CA 或者中间 CA 来签发，中间 CA 的信任链最终要能追溯到授信的根 CA。
  
  中间 CA 可能代表了该组织的不同细分（就像 `ORG1` 会有 `ORG1-MANUFACTURING` 和 `ORG1-DISTRIBUTION`），或者是这个组织自身（比如一个商业 CA 被用来作为组织身份管理的情况）。在后边的情况中，中间 CA 可以被用来代表组织的细分。[从这里](../msp.html) 你可能找到关于对于 MSP 配置的最佳实践的更多信息。注意，对于一个可用网络来说，可以没有任何中间 CA，对于这种情况，这个文件夹就是空的。
  
  就像根 CA 文件夹一样，这个文件夹定义了能够被认为是某个组织的成员的证书所来自的 CA。

In order to use the Node OU roles, the "identity classification" feature must be enabled for the network. When using the folder-based MSP structure, this is accomplished by enabling "Node OUs" in the config.yaml file which resides in the root of the MSP folder:

* **Organizational Units （组织单元，OUs）** 这些在 `$FABRIC_CFG_PATH/msp/config.yaml` 文件中被列出来，并且包含了组织单元的一个列表，他们的成员被认为是由这个 MSP 所代表的组织的一部分。当你想要将组织的成员限定在其身份信息中有某个指定 OU 时是很有用的（这个身份信息是由 MSP 指定的 CA 签发的）。
  
  指定 OU 是可选的。如果没有列出任何的 OU，对于 MSP 的所有身份信息（由根 CA 和中间 CA 文件夹标识）都将会被认为是组织的成员。

```
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.sampleorg-cert.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.sampleorg-cert.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.sampleorg-cert.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.sampleorg-cert.pem
    OrganizationalUnitIdentifier: orderer
```

* **Administrators（管理员）：** 这个文件夹包含了该组织管理元的身份信息列表。对于标准的 MSP 类型，在这个列表中应该有一个或者多个 X509 证书。

In the example above, there are 4 possible Node OU `ROLES` for the MSP:

  值得一提的是，一个操作者具有管理员角色但是并不意味着他可以管理某个资源！因为身份所具有的实际权利以及对于系统的相关管理是由管理系统资源的策略所决定的。比如，通道策略可能会指明 `ORG1-MANUFACTURING` 管理员有权利向通道中添加新的组织，然而 `ORG1-DISTRIBUTION` 管理员却没有这个权利。
  
  尽管这样，X.509 证书有一个 `ROLE` 属性（具体来讲，比如操作者是一个 `admin`），这指的是在它的组织而不是在这个区块链网络上的操作者的角色。这个跟 `OU` 属性的目的是类似的（如果它被定义了的话）取决于操作者在组织中的位置。
  
  如果在通道级别已经写入了允许来自任何组织（或者某些组织）的管理员来执行某个通道方法（比如实例化）的策略的话，`ROLE` 属性就**能够**被用来在通道级别授予管理者权限。

   * client
   * peer
   * admin
   * orderer

* **Revoked Certificates（已收回证书）：** 如果一个参与者的身份信息已经被收回，有关这个身份信息的标识信息（不是指身份本身）会被放进这个文件夹中。对于基于 X.509 的身份信息，这些标识符是以主体密钥标识符（Subject Key Identifier，SKI）以及权限访问控制符（Authority Access Identifier，AKI）组成的字符串对，并且会在 X.509 证书被使用的时候被检查，以确保证书没有被收回。

This convention allows you to distinguish MSP roles by the OU present in the CommonName attribute of the X509 certificate. The example above says that any certificate issued by cacerts/ca.sampleorg-cert.pem in which OU=client will identified as a client, OU=peer as a peer, etc. Starting with Fabric v1.4.3, there is also an OU for the orderer and for admins. The new admins role means that you no longer have to explicitly place certs in the admincerts folder of the MSP directory. Rather, the `admin` role present in the user's signcert qualifies the identity as an admin user.

  这个列表在概念上跟 CA 的证书回收列表（CRL）是一样的，但是它也和从组织中收回成员有关。因此，本地或者通道的 MSP 管理员可以将 CA 更新过的 CRL 以广播的方式，快速地从组织中收回参与者或者节点，这个 CA 就是颁发这个要回收的证书的 CA。这个列表的列表是可选的。它只在证书被回收的时候才有用。

These Role and OU attributes are assigned to an identity when the Fabric CA or SDK is used to `register` a user with the CA. It is the subsequent `enroll` user command that generates the certificates in the users' `/msp` folder.   

* **Node Identity（节点身份）：** 这个文件夹包含了节点的身份信息，比如，加密材料（和 `KeyStore` 的内容一起）将会允许节点在被发送到其他通道和网络的参与者的信息当中来为自己授权。对于基于 X.509 的身份信息，这个文件夹包含了一个 **X.509 证书**。这是 Peer 节点会放置到一笔交易提案的反馈中的证书，比如，来表述这个 Peer 节点已经为它背书——这可以在接下来的验证阶段同产生结果的交易的背书策略相比较来进行验证。

![MSP1c](./ca-msp-visualization.png)

  这个文件夹对于本地 MSP 是必须的，并且对于这个节点这里也必须要有一个 X.509 证书。通道 MSP 是不需要有这个的。

The resulting ROLE and OU attributes are visible inside the X.509 signing certificate located in the `/signcerts` folder. The `ROLE` attribute is identified as `hf.Type` and  refers to an actor's role within its organization, (specifying, for example, that an actor is a `peer`). See the following snippet from a signing certificate shows how the Roles and OUs are represented in the certificate.

* **私钥的 `KeyStore`：** 这个文件夹是为 Peer 节点或者排序节点（或者在客户端的本地 MSP 中）的本地 MSP 定义的，并且包含了节点的**签名秘钥**。这个秘钥与包含在**节点身份信息**文件夹里的节点的身份信息密码相匹配，并且会被用来对数据提供签名——比如作为背书阶段的一部分，会对一个交易提案的响应提供签名。

![MSP1d](./signcert.png)

  这个文件夹对于本地 MSP 是必须的，并且必须要包含一个私钥。很显然，对于这个文件夹的访问，必须要局限于对这个 Peer 节点有管理职责的用户的身份信息。
  
  **通道 MSP** 的配置信息不会包含这个文件夹，因为通道 MSP 仅仅是为了提供身份信息验证的功能，而不是为了提供签名的能力。

**Note:** For Channel MSPs, just because an actor has the role of an administrator it doesn't mean that they can administer particular resources. The actual power a given identity has with respect to administering the system is determined by the _policies_ that manage system resources. For example, a channel policy might specify that `ORG1-MANUFACTURING` administrators, meaning identities with a role of `admin` and a Node OU of  `ORG1-MANUFACTURING`, have the rights to add new organizations to the channel, whereas the `ORG1-DISTRIBUTION` administrators have no such rights.

* **TLS Root CA（TLS 根 CA）：** 这个文件夹包含了一个自签名的 X.509 证书列表，这个 X.509 证书是由这个组织信任的根 CA 颁发的，这是**为了 TLS 通信**的目的。一个 TLS 通信的例子就是 Peer 节点需要连接到排序节点，所以他才能够接收到账本的更新。

Finally, OUs could be used by different organizations in a consortium to distinguish each other. But in such cases, the different organizations have to use the same Root CAs and Intermediate CAs for their chain of trust, and assign the OU field to identify members of each organization. When every organization has the same CA or chain of trust, this makes the system more centralized than what might be desirable and therefore deserves careful consideration on a blockchain network.

  MSP TLS 信息跟在这个网络内部的节点有关联（Peers 节点和排序节点），换句话说，这个并不是指消费这个网络的应用程序和管理功能。
  
  在这个文件夹中必须至少有一个 TLS 根 CA X.509 证书。

## MSP Structure

* **TLS Intermediate CA（TLS 中间 CA）：** 这个文件夹包含了一个中间 CA 的列表，这些 CA 被这个 MSP 代表的组织所信任，这是**为了 TLS 通信** 的目的。这个文件夹在当商业的 CA 被用于一个组织的 TLS 证书的时候特别有用。跟成员的中间 CA 类似，指定中间 TLS CA 是可选的。

Let's explore the MSP elements that render the functionality we've described so far.

  关于 TLS 的更多信息，点击 [这里](../enable_tls.html)。
  
如果你已经读过了这个文档并且也读了[身份](../identity/identity.html)文档的话，对于身份信息和成员在 Hyperledger Fabric 中是如何工作的，你应该已经有了很好的了解了。你已经看到了一个 PKI 和 MSP 是如何被用于识别区块链网络中协作的参与者的。你已经学到了证书、公/私钥以及信任的根是如何工作的，并且了解了 MSP 是如何在物理上和逻辑上被构建的。

A local MSP folder contains the following sub-folders:

![MSP6](./membership.diagram.6.png)

*The figure above shows the subfolders in a local MSP on the file system*

* **config.yaml:**  Used to configure the identity classification feature in Fabric by enabling "Node OUs" and defining the accepted roles.

* **cacerts:** This folder contains a list of self-signed X.509 certificates of the Root CAs trusted by the organization represented by this MSP. There must be at least one Root CA certificate in this MSP folder.

  This is the most important folder because it identifies the CAs from which all other certificates must be derived to be considered members of the
  corresponding organization to form the chain of trust.

* **intermediatecerts:** This folder contains a list of X.509 certificates of the Intermediate CAs trusted by this organization. Each certificate must be signed by one of the Root CAs in the MSP or by any Intermediate CA whose issuing CA chain ultimately leads back to a trusted Root CA.

  An intermediate CA may represent a different subdivision of the organization (like `ORG1-MANUFACTURING` and `ORG1-DISTRIBUTION` do for `ORG1`), or the
  organization itself (as may be the case if a commercial CA is leveraged for the organization's identity management). In the latter case intermediate CAs
  can be used to represent organization subdivisions. [Here](../msp.html) you may find more information on best practices for MSP configuration. Notice, that
  it is possible to have a functioning network that does not have an Intermediate CA, in which case this folder would be empty.

  Like the Root CA folder, this folder defines the CAs from which certificates must be issued to be considered members of the organization.

* **admincerts (Deprecated from Fabric v1.4.3 and higher):** This folder contains a list of identities that define the actors who have the role of administrators for this organization. In general, there should be one or more X.509 certificates in this list.

  **Note:** Prior to Fabric v1.4.3, admins were defined by explicitly putting certs in the `admincerts` folder in the local MSP directory of your peer. **With Fabric v1.4.3 or higher, certificates in this folder are no longer required.** Instead, it is recommended that when the user is registered with the CA, that the `admin` role is used to designate the node administrator. Then, the identity is recognized as an `admin` by the Node OU role value in their signcert. As a reminder, in order to leverage the admin role, the "identity classification" feature must be enabled in the config.yaml above by setting "Node OUs" to `Enable: true`. We'll explore this more later.

  And as a reminder, for Channel MSPs, just because an actor has the role of an administrator it doesn't mean that they can administer particular resources. The actual power a given identity has with respect to administering the system is determined by the _policies_ that manage system resources. For example, a channel policy might specify that `ORG1-MANUFACTURING` administrators have the rights to add new organizations to the channel, whereas the `ORG1-DISTRIBUTION` administrators have no such rights.

* **keystore: (private Key)** This folder is defined for the local MSP of a peer or orderer node (or in a client's local MSP), and contains the node's private key. This key is used to sign data --- for example to sign a transaction proposal response, as part of the endorsement phase.

  This folder is mandatory for local MSPs, and must contain exactly one private key. Obviously, access to this folder must be limited only to the identities of users who have administrative responsibility on the peer.

  The **channel MSP** configuration does not include this folder, because channel MSPs solely aim to offer identity validation functionalities and not signing abilities.

  **Note:** If you are using a [Hardware Security Module(HSM)](../hsm.html) for key management, this folder is empty because the private key is generated by and stored in the HSM.

* **signcert:** For a peer or orderer node (or in a client's local MSP) this folder contains the node's **signing key**. This key matches cryptographically the node's identity included in **Node Identity** folder and is used to sign data --- for example to sign a transaction proposal response, as part of the endorsement phase.

  This folder is mandatory for local MSPs, and must contain exactly one public key. Obviously, access to this folder must be limited only to the identities of users who have  administrative responsibility on the peer.

  Configuration of a **channel MSP** does not include this folder, as channel MSPs solely aim to offer identity validation functionalities and not signing abilities.

* **tlscacerts:** This folder contains a list of self-signed X.509 certificates of the Root CAs trusted by this organization **for secure communications between nodes using TLS**. An example of a TLS communication would be when a peer needs to connect to an orderer so that it can receive ledger updates.

  MSP TLS information relates to the nodes inside the network --- the peers and the orderers, in other words, rather than the applications and administrations that consume the network.

  There must be at least one TLS Root CA certificate in this folder. For more information about TLS, see [Securing Communication with Transport Layer Security (TLS)](../enable_tls.html).

* **tlsintermediatecacerts:** This folder contains a list intermediate CA certificates CAs trusted by the organization represented by this MSP **for secure communications between nodes using TLS**. This folder is specifically useful when commercial CAs are used for TLS certificates of an organization. Similar to membership intermediate CAs, specifying intermediate TLS CAs is optional.

* **operationscerts:** This folder contains the certificates required to communicate with the [Fabric Operations Service](../operations_service.html) API.

A channel MSP includes the following additional folder:

* **Revoked Certificates:** If the identity of an actor has been revoked, identifying information about the identity --- not the identity itself --- is held in this folder. For X.509-based identities, these identifiers are pairs of strings known as Subject Key Identifier (SKI) and Authority Access Identifier (AKI), and are checked whenever the certificate is being used to make sure the certificate has not been revoked.

  This list is conceptually the same as a CA's Certificate Revocation List (CRL), but it also relates to revocation of membership from the organization. As a result, the administrator of a channel MSP can quickly revoke an actor or node from an organization by advertising the updated CRL of the CA. This "list of lists" is optional. It will only become populated as certificates are revoked.

If you've read this doc as well as our doc on [Identity](../identity/identity.html), you
should now have a pretty good grasp of how identities and MSPs work in Hyperledger Fabric.
You've seen how a PKI and MSPs are used to identify the actors collaborating in a blockchain
network. You've learned how certificates, public/private keys, and roots of trust work,
in addition to how MSPs are physically and logically structured.
