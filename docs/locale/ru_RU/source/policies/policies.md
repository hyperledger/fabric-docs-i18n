# Policies

**Audience**: Architects, application and smart contract developers,
administrators

In this topic, we'll cover:

* [What is a policy](#what-is-a-policy)
* [Why are policies needed](#why-are-policies-needed)
* [How are policies implemented throughout Fabric](#how-are-policies-implemented-throughout-fabric)
* [Fabric policy domains](#the-fabric-policy-domains)
* [How do you write a policy in Fabric](#how-do-you-write-a-policy-in-fabric)
* [Fabric chaincode lifecycle](#fabric-chaincode-lifecycle)
* [Overriding policy definitions](#overriding-policy-definitions)

## What is a policy

At its most basic level, a policy is a set of rules that define the structure
for how decisions are made and specific outcomes are reached. To that end,
policies typically describe a **who** and a **what**, such as the access or
rights that an individual has over an **asset**. We can see that policies are
used throughout our daily lives to protect assets of value to us, from car
rentals, health, our homes, and many more.

For example, an insurance policy defines the conditions, terms, limits, and
expiration under which an insurance payout will be made. The policy is
agreed to by the policy holder and the insurance company, and defines the rights
and responsibilities of each party.

Whereas an insurance policy is put in place for risk management, in Hyperledger
Fabric, policies are the mechanism for infrastructure management. Fabric policies
represent how members come to agreement on accepting or rejecting changes to the
network, a channel, or a smart contract. Policies are agreed to by the consortium
members when a network is originally configured, but they can also be modified
as the network evolves. For example, they describe the criteria for adding or
removing members from a channel, change how blocks are formed, or specify the
number of organizations required to endorse a smart contract. All of these
actions are described by a policy which defines who can perform the action.
Simply put, everything you want to do on a Fabric network is controlled by a
policy.

## Why are policies needed

Policies are one of the things that make Hyperledger Fabric different from other
blockchains like Ethereum or Bitcoin. In those systems, transactions can be
generated and validated by any node in the network. The policies that govern the
network are fixed at any point in time and can only be changed using the same
process that governs the code. Because Fabric is a permissioned blockchain whose
users are recognized by the underlying infrastructure, those users have the
ability to decide on the governance of the network before it is launched, and
change the governance of a running network.

Policies allow members to decide which organizations can access or update a Fabric
network, and provide the mechanism to enforce those decisions. Policies contain
the lists of organizations that have access to a given resource, such as a
user or system chaincode. They also specify how many organizations need to agree
on a proposal to update a resource, such as a channel or smart contracts. Once
they are written, policies evaluate the collection of signatures attached to
transactions and proposals and validate if the signatures fulfill the governance
agreed to by the network.

## How are policies implemented throughout Fabric

Policies are implemented at different levels of a Fabric network. Each policy
domain governs different aspects of how a network operates.

![policies.policies](./FabricPolicyHierarchy-2.png) *A visual representation
of the Fabric policy hierarchy.*

### System channel configuration

Every network begins with an ordering **system channel**. There must be exactly
one ordering system channel for an ordering service, and it is the first channel
to be created. The system channel also contains the organizations who are the
members of the ordering service (ordering organizations) and those that are
on the networks to transact (consortium organizations).

The policies in the ordering system channel configuration blocks govern the
consensus used by the ordering service and define how new blocks are created.
The system channel also governs which members of the consortium are allowed to
create new channels.

### Application channel configuration

Application _channels_ are used to provide a private communication mechanism
between organizations in the consortium.

The policies in an application channel govern the ability to add or remove
members from the channel. Application channels also govern which organizations
are required to approve a chaincode before the chaincode is defined and
committed to a channel using the Fabric chaincode lifecycle. When an application
channel is initially created, it inherits all the ordering service parameters
from the orderer system channel by default. However, those parameters (and the
policies governing them) can be customized in each channel.

### Access control lists (ACLs)

Network administrators will be especially interested in the Fabric use of ACLs,
which provide the ability to configure access to resources by associating those
resources with existing policies. These "resources" could be functions on system
chaincode (e.g., "GetBlockByNumber" on the "qscc" system chaincode) or other
resources (e.g.,who can receive Block events). ACLs refer to policies
defined in an application channel configuration and extends them to control
additional resources. The default set of Fabric ACLs is visible in the
`configtx.yaml` file under the `Application: &ApplicationDefaults` section but
they can and should be overridden in a production environment. The list of
resources named in `configtx.yaml` is the complete set of all internal resources
currently defined by Fabric.

In that file, ACLs are expressed using the following format:

```
# ACL policy for chaincode to chaincode invocation
peer/ChaincodeToChaincode: /Channel/Application/Readers
```

Where `peer/ChaincodeToChaincode` represents the resource being secured and
`/Channel/Application/Readers` refers to the policy which must be satisfied for
the associated transaction to be considered valid.

For a deeper dive into ACLS, refer to the topic in the Operations Guide on [ACLs](../access_control.html).

### Smart contract endorsement policies

Every smart contract inside a chaincode package has an endorsement policy that
specifies how many peers belonging to different channel members need to execute
and validate a transaction against a given smart contract in order for the
transaction to be considered valid. Hence, the endorsement policies define the
organizations (through their peers) who must “endorse” (i.e., approve of) the
execution of a proposal.

### Modification policies

There is one last type of policy that is crucial to how policies work in Fabric,
the `Modification policy`. Modification policies specify the group of identities
required to sign (approve) any configuration _update_. It is the policy that
defines how the policy is updated. Thus, each channel configuration element
includes a reference to a policy which governs its modification.

## The Fabric policy domains

While Fabric policies are flexible and can be configured to meet the needs of a
network, the policy structure naturally leads to a division between the domains
governed by either the Ordering Service organizations or the members of the
consortium. In the following diagram you can see how the default policies
implement control over the Fabric policy domains below.

![policies.policies](./FabricPolicyHierarchy-4.png) *A more detailed look at the
policy domains governed by the Orderer organizations and consortium organizations.*

A fully functional Fabric network can feature many organizations with different
responsibilities. The domains provide the ability to extend different privileges
and roles to different organizations by allowing the founders of the ordering
service the ability to establish the initial rules and membership of the
consortium. They also allow the organizations that join the consortium to create
private application channels, govern their own business logic, and restrict
access to the data that is put on the network.

The system channel configuration and a portion of each application channel
configuration provides the ordering organizations control over which organizations
are members of the consortium, how blocks are delivered to channels, and the
consensus mechanism used by the nodes of the ordering service.

The system channel configuration provides members of the consortium the ability
to create channels. Application channels and ACLs are the mechanism that
consortium organizations use to add or remove members from a channel and restrict
access to data and smart contracts on a channel.

## How do you write a policy in Fabric

If you want to change anything in Fabric, the policy associated with the resource
describes **who** needs to approve it, either with an explicit sign off from
individuals, or an implicit sign off by a group. In the insurance domain, an
explicit sign off could be a single member of the homeowners insurance agents
group. And an implicit sign off would be analogous to requiring approval from a
majority of the managerial members of the homeowners insurance group. This is
particularly useful because the members of that group can change over time
without requiring that the policy be updated. In Hyperledger Fabric, explicit
sign offs in policies are expressed using the `Signature` syntax and implicit
sign offs use the `ImplicitMeta` syntax.

### Signature policies

`Signature` policies define specific types of users who must sign in order for a
policy to be satisfied such as `OR('Org1.peer', 'Org2.peer')`. These policies are
considered the most versatile because they allow for the construction of
extremely specific rules like: “An admin of org A and 2 other admins, or 5 of 6
organization admins”. The syntax supports arbitrary combinations of `AND`, `OR`
and `NOutOf`. For example, a policy can be easily expressed by using
`AND('Org1.member', 'Org2.member')` which means that a signature from at least
one member in Org1 AND one member in Org2 is required for the policy to be satisfied.

### ImplicitMeta policies

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

## An example: channel configuration policy

Understanding policies begins with examining the `configtx.yaml` where the
channel policies are defined. We can use the `configtx.yaml` file in the Fabric
test network to see examples of both policy syntax types. We are going to examine
the configtx.yaml file used by the [fabric-samples/test-network](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/test-network/configtx/configtx.yaml) sample.

The first section of the file defines the organizations of the network. Inside each
organization definition are the default policies for that organization, `Readers`, `Writers`,
`Admins`, and `Endorsement`, although you can name your policies anything you want.
Each policy has a `Type` which describes how the policy is expressed (`Signature`
or `ImplicitMeta`) and a `Rule`.

The test network example below shows the Org1 organization definition in the system
channel, where the policy `Type` is `Signature` and the endorsement policy rule
is defined as `"OR('Org1MSP.peer')"`. This policy specifies that a peer that is
a member of `Org1MSP` is required to sign. It is these signature policies that
become the sub-policies that the ImplicitMeta policies point to.  

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

Следующий пример показывает, как политика `ImplicitMeta` используется в секции `Application`
`configtx.yaml`. Этот набор политик доступен через путь `/Channel/Application/`. Если вы используете стандартный набор Fabric ACLs,
эти политики определяют поведение многих важных параметров каналов, таких как кто может выполнять поисковые запросы к реестру канала, исполнять
чейнкод или обновлять конфигурацию канала. Эти политики работают через суб-политики, определенные для каждой организации.
Org1, определенная в секции выше, содержит суб-политики`Reader`, `Writer` и `Admin`, которые используются политика `ImplicitMeta`
из секции `Application`. Так как тестовая сеть использует стандартные политки, вы можете использовать Org1 для выполнения поисковых запросов к реестру канала,
исполнять чейнкод и одобрять изменения канала для любого канала тестовой сети, который вы создадите.

<details>
  <summary>
    **Нажмите сюда, чтобы посмотреть пример использования политики `ImplicitMeta`**
  </summary>
```
################################################################################
#
#   SECTION: Application
#
#   - Эта секция определяет значения, связанные с приложениями, которые будут
#   записаны в конфигурационную транзакцию или genesis-блок
#
################################################################################
Application: &ApplicationDefaults

    # Organizations - это список организаций, указанных как участники прикладной стороны сети
    Organizations:

    # Policies определяет набор политик на этом уровне дерева конфигурации
    # Для политик приложений, путь к ним обычно такой:
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
</details>

## Жизненный цикл чейнкода Fabric

В релизе Fabric 2.0, был представлен новый жизненный цикл чейнкода,
в котором используется более демократичный процесс управления чейнкодом сети.
Новый цикл позволяет нескольким организациям голосовать, как будет эксплуатироваться
чейнкод до того, как он будет доступен на канале. Это важно, так как именно этот
новый жизненный цикл вкупе с политиками определяет безопасность сети.
[Больше деталей про жизненный цикл чейнкода](../chaincode_lifecycle.html).
Для понимания этой темы, необходимо осознавать, какое место занимают политики в этом цикле.
Новый цикл включает два шага, на которых определяются политики:
Когда чейнкод **одобряется** участниками организации, и когда он **сохраняется** в канал.

В секции `Application` файла `configtx.yaml` включена стандартная политика подтверждения для жизненного
цикла чейнкода. При промышленном использовании, вы можете изменить ее под ваш случай.

```
################################################################################
#
#   SECTION: Application
#
#   - Эта секция определяет значения, связанные с приложениями, которые будут
#   записаны в конфигурационную транзакцию или genesis-блок
#
################################################################################
Application: &ApplicationDefaults

    # Organizations - это список организаций, указанных как участники прикладной стороны сети
    Organizations:

    # Policies определяет набор политик на этом уровне дерева конфигурации
    # Для политик приложений, путь к ним обычно такой:
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

- Политика `LifecycleEndorsement` управляет тем, кому надо  _одобрить определение чейнкода_.
- Политика `Endorsement` - _стандартная политика подтверждения для чейнкода_.

## Политики подтверждения чейнкода

Политика подтверждения указывается для **чейнкода**, когда он одобрен и сохранен в канал, следуя
жизненному циклу чейнкода (то есть одна политика подтверждения покрывает все состояния (ключи),
связанные с данным чейнкодом). Политика подтверждения может быть указана или как ссылка на существующую
политику подтверждения из конфигурации канала или через явное определения политики `Signature`.

Если политика подтверждения не явно определена во время шага одобрения, выбирается стандартная
`Endorsement`-политика - `"MAJORITY Endorsement"`, что означает, что
большинство пиров, принадлежащих разным участникам (организациям) канала должны выполнить и проверить
транзакцию, чтобы транзакция считалась валидной. Эта стандартная политика позволяет автоматически включить присоединяющихся к каналу организациям в процесс подтверждения.
Если вы не хотите использовать стандартную политику подтверждения, вы можете использовать формат политики `Signature`, чтобы указать более сложную политику подтверждения
(например, требующую подтверждения чейнкода одной организацией и отличающейся от нее организацией).

Политики `Signature` также позволяют включить `principals`, которые, на самом деле, просто представляют из себя
способ совмещения определенной identity с ролью. Principals похожи на user ID или group ID, но они более универсальные,
так как могут включать широкий набор параметров, таких как identity, организация, организационное подразделение (OU) и роль.
Principals - наборы свойств, определяющих права участников.
Principals указываются через ``'MSP.ROLE'``, где ``MSP`` --- необходимый идентификатор MSP и ``ROLE`` --- одна из четырех ролей: ``member``, ``admin``, ``client`` и
``peer``.
Роль должна быть связана с identity во время того, как пользователь регистрируется через CA.

Несколько примеров корректных principals:

 * `'Org0.admin'`: любой администратор из `Org0` MSP
 * `'Org1.member'`: любой участник `Org1` MSP
 * `'Org1.client'`: любой клиент `Org1` MSP
 * `'Org1.peer'`: любой пир `Org1` MSP
 * `OrdererOrg.Orderer`: orderer из OrdererOrg MSP

Бывают случаи, когда необходимо указать политику подтверждения конкретному состоянию, то есть паре ключ-значение.
**Подтверждение на уровне состояния** позволяет для конкретного состояния указать свою политику,
которая отменит политику подтверждения на уровне чейнкода.

Для более подробной информацией про политики подтверждения, обратитесь к статье
раздела Руководства об эксплуатации [Политики подтверждения](../endorsement-policies.html).

**Заметка:**  Политики работают по разному в зависимости от используемой версии Fabric:
- В релизах до 2.0, политики подтверждения могут быть обновлены во время инстанцирования (instantiation) чейнкода
  или при использовании команд жизненного цикла чейнкода.
  Если политики не были указаны во время инстанцирования, они по умолчанию устанавливаются на
  “любой участник организации канала”. Например, в канале из “Org1” и “Org2” стандартная политика подтверждения такая -
  `OR(‘Org1.member’, ‘Org2.member’)`.
- Релиз Fabric v2.0 представил новый цикл, который позволяет нескольким организациям голосовать, как будет эксплуатироваться
  чейнкод до того, как он будет доступен на канале. Новый процесс требует, чтобы организации согласились на параметрах, определяющих чейнкод,
  таких как имя, версия и политика подтверждения чейнкода.

## Переопределение политик

Hyperledger Fabric включает политики по умолчанию, полезные для начала работы с Fabric, для разработки и для тестирования блокчейна,
но при промышленном использовании их надо настроить. Вы быть в курсе стандартных политик из файла `configtx.yaml`. Политики конфигурации канала могут быть расширены
вне стандартных `Readers, Writers, Admins` из файла `configtx.yaml`. Orderer-система и каналы переопределяются через выпуск обновления конфигурации, когда вы
переопределяете стандартные политики, редактируя `configtx.yaml` канала.

За более подробной информацией, смотрите статью [Обновление конфигурации канала](../config_update.html#updating-a-channel-configuration).

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
