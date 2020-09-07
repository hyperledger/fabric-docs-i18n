Modelo de Hyperledger Fabric
========================

Esta sección esboza las características clave de diseño de Hyperledger Fabric 
que cumplen su promesa de una solución integral, pero personalizable de cadena de bloques empresarial:

* `Activos`_ --- Las definiciones de activos permiten el intercambio de casi cualquier cosa con valor monetario a través de la red, desde alimentos enteros hasta coches antiguos y futuros de divisas.
* `Chaincode`_ --- La ejecución del Chaincode se divide en el ordenamiento de las transacciones, delimitando los niveles requeridos de confianza y verificación en los tipos de nodos y optimizando la escalabilidad y el rendimiento de la red.
* `Caracteristicas del libro mayor`_ --- La inmutabilidad, el libro mayor compartido codifica todo el historial de transacciones de cada canal e incluye una capacidad de consulta tipo SQL para una auditoría eficiente y la resolución de disputas.
* `Privacidad`_ --- Los canales y las recopilaciones de datos privados permiten realizar transacciones multilaterales privadas y confidenciales que suelen ser necesarias para las empresas competidoras y las industrias reguladas que intercambian activos en una red común.
* `Seguridad & Servicio de membresia`_ --- La membresía permisionada proporciona una red de cadenas de bloqueo de confianza, en la que los participantes saben que todas las transacciones pueden ser detectadas y rastreadas por los reguladores y auditores autorizados.
* `Consenso`_ --- Un enfoque único del consenso permite la flexibilidad y la escalabilidad necesarias para la empresa.


Activos
------

Los activos pueden ir desde lo tangible (bienes raíces y hardware) hasta lo intangible (contratos y propiedad intelectual).  
Hyperledger Fabric ofrece la posibilidad de modificar los activos mediante transacciones con código de cadena.

Los activos son representados en Hyperledger Fabric como una colección de pares clave-valor, con los cambios de estado 
registrados como transacciones en un libro mayor del :ref:`Canal`.  Los activos pueden ser representados en forma binaria y/o JSON.


Chaincode
---------

El Chaincode es un software que define un activo o activos y las instrucciones de la transacción para modificar el activo o activos; 
en otras palabras, es la lógica del negocio.  El Chaincode hace cumplir las reglas para leer o modificar los pares clave-valor u otra 
información de la base de datos de estado. Las funciones de Chaincode se ejecutan contra la base de datos del estado actual del libro mayor
y se inician mediante una propuesta de transacción. La ejecución del Chaincode da como resultado un conjunto de escrituras clave-valor 
(conjunto de escritura) que puede ser enviado a la red y aplicado al libro mayor en todos los pares.


Caracteristicas del libro mayor
---------------

El libro mayor es el registro secuencial y a prueba de manipulaciones de todas las transiciones de estado en Fabric.
Las transiciones de estado son el resultado de los llamados del chaincode ("transacciones") presentadas por las partes participantes. 
Cada transacción da lugar a un conjunto de pares clave-valor de activos que se registran en el libro mayor en forma de creación, actualización 
o eliminación.

El libro mayor está compuesto por una cadena de bloques ('cadena') para almacenar el registro inmutable y secuenciado en bloques, 
así como una base de datos de estado para mantener el estado actual de Fabric.  Hay un libro mayor por canal. Cada par mantiene una copia del 
libro mayor para cada canal del que es miembro.

Algunas características de libro mayor de Fabric:

- Consultar y actualizar el libro mayor usando búsquedas basadas en claves, consultas de rango y consultas de claves compuestas
- Consultas de sólo lectura usando un lenguaje de consulta enriquecida (si se usa CouchDB como base de datos del estado)
- Consultas de historial de sólo lectura --- Consultar el historial del libro mayor para una clave, permitiendo escenarios de origen de datos
- Las transacciones consisten en las versiones de claves/valores que fueron leídas en  el chaincode (conjunto de lectura) y claves/valores que fueron escritas en el chaincode (conjunto de escritura)
- Las transacciones contienen las firmas de todos los pares que las avalan y se envían al servicio de ordenamiento
- Las transacciones se ordenan en bloques y se "entregan" desde un servicio de ordenamiento a los pares en un canal
- Los pares validan las transacciones contra las políticas de endoso y hacen cumplir las políticas
- Antes de añadir un bloque, se realiza una comprobación de versiones para asegurar que los estados de los activos leídos no han cambiado durante el tiempo de ejecución del chaincode.
- Hay inmutabilidad una vez que una transacción es validada y confirmada
- El libro mayor de un canal contiene un bloque de configuración que define las políticas, las listas de control de acceso y otra información pertinente
- Los canales contienen :ref:`MSP` instancias que permiten que los materiales criptográficos se deriven de diferentes autoridades de certificación

Ver el tema :doc:`ledger` para una inmersión más profunda en las bases de datos, la estructura de almacenamiento y la "consultabilidad".


Privacidad
-------

Hyperledger Fabric employs an immutable ledger on a per-channel basis, as well as
chaincode that can manipulate and modify the current state of assets (i.e. update
key-value pairs).  A ledger exists in the scope of a channel --- it can be shared
across the entire network (assuming every participant is operating on one common
channel) --- or it can be privatized to include only a specific set of participants.

In the latter scenario, these participants would create a separate channel and
thereby isolate/segregate their transactions and ledger.  In order to solve
scenarios that want to bridge the gap between total transparency and privacy,
chaincode can be installed only on peers that need to access the asset states
to perform reads and writes (in other words, if a chaincode is not installed on
a peer, it will not be able to properly interface with the ledger).

When a subset of organizations on that channel need to keep their transaction
data confidential, a private data collection (collection) is used to segregate
this data in a private database, logically separate from the channel ledger,
accessible only to the authorized subset of organizations.

Thus, channels keep transactions private from the broader network whereas
collections keep data private between subsets of organizations on the channel.

To further obfuscate the data, values within chaincode can be encrypted
(in part or in total) using common cryptographic algorithms such as AES before
sending transactions to the ordering service and appending blocks to the ledger.
Once encrypted data has been written to the ledger, it can be decrypted only by
a user in possession of the corresponding key that was used to generate the cipher
text.

See the :doc:`private-data-arch` topic for more details on how to achieve
privacy on your blockchain network.


Seguridad & Servicio de membresia
------------------------------

Hyperledger Fabric underpins a transactional network where all participants have
known identities.  Public Key Infrastructure is used to generate cryptographic
certificates which are tied to organizations, network components, and end users
or client applications.  As a result, data access control can be manipulated and
governed on the broader network and on channel levels.  This "permissioned" notion
of Hyperledger Fabric, coupled with the existence and capabilities of channels,
helps address scenarios where privacy and confidentiality are paramount concerns.

See the :doc:`msp` topic to better understand cryptographic
implementations, and the sign, verify, authenticate approach used in
Hyperledger Fabric.


Consenso
---------

In distributed ledger technology, consensus has recently become synonymous with
a specific algorithm, within a single function. However, consensus encompasses more
than simply agreeing upon the order of transactions, and this differentiation is
highlighted in Hyperledger Fabric through its fundamental role in the entire
transaction flow, from proposal and endorsement, to ordering, validation and commitment.
In a nutshell, consensus is defined as the full-circle verification of the correctness of
a set of transactions comprising a block.

Consensus is achieved ultimately when the order and results of a block's
transactions have met the explicit policy criteria checks. These checks and balances
take place during the lifecycle of a transaction, and include the usage of
endorsement policies to dictate which specific members must endorse a certain
transaction class, as well as system chaincodes to ensure that these policies
are enforced and upheld.  Prior to commitment, the peers will employ these
system chaincodes to make sure that enough endorsements are present, and that
they were derived from the appropriate entities.  Moreover, a versioning check
will take place during which the current state of the ledger is agreed or
consented upon, before any blocks containing transactions are appended to the ledger.
This final check provides protection against double spend operations and other
threats that might compromise data integrity, and allows for functions to be
executed against non-static variables.

In addition to the multitude of endorsement, validity and versioning checks that
take place, there are also ongoing identity verifications happening in all
directions of the transaction flow.  Access control lists are implemented on
hierarchical layers of the network (ordering service down to channels), and
payloads are repeatedly signed, verified and authenticated as a transaction proposal passes
through the different architectural components.  To conclude, consensus is not
merely limited to the agreed upon order of a batch of transactions; rather,
it is an overarching characterization that is achieved as a byproduct of the ongoing
verifications that take place during a transaction's journey from proposal to
commitment.

Check out the :doc:`txflow` diagram for a visual representation
of consensus.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
