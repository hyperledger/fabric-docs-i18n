# 连接配置文件

**受众**：架构师、应用程序和智能合约开发人员

连接配置文件描述了一组组件，包括 Hyperledger Fabric 区块链网络中的 Peer 节点、排序节点以及 CA。它还包含与这些组件相关的通道和组织信息。连接配置文件主要由应用程序用于配置处理所有网络交互的[网关](./gateway.html)，从而使其可以专注于业务逻辑。连接配置文件通常由了解网络拓扑的管理员创建。

在本主题中，我们将介绍：

* [为什么连接配置文件很重要](#情景)
* [应用程序如何使用连接配置文件](#用法)
* [如何定义连接配置文件](#结构)

## 情景

连接配置文件用于配置网关。网关很重要，[很多原因](./gateway.html)，主要是简化应用程序与网络通道的交互。

![profile.scenario](./develop.diagram.30.png)
*两个应用程序，发行和购买，使用配置有连接配置文件1和2的网关1和2。每个配置文件描述了 MagnetoCorp 和 DigiBank 网络组件的不同子集。每个连接配置文件必须包含足够的信息，以便网关代表发行和购买应用程序与网络进行交互。有关详细说明，请参阅文本。*

连接配置文件包含网络视图的描述，以技术语法表示，可以是 JSON 或 YAML。在本主题中，我们使用 YAML 表示，因为它更容易阅读。静态网关需要比动态网关更多的信息，因为后者可以使用[服务发现](../discovery-overview.html)来动态增加连接配置文件中的信息。

连接配置文件不应该是网络通道的详尽描述；它只需要包含足够的信息，足以满足使用它的网关。在上面的网络中，连接配置文件1需要至少包含背书组织和用于 `issue` 交易的 Peer 节点，以及识别将交易提交到帐本上时会通知网关的 Peer 节点。

最简单的方法是将连接配置文件视为描述网络的*视图*。这可能是一个综合观点，但由于以下几个原因，这是不现实的：

* 根据需求添加和删除 Peer 节点、排序节点、CA、通道和组织。

* 组件可以启动或停止，或意外失败（例如断电）.

* 网关不需要整个网络的视图，只需要成功处理交易提交或事件通知所需的内容。

* 服务发现可以扩充连接配置文件中的信息。具体来说，动态网关可以配置最少的 Fabric 拓扑信息；其余的都可以被发现。

静态连接配置文件通常由详细了解网络拓扑的管理员创建。这是因为静态配置文件可能包含大量信息，管理员需要在相应的连接配置文件中获取到这些信息。相比之下，动态配置文件最小化所需的定义数量，因此对于想要快速掌握的开发人员或想要创建响应更快的网关的管理员来说，这是更好的选择。使用编辑器以 YAML 或 JSON 格式创建连接配置文件。

## 用法

我们将看到如何快速定义连接配置文件；让我们首先看看 MagnetoCorp 示例的 `issue` 程序如何使用它：

```javascript
const yaml = require('js-yaml');
const { Gateway } = require('fabric-network');

const connectionProfile = yaml.safeLoad(fs.readFileSync('../gateway/paperNet.yaml', 'utf8'));

const gateway = new Gateway();

await gateway.connect(connectionProfile, connectionOptions);
```

加载一些必需的类后，查看如何从文件系统加载 `paperNet.yaml` 网关文件，使用 `yaml.safeLoad()` 方法转换为 JSON 对象，并使用其 `connect()` 方法配置网关。

通过使用此连接配置文件配置网关，发行应用程序为网关提供应用于处理交易的相关网络拓扑。这是因为连接配置文件包含有关 PaperNet 通道、组织、Peer 节点或排序节点和 CA 的足够信息，以确保可以成功处理交易。

连接配置文件为任何给定的组织定义多个 Peer 节点是一种比较好的做法，它可以防止单点故障。这种做法也适用于动态网关; 为服务发现提供多个起点。

DigiBank 的 `buy` 程序通常会为其网关配置类似的连接配置文件，但有一些重要的区别。一些元素将是相同的，例如通道；一些元素将重叠，例如背书节点。其他元素将完全不同，例如通知 Peer 节点或 CA。

传递给网关的 `connectionOptions` 补充了连接配置文件。它们允许应用程序声明网关如何使用连接配置文件。它们由 SDK 解释以控制与网络组件的交互模式，例如选择要连接的标识或用于事件通知的节点。[了解](./connectoptions.html)可用连接选项列表以及何时使用它们。

## 结构

为了帮助您了解连接配置文件的结构，我们将逐步介绍[上面](#情景)显示的网络示例。其连接配置文件基于 PaperNet 商业票据样例，并[存储](https://github.com/hyperledger/fabric-samples/blob/master/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)在 GitHub 仓库中。为方便起见，我们在[下面](#示例)复制了它。您会发现在现在阅读它时，将它显示在另一个浏览器窗口中会很有帮助：

* 第9行： `name: "papernet.magnetocorp.profile.sample"`

  这是连接配置文件的名称。尝试使用 DNS 风格名称；它们是传达意义的一种非常简单的方式。

* 第16行： `x-type: "hlfv1"`

  用户可以添加自己的“特定于应用程序”的 `x-` 属性，就像 HTTP 头一样。它们主要供未来使用。

* 第20行： `description: "Sample connection profile for documentation topic"`

  连接配置文件的简短描述。尽量让这对第一次看到这个的读者有所帮助！

* 第25行： `version: "1.0"`

  此连接配置文件的架构版本。目前仅支持版本1.0，并且未设想此架构将经常更改。

* 第32行： `channels:`

  这是第一个非常重要的行。`channels:` 标识以下内容是此连接配置文件描述的*所有*通道。但是，最好将不同的通道保存在不同的连接配置文件中，特别是如果它们彼此独立使用。
  
* 第36行： `papernet:`

  `papernet` 详细信息将是此连接配置文件中的第一个通道。

* 第41行： `orderers:`

  有关 `papernet` 的所有排序节点的详细信息如下。您可以在第45行看到此通道的排序节点是 `orderer1.magnetocorp.example.com`。这只是一个逻辑名称；稍后在连接配置文件（第134-147行）中，将会有如何连接到此排序节点的详细信息。请注意 `orderer2.digibank.example.com` 不在此列表中；应用程序使用自己组织的排序节点，而不是来自不同组织的排序节点，这是有道理的。

* 第49行： `peers:`

  下边将介绍 `papernet` 所有 Peer 节点的详细信息。
 
  您可以看到 MagnetoCorp 列出的三个 Peer 节点： `peer1.magnetocorp.example.com`、 `peer2.magnetocorp.example.com` 和 `peer3.magnetocorp.example.com`。没有必要列出 MagnetoCorp 中的所有 Peer 节点，就像这里所做的那样。您只能看到 DigiBank 中列出的一个 Peer 节点： `peer9.digibank.example.com`; 包括这个 Peer 节点开始隐含背书策略要求 MagnetoCorp和DigiBank 背书交易，正如我们现在要确认的。最好有多个 Peer 节点来避免单点故障。

  在每个 peer 下面，您可以看到四个非独占角色：**endorsingPeer**、**chaincodeQuery**、**ledgerQuery** 和 **eventSource**。了解一下 `peer1` 和 `peer2` 如何在主机 `papercontract` 中执行所有角色。它们与 `peer3` 不同，`peer3` 只能用于通知，或者用于访问帐本的链组件而不是世界状态的帐本查询，因此不需要安装智能合约。请注意 `peer9` 不应该用于除背书之外的任何其他情况，因为 MagnetoCorp 的节点可以更好地服务于这些角色。

  再次，看看如何根据 Peer 节点的逻辑名称和角色来描述 Peer 节点。稍后在配置文件中，我们将看到这些 Peer 节点的物理信息。

* 第97行： `organizations:`

  所有组织的详细信息将适用与所有通道。请注意，这些组织适用于所有通道，即使 `papernet` 是目前唯一列出的组织。这是因为组织可以在多个通道中，通道可以有多个组织。此外，一些应用程序操作涉及组织而不是通道。例如，应用程序可以使用[连接选项](./connectoptions.html)从其组织内的一个或所有 Peer 节点或网络中的所有组织请求通知。为此，需要有一个组织到 Peer 节点的映射，本节提供了它。

* 第101行： `MagnetoCorp:`

  列出了属于 MagnetoCorp 的所有 Peer 节点：`peer1`、`peer2` 和 `peer3`。同样适用于证书颁发机构。再次注意逻辑名称用法，与 `channels:` 部分相同；物理信息将在后面的配置文件中显示。

* 第121行 `DigiBank:`

  只有 `peer9` 被列为 DigiBank 的一部分，没有证书颁发机构。这是因为这些其他 Peer 节点和 DigiBank CA与此连接配置文件的用户无关。

* 第134行： `orderers:`

  现在列出了排序节点的物理信息。由于此连接配置文件仅提到了 `papernet` 一个排序节点，您会看到列出的 `orderer1.magnetocorp.example.com` 的详细信息。包括其 IP 地址和端口，以及可以覆盖与排序节点通信时使用的默认值的 gRPC 选项（如有必要）。对于 `peers:` 为了实现高可用性，可以指定多个排序节点。

* 第152行： `peers:`

  现在列出所有先前 Peer 节点的物理信息。此连接配置文件有三个 MagnetoCorp 的 Peer 节点：`peer1`、`peer2` 和 `peer3`；对于 DigiBank，单个 peer `peer9`列出了其信息。对于每个 Peer 节点，与排序节点一样，列出了它们的 IP 地址和端口，以及可以覆盖与特定节点通信时使用的默认值的 gRPC 选项（如有必要）。

* 第194行： `certificateAuthorities:`

  现在列出了证书颁发机构的物理信息。连接配置文件为 MagnetoCorp 列出了一个 CA `ca1-magnetocorp`，然后是其物理信息。除了 IP 详细信息，注册商信息允许此 CA 用于证书签名请求（CSR）。这些都是用本地生成的公钥/私钥对来请求新证书。

现在您已经了解了 MagnetoCorp 的连接配置文件，您可能希望查看 DigiBank 的[相关](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)配置文件。找到与 MagnetoCorp 相同的配置文件的位置，查看它的相似之处，并比较最终哪里不同。想想为什么这些差异对 DigiBank 应用程序有作用。

这就是您需要了解的有关连接配置文件的所有信息。总之，连接配置文件为应用程序定义了足够的通道、组织、Peer 节点、排序节点和 CA 以配置网关。网关允许应用程序专注于业务逻辑而不是网络拓扑的细节。

## 示例

该文件是从 GitHub 商业票据[示例](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)中复制的。

```
1: ---
2: #
3: # [Required]. A connection profile contains information about a set of network
4: # components. It is typically used to configure gateway, allowing applications
5: # interact with a network channel without worrying about the underlying
6: # topology. A connection profile is normally created by an administrator who
7: # understands this topology.
8: #
9: name: "papernet.magnetocorp.profile.sample"
10: #
11: # [Optional]. Analogous to HTTP, properties with an "x-" prefix are deemed
12: # "application-specific", and ignored by the gateway. For example, property
13: # "x-type" with value "hlfv1" was originally used to identify a connection
14: # profile for Fabric 1.x rather than 0.x.
15: #
16: x-type: "hlfv1"
17: #
18: # [Required]. A short description of the connection profile
19: #
20: description: "Sample connection profile for documentation topic"
21: #
22: # [Required]. Connection profile schema version. Used by the gateway to
23: # interpret these data.
24: #
25: version: "1.0"
26: #
27: # [Optional]. A logical description of each network channel; its peer and
28: # orderer names and their roles within the channel. The physical details of
29: # these components (e.g. peer IP addresses) will be specified later in the
30: # profile; we focus first on the logical, and then the physical.
31: #
32: channels:
33:   #
34:   # [Optional]. papernet is the only channel in this connection profile
35:   #
36:   papernet:
37:     #
38:     # [Optional]. Channel orderers for PaperNet. Details of how to connect to
39:     # them is specified later, under the physical "orderers:" section
40:     #
41:     orderers:
42:     #
43:     # [Required]. Orderer logical name
44:     #
45:       - orderer1.magnetocorp.example.com
46:     #
47:     # [Optional]. Peers and their roles
48:     #
49:     peers:
50:     #
51:     # [Required]. Peer logical name
52:     #
53:       peer1.magnetocorp.example.com:
54:         #
55:         # [Optional]. Is this an endorsing peer? (It must have chaincode
56:         # installed.) Default: true
57:         #
58:         endorsingPeer: true
59:         #
60:         # [Optional]. Is this peer used for query? (It must have chaincode
61:         # installed.) Default: true
62:         #
63:         chaincodeQuery: true
64:         #
65:         # [Optional]. Is this peer used for non-chaincode queries? All peers
66:         # support these types of queries, which include queryBlock(),
67:         # queryTransaction(), etc. Default: true
68:         #
69:         ledgerQuery: true
70:         #
71:         # [Optional]. Is this peer used as an event hub? All peers can produce
72:         # events. Default: true
73:         #
74:         eventSource: true
75:       #
76:       peer2.magnetocorp.example.com:
77:         endorsingPeer: true
78:         chaincodeQuery: true
79:         ledgerQuery: true
80:         eventSource: true
81:       #
82:       peer3.magnetocorp.example.com:
83:         endorsingPeer: false
84:         chaincodeQuery: false
85:         ledgerQuery: true
86:         eventSource: true
87:       #
88:       peer9.digibank.example.com:
89:         endorsingPeer: true
90:         chaincodeQuery: false
91:         ledgerQuery: false
92:         eventSource: false
93: #
94: # [Required]. List of organizations for all channels. At least one organization
95: # is required.
96: #
97: organizations:
98:    #
99:    # [Required]. Organizational information for MagnetoCorp
100:   #
101:   MagnetoCorp:
102:     #
103:     # [Required]. The MSPID used to identify MagnetoCorp
104:     #
105:     mspid: MagnetoCorpMSP
106:     #
107:     # [Required]. The MagnetoCorp peers
108:     #
109:     peers:
110:       - peer1.magnetocorp.example.com
111:       - peer2.magnetocorp.example.com
112:       - peer3.magnetocorp.example.com
113:     #
114:     # [Optional]. Fabric-CA Certificate Authorities.
115:     #
116:     certificateAuthorities:
117:       - ca-magnetocorp
118:   #
119:   # [Optional]. Organizational information for DigiBank
120:   #
121:   DigiBank:
122:     #
123:     # [Required]. The MSPID used to identify DigiBank
124:     #
125:     mspid: DigiBankMSP
126:     #
127:     # [Required]. The DigiBank peers
128:     #
129:     peers:
130:       - peer9.digibank.example.com
131: #
132: # [Optional]. Orderer physical information, by orderer name
133: #
134: orderers:
135:   #
136:   # [Required]. Name of MagnetoCorp orderer
137:   #
138:   orderer1.magnetocorp.example.com:
139:     #
140:     # [Required]. This orderer's IP address
141:     #
142:     url: grpc://localhost:7050
143:     #
144:     # [Optional]. gRPC connection properties used for communication
145:     #
146:     grpcOptions:
147:       ssl-target-name-override: orderer1.magnetocorp.example.com
148: #
149: # [Required]. Peer physical information, by peer name. At least one peer is
150: # required.
151: #
152: peers:
153:   #
154:   # [Required]. First MagetoCorp peer physical properties
155:   #
156:   peer1.magnetocorp.example.com:
157:     #
158:     # [Required]. Peer's IP address
159:     #
160:     url: grpc://localhost:7151
161:     #
162:     # [Optional]. gRPC connection properties used for communication
163:     #
164:     grpcOptions:
165:       ssl-target-name-override: peer1.magnetocorp.example.com
166:       request-timeout: 120001
167:   #
168:   # [Optional]. Other MagnetoCorp peers
169:   #
170:   peer2.magnetocorp.example.com:
171:     url: grpc://localhost:7251
172:     grpcOptions:
173:       ssl-target-name-override: peer2.magnetocorp.example.com
174:       request-timeout: 120001
175:   #
176:   peer3.magnetocorp.example.com:
177:     url: grpc://localhost:7351
178:     grpcOptions:
179:       ssl-target-name-override: peer3.magnetocorp.example.com
180:       request-timeout: 120001
181:   #
182:   # [Required]. Digibank peer physical properties
183:   #
184:   peer9.digibank.example.com:
185:     url: grpc://localhost:7951
186:     grpcOptions:
187:       ssl-target-name-override: peer9.digibank.example.com
188:       request-timeout: 120001
189: #
190: # [Optional]. Fabric-CA Certificate Authority physical information, by name.
191: # This information can be used to (e.g.) enroll new users. Communication is via
192: # REST, hence options relate to HTTP rather than gRPC.
193: #
194: certificateAuthorities:
195:   #
196:   # [Required]. MagnetoCorp CA
197:   #
198:   ca1-magnetocorp:
199:     #
200:     # [Required]. CA IP address
201:     #
202:     url: http://localhost:7054
203:     #
204:     # [Optioanl]. HTTP connection properties used for communication
205:     #
206:     httpOptions:
207:       verify: false
208:     #
209:     # [Optional]. Fabric-CA supports Certificate Signing Requests (CSRs). A
210:     # registrar is needed to enroll new users.
211:     #
212:     registrar:
213:       - enrollId: admin
214:         enrollSecret: adminpw
215:     #
216:     # [Optional]. The name of the CA.
217:     #
218:     caName: ca-magnetocorp
```

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->