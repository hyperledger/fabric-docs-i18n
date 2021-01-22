# Transaction handlers

**対象読者**: アーキテクト、アプリケーションおよびスマートコントラクト開発者

トランザクションハンドラによって、スマートコントラクト開発者は、アプリケーションとスマートコントラクトのやりとりの中の重要なポイントでの共通処理を定義することができます。
トランザクションハンドラは必須ではありませんが、定義された場合、スマートコントラクトで各トランザクションが実行される前あるいは後に制御を受け取ることができます。
スマートコントラクトで定義されていないトランザクションを実行しようとする要求があった場合に制御を受け取るハンドラもあります。

[コマーシャルペーパースマートコントラクトのサンプル](./smartcontract.html)のトランザクションハンドラの例は、下記のとおりです。

![develop.transactionhandler](./develop.diagram.2.png)

*Before・After・Unknownトランザクションハンドラ。
この例では、`beforeTransaction()`は、**発行**、**購入**、**現金化**トランザクションの前に呼ばれます。
`afterTransaction()`は、**発行**、**購入**、**現金化**トランザクションの後に呼ばれます。
`unknownTransaction()`は、スマートコントラクトで定義されていないトランザクションを実行しようとする要求があった場合にのみ呼ばれます。
(図は、`beforeTransaction`と`afterTransaction`の箱を各トランザクションごとに繰り返し描かないで簡略化しています)*

## Types of handler

下記のように、アプリケーションとスマートコントラクトの別々の側面に対応する3種類のトランザクションハンドラがあります。

  * **Beforeハンドラ**: 各スマートコントラクトトランザクションが実行される前に呼ばれます。
    このハンドラは、トランザクションで使われるトランザクションコンテキストを変更するために通常使われます。
    ハンドラは、Fabric APIの全てにアクセスすることができ、例えば、`getState()`や`putState()`を実行できます。


  * **Afterハンドラ**: 各スマートコントラクトトランザクションが実行された後に呼ばれます。
    このハンドラは、各トランザクションに共通な後処理を通常行い、これもFabric API全てにアクセスできます。


  * **Unknownハンドラ**: スマートコントラクトに定義されていないトランザクションを実行しようとした場合に呼ばれます。
    多くの場合、ハンドラは、後で管理者による処理のためにエラーを記録します。
    このハンドラは、Fabric API全てにアクセスできます。

トランザクションハンドラの定義は、必須ではありません。
ハンドラが定義されていない場合でも、スマートコントラクトは正しく動作します。
スマートコントラクトは、ハンドラの種類ごとにそれぞれ一つまで定義することができます。

## Defining a handler

トランザクションハンドラは、決められた名前のメソッドとして、スマートコントラクトに追加ｓれます。
下記が、各種類のハンドラを追加する例です。

```JavaScript
CommercialPaperContract extends Contract {

    ...

    async beforeTransaction(ctx) {
        // トランザクションIDをコンソールに情報として出力します
        console.info(ctx.stub.getTxID());
    };

    async afterTransaction(ctx, result) {
        // このハンドラは台帳とやりとりを行います
        ctx.stub.cpList.putState(...);
    };

    async unknownTransaction(ctx) {
        // このハンドラは例外を投げます
        throw new Error('Unknown transaction function');
    };

}
```

トランザクションハンドラ定義の形式は全てのハンドラの種類で似ていますが、`afterTransaction(ctx, result)`は、トランザクションによって返された結果も受け取ることに注意してください。
[APIドキュメント](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-contract-api.Contract.html)には、これらのハンドラの正確な形式の説明があります。

## Handler processing

ハンドラがスマートコントラクトに追加されると、ハンドラはトランザクション処理の間に実行されます。
処理においては、ハンドラは[トランザクションコンテキスト](./transationcontext.html)である`ctx`を受け取り、何らかの処理を行い、完了時に制御を返します。処理は、下記のように続きます。

* **Beforeハンドラ**: ハンドラが正常に終了した場合、トランザクションが更新されたコンテキストで呼ばれます。
  ハンドラが例外を投げた場合、トランザクションは呼ばれず、スマートコントラクトはその例外のエラーメッセージで失敗します。


* **Afterハンドラ**: ハンドラが正常に終了した場合、スマートコントラクトは、実行されたトランザクションの通りに終了します。
  ハンドラが例外を投げた場合、トランザクションはその例外のエラーメッセージで失敗します。


* **Unknownハンドラ**: ハンドラは、必要なエラーメッセージを含む例外を投げて終了するべきです。
  **Unknownハンドラ**が指定されなかった場合、あるいは、ハンドラが例外を投げなかった場合には、ちゃんとしたデフォルトの処理があり、スマートコントラクトは、**unknown transaction**のエラーメッセージで失敗します。

もし、ハンドラが関数及び引数にアクセスする必要がある場合、下記のように簡単に行うことができます。

```JavaScript
async beforeTransaction(ctx) {
    // トランザクションの詳細を取得します
    let txnDetails = ctx.stub.getFunctionAndParameters();

    console.info(`Calling function: ${txnDetails.fcn} `);
    console.info(util.format(`Function arguments : %j ${stub.getArgs()} ``);
}
```

このハンドラが、[トランザクションコンテキスト](./transactioncontext.html#stub)を通じて、ユーティリティAPIである`getFunctionAndParameters`を呼んでいるのがわかるでしょう。

## Multiple handlers

スマートコントラクトに対して、各種類のハンドラについて、最大一つまでしか定義することができません。
もし、スマートコントラクトが、before・after・unknown処理で複数の関数を呼ぶ必要がある場合は、適切なハンドラ関数がそれを管理しなければなりません。
