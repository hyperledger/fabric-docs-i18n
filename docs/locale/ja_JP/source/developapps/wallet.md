# Wallet

**対象読者**: アーキテクト、アプリケーションおよびスマートコントラクト開発者

ウォレットは、ユーザーのアイデンティティを集めたものです。
ユーザーが起動したアプリケーションは、その中のアイデンティティの一つを選んで、チャネルに接続します。
例えば台帳といったチャネルの資源へのアクセス権は、このアイデンティティとMSPの組み合わせで判断されます。

このトピックでは、次のことについて扱います。

* [なぜウォレットが重要なのか](#scenario)
* [ウォレットの構成](#structure)
* [ウォレットの種類](#types)
* [ウォレットの操作](#operations)

## Scenario

アプリケーションは、PaperNetのようなネットワークチャネルに接続するとき、それを行うためのユーザーアイデンティティ(例えば`ID1`)を選択します。
チャネルMSPは、`ID1`と、ある組織の中の役割を関連付け、この役割によって、最終的にアプリケーションのチャネル資源に対する権利が決まります。
例えば、`ID1`は、台帳に対する読み書きのできるMagnetoCorp組織のメンバーとしてユーザーを識別するかもしれませんし、一方`ID2`は、コンソーシアムに新しい組織を追加できるMagnetoCorpの管理者を識別するものかもしれません。

![wallet.scenario](./develop.diagram.10.png) *二人のユーザーIsabellaとBalajiは、PaperNetとBondNetという別々のネットワークに接続する際に使用可能な、異なるアイデンティティを含むウォレットを持っています*

MagnetoCorpのIsabellaとDigiBankのBalajiという二つのユーザーの例について考えてみましょう。
Isabellaは、App 1を使って、PanerNetのスマートコントラクトとBondNetの別のスマートコントラクトを実行しようとしています。
Balajiも同じように、App 2を使って、スマートコントラクトを実行しようとしていますが、PaperNetのスマートコントラクトのみです。
(アプリケーションが複数のネットワークとそのネットワーク内のスマートコントラクトにアクセスするのは、非常に[簡単](./application.html#construct-request)です)

このとき次のことがわかるでしょう。

* アイデンティティを発行するのに、MagnetoCorpはCA1を用い、DigiBankはCA2を用いている。
  これらのアイデンティティはユーザーのウォレットに格納されます。

* Balajiのウォレットは、CA2で発行された`ID4`というアイデンティティを一つだけ格納しています。
  Isabellaのウォレットは、CA1で発行された`ID1`・`ID2`・`ID3`という多くのアイデンティティを持っています。
  ウォレットは、一人のユーザーに対する複数のアイデンティティを持つことができ、各アイデンティティは別々のCAによって発行されることもあります。

* IsabellaとBalajiはともにPaperNetに接続し、そのMSPは、アイデンティティを発行しているCAに基づいて、IsabellaがMagnetoCorp組織のメンバーであり、BalajiをDigiBank組織のメンバーとして判断します。
  (一つの組織が複数のCAを用いることも、一つのCAが複数の組織に対応することも[可能です](../membership/membership.html#mapping-msps-to-organizations))

* Isabellaは、`ID1`をPaperNetとBondNetのどちらに接続するときも使うことができます。
  どの場合でも、このアイデンティティを使用すると、彼女はMagnetoCorpのメンバーとして認識されます。

* Isabellaは、`ID2`をBondNetに接続するときに使うことができ、この場合、彼女はMagnetoCorpの管理者として識別されます。
  このようにして、Isabellaは二つの非常に異なる特権を持つことができます。
  `ID1`は、BondNetの台帳を読み書きできるMagnetoCorpの単純なメンバーとして彼女を識別します。
  一方、`ID2`は、BondNetに対して新しい組織を追加できるMagnetoCorpの管理者として彼女を識別します。

* Balajiは、`ID4`を用いてBondNetに接続することはできません。
  もし接続しようとしたなら、BondNetのMSPはCA2のことを知らないので、`ID4`はDigiBankに属しているとは認識されないでしょう。

## Types

どこにアイデンティティを格納するかによって、ウォレットにはいくつかの種類があります。

![wallet.types](./develop.diagram.12.png) *３つの異なる種類のウォレットストレージであるファイルシステム・インメモリ・CouchDB*

* **ファイルシステム**: もっとも一般的なウォレットの格納先です。
  ファイルシステムは、広く使われており、わかりやすく、ネットワーク経由でマウントすることもできます。
  ウォレットのデフォルトとしてよい選択肢です。

* **インメモリ**: アプリケーション内に格納されるウォレットです。
  ファイルシステムに対してアクセスができないような、典型的にはブラウザのような制限された環境でアプリケーションが動いている場合に、この種類のウォレットを使用してください。
  この種類のウォレットは揮発性であり、アプリケーションが終了したりクラッシュしたりすると、アイデンティティは失われることは覚えておくとよいでしょう。

* **CouchDB**: CouchDBに格納されたウォレットです。
  これは使われることが最もまれな形のウォレットの格納先ですが、データベースのバックアップと復元機構を使いたいユーザーには、CouchDBウォレットは、ディザスタリカバリを単純にする便利な選択肢となるかもしれません。

ウォレットを作成するには、`Wallets`[クラス](https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/module-fabric-network.Wallets.html)が提供するファクトリ関数を使用してください。

### Hardware Security Module

ハードウェアセキュリティモジュール(HSM)は、非常にセキュアで耐タンパ性をもつデバイスで、特に秘密鍵のようなデジタルアイデンティティ情報を格納するものです。
HSMは、コンピュータにローカルに接続されたり、ネットワーク経由でアクセス可能であったりします。
ほとんどのHSMは、秘密鍵を用いた内部での暗号化が可能で、秘密鍵がHSMの外に出ないようになっています。

HSMは、どの種類のウォレットでも利用可能です。
この場合、アイデンティティの証明書はウォレットに格納され、秘密鍵はHSMに格納されます。

HSMで管理されたアイデンティティの利用を有効かするには、`IdentityProvider`にHSMへの接続情報が設定され、ウォレットに登録されている必要があります。
より詳細については、[ウォレットを用いたアイデンティティの管理](https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-wallet.html)のチュートリアルを参照してください。

## Structure

一つのウォレットは、複数のアイデンティティを持つことができ、それぞれのアイデンティティはある認証局(CA)により発行されています。
各アイデンティティは、それを説明するラベル、公開鍵を含むX.509証明書、秘密鍵、Fabric特有のメタデータからなる標準的な構造を持っています。
[ウォレットの種類](#types)ごとに、この構造が適切にその格納機構にマップされています。

![wallet.structure](./develop.diagram.11.png) *Fabricのウォレットは、異なる証明局によって発行された証明書を含む複数のアイデンティティを持つことができます。
アイデンティティは、証明書、秘密鍵、Fabricのメタデータを持ちます。*

ウォレットとアイデンティティを簡単にする重要なクラスメソッドがいくつかあります。

```JavaScript
const identity: X509Identity = {
    credentials: {
        certificate: certificatePEM,
        privateKey: privateKeyPEM,
    },
    mspId: 'Org1MSP',
    type: 'X.509',
};
await wallet.put(identityLabel, identity);
```

メタデータ`Org1MSP`、証明書`certificate`と秘密鍵`privateKey`を持つ`identity`が作られているのがわかります。
また、`wallet.put()`がこのアイデンティティを、`identityLabel`というラベルでウォレットに追加しているのがわかります。

`Gateway`クラスは、アイデンティティについて`mspId`と`type`メタデータ(上記の例では、それぞれ`Org1MSP1`と`X.509`)が設定されていることだけを要求します。
`Gateway`は、*今のところは*、例えば、特定の通知のストラテジが要求されたときなどに、このMSP IDの値を[コネクションプロファイル](./connectionprofile.html)のピアを識別するのに使います。
DigiBankのゲートウェイファイル `networkConnection.yaml`から、`Org1MSP`の通知が`peer0.org1.example.com`に関連付けられていることがわかるでしょう。

```yaml
organizations:
  Org1:
    mspid: Org1MSP

    peers:
      - peer0.org1.example.com
```

それぞれのウォレットの種類の内部構造について心配する必要はまったくありませんが、もし興味があれば、コマーシャルペーパーのサンプルで、下記のユーザーアイデンティティのフォルダを見てみてください。

```
magnetocorp/identity/user/isabella/
                                  wallet/
                                        User1@org1.example.com.id
```

これらのファイルを詳細にみることもできますが、これまで述べたように、SDKを用いてこれらのデータを操作するほうが簡単です。

## Operations

すべての種類のウォレットは、共通の[Wallet](https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/module-fabric-network.Wallet.html)インタフェースを実装しており、アイデンティティの管理のための標準的なAPIを提供しています。
つまり、アプリケーションは、実際のウォレットの格納機構とは独立に作ることができ、たとえば、ファイルシステムとHSMのウォレットは、非常に近い方法で扱うことができるということです。

![wallet.operations](./develop.diagram.13.png) *ウォレットは、あるライフサイクルに従い、新たに作成・既存のものを開くことができますし、アイデンティティを読み、追加し、削除することができます*

アプリケーションは、単純なライフサイクルに従ってウォレットを使うことができます。
ウォレットは、既存のものを開くか新たに作成することができ、その後、アイデンティティを追加し、更新し、読み取り、また削除することができます。
[JSDoc](https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/module-fabric-network.Wallet.html)の`Wallet`の様々なメソッドについて、どのように動くかを少し見てください。
コマーシャルペーパーのチュートリアルの`addToWallet.js`は、下記のようによい例となっています。

```JavaScript
const wallet = await Wallets.newFileSystemWallet('../identity/user/isabella/wallet');

const cert = fs.readFileSync(path.join(credPath, '.../User1@org1.example.com-cert.pem')).toString();
const key = fs.readFileSync(path.join(credPath, '.../_sk')).toString();

const identityLabel = 'User1@org1.example.com';
const identity = {
    credentials: {
        certificate: cert,
        privateKey: key,
    },
    mspId: 'Org1MSP',
    type: 'X.509',
};

await wallet.put(identityLabel, identity);
```

次のことに注目してください。

* プログラムが初めて実行されたとき、ウォレットは、ローカルファイルシステム上の`.../isabella/wallet`に作成されます。

* 証明書`cert`と秘密鍵`key`は、ファイルシステムからロードされます。

* 新しいX.509アイデンティティは、`cert`、`key`、`Org1MSP`という値で作成されます。

* 新しいアイデンティティは、`User1@org1.example.com`というラベルで、`wallet.put()`によってウォレットに追加されます。

これでウォレットに関して知るべきことはすべてです。
Fabricのネットワーク資源にアクセスするために、ユーザーの代わりにアプリケーションによって使われるアイデンティティを、どのようにウォレットが持っているかを見てきました。
アプリケーションとセキュリティの必要性に応じて、異なる種類のウォレットが利用可能であり、単純なAPIによってアプリケーションがウォレットとその中のアイデンティティを管理することができます。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
