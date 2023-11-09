# 在开发模式下运行智能合约

**受众人群:** 智能合约开发人员，他们想要迭代开发和测试chaincode代码，但不希望每次更新智能合约都需要一定的生命周期处理开销。

在智能合约开发过程中，开发人员需要一种快速、迭代的测试chaincode代码的方法，而无需每次更新都执行链码生命周期的命令。本教程使用Fabric二进制文件并以开发模式("DevMode")启动peer，然后将chaincode连接到peer。无需在peer上安装chaincode，等chaincode提交到通道之后，就可以绕过peer的链码生命周期命令启动chaincode。这有利于快速部署、调试和更新chaincode，而无需每次更新时重新发起peer生命周期链码命令。

**注意:** 为了在peer上使用开发模式("DevMode")，网络中的所有节点必须禁用TLS通信。在生产网络环境下强烈推荐使用TLS通信，所以永远不要在开发模式下启动一台生产型peer。不要将本教程中使用的网络作为任何形式的生产网络的模板。参考[部署一个生产网络](deployment_guide_overview.html)来了解怎样部署一个生产型网络。还可以参考 [Fabric测试网络](test_network.html)，了解更多关于如何使用Fabric链码生命周期流程在通道上部署和更新智能合约的信息。

在本教程中，所有执行命令都基于`fabric/`目录。peer和orderer节点都使用默认设置，并根据需要使用命令行重写环境变量。默认的peer `core.yaml` 或 orderer `orderer.yaml`文件不需要任何修改。

## 安装环境

1. 从[GitHub](https://github.com/hyperledger/fabric)克隆Fabric代码库，根据需要选择发行的分支。
2. 运行以下命令，构建order、 peer和configtxgen的二进制文件:
    ```
    make orderer peer configtxgen
    ```
    当成功时会看到类似的结果:
    ```
    Building build/bin/orderer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/orderer
    Building build/bin/peer
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/peer
    Building build/bin/configtxgen
    GOBIN=/testDevMode/fabric/build/bin go install -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.0 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=298695ae2 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" github.com/hyperledger/fabric/cmd/configtxgen
    ```
3. 设置 `PATH` 环境变量，以包含orderer和peer二进制文件:
    ```
    export PATH=$(pwd)/build/bin:$PATH
    ```
4. 设置`FABRIC_CFG_PATH`环境变量，指向`sampleconfig`文件夹:
    ```
    export FABRIC_CFG_PATH=$(pwd)/sampleconfig
    ```
5. 在`/var`目录下创建`hyperledger`子文件夹。这是Fabric用来存储区块的默认位置，在order节点的`orderer.yaml`和peer节点的`core.yaml`文件中定义。执行以下命令以创建`hyperledger`子目录，使用自己的用户名替代问号:
    ```
    sudo mkdir /var/hyperledger
    sudo chown ????? /var/hyperledger
    ```
6. 为排序服务创建创世区块。运行以下命令生成创世区块，并将其存储在`$（pwd）/sampleconfig/genesisblock`中，在下一步启动排序节点之后，排序节点可以使用它。
    ```
    configtxgen -profile SampleDevModeSolo -channelID syschannel -outputBlock genesisblock -configPath $FABRIC_CFG_PATH -outputBlock "$(pwd)/sampleconfig/genesisblock"
    ```
    当执行成功时，结果如下：
    ```
    2020-09-14 17:36:37.295 EDT [common.tools.configtxgen] doOutputBlock -> INFO 004 Generating genesis block
    2020-09-14 17:36:37.296 EDT [common.tools.configtxgen] doOutputBlock -> INFO 005 Writing genesis block
    ```

## 启动排序服务

运行下列命令以`SampleDevModeSolo`模式启动排序节点，开启排序服务:
```
ORDERER_GENERAL_GENESISPROFILE=SampleDevModeSolo orderer
```
当成功时可以看见类似的结果:
```
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00b Starting orderer:
 Version: 2.3.0
 Commit SHA: 298695ae2
 Go version: go1.15
 OS/Arch: darwin/amd64
2020-09-14 17:37:20.258 EDT [orderer.common.server] Main -> INFO 00c Beginning to serve requests
```

## 在开发模式中启动peer

打开另一个终端窗口，设置环境变量重载peer配置，然后启动peer节点:

**注意:** 如果你想要将排序节点和peer节点部署在一个环境(不是分开的容器)，只需要设置`CORE_OPERATIONS_LISTENADDRESS`环境变量(端口除9443外皆可)
```
export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:9444
```

以 `--peer-chaincodedev=true` 标识启动peer节点，让peer进入开发模式
```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
FABRIC_LOGGING_SPEC=chaincode=debug CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052 peer node start --peer-chaincodedev=true
```

**提醒:** 当进入`DevMode`，TLS将被禁用。

当成功时你会看到类似结果:
```
2020-09-14 17:38:45.324 EDT [nodeCmd] serve -> INFO 00e Running in chaincode development mode
...
2020-09-14 17:38:45.326 EDT [nodeCmd] serve -> INFO 01a Started peer with ID=[jdoe]，network ID=[dev]，address=[192.168.1.134:7051]
```

## 创建通道并加入peer

打开另一个终端窗口，运行下列命令，使用`configtxgen`工具生成创建通道的事务。 这个命令在`SampleSingleMSPChannel`方式创建了一个通道 `ch1`:

```
export PATH=$(pwd)/build/bin:$PATH
export FABRIC_CFG_PATH=$(pwd)/sampleconfig
configtxgen -channelID ch1 -outputCreateChannelTx ch1.tx -profile SampleSingleMSPChannel -configPath $FABRIC_CFG_PATH
peer channel create -o 127.0.0.1:7050 -c ch1 -f ch1.tx
```

当成功时你会看到类似结果:
```
2020-09-14 17:42:56.931 EDT [cli.common] readBlock -> INFO 002 Received block: 0
```

现在通过下列命令将peer加入通道中:
```
peer channel join -b ch1.block
```

当成功时你会看到类似结果:
```
2020-09-14 17:43:34.976 EDT [channelCmd] executeJoin -> INFO 002 Successfully submitted proposal to join channel
```

现在peer已经加入到了通道 `ch1`。


## 构建链码

我们使用`fabric/integration/chaincode`目录下的**简单**链码，来说明怎样在开发模式中运行一个链码包。 在上一步相同的终端窗口，运行下列命令来构建链码:

```
go build -o simpleChaincode ./integration/chaincode/simple/cmd
```

## 开始链码

在peer节点上开启了`DevMode`开发模式之后，必须将环境变量`CORE_CHAINCODE_ID_NAME`设置为`<CHAINCODE_NAME>:<CHAINCODE_VERSION>`，否则peer会找不到链码。在本例中，我们设置为`mycc:1.0`。执行以下命令，启动链码，并将它关联到peer节点：
```
CORE_CHAINCODE_LOGLEVEL=debug CORE_PEER_TLS_ENABLED=false CORE_CHAINCODE_ID_NAME=mycc:1.0 ./simpleChaincode -peer.address 127.0.0.1:7052
```

在启动peer时设置了调试日志，可以确认链码注册是成功的。在peer日志中，你可以看到类似结果:

```
2020-09-14 17:53:43.413 EDT [chaincode] sendReady -> DEBU 045 Changed to state ready for chaincode mycc:1.0
```
## 同意和提交链码

现在需要运行下列Fabric链码生命周期命令，以同意并将链码提交到通道中:

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

为了验证智能合约的逻辑，你可以使用客户端命令来调用和查询链码。在本样例中，我们提交了三个命令，第一个初始化智能合约，第二个命令从资产`a`中转移`10`给资产`b`。最后一个命令查询`a`的值，以验证它是否成功从`100`变更为 `90`。

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

以开发模式运行peer的好处是，可以交互性地更新智能合约，保存变更，[构建](#build-the-chaincode) 链码，然后用上述步骤[启动](#start-the-chaincode) 。不需要在每次变更时，都运行peer生命周期命令来更新链码。
