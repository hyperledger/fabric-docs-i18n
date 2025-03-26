# Fabric Contract APIsとApplication APIs

## Fabric Contract APIs

Hyperledger Fabricは、多くのプログラミング言語に対応したスマートコントラクト（チェーンコード）の開発を支援するために、複数のAPIを提供しています。スマートコントラクトAPIは、Go、Node.jsとJavaで利用可能です。

* [Go contract API](https://github.com/hyperledger/fabric-contract-api-go) と [documentation](https://pkg.go.dev/github.com/hyperledger/fabric-contract-api-go)
* [Node.js contract API](https://github.com/hyperledger/fabric-chaincode-node) と [documentation](https://hyperledger.github.io/fabric-chaincode-node/)
* [Java contract API](https://github.com/hyperledger/fabric-chaincode-java) と [documentation](https://hyperledger.github.io/fabric-chaincode-java/)

## Fabric Application APIs

Hyperledger Fabricは、Go、Node.jsとJavaによるアプリケーションの開発を支援するために、FabricゲートウェイクライアントAPIを提供しています。このAPIは、Fabricネットワークとやり取りするためにFabric v2.4から導入されたゲートウェイピアケーパビリティを使用しています。また、このAPIは、Fabric v1.4から導入された新しいアプリケーションプログラミングモデルの発展です。FabricゲートウェイクライアントAPIは、Fabric v2.4以降のアプリケーション開発で推奨されるAPIです。

* [Fabric Gateway client API](https://github.com/hyperledger/fabric-gateway) と [documentation](https://hyperledger.github.io/fabric-gateway/)

レガシーアプリケーションSDKsも、様々なプログラミング言語向けに存在し、Fabric v2.4で使用出来ます。これらのアプリケーションSDKsは、v2.4以前のFabricバージョンをサポートし、ゲートウェイピアケーパビリティを必要としません。また、認証局 (CA) によるアイデンティティの登録管理などのFabricゲートウェイAPIで提供していない管理者向けの機能を含みます。アプリケーションSDKsは、Go、Node.jsとJavaで使用可能です。

* [Node.js SDK](https://github.com/hyperledger/fabric-sdk-node) と [documentation](https://hyperledger.github.io/fabric-sdk-node/)
* [Java SDK](https://github.com/hyperledger/fabric-gateway-java) と [documentation](https://hyperledger.github.io/fabric-gateway-java/)
* [Go SDK](https://github.com/hyperledger/fabric-sdk-go) と [documentation](https://pkg.go.dev/github.com/hyperledger/fabric-sdk-go/)

SDKを使用した開発での前提条件は、
Node.js SDK [README](https://github.com/hyperledger/fabric-sdk-node#build-and-test) 、
Java SDK [README](https://github.com/hyperledger/fabric-gateway-java/blob/main/README.md) と
Go SDK [README](https://github.com/hyperledger/fabric-sdk-go/blob/main/README.md)
に記載されています。

加えて、公式にリリースされていないPython向けのアプリケーションSDKがありますが、ダウンロードとテストは可能です:

* [Python SDK](https://github.com/hyperledger/fabric-sdk-py)
