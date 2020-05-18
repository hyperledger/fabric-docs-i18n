# 策略

**受众**： 架构师，应用和智能合约开发者，管理员

本主题将包含：

* [策略是什么](#策略是什么)
* [为什么需要策略](#为什么需要策略)
* [Fabric 是如何实现策略](#Fabric是如何实现策略的)
* [Fabric 策略作用域](#策略作用域)
* [如何将策略写入 Fabric](#如何将策略写入Fabric)
* [Fabric 链码生命周期](#Fabric链码生命周期)
* [覆盖策略定义](#覆盖策略定义)

## 策略是什么

从根本上来说，策略是一组规则，用来定义如何做出决策和实现特定结果。为此，策略一般描述了**谁**和**什么**，比如一个人对**资产**访问或者权限。我们可以看到，在我们的日常生活中策略也在保护我们的资产数据，比如汽车租金、健康、我们的房子等。

例如，购买保险时，保险策略定义了条件、项目、限制和期限。该策略经过了策略持有者和保险公司的一致同意，定义了各方的权利和责任。

保险策略用于风险管理，在 Hyperledger Fabric 中，策略是基础设施的管理机制。Fabric 策略表示成员如何同意或者拒绝网络、通道或者智能合约的变更。策略在网络最初配置的时候由联盟成员一致同意，但是当在网络演化的过程中可以进行修改。例如，他们定义了从通道中添加或者删除成员的标准，改变区块格式或者指定需要给智能合约背书的组织数量。所有这些定义谁可以干什么的行为都在策略中描述。简单来说，你在 Fabric 网络中的所有想做的事情，都要受到策略的控制。

## 为什么需要策略

策略是使 Hyperledger Fabric 不同于其他区块链系统（比如 Ethereum 或者 Bitcoin）的内容之一。这其他系统中，交易可以在网络中的任意节点生成和验证。治理网络的策略可以在任何时间及时修复，并且只可以使用和治理代码相同的方式进行变更。因为 Fabric 是授权区块链，用户由底层基础设施识别，所以用户可以在启动前决定网络的治理方式，以及改变正在运行的网络的治理方式。

策略决定了那些组织可以访问或者更新 Fabric 网络，并且提供了强制执行这些决策的机制。策略包含了有权访问给定资源的组织列表，比如一个用户或者系统链码。他们同样指定了需要多少组织同意更新资源的提案，比如通道或者智能合约。一旦策略被写入，他们就会评估交易和提案中的签名，并验证签名是否满足网络治理规则。

## Fabric是如何实现策略的

策略实现在 Fabric 网络的不同层次。每个策略域都管理着网络操作的不同方面。

![policies.policies](./FabricPolicyHierarchy-2.png) *Fabric 策略层级图。*

### 系统通道配置

每个网络都从排序服务**系统通道**开始。网络中必须有至少一个排序服务的排序系统通道，它是第一个被创建的通道。该通道也包含着谁是排序服务（排序服务组织）以及在网络中交易（联盟组织）的成员。

排序系统通道配置区块中的策略治理着排序服务使用的共识，并定义了新区块如何被创建。系统通道也治理着联盟中的哪些成员可以创建新通道。

### 应用通道配置

应用 _通道_ 用于向联盟中的组织间提供私有通信机制。

应用通道中的策略治理着从通道中添加和删除成员的能力。应用通道也治理着使用 Fabric 链码生命周期在链码定义和提交到通道前需要哪些组织同意。当系统通道初始创建时，它默认继承了排序系统通道的所有排序服务参数。同时，这些参数（包括治理它们的策略）可以被每个通道自定义。

### 权限控制列表（ACL）

网络管理员可能对 Fabric 中 ACL 的使用更感兴趣，ACL 通过将资源和已有策略相关联的方式提供了资源访问配置的能力。“资源”可以是系统链码中的方法（例如，“qscc”中的“GetBlockByNumber”）或者其他资源（例如，谁可以获取区块事件）。ACL 参考应用通道配置中定义的策略并将它们扩展到了其他资源的控制。Fabric ACL 的默认集合在 `configtx.yaml` 文件的 `Application: &ApplicationDefaults` 部分，但是它们可以也应该在生产环境中被重写。`configtx.yaml` 中定义的资源列表是 Fabric 当前定义的所有内部资源的完整集合。

该文件中，ACL 以如下格式表示：

```
# ACL policy for chaincode to chaincode invocation
peer/ChaincodeToChaincode: /Channel/Application/Readers
```

`peer/ChaincodeToChaincode` 表示该资源是被保护的，相关的交易必须符合 `/Channel/Application/Readers` 引用侧策略才能被认为是有效的。

关于 ACL 更深入的信息，请参考操作指南中的 [ACL](../access_control.html) 主题。

### 智能合约背书策略

链码包中的每一个智能合约都有一个背书策略，该策略指明了需要通道中多少不同组织的成员根据指定智能合约执行和验证交易才能使一笔交易有效。因此，背书策略定义了必须“背书”（批准）提案执行的组织（的 Peer 节点）。

### 修改策略

还有一个对 Fabric 的策略工作有重要作用的策略类型—— `Modification policy`。修改策略指明了需要签名所有配置 _更新_ 的一组身份。它是定义如何更新策略的策略。因此，每个通道配置元素都包含这一个治理它的变更的策略的引用。

## 策略作用域

虽然 Fabric 的策略很灵活地配置以适应网络需要，但是策略的结构天然地隔离了由不同排序服务组织或者不同联盟成员治理的域。下边的图中，你可以看到默认策略是如何实现对 Fabric 策略域的控制的。

![policies.policies](./FabricPolicyHierarchy-4.png) *排序组织和联名组织治理的策略域的详细视图。*

一个完整的 Fabric 网络可以由许多不同职能的组织组成。通过支持排序服务创建者建立初始规则和联盟成员的方式，域提供了向不同组织扩展不同的优先级和角色的能力。还支持联盟中的组织创建私有应用通道、治理他们自己的商业逻辑以及限制网络中数据的访问权限。

系统通道配置和每个应用通道配置部分提供了排序组织对哪些组织是联盟成员、区块如何分发到通道以及排序服务节点使用的共识机制的控制。

系统通道配置为联盟成员提供了创建通道的能力。应用通道和 ACL 是联盟组织用来从通道中添加或删除成员以及限制通道中智能合约和数据访问的机制。

## 如何将策略写入 Fabric

如果你想修改 Fabric 的任何东西，和资源相关的策略都描述了**谁**需要批准它，无论是明确使用某个还是一组身份的离线签名还是一组。在保险领域，一个明确的签名可以是业主保险代理集团中的一员。而一个隐含的签名类似于需要业主保险代理集团中的大多数管理成员批准。这很重要，因为集团中的成员可以在不更新策略的情况下变动。在 Hyperledger Fabric 中，策略中明确的签名使用 `Signature` 语法，隐含的签名使用 `ImplicitMeta` 语法。

### 签名策略

`Signature` 策略定义了要满足策略就必须签名的特定用户类型，比如 `Org1.Peer OR Org2.Peer`。策略是很强大的，应为它可以构造复杂的规则，比如“组织 A 和 2 个其他管理员，或者 6 个组织的管理员中的 5 个”。语法支持 `AND`、 `OR` 和 `NOutOf` 的任意组合。例如，一个策略可以简单表达为使用 `AND (Org1, Org2)` ，表示满足该策略就同时需要 Org1 中的一个成员和 Org2 中的一个成员的签名。

### ImplicitMeta 策略

`ImplicitMeta` policies are only valid in the context of channel configuration
which is based on a tiered hierarchy of policies in a configuration tree. ImplicitMeta
policies aggregate the result of policies deeper in the configuration tree that
are ultimately defined by Signature policies. They are `Implicit` because they
are constructed implicitly based on the current organizations in the
channel configuration, and they are `Meta` because their evaluation is not
against specific MSP principals, but rather against other sub-policies below
them in the configuration tree.

The following diagram illustrates the tiered policy structure for an application
channel and shows how the `ImplicitMeta` channel configuration admins policy,
named `/Channel/Admins`, is resolved when the sub-policies named `Admins` below it
in the configuration hierarchy are satisfied where each check mark represents that
the conditions of the sub-policy were satisfied.

![policies.policies](./FabricPolicyHierarchy-6.png)

As you can see in the diagram above, `ImplicitMeta` policies, Type = 3, use a
different syntax, `"<ANY|ALL|MAJORITY> <SubPolicyName>"`, for example:
```
`MAJORITY sub policy: Admins`
```
The diagram shows a sub-policy `Admins`, which refers to all the `Admins` policy
below it in the configuration tree. You can create your own sub-policies
and name them whatever you want and then define them in each of your
organizations.

As mentioned above, a key benefit of an `ImplicitMeta` policy such as `MAJORITY
Admins` is that when you add a new admin organization to the channel, you do not
have to update the channel policy. Therefore `ImplicitMeta` policies are
considered to be more flexible as the consortium members change. The consortium
on the orderer can change as new members are added or an existing member leaves
with the consortium members agreeing to the changes, but no policy updates are
required. Recall that `ImplicitMeta` policies ultimately resolve the
`Signature` sub-policies underneath them in the configuration tree as the
diagram shows.

You can also define an application level implicit policy to operate across
organizations, in a channel for example, and either require that ANY of them
are satisfied, that ALL are satisfied, or that a MAJORITY are satisfied. This
format lends itself to much better, more natural defaults, so that each
organization can decide what it means for a valid endorsement.

Further granularity and control can be achieved if you include [`NodeOUs`](msp.html#organizational-units) in your
organization definition. Organization Units (OUs) are defined in the Fabric CA
client configuration file and can be associated with an identity when it is
created. In Fabric, `NodeOUs` provide a way to classify identities in a digital
certificate hierarchy. For instance, an organization having specific `NodeOUs`
enabled could require that a 'peer' sign for it to be a valid endorsement,
whereas an organization without any might simply require that any member can
sign.

## 示例：通道配置策略

Understanding policies begins with examining the `configtx.yaml` where the
channel policies are defined. We can use the `configtx.yaml` file in the BYFN
(first-network) tutorial to see examples of both policy syntax types. Navigate to the [fabric-samples/first-network](https://github.com/hyperledger/fabric-samples/blob/master/first-network/configtx.yaml)
directory and examine the configtx.yaml file for BYFN.

The first section of the file defines the Organizations of the network. Inside each
organization definition are the default policies for that organization, `Readers, Writers,
Admins, and Endorsement`, although you can name your policies anything you want.
Each policy has a `Type` which describes how the policy is expressed (`Signature`
or `ImplicitMeta`) and a `Rule`.

The BYFN example below shows the `Org1` organization definition in the system
channel, where the policy `Type` is `Signature` and the Endorsement policy rule
is defined as `"OR('Org1MSP.peer')"` which  means that peer that is a member of
`Org1MSP` is required to sign. It is these Signature policies that become the
sub-policies that the ImplicitMeta policies point to.  

<details>
  <summary>
    **Click here to see an example of an organization defined with signature policies**
  </summary>

```
 - &Org1
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: Org1MSP

        # ID to load the MSP definition as
        ID: Org1MSP

        MSPDir: crypto-config/peerOrganizations/org1.example.com/msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('Org1MSP.peer')"
```
</details>

The next example shows the `ImplicitMeta` policy type used in the `Orderer`
section of the `configtx.yaml` file which defines the default
behavior of the orderer and also contains the associated policies `Readers`,
`Writers`, and `Admins`. Again, these ImplicitMeta policies are evaluated based
on their underlying Signature sub-policies which we saw in the snippet above.

<details>
  <summary>
    **Click here to see an example of ImplicitMeta policies**
  </summary>
```

################################################################################
#
#   SECTION: Orderer
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters
#
################################################################################
Orderer: &OrdererDefaults

# Organizations is the list of orgs which are defined as participants on
# the orderer side of the network
Organizations:

# Policies defines the set of policies at this level of the config tree
# For Orderer policies, their canonical path is
#   /Channel/Orderer/<PolicyName>
Policies:
Readers:
    Type: ImplicitMeta
    Rule: "ANY Readers"
Writers:
    Type: ImplicitMeta
    Rule: "ANY Writers"
Admins:
    Type: ImplicitMeta
    Rule: "MAJORITY Admins"
# BlockValidation specifies what signatures must be included in the block
# from the orderer for the peer to validate it.
BlockValidation:
    Type: ImplicitMeta
    Rule: "ANY Writers"

```
</details>

## Fabric 链码生命周期

In the Fabric 2.0 release, a new chaincode lifecycle process was introduced,
whereby a more democratic process is used to govern chaincode on the network.
The new process allows multiple organizations to vote on how a chaincode will
be operated before it can be used on a channel. This is significant because it is
the combination of this new lifecycle process and the policies that are
specified during that process that dictate the security across the network. More details on
the flow are available in the [Chaincode for Operators](../chaincode4noah.html)
tutorial, but for purposes of this topic you should understand how policies are
used in this flow. The new flow includes two steps where policies are specified:
when chaincode is **approved**  by organization members, and when it is **committed**
to the channel.

The `Application` section of  the `configtx.yaml` file includes the default
chaincode lifecycle endorsement policy. In a production environment you would
customize this definition for your own use case.

```
################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
```

- The `LifecycleEndorsement` policy governs who needs to _approve a chaincode
definition_.
- The `Endorsement` policy is the _default endorsement policy for
a chaincode_. More on this below.

## 链码背书策略

The endorsement policy is specified for a **chaincode** when it is approved
and committed to the channel using the Fabric chaincode lifecycle (that is, one
endorsement policy covers all of the state associated with a chaincode). The
endorsement policy can be specified either by reference to an endorsement policy
defined in the channel configuration or by explicitly specifying a Signature policy.

If an endorsement policy is not explicitly specified during the approval step,
the default `Endorsement` policy `"MAJORITY Endorsement"` is used which means
that a majority of the peers belonging to the different channel members
(organizations) need to execute and validate a transaction against the chaincode
in order for the transaction to be considered valid.  This default policy allows
organizations that join the channel to become automatically added to the chaincode
endorsement policy. If you don't want to use the default endorsement
policy, use the Signature policy format to specify a more complex endorsement
policy (such as requiring that a chaincode be endorsed by one organization, and
then one of the other organizations on the channel).

Signature policies also allow you to include `principals` which are simply a way
of matching an identity to a role. Principals are just like user IDs or group
IDs, but they are more versatile because they can include a wide range of
properties of an actor’s identity, such as the actor’s organization,
organizational unit, role or even the actor’s specific identity. When we talk
about principals, they are the properties which determine their permissions.
Principals are described as 'MSP.ROLE', where `MSP` represents the required MSP
ID (the organization),  and `ROLE` represents one of the four accepted roles:
Member, Admin, Client, and Peer. A role is associated to an identity when a user
enrolls with a CA. You can customize the list of roles available on your Fabric
CA.

Some examples of valid principals are:
* 'Org0.Admin': an administrator of the Org0 MSP
* 'Org1.Member': a member of the Org1 MSP
* 'Org1.Client': a client of the Org1 MSP
* 'Org1.Peer': a peer of the Org1 MSP
* 'OrdererOrg.Orderer': an orderer in the OrdererOrg MSP

There are cases where it may be necessary for a particular state
(a particular key-value pair, in other words) to have a different endorsement
policy. This **state-based endorsement** allows the default chaincode-level
endorsement policies to be overridden by a different policy for the specified
keys.

For a deeper dive on how to write an endorsement policy refer to the topic on
[Endorsement policies](../endorsement-policies.html) in the Operations Guide.

**Note:**  Policies work differently depending on which version of Fabric you are
  using:
- In Fabric releases prior to 2.0, chaincode endorsement policies can be
  updated during chaincode instantiation or by using the chaincode lifecycle
  commands. If not specified at instantiation time, the endorsement policy
  defaults to “any member of the organizations in the channel”. For example,
  a channel with “Org1” and “Org2” would have a default endorsement policy of
  “OR(‘Org1.member’, ‘Org2.member’)”.
- Starting with Fabric 2.0, Fabric introduced a new chaincode
  lifecycle process that allows multiple organizations to agree on how a
  chaincode will be operated before it can be used on a channel.  The new process
  requires that organizations agree to the parameters that define a chaincode,
  such as name, version, and the chaincode endorsement policy.

## 覆盖策略定义

Hyperledger Fabric includes default policies which are useful for getting started,
developing, and testing your blockchain, but they are meant to be customized
in a production environment. You should be aware of the default policies
in the `configtx.yaml` file. Channel configuration policies can be extended
with arbitrary verbs, beyond the default `Readers, Writers, Admins` in
`configtx.yaml`. The orderer system and application channels are overridden by
issuing a config update when you override the default policies by editing the
`configtx.yaml` for the orderer system channel or the `configtx.yaml` for a
specific channel.

更多信息请查阅
[更新通道配置](../config_update.html#updating-a-channel-configuration)。


<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
