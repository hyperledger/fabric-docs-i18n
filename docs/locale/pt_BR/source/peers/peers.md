# Pares

Uma rede blockchain é composta principalmente por um conjunto de *nós de pares* (ou, simplesmente, *pares*). Os pares são um elemento 
fundamental da rede porque hospedam os livros-razão e o contratos inteligentes. Lembre-se de que um libro-razão registra de forma imutável 
todas as transações geradas por contratos inteligentes (que na Hyperledger Fabric estão chamados de *chaincode*, mais sobre isso a frente). 
Contratos inteligentes e livros-razaõ são usados para encapsular os processos *compartilhados* e as informações *compartilhadas* em uma 
rede, respectivamente. Esses aspectos de um par os tornam um bom ponto de partida para entender uma rede Fabric.

Outros elementos da rede blockchain são obviamente importantes: livros-razão e contratos inteligentes, ordens, políticas, canais, 
aplicativos, organizações, identidades e associação, você pode ler mais sobre eles em suas próprias seções. Esta seção se concentra nos 
pares e no relacionamento deles com os outros elementos em uma rede Fabric.

![Peer1](./peers.diagram.1.png)

*Uma rede blockchain é composta por nós pares, cada um dos quais pode conter cópias de livros-razão e cópias de contratos inteligentes. 
Neste exemplo, a rede N consiste em pares P1, P2 e P3, cada um dos quais mantém sua própria instância do livro-razão distribuída L1. P1, P2 
e P3 usam o mesmo chaincode, S1, para acessar sua cópia desse livro-razão distribuído*.

Os pares podem ser criados, iniciados, parados, reconfigurados e até excluídos. Eles expõem um conjunto de APIs que permitem que 
administradores e aplicativos interajam com os serviços que eles fornecem. Aprenderemos mais sobre esses serviços nesta seção.

### Uma palavra sobre terminologia

A Fabric implementa **contratos inteligentes** com um conceito de tecnologia que chama **chaincode** --- simplesmente um trecho de código 
que acessa o livro-razão, escrito em uma das linguagens de programação suportadas. Neste tópico, geralmente usaremos o termo **chaincode**, 
mas fique à vontade para lê-lo como **contrato inteligente** se você estiver mais acostumado a esse termo. É a mesma coisa! Se você quiser 
saber mais sobre chaincode e contratos inteligentes, consulte nossa 
[documentação sobre contratos inteligentes e chaincode](../smartcontract/smartcontract.html).

## Livros-Razão e Chaincode

Vejamos um par com mais detalhes. Podemos ver que é o ponto que hospeda o livro-razão e o chaincode. Mais precisamente, o par realmente 
hospeda *instâncias* do livro-razão e *instâncias* do chaincode. Observe que isso fornece uma redundância deliberada em uma rede Fabric 
--- evita pontos únicos de falha. Aprenderemos mais sobre a natureza distribuída e descentralizada de uma rede blockchain posteriormente 
nesta seção.

![Peer2](./peers.diagram.2.png)

*Um par hospeda instâncias do livro-razão e instâncias de chaincode. Neste exemplo, P1 hospeda uma instância do livro-razão L1 e uma 
instância do chaincode S1. Pode haver muitos livros-razão e chaincodes hospedados em um par individual.*

Como um par é um *host* para livros-razão e chaincodes, aplicativos e administradores devem interagir com um par se quiserem acessar esses 
recursos. É por isso que os pares são considerados os blocos de construção mais fundamentais de uma rede Fabric. Quando um par é criado pela 
primeira vez, ele não possui livros-razão nem chaincodes. Veremos mais adiante como os livros-razão são criados e como os chaincodes são 
instalados nos pares.

### Múltiplos livros-razão

Um par é capaz de hospedar mais de um livro-razão, o que é útil porque permite um design de sistema flexível. A configuração mais simples é 
um par gerenciar um único livro-razão, mas é absolutamente apropriado que ele hospede dois ou mais livros quando necessário.

![Peer3](./peers.diagram.3.png)

*Um par que hospeda vários livros-razão. Os pares hospedam um ou mais livros-razão, e cada livro-razão tem zero ou mais chaincodes que se 
aplicam a eles. Neste exemplo, podemos ver que o par P1 hospeda os livros-razão L1 e L2. O razão L1 é acessado usando o chaincode S1. O 
razão L2, por outro lado, pode ser acessado usando os chaincode S1 e S2.*

Embora seja perfeitamente possível que um par hospede uma instância do livro-razão sem hospedar nenhum chaincode que acesse esse 
livro-razão, é raro que os pares sejam configurados dessa maneira. A grande maioria dos pares terá pelo menos um chaincode instalado, que 
pode consultar ou atualizar as instâncias do próprio livro-razão. Vale mencionar de passagem que, independentemente de os usuários terem 
instalado ou não um chaincode para uso em aplicativos externos, os pares também têm **chaincodes especiais** sempre presentes. Estes não são 
discutidos em detalhes neste tópico.

### Múltiplos Chaincodes

Não há um relacionamento fixo entre o número de livros-razão que um par possui e o número de chaincodes que podem acessar esse livro. Um par 
pode ter muitos chaincodes e muitos livros-razão à sua disposição.

![Peer4](./peers.diagram.4.png)

*Um exemplo de um par que hospeda vários chaincodes. Cada livro-razão pode ter muitos chaincodes de acesso que o acessam. Neste exemplo, 
podemos ver que o par P1 hospeda os livros-razão L1 e L2, onde L1 é acessado pelos chaincode S1 e S2 e L2 é acessado por S1 e S3. Podemos 
ver que S1 pode acessar L1 e L2.*

Veremos um pouco mais adiante por que o conceito de **canais** na Fabric é importante ao hospedar vários livros-razão ou vários chaincodes 
em um par.

## Aplicativos e Pares

Agora vamos mostrar como os aplicativos interagem com os pares para acessar o livro-razão. As interações de consulta no livro-razão envolvem 
um simples diálogo de três etapas entre um aplicativo e um par, as interações de atualização do livro-razão são um pouco mais exigentes e
demandas duas etapas extras. Simplificamos um pouco essas etapas para ajudá-lo a começar com a Fabric, mas não se preocupe --- o mais 
importante é entender a diferença nas interações entre pares de aplicativos para consulta do livro-razão em comparação com modelos de 
transação de atualização de livro-razão.

Os aplicativos sempre se conectam com os pares quando precisam acessar os livros-razão e chaincodes. O Fabric Software Development Kit (SDK) 
facilita isso para os programadores --- suas APIs permitem que os aplicativos se conectem aos pares, invoquem chaincodes para gerar 
transações, enviar transações à rede solicitada, validadar e confirmadar no livro-razão distribuído e receber eventos quando esse processo 
estiver concluído.

Por meio de uma conexão com o par, os aplicativos podem executar chaincodes para consultar ou atualizar um livro-razão. O resultado de uma 
transação de consulta do livro-razão é retornado imediatamente, enquanto as atualizações do razão envolvem uma interação mais complexa entre 
aplicativos, pares e ordens. Vamos investigar isso com mais detalhes.

![Peer6](./peers.diagram.6.png)

*Os pares, em conjunto com os ordenadores, garantem que o livro-razão seja mantido atualizado em todos os pares. Neste exemplo, o aplicativo 
A se conecta a P1 e chama o chaincode S1 para consultar ou atualizar o livro-razão L1. P1 chama S1 para gerar uma resposta da 
proposta que contém um resultado da proposta de consulta ou uma atualização do livro-razão. O aplicativo A recebe a resposta da proposta e, 
para consultas, o processo está concluído. Para atualizações, A cria uma transação com todas as respostas, que são enviadas à O1 para 
ordenar. O1 coleta transações da rede em blocos e as distribui a todos os pares, incluindo P1. P1 valida a transação antes de confirmar com 
L1. Depois que L1 é atualizado, P1 gera um evento, recebido por A, para indicar a conclusão.*

Um par pode retornar os resultados de uma consulta para um aplicativo imediatamente, pois todas as informações necessárias para satisfazer a 
consulta estão na cópia local do livro-razão do par. Os pares nunca consultam outros para responder a uma consulta de um aplicativo. Os 
aplicativos podem, no entanto, conectar-se a um ou mais pares para emitir uma consulta, por exemplo, para corroborar um resultado entre 
vários pares ou recuperar um resultado mais atualizado de outro par, se houver suspeita de que as informações possam estar desatualizadas. 
No diagrama, você pode ver que a consulta do livro-razão é um processo simples de três etapas.

Uma transação de atualização inicia da mesma maneira que uma transação de consulta, mas possui duas etapas extras. Embora os aplicativos de 
atualização do livro-razão também se conectem aos pares para chamar um chaincode, diferente dos aplicativos de consulta do livro-razão, um 
par individual não pode executar uma atualização do livro-razão no momento, porque outros pares devem primeiro concordar com a alteração 
--- em um processo chamado **consenso**. Portanto, os pares retornam ao aplicativo uma **proposta** de atualização --- que esse parceiro 
aplicaria, mediante acordo prévio de outros pares. A primeira etapa extra --- etapa quatro --- exige que os aplicativos enviem um conjunto 
apropriado de atualizações propostas correspondentes para toda a rede de pares como uma transação para compromisso com seus respectivos 
livros-razão. Isso é alcançado pelo aplicativo usando um **ordenador** para empacotar transações em blocos e distribuí-las para toda a rede 
de pares, onde elas podem ser verificadas antes de serem aplicadas à cópia local do livro-razão de cada par. Como todo esse processamento de 
pedidos leva algum tempo para ser concluído (segundos), o aplicativo é notificado de forma assíncrona, conforme mostrado na etapa cinco.

Posteriormente nesta seção, você aprenderá mais sobre a natureza detalhada desse processo de ordens --- e para uma visão realmente detalhada 
desse processo, consulte o tópico [Fluxo de transações](../txflow.html).

## Pares e Canais

Embora esta seção seja sobre pares e não canais, vale a pena dedicar um pouco de tempo para entender como os pares interagem entre si e com 
aplicativos via *canais* --- um mecanismo pelo qual um conjunto de componentes dentro de uma rede blockchain pode se comunicar e 
transacionar *de forma privada*.

Esses componentes geralmente são nós de pares, nós de ordens e aplicativos, e ao ingressar em um canal, eles concordam em colaborar para 
compartilhar e gerenciar coletivamente cópias idênticas do razão associado a esse canal. Conceitualmente, você pode pensar em canais como 
sendo semelhantes a grupos de amigos (embora os membros de um canal certamente não precisem ser amigos!). Uma pessoa pode ter vários grupos 
de amigos, com cada grupo tendo atividades que realiza juntos. Esses grupos podem ser totalmente separados (um grupo de amigos de trabalho 
em comparação com um grupo de amigos de hobby) ou pode haver algum cruzamento entre eles. No entanto, cada grupo é sua própria entidade, com 
suas próprias "regras".

![Peer5](./peers.diagram.5.png)

Os canais permitem que um conjunto específico de pares e aplicativos se comuniquem entre si em uma rede blockchain. Neste exemplo, o 
aplicativo A pode se comunicar diretamente com os pares P1 e P2 usando o canal C. Você pode pensar no canal como um caminho para a 
comunicação entre aplicativos e pares específicos. (Para simplificar, as ordens não são mostradas neste diagrama, mas devem estar presentes 
em uma rede que funcione.)*

Vemos que os canais não existem da mesma maneira que os pares --- é mais apropriado pensar em um canal como uma estrutura lógica formada por 
uma coleção de pares físicos. *É vital entender esse ponto --- os pares fornecem o ponto de controle para acesso e gerenciamento de canais*.

## Pares e organizações

Agora que você conhece os pares e o relacionamento deles com os livros-razão, chaincodes e canais, poderá ver como várias organizações se 
reúnem para formar uma rede blockchain.

As redes Blockchain são administradas por um conjunto de organizações, e não por uma única organização. Os pares são fundamentais para a 
construção desse tipo de rede distribuída, porque pertencem a --- e são os pontos de conexão da rede para --- essas organizações.

<a name="Peer8"></a>
![Peer8](./peers.diagram.8.png)

*Pares em uma rede blockchain com várias organizações. A rede blockchain é construída a partir de pares pertencentes e suportados por 
diferentes organizações. Neste exemplo, vemos quatro organizações contribuindo com oito pares para formar uma rede. O canal C conecta cinco 
desses pares na rede N --- P1, P3, P5, P7 e P8. Os outros pares pertencentes a essas organizações não ingressaram neste canal, mas 
geralmente estão associados a pelo menos um outro canal. Os aplicativos que foram desenvolvidos por uma organização específica se conectam 
aos pares de sua própria organização e aos de diferentes organizações. Novamente, por simplicidade, o nó do ordenador não é mostrado neste 
diagrama.

É realmente importante que você possa ver o que está acontecendo na formação de uma rede blockchain. *A rede é formada e gerenciada pelas 
várias organizações que contribuem com recursos*. Pares são os recursos que estamos discutindo neste tópico, mas os recursos que uma 
organização fornece são mais do que apenas pares. Há um princípio em ação aqui --- a rede literalmente não existe sem as organizações 
contribuírem com seus recursos individuais para uma rede coletiva. Além disso, a rede cresce e diminui com os recursos fornecidos por essas 
organizações colaboradoras.

Você pode ver que (além do serviço de ordens) não existem recursos centralizados --- no [exemplo acima](#Peer8), a rede **N** não existiria 
se as organizações não contribuíssem com seus pares. Isso reflete o fato de que a rede não existe em nenhum sentido significativo, a menos e 
até que as organizações contribuam com os recursos que a formam. Além disso, a rede não depende de nenhuma organização individual 
--- continuará a existir enquanto uma organização permanecer, independentemente de outras organizações que possam ir e vir. Este é o cerne 
do que significa descentralizar uma rede.

Aplicativos em diferentes organizações, como no [exemplo acima](#Peer8), podem ou não ser os mesmos. Isso porque depende inteiramente de uma 
organização a maneira como seus aplicativos processam as cópias de seus pares do livro-razão. Isso significa que a lógica do aplicativo e da 
apresentação pode variar de organização para organização, mesmo que seus respectivos pares hospedem exatamente os mesmos dados no 
livro-razão.

Os aplicativos se conectam aos pares em sua organização ou de outra organização, dependendo da natureza da interação com o livro-razão 
necessária. Para interações entre consulta e livro-razão, os aplicativos geralmente se conectam aos pares da própria organização. Para 
interações de atualizaão do livro-razão, veremos mais adiante por que os aplicativos precisam se conectar aos pares que representam *todas* 
as organizações necessárias para endossar a atualizar o livro-razão.

## Pares e Identidade

Agora que você viu como pares de diferentes organizações se reúnem para formar uma rede blockchain, vale a pena gastar algum tempo para 
entender como os pares são atribuídos às organizações por seus administradores.

Os pares têm uma identidade atribuída a eles por meio de um certificado digital de uma autoridade de certificação específica. Você pode ler
muito mais sobre como os certificados digitais X.509 funcionam em outras partes deste guia, mas, por enquanto, pense em um certificado 
digital como um cartão de identificação que fornece muitas informações verificáveis sobre um par. *Todos os pares na rede recebem um 
certificado digital de um administrador da organização proprietária*.

![Peer9](./peers.diagram.9.png)

*Quando um par se conecta a um canal, seu certificado digital identifica sua organização proprietária por meio de um MSP do canal. Neste 
exemplo, P1 e P2 têm identidades emitidas por CA1. O canal C determina, a partir de uma política em sua configuração de canal, que as 
identidades do CA1 devem ser associadas ao Org1 usando o ORG1.MSP. Da mesma forma, P3 e P4 são identificados pelo ORG2.MSP como parte da 
Org2.*

Sempre que um par se conecta usando um canal a uma rede blockchain, *uma política na configuração do canal usa a identidade do par para 
determinar seus direitos.* O mapeamento da identidade para a organização é fornecido por um componente chamado *Membership Service Provider* 
(MSP) --- determina como um par é atribuído a uma função específica em uma organização específica e, consequentemente, obtém acesso adequado 
aos recursos da blockchain. Além disso, um par pode pertencer apenas a uma única organização e, portanto, está associado a um único MSP. 
Aprenderemos mais sobre controle de acesso por pares posteriormente nesta seção, e há uma seção inteira sobre MSPs e políticas de controle
de acesso em outras partes deste guia. Mas, por enquanto, pense em um MSP como fornecendo ligação entre uma identidade individual e uma 
função organizacional específica em uma rede blockchain.

Uma pequena digressão, pares e *tudo o que interage com uma rede blockchain adquirem sua identidade organizacional a partir de seu 
certificado digital e de um MSP*. Pares, aplicativos, usuários finais, administradores e ordens devem ter uma identidade e um MSP associado 
se quiserem interagir com uma rede blockchain. *Damos um nome a todas as entidades que interagem com uma rede blockchain usando uma 
identidade --- um `principal`*. Você pode aprender muito mais sobre `principals` e organizações em outras partes deste guia, mas por 
enquanto, você sabe mais que o suficiente para continuar entendendo de pares!

Por fim, observe que não é realmente importante onde o par está fisicamente localizado --- ele pode residir na nuvem ou em um data center 
pertencente a uma das organizações ou em uma máquina local --- é o certificado digital associado que o identifica como pertencente a uma 
organização específica. No nosso exemplo acima, o P3 pode estar hospedado no data center da Org1, mas desde que o certificado digital 
associado a ele seja emitido pelo CA2, ele pertence ao Org2.

## Pares e Ordenadores

Vimos que os pares formam a base de uma rede blockchain, hospedando livros-razão e contratos inteligentes que podem ser consultados e atualizados pelos aplicativos conectados aos pares. No entanto, o mecanismo pelo qual os aplicativos e os pares interagem entre si para garantir que o registro de todos 
os pares seja mantido consistente é mediado por nós especiais chamados *ordenadores*, e é para esses nós que agora voltamos nossa atenção.

Uma transação de atualização é bem diferente de uma transação de consulta porque um único par não pode, por si só, atualizar o livro-razão 
--- a atualização requer o consentimento de outros pares na rede. Um par exige que outros na rede aprovem uma atualização do livro-razão 
antes de poder ser aplicada ao livro-razão local de um par. Esse processo é chamado de *consenso*, que leva muito mais tempo para ser 
concluído do que uma simples consulta. Porém, quando todos os pares necessários para aprovar a transação o fizerem e a transação for 
confirmada no livro-razão, os pares notificarão seus aplicativos conectados que o razão foi atualizado. Você verá muito mais detalhes sobre 
como pares e ordenadores gerenciam o processo de consenso nesta seção.

Especificamente, os aplicativos que desejam atualizar o livro-razão estão envolvidos em um processo trifásico, o que garante que todos os 
pares de uma rede blockchain mantenham seus registros consistentes entre si.

* Na primeira fase, os aplicativos trabalham com um subconjunto de *pares endossantes*, cada um dos quais fornece um endosso da proposta de
  atualização do livro-razão pelo aplicativo, mas não aplica a atualização proposta à sua cópia do livro-razão.
* Na segunda fase, esses endossos separados são coletados como transações e empacotados em blocos.
* Na terceira e última fase, esses blocos são distribuídos de volta para todos os pares, e cada transação é validada antes de serem 
  registradas na cópia do livro-razão desse par.

Como você verá, os nós de ordens são centrais nesse processo, portanto, vamos investigar um pouco mais detalhadamente como aplicativos e 
pares usam as ordens para gerar atualizações do livro-razão que podem ser aplicadas de maneira consistente a um livro-razão replicado e 
distribuído.

### Fase 1: proposta

A fase 1 do fluxo de trabalho da transação envolve uma interação entre um aplicativo e um conjunto de pares --- não envolve ordenadores. 
A fase 1 refere-se apenas a um aplicativo que solicita que pares de diferentes organizações concordem com o resultado proposto pela chamada 
do chaincode.

Para iniciar a fase 1, os aplicativos geram uma proposta de transação que eles enviam para cada um dos conjuntos de pares necessários para 
aprovação. Cada um desses *pares endossante * executa independentemente um chaincode usando a proposta de transação para gerar uma resposta 
da proposta de transação. Ele não aplica essa atualização ao livro-razão, simplesmente a assina e a devolve ao aplicativo. Depois que o 
aplicativo recebe um número suficiente de respostas da proposta assinadas, a primeira fase do fluxo da transação é concluída. Vamos examinar 
esta fase um pouco mais detalhadamente.

![Peer10](./peers.diagram.10.png)

*Transaction proposals are independently executed by peers who return endorsed
proposal responses. In this example, application A1 generates transaction T1
proposal P which it sends to both peer P1 and peer P2 on channel C. P1 executes
S1 using transaction T1 proposal P generating transaction T1 response R1 which
it endorses with E1. Independently, P2 executes S1 using transaction T1
proposal P generating transaction T1 response R2 which it endorses with E2.
Application A1 receives two endorsed responses for transaction T1, namely E1
and E2.*

Initially, a set of peers are chosen by the application to generate a set of
proposed ledger updates. Which peers are chosen by the application? Well, that
depends on the *endorsement policy* (defined for a chaincode), which defines
the set of organizations that need to endorse a proposed ledger change before it
can be accepted by the network. This is literally what it means to achieve
consensus --- every organization who matters must have endorsed the proposed
ledger change *before* it will be accepted onto any peer's ledger.

A peer endorses a proposal response by adding its digital signature, and signing
the entire payload using its private key. This endorsement can be subsequently
used to prove that this organization's peer generated a particular response. In
our example, if peer P1 is owned by organization Org1, endorsement E1
corresponds to a digital proof that "Transaction T1 response R1 on ledger L1 has
been provided by Org1's peer P1!".

Phase 1 ends when the application receives signed proposal responses from
sufficient peers. We note that different peers can return different and
therefore inconsistent transaction responses to the application *for the same
transaction proposal*. It might simply be that the result was generated at
different times on different peers with ledgers at different states, in which
case an application can simply request a more up-to-date proposal response. Less
likely, but much more seriously, results might be different because the chaincode
is *non-deterministic*. Non-determinism is the enemy of chaincodes
and ledgers and if it occurs it indicates a serious problem with the proposed
transaction, as inconsistent results cannot, obviously, be applied to ledgers.
An individual peer cannot know that their transaction result is
non-deterministic --- transaction responses must be gathered together for
comparison before non-determinism can be detected. (Strictly speaking, even this
is not enough, but we defer this discussion to the transaction section, where
non-determinism is discussed in detail.)

At the end of phase 1, the application is free to discard inconsistent
transaction responses if it wishes to do so, effectively terminating the
transaction workflow early. We'll see later that if an application tries to use
an inconsistent set of transaction responses to update the ledger, it will be
rejected.

### Phase 2: Ordering and packaging transactions into blocks

The second phase of the transaction workflow is the packaging phase. The orderer
is pivotal to this process --- it receives transactions containing endorsed
transaction proposal responses from many applications, and orders the
transactions into blocks. For more details about the
ordering and packaging phase, check out our
[conceptual information about the ordering phase](../orderer/ordering_service.html#phase-two-ordering-and-packaging-transactions-into-blocks).

### Phase 3: Validation and commit

At the end of phase 2, we see that orderers have been responsible for the simple
but vital processes of collecting proposed transaction updates, ordering them,
and packaging them into blocks, ready for distribution to the peers.

The final phase of the transaction workflow involves the distribution and
subsequent validation of blocks from the orderer to the peers, where they can be
committed to the ledger. Specifically, at each peer, every transaction within a
block is validated to ensure that it has been consistently endorsed by all
relevant organizations before it is committed to the ledger. Failed transactions
are retained for audit, but are not committed to the ledger.

![Peer12](./peers.diagram.12.png)

*The second role of an orderer node is to distribute blocks to peers. In this
example, orderer O1 distributes block B2 to peer P1 and peer P2. Peer P1
processes block B2, resulting in a new block being added to ledger L1 on P1.
In parallel, peer P2 processes block B2, resulting in a new block being added
to ledger L1 on P2. Once this process is complete, the ledger L1 has been
consistently updated on peers P1 and P2, and each may inform connected
applications that the transaction has been processed.*

Phase 3 begins with the orderer distributing blocks to all peers connected to
it. Peers are connected to orderers on channels such that when a new block is
generated, all of the peers connected to the orderer will be sent a copy of the
new block. Each peer will process this block independently, but in exactly the
same way as every other peer on the channel. In this way, we'll see that the
ledger can be kept consistent. It's also worth noting that not every peer needs
to be connected to an orderer --- peers can cascade blocks to other peers using
the **gossip** protocol, who also can process them independently. But let's
leave that discussion to another time!

Upon receipt of a block, a peer will process each transaction in the sequence in
which it appears in the block. For every transaction, each peer will verify that
the transaction has been endorsed by the required organizations according to the
*endorsement policy* of the chaincode which generated the transaction. For
example, some transactions may only need to be endorsed by a single
organization, whereas others may require multiple endorsements before they are
considered valid. This process of validation verifies that all relevant
organizations have generated the same outcome or result. Also note that this
validation is different than the endorsement check in phase 1, where it is the
application that receives the response from endorsing peers and makes the
decision to send the proposal transactions. In case the application violates
the endorsement policy by sending wrong transactions, the peer is still able to
reject the transaction in the validation process of phase 3.

If a transaction has been endorsed correctly, the peer will attempt to apply it
to the ledger. To do this, a peer must perform a ledger consistency check to
verify that the current state of the ledger is compatible with the state of the
ledger when the proposed update was generated. This may not always be possible,
even when the transaction has been fully endorsed. For example, another
transaction may have updated the same asset in the ledger such that the
transaction update is no longer valid and therefore can no longer be applied. In
this way, the ledger is kept consistent across each peer in the channel because
they each follow the same rules for validation.

After a peer has successfully validated each individual transaction, it updates
the ledger. Failed transactions are not applied to the ledger, but they are
retained for audit purposes, as are successful transactions. This means that
peer blocks are almost exactly the same as the blocks received from the orderer,
except for a valid or invalid indicator on each transaction in the block.

We also note that phase 3 does not require the running of chaincodes --- this is
done only during phase 1, and that's important. It means that chaincodes only have
to be available on endorsing nodes, rather than throughout the blockchain
network. This is often helpful as it keeps the logic of the chaincode
confidential to endorsing organizations. This is in contrast to the output of
the chaincodes (the transaction proposal responses) which are shared with every
peer in the channel, whether or not they endorsed the transaction. This
specialization of endorsing peers is designed to help scalability and confidentiality.

Finally, every time a block is committed to a peer's ledger, that peer
generates an appropriate *event*. *Block events* include the full block content,
while *block transaction events* include summary information only, such as
whether each transaction in the block has been validated or invalidated.
*Chaincode* events that the chaincode execution has produced can also be
published at this time. Applications can register for these event types so
that they can be notified when they occur. These notifications conclude the
third and final phase of the transaction workflow.

In summary, phase 3 sees the blocks which are generated by the orderer
consistently applied to the ledger. The strict ordering of transactions into
blocks allows each peer to validate that transaction updates are consistently
applied across the blockchain network.

### Orderers and Consensus

This entire transaction workflow process is called *consensus* because all peers
have reached agreement on the order and content of transactions, in a process
that is mediated by orderers. Consensus is a multi-step process and applications
are only notified of ledger updates when the process is complete --- which may
happen at slightly different times on different peers.

We will discuss orderers in a lot more detail in a future orderer topic, but for
now, think of orderers as nodes which collect and distribute proposed ledger
updates from applications for peers to validate and include on the ledger.

That's it! We've now finished our tour of peers and the other components that
they relate to in Fabric. We've seen that peers are in many ways the
most fundamental element --- they form the network, host chaincodes and the
ledger, handle transaction proposals and responses, and keep the ledger
up-to-date by consistently applying transaction updates to it.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
