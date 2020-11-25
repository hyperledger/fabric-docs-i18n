# Application

**対象読者**: アーキテクト、アプリケーションおよびスマートコントラクト開発者

アプリケーションは、台帳に対するトランザクションを送信したり台帳の内容のクエリを行うことで、ブロックチェーンネットワークとやりとりします。
このトピックでは、アプリケーションがこれを行う仕組みについて取り上げます。
ここでのシナリオにおいては、組織は、コマーシャルぺーパーのスマートコントラクトで定義された、**発行**、**購入**、**現金化**のトランザクションを実行するアプリケーションを用いてPaperNetにアクセスします。
MagnetoCorpのアプリケーションがコマーシャルペーパーを発行するアプリケーションは基本的なものですが、理解に必要な重要な点をすべて扱っています。

このトピックでは、以下の項目について取り上げます。

* [スマートコントラクトを実行するアプリケーションのフロー](#basic-flow)
* [アプリケーションのウォレットとアイデンティティの使い方](#wallet)
* [アプリケーションのゲートウェイを用いた接続の仕方](#gateway)
* [特定のネットワークへのアクセスの仕方](#network-channel)
* [トランザクション要求の作成の仕方](#construct-request)
* [トランザクションの送信の仕方](#submit-transaction)
* [トランザクション応答の処理の仕方](#process-response)

理解を助けるために、以降ではHyperledger Fabricで提供されているコマーシャルペーパーのサンプルアプリケーションを参照していきます。
[このアプリケーションをダウンロードして](../install.html)、[ローカルで実行することができます](../tutorial/commercial_paper.html)。
アプリケーションは、JavaScriptとJavaの両方で書かれていますが、ロジックは言語にあまり依存していないので、何が起きているかを簡単に理解することができるでしょう。(Go版も提供される予定です)

## Basic Flow

アプリケーションは、ブロックチェーンネットワークとFabric SDKを用いてやりとりを行います。
下記の図は、アプリケーションがコマーシャルペーパーのスマートコントラクトをどのように実行するかを単純化したものです。

![develop.application](./develop.diagram.3.png) *PaperNetアプリケーションが、発行トランザクション要求を送信するために、コマーシャルペーパーのスマートコントラクトを実行します。*

アプリケーションはトランザクションを送信するために、次の6つの基本的なステップに従わなければなりません。

* ウォレットからアイデンティティを選択する
* ゲートウェイに接続する
* 目的のネットワークにアクセスする
* スマートコントラクトに対するトランザクション要求を作成する
* トランザクションをネットワークに送信する
* 応答を処理する

これから、典型的なアプリケーションがFabric SDKを用いてこの6つのステップをどのように実行するかを見ていきます。
`issue.js`に、このアプリケーションのコードが含まれています。
ブラウザで[見る](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/application/issue.js)か、ダウンロードしているならお好きなエディタで開いて見てください。
アプリケーションの全体構造を確認してみてください。
コメントやスペースも含んでさえ、たったの100行のコードです!

## Wallet

`issue.js`の冒頭の方で、2つのFabricのクラスがスコープに取り込まれているのがわかります。

```JavaScript
const { Wallets, Gateway } = require('fabric-network');
```

`fabric-network`に含まれるクラスについては、[Node SDKのドキュメント](https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/module-fabric-network.html)で参照することができますが、今のところは、MagnetoCorpのアプリケーションがPaperNetに接続するのに、どのようにこれらのクラスを用いているかを見ていきましょう。
アプリケーションは、Fabricの**Wallet**クラスを次のように使っています。

```JavaScript
const wallet = await Wallets.newFileSystemWallet('../identity/user/isabella/wallet');
```

`wallet`に対して、ローカルファイルシステムの[ウォレット](./wallet.html)がどのように指定されているかがわかるでしょうか。
ウォレットから取得されるアイデンティティは、明らかにIsabellaと呼ばれるユーザーのもので、このユーザーが`issue`アプリケーションを使用しています。
ウォレットは、アイデンティティのセット、すなわち複数のX.509デジタル証明書を保持し、PaperNetやそのほかのFabricネットワークにアクセスするために使うことができます。
もし、チュートリアルを動かしてこのディレクトリの中を見てみると、Isabellaに対するアイデンティティの資格情報があることがわかるでしょう。

[ウォレット](./wallet.html)は、政府発行の身分証明書や運転免許証やATMカードのデジタル版を保持しているものと考えてください。
その中のX.509デジタル証明書は、それを保持しているものと組織を関連付けるもので、すなわち、ネットワークのチャネルへのアクセスする権利を与えているものということになります。
例えば、`Isabella`はMagnetoCorpの管理者であるかもしれません。この場合、DigiBankの`Balaji`といったほかのユーザーとは異なる特権を与えられているかもしれません。
さらに、スマートコントラクトは、その処理の際に、[トランザクション・コンテキスト](./transactioncontext.html)を用いて、このアイデンティティを取得することができます。

ウォレットは、いかなる形の現金やトークンも保持しておらず、アイデンティティを保持するものであることに注意してください。

## Gateway

二つ目の重要なFabricのクラスは、**Gateway**です。
もっとも重要なことは、[ゲートウェイ](./gateway.html)は、ネットワーク(ここでは、PaperNet)に対するアクセスを提供する、1つあるいは複数のピアを認識しているということです。
以下のようにして、`issue.js`はゲートウェイに接続を行っています。

```JavaScript
await gateway.connect(connectionProfile, connectionOptions);
```

`gateway.connect()`には、2つの重要なパラメータがあります。

  * **connectionProfile**: PaperNetへのゲートウェイとなるピアのセットの情報を含む[コネクションプロファイル](./connectionprofile.html)のファイルシステム上での位置

  * **connectionOptions**: `issue.js`がPaperNetとのやりとりする際に用いられるオプション


クライアントアプリケーションがゲートウェイを使って、変化しうるネットワークトポロジーの影響を直接受けないようにしているのがわかるでしょうか。
ゲートウェイは、[コネクションプロファイル](./connectionprofile.html)と[オプション](./connectionoptions.html)を用いて、トランザクション提案を適切なピアノードに送信する処理の面倒をみます。

コネクション[プロファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/gateway/networkConnection.yaml)の`./gateway/connectionProfile.yaml` を少し確認してみてください。
読むのが簡単なように[YAML](http://yaml.org/spec/1.2/spec.html#Preview)を用いています。

このファイルは、オブジェクトに変換されてロードされます。

```JavaScript
let connectionProfile = yaml.safeLoad(file.readFileSync('./gateway/connectionProfile.yaml', 'utf8'));
```

今ここでは、下記に示す、`channels:`と`peers:`セクションだけが重要なセクションです。(説明を簡単にするために多少改変してあります)

```YAML
channels:
  papernet:
    peers:
      peer1.magnetocorp.com:
        endorsingPeer: true
        eventSource: true

      peer2.digibank.com:
        endorsingPeer: true
        eventSource: true

peers:
  peer1.magnetocorp.com:
    url: grpcs://localhost:7051
    grpcOptions:
      ssl-target-name-override: peer1.magnetocorp.com
      request-timeout: 120
    tlsCACerts:
      path: certificates/magnetocorp/magnetocorp.com-cert.pem

  peer2.digibank.com:
    url: grpcs://localhost:8051
    grpcOptions:
      ssl-target-name-override: peer1.digibank.com
    tlsCACerts:
      path: certificates/digibank/digibank.com-cert.pem
```

`channel:`でネットワークチャネルの`PaperNet:`と、その二つのピアが定義されているのがわかるでしょうか。
MagnetoCorpは`peer1.magenetocorp.com`を持ち、DigiBankは`peer2.digibank.com`を持ち、二つのピアともにエンドーシングピアのロールを持っています。

これらのピアは、ネットワークアドレスなどの接続のための方法などの詳細を含んでいる`peers:`キーに関連付けられます。

コネクションプロファイルは、ピアだけでなく、ネットワークチャネル、Orderer、組織、CAなど、非常に多くの情報を含んでいますので、全部が理解できなくても心配する必要はありません！

では次に、`connectionOptions`オブジェクトのほうを見ていきましょう。

```JavaScript
let connectionOptions = {
    identity: userName,
    wallet: wallet,
    discovery: { enabled:true, asLocalhost: true }
};
```

ゲートウェイに接続するのに使う必要のある、`userName`というアイデンティティ、`wallet`というウォレットが、オプションで指定されているのがわかるでしょうか。
これらの変数は、この前のコードで値が代入されています。

このほかにも、[コネクションオプション](./connectionoptions.html)があり、アプリケーションがSDKに対してその挙動をより細かく指示するのに使うことができます。

例:

```JavaScript
let connectionOptions = {
  identity: userName,
  wallet: wallet,
  eventHandlerOptions: {
    commitTimeout: 100,
    strategy: EventStrategies.MSPID_SCOPE_ANYFORTX
  },
}
```

ここでは、`commitTimeout`によって、トランザクションがコミットされたかどうかの結果を、100秒間まで待つようにSDKに指示しています。
そして、`strategy: EventStrategies.MSPID_SCOPE_ANYFORTX`は、MagnetoCorpの1つのピアがトランザクションを確認した時点で、SDKはアプリケーションに通知してよいということを表しています。
これに対して、`strategy: EventStrategies.NETWORK_SCOPE_ALLFORTX`では、MagnetoCorpとDigiBankのすべてのピアがトランザクションを確認するまで待つ必要があります。

コネクションオプションによって、アプリケーションが目的に応じた挙動を、実現方法を気にせずに指定することができます。
もし必要であれば、[詳細を確認することができます](./connectionoptions.html)。

## Network channel

`connectionProfile.yaml`のゲートウェイで定義されたピアによって、`issue.js`はPaperNetにアクセスできます。
これらのピアは、複数のネットワークチャネルに参加することができるので、アプリケーションはゲートウェイによって複数のネットワークチャネルへのアクセスを得ることができます。

アプリケーションが特定のチャネルをどのように選択するかを見てください。

```JavaScript
const network = await gateway.getNetwork('PaperNet');
```

これ以降では、`network`はPaperNetへのアクセスを提供します。
さらに、もしアプリケーションが他のネットワーク`BondNet`へのアクセスが同時に必要であったなら、下記のように簡単にできます。

```JavaScript
const network2 = await gateway.getNetwork('BondNet');
```

これでアプリケーションは、二つ目のネットワーク`BondNet`へのアクセスが、`PaperNet`と同時に可能になります！

ここに、Hyperledger Fabricの強力な機能を見ることができます。
すなわち、それぞれが複数ネットワークチャネルに参加している、複数のゲートウェイのピアに接続することで、アプリケーションは**ネットワークのネットワーク**に参加することができる、ということです。
アプリケーションは、`gateway.connect()`で提供したウォレットのアイデンティティに応じて、それぞれのチャネルで異なる権利を有します。

## Construct request

さて、アプリケーションはコマーシャルペーパーを**発行**することができるようになりました。
これを行うには、`CommercialPaperContract`を使うことになりますが、スマートコントラクトへのアクセスもまた非常に簡単です。

```JavaScript
const contract = await network.getContract('papercontract', 'org.papernet.commercialpaper');
```

アプリケーションが`papercontract`という名前と、明示的にコントラクトの名前`org.papernet.commercialpaper`を指定していることに注目してください。
複数のコントラクトを含むチェーンコード `papercontract.js`から、1つのコントラクトを、[コントラクト名](./contractname.html)によって選んでいることがわかるでしょうか。
PaperNetでは、`papercontract.js`が、`papercontract`という名前でチャネルにインストールされデプロイされていました。
もし興味があれば、複数のスマートコントラクトを含むチェーンコードを[どのように](../chaincode_lifecycle.html)デプロイするのかのドキュメントを参照してください。

もしアプリケーションが同時に、PaperNetやBondNetの他のコントラクトへのアクセスが必要だったなら、これも下記のように簡単に行えるでしょう。

```JavaScript
const euroContract = await network.getContract('EuroCommercialPaperContract');

const bondContract = await network2.getContract('BondContract');
```

この例では、コントラクト名を使用していないことに注意してください。
これは、ファイルあたり1つのスマートコントラクトしかないからで、`getContract()`は最初にみつけたコントラクトを使用します。

最初のコマーシャルペーパーを発行するのに、`MagnetoCorp`が下記のようなトランザクションを用いたことを思い出してください。

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

それでは、このトランザクションをPaperNetに送信しましょう！

## Submit transaction

トランザクションの送信は、下記の通り、SDKの1つのメソッドの呼び出しで行えます。

```JavaScript
const issueResponse = await contract.submitTransaction('issue', 'MagnetoCorp', '00001', '2020-05-31', '2020-11-30', '5000000');
```

`submitTransaction()`のパラメータが、トランザクション要求のそれに一致しているのがわかります。
この値が、スマートコントラクトの`issue()`メソッドに渡され、新しいコマーシャルペーパーを作成するのに使用されます。
このメソッドのシグネチャを思い出してください。

```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```

アプリケーションが、`submitTransaction()`を発行すると、すぐにスマートコントラクトに制御が移るように見えるかもしれませんが、それは違います。
SDKが裏では、`connectionOptions`と`connectionProfile`の詳細を使用して、必要なエンドースメントを得られるネットワークの適切なピア群にトランザクション提案を送信しています。
しかし、アプリケーションはこういったことを気にする必要はなく、ただ`submitTransaction`を呼び出すだけで、SDKが後の面倒は見てくれます！

`submitTransaction` APIには、トランザクションのコミットを待つというプロセスが含まれていることに注目してください。
コミットを待つことは必要不可欠で、もし、これがなければ、トランザクションの順序付け、検証、台帳へのコミットが成功したかどうかを知ることができないでしょう。

次は、アプリケーションが応答をどのように処理するかを見ていきましょう！

## Process response

`papercontract.js`で、下記のように、**issue**トランザクションがコマーシャルペーパーの応答を返していたのを思い出しましょう。

```JavaScript
return paper.toBuffer();
```

ここでちょっとしたクセがあることに気づくでしょう。
新しい`paper`はbufferに変換してから、アプリケーションに返さなければならないということです。
`issue.js`では、クラスメソッド`CommercialPaper.fromBuffer()`を用いて、応答のbufferからコマーシャルペーパーに復元しているのに注目してください。

```JavaScript
let paper = CommercialPaper.fromBuffer(issueResponse);
```

これによって、下記のように、完了メッセージの説明文で`paper`を自然な形で使うことができます。

```JavaScript
console.log(`${paper.issuer} commercial paper : ${paper.paperNumber} successfully issued for value ${paper.faceValue}`);
```

アプリケーションとスマートコントラクトで、同じ`paper`クラスが使われていることがわかります。
コードの構造をこのようにすることで、非常に読みやすく、また再利用しやすくすることができます。

トランザクション提案の場合と同様に、スマートコントラクトが完了するとすぐにアプリケーションに制御が移るように見えるかもしれませんが、これも違います。
SDKが、裏で合意形成プロセス全体を処理し、connectionOptionsの`strategy`にしたがって、完了した時点でアプリケーションに通知します。
もし、SDKが実際に裏で何をしているかに興味ある場合には、詳細な[トランザクションのフロー](../txflow.html)を参照してください。

以上です！
このトピックで、MagnetoCorpのアプリケーションがPaperNetで新しいコマーシャルペーパーを発行するやり方を通じて、サンプルアプリケーションからスマートコントラクトをどのように呼ぶかが理解できたでしょう。
[アーキテクチャのトピック](./architecture.html)で、これらの背後にある、重要な台帳やスマートコントラクトのデータ構造を見てみましょう。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
