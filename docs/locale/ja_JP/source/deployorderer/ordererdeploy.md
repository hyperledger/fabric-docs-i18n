# Deploy the ordering service

オーダリングサービスをデプロイする前に、 [Planning for an ordering service](./ordererplan.html) と [Checklist for a production ordering service](./ordererchecklist.html) の資料を確認してください。この資料では、オーダリングサービスをデプロイする前に必要な決定事項や設定する必要があるパラメータについて説明しています。

このチュートリアルはRaft合意形成プロトコルに基づいており、オーダリングノードまたは "orderer" で構成されるオーダリングサービスをビルドするために使用することができます。すべてのオーダリングノードが同じ組織に所属するような3ノードRaftオーダリングサービスを作成するプロセスについて説明しています

## Download the ordering service binary and configuration files

まず初めに、Fabricのバイナリを [GitHub](https://github.com/hyperledger/fabric/releases) からローカルシステム上のフォルダ( `fabric/` など)にダウンロードします。GitHubで、ダウンロードしたいFabricリリースまでスクロールし、 **Assets** をクリックして、システムタイプに対応するバイナリを選択します。 `zip` ファイルを解凍すると、すべてのFabricバイナリが `/bin` フォルダに、関連する設定ファイルが `/config` フォルダにあります。
フォルダ構造は次のようになります。

```
├── fabric
  ├── bin
  │   ├── configtxgen
  │   ├── configtxlator
  │   ├── cryptogen
  │   ├── discover
  │   ├── idemixgen
  │   ├── orderer
  │   └── osnadmin
  └── config
    ├── configtx.yaml
    ├── orderer.yaml
    └── core.yaml
```

関連するバイナリファイルとともに、ネットワーク上でordererを起動するのにorderer設定ファイル `orderer.yaml` は必須です。他のファイルはordererのデプロイには必須ではありませんが、チャネルの作成や編集などの作業を行うときに役立ちます。

**ヒント:** ordererバイナリの場所を `PATH` 環境変数に追加して、バイナリの実行可能ファイルへのパスを完全に修飾せずに取得できるようにします。例えば、次のようなものです。

```
export PATH=<path to download location>/bin:$PATH
```

ordererファイルと `rderer.yaml` 設定ファイルを使用してオーダリングサービスのデプロイと実行をマスターした後は、KubernetesまたはDockerのデプロイでordererコンテナを使用したいと思うことが多いでしょう。Hyperledger Fabricプロジェクトは、開発やテストに使用できる [orderer image](https://hub.docker.com/r/hyperledger/fabric-orderer) を公開しており、さまざまなベンダーがサポートするordererイメージを提供しています。現時点では、このトピックの目的は、ordererバイナリを適切に使用する方法を提示することです。そうすれば、その知識を取得して、お好みの本番環境に適用できます。

## Prerequisites

本番ネットワークでordererを立ち上げる前に、必要な証明書を作成および整理し、ジェネシスブロックを生成し、ストレージを決定し、 `orderer.yaml` を設定したことを確認する必要があります。

### Certificates

**cryptogen** は、テスト環境の証明書を生成するために使用できる便利なユーティリティですが、本番ネットワークでは使用することは **ありません** 。Fabricノードの証明書の中核的な要件は、Elliptic Curve (EC)証明書であることです。これらの証明書を発行するために好きなツール(OpenSSLなど)を使用することができます。ただし、Fabric CAはメンバーシップサービスプロバイダ(MSPs)を生成するので、プロセスを合理化します。

ordererをデプロイするする前に、ordererまたはorderer証明書の推奨フォルダ構造を作成します。このフォルダ構造については、 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) のトピックで、生成された証明書とMSPsの保管方法について説明しています。

このフォルダ構造は必須ではありませんが、この手順では、作成済みであることを前提としています。

```
├── organizations
  └── ordererOrganizations
      └── ordererOrg1.example.com
          ├── msp
            ├── cacerts
            └── tlscacerts
          ├── orderers
              └── orderer0.ordererOrg1.example.com
                  ├── msp
                  └── tls
```

選択した認証局を使用して、orderer登録証明書、TLS証明書、秘密鍵、およびFabricが使用する必要があるMSPsを生成する必要があります。CAの作成方法およびこれらの証明書の生成方法については、 [CA deployment guide](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/cadeploy.html) や[Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) のトピックを参照してください。次の証明書セットを生成する必要があります。

  - **Orderer organization MSP**
  - **Orderer TLS CA certificates**
  - **Orderer local MSP (enrollment certificate and private key of the orderer)**

証明書を推奨のフォルダ構造に直接生成するには、Fabric CAクライアントを使用するか、または、生成された証明書を推奨のフォルダにコピーする必要があります。どちらの方法を選択した場合でも、ほとんどのユーザーが最終的にこのプロセスをスクリプト化する可能性が高いため、必要に応じて繰り返すことができます。証明書とその場所のリストは、便利なようにここに記載されています。

ネットワークを実行するためにコンテナ化されたソリューションを使用している場合(あきらかな理由として一般的な選択ですが)、 **ベストプラクティスは、ノード自体が実行されているコンテナの外部にある証明書ディレクトリのためのマウントボリュームです。これにより、オーダリングノードコンテナがダウンしたり、破損したり、再起動されたりしても、オーダリングノードコンテナによって証明書を使用できるようになります。**

#### TLS certificates

オーダリングノードが正常に起動するには、 [Checklist for a production ordering node](./ordererchecklist.html) で指定したTLS証明書の場所が正しい証明書を指している必要があります。そのためには、

  - デフォルトで `ca-cert.pem` と呼ばれる **TLS CA Root certificate** を、オーダリング組織のMSP定義 `organizations/ordererOrganizations/ordererOrg1.example.com/msp/tlscacerts/tls-cert.pem` にコピーします。
  - デフォルトで `ca-cert.pem` と呼ばれる **CA Root certificate** を、オーダリング組織のMSP定義 `organizations/ordererOrganizations/ordererOrg1.example.com/msp/cacerts/ca-cert.pem` にコピーします。
  - TLS CAでordererアイデンティティをエンロールすると、公開鍵は `signcerts` フォルダに生成され、秘密鍵は `keystore` ディレクトリに置かれます。 `keystore` フォルダ内の秘密鍵の名前を `orderer0-tls-key.pem` に変更し、後でこのノードのTLS秘密鍵として簡単に認識できるようにします。
  - ordererのTLS証明書と秘密鍵のファイルを `organizations/ordererOrganizations/ordererOrg1.example.com/orderers/orderer0.ordererOrg1.example.com/tls` にコピーします。証明書と秘密鍵のファイルのパスと名前は、 `orderer.yaml` の `General.TLS.Certificate` と `General.TLS.PrivateKey` のパラメータの値に対応しています。

**注:** `config.yaml` ファイルを作成し、各オーダリングノードのための組織MSPとローカルMSPのフォルダに追加することを忘れないでください。このファイルにより、MSPのノードOUサポートが有効になります。これは、アイデンティティ証明書の "admin" OUに基づいて、MSPの管理者を識別できるようにする重要な機能です。詳しくは、 [Fabric CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#nodeous) のドキュメントを参照してください。

ネットワークを実行するためにコンテナ化されたソリューションを使用している場合(あきらかな理由として一般的な選択ですが)、 **ベストプラクティスは、ノード自体が実行されているコンテナの外部にある証明書ディレクトリのためのマウントボリュームです。これにより、オーダリングノードコンテナがダウンしたり、破損したり、再起動されたりしても、オーダリングノードコンテナによって証明書を使用できるようになります。**

#### Orderer local MSP (enrollment certificate and private key)

同様に、MSPフォルダを `organizations/ordererOrganizations/ordererOrg1.example.com/orderers/orderer0.ordererOrg1.example.com/msp` にコピーすることで、  [local MSP of your orderer](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#create-the-local-msp-of-a-node) を提示する必要があります。このパスは、 `orderer.yaml` ファイルの `General.LocalMSPDir` パラメータの値に対応します。Fabricのコンセプトである ["Node Organization Unit (OU)"](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#nodeous) により、ブートストラップの場合、ordererの管理者を指定する必要はありません。代わりに、 "admin" の役割は、 `config.yaml` ファイルによって有効になっている証明書の内部に "admin" のOU値を設定することで、アイデンティティが付与されます。Node OUが有効になっている場合、この組織の管理者アイデンティティはordererを管理することができます。

ローカルのMSPには、署名付き証明書(公開鍵)とordererの秘密鍵が含まれていることに注意してください。秘密鍵は、トランザクションを署名するするノードによって使用されるため、共有されず、セキュリティで保護される必要があります。最大限のセキュリティを確保するために、ハードウェアセキュリティモジュール(HSM)を構成して、この秘密鍵を生成および保存することができます。

### Create the ordering service genesis block

Fabricネットワークで最初に作成されるチャネルは、「システム」チャネルです。システムチャネルは、オーダリングサービスを形成するオーダリングノードのセットと、オーダリングサービス管理者として機能する組織のセットを定義します。ピアは、「コンソーシアム」(オーダリングサービスとして知られるピア組織)を定義する、オーダリングサービス システムチャネルに由来するプライベートな「アプリケーション」チャネルで取引をします。そのため、オーダリングサービスをデプロイするする前に、 `configtxgen` というツールを使用してシステムチャネル「ジェネシスブロック」を作成し、システムチャネル設定を生成する必要があります。次に、生成されたシステムチャネル ジェネシスブロックを使用して、各オーダリングノードを起動します。

#### Set up the `configtxgen` tool

チャネル作成トランザクションファイルを手動でビルドすることは可能ですが、[configtxgen](../commands/configtxgen.html)  ツールを使用する方が簡単です。これは、チャネルの設定を定義する `configtx.yaml` ファイルを読み取ってから、関連する情報を「ジェネシスブロック」と呼ばれるコンフィギュレーションブロックに書き込むことで機能します。

`configtxgen` ツールがダウンロードしたFabricバイナリの `bin` フォルダにあることに注意してください。

`configtxgen` を使用する前に、 `FABRIC_CFG_PATH` 環境変数が `configtx.yaml` ファイルのローカルコピーが格納されているディレクトリのパスに設定されていることを確認します。 `configtxgen` ヘルプテキストを出力することで、このツールが使用できることを確認できます。

```
configtxgen --help
```

#### The `configtx.yaml` file

`configtx.yaml` ファイルは、システムチャネルの **channel configuration** とアプリケーションチャネルを指定するために使用されます。 `configtx.yaml` ファイルには、チャネル設定をビルドするために必須の情報が、読み取りおよび編集可能な形式で指定されています。 `configtxgen` ツールは、 `configtx.yaml` で定義されたチャネルプロファイルを使用して、 [protobuf format](https://developers.google.com/protocol-buffers) 内にチャネル設定ブロックを作成します。

`configtx.yaml` ファイルは、ダウンロードしたイメージとともに `config` フォルダにあり、新しいチャネルを作成するために必要な次の設定セクションが含まれています。

- **Organizations:** チャネルのメンバーになることができる組織。各組織は、 [channel MSP](../membership/membership.html) をビルドするために使用される暗号マテリアルへの参照を持っています。
- **Orderer:** どのオーダリングノードがチャネルのRaft同意者セットを形成するか。
- **Policies** ファイルのさまざまなセクションが連携してチャネルポリシーを定義し、組織がチャネルとやり取りする方法と、どの組織がチャネルの更新を承認する必要があるかを管理します。このチュートリアルでは、Fabricで使われているデフォルトを使用します。ポリシーの詳細については、 [Policies](../policies/policies.html) をご覧ください。
- **Profiles** 各チャネルプロファイルは、チャネル設定をビルドするするために、 `configtx.yaml` ファイルの他のセクションから情報を参照します。プロファイルは、チャネルのジェネシスブロックを作成するために使用されます。

`configtxgen` ツールは、 `configtx.yaml` ファイルを使用して、チャネル用のジェネシスブロックを作成します。 `configtx.yaml` ファイルの詳細なバージョンは、 [Fabric sample configuration](https://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/configtx.yaml) で入手できます。このファイルの設定の詳細については、 [Using configtx.yaml to build a channel configuration](../create_channel/create_channel_config.html) チュートリアルを参照してください。

#### Generate the system channel genesis block

Fabricネットワークで最初に作成されるチャネルは、システムチャネルです。システムチャネルは、オーダリングサービスを形成するオーダリングノードのセットと、オーダリングサービス管理者として機能する組織のセットを定義します。システムチャネルには、ブロックチェーン [consortium](../glossary.html#consortium) のメンバーである組織も含まれます。コンソーシアムは、システムチャネルに属するピア組織のセットですが、オーダリングサービスの管理者ではありません。コンソーシアムメンバーは、新しいチャネルを作成し、他のコンソーシアム組織をチャネルメンバーに含めることができます。

システムチャネルのジェネシスブロックは、新しいオーダリングサービスをデプロイすることが要求されます。システムチャネルプロファイルの良い例は、以下に示すように `TwoOrgsOrdererGenesis` プロファイルを含む [test network configtx.yaml](https://github.com/hyperledger/fabric-samples/blob/master/test-network/configtx/configtx.yaml#L319) にあります。

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

プロファイルの `Orderer:` セクションは、 `OrdererOrg` をオーダリングサービス管理者として、Raftオーダリングサービスを定義しています。プロファイルの `Consortiums` セクションは、 `SampleConsortium:` という名前のピア組織のコンソーシアムを作成します。本番環境では、ピアノードとオーダリングノードは別々の組織に属するようにすることを推奨します。この例では、ピア組織として `Org1` と `Org2` を使用します。このセクションをカスタマイズするには、コンソーシアム名を指定し、`Org1` と `Org2` をピア組織の名前に置き換えてください。もし、コンソーシアム名が不明な場合は、 `Consortiums.SampleConsortium.Organizations` の下に組織をリストアップする必要はありません。ここでピア組織を追加しておくと、後でチャンネル設定の更新をする手間が省けます。もしそれらを追加する場合は、 `configtx.yaml` ファイルの先頭にある `Organizations:` セクションで、ピア組織を定義することも忘れないでください。このプロファイルには、 `Application:` セクションがないことに注意してください。オーダリングサービスをデプロイした後に、アプリケーションチャンネルを作成する必要があります。

ネットワークに参加するordererとピア組織を反映するための `configtx.yaml` の編集が完了したら、以下のコマンドを実行してシステムチャネルのジェネシスブロックを作成します。
```
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block
```

Where:

  - `-profile` は、 `configtx.yaml`の `TwoOrgsOrdererGenesis` プロファイルを参照します。
  - `-channelID` は、システムチャネルの名前です。このチュートリアルでは、システムチャネルは `system-channel` という名前がついています。
  - `-outputBlock` は、作成されたジェネシスブロックの場所を参照します。

コマンドが成功すると、 `configtxgen` が `configtx.yaml` ファイルをロードし、チャネル作成トランザクションを表示するログを確認します。
```
INFO 001 Loading configuration
INFO 002 Loaded configuration: /Usrs/fabric-samples/test-network/configtx/configtx.yaml
INFO 003 Generating new channel configtx
INFO 004 Generating genesis block
INFO 005 Creating system channel genesis block
INFO 006 Writing genesis block
```

作成された出力ブロックのファイル名をメモしておいてください。これはあなたのジェネシスブロックで、以下の `orderer.yaml` ファイルで参照されます。

### Storage

台帳のための永続的なストレージをプロビジョニングする必要があります。デフォルトでは、台帳は `/var/hyperledger/production/orderer` に置かれます。ordererがこのフォルダーへの書き込み権限を持っていることを確認してください。別の場所を使いたい場合は、 `orderer.yaml` ファイルの `FileLedger:` パラメーターにそのパスを指定してください。Kubernetes や Docker を使用する場合、コンテナ環境ではコンテナが移動するとローカルストレージが消滅するため、ordererをデプロイする前に、台帳用の永続ストレージをプロビジョンまたはマウントする必要があることを思い出してください。

### Configuration of `orderer.yaml`

これで、 [Checklist for a production orderer](./ordererchecklist.html) を使って `orderer.yaml` ファイル内のデフォルト設定を変更することができます。将来的に、Kubernetes や Docker を使ってordererをデプロイすることになった場合、代わりに環境変数を使って同じデフォルト設定を上書きすることができます。上書きするための環境変数名の作成方法については、デプロイメントガイドの概要にある [note](../deployment_guide_overview.html #step-five-deploy-orderrers-and-ordering-nodes) を確認してください。

最低限、以下のパラメータを設定する必要があります。
  - `General.ListenAddress` - オーダリングノードがListenするホスト名
  - `General.ListenPort` - オーダリングノードがListenするポート
  - `General.TLS.Enabled: true` - Server-side TLS は、すべての本番ネットワークで有効にする必要があります。
  - `General.TLS.PrivateKey ` - TLS CAによるオーダリングノードの秘密鍵
  - `General.TLS.Certificate ` - TLS CAによるオーダリングノードの署名された証明書（公開鍵）
  - `General.TLS.RootCAS` - この値は定義しないこと
  - `General.BoostrapMethod:file` - システムチャネルでのオーダリングサービスの開始
  - `General.BootstrapFile` - オーダリングサービスのシステムチャネル向けのジェネシスブロックのパスと名前
  - `General.LocalMSPDir` - オーダリングノードのMSPフォルダーへのパス
  - `General.LocalMSPID` - チャネル設定で指定されたオーダリング組織のMSP ID
  - `FileLedger.Location` - ファイルシステムでのorderer台帳の場所

このチュートリアルでは、ordererのブートストラップ時にシステムチャネルのジェネシスブロックを使用しないことを前提としているため、 `osnadmin` コマンドでアプリケーションチャネルを作成する場合は、次の追加パラメータが必要です。

  - `Admin.ListenAddress` - オーダリングサービスのチャネルを設定するために、 `osnadmin` コマンドで使用できるorderer管理サーバーアドレス（ホストとポート）。この値は、衝突を避けるために `host:port` の組み合わせである必要があります。
  - `Admin.TLS.Enabled:` - 技術的には `false` にすることもできますが、それはお勧めしません。一般的に、常に `true` に設定しておく必要があります。
  - `Admin.TLS.PrivateKey:` - TLS CAによって発行されたordererプライベートキーのパスとファイル名。
  - `Admin.TLS.Certificate:` - TLS CAによって発行された証明書にサインしたordererのパスとファイル名。
  - `Admin.TLS.ClientAuthRequired:` この値は `true` に設定する必要があります。 orderer Adminのエンドポイントではすべての運用に相互TLSが必要ですが、ネットワーク全体では相互TLSは必要ありません。
  - `Admin.TLS.ClientRootCAs:` - 管理クライアントTLS CA Root証明書のパスとファイル名。上記のフォルダ構造では、 `admin-client/client-tls-ca-cert.pem` のことを指します。

## Start the orderer

ordererバイナリを起動した場所に関連して、 `orderer.yaml` ファイルがあるところに `FABRIC_CFG_PATH` の値が設定されていることを確認してください。例えば、 `fabric/bin` フォルダからordererバイナリを実行した場合は、 `/config` フォルダを指します。
```
export FABRIC_CFG_PATH=../config
```

`orderer.yaml` が設定され、バックエンドのデプロイが準備できたら、次のコマンドで簡単にordererノードを起動することができます。

```
cd bin
./orderer start
```

ordererが正常に起動すると、次のようなメッセージが確認できます。

```
INFO 019 Starting orderer:
INFO 01a Beginning to serve requests
```

1つのノードが正常に起動したので、これらの設定を繰り返して残りの2つのordererを起動します。過半数のordererが起動すると、Raftリーダーが選出されます。次のような出力が表示されるはずです。
```
INFO 01b Applied config change to add node 1, current nodes in channel: [1] channel=syschannel node=1
INFO 01c Applied config change to add node 2, current nodes in channel: [1 2] channel=syschannel node=1
INFO 01d Applied config change to add node 3, current nodes in channel: [1 2 3] channel=syschannel node=1
INFO 01e raft.node: 1 elected leader 2 at term 11 channel=syschannel node=1
INFO 01f Raft leader changed: 0 -> 2 channel=syschannel node=1
```

## Next steps

オーダリングサービスが起動し、ブロック内のオーダートランザクションの準備ができました。場合によっては、同意者セットからordererを追加または削除する必要があったり、他の組織は、自身のordererをクラスタに提供したいと思うかもしれません。検討事項や手順に関しては、オーダリングサービスの [reconfiguration](../raft_configuration.html#reconfiguration) のトピックを参照してください。

最後に、システムチャネルは、チャネル設定の `Organization` セクションで定義されているようなピア組織のコンソーシアムを含みます。このピア組織のリストによって、オーダリングサービスでチャネルを作成することを許可します。アプリケーションチャネルを作成するために、 `configtxgen` コマンドと `configtx.yaml` ファイルを使う必要があります。詳細は、 [Creating a channel](../create_channel/create_channel.html#creating-an-application-channel) チュートリアルを参照してください。

## Troubleshooting

### ordererを起動した際、次のエラーで失敗する。
```
ERRO 001 failed to parse config:  Error reading configuration: Unsupported Config Type ""
```

**解決策**  

`FABRIC_CFG_PATH` が設定されていません。次のコマンドを実行し、 `orderer.yaml` のある場所にそれを設定してください。

```
export FABRIC_CFG_PATH=<PATH_TO_ORDERER_YAML>
```

### ordererを起動した際、次のエラーで失敗する。
```
PANI 003 Failed to setup local msp with config: administrators must be declared when no admin ou classification is set
```

**解決策**   

ローカルMSPの定義に `config.yaml` ファイルがありません。ファイルを作成し、ordererのローカルMSP `/msp` フォルダへコピーします。さらに詳しい手順は [Fabric CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#nodeous) ドキュメントを参照してください。


### ordererを起動した際、次のエラーで失敗する。
```
PANI 005 Failed validating bootstrap block: initializing channelconfig failed: could not create channel Orderer sub-group config: setting up the MSP manager failed: administrators must be declared when no admin ou classification is set
```

**解決策**   

システムチャネルの設定に missing `config.yaml` ファイルがありません。新しいオーダリングサービスを作成したら、 `configtx.yaml` ファイルで参照される `MSPDir` が、 `config.yaml` ファイルにないことがあります。 [Fabric CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#nodeous) ドキュメントにある指示に従ってこのファイルを作成し、システムチャネルのジェネシスブロックを再作成するために `configtxgen` を再度実行してください。
```
# MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: ../config/organizations/ordererOrganizations/ordererOrg1.example.com/msp
```
ordererを再起動する前に、 `orderer.yaml` ファイルの `FileLedger.Location` セッティングに保存されている既存のチャネル台帳ファイルを削除してください。


### ordererを起動した際、次のエラーで失敗する。
```
PANI 004 Failed validating bootstrap block: the block isn't a system channel block because it lacks ConsortiumsConfig
```

**解決策**   

チャネル設定に、コンソーシアム定義がありません。新しいオーダリングサービスを起動すると、 `configtx.yaml` ファイルの `Profiles:` セクションを編集し、コンソーシアム定義を追加されます。
```
Consortiums:
            SampleConsortium:
                Organizations:
```
`Consortiums:` セクションは必要ですが、ピア組織がわからない場合は上記のように空でもかまいません。 `configtxgen` を際実行して、システムチャネルのジェネシスブロックを作成し、ordererを起動する前に、 `orderer.yaml` ファイルの `FileLedger.Location` 設定に保存されている既存のチャネル台帳ファイルを削除してください。

### ordererを起動した際、次のエラーで失敗する。
```
PANI 27c Failed creating a block puller: client certificate isn't in PEM format:  channel=mychannel node=3
```

**解決策**   

`orderer.yaml` ファイルに `General.Cluster.ClientCertificate` と `General.Cluster.ClientPrivateKey` の定義がありません。これら2つの項目に、ordererに対してTLS CAが作成した公開証明書（または署名入り証明書）のパスおよびファイル名と秘密鍵を入力し、ノードを再起動してください。

### ordererを起動した際、次のエラーで失敗する。
```
ServerHandshake -> ERRO 025 TLS handshake failed with error remote error: tls: bad certificate server=Orderer remoteaddress=192.168.1.134:52413
```

**解決策**   

このエラーは、 `tlscacerts` フォルダが、チャネル設定に指定されたorderer組織のMSPフォルダからなくなった場合に起こります。MSP定義内に `tlscacerts` フォルダを作成し、TLS CA( `ca-cert.pem` )からのroot証明書を挿入してください。 `configtxgen` を再実行して、システムチャネル用の ジェネシスブロックを再生成し、チャネル設定にこの証明書が含まれるようにします。ordererを再度起動する前に、 `orderer.yaml` ファイルの `FileLedger.Location` 設定に保存されている既存のチャネル台帳ファイルを削除してください。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
