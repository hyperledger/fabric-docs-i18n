Contribuciones Bienvenidas!
===========================

Damos la bienvenida a las contribuciones a Hyperledger en muchas formas, ¡y siempre hay mucho que hacer!

Lo primero es lo primero, 
`revise el Código de Conducta de Hyperledger <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`_ 
antes de participar. Es importante que mantengamos las cosas en forma civilizada.

.. note:: Si desea contribuir a esta documentación, consulte la :doc:`style_guide`.

Formas de Contribuir
--------------------
Hay muchas formas en las que puede contribuir a Hyperledger Fabric, tanto como usuario como desarrollador.
  
Como usuario:

- `Creando Funcionalidad / Propuesta de Mejora`_
- `Reportando Errores`_
- Ayudando a probar una epica que este por salir en el
  `release roadmap <https://jira.hyperledger.org/secure/Dashboard.jspa?selectPageId=10104>`_.
  Póngase en contacto con el asignado de Epic a través de Jira o en
  `RocketChat <https://chat.hyperledger.org>`_.

Como escritor o desarrollador de información:

- Actualice la documentación utilizando su experiencia con Fabric y esta documentación para mejorar los temas existentes y crear otros nuevos. Un cambio de documentación es una manera fácil de comenzar como colaborador, facilita que otros usuarios comprendan y usen Fabric, y aumenta su historial de contribuciones de código abierto.


- Participe en una traducción de idioma para mantener actualizada la documentación de Fabric en el idioma que elija. La documentación de Fabric está disponible en varios idiomas: inglés, chino, malayalam, español y portugués de Brasil, así que ¿por qué no unirse a un equipo que mantiene actualizada su documentación favorita? Encontrará una comunidad amigable de usuarios, escritores y desarrolladores con quienes colaborar.


- Inicie una nueva traducción de idioma si la documentación de Fabric no está disponible en su idioma. Los equipos brasileños de China, Malayalam, Latinoamerica y Portugal empezaron de esta manera, ¡y tú también puedes! Es más trabajo, ya que tendrás que formar una comunidad de escritores y organizar las contribuciones; pero es realmente gratificante ver la documentación de Fabric disponible en el idioma elegido.

Vaya a  `Contribuyendo documentacion`_ para comenzar su viaje.

Como un desarrollador:

- Si solo tiene un poco de tiempo, considere la posibilidad de realizar una tarea `"help-wanted" <https://jira.hyperledger.org/issues/?filter=10147>`_, vea `Fixing issues and working stories`_.
- Si puede comprometerse con el desarrollo a tiempo completo, proponga una nueva característica (ver `Creando Funcionalidad / Propuesta de Mejora`_) y traiga un equipo para implementarla, o únase a uno de los equipos que trabajan en una epica existente. Si ves una epica que te interesa en el `release roadmap <https://jira.hyperledger.org/secure/Dashboard.jspa?selectPageId=10104>`_, contacte al asignado a la epica a través de Jira o en `RocketChat <https://chat.hyperledger.org/>`__.



Conseguir una cuenta en Linux Foundation
----------------------------------------

Para participar en el desarrollo del proyecto Hyperledger Fabric, necesitará una cuenta de Fundación Linux. Una vez que tenga una LF ID, podrá
acceder a todas las herramientas de la comunidad Hyperledger, incluidas
`Jira issue management <https://jira.hyperledger.org>`__,
`RocketChat <https://chat.hyperledger.org/>`__, and the
`Wiki <https://wiki.hyperledger.org/display/fabric/Hyperledger+Fabric>`__ (para edicion solamente).

Siga los pasos a continuación para crear una cuenta de la Fundación Linux si aún no tiene una.

1. Vaya a `Linux Foundation ID
   website <https://identity.linuxfoundation.org/>`__.

2. Seleccione la opcion ``I need to create a Linux Foundation ID``, y llene el formulario que aparece.

3. Espere unos minutos, luego busque un mensaje de correo electrónico con el asunto:
   "Validate your Linux Foundation ID email".

4. Abra la URL recibida para validar su dirección de correo electrónico.

5. Verifique que su navegador muestre el mensaje
   ``You have successfully validated your e-mail address``.

6. Acceda a `Jira issue management <https://jira.hyperledger.org>`__, o
   `RocketChat <https://chat.hyperledger.org/>`__.

Contribuyendo documentacion
---------------------------

Es una buena idea hacer que su primer cambio sea un cambio de documentación. Es rápido y fácil de hacer, garantiza que tenga una máquina configurada correctamente (incluido el software de prerrequisito requerido) y lo familiariza con el proceso de contribución. Utilice los siguientes temas para ayudarlo a comenzar:

.. toctree::
   :maxdepth: 1

   advice_for_writers
   docs_guide
   international_languages
   style_guide

Gestión del Proyecto
--------------------

Hyperledger Fabric se administra bajo un modelo de gobierno abierto como se describe en nuestro `charter <https://www.hyperledger.org/about/charter>`__. Los proyectos y subproyectos están dirigidos por un conjunto de mantenedores. Los nuevos subproyectos pueden designar un conjunto inicial de mantenedores que serán aprobados por los mantenedores existentes del proyecto de nivel superior cuando el proyecto se apruebe por primera vez.

Mantenedores
~~~~~~~~~~~~

El proyecto Fabric está dirigido por los `mantenedores <https://github.com/hyperledger/fabric/blob/master/MAINTAINERS.md>`__ de nivel superior del proyecto.
Los mantenedores son responsables de revisar y fusionar todos los parches enviados para su revisión, y guían la dirección técnica general del proyecto dentro de las pautas establecidas por el Comité Directivo Técnico de Hyperledger (TSC).

Convertirse en Mantenedor 
~~~~~~~~~~~~~~~~~~~~~~~~~

Los mantenedores del proyecto, de vez en cuando, considerarán agregar un mantenedor, según los siguientes criterios:

- Historial demostrado de revisiones de pull requests (tanto la calidad como la cantidad de revisiones)
- Liderazgo demostrado en el proyecto
- Ayuda demostrada de coordinacion de trabajo del proyecto y los contribuyentes

Un mantenedor existente puede enviar un pull request al `repositorio de mantenedores <https://github.com/hyperledger/fabric/blob/master/MAINTAINERS.md>`__ .
Un Contribuidor designado puede convertirse en Mantenedor mediante la aprobación mayoritaria de la propuesta por parte de los Mantenedores existentes. Una vez aprobado, el conjunto de cambios se fusiona y la persona se agrega al grupo de mantenedores.


Los mantenedores pueden ser removidos por renuncia explícita, por
inactividad (p. ej., 3 meses o más sin comentarios de revisión), o por alguna infracción del `código de conducta <https://wiki.hyperledger.org/community/hyperledger-project-code-of-conduct>`__ o por demostrar constantemente un juicio deficiente. Una remoción propuesta también requiere una aprobación mayoritaria. Un mantenedor retirado por inactividad debe restablecerse luego de una reanudación sostenida de las contribuciones y revisiones (un mes o más) que demuestren un compromiso renovado con el proyecto.

Cadencia de liberación
~~~~~~~~~~~~~~~~~~~~~~



Los mantenedores de Fabric se han decidido por una cadencia de lanzamiento trimestral (aproximadamente). Vea `releases <https://github.com/hyperledger/fabric#releases>`__).
En cualquier momento, habrá una rama de lanzamiento de LTS (soporte a largo plazo) estable, así como la rama principal para las próximas funciones nuevas.
Siga la discusión en el canal #fabric-release en RocketChat.


Creando Funcionalidad / Propuesta de Mejora
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

Reportando Errores
~~~~~~~~~~~~~~~~~~

Si es un usuario y ha encontrado un error, envíe un problema utilizando `JIRA <https://jira.hyperledger.org/secure/Dashboard.jspa?selectPageId=10104>`__.
Antes de crear un nuevo problema de JIRA, intente buscar los elementos existentes para asegurarse de que nadie más lo haya informado anteriormente. Si se ha informado anteriormente, puede agregar un comentario de que también está interesado en que se solucione el defecto.

.. note:: Si el defecto está relacionado con la seguridad, 
         siga el proceso de informe de `errores de seguridad de Hyperledger <https://wiki.hyperledger.org/display/HYP/Defect+Response>`__.

Si no se ha informado anteriormente, puede enviar un PR con un mensaje de confirmación bien documentado que describa el defecto y la solución, o puede crear una nueva JIRA. Intente proporcionar suficiente información para que otra persona pueda reproducir el problema. Uno de los encargados del mantenimiento del proyecto debe responder a su problema dentro de las 24 horas. De lo contrario, agregue un comentario al problema y solicite que sea
revisado. También puede publicar en el canal Hyperledger Fabric relevante en `Chat de Hyperledger <https://chat.hyperledger.org>`__. Por ejemplo, un error de documento debe transmitirse a ``#fabric-documentation``, un error de base de datos a ``#fabric-ledger``, y así sucesivamente ...

Envío de su corrección
~~~~~~~~~~~~~~~~~~~~~~

Si acaba de enviar una JIRA para un error que ha descubierto y le gustaría proporcionar una solución, ¡lo agradeceríamos con mucho gusto! Asigne el problema de JIRA a sí mismo y luego envíe un pull request (PR). Consulte :doc:`github/github` para obtener un flujo de trabajo detallado.

Solucionando incidencias y trabajando historias de usuario
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
