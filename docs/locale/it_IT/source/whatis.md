# Introducción

En términos generales, una blockchain (cadena de bloques) es un libro de transacciones inmutable, mantenido
dentro de una red distribuida de _nodos pares_. Cada uno de estos nodos mantiene una copia
del libro mayor aplicando transacciones que han sido validadas por un _protocolo de consenso_, agrupadas en bloques que incluyen un hash que vincula cada bloque al bloque precedente.

La primera y más reconocida aplicación de blockchain es la
criptomoneda [Bitcoin](https://en.wikipedia.org/wiki/Bitcoin), aunque otras
han seguido sus pasos. Ethereum, una criptomoneda alternativa, tomó un
enfoque diferente, integrando muchas de las mismas características que Bitcoin pero
agregando _contratos inteligentes_ para crear una plataforma para aplicaciones distribuidas.
Bitcoin y Ethereum pertenecen a una clase de blockchain que clasificaríamos como
Tecnología blockchain _pública sin permiso_. Básicamente, se trata de redes públicas, abiertas a cualquier persona, donde los participantes interactúan de forma anónima.

A medida que creció la popularidad de Bitcoin, Ethereum y algunas otras tecnologías derivadas, también creció el interés en aplicar la tecnología subyacente de la blockchain, el libro mayor distribuido y la plataforma de aplicaciones distribuidas a casos de uso de _empresas_ más innovadores.

Sin embargo, muchos casos de uso empresarial requieren características de funcionamiento que las tecnologías blockchain sin permiso son
incapaces (actualmente) de realizar. Además, en muchos casos de uso, la identidad de los participantes es un requisito estricto, como en el caso de transacciones financieras donde se deben seguir las regulaciones Conozca a su cliente (KYC) y Anti-Lavado de dinero (AML).

Para uso empresarial, debemos considerar los siguientes requisitos:

- Los participantes deben estar identificados / identificables
- Las redes deben tener _permiso_
- Alto rendimiento de producción de transacciones
- Baja latencia de la confirmación de la transacción
- Privacidad y confidencialidad de transacciones y datos relacionados con transacciones comerciales.

Mientras que muchas de las primeras plataformas blockchain están siendo
_adaptadas_ para uso empresarial, Hyperledger Fabric ha sido _diseñada_ para
uso empresarial desde el principio. En las siguientes secciones se describe
la forma en que Hyperledger Fabric (Fabric) se diferencia de otras plataformas
blockchain y algunas de las motivaciones de sus decisiones arquitectónicas.

## Hyperledger Fabric

Hyperledger Fabric es una plataforma de tecnología de libro mayor distribuido (DLT) de código abierto y de grado empresarial, diseñada para su uso en contextos empresariales, que ofrece algunas capacidades de diferenciación clave sobre otras plataformas populares de contabilidad distribuida o blockchain.

Un punto clave de diferenciación es que Hyperledger se estableció bajo la Fundación Linux, que a su vez tiene una historia larga y muy exitosa de nutrir proyectos de código abierto bajo **gobierno abierto** que hacen crecer comunidades sólidas y sostenibles y ecosistemas prósperos. Hyperledger está gobernado por un comité directivo técnico diverso, y el proyecto Hyperledger Fabric por un conjunto diverso de mantenedores de múltiples organizaciones. Tiene un desarrollo
comunidad que ha crecido a más de 35 organizaciones y casi 200 desarrolladores desde sus primeros códigos.

Fabric tiene una arquitectura altamente **modular** y **configurable**, que permite la innovación, la versatilidad y la optimización para una amplia gama de casos de uso de la industria, incluidos banca, finanzas, seguros, atención médica, recursos humanos, cadena de suministro e incluso entrega de música digital.

Fabric es la primera plataforma de contabilidad distribuida que admite **contratos inteligentes creados en lenguajes de programación de uso general** como Java, Go y Node.js, en lugar de lenguajes específicos de dominio restringidos (DSL). Esto significa que la mayoría de las empresas ya tienen las habilidades necesarias para desarrollar contratos inteligentes y no se necesita capacitación adicional para aprender un nuevo idioma o DSL.

La plataforma Fabric también es **permisionada**, lo que significa que, a diferencia de una red pública sin permiso, los participantes se conocen entre sí, en lugar de ser anónimos y, por lo tanto, no se confía en absoluto. Esto significa que, si bien los participantes pueden no confiar _completamente_ entre sí (pueden, por ejemplo, ser competidores en la misma industria), una red puede operarse bajo un modelo de gobernanza que se basa en que la confianza _existe_ entre los participantes, como un acuerdo legal o marco para manejar disputas.

Uno de los diferenciadores más importantes de la plataforma es su compatibilidad con **protocolos de consenso conectables** que permiten que la plataforma se personalice de manera más eficaz para adaptarse a casos de uso particulares y modelos de confianza. Por ejemplo, cuando se implementa dentro de una sola empresa, o es operado por una autoridad confiable, el consenso totalmente bizantino tolerante a fallas puede considerarse innecesario y un lastre excesivo para el rendimiento y el rendimiento. En situaciones
como ese, un [crash fault-tolerant](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT) protocolo de consenso podría ser más que adecuado, mientras que, en un caso de uso descentralizado de múltiples partes, un protocolo más tradicional
[tolerante a fallos bizantinos](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance) (BFT) podría ser necesario un protocolo de consenso.

Fabric puede aprovechar los protocolos de consenso que **no requieren una criptomoneda nativa** para incentivar la minería costosa o impulsar la ejecución de contratos inteligentes.
Evitar una criptomoneda reduce algunos vectores de riesgo / ataque significativos, y la ausencia de operaciones de minería criptográfica significa que la plataforma se puede implementar con aproximadamente el mismo costo operativo que cualquier otro sistema distribuido.

La combinación de estas características diferenciadoras de diseño convierte a Fabric en una de las **plataformas de mejor rendimiento** disponibles en la actualidad tanto en términos de procesamiento de transacciones como de latencia de confirmación de transacciones, y permite **privacidad y confidencialidad** de transacciones y los contratos inteligentes (lo que Fabric llama "chaincode") que los implementan.

Exploremos estas características diferenciadoras con más detalle.

## Modularidad

Hyperledger Fabric ha sido diseñado específicamente para tener una arquitectura modular. Ya sea por consenso conectable, protocolos de administración de identidad conectables como LDAP u OpenID Connect, protocolos de administración de claves o bibliotecas criptográficas, la plataforma se ha diseñado desde su concepción para ser configurada para cumplir con la diversidad de requisitos de casos de uso empresarial.

A un alto nivel, Fabric se compone de los siguientes componentes modulares:

- Un _servicio de ordenamiento_ conectable establece un consenso sobre el orden de las transacciones y luego transmite los bloques a los pares.
- Un _proveedor de servicios de membresía_ conectable es responsable de asociar entidades en la red con identidades criptográficas.
- Un _peer-to-peer gossip service_ opcional distribuye la salida de los bloques solicitando el servicio a otros compañeros.
- Los contratos inteligentes ("chaincode") se ejecutan dentro de un entorno de contenedor (por ejemplo, Docker) para el aislamiento. Se pueden escribir en lenguajes de programación estándar, pero no tienen acceso directo al estado del libro mayor.
- El libro mayor se puede configurar para admitir una variedad de DBMS.
- Aplicación de políticas de validación y respaldo conectable que se puede configurar de forma independiente por aplicación.

Existe un acuerdo justo en la industria de que no existe "una blockchain para gobernarlos a todos". Hyperledger Fabric se puede configurar de varias formas para satisfacer los diversos requisitos de la solución para múltiples casos de uso de la industria.

## Blockchains Con permiso vs Sin permiso

En una blockchain sin permiso, prácticamente cualquier persona puede participar, y cada participante es anónimo. En tal contexto, no puede haber otra confianza que el estado de la blockchain, antes de una cierta profundidad, es inmutable. Para mitigar esta falta de confianza, los blockchains sin permiso suelen emplear una criptomoneda nativa "minada" o tarifas de transacción para proporcionar un incentivo económico para compensar los costos extraordinarios de participar en una forma de consenso bizantino tolerante a fallas basado en una "prueba de trabajo" (PoW ).

Los blockchains **con permisos**, por otro lado, operan una blockchain entre un conjunto de participantes conocidos, identificados y a menudo examinados que operan bajo un modelo de gobierno que genera un cierto grado de confianza. Una blockchain autorizada proporciona una forma de asegurar las interacciones entre un grupo de entidades que tienen un objetivo común pero que pueden no confiar plenamente entre sí. Al confiar en las identidades de los participantes, una blockchain autorizada puede utilizar protocolos de consenso más tradicionales tolerantes a fallas de choque (CFT) o tolerantes a fallas bizantinas (BFT) que no requieren una minería costosa.

Además, en un contexto tan controlado, el riesgo de un participante se reduce la introducción intencional de código malicioso a través de un contrato inteligente.
Primero, los participantes se conocen entre sí y todas las acciones, ya sea enviar transacciones de aplicaciones, modificar la configuración de la red o implementar un contrato inteligente, se registran en la blockchain siguiendo una política de respaldo que se estableció para la red y el tipo de transacción relevante. En lugar de ser completamente anónimo, la parte culpable puede identificarse fácilmente y el incidente manejarse de acuerdo con los términos del modelo de gobierno.

## Contratos Inteligentes

Un contrato inteligente, o lo que Fabric llama "chaincode", funciona como una aplicación distribuida confiable que obtiene su seguridad / confianza de la blockchain y del consenso subyacente entre los pares. Es la lógica empresarial de una aplicación blockchain.

Hay tres puntos clave que se aplican a los contratos inteligentes, especialmente cuando se aplican a una plataforma:

- muchos contratos inteligentes se ejecutan simultáneamente en la red,
- pueden desplegarse dinámicamente (en muchos casos por cualquier persona), y
- el código de la aplicación debe tratarse como no confiable, incluso potencialmente malicioso.

La mayoría de las plataformas blockchain con capacidad para contratos inteligentes siguen una
arquitectura de **orden-ejecución** en la que el protocolo de consenso:

- valida y ordena las transacciones y luego las propaga a todos los nodos pares,
- cada par luego ejecuta las transacciones secuencialmente.

La arquitectura de ejecución de órdenes se puede encontrar en prácticamente todos los sistemas blockchain existentes, que van desde plataformas públicas / sin permisos como [Ethereum](https://ethereum.org/) (con consenso basado en PoW) hasta plataformas permisionadas como [Tendermint ](http://tendermint.com/), [Chain](http://chain.com/) y [Quorum](http://www.jpmorgan.com/global/Quorum).

Los contratos inteligentes que se ejecutan en una blockchain que opera con la arquitectura de ejecución de órdenes deben ser deterministas; de lo contrario, es posible que nunca se llegue a un consenso.
Para abordar el problema del no determinismo, muchas plataformas requieren que los contratos inteligentes se escriban en un lenguaje no estándar o específico del dominio (como [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) para que se puedan eliminar las operaciones no deterministas. Esto dificulta la difusión
adopción porque requiere que los desarrolladores escriban contratos inteligentes para aprender un nuevo lenguaje y puede conducir a errores de programación.

Además, dado que todas las transacciones se ejecutan secuencialmente por todos los nodos,
el rendimiento y la escala son limitados. El hecho de que el código de contrato inteligente se ejecute en cada nodo del sistema exige que se tomen medidas complejas para proteger el sistema en general de contratos potencialmente maliciosos a fin de garantizar la resistencia del sistema en general.

## Un nuevo enfoque

Fabric presenta una nueva arquitectura para transacciones que llamamos **ejecutar-ordenar-validar**. Aborda los desafíos de resiliencia, flexibilidad, escalabilidad, rendimiento y confidencialidad que enfrenta el modelo de ejecución de órdenes al separar el flujo de transacciones en tres pasos:

- _ejecutar_ una transacción y comprobar su corrección, refrenándola,
- _ordenar_ transacciones a través de un protocolo de consenso (conectable), y
- _validar_ transacciones contra una política de endoso específica de la aplicación antes de confirmarlas en el libro mayor

Este diseño se aparta radicalmente del paradigma de ejecución de órdenes en el que Fabric ejecuta transacciones antes de llegar a un acuerdo final sobre su orden.

En Fabric, una política de respaldo específica de la aplicación indica qué nodos pares, o cuántos de ellos, deben responder por la ejecución correcta de un contrato inteligente determinado. Por lo tanto, cada transacción solo necesita ser ejecutada (respaldada) por el subconjunto de nodos pares necesarios para satisfacer la política de aprobación de la transacción. Esto permite la ejecución en paralelo aumentando el rendimiento general y la escala del sistema. Esta primera fase también **elimina cualquier no determinismo**, ya que los resultados inconsistentes pueden filtrarse antes de realizar el pedido.

Debido a que hemos eliminado el no determinismo, Fabric es la primera tecnología blockchain que **permite el uso de lenguajes de programación estándar**.

## Privacidad y Confidencialidad

Como hemos comentado, en una red blockchain pública sin permisos que aprovecha PoW para su modelo de consenso, las transacciones se ejecutan en cada nodo.
Esto significa que tampoco puede haber confidencialidad de los contratos.
ellos mismos, ni de los datos de transacciones que procesan. Cada transacción, y el código que la implementa, es visible para todos los nodos de la red. En este caso, hemos cambiado la confidencialidad del contrato y los datos por un consenso bizantino tolerante a fallas entregado por PoW.

Esta falta de confidencialidad puede ser problemática para muchos casos de uso empresarial / empresarial. Por ejemplo, en una red de socios de la cadena de suministro, a algunos consumidores se les pueden dar tarifas preferenciales como un medio para solidificar una relación o promover ventas adicionales. Si cada participante puede ver cada contrato y transacción, se vuelve imposible mantener tales relaciones comerciales en una red completamente transparente --- ¡todos querrán las tarifas preferidas!

Como segundo ejemplo, considere la industria de valores, donde un comerciante que está construyendo una posición (o deshaciéndose de una) no querría que sus competidores se enteraran de esto, o de lo contrario buscarían entrar en el juego, debilitando la táctica del comerciante.

Para abordar la falta de privacidad y confidencialidad con el fin de cumplir con los requisitos de casos de uso empresarial, las plataformas blockchain han adoptado una variedad de enfoques. Todos tienen sus compensaciones.

La encriptación de datos es un método para brindar confidencialidad; sin embargo, en una red sin permisos que aprovecha PoW para su consenso, los datos cifrados se encuentran en cada nodo. Con suficiente tiempo y recursos computacionales, el cifrado podría romperse. Para muchos casos de uso empresarial, el riesgo de que su información se vea comprometida es inaceptable.

Las pruebas de conocimiento cero (ZKP) son otra área de investigación que se está explorando para abordar este problema, y ​​la compensación aquí es que, en la actualidad, calcular un ZKP requiere un tiempo y recursos computacionales considerables. Por lo tanto, la compensación en este caso es el desempeño por la confidencialidad.

En un contexto autorizado que puede aprovechar formas alternativas de consenso, se podrían explorar enfoques que restrinjan la distribución de información confidencial exclusivamente a los nodos autorizados.

Hyperledger Fabric, al ser una plataforma autorizada, permite la confidencialidad a través de su arquitectura de canales y la función [datos privados](./privados-datos/privados-datos.html). En los canales, los participantes de una red de Fabric establecen una subred donde cada miembro tiene visibilidad de un conjunto particular de transacciones. Así, solo aquellos nodos que participan en un canal tienen acceso al contrato inteligente (chaincode) y a los datos transados, preservando la privacidad y confidencialidad de ambos. Los datos privados permiten recopilaciones entre miembros en un canal, lo que permite gran parte de la misma protección que los canales sin la sobrecarga de mantenimiento de crear y mantener un canal separado.

## Consenso conectable

El orden de las transacciones se delega a un componente modular de consenso que está lógicamente desacoplado de los pares que ejecutan las transacciones y mantienen el libro mayor. En concreto, el servicio de ordenamiento. Dado que el consenso es modular, su implementación se puede adaptar al supuesto de confianza de una implementación o solución en particular. Esta arquitectura modular permite que la plataforma se base en conjuntos de herramientas bien establecidos para pedidos CFT (tolerante a fallas de choque) o BFT (tolerante a fallas bizantino).

Fabric ofrece actualmente una implementación de servicio de ordenamiento CFT
basado en la [biblioteca `etcd`](https://coreos.com/etcd/) del [protocolo Raft](https://raft.github.io/raft.pdf).
Para obtener información sobre los servicios de pedidos disponibles actualmente, consulte
nuestra [documentación conceptual sobre pedidos](./orderer/ordering_service.html).

Tenga en cuenta también que estos no son mutuamente excluyentes. Una red Fabric puede tener varios servicios de pedidos que admiten diferentes aplicaciones o requisitos de aplicación.

## Rendimiento y escalabilidad

El rendimiento de una plataforma blockchain puede verse afectado por muchas variables como el tamaño de la transacción, el tamaño del bloque, el tamaño de la red, así como los límites del hardware, etc. El grupo de trabajo Hyperledger Fabric [Performance and Scale](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group) actualmente trabaja en un marco de evaluación comparativa llamado [Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

Se han publicado varios artículos de investigación que estudian y prueban las capacidades de rendimiento de Hyperledger Fabric. El último [Fabric escalado a 20.000 transacciones por segundo](https://arxiv.org/abs/1901.00910).

## Conclusión

Cualquier evaluación seria de las plataformas blockchain debería incluir Hyperledger Fabric en su lista corta.

Combinadas, las capacidades diferenciadoras de Fabric lo convierten en un sistema altamente escalable para blockchains autorizadas que respaldan supuestos de confianza flexibles que permiten que la plataforma admita una amplia gama de casos de uso de la industria que van desde el gobierno hasta las finanzas, la logística de la cadena de suministro, la atención médica, etc. mucho más.

Hyperledger Fabric es el más activo de los proyectos de Hyperledger. La construcción de la comunidad alrededor de la plataforma está creciendo constantemente, y la innovación entregada con cada lanzamiento sucesivo supera con creces a cualquiera de las otras plataformas de blockchain empresariales.

## Reconocimiento

Lo anterior se deriva de la revisión por pares
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
