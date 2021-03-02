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

Hyperledger Fabric emplea un libro mayor inmutable por cada canal, así como un chaincode que puede manipular y modificar el estado actual de los activos 
(es decir, actualizar los pares clave-valor).  Un libro mayor existe en el ámbito de un canal --- puede ser compartido a través de toda la red (asumiendo 
que cada participante está operando en un canal común) --- o puede ser privado para incluir sólo un conjunto específico de participantes.

En este último caso, estos participantes crearían un canal separado y, por lo tanto, aislarían/segregarían sus transacciones y su libro mayor.  
Para resolver los escenarios que quieren cerrar la brecha entre la transparencia total y la privacidad, el chaincode puede instalarse sólo en pares que 
necesitan acceder a los estados de los activos para realizar lecturas y escrituras (en otras palabras, si no se instala un chaincode en un par, no podrá 
interactuar adecuadamente con el libro mayor).

Cuando un subconjunto de organizaciones de ese canal necesita mantener la confidencialidad de los datos de sus transacciones, 
se utiliza una recopilación de datos privados (recopilación) para segregar esos datos en una base de datos privada, lógicamente 
separada del libro mayor del canal, a la que sólo puede acceder el subconjunto de organizaciones autorizadas.

Así pues, los canales mantienen las transacciones privadas de la red más amplia, mientras que las recopilaciones mantienen los datos 
privados entre subconjuntos de organizaciones del canal.

Para ofuscar aún más los datos, los valores dentro del chaincode pueden ser encriptados (en parte o en total) utilizando algoritmos 
criptográficos comunes como el AES, antes de enviar las transacciones al servicio de ordenamiento y agregar bloques al libro mayor.
Una vez que los datos cifrados se han escrito en el libro mayor, sólo pueden ser descifrados por un usuario en posesión de la llave 
correspondiente que se utilizó para generar el texto cifrado.

Vea el tema :doc:`private-data-arch`  para más detalles sobre cómo lograr la privacidad en su red de cadena de bloques.

Seguridad & Servicio de membresia
------------------------------

Hyperledger Fabric sustenta una red transaccional en la que todos los participantes tienen identidades conocidas.  La Infraestructura 
de Clave Pública se utiliza para generar certificados criptográficos que están vinculados a organizaciones, componentes de red y usuarios 
finales o aplicaciones cliente.  Como resultado de ello, el control de acceso a los datos puede tratarse y regirse en la red en general y en 
el nivel de los canales.  Esta noción "permitida" de Hyperledger Fabric, unida a la existencia y las capacidades de los canales, ayuda a abordar 
las situaciones en que la privacidad y la confidencialidad son preocupaciones primordiales.

Vea el tema :doc:`msp` para entender mejor la criptografía
y el enfoque de firmar, verificar y autentificar usado en Hyperledger Fabric.


Consenso
---------

En la tecnología de libro mayor distribuido, el consenso se ha convertido recientemente en sinónimo de un algoritmo específico, 
dentro de una sola función. Sin embargo, el consenso abarca algo más que el simple acuerdo sobre el orden de las transacciones, 
y esta diferenciación se evidencia en Hyperledger Fabric a través de su papel fundamental en todo el flujo de transacciones, 
desde la propuesta y la aprobación, hasta el orden, la validación y la confirmación.
En pocas palabras, el consenso se define como la verificación de todo el círculo de la veracidad de un conjunto de 
transacciones que comprende un bloque.

El consenso se logra en última instancia cuando el orden y los resultados de las transacciones de un bloque han cumplido con las 
verficaciones de los criterios normativos definidos. Estas comprobaciones tienen lugar durante el ciclo de vida de una transacción 
e incluyen el uso de políticas de endoso para definir qué miembros específicos deben endosar una determinada clase de transacción, 
así como chaincode del sistema para garantizar que estas políticas se apliquen y se mantengan.  Antes de confirmarse, los pares 
emplearán estos chaincodes del sistema para asegurarse de que hay suficientes endosos presentes, y de que éstos se derivan de las 
entidades apropiadas. Además, se realizará una verificación de versiones durante la cual se acuerda o se conviene el estado actual del libro mayor, 
antes de que se adjunte al libro mayor cualquier bloque que contenga transacciones. Esta comprobación final proporciona protección contra 
las operaciones de doble gasto y otros amenazas que podrían comprometer la  integridad de los datos, y permite que las funciones ejecutadas contra variables no estáticas.

Además de la multitud de comprobaciones de respaldo, validez y versiones que se realizan, también se llevan a cabo verificaciones de identidad en todas las direcciones 
del flujo de transacciones.  Las listas de control de acceso se aplican en capas jerárquicas de la red (servicio de ordenamiento hasta los canales), y las cargas útiles s
e firman, verifican y autentican repetidamente a medida que una propuesta de transacción pasa por los diferentes componentes arquitectónicos.  En conclusión, el consenso no 
se limita al orden convenido de un lote de transacciones, sino que se trata de un consenso,
es una caracterización general que se logra como subproducto de las verificaciones en curso que tienen lugar durante el trayecto de una transacción desde la propuesta hasta 
el confirmación.

Vea el diagrama :doc:`txflow` para una representación visual del consenso.

.. Licenciado bajo la licencia internacional Creative Commons Attribution 4.0
   https://creativecommons.org/licenses/by/4.0/
