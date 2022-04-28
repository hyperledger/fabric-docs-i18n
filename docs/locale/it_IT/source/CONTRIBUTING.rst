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

Primero, tómese el tiempo para revisar `JIRA <https://jira.hyperledger.org/issues/?filter=12524>`__ para asegurarse de que no haya una propuesta abierta (o cerrada recientemente) para la misma función. Si no lo hay, para hacer una propuesta, le recomendamos que abra una historia o una épica de JIRA, lo que mejor se adapte a la circunstancia y enlace o inserte una "página" de la propuesta que indique cuál sería la función.
Hacerlo y, si es posible, cómo podría implementarse. También ayudaría a argumentar por qué se debe agregar la función, como identificar casos de uso específicos para los cuales se necesita la función y un caso de cuál sería el beneficio si se implementara la función. Una vez que se crea el problema de la JIRA, y el "un paginador" ya sea adjunto, incluido en el campo de descripción, o un enlace a un documento de acceso público se agrega a la descripción, envíe un correo electrónico de presentación a fabric@lists.hyperledger.org lista de correo que vincula el tema de la JIRA y solicita comentarios.

La discusión de la característica propuesta debe llevarse a cabo en el tema de JIRA en sí, de modo que tengamos un patrón consistente dentro de nuestra comunidad sobre dónde encontrar la discusión de diseño.

Obtener el apoyo de tres o más de los mantenedores de Hyperledger Fabric para la nueva función aumentará en gran medida la probabilidad de que los PR relacionados con la función se incluyan en una versión posterior.

Reunion de contribuyentes
~~~~~~~~~~~~~~~~~~~~~~~~~

Los mantenedores celebran reuniones periódicas de contribuyentes.
El propósito de la reunión de contribuyentes es planificar y revisar el progreso de las emisiones y contribuciones, y discutir la dirección técnica y operativa del proyecto y los subproyectos.

Consulte la `wiki <https://wiki.hyperledger.org/display/fabric/Contributor+Meetings>`__ para conocer los detalles de la reunión de mantenedores.

Las propuestas de nuevas características / mejoras descritas anteriormente deben presentarse en una reunión de mantenedores para su consideración, comentarios y aceptación.

Hoja de ruta de lanzamiento
~~~~~~~~~~~~~~~~~~~~~~~~~~~

La hoja de ruta de epicas del lanzamiento de Fabric se mantiene en
`JIRA <https://jira.hyperledger.org/secure/Dashboard.jspa?selectPageId=10104>`__.

Comunicaciones
~~~~~~~~~~~~~~

Usamos `RocketChat <https://chat.hyperledger.org/>`__ para la comunicación y Google Hangouts ™ para compartir la pantalla entre desarrolladores. Nuestra planificación de desarrollo y priorización se realiza en `JIRA <https://jira.hyperledger.org>`__ y llevamos discusiones / decisiones más largas a la `lista de correo <https://lists.hyperledger.org/mailman/listinfo/hyperledger-fabric>`__.

Guia de Contribucion
--------------------

Instalacion de prerrequisitos
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Antes de comenzar, si aún no lo ha hecho, es posible que desee verificar que tiene todos los :doc:`prerequisites <prereqs>` instalados en la plataforma (s) en la que desarrollará aplicaciones de cadena de bloques y/o utilizará Hyperledger Fabric. 


Como conseguir ayuda
~~~~~~~~~~~~~~~~~~~~

Si está buscando algo en lo que trabajar o necesita asistencia de un experto para depurar un problema o solucionar un problema, nuestra `comunidad <https://www.hyperledger.org/community>`__ siempre está dispuesta a ayudar. Pasamos el rato en `Chat <https://chat.hyperledger.org/channel/fabric/>`__, IRC (#hyperledger on freenode.net) y las `listas de correo <https://lists.hyperledger.org/>`__. La mayoría de nosotros no mordemos :sonríe: y estaremos encantados de ayudar. La única pregunta tonta es la que no haces. De hecho, las preguntas son una excelente manera de ayudar a mejorar el proyecto, ya que resaltan dónde nuestra documentación podría ser más clara.

Segnalare bug
~~~~~~~~~~~~~

Si es un usuario y ha encontrado un error, envíe un problema utilizando `JIRA <https://jira.hyperledger.org/secure/Dashboard.jspa?selectPageId=10104>`__.
Antes de crear un nuevo problema de JIRA, intente buscar los elementos existentes para asegurarse de que nadie más lo haya informado anteriormente. Si se ha informado anteriormente, puede agregar un comentario de que también está interesado en que se solucione el defecto.

.. note:: Si el defecto está relacionado con la seguridad, 
         siga el proceso de informe de `errores de seguridad de Hyperledger <https://wiki.hyperledger.org/display/HYP/Defect+Response>`__.

Si no se ha informado anteriormente, puede enviar un PR con un mensaje de confirmación bien documentado que describa el defecto y la solución, o puede crear una nueva JIRA. Intente proporcionar suficiente información para que otra persona pueda reproducir el problema. Uno de los encargados del mantenimiento del proyecto debe responder a su problema dentro de las 24 horas. De lo contrario, agregue un comentario al problema y solicite que sea
revisado. También puede publicar en el canal Hyperledger Fabric relevante en `Chat de Hyperledger <https://chat.hyperledger.org>`__. Por ejemplo, un error de documento debe transmitirse a ``#fabric-documentation``, un error de base de datos a ``#fabric-ledger``, y así sucesivamente ...

Envío de su corrección
~~~~~~~~~~~~~~~~~~~~~~

Si acaba de enviar una JIRA para un error que ha descubierto y le gustaría proporcionar una solución, ¡lo agradeceríamos con mucho gusto! Asigne el problema de JIRA a sí mismo y luego envíe un pull request (PR). Consulte :doc:`github/github` para obtener un flujo de trabajo detallado.

Risolvere issue e storie di lavoro
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Revise la `lista de problemas <https://jira.hyperledger.org/issues/?filter=10580>`__ y encuentre algo que le interese. También puede consultar `la lista de ayuda solicitada <https://jira.hyperledger.org/issues/?filter=10147>`__. Es aconsejable comenzar con algo relativamente sencillo y alcanzable, y que nadie ya esté asignado. Si no hay nadie asignado, asígnese el problema a usted mismo. Sea considerado y anule la asignación si no puede terminar en un tiempo razonable, o agregue un comentario que diga que todavía está trabajando activamente en el problema si necesita un poco más de tiempo.

Revisando Pull Requests enviados (PRs)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Otra forma de contribuir y aprender sobre Hyperledger Fabric es ayudar a los mantenedores con la revisión de los PR que están abiertos. En efecto
Los mantenedores tienen el difícil papel de tener que revisar todos los PR que se envían y evaluar si deben fusionarse o
no. Puede revisar los cambios en el código y/o la documentación, probar los cambios y decirles a los remitentes y mantenedores lo que piensa. Una vez que su revisión y/o prueba esté completa, simplemente responda al PR con sus hallazgos, agregando comentarios y / o votando. Un comentario que diga algo como "Lo probé en el sistema X y funciona" o posiblemente "Recibí un error en el sistema X: xxx" ayudará a los mantenedores en su evaluación. Como resultado, los mantenedores podrán procesar los PR más rápido y todos se beneficiarán de ello.

Simplemente navegue a través de los `PR abiertos <https://github.com/hyperledger/fabric/pulls>`__ en GitHub para comenzar.

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
