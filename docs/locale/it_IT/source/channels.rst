Canali
========

Un ``canale`` di Hyperledger Fabric è una "sottorete" di comunicazione privata tra due
o più membri della rete, che serve a scambiarsi transazioni in maniera privata.
Un canale è definito dai membri (organizzazioni), peer per ogni organizzazione,
il ledger condiviso, applicazioni chaincode e i nodi dell'ordering service.
Ogni transazione nella rete è eseguita all'interno di un canale, dove ogni
membro deve autenticarsi ed essere autorizzato a condurre transazioni su quel canale.
Ogni peer che entra a far parte di un canale, ha la sua identità, data da un Membership Services Provider (MSP),
che autentica ogni peer ai peer e servizi del canale.

Per creare un nuovo canale, il client SDK chiama la configurazione del system chaincode
referenziando proprietà come gli ``anchor peers`` e i membri (le organizzazioni).
Questa richiesta crea un ``genesis block`` per il ledger del canale, che memorizza
le informazioni sulla configurazione riguardo le policy del canale, i membri e i peers.
Quando si aggiunge un nuovo membro ad un canale già esistente, questo genesis block o,
se disponibile, un blocco più recente di configurazione, viene condiviso con il nuovo membro.

.. note:: Vedi la sezione :doc:`configtx` per più dettagli sulle proprietà
          e strutture delle transazioni di configurazione

L'elezione di un ``leading peer`` per ogni membro sul canale determina quale peer
comunica con l'ordering service. Se nessun leader viene identificato, può
essere usato un algoritmo per identificare il leader. Il servizio di consenso
ordina le transazioni e le distribuisce, in blocchi, ad ogni leading peer, che a sua volta
distribuisce i blocchi agli altri peer, e attraverso il canale, usando il protocollo
di ``gossip``.

Sebbene un qualsiasi anchor peer possa appartenere a più canali, e quindi
mantenere più registri, nessun dato di registro può passare da un canale all'altro.
Questa separazione dei registri, per canale, è definita e implementata dal chaincode
di configurazione, l'MSP e i dati di gossip protocol di diffusione. La diffusione dei dati,
che include informazioni sulle transazioni, lo stato del registro e l'appartenenza al canale
sono limitati ai peer con appartenenza verificabile sul canale. Questo isolamento di peer e dati contabili
per canale, consente ai membri della rete che richiedono transazioni private e confidenziali
per coesistere con concorrenti aziendali e altri membri soggetti a restrizioni,
sulla stessa rete blockchain.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
