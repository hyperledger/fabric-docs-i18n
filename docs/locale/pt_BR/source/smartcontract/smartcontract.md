# Contratos Inteligentes e Chaincode

**Audiência:** Arquitetos, desenvolvedores de aplicações e smart contracts, administradores

Da perspectiva de um desenvolvedor de aplicativos, um **contrato inteligente**, junto com o [livro-razão](../ledger/ledger.html), forma o 
coração de um sistema blockchain da Hyperledger Fabric. Enquanto um ledger contém fatos sobre o estado atual e histórico de um conjunto de 
objetos de negócios, um **contrato inteligente** define a lógica executável que gera novos fatos que são adicionados ao livro-razão. Um 
**chaincode** normalmente é usado pelos administradores para agrupar contratos inteligentes relacionados à confirmação, mas também pode ser 
usado para a programação de sistema de baixo nível da Fabric. Neste tópico, abordaremos por que existem **contratos inteligentes** ,
**código de chamada**, e como e quando usá-los.

Neste tópico, abordaremos:

* [What is a smart contract](#smart-contract)
* [A note on terminology](#terminology)
* [Smart contracts and the ledger](#ledger)
* [How to develop a smart contract](#developing)
* [The importance of endorsement policies](#endorsement)
* [Valid transactions](#valid-transactions)
* [Channels and chaincode definitions](#channels)
* [Communicating between smart contracts](#intercommunication)
* [What is system chaincode?](#system-chaincode)

## Contrato inteligente

Antes que as empresas possam negociar entre si, elas devem definir um conjunto comum de contratos que abranja termos, dados, regras, 
definições de conceitos e processos comuns. Tomados em conjunto, esses contratos estabelecem o **modelo de negócios** que governa todas as 
interações entre as partes envolvidas na transação.

![smart.diagram1](./smartcontract.diagram.01.png) *Um contrato inteligente define as regras entre diferentes organizações no código 
executável. Os aplicativos invocam um contrato inteligente para gerar transações registradas no livro-razão.*

Usando uma rede blockchain, podemos transformar esses contratos em programas executáveis ​​--- conhecidos na indústria como 
**contratos inteligentes** --- para abrir uma ampla variedade de novas possibilidades. Isso ocorre porque um contrato inteligente pode 
implementar as regras de governança para **qualquer** tipo de objeto de negócios, para que possam ser aplicadas automaticamente quando o 
contrato inteligente for executado. Por exemplo, um contrato inteligente pode garantir que uma nova entrega de carro seja feita dentro de um 
prazo especificado ou que os fundos sejam liberados de acordo com termos previamente combinados, melhorando o fluxo de mercadorias ou 
capital, respectivamente. Mais importante, no entanto, a execução de um contrato inteligente é muito mais eficiente do que um processo de 
negócios humano manual.

No [diagrama acima](#contrato-inteligente), podemos ver como duas organizações, `ORG1` e` ORG2` definiram um contrato inteligente de `car` 
para `query`, `transfer` and `update` carros. Os aplicativos dessas organizações invocam esse contrato inteligente para executar uma 
etapa acordada em um processo comercial, por exemplo, para transferir a propriedade de um carro específico de `ORG1` para` ORG2`.

## Terminologia

Os usuários da Hyperledger Fabric geralmente usam os termos **contrato inteligente** e **chaincode** de forma intercambiável. Em geral, um 
contrato inteligente define a **lógica da transação** que controla o ciclo de vida de um objeto de negócios contido no estado global. Em 
seguida, é empacotado em um chaincode que é implantado em uma rede blockchain. Pense nos contratos inteligentes como transações
controladoras, enquanto o chaincode governa como os contratos inteligentes são compactados para implantação.

![smart.diagram2](./smartcontract.diagram.02.png) *Um contrato inteligente é definido dentro de um chaincode. Vários contratos inteligentes 
podem ser definidos no mesmo código. Quando um chaincode é implantado, todos os contratos inteligentes nele são disponibilizados para os
aplicativos.*

No diagrama, podemos ver um chaincode `vehicle` que contém três contratos inteligentes: `cars`, `boats` e `trucks`. Também podemos ver 
um chaincode `insurance` que contém quatro contratos inteligentes: `policy`, `liability`, `syndication` e `securitization`. Nos dois casos, 
esses contratos cobrem aspectos-chave do processo de negócios relacionados a veículos e seguros. Neste tópico, usaremos o contrato `car` 
como exemplo. Podemos ver que um contrato inteligente é um programa específico de domínio relacionado a processos de negócios específicos, 
enquanto um chaincode é um contêiner técnico de um grupo de contratos inteligentes relacionados.

## Livro-Razão

No nível mais simples, uma blockchain registra as transações imutáveis que atualizam estados em um livro-razão. Um contrato inteligente 
acessa programaticamente duas partes distintas do livro-razão --- uma **blockchain**, que registra o histórico imutável de todas as 
transações e um **estado global**, que armazena um cache do valor atual desses estados, geralmente o que se busca saber é o valor atual de 
um objeto.

Contratos inteligentes primariamente executam operações de **put**, **get** e **delete** no estado global e também podem consultar os 
registros imutáveis de transações na blockchain.

* **get** normalmente representa uma consulta para recuperar informações sobre o estado atual de um objeto de negócios.
* **put** normalmente cria um novo objeto de negócios ou modifica um existente no estado global do livro-razão.
* **delete** normalmente representa a remoção de um objeto de negócios do estado atual do razão, mas não seu histórico.

Os contratos inteligentes têm muitas [APIs](../developapps/transactioncontext.html#structure) disponíveis para eles. Em todos os casos, se 
as transações criam, leem, atualizam ou excluem objetos de negócios no estado global, a blockchain manterá um 
[registro imutável](../ledger/ledger.html) dessas alterações.

## Desenvolvimento

Contratos inteligentes são o foco do desenvolvimento de aplicativos e, como vimos, um ou mais contratos inteligentes podem ser definidos em 
um único chaincode. A implantação de um chaincode em uma rede disponibiliza todos os seus contratos inteligentes para as organizações nessa 
rede. Isso significa que apenas os administradores precisam se preocupar com o chaincode, todo mundo pode pensar em termos de contratos 
inteligentes.

No coração de um contrato inteligente, há um conjunto de definições de `transação`. Por exemplo, veja 
[`fabcar.js`](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/fabcar/javascript/lib/fabcar.js#L93), onde você pode ver 
uma transação de um contrato inteligente que cria um carro novo:

```javascript
async createCar(ctx, carNumber, make, model, color, owner) {

    const car = {
        color,
        docType: 'car',
        make,
        model,
        owner,
    };

    await ctx.stub.putState(carNumber, Buffer.from(JSON.stringify(car)));
}
```

Você pode aprender mais sobre o contrato inteligente **Fabcar** no tutorial [Escrevendo seu primeiro aplicativo](../write_first_app.html).

Um contrato inteligente pode descrever uma matriz quase infinita de casos de uso de negócios relacionados à imutabilidade de dados na tomada 
de decisão multi-organizacional. O trabalho de um desenvolvedor de contrato inteligente é assumir um processo de negócios existente que 
possa governar valores financeiros ou condições de entrega e expressá-lo como um contrato inteligente em uma linguagem de programação como 
JavaScript, Go ou Java. As habilidades legais e técnicas necessárias para converter séculos de linguagem jurídica em linguagem de 
programação são cada vez mais praticadas por **auditores de contratos inteligentes**. Você pode aprender sobre como projetar e desenvolver 
um contrato inteligente no [tópico Desenvolvendo aplicativos](../developapps/developing_applications.html).

## Endosso

Associada a todos os chaincodes, há uma política de endosso que se aplica a todos os contratos inteligentes definidos nele. Uma política de 
endosso é muito importante, indica quais organizações em uma rede blockchain devem assinar uma transação gerada por um determinado contrato 
inteligente para que essa transação seja declarada **válida**.

![smart.diagram3](./smartcontract.diagram.03.png) *Todo contrato inteligente possui uma política de endosso associada. Esta política de 
endosso identifica quais organizações devem aprovar transações geradas pelo contrato inteligente antes que essas transações possam ser 
identificadas como válidas.*

Um exemplo de política de endosso pode definir que três das quatro organizações que participam de uma rede blockchain devem assinar uma 
transação antes de serem consideradas **válidas**. Todas as transações, sejam **válidas** ou **inválidas**, são adicionadas a um livro-razão 
distribuído, mas apenas as transações **válidas** atualizam o estado global.

Se uma política de endosso especificar que mais de uma organização deve assinar uma transação, o contrato inteligente deve ser executado por 
um conjunto suficiente de organizações para que uma transação válida seja gerada. No exemplo [acima](#endosso), uma transação de contrato 
inteligente para `transferir` um carro precisaria ser executada e assinada por `ORG1` e `ORG2` para que ele fosse válido.

Políticas de endosso são o que torna a Hyperledger Fabric diferente de outras blockchains como Ethereum ou Bitcoin. Nesses sistemas, 
transações válidas podem ser geradas por qualquer nó da rede. O Hyperledger Fabric modela mais realisticamente o mundo real, as transações 
devem ser validadas por organizações confiáveis ​​em uma rede. Por exemplo, uma organização governamental deve assinar uma transação válida de 
`issueIdentity` ou o comprador e o vendedor de um carro devem assinar uma transação de transferência de carro. As políticas de endosso são 
projetadas para permitir que o Hyperledger Fabric modele melhor esses tipos de interações no mundo real.

Por fim, as políticas de endosso são apenas um exemplo de [política](../access_control.html#policies) no Hyperledger Fabric. Outras 
políticas podem ser definidas para identificar quem pode consultar ou atualizar o livro-razão, ou adicionar ou remover participantes da rede. 
Em geral, as políticas devem ser previamente acordadas pelo consórcio de organizações em uma rede blockchain, embora não sejam imutáveis. De 
fato, as próprias políticas podem definir as regras pelas quais elas podem ser alteradas. E, embora seja um tópico avançado, também é 
possível definir [política de endosso personalizada](../pluggable_endorsement_and_validation.html) que governa além daquelas fornecidas pelo 
Fabric.

## Valid transactions

When a smart contract executes, it runs on a peer node owned by an organization
in the blockchain network. The contract takes a set of input parameters called
the **transaction proposal** and uses them in combination with its program logic
to read and write the ledger. Changes to the world state are captured as a
**transaction proposal response** (or just **transaction response**) which
contains a **read-write set** with both the states that have been read, and the
new states that are to be written if the transaction is valid. Notice that the
world state **is not updated when the smart contract is executed**!

![smart.diagram4](./smartcontract.diagram.04.png) *All transactions have an
identifier, a proposal, and a response signed by a set of organizations. All
transactions are recorded on the blockchain, whether valid or invalid, but only
valid transactions contribute to the world state.*

Examine the `car transfer` transaction. You can see a transaction `t3` for a car
transfer between `ORG1` and `ORG2`. See how the transaction has input `{CAR1,
ORG1, ORG2}` and output `{CAR1.owner=ORG1, CAR1.owner=ORG2}`, representing the
change of owner from `ORG1` to `ORG2`. Notice how the input is signed by the
application's organization `ORG1`, and the output is signed by *both*
organizations identified by the endorsement policy, `ORG1` and `ORG2`.  These
signatures were generated by using each actor's private key, and mean that
anyone in the network can verify that all actors in the network are in agreement
about the transaction details.

A transaction that is distributed to all peer nodes in the network is
**validated** in two phases by each peer. Firstly, the transaction is checked to
ensure it has been signed by sufficient organizations according to the endorsement
policy. Secondly, it is checked to ensure that the current value of the world state
matches the read set of the transaction when it was signed by the endorsing peer
nodes; that there has been no intermediate update. If a transaction passes both
these tests, it is marked as **valid**. All transactions are added to the
blockchain history, whether **valid** or **invalid**, but only **valid**
transactions result in an update to the world state.

In our example, `t3` is a valid transaction, so the owner of `CAR1` has been
updated to `ORG2`. However, `t4` (not shown) is an invalid transaction, so while
it was recorded in the ledger, the world state was not updated, and `CAR2`
remains owned by `ORG2`.

Finally, to understand how to use a smart contract or chaincode with world
state, read the [chaincode namespace
topic](../developapps/chaincodenamespace.html).

## Channels

Hyperledger Fabric allows an organization to simultaneously participate in
multiple, separate blockchain networks via **channels**. By joining multiple
channels, an organization can participate in a so-called **network of networks**.
Channels provide an efficient sharing of infrastructure while maintaining data
and communications privacy. They are independent enough to help organizations
separate their work traffic with different counterparties, but integrated enough
to allow them to coordinate independent activities when necessary.

![smart.diagram5](./smartcontract.diagram.05.png) *A channel provides a
completely separate communication mechanism between a set of organizations. When
a chaincode definition is committed to a channel, all the smart contracts within
the chaincode are made available to the applications on that channel.*

While the smart contract code is installed inside a chaincode package on an
organizations peers, channel members can only execute a smart contract after
the chaincode has been defined on a channel. The **chaincode definition** is a
struct that contains the parameters that govern how a chaincode operates. These
parameters include the chaincode name, version, and the endorsement policy.
Each channel member agrees to the parameters of a chaincode by approving a
chaincode definition for their organization. When a sufficient number of
organizations (a majority by default) have approved to the same chaincode
definition, the definition can be committed to the channel. The smart contracts
inside the chaincode can then be executed by channel members, subject to the
endorsement policy specified in the chaincode definition. The endorsement policy
applies equally to all smart contracts defined within the same chaincode.

In the example [above](#channels), a `car` contract is defined on the `VEHICLE`
channel, and an `insurance` contract is defined on the `INSURANCE` channel.
The chaincode definition of `car` specifies an endorsement policy that requires
both `ORG1` and `ORG2` to sign transactions before they can be considered valid.
The chaincode definition of the `insurance` contract specifies that only `ORG3`
is required to endorse a transaction. `ORG1` participates in two networks, the
`VEHICLE` channel and the `INSURANCE` network, and can coordinate activity with
`ORG2` and `ORG3` across these two networks.

The chaincode definition provides a way for channel members to agree on the
governance of a chaincode before they start using the smart contract to
transact on the channel. Building on the example above, both `ORG1` and `ORG2`
want to endorse transactions that invoke the `car` contract. Because the default
policy requires that a majority of organizations approve a chaincode definition,
both organizations need to approve an endorsement policy of `AND{ORG1,ORG2}`.
Otherwise, `ORG1` and `ORG2` would approve different chaincode definitions and
would be unable to commit the chaincode definition to the channel as a result.
This process guarantees that a transaction from the `car` smart contract needs
to be approved by both organizations.

## Intercommunication

A Smart Contract can call other smart contracts both within the same
channel and across different channels. It this way, they can read and write
world state data to which they would not otherwise have access due to smart
contract namespaces.

There are limitations to this inter-contract communication, which are described
fully in the [chaincode namespace](../developapps/chaincodenamespace.html#cross-chaincode-access) topic.

## System chaincode

The smart contracts defined within a chaincode encode the domain dependent rules
for a business process agreed between a set of blockchain organizations.
However, a chaincode can also define low-level program code which corresponds to
domain independent *system* interactions, unrelated to these smart contracts
for business processes.

The following are the different types of system chaincodes and their associated
abbreviations:

* `_lifecycle` runs in all peers and manages the installation of chaincode on
  your peers, the approval of chaincode definitions for your organization, and
  the committing of chaincode definitions to channels. You can read more about
  how `_lifecycle` implements the Fabric chaincode lifecycle [process](../chaincode_lifecycle.html).

* Lifecycle system chaincode (LSCC) manages the chaincode lifecycle for the
  1.x releases of Fabric. This version of lifecycle required that chaincode be
  instantiated or upgraded on channels. You can still use LSCC to manage your
  chaincode if you have the channel application capability set to V1_4_x or below.

* **Configuration system chaincode (CSCC)** runs in all peers to handle changes to a
  channel configuration, such as a policy update.  You can read more about this
  process in the following chaincode
  [topic](../configtx.html#configuration-updates).

* **Query system chaincode (QSCC)** runs in all peers to provide ledger APIs which
  include block query, transaction query etc. You can read more about these
  ledger APIs in the transaction context
  [topic](../developapps/transactioncontext.html).

* **Endorsement system chaincode (ESCC)** runs in endorsing peers to
  cryptographically sign a transaction response. You can read more about how
  the ESCC implements this [process](../peers/peers.html#phase-1-proposal).

* **Validation system chaincode (VSCC)** validates a transaction, including checking
  endorsement policy and read-write set versioning. You can read more about the
  VSCC implements this [process](../peers/peers.html#phase-3-validation).

It is possible for low level Fabric developers and administrators to modify
these system chaincodes for their own uses. However, the development and
management of system chaincodes is a specialized activity, quite separate from
the development of smart contracts, and is not normally necessary. Changes to
system chaincodes must be handled with extreme care as they are fundamental to
the correct functioning of a Hyperledger Fabric network. For example, if a
system chaincode is not developed correctly, one peer node may update its copy
of the world state or blockchain differently compared to another peer node. This
lack of consensus is one form of a **ledger fork**, a very undesirable situation.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
