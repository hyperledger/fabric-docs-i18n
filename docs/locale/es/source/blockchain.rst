Introducción
============
Hyperledger Fabric es una plataforma para soluciones de ledger distribuido que esta
sustentado con una arquitectura modular que entrega los altos niveles de confidencialidad,
resiliencia, flexibilidad y escalabilidad. Esta diseñada para soportar implementaciones
intercambiables de diferentes componentes y acomodar la complejidad y sutileza
que existe a través del ecosistema económico.

Recomendamos que los usuarios primerizos comiencen leyendo el resto de la 
introducción a continuación para familiarizarse con cómo funciona una blockchain
y con las capacidades específicas y componentes de Hyperledger Fabric.

Una vez que estén cómodos --- o si ya están familiarizados con blockchain y
Hyperledger Fabric --- ir a :doc:`getting_started` y de allí exploren las
demos, especificaciones técnicas, APIs, etc.

¿Qué es una Blockchain?
-----------------------
**Un Ledger Distribuido**

En el corazón de una red de blockchain se encuentra un ledger distribuido que registra todas
las transacciones que ocurren en la red.

Un ledger de blockchain es comúnmente descrito como **descentralizada** porque esta replicado
através de muchos participantes de la red, cada uno de los cuales **colabora** en su mantenimiento.
Veremos que la descentralización y colaboración son capacidades poderosas que
reflejan la manera en que las empresas intercambian bienes y servicios en el mundo real.

.. image:: images/basic_network.png

Adicionalmente a ser descentralizado y colaborativo, la información registrada
en blockchain solo puede ser agregada, utilizando técnicas criptográficas que garantizan
que una vez que una transacción ha sido agregada al ledger no pueda ser modificada.
Esta propiedad de "inmutabilidad" hace simple determinar la procedencia de
información porque los participantes están seguros que no ha sido modificada
luego del hecho. Este es el motivo por el cual a veces las blockchains son descritas como **sistemas de prueba**.

**Contratos Inteligentes**

Para soportar la consistente actualización de información --- y habilitar una amplia variedad de 
funciones del ledger (transaccionar, consultar, etc) --- una red de blockchain utiliza **contratos
inteligentes** para proveer el acceso controlado al ledger.

.. image:: images/Smart_Contract.png

Los contratos inteligente no son sólo un mecanismo clave para encapsular información
y mantenerlo simple a través de toda la red, también pueden ser escritos para permitirle
a los participantes ejecutar ciertos aspectos de las transacciones automáticamente.

Un contrato inteligente puede, por ejemplo, ser escrito para estipular el costo de envío
de un ítem donde el valor del cargo de envío cambia dependiendo de cuan rápido llega el ítem.
Con los términos acordados por ambas partes y escritas al ledger,
los fondos correspondientes cambian de mano automáticamente cuando el ítem es recibido.

**Consenso**

El proceso para mantener las transacciones del ledger sincronizadas através de la red ---
para asegurar que los ledger solo se actualicen cuando las transacciones son aprobadas por los participantes
apropiados, y cuando los ledgers si actualizan, lo hagan con
las mismas transacciones en el mismo orden --- es llamado **consenso**.

.. image:: images/consensus.png

Aprenderás mucho mas sobre ledgers, contratos inteligentes y consenso mas adelante. Por
ahora, es suficiente que pienses en blockchain como un sistema transaccional compartido
y replicado que es actualizado vía contratos inteligentes y mantenido consistentemente
sincronizado por medio de un proceso colaborativo que se llama consenso.

¿Por qué es útil Blockchain?
----------------------------

**Los Sistemas de Registro de Hoy**

Las redes transaccionales de hoy no son mas que versiones ligeramente actualizadas
de redes que han existido desde que se han mantenido registros de negocios.
Los miembros de una **red de negocios** transaccionan entre ellos, pero mantienen
registros separados de sus transacciones. Y las cosas que están transaccionando ---
sean tapices flamencos del siglo 16 o los títulos financieros de hoy
--- deben establecer su procedencia cada vez que son vendidos para asegurarle 
al negocio que vende un ítem que posee una cadena de títulos verificando que sea de
de su propiedad. 

Lo que te queda es una red de negocio que se parece a esto:

.. image:: images/current_network.png

La tecnología moderna ha llevado este proceso del uso de tabletas de piedra y carpetas de papel
a discos duros y plataformas de nube, pero la estructura subyacente es la misma.
No existen sistemas unificados para administrar la identidad de los participantes de la red,
entonces establecer la procedencia es tan laborioso que lleva días compensar transacciones de
títulos financieros (el volumen mundial de esto esta estimado en muchos billones de
dólares), los contratos deben estar firmados y ejecutados manualmente, y todas las bases de datos
en el sistema contiene información única y consecuentemente representa un único punto
de falla.

Es imposible construir un sistema de registro que comprenda una red de negocios
con el enfoque fracturado actual de la información y procesos para compartirla, aún 
cuando las necesidades de visibilidad y claridad sean evidentes.

**La Diferencia con Blockchain**

Y si, en vez del revoltijo de ineficencias representadas por el "moderno"
sistema de transacciones, las redes de negocio tuviesen métodos estándar para establecer
la identidad en la red, ejecutar transacciones, y almacenar data? Y 
si la comprobación de la procedencia de un activo pudiese determinarse al revisar
una lista de transacciones que, una vez escritas, no pueden ser modificadas, y pueden
consiguientemente ser confiables? 

La red de negocio se parecería mas a esto:

.. image:: images/future_net.png

Esta es una red de blockchain, donde cada participante tiene su propia copia
replicada del ledger. Adicional a la información del ledger compartida, los procesos
que actualizan el ledger también son compartidos. A diferencia de los sistemas actuales, donde los
programas **privados** de los participantes son utilizados para actualizar sus ledgers **privados**,
un sistema de blockchain tiene programas **compartidos** para actualizar ledgers **compartidos**.

Con la habilidad para poder coordinar a la red de negocio mediante un ledger compartido,
las redes blockchain pueden reducir tiempo, costo y riesgo asociado con la información
privada y su procesamiento mejorando la confiabilidad y visibilidad al mismo tiempo.

Ahora conoces qué es blockchain y por qué es útil. Hay muchísimos detalles
adicionales que son importantes, pero se relacionan con estas ideas fundamentales de
compartir la información y los procesos.

¿Qué es Hyperledger Fabric?
---------------------------

La Linux Foundation fundó el proyecto Hyperledger en 2015 para avanzar
las tecnologías interindustria de blockchain. Ante que declarar un solo
estándar de blockchain, alienta un enfoque colaborativo al desarrollo
de tecnologías blockchain mediante un proceso comunitario, con derechos de
propiedad intelectual que alienta el desarrollo abierto y la adopción de estándares
en el tiempo.

Hyperledger Fabric es uno de los proyectos de blockchain dentro de Hyperledger.
Como otras tecnologías de blockchain, tiene un ledger, usa contratos inteligentes,
y es un sistema por el cual los participantes manejan sus transacciones.

Donde Hyperledger Fabric se separa de otros sistemas de blockchain es en que 
es **privado** y **permisionado**. Ante que un sistema abierto y no permisionado
que permite a identidades desconocidas participar en la red (requiriendo protocolos
como "prueba de trabajo" para validar transacciones y asegurar la red), los miembros
de una red de Hyperledger Fabric se inscriben mediante un 
**Proveedor de Servicios de Membresía (MSP por sus siglas en inglés)** confiable.

Hyperledger Fabric también ofrece algunas opciones conectables. La data del Ledger puede ser
almacenada en múltiples formatos, los mecanismos de consenso pueden ser intercambiados,
y diferentes MSPs son soportados.

Hyperledger Fabric también ofrece la capacidad de crear **canales**, permitiendo a un grupo de
participantes crear un ledger separado de transacciones. Esta es una opción especialmente
importante para redes donde algunos de los participantes pueden ser competidores y no quieren
que todas las transacciones que realicen --- un precio especial que están ofreciendo a algunos participantes
y no a otros, por ejemplo --- sea conocido por todos. Si dos participantes
forman un canal, entonces esos participantes --- y no otros --- tienen copias del ledger
para ese canal.

**Ledger Compartido**

Hyperledger Fabric tiene un subsistema de ledger compuesto por dos componentes: el **world
state** y el **transaction log**. Cada participante tiene una copia del ledger de cada
red de Hyperledger Fabric al que pertenecen.

El componente de world state describe el estado del ledger a un momento determinado
en el tiempo. Es la base de datos del ledger. El componente de transaction log registra
todas las transacciones que han resultado en el valor actual del world state;
es la historia de actualizaciones para el world state. El ledger es, entonces, una combinación
de la base de datos del world state y la historia del transaction log.

El ledger tiene un repositorio de datos reemplazable para el world state. Por defecto, es
una base de datos de almacenamiento clave-valor en LevelDB. El transaction log no necesita ser
intercambiable. Simplemente registra los valores de antes y después de la base de datos del ledger
que esta siendo usado por la red de blockchain.

**Contratos Inteligentes**

Los contratos inteligentes en Hyperledger Fabric son escritos en **chaincode** y son invocados
por una aplicación externa a blockchain cuando esa aplicación necesita
interactuar con el ledger. En la mayoría de los casos, el chaincode interactúa solamente con el
componente de la base de datos del ledger, el world state (consultándolo, por ejemplo), y
no el transaction log.

Un chaincode puede ser implementado en varios lenguajes de programación. Actualmente son soportados
chaincodes escritos en Go, Node.js, y Java.


**Privacidad**

Dependiendo de las necesidades de la red, los participantes en una red 
Business-to-Business (B2B) quizás sean extremamente sensibles respecto a cuánta información comparten.
Para otras redes, la privacidad no sera una preocupación primordial.

Hyperledger Fabric soporta redes donde la privacidad (utilizando canales) es un requerimiento
operacional clave así como aquellas que son comparativamente abiertas..

**Consenso**

Las transacciones deben ser escritas al ledger en el orden en que ocurren.
aún cuando puedan transcurrir entre diferentes juegos de participantes dentro de
la red. Para que esto ocurra, el orden de las transacciones debe ser establecida
y un método para rechazar transacciones erróneas que han sido insertadas en el
ledger por error (o maliciosamente) debe ser implementado.

Ésta es una área de las ciencias de la computación que ha sido minuciosamente investigada, y 
existen muchas maneras de lograrlo, cada una con un trade-off diferente. Por ejemplo, PBFT (Practical
Byzantine Fault Tolerance) puede proveer un mecanismo para que réplicas de archivos se
comuniquen entre ellos para mantener cada copia consistente, aún en el evento
de una corrupción. Alternativamente, en Bitcoin, el ordenamiento ocurre mediante un proceso
llamado minado donde computadoras en competencia corren a resolver un acertijo criptográfico 
que define el orden en que todos los procesos construyen posteriormente.

Hyperledger Fabric ha sido diseñado para permitir a quienes comienzan redes que puedan
elegir el mecanismo de consenso que mejor representa las relaciones existentes entre
los participantes. Así como ocurre con la privacidad, hay un espectro de necesidades, desde
redes que son altamente estructuradas en sus relaciones a aquellas que son mas
peer-to-peer.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
