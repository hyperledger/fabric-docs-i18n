# O serviço de ordens

**Audiência:** Arquitetos, administradores de serviços de ordens, criadores de canais

Este tópico serve como uma introdução ao conceito de ordem, como os ordenadores interagem com os pares, o papel que eles desempenham em um 
fluxo de transações e uma visão geral das implementações atualmente disponíveis do serviço de ordens, recomendando um foco particular na
implementação do serviço de ordens **Raft**.

## O que é ordenação?

Muitas blockchains distribuídas, como Ethereum e Bitcoin, não são permissionadas, o que significa que qualquer nó pode participar do 
processo de consenso, em que as transações são ordenadas e agrupadas em blocos. Devido a esse fato, esses sistemas se baseiam em algoritmos 
de consenso **probabilísticos** que, eventualmente, garantem a consistência do livro-razão com um alto grau de probabilidade, mas que ainda 
são vulneráveis ​​a livros-razão divergentes (também conhecidos como "fork" do ledger), onde diferentes participantes na rede têm uma visão 
diferente da ordem das transações aceita.

A Hyperledger Fabric funciona de maneira diferente. Ela apresenta um nó chamado **ordenador** (também conhecido como "nó de ordenação") que 
faz esse pedido de transação, que junto com outros nós ordenadores formam um **serviço de ordenação**. Como o design da Fabric se baseia em 
algoritmos de consenso determinístico, qualquer bloco validado pelo par é garantido como final e correto. Os livros contábeis não podem se
comportar como em muitas outras redes de blockchain distribuídas e não permissionadas.

Além de promover a finalização, separar o endosso da ordem da execução do chaincode (que acontece nos pares), oferece vantagens de 
desempenho e escalabilidade na Fabric, eliminando gargalos que podem ocorrer quando a execução e a ordem são realizada pelos mesmos nós.

## Nós do ordenação e configuração de canal

Além de sua função de **ordenador**, os ordenantes também mantêm a lista de organizações que têm permissão para criar canais. Essa lista de
organizações é conhecida como "consórcio" e a própria lista é mantida na configuração do "canal do sistema de ordens" (também conhecido como 
"canal do sistema de ordenação"). Por padrão, esta lista e o canal em que ela vive só podem ser editados pelo administrador do ordenador. 
Observe que é possível que um serviço de ordens mantenha várias dessas listas, o que torna o consórcio um veículo para o particionamento 
(multi-tenancy) da Fabric.

Os ordenadors também reforçam o controle básico de acesso aos canais, restringindo quem pode ler e gravar dados neles e quem pode 
configurá-los. Lembre-se de que, quem está autorizado a modificar um elemento de configuração em um canal, também está sujeito às políticas 
que os administradores superiores definiram quando criaram o consórcio ou o canal. As transações de configuração são processadas pelo 
solicitante, pois ele precisa conhecer o conjunto atual de políticas para executar sua forma básica de controle de acesso. Nesse caso, o 
ordenador processa a atualização de configuração para garantir que o solicitante tenha os direitos administrativos adequados. O ordenador 
valida a solicitação de atualização com relação à configuração existente, gera uma nova transação de configuração e a empacota em um bloco 
que é retransmitido para todos os pares no canal. Os pares então processam as transações de configuração para verificar se as modificações 
aprovadas pelo solicitante realmente satisfazem as políticas definidas no canal.

## Nós do ordenador e identidade

Tudo o que interage com uma rede blockchain, incluindo pares, aplicativos, administradores e ordens, adquire sua identidade organizacional a 
partir de seu certificado digital e da definição do Provedor de Serviço de Associação (MSP).

Para obter mais informações sobre identidades e MSPs, consulte nossa documentação sobre [Identidade](../identity/identity.html) e 
[Associação](../membership/membership.html).

Assim como os pares, os nós de ordens pertencem a uma organização. E semelhante aos pares, uma Autoridade de Certificação (CA) separada deve 
ser usada para cada organização. Se essa autoridade de certificação funcionará como a autoridade de certificação raiz ou se você optar por 
implantar uma autoridade de certificação raiz e, em seguida, intermediárias associadas a essa autoridade de certificação raiz, é com você.

## Ordens e o fluxo da transação

### Primeira fase: proposta

Vimos em nosso tópico [Pares](../peers/peers.html) que eles formam a base de uma rede blockchain, hospedando livros-razão, que podem ser 
consultados e atualizados por aplicativos através de contratos inteligentes.

Especificamente, os aplicativos que desejam atualizar o livro-razão estão envolvidos em um processo com três fases que garantem que todos os 
pares de uma rede blockchain mantenham seus registros consistentes entre si.

Na primeira fase, um aplicativo cliente envia uma proposta de transação para um subconjunto de pares que invocará um contrato inteligente 
para produzir uma proposta de atualização do razão e endossar os resultados. Os pares endossantes não aplicam a atualização proposta à sua 
cópia do razão no momento. Em vez disso, os pares endossantes retornam uma proposta de resposta ao aplicativo cliente. As propostas de 
transação endossadas serão ordenadas em blocos na fase dois e depois distribuídas a todos os pares para validação final e confirmadas na 
fase três.

Para uma análise detalhada da primeira fase, consulte o tópico [Pares](../peers/peers.html#fase-1-proposta).

### Fase dois: Ordenar e empacotar transações em blocos

Após a conclusão da primeira fase de uma transação, um aplicativo cliente recebeu uma resposta de proposta de transação endossada de um 
conjunto de pares. Agora é hora da segunda fase de uma transação.

Nesta fase, os clientes do aplicativo enviam transações contendo respostas da proposta de transação endossada para um nó de serviço de 
ordens. O serviço de ordens cria blocos de transações que serão distribuídos a todos os pares no canal para validação final e confirmação na 
fase três.

Os nós do serviço de ordens recebem transações de muitos clientes de aplicativos diferentes simultaneamente. Esses nós do serviço de ordens 
trabalham juntos para formar coletivamente o serviço de ordens. Seu trabalho é organizar lotes de transações enviadas em uma sequência bem 
definida e empacotá-los em *blocos*. Esses blocos se tornarão os *blocos* da blockchain!

O número de transações em um bloco depende dos parâmetros de configuração do canal, relacionado ao tamanho desejado e à duração máxima 
decorrida de um bloco (parâmetros `BatchSize` e `BatchTimeout`, para ser exato). Os blocos são salvos no razão do ordenador e distribuídos a 
todos os pares que ingressaram no canal. Se um par estiver inativo nesse momento, ou ingressar no canal mais tarde, ele receberá os blocos 
após se reconectar a um nó de serviço de ordens ou comunicar com outro par. Vamos ver como esse bloco é processado pelos pares na terceira 
fase.

![Orderer1](./orderer.diagram.1.png)

*A primeira função de um nó de ordens é empacotar as propostas de atualizações do livro-razão. Neste exemplo, o aplicativo A1 envia uma 
transação T1 endossada por E1 e E2 para o ordenador O1. Paralelamente, o Aplicativo A2 envia a transação T2 endossada por E1 para o 
ordenador O1. O1 empacota a transação T1 do aplicativo A1 e a transação T2 do aplicativo A2 juntamente com outras transações de outros 
aplicativos da rede no bloco B2. Podemos ver que em B2, a ordem da transação é T1, T2, T3, T4, T6, T5 --- que pode não ser a ordem em que 
essas transações chegaram ao ordenador! (Este exemplo mostra uma configuração de serviço de ordens muito simplificada com apenas um nó de 
ordens.)*

Vale ressaltar que o seqüenciamento de transações em um bloco não é necessariamente o mesmo que o pedido recebido pelo serviço de ordens, 
pois pode haver vários nós do serviço de ordens que recebem transações aproximadamente ao mesmo tempo. O importante é que o serviço de 
ordens coloque as transações em uma ordem estrita, e os pares usarão esse pedido ao validar e confirmar transações.

Essa ordem estrita de transações dentro de blocos torna a Hyperledger Fabric um pouco diferente de outras cadeias de blocos, nas quais a 
mesma transação pode ser empacotada em vários blocos diferentes que competem para formar uma cadeia. No Hyperledger Fabric, os blocos 
gerados pelo serviço de ordens são **finais**. Depois que uma transação é gravada em um bloco, sua posição no razão fica imutável. Como 
dissemos anteriormente, a finalidade do Hyperledger Fabric significa que não existem **livros-razão diferentes** --- as transações validadas 
nunca serão revertidas ou eliminadas.

Também podemos ver que, enquanto os pares executam contratos inteligentes e processam transações, os ordenadores definitivamente não o fazem. 
Toda transação autorizada que chega a um ordenador é mecanicamente empacotada em um bloco --- o ordenador não julga o conteúdo de uma 
transação (exceto as transações de configuração de canal, como mencionado anteriormente).

No final da fase dois, vemos que os ordenadores foram responsáveis pelos processos simples, mas vitais, de coletar propostas de atualizações 
de transações, ordená-las e empacotá-las em blocos, prontas para distribuição.

### Fase três: validação e confirmação

A terceira fase do fluxo de trabalho da transação envolve a distribuição e a validação subsequente dos blocos do ordenador para os pares, 
onde eles podem ser confirmados no razão.

A fase 3 começa com o ordenador distribuindo blocos a todos os pares conectados a ele. Também é importante notar que nem todos os pares 
precisam estar conectados a um ordenador --- os pares podem cascatear blocos com outros usando o protocolo [**gossip**](../gossip.html).

Cada par validará independentemente os blocos distribuídos, mas de maneira determinística, garantindo que os livros permaneçam consistentes. 
Especificamente, cada par no canal validará cada transação no bloco para garantir que foi endossado pelos colegas da organização requerida,
que seus endossos correspondem e que não foi invalidado por outras transações confirmada recentemente, que possa ter sido atualizado quando 
a transação foi originalmente endossada. As transações invalidadas ainda são retidas no bloco imutável criado pelo ordenador, mas são 
marcadas como inválidas pelo par e não atualizam o estado do livro-razão.

![Orderer2](./orderer.diagram.2.png)

*A segunda função de um nó de ordens é distribuir blocos aos pares. Neste exemplo, o ordenador O1 distribui o bloco B2 nos pares P1 e P2. O 
par P1 processa o bloco B2, resultando em um novo bloco sendo adicionado ao livro-razão L1 em P1. Paralelamente, o par P2 processa o bloco 
B2, resultando em um novo bloco sendo adicionado ao razão L1 em P2. Depois que esse processo é concluído, o razão L1 foi consistentemente 
atualizado nos pares P1 e P2, e cada um pode informar aos aplicativos conectados que a transação foi processada.*

Em resumo, a fase três vê os blocos gerados pelo serviço de ordens aplicados de forma consistente ao livro-razão. A ordem estrita de 
transações em blocos permite que cada par valide que as atualizações de transações são aplicadas de forma consistente na rede blockchain.

Para uma visão mais aprofundada da fase 3, consulte o tópico [Peers](../peers/peers.html#fase-3-validacao-e-confirmacao).

## Implementação do serviço de ordens

Embora todo serviço de orden disponível atualmente lide com transações e atualizações de configuração da mesma maneira, existem várias 
implementações diferentes para obter consenso sobre a ordem estrita de transações entre nós do serviço de ordens.

Para obter informações sobre como suportar um nó de ordens (independentemente da implementação em que o nó será usado), consulte 
[nossa documentação sobre como levantar um nó de ordens](../orderer_deploy.html).

* **Raft** (recomendado)

  Novidade a partir da v1.4.1, o Raft é um serviço de ordens de tolerância a falhas (CFT) baseado na implementação do 
  [protocolo Raft](https://raft.github.io/raft.pdf) em [`etcd`](https://coreos.com/etcd/). O Raft segue um modelo de "líder e seguidor", em 
  que um nó líder é eleito (por canal) e suas decisões são replicadas pelos seguidores. Os serviços Raft de ordens devem ser mais fáceis de 
  configurar e gerenciar do que os serviços de ordens baseados em Kafka, e seu design permite que diferentes organizações contribuam com nós 
  para um serviço de ordens distribuído.

* **Kafka** (descontinuado na v2.0)

  Semelhante ao ordenador baseado em Raft, o Apache Kafka é uma implementação de CFT que usa uma configuração de nó "líder e seguidor". 
  Kafka utiliza em conjunto o ZooKeeper para fins de gerenciamento. O serviço de ordens baseado em Kafka está disponível desde o Fabric 
  v1.0, mas muitos usuários podem achar a sobrecarga administrativa de gerenciar um cluster Kafka intimidante ou indesejável.

* **Solo** (descontinuado na v2.0)

  A implementação Solo do serviço de ordens destina-se apenas para teste e consiste em um único nó de ordens. Ele foi descontinuado e pode 
  ser removido inteiramente em uma versão futura. Os usuários existentes do Solo devem mudar para uma rede Raft de nó único para uma função 
  equivalente.

## Raft

Para obter informações sobre como configurar um serviço de ordens de Raft, consulte nossa 
[documentação sobre como configurar um serviço de pedido de Raft](../raft_configuration.html).

Como opção de serviço de ordem inicial para redes de produção, a implementação Fabric do protocolo Raft usa um modelo "líder e seguidor", no 
qual um líder é eleito dinamicamente entre os nós de ordens em um canal (essa coleção de nós é conhecida como o "conjunto de consentidores") 
e esse líder replica mensagens para os nós seguintes. Como o sistema pode suportar a perda de nós, incluindo nós líderes, desde que a
maioria dos nós de ordens (o que é conhecido como "quorum") permaneça. Raft é considerado "tolerante a falhas" (CFT). Em outras palavras, se 
houver três nós em um canal, ele poderá suportar a perda de um nó (deixando dois restantes). Se você tiver cinco nós em um canal, poderá 
perder dois nós (deixando três nós restantes).

Da perspectiva do serviço que eles fornecem a uma rede ou canal, o serviço de ordens existente baseado em Kafka (sobre o qual falaremos mais 
adiante) e o Raft são semelhantes. Ambos são serviços de ordens CFT que usam o design de líder e seguidor. Se você é desenvolvedor de 
aplicativos, desenvolvedor de contrato inteligente ou administrador de pares, não notará uma diferença funcional entre um serviço de ordens 
baseado em Raft versus Kafka. No entanto, existem algumas diferenças importantes que valem a pena considerar, especialmente se você pretende 
gerenciar um serviço de ordens:

* Raft é mais fácil de configurar. Embora o Kafka tenha muitos admiradores, mesmo esses admiradores (geralmente) admitem que a implantação 
de um cluster Kafka em conjunto com o ZooKeeper pode ser complicado, exigindo um alto nível de conhecimento em infraestrutura e 
configurações do Kafka. Além disso, há muito mais componentes para gerenciar com o Kafka do que com o Raft, o que significa que há mais 
lugares onde as coisas podem dar errado. E o Kafka tem suas próprias versões, que devem ser coordenadas com suas ordens. **Com o Raft, tudo 
é incorporado ao seu nó de ordens**.

* Kafka e Zookeeper não foram projetados para serem executados em redes grandes. Enquanto o Kafka é CFT, ele deve ser executado em um grupo 
restrito de hosts. Isso significa que, na prática, é necessário que uma organização execute o cluster Kafka. Dado que, ter nós de ordem 
executados por diferentes organizações ao usar o Kafka (que o Fabric suporta) não oferece muito em termos de descentralização, porque todos 
os nós irão para o mesmo cluster Kafka que está sob o controle de uma única organização. Com o Raft, cada organização pode ter seus próprios 
nós de ordens, participando do serviço de ordens, o que leva a um sistema mais descentralizado.

* O Raft é suportado nativamente, o que significa que os usuários precisam obter as imagens necessárias e aprender a usar o Kafka e o 
ZooKeeper por conta própria. Da mesma forma, o suporte para problemas relacionados ao Kafka é tratado pela 
[Apache](https://kafka.apache.org/), o desenvolvedor do código aberto do Kafka, e não pelo Hyperledger Fabric. A implementação da Fabric 
Raft, por outro lado, foi desenvolvida e será suportada pela comunidade de desenvolvedores da Fabric e suas capacidades de suporte.

* Onde o Kafka usa um pool de servidores (chamados "Kafka brokers") e o administrador da organização de ordens especifica quantos nós eles 
desejam usar em um canal específico, o Raft permite que os usuários especifiquem quais nós de ordens serão implantados e em qual canal. 
Dessa maneira, as organizações dos nós pares podem garantir que, se eles também possuem um ordenador, esse nó fará parte de um serviço de 
ordens desse canal, em vez de confiar e depender de um administrador central para gerenciar os nós Kafka.

* O Raft é o primeiro passo para o desenvolvimento de um serviço de ordem tolerante a falhas bizantinas (BFT) da Fabric. Como veremos, 
algumas decisões no desenvolvimento do Raft foram motivadas por isso. Se você está interessado em BFT, aprender a usar o Raft deve facilitar 
a transição.

Por todos esses motivos, o suporte ao serviço de ordens baseado em Kafka está sendo preterido no Fabric v2.0.

Nota: Semelhante ao Solo e Kafka, um serviço de ordens Raft pode perder transações após o envio do aviso de recebimento a um cliente. Por 
exemplo, se o líder travar, quase ao mesmo tempo que um seguidor fornecerá um aviso de recebimento. Portanto, os clientes de aplicativos 
devem escutar os eventos dos pares de confirmação de transação independentemente (para verificar a validade da transação), mas deve-se tomar 
um cuidado extra para garantir que o cliente também aguarde um tempo limite no qual a transação não seja confirmada em um período configurado. 
Dependendo do aplicativo, pode ser desejável reenviar a transação ou coletar um novo conjunto de recomendações após esse tempo limite.

### Raft concepts

While Raft offers many of the same features as Kafka --- albeit in a simpler and
easier-to-use package --- it functions substantially different under the covers
from Kafka and introduces a number of new concepts, or twists on existing
concepts, to Fabric.

**Log entry**. The primary unit of work in a Raft ordering service is a "log
entry", with the full sequence of such entries known as the "log". We consider
the log consistent if a majority (a quorum, in other words) of members agree on
the entries and their order, making the logs on the various orderers replicated.

**Consenter set**. The ordering nodes actively participating in the consensus
mechanism for a given channel and receiving replicated logs for the channel.
This can be all of the nodes available (either in a single cluster or in
multiple clusters contributing to the system channel), or a subset of those
nodes.

**Finite-State Machine (FSM)**. Every ordering node in Raft has an FSM and
collectively they're used to ensure that the sequence of logs in the various
ordering nodes is deterministic (written in the same sequence).

**Quorum**. Describes the minimum number of consenters that need to affirm a
proposal so that transactions can be ordered. For every consenter set, this is a
**majority** of nodes. In a cluster with five nodes, three must be available for
there to be a quorum. If a quorum of nodes is unavailable for any reason, the
ordering service cluster becomes unavailable for both read and write operations
on the channel, and no new logs can be committed.

**Leader**. This is not a new concept --- Kafka also uses leaders, as we've said ---
but it's critical to understand that at any given time, a channel's consenter set
elects a single node to be the leader (we'll describe how this happens in Raft
later). The leader is responsible for ingesting new log entries, replicating
them to follower ordering nodes, and managing when an entry is considered
committed. This is not a special **type** of orderer. It is only a role that
an orderer may have at certain times, and then not others, as circumstances
determine.

**Follower**. Again, not a new concept, but what's critical to understand about
followers is that the followers receive the logs from the leader and
replicate them deterministically, ensuring that logs remain consistent. As
we'll see in our section on leader election, the followers also receive
"heartbeat" messages from the leader. In the event that the leader stops
sending those message for a configurable amount of time, the followers will
initiate a leader election and one of them will be elected the new leader.

### Raft in a transaction flow

Every channel runs on a **separate** instance of the Raft protocol, which allows
each instance to elect a different leader. This configuration also allows
further decentralization of the service in use cases where clusters are made up
of ordering nodes controlled by different organizations. While all Raft nodes
must be part of the system channel, they do not necessarily have to be part of
all application channels. Channel creators (and channel admins) have the ability
to pick a subset of the available orderers and to add or remove ordering nodes
as needed (as long as only a single node is added or removed at a time).

While this configuration creates more overhead in the form of redundant heartbeat
messages and goroutines, it lays necessary groundwork for BFT.

In Raft, transactions (in the form of proposals or configuration updates) are
automatically routed by the ordering node that receives the transaction to the
current leader of that channel. This means that peers and applications do not
need to know who the leader node is at any particular time. Only the ordering
nodes need to know.

When the orderer validation checks have been completed, the transactions are
ordered, packaged into blocks, consented on, and distributed, as described in
phase two of our transaction flow.

### Architectural notes

#### How leader election works in Raft

Although the process of electing a leader happens within the orderer's internal
processes, it's worth noting how the process works.

Raft nodes are always in one of three states: follower, candidate, or leader.
All nodes initially start out as a **follower**. In this state, they can accept
log entries from a leader (if one has been elected), or cast votes for leader.
If no log entries or heartbeats are received for a set amount of time (for
example, five seconds), nodes self-promote to the **candidate** state. In the
candidate state, nodes request votes from other nodes. If a candidate receives a
quorum of votes, then it is promoted to a **leader**. The leader must accept new
log entries and replicate them to the followers.

For a visual representation of how the leader election process works, check out
[The Secret Lives of Data](http://thesecretlivesofdata.com/raft/).

#### Snapshots

If an ordering node goes down, how does it get the logs it missed when it is
restarted?

While it's possible to keep all logs indefinitely, in order to save disk space,
Raft uses a process called "snapshotting", in which users can define how many
bytes of data will be kept in the log. This amount of data will conform to a
certain number of blocks (which depends on the amount of data in the blocks.
Note that only full blocks are stored in a snapshot).

For example, let's say lagging replica `R1` was just reconnected to the network.
Its latest block is `100`. Leader `L` is at block `196`, and is configured to
snapshot at amount of data that in this case represents 20 blocks. `R1` would
therefore receive block `180` from `L` and then make a `Deliver` request for
blocks `101` to `180`. Blocks `180` to `196` would then be replicated to `R1`
through the normal Raft protocol.

### Kafka (deprecated in v2.0)

The other crash fault tolerant ordering service supported by Fabric is an
adaptation of a Kafka distributed streaming platform for use as a cluster of
ordering nodes. You can read more about Kafka at the [Apache Kafka Web site](https://kafka.apache.org/intro),
but at a high level, Kafka uses the same conceptual "leader and follower"
configuration used by Raft, in which transactions (which Kafka calls "messages")
are replicated from the leader node to the follower nodes. In the event the
leader node goes down, one of the followers becomes the leader and ordering can
continue, ensuring fault tolerance, just as with Raft.

The management of the Kafka cluster, including the coordination of tasks,
cluster membership, access control, and controller election, among others, is
handled by a ZooKeeper ensemble and its related APIs.

Kafka clusters and ZooKeeper ensembles are notoriously tricky to set up, so our
documentation assumes a working knowledge of Kafka and ZooKeeper. If you decide
to use Kafka without having this expertise, you should complete, *at a minimum*,
the first six steps of the [Kafka Quickstart guide](https://kafka.apache.org/quickstart) before experimenting with the
Kafka-based ordering service. You can also consult
[this sample configuration file](https://github.com/hyperledger/fabric/blob/release-1.1/bddtests/dc-orderer-kafka.yml)
for a brief explanation of the sensible defaults for Kafka and ZooKeeper.

To learn how to bring up a a Kafka-based ordering service, check out [our documentation on Kafka](../kafka.html).

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
