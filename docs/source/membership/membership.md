# Membership - 成员

If you've read through the documentation on [identity](../identity/identity.html)
you've seen how a PKI can provide verifiable identities through a chain
of trust. Now let's see how these identities can be used to represent the
trusted members of a blockchain network.

如果你已经通读了 [身份](../identity/identity.html) 文档，那么你应该已经看到了一个 PKI 是如何能够通过一个信任的链条来提供一个可验证的身份信息的。现在让我们看一下这些身份信息是如何能够被用来代表这些区块链网络中的可信任的成员的。

This is where a **Membership Service** Provider (MSP) comes into play ---
**it identifies which Root CAs and Intermediate CAs are trusted to define
the members of a trust domain, e.g., an organization**, either by listing the
identities of their members, or by identifying which CAs are authorized to
issue valid identities for their members, or --- as will usually be the case ---
through a combination of both.

这就是一个 **成员服务提供者** 需要上场了 --- **它定义了哪些根 CAs 和中间 CAs 是授信的来定义一个可信域的成员，比如，一个组织**，通过列出他们成员的身份信息，或者通过识别哪些 CAs 是授信的可以为他们的成员来颁发有效的身份信息的，或者 --- 通常会是这样的情况 --- 两者结合。

The power of an MSP goes beyond simply listing who is a network participant or
member of a channel. An MSP can identify specific **roles** an actor might play either
within the scope of the organization the MSP represents (e.g., admins, or as members
of a sub-organization group), and sets the basis for defining **access privileges**
in the context of a network and channel (e.g., channel admins, readers, writers).

一个 MSP 的能力远远要超过简单地列出来谁是一个网络的参与者或者是一个 channel 的成员。一个 MSP 能够在这个 MSP 所代表的组织 (比如，管理员或者作为一个子组织小组的成员)，和范围内识别一个操作者可能会扮演的特殊的 **角色**，并且在一个网络和 channel (比如 channel 管理员、只读者、写入者) 的上下文中设置定义 **访问权限** 的基础。

The configuration of an MSP is advertised to all the channels where members of
the corresponding organization participate (in the form of a **channel MSP**). In
addition to the channel MSP, peers, orderers, and clients also maintain a **local MSP**
to authenticate member messages outside the context of a channel and to define the
permissions over a particular component (who has the ability to install chaincode on
a peer, for example).

一个 MSP 的配置文件会被广播到相对应的组织的成员所参与的所有的 channel 中 (以一种 **channel MSP** 的形式)。除了 channel MSP，peers、排序节点以及客户端也维护这一个 **本地的 MSP**，来为在一个 channel 上下文之外的成员消息进行授权，并且为一个特定的组件定义权限 (比如，它有能力在一个 peer 上来安装 chaincode)。

In addition, an MSP can allow for the identification of a list of identities that
have been revoked --- as discussed in the [Identity](../identity/identity.html)
documentation --- but we will talk about how that process also extends to an MSP.

另外，一个 MSP 能够允许来识别已经被收回的身份信息的列表 --- 就像在 [身份](../identity/identity.html) 文档里讨论的那样 --- 但是我们将会聊聊关于那个流程是如何将一个 MSP 进行扩展的。

We'll talk more about local and channel MSPs in a moment. For now let's see what
MSPs do in general.

我们会在一会讨论更多关于本地和 channel MSPs 的问题。现在，让我们大体上看一下 MSPs 都在做什么。

### Mapping MSPs to Organizations - 将 MSPs 匹配到组织

An **organization** is a managed group of members. This can be something as big
as a multinational corporation or a small as a flower shop. What's most
important about organizations (or **orgs**) is that they manage their
members under a single MSP. Note that this is different from the organization
concept defined in an X.509 certificate, which we'll talk about later.

一个 **组织** 是一个被管理的成员的小组。这个可以是诸如一个大的跨国的企业或者一个小鲜花商店。对于组织 (或者 **orgs**) 来说最重要的是他们在一个单独的 MSP 下管理他们的成员。请注意，这同在一个 X.509 证书中定义的组织概念是不同的，我们会在稍后讨论。

The exclusive relationship between an organization and its MSP makes it sensible to
name the MSP after the organization, a convention you'll find adopted in most policy
configurations. For example, organization `ORG1` would likely have an MSP called
something like `ORG1-MSP`. In some cases an organization may require multiple
membership groups --- for example, where channels are used to perform very different
business functions between organizations. In these cases it makes sense to have
multiple MSPs and name them accordingly, e.g., `ORG2-MSP-NATIONAL` and
`ORG2-MSP-GOVERNMENT`, reflecting the different membership roots of trust within
`ORG2` in the `NATIONAL` sales channel compared to the `GOVERNMENT` regulatory
channel.

在一个组织和它的 MSP 间独有的关系使其很自然地将在组织之后来命名 MSP，一个你在大多数的策略配置中都能找到的一种规约。比如，组织 `ORG1` 会可能有一个 MSP 被称为类似于 `ORG1-MSP`。在一些情况中，一个组织可能会需要多个成员组 --- 比如，在不同的组织间 channels 会被用来执行不同的业务方法。在这些情况下，拥有多个 MSPs 并且为他们起对应的名字是有意义的，比如，`ORG2-MSP-NATIONAL` 和 `ORG2-MSP-GOVERNMENT`，这个反应了在 `NATIONAL` 销售 channel 和 `GOVERNMENT` 监管 channel 中的 `ORG2` 里，不同的成员的信任的 roots。

![MSP1](./membership.diagram.3.png)

*Two different MSP configurations for an organization. The first configuration shows
the typical relationship between an MSP and an organization --- a single MSP defines
the list of members of an organization. In the second configuration, different MSPs
are used to represent different organizational groups with national, international,
and governmental affiliation.*

*对于一个组织的两个不同的 MSP 配置。第一个配置显示了在一个 MSP 和一个组织间的典型的关系 --- 一个单独的 MSP 定义了一个组织的成员列表。在第二个配置中，不同的 MSPs 被用来代表具有不同国内的、国际的以及政府相关的组织的小组*

#### Organizational Units and MSPs - 组织的单位以及 MSPs

An organization is often divided up into multiple **organizational units** (OUs), each
of which has a certain set of responsibilities. For example, the `ORG1`
organization might have both `ORG1-MANUFACTURING` and `ORG1-DISTRIBUTION` OUs
to reflect these separate lines of business. When a CA issues X.509 certificates,
the `OU` field in the certificate specifies the line of business to which the
identity belongs.

一个组织通常会被分成多个 **组织的单位** (OUs)，其中的每一个具有某些特定的职责。比如 `ORG1` 这个组织可能会有 `ORG1-MANUFACTURING` 和 `ORG1-DISTRIBUTION` 两个 OUs 来反应这些分离的业务线。当一个 CA 颁发 X.509 证书的时候，这个证书中的 `OU` 字段指定了这个身份信息所归属的业务线。

We'll see later how OUs can be helpful to control the parts of an organization who
are considered to be the members of a blockchain network. For example, only
identities from the `ORG1-MANUFACTURING` OU might be able to access a channel,
whereas `ORG1-DISTRIBUTION` cannot.

我们在后边会看到 OUs 是如何能够来帮助管控一个组织的一部分，而这个组织被认为是一个区块链网络的成员。比如，只有来自于 `ORG1-MANUFACTURING` OU 的身份信息可能能够访问一个 channel，但是 `ORG1-DISTRIBUTION` 却不能。

Finally, though this is a slight misuse of OUs, they can sometimes be used by
different organizations in a consortium to distinguish each other. In such cases, the
different organizations use the same Root CAs and Intermediate CAs for their chain
of trust, but assign the `OU` field to identify members of each organization.
We'll also see how to configure MSPs to achieve this later.

最终，尽管这个是一个不正确的使用 OUs 的例子，但是他们有时可以被一个联盟中不同的组织用来区分彼此。在这种情况下，不同的组织对于他们的信任的链条使用相同的根 CAs 和中间 CAs，但是会使用 `OU` 字段来识别每个组织的成员。我们会在稍后看到如何配置 MSPs 来实现这个。

### Local and Channel MSPs - 本地和 channel MSPs

MSPs appear in two places in a blockchain network: channel configuration
(**channel MSPs**), and locally on an actor's premise (**local MSP**). **Local MSPs are
defined for clients (users) and for nodes (peers and orderers)**. Node local MSPs define
the permissions for that node (who the peer admins are, for example). The local MSPs
of the users allow the user side to authenticate itself in its transactions as a member
of a channel (e.g. in chaincode transactions), or as the owner of a specific role
into the system (an org admin, for example, in configuration transactions).

MSPs 在一个区块链网络中会出现在两个地方：channel 配置 (**channel MSPs**)，以及在一个操作者的自身 (**本地 MSP**)。**本地 MSPs 是为了客户端 (用户) 以及节点 (peers 和排序) 而定义的**。节点本地 MSPs 定义了那个节点的权限 (比如，谁是 peer admin)。用户的本地 MSPs 允许用户这边作为一个 channel 中的一员在他的交易中为自己认证 (比如在 chaincode 交易中)，或者在系统中作为一个指定角色的所有者 (比如，一个组织的管理员，在配置交易中)。

**Every node and user must have a local MSP defined**, as it defines who has
administrative or participatory rights at that level (peer admins will not necessarily
be channel admins, and vice versa).

**每个节点和用户必须要有一个本地的 MSP 被定义**，因为它定义了在那个级别谁具有管理员或者参与者的权利 (peer 管理员并没有必要是 channel 管理员，反过来也一样)。

In contrast, **channel MSPs define administrative and participatory rights at the
channel level**. Every organization participating in a channel must have an MSP
defined for it. Peers and orderers on a channel will all share the same view of channel
MSPs, and will therefore be able to correctly authenticate the channel participants.
This means that if an organization wishes to join the channel, an MSP incorporating
the chain of trust for the organization's members would need to be included in the
channel configuration. Otherwise transactions originating from this organization's
identities will be rejected.

相反，**channel MSPs 定义了在 channel 级别的管理员和参与者的权利**。对于每一个参与到一个 channel 的组织，必须要为它定义一个 MSP。在一个 channel 中的 peers 和排序节点将会全部共享 channel MSP 的相同的视图，并且因此能够正确的认证 channel 的参与者。这意味着如果一个组织希望加入到一个 channel，一个与组织成员的信任的链条相结合的 MSP 需要被包含到 channel 的配置中。否则的话，从这个组织的身份而来的交易会被拒绝。

The key difference here between local and channel MSPs is not how they function
--- both turn identities into roles --- but their **scope**.

这里，在本地和 channel 的 MSPs 主要的不同是他们是如何工作的 --- 他们都是将身份变为角色 --- 但是是他们的 **范围**。

<a name="msp2img"></a>

![MSP2](./membership.diagram.4.png)

*Local and channel MSPs. The trust domain (e.g., the organization) of each
peer is defined by the peer's local MSP, e.g., ORG1 or ORG2. Representation
of an organization on a channel is achieved by adding the organization's MSP to
the channel configuration. For example, the channel of this figure is managed by
both ORG1 and ORG2. Similar principles apply for the network, orderers, and users,
but these are not shown here for simplicity.*

*本地以及 channel MSPs。每个 peer 的信任的域 (比如，组织) 是由 peer 的本地 MSP 来定义的，比如 ORG1 或者 ORG2。对于一个 channel 上的一个组织的表现，是通过将组织的 MSP 添加到 channel 配置中的方式来实现的。比如，这个图中的 channel 是由 ORG1 和 ORG2 来管理的。类似的概念可以应用在网络、排序节点和用户上边，但是为了简单，这些在这里并没有表示出来。*

You may find it helpful to see how local and channel MSPs are used by seeing
what happens when a blockchain administrator installs and instantiates a smart
contract, as shown in the [diagram above](#msp2img).

你可能会发现，通过查看像 [上边的图表](#msp2img) 中所示的当一个区块链管理员安装并初始化一个智能合约的时候都发生了什么，这对于理解本地和 channel MSPs 是如何被使用的是很有帮助的。

An administrator `B` connects to the peer with an identity issued by `RCA1`
and stored in their local MSP. When `B` tries to install a smart contract on
the peer, the peer checks its local MSP, `ORG1-MSP`, to verify that the identity
of `B` is indeed a member of `ORG1`. A successful verification will allow the
install command to complete successfully. Subsequently, `B` wishes
to instantiate the smart contract on the channel. Because this is a channel
operation, all organizations on the channel must agree to it. Therefore, the
peer must check the MSPs of the channel before it can successfully commit this
command. (Other things must happen too, but concentrate on the above for now.)

一个管理员 `B` 使用一个由 `RCA1` 颁发的身份信息连接到了 peer，并且将它存储到了他们的本地 MSP 中。当 `B` 尝试在 peer 上安装一个智能合约的时候，peer 会检查它的 local MSP，`ORG1-MSP`，来验证 `B` 的身份确实是 `ORG1` 的一个成员。一个成功的确认会允许这个安装的命令能够成功地完成。接下来，`B` 希望在 channel 上初始化智能合约。因为这是一个 channel 的操作，所有在这个 channel 上的组织必须要都同意。因此，在这个命令能够被成功提交之前，peer 必须要检查 channel 的 MSPs。 (其他的一些事情也是必须要发生的，但是现在让我们主要关注在上边说的这些事情上边。)

**Local MSPs are only defined on the file system of the node or user** to which
they apply. Therefore, physically and logically there is only one local MSP per
node or user. However, as channel MSPs are available to all nodes in the
channel, they are logically defined once in the channel configuration. However,
**a channel MSP is also instantiated on the file system of every node in the
channel and kept synchronized via consensus**. So while there is a copy of each
channel MSP on the local file system of every node, logically a channel MSP
resides on and is maintained by the channel or the network.

**本地的 MSPs 只会在节点或者用户的文件系统上被定义**，这个节点或者用户是他们要被应用的。因此，物理上并且逻辑上，对于一个节点或者用户，这里只有一个本地的 MSP。然而，因为 channel MSPs 对于 channel 中的所有节点都是可用的，所以他们只会在 channel 配置中被逻辑地定义一次。但是，**一个 channel MSP 也会在 channel 中每个节点的文件系统上被初始化并且通过公式保持同步**。所以尽管在每个节点的本地文件系统上都有每个 channel MSP 的一个副本，但是逻辑上一个 channel MSP 是存在于 channel 或者网络上并且是由 channel 或者网络来维护的。

### MSP Levels - MSP 层级

The split between channel and local MSPs reflects the needs of organizations
to administer their local resources, such as a peer or orderer nodes, and their
channel resources, such as ledgers, smart contracts, and consortia, which
operate at the channel or network level. It's helpful to think of these MSPs
as being at different **levels**, with **MSPs at a higher level relating to
network administration concerns** while **MSPs at a lower level handle
identity for the administration of private resources**. MSPs are mandatory
at every level of administration --- they must be defined for the network,
channel, peer, orderer, and users.

对于 channel 和本地 MSPs 的分离体现了组织对于管理他们本地资源的需求，比如一个 peer 或者排序节点，以及他们的 channel 资源，比如账本、智能合约，和在 channel 或者网络层级上进行操作的联盟。将这些 MSPs 理解为是处在不同的 **层级** 上是非常有用的，**在更高层级的 MSPs 是处理网络管理的问题**，**在更低层级的 MSPs 是处理管理私有资源的身份**。MSPs 对于每个层级的管理工作都是必须的 --- 他们必须要为网络、channel、peer、排序节点和用户来定义。

![MSP3](./membership.diagram.2.png)

*MSP Levels. The MSPs for the peer and orderer are local, whereas the MSPs for a
channel (including the network configuration channel) are shared across all
participants of that channel. In this figure, the network configuration channel
is administered by ORG1, but another application channel can be managed by ORG1
and ORG2. The peer is a member of and managed by ORG2, whereas ORG1 manages the
orderer of the figure. ORG1 trusts identities from RCA1, whereas ORG2 trusts
identities from RCA2. Note that these are administration identities, reflecting
who can administer these components. So while ORG1 administers the network,
ORG2.MSP does exist in the network definition.*

*MSP 层级。对于 peer 和排序节点的 MSPs 是本地的，但是对于一个 channel (包括网络配置 channel) 的 MSPs 对于这个 channel 的所有参与者是共享的。在这个图中，网络配置 channel 是由 ORG1 来管理的，但是另外一个应用程序 channel 可以由 ORG1 和 ORG2 来管理。这个 peer 是 ORG2 的一个成员并且它由 ORG2 来管理，ORG1 管理图中的排序节点。ORG1 相信来自于 RCA1 的身份，然而 ORG2 相信来自于 RCA2 的身份。注意到这些是管理者身份，反应了谁能够管理这些组件。所以尽管 ORG1 管理着网络，但是 ORG2.MSP 却不在网络定义中存在。*

 * **Network MSP:** The configuration of a network defines who are the
 members in the network --- by defining the MSPs of the participant organizations
 --- as well as which of these members are authorized to perform
 administrative tasks (e.g., creating a channel).
 
 * **网络 MSP：** 一个网络的配置文件，定义了谁是这个网络中的成员 --- 通过定义参与组织的 MSPs --- 并且定义了这些成员中的哪些被授权来进行管理相关的任务 (比如，创建一个 channel)。

 * **Channel MSP:** It is important for a channel to maintain the MSPs of its members
 separately. A channel provides private communications between a particular set of
 organizations which in turn have administrative control over it. Channel policies
 interpreted in the context of that channel's MSPs define who has ability to
 participate in certain action on the channel, e.g., adding organizations, or
 instantiating chaincodes. Note that there is no necessary relationship between
 the permission to administrate a channel and the ability to administrate the
 network configuration channel (or any other channel). Administrative rights
 exist within the scope of what is being administrated (unless the rules have
 been written otherwise --- see the discussion of the `ROLE` attribute below).
 
 * **Channel MSP：** 对于一个 channel 来说，分别维护它的成员的 MSPs 非常重要。一个 channel 在一个指定的一系列组织间提供了一个私有的通信方式，这些组织又对这个 channel 进行管理。在这个 channel 的 MSPs 的上下文中被解释执行的 channel 策略定义了谁有能力来参与到在这个 channel 上的某些操作中，比如，添加组织，或者实例化 chaincode。注意，在管理一个 channel 的权限和管理网络配置 channel (或者任何其他的 channel) 之间没有必然的联系。管理的权利存在于什么被管理的范围中 (除非规则已经被制定，否则 --- 查看下边对于 `ROLE` 属性的讨论)。

 * **Peer MSP:** This local MSP is defined on the file system of each peer and there is a
 single MSP instance for each peer. Conceptually, it performs exactly the same function
 as channel MSPs with the restriction that it only applies to the peer where it is defined.
 An example of an action whose authorization is evaluated using the peer's local MSP is
 the installation of a chaincode on the peer.
 
 * **Peer MSP：** 这个本地 MSP 是在每个 peer 的文件系统上定义的，并且对于每个 peer 都有一个单独的 MSP 实例。概念上讲，它同 channel MSPs 执行这完全一样的操作，但是具有这些操作仅仅能够被应用到它被定义的那个 peer 上的限制。对于使用 peer 的本地 MSP 来判定谁被授权进行的一个操作的例子就是在 peer 上安装一个 chaincode。

 * **Orderer MSP:** Like a peer MSP, an orderer local MSP is also defined on the file system
 of the node and only applies to that node. Like peer nodes, orderers are also owned by a single
 organization and therefore have a single MSP to list the actors or nodes it trusts.
 
 * **排序节点 MSP：** 像一个 peer MSP，一个排序节点的本地 MSP 也是在节点的文件系统上定义的，并且只会应用于这个节点。就像 peer 节点，排序节点也是由一个单独的组织所有，因此具有一个单独的 MSP 来列出它所信任的操作者或者节点。

### MSP Structure - MSP 结构

So far, you've seen that the most important element of an MSP are the specification
of the root or intermediate CAs that are used to establish an actor's or node's
membership in the respective organization. There are, however, more elements that are
used in conjunction with these two to assist with membership functions.

目前为止，你所看到的对于一个 MSP 最为重要的元素就是对于根或者中间 CAs 的声明，这些 CAs 被用来在对应的组织中建立一个参与者或者节点的成员身份。然而这里还有更多的元素同这两个元素一起被用来帮助成员相关的功能。

![MSP4](./membership.diagram.5.png)

*The figure above shows how a local MSP is stored on a local filesystem. Even though
channel MSPs are not physically structured in exactly this way, it's still a helpful
way to think about them.*

*上边的图片展示了一个本地的 MSP 是如何被存储到一个本地文件系统上的。尽管 channel MSPs 不是像这种方式那样被物理地构建起来，但是这还是一个对于理解他们有帮助的方式。*

As you can see, there are nine elements to an MSP. It's easiest to think of these elements
in a directory structure, where the MSP name is the root folder name with each
subfolder representing different elements of an MSP configuration.

就像你看到的那样，对于一个 MSP，这里有九个元素。将这些元素按照一个目录结构的方式理解最为简单，在这个目录结构中，MSP 名字是根文件夹，它下边有代表一个 MSP 配置的不同元素的子文件夹。

Let's describe these folders in a little more detail and see why they are important.

让我们更详细地描述一下这些文件夹，并且看看他们为什么很重要。

* **Root CAs:** This folder contains a list of self-signed X.509 certificates of
  the Root CAs trusted by the organization represented by this MSP.
  There must be at least one Root CA X.509 certificate in this MSP folder.

  This is the most important folder because it identifies the CAs from
  which all other certificates must be derived to be considered members of the
  corresponding organization.
  
* **根 CAs：** 这个文件夹包含了一个这个 MSP 所代表的组织所信任的根证书的自签名 X.509 证书列表。在这个 MSP 文件夹中至少要有一个根 CA X.509 证书。
  
  这是最重要的一个文件夹，因为它标识了可以被认为是对应组织的成员的所有其他的证书的来源 CAs。

* **Intermediate CAs:** This folder contains a list of X.509 certificates of the
  Intermediate CAs trusted by this organization. Each certificate must be signed by
  one of the Root CAs in the MSP or by an Intermediate CA whose issuing CA chain ultimately
  leads back to a trusted Root CA.

  An intermediate CA may represent a different subdivision of the organization
  (like `ORG1-MANUFACTURING` and `ORG1-DISTRIBUTION` do for `ORG1`), or the
  organization itself (as may be the case if a commercial CA is leveraged for
  the organization's identity management). In the latter case intermediate CAs
  can be used to represent organization subdivisions. [Here](../msp.html) you
  may find more information on best practices for MSP configuration. Notice, that
  it is possible to have a functioning network that does not have an Intermediate
  CA, in which case this folder would be empty.

  Like the Root CA folder, this folder defines the CAs from which certificates must be
  issued to be considered members of the organization.
  
* **中间 CAs：** 这个文件夹包含了由这个组织所信任的中间 CAs 对应的 X.509 证书列表。每个证书必须要由这个 MSP 中的一个根 CAs 来签发，或者有一个中间 CA 来签发，这个中间 CA 的签发 CA 的链条最终能够导向回一个授信的根 CA。
  
  一个中间 CA 可能代表了该组织的一个不同的细分 (就像对于 `ORG1` 会有 `ORG1-MANUFACTURING` 和 `ORG1-DISTRIBUTION`)，或者是这个组织自身 (比如就像一个商业的 CA 被用来作为组织的身份管理这样的一个情况)。在后边这个情况中，中间 CAs 可以被用来代表组织的细分。[从这里](../msp.html) 你可能找到关于对于 MSP 配置的最佳实践的更多信息。注意，对于一个可工作的网络来说，没有任何的中间 CA 是可能的，对于这种情况，这个文件夹就是空的。
  
  就像根 CA 文件夹一样，这个文件夹定义了能够被认为是某个组织的成员的证书所来自的 CAs。


* **Organizational Units (OUs):** These are listed in the `$FABRIC_CFG_PATH/msp/config.yaml`
  file and contain a list of organizational units, whose members are considered
  to be part of the organization represented by this MSP. This is particularly
  useful when you want to restrict the members of an organization to the ones
  holding an identity (signed by one of MSP designated CAs) with a specific OU
  in it.

  Specifying OUs is optional. If no OUs are listed, all the identities that are part of
  an MSP --- as identified by the Root CA and Intermediate CA folders --- will be considered
  members of the organization.
  
* **组织单元 (OUs)** 这些在 `$FABRIC_CFG_PATH/msp/config.yaml` 文件中被列出来，并且包含了组织单元的一个列表，他们的成员被认为是由这个 MSP 所代表的组织的一部分。这个在当你想要将组织的成员限定在那些具有某个指定的 OU 在其身份信息中的成员 (这个身份信息是由 MSP 指定的 CAs 签发的)。
  
  指定 OUs 是可选的。如果没有列出任何的的 OUs，对于作为一个 MSP 的一部分的所有身份信息 --- 作为由根 CA 和中间 CA 文件夹标识的 --- 将会被认为是组织的成员。

* **Administrators:** This folder contains a list of identities that define the
  actors who have the role of administrators for this organization. For the standard MSP type,
  there should be one or more X.509 certificates in this list.

  It's worth noting that just because an actor has the role of an administrator it doesn't
  mean that they can administer particular resources! The actual power a given identity has
  with respect to administering the system is determined by the policies that manage system
  resources. For example, a channel policy might specify that `ORG1-MANUFACTURING`
  administrators have the rights to add new organizations to the channel, whereas the
  `ORG1-DISTRIBUTION` administrators have no such rights.

  Even though an X.509 certificate has a `ROLE` attribute (specifying, for example, that
  an actor is an `admin`), this refers to an actor's role within its organization
  rather than on the blockchain network. This is similar to the purpose of
  the `OU` attribute, which --- if it has been defined --- refers to an actor's place in
  the organization.

  The `ROLE` attribute **can** be used to confer administrative rights at the channel level
  if the policy for that channel has been written to allow any administrator from an organization
  (or certain organizations) permission to perform certain channel functions (such as
  instantiating chaincode). In this way, an organizational role can confer a network role.
  
* **管理员：** 这个文件夹包含了定义对于该组织来讲具有管理员角色的操作者的所有身份信息的列表。对于标准的 MSP 类型，在这个列表中应该有一个或者多个 X509 证书。

  如果一个操作者具有一个管理者的角色但是它却不能管理某个资源，那这样就没有任何意义了！对于一个给定的身份所具有的实际的权利以及对于系统的相关的管理是由管理系统资源的策略所决定的。比如，一个 channel 策略可能会指明 `ORG1-MANUFACTURING` 管理员有权利来向 channel 中添加新的组织，然而 `ORG1-DISTRIBUTION` 管理员却没有这个权利。
  
  尽管这样，一个 X.509 证书具有一个 `ROLE` 属性 (具体来讲，比如一个操作者是一个 `admin`)，这个指的是在它的组织而不是在这个区块链网络上的一个操作者的角色。这个跟 `OU` 属性的目的是类似的 --- 如果它被定义了的话 --- 参考在组织中的一个操作者的地方。
  
  如果这个 channel 已经写入了这个允许任何来自于一个组织 (或者某些组织) 的管理员的权限来执行某个 channel 方法 (比如初始化 chaincode) 的策略的话，这个 `ROLE` 属性 **能够** 被用来在 channel 层级授予管理者权限。

* **Revoked Certificates:** If the identity of an actor has been revoked,
  identifying information about the identity --- not the identity itself --- is held
  in this folder. For X.509-based identities, these identifiers are pairs of strings known as
  Subject Key Identifier (SKI) and Authority Access Identifier (AKI), and are checked
  whenever the X.509 certificate is being used to make sure the certificate has not
  been revoked.

  This list is conceptually the same as a CA's Certificate Revocation List (CRL),
  but it also relates to revocation of membership from the organization. As a result,
  the administrator of an MSP, local or channel, can quickly revoke an actor or node
  from an organization by advertising the updated CRL of the CA the revoked certificate
  as issued by. This "list of lists" is optional. It will only become populated
  as certificates are revoked.

* **收回证书：** 如果一个参与者的身份信息被收回，有关这个身份信息的标识信息 --- 不是指身份信息本身 --- 被放置于这个文件夹中。对于基于 X.509 身份信息，这些标识符是以主体密钥标识符 (SKI) 以及权限访问标识符 (AKI) 的形式的字符串对，并且会在 X.509 证书被使用的时候被检查，以确保证书没有被收回。

  这个列表在概念上跟一个 CA 的证书回收列表 (CRL) 是一样的，但是它也同从组织中收回成员有关。作为结果，对于本地或者 channel 的一个 MSP 的管理员，能够通过将这个 CA 的更新过的 CRL 广播的方式，快速地从一个组织中收回一个参与者或者节点，这个 CA 就是颁发这个要回收的证书的 CA。

* **Node Identity:** This folder contains the identity of the node, i.e.,
  cryptographic material that --- in combination to the content of `KeyStore` --- would
  allow the node to authenticate itself in the messages that is sends to other
  participants of its channels and network. For X.509 based identities, this
  folder contains an **X.509 certificate**. This is the certificate a peer places
  in a transaction proposal response, for example, to indicate that the peer has
  endorsed it --- which can subsequently be checked against the resulting
  transaction's endorsement policy at validation time.

  This folder is mandatory for local MSPs, and there must be exactly one X.509 certificate
  for the node. It is not used for channel MSPs.

* **节点身份信息：** 这个文件夹包含了节点的身份信息，比如，加密材料 --- 同 `KeyStore` 的内容合并起来 --- 将会允许节点在被发送到其他的该 channel 和网络的参与者的信息当中来为自己授权。对于基于 X.509 的身份信息，这个文件夹包含了一个 **X.509 证书**。这是一个 peer 会放置到一笔交易提案的反馈中的证书，比如，来表述这个 peer 已经为它背书 --- 这个可以在接下来的验证阶段同产生结果的交易的背书策略相比较来进行验证。

  这个文件夹对于本地 MSPs 是必须的，并且对于这个节点这里也必须要有一个 X.509 证书。Channel MSPs 是不需要有这个的。

* **`KeyStore` for Private Key:** This folder is defined for the local MSP of a peer or
  orderer node (or in an client's local MSP), and contains the node's **signing key**.
  This key matches cryptographically the node's identity included in **Node Identity**
  folder and is used to sign data --- for example to sign a transaction proposal response,
  as part of the endorsement phase.

  This folder is mandatory for local MSPs, and must contain exactly one private key.
  Obviously, access to this folder must be limited only to the identities of users who have
  administrative responsibility on the peer.

  Configuration of a **channel MSPs** does not include this folder, as channel MSPs
  solely aim to offer identity validation functionalities and not signing abilities.

* **私钥的 `KeyStore`：** 这个文件夹是为了一个 peer 或者排序节点 (或者在一个客户端的本地 MSP 中) 的本地 MSP 来定义的，并且包含了节点的 **签名秘钥**。这个秘钥与包含在 **节点身份信息** 文件夹里的节点的身份信息密码上匹配，并且会被用来对数据提供签名 --- 比如作为背书阶段的一部分，会对一个交易提案的反馈提供签名。

  这个文件夹对于本地 MSPs 是必须的，并且必须要包含一个私钥。很显然，对于这个文件夹的访问，必须要仅仅局限于对于这个 peer 有管理职责的用户的身份信息。
  
  一个 **channel MSPs** 的配置信息不回包含这个文件夹，因为 channel MSPs 仅仅是为了提供身份信息验证的功能，而不是为了提供签名的能力。

* **TLS Root CA:** This folder contains a list of self-signed X.509 certificates of the
  Root CAs trusted by this organization **for TLS communications**. An example of a TLS
  communication would be when a peer needs to connect to an orderer so that it can receive
  ledger updates.

  MSP TLS information relates to the nodes inside the network --- the peers and the
  orderers, in other words, rather than the applications and administrations that
  consume the network.

  There must be at least one TLS Root CA X.509 certificate in this folder.

* **TLS 根 CA：** 这个文件夹包含了一个自签名的 X.509 证书列表，这个 X.509 证书是由这个组织信任的根 CAs 颁发的证书，这是 **为了 TLS 通信** 的目的。一个 TLS 通信的例子就是当一个 peer 需要连接到一个排序节点，所以他才能够接收到账本的更新。

  MSP TLS 信息跟在这个网络内部的节点有关联 --- peers 节点和排序节点，换句话说，这个并不是指消费这个网络的应用程序和管理功能。
  
  在这个文件夹中必须至少有一个 TLS 根 CA X.509 证书。

* **TLS Intermediate CA:** This folder contains a list intermediate CA certificates
  CAs trusted by the organization represented by this MSP **for TLS communications**.
  This folder is specifically useful when commercial CAs are used for TLS certificates of an
  organization. Similar to membership intermediate CAs, specifying intermediate TLS CAs is
  optional.

  For more information about TLS, click [here](../enable_tls.html).
  
* **TLS 中间 CA：** 这个文件夹包含了一个中间证书 CAs 的列表，这些 CAs 被这个 MSP 所代表的的组织所信任，这是 **为了 TLS 通信** 的目的。这个文件夹在当商业的 CAs 被用于一个组织的 TLS 证书的时候特别有用。跟成员的中间 CAs 类似，指定中间 TLS CAs 是可选的。

  关于 TLS 的更多信息，点击 [这里](../enable_tls.html)。

If you've read this doc as well as our doc on [Identity](../identity/identity.html), you
should have a pretty good grasp of how identities and membership work in Hyperledger Fabric.
You've seen how a PKI and MSPs are used to identify the actors collaborating in a blockchain
network. You've learned how certificates, public/private keys, and roots of trust work,
in addition to how MSPs are physically and logically structured.

如果你已经读过了这个文档并且也读了 [身份](../identity/identity.html) 文档的话，对于身份信息和成员在 Hyperledger Fabric 中是如何工作的，你应该已经有了很好的了解了。你已经看到了一个 PKI 和 MSPs 是如何被用于识别在一个区块链网络中协作的参与者的。你已经学到了证书、公/私钥以及信任的根是如何工作的，并且了解了 MSPs 是如何在物理上和逻辑上被构建的。

<!---
Licensed under Creative Commons Attribution 4.0 International License https://creativecommons.org/licenses/by/4.0/
-->
