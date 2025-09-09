# Libro Mayor

**Audiencia**: Arquitectos, desarrolladores de aplicaciones y contratos inteligentes,
administradores

Un **libro mayor** es un concepto clave en Hyperledger Fabric; almacena información factual importante
sobre objetos de negocio; tanto el valor actual de los atributos de
los objetos, como el historial de transacciones que resultaron en estos valores actuales.

En este tema, vamos a cubrir:

* [¿Qué es un Libro Mayor?](#qué-es-un-libro-mayor)
* [Almacenando hechos sobre objetos de negocio](#libros-mayores-hechos-y-estados)
* [Un libro mayor blockchain](#el-libro-mayor)
* [El estado mundial](#estado-mundial)
* [La estructura de datos de blockchain](#blockchain)
* [Cómo se almacenan los bloques en un blockchain](#bloques)
* [Transacciones](#transacciones)
* [Opciones de base de datos del estado mundial](#opciones-de-base-de-datos-del-estado-mundial)
* [El ejemplo de libro mayor **Fabcar**](#ejemplo-de-libro-mayor-fabcar)
* [Libros mayores y espacios de nombres](#espacios-de-nombres)
* [Libros mayores y canales](#canales)

## ¿Qué es un Libro Mayor?

Un libro mayor contiene el estado actual de un negocio como un diario de transacciones.
Los libros mayores europeos y chinos más antiguos datan de hace casi 1000 años, y
los sumerios tenían [libros mayores de
piedra](http://www.sciencephoto.com/media/686227/view/accounting-ledger-sumerian-cuneiform)
hace 4000 años -- ¡pero comencemos con un ejemplo más actualizado!

Probablemente estés acostumbrado a mirar tu cuenta bancaria. Lo más importante para
ti es el saldo disponible -- es lo que puedes gastar en el momento actual.
Si quieres ver cómo se derivó tu saldo, entonces puedes
revisar los créditos y débitos de las transacciones que lo determinaron. Este es un
ejemplo real de un libro mayor -- un estado (tu saldo bancario), y un conjunto de
transacciones ordenadas (créditos y débitos) que lo determinan. Hyperledger Fabric
está motivado por estas mismas dos preocupaciones -- presentar el valor actual de un conjunto
de estados de libros mayores, y capturar la historia de las transacciones que determinaron
estos estados.

## Libros Mayores, Hechos y Estados

Un libro mayor no almacena literalmente objetos de negocio -- en su lugar, almacena **hechos**
sobre esos objetos. Cuando decimos "almacenamos un objeto de negocio en un libro mayor" lo que
realmente queremos decir es que estamos registrando los hechos sobre el estado actual de un
objeto, y los hechos sobre la historia de transacciones que llevaron al estado actual. En un mundo
cada vez más digital, puede parecer que estamos mirando un
objeto, en lugar de hechos sobre un objeto. En el caso de un objeto digital, es
probable que viva en un almacén de datos externo; los hechos que almacenamos en el libro mayor
nos permiten identificar su ubicación junto con otra información clave sobre él.

Mientras que los hechos sobre el estado actual de un objeto de negocio pueden cambiar, la
historia de hechos sobre él es **inmutable**, se puede agregar a ella, pero no se puede cambiar
retrospectivamente. Vamos a ver cómo pensar en una blockchain como una
historia inmutable de hechos sobre objetos de negocio es una forma simple pero poderosa
de entenderla.

¡Ahora echemos un vistazo más de cerca a la estructura del libro mayor de Hyperledger Fabric!


## El Libro Mayor

En Hyperledger Fabric, un libro mayor consta de dos partes distintas, aunque relacionadas
-- un estado mundial y una blockchain. Cada una de estas representa un conjunto de hechos sobre
un conjunto de objetos de negocio.

En primer lugar, está el **estado mundial** -- una base de datos que mantiene los **valores actuales**
de un conjunto de estados del libro mayor. El estado mundial facilita que un programa acceda directamente
al valor actual de un estado en lugar de tener que calcularlo recorriendo todo el registro de transacciones.
Los estados del libro mayor se expresan, por defecto, como pares **clave-valor**,
y veremos más adelante cómo Hyperledger Fabric ofrece flexibilidad en este aspecto.
El estado mundial puede cambiar frecuentemente, ya que los estados pueden ser creados, actualizados y eliminados.

En segundo lugar, está la **blockchain** -- un registro de transacciones que registra todos los
cambios que han resultado en el estado mundial actual. Las transacciones se
recopilan dentro de bloques que se añaden a la blockchain -- permitiéndote
entender la historia de cambios que han resultado en el estado mundial actual.
La estructura de datos de la blockchain es muy diferente al estado mundial porque una vez
escrita, no se puede modificar; es **inmutable**.

![ledger.ledger](./ledger.diagram.1.png) *Un Libro Mayor L comprende la blockchain B y
el estado mundial W, donde la blockchain B determina el estado mundial W. También podemos decir que
el estado mundial W se deriva de la blockchain B.*

Es útil pensar que hay un libro mayor **lógico** en una red de Hyperledger
Fabric. En realidad, la red mantiene múltiples copias de un libro mayor --
que se mantienen consistentes con cada otra copia a través de un proceso llamado
**consenso**. El término **Tecnología de Libro Mayor Distribuido** (**DLT**, por sus siglas en inglés) a menudo
se asocia con este tipo de libro mayor -- uno que es lógicamente singular, pero tiene
muchas copias consistentes distribuidas a través de una red.

Ahora examinemos con más detalle las estructuras de datos del estado mundial y la blockchain.

## Estado Mundial

El estado mundial mantiene el valor actual de los atributos de un objeto de negocio
como un estado único del libro mayor. Esto es útil porque los programas generalmente requieren el
valor actual de un objeto; sería engorroso recorrer toda la
blockchain para calcular el valor actual de un objeto -- simplemente se obtiene directamente
del estado mundial.

![ledger.worldstate](./ledger.diagram.3.png) *Un estado mundial del libro mayor que contiene
dos estados. El primer estado es: clave=CAR1 y valor=Audi. El segundo estado tiene un
valor más complejo: clave=CAR2 y valor={modelo:BMW, color=rojo, propietario=Jane}. Ambos
estados están en la versión 0.*

Un estado del libro mayor registra un conjunto de hechos sobre un objeto de negocio particular. Nuestro
ejemplo muestra estados del libro mayor para dos autos, CAR1 y CAR2, cada uno con una clave y un
valor. Un programa de aplicación puede invocar un contrato inteligente que utiliza simples
APIs del libro mayor para **obtener**, **poner** y **eliminar** estados. Nota cómo un valor de estado
puede ser simple (Audi...) o compuesto (tipo:BMW...). El estado mundial a menudo se
consulta para recuperar objetos con ciertos atributos, por ejemplo, para encontrar todos los BMWs rojos.

El estado mundial se implementa como una base de datos. Esto tiene mucho sentido porque
una base de datos proporciona un rico conjunto de operadores para el almacenamiento eficiente y
recuperación de estados. Veremos más adelante que Hyperledger Fabric puede configurarse
para usar diferentes bases de datos de estado mundial para abordar las necesidades de diferentes tipos
de valores de estado y los patrones de acceso requeridos por las aplicaciones, por ejemplo, en
consultas complejas.

Las aplicaciones envían transacciones que capturan cambios en el estado mundial, y
estas transacciones terminan siendo comprometidas en la blockchain del libro mayor. Las
aplicaciones están aisladas de los detalles de este mecanismo de [consenso](../txflow.html) por
el SDK de Hyperledger Fabric; simplemente invocan un contrato inteligente y son
notificadas cuando la transacción ha sido incluida en la blockchain (ya sea válida
o inválida). El punto clave de diseño es que solo las transacciones que están **firmadas**
por el conjunto requerido de **organizaciones endosantes** resultarán en una actualización al
estado mundial. Si una transacción no está firmada por suficientes endosantes, no
resultará en un cambio del estado mundial. Puedes leer más sobre cómo las aplicaciones
usan [contratos inteligentes](../smartcontract/smartcontract.html), y cómo [desarrollar
aplicaciones](../developapps/developing_applications.html).

También notarás que un estado tiene un número de versión, y en el diagrama anterior,
los estados CAR1 y CAR2 están en sus versiones iniciales, 0. El número de versión es para
uso interno de Hyperledger Fabric, y se incrementa cada vez que el estado
cambia. La versión se verifica cada vez que el estado se actualiza para asegurarse de que
los estados actuales coincidan con la versión en el momento de la aprobación. Esto asegura que
el estado mundial esté cambiando como se espera; que no ha habido una actualización concurrente.

Finalmente, cuando un libro mayor es creado por primera vez, el estado mundial está vacío. Debido a que cualquier
transacción que representa un cambio válido al estado mundial se registra en la
blockchain, significa que el estado mundial puede ser regenerado desde la
blockchain en cualquier momento. Esto puede ser muy conveniente -- por ejemplo, el estado mundial
se genera automáticamente cuando se crea un par. Además, si un par
falla de manera anormal, el estado mundial puede ser regenerado al reiniciar el par, antes
de que se acepten transacciones.

## Blockchain

Ahora dirijamos nuestra atención desde el estado mundial hacia la blockchain. Mientras que el
estado mundial contiene un conjunto de hechos relacionados con el estado actual de un conjunto de
objetos de negocio, la blockchain es un registro histórico de los hechos sobre cómo
estos objetos llegaron a sus estados actuales. La blockchain ha registrado cada
versión anterior de cada estado del libro mayor y cómo ha sido cambiado.

La blockchain está estructurada como un registro secuencial de bloques interconectados, donde cada
bloque contiene una secuencia de transacciones, cada transacción representando una consulta
o actualización al estado mundial. El mecanismo exacto por el cual las transacciones son
ordenadas se discute [en otro lugar](../peers/peers.html#peers-and-orderers);
lo importante es que la secuenciación de bloques, así como la secuenciación de transacciones
dentro de los bloques, se establece cuando los bloques son creados por primera vez por un componente de Hyperledger
Fabric llamado el **servicio de ordenamiento**.

El encabezado de cada bloque incluye un hash de las transacciones del bloque, así como un hash
del encabezado del bloque anterior. De esta manera, todas las transacciones en el libro mayor están secuenciadas
y enlazadas criptográficamente entre sí. Este enlace y hash hacen que los datos del libro mayor
sean muy seguros. Incluso si un nodo que aloja el libro mayor fuera manipulado, no podría
convencer a todos los otros nodos de que tiene la blockchain 'correcta' porque el libro mayor está
distribuido a través de una red de nodos independientes.

La blockchain siempre se implementa como un archivo, en contraste con el estado mundial,
que utiliza una base de datos. Esta es una elección de diseño sensata ya que la estructura de datos de la blockchain
está muy sesgada hacia un conjunto muy pequeño de operaciones simples.
Añadir al final de la blockchain es la operación principal, y la consulta es
actualmente una operación relativamente infrecuente.

Veamos la estructura de una blockchain con un poco más de detalle.

![ledger.blockchain](./ledger.diagram.2.png) *Una blockchain B que contiene los bloques
B0, B1, B2, B3. B0 es el primer bloque en la blockchain, el bloque génesis.*

En el diagrama anterior, podemos ver que el **bloque** B2 tiene unos **datos de bloque** D2 que
contienen todas sus transacciones: T5, T6, T7.

Lo más importante, B2 tiene un **encabezado de bloque** H2, que contiene un **hash** criptográfico
de todas las transacciones en D2, así como un hash de H1. De esta manera,
los bloques están inextricable e inmutablemente vinculados entre sí, ¡lo que el término **blockchain**
captura tan bien!

Finalmente, como puedes ver en el diagrama, el primer bloque en la blockchain se
llama el **bloque génesis**. Es el punto de partida para el libro mayor, aunque no
contiene ninguna transacción de usuario. En su lugar, contiene una transacción de configuración que contiene el estado inicial del canal de la red (no mostrado). Discutimos
el bloque génesis con más detalle cuando hablamos de la red blockchain y
[canales](../channels.html) en la documentación.

## Bloques

Veamos más de cerca la estructura de un bloque. Consiste en tres
secciones

* **Encabezado del Bloque**

  Esta sección comprende tres campos, escritos cuando se crea un bloque.

  * **Número de Bloque**: Un entero que comienza en 0 (el bloque génesis), y
  se incrementa en 1 por cada nuevo bloque añadido a la blockchain.

  * **Hash del Bloque Actual**: El hash de todas las transacciones contenidas en el
  bloque actual.

  * **Hash del Encabezado del Bloque Anterior**: El hash del encabezado del bloque anterior.

  Estos campos se derivan internamente al hacer el hash criptográfico de los datos del bloque.
  Aseguran que cada bloque esté inextricablemente vinculado a su vecino, llevando a un libro mayor inmutable.

  ![ledger.blocks](./ledger.diagram.4.png) *Detalles del encabezado del bloque. El encabezado H2
  del bloque B2 consiste en el número de bloque 2, el hash CH2 de los datos actuales del bloque
  D2, y el hash del encabezado del bloque anterior H1.*


* **Datos del Bloque**

  Esta sección contiene una lista de transacciones ordenadas. Se escribe
  cuando el bloque es creado por el servicio de ordenamiento. Estas transacciones tienen una
  estructura rica pero sencilla, la cual describimos [más adelante](#Transacciones)
  en este tema.


* **Metadatos del Bloque**

  Esta sección contiene el certificado y la firma del creador del bloque, que se utiliza para verificar
  el bloque por los nodos de la red.
  Posteriormente, el comprometedor del bloque añade un indicador válido/inválido para cada transacción en
  un mapa de bits que también reside en los metadatos del bloque, así como un hash de las actualizaciones de estado acumulativas
  hasta e incluyendo ese bloque, para detectar una bifurcación del estado.
  A diferencia de los datos del bloque y los campos del encabezado, esta sección no es una entrada para el cálculo del hash del bloque.


## Transacciones

Como hemos visto, una transacción captura cambios en el estado mundial. Vamos a
mirar la estructura detallada de **blockdata** que contiene las transacciones en
un bloque.

![ledger.transaction](./ledger.diagram.5.png) *Detalles de la transacción. La transacción
T4 en blockdata D1 del bloque B1 consiste en un encabezado de transacción, H4, una firma
de transacción, S4, una propuesta de transacción P4, una respuesta de transacción, R4, y una lista
de endosos, E4.*

En el ejemplo anterior, podemos ver los siguientes campos:


* **Encabezado**

  Esta sección, ilustrada por H4, captura algunos metadatos esenciales sobre la
  transacción -- por ejemplo, el nombre del chaincode relevante y su
  versión.


* **Firma**

  Esta sección, ilustrada por S4, contiene una firma criptográfica, creada
  por la aplicación cliente. Este campo se utiliza para verificar que los detalles de la transacción
  no hayan sido alterados, ya que requiere la clave privada de la aplicación para generarla.


* **Propuesta**

  Este campo, ilustrado por P4, codifica los parámetros de entrada suministrados por una
  aplicación al contrato inteligente que crea la propuesta de actualización del libro mayor.
  Cuando el contrato inteligente se ejecuta, esta propuesta proporciona un conjunto de parámetros de entrada, que, en combinación con el estado mundial actual, determina el
  nuevo estado mundial.


* **Respuesta**

  Esta sección, ilustrada por R4, captura los valores antes y después del estado mundial, como un **conjunto de lectura escritura** (RW-set). Es la salida de un contrato inteligente, y si la transacción es validada con éxito, se aplicará al libro mayor para actualizar el estado mundial.

* **Endosos**

  Como se muestra en E4, esta es una lista de respuestas de transacción firmadas por cada
  organización requerida suficiente para satisfacer la política de endoso. Notarás que, mientras que solo se incluye una respuesta de transacción en la transacción, hay múltiples endosos. Eso es porque cada endoso
  codifica efectivamente la respuesta de transacción particular de su organización --
  lo que significa que no hay necesidad de incluir ninguna respuesta de transacción que no
  coincida con los endosos suficientes, ya que será rechazada como inválida y no
  actualizará el estado mundial.

Eso concluye los campos principales de la transacción -- hay otros, pero
estos son los esenciales que necesitas entender para tener un sólido
entendimiento de la estructura de datos del libro mayor.

## Opciones de base de datos para el Estado Mundial

El estado mundial se implementa físicamente como una base de datos, para proporcionar un almacenamiento y recuperación simples y
eficientes de los estados del libro mayor. Como hemos visto, los estados del libro mayor
pueden tener valores simples o compuestos, y para acomodar esto, la implementación de la base de datos del estado mundial puede variar, permitiendo que estos valores se implementen de manera eficiente. Las opciones para la base de datos del estado mundial actualmente incluyen LevelDB y
CouchDB.

LevelDB es la opción predeterminada y es particularmente apropiada cuando los estados del libro mayor son
pares clave-valor simples. Una base de datos LevelDB está co-ubicada con el nodo par -- está incrustada dentro del mismo proceso del sistema operativo.

CouchDB es una elección particularmente apropiada cuando los estados del libro mayor están estructurados
como documentos JSON porque CouchDB soporta las consultas ricas y la actualización de tipos de datos más ricos a menudo encontrados en transacciones comerciales. En términos de implementación, CouchDB
se ejecuta en un proceso del sistema operativo separado, pero todavía hay una relación 1:1
entre un nodo par y una instancia de CouchDB. Todo esto es invisible para un contrato inteligente. Ver [CouchDB como la Base de Datos del Estado](../couchdb_as_state_database.html)
para más información sobre CouchDB.

En LevelDB y CouchDB, vemos un aspecto importante de Hyperledger Fabric -- es
*modificable*. La base de datos del estado mundial podría ser una tienda de datos relacional, o una
tienda de gráficos, o una base de datos temporal. Esto proporciona una gran flexibilidad en los
tipos de estados del libro mayor que pueden ser accedidos de manera eficiente, permitiendo a Hyperledger Fabric abordar muchos tipos diferentes de problemas.

## Ejemplo de Libro Mayor: fabcar

Al finalizar este tema sobre el libro mayor, veamos un ejemplo de libro mayor. Si
has ejecutado la [aplicación de muestra fabcar](../write_first_app.html), entonces has
creado este libro mayor.

La aplicación de muestra fabcar crea un conjunto de 10 autos, cada uno con una identidad única; un
color, marca, modelo y propietario diferentes. Así es como se ve el libro mayor después de que se han creado los primeros cuatro autos.

![ledger.transaction](./ledger.diagram.6.png) *El libro mayor, L, comprende un estado
mundial, W y una blockchain, B. W contiene cuatro estados con claves: CAR0, CAR1, CAR2
y CAR3. B contiene dos bloques, 0 y 1. El bloque 1 contiene cuatro transacciones:
T1, T2, T3, T4.*

Podemos ver que el estado mundial contiene estados que corresponden a CAR0, CAR1,
CAR2 y CAR3. CAR0 tiene un valor que indica que es un Toyota Prius azul,
actualmente propiedad de Tomoko, y podemos ver estados y valores similares para los
otros autos. Además, podemos ver que todos los estados de los autos están en el número de versión 0,
indicando que este es su número de versión inicial -- no han sido
actualizados desde que fueron creados.

También podemos ver que la blockchain contiene dos bloques. El bloque 0 es el bloque génesis,
aunque no contiene ninguna transacción relacionada con autos. Sin embargo, el bloque 1
contiene transacciones T1, T2, T3, T4 y estas corresponden a
transacciones que crearon los estados iniciales para CAR0 a CAR3 en el estado
mundial. Podemos ver que el bloque 1 está vinculado al bloque 0.

No hemos mostrado los otros campos en los bloques o transacciones, específicamente
encabezados y hashes. Si estás interesado en los detalles precisos de estos,
encontrarás un tema de referencia dedicado en otra parte de la documentación. Te da
un ejemplo completamente trabajado de un bloque entero con sus transacciones en glorioso
detalle -- pero por ahora, has logrado un sólido entendimiento conceptual de un
libro mayor de Hyperledger Fabric. ¡Bien hecho!

## Espacios de Nombres

Aunque hemos presentado el libro mayor como si fuera un único estado mundial
y una única blockchain, eso es un poco de simplificación. En
realidad, cada chaincode tiene su propio estado mundial que está separado de todos los demás
chaincodes. Los estados mundiales están en un espacio de nombres para que solo los contratos inteligentes dentro
del mismo chaincode puedan acceder a un espacio de nombres dado.

Una blockchain no está dividida por espacios de nombres. Contiene transacciones de muchos diferentes
espacios de nombres de contratos inteligentes. Puedes leer más sobre los espacios de nombres de chaincode en este
[tema](../developapps/chaincodenamespace.html).

Ahora veamos cómo se aplica el concepto de un espacio de nombres dentro de un canal de Hyperledger
Fabric.

## Canales

En Hyperledger Fabric, cada [canal](../channels.html) tiene un libro mayor completamente
separado. Esto significa una blockchain completamente separada, y estados mundiales completamente
separados, incluyendo espacios de nombres. Es posible para las aplicaciones y
contratos inteligentes comunicarse entre canales para que la información del libro mayor pueda
ser accedida entre ellos.

Puedes leer más sobre cómo funcionan los libros mayores con los canales en este
[tema](../developapps/chaincodenamespace.html#channels).


## Más información

Consulta los temas de [Flujo de Transacciones](../txflow.html),
[Semántica de Conjunto de Lectura-Escritura](../readwrite.html) y
[CouchDB como la Base de Datos del Estado](../couchdb_as_state_database.html) para una
inmersión más profunda en el flujo de transacciones, control de concurrencia y la base de datos
del estado mundial.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
