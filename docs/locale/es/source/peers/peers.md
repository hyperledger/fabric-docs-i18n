# Pares

Una red de blockchain está compuesta principalmente por un conjunto de *nodos pares* (o simplemente, *pares*).
Los pares son un elemento fundamental de la red porque alojan los libros de contabilidad y los
contratos inteligentes. Recuerda que un libro de contabilidad registra de manera inmutable todas las transacciones generadas
por contratos inteligentes (que en Hyperledger Fabric están contenidos en un *chaincode*,
más sobre esto más adelante). Los contratos inteligentes y los libros de contabilidad se utilizan para encapsular los
*procesos* compartidos y la *información* compartida en una red, respectivamente. Estos
aspectos de un par los convierten en un buen punto de partida para entender una red Fabric.

Otros elementos de la red blockchain son, por supuesto, importantes: libros de contabilidad y
contratos inteligentes, ordenadores, políticas, canales, aplicaciones, organizaciones,
identidades y membresía, y puedes leer más sobre ellos en sus propias
secciones dedicadas. Esta sección se centra en los pares, y su relación con esos
otros elementos en una red Fabric.

![Peer1](./peers.diagram.1.png)

*Una red de blockchain está compuesta por nodos pares, cada uno de los cuales puede mantener copias
de los libros de contabilidad y copias de los contratos inteligentes. En este ejemplo, la red N
consiste en los pares P1, P2 y P3, cada uno de los cuales mantiene su propia instancia del
libro de contabilidad distribuido L1. P1, P2 y P3 utilizan el mismo chaincode, S1, para acceder
a su copia de ese libro de contabilidad distribuido*.

Los pares pueden ser creados, iniciados, detenidos, reconfigurados e incluso eliminados. Ellos
exponen un conjunto de APIs que permiten a los administradores y aplicaciones interactuar
con los servicios que proporcionan. Aprenderemos más sobre estos servicios en
esta sección.

### Una palabra sobre la terminología

Fabric implementa **contratos inteligentes** con un concepto tecnológico que llama
**chaincode** --- simplemente un fragmento de código que accede al libro de contabilidad, escrito en
uno de los lenguajes de programación soportados. En este tema, generalmente usaremos el
término **chaincode**, pero siéntete libre de leerlo como **contrato inteligente** si estás
más acostumbrado a ese término. ¡Es lo mismo! Si quieres aprender más sobre
chaincode y contratos inteligentes, consulta nuestra [documentación sobre contratos inteligentes
y chaincode](../smartcontract/smartcontract.html).

## Libros de Contabilidad y Chaincode

Veamos un par en un poco más de detalle. Podemos ver que es el par el que
aloja tanto el libro de contabilidad como el chaincode. Más precisamente, el par realmente aloja
*instancias* del libro de contabilidad, y *instancias* de chaincode. Nota que esto proporciona
una redundancia deliberada en una red Fabric --- evita puntos únicos de
fallo. Aprenderemos más sobre la naturaleza distribuida y descentralizada de una
red blockchain más adelante en esta sección.

![Peer2](./peers.diagram.2.png)

*Un par aloja instancias de libros de contabilidad e instancias de chaincodes. En este ejemplo,
P1 aloja una instancia del libro de contabilidad L1 y una instancia del chaincode S1. Puede
haber muchos libros de contabilidad y chaincodes alojados en un par individual.*

Dado que un par es un *anfitrión* para libros de contabilidad y chaincodes, aplicaciones y
administradores deben interactuar con un par si quieren acceder a estos recursos.
Por eso los pares son considerados los bloques de construcción más fundamentales de una
red Fabric. Cuando un par es creado por primera vez, no tiene ni libros de contabilidad ni
chaincodes. Veremos más adelante cómo se crean los libros de contabilidad, y cómo se instalan
chaincodes, en los pares.

### Múltiples Libros de Contabilidad

Un par es capaz de alojar más de un libro de contabilidad, lo cual es útil porque permite
un diseño de sistema flexible. La configuración más simple es que un par gestione un
único libro de contabilidad, pero es absolutamente apropiado que un par aloje dos o más
libros de contabilidad cuando sea necesario.

![Peer3](./peers.diagram.3.png)

*Un par alojando múltiples libros de contabilidad. Los pares alojan uno o más libros de contabilidad, y cada
libro de contabilidad tiene cero o más chaincodes que se aplican a ellos. En este ejemplo, podemos
ver que el par P1 aloja los libros de contabilidad L1 y L2. El libro de contabilidad L1 se accede utilizando
el chaincode S1. Por otro lado, el libro de contabilidad L2 puede ser accedido utilizando los chaincodes S1 y S2.*

Aunque es perfectamente posible que un par aloje una instancia de libro de contabilidad sin
alojar ningún chaincode que acceda a ese libro de contabilidad, es raro que los pares estén configurados
de esta manera. La gran mayoría de los pares tendrán al menos un chaincode instalado
en él que puede consultar o actualizar las instancias del libro de contabilidad del par. Vale la pena
mencionar de pasada que, ya sea que los usuarios hayan instalado chaincodes para uso por
aplicaciones externas, los pares también tienen **chaincodes de sistema** especiales que siempre
están presentes. Estos no se discuten en detalle en este tema.

### Múltiples Chaincodes

No hay una relación fija entre el número de libros de contabilidad que un par tiene y
el número de chaincodes que pueden acceder a ese libro de contabilidad. Un par podría tener
muchos chaincodes y muchos libros de contabilidad disponibles para él.

![Peer4](./peers.diagram.4.png)

*Un ejemplo de un par alojando múltiples chaincodes. Cada libro de contabilidad puede tener
muchos chaincodes que lo acceden. En este ejemplo, podemos ver que el par P1
aloja los libros de contabilidad L1 y L2, donde L1 es accedido por los chaincodes S1 y S2, y
L2 es accedido por S1 y S3. Podemos ver que S1 puede acceder tanto a L1 como a L2.*

Veremos un poco más adelante por qué el concepto de **canales** en Fabric es importante
cuando se alojan múltiples libros de contabilidad o múltiples chaincodes en un par.

## Aplicaciones y Pares

Ahora vamos a mostrar cómo las aplicaciones interactúan con los pares para acceder al
libro de contabilidad. Las interacciones de consulta del libro de contabilidad implican un simple diálogo de tres pasos entre
una aplicación y un par; las interacciones de actualización del libro de contabilidad son un poco más
complicadas, y requieren dos pasos adicionales. Hemos simplificado estos pasos un poco para
ayudarte a comenzar con Fabric, pero no te preocupes --- lo más importante que debes
entender es la diferencia en las interacciones entre aplicaciones y pares para consultas del libro de contabilidad
comparado con los estilos de transacción de actualización del libro de contabilidad.

Las aplicaciones siempre se conectan a los pares cuando necesitan acceder a los libros de contabilidad y
chaincodes. El Kit de Desarrollo de Software (SDK) de Fabric hace esto
fácil para los programadores --- sus APIs permiten que las aplicaciones se conecten a los pares, invoquen
chaincodes para generar transacciones, envíen transacciones a la red que
serán ordenadas, validadas y comprometidas al libro de contabilidad distribuido, y reciban
eventos cuando este proceso esté completo.

A través de una conexión con un par, las aplicaciones pueden ejecutar chaincodes para consultar o
actualizar un libro de contabilidad. El resultado de una transacción de consulta del libro de contabilidad se devuelve
inmediatamente, mientras que las actualizaciones del libro de contabilidad involucran una interacción más compleja entre
aplicaciones, pares y ordenadores. Investigaremos esto con un poco más de detalle.

![Peer6](./peers.diagram.6.png)

*Los pares, en conjunto con los ordenadores, aseguran que el libro de contabilidad se mantenga actualizado
en cada par. En este ejemplo, la aplicación A se conecta a P1 e invoca
el chaincode S1 para consultar o actualizar el libro de contabilidad L1. P1 invoca a S1 para generar una
respuesta de propuesta que contiene un resultado de consulta o una actualización propuesta del libro de contabilidad.
La aplicación A recibe la respuesta de la propuesta y, para consultas,
el proceso ahora está completo. Para actualizaciones, A construye una transacción
a partir de todas las respuestas, la cual envía a O1 para su ordenamiento. O1 recopila
transacciones de toda la red en bloques, y distribuye estos a todos
los pares, incluido P1. P1 valida la transacción antes de comprometerla a L1. Una vez que L1
se actualiza, P1 genera un evento, recibido por A, para señalar la finalización.*

Un par puede devolver los resultados de una consulta a una aplicación inmediatamente, ya que
toda la información requerida para satisfacer la consulta se encuentra en la copia local del
libro de contabilidad del par. Los pares nunca consultan con otros pares para responder a una consulta de
una aplicación. Sin embargo, las aplicaciones pueden conectarse a uno o más pares para emitir
una consulta; por ejemplo, para corroborar un resultado entre varios pares, o
obtener un resultado más actualizado de un par diferente si hay sospecha
de que la información podría estar desactualizada. En el diagrama, puedes ver que la consulta del libro de contabilidad
es un simple proceso de tres pasos.

Una transacción de actualización comienza de la misma manera que una transacción de consulta, pero tiene dos
pasos adicionales. Aunque las aplicaciones que actualizan el libro de contabilidad también se conectan a los pares para
invocar un chaincode, a diferencia de las aplicaciones que consultan el libro de contabilidad, un par individual
no puede realizar una actualización del libro de contabilidad en este momento, porque otros pares primero deben
acordar el cambio --- un proceso llamado **consenso**. Por lo tanto, los pares devuelven
a la aplicación una actualización **propuesta** --- una que este par aplicaría
sujeto al acuerdo previo de otros pares. El primer paso adicional --- paso cuatro ---
requiere que las aplicaciones envíen un conjunto apropiado de actualizaciones propuestas coincidentes
a toda la red de pares como una transacción para su compromiso en sus
respectivos libros de contabilidad. Esto se logra por la aplicación utilizando un **ordenador** para
empaquetar transacciones en bloques, y distribuyéndolos a toda la red de
pares, donde pueden ser verificados antes de ser aplicados a la copia local del libro de contabilidad
de cada par. Como todo este proceso de ordenamiento tarda algún tiempo en completarse
(segundos), la aplicación es notificada de manera asincrónica, como se muestra en el paso cinco.

Más adelante en esta sección, aprenderás más sobre la naturaleza detallada de este
proceso de ordenamiento --- y para una mirada realmente detallada a este proceso, consulta el tema
[Flujo de Transacciones](../txflow.html).

## Pares y Canales

Aunque esta sección es sobre pares en lugar de canales, vale la pena dedicar un
poco de tiempo a entender cómo los pares interactúan entre sí, y con las aplicaciones,
a través de *canales* --- un mecanismo por el cual un conjunto de componentes dentro de una red
blockchain pueden comunicarse y transaccionar *privadamente*.

Estos componentes son típicamente nodos de pares, nodos ordenadores y aplicaciones y,
al unirse a un canal, acuerdan colaborar colectivamente para compartir y
gestionar copias idénticas del libro de contabilidad asociado con ese canal. Conceptualmente, puedes
pensar en los canales como similares a grupos de amigos (aunque los miembros de un
canal ciertamente no necesitan ser amigos). Una persona podría tener varios grupos
de amigos, con cada grupo realizando actividades juntos. Estos grupos
pueden ser totalmente separados (un grupo de amigos del trabajo en comparación con un grupo de
amigos por hobby), o puede haber algo de cruce entre ellos. Sin embargo, cada grupo
es su propia entidad, con "reglas" de cierto tipo.

![Peer5](./peers.diagram.5.png)

*Los canales permiten a un conjunto específico de pares y aplicaciones comunicarse entre
sí dentro de una red blockchain. En este ejemplo, la aplicación A puede
comunicarse directamente con los pares P1 y P2 usando el canal C. Puedes pensar en el
canal como una vía para comunicaciones entre aplicaciones y
pares particulares. (Para simplificar, los ordenadores no se muestran en este diagrama, pero deben
estar presentes en una red funcional).*

Vemos que los canales no existen de la misma manera que los pares --- es más
apropiado pensar en un canal como una estructura lógica que se forma por una
colección de pares físicos. *Es vital entender este punto --- los pares
proporcionan el punto de control para el acceso y la gestión de los canales*.

## Pares y Organizaciones

Ahora que entiendes los pares y su relación con los libros de contabilidad, chaincodes
y canales, podrás ver cómo múltiples organizaciones se unen para
formar una red blockchain.

Las redes blockchain son administradas por una colección de organizaciones en lugar
de una sola organización. Los pares son centrales en cómo este tipo de red distribuida
se construye porque son propiedad de --- y son los puntos de conexión a
la red para --- estas organizaciones.

![Peer8](./peers.diagram.8.png)

*Pares en una red blockchain con múltiples organizaciones. La red blockchain
se construye a partir de los pares propiedad y aportados por las diferentes
organizaciones. En este ejemplo, vemos cuatro organizaciones que contribuyen con ocho
pares para formar una red. El canal C conecta cinco de estos pares en la
red N --- P1, P3, P5, P7 y P8. Los otros pares propiedad de estas
organizaciones no se han unido a este canal, pero típicamente se unen a
al menos otro canal. Las aplicaciones que han sido desarrolladas por una
organización particular se conectarán tanto a los pares de su propia organización como a los de
diferentes organizaciones. Nuevamente,
por simplicidad, un nodo ordenador no se muestra en este diagrama.*

Es realmente importante que puedas ver lo que está sucediendo en la formación de una
red blockchain. *La red es formada y gestionada por las múltiples
organizaciones que contribuyen recursos a ella.* Los pares son los recursos de
los que estamos hablando en este tema, pero los recursos que una organización proporciona son
más que solo pares. Hay un principio en juego aquí --- la red literalmente
no existe sin que las organizaciones contribuyan sus recursos individuales al
colectivo de la red. Además, la red crece y se reduce con los
recursos que son proporcionados por estas organizaciones colaboradoras.

Puedes ver que (aparte del servicio de ordenación) no hay recursos centralizados --- en el [ejemplo anterior](#Peer8), la red, **N**, no existiría si las organizaciones no aportaran sus pares. Esto refleja el hecho de que la red no existe en ningún sentido significativo a menos que y hasta que las organizaciones contribuyan con los recursos que la forman. Además, la red no depende de ninguna organización individual --- continuará existiendo mientras quede al menos una organización, sin importar qué otras organizaciones puedan ir y venir. Esto está en el corazón de lo que significa que una red sea descentralizada.

Las aplicaciones en diferentes organizaciones, como en el [ejemplo anterior](#Peer8), pueden ser o no ser las mismas. Eso es porque depende enteramente de una organización cómo sus aplicaciones procesan las copias del libro de contabilidad de sus pares. Esto significa que tanto la lógica de aplicación como la lógica de presentación pueden variar de una organización a otra, aunque sus respectivos pares alojen exactamente los mismos datos del libro de contabilidad.

Las aplicaciones se conectan ya sea a pares en su organización o a pares en otra organización, dependiendo de la naturaleza de la interacción con el libro de contabilidad que se requiera. Para interacciones de consulta del libro de contabilidad, las aplicaciones típicamente se conectan a los pares de su propia organización. Para interacciones de actualización del libro de contabilidad, veremos más adelante por qué las aplicaciones necesitan conectarse a pares que representan a *cada* organización que se requiere para respaldar la actualización del libro de contabilidad.

## Pares e Identidad

Ahora que has visto cómo los pares de diferentes organizaciones se unen para
formar una red blockchain, vale la pena dedicar unos momentos a entender cómo
los administradores asignan pares a las organizaciones.

Los pares tienen una identidad asignada a través de un certificado digital de una
autoridad de certificación particular. Puedes leer mucho más sobre cómo funcionan los certificados digitales X.509 en otras partes de esta guía pero, por ahora, piensa en un
certificado digital como si fuera un carnet de identidad que proporciona mucha información verificable sobre un par. *Cada uno de los pares en la red es asignado un
certificado digital por un administrador de su organización propietaria*.

![Peer9](./peers.diagram.9.png)

*Cuando un par se conecta a un canal, su certificado digital identifica a su
organización propietaria a través de un MSP del canal. En este ejemplo, P1 y P2 tienen
identidades emitidas por CA1. El canal C determina a partir de una política en su configuración de canal que las identidades de CA1 deben asociarse con Org1 usando
ORG1.MSP. De manera similar, P3 y P4 son identificados por ORG2.MSP como parte de
Org2.*

Siempre que un par se conecta usando un canal a una red blockchain, *una política en
la configuración del canal utiliza la identidad del par para determinar sus
derechos.* La asignación de identidad a organización es proporcionada por un componente
llamado *Proveedor de Servicio de Membresía* (MSP, por sus siglas en inglés) --- determina cómo un par es
asignado a un rol específico en una organización particular y, en consecuencia, obtiene
acceso apropiado a los recursos de blockchain. Además, un par solo puede ser propiedad de una única organización, y por lo tanto, está asociado con un único MSP. Aprenderemos más sobre el control de acceso de pares más adelante en esta sección, y hay una sección entera sobre MSPs y políticas de control de acceso en otra parte de esta guía. Pero por ahora,
piensa en un MSP como proporcionando un enlace entre una identidad individual y un
rol organizacional particular en una red blockchain.

Para hacer una digresión por un momento, los pares, así como *todo lo que interactúa con una red blockchain, adquieren su identidad organizacional de su certificado digital y un MSP*. Pares, aplicaciones, usuarios finales, administradores y ordenadores deben tener una identidad y un MSP asociado si quieren interactuar con una red blockchain. *Le damos un nombre a cada entidad que interactúa con una red blockchain usando una identidad --- un principal*. Puedes aprender mucho más sobre principales y organizaciones en otras partes de esta guía, pero por ahora ¡sabes más que suficiente para continuar tu entendimiento sobre los pares!

Finalmente, nota que no es realmente importante dónde está ubicado físicamente el par --- podría residir en la nube, o en un centro de datos propiedad de una de las organizaciones, o en una máquina local --- es el certificado digital asociado con él lo que lo identifica como propiedad de una organización particular. En nuestro ejemplo anterior, P3 podría estar alojado en el centro de datos de Org1, pero mientras el certificado digital asociado con él sea emitido por CA2, entonces es propiedad de Org2.

## Pares y Ordenadores

Hemos visto que los pares forman la base de una red blockchain, alojando libros de contabilidad
y contratos inteligentes que pueden ser consultados y actualizados por aplicaciones conectadas a los pares.
Sin embargo, el mecanismo por el cual las aplicaciones y los pares interactúan entre sí
para asegurar que el libro de contabilidad de cada par se mantenga consistente con los demás es mediado
por nodos especiales llamados *ordenadores*, y es hacia estos nodos a los que ahora dirigimos nuestra
atención.

Una transacción de actualización es bastante diferente de una transacción de consulta porque un solo
par no puede, por sí mismo, actualizar el libro de contabilidad --- actualizar requiere el consentimiento de otros
pares en la red. Un par requiere que otros pares en la red aprueben una
actualización del libro de contabilidad antes de que pueda ser aplicada al libro de contabilidad local de un par. Este proceso se
llama *consenso*, el cual tarda mucho más en completarse que una simple consulta. Pero cuando
todos los pares requeridos para aprobar la transacción lo hacen, y la transacción es
comprometida al libro de contabilidad, los pares notificarán a sus aplicaciones conectadas que el
libro de contabilidad ha sido actualizado. Estás a punto de ver mucho más detalle sobre cómo
los pares y los ordenadores gestionan el proceso de consenso en esta sección.

Específicamente, las aplicaciones que quieren actualizar el libro de contabilidad están involucradas en un
proceso de 3 fases, el cual asegura que todos los pares en una red blockchain mantengan
sus libros de contabilidad consistentes entre sí.

* En la primera fase, las aplicaciones trabajan con un subconjunto de *pares endosantes*, cada uno de
  los cuales proporciona un endoso de la actualización propuesta del libro de contabilidad a la aplicación,
  pero no aplican la actualización propuesta a su copia del libro de contabilidad.
* En la segunda fase, estos endosos separados se recopilan juntos
  como transacciones y se empaquetan en bloques.
* En la tercera y última fase, estos bloques se distribuyen de vuelta a cada par donde
  cada transacción es validada antes de ser comprometida a la copia del libro de contabilidad de ese par.

Como verás, los nodos ordenadores son centrales en este proceso, así que vamos a
investigar un poco más en detalle cómo las aplicaciones y los pares usan a los ordenadores para
generar actualizaciones del libro de contabilidad que pueden ser aplicadas de manera consistente a un libro de contabilidad distribuido y replicado.

### Fase 1: Propuesta

La fase 1 del flujo de trabajo de la transacción implica una interacción entre una
aplicación y un conjunto de pares --- no involucra a los ordenadores. La fase 1 solo
se preocupa de que una aplicación solicite a los pares endosantes de diferentes organizaciones que
acuerden con los resultados de la invocación del chaincode propuesto.

Para iniciar la fase 1, las aplicaciones generan una propuesta de transacción que envían
a cada uno del conjunto requerido de pares para su endoso. Cada uno de estos *pares endosantes* entonces
ejecuta de manera independiente un chaincode usando la propuesta de transacción para
generar una respuesta a la propuesta de transacción. No aplica esta actualización al
libro de contabilidad, sino que simplemente lo firma y lo devuelve a la aplicación. Una vez que
la aplicación ha recibido un número suficiente de respuestas a la propuesta firmadas,
la primera fase del flujo de transacción está completa. Examinemos esta fase en
un poco más de detalle.

![Peer10](./peers.diagram.10.png)

*Las propuestas de transacción son ejecutadas de manera independiente por pares que devuelven respuestas a la propuesta endosadas. En este ejemplo, la aplicación A1 genera la propuesta de transacción T1 que envía tanto al par P1 como al par P2 en el canal C. P1 ejecuta
S1 usando la propuesta de transacción T1 generando la respuesta de transacción T1 R1 que
endosa con E1. De manera independiente, P2 ejecuta S1 usando la propuesta de transacción T1 generando la respuesta de transacción T1 R2 que endosa con E2.
La aplicación A1 recibe dos respuestas endosadas para la transacción T1, a saber, E1
y E2.*

Inicialmente, un conjunto de pares es elegido por la aplicación para generar un conjunto de
actualizaciones propuestas al libro de contabilidad. ¿Qué pares son elegidos por la aplicación? Bueno, eso
depende de la *política de endoso* (definida para un chaincode), que define
el conjunto de organizaciones que necesitan endosar un cambio propuesto al libro de contabilidad antes de que
pueda ser aceptado por la red. Esto es literalmente lo que significa alcanzar
consenso --- cada organización que importa debe haber endosado el cambio propuesto al libro de contabilidad *antes* de que sea aceptado en el libro de contabilidad de cualquier par.

Un par endosa una respuesta a la propuesta añadiendo su firma digital, y firmando
la carga completa usando su clave privada. Este endoso puede ser usado posteriormente
para probar que el par de esta organización generó una respuesta particular. En
nuestro ejemplo, si el par P1 es propiedad de la organización Org1, el endoso E1
corresponde a una prueba digital de que "¡La respuesta a la transacción T1 R1 en el libro de contabilidad L1 ha sido proporcionada por el par P1 de Org1!".

La fase 1 termina cuando la aplicación recibe respuestas a la propuesta firmadas por
suficientes pares. Notamos que diferentes pares pueden devolver diferentes y
por lo tanto respuestas inconsistentes a la transacción a la aplicación *para la misma
propuesta de transacción*. Simplemente podría ser que el resultado fue generado en
momentos diferentes en diferentes pares con libros de contabilidad en diferentes estados, en cuyo
caso una aplicación puede simplemente solicitar una respuesta a la propuesta más actualizada. Menos
probable, pero mucho más serio, los resultados podrían ser diferentes porque el chaincode
es *no determinista*. La no determinación es el enemigo de los chaincodes
y los libros de contabilidad y si ocurre indica un problema serio con la transacción propuesta, ya que resultados inconsistentes no pueden, obviamente, ser aplicados a los libros de contabilidad.
Un par individual no puede saber que su resultado de transacción es
no determinista --- las respuestas a la transacción deben ser reunidas para
comparación antes de que la no determinación pueda ser detectada. (Estrictamente hablando, incluso esto
no es suficiente, pero diferimos esta discusión a la sección de transacciones, donde
la no determinación se discute en detalle.)

Al final de la fase 1, la aplicación es libre de descartar respuestas a transacciones inconsistentes si así lo desea, terminando efectivamente el flujo de trabajo de la transacción tempranamente. Veremos más adelante que si una aplicación intenta usar
un conjunto inconsistente de respuestas a transacciones para actualizar el libro de contabilidad, será
rechazado.

### Fase 2: Ordenamiento y empaquetado de transacciones en bloques

La segunda fase del flujo de trabajo de la transacción es la fase de empaquetado. El ordenador
es fundamental en este proceso --- recibe transacciones que contienen respuestas endosadas a propuestas de transacción de muchas aplicaciones, y ordena las
transacciones en bloques. Para más detalles sobre la
fase de ordenamiento y empaquetado, consulta nuestra
[información conceptual sobre la fase de ordenamiento](../orderer/ordering_service.html#phase-two-ordering-and-packaging-transactions-into-blocks).

### Fase 3: Validación y compromiso

Al final de la fase 2, vemos que los ordenadores han sido responsables de los procesos simples
pero vitales de recolectar actualizaciones de transacciones propuestas, ordenarlas,
y empaquetarlas en bloques, listos para su distribución a los pares.

La fase final del flujo de trabajo de la transacción implica la distribución y
posterior validación de bloques desde el ordenador a los pares, donde pueden ser
comprometidos al libro de contabilidad. Específicamente, en cada par, cada transacción dentro de un
bloque es validada para asegurar que ha sido consistentemente endosada por todas
las organizaciones relevantes antes de ser comprometida al libro de contabilidad. Las transacciones fallidas
se retienen para auditoría, pero no se comprometen al libro de contabilidad.

![Peer12](./peers.diagram.12.png)

*El segundo rol de un nodo ordenador es distribuir bloques a los pares. En este
ejemplo, el ordenador O1 distribuye el bloque B2 al par P1 y al par P2. El par P1
procesa el bloque B2, resultando en un nuevo bloque siendo añadido al libro de contabilidad L1 en P1.
En paralelo, el par P2 procesa el bloque B2, resultando en un nuevo bloque siendo añadido
al libro de contabilidad L1 en P2. Una vez que este proceso está completo, el libro de contabilidad L1 ha sido
actualizado consistentemente en los pares P1 y P2, y cada uno puede informar a las aplicaciones conectadas que la transacción ha sido procesada.*

La fase 3 comienza con el ordenador distribuyendo bloques a todos los pares conectados a
él. Los pares están conectados a los ordenadores en canales de tal manera que cuando un nuevo bloque es
generado, todos los pares conectados al ordenador recibirán una copia del
nuevo bloque. Cada par procesará este bloque independientemente, pero de exactamente la misma manera que cualquier otro par en el canal. De esta manera, veremos que el
libro de contabilidad puede mantenerse consistente. También vale la pena mencionar que no cada par necesita
estar conectado a un ordenador --- los pares pueden cascada los bloques a otros pares usando
el protocolo **gossip**, quienes también pueden procesarlos independientemente. ¡Pero dejemos
esa discusión para otro momento!

Al recibir un bloque, un par procesará cada transacción en la secuencia en
la que aparece en el bloque. Para cada transacción, cada par verificará que
la transacción ha sido endosada por las organizaciones requeridas según la
*política de endoso* del chaincode que generó la transacción. Por
ejemplo, algunas transacciones pueden solo necesitar ser endosadas por una
organización, mientras que otras pueden requerir múltiples endosos antes de que sean
consideradas válidas. Este proceso de validación verifica que todas las organizaciones relevantes
han generado el mismo resultado o conclusión. También nota que esta
validación es diferente a la verificación de endoso en la fase 1, donde es la
aplicación la que recibe la respuesta de los pares endosantes y toma la
decisión de enviar las transacciones propuestas. En caso de que la aplicación viole
la política de endoso enviando transacciones incorrectas, el par todavía es capaz de
rechazar la transacción en el proceso de validación de la fase 3.

Si una transacción ha sido correctamente endosada, el par intentará aplicarla
al libro de contabilidad. Para hacer esto, un par debe realizar una verificación de consistencia del libro de contabilidad para
verificar que el estado actual del libro de contabilidad es compatible con el estado del
libro de contabilidad cuando la actualización propuesta fue generada. Esto no siempre puede ser posible,
incluso cuando la transacción ha sido completamente endosada. Por ejemplo, otra
transacción puede haber actualizado el mismo activo en el libro de contabilidad de tal manera que la
actualización de la transacción ya no es válida y por lo tanto ya no puede ser aplicada. De
esta manera, el libro de contabilidad se mantiene consistente a través de cada par en el canal porque
todos siguen las mismas reglas para la validación.

Después de que un par ha validado exitosamente cada transacción individual, actualiza
el libro de contabilidad. Las transacciones fallidas no se aplican al libro de contabilidad, pero se
retienen para fines de auditoría, al igual que las transacciones exitosas. Esto significa que
los bloques de pares son casi exactamente iguales a los bloques recibidos del ordenador,
excepto por un indicador de válido o inválido en cada transacción en el bloque.

También notamos que la fase 3 no requiere la ejecución de chaincodes --- esto se
hace solo durante la fase 1, y eso es importante. Significa que los chaincodes solo tienen
que estar disponibles en los nodos endosantes, en lugar de en toda la red blockchain.
Esto es a menudo útil ya que mantiene la lógica del chaincode
confidencial para las organizaciones endosantes. Esto contrasta con el resultado de
los chaincodes (las respuestas a la propuesta de transacción) que se comparten con cada
par en el canal, ya sea que hayan endosado la transacción o no. Esta
especialización de pares endosantes está diseñada para ayudar a la escalabilidad y confidencialidad.

Finalmente, cada vez que un bloque se compromete en el libro de contabilidad de un par, ese par
genera un *evento* apropiado. Los *eventos de bloque* incluyen el contenido completo del bloque,
mientras que los *eventos de transacción de bloque* incluyen solo información resumida, como
si cada transacción en el bloque ha sido validada o invalidada.
Los *eventos de chaincode* que la ejecución del chaincode ha producido también pueden ser
publicados en este momento. Las aplicaciones pueden registrarse para estos tipos de eventos para
que puedan ser notificadas cuando ocurran. Estas notificaciones concluyen la
tercera y última fase del flujo de trabajo de la transacción.

En resumen, la fase 3 ve los bloques que son generados por el ordenador
aplicados consistentemente al libro de contabilidad. El estricto ordenamiento de transacciones en
bloques permite que cada par valide que las actualizaciones de transacciones se apliquen de manera consistente
a través de la red blockchain.

### Ordenadores y Consenso

Todo este proceso de flujo de trabajo de la transacción se llama *consenso* porque todos los pares
han llegado a un acuerdo sobre el orden y contenido de las transacciones, en un proceso
que es mediado por los ordenadores. El consenso es un proceso de múltiples pasos y las aplicaciones
solo son notificadas de las actualizaciones del libro de contabilidad cuando el proceso está completo --- lo cual puede
ocurrir en momentos ligeramente diferentes en diferentes pares.

Discutiremos los ordenadores con mucho más detalle en un futuro tema sobre ordenadores, pero por
ahora, piensa en los ordenadores como nodos que recopilan y distribuyen propuestas de actualizaciones del libro de contabilidad
de las aplicaciones para que los pares las validen e incluyan en el libro de contabilidad.

¡Eso es todo! Ahora hemos terminado nuestro recorrido por los pares y los otros componentes a los
que se relacionan en Fabric. Hemos visto que los pares son de muchas maneras el
elemento más fundamental --- forman la red, alojan chaincodes y el
libro de contabilidad, manejan propuestas de transacciones y respuestas, y mantienen el libro de contabilidad
actualizado aplicando consistentemente actualizaciones de transacciones en él.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->
