# Setting up an ordering node

このトピックでは、オーダリングノードのブートストラッピングプロセスを説明します。実装方法が異なる様々なオーダリングサービスやそれぞれの比較については、[conceptual documentation about ordering](./orderer/ordering_service.html) セクションを参照してください。

このトピックは以下のステップで説明します。

1. (未作成の場合) オーダリングノードが属する組織の作成
2. `orderer.yaml` を使用したノードの設定
3. オーダリングシステムチャネル用のジェネシスブロックの作成
4. オーダリングノードのブートストラッピング

注釈: このトピックは、docker hubからオーダリングノードのイメージをプルしていることを前提にしています。

## Create an organization definition

全てのオーダリングノードは、ピアと同様に、事前に作成された組織に所属する必要があります。この組織は、[Membership Service Provider](./membership/membership.html)
(MSP) によってカプセル化された定義情報を保持しています。なお、MSPはCAによって作成されます。またCAは、証明書と組織のMSPを作成します。

CAの作成、CAを使用したユーザとMSPの作成については、[Fabric CA user's guide](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html) セクションを参照してください。

## Configure your node

オーダリングノードは、`orderer.yaml` と呼ばれる `yaml` ファイルで設定されます。環境変数 `FABRIC_CFG_PATH` は、 `orderer.yaml` ファイルの格納先を示すために使用します。

`orderer.yaml` のサンプルファイルは、[`fabric-samples` github repo](https://github.com/hyperledger/fabric/blob/release-2.2/sampleconfig/orderer.yaml) を参照してください。次のステップに進む前に、 **必ず確認し、内容を把握** してください。以下にいくつかの項目を説明します:

* `LocalMSPID` --- CAが作成したオーダリングノード組織のMSP名です。オーダリングノード組織の管理者が設定します。

* `LocalMSPDir` --- ローカルMSPが格納されている場所を設定します。

*  `# TLS enabled`, `Enabled: false`. [enable TLS](enable_tls.html) セクションに説明があるTLSを設定します。 `true` を設定した場合、TLSの証明書に関するファイルの格納先を指定する必要があります。なおRaftノードであれば、この設定項目は必須です。

* `BootstrapFile` --- オーダリングサービス向けに作成するジェネシスブロックの名称を設定します。

* `BootstrapMethod` --- ブートストラップブロックを提供する方法です。`BootstrapFile` に名称を設定した場合に、`file` を指定することが可能です。

複数のオーダリングノードを用いたクラスタ構成（例えば、Raftを用いた構成）で構築する場合、`Cluster` セクションと `Consensus` セクションを設定します。

Kafkaを用いたオーダリングサービスを構築する場合、`Kafka` セクションを設定します。

## Generate the genesis block of the orderer

チャネルを作成した際に生成される最初のブロックは、"ジェネシスブロック"と言われます。ジェネシスブロックは、**新しいネットワーク** （すなわち、作成されるオーダリングノードは既存のオーダリングノードのクラスタに参加していません。）の一部として生成され、システムチャネル（オーダリングノードシステムチャネルとも言われます。）の最初のブロックにもなります。システムチャネルは、オーダリングノード管理者によって管理され、チャネルの作成を許可する組織の情報を含むため、特別なチャネルです。*ノードが生成される前に作成され、ノードの設定情報に含まれるため、システムチャネルのジェネシスブロックは特別なブロックです。*

ジェネシスブロックを作成するツールである `configtxgen` については、[Channel Configuration (configtx)](configtx.html) セクションを参照してください。

## Bootstrap the ordering node

イメージをビルドし、MSPを作成し、`orderer.yaml` を設定し、ジェネシスブロックを作成することで、以下の様なコマンドを用いてオーダリングノードを立ち上げることができます。

```
docker-compose -f docker-compose-cli.yaml up -d --no-deps orderer.example.com
```

なお、`orderer.example.com` の箇所は、各自のordererのアドレスに変更してください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->