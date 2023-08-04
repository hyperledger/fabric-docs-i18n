¿Qué es lo Nuevo en Hyperledger Fabric v2.x?
=====================================

Lo nuevo en Hyperledger Fabric v2.5
-------------------------------------

Purgar la historia de data privada
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Aún cuando siempre ha sido posible borrar data privada del estado actual, esta nueva capacidad permite purgar la historia de data privada de un peer conservando un hash de la data privada como evidencia inmutable en blockchain.

* Util para purgar data privada a demanda por motivos de privacidad o para alinearse con regulaciones gubernamentales.
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

Ahora puedes desvincular un peer de un canal cuando el canal ya no es requerido. Todos los recursos del canal seran eliminados del peer y el mismo no procesara mas bloques de ese canal.

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
  Las instantáneas en las que esten todos de acuerdo pueden ser usadas como puntos de control y la base para nuevos peers que se estén uniendo.

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

Decentralized governance for smart contracts
--------------------------------------------

Fabric v2.0 introduces decentralized governance for smart contracts, with a new
process for installing a chaincode on your peers and starting it on a channel.
The new Fabric chaincode lifecycle allows multiple organizations to come to
agreement on the parameters of a chaincode, such as the chaincode endorsement
policy, before it can be used to interact with the ledger. The new model
offers several improvements over the previous lifecycle:

* **Multiple organizations must agree to the parameters of a chaincode**
  In the release 1.x versions of Fabric, one organization had the ability to
  set parameters of a chaincode (for instance the endorsement policy) for all
  other channel members, who only had the power to refuse to install the chaincode
  and therefore not take part in transactions invoking it. The new Fabric
  chaincode lifecycle is more flexible since it supports both centralized
  trust models (such as that of the previous lifecycle model) as well as
  decentralized models requiring a sufficient number of organizations to
  agree on an endorsement policy and other details before the chaincode
  becomes active on a channel.

* **More deliberate chaincode upgrade process** In the previous chaincode
  lifecycle, the upgrade transaction could be issued by a single organization,
  creating a risk for a channel member that had not yet installed the new
  chaincode. The new model allows for a chaincode to be upgraded only after
  a sufficient number of organizations have approved the upgrade.

* **Simpler endorsement policy and private data collection updates**
  Fabric lifecycle allows you to change an endorsement policy or private
  data collection configuration without having to repackage or reinstall
  the chaincode. Users can also take advantage of a new default endorsement
  policy that requires endorsement from a majority of organizations on the
  channel. This policy is updated automatically when organizations are
  added or removed from the channel.

* **Inspectable chaincode packages** The Fabric lifecycle packages chaincode
  in easily readable tar files. This makes it easier to inspect the chaincode
  package and coordinate installation across multiple organizations.

* **Start multiple chaincodes on a channel using one package** The previous
  lifecycle defined each chaincode on the channel using a name and version
  that was specified when the chaincode package was installed. You can now
  use a single chaincode package and deploy it multiple times with different
  names on the same channel or on different channels. For example, if you’d
  like to track different types of assets in their own ‘copy’ of the chaincode.

* **Chaincode packages do not need to be identical across channel members**
  Organizations can extend a chaincode for their own use case, for example
  to perform different validations in the interest of their organization.
  As long as the required number of organizations endorse chaincode transactions
  with matching results, the transaction will be validated and committed to the
  ledger.  This also allows organizations to individually roll out minor fixes
  on their own schedules without requiring the entire network to proceed in lock-step.

Using the new chaincode lifecycle
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For existing Fabric deployments, you can continue to use the prior chaincode
lifecycle with Fabric v2.x. The new chaincode lifecycle will become effective
only when the channel application capability is updated to v2.0.
See the :doc:`chaincode_lifecycle` concept topic for an overview of the new
chaincode lifecycle.

New chaincode application patterns for collaboration and consensus
------------------------------------------------------------------

The same decentralized methods of coming to agreement that underpin the
new chaincode lifecycle management can also be used in your own chaincode
applications to ensure organizations consent to data transactions before
they are committed to the ledger.

* **Automated checks** As mentioned above, organizations can add automated
  checks to chaincode functions to validate additional information before
  endorsing a transaction proposal.

* **Decentralized agreement** Human decisions can be modeled into a chaincode process
  that spans multiple transactions. The chaincode may require actors from
  various organizations to indicate their terms and conditions of agreement
  in a ledger transaction. Then, a final chaincode proposal can
  verify that the conditions from all the individual transactors are met,
  and "settle" the business transaction with finality across all channel
  members. For a concrete example of indicating terms and conditions in private,
  see the asset transfer scenario in the :doc:`private-data/private-data` documentation.

Private data enhancements
-------------------------

Fabric v2.0 also enables new patterns for working with and sharing private data,
without the requirement of creating private data collections for all
combinations of channel members that may want to transact. Specifically,
instead of sharing private data within a collection of multiple members,
you may want to share private data across collections, where each collection
may include a single organization, or perhaps a single organization along
with a regulator or auditor.

Several enhancements in Fabric v2.x make these new private data patterns possible:

* **Sharing and verifying private data** When private data is shared with a
  channel member who is not a member of a collection, or shared with another
  private data collection that contains one or more channel members (by writing
  a key to that collection), the receiving parties can utilize the
  GetPrivateDataHash() chaincode API to verify that the private data matches the
  on-chain hashes that were created from private data in previous transactions.

* **Collection-level endorsement policies** Private data collections can now
  optionally be defined with an endorsement policy that overrides the
  chaincode-level endorsement policy for keys within the collection. This
  feature can be used to restrict which organizations can write data to a
  collection, and is what enables the new chaincode lifecycle and chaincode
  application patterns mentioned earlier. For example, you may have a chaincode
  endorsement policy that requires a majority of organizations to endorse,
  but for any given transaction, you may need two transacting organizations
  to individually endorse their agreement in their own private data collections.

* **Implicit per-organization collections** If you’d like to utilize
  per-organization private data patterns, you don’t even need to define the
  collections when deploying chaincode in Fabric v2.x.  Implicit
  organization-specific collections can be used without any upfront definition.

To learn more about the new private data patterns, see the :doc:`private-data/private-data` (conceptual
documentation). For details about private data collection configuration and
implicit collections, see the :doc:`private-data-arch` (reference documentation).

External chaincode launcher
---------------------------

The external chaincode launcher feature empowers operators to build and launch
chaincode with the technology of their choice. Use of external builders and launchers
is not required as the default behavior builds and runs chaincode in the same manner
as prior releases using the Docker API.

* **Eliminate Docker daemon dependency** Prior releases of Fabric required
  peers to have access to a Docker daemon in order to build and launch
  chaincode - something that may not be desirable in production environments
  due to the privileges required by the peer process.

* **Alternatives to containers** Chaincode is no longer required to be run
  in Docker containers, and may be executed in the operator’s choice of
  environment (including containers).

* **External builder executables** An operator can provide a set of external
  builder executables to override how the peer builds and launches chaincode.

* **Chaincode as an external service** Traditionally, chaincodes are launched
  by the peer, and then connect back to the peer. It is now possible to run chaincode as
  an external service, for example in a Kubernetes pod, which a peer can
  connect to and utilize for chaincode execution. See :doc:`cc_service` for more
  information.

See :doc:`cc_launcher` to learn more about the external chaincode launcher feature.

State database cache for improved performance on CouchDB
--------------------------------------------------------

* When using external CouchDB state database, read delays during endorsement
  and validation phases have historically been a performance bottleneck.

* With Fabric v2.0, a new peer cache replaces many of these expensive lookups
  with fast local cache reads. The cache size can be configured by using the
  core.yaml property ``cacheSize``.

Alpine-based docker images
--------------------------

Starting with v2.0, Hyperledger Fabric Docker images will use Alpine Linux,
a security-oriented, lightweight Linux distribution. This means that Docker
images are now much smaller, providing faster download and startup times,
as well as taking up less disk space on host systems. Alpine Linux is designed
from the ground up with security in mind, and the minimalist nature of the Alpine
distribution greatly reduces the risk of security vulnerabilities.

Sample test network
-------------------

The fabric-samples repository now includes a new Fabric test network. The test
network is built to be a modular and user friendly sample Fabric network that
makes it easy to test your applications and smart contracts. The network also
supports the ability to deploy your network using Certificate Authorities,
in addition to cryptogen.

For more information about this network, check out :doc:`test_network`.

Upgrading to Fabric v2.x
------------------------

A major new release brings some additional upgrade considerations. Rest assured
though, that rolling upgrades from v1.4.x to v2.0 are supported, so that network
components can be upgraded one at a time with no downtime.

The upgrade docs have been significantly expanded and reworked, and now have a
standalone home in the documentation: :doc:`upgrade`. Here you'll find documentation on
:doc:`upgrading_your_components` and :doc:`updating_capabilities`, as well as a
specific look  at the considerations for upgrading to v2.x, :doc:`upgrade_to_newest_version`.

Release notes
=============

The release notes provide more details for users moving to the new release.
Specifically, take a look at the changes and deprecations.

* `Fabric v2.5.0 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.0>`_.
* `Fabric v2.5.1 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.1>`_.
* `Fabric v2.5.2 release notes <https://github.com/hyperledger/fabric/releases/tag/v2.5.2>`_.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
