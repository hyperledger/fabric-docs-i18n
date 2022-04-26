# Introduzione

In termini generali, una blockchain è un registro immutabile di transazioni, mantenuto all'interno di una rete distribuita di _nodi peer_. Ciascuno di questi nodi mantiene una copia del registro aggiungendo transazioni che sono state convalidate da un _protocollo di consenso_, raggruppate in blocchi che includono un hash che lega ogni blocco al blocco precedente.

La prima e più ampiamente riconosciuta applicazione della blockchain è la criptovaluta [Bitcoin](https://en.wikipedia.org/wiki/Bitcoin), anche se altre ne hanno seguito le orme. Ethereum, una criptovaluta alternativa, ha adottato un approccio diverso, integrando molte delle stesse caratteristiche di Bitcoin ma aggiungendo gli _smart contract_ (programmi per computer che implementano una o più clausole contrattuali) per creare una piattaforma per applicazioni distribuite. Bitcoin ed Ethereum rientrano in una classe di blockchain che classificheremmo come tecnologia blockchain _pubblica e permissionless_ (partecipanti non noti tra loro e senza gestione delle autorizzazioni di accesso). Fondamentalmente, si tratta di reti pubbliche, aperte a chiunque, in cui i partecipanti interagiscono in modo anonimo.

Con la crescita della popolarità di Bitcoin, Ethereum e di alcune altre tecnologie derivate, è cresciuto anche l'interesse per l'applicazione della tecnologia alla base della blockchain, del registro distribuito e della piattaforma di applicazioni distribuite a casi d'uso _enterprise_ più innovativi. Tuttavia, molti casi d'uso richiedono caratteristiche prestazionali che le tecnologie blockchain _permissionless_ non sono in grado (attualmente) di fornire. Inoltre, in molti casi d'uso, l'identità dei partecipanti è un requisito fondamentale, come nel caso di transazioni finanziarie in cui è necessario seguire le normative Know-Your-Customer (KYC) e Antiriciclaggio (AML).

Per l'uso in ambito enterprise, dobbiamo considerare i seguenti requisiti:

- I partecipanti devono essere identificati/identificabili
- Le reti devono essere _permissioned_ (con partecipanti noti, autenticati e autorizzati all'accesso)
- Elevate prestazioni di throughput (portata del flusso) delle transazioni
- Bassa latenza di conferma della transazione
- Privacy e riservatezza delle transazioni e dei dati relativi alle transazioni commerciali

Mentre molte delle prime piattaforme blockchain sono attualmente in fase di _adattamento_ per l'uso enterprise, Hyperledger Fabric è stato _progettato_ per l'uso enterprise sin dall'inizio. Le sezioni seguenti descrivono come Hyperledger Fabric (Fabric) si differenzia dalle altre piattaforme blockchain e descrivono alcune delle motivazioni alla basse delle sue scelte architetturali.

## Hyperledger Fabric

Hyperledger Fabric è una piattaforma DLT (Permissioned Distributed Ledger Technology - Tecnologia di Registro Distribuito con gestione delle Autorizzazioni) open source di livello _enterprise_, progettata per l'uso in contesti imprenditoriali, che offre alcune importanti caratteristiche che la differenziano rispetto ad altre popolari piattaforme di registro distribuito o blockchain.

Un importante punto di differenziazione è che Hyperledger è stata fondata sotto la Linux Foundation, che a sua volta ha una storia lunga e di grande successo nel coltivare progetti open source sotto una **governance aperta** che fanno crescere comunità di sostegno forti ed ecosistemi fiorenti. Hyperledger è governato da un comitato direttivo tecnico diversificato e il progetto Hyperledger Fabric da un insieme diversificato di manutentori provenienti da diverse organizzazioni. Ha una comunità di sviluppo che è cresciuta fino a raggiungere oltre 35 organizzazioni e quasi 200 sviluppatori software dai suoi primi sviluppi di codice.

Fabric ha un'architettura altamente **modulare** e **configurabile** che consente innovazione, versatilità e ottimizzazione per un'ampia gamma di casi d'uso tra cui banche, finanza, assicurazioni, assistenza sanitaria, risorse umane, catene di approvvigionamento e persino distribuzione di musica in formato digitale.

Fabric è la prima piattaforma di registro distribuito a **supportare _smart contract_ creati in linguaggi di programmazione _general-purpose_** come Java, Go e Node.js, piuttosto che in linguaggi di dominio specifici (DSL). Ciò significa che la maggior parte delle imprese dispone già delle competenze necessarie per sviluppare smart contract e non è necessaria alcuna formazione aggiuntiva per apprendere un nuovo linguaggio di programmazione o DSL.

La piattaforma Fabric è anche **permissioned**, il che significa che, a differenza di una rete pubblica _permissionless_, i partecipanti sono noti tra loro, anziché anonimi e quindi completamente non attendibili. Ciò significa che mentre i partecipanti potrebbero non fidarsi completamente l'uno dell'altro (potrebbero, per esempio, essere concorrenti nello stesso settore), una rete può essere gestita secondo un modello di governance che si basa sulla fiducia che esiste tra i partecipanti, come un accordo legale o un quadro di riferimento per la gestione delle controversie.

Uno dei più importanti fattori di differenziazione della piattaforma è il suo supporto per **protocolli di consenso intercambiabili** che consentono alla piattaforma di essere personalizzata più efficacemente per adattarsi a casi d'uso e modelli di _trust_ (fiducia) particolari. Per esempio, quando implementato all'interno di una singola impresa o gestito da un'autorità di fiducia, il consenso _fully byzantine fault tolerant_  (con completa tolleranza bizantina agli errori) potrebbe essere considerato non necessario e un ostacolo eccessivo alle prestazioni e al throughput. In situazioni del genere un protocollo di consenso [crash fault-tolerant](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT - tollerante agli errori di crash) potrebbe essere più che adeguato mentre, in un caso d'uso decentralizzato con più parti coinvolte, potrebbe essere necessario un più tradizionale protocollo di consenso [byzantine fault tolerant](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance) (BFT - con tolleranza bizantina agli errori).

Fabric può sfruttare protocolli di consenso che **non richiedono una criptovaluta nativa** per incentivare un _mining_ costoso o per alimentare l'esecuzione di smart contract. L'esclusione di una criptovaluta dal processo di consenso riduce alcuni significativi vettori di rischio/attacco e l'assenza di operazioni di mining crittografico implica che la piattaforma può essere implementata con all'incirca lo stesso costo operativo di qualsiasi altro sistema distribuito.

La combinazione di queste caratteristiche progettuali differenzianti rende Fabric una delle **piattaforme più performanti** oggi disponibili sia in termini di elaborazione delle transazioni che di latenza nella conferma delle transazioni, e consente la **privacy e la riservatezza** delle transazioni e degli smart contract (ciò che in Fabric prende il nome di  "chaincode") che li implementano.

Esaminiamo queste caratteristiche differenzianti in modo più dettagliato.

## Modularità

Hyperledger Fabric è stato progettato specificamente per avere un'architettura modulare. Sia che si tratti del consenso intercambiabile, dei protocolli di gestione delle identità integrabili come LDAP o OpenID Connect, dei protocolli di gestione delle chiavi o delle librerie crittografiche, la piattaforma è stata progettata dalle sue fondamenta per essere configurata per soddisfare la diversità dei requisiti dei casi d'uso aziendali.

Ad alto livello, Fabric è composto dai seguenti componenti modulari:

- Un _ordering service_ (servizio di ordinamento) intercambiabile che determina il consenso sull'ordine delle transazioni e quindi trasmette i blocchi ai peer (nodi).
- Un _membership service provider_ (fornitore di servizi di identità e appartenenza) intercambiabile che è responsabile dell'associazione delle entità nella rete con identità crittografiche.
- Un _peer-to-peer gossip service_ (servizio di propagazione da nodo a nodo) opzionale che diffonde l'output dei blocchi dall'ordering service agli altri peer.
- Gli smart contract ("chaincode") vengono eseguiti all'interno di un ambiente a container (ad es. Docker) per l'isolamento. Essi possono essere scritti in linguaggi di programmazione standard ma non hanno accesso diretto allo stato del registro distribuito.
- Il registro può essere configurato per supportare una varietà di DBMS.
- Un'applicazione dei criteri (policy enforcement) di approvazione e convalida intercambiabile che può essere configurata in modo indipendente per ciascuna applicazione.

È opinione condivisa nel settore il fatto che non esiste "una blockchain che li governi tutti". Hyperledger Fabric può essere configurato in più modi per soddisfare i requisiti di soluzioni diversificate per molteplici casi d'uso aziendali.

## Blockchain _Permissioned_ e _Permissionless_

In una blockchain _permissionless_, virtualmente chiunque può partecipare e ogni partecipante è anonimo. In un tale contesto non può esserci fiducia se non nel fatto che lo stato della blockchain, a partire da un certo livello in giù, è immutabile. Al fine di mitigare quest'assenza di fiducia, le blockchain permissionless utilizzano tipicamente una criptovaluta nativa generata con il processo di "mining" o commissioni di transazione per fornire un incentivo economico, al fine di compensare i costi straordinari della partecipazione a una forma di consenso con tolleranza bizantina agli errori basato sul "proof of work" (PoW - prova che un certo lavoro computazionale, generalmente oneroso, è stato svolto).

Le blockchain **permissioned**, d'altra parte, consentono di gestire una blockchain tra un insieme di partecipanti noti, identificati e spesso controllati che operano secondo un modello di governance che produce un certo grado di fiducia. Una blockchain permissioned fornisce un modo per rendere sicure le interazioni tra un gruppo di entità che hanno un obiettivo comune ma che potrebbero non fidarsi completamente l'una dell'altra. Facendo affidamento sulle identità dei partecipanti, una blockchain permissioned può utilizzare più tradizionali protocolli di consenso con tolleranza agli errori di crash (CFT) o con tolleranza bizantina agli errori (BFT) che non richiedono un mining costoso.

Inoltre, in un tale contesto _permissioned_, il rischio che un partecipante introduca intenzionalmente codice dannoso tramite uno smart contract è ridotto. Innanzitutto, i partecipanti sono noti tra loro e tutte le azioni, sia che si tratti di inviare transazioni di applicazione, modificare la configurazione della rete o distribuire uno smart contract, vengono registrate sulla blockchain in base a una _policy_ di approvazione stabilita per la rete e il pertinente tipo di transazione. Piuttosto che essere completamente anonima, la parte responsabile può essere facilmente identificata e l'incidente gestito secondo i termini del modello di governance.

## Smart Contract

Uno smart contract, o ciò che Fabric chiama "chaincode", funziona come un'applicazione distribuita affidabile che ottiene la sua sicurezza/fiducia dalla blockchain e dal sottostante consenso tra i peer. È la logica di business di un'applicazione blockchain.

Ci sono tre punti chiave che si applicano agli smart contract, soprattutto se applicati a una piattaforma:

- molti smart contract vengono eseguiti contemporaneamente nella rete,
- possono essere distribuiti dinamicamente (in molti casi da chiunque), e
- il codice dell'applicazione dovrebbe essere trattato come non attendibile, potenzialmente anche dannoso.

La maggior parte delle piattaforme blockchain esistenti che implementano la funzionalità degli smart contract seguono un'architettura **order-execute** (ordina-esegui) in cui il protocollo di consenso:

- valida e ordina le transazioni, quindi le propaga a tutti i nodi peer,
- ogni peer, quindi, esegue le transazioni in sequenza.

L'architettura order-execute può essere trovata praticamente in tutti i sistemi blockchain esistenti, dalle piattaforme pubbliche/permissionless come [Ethereum](https://ethereum.org/) (con consenso basato su PoW) alle piattaforme permissioned come [Tendermint](http://tendermint.com/), [Chain](http://chain.com/) e [Quorum](http://www.jpmorgan.com/global/Quorum).

Gli smart contract che eseguono in una blockchain che opera con l'architettura order-execute devono essere deterministici; in caso contrario il consenso potrebbe non essere mai raggiunto. Per affrontare il problema del non determinismo, molte piattaforme richiedono che gli smart contract siano scritti in un linguaggio non standard o di dominio specifico (come [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) in modo da poter eliminare le operazioni non deterministiche. Ciò ostacola una loro ampia adozione perché richiede agli sviluppatori che scrivono smart contract di imparare un nuovo linguaggio e può portare a errori di programmazione.

Inoltre, poiché tutte le transazioni vengono eseguite in sequenza da tutti i nodi, le prestazioni e la scalabilità sono limitate. Il fatto che il codice dello smart contract venga eseguito su ogni nodo del sistema richiede che siano prese misure complesse per proteggere l'intero sistema da smart contract potenzialmente dannosi al fine di garantire la resilienza dell'intero sistema.

## Un nuovo approccio

Fabric introduce una nuova architettura per le transazioni che chiamiamo **execute-order-validate** (esegui-ordina-valida). Essa affronta le sfide di resilienza, flessibilità, scalabilità, prestazioni e riservatezza affrontate dal modello order-execute separando il flusso delle transazioni in tre fasi:

- _esegue_ una transazione e ne verifica la correttezza, approvandola,
- _ordina_ le transazioni tramite un protocollo di consenso (intercambiabile) e
- _convalida_ le transazioni rispetto a una _policy_ di approvazione specifica dell'applicazione prima di aggiungerla al registro

Quest'architettura si discosta radicalmente dal paradigma _execute-order_ in quanto Fabric esegue le transazioni prima di raggiungere l'accordo finale sul loro ordinamento.

In Fabric, una _policy_ di approvazione specifica dell'applicazione stabilisce quali nodi peer, o quanti di essi, devono garantire la corretta esecuzione di uno smart contract. Pertanto, ogni transazione deve essere eseguita (approvata) solo dal sottoinsieme dei nodi peer necessari a soddisfare la _policy_ di approvazione della transazione. Ciò consente l'esecuzione parallela aumentando le prestazioni complessive e la scalabilità del sistema. Questa prima fase **elimina anche qualsiasi non-determinismo**, poiché i risultati incoerenti possono essere filtrati prima dell'ordinamento.

Poiché abbiamo eliminato il non-determinismo, Fabric è la prima tecnologia blockchain che **consente l'uso di linguaggi di programmazione standard**.

## Privacidad y Confidencialidad

Como hemos comentado, en una red blockchain pública sin permisos que aprovecha PoW para su modelo de consenso, las transacciones se ejecutan en cada nodo.
Esto significa que tampoco puede haber confidencialidad de los contratos.
ellos mismos, ni de los datos de transacciones que procesan. Cada transacción, y el código que la implementa, es visible para todos los nodos de la red. En este caso, hemos cambiado la confidencialidad del contrato y los datos por un consenso bizantino tolerante a fallas entregado por PoW.

Esta falta de confidencialidad puede ser problemática para muchos casos de uso empresarial / empresarial. Por ejemplo, en una red de socios de la cadena de suministro, a algunos consumidores se les pueden dar tarifas preferenciales como un medio para solidificar una relación o promover ventas adicionales. Si cada participante puede ver cada contrato y transacción, se vuelve imposible mantener tales relaciones comerciales en una red completamente transparente --- ¡todos querrán las tarifas preferidas!

Como segundo ejemplo, considere la industria de valores, donde un comerciante que está construyendo una posición (o deshaciéndose de una) no querría que sus competidores se enteraran de esto, o de lo contrario buscarían entrar en el juego, debilitando la táctica del comerciante.

Para abordar la falta de privacidad y confidencialidad con el fin de cumplir con los requisitos de casos de uso empresarial, las plataformas blockchain han adoptado una variedad de enfoques. Todos tienen sus compensaciones.

La encriptación de datos es un método para brindar confidencialidad; sin embargo, en una red sin permisos que aprovecha PoW para su consenso, los datos cifrados se encuentran en cada nodo. Con suficiente tiempo y recursos computacionales, el cifrado podría romperse. Para muchos casos de uso empresarial, el riesgo de que su información se vea comprometida es inaceptable.

Las pruebas de conocimiento cero (ZKP) son otra área de investigación que se está explorando para abordar este problema, y ​​la compensación aquí es que, en la actualidad, calcular un ZKP requiere un tiempo y recursos computacionales considerables. Por lo tanto, la compensación en este caso es el desempeño por la confidencialidad.

En un contexto autorizado que puede aprovechar formas alternativas de consenso, se podrían explorar enfoques que restrinjan la distribución de información confidencial exclusivamente a los nodos autorizados.

Hyperledger Fabric, al ser una plataforma autorizada, permite la confidencialidad a través de su arquitectura de canales y la función [datos privados](./privados-datos/privados-datos.html). En los canales, los participantes de una red de Fabric establecen una subred donde cada miembro tiene visibilidad de un conjunto particular de transacciones. Así, solo aquellos nodos que participan en un canal tienen acceso al contrato inteligente (chaincode) y a los datos transados, preservando la privacidad y confidencialidad de ambos. Los datos privados permiten recopilaciones entre miembros en un canal, lo que permite gran parte de la misma protección que los canales sin la sobrecarga de mantenimiento de crear y mantener un canal separado.

## Consenso conectable

El orden de las transacciones se delega a un componente modular de consenso que está lógicamente desacoplado de los pares que ejecutan las transacciones y mantienen el libro mayor. En concreto, el servicio de ordenamiento. Dado que el consenso es modular, su implementación se puede adaptar al supuesto de confianza de una implementación o solución en particular. Esta arquitectura modular permite que la plataforma se base en conjuntos de herramientas bien establecidos para pedidos CFT (tolerante a fallas de choque) o BFT (tolerante a fallas bizantino).

Fabric ofrece actualmente una implementación de servicio de ordenamiento CFT
basado en la [biblioteca `etcd`](https://coreos.com/etcd/) del [protocolo Raft](https://raft.github.io/raft.pdf).
Para obtener información sobre los servicios de pedidos disponibles actualmente, consulte
nuestra [documentación conceptual sobre pedidos](./orderer/ordering_service.html).

Tenga en cuenta también que estos no son mutuamente excluyentes. Una red Fabric puede tener varios servicios de pedidos que admiten diferentes aplicaciones o requisitos de aplicación.

## Rendimiento y escalabilidad

El rendimiento de una plataforma blockchain puede verse afectado por muchas variables como el tamaño de la transacción, el tamaño del bloque, el tamaño de la red, así como los límites del hardware, etc. El grupo de trabajo Hyperledger Fabric [Performance and Scale](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group) actualmente trabaja en un marco de evaluación comparativa llamado [Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

Se han publicado varios artículos de investigación que estudian y prueban las capacidades de rendimiento de Hyperledger Fabric. El último [Fabric escalado a 20.000 transacciones por segundo](https://arxiv.org/abs/1901.00910).

## Conclusión

Cualquier evaluación seria de las plataformas blockchain debería incluir Hyperledger Fabric en su lista corta.

Combinadas, las capacidades diferenciadoras de Fabric lo convierten en un sistema altamente escalable para blockchains autorizadas que respaldan supuestos de confianza flexibles que permiten que la plataforma admita una amplia gama de casos de uso de la industria que van desde el gobierno hasta las finanzas, la logística de la cadena de suministro, la atención médica, etc. mucho más.

Hyperledger Fabric es el más activo de los proyectos de Hyperledger. La construcción de la comunidad alrededor de la plataforma está creciendo constantemente, y la innovación entregada con cada lanzamiento sucesivo supera con creces a cualquiera de las otras plataformas de blockchain empresariales.

## Reconocimiento

Lo anterior se deriva de la revisión por pares
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
