# Исполнение смарт-контрактов

**Аудитория**: Архитекторы приложений, разработчики смарт-контрактов и приложений

В самом центре концепции блокчейн-сети располагается смарт-контракт. В сети PaperNet
программный код смарт-контракта определяет разрешенные состояния коммерческой ценной
бумаги и логику транзакции, которая переводит бумагу из одного состояния в другое.
В этой главе мы покажем, как реализовать смарт-контракт для условий реального мира так, чтобы
этот смарт-контракт заведовал процессами выпуска, покупки и погашения коммерческих ценных бумаг.

Далее рассмотрим следующее:

* [Что такое смарт-контракт, и почему он важен](#smart-contract)
* [Как определить смарт-контракт](#contract-class)
* [Как определить транзакцию](#transaction-definition)
* [Как реализовать транзакцию](#transaction-logic)
* [Как задать представление бизнес-объекта внутри смарт-контракта](#representing-an-object)
* [Как хранить и как извлекать объект из реестра](#access-the-ledger)

По желанию можете [загрузить пример](../install.html) и даже попробовать [запустить его на локальной машине](../tutorial/commercial_paper.html).
Он написан на JavaScript и Java, но его логика не зависит от структуры языка, так что
вам сразу будет ясно, что происходит (кстати, пример есть и на языке Go).

## Смарт-контракт
Смарт-контрактом определяются различные состояния бизнес-объекта и регламентируются
процессы, которые проводят объект от одного состояния к другому. Смарт-контракты важны,
так как они позволяют архитекторам и разработчикам смарт-контрактов задавать
ключевые бизнес-процессы и определять данные, которыми совместно будут пользоваться
различные организации - партнеры по блокчейн-сети.

В сети PaperNet, к примеру, смарт-контракт совместно используется разными участниками
сети, такими как MagnetoCorp и DigiBank. Все приложения, присоединенные к сети, должны
использовать одну и ту же версию смарт-контракта, чтобы совместно реализовать идентичные
совместно используемые бизнес-процессы и данные.

## Языки реализации

Поддерживаются две среды исполнения - Java Virtual Machine и Node.js. Таким образом,
дается возможность для использования любого из языков, поддерживающихся в этой среде,
будь то JavaScript, TypeScript, Java или другие.

В языках Java and TypeScript, для описания информации о смарт-контракте и его структуре
используются аннотации и декораторы. С их помощью разработка становится содержательнее -
к примеру, можно ввести информацию об авторе или типах возвращаемых значений.
Также в JavaScript необходимо следовать конвенциям (соглашениям), и, следовательно,
в связи с этим есть ограничения на автоматические определения.

Приведем примеры на JavaScript и Java.

## Класс контракта

Копия смарт-контракта коммерческой ценной бумаги PaperNet содержится в единственном файле.
Просмотрите его своим браузером или откройте в текстовом редакторе на ваш выбор.
  - `papercontract.js` - [версия JavaScript](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
  - `CommercialPaperContract.java` - [версия Java](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp//contract-java/src/main/java/org/example/CommercialPaperContract.java)


Легко заметить, что путь файла указывает на то, что эта копия смарт-контракта принадлежит 
MagnetoCorp. MagnetoCorp и DigiBank должны иметь согласованную версию смарт-контракта.
В настоящий момент не важно, чья копия используется - они одинаковые.

Ненадолго бросьте взгляд на полную структуру смарт-контракта - она довольно короткая.
В самом верху файла вы можете заметить определение смарт-контракта
коммерческих ценных бумаг:
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


Класс `CommercialPaperContract` содержит определения транзакций для коммерческих ценных бумаг - **выпустить**, **купить**
и **погасить**. Именно эти транзакции создают ценную бумагу и проводят её по ряду состояний
в течение её жизненного цикла. Скоро мы изучим эти
[транзакции](#transaction-definition), а сейчас в случае JavaScript заметим, что
`CommericalPaperContract` наследует [класс](https://hyperledger.github.io/fabric-chaincode-node/{BRANCH}/api/fabric-contract-api.Contract.html)
`Contract` из Hyperledger Fabric.

В языке Java, класс должен быть снабжен аннотацией `@Contract(...)`.
Этот дает возможность предоставить дополнительную информацию о контракте, такую как, например,
номер лицензии и имя автора. Аннотация `@Default()` сигнализирует о том, что
этот класс контракта является заданным по умолчанию. Обозначить класс контракта "по умолчанию"
иногда полезно в смарт-контрактах, у которых имеется множество классов.

Если вы используете реализацию в TypeScript implementation, то - есть похожие аннотации `@Contract(...)`,
которые служат тем же целям, что и в Java.

Более подробно о возможных аннотациях можно посмотреть в документации API:
* [API-документация для смарт-контрактов на Java](https://hyperledger.github.io/fabric-chaincode-java/)
* [API-документация для смарт-контрактов Node.js](https://hyperledger.github.io/fabric-chaincode-node/)

Классы контрактов для Fabric присутствуют и в смарт-контрактах, написанных на Go. Сейчас мы не будем обсуждать API контрактов на Go,
но для них используются те же концепции, и что и в API для Java и JavaScript:
* [API-документация для смарт-контрактов на Go](https://github.com/hyperledger/fabric-contract-api-go)

Эти классы, аннотации и класс `Context` мы рассмотрели ранее:

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


Наш контракт для коммерческих ценных бумаг использует встроенные свойства классов,
такие как автоматический вызов метода,
[потранзакционный контекст](./transactioncontext.html),
[обработчики транзакций](./transactionhandler.html), и разделяемое классами состояние.

Обратите внимание на то, как конструктор классов JavaScript использует
[родительский класс](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super),
чтобы инициализироваться конкретным [названием контракта](./contractname.html):

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

В классе Java конструктор является пустым, так как явное название контракта может быть
задано в аннотации `@Contract()`. Если имя отсутствует, тогда используется название класса.


Но важнейшим и наиболее подробным по описанию является `org.papernet.commercialpaper` --
этот смарт-контракт является согласованным определением ценной бумаги для всех
организаций сети PaperNet.

Обычно на один файл приходится один смарт-контракт - у контрактов может быть различный
жизненный цикл, и поэтому разумно контракты развести по разным файлам. Но при этом в некоторых
случаях, множественность смарт-контрактов и их названий может синтаксически облегчать
жизнь приложениями, например, такими названиями как `EuroBond`, `DollarBond`, `YenBond`,
хоть и выполняя по сути, одну и ту же функцию. Это пример тех случаев, когда постарались
различать смарт-контракты и транзакции, так, чтобы в них не запутаться.

## Как определить транзакцию

Внутри класса найдите метод **выпустить** (issue).
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

В Java аннотация `@Transaction` используется для того, чтобы пометить этот метод
как содержащий определение транзакции; аннотация в TypeScript - такая же.

Этой функции передается управление, как только этот контракт вызывается для того, чтобы
`выпустить` коммерческую ценную бумагу. Вспомните, какой транзакцией была создана
ценная бумага 00001:

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

Мы поменяли названия переменных для лучшей наглядности стиля программирования, но,
как видите, имена свойств полностью соответствуют переменным метода `issue`.

Методу `issue` автоматически передается управление контрактом, как только приложение
запрашивает выпуск коммерческой ценной бумаги. Значения свойств транзакции передаются методу
через соответствующие переменные. В главе [приложение](./application.html) описано, как
приложение отправляет транзакцию при помощи Hyperledger Fabric SDK, используя пример приложения.

Вы могли заметить лишнюю переменную в определении **выпуска** -- `ctx`.
Она называется [**транзакционный контекст**](./transactioncontext.html) и всегда
указывается первой. По умолчанию, она содержит [транзакционную логику](#transaction-logic)
для каждого контракта и каждой транзакции. Например, в ней содержится идентификатор
конкретной транзакции MagnetoCorp, цифровой сертификат пользователя-эмитента в составе MagnetoCorp,
а также доступ к API реестра.

Взгляните, как смарт-контракт дополняет заданный по умолчанию транзакционный контекст путем реализации
собственного метода `createContext()`, а не использует реализацию, данную по умолчанию:

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


Этот дополненный контекст добавляет свойство `paperList` к свойствам, данным по умолчанию:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContext extends Context {

  constructor() {
    super();
    // Все ценные бумаги входят в список ценных бумаг
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

Впоследствии опишем, как `ctx.paperList` можно использовать для хранения и
извлечения всех коммерческих ценных бумаг сети PaperNet.

Чтобы укрепить понимание структуры транзакции смарт-контрактов, посмотрите на
определения транзакций **buy** и **redeem**, и попробуйте понять, как они отражаются на
соответствующие транзакции коммерческой ценной бумаги.

Транзакция **buy** (купить):

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

Транзакция **redeem** (погасить):

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

В обоих случаях обратите внимание на взаимно-однозначное соответствие транзакции
коммерческой ценной бумаги и определения смарт-контракта.

Все функции JavaScript пользуются [ключевыми словами](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
  `async` и `await`, которые позволяют обращаться с функциями JavaScript так, будто это были синхронные вызовы функций.



## Логика транзакции

Теперь, когда вы ознакомились со структурированием и определением транзакций,
сконцентрируемся на внутренней логике смарт-контракта.

Вспомним первую транзакцию **issue** (выпустить):

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

Она приводит к передаче управления методу **issue**:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

   // создать экземпляр ценной бумаги
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);

  // Смарт-контракт перемещает в состояние ISSUED (выпущена)
  paper.setIssued();

  // Свежевыпущенная бумага пока еще принадлежит тому, кто ее выпустил
  paper.setOwner(issuer);

  // Внести эту ценную бумагу в список всех похожих бумаг в глобальное состояние в реестре
  await ctx.paperList.addPaper(paper);

  // Получить сериализованный вывод ценной бумаги и передать тому, кто вызвал смарт-контракт
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

    // создать экземпляр ценной бумаги
    CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
            faceValue,issuer,"");

    // Смарт-контракт перемещает в состояние ISSUED (выпущена)
    paper.setIssued();

    // Свежевыпущенная бумага пока еще принадлежит тому, кто ее выпустил
    paper.setOwner(issuer);

    System.out.println(paper);
    // Внести эту ценную бумагу в список всех похожих бумаг в глобальное состояние в реестре
    ctx.paperList.addPaper(paper);

    // Получить сериализованный вывод ценной бумаги и передать тому, кто вызвал смарт-контракт
    return paper;
}
```
</details>


Логика проста: на основании входных переменных транзакции создать новую коммерческую ценную бумагу `paper`,
добавить ее в список всех коммерческих ценных бумаг при помощи `paperList`, и выдать коммерческую ценную
бумагу (в сериализованном виде) как ответ транзакции.

Посмотрите, как мы извлекаем `paperList` из транзакционного контекста, чтобы обеспечить
доступ к списку коммерческих ценных бумаг. `issue()`, `buy()` and `redeem()` постоянно обращаются
к `ctx.paperList`, чтобы поддерживать его в актуальном состоянии.

Логика транзакции **buy** немного сложнее:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

  // Извлечь текущую бумагу при помощи ключевых полей
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

  // Проверить текущего владельца
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

  // Сначала транзакция изменяет состояние с ISSUED на TRADING
  if (paper.isIssued()) {
      paper.setTrading();
  }

  // Проверка - не погашена ли бумага до сих пор (не находится ли в состоянии REDEEMED)
  if (paper.isTrading()) {
      paper.setOwner(newOwner);
  } else {
      throw new Error('Paper ' + issuer + paperNumber + ' is not trading. Current state = ' +paper.getCurrentState());
  }

  // Изменить состояние бумаги
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

    // Извлечь текущую бумагу при помощи ключевых полей
    String paperKey = State.makeKey(new String[] { paperNumber });
    CommercialPaper paper = ctx.paperList.getPaper(paperKey);

    // Проверить текущего владельца
    if (!paper.getOwner().equals(currentOwner)) {
        throw new RuntimeException("Paper " + issuer + paperNumber + " is not owned by " + currentOwner);
    }

    // Сначала транзакция изменяет состояние с ISSUED на TRADING
    if (paper.isIssued()) {
        paper.setTrading();
    }

    // Проверка - не погашена ли бумага до сих пор (не находится ли в состоянии REDEEMED)
    if (paper.isTrading()) {
        paper.setOwner(newOwner);
    } else {
        throw new RuntimeException(
                "Paper " + issuer + paperNumber + " is not trading. Current state = " + paper.getState());
    }

    // Изменить состояние бумаги
    ctx.paperList.updatePaper(paper);
    return paper;
}
```
</details>

Транзакция сначала проверяет имя текущего владельца `currentOwner` и то, что бумага `paper`
находится в состоянии `TRADING` (торгуется), и только после этого меняет владельца `paper.setOwner(newOwner)`.
Последовательность простейшая - сначала проверить какие-то обязательные пред-условия,
затем установить в состоянии имя нового владельца, изменить состояние бумаги в реестре, а потом
предоставить ответ транзакции в виде измененного статуса ценной бумаги (сериализованного в буфер).

Теперь в качестве упражнения можете посмотреть, как работает транзакция **redeem** (погасить).

## Представление объекта

Теперь, когда мы знаем, как задать и реализовать транзакции **issue**, **buy** и **redeem**
при помощи классов`CommercialPaper` и `PaperList`, завершим эту главу изложением того,
как работают классы.

Найдите класс `CommercialPaper`:

<details open="true">
<summary>JavaScript</summary>
In the
[paper.js file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paper.js):

```JavaScript
class CommercialPaper extends State {...}
```
</details>

<details>
<summary>Java</summary>
In the [CommercialPaper.java file](https://github.com/hyperledger/fabric-samples/blob/release-1.4/commercial-paper/organization/magnetocorp/contract-java/src/main/java/org/example/CommercialPaper.java):


```Java
@DataType()
public class CommercialPaper extends State {...}
```
</details>


Этот класс содержит представление того, как хранится в памяти состояние ценной бумаги.
Метод `createInstance` инициализирует коммерческую ценную бумагу полученными параметрами
вот таким образом:

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

Вспомним, как этот класс использовался транзакцией **issue**:

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

Примечательно, что каждый раз при вызове транзакции создания бумаги, создается новая копия
ценной бумаги в памяти, и эта копия содержит данные транзакции.

Важно отметить:

  * Это представление в памяти, а не в реестре; как оно появится в реестре, мы увидим
    [позже](#accessing-the-ledger).


  * Класс `CommercialPaper` наследует класс `State`. `State` - это класс, задающийся приложением,
    и он создает общую абстракцию состояния. Каждое состояние содержит класс бизнес-объекта,
    который оно представляет, составной ключ, может быть сериализовано или десериализовано, и так далее.
    Наличие `State` делает код более читаемым в случае, когда приходится хранить более
    одного типа бизнес-объектов в реестре. Посмотрите на класс `State` в [файле](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js) `state.js`.


  * Ценная бумага вычисляет собственный ключ в момент собственного создания -- этот ключ будет использоваться при доступе к реестру.
    Этот ключ состоит из комбинации `issuer` и `paperNumber`.

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```


  * Транзакция, а не класс бумаги, перемещает бумагу в состояние `ISSUED` (выпущена).
    Причина этого в том, что жизненным циклом ценной бумаги управляет смарт-контракт.
    К примеру, транзакция `import` может создать ряд ценных бумаг, и сразу же
    в состоянии `TRADING` (торгуется).

В остальном в классе `CommercialPaper` содержатся простые вспомогательные методы:

```JavaScript
getOwner() {
    return this.owner;
}
```

Припомните, что похожими методами пользуется смарт-контракт для проведения ценной бумаги
по ее жизненному циклу. Например, как видели, транзакция **redeem** производит следующее:

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

## Доступ к реестру

Найдите класс `PaperList` в `paperlist.js`
[file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js):

```JavaScript
class PaperList extends StateList {
```

Этот вспомогательный класс нужен, чтобы управлять всеми ценными бумагами сети PaperNet
в базе данных состояний Hyperledger Fabric. Подробнее о структурах данных PaperList
мы рассказываем в [главе об архитектуре](./architecture.html).

Как и класс `CommercialPaper`, этот класс дополняет определяемый приложением класс
`StateList`, который в свою очередь создает общую абстракцию для списка классов --
в нашем случае, для всех коммерческих ценных бумаг сети PaperNet.

Этот метод `addPaper()` всего лишь косметическое прикрытие метода `StateList.addState()`:

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

В [файле](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js) `StateList.js`
видно, как класс `StateList` пользуется Fabric API `putState()`, чтобы вписать ценную бумагу
как данные состояния в реестр:

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

Любая часть данных состояния в реестре обязана содержать два основных элемента:

  * **Ключ**: `key` формируется `createCompositeKey()`, используя постоянное название
    и ключ состояния `state`. Это название было присвоено при создании объекта `PaperList`,
    и посредством `state.getSplitKey()` определяется уникальный ключ каждого состояния.


  * **Данные**: `data` это просто состояние ценной бумаги в сериализованной форме, которая
    была создана методом `State.serialize()`. Класс `State`при помощи JSON сериализует
    и десериализует не только данные, но и класс бизнес-объекта состояния по необходимости,
    в нашем случае это класс `CommercialPaper`, который был задан при создании объекта
    `PaperList`.


Примечательно, что `StateList` не хранит ничего, указывающего на индивидуальное состояние
или полный список состояний -- всё это он делегирует базе данных состояний Fabric.
Это важный шаблон проектирования -- тем самым снижается вероятность [конфликта версий реестра](../readwrite.html) в Hyperledger Fabric.

Принадлежащие StateList методы `getState()` и `updateState()` работают сходным образом:

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

Посмотрите, как они используют интерфейсы API Fabric `putState()`, `getState()` и
`createCompositeKey()` чтобы обращаться к реестру. Мы распространим этот смарт-контракт
позже на весь список ценных бумаг сети PaperNet -- постарайтесь представить, как
в этом случае должен выглядеть метод, чтобы обращаться к реестру для этой цели?

На этом всё! В этой главе вам удалось разобраться, как реализовывать смарт-контракты
для PaperNet. Теперь можно переходить к следующему подразделу, описывающему в свою очередь,
как приложение вызывает смарт-контракт при помощи Fabric SDK.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
