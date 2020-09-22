Glosario
===========================

La terminología es importante para que todos los usuarios y desarrolladores de Hyperledger Fabric
estén de acuerdo con lo que queremos decir con cada término específico. ¿Qué es un contrato inteligente, por ejemplo? 
La documentación hará referencia al glosario según sea necesario, pero no dude en
leer todo de una sola vez si lo desea; ¡Es bastante esclarecedor!

.. _Peer-Ancla:

Peer Ancla
----------

Utilizado por el protocolo de chismes para asegurarse que los pares de diferentes organizaciones 
se conozcan entre sí.

Cuando se envia un bloque de configuración que contiene una actualización de los pares ancla,
los pares se comunican con los pares ancla y se enteran sobre todos los pares conocidos por los peer ancla. 
Una vez que al menos un peer de cada organización se ha puesto en contacto con un peer ancla, 
el peer ancla aprende sobre cada peer en el canal. Dado que la comunicación de chismes es constante, 
y debido a que los pares siempre piden que se les informe sobre la existencia de cualquier peer que no conocen, 
se puede establecer una visión común de membresía para un canal.

Por ejemplo, supongamos que tenemos tres organizaciones --- ``A``, ``B``, ``C`` --- en el canal
y solo un peer ancla --- ``peer0.orgC`` --- definido para la organización ``C``.
Cuando ``peer1.orgA`` (de la organización ``A``) contacta al ``peer0.orgC``, le dirá al
``peer0.orgC`` acerca ``peer0.orgA``. Y cuando más adelante ``peer1.orgB``
contacte ``peer0.orgC``, el último le contará al primero sobre ``peer0.orgA``.
A partir de ese momento, las organizaciones ``A`` y ``B`` comenzarían a intercambiar
información de los miembros directamente sin ninguna asistencia de ``peer0.orgC``.

Como la comunicación entre organizaciones depende del protocolo de chismes para funcionar, debe existir
al menos un peer ancla definido en la configuración del canal. Es muy recomendable
que cada organización proporciona su propio conjunto de pares ancla para garantizar alta
disponibilidad y redundancia.

.. _glosario_ACL:

ACL
---

Una ACL, o Lista de control de acceso, asocia el acceso a recursos de pares 
específicos (por ejemplo APIs del sistema de chaincode o servicios de eventos) a una Politica_
(que especifica cuántas y qué tipos de organizaciones o roles se requieren). 
La ACL es parte de la configuración de un canal. Por lo tanto, 
se conserva en los bloques de configuración del canal y se puede actualizar 
mediante el mecanismo de actualización de configuración estándar.

Una ACL tienen formato como una lista de pares clave-valor, donde la clave identifica 
el recurso cuyo acceso deseamos controlar, y el valor identifica la
política de canal (grupo) al que se le permite acceder. Por ejemplo
``lscc/GetDeploymentSpec: /Channel/Application/Readers``
define el acceso al ciclo de vida del chaincode ``GetDeploymentSpec`` API
(el recurso) es consumido por identidades que satisfacen la
``/Channel/Application/Readers`` politica.

Se proporciona un conjunto de ACLs por defecto en el archivo ``configtx.yaml`` que es
utilizado por configtxgen para establecer las configuraciones del canal. Los valores por defecto pueden ser establecidos
en el parte superior en la sección de "Applications" del``configtx.yaml`` o sobrescritos 
por cada perfil en la sección "Profiles".


.. _Bloque:

Bloque
------

.. figure:: ./glossary/glossary.block.png
   :scale: 50 %
   :align: right
   :figwidth: 40 %
   :alt: A Block

   Bloque B1 está unido al bloque B0. Bloque B2 está unido al bloque B1.

=======

Un bloque contiene un conjunto ordenado de transacciones. Está unido criptográficamente 
al bloque precedente, y a su vez está unido a los bloques posteriores. El 
primer bloque de esa blockchain se denomina **bloque génesis**. Los bloques
son creados por el servicio de ordenamiento y luego validados y confirmados por los pares.


.. _Cadena:


Cadena
------

.. figure:: ./glossary/glossary.blockchain.png
   :scale: 75 %
   :align: right
   :figwidth: 40 %
   :alt: Blockchain

   La blockchain B contiene los bloques 0, 1, 2.

=======

La cadena del libro mayor es un registro de transacciones estructurado como bloques de transacciones 
vinculados mediante hash. Los pares reciben bloques de transacciones del servicio de ordenamiento, marcan las 
transacciones del bloque como válidas o inválidas basándose en las políticas de aprobación y las violaciones 
de la concurrencia, y añaden el bloque a la cadena de hash en el sistema de archivos del pares.



.. _chaincode:

Chaincode
---------

vea Smart-Contract_.

.. _Canal:

Canal
-------

.. figure:: ./glossary/glossary.channel.png
   :scale: 30 %
   :align: right
   :figwidth: 40 %
   :alt: A Channel

   Canal C conecta las aplicaciones A1, peer P2 y el servicio de ordenamiento O1.

=======

Un canal es una capa de la blockchain privada que permite el aislamiento y la confidencialidad 
de los datos. Un libro mayor específico del canal que se comparte entre los pares del canal, y las pares que realizan 
la transacción deben estar autenticados en un canal para poder interactuar con él.  Los canales están definidos por un
Bloque-configuracion_.


.. _Commit:

Commit
------

Cada Peer_ en un canal valida bloques ordenados de transacciones y luego confirma (escribe / agrega) los bloques a su réplica del Libro-mayor-ledger_ del canal. Los pares también marcan cada transacción en cada bloque como válida o no válida.

.. _Verificación de control de concurrencia:

Verificación de control de concurrencia
---------------------------------------

La verificación de control de concurrencia es un método para mantener sincronizado el estado del libro mayor entre los pares de un canal. Los pares ejecutan transacciones en paralelo y, antes de adicionarse en el libro mayor, los pares comprueban si se ha modificado el estado leído en el momento en que se ejecutó la transacción. Si los datos leídos para la transacción han cambiado entre el tiempo de ejecución y el tiempo de adicion, entonces se ha producido una violación de Verificación Control de Concurrencia y la transacción se marca como no válida en el libro mayor y los valores no se actualizan en la base de datos de estado.

.. _Bloque-configuracion:

Bloque de configuración
-----------------------

Contiene los datos de configuración que definen miembros y políticas para una cadena de sistema (servicio de ordenamiento) o canal. Cualquier modificación de configuración a un canal o red general (por ejemplo, un miembro que se va o se une) dará como resultado un nuevo bloque de configuración que se agregará a la cadena correspondiente. Este bloque contendrá el contenido del bloque de génesis, más el delta.

.. _Consenso:

Consenso
--------

Término más amplio que abarca todo el flujo transaccional, que sirve para generar un acuerdo sobre el pedido y para confirmar la corrección del conjunto de transacciones que constituyen un bloque.

.. _conjunto-de-consentimiento:

Conjunto de Consentimiento
--------------------------

En un servicio de ordenamiento de Raft, estos son los nodos de pedidos que participan activamente en el mecanismo de consenso en un canal. Si existen otros nodos de ordenación en el canal del sistema, pero no forman parte de un canal, no forman parte del conjunto de consentimiento de ese canal.

.. _Consorcio:

Consorcio
---------

Un consorcio es una colección de organizaciones sin capacidad de "orderer" en la red blockchain. Estas son las organizaciones que forman y se unen a canales y que poseen pares. Si bien una red blockchain puede tener varios consorcios, la mayoría de las redes blockchain tienen un solo consorcio. En el momento de la creación del canal, todas las organizaciones agregadas al canal deben formar parte de un consorcio. Sin embargo, una organización que no esté definida en un consorcio puede agregarse a un canal existente.

.. _Definicion-de-chaincode:

Definicion de Chaincode
-----------------------

Las organizaciones utilizan una definición de chaincode para acordar los parámetros de un chaincode antes de que pueda usarse en un canal. Cada miembro del canal que desee utilizar el chaincode para respaldar transacciones o consultar el libro mayor debe aprobar una definición de chaincode para su organización. Una vez que suficientes miembros del canal han aprobado una definición de chaincode para cumplir con la política de respaldo del ciclo de vida (que se establece en la mayoría de las organizaciones en el canal de forma predeterminada), la definición de chaincode se puede asignar al canal. Una vez confirmada la definición, la primera invocación del chaincode (o, si se solicita, la ejecución de la función Init) iniciará el chaincode en el canal.

.. _Membresia-dinamica:

Membresía dinámica
------------------

Hyperledger Fabric admite la adición/eliminación de miembros, pares y nodos de servicio de orderes, sin comprometer la operatividad de la red en general. La membresía dinámica es fundamental cuando las relaciones comerciales se ajustan y las entidades deben agregarse/eliminarse por diversas razones.

.. Patrocinio:

Patrocinio
----------

Se refiere al proceso en el que ciertos nodos pares específicos ejecutan una transacción de chaincode y devuelven una respuesta de propuesta a la aplicación cliente. La respuesta a la propuesta incluye el mensaje de respuesta de ejecución del chaincode, los resultados (conjunto de lectura y conjunto de escritura) y eventos, así como una firma que sirve como prueba de la ejecución del chaincode del peer. Las aplicaciones de chaincode tienen las políticas de aprobación correspondientes, en las que se especifican los peers que respaldan.

.. _Politica-endorsamiento:

Politica Endorsamiento
----------------------

Define los nodos pares de un canal que deben ejecutar las transacciones vinculadas a una ejecución específica de un chaincode y la combinación requerida de respuestas (endosos).
Una política podría exigir que una transacción sea endosada por un número mínimo de pares endosantes, un porcentaje mínimo de pares endosantes o por todos los peers endosantes
asignados a una específica de chaincode. Las políticas se pueden elaborar en función de la aplicación y del nivel deseado de resistencia contra el mal comportamiento 
(deliberado o no) de los pares endosantes. Una transacción que se envía debe satisfacer la política de aprobación antes de ser marcada como válida por los peers que la aprueban.

.. Seguidor:

Seguidor
--------

En un protocolo de consenso basado en liderazgo, como Raft, estos son los nodos que replican las entradas de registro producidas por el líder. En Raft, los seguidores también reciben mensajes de "latidos" del líder. En el caso de que el líder deje de enviar esos mensajes por un período de tiempo configurable, los seguidores iniciarán una elección de líder y uno de ellos será elegido líder.

.. _Bloque-genesis:

Bloque Génesis
--------------

El bloque de configuración que inicializa el servicio de orders o sirve como el primer bloque de una cadena.

.. _Protocolo-de-chismes:

Protocolo de chismes
--------------------

El protocolo de chismes de difusión de datos realiza tres funciones:
1) gestiona el descubrimiento de pares y la pertenencia al canal;
2) difunde los datos del libro mayor a todos los pares del canal;
3) sincroniza el estado del libro mayor en todos los pares del canal.
Consulte el tema :doc:`Gossip <gossip>` para obtener más detalles.

.. _Fabric-ca:

Hyperledger Fabric CA
---------------------

Hyperledger Fabric CA es la autoridad de certificación predeterminada, que emite certificados basados en PKI a las organizaciones miembros de la red y sus usuarios.
La CA emite un certificado raíz (rootCert) a cada miembro y un certificado de inscripción (ECert) a cada usuario autorizado.

.. _Init:

Init
----

Un método para inicializar un chaincode. Todos los chaincode deben tener una función de inicialización. Por defecto, esta función nunca se ejecuta. Sin embargo, puede utilizar la definición de chaincode para solicitar la ejecución de la función Init para inicializar el chaincode.

Install
-------

El proceso de colocar un chaincode en el sistema de archivos de un par.

Instanciar
----------

El proceso de iniciar e inicializar una aplicación de chaincode en un canal específico. Después de la creación de instancias, los pares que tienen el chaincode instalado pueden aceptar invocaciones de chaincode.

**NOTA**: *Este método, es decir, crear instancias se utilizó en la 1.4.x y versiones anteriores del ciclo de vida del chaincode. Para conocer el procedimiento actual utilizado para iniciar un chaincode en un canal con el nuevo ciclo de vida del chaincode de Fabric introducido como parte de Fabric v2.0, consulte Definición de chaincode.*

.. _Invocar:

Invocar
-------

Se utiliza para llamar a funciones de chaincode. Una aplicación cliente invoca un chaincode enviando una propuesta de transacción a un par. El par ejecutará el chaincode y devolverá una respuesta de propuesta respaldada a la aplicación cliente. La aplicación del cliente recopilará suficientes respuestas a la propuesta para satisfacer una política de aprobación y luego enviará los resultados de la transacción para su pedido, validación y confirmación.
La aplicación cliente puede optar por no enviar los resultados de la transacción. Por ejemplo, si la invocación solo consulta el libro mayor, la aplicación cliente normalmente no enviará la transacción de solo lectura, a menos que se desee registrar la lectura en el libro mayor con fines de auditoría. La invocación incluye un identificador de canal, la función de chaincode para
invocar y una matriz de argumentos.


.. _Lider:

Lider
-----

En un protocolo de consenso basado en liderazgo, como Raft, el líder es responsable de ingerir nuevas entradas de registro, replicarlas en los nodos de pedido de seguidores y administrar cuando una entrada se considera comprometida. Este no es un ** tipo ** especial de pedido. Es solo un rol que un ordenante puede tener en ciertos momentos, y luego no en otros, según lo determinen las circunstancias.

.. _Leading-Peer:

Leading Peer
------------

Cada Organizacion_ puede poseer varios pares en cada canal que
a los que se suscriben. Uno o más de estos pares deben servir como pares principales (leading peer) para el canal, a fin de comunicarse con el servicio de ordenamiento de la red en nombre de la organización. El servicio de ordenamiento entrega bloques a los pares líderes en un canal, quienes luego los distribuyen a otros pares dentro de la misma organización.

.. _Libro-mayor-ledger:

Libro mayor - Ledger
--------------------

.. figure:: ./glossary/glossary.ledger.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Ledger

   Un libro mayor, 'L'

Un libro mayor consta de dos partes distintas, aunque relacionadas: una "blockchain" y la "base de datos de estado", también conocida como "estado mundial". A diferencia de otros libros mayores, las blockchains son **inmutables**, es decir, una vez que se ha agregado un bloque a la cadena, no se puede cambiar. Por el contrario, el "estado mundial" es una base de datos que contiene el valor actual del conjunto de pares clave-valor que se han agregado, modificado o eliminado por el conjunto de transacciones validadas y comprometidas en la blockchain.

Es útil pensar que hay un libro mayor **lógico** para cada canal de la red. En realidad, cada par en un canal mantiene su propia copia del libro mayor, que se mantiene consistente con la copia de todos los demás pares a través de un proceso llamado **consenso**. El término **Tecnología de libro mayor distribuido** (**DLT**) a menudo se asocia con este tipo de libro mayor, uno que es lógicamente singular, pero tiene muchas copias idénticas distribuidas en un conjunto de nodos de red (pares y el servicio de ordenamiento).


.. _Log-entry:

Entrada de registro
-------------------

La unidad principal de trabajo en un servicio de ordenamiento de Raft, las entradas de registro se distribuyen desde el líder que ordena a los seguidores. La secuencia completa de dichas entradas conocida como "registro". Se considera que el registro es coherente si todos los miembros están de acuerdo con las entradas y su orden.

.. _Miembro:

Miembro
-------

Vea Organizacion_.

.. _MSP:

Proveedor de servicios de membresia
-----------------------------------

.. figure:: ./glossary/glossary.msp.png
   :scale: 35 %
   :align: right
   :figwidth: 25 %
   :alt: An MSP

   un MSP, 'ORG.MSP'


El proveedor de servicios de membresía (Membership Service Provider - MSP) se refiere a un componente abstracto del sistema que proporciona credenciales a los clientes y compañeros para que participen en una red Hyperledger Fabric. Los clientes usan estas credenciales para autenticar sus transacciones, y los pares usan estas credenciales para autenticar los resultados del procesamiento de transacciones (endosos). Si bien está fuertemente conectada a los componentes de procesamiento de transacciones de los sistemas, esta interfaz tiene como objetivo tener componentes de servicios de membresía definidos, de tal manera que las implementaciones alternativas de esto se pueden conectar sin problemas sin modificar el núcleo de los componentes de procesamiento de transacciones del sistema.

.. _servicio-de-membresia:

Servicios de membresía
----------------------

Los Servicios de membresía autentican, autorizan y administran las identidades en una red blockchain autorizada. El código de servicios de membresía que se ejecuta en pares y ordenadores autentica y autoriza las operaciones de blockchain. Es una implementación basada en PKI de la abstracción del Proveedor de servicios de membresía (MSP).

.. _Servicio-ordenamiento:

Servicio de Ordenamiento
------------------------

También conocido como **ordenador**. Una coleccion de nodos que ordena las transacciones en un bloque y luego distribuye los bloques a los pares conectados para su validación y confirmación. El servicio de ordenamiento existe independientemente de los procesos de pares y las transacciones de pedidos se basan en el orden de llegada para todos los canales de la red. Está diseñado para admitir implementaciones conectables más allá de las variedades Kafka y Raft listas para usar. Es un enlace común para toda la red; contiene el material de identidad criptográfico vinculado a cada Miembro_.

.. _Organizacion:

Organizacion
------------

=====


.. figure:: ./glossary/glossary.organization.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: An Organization

   Una organizacion, 'ORG'


También conocidas como "miembros", las organizaciones están invitadas a unirse a la red blockchain por un proveedor de red blockchain. Una organización se une a una red agregando su Proveedor de servicios de membresía (MSP_) a la red. El MSP define cómo otros miembros de la
La red puede verificar que las firmas (como las de las transacciones) fueron generadas por una identidad válida, emitida por esa organización. Los derechos de acceso particulares de las identidades dentro de un MSP se rigen por políticas que también se acuerdan cuando la organización se une a la red. Una organización puede ser tan grande como una corporación multinacional o tan pequeña como un individuo. El punto final de la transacción de una organización es un Peer_. Una colección de organizaciones forma un Consorcio_. Si bien todas las organizaciones de una red son miembros, no todas las organizaciones formarán parte de un consorcio.

.. _Peer:

Peer
----

.. figure:: ./glossary/glossary.peer.png
   :scale: 25 %
   :align: right
   :figwidth: 20 %
   :alt: A Peer

   un peer, 'P'

Una entidad de red que mantiene un libro mayor y ejecuta contenedores de código de cadena para realizar operaciones de lectura/escritura en el libro mayor. Los miembros pertenecen y son mantenidos por los compañeros.

.. _Politica:

Política
--------

Las políticas son expresiones compuestas por propiedades de identidades digitales, por ejemplo: ``OR ('Org1.peer', 'Org2.peer')``. Se utilizan para restringir el acceso a los recursos en una red blockchain. Por ejemplo, dictan quién puede leer o escribir en un canal, o quién puede usar una API de código de cadena específica a través de una ACL_. Las políticas se pueden definir en ``configtx.yaml`` antes de iniciar un servicio de ordenamiento o crear un canal, o se pueden especificar al crear una instancia del código de cadena en un canal. Un conjunto predeterminado de políticas se envía en el ejemplo ``configtx.yaml`` que será apropiado para la mayoría de las redes.

.. _glosario-Datos-privados:

Datos Privados
--------------

Datos confidenciales que se almacenan en una base de datos privada en cada par autorizado, lógicamente separados de los datos del 
libro mayor del canal. El acceso a estos datos está restringido a una o más organizaciones de un canal mediante una definición 
de recopilación de datos privados. Las organizaciones no autorizadas tendrán un hash de los datos privados en el libro mayor del canal 
como prueba de los datos de la transacción. También, o más privacidad, los hash de los datos privados pasan por Servicio-ordenamiento_, 
no los datos privados en sí, por lo que esto mantiene los datos privados confidenciales del Ordenador.

.. _glosario-coleccion-datos-privados:

Recopilación de datos privados (Recopilación)
---------------------------------------------

Se utiliza para gestionar los datos confidenciales que dos o más organizaciones de un canal quieren mantener en privado de otras 
organizaciones de ese canal. La definición de recopilación describe un subconjunto de organizaciones en un canal con derecho 
a almacenar un conjunto de datos privados, lo que por extensión implica que sólo estas organizaciones pueden realizar transacciones con los datos privados.

.. _Propuesta:

Propuesta
---------

Una solicitud de endoso que está dirigida a pares específicos en un canal. 
Cada propuesta es una solicitud de Init o de Invocación (lectura/escritura).


.. _Consulta:

Consulta
--------

Una consulta es una invocación de un chaincode que lee el estado actual del libro mayor pero no escribe en el libro mayor. 
La función de chaincode puede consultar ciertas llaves del libro mayor, o puede consultar un conjunto de llaves del libro mayor. 
Dado que las consultas no cambian el estado del libro mayor, la aplicación cliente no suele enviar estas transacciones de sólo lectura
para su ordenamiento, validación y confirmación. Aunque no es típico, la aplicación cliente puede elegir enviar la transacción de sólo lectura para 
ordenar, validar y confirmar, por ejemplo si el cliente quiere una prueba auditable en la cadena del libro mayor de que tenía conocimiento de un estado específico 
del libro mayor en un momento determinado.

.. _Quorum:

Quorum
------

En él se describe el número mínimo de miembros del grupo que deben presentar una propuesta para que se puedan ordenar 
las transacciones. Por cada conjunto de consentimiento, esto es una **mayoría** de nodos. 
En un grupo con cinco nodos, tres deben estar disponibles para que haya quórum. Si un quórum de nodos no está disponible por cualquier razón, 
el cluster no está disponible para operaciones de lectura y escritura y no se pueden efectuar nuevos registros.

.. _Raft:

Raft
----

Nuevo para v1.4.1, Raft es un servicio de ordenamiento tolerante a fallas de choque (CFT)
implementación basada en la `biblioteca etcd <https://coreos.com/etcd/>`_ del `protocolo Raft <https://raft.github.io/raft.pdf>`_. Raft sigue un modelo de "líder y seguidor", donde se elige un nodo líder (por canal) y sus decisiones son replicadas por los seguidores. Los servicios de ordenamiento de balsa deberían ser más fáciles de configurar y administrar que los servicios de ordenamiento basados en Kafka, y su diseño permite a las organizaciones contribuir con nodos a un servicio de ordenamiento distribuido.

.. _SDK:

Kit de desarrollo de software (SDK)
-----------------------------------

El SDK del cliente Hyperledger Fabric proporciona un entorno estructurado de bibliotecas para que los desarrolladores escriban y prueben aplicaciones de chaincode. El SDK es completamente configurable y extensible a través de una interfaz estándar. Los componentes, incluidos los algoritmos criptográficos para firmas, los marcos de registro y las tiendas estatales, se pueden intercambiar fácilmente dentro y fuera del SDK. El SDK proporciona API para procesamiento de transacciones, servicios de membresía, cruce de nodos y manejo de eventos.

Actualmente, los dos SDK admitidos oficialmente son para Node.js y Java, mientras que dos más, Python y Go, aún no son oficiales, pero aún se pueden descargar y probar.

.. _Smart-Contract:

Contrato inteligente (Smart Contract)
-------------------------------------

Un contrato inteligente es un código, invocado por una aplicación cliente externa a la red blockchain, que administra el acceso y las modificaciones a un conjunto de pares clave-valor en :ref:`Estado-mundial` a través de :ref:`Transaccion`. En Hyperledger Fabric, los contratos inteligentes se empaquetan como código de cadena (chaincode). Chaincode se instala en pares y luego se define y se usa en uno o más canales.

.. _State-DB:

Base de Datos de estado - State Database
----------------------------------------

Los datos de estado mundial se almacenan en una base de datos de estado para lecturas y consultas eficientes desde el chaincode. Las bases de datos compatibles incluyen levelDB y couchDB.

.. _Cadena-sistema:

Cadena del sistema
------------------

Contiene un bloque de configuración que define la red a nivel de sistema. La cadena del sistema vive dentro del servicio de ordenamiento, y de forma similar a un canal, tiene una configuración inicial que contiene información como: Información de MSP, políticas y detalles de configuración. Cualquier cambio en la red global (por ejemplo, la incorporación de una nueva organización o la adición de un nuevo nodo de pedido) dará lugar a la adición de un nuevo bloque de configuración a la cadena del sistema.

La cadena del sistema puede considerarse como la unión común de un canal o grupo de canales. Por ejemplo, un conjunto de instituciones financieras puede formar un consorcio (representado a través de la cadena del sistema), y luego proceder a crear canales relativos a sus programas comerciales alineados y variables

.. _Transaccion:

Transacción
-----------

.. figure:: ./glossary/glossary.transaction.png
   :scale: 30 %
   :align: right
   :figwidth: 20 %
   :alt: A Transaction

   Una transacción, 'T'

Las transacciones se crean cuando se invoca un chaincode desde una aplicación cliente
para leer o escribir datos del libro mayor. Los clientes de aplicaciones de Fabir presentan propuestas de transacciones a sus pares para su ejecución y aprobación,
recogen las respuestas firmadas (aprobadas) de esos pares que las aprueban y luego empaquetan los resultados y las aprobaciones en una transacción que se presenta 
al servicio de ordenamiento. El servicio de ordenamiento ordena y coloca las transacciones en un bloque que se transmite a los pares que validan y comprometen las transacciones 
en el libro mayor y actualizar el estado mundial.

.. _Estado-mundial:

Estado Mundial
--------------

.. figure:: ./glossary/glossary.worldstate.png
   :scale: 40 %
   :align: right
   :figwidth: 25 %
   :alt: Current State

   El Estado Mundial, 'W'


También conocido como el "estado actual", el estado mundial es un componente del Libro-mayor-ledger_ 
HyperLedger Fabric. El estado del mundo representa los últimos valores
para todas las llaves incluidas en el registro de transacciones de la cadena. El Chaincode ejecuta las propuestas de transacción 
contra los datos del estado mundial porque el estado mundial proporciona acceso directo al último valor de estas claves en lugar 
de tener que calcular a traves de todo el registro de transacciones. El estado mundial cambiará cada vez que cambie el valor de 
una llave (por ejemplo, cuando la propiedad de un coche -- la "llave" -- se transfiera de un propietario a otro -- el "valor") 
o cuando se añada una nueva llave (se cree un coche). Como resultado, el estado del mundo es crítico para el flujo de una transacción, 
ya que el estado actual de un par llave-valor debe ser conocido antes de que pueda ser cambiado. Los pares confirman los últimos valores 
al estado mundial del libro mayor para cada transacción válida incluida en un bloque procesado.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
