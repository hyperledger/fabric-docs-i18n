# Fabric Contract APIs and Application APIs

## Fabric Contract APIs

Hyperledger Fabric提供了多个API来支持使用不同编程语言开发智能合约（链码）。 目前官方提供Go、Node.js和Java编程语言来调用智能合约的API。

* [Go contract API](https://github.com/hyperledger/fabric-contract-api-go) and [documentation](https://pkg.go.dev/github.com/hyperledger/fabric-contract-api-go).
* [Node.js contract API](https://github.com/hyperledger/fabric-chaincode-node) and [documentation](https://hyperledger.github.io/fabric-chaincode-node/).
* [Java contract API](https://github.com/hyperledger/fabric-chaincode-java) and [documentation](https://hyperledger.github.io/fabric-chaincode-java/).

## Fabric Application APIs

Hyperledger Fabric提供了Fabric Gateway客户端API，以支持使用Go、Node.js和Java编程语言开发应用程序。该API利用Fabric v2.4引入的Gateway peer功能与Fabric网络进行交互，其最初在Fabric v1.4中作为一种新的的应用程序开发模型被引入。目前，Fabric Gateway客户端API是开发Fabric v2.4及更高版本应用程序的首选API。

* [Fabric Gateway client API](https://github.com/hyperledger/fabric-gateway) and [documentation](https://hyperledger.github.io/fabric-gateway/).

对于不同的编程语言，仍然存在用于旧版本应用程序的SDK，但它们可以与Fabric v2.4版本的Gateway peer一起使用。这些应用程序SDK支持v2.4之前的Fabric版本，并且不需要Gateway peer功能。另外它们还包含一些其他功能，例如通过证书颁发机构（CA）进行身份注册管理的管理操作，这些功能在Fabric Gateway API中不提供。目前Fabric v2.4版本的应用程序SDK提供Go、Node.js和Java语言版本。

* [Node.js SDK](https://github.com/hyperledger/fabric-sdk-node) and [documentation](https://hyperledger.github.io/fabric-sdk-node/).
* [Java SDK](https://github.com/hyperledger/fabric-gateway-java) and [documentation](https://hyperledger.github.io/fabric-gateway-java/).
* [Go SDK](https://github.com/hyperledger/fabric-sdk-go) and [documentation](https://pkg.go.dev/github.com/hyperledger/fabric-sdk-go/).

开发SDK的准备条件可以在以下位置找到：
Node.js SDK [README](https://github.com/hyperledger/fabric-sdk-node#build-and-test),
Java SDK [README](https://github.com/hyperledger/fabric-gateway-java/blob/main/README.md), and
Go SDK [README](https://github.com/hyperledger/fabric-sdk-go/blob/main/README.md).

此外，还有一个针对Python的应用程序SDK尚未正式发布，但仍可供下载和测试使用。

* [Python SDK](https://github.com/hyperledger/fabric-sdk-py).
