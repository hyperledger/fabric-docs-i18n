¿Qué es lo Nuevo en Hyperledger Fabric v2.x?
=====================================

Lo nuevo en Hyperledger Fabric v2.5
-------------------------------------

Purgar la historia de data privada
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Aún cuando siempre ha sido posible borrar data privada del estado actual, esta nueva capacidad permite purgar la historia de data privada de un peer conservando un hash de la data privada como evidencia inmutable en blockchain.

* Útil para purgar data privada a demanda por motivos de privacidad o para alinearse con regulaciones gubernamentales.
* Eliminar data privada del estado y de la historia de data privada de los peers para que no pueda ser consultado desde eventos de bloques o de otros peers.
* Disponible como una nueva API de chaincode `PurgePrivateData()`.
* Requiere que se defina la capacidad aplicativa a `V2_5` en la configuración del canal

Para mayores detalles, ver el tópico :doc:`private-data/private-data`.

Disponibilidad de binarios e imágenes Docker de multi-arquitectura
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Los binarios del release y las imágenes Docker han sido actualizadas como se describe a continuación:

* Soporte para amd64 y arm64.
* Los binarios del release están enlazados estáticamente para tener máxima portabilidad.
* Las imágenes Docker utilizan binarios enlazados dinámicamente y están basados ahora en Ubuntu (ante que Alpine) para que sean mas consistentes con los típicos ambientes de ejecución productivos (los ambientes de ejecución productivos están típicamente basados en glibc y a menudo requieren el enlazamiento dinámico de módulos de HSM).

.. note::

   Fabric v2.5.x es el release actual para soporte a largo plazo (LTS). Una simple actualización in-situ desde el release LTS anterior (Fabric v2.2.x) es posible.


Lo Nuevo en Hyperledger Fabric v2.4
-------------------------------------

Fabric Gateway
^^^^^^^^^^^^^^

El Fabric Gateway es un nuevo servicio que ejecuta en los nodos peer que administra el envío de transacciones y su procesamiento para las aplicaciones cliente, con los siguientes beneficios:

* Simplificación de aplicaciones clientes y SDKs - Tus aplicaciones cliente simplemente pueden delegar el envío de transacciones a un peer confiable. No hay necesidad para que tu aplicación habrá conexiones con nodos peers y del servicio de ordenamiento de otras organizaciones.
* Fabric Gateway administra el conjunto de endosos transaccionales de otras organizaciones y el envío de parte de las aplicaciones cliente.
* Fabric Gateway tiene la inteligencia para determinar que endosos son requeridos para una transacción dada, aún si tu solución utiliza una combinación de políticas de endoso a nivel del chaincode, políticas de endoso de conjuntos de data privada, y políticas de endoso basada en el estado. 
 
Se encuentran disponibles nuevos SDKs livianos de Gateway (v1.0.0) para Node, Java, y Go. Los SDK soportan patrones aplicativos flexibles:

* You can utilize the high-level programming model similar to prior SDK versions, allowing your application to simply call a single SubmitTransaction() function.
* More advanced applications can leverage the gateway's individual Endorse, Submit, and CommitStatus services for transaction submission, and the Evaluate service for queries.
* You can delegate transaction endorsement entirely to the gateway, or if needed, specify the endorsing organizations and the gateway will utilize a peer from each organization.

Para mas información, ver el tópico :doc:`gateway`.

Desvincular un peer node
^^^^^^^^^^^^^^^^^^^^^^^^

Ahora puedes desvincular un peer de un canal cuando el canal ya no es requerido. Todos los recursos del canal serán eliminados del peer y el mismo no procesara mas bloques de ese canal.

Para mas detalles, ver `peer node unjoin` :doc:`command reference topic<commands/peernode>`.

Calcular el ID del paquete de un chaincode empaquetado
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Se puede calcular el ID del paquete de un chaincode empaquetado sin tener que instalarlo en los peers utilizando el nuevo comando `peer lifecycle chaincode calculatepackageid`.
Este comando sera util, por ejemplo, en los siguientes escenarios:

* Cuando múltiples paquetes de chaincode están instalados utilizando el mismo nombre de etiqueta, es posible luego identificar qué ID corresponde a qué paquete.
* Para verificar si un paquete de chaincode puntual se encuentra instalado o no sin tener que instalarlo.

Para mas información, ver `peer lifecycle chaincode calculatepackageid` :doc:`command reference topic<commands/peerlifecycle>`.


Lo Nuevo en Hyperledger Fabric v2.3
-----------------------------------

Hyperledger Fabric v2.3 introduce dos nuevas capacidades para mejorar las operaciones del peer y el ordenador.

Administración de los canales en el Ordenador sin un canal de sistema
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Para simplificar el proceso de creación de canales y mejorar la privacidad y escalabilidad de los canales,
es posible ahora crear estos canales aplicativos sin tener que primeramente crear un "canal de sistema" administrado por el servicio de ordenamiento.
Este proceso permite que los nodos de ordenamiento puedan unirse (o dejar) cualquier número de canales como se requiera, de manera similar a como los peers pueden participar en múltiples canales.

Beneficios de este nuevo proceso:

* **Mayor privacidad:** Como todos los nodos de ordenamiento estaban conectados al canal de sistema,
  todo nodo de ordenamiento en una red conocía la existencia de todo canal que hubiese en el servicio de ordenamiento.
  Ahora, un nodo de ordenamiento solo conoce los canales a los cuales esta unido.
* **Escalabilidad:** Cuando hay un gran número de nodos de ordenamiento y canales definidos en el canal de sistema,
  puede acarrearle mucho tiempo a los nodos de ordenamiento lograr un consenso sobre la membresía de todos los canales.
  Ahora, un servicio de ordenamiento puede escalar horizontalmente de manera descentralizada uniendo independientemente nodos de ordenamiento a canales específicos.
* **Beneficios operacionales**
   * Proceso simple para unir un nodo de ordenamiento a un canal.
   * Habilidad para listar los canales en los que el nodo de ordenamiento es un consentidor.
   * Proceso simple para sacar un canal de un nodo de ordenamiento, que automáticamente limpia los bloques asociados con ese canal.
   * Los organizaciones de los peers no necesitan coordinar con el administrador del canal de sistema para crear o actualizar su MSP (proveedor de servicios de membresía).

Para mas información, ver el tópico :doc:`create_channel/create_channel_participation`.

Foto Instantánea del Ledger
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ahora es posible tomar una foto instantánea de la información de un canal de un peer, incluyendo la base de datos de estados,
y unir a nuevos peers (en la misma o diferentes organizaciones) al canal basado en la instantánea.

Utilizar estas fotos instantáneas del ledger tiene las siguientes ventajas:

* **Los peers no tienen que procesar todos los bloques desde  el bloque génesis:** Los peers pueden unirse a un canal sin procesar todos
  los bloques previos desde el de génesis, reduciendo enormemente el tiempo que le conlleva a un peer unirse a un canal existente.
* **Los peers pueden unirse a canales utilizando la última configuración del canal:** Como las instantáneas incluyen la última configuración del canal,
  los peers ahora pueden unirse a un canal utilizando la última configuración realizada del canal.
  Esto es especialmente importante si configuración crítica del canal como los puntos de acceso al ordenamiento ó si los certificados TLS de la autoridad certificante (CA) han sido actualizados desde la creación del bloque de génesis.
* **Reducción de costos de almacenamiento:** Los peers que se unen por una instantánea no incurren en el costo de almacenamiento de mantener todos los bloques desde el de génesis.
* **Control de status:** Los administradores de los peers pueden tomar instantáneas del status del canal actual y compararlo con la de otros peers,
  en la misma o diferente organización, para verificar la consistencia e integridad del ledger en cada peer.
  Las instantáneas en las que estén todos de acuerdo pueden ser usadas como puntos de control y la base para nuevos peers que se estén uniendo.

Para mas información, ver el tópico :doc:`peer_ledger_snapshot`.

.. note::

   Aún cuando Fabric v2.3.0 introduce nuevas características, Fabric v2.2.x continúa siendo el release vigente con soporte a largo plazo hasta que el siguiente release LTS sea anunciado.

Lo nuevo en Hyperledger Fabric v2.0, v2.1, v2.2
-------------------------------------------------

El primer release mayor de Hyperledger Fabric desde v1.0, Fabric v2.0
entrega importantes nuevas capacidades y cambios tanto para usuarios como para operadores
incluyendo soporte para nuevos patrones de tanto de privacidad como de aplicativos, gobernabilidad
mejorada de los contratos inteligentes, y nuevas opciones para los nodos operacionales.

Cada release menor de v2.x construye sobre el release v2.0 con capacidades menores, mejoras y arreglos de errores.

v2.2 es el primer release con soporte a largo plazo (LTS) de Fabric v2.x.
Los arreglos serán provistos en el flujo del release de v2.2.x hasta después que el siguiente release de LTS sea anunciado.

Revisemos algunos de los puntos más destacados del release de Fabric v2.0 ...

Gobernabilidad descentralizada para contratos inteligentes 
---------------------------------------------------------

Fabric v2.0 introduce la gobernabilidad descentralizada para contratos inteligentes, con un nuevo
proceso de instalación del chaincode en tus peers y hacerlo iniciar en un canal.
El nuevo ciclo de vida de los chaincode en Fabric permite que múltiples organizaciones lleguen a un
acuerdo sobre los parámetros del chaincode, tales como la política de endoso del 
chaincode, antes de que pueda ser utilizado para interactuar con el ledger. El nuevo modelo
ofrece varias mejoras respecto del ciclo de vida previo:

* **Múltiples organizaciones deben acordar los parámetros de un chaincode**
  En las versiones del release 1.x de Fabric, una sola organización tenía la habilidad de
  definir los parámetros de un chaincode (por ejemplo la política de endoso) para todos
  los demás miembros del canal, quienes solo tenían el poder de negarse a instalar el chaincode
  y, consecuentemente, no tomar parte en las transacciones que la invocasen. El nuevo ciclo de 
  de vida de chaincode en Fabric es mas flexible ya que soporta tanto modelos de confianza 
  centralizados (tales como los del modelo del ciclo de vida previo) asi como
  modelos descentralizados que requieren un número suficiente de organizaciones para
  acordar una política de endoso y otros detalles antes de que el chaincode
  esté activo en un canal.

* **Un proceso de actualización del chaincode mas intencionado** En el ciclo de vida previo
  del chaincode, la transacción de actualización del código podía ser emitida por una sola organización,
  generando un riesgo para un miembro del canal que aún no hubiese instalado el nuevo
  chaincode. El nuevo modelo permite que el chaincode sea actualizado sólo después
  de que un número suficiente de organizaciones hayan aprobado la actualización.

* **Políticas de endoso mas simples y actualizaciones a las colecciones de data privada**
  El ciclo de vida de Fabric lifecycle permite que cambies una política de endoso o la configuración
  de una colección de data privada sin tener que empaquetar o instalar nuevamente
  el chaincode. Los usuarios pueden también tomar provecho de la nueva política de endoso por
  defecto que exige en endoso de una mayoría de organizaciones en el 
  canal. Esta política es actualizada automáticamente cuando organizaciones son
  agregadas o sacadas del canal.

* **Paquetes de chaincode inspeccionables** El ciclo de vida de Fabric empaqueta chaincode
  en archivos tar fácilmente legibles. Esto hace más fácil inspeccionar el paquete del
  chaincode y coordinar la instalación en múltiples organizaciones.

* **Iniciar múltiples chaincodes en un canal utilizando un solo paquete** El ciclo de vida
  anterior definía cada chaincode en el canal utilizando un nombre y versión
  que se especificaba cuando el paquete del chaincode era instalado. Ahora tú puedes
  usar un único paquete de chaincode e implementarlo múltiples veces con diferentes
  nombres en el mismo canal o en diferentes canales. Por ejemplo, si quisieras rastrear
  diferentes activos en su propia ‘copia’ del chaincode.

* **Los paquetes de chaincode no tiene que ser idénticos en todos los miembros del canal**
  Las organizaciones pueden extender un chaincode para su propio caso de uso, por ejemplo
  para realizar diferentes validaciones que son del interés de su organización.
  Mientras coincidan los resultados del número requerido de organizaciones que endosa 
  transacciones del chaincode, la transacción será validada y escrita al
  ledger.  Esto también les permite a las organizaciones individualmente desplegar arreglos menores
  a su conveniencia sin requerir que toda la red lo haga en estrecha sincronía.

Utilizar el nuevo ciclo de vida de chaincode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Para implementaciones existentes de Fabric, puedes continuar utilizar el anterior ciclo de vida
de chaincodes con Fabric v2.x. El nuevo ciclo de vida de chaincodes entrará en vigencia
solo cuando la capacidad aplicativa del canal sea actualizada a v2.0.
Ver el tópico de concepto :doc:`chaincode_lifecycle` para un resumen del nuevo ciclo de 
vida de chaincode.

Nuevos patrones aplicativos de chaincode para colaboración y consenso
---------------------------------------------------------------------

Los mismos métodos descentralizados de lograr un acuerdo que apuntala la
administración del ciclo de vida de los chaincode puede también ser usado en tus propias
aplicaciones de chaincode para asegurarte el consentimiento de las organizaciones de las 
transacciones de data ants que sean escritas al ledger.

* **Verificaciones automáticas** Como se menciona arriba las organizaciones pueden agregar
  verificaciones automáticas a las funciones de chaincode para validar información adicional
  de endosar una propuesta transaccional.

* **Acuerdos descentralizados** Las decisiones humanas pueden ser modeladas en un proceso de chaincode
  que abarca múltiples transacciones. El chaincode puede requerir que actores de 
  varias organizaciones indiquen cuales son sus términos y condiciones para un acuerdo
  en una transacción en el ledger. Luego, una propuesta de chaincode final puede
  verificar que las condiciones de todos las partes en la transacción son alcanzadas,
  y "resolver" la transacción de negocio con finalidad en todos los miembros del
  canal. Para un ejemplo concreto de como indicar términos y condiciones en privado,
  ver el escenario de transferencia de activos en la documentación :doc:`private-data/private-data`.

Mejoras en data privada
-----------------------

Fabric v2.0 permite también nuevos patrones para trabajar y compartir data privada,
sin el requerimiento de crear colecciones de data privada para todas las
combinaciones de miembros de canal que puedan querer transaccionar. Específicamente,
en vez de compartir data privada dentro de una colección de múltiples miembros,
puedes querer compartir la data privada por todas las colecciones, donde cada colección
puede incluir una única organización, o quizás una sola organización junto a 
un regulador o auditor.

Varias mejoras en Fabric v2.x hacen posible estos nuevos patrones en data privada:

* **Compartir y verificar data privada** Cuando data privada es compartida con un
  miembro de un canal que no es miembro de una colección, o compartida con otra
  colección de data privada que contiene uno o mas miembros de canal (escribiendo
  una llave a esa colección), las partes receptoras pueden utilizar la API de chaincode
  GetPrivateDataHash() para verificar que la data privada coincide con
  los hashes on-chain que fueron creados desde data privada en las transacciones previas.

* **Políticas de endoso a nivel de colección** Las colecciones de data privada ahora pueden
  opcionalmente ser definidos con una política de endoso que anula la
  política de endoso a nivel del para llaves dentro de esa colección. Esta
  capacidad puede ser utilizada para restringir que organización puede escribir data a
  una colección, y es lo que permite el nuevo ciclo de vida del chaincode y los patrones
  aplicativos de chaincode mencionados antes. Por ejemplo, puedes tener una política de 
  endoso de chaincode que requiere que una mayoría de organizaciones endosen,
  pero para cualquier transacción dada, requieras que dos organizaciones transaccionales
  individualmente endosen su acuerdo en su propio colección de data privada.

* **Colecciones implícitas por organización** Si quisieras utilizar patrones
  de data privada por organización, no tienes que definir las
  colecciones cuando estés desplegando el chaincode en Fabric v2.x.  Las colecciones
  implícitas específicas a una organización pueden utilizarse sin ninguna definición inicial.

Para aprender mas sobre los nuevos patrones de data privada, ver :doc:`private-data/private-data` (documentación
del concepto). Para detalles respecto de la configuración de colecciones de data privada y
colecciones implícitas, ver :doc:`private-data-arch` (documentación de referencia).

Lanzador de chaincodes externos
-------------------------------

La capacidad de lanzar chaincodes externos empodera a los operadores a construir e iniciar
chaincodes con la tecnología de su elección. El uso de generadores externos e iniciadores
no es requerido ya que el comportamiento por defecto construye y ejecuta chaincode de la misma manera
que en releases anteriores utilizando la API de Docker.

* **Eliminar dependencias del daemon de Docker** Los releases anteriores de Fabric requerían
  que los peers tuviesen acceso al daemon de Docker para poder construir e iniciar un
  chaincode - algo que puede no ser deseable en ambiente productivos debido a
  los privilegios requeridos por el proceso del peer.

* **Alternativas a contenedores** Ya no se require que un chaincode ejecute
  en un contenedor Docker, y puede hacerlo en el ambiente de elección del operador
  (incluyendo contenedores).

* **Ejecutables de generador externo** Un operador puede proveer un conjunto de
  ejecutables de generador externo para reemplazar como el peer construye y lanza chaincode.

* **Chaincode como un servicio externo** Tradicionalmente, los chaincodes eran levantados
  por el peer, y luego se conectan con el peer. Es posible ahora ejecutar un chaincode como
  un servicio externo, por ejemplo en un pod de Kubernetes, al cual un peer puede
  conectarse a y utilizar para la ejecución del chaincode. Ver :doc:`cc_service` para mas
  información.

Ver :doc:`cc_launcher` para aprender mas sobre la capacidad de lanzador de chaincodes externos.

Cache de la base de datos de estados para un desempeño mejorado en CouchDB
--------------------------------------------------------------------------

* Cuando se utiliza una base de datos de estado externa en CouchDB, los retrasos en lecturas durante las
  fases de endoso y validación han sido históricamente una limitación de rendimiento.

* Con Fabric v2.0, un nuevo cache en el peer reemplaza a muchos de estas búsquedas costosas
  con lecturas locales rápidas al cache. El tamaño del cache puede ser configurado utilizando
  la propiedad ``cacheSize`` en el archivo core.yaml.

Imágenes Docker basadas en Alpine
---------------------------------

Comenzando con v2.0, las imágenes Docker de Hyperledger Fabric utilizarán Alpine Linux,
una distribución de Linux liviana y orientada a la seguridad. Esto significa que las imágenes
Docker ahora son mas pequeñas, proveyendo tanto una bajada como un tiempo de arranque mas rápida,
como también ocupando menos espacio de disco en los sistemas host. Alpine Linux esta diseñado
desde su base teniendo presente la seguridad, y la naturaleza minimalista de la distribución 
Alpine reduce bastante el riesgo de vulnerabilidades de seguridad.

Red de pruebas de ejemplo
-------------------------

El repositorio de fabric-samples ahora incluye una nueva red de pruebas de Fabric. La red
de pruebas esta construída para ser una red ejemplo de Fabric modular y amigable para el usuario que
hace fácil probar tus aplicaciones y contratos inteligentes. La red también
soporta la habilidad para implementar tu red utilizando Autoridades Certificantes,
además de cryptogen.

Para mas información respecto de esta red, revisar :doc:`test_network`.

Actualización a Fabric v2.x
---------------------------

Un importante nuevo release conlleva algunas consideraciones adicionales de actualización. Puedes estar seguro
que las actualizaciones progresivas de v1.4.x a v2.0 están soportadas, para que los componentes
de la red puedan ser actualizados uno a la vez sin tiempo fuera de línea.

Los docs de actualización han sido significativamente re-trabajados y expandidos, y tienen ahora
un hogar por si solos en la documentación: :doc:`upgrade`. Encontrarás aquí documentación sobre
:doc:`upgrading_your_components` y :doc:`updating_capabilities`, asi como una
mirada específica de las consideraciones para actualizar a v2.x, :doc:`upgrade_to_newest_version`.

Release notes
=============

Las notas de la versión proveen mas detalles para usuarios moviéndose al nuevo release.
Específicamente, revisa los cambios y obsolescencias.

* `Fabric v2.5.0 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.0>`_.
* `Fabric v2.5.1 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.1>`_.
* `Fabric v2.5.2 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.2>`_.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
