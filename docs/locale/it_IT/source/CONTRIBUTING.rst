Contribuisci anche tu!
======================

Accogliamo contributi a Hyperledger in molte forme, e c'è sempre molto da fare!

Per prima cosa, consulta il `Codice di Condotta <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`_ di Hyperledger prima di partecipare. È importante comportarsi in modo civile.

.. note:: Se desideri contribuire a questa documentazione, consulta la :doc:`style_guide`.

Come contribuire
----------------
Ci sono molti modi in cui puoi contribuire a Hyperledger Fabric, sia come utente sia come sviluppatore.
  
Come utente:

- `Proporre nuove feature o miglioramenti`_
- `Segnalare bug`_


Come autore:

- Aggiornando la documentazione in base alla tua esperienza con Fabric e con questa documentazione per migliorare gli articoli esistenti e crearne di nuovi. Una modifica alla documentazione è un modo semplice per iniziare a collaborare, facilita la comprensione e l'utilizzo di Fabric da parte degli altri utenti, e aumenta l'insieme dei tuoi contributi a progetti open source.


- Partecipando a una traduzione per mantenere aggiornata la documentazione Fabric nella lingua scelta. La documentazione Fabric è disponibile in diverse lingue – inglese, cinese, malayalam e portoghese brasiliano – quindi perché non unirti a un team che la mantiene aggiornata? Troverai un'amichevole comunità di utenti, autori e sviluppatori con cui collaborare.


- Iniziando una nuova traduzione in una nuova lingua se la documentazione di Fabric non è disponibile nella tua lingua. I gruppi di cinese, malayalam e portoghese brasiliano hanno iniziato in questo modo e puoi farlo anche tu! C'è più lavoro da fare, poiché dovrai formare una comunità di autori e organizzare i contributi; ma è davvero appagante vedere la documentazione di Fabric disponibile nella lingua scelta.

Leggi `Contribuire alla documentazione`_ per iniziare il lavoro.

Come sviluppatore:

- Se hai poco tempo, puoi considerare un primo task come ad esempio una tra le `"good first issue" <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`_; leggi `Risolvere issue e storie di lavoro`_.
- Se puoi impegnarti nello sviluppo a tempo pieno, puoi proporre una nuova feature (leggi `Proporre nuove feature o miglioramenti`_) e costruire un gruppo per implementarla, oppure puoi unirti a uno dei gruppi che lavora a un Epic esistente. Se trovi un Epic che ti interessa sul `GitHub epic backlog <https://github.com/hyperledger/fabric/labels/Epic>`_, contatta pure l'assignee dell'Epic attraverso il GitHub Issue tracker.


Creare un account della Linux Foundation
----------------------------------------

Per partecipare allo sviluppo del progetto Fabric, avrai bisogno di un account della Linux Foundation. Quando avrai un LF ID, potrai accedere a tutti gli strumenti della comunità Hyperledger, inclusi `RocketChat <https://wiki.hyperledger.org/display/HYP/Our+chat+service>`__, e la `Wiki <https://wiki.hyperledger.org/display/fabric/Hyperledger+Fabric>`__ (solo per le modifiche).

Segui i passaggi seguenti per creare un account della Linux Foundation se non ne hai già uno.

1. Vai sul sul sito della `Linux Foundation ID <https://identity.linuxfoundation.org/>`__.

2. Seleziona l'opzione ``I need to create a Linux Foundation ID``, e compila il form che compare.

3. Attendi qualche minuto, quindi cerca un messaggio di posta elettronica con l'oggetto:
   "Validate your Linux Foundation ID email".

4. Apri l'URL ricevuto per convalidare il tuo indirizzo email.

5. Verifica che il tuo browser visualizzi il messaggio
   ``You have successfully validated your e-mail address``.

6. Accedi a `RocketChat <https://wiki.hyperledger.org/display/HYP/Our+chat+service>`__ per confermare l'accesso.

Contribuire alla documentazione
-------------------------------

Sarebbe una buona idea che il tuo primo contributo fosse una modifica alla documentazione. È facile e veloce da realizzare, ti garantisce di avere una macchina configurata correttamente (compreso il software necessario), e ti permette di familiarizzare con il processo di collaborazione. Usa i seguenti articoli per iniziare:

.. toctree::
   :maxdepth: 1

   advice_for_writers
   docs_guide
   international_languages
   style_guide

Governance del progetto
-----------------------

Hyperledger Fabric è gestito secondo un modello di open governance come descritto nel nostro `charter <https://www.hyperledger.org/about/charter>`__. Progetti e sottoprogetti sono guidati da un gruppo di *maintainer* (manutentore del software). I nuovi sottoprogetti possono designare un gruppo iniziale di maintainer che sarà approvato dai maintainer di primo livello del progetto quando il progetto inizia.

Maintainer
~~~~~~~~~~

Il progetto Fabric è diretto dai `maintainer <https://github.com/hyperledger/fabric/blob/master/MAINTAINERS.md>`__ di primo livello del progetto. Essi sono responsabili del controllo e del merging di tutte le patch inviate per la revisione, e guidano la direzione tecnica complessiva stabilita dal *Technical Steering Committee* (TSC, Commissione Tecnica Direttiva) di Hyperledger.

Diventare un Maintainer
~~~~~~~~~~~~~~~~~~~~~~~

I maintainer del progetto, di volta in volta, prenderanno in considerazione l'aggiunta di un maintainer, in base ai seguenti criteri:

- Comprovato contributo alla revisione di PR (sia in termini di qualità sia in termini di quantità delle revisioni)
- Comprovata leadership intellettuale nel progetto
- Comprovata capacità di conduzione del progetto e dei collaboratori

Un maintainer in carica può inviare una pull request al file dei `maintainer <https://github.com/hyperledger/fabric/blob/master/MAINTAINERS.md>`__.
Un *contributor* (collaboratore) nominato può diventare un maintainer con l'approvazione della proposta a maggioranza da parte dei maintainer in carica. Una volta approvato, viene quindi effettuato il merge del set di modifiche e l'individuo viene aggiunto al gruppo dei maintainer.

I maintainer possono essere rimossi per rinuncia esplicita, per inattività prolungata (es. 3 o più mesi senza commenti alle revisioni), per infrazione al `Codice di Condotta <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`__ o per aver dimostrato frequentemente scarsa capacità di giudizio. Anche una proposta di rimozione richiede l'approvazione a maggioranza. Un maintainer rimosso per inattività dovrebbe essere reintegrato dopo una prolungata ripresa dei contributi e delle revisioni (un mese o più) che dimostrino un rinnovato impegno nel progetto.

Release
~~~~~~~

Fabric fa uscire una *release* (rilascio del software) approssimativamente una volta ogni quattro mesi con nuove feature e miglioramenti. Le nuove feature vengono integrate nel *main branch* (ramo principale di un repository)  su `GitHub <https://github.com/hyperledger/fabric>`__.
I release branch vengono creati prima di ogni release così che il codice possa stabilizzarsi mentre nuove feature continuano a essere integrate nel master branch. *Fix* (correzioni del codice) importanti saranno anche integrati nel più recente release branch LTS (*long-term support*, supporto a lungo termine), e nel precedente release branch LTS durante periodi di sovrapposizione delle release.

Leggi la documentazione sulle `release <https://github.com/hyperledger/fabric#releases>`__ per maggiori dettagli.


Proporre nuove feature o miglioramenti
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

È possibile implementare e revisionare piccoli miglioramenti attraverso il normale `flusso di lavoro delle pull request su GitHub <https://docs.github.com/en/get-started/quickstart/github-flow>`__ ma per cambiamenti più sostanziali Fabric segue il processo RFC (*request for comments*, richiesta di commenti).

Questa procedura ha lo scopo di fornire un percorso coerente e controllato per le principali modifiche a Fabric e agli altri componenti ufficiali del progetto, così che tutte le parti interessate possano essere sicure della direzione in cui Fabric sta evolvendo.

Per proporre una nuova feature, innanzitutto, controlla il `backlog delle issue su GitHub <https://github.com/hyperledger/fabric/issues>`__ e il `repository di Fabric RFC <https://github.com/hyperledger/fabric-rfcs/>`__ per assicurarti che non ci sia già una proposta aperta (o chiusa di recente) per la stessa funzionalità. Se non c'è, segui il `processo RFC <https://github.com/hyperledger/fabric-rfcs/blob/main/README.md>`__ per fare una proposta.

Riunione dei contributor
~~~~~~~~~~~~~~~~~~~~~~~~

I maintainer tengono regolarmente delle riunioni dei contributor. Lo scopo della riunione dei contributor è di pianificare e revisionare lo stato di avanzamento delle release e dei contributi, e di discutere la direzione tecnica e operativa del progetto e dei sottoprogetti.

Consulta la `wiki <https://wiki.hyperledger.org/display/fabric/Contributor+Meetings>`__ per i dettagli sulle riunioni dei maintainer.

Le proposte di nuove feature/miglioramenti, come descritto sopra, dovrebbero essere presentate a una riunione dei maintainer per valutazione, feedback e approvazione.


Tabella di marcia delle release
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

La tabella di marcia delle release di Fabric è gestita come una lista di `issue su GitHub con l'etichetta Epic <https://github.com/hyperledger/fabric/labels/Epic>`__.

Comunicazioni
~~~~~~~~~~~~~

Usiamo `RocketChat <https://wiki.hyperledger.org/display/HYP/Our+chat+service>`__ per comunicare e Google Hangouts™ per la condivisione dello schermo tra sviluppatori. La nostra pianificazione dello sviluppo e la definizione delle priorità sono realizzate usando il `board GitHub Issues ZenHub <https://app.zenhub.com/workspaces/fabric-57c43689b6f3d8060d082cf1/board>`__ mentre presentiamo discussioni/decisioni più impegnative alla riunione dei contributor di Fabric o sulla `mailing list <https://lists.hyperledger.org/g/fabric>`__.

Guida alla collaborazione
-------------------------

Installare i prerequisiti
~~~~~~~~~~~~~~~~~~~~~~~~~

Prima di iniziare, se non l'hai già fatto, dovresti verificare di avere tutti i :doc:`prerequisiti <prereqs>` installati sulla/e piattaforma/e su cui svilupperai applicazioni blockchain e/o eseguirai Hyperledger Fabric.


Come ricevere aiuto
~~~~~~~~~~~~~~~~~~~

Se stai cercando qualcosa su cui lavorare, o hai bisogno di assistenza qualificata per il *debug* di un problema o per trovare la soluzione a una issue, la nostra `comunità <https://www.hyperledger.org/community>`__ è sempre pronta ad aiutarti. Puoi trovarci su `Chat <https://wiki.hyperledger.org/display/HYP/Our+chat+service/>`__, IRC (#hyperledger su freenode.net) o sulla `mailing list <https://lists.hyperledger.org/g/main/>`__. La maggiorparte di noi non morde :grin: e sarà felice di aiutarti. La sola domanda stupida è quella che non fai. Le domande sono infatti una grande occasione per aiutarci a migliorare il progetto perché evidenziano dove la nostra documentazione potrebbe essere più chiara.

Segnalare bug
~~~~~~~~~~~~~

Se sei un utente e hai riscontrato un bug, per favore crea un issue usando i `GitHub Issues <https://github.com/hyperledger/fabric/issues>`__.
Prima di creare un nuovo issue su GitHub, per favore ricerca tra gli issue esistenti per essere sicuro che nessuno lo abbia già segnalato. Se è già stato segnalato, potresti anche aggiungere un commento che dimostri che anche tu sei interessato a vedere risolto il problema.

.. note:: Se il problema è legato alla sicurezza, per favore segui il `processo di segnalazione dei bug di sicurezza <https://wiki.hyperledger.org/display/SEC/Defect+Response>`__ di Hyperledger.
          
Se non è già stato segnalato, potresti creare una pull request con un messaggio di commit ben documentato che descriva il problema e la sua soluzione, oppure potresti creare un nuovo issue su GitHub. Per favore prova a fornire informazioni sufficienti perché qualcun altro possa riprodurre il problema. Uno dei maintainer del progetto dovrebbe risponderti entro 24 ore. In caso contrario, per favore sposta l'issue in alto con un commento e richiedi che venga revisionato. Puoi anche scrivere sul canale di Hyperledger Fabric appropriato della `chat di Hyperledger <https://wiki.hyperledger.org/display/HYP/Our+chat+service>`__. Per esempio, un bug relativo alla documentazione dovrebbe essere segnalato su ``#fabric-documentation``, un bug relativo ai database su ``#fabric-ledger``, e così via...

Sottoporre un fix
~~~~~~~~~~~~~~~~~

Se hai appena aperto un issue su GitHub per un bug che hai scoperto, e vorresti fornire un fix, lo accoglieremmo volentieri! Per favore assegna l'issue su GitHub a te stesso, e poi crea una pull request (PR). Consulta la pagina :doc:`github/github` per maggiori dettagli sul flusso di lavoro.

Risolvere issue e storie di lavoro
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

I problemi e i bug di Fabric sono gestiti nelle `issue su GitHub <https://github.com/hyperledger/fabric/issues>`__. Potresti anche controllare la lista delle `"good first issue" <https://github.com/hyperledger/fabric/labels/good%20first%20issue>`__. È bene iniziare con qualcosa di relativamente facile e realizzabile, e che non sia già stato assegnato. Se nessuno ci sta lavorando, assegna l'issue a te stesso. Per favore, sii ragionevole e rinuncia all'incarico se non riesci a finire in un tempo raigonevole, o aggiungi un commento specificando che stai ancora lavorando attivamente all'issue se hai bisogno di un po' più di tempo.

Nonostante su GitHub sia presente un backlog di issue note su cui si potrebbe lavorare in futuro, se hai intenzione di lavorare immediatamente a una modifica che non ha ancora un issue corrispondente, puoi creare una pull request su `GitHub <https://github.com/hyperledger/fabric>`__ senza collegamento a un issue esistente.

Revisionare Pull Request (PR) aperte
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Un altro modo di scoprire e contribuire a Hyperledger Fabric è quello di aiutare i maintainer con la revisione delle PR aperte. In effetti i maintainer hanno il difficile compito di dover revisionare tutte le PR che vengono create e valutare se sia il caso di farne il merging o meno. Puoi revisionare il codice e/o le modifiche alla documentazione, testare le modifiche, e dire ai contributor e ai maintainer cosa ne pensi. Una volta che la tua revisione e/o test sono completi rispondi semplicemente alla PR facendo presenti le tue scoperte, aggiungendo commenti e/o votando. Un commento come "L'ho provato sul sistema X e funziona" o eventualmente "Ho riscontrato un errore sul sistema X: xxx" aiuterà i maintainer nella loro valutazione. Di conseguenza, i maintainer saranno in grado di elaborare le PR più rapidamente e tutti ne trarranno beneficio.

Dai un'occhiata alle `PR aperte su GitHub <https://github.com/hyperledger/fabric/pulls>`__ per iniziare.

Envegecimiento de PR
~~~~~~~~~~~~~~~~~~~~

A medida que el proyecto Fabric ha crecido, también lo ha hecho la acumulación de PRs abiertos. Un problema al que se enfrentan casi todos los proyectos es la gestión eficaz de esa acumulación y Fabric no es una excepción. En un esfuerzo por mantener manejable la acumulación de proyectos de Fabric y los PRs relacionados con el proyecto, estamos introduciendo una política de envejecimiento que los bots harán cumplir. Esto es coherente con la forma en que otros grandes proyectos gestionan su acumulación de PRs.

Politica de Envegecimiento de PR
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Los mantenedores del proyecto Fabric monitorearán automáticamente toda la actividad de relaciones públicas para detectar morosidad. Si un PR no se ha actualizado en 2 semanas, se agregará un comentario recordatorio solicitando que el PR se actualice para abordar cualquier comentario pendiente o se abandone si se va a retirar. Si un PR moroso pasa otras 2 semanas sin una actualización, se abandonará automáticamente. Si un PR ha envejecido más de 2 meses desde que se envió originalmente, incluso si tiene actividad, se marcará para la revisión del mantenedor.

Si un PR enviado ha pasado toda la validación pero no ha sido revisado en 72 horas (3 días), se marcará al canal #fabric-pr-review diariamente hasta que reciba un comentario de revisión.

Esta política se aplica a todos los proyectos oficiales de Fabric (fabric, fabric-ca,
fabric-samples, fabric-test, fabric-sdk-node, fabric-sdk-java, fabric-gateway-java,
fabric-chaincode-node, fabric-chaincode-java, fabric-chaincode-evm,
fabric-baseimage, y fabric-amcl).

Configuración del entorno de desarrollo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A continuación, intente :doc:`construyendo el proyecto <dev-setup/build>` en su entorno de desarrollo local para garantizar que todo esté configurado correctamente.

Caracteristicas de un buen PR
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  Un cambio a la vez. Ni cinco, ni tres, ni diez. Uno y solo uno. ¿Por qué? Porque limita el área de explosión del cambio. Si tenemos una regresión, es mucho más fácil identificar el compromiso culpable que si tenemos algún cambio compuesto que impacta más en el código.

-  Incluya un enlace a la historia de JIRA para el cambio. ¿Por qué? Porque a) queremos rastrear nuestra velocidad para juzgar mejor lo que creemos que podemos entregar y cuándo y b) porque podemos justificar el cambio de manera más efectiva. En muchos casos, debería haber alguna discusión en torno a un cambio propuesto y queremos vincularlo desde el cambio en sí.

-  Incluya pruebas unitarias y de integración (o cambios en las pruebas existentes) con cada cambio. Esto tampoco significa simplemente una prueba de ruta feliz. También significa una prueba negativa de cualquier código defensivo para detectar correctamente los errores de entrada. Cuando escribe código, es responsable de probarlo y proporcionar las pruebas que demuestren que su cambio hace lo que dice. ¿Por qué? Porque sin esto no tenemos ni idea de si nuestra base de código actual realmente funciona.

-  Las pruebas unitarias NO deben tener dependencias externas. Debería poder ejecutar pruebas unitarias en su lugar con ``go test`` o equivalente para el idioma. Cualquier prueba que requiera alguna dependencia externa (por ejemplo, debe estar programada para ejecutar otro componente) necesita un mocking adecuado.

Cualquier otra cosa no es una prueba unitaria, es una prueba de integración por definición. ¿Por qué? Porque muchos desarrolladores de código abierto realizan el desarrollo basado en pruebas. Colocan un reloj en el directorio que invoca las pruebas automáticamente cuando se cambia el código. Esto es mucho más eficiente que tener que ejecutar una compilación completa entre cambios de código. Consulte `esta definición <http://artofunittesting.com/definition-of-a-unit-test/>`__ de pruebas unitarias para obtener un buen conjunto de criterios a tener en cuenta para escribir pruebas unitarias efectivas.

-  Minimice las líneas de código por PR. ¿Por qué? Los mantenedores también tienen trabajos diarios. Si envía un cambio de 1000 o 2000 LOC, ¿cuánto tiempo cree que se tarda en revisar todo ese código? Mantenga sus cambios en <200-300 LOC, si es posible. Si tiene un cambio mayor, descompóngalo en varios cambios independientes. Si está agregando un montón de funciones nuevas para cumplir con los requisitos de una nueva capacidad, agréguelas por separado con sus pruebas y luego escriba el código que las usa para entregar la capacidad. Por supuesto, siempre hay excepciones. Si agrega un pequeño cambio y luego agrega 300 LOC de pruebas, será perdonado ;-) Si necesita hacer un cambio que tenga un impacto amplio o un montón de código generado (protobufs, etc.). Nuevamente, puede haber excepciones.

.. note:: Grandes solicitudes de extracción, p. Ej. es muy probable que aquellos con más de 300 LOC no reciban una aprobación, y se le pedirá que refactorice el cambio para cumplir con esta guía.

-  Escribe un mensaje de confirmación significativo. Incluya un título significativo de 55 (o menos) caracteres, seguido de una línea en blanco, seguida de una descripción más completa del cambio. Cada cambio DEBE incluir el identificador JIRA correspondiente al cambio (por ejemplo, [FAB-1234]). Esto puede estar en el título, pero también debería estar en el cuerpo del mensaje de confirmación.

.. note:: Ejemplo de mensaje de commit:

          ::

              [FAB-1234] fix foobar() panic

              Fix [FAB-1234] added a check to ensure that when foobar(foo string)
              is called, that there is a non-empty string argument.

Finalmente, sea receptivo. No permita que una solicitud de extracción se infecte con comentarios de revisión de modo que llegue a un punto en el que requiera una nueva base. Solo retrasa aún más la fusión y agrega más trabajo para usted, para remediar los conflictos de fusión.

Cosas Legales
-------------

**Nota:** Cada archivo de origen debe incluir un encabezado de licencia para Apache Software License 2.0. Consulte la plantilla del `encabezado de licencia <https://github.com/hyperledger/fabric/blob/master/docs/source/dev-setup/headers.txt>`__.

We have tried to make it as easy as possible to make contributions. This
applies to how we handle the legal aspects of contribution. We use the
same approach—the `Developer's Certificate of Origin 1.1
(DCO) <https://github.com/hyperledger/fabric/blob/master/docs/source/DCO1.1.txt>`__—that the Linux® Kernel
`community <https://elinux.org/Developer_Certificate_Of_Origin>`__ uses
to manage code contributions.

Hemos tratado de facilitar al máximo la realización de contribuciones. Esto se aplica a cómo manejamos los aspectos legales de la contribución. Usamos el mismo enfoque, el `Certificado de origen 1.1 (DCO) del desarrollador <https://github.com/hyperledger/fabric/blob/master/docs/source/DCO1.1.txt>`__ - que Linux® Kernel `community <https://elinux.org/Developer_Certificate_Of_Origin>`__ utiliza para administrar las contribuciones de código.

Simplemente pedimos que al enviar un parche para su revisión, el desarrollador debe incluir una declaración de aprobación en el mensaje de confirmación.


A continuación, se muestra un ejemplo de Signed-off-by, que indica que el
el remitente acepta el DCO:

::

    Signed-off-by: John Doe <john.doe@example.com>

Puedes incluir esto automáticamente cuando confirmes un cambio en tu repositorio de git local usando ``git commit -s``.

Related Topics
--------------

.. toctree::
   :maxdepth: 1

   jira_navigation
   dev-setup/devenv
   dev-setup/build
   style-guides/go-style

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
