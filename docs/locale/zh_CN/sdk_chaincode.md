# Fabric 合约 API 和应用程序 API

## Fabric 合约 API

Hyperledger Fabric提供了多个API来支持使用不同编程语言开发智能合约（链码）。 目前官方提供Go、Node.js和Java编程语言来调用智能合约API。

* [Go合约API](https://github.com/hyperledger/fabric-contract-api-go) and [文档](https://pkg.go.dev/github.com/hyperledger/fabric-contract-api-go).
* [Node.js合约API](https://github.com/hyperledger/fabric-chaincode-node) and [文档ation](https://hyperledger.github.io/fabric-chaincode-node/).
* [Java合约API](https://github.com/hyperledger/fabric-chaincode-java) and [文档](https://hyperledger.github.io/fabric-chaincode-java/).

## Fabric 应用程序 API

Hyperledger Fabric提供了Fabric 网关客户端API，以支持使用Go、Node.js和Java编程语言开发应用程序。该API利用Fabric从版本2.4引入的网关peer功能与Fabric网络进行交互，其最初在Fabric v1.4中作为一种新的的应用程序开发模型被引入。目前，Fabric网关客户端API是开发Fabric 版本2.4及更高版本应用程序的首选API。

* [Fabric 网关客户端 API](https://github.com/hyperledger/fabric-gateway) and [文档](https://hyperledger.github.io/fabric-gateway/).

对于不同的编程语言，仍然存在用于旧版本应用程序的SDK，但它们可以与Fabric v2.4版本的Gateway peer一起使用。这些应用程序SDK支持v2.4之前的Fabric版本，并且不需要Gateway peer功能。另外它们还包含一些其他功能，例如通过证书颁发机构（CA）进行身份注册管理的管理操作，这些功能在Fabric Gateway API中不提供。目前Fabric v2.4版本的应用程序SDK提供Go、Node.js和Java语言版本。

* [Node.js SDK](https://github.com/hyperledger/fabric-sdk-node) and [documentation](https://hyperledger.github.io/fabric-sdk-node/).
* [Java SDK](https://github.com/hyperledger/fabric-gateway-java) and [documentation](https://hyperledger.github.io/fabric-gateway-java/).
* [Go SDK](https://github.com/hyperledger/fabric-sdk-go) and [documentation](https://pkg.go.dev/github.com/hyperledger/fabric-sdk-go/).

开发SDK的准备条件可以在以下位置找到：
Node.js SDK [README](https://github.com/hyperledger/fabric-sdk-node#build-and-test),
Java SDK [README](https://github.com/hyperledger/fabric-gateway-java/blob/main/README.md), and
Go SDK [README](https://github.com/hyperledger/fabric-sdk-go/blob/main/README.md).

此外，Python的应用程序SDK还未正式发布，但可供下载和测试。
* [Python SDK](https://github.com/hyperledger/fabric-sdk-py).
