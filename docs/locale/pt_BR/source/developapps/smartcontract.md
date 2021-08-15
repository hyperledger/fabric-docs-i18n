# Processamento de Contrato Inteligente

**Publico alvo**: Arquitetos, desenvolvedores de aplicativos e de contratos inteligentes

O contrato inteligente está no centro de uma rede blockchain para negócios. No PaperNet, o código
no contrato inteligente de papel comercial define os estados válidos para o papel comercial,
e a transação lógica que transitou de um 
estado de
papel para outro. Nesse tópico vamos mostrar como implementar um 
contrato inteligente do mundo real que governa o processo de emissão.

Vamos abordar:

* [o que é contrato inteligente e por que é importante](#smart-contract)
* [Como definir um contrato inteligente](#contract-class)
* [Como definir uma transação](#transaction-definition)
* [Como implementar uma transação](#transaction-logic)
* [Como representar um objeto de negócios em um contrato inteligente](#representing-an-object)
* [Como armazenar e recuperar um histórico no livro razão](#access-the-ledger)

Se preferir, pode fazer o download [download the sample](../install.html) [executá-lo 
localmente](../tutorial/commercial_paper.html). Está escrito em JavaScript e Java, mas a lógica é bem independente de uma linguagem para a outra,
então você poderá ver facilmente o que está acontecendo.
(A amostra também estará disponível para Go.)

## Contrato inteligente

Um contrato inteligente define diferentes estágios de objeto do trabalho, e governa 
o processo que move o objeto em diferentes estágios. Contratos inteligentes são importantes 
porque eles habilitam arquitetos e desenvolvedores de contratos inteligentes a definir a chave 
do processo e os dados que vão compartilhar com diferentes 
organizações que colaboram na rede blockchain.

Na rede PaperNet, o contrato inteligente é compartilhado por diferentes redes participantes, 
como MagnetoCorp e DigiBank. A mesma versão do contrato inteligente deve ser usada para todos
os aplicativos conectados à rede, para que eles implementem em conjunto os mesmos processos e dados
de negócios compartilhados. 

## Linguagens de implementação

Existem dois tempos de execução que são suportados, o Java Máquina Virtual e Node.js.
Isso confere a oportunidade de usar o JavaScrip, TypeScript, Java ou outra linguagem que 
pode ser executada em um desses tempos de execução.

No Java e no TypeScript, anotações e decorações são usadas para forneceder informação do contrato
inteligente e sua estrutura. Isso permite uma experiência de desenvolvimento mais rica ---
Por exemplo, informação sobre o autor ou tipos de retorno podem ser aplicados. Dentro do JavaScript, 
convenções devem ser seguidas, no entanto, existem limitações em torno que podem ser 
determinadas automaticamente.

Os exemplos aqui são fornecidos em JavaScript e Java

## Classe de contrato

A cópia do contrato inteligente do PaperNet está contida em um único arquivo. Visualize com o seu navegador, 
ou abra-o com o seu editor favorito, caso tenha baixado.
 - `papercontract.js` - [JavaScript version](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/papercontract.js)
  - `CommercialPaperContract.java` - [Java version](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp//contract-java/src/main/java/org/example/CommercialPaperContract.java)


Você pode observar no caminho do arquivo que esta é a cópia do contrato inteligente da MagnetoCorp's.  
MagnetoCorp and DigiBank devem concordar com a versão do contrato inteligente que irão usar.
Agora, não importa qual a cópia da organização que você usa,
todas são as mesmas.

Passe alguns momentos examinando a estrutura geral dos contratos inteligentes; observe que é relativamente curto.
No topo do arquivo você verá que tem uma definição para contrato 
inteligente de papel comercial: 
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


A classe `CommercialPaperContract`contém as definições para transação comercial -- **issue**, **buy**
e **redeem**. São essas transações comerciais que trazem o papel comercial a existencia e os movem ao longo de seu ciclo de vida.
 Examinaremos essas [transações](#transaction-definition) em breve,
 mas, por enquanto observe para o JavaScript, que o 
 CommericalPaperContract`estende o Hyperledger 
Fabric `Contrato` [classe] (https://hyperledger.github.io/fabric-chaincode-node/master/api/fabric-contract-api.Contract.html).

Com Java a classe deve ser decorada com a anotação `@Contract(...)`. Isso concede a oportunidade 
de fornecer informação adicional sobre o contrato, como
a licença e o autor. A anotação `@Default()`indica 
que essa classe de contrato é a classe de contrato padrão. Ser capaz de marcar uma classe de contrato como classe de contrato padrão é util em alguns contratos inteligentes que têm multiplas classes de contratos.

Se você está usando uma implementação TypScript, existem anotações similares `@Contract(...)` que cumprem a mesma finalidade que em Java.

Para mais informações nas anotações validadas, consulte a documentação válida API.
* [API documentação para contratos inteligentes Java](https://hyperledger.github.io/fabric-chaincode-java/)
* [API documentação para contratos inteligentes Java Node.js](https://hyperledger.github.io/fabric-chaincode-node/)

A classe de contrato do Fabric também está valida para contratos inteligentes escritos em GO. Enquanto nós não discutimos o contrato GO API nesse tópico, usamos conceitos similares com o API para Java e JavaScript:
* [API documentação para contrato inteligente Go](https://github.com/hyperledger/fabric-contract-api-go)

As classes, anotações, e a classe `Context`, foram trazidas ao escopo anteriormente:

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


Nosso contrato de papel comercial usará recursos integrados dessas classes,tal como a invocação automática de metódo, um 
[contexto por transação](./transactioncontext.html),
[manipuladores de transações](./transactionhandler.html), e estado 
de classe compartilhada.

Observe também como o construtor da classe JavaScrip usa seu 
[superclasse](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/super)
para se inicializar com um [nome do contrato](./contractname.html):

```JavaScript
constructor() {
    super('org.papernet.commercialpaper');
}
```

Com a classe Java, o construtor está em branco pois o nome do contrato explícito pode ser especificado na anotação `@Contract(). Se ausente, então é usado a classe de nome. 

Mais importante, `org.papernet.commercialpaper`é muito descritivo
 -- esse contrato inteligente é a verdadeira definição de papel 
 comercial para toda organização PaperNet.

Normalmente existirá apenas um contrato inteligente por arquivo -- 
contratos tendem a ter diferentes ciclos de vida, o que torna-os 
sensíveis ao separá-los. No entanto, em alguns casos, multiplos 
contratos devem disponibilizar ajuda sintetica para as aplicações, 
exemplo `EuroBond`, `DollarBond`, `YenBond`, mas essencialmente fornecem a mesma função. Em todos os casos, contratos inteligentes e transações podem não ser ambiguos.

## Definição de transação

Dentro da classe, localize o método "problema".
<details open="true">
<summary>JavaScript</summary>
```JavaScript
problema assíncrono (ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {...}
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

A anotação Java `@Transaction` é usada para marcar o método com uma definição de transação; TypeScreipt tem uma anotação equivalente.

Esta função recebe um controle sempre que aparecer `issue` na transação comercial. 
Lembre-se de como o papel comercial 00001 foi criado 
com a seguinte transação:

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

Alteramos os nomes das variáveis para o estilo de programação, mas veja como essas
propriedades são mapeadas quase diretamente para as variáveis do método “issue”

O método `issue` é automaticamente controlado pelo contrato sempre que uma
aplicação faz um pedido de emissão de papel comercial. Os valores das propriedades de transação
são disponibilizados para o método por meio de variáveis correspondentes. 
Veja como uma aplicação é enviada para uma transação usando o Hyperledger
Fabric SDK em: [aplicação](./application.html) tópico, 
usando um simples programa de aplicação.

Você deve ter observado uma variável extra na definição **issue** -- `ctx`.
Chama-se [**transaction context**](./transactioncontext.html), é 
sempre primeiro. Por padrão, mantém per-contract e per-transaction como 
informação relevante para [lógica de transação](#transaction-logic).Por exemplo,
conteria o identificador de transação identificado da MagnetoCorp’s, 
emissão do certificado digital do usuário, bem como acesso à API do razão.

Veja como o contrato inteligente estende o contexto de transação 
padrão implementando seu próprio método `createContext()` ao em vez 
de aceitar a implementação padrão.

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


Este contexto estendido adiciona uma propriedade personalizada para o padrão:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
class CommercialPaperContext extends Context {

  constructor() {
    super();
    // All papers are held in a list of papers
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

Em breve veremos como `ctx.paperList`pode ser utilizada
posteriormente para ajudar a armazenar e recuperar toda transação 

comercial em Papernet.
Para solidificar seu entendimento na estrutura de transação de contrato inteligente, localize as definições de transação **buy** e **redeem**,
 e veja como eles são mapeados para suas transações comerciais.

A transação **buy**: 

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

The **redeem** transaction:

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

Nos dois casos, observe o 1:1 correspondente entre transação comercial e o metodo de definição de contrato inteligente.
Todas as funções de JavaScript usam o `async` e `await`

Todas as funções JavaScript usam `async` e `await`
[Palavras chaves](https://developer.mozilla.org/en-US/docs/Web/ JavaScript/Reference/Statements/async_function)que permitem que funções JavaScript sejam tratadas como se fossem chamadas funções síncronas. 


## Lógica de transação

Agora que você viu como a estrutura dos contratos são definidas, 
vamos focar na lógica por dentro do contrato inteligente.

Lembre-se da primeira transação **issue**:

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

It results in the **issue** method being passed control:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async issue(ctx, issuer, paperNumber, issueDateTime, maturityDateTime, faceValue) {

   // create an instance of the paper
  let paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime, faceValue);

  // Smart contract, rather than paper, moves paper into ISSUED state
  paper.setIssued();

  // Newly issued paper is owned by the issuer
  paper.setOwner(issuer);

  // Add the paper to the list of all similar commercial papers in the ledger world state
  await ctx.paperList.addPaper(paper);

  // Must return a serialized paper to caller of smart contract
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

    // create an instance of the paper
    CommercialPaper paper = CommercialPaper.createInstance(issuer, paperNumber, issueDateTime, maturityDateTime,
            faceValue,issuer,"");

    // Smart contract, rather than paper, moves paper into ISSUED state
    paper.setIssued();

    // Newly issued paper is owned by the issuer
    paper.setOwner(issuer);

    System.out.println(paper);
    // Add the paper to the list of all similar commercial papers in the ledger
    // world state
    ctx.paperList.addPaper(paper);

    // Must return a serialized paper to caller of smart contract
    return paper;
}
```
</details>


A lógica é simples: pegue as variáveis de entrada de transação, crie uma nova transação comercial `paper`, e adicione isto na lista 
com todos os papeis comerciais utilizados `paperList, e retorne a
nova transação comercial (serializado como um buffer) como resposta
de transação.

Veja como `paperList`é recuperado do contexto de transação para fornecer acesso a lista de transações comerciais. `issue()`, `buy()` e `redeem()` continuamente
Acesse novamente `ctx.paperList`para manter a lista de transações 
comerciais atualizada.

A lógica para a transação **buy** é um pouco mais elaborada:
<details open="true">
<summary>JavaScript</summary>
```JavaScript
async buy(ctx, issuer, paperNumber, currentOwner, newOwner, price, purchaseDateTime) {

  // Retrieve the current paper using key fields provided
  let paperKey = CommercialPaper.makeKey([issuer, paperNumber]);
  let paper = await ctx.paperList.getPaper(paperKey);

  // Validate current owner
  if (paper.getOwner() !== currentOwner) {
      throw new Error('Paper ' + issuer + paperNumber + ' is not owned by ' + currentOwner);
  }

  // First buy moves state from ISSUED to TRADING
  if (paper.isIssued()) {
      paper.setTrading();
  }

  // Check paper is not already REDEEMED
  if (paper.isTrading()) {
      paper.setOwner(newOwner);
  } else {
      throw new Error('Paper ' + issuer + paperNumber + ' is not trading. Current state = ' +paper.getCurrentState());
  }

  // Update the paper
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

    // Retrieve the current paper using key fields provided
    String paperKey = State.makeKey(new String[] { paperNumber });
    CommercialPaper paper = ctx.paperList.getPaper(paperKey);

    // Validate current owner
    if (!paper.getOwner().equals(currentOwner)) {
        throw new RuntimeException("Paper " + issuer + paperNumber + " is not owned by " + currentOwner);
    }

    // First buy moves state from ISSUED to TRADING
    if (paper.isIssued()) {
        paper.setTrading();
    }

    // Check paper is not already REDEEMED
    if (paper.isTrading()) {
        paper.setOwner(newOwner);
    } else {
        throw new RuntimeException(
                "Paper " + issuer + paperNumber + " is not trading. Current state = " + paper.getState());
    }

    // Update the paper
    ctx.paperList.updatePaper(paper);
    return paper;
}
```
</details>

Veja como a transação verifica `currentOwner`e que`paper`é `TRADING`
Antes de mudar o proprietário com `paper.setOwner(newOwner)`. O fluxo básico é
simples - verifique algumas condições, defina o novo proprietário, atualize  
a trasação comercial no livro razão, e devolva a transação comercial atualizada.
(serializado como um buffer) como a resposta da transação.

Por que você não vê se consegue entender a lógica da transação 
**redeem**?  

## Representando um objeto

Vimos como definir e implementar as transações **issue**, **buy** e 
**redeem** usando as classes `CommercialPaper`e `PaperList`.
Vamos encerrar este tópico vendo como essas classes funcionam.

Localize a classe `CommercialPaper`:

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


Esta classe contém a representação na memória do estado de uma transação comercial.
Veja como o método `createInstance` inicializa uma nova transação comercial com os 
parametros fornecidos:

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

Recall how this class was used by the **issue** transaction:

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

Veja como toda vez que a transação de emissão é chamada, uma nova instância na 
memória de uma transação comercial é criada contendoos dados de transação.

Alguns pontos importantes a serem observados:

  * A classe `CommercialPaper` estende a classe `State`. `State` é 
  uma
    classe definida pela aplicação que cria uma abstração comum 
    para o estado.
    Todos os estados tem uma classe de objeto de negócios que 
    representam, uma chave composta, 
    que pode ser serializada e desserializada, e assim por diante.
      `State` ajuda o nosso código a ser mais legível 
      quando estamos armazenando mais de um tipo de objeto de negócios 
      no razão. Examine a classe `State` e a classe `state.js`
    [file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/state.js).

 
  * Um papel calcula sua própria chave quando é criado -- esta chave será usada quando o razão for acessado. A chave é formada 
  por uma combinação de 
    `issuer` e `paperNumber`.

    ```JavaScript
    constructor(obj) {
      super(CommercialPaper.getClass(), [obj.issuer, obj.paperNumber]);
      Object.assign(this, obj);
    }
    ```


  * Um papel é movido para o estado `ISSUED` pela transação, não por uma classe de papel.
   Isso porque é o contrato inteligente que governa o ciclo de vida do estado do papel.
   Por exemplo, uma transação `import` pode criar um novo conjunto 
   de papéis imediatamente no estado `TRADING`.

O restante da classe `CommercialPaper` contém metodos auxiliares simples:

```JavaScript
getOwner() {
    return this.owner;
}
```

Lembre-se de como métodos como esse foram usados pelo contrato 
inteligente para mover a trasação comercial ao longo de seu ciclo 
de vida. Por exemplo, na transação **redeem** nós vimos:

```JavaScript
if (paper.getOwner() === redeemingOwner) {
  paper.setOwner(paper.getIssuer());
  paper.setRedeemed();
}
```

## Accesse o livro razão

Now locate the `PaperList` class in the `paperlist.js`
[file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/lib/paperlist.js):

```JavaScript
class PaperList extends StateList {
```

Esta classe de utilitário é usada para gerenciar todos as transações comerciais PaperNet
 no banco de dados Hyperledger  Fabric. As estruturas de dados PaperList estão descritas com mais 
 detalhes no: [architecture topic](./architecture.html).

Como a classe `CommercialPaper`, esta classe estende uma classe definida pela aplicação 
`StateList` que cria uma abstração comum para uma lista de estados
 -- neste caso toda transação comercial no PaperNet. 

O método `addPaper ()` é um verniz simples sobre o método `StateList.addState ()`
Método

```JavaScript
async addPaper(paper) {
  return this.addState(paper);
}
```

Você pode ver no `StateList.js`
[file](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/commercial-paper/organization/magnetocorp/contract/ledger-api/statelist.js)
Como a classe `StateList`usa o Fabric API `putState()` para escrever a transação comercial 
como base de dados no livro razão:

```JavaScript
async addState(state) {
  let key = this.ctx.stub.createCompositeKey(this.name, state.getSplitKey());
  let data = State.serialize(state);
  await this.ctx.stub.putState(key, data);
}
```

Todas as peças na base de dados do livro razão requerem estes dois elementos fundamentais:

* **Key**: `key` é formado com `createCompositeKey()` usando um     nome fixo e a chave
     de `state`. O nome foi atribuido quando o objeto `PaperList` foi construído,
     e `state.getSplitKey()` determina a chave única de cada estado.


 * **Data**: `data` é simplesmente a forma serelializada do estado da transação comercial,
   criado usando o método utilitário `State.
  serialize()`. A classe `State` serializa e desserializa dados usando JSON, 
  e a classe de objeto de negócios conforme  necessário, no nosso caso `CommercialPaper`, novamente foi  
  definido quando o objeto `PaperList` foi construído.


Observe como um `StateList`não armazena nada sobre um estado individual 
ou a lista total de estados -- ele delega tudo isso para o banco de dados de estado do Fabric.
Este é um padrão de desing importante - ele reduz a oportunidade de [ledger 
MVCC collisions](../readwrite.html) em Hyperledger Fabric.

Os métodos StateList `getState()` e `updateState()`funcionam de maneiras semelhantes.

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

Veja como eles usam as APIs do Fabric `putState()`, `getState()`e 
`createCompositeKey()` para acessar o livro razão. 
Vamos expandir este contrato inteligente mais tarde, para listar todos os papéis comerciais no paperNet --
 Como seria o método para implementar essa recuperação do razão?

É isso! Neste tópico, você entendeu como implementar o contrato inteligente para PaperNet. Você pode passar para o próximo subtópico para ver como um aplicativo chama o contrato inteligente usando o Fabric SDK.
<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
