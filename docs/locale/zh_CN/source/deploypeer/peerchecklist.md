#  用于生产环境下 peer 节点的检查清单
在构建生产节点之前，您需要通过编辑 [core.yaml](https://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/core.yaml) 文件来自定义配置。该文件在下载 Fabric 二进制文件时会被复制到 `/config` 目录中，并在 Fabric 节点镜像的 `/etc/hyperledger/fabric/core.yaml` 位置可用。

在生产环境中，虽然您可以在 Docker 容器或 Kubernetes 作业中覆盖 `core.yaml` 文件中的环境变量，但本指南将展示如何编辑 `core.yaml` 文件。了解配置文件中的参数及其对文件中其他参数设置的依赖关系非常重要。盲目地使用环境变量覆盖某个设置可能会影响其他设置的功能。因此，建议在启动节点之前，您应该修改配置文件中的设置，以熟悉可用的设置及其工作原理。随后，您可以选择使用环境变量来覆盖这些参数。

此清单涵盖了设置生产网络所需的关键配置参数。当然，您始终可以参考 core.yaml 文件获取其他参数或更多信息。它还提供了有关应该覆盖哪些参数的指导。您需要了解并在本主题中描述的参数列表包括：

- [peer.id](#peer-id)
- [peer.networkId](#peer-networkid)
- [peer.listenAddress](#peer-listenaddress)
- [peer.chaincodeListenAddress](#peer-chaincodelistenaddress)
- [peer.chaincodeAddress](#peer-chaincodeaddress)
- [peer.address](#peer-address)
- [peer.mspConfigPath](#peer-mspconfigpath)
- [peer.localMspId](#peer-localmspid)
- [peer.fileSystemPath](#peer-filesystempath)
- [peer.gossip.*](#peer-gossip)
- [peer.tls.*](#peer-tls)
- [peer.bccsp.*](#peer-bccsp)
- [chaincode.externalBuilders.*](#chaincode-externalbuilders)
- [ledger.*](#ledger)
- [operations.*](#operations)
- [metrics.*](#metrics)

## peer.id

```
# The peer id provides a name for this peer instance and is used when
# naming docker resources.
id: jdoe
```

- **`id`**：（默认值应该被覆盖）首先给您的节点分配一个 ID（类似于给它一个名称）。通常，该名称表示节点所属的组织，例如 `peer0.org1.example.com`。它用于为节点的链码镜像和容器命名。

## peer.networkId

```
# The networkId allows for logical separation of networks and is used when
# naming docker resources.
networkId: dev
```

- **`networkId`**：（默认值应该被覆盖）指定任何您想要的名称。一种建议是根据计划使用情况来命名网络（例如，“dev”，“staging”，“test”，“production”等）。此值还用于构建链码镜像和容器的名称。
## peer.listenAddress

```
# The Address at local network interface this Peer will listen on.
# By default, it will listen on all network interfaces
listenAddress: 0.0.0.0:7051
```
- **`listenAddress`**：（默认值应该被覆盖）指定节点监听的地址，例如 `0.0.0.0:7051`。

## peer.chaincodeListenAddress

```
# The endpoint this peer uses to listen for inbound chaincode connections.
# If this is commented-out, the listen address is selected to be
# the peer's address (see below) with port 7052
chaincodeListenAddress: 0.0.0.0:7052
```

- **`chaincodeListenAddress`**：（默认值应该被覆盖）取消注释此参数，并指定该节点用于接收链码请求的地址。它需要与 `peer.listenAddress` 不同，例如 `0.0.0.0:7052`。

## peer.chaincodeAddress

```
# The endpoint the chaincode for this peer uses to connect to the peer.
# If this is not specified, the chaincodeListenAddress address is selected.
# And if chaincodeListenAddress is not specified, address is selected from
# peer address (see below). If specified peer address is invalid then it
# will fallback to the auto detected IP (local IP) regardless of the peer
# addressAutoDetect value.
chaincodeAddress: 0.0.0.0:7052
```

- **`chaincodeAddress`**：（默认值应该被覆盖）取消注释此参数，并指定链码容器用于连接到该节点的地址，例如 `peer0.org1.example.com:7052`。

## peer.address

```
# When used as peer config, this represents the endpoint to other peers
# in the same organization. For peers in other organization, see
# gossip.externalEndpoint for more info.
# When used as CLI config, this means the peer's endpoint to interact with
address: 0.0.0.0:7051
```

- **`address`**：（默认值应该被覆盖）指定组织中其他节点用于连接到该节点的地址，例如 `peer0.org1.example.com:7051`。

## peer.mspConfigPath

```
mspConfigPath: msp
```

- **`mspConfigPath`**：（默认值应该被覆盖）这是节点本地 MSP 的路径，在部署节点之前必须创建。路径可以是绝对路径，也可以是相对于 `FABRIC_CFG_PATH` 的路径（默认情况下，在节点镜像中为 `/etc/hyperledger/fabric`）。除非指定了指向名称不是 “msp” 的文件夹的绝对路径，否则节点会默认在该路径（即 `FABRIC_CFG_PATH/msp`）查找名为 “msp” 的文件夹。如果您使用了[注册和登录身份](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html)的推荐文件夹结构，请根据以下方式相对于 FABRIC_CFG_PATH 进行设置：`config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp`。**最佳做法是将此数据存储在持久存储中**。这样，即使由于某种原因销毁了您节点上的容器，MSP 也不会丢失。

## peer.localMspId

```
# Identifier of the local MSP
# ----!!!!IMPORTANT!!!-!!!IMPORTANT!!!-!!!IMPORTANT!!!!----
# Deployers need to change the value of the localMspId string.
# In particular, the name of the local MSP ID of a peer needs
# to match the name of one of the MSPs in each of the channel
# that this peer is a member of. Otherwise this peer's messages
# will not be identified as valid by other nodes.
localMspId: SampleOrg
```

- **`localMspId`**：（默认值应该被覆盖）这是节点所属组织的 MSP ID 的值。因为只有属于通道成员组织的节点才能加入通道，所以此 MSP ID 必须与该节点所属的每个通道中至少有一个 MSP 的名称能匹配。

## peer.fileSystemPath

```
# Path on the file system where peer will store data (eg ledger). This
# location must be access control protected to prevent unintended
# modification that might corrupt the peer operations.
fileSystemPath: /var/hyperledger/production
```

- **`fileSystemPath`**：（默认值应该被覆盖）这是节点本地文件系统上账本和已安装链码的路径。它可以是绝对路径或相对于 `FABRIC_CFG_PATH` 的路径。默认为 `/var/hyperledger/production` 。运行节点的用户需要拥有并具有对此目录的写访问权限。**最佳做法是将这些数据存储在持久存储中**。这样，如果由于某种原因销毁了您的节点容器，账本和任何已安装的链码都不会丢失。请注意，账本快照将写入到 [ledger.* 部分](#ledger)中描述的 `ledger.snapshots.rootDir`。

## peer.gossip.*

```
gossip:
    # Bootstrap set to initialize gossip with.
    # This is a list of other peers that this peer reaches out to at startup.
    # Important: The endpoints here have to be endpoints of peers in the same
    # organization, because the peer would refuse connecting to these endpoints
    # unless they are in the same organization as the peer.
    bootstrap: 127.0.0.1:7051

    # Overrides the endpoint that the peer publishes to peers
    # in its organization. For peers in foreign organizations
    # see 'externalEndpoint'
    endpoint:

    # This is an endpoint that is published to peers outside of the organization.
    # If this isn't set, the peer will not be known to other organizations and will not be exposed via service discovery.
    externalEndpoint:

    # NOTE: orgLeader and useLeaderElection parameters are mutual exclusive.
    # Setting both to true would result in the termination of the peer
    # since this is undefined state. If the peers are configured with
    # useLeaderElection=false, make sure there is at least 1 peer in the
    # organization that its orgLeader is set to true.

    # Defines whenever peer will initialize dynamic algorithm for
    # "leader" selection, where leader is the peer to establish
    # connection with ordering service and use delivery protocol
    # to pull ledger blocks from ordering service.
    useLeaderElection: false

    # Statically defines peer to be an organization "leader",
    # where this means that current peer will maintain connection
    # with ordering service and disseminate block across peers in
    # its own organization. Multiple peers or all peers in an organization
    # may be configured as org leaders, so that they all pull
    # blocks directly from ordering service.
    orgLeader: true

    # Gossip state transfer related configuration
    state:
        # indicates whenever state transfer is enabled or not
        # default value is false, i.e. state transfer is active
        # and takes care to sync up missing blocks allowing
        # lagging peer to catch up to speed with rest network
        enabled: false

    pvtData:
      implicitCollectionDisseminationPolicy:
          # requiredPeerCount defines the minimum number of eligible peers to which the peer must successfully
          # disseminate private data for its own implicit collection during endorsement. Default value is 0.
          requiredPeerCount: 0

          # maxPeerCount defines the maximum number of eligible peers to which the peer will attempt to
          # disseminate private data for its own implicit collection during endorsement. Default value is 1.
          maxPeerCount: 1
```

Peer 节点利用 Gossip 数据传播协议以可扩展的方式广播账本和通道数据。Gossip 消息传递是连续的，通道上的每个节点都会不断接收来自多个节点的当前和一致的账本数据。虽然可以定制许多 Gossip 参数，但至少需要关注以下三组设置：

* **端点（Endpoints）** 为了进行服务发现和私有数据传播，需要使用 Gossip。要使用这些功能，除了在节点的通道配置中**设置至少一个锚节点**外，还必须配置 gossip `bootstrap`、`endpoint` 和 `externalEndpoint` 参数。

  - **`bootstrap：`**（默认值应该被覆盖）提供此组织中其他 peer 节点的[地址](#address)列表以进行发现。

  - **`endpoint：`**（默认值应该被覆盖）指定其他此组织中的节点连接到该节点时应使用的地址。例如，`peer0.org1.example.com:7051`。

  - **`externalEndpoint：`**（默认值应该被覆盖）指定其他组织的节点连接到该节点时应使用的地址，例如，`peer0.org1.example.com:7051`。

* **区块传播（Block dissemination）** 为了减少网络流量，建议节点从排序服务获取区块，而不是从其组织中的其他节点获取（从 Fabric v2.2 开始的默认配置）。在此部分中，`useLeaderElection`、`orgLeader` 和 `state.enabled` 参数的组合确保节点将从排序服务拉取区块。

  - **`useLeaderElection：`**（从 v2.2 开始默认为 `false`，推荐设置为 `false`，以便节点从排序服务获取区块。）当将 `useLeaderElection` 设置为 false 时，必须通过将 `peer.gossip.orgLeader` 设置为 true 来配置至少一个节点作为组织领导者。如果您希望节点在组织中使用 Gossip 进行区块传播，请将 `useLeaderElection` 设置为 true。

  - **`orgLeader：`**（从 v2.2 开始默认为 `true`，推荐设置为 `true`，以便节点从排序服务获取区块。）如果您希望节点在组织中使用 Gossip 进行区块传播，请将此值设置为 `false`。

  - **`state.enabled：`**（从 v2.2 开始默认为 `false`，推荐设置为 `false`，以便节点从排序服务获取区块。）当您希望使用 Gossip 同步丢失的区块时，请将此值设置为 `true`，这允许滞后的节点与网络上的其他节点保持同步。

* **隐式数据（Implicit data）** Fabric v2.0 引入了节点上面向私有数据的隐式集合的概念。如果您想利用每个组织的私有数据模式，在 Fabric v2.* 中部署链码时不需要定义任何集合。可以在没有任何事前定义的情况下使用隐式的特定于组织的集合。当您计划利用这个新功能时，需要配置 `pvtData.implicitCollectionDisseminationPolicy.requiredPeerCount` 和 `pvtData.implicitCollectionDisseminationPolicy.maxPeerCount` 的值。有关更多详细信息，请参阅[私有数据教程](../private_data_tutorial.html)。

  - **`pvtData.implicitCollectionDisseminationPolicy.requiredPeerCount`:**（使用私有数据隐式集合时建议覆盖此值。）**Fabric 2.0 中的新功能**，默认为0，但您需要根据属于该组织的节点数量增加它。该值表示必须将数据传播到所属组织内的节点数量，以确保在节点背书交易后发生故障时数据的冗余性。

  - **`pvtData.implicitCollectionDisseminationPolicy.maxPeerCount`:**（使用私有数据隐式集合时建议覆盖此值。）**Fabric 2.0 中的新功能**，用于确保在该节点背书请求然后由于某种原因停机时，私有数据在其他位置也能被传播。虽然 `requiredPeerCount` 指定了必须获取数据的节点数量，但 `maxPeerCount` 是尝试进行数据传播的节点数量。默认设置为 `1`，但在具有 `n` 个 peer 节点的组织的生产环境中，推荐设置为 `n-1`。

## peer.tls.*

```
tls:
    # Require server-side TLS
    enabled:  false
    # Require client certificates / mutual TLS for inbound connections.
    # Note that clients that are not configured to use a certificate will
    # fail to connect to the peer.
    clientAuthRequired: false
    # X.509 certificate used for TLS server
    cert:
        file: tls/server.crt
    # Private key used for TLS server
    key:
        file: tls/server.key
    # rootcert.file represents the trusted root certificate chain used for verifying certificates
    # of other nodes during outbound connections.
    # It is not required to be set, but can be used to augment the set of TLS CA certificates
    # available from the MSPs of each channel’s configuration.
    rootcert:
        file: tls/ca.crt
    # If mutual TLS is enabled, clientRootCAs.files contains a list of additional root certificates
    # used for verifying certificates of client connections.
    # It augments the set of TLS CA certificates available from the MSPs of each channel’s configuration.
    # Minimally, set your organization's TLS CA root certificate so that the peer can receive join channel requests.
    clientRootCAs:
        files:
          - tls/ca.crt
```

配置此部分以启用 peer 节点的 TLS 通信。启用 TLS 后，与 peer 节点进行交互的所有节点也需要启用 TLS。请查阅[注册和登录CA身份](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html)主题中有关如何生成 peer 节点 TLS 证书的说明。

- **`enabled`：**（默认值应该被覆盖）为确保生产环境安全，应通过在配置文件的 `tls` 部分设置 `enabled: true` 来启用节点之间的所有通信的 TLS。虽然默认情况下禁用此字段，在测试网络中可能是可接受的，但在生产环境中应启用它。此设置将配置**服务器端 TLS（server-side TLS）**，这意味着 TLS 将向客户端保证服务器的身份，并提供了双向加密通道。

- **`cert.file`：**（默认值应该被覆盖）每个 peer 节点在可以与组织中的其他节点安全交易之前，都需要向其 TLS CA 注册和登录。因此，在部署 peer 节点之前，必须首先为 peer 节点注册用户，并使用 TLS CA 注册 peer 节点身份以生成 peer 节点的 TLS 签名证书。如果您正在使用[注册和登录 CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html)主题中推荐的文件夹结构，则需要将此文件复制到 `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` 目录中。

- **`key.file`：**（默认值应该被覆盖）类似于 `cert.file`，为该 peer 节点提供生成的 TLS 私钥的名称和位置，例如 `/msp/keystore/87bf5eff47d33b13d7aee81032b0e8e1e0ffc7a6571400493a7c_sk`。如果您正在使用[使用 CA 注册和登录](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html)主题中推荐的文件夹结构，则需要将此文件复制到 `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` 目录中。如果您使用 [HSM](#bccsp) 存储 peer 节点的私钥，则此字段将为空。

- **`rootcert.file`：**（默认值可以不设置）该值包含用于在向外连接期间验证其他节点证书的根证书链的名称和位置。不需要设置此值，但可以用于增加每个通道配置的 MSP 的 TLS CA 证书集合。如果您正在使用[注册和登录 CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) 主题中推荐的文件夹结构，则可以将此文件复制到 `config/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` 目录中。

只有在需要双向 TLS 时才需要提供下面两个参数：

- **`clientAuthRequired`：**默认值为 `false`。通过使用**双向 TLS（mutual TLS）** 将其设置为 `true`，以更高级别的安全性，可以将其配置为客户端 TLS 证书的额外验证步骤。服务器端 TLS 被认为是最低必要的安全级别，而双向 TLS 是额外的可选安全级别。

- **`clientRootCAs.files`：**包含用于验证客户端连接证书的附加根证书列表。它扩充了每个通道配置的 MSPs 的 TLS CA 证书集合。至少，设置您组织的 TLS CA 根证书，以便 peer 节点可以接收加入通道的请求。

## peer.bccsp.*

```
BCCSP:
        Default: SW
        # Settings for the SW crypto provider (i.e. when DEFAULT: SW)
        SW:
            # TODO: The default Hash and Security level needs refactoring to be
            # fully configurable. Changing these defaults requires coordination
            # SHA2 is hardcoded in several places, not only BCCSP
            Hash: SHA2
            Security: 256
            # Location of Key Store
            FileKeyStore:
                # If "", defaults to 'mspConfigPath'/keystore
                KeyStore:
        # Settings for the PKCS#11 crypto provider (i.e. when DEFAULT: PKCS11)
        PKCS11:
            # Location of the PKCS11 module library
            Library:
            # Token Label
            Label:
            # User PIN
            Pin:
            Hash:
            Security:
```

（可选的）此部分用于配置区块链加密提供程序。

- **`BCCSP.Default：`**如果计划使用硬件安全模块（HSM），则必须将其设置为 `PKCS11`。

- **`BCCSP.PKCS11.*：`**根据 HSM 配置提供一组参数。有关详细信息，请参阅 HSM 配置[示例](../hsm.html)。

## chaincode.externalBuilders.*

```
# List of directories to treat as external builders and launchers for
    # chaincode. The external builder detection processing will iterate over the
    # builders in the order specified below.
    externalBuilders: []
        # - path: /path/to/directory
        #   name: descriptive-builder-name
        #   propagateEnvironment:
        #      - ENVVAR_NAME_TO_PROPAGATE_FROM_PEER
        #      - GOPROXY
```

（可选的）**Fabric 2.0 中新增的功能。**此部分用于配置链码构建器所在路径的集合。每个外部构建器定义必须包括一个名称（用于日志记录）和包含构建器脚本的 `bin` 目录的路径。此外，您可以选择指定一个要从 peer 节点传播的环境变量名称列表，以在 peer 节点调用外部构建器脚本时传播它们。有关详细信息，请参见[配置外部构建器和启动器](../cc_launcher.html)。

- **`externalBuilders.path:`** 指定构建器的路径。
- **`externalBuilders.name:`** 为此构建器命名。
- **`externalBuilders.propagateEnvironment:`** 指定要传播到 peer 节点的环境变量列表。
  
## ledger.*

```
ledger:

  state:
    # stateDatabase - options are "goleveldb", "CouchDB"
    # goleveldb - default state database stored in goleveldb.
    # CouchDB - store state database in CouchDB
    stateDatabase: goleveldb

    couchDBConfig:
       # It is recommended to run CouchDB on the same server as the peer, and
       # not map the CouchDB container port to a server port in docker-compose.
       # Otherwise proper security must be provided on the connection between
       # CouchDB client (on the peer) and server.
       couchDBAddress: 127.0.0.1:5984

       # This username must have read and write authority on CouchDB
       username:

       # The password is recommended to pass as an environment variable
       # during start up (eg CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD).
       # If it is stored here, the file must be access control protected
       # to prevent unintended users from discovering the password.
       password:
```

此部分用于选择您的账本数据库类型，可以选择 goleveldb 或 CouchDB。为避免出现错误，所有 peer 服务应使用相同的数据库**类型**。当需要使用 JSON 查询时，CouchDB 是一个合适的选择。虽然 CouchDB 运行在单独的操作系统进程中，但 peer 节点和 CouchDB 实例之间仍然存在1:1的关系，这意味着每个 peer 节点将具有一个单独的数据库，并且该数据库将仅与该 peer 节点关联。除了 CouchDB 的额外 JSON 查询功能外，数据库的选择对智能合约是无形的。

- **`ledger.state.stateDatabase：`**（当您计划使用 CouchDB 时，覆盖此值。）默认为 goleveldb，适用于账本状态是简单键值对的情况。LevelDB 数据库嵌入在 peer 节点进程中。

- **`ledger.state.couchDBConfig.couchDBAddress：`**（当使用 CouchDB 时必须指定。）指定 CouchDB 运行的地址和端口。

- **`ledger.state.couchDBConfig.username：`**（当使用 CouchDB 时必须指定。）指定具有对数据库的读写权限的 CouchDB 用户。

- **`ledger.state.couchDBConfig.password：`**（当使用 CouchDB 时必须指定。）指定具有对数据库的读写权限的 CouchDB 用户的密码。

`ledger` 部分还包含您的默认快照目录，其中存储快照。有关快照的更多信息，请查看[拍摄账本快照并使用它们加入通道](../peer_ledger_snapshot.html)。

```
snapshots:
  # Path on the file system where peer will store ledger snapshots
  rootDir: /var/hyperledger/production/snapshots
```

- **`ledger.snapshots.rootDir:`**（默认值应被覆盖。）这是快照在 peer 节点的本地文件系统上存储的路径。它可以是绝对路径，也可以是相对于 `FABRIC_CFG_PATH` 的路径，默认为 `/var/hyperledger/production/snapshots`。当拍摄快照时，它会自动按照快照的状态、通道名称和区块编号进行组织。有关更多信息，请查看[拍摄一个快照](../peer_ledger_snapshot.html#taking-a-snapshot)。运行 peer 服务的用户需要拥有并具有对此目录的写访问权限。

## operations.*

```
operations:
    # host and port for the operations server
    listenAddress: 127.0.0.1:9443

    # TLS configuration for the operations endpoint
    tls:
        # TLS enabled
        enabled: false

        # path to PEM encoded server certificate for the operations server
        cert:
            file:

        # path to PEM encoded server key for the operations server
        key:
            file:

        # most operations service endpoints require client authentication when TLS
        # is enabled. clientAuthRequired requires client certificate authentication
        # at the TLS layer to access all resources.
        clientAuthRequired: false

        # paths to PEM encoded ca certificates to trust for client authentication
        clientRootCAs:
            files: []
```

操作服务用于监视 peer 节点的健康状况，并依赖于双向 TLS 来保护其通信。因此，您需要将 `operations.tls.clientAuthRequired` 设置为 `true`。当将此参数设置为 `true` 时，试图确定节点健康状况的客户端必须提供有效的证书进行身份验证。如果客户端没有提供证书或服务无法验证客户端的证书，则会拒绝请求。这意味着客户端需要向 peer 服务的 TLS CA 注册，并在请求中提供其 TLS 签名证书。有关详情，请参见[操作服务](../operations_service.html)。

如果您计划使用 Prometheus [metrics](#metrics) 来监视 peer 节点，则必须在此处配置操作服务。

如果两个 peer 服务在同一节点上运行，您需要修改第二个 peer 服务的地址以使用不同的端口。否则，当您启动第二个 peer 服务时，它将无法启动，并报告地址已被使用。

- **`operations.listenAddress：`**（使用操作服务时必须指定。）指定操作服务器的地址和端口。
- **`operations.tls.cert.file*：`**（使用操作服务时必须指定。）可以是与 `peer.tls.cert.file` 相同的文件。
- **`operations.tls.key.file*：`**（使用操作服务时必须指定。）可以是与 `peer.tls.key.file` 相同的文件。
- **`operations.tls.clientAuthRequired*：`**（使用操作服务时必须指定。）必须设置为 `true`，以启用客户端和服务器之间的双向 TLS。
- **`operations.tls.clientRootCAs.files*：`**（使用操作服务时必须指定。）类似于 [peer.tls.clientRootCAs.files](#tls)，它包含可以用于验证客户端证书的客户端根 CA 证书列表。如果客户端使用 peer 服务组织 CA 注册，则此值为 peer 服务组织根 CA 证书。

## metrics.*

```
metrics:
    # metrics provider is one of statsd, prometheus, or disabled
    provider: disabled
    # statsd configuration
    statsd:
        # network type: tcp or udp
        network: udp

        # statsd server address
        address: 127.0.0.1:8125
```

默认情况下，此选项已被禁用，但如果您想监视 peer 节点的度量指标（metrics），则需要选择 `statsd` 或 `Prometheus` 作为您的度量指标提供器。`Statsd` 使用“推送”模型，从 peer 服务推送度量指标到 `statsd` 端点。因此，它不需要配置操作服务本身。请参见[可用于 peer 服务的度量指标](../metrics_reference.html#peer-metrics)列表。

- **`provider`：**（必须提供以使用 peer 服务的 `statsd` 或 `Prometheus` 度量指标。）由于 Prometheus 使用“拉取”模型，因此除了使操作服务可用之外不需要进行任何配置。而 Prometheus 以轮询的方式操作 URL 发送请求，保持度量指标的可用性。
- **`address`：**（使用 `statsd` 时必须指定。）当启用 `statsd` 时，您需要配置 statsd 服务器的主机名和端口，以便 peer 服务可以推送度量指标，进行更新。

## 下一步

在确定 peer 节点配置后，您可以部署 peer 节点。请按照[部署 peer 节点](./peerdeploy.html)主题中的说明部署您的 peer 节点。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
