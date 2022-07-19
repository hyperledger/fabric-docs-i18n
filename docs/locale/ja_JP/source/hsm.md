# Using a Hardware Security Module (HSM)

Fabricノードによって実行される暗号処理は、HSM(ハードウェア・セキュリティ・モジュール)を利用できます。
HSMは、秘密鍵を保護し、暗号処理を行います。これにより、ピアとOrdererが秘密鍵を晒すことなくトランザクションへの署名とエンドースを行います。
FIPS 140-2のような政府標準への準拠が必要な場合、複数の認証済みHSMから選択できます。

Fabricは現在、PKCS11標準を利用してHSMと通信しています。


## Configuring an HSM

FabricノードでHSMを使用するには、core.yamlやorderer.yamlなどのノード設定ファイルの `bccsp` (Crypto Service Provider)セクションを更新する必要があります。
`bccsp` セクションで、プロバイダとしてPKCS11を選択し、使用するPKCS11ライブラリへのパスを入力する必要があります。
また、暗号処理用に作成したトークンの `Label` と `PIN` も指定する必要があります。
1つのトークンを使用して、複数のキーを生成および格納できます。

事前にビルドされたHyperledger FabricのDockerイメージは、PKCS11を使用できるようになっていません。
dockerを使用してFabricをデプロイする場合は、独自のイメージをビルドし、次のコマンドを使用してPKCS11を有効にする必要があります。

```
make docker GO_TAGS=pkcs11
```
また、ノードがPKCS11ライブラリを利用できるように、インストールするか、コンテナ内にマウントする必要があります。

### Example

次の例は、HSMを使用できるようにFabricノードを設定する方法を示しています。

まず、PKCS11インターフェースの実装をインストールする必要があります。
この例では、[softhsm](https://github.com/opendnssec/SoftHSMv2)のオープンソース実装を使用します。
softhsmのダウンロードと設定後、環境変数SOFTHSM2_CONFに、softhsm2の設定ファイルへのパスを指定します。

次に、softhsmを使用して、HSMスロット内に、Fabricノード上で暗号処理を行うトークンを作成します。
この例では"fabric"とラベル付けされたトークンを使用し、PINを"71811222"に設定します。
トークンを作成したら、設定ファイルを更新して、PKCS11とトークンをcrypto service providerとして利用できるようにします。
以下に `bccsp` セクションの例を示します。

```
#############################################################################
# BCCSP (BlockChain Crypto Service Provider) section is used to select which
# crypto library implementation to use
#############################################################################
bccsp:
  default: PKCS11
  pkcs11:
    Library: /etc/hyperledger/fabric/libsofthsm2.so
    Pin: "71811222"
    Label: fabric
    hash: SHA2
    security: 256
    Immutable: false
```

デフォルトでは、HSMを使用して秘密鍵を生成する場合、秘密鍵を変更可能です。つまり、鍵を生成した後で、PKCS11の秘密鍵属性を変更できます。
`Immutable` を `true` に設定すると、鍵の生成後に秘密鍵属性を変更できません。
`Immutable:true` を設定する前に、利用するHSMでPKCS11オブジェクトコピーがサポートされていることを確認してください。

環境変数を使用して、設定ファイルの関連項目を上書きすることもできます。
Fabric CAサーバを使用してsofthsm2に接続する場合は、次の環境変数を設定するか、CAサーバの設定ファイルで対応する値を直接設定できます。

```
FABRIC_CA_SERVER_BCCSP_DEFAULT=PKCS11
FABRIC_CA_SERVER_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
FABRIC_CA_SERVER_BCCSP_PKCS11_PIN=71811222
FABRIC_CA_SERVER_BCCSP_PKCS11_LABEL=fabric
```

Fabricピアを使用してsofthsm2に接続している場合は、次の環境変数を設定するか、ピアの設定ファイルで対応する値を直接設定できます。

```
CORE_PEER_BCCSP_DEFAULT=PKCS11
CORE_PEER_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
CORE_PEER_BCCSP_PKCS11_PIN=71811222
CORE_PEER_BCCSP_PKCS11_LABEL=fabric
```

FabricのOrdererを使用してsofthsm2に接続している場合は、次の環境変数を設定するか、Ordererの設定ファイルで対応する値を直接設定できます。

```
ORDERER_GENERAL_BCCSP_DEFAULT=PKCS11
ORDERER_GENERAL_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
ORDERER_GENERAL_BCCSP_PKCS11_PIN=71811222
ORDERER_GENERAL_BCCSP_PKCS11_LABEL=fabric
```

docker composeを使用してノードをデプロイしている場合、独自のイメージをビルドした後でdocker composeファイルを更新して、ボリュームを使用しているコンテナ内にsofthsmライブラリと設定ファイルマウントします。
例えば、以下の環境変数とボリューム変数をdocker composeファイルに追加します。
```
  environment:
     - SOFTHSM2_CONF=/etc/hyperledger/fabric/config.file
  volumes:
     - /home/softhsm/config.file:/etc/hyperledger/fabric/config.file
     - /usr/local/Cellar/softhsm/2.1.0/lib/softhsm/libsofthsm2.so:/etc/hyperledger/fabric/libsofthsm2.so
```

## Setting up a network using HSM

HSMを使用してFabricノードをデプロイする場合、秘密鍵はノードのローカルMSPフォルダの `keystore` フォルダ内ではなく、HSM内に生成および保存されます。
MSPの `keystore` フォルダは空のままです。
代わりにFabricノードは、 `signcerts` フォルダの署名証明書のサブジェクト鍵識別子を使用して、HSM内部から秘密鍵を取得します。
ノードのMSPフォルダを作成するプロセスは、Fabric Certificate Authority(CA)と独自CAのどちらを利用するかで変わります。

### Before you begin

HSMを使用するようにFabricノードを設定する前に、次の手順を完了しておく必要があります。

1. HSMサーバ上にパーティションを作成し、パーティションの `Label` と`PIN` を記録します。
2. HSMプロバイダのドキュメントの指示に従って、HSMサーバと通信するHSMクライアントを設定します。

### Using an HSM with a Fabric CA

HSMを使用するようにFabric CAを設定するには、CAサーバ設定ファイルに対して、ピアノードまたはオーダリングノードと同じ設定をします。
Fabric CAを使用してHSM内に鍵を生成できるため、ローカルMSPフォルダの作成プロセスは簡単です。
次の手順を実行します。

1. Fabric CAサーバ設定ファイルの `bccsp` セクションを変更し、HSM用に作成した `Label` および `PIN` を指定します。
Fabric CAサーバが起動すると、秘密鍵が生成され、HSMに保存されます。
CA署名証明書の公開を気にしない場合は、この手順をスキップして、次の手順で説明するように、ピアまたはオーダリングノード用にのみHSMを設定できます。

2. Fabric CAクライアントを使用して、ピアIDまたはオーダリングノードIDをCAに登録します。

3. HSMサポートを使用してピアノードまたはオーダリングノードをデプロイする前に、秘密鍵をHSMに保存してノードIDを登録する必要があります。
Fabric CAクライアント設定ファイルの `bccsp` セクションを編集するか、関連する環境変数を使用して、ピアまたはオーダリングノードのHSM設定を指定します。
Fabric CAクライアント設定ファイルで、デフォルトの `SW` 設定を `PKCS11` 設定に置き換え、独自のHSMの値を指定します。

  ```
  bccsp:
    default: PKCS11
    pkcs11:
      Library: /etc/hyperledger/fabric/libsofthsm2.so
      Pin: "71811222"
      Label: fabric
      hash: SHA2
      security: 256
      Immutable: false
  ```

次に、各ノードについて、Fabric CAクライアントを使用して、手順2で登録したノードIDに対してエンロールすることにより、ピアまたはオーダリングノードのMSPフォルダを生成します。
関連付けられたMSPの `keystore` フォルダに秘密鍵を格納するのではなく、enrollコマンドは、ノードのHSMを使用して、ピアまたはオーダリングノードの秘密鍵を生成および格納します。
`keystore` フォルダは空のままです。

4. ピアまたはオーダリングノードがHSMを使用するように設定するには、ピアまたはオーダリングノードの設定ファイルの `bccsp` セクションを同様に更新してPKCS11を使用し、 `Label` と `PIN` を指定します。
また、 `mspConfigPath` (ピアノード用)または `LocalMSPDir` (オーダリングノード用)の値を編集して、Fabric CAクライアントを使用して前の手順で生成されたMSPフォルダを指定するようにします。
これで、ピアまたはオーダリングノードがHSMを使用するように設定されたので、ノードを起動すると、HSMで保護された秘密鍵を使用してトランザクションに署名し、エンドースすることができます。

### Using an HSM with your own CA

独自の認証局を使用してFabricコンポーネントをデプロイする場合は、次の手順に従ってHSMを使用できます。

1. PKCS11を使用してHSMと通信するようにCAを設定し、 `Label` と `PIN` を作成します。
次に、HSM内で生成された秘密鍵を使用して、CAで各ノードの秘密鍵と署名証明書を生成します。

2. CAを使用して、ピアまたはオーダリングノードのMSPフォルダを作成します。手順1で生成した署名証明書を `signcerts` フォルダ内に配置します。
`keystore` フォルダは空のままです。

3. ピアノードまたはオーダリングノードがHSMを使用するように設定するには、ピアノードまたはオーダリングノードの設定ファイルの `bccsp` セクションを同様に更新してPKCS11を使用し、 `Label` と `PIN` を提供します。
Fabric CAクライアントを使用した前の手順で生成されたMSPフォルダを指定するように、 `mspConfigPath` (ピアノード用)または `LocalMSPDir` (オーダリングノード用)の値を編集します。
これで、ピアノードまたはオーダリングノードがHSMを使用するように設定されたので、ノードを起動すると、HSMで保護された秘密鍵を使用してトランザクションに署名し、エンドースすることができます。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
