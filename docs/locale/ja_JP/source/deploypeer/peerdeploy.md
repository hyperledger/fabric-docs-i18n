# Deploy the peer

ピアをデプロイする前に、 [Planning for a peer](./peerplan.html) と [Checklist for a production peer](./peerchecklist.html) の資料を必ず消化してください。この資料では、ピアをデプロイする前に設定する必要のあるすべての関連する決定事項とパラメータについて説明しています。

注: ピアがチャネルに参加するには、ピアが属する組織がチャネルに参加している必要があります。つまり、 [組織のMSPを作成すること](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#create-the-org-msp-needed-to-add-an-org-to-a-channel) が必要です。この組織のMSP IDは、 `core.yaml` の `peer.localMspId` で指定されたIDと同じである必要があります。

## Download the peer binary and configuration files

Fabricピアバイナリおよび設定ファイルは、 [GitHub](https://github.com/hyperledger/fabric/releases) からローカルシステム上のフォルダ(例えば、 `fabric/` など)にダウンロードできます。ダウンロードするFabricリリースまでスクロールし、 **Assets** のツイスティをクリックして、システムタイプに応じたバイナリを選択します。ZIPファイルを解凍すると、すべてのFabricバイナリが `/bin` フォルダに、関連する設定ファイルが `/config` フォルダにあります。結果として得られるフォルダ構造は次のようになります。

```
├── fabric
  ├── bin
  │   ├── configtxgen
  │   ├── configtxlator
  │   ├── cryptogen
  │   ├── discover
  │   ├── idemixgen
  │   ├── orderer
  │   └── peer
  └── config
    ├── configtx.yaml
    ├── core.yaml
    └── orderer.yaml
```

関連するバイナリとともに、ピアバイナリ実行可能ファイルとピア設定ファイル `core.yaml` の両方を受け取ります。これは、ネットワーク上でピアを起動するのに必須です。他のファイルはピアのデプロイに必須ではありませんが、タスク間でチャネルを作成または編集するときなどに役立ちます。

**Tip:** ピアバイナリの場所を `PATH` 環境変数に追加して、バイナリの実行可能ファイルへのパスを完全に修飾せずに取得できるようにします。次に例を示します。

```
export PATH=<path to download location>/bin:$PATH
```

ピアバイナリとcore.yaml設定ファイルを使用してピアのデプロイと実行をマスターした後、KubernetesまたはDockerのデプロイでピアコンテナを使用することになる可能性があります。Hyperledger Fabricプロジェクトは開発とテストに使用できる [peer image](https://hub.docker.com/r/hyperledger/fabric-peer) を公開しており、様々なベンダーはサポートされているピアイメージを提供しています。しかし今のところ、このトピックの目的は、ピアバイナリを適切に使用する方法を伝えることであり、その知識を使用して選択した本番環境に適用できます。

## Prerequisites

ピアノードで本番ネットワークを立ち上げる前に、必要な証明書を作成して整理し、ストレージを決定し、 `core.yaml` を設定したことを確認する必要があります。

### Certificates

注: **cryptogen** はテストネットワークの証明書を生成するために使用できる便利なユーティリティですが、本番ネットワークで使用することは **できません** 。Fabricノードの証明書の主要な要件は、それらがElliptic Curve (EC)証明書であることです。これらの証明書を取得するために任意のツール(OpenSSLなど)を使用できます。ただし、Fabric CAはメンバーシップサービスプロバイダ(MSP)を生成するため、プロセスを合理化します。

ピアをデプロイするする前に、 [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) トピックで説明されているピア証明書の推奨フォルダ構造を作成して、生成された証明書とMSPを格納します。

このフォルダ構造は必須ではありませんが、次の手順では作成済みであることを前提としています。
```
├── organizations
  └── peerOrganizations
      └── org1.example.com
          ├── msp
          └── peers
              └── peer0.org1.example.com
                  ├── msp
                  └── tls
```

すでに選択した認証局を使用して、ピア登録証明書、TLS証明書、秘密鍵、およびFabricが消費する必要のあるMSPを生成する必要があります。Fabric CAの作成方法およびこれらの証明書の生成方法については、 [CA deployment](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/cadeploy.html) および [Registering and enrolling identities with a CA](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html) のトピックを参照してください。次の一連の証明書を生成する必要があります。
  - **Peer TLS CA certificates**
  - **Peer local MSP (ピアの登録証明書と秘密鍵)**

Fabric CAクライアントを使用して証明書を推奨フォルダ構造に直接生成するか、生成された証明書を生成後に推奨フォルダにコピーする必要があります。どちらの方法を選択しても、ほとんどのユーザーは最終的にこのプロセスをスクリプト化する可能性が高いため、必要に応じて繰り返し実行できます。証明書のリストとその場所は、便宜上ここに記載しています。

#### TLS certificates

ピアが正常に起動するために、 [Checklist for a production peer](./peerchecklist.html) で指定したTLS証明書の場所が正しい証明書を指していることを確認します。これを行うには、次のことに注意してください。

- 署名鍵(秘密鍵)証明書に関連付けられた公開鍵を含むTLS証明書(デフォルトでは `ca-cert.pem` と呼ばれます)を、 `organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/tls-cert.pem` にコピーします。証明書のパスと名前は、 `core.yaml` の `peer.tls.rootcert.file` パラメータに対応します。
- ピアTLS証明書を生成した後、証明書は `signcerts` ディレクトリに生成され、秘密鍵は `keystore` ディレクトリに生成されます。 `keystore` フォルダに生成された秘密鍵の名前を `peer0-key.pem` に変更して、後で秘密鍵として簡単に認識できるようにします。
- ピアTLS証明書と秘密鍵を `organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls` にコピーします。証明書と秘密鍵のファイルのパスと名前は、 `core.yaml` の `peer.tls.cert.file` と `peer.tls.key.file` のパラメータに対応します。
- 相互認証を使用する場合( `clientAuthRequired` がtrueに設定されている場合)、クライアントを認証するために使用するTLS CAルート証明書をピアに示す必要があります。組織のTLS CAルート証明書 `ca-cert.pem` を `organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca-cert.pem` にコピーして、組織のクライアントが認証されるようにします。証明書のパスと名前は、 `core.yaml` の `peer.tls.clientRootCAs.files` パラメータに対応します。ピアと通信するクライアント組織ごとに、複数のファイルを設定できることに注意してください(例えば、他の組織がこのピアをエンドースメントに使用する場合)。 `clientAuthRequired` がfalseに設定されている場合は、この手順をスキップできます。

#### Peer local MSP (enrollment certificate and private key)

同様に、 [local MSP of your node](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#create-the-local-msp-of-a-node) を `organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp` にコピーして指定する必要があります。このパスは、 `core.yaml` ファイル内の `peer.mspConfigPath` パラメータの値に対応します。 ["Node Organization Unit (OU)"](https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/deployguide/use_CA.html#nodeous) というFabricの概念のため、ブートストラップ時にピアの管理者を指定する必要はありません。むしろ"admin"ロールは、証明書の内部に"admin"のOU値を設定することでアイデンティティを付与され、 `config.yaml` ファイルで有効になります。Node OUが有効になっているの場合、組織のadminは誰でもピアを管理できます。

ローカルMSPには、署名された証明書(公開鍵)とピアの秘密鍵が含まれていることに注意してください。秘密鍵は、ノードがトランザクションに署名するために使用するため、共有せず、保護する必要があります。セキュリティを最大に高めるために、ハードウェアセキュリティモジュール(HSM)を設定して、この秘密鍵を生成および保存できます。

### Storage

台帳の永続ストレージをプロビジョニングする必要があります。外部のチェーンコードビルダーとランチャーを使用していない場合は、ストレージも考慮に入れる必要があります。台帳のデフォルトの場所は `/var/hyperledger/production` にあります。ピアがフォルダへの書き込みアクセス権を持っていることを確認してください。別の場所を使用する場合は、 `core.yaml` ファイルの `peer.fileSystemPath` パラメータにそのパスを指定します。KubernetesまたはDockerを使用することにした場合、コンテナ化された環境では、コンテナがなくなるとローカルストレージが消失するため、ピアをデプロイするする前に、台帳の永続ストレージをプロビジョニングまたはマウントするする必要があります。

### Configuration of `core.yaml`

ここで、 [本番のピアのためのチェックリスト](./peerchecklist.html) を使用して、 `core.yaml` ファイルのデフォルト設定を変更できます。将来、KubernetesまたはDockerを経由してピアをデプロイすることにした場合は、代わりに環境変数を使用して同じデフォルト設定を上書きすることができます。上書きのための環境変数名を作成する方法については、デプロイメントガイドの概要の [note](../deployment_guide_overview.html#step-five-deploy-peers-and-ordering-nodes) を参照してください。

`FABRIC_CFG_PATH` の値を `core.yaml` ファイルの場所に設定してください。 `fabric/bin` フォルダからピアバイナリを実行すると、 `/config` フォルダを指します。
    ```
    export FABRIC_CFG_PATH=../config
    ```

## Start the peer

`core.yaml` が設定され、デプロイメントバックエンドの準備ができたら、次のコマンドでピアノードを開始するだけです。

```
cd bin
./peer node start
```

ピアが正常に開始されると、次のようなメッセージが表示されます。

```
[nodeCmd] serve -> INFO 017 Started peer with ID=[peer0.org1.example.com], network ID=[prod], address=[peer0.org1.example.com:7060]
```

## Next steps

ネットワーク上で取引できるようにするためには、ピアをチャネルに参加させる必要があります。組織が属するピアは、そのピアの1つをチャネルに参加させる前に、チャネルのメンバーである必要があります。組織がチャネルを作成する場合は、オーダリングサービスがホストするコンソーシアムのメンバーである必要があります。組織がチャネルで少なくとも1つの [アンカーピア](../glossary.html#anchor-peer) を指定していない場合は、組織間の通信を有効にするため、指定する必要があります。詳細については、 [チャネル作成のチュートリアル](../create_channel/create_channel_overview.html) を参照してください。ピアがチャネルに参加すると、Fabricチェーンコードライフサイクルプロセスを使用して、ピア上のチェーンコードパッケージをインストールできます。ピア管理者IDのみが、ピア上のパッケージ化をインストールするために使用できます。

高可用性については、少なくとも1つの他のピアを組織にデプロイすることを検討する必要があります。これにより、このピアはメンテナンスのために安全にオフラインになり、トランザクション要求は他のピアによって処理され続けることができます。この冗長ピアは、両方のピアがデプロイされている場所がダウンした場合に備えて、別のシステムまたは仮想マシン上にある必要があります。

## Troubleshooting peer deployment

### Peer fails to start with ERRO 001 Fatal error when initializing core config

**Problem:** When launching the peer, it fails with:

```
InitCmd -> ERRO 001 Fatal error when initializing core config : Could not find config file. Please make sure that FABRIC_CFG_PATH is set to a path which contains core.yaml
```

**Solution:**

このエラーは、 `FABRIC_CFG_PATH` が設定されていないか、正しく設定されていない場合に発生します。 `FABRIC_CFG_PATH` 環境変数がピアの `core.yaml` ファイルの場所を指すように設定されていることを確認します。 `peer.exe` バイナリファイルが存在するフォルダに移動し、次のコマンドを実行します。

```
export FABRIC_CFG_PATH=../config
```
