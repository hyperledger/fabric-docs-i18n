# 将智能合约部署到通道

终端用户通过调用智能合约与区块链账本进行交互。在 Hyperledger Fabric 中，智能合约被部署在链码包中。若组织想要验证交易或访问账本，则需要在 peer 上安装链码。待为通道上的 peer 安装链码后，通道成员可将链码部署到通道上，并可在该通道使用智能合约新增或更新通道账本上的资产。

通过使用 Fabric 链码生命周期，我们可将链码部署到通道上。Fabric 链码生命周期允许多个组织在使用链码创建交易之前，就链码的操作达成一致意见。例如，当一个背书策略指定哪些组织需要执行链码来验证交易的时候，通道成员需使用 Fabric 链码生命周期来商定链码的背书策略。有关如何在通道上部署和管理链码的更深入的概述，请参阅 [Fabric chaincode lifecycle](./chaincode_lifecycle.html).

通过本教程，您将学会如何使用 [peer lifecycle chaincode commands](./commands/peerlifecycle.html) 在 Fabric 测试网络的通道上部署一个智能合约。一旦您了解了这些指令，您就可以利用教程中的步骤去将您自己的链码部署到测试网络上，或将链码部署到生产网络上。在本教程中，您将部署 [Running a Fabric Application tutorial](./write_first_app.html)中用到的 asset-transfer (basic)链码。

**注意：** 这些说明使用的是 v2.0 版本中引入的 Fabric 链码周期。如果您想要使用先前版本的生命周期去安装和实例化链码，请参阅 [v1.4 version of the Fabric documentation](https://hyperledger-fabric.readthedocs.io/en/release-1.4)。

## 启动网络

我们将从部署 Fabric 测试网络的实例开始。在您开始前，请确保您已按照[getting_started](getting_started.html)中的说明安装了必要的软件。使用以下命令进入到您本地克隆的`fabric-samples`仓库中的测试网络的文件目录之下：

```
cd fabric-samples/test-network
```

在本教程中，我们希望能从已知的初始状态进行操作。下面的命令将终止所有活动的或过时的 docker 容器，并删除以前生成的构件。

```
./network.sh down
```

然后您可以使用以下命令去启动测试网络：

```
./network.sh up createChannel
```

`createChannel`命令创建一个名为`mychannel`的通道，有两个通道成员，分别是 Org1 和 Org2。这个命令也会加入一个 peer，该 peer 属于该通道下的每个组织。如果该网络和通道创建成功，您可在日志中看到如下信息：

```
========= Channel successfully joined ===========
```

现在，我们可使用 Peer CLI 将 asset-transfer (basic) 链码部署到通道上，步骤如下：

- [Step one: Package the smart contract](#package-the-smart-contract)
- [Step two: Install the chaincode package](#install-the-chaincode-package)
- [Step three: Approve a chaincode definition](#approve-a-chaincode-definition)
- [Step four: Committing the chaincode definition to the channel](#committing-the-chaincode-definition-to-the-channel)

## 设置 Logspout（可选）

这个步骤不是必须的，但其对于排除链码故障非常有用。管理者可通过使用 `logspout` [tool](https://logdna.com/what-is-logspout/)查看一组 Docker 容器的汇总输出，从而监控智能合约的日志。该工具从不同的 Docker 容器收集输出流，并将其汇总到一处，使得我们能够很容易地从一个简单的窗口中看到发生的事情。当管理者安装智能合约时，或者开发者调用智能合约，这可帮助他们调试问题。由于一些容器纯粹是为了启动智能合约创建的，并且只存在很短时间，因此，收集网络中的所有日志是很有帮助的。

安装和配置 Logspout 的脚本是`monitordocker.sh`，其已被包含在`test-network` 文件夹的 Fabric samples 中。Logspout 工具将会在您的终端中持续输出日志，因此您需要使用一个新的终端窗口。打开一个新终端并进入到 `test-network` 文件夹下。

```
cd fabric-samples/test-network
```

然后，您可使用以下命令启动 Logspout：

```
./monitordocker.sh fabric_test
```

您将看到类似以下的输出：

```
Starting monitoring on all containers on the network net_basic
Unable to find image 'gliderlabs/logspout:latest' locally
latest: Pulling from gliderlabs/logspout
4fe2ade4980c: Pull complete
decca452f519: Pull complete
ad60f6b6c009: Pull complete
Digest: sha256:374e06b17b004bddc5445525796b5f7adb8234d64c5c5d663095fccafb6e4c26
Status: Downloaded newer image for gliderlabs/logspout:latest
1f99d130f15cf01706eda3e1f040496ec885036d485cb6bcc0da4a567ad84361

```

一开始，您不会看到任何日志，但是当我们部署了链码后将会改变。将终端窗口变宽，字体变小，可能会有所帮助。

## 打包智能合约

在将链码安装到 peer 前，我们需要打包链码。用不同的语言如[Go](#go)、[JavaScript](#javascript)、或[Typescript](#typescript)编写的链码，安装的步骤是不同的。

### Go

在打包链码前，我们需要安装链码依赖。切换到 Go 语言版本的 asset-transfer (basic)目录下。

```
cd fabric-samples/asset-transfer-basic/chaincode-go
```

该例子使用 Go module 安装链码依赖。依赖将会被列举到 `go.mod` 的文件中，其在`asset-transfer-basic/chaincode-go`的文件夹下。您应花点时间去检查这个文件。

```
$ cat go.mod
module github.com/hyperledger/fabric-samples/asset-transfer-basic/chaincode-go

go 1.14

require (
        github.com/golang/protobuf v1.3.2
        github.com/hyperledger/fabric-chaincode-go v0.0.0-20200424173110-d7076418f212
        github.com/hyperledger/fabric-contract-api-go v1.1.0
        github.com/hyperledger/fabric-protos-go v0.0.0-20200424173316-dd554ba3746e
        github.com/stretchr/testify v1.5.1
)
```

`go.mod`文件将 Fabric 合约 API 导入到智能合约包。您可用文本编辑器打开`asset-transfer-basic/chaincode-go/chaincode/smartcontract.go`，来查看如何使用合约 API 在智能合约的开头定义`SmartContract`类型：

```
// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}
```

然后，`SmartContract` 类型用于为智能合约中定义的函数创建交易上下文，这些函数将数据读写到区块链账本。

```
// CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, color string, size int, owner string, appraisedValue int) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the asset %s already exists", id)
	}

	asset := Asset{
		ID:             id,
		Color:          color,
		Size:           size,
		Owner:          owner,
		AppraisedValue: appraisedValue,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

```

您可以学习更多关于 Go 语言的合约 API，请参阅[API documentation](https://github.com/hyperledger/fabric-contract-api-go)和[smart contract processing topic](developapps/smartcontract.html)。

为了安装智能合约依赖，请在`asset-transfer-basic/chaincode-go`文件夹下运行以下命令：

```
GO111MODULE=on go mod vendor
```

如果命令生效，go 的依赖包将会被安装到`vendor`文件夹下。

现在，我们有了自己的依赖，我们可以创建链码包。回到`test-network`的工作目录下，然后将链码连同网络的其他构件一同打包。

```
cd ../../test-network
```

您可以使用`peer` CLI 在创建链码包时指定所需格式。`peer`的二进制文件在`bin`目录下的`fabric-samples`仓库中。使用以下命令将这些二进制文件添加到您的 CLI 路径：

```
export PATH=${PWD}/../bin:$PATH
```

您也需通过设置`FABRIC_CFG_PATH`在`fabric-samples` 仓库中指定`core.yaml`文件：

```
export FABRIC_CFG_PATH=$PWD/../config/
```

为了确保您已经可以使用`peer` CLI，请检查二进制文件的版本。版本需为`2.0.0`或者更新的版本，以便能够运行本教程。

```
peer version
```

现在，您可使用[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package) 的命令创建链码包：

```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-go/ --lang golang --label basic_1.0
```

这个命令将会在您当前的文件夹下创建一个名为`basic.tar.gz`的包。
`--lang`标记用来指明链码语言，`--path`标记用来提供智能合约代码的位置。这个路径必须是完全有效的路径，或者是当前工作目录下的相对路径。
`--label`标志用于指定一个链码标签，该标签将在安装后识别您的链码。建议您的标签包含链码名称和版本。

现在，我们已经创建了链码包，我们可在 peer 的测试网络中[install the chaincode](#install-the-chaincode-package)。

### JavaScript

在打包链码前，我们需要安装链码依赖。切换到 JavaScript 语言版本的 asset-transfer (basic)目录下。

```
cd fabric-samples/asset-transfer-basic/chaincode-javascript
```

依赖将会被列举在`asset-transfer-basic/chaincode-javascript`目录下的`package.json`文件中。您应花点时间去检查这个文件。您可以找到如下所示的依赖部分：

```
"dependencies": {
		"fabric-contract-api": "^2.0.0",
		"fabric-shim": "^2.0.0"
```

`package.json`文件将 Fabric 合约 class 导入到智能合约包。您可用文本编辑器打开`lib/assetTransfer.js`来查看导入到智能合约及用于创建 asset-transfer (basic)的合约 class。

```
const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {
	...
}

```

`AssetTransfer` class 用于为智能合约中定义的函数创建交易上下文，这些函数将数据读写到区块链账本。

```
async CreateAsset(ctx, id, color, size, owner, appraisedValue) {
        const asset = {
            ID: id,
            Color: color,
            Size: size,
            Owner: owner,
            AppraisedValue: appraisedValue,
        };

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }
```

您可以学习更多关于 JavaScript 语言编写的合约 API，请参阅[API documentation](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/) 和[smart contract processing topic](developapps/smartcontract.html)。

为了安装智能合约依赖，请在`asset-transfer-basic/chaincode-javascript` 文件夹下运行以下命令：

```
npm install
```

如果命令生效，JavaScript 的依赖包将会被安装到`node_modules`文件夹下。

现在，我们有了自己的依赖，我们可以创建链码包。回到`test-network`的工作目录下，然后将链码连同网络的其他构件一同打包。

```
cd ../../test-network
```

您可以使用`peer` CLI 在创建链码包时指定所需格式。`peer`的二进制文件在`bin`目录下的`fabric-samples`仓库中。使用以下命令将这些二进制文件添加到您的 CLI 路径：

```
export PATH=${PWD}/../bin:$PATH
```

您也需通过设置 `FABRIC_CFG_PATH`在`fabric-samples` 仓库中指定`core.yaml`文件：

```
export FABRIC_CFG_PATH=$PWD/../config/
```

为了确保您已经可以使用`peer` CLI，请检查二进制文件的版本。版本需为`2.0.0`或者更新的版本，以便能够运行本教程。

```
peer version
```

现在，您可使用[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package) 的命令创建链码包：

```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_1.0
```

这个命令将会在您当前的文件夹下创建一个名为`basic.tar.gz`的包。`--lang`标记用来指明链码语言，`--path`标记用来提供智能合约代码的位置。这个路径必须是完全有效的路径，或者是当前工作目录下的相对路径。`--label`标志用于指定一个链码标签，该标签将在安装后识别您的链码。建议您的标签包含链码名称和版本。

现在，我们已经创建了链码包，我们可在 peer 的测试网络中[install the chaincode](#install-the-chaincode-package)。

### Typescript

在打包链码前，我们需要安装链码依赖。切换到 TypeScript 语言版本的 asset-transfer (basic)目录下。

```
cd fabric-samples/asset-transfer-basic/chaincode-typescript
```

依赖将会被列举在`asset-transfer-basic/chaincode-typescript`目录下的`package.json`文件中。您应花点时间去检查这个文件。您可以找到如下所示的依赖部分：

```
"dependencies": {
		"fabric-contract-api": "^2.0.0",
		"fabric-shim": "^2.0.0"
```

`package.json`文件将 Fabric 合约 class 导入到智能合约包。您可用文本编辑器打开`src/assetTransfer.ts` 来查看导入到智能合约及用于创建 asset-transfer (basic)的合约 class。同时注意 Asset class 是从名为`asset.ts`类型的定义文件中导入。

```
import { Context, Contract } from 'fabric-contract-api';
import { Asset } from './asset';

export class AssetTransfer extends Contract {
	...
}

```

`AssetTransfer` class 用于为智能合约中定义的函数创建交易上下文，这些函数将数据读写到区块链账本。

```
 // CreateAsset issues a new asset to the world state with given details.
    public async CreateAsset(ctx: Context, id: string, color: string, size: number, owner: string, appraisedValue: number) {
        const asset = {
            ID: id,
            Color: color,
            Size: size,
            Owner: owner,
            AppraisedValue: appraisedValue,
        };

        await ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }

```

您可以学习更多关于 TypeScript 语言编写的合约 API，请参阅[API documentation](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/) 和[smart contract processing topic](developapps/smartcontract.html)。

为了安装智能合约依赖，请在`asset-transfer-basic/chaincode-typescript`文件夹下运行以下命令：

```
npm install
```

如果命令生效，JavaScript 的依赖包将会被安装到`node_modules`文件夹下。

现在，我们有了自己的依赖，我们可以创建链码包。回到`test-network`的工作目录下，然后将链码连同网络的其他构件一同打包。

```
cd ../../test-network
```

您可以使用`peer` CLI 在创建链码包时指定所需格式。`peer`的二进制文件在`bin`目录下的`fabric-samples`仓库中。使用以下命令将这些二进制文件添加到您的 CLI 路径：

```
export PATH=${PWD}/../bin:$PATH
```

您也需通过设置`FABRIC_CFG_PATH`在`fabric-samples` 仓库中指定`core.yaml`文件：

```
export FABRIC_CFG_PATH=$PWD/../config/
```

为了确保您已经可以使用`peer` CLI，请检查二进制文件的版本。版本需为`2.0.0`或者更新的版本，以便能够运行本教程。

```
peer version
```

现在，您可使用[peer lifecycle chaincode package](commands/peerlifecycle.html#peer-lifecycle-chaincode-package) 的命令创建链码包：

```
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-typescript/ --lang node --label basic_1.0
```

这个命令将会在您当前的文件夹下创建一个名为`basic.tar.gz`的包。`--lang`标记用来指明链码语言，`--path`标记用来提供智能合约代码的位置。这个路径必须是完全有效的路径，或者是当前工作目录下的相对路径。`--label`标志用于指定一个链码标签，该标签将在安装后识别您的链码。建议您的标签包含链码名称和版本。

现在，我们已经创建了链码包，我们可在 peer 的测试网络中[install the chaincode](#install-the-chaincode-package)。

## 安装链码包

在打包了 asset-transfer (basic)智能合约后，我们可以在 peer 上安装链码。链码必须安装在每个为交易背书的 peer 上。由于我们将要设置背书策略，并要求来自 Org1 和 Org2 的背书，因此我们需要两个组织操作的 peer 上安装链码：

- peer0.org1.example.com
- peer0.org2.example.com

首先在 Org1 的 peer 上安装链码。设置以下环境变量以 Org1 的管理员的身份去操作`peer` CLI。 而`CORE_PEER_ADDRESS`将被设置为指向 Org1 的 peer`peer0.org1.example.com`。

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

执行[peer lifecycle chaincode install](commands/peerlifecycle.html#peer-lifecycle-chaincode-install)命令安装 peer 上的链码：

```
peer lifecycle chaincode install basic.tar.gz
```

如果命令生效，peer 将会生成和返回包 ID。这个包 ID 将在下一步中用于批准链码。您将看到以下类似的输出：

```
2020-07-16 10:09:57.534 CDT [cli.lifecycle.chaincode] submitInstallProposal -> INFO 001 Installed remotely: response:<status:200 payload:"\nJbasic_1.0:e2db7f693d4aa6156e652741d5606e9c5f0de9ebb88c5721cb8248c3aead8123\022\tbasic_1.0" >
2020-07-16 10:09:57.534 CDT [cli.lifecycle.chaincode] submitInstallProposal -> INFO 002 Chaincode code package identifier: basic_1.0:e2db7f693d4aa6156e652741d5606e9c5f0de9ebb88c5721cb8248c3aead8123
```

现在我们可以在 Org2 peer 上安装链码。设置以下环境变量以 Org2 的管理员的身份去操作`peer` CLI。 而`CORE_PEER_ADDRESS`将被设置为指向 Org1 的 peer`peer0.org2.example.com`。

```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

执行以下命令去安装链码：

```
peer lifecycle chaincode install basic.tar.gz
```

链码在安装时会被 peer 构建。如果智能合约的代码有误，安装命令将会返回链码的构建错误信息。

## 批准链码定义

在您安装了链码包后，您需要为组织批准链码定义。定义包括链码管理的重要参数，如名称、版本和链码背书策略。

通道成员集合需要在部署链码前批准链码，该集合受到`/Channel/Application/LifecycleEndorsement`策略的管辖。默认情况下，该策略要求在通道中使用链码前，需要大多数通道成员批准链码。由于我们通道上只有两个组织，而 2 的大多数就是 2，因此我们需要作为 Org1 和 Org2 来批准 asset-transfer (basic)的链码定义。

如果一个组织已经在 peer 上安装了链码，则需要在组织批准的链码定义中包含包 ID。包 ID 用来关联安装在批准了链码定义 peer 的链码，并允许组织使用链码去对交易背书。您可以使用 [peer lifecycle chaincode queryinstalled](commands/peerlifecycle.html#peer-lifecycle-chaincode-queryinstalled)命令查询 peer，找到链码的包 ID。

```
peer lifecycle chaincode queryinstalled
```

包 ID 是链码标签和链码二进制文件哈希值的组合。每个 peer 将会生成相同的包 ID。您应当能看到以下类似的输出：

```
Installed chaincodes on peer:
Package ID: basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: basic_1.0
```

我们将在批准链码的时候使用包 ID，因此将其保存为环境变量。将`peer lifecycle chaincode queryinstalled`命令返回的包 ID 粘贴到以下命令中。**注意：**并非所有用户的包 ID 都相同，因此您需要使用上一步命令窗口返回的包 ID 来完成此步骤。

```
export CC_PACKAGE_ID=basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3
```

由于环境变量已经被设置为作为 Org2 管理员来进行操作，我们可以以 Org2 的身份批准 asset-transfer (basic) 的链码定义。链码在组织级别得到批准，因此命令只需针对一个 peer。而批准会被在组织的内部通过 gossip 分发给其他 peer。使用[peer lifecycle chaincode approveformyorg](commands/peerlifecycle.html#peer-lifecycle-chaincode-approveformyorg)命令批准链码定义：

```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

上面的命令使用`--package-id`标志在链码定义中包含包的标识符。`--sequence`参数是一个整数，用于跟踪链码被定义或更新的次数。由于链码是第一次部署到通道，因此其序列号为 1。当 asset-transfer (basic)链码升级时，序列号将增加到 2。如果您正在使用 Fabric Chaincode Shim API 提供的低版本 API，您可以传递`--init-required`标志给上述命令，以请求执行 Init 函数来初始化链码。链码的第一次调用需要指定 Init 函数并包含`--isInit`标志，然后才能调用链码中的其他函数与 ledger 进行交互。

我们可以为`approveformyorg`命令提供`--signature-policy`或`--channel-config-policy`参数来指定链码背书策略。背书策略指定需要多少属于不同通道成员的 peers 来根据给定的链码去验证交易。因为我们没有设置策略，所以 asset-transfer (basic)定义将使用默认的背书策略，该策略要求事务在提交时得到大多数通道成员的背书。这意味着如果从通道中添加或删除新的组织，背书策略
会自动更新以要求更多或更少的背书。在本教程中，默认策略将需要 2 中的大多数，并且事务需要由来自 Org1 和 Org2 的 peer 进行背书。如果需要自定义背书策略，可以参考[Endorsement Policies](endorsement-policies.html)操作指南了解策略语法。

您需要批准具有管理员角色的身份的链码定义。因此，`CORE_PEER_MSPCONFIGPATH`变量需要指向包含管理员身份的 MSP 文件。您不能与客户端用户一起批准链码定义。需要将批准提交给排序服务，该服务将验证管理员签名，然后将批准分发给您的 peers。

我们仍需批准链码定义为 Org1。设置以下环境变作为 Org1 的管理员操作：

```
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
```

现在您可以作为 Org1 来批准链码定义。

```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

现在，我们有了部署 asset-transfer (basic)链码到通道所需的大多数。虽然只有大多数组织需要批准链码定义(使用默认策略)，但所有组织都需要批准链码定义才能在其 peers 上启动链码。如果在通道成员批准链码之前提交定义，则组织将无法认可交易。因此，建议所有通道成员在提交链码定义之前批准链码。

## 提交链码定义到通道

在足够数量的组织批准了链码定义后，一个组织可以将链码定义提交到通道。如果大多数通道成员批准了该定义，则提交交易将成功，并且在链码定义中商定的参数将在通道上实现。

您可以使用[peer lifecycle chaincode checkcommitreadiness](commands/peerlifecycle.html#peer-lifecycle-chaincode-checkcommitreadiness)命令来检查通道成员是否已经批准了相同的链码定义。用于`checkcommitreadiness`命令的标志与用于批准组织链码的标志相同。但是，您不需要包含`--package-id`标志。

```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json
```

该命令将生成一个 JSON 映射，显示通道成员是否批准了在`checkcommitreadiness`命令中指定的参数:

```json
{
  "Approvals": {
    "Org1MSP": true,
    "Org2MSP": true
  }
}
```

由于作为通道成员的两个组织都批准了相同的参数，因此链码定义已准备好提交给通道。您可以使用[peer lifecycle chaincode commit](commands/peerlifecycle.html#peer-lifecycle-chaincode-commit)命令将链码定义提交到通道。commit 命令也需要由组织管理员提交。

```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
```

上述交易使用`--peerAddresses`标志来定位来自 Org1 的`peer0.org1.example.com`和来自 Org2 的`peer0.org2.example.com`。`commit`事务是提交给加入通道的 peer，以查询由操作该 peer 的组织所批准的链码定义。该命令需要针对来自足够数量的组织的 peers，以满足部署链码的策略。由于批准分布在每个组织中，因此可以针对属于通道成员的任何 peer。

通道成员的链码定义背书被提交给排序服务，以添加到块中并分发到通道。然后，通道上的 peers 验证是否有足够数量的组织批准了链码定义。`peer lifecycle chaincode commit`命令将在返回响应之前等待 peer 的验证。

您可以使用[peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted)命令确认链码定义已经提交到通道。

```
peer lifecycle chaincode querycommitted --channelID mychannel --name basic --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

如果 chaincode 被成功提交到通道，`querycommitted`命令将返回链码定义的序列和版本:

```
Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
```

## 调用链码

在将链码定义提交给通道后，链码将在加入到安装了链码的通道的 peers 上启动。asset-transfer (basic)链码现在可以被客户端应用程序调用了。使用以下命令在账本上创建一组初始资产。请注意，调用命令需要针对足够数量的 peers 来满足链码的背书策略。(注意 CLI 不能访问 Fabric Gateway peer，因此必须指定每个认可 peer。)

```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

如果命令生效，您应该看到以下类似的响应：

```
2020-02-12 18:22:20.576 EST [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200
```

我们可以使用查询函数去读取链码创建的汽车集合：

```
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

查询的响应应该是以下资产列表：

```
[{"Key":"asset1","Record":{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300}},
{"Key":"asset2","Record":{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400}},
{"Key":"asset3","Record":{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500}},
{"Key":"asset4","Record":{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600}},
{"Key":"asset5","Record":{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700}},
{"Key":"asset6","Record":{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}}]
```

## 升级智能合约

您可以使用相同的 Fabric 链码生命周期过程来升级已经部署到通道的链码。通道成员可以通过安装新的链码包，然后批准具有新的包 ID、新的链码版本和序列号加 1 的链码定义来升级链码。在将链码定义提交给通道后，可以使用新的链码。此过程允许通道成员协调何时升级链码，并确保在部署到通道之前有足够数量的通道成员准备使用新的链码。

通道成员也可以使用升级流程更改链码背书策略。通过使用新的背书策略批准链码定义，并将链码定义提交到通道，通道成员可以更改管理链码的背书策略，而无需安装新的链码包。

为了提供一个升级我们刚刚部署的 asset-transfer (basic)链码的场景，让我们假设 Org1 和 Org2 想要安装用另一种语言编写的链码版本。他们将使用 Fabric 链码生命周期来更新链码版本，并确保两个组织都在新的链码在通道上激活之前安装了它。

我们假设 Org1 和 Org2 最初安装了 GO 版本的 asset-transfer (basic)链码，但使用 JavaScript 编写的链码会合意些。第一步是打包 JavaScript 版本的 asset-transfer (basic)链码。如果您在学习本教程时使用了 JavaScript 指令来打包链码，您可以按照用[Go](#go)或[TypeScript](#typescript)打包链码的步骤来安装新的链码二进制文件。

在`test-network`目录下执行以下命令来安装链码依赖。

```
cd ../asset-transfer-basic/chaincode-javascript
npm install
cd ../../test-network
```

然后，您可以执行以下命令从`test-network`目录打包 JavaScript 链码。为了防止您已经关闭了终端，我们将设置再次使用`peer` CLI 所需的环境变量。

```
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer lifecycle chaincode package basic_2.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_2.0
```

运行以下命令以 Org1 管理员的身份操作`peer` CLI：

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

现在，我们可以使用以下命令在 Org1 peer 上安装新的链码包。

```
peer lifecycle chaincode install basic_2.tar.gz
```

新的链码包将创建一个新的包 ID。我们可以通过查询 peer 来查找新的包 ID。

```
peer lifecycle chaincode queryinstalled
```

`queryinstalled` 命令将返回已安装在 peer 上的链码列表，类似于以下输出。

```
Installed chaincodes on peer:
Package ID: basic_1.0:69de748301770f6ef64b42aa6bb6cb291df20aa39542c3ef94008615704007f3, Label: basic_1.0
Package ID: basic_2.0:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4, Label: basic_2.0
```

您可以使用包标签查找新链码的包 ID，并将其保存为新的环境变量。每个链码包输出的包 ID 都会不同，所以不要复制和粘贴！

```
export NEW_CC_PACKAGE_ID=basic_2.0:1d559f9fb3dd879601ee17047658c7e0c84eab732dca7c841102f20e42a9e7d4
```

Org1 现在可以批准新的链码定义：

```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

新的链码定义使用 JavaScript 链码包的包 ID，并更新了链码版本。因为 Fabric 链码生命周期使用 sequence 参数来跟踪链码升级，所以 Org1 也需要将序列号从 1 增加到 2。您可以使用[peer lifecycle chaincode querycommitted](commands/peerlifecycle.html#peer-lifecycle-chaincode-querycommitted)命令来查找最后提交到通道的链码的顺序。

我们现在需要安装链码包，并批准链码定义为 Org2，以便升级链码。执行以下命令以 Org2 管理员的身份操作`peer` CLI :

```
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

现在，我们可以使用以下命令在 Org2 peer 上安装新的链码包。

```
peer lifecycle chaincode install basic_2.tar.gz
```

您现在可以批准 Org2 的新链码定义。

```
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

使用[peer lifecycle chaincode checkcommitreadiness](commands/peerlifecycle.html#peer-lifecycle-chaincode-checkcommitreadiness)命令检查序列 2 的链码定义是否准备好提交到通道：

```
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json
```

如果命令返回以下 JSON，则可以升级链码:

```json
{
  "Approvals": {
    "Org1MSP": true,
    "Org2MSP": true
  }
}
```

提交新的链码定义后，将在通道上升级链码。在此之前，之前的链码将继续在两个组织的 peers 上运行。Org2 可以使用以下命令升级链码:

```
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
```

一个成功的提交事务将立即启动新的链码。如果链码定义改变了背书策略，则新策略将生效。

您可以使用`docker ps`命令来验证新的链码是否已经在您的 peers 上启动:

```
$ docker ps
CONTAINER ID        IMAGE                                                                                                                                                                    COMMAND                  CREATED             STATUS              PORTS                              NAMES
7bf2f1bf792b        dev-peer0.org1.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c-69c9e3e44ed18cafd1e58de37a70e2ec54cd49c7da0cd461fbd5e333de32879b   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org1.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c
985e0967c27a        dev-peer0.org2.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c-158e9c6a4cb51dea043461fc4d3580e7df4c74a52b41e69a25705ce85405d760   "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes                                           dev-peer0.org2.example.com-basic_2.0-572cafd6a972a9b6aa3fa4f6a944efb6648d363c0ba4602f56bc8b3f9e66f46c
31fdd19c3be7        hyperledger/fabric-peer:latest                                                                                                                                           "peer node start"        About an hour ago   Up About an hour    0.0.0.0:7051->7051/tcp             peer0.org1.example.com
1b17ff866fe0        hyperledger/fabric-peer:latest                                                                                                                                           "peer node start"        About an hour ago   Up About an hour    7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
4cf170c7ae9b        hyperledger/fabric-orderer:latest
```

如果您使用了`--init-required`标志，则需要在使用升级后的链码之前调用 Init 函数。因为我们没有请求 Init 的执行，可以通过创建一个新的汽车来测试我们新的 JavaScript 链码:

```
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["asset8","blue","16","Kelley","750"]}'
```

您可以再次查询账本上的所有汽车以查看新车:

```
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

您应该从 JavaScript 链码中看到以下结果:

```
[{"Key":"asset1","Record":{"ID":"asset1","color":"blue","size":5,"owner":"Tomoko","appraisedValue":300}},
{"Key":"asset2","Record":{"ID":"asset2","color":"red","size":5,"owner":"Brad","appraisedValue":400}},
{"Key":"asset3","Record":{"ID":"asset3","color":"green","size":10,"owner":"Jin Soo","appraisedValue":500}},
{"Key":"asset4","Record":{"ID":"asset4","color":"yellow","size":10,"owner":"Max","appraisedValue":600}},
{"Key":"asset5","Record":{"ID":"asset5","color":"black","size":15,"owner":"Adriana","appraisedValue":700}},
{"Key":"asset6","Record":{"ID":"asset6","color":"white","size":15,"owner":"Michel","appraisedValue":800}},
"Key":"asset8","Record":{"ID":"asset8","color":"blue","size":16,"owner":"Kelley","appraisedValue":750}}]
```

## 清理

使用完链码后，还可以使用以下命令删除 Logspout 工具。

```
docker stop logspout
docker rm logspout
```

然后，您可以通过在`test-network`目录下执行以下命令来关闭测试网络:

```
./network.sh down
```

## 下一步

在编写智能合约并将其部署到通道之后，可以使用 Fabric SDKs 提供的 APIs 从客户端应用程序调用智能合约。这允许最终用户与区块链账本上的资产进行交互。要开始使用 Fabric SDKs，请参阅[Running a Fabric Application tutorial](write_first_app.html)。

## 解决难题

### 组织不同意使用链码

**问题：**当我尝试向通道提交新的链码定义时，`peer lifecycle chaincode commit`命令失败，出现以下错误:

```
Error: failed to create signed transaction: proposal response was not successful, error code 500, msg failed to invoke backing implementation of 'CommitChaincodeDefinition': chaincode definition not agreed to by this org (Org1MSP)
```

**解决方案：**您可以尝试通过使用`peer lifecycle chaincode checkcommitreadiness`命令来解决此错误，以检查哪些通道成员已经批准了您试图提交的链码定义。如果任何组织对链码定义的任何参数使用了不同的值，则提交事务将失败。`peer lifecycle chaincode checkcommitreadiness`将显示哪些组织未批准您试图提交的链码定义:

```
{
	"approvals": {
		"Org1MSP": false,
		"Org2MSP": true
	}
}
```

### 调用失败

**问题：** `peer lifecycle chaincode commit`事务成功，但当我第一次尝试调用链码时失败了，出现以下错误:

```
Error: endorsement failure during invoke. response: status:500 message:"make sure the chaincode asset-transfer (basic) has been successfully defined on channel mychannel and try again: chaincode definition for 'asset-transfer (basic)' exists, but chaincode is not installed"
```

**Solution:** You may not have set the correct `--package-id` when you approved your chaincode definition. As a result, the chaincode definition that was committed to the channel was not associated with the chaincode package you installed and the chaincode was not started on your peers. If you are running a docker based network, you can use the `docker ps` command to check if your chaincode is running:

**解决方案:**当您批准您的链码定义时可能没有设置正确的`--package-id`。因此，提交给通道的链码定义与您安装的链码包没有关联，并且链码没有在您的 peers 上启动。如果您正在运行一个基于 docker 的网络，您可以使用`docker ps`命令来检查您的链码是否正在运行:

```
docker ps
CONTAINER ID        IMAGE                               COMMAND             CREATED             STATUS              PORTS                              NAMES
7fe1ae0a69fa        hyperledger/fabric-orderer:latest   "orderer"           5 minutes ago       Up 4 minutes        0.0.0.0:7050->7050/tcp             orderer.example.com
2b9c684bd07e        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        0.0.0.0:7051->7051/tcp             peer0.org1.example.com
39a3e41b2573        hyperledger/fabric-peer:latest      "peer node start"   5 minutes ago       Up 4 minutes        7051/tcp, 0.0.0.0:9051->9051/tcp   peer0.org2.example.com
```

如果您没有看到列出任何链码容器，使用`peer lifecycle chaincode approveformyorg`命令批准具有正确包 ID 的链码定义。

## 背书策略失败

**问题：** 当我尝试提交链码定义到通道上，交易失败，出现以下错误：

```
2020-04-07 20:08:23.306 EDT [chaincodeCmd] ClientWait -> INFO 001 txid [5f569e50ae58efa6261c4ad93180d49ac85ec29a07b58f576405b826a8213aeb] committed with status (ENDORSEMENT_POLICY_FAILURE) at localhost:7051
Error: transaction invalidated with status (ENDORSEMENT_POLICY_FAILURE)
```

**解决方案：** 这个错误是提交交易没有收集到足够的背书来符合生命周期背书策略的结果。此问题可能是由于您的交易没有针对足够数量的 peers 来满足策略。这也可能是由于一些 peer 组织没有包含`Endorsement:`在其`configtx.yaml`文件中的默认`/Channel/Application/Endorsement`策略引用的签名策略:

```
Readers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.peer', 'Org2MSP.client')"
Writers:
		Type: Signature
		Rule: "OR('Org2MSP.admin', 'Org2MSP.client')"
Admins:
		Type: Signature
		Rule: "OR('Org2MSP.admin')"
Endorsement:
		Type: Signature
		Rule: "OR('Org2MSP.peer')"
```

当您[enable the Fabric chaincode lifecycle](enable_cc_lifecycle.html)时，除了需要将您的通道升级到`V2_0`之外，还需要使用新的 Fabric 2.0 通道策略。您的通道需要包含新的`/Channel/Application/LifecycleEndorsement`和`/Channel/Application/Endorsement`策略：

```
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

如果您没有包含通道配置中新的通道策略，当您在组织中批准链码定义时将会得到以下的错误：

```
Error: proposal failed with status: 500 - failed to invoke backing implementation of 'ApproveChaincodeDefinitionForMyOrg': could not set defaults for chaincode definition in channel mychannel: policy '/Channel/Application/Endorsement' must be defined for channel 'mychannel' before chaincode operations can be attempted
```

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
