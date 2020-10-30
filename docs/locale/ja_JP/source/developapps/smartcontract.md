# Smart Contract Processing

**対象読者**: アーキテクト、アプリケーション及びスマートコントラクト開発者

スマートコントラクトは、ブロックチェーン・ネットワークの中心にあります。
PaperNetでは、コマーシャルペーパーの有効な状態と、その状態間の遷移を引き起こすロジックは、コマーシャルペーパーのスマートコントラクトのコードによって定義されています。
このトピックでは、コマーシャルペーパーの発行、購入、現金化のプロセスを管理する実世界のスマートコントラクトをどのように実装するかを示していきます。

ここでは、以下について扱います。

* [スマートコントラクトとは何か、そして、なぜそれが重要なのか](#smart-contract)
* [スマートコントラクトの定義の仕方](#contract-class)
* [トランザクションの定義の仕方](#transaction-definition)
* [トランザクションの実装の仕方](#transaction-logic)
* [スマートコントラクトでのビジネスデータの表現の仕方](#representing-an-object)
* [台帳におけるデータの格納と取得の仕方](#access-the-ledger)

もし必要であれば、[サンプルをダウンロード](../install.html)し、さらに[ローカルで実行する](../tutorial/commercial_paper.html)こともできます。
サンプルは、JavaScriptとJavaで書かれていますが、そのロジックはプログラミング言語には依存しませんので、内容を把握するのは簡単でしょう。(Go版のサンプルも作られる予定です)

## Smart Contract

スマートコントラクトは、ビジネスデータの様々な状態を定義し、データをその状態間で遷移させるプロセスを管理するものです。
スマートコントラクトによって、アーキテクトやスマートコントラクト開発者が、ブロックチェーンネットワークで協業する様々な組織間で共有される重要なビジネスプロセスやデータを定義することができるため、スマートコントラクトは重要なものです。

PaperNetのネットワークにおいては、スマートコントラクトは、MagnetoCorpやDigiBankといった様々なネットワーク参加者によって共有されています。
共有している同じビジネスプロセスとデータを共同で実装するために、ネットワークに接続されているすべてのアプリケーションは、同じバージョンのスマートコントラクトを使用しなければなりません。

## Implementation Languages

Java仮想マシンとNode.jsの二つのランタイムがサポートされています。
これにより、JavaScript、TypeScriptやJava、あるいはこれらのランタイム上で動くその他の言語を使うことができます。

JavaとTypeScriptにおいては、アノテーションあるいはデコレータを使って、スマートコントラクトとその構造に関する情報を提供することができます。
これによって、よりよい開発体験、例えば、製作者の情報の提供や、返り値の型の強制などを行うことができます。
JavaScriptだけでは、コーディング規約に従う必要があり、それゆえに自動的に判定できることに制限があります。

このトピックの例では、JavaScriptとJavaの両方を使用しています。

## Contract class

PaperNetコマーシャルペーパーのスマートコントラクトは、一つのファイル内に書かれています。
ブラウザで見るか、既にダウンロードしてあるのであれば、好きなエディタで開いてください。
  - `papercontract.js` - [JavaScript版](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
  - `CommercialPaperContract.java` - [Java版](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp//contract-java/src/main/java/org/example/CommercialPaperContract.java)


ファイルのパスから、これはMagnetoCorpのスマートコントラクトと気づくかもしれません。
MagnetoCorpとDigiBankは、これから使用するスマートコントラクトのバージョンについて合意していなければなりません。
とりあえずは、どの組織のものを使うかは関係ありません。全て同じです。

スマートコントラクトの全体の構造について、少し見てみましょう。
非常に短いことに注目してください！
ファイルの冒頭のほうに、次のようなコマーシャルペーパーのスマートコントラクトの定義があることがわかります。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContract extends Contract {...}
```
</details>

<details>
<summary>Java</summary>
```Java
@Contract(...)
@Default
public class CommercialPaperContract implements ContractInterface {...}
```
</details>


`CommercialPaperContract`クラスは、コマーシャルペーパーに関するトランザクションの定義を含んでいます。
すなわち、**発行(issue)**、**購入(buy)**、**現金化(redeem)**です。
これらのトランザクションが、コマーシャルペーパーを作り出し、そのライフサイクルに従って遷移させるものです。
この[トランザクション](#transaction-definition)については、この後ですぐ見ることになります。
今のところは、JavaScriptでは`CommercialPaperContract`が、Hyperledger Fabricの`Contract`[クラス](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-contract-api.Contract.html)を継承していることに注意してください。

Javaでは、このクラスには、アノテーション`@Contract(...)`を付加する必要があります。
これによって、ライセンスや製作者といったコントラクトに関する追加の情報を提供することができます。
`@Default()`アノテーションは、このクラスが、デフォルトのコントラクトのクラスであることを示しています。
あるクラスを、デフォルトのコントラクトのクラスとして指定できることは、複数のコントラクトのクラスをもつスマートコントラクトで便利なことがあります。

もし、TypeScriptによる実装を使っている場合には、Javaと同じ目的を満たす、似たような`@Contract(...)`デコレータがあります。

アノテーションに関する情報については、APIのドキュメントを参照してください。
* [JavaスマートコントラクトのAPIドキュメント](https://hyperledger.github.io/fabric-chaincode-java/)
* [Node.JsスマートコントラクトのAPIドキュメント](https://hyperledger.github.io/fabric-chaincode-node/)

Fabricのコントラクトのクラスは、Goで書かれたスマートコントラクトでも利用可能です。
このトピックでは、GoのコントラクトAPIについては述べませんが、JavaやJavaScriptのAPIと同様の概念を利用しています。
* [GoスマートコントラクトのAPIドキュメント](https://github.com/hyperledger/fabric-contract-api-go)

これらのクラス、アノテーション、`Context`クラスは、その前の下記の記述によって、スコープ内に取り込んでいます。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
const { Contract, Context } = require('fabric-contract-api');
```
</details>

<details>
<summary>Java</summary>
```Java
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contact;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.License;
import org.hyperledger.fabric.contract.annotation.Transaction;
```
</details>

コマーシャルペーパーのスマートコントラクトは、これらのクラスに組み込まれている機能を用います。
例えば、自動的なメソッドの呼び出し、[トランザクションごとのコンテキスト](./transactioncontext.html)、[トランザクション・ハンドラ](./transactionhandler.html)、クラス間で共有されるステートなどです。

JavaScriptでは、クラスのコンストラクタで、[親クラス](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)を用いて、明示的に[コントラクト名](./contractname.html)を指定して初期化していることにも注目してください。

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

Javaのクラスでは、コンストラクトは空で、`@Contract()`アノテーションによって明示的な名前を指定することができます。
もし、アノテーションがなければ、そのクラスの名前が使われます。

最も重要なのは、`org.papernet.commercialpaper`という名前が非常に記述的であるということで、このスマートコントラクトは、PaperNetに参加する組織すべてで合意されたコマーシャルペーパーの定義であるということを示しています。

通常、1つのファイルには1つのスマートコントラクトしか書かれないでしょう。
これは、スマートコントラクトは、別々のライフサイクルを持つことが多く、分けておくことは賢明なことだからです。
しかし、場合によっては、例えば`EuroBond`、`DollarBond`、`YenBond`というように、複数のスマートコントラクトで、アプリケーションに対しては文法的に区別できるようにしつつ、基本的には同じ機能を提供したいという場合があります。
このような場合では、スマートコントラクトとトランザクションの曖昧さを避けることができます。

## Transaction definition

クラスの中から**issue**メソッドを探してみてください。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                             String issuer,
                             String paperNumber,
                             String issueDateTime,
                             String maturityDateTime,
                             int faceValue) {...}
```
</details>

Javaのアノテーション `@Transaction` は、このメソッドがトランザクションの定義であることを示すもので、TypeScriptにも同等のデコレータがあります。

このコントラクトがコマーシャルペーパーの`issue`(発行)のために呼ばれた場合に、この関数に制御がわたります。
コマーシャルペーパー00001が次のようなトランザクションで作成されたことを思い出してください。

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

プログラミング・スタイルに従って変数名は変えていますが、これらのプロパティがほとんどそのまま`issue`メソッドの引数に対応することがわかるでしょう。

`issue`メソッドは、アプリケーションがコマーシャルペーパーの発行の要求をするたびに、コントラクトによって自動的に実行されます。
トランザクションのプロパティの値は、対応する引数という形でメソッドから利用可能です。
アプリケーションがどのようにHyperledger SDKを用いてトランザクションを送信するかは、[アプリケーション](./application.html)のトピックで、サンプルのアプリケーションを用いて説明されています。

**issue**の定義に、追加の引数 `ctx` があることに気づいたかもしれません。
これは、[**トランザクション・コンテキスト**](./transactioncontext.html)と呼ばれるもので、必ず一番最初の引数となります。
デフォルトでは、[トランザクションのロジック](#transaction-logic)に関係する、コントラクトごと、またトランザクションごとの情報を保持しています。
たとえば、MagnetoCorpのあるトランザクションの識別子、すなわちMagnetoCorpにより発行されたユーザーのデジタル証明書や、台帳APIへのアクセスを含んでいるでしょう。

スマートコントラクトは、デフォルトのトランザクション・コンテキストを拡張することができます。
これには、デフォルトをそのまま使うのではなく、独自の`createContext()`メソッドを実装することによって行えます。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
createContext() {
  return new CommercialPaperContext()
}
```
</details>

<details>
<summary>Java</summary>
```Java
@Override
public Context createContext(ChaincodeStub stub) {
     return new CommercialPaperContext(stub);
}
```
</details>

この拡張されたコンテキストでは、デフォルトのプロパティに対して、カスタムプロパティである`paperList`を加えています。
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContext extends Context {

  constructor() {
    super();
    // すべてのコマーシャルペーパーがリストに保存される
    this.paperList = new PaperList(this);
}
```
</details>

<details>
<summary>Java</summary>
```Java
class CommercialPaperContext extends Context {
    public CommercialPaperContext(ChaincodeStub stub) {
        super(stub);
        this.paperList = new PaperList(this);
    }
    public PaperList paperList;
}
```
</details>

この後で、どのように`ctx.paperList`が全てのPaperNetのコマーシャルペーパーを格納し取得するのに役立つかを述べます。

スマートコントラクト・トランザクションの構造に対する理解を確かなものにするために、**buy**と**redeem**トランザクションの定義を探してみて、それぞれ相当するコマーシャルペーパーのトランザクションにどのように対応するかを見てみてください。

**buy**トランザクション:

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseTime) {...}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {...}
```
</details>

**redeem**トランザクション:

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Redeemer = DigiBank
Redeem time = 31 Dec 2020 12:00:00 EST
```

<details open="true">
<summary>JavaScript</summary>
```JavaScript
async redeem(ctx, issuer, paperNumber, redeemingOwner, redeemDateTime) {...}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper redeem(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String redeemingOwner,
                              String redeemDateTime) {...}
```
</details>

どちらの場合も、コマーシャルペーパーのトランザクションと、スマートコントラクトのメソッド定義に1:1の対応関係があるのを確認してください。

全てのJavaScriptの関数は、`async`と`await`[キーワード](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)を使っています。
これによって、JavaScriptの関数を、同期的関数呼び出しかのように扱うことを可能にしています。

## Transaction logic

ここまでで、コントラクトがどのような構造をもち、トランザクションがどのように定義されているかを見てきましたので、次は、スマートコントラクト内のロジックにフォーカスしましょう。

最初の**issue**トランザクションを思い出してください。

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

これによって、**issue**メソッドに処理が渡ります。
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

  // コマーシャルペーパーのインスタンスを作成
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);

  // コマーシャルペーパーでなく、スマートコントラクトがコマーシャルペーパーをISSUED(発行済み)状態に設定
  paper.setIssued();

  // 新規発行されたコマーシャルペーパーの所有者は発行者
  paper.setOwner(issuer);

  // このコマーシャルペーパーを、台帳のワールドステート内の同様のコマーシャルペーパーのリストに追加
  await ctx.paperList.addPaper(paper);

  // スマートコントラクトの呼び出し元に、シリアライズしたコマーシャルペーパーを返す
  return paper.toBuffer();
}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper issue(CommercialPaperContext ctx,
                              String issuer,
                              String paperNumber,
                              String issueDateTime,
                              String maturityDateTime,
                              int faceValue) {

    System.out.println(ctx);

    // コマーシャルペーパーのインスタンスを作成
    CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
            faceValue,issuer,"");

    // コマーシャルペーパーでなく、スマートコントラクトがコマーシャルペーパーをISSUED(発行済み)状態に設定
    paper.setIssued();

    // 新規発行されたコマーシャルペーパーの所有者は発行者
    paper.setOwner(issuer);

    System.out.println(paper);
    // このコマーシャルペーパーを、台帳のワールドステート内の同様のコマーシャルペーパーのリストに追加
    ctx.paperList.addPaper(paper);

    // スマートコントラクトの呼び出し元に、シリアライズしたコマーシャルペーパーを返す
    return paper;
}
```
</details>

ロジックは単純で、入力値を取得し、新しいコマーシャルペーパー `paper` を作成し、それをコマーシャルペーパーのリストに、`paperList`を使って追加し、(bufferとしてシリアライズした)新しいコマーシャルペーパーを、トランザクションの応答として返すというものです。

`paperList`が、トランザクション・コンテキストから取得され、コマーシャルペーパーのリストへのアクセスを提供しているのを確認してください。`issue()`、`buy()`、そして`redeem()`は`ctx.paperList`に継続的に何度もアクセスし、コマーシャルペーパーのリストを最新の状態に維持しています。

**buy**トランザクションのロジックは、もう少し複雑なものです。
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

  // 与えられたフィールドをキーとして、現在のコマーシャルペーパーを取得
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

  // 現在の所有者の検証
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

  // 最初の購入では、状態をISSUEDからTRADINGに変更
  if (paper.isIssued()) {
      paper.setTrading();
  }

  // コマーシャルペーパーが既にREDEEMED(現金化済み)でないことを確認
  if (paper.isTrading()) {
      paper.setOwner(newOwner);
  } else {
      throw new Error('Paper ' + issuer + paperNumber + ' is not trading. Current state = ' +paper.getCurrentState());
  }

  // コマーシャルペーパーの更新
  await ctx.paperList.updatePaper(paper);
  return paper.toBuffer();
}
```
</details>

<details>
<summary>Java</summary>
```Java
@Transaction
public CommercialPaper buy(CommercialPaperContext ctx,
                           String issuer,
                           String paperNumber,
                           String currentOwner,
                           String newOwner,
                           int price,
                           String purchaseDateTime) {

    // 与えられたフィールドをキーとして、現在のコマーシャルペーパーを取得
    String paperKey = State.makeKey(new String[] { paperNumber });
    CommercialPaper paper = ctx.paperList.getPaper(paperKey);

    // 現在の所有者の検証
    if (!paper.getOwner().equals(currentOwner)) {
        throw new RuntimeException("Paper " + issuer + paperNumber + " is not owned by " + currentOwner);
    }

    // 最初の購入では、状態をISSUEDからTRADINGに変更
    if (paper.isIssued()) {
        paper.setTrading();
    }

    // コマーシャルペーパーが既にREDEEMED(現金化済み)でないことを確認
    if (paper.isTrading()) {
        paper.setOwner(newOwner);
    } else {
        throw new RuntimeException(
                "Paper " + issuer + paperNumber + " is not trading. Current state = " + paper.getState());
    }

    // コマーシャルペーパーの更新
    ctx.paperList.updatePaper(paper);
    return paper;
}
```
</details>

トランザクションが、`curretOwner`と`paper`が`TRADING`であることを確認してから、所有者を`paper.SetOwner(newOwner)`で変更しているのを確認してください。
ですが、基本的なフローは単純で、いくつかの前提条件をチェックし、新しい所有者を設定し、台帳上のコマーシャルペーパーを更新し、更新した(bufferとしてシリアライズした)コマーシャルペーパーをトランザクションの応答として返すというものです。

**redeem**トランザクションのロジックも理解できるかどうか確認してみませんか？

## Representing an object

ここまでは、`CommercialPaper`と`PaperList`クラスを用いて、**issue**、**buy**、**redeem**のトランザクションをどのように定義・実装するかを見てきました。
これらのクラスがどのように動くのかを見て、このトピックを終わりにしましょう。

`CommercialPaper`クラスを探してみてください。

<details open="true">
<summary>JavaScript</summary>
[paper.jsファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paper.js)の中:

```JavaScript
class CommercialPaper extends State {...}
```
</details>

<details>
<summary>Java</summary>
[CommercialPaper.javaファイル](https://github.com/hyperledger/fabric-samples/blob/release-1.4/commercial-paper/organization/magnetocorp/contract-java/src/main/java/org/example/CommercialPaper.java)の中:


```Java
@DataType()
public class CommercialPaper extends State {...}
```
</details>


このクラスは、コマーシャルペーパーのステートのメモリ上での表現を含んでいます。
`createInstance`メソッドの、新しいコマーシャルペーパーを与えられたパラメータで初期化する方法を見てください。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
static createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {
  return new CommercialPaper({ issuer, paperNumber, issueDateTime, maturityDateTime, faceValue });
}
```
</details>

<details>
<summary>Java</summary>
```Java
public static CommercialPaper createInstance(String issuer, String paperNumber, String issueDateTime,
        String maturityDateTime, int faceValue, String owner, String state) {
    return new CommercialPaper().setIssuer(issuer).setPaperNumber(paperNumber).setMaturityDateTime(maturityDateTime)
            .setFaceValue(faceValue).setKey().setIssueDateTime(issueDateTime).setOwner(owner).setState(state);
}
```
</details>

このクラスが**issue**トランザクションでどのように使われていたかを思い出してください。

<details open="true">
<summary>JavaScript</summary>
```JavaScript
let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);
```
</details>

<details>
<summary>Java</summary>
```Java
CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
        faceValue,issuer,"");
```
</details>

このissueトランザクションが呼ばれるたびに、トランザクションのデータを含んだコマーシャルペーパーの新しいメモリ上のインスタンスが作成されます。

何点か重要な注意点です。

  * これはメモリ上での表現です。台帳上にどう表れるかは、[後ほど](#accessing-the-ledger)見ていきます。

  * `CommercialPaper`クラスは、`State`クラスを継承しています。
    `State`は、ステートの共通的な抽象化を作成するアプリケーションで定義されたクラスです。
    全てのステートには、それが表現するビジネスデータのクラスがあり、複合キーを作り、シリアライズやデシリアライズなどを行うことができます。
    `State`は、台帳に複数の型のビジネスデータを格納する際に、コードをより読みやすくするのに役立ちます。
    `State`クラスの内容は、`state.js`[ファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js)で確認できます。

  * コマーシャルペーパーは、作られた際に、そのキーを計算します。このキーは、台帳にアクセスする際に用いられます。
    キーは、`issuer`と`paperNumber`を合わせたものです。

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```


  * コマーシャルペーパーは、クラスではなく、トランザクションによって`ISSUED`状態に遷移させられます。
    これは、コマーシャルペーパーのライフサイクル状態を管理するのは、スマートコントラクトであるからです。
    たとえば、`import`トランザクションがあったならば、いくつかの`TRADING`状態のコマーシャルペーパーを
    作成することになるであろうからです。

`CommercialPaper`クラスの残りは、単純なヘルパーメソッドを含んでいます。

```JavaScript
getOwner() {
    return this.owner;
}
```

スマートコントラクトが、このようなメソッドを使ってコマーシャルペーパーをライフサイクルの中で、どのように遷移させていたかを思い出してください。
たとえば、**redeem**トランザクションでは、次のようなコードがありました。

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

## Access the ledger

では、`paperlist.js`[ファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js)から、`PaperList`クラスを探してください。

```JavaScript
class PaperList extends StateList {
```

このユーティリティ・クラスは、Hyperledger Fabricのステートデータベース内の全てのPaperNetのコマーシャルペーパーを管理するのに使用されます。
PaperListのデータ構造の詳細は、[アーキテクチャのトピック](./architecture.html)で説明されています。

`CommercialPaper`と同じように、このクラスは、アプリケーションで定義された`StateList`クラスを継承しています。
`SateList`クラスは、ステートのリストに共通で使われる抽象化を作成し、この場合には、PaperNetの全てのコマーシャルペーパーのリストのことです。

`addPaper()`メソッドは、以下のような、`StateList.addState()`に対する単純なラッパーです。

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

`StateList.js`[ファイル](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)で、`StateList`クラスが、ステートデータとして台帳にコマーシャルペーパーを記録するのに、どのようにFabric APIの`putState()`を使用しているかを見ることができます。

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

台帳において、各ステートデータには、二つの基本的な要素が必要となります。

  * **キー**。`key`は、固定の名前と`state`のキーを用いて、`createCompositeKey()`によって作られます。
    この名前は、`PaperList`オブジェクトが作られたときに与えられ、`state.getSplitKey()`によって各ステートのユニークなキーが決められます。


  * **データ**。`data`は、単純にコマーシャルペーパーのステートをシリアライズしたもので、`State.serialize()`というユーティリティメソッドを用いて作られます。
    `State`クラスは、JSONによってデータ、また、必要があればStateのビジネスデータのクラス(この場合は`CommercialPaper`)のシリアライズ・デシリアライズを行います。ビジネスデータのクラスもまた、`PaperList`オブジェクトが作られたときに設定されます。

`StateList`自体は各ステートやステートのリストを格納せず、すべてFabricのステートデータベースに任せていることに注意してください。
これは重要なデザインパターンで、Hyperledger Fabricにおける[台帳のMVCC衝突](../readwrite.html)の可能性を減らすことができます。

ステートリストの`getState()`と`updateState()`メソッドは、同じように動作します。

```JavaScript
async getState(key) {
  let ledgerKey = this.ctx.stub.createCompositeKey(this.name, State.splitKey(key));
  let data = await this.ctx.stub.getState(ledgerKey);
  let state = State.deserialize(data, this.supportedClasses);
  return state;
}
```

```JavaScript
async updateState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

これらのメソッドが、Fabric APIである`putState()`、`getState()`、`createCompositeKey()`を使って台帳にアクセスするのを確認してください。
後でこのスマートコントラクトをPaperNetにあるすべてのコマーシャルペーパーのリストを返すように拡張します。
このとき、そのメソッドはどのような実装になるでしょうか？

以上です！
このトピックでは、PaperNetのスマートコントラクトをどのように実装するかを理解できました。
次のサブトピックにうつって、アプリケーションがFabric SDKを用いてどのようにスマートコントラクトを呼ぶかを見ることができます。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
