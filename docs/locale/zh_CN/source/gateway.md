# Fabric Gateway(Fabric 网关)

Fabric Gateway是Hyperledger Fabric v2.4在对等节点peers引入的一项服务，它提供了一个简化、最小的API，用于向Fabric网络提交交易。在使用Gateway之前，一些操作例如从各个组织的对等节点收集交易背书等操作都需要借助客户端的SDK实现。现在这些操作可以委托给正在运行的对等节点peers通过Fabric Gateway服务来实现，以此方式有效简化了从v2.4后的应用程序开发和交易提交的功能。

## Writing client applications （撰写客户端应用）

从Fabric v2.4开始，在对区块链进行操作的诸多内容中，客户端应用程序应该使用Go、Node或者Java程序设计语言之一的Fabric Gateway API，这些API已经在与Fabric Gateway交互中经过优化。同时，这些API也公开了与最初在Fabric v1.4中引入的高级编程模型。

Fabric Gateway(也称为"网关")管理以下交易步骤：

- **评估**一个交易提案。这将在一个节点上调用智能合约（chaincode，链码）函数，并将结果返回给客户端。通常用于查询账本的当前状态而不进行任何账本更新。网关首选会选择与网关节点同一组织的节点，并选择具有最高账本区块高度的节点。如果在网关的组织中没有可用的节点，那么它将选择另一个组织的节点。

- **背书**一个交易提案。这将收集足够的背书响应以满足联合签名策略的要求(see [below](#how-the-gateway-endorses-your-transaction-proposal))，并返回一个准备好的交易信封(transaction envelope)返回给客户端用于签名。

- **提交**一个交易。这将向排序服务发送一个已签名的交易信封(transaction envelope)，以便将其提交到总账中进行确认。

- 等待**提交状态**事件。这将允许客户端等待交易被提交到总账中并获取提交的状态码（包括验证/作废两种状态）。

- 接收**链码事件**。这将允许客户端应用程序在交易提交到总账时对由智能合约函数发出的事件做出响应。

Fabric Gateway客户端API将认可（Endorse）、提交（Submit）和提交状态（CommitStatus）操作组合到一个单独的阻塞**SubmitTransaction**函数中，通过这种方式支持只需一行代码就能进行交易提交。或者，每个单独的操作可以被调用来支持灵活的应用模块。

## Client application APIs(客户端应用程序APIs)
Gateway及其客户端API旨在让您作为客户端应用程序开发人员专注于应用程序的*业务逻辑*，而无需关注与Fabric网络相关的*基础设施逻辑*。因此，这些API提供了逻辑抽象，如*组织（organization）*和*合约（contract）*，而不是操作抽象，如*节点（peer）*和*链码（chaincode）*。【旁注：显然，管理员API可能希望暴露这些操作抽象，但这*不是*一个管理员API。】

Hyperledger Fabric目前支持三种语言进行客户端应用程序开发：

- **Go**.  查看[Go API 文档](https://pkg.go.dev/github.com/hyperledger/fabric-gateway/pkg/client) 详细内容
- **Node (Typescript/Javascript)**.  查看 [Node API文档](https://hyperledger.github.io/fabric-gateway/main/api/node/) 详细内容.
- **Java**. 查看 [Java API 文档](https://hyperledger.github.io/fabric-gateway/main/api/java/)详细内容

## How the gateway endorses your transaction proposal
## 网关如何背书您的交易提案

为了将交易成功地提交到账本中，需要获得足够数量的背书以满足[背书策略](endorsement-policies.html)。从组织中获得背书需要连接到其一个节点，并让该节点模拟（执行）交易提案以验证其副本账本。节点通过调用链码函数来模拟交易，链码函数在提案中指定了其名称和参数，并建立（并签名）读写集。读写集包含当前账本状态和提案修改内容以响应函数中状态获取/设置指令。

具体使用什么背书策略或者多个背书策略的总和取决于一个交易，这个交易依赖于一个被调用的链码功能，并且可以包括以下几种组合：

- **链码背书策略**。这些是通道成员(channel members)在批准其组织的链码定义时同意的政策。如果链码函数调用另一个链码中的函数，则两个政策都需要得到满足。

- **私有数据集(Private data conllection)背书策略**。如果链码函数将数据写入私有数据集的状态中，那么该数据集的背书策略将会覆盖该状态的链码策略。如果链码函数从私有数据集中读取数据，那么这个策略将只限于被属于该数据集的组织所使用。

- **基于状态的背书（SBE）策略**。也被称为键级(key-level)签名策略，可以应用于个别的状态，并且将会覆盖链码策略或私有数据集状态的集合策略。这些背书策略本身存储在账本中，并且可以通过新的交易进行更新。


在交易提案中具体使用何种背书策略（上述三种）需要由正在运行的链码(chaincode)决定，不能通过静态分析获得。


Fabric网关(Gateway)可以代表客户端管理交易背书的复杂性，使用以下过程：

- Fabric Gateway通过识别具有最高账本区块高度的（可用的）节点，从网关节点所属组织（[MSP ID](membership/membership.html)）中选择背书节点。具体设想为所有网关节点所属组织内的节点都被连接到网关节点的客户端应用程序所信任。

- 交易提案在所选的背书节点上进行模拟。该模拟会捕获所访问的状态信息，从而确定需要合并的背书策略（包括存储在背书节点账本上的任何单个状态基础策略）。

- 捕获的策略信息被组合成一个ChaincodeInterest的protobuf结构，然后传递给发现服务(discovery service)，以便为提议的交易生成一个特定的背书计划。

- 网关通过向满足计划中所有策略的组织请求背书来应用背书计划。对于每个组织，网关节点将从具有最高块高度的（可用的）节点请求背书。

网关依赖于发现服务([discovery service](discovery-overview.html))来获取可用节点和排序服务节点的连接详细信息，并计算所需背书交易提议的节点组合。因此，在启用网关服务的节点上，发现服务必须始终保持启用状态。

网关背书过程对于以传递方式作为瞬态数据传递的私有数据更加严格，因为它通常包含敏感或个人信息，不能传递给所有组织的节点。在这种情况下，网关将限制背书组织集仅包含那些可以访问私有数据集合（读或写）的成员组织。如果针对瞬态数据的此限制不满足背书策略，则网关会向客户端返回错误，而不是将私有数据转发给未经授权访问私有数据的组织。在这些情况下，客户端应用程序应编写明确定义哪些组织应该背书事务的代码。

### 指定特定的背书节点(Targeting specific endorsement peers)
在某些情况下，一个客户端应用程序必须明确选择用于评估或背书一个交易提案的组织。

例如，临时数据经常包括个人或敏感数据，这些数据必须写入私有数据集中，基于以上情况限制了背书组织的使用范围

在这些情况下，客户端应用程序可以明确指定背书组织，以满足应用程序的隐私和背书要求；然后，网关将从每个指定组织中选择（可用的）背书节点，这些背书节点都具备存储了各个指定组织最高区块计数的特质。

然而，如果客户端指定的一组组织不满足背书策略，交易仍然可能被指定的节点背书并提交进行排序，但在验证和提交阶段，所有通道中的节点都将使交易无效


这个无效的交易将会被记录在账本中，但是交易的更新不会被写入任何通道节点的状态数据库中。

### 重试和错误处理

Fabric网关(Gateway)通过以下描述处理节点连接的重试尝试、错误和超时：

#### 重试尝试

当出现交易由于peer或者ordering节点不可达的情况，网关(gateway)将使用发现服务信息来重试。如果一个组织正在运行多个对等节点(peer)或排序(ordering)节点，那么另一个合格的节点讲用于尝试。如果一个组织在背书交易提案时失败，那么另一个将被选中。如果一个组织背书过程完全失败，另外一组适配于背书策略的组织将被重新选中。只有当没有可使用的对等节点(peers)适配于背书策略，网关将停止重试。网关将一直不断进行重试尝试，直到所有可能使用的背书节点被尝试过一遍。

#### 错误处理

Fabric网关通过gRPC连接来管理网络中的peer和ordering节点。如果网关服务请求错误源自网络中的peer节点或ordering节点（即网关外部），网关将在消息的Details字段中向客户端返回错误、端点和组织（[MSP ID](membership/membership.html)）信息。
如果Details字段为空，则该错误源自网关对等节点(gateway peer)。

#### 超时

Fabric Gateway的`Evaluate`和`Endorse`方法会向网关外的对等节点发出gRPC请求。为了限制客户端等待这些集体响应时长，可以在peer节点的core.yaml配置文件中的网关部分覆盖`peer.gateway.endorsementTimeout`值。

类似地，Fabric Gateway的`Submit`方法会向订购服务节点(ordering service nodes)建立gRPC连接，以广播已背书的交易。为了限制客户端等待各个订购节点(ordering nodes)响应时长，可以在peer的core.yaml配置文件的网关部分覆盖`peer.gateway.broadcastTimeout`值。

Fabric Gateway客户端API还提供了一些机制,用于处理当从客户端应用程序调用时，可以为每个网关方法设置默认和每次调用的超时时间。


## 事件(events)监听


网关为客户端应用程序提供了一个简化的API，用于在客户端应用程序中接收链码事件([chaincode events](peer_event_services.html#how-to-register-for-events))。客户端API提供了使用特定语言惯用语处理这些事件的机制
