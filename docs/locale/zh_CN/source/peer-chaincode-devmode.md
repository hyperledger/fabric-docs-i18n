# 在开发模式下运行链码

**受众:** 那些想要迭代开发和测试他们的链码包，但不愿意为每次更新智能合约生命周期过程的做额外开销的智能合约开发者们。

在智能合约开发期间，开发人员需要一种方法来快速迭代地测试链码包，而不必为每次修改执行链码生命周期命令。本教程使用 Fabric 二进制文件并在开发模式("DevMode")中启动peer，然后将链码连接到peer。它允许您启动链码，而无需在peer上安装链码，在链码最初提交到通道之后，您可以绕过peer方的生命周期链码命令。这允许快速部署、调试和更新，而不需要在每次进行更新时重新发出peer生命周期链码命令。

**注意:** 为了在peer上使用开发模式("DevMode")标志，必须在网络中的所有节点上禁用 TLS 通信。并且由于强烈建议生产网络使用 TLS 通信，因此您永远不应该在运行一个生产peer在开发模式中。本教程中使用的网络不应用作任何形式的生产网络的模板。参考[部署一个生产网络](deployment_guide_overview.html)来了解怎样部署一个生产网络。您还可以参考 [Fabric 测试网络](test_network.html)，了解更多关于如何使用 Fabric 链码生命周期过程在通道上部署和更新智能契约包的信息。

在本教程中，所有执行命令都是来自从`fabric/`文件夹。它使用peer和orderer的所有默认设置，并根据需要使用命令行中的环境变量重写配置。默认peer `core.yaml` 或 orderer `orderer.yaml`文件不需要任何编辑。

## 安装环境

1. 克隆Fabric仓库从[GitHub](https://github.com/hyperledger/fabric)，根据您的需要选择发布的分支。
2. 运行以下命令order、 peer 和 configtxgen 构建二进制文件:
    ```
    make orderer peer configtxgen
    ```
    当成功时你会看到类似的结果:
    ```
    Building build/bin/orderer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/orderer
    Building build/bin/peer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/peer
    Building build/bin/configtxgen
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/configtxgen
    ```
3. 设置 `PATH` 环境变量来包含orderer和peer二进制文件:
    ```
    export PATH=$(pwd)/build/bin:$PATH
    ```
4. 设置 `FABRIC_CFG_PATH` 环境变量来指定 `sampleconfig` 文件夹:
    ```
    export FABRIC_CFG_PATH=$(pwd)/sampleconfig
    ```
5. 创建 `hyperledger` 子文件夹在 `/var` 文件夹。这是 Fabric 用来存储 `orderer.yaml` 和 peer `core.yaml` 文件中定义的块的默认位置。要创建 `hyperledger` 子目录，执行以下命令，用用户名替换问号:

    ```
    sudo mkdir /var/hyperledger
    sudo chown ????? /var/hyperledger
    ```
6. 为了订阅服务创建genesis块。运行以下命令生成genesis块，并将其存储在 `$（pwd）/sampleconfig/genesisblock` 中，以便订阅者在下一步启动订阅模块时可以使用它。
    ```
    configtxgen -profile SampleDevModeSolo -channelID syschannel -outputBlock genesisblock -configPath $FABRIC_CFG_PATH -outputBlock "$(pwd)/sampleconfig/genesisblock"
    ```

    ```
    2020-09-14 17:36:37.295 EDT [common.tools.configtxgen] doOutputBlock -> INFO 004 Generating genesis block
    2020-09-14 17:36:37.296 EDT [common.tools.configtxgen] doOutputBlock -> INFO 005 Writing genesis block
    ```
## 启动订阅

运行下列命令以 `SampleDevModeSolo` 模式开始订阅，并启动订阅服务:

```
ORDERER_GENERAL_GENESISPROFILE=SampleDevModeSolo orderer
```
当成功时你可以看见类似的结果:
```
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00b Starting orderer:
 Version: 2.3.0
 Commit SHA: 298695ae2
 Go version: go1.15
 OS/Arch: darwin/amd64
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00c Beginning to serve requests
```

## 在开发模式中开启peer

打开另一个终端窗口，设置环境变量重载peer配置，然后启动peer节点:

**注意:** 如果你想要保证orderer和peer在相同的的环境(不是分开的容器)，只需要设置 `CORE_OPERATIONS_LISTENADDRESS` 环境变量(端口除9443外皆可)
```
export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:9444
```

以 `--peer-chaincodedev=true` 标志启动peer让peer进入开发模式
```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true
```

**提醒:** 当进入 `DevMode`，TLS 将被禁用。

当成功时你可能看到类似结果:
```
2020-09-14 17:38:45.324 EDT [nodeCmd] serve -> INFO 00e Running in chaincode development mode
...
2020-09-14 17:38:45.326 EDT [nodeCmd] serve -> INFO 01a Started peer with ID=[jdoe]，network ID=[dev]，address=[192.168.1.134:7051]
```

## 创建通道并加入peer

打开另一个终端窗口，运行下列命令使用`configtxgen`工具来生成通道创建事务。 这个命令在 `SampleSingleMSPChannel` 环境创建了一个通道 `ch1`:

```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
configtxgen -channelID ch1 -outputCreateChannelTx ch1.tx -profile SampleSingleMSPChannel -configPath $FABRIC_CFG_PATH
peer channel create -o 127.0.0.1:7050 -c ch1 -f ch1.tx
```

```
2020-09-14 17:42:56.931 EDT [cli.common] readBlock -> INFO 002 Received block: 0
```

现在通过下列命令将peer加入通道中:

```
peer channel join -b ch1.block
```
```
2020-09-14 17:43:34.976 EDT [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

peer现在加入到了通道 `ch1`。

## 构建链码

我们使用来自 `fabric/integration/chaincode` 目录的**简单**链码来说明怎样在开发模式中运行一个链码包。 在上一步相同的终端窗口，运行下列命令来构建链码:

```
go build -o simpleChaincode ./integration/chaincode/simple/cmd
```

## 开始链码


```
CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./simpleChaincode -peer.address 127.0.0.1:7052
```

因为我们在开始时在peer上设置了调试日志，你可以确认链码注册是成功的。在你的peer日志中，你可以看到类似结果:

```
2020-09-14 17:53:43.413 EDT [chaincode] sendReady -> DEBU 045 Changed to state ready for chaincode mycc:1.0
```
## 赞同和提交链码定义

现在你需要运行下列Fabric链码生命周期命令来赞同和提交链码定义到通道中:

```
peer lifecycle chaincode approveformyorg  -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --package-id mycc:1.0
peer lifecycle chaincode checkcommitreadiness -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')"
peer lifecycle chaincode commit -o 127.0.0.1:7050 --channelID ch1 --name mycc --version 1.0 --sequence 1 --init-required --signature-policy "OR ('SampleOrg.member')" --peerAddresses 127.0.0.1:7051
```

你应该看到相似结果:
```
2020-09-14 17:56:30.820 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [f22b3c25dfea7fe0b28af9ee818056db81e29a9421c83fe00eb22fa41d1d1e21] committed with status (VALID) at
Chaincode definition for chaincode 'mycc'，version '1.0'，sequence '1' on channel 'ch1' approval status by org:
SampleOrg: true
2020-09-14 17:57:43.295 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [fb803e8b0b4eae6b3a9ed35668f223753e1a34ffd2a7042f9e5bb516a383eb32] committed with status (VALID) at 127.0.0.1:7051
```

## 下一步

为了验证你的智能合约，必要时你可以发布客户端命令来调用和查询链码。举个例子，我们发布三个命令，第一个初始化智能合约，第二个命令移动 `10` 从集合 `a` 到集合 `b`。最后的命令查询 `a` 的值来验证它是否成功从 `100` 变更为 `90`。

```
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["init","a","100","b","200"]}' --isInit
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["invoke","a","b","10"]}'
CORE_PEER_ADDRESS=127.0.0.1:7051 peer chaincode invoke -o 127.0.0.1:7050 -C ch1 -n mycc -c '{"Args":["query","a"]}'
```

你应该看到类似结果:
```
2020-09-14 18:15:00.034 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
2020-09-14 18:16:29.704 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
2020-09-14 18:17:42.101 EDT [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 payload:"90"
```

在开发模式中运行peer的好处是你可以交互性的更新您的智能合约，保存您的变更，[构建](#build-the-chaincode) 链码，然后[启动](#start-the-chaincode) 用上述步骤启动它。你不需要在你每次变更时运行peer生命周期命令来更新链码。
