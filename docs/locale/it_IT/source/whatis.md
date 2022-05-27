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

## Privacy e Riservatezza

Come abbiamo visto, in una rete blockchain pubblica e permissionless che fa leva sulla PoW (proof of work) come modello di consenso, le transazioni vengono eseguite su tutti i nodi. Ciò significa che non può esserci riservatezza né dei contratti stessi, né dei dati delle transazioni che essi elaborano. Ogni transazione, e il codice che la implementa, sono visibili a tutti i nodi della rete. In questo caso sacrifichiamo la riservatezza dello smart contract e dei dati in cambio di un modello di consenso con tolleranza bizantina all'errore quale quello fornito dalla PoW.

Questa mancanza di riservatezza può essere problematica per molti casi d'uso aziendali. Ad esempio, in una rete di partner in una catena di approvvigionamento, ad alcuni consumatori potrebbero essere offerte tariffe privilegiate come mezzo per consolidare una relazione o promuovere vendite aggiuntive. Se tutti i partecipanti potessero vedere ogni contratto e transazione, diventerebbe impossibile mantenere tali relazioni commerciali in una rete completamente trasparente --- tutti vorrebbero le tariffe privilegiate!

Come secondo esempio, si consideri il settore dei titoli di borsa, in cui un trader che apre una posizione (o intende chiuderne una) non vuole che i suoi concorrenti lo sappiano, altrimenti essi cercherebbero di entrare in gioco, indebolendo la mossa del trader.

Al fine di affrontare la mancanza di privacy e riservatezza allo scopo di soddisfare i requisiti dei casi d'uso aziendali, le piattaforme blockchain hanno adottato una varietà di approcci. Tutti hanno i loro compromessi.

La cifratura dei dati è un approccio per garantire la riservatezza; tuttavia, in una rete permissionless che fa leva sulla PoW per il suo consenso, i dati cifrati si trovano su ogni nodo. Avendo abbastanza tempo e risorse di calcolo, i dati potrebbero essere decifrati. Per molti casi d'uso aziendali il rischio che le informazioni possano essere compromesse è inaccettabile.

Le _zero knowledge proof_ (ZKP - dimostrazione a conoscenza zero - metodi mediante i quali è possibile provare di possedere un'informazione senza doverla rivelare) sono un'altra area di ricerca esplorata per affrontare questo problema, il compromesso qui è che, attualmente, il calcolo di una ZKP richiede tempo e risorse computazionali considerevoli. Quindi il compromesso, in questo caso, è prestazione per riservatezza.

In un contesto permissioned che può sfruttare forme alternative di consenso, si potrebbero esplorare approcci che limitano la distribuzione di informazioni riservate esclusivamente ai nodi autorizzati.

Hyperledger Fabric, essendo una piattaforma permissioned, consente la riservatezza attraverso l'architettura a canali e la funzionalità dei [dati privati](./private-data/private-data.html). Nei canali, i partecipanti a una rete Fabric stabiliscono una sottorete in cui ogni membro ha visibilità su un particolare insieme di transazioni. Pertanto, solo quei nodi che partecipano a un canale hanno accesso allo smart contract (chaincode) e ai dati oggetto di transazione, preservando la privacy e la riservatezza di entrambi. I dati privati consentono raccolte di dati tra membri partecipanti a un canale, consentendo gran parte della stessa protezione garantita dai canali senza il sovraccarico di manutenzione dovuto alla creazione e al mantenimento di un canale separato.

## Consenso intercambiabile

L'ordinamento delle transazioni è delegato a un componente modulare per il consenso che è logicamente disaccoppiato dai peer che eseguono le transazioni e mantengono una copia del registro (ledger). Nello specifico, il servizio di ordinamento. Poiché il consenso è modulare, la sua implementazione può essere adattata alla fiducia accordata per assunto a una particolare distribuzione o soluzione. Questa architettura modulare consente alla piattaforma di fare affidamento su algoritmi consolidati per l'ordinamento come CFT (crash fault-tolerant) o BFT (byzantine fault-tolerant).

Fabric attualmente offre un'implementazione del servizio di ordinamento CFT basata sulla [libreria `etcd`](https://coreos.com/etcd/) del [protocollo Raft](https://raft.github.io/raft.pdf). Per informazioni sui servizi di ordinamento attualmente disponibili, consulta la nostra [documentazione concettuale sull'ordinamento](./orderer/ordering_service.html).

Si noti inoltre che questi non si escludono a vicenda. Una rete Fabric può avere più servizi di ordinamento che supportano applicazioni o requisiti applicativi differenti.

## Prestazioni e Scalabilità

Le prestazioni di una piattaforma blockchain possono essere influenzate da molte variabili come la dimensione della transazione, la dimensione del blocco, la dimensione della rete, nonché i limiti dell'hardware, ecc. Il gruppo di lavoro Hyperledger Fabric [Performance and Scale](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group) attualmente lavora su un framework di benchmarking chiamato [Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

Sono stati pubblicati diversi documenti di ricerca che hanno studiato e testato le capacità prestazionali di Hyperledger Fabric. L'ultimo ha [portato Fabric a 20.000 transazioni al secondo](https://arxiv.org/abs/1901.00910).

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
