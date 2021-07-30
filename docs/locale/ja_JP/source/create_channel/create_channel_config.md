# Using configtx.yaml to build a channel configuration

チャネルは、チャネルの初期設定を指定するチャネル作成トランザクションアーティファクトをビルドすることによって作成されます。チャネル設定( **channel configuration** )は台帳に格納され、チャネルに追加されるすべての後続のブロックを管理します。チャネル設定は、どの組織がチャネルメンバーであるか、新しいブロックを追加できるオーダリングノード、チャネルの更新を管理するポリシーなどを指定します。ジェネシスブロックに格納されている初期チャネル設定は、チャネル設定の更新によって更新することができます。十分な数の組織がチャネル更新を承認すると、新しいチャネル設定ブロックはチャネルにコミットされた後に、チャネルを管理するようになります。

チャネル作成トランザクションファイルを手動でビルドすることは可能ですが、 `configtx.yaml` ファイルと [configtxgen](../commands/configtxgen.html) ツールを使用してチャネルを作成する方が簡単です。 `configtx.yaml` ファイルには、チャネル設定をビルドするために必要とされる情報が、人間が簡単に読み込み編集できる形式で記述されています。 `configtxgen` ツールは、 `configtx.yaml` ファイル内の情報を読み取り、Fabricが読めるプロトコルバッファフォーマット [protobuf format](https://developers.google.com/protocol-buffers) に書き込みます。

## Overview

このチュートリアルを使用して、ジェネシスブロックに格納されている初期チャネル設定をビルドするするための `configtx.yaml` ファイルの使用方法を学習することができます。チュートリアルでは、ファイルの各セクションによってビルドされるチャネル設定の部分について説明します。

- [Organizations](#organizations)
- [Capabilities](#capabilities)
- [Application](#application)
- [Orderer](#orderer)
- [Channel](#channel)
- [Profiles](#profiles)

ファイルのさまざまなセクションが連携して、チャネルを管理するためのポリシーが作成されるため、チャネルポリシーについては [チュートリアルごと](channel_policies.html) に説明します。

[Creating a channel tutorial](create_channel.html) のビルドでは、例としてFabricテストネットワークをデプロイするに使用される `configtx.yaml` ファイルを使用します。ローカルマシンのコマンドターミナルを開き、Fabricサンプルのローカルクローンにある `test-network` ディレクトリに移動します。:

```
cd fabric-samples/test-network
```

テストネットワークが使用する `configtx.yaml` ファイルは、 `configtx` フォルダにあります。ファイルをテキストエディタで開きます。チュートリアルで各セクションを進む際に、このファイルを参照することができます。Fabricサンプル設定 [Fabric sample configuration](https://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/configtx.yaml) に詳細なバージョンの `configtx.yaml` ファイルがあります。

## Organizations

チャネル設定に含まれる最も重要な情報は、チャネルメンバである組織です。各組織は、MSP IDとチャネルMSP  [channel MSP](../membership/membership.html) によって識別されます。チャネルMSPはチャネル設定に格納され、組織のノード、アプリケーション、および管理者を識別する際に使用する証明書が含まれます。 `configtx.yaml` ファイルの **Organizations** セクションは、チャネルの各メンバーのチャネルMSPと付随するMSP IDを作成するために使用されます。

テストネットワークによって使用される `configtx.yaml` ファイルには、3つの組織が含まれています。2つは、アプリケーションチャネルに追加することができるOrg1およびOrg2のピア組織です。あと1つは、OrdererOrgというオーダリングサービスの管理者の組織です。ピアノードとオーダリングノードをデプロイするのに別の認証局を使用することがベストプラクティスであるため、実際には同じ企業が運用していても、組織はピア組織またはオーダリング組織として参照されます。

テストネットワークのOrg1を定義する `configtx.yaml` の部分を次に示します。:

  ```yaml
  - &Org1
      # DefaultOrg defines the organization which is used in the sampleconfig
      # of the fabric.git development environment
      Name: Org1MSP

      # ID to load the MSP definition as
      ID: Org1MSP

      MSPDir: ../organizations/peerOrganizations/org1.example.com/msp

      # Policies defines the set of policies at this level of the config tree
      # For organization policies, their canonical path is usually
      #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
      Policies:
          Readers:
              Type: Signature
              Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
          Writers:
              Type: Signature
              Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
          Admins:
              Type: Signature
              Rule: "OR('Org1MSP.admin')"
          Endorsement:
              Type: Signature
              Rule: "OR('Org1MSP.peer')"
  ```  

  - `Name` フィールドは、組織を識別するのに使用される非公式の名前です。

  - `ID` フィールドは組織のMSP IDです。MSP IDは、組織のユニークな識別子として機能し、チャネルポリシーによって参照され、チャネルに送信されるトランザクションに含まれます。

  - `MSPDir` は組織によって作られたMSPフォルダへのパスです。 `configtxgen` ツールは、チャネルMSPを作成するためにこのMSPフォルダを使用します。このMSPフォルダには次の情報を含める必要があります。そしてそれらはチャネルMSPに転送され、チャネル設定に格納されます。:
    - 組織への信頼のルートを設定するCAルート証明書。CAルート証明書は、アプリケーション、ノード、または管理者がチャネルメンバーに属しているかどうかを確認するために使用されます。
    - ピアまたはオーダリングノードのTLS証明書を発行したTLS CAからのルート証明書。TLSルート証明書は、ゴシッププロトコルによって組織を識別するするために使用されます。
    - Node OUが有効になっている場合、MSPフォルダは、x509証明書のOUに基づいた管理者、ノード、およびクライアントを識別する `config.yaml` ファイルを含む必要があります。
    - Node OUが有効になっていない場合、MSPには、組織管理者のアイデンティティの署名証明書を含むadmincertsフォルダを含める必要があります。

    チャネルMSPの作成に使用されるMSPフォルダには、公開証明書のみが含まれます。その結果、MSPフォルダをローカルにビルドし、チャネルを作成している組織にMSPを送信することができます。

  - `Policy` セクションは、チャネルメンバを参照するSignatureポリシーのセットを定義するために使用されます。 [channel policies](channel_policies.html) について説明するときに、これらのポリシーについて詳しく説明します。

## Capabilities

Fabricチャネルは、Hyperledger Fabricの異なるバージョンを実行しているordererとピアノードを追加させることができます。チャネルケイパビリティは、特定の機能のみを有効にすることによって、異なるFabricバイナリを実行している組織を同じチャネルに参加するのを許可します。たとえば、Fabric v1.4を実行している組織とFabric v2.xを実行している組織は、チャネルケイパビリティレベルがV1_4_X以下に設定されている限り、同じチャネルに参加できます。どのチャネルメンバーもFabric v2.0で導入された機能は使用できません。

`configtx.yaml` ファイルを調べると、次の3つのケーパビリティグループがあります。:

- **Application** ケーパビリティは、Fabricチェーンコードライフサイクルなどのようなピアノードによって使用される機能を管理し、チャネルに接続されたピアによって実行可能なFabricバイナリの最小バージョンを設定します。

- **Orderer** ケーパビリティは、Raft合意形成などのようなオーダリングノードで使用される機能を管理し、チャネル同意者セットに属するオーダリングノードで実行可能なFabricバイナリの最小バージョンを設定します。

- **Channel** ケーパビリティは、ピアとオーダリングノードが実行できるFabricの最小バージョンを設定します。

Fabricテストネットワークのピアとオーダリングノードの両方がバージョンv2.xを実行するため、すべてのケーパビリティグループは `v2_0` に設定されます。結果として、テストネットワークは、v2.0よりも低いFabricのバージョンを実行するノードが参加することができません。詳細については、 [capabilities](./capabilities_concept.html) コンセプトトピックを参照してください。

## Application

アプリケーションセクションでは、ピア組織がアプリケーションチャネルとどのようにやりとりすることができるかを管理するポリシーを定義しています。これらのポリシーは、チェーンコード定義を承認するのに必要なピア組織の数、またはチャネル設定の更新に署名する必要のあるピア組織の数を管理します。これらのポリシーは、チャネル台帳への書き込みまたはチャネルイベントのクエリのような、チャネルリソースへのアクセスを制限するためにも使用されます。

テストネットワークはHyperledger Fabricが提供するデフォルトアプリケーションポリシーを利用しています。デフォルトポリシーを使用する場合、すべてのピア組織は台帳のデータを読み書きすることができます。また、デフォルトポリシーでは、チャネルメンバーの過半数がチャネル設定の更新を署名し、チェーンコードがチャネルにデプロイされる前にチャネルメンバーの過半数がチェーンコード定義を承認することが必要です。このセクションの内容については、 [channel policies](channel_policies.html) チュートリアルで詳しく説明しています。

## Orderer

各チャネル設定には、チャネル [同意者セット](../glossary.html#consenter-set) のオーダリングノードが含まれます。同意者セットは、新しいブロックを作成し、それをチャネルに参加しているピアへ配布する能力を持つオーダリングノードのグループです。同意者セットのメンバーである各オーダリングノードのエンドポイント情報は、チャネル設定に格納されます。

テストネットワークは `configtx.yaml` ファイルの **Orderer** セクションを使用して、単一ノードRaftオーダリングサービスを作成します。

-`OrdererType` フィールドは、合意形成タイプとしてRaftを選択するために使用されます。:

  ```
  OrdererType: etcdraft
  ```

  Raftオーダリングサービスは、合意形成プロセスに参加できる同意者のリストによって定義されます。テストネットワークはオーダリングノードを1つだけ使用するので、同意者リストはエンドポイントを1つだけ含みます。:

  ```yaml
  EtcdRaft:
      Consenters:
      - Host: orderer.example.com
        Port: 7050
        ClientTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
        ServerTLSCert: ../organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
      Addresses:
      - orderer.example.com:7050
  ```

  同意者リストの各オーダリングノードは、エンドポイントのアドレスとクライアントおよびサーバーのTLS証明書によって識別されます。マルチノードオーダリングサービスをデプロイする場合は、ホスト名、ポート、および各ノードで使用されるTLS証明書へのパスを指定する必要があります。また、各オーダリングノードのエンドポイントアドレスを `Addresses` のリストに追加する必要があります。

- `BatchTimeout` フィールドと `BatchSize` フィールドを使用して、各ブロックの最大サイズと新しいブロックが作成される頻度を変更することにより、チャネルのレイテンシとスループットを調整できます。

- `Policies` セクションは、チャネル同意者セットを管理するポリシーを作成します。テストネットワークは、Fabricによって提供されたデフォルトポリシーを使用します。このポリシーでは、orderer管理者の過半数が、オーダリングノードや組織の追加や削除、またはブロック作成パラメータに対する更新について、承認する必要があります。

テストネットワークは開発とテストに使用されるため、単一のオーダリングノードで構成されるオーダリングサービスを使用します。本番でデプロイされるネットワークは、セキュリティと可用性のためにマルチノードオーダリングサービスを使用する必要があります。詳細については、 [Configuring and operating a Raft ordering service](../raft_configuration.html) を参照してください。

## Channel

チャネルセクションでは、チャネル設定の最高レベルを管理するポリシーを定義しています。アプリケーションチャネルの場合、これらのポリシーはハッシュ・アルゴリズム、新しいブロックの作成に使用されるデータ・ハッシュ構造、およびチャネルケイパビリティレベルを管理します。システム・チャネルでは、これらのポリシーはピア組織のコンソーシアムの作成または削除も管理します。

テストネットワークは、Fabricによって提供されるデフォルトポリシーを使用します。このポリシーでは、過半数のordererのサービス管理者が、システムチャネル内のこれらの値の更新について承認する必要があります。アプリケーションチャネルでは、変更はorderer組織の過半数とチャネルメンバーの過半数によって承認される必要があります。ほとんどのユーザは、これらの値を変更する必要はありません。

## Profiles

`configtxgen` ツールは、 **Profiles** セクションのチャネルプロファイルを読み取って、チャネル設定をビルドします。各プロファイルはYAML構文を使用して、ファイルの他のセクションからデータを収集します。 `configtxgen` ツールはこの設定を使用して、アプリケーションチャネルに対してチャネル作成トランザクションを作成したり、システムチャネルに対してチャネルジェネシスブロックを書き込みます。YAML構文についてさらに学ぶために、最初は [Wikipedia](https://en.wikipedia.org/wiki/YAML) を参考にするのがいいでしょう。

テストネットワークで使用される `configtx.yaml` には、 `TwoOrgsOrdererGenesis` と `TwoOrgsChannel` という2つのチャネルプロファイルが含まれています。:

### TwoOrgsOrdererGenesis

`TwoOrgOrdererGenesis` プロファイルは、システムチャネルジェネシスブロックを作成するために使用されます。:

```yaml
TwoOrgsOrdererGenesis:
    <<: *ChannelDefaults
    Orderer:
        <<: *OrdererDefaults
        Organizations:
            - *OrdererOrg
        Capabilities:
            <<: *OrdererCapabilities
    Consortiums:
        SampleConsortium:
            Organizations:
                - *Org1
                - *Org2
```

システムチャネルは、オーダリングサービスのノードと、オーダリングサービス管理者である組織のセットを定義します。システムチャネルには、ブロックチェーンコンソーシアム [consortium](../glossary.html#consortium) に属するピア組織セットも含まれます。コンソーシアムの各メンバーのチャネルMSPはシステムチャネルに含まれているため、新しいアプリケーションチャネルを作成し、新しいチャネルにコンソーシアムメンバーを追加することができます。

プロファイルは、 `configtx.yaml` ファイル内の2つのピア組織(Org1とOrg2)を含む `SampleConsortium` という名前のコンソーシアムを作成します。プロファイルの `Orderer` セクションは、ファイルの **Orderer:** セクションで定義された単一ノードRaftオーダリングサービスを使用します。 **Organizations:** セクションのOrdererOrgは、オーダリングサービスの唯一の管理者となります。唯一のオーダリングノードがFabric 2.xを運用しているため、ordererシステムチャネルケーパビリティを `V2_0` に設定することができます。システムチャネルは、 **Channel** セクションのデフォルトポリシーを使用し、チャネルケーパビリティレベルとして `V2_0` を有効にします。

### TwoOrgsChannel

`TwoOrgsChannel` プロファイルは、アプリケーションチャネルを作成するためにテストネットワークによって使用されます。:

```yaml
TwoOrgsChannel:
    Consortium: SampleConsortium
    <<: *ChannelDefaults
    Application:
        <<: *ApplicationDefaults
        Organizations:
            - *Org1
            - *Org2
        Capabilities:
            <<: *ApplicationCapabilities
```

システムチャネルは、オーダリングサービスによってアプリケーションチャネルを作成するためのテンプレートとして使用されます。システムチャネルで定義されたオーダリングサービスのノードは、新しいチャネルのデフォルト同意者セットになり、オーダリングサービスの管理者は、チャネルのorderer管理者になります。チャネルメンバのチャネルMSPは、システムチャネルから新しいチャネルに転送されます。チャネルが作成された後、チャネル設定を更新することによって、オーダリングノードを追加したりチャネルから削除したりすることができます。 [他の組織をチャネルメンバーとして追加](../channel_update_tutorial.html) するために、チャネル設定を更新することもできます。

`TwoOrgsChannel` は、テストネットワークシステムチャネルがホストする `SampleConsortium` というコンソーシアムの名前を提供しています。その結果、 `TwoOrgsOrdererGenesis` プロファイルで定義されたオーダリングサービスはチャネル同意者セットとなります。 `Application` セクションでは、両方のコンソーシアムの組織(Org1とOrg2)がチャネルメンバーとして含まれます。チャネルは `V2_0` をアプリケーションケーパビリティとして使用し、ピア組織がチャネルとどのようにやりとりするかを管理するために、 **Application** セクションのデフォルトポリシーを使用します。また、アプリケーションチャネルは **Channel** セクションのデフォルトポリシーを使用し、チャネルケーパビリティレベルとして `V2_0` を有効にします。
