# Políticas

**Audiencia**: Arquitectos, desarrolladores de aplicaciones y contratos inteligentes,
administradores

En este tema, cubriremos:

* [Qué es una política](#qué-es-una-política)
* [Por qué son necesarias las políticas](#por-qué-son-necesarias-las-políticas)
* [Cómo se implementan las políticas en Fabric](#cómo-se-implementan-las-políticas-en-fabric)
* [Dominios de política de Fabric](#los-dominios-de-política-de-fabric)
* [Cómo escribir una política en Fabric](#cómo-escribir-una-política-en-fabric)
* [Ciclo de vida del chaincode de Fabric](#ciclo-de-vida-del-chaincode-de-fabric)
* [Sobrescribir definiciones de políticas](#sobrescribir-definiciones-de-políticas)

## Qué es una política

En su nivel más básico, una política es un conjunto de reglas que definen la estructura
para cómo se toman las decisiones y se alcanzan resultados específicos. Con ese fin,
las políticas típicamente describen un **quién** y un **qué**, como el acceso o
los derechos que un individuo tiene sobre un **activo**. Podemos ver que las políticas son
utilizadas a lo largo de nuestras vidas diarias para proteger activos de valor para nosotros, desde alquileres de autos, salud, nuestras casas, y muchos más.

Por ejemplo, una póliza de seguro define las condiciones, términos, límites, y
expiración bajo los cuales se realizará un pago del seguro. La póliza es
acordada por el titular de la póliza y la compañía de seguros, y define los derechos
y responsabilidades de cada parte.

Mientras que una póliza de seguro se establece para la gestión de riesgos, en Hyperledger
Fabric, las políticas son el mecanismo para la gestión de infraestructura. Las políticas de Fabric
representan cómo los miembros llegan a un acuerdo sobre aceptar o rechazar cambios en la
red, un canal, o un contrato inteligente. Las políticas son acordadas por los miembros del consorcio
cuando una red es configurada originalmente, pero también pueden ser modificadas
a medida que la red evoluciona. Por ejemplo, describen los criterios para agregar o
eliminar miembros de un canal, cambiar cómo se forman los bloques, o especificar el
número de organizaciones requeridas para respaldar un contrato inteligente. Todas estas
acciones son descritas por una política que define quién puede realizar la acción.
En pocas palabras, todo lo que quieras hacer en una red de Fabric está controlado por una
política.

## Por qué son necesarias las políticas

Las políticas son una de las cosas que hacen a Hyperledger Fabric diferente de otras
blockchains como Ethereum o Bitcoin. En esos sistemas, las transacciones pueden ser
generadas y validadas por cualquier nodo en la red. Las políticas que gobiernan la
red están fijas en cualquier momento y solo pueden ser cambiadas usando el mismo
proceso que gobierna el código. Debido a que Fabric es una blockchain con permisos cuyos
usuarios son reconocidos por la infraestructura subyacente, esos usuarios tienen la
capacidad de decidir sobre la gobernanza de la red antes de que sea lanzada, y
cambiar la gobernanza de una red en funcionamiento.

Las políticas permiten a los miembros decidir qué organizaciones pueden acceder o actualizar una
red de Fabric, y proporcionan el mecanismo para hacer cumplir esas decisiones. Las políticas contienen
las listas de organizaciones que tienen acceso a un recurso dado, como un
usuario o chaincode del sistema. También especifican cuántas organizaciones necesitan estar de acuerdo
en una propuesta para actualizar un recurso, como un canal o contratos inteligentes. Una vez
que están escritas, las políticas evalúan la colección de firmas adjuntas a
transacciones y propuestas y validan si las firmas cumplen con la gobernanza
acordada por la red.

## Cómo se implementan las políticas en Fabric

Las políticas se implementan en diferentes niveles de una red de Fabric. Cada dominio de política
gobierna diferentes aspectos de cómo opera una red.

![policies.policies](./FabricPolicyHierarchy-2.png) *Una representación visual
de la jerarquía de políticas de Fabric.*

### Configuración del canal del sistema

Cada red comienza con un **canal del sistema** de ordenamiento. Debe haber exactamente
un canal del sistema de ordenamiento para un servicio de ordenamiento, y es el primer canal
que se crea. El canal del sistema también contiene las organizaciones que son los
miembros del servicio de ordenamiento (organizaciones de ordenamiento) y aquellas que están
en las redes para realizar transacciones (organizaciones del consorcio).

Las políticas en los bloques de configuración del canal del sistema de ordenamiento gobiernan el
consenso utilizado por el servicio de ordenamiento y definen cómo se crean nuevos bloques.
El canal del sistema también gobierna qué miembros del consorcio están autorizados para
crear nuevos canales.

### Configuración del canal de aplicación

Los _canales_ de aplicación se utilizan para proporcionar un mecanismo de comunicación privado
entre organizaciones en el consorcio.

Las políticas en un canal de aplicación gobiernan la capacidad de agregar o eliminar
miembros del canal. Los canales de aplicación también gobiernan qué organizaciones
son requeridas para aprobar un chaincode antes de que el chaincode sea definido y
comprometido a un canal usando el ciclo de vida del chaincode de Fabric. Cuando un canal de aplicación
se crea inicialmente, hereda todos los parámetros del servicio de ordenamiento
del canal del sistema de ordenamiento por defecto. Sin embargo, esos parámetros (y las
políticas que los gobiernan) pueden ser personalizados en cada canal.

### Listas de control de acceso (ACLs)

Los administradores de red estarán especialmente interesados en el uso de ACLs por parte de Fabric,
que proporcionan la capacidad de configurar el acceso a recursos asociando esos
recursos con políticas existentes. Estos "recursos" podrían ser funciones en el
chaincode del sistema (por ejemplo, "GetBlockByNumber" en el chaincode del sistema "qscc") u otros
recursos (por ejemplo, quién puede recibir eventos de Bloque). Las ACLs se refieren a políticas
definidas en una configuración de canal de aplicación y las extienden para controlar
recursos adicionales. El conjunto predeterminado de ACLs de Fabric es visible en el
archivo `configtx.yaml` bajo la sección `Application: &ApplicationDefaults` pero
pueden y deben ser sobrescritas en un entorno de producción. La lista de
recursos nombrados en `configtx.yaml` es el conjunto completo de todos los recursos internos
actualmente definidos por Fabric.

En ese archivo, las ACLs se expresan usando el siguiente formato:

```
# Política ACL para la invocación de chaincode a chaincode
peer/ChaincodeToChaincode: /Channel/Application/Readers
```

Donde `peer/ChaincodeToChaincode` representa el recurso que está siendo asegurado y
`/Channel/Application/Readers` se refiere a la política que debe ser satisfecha para
que la transacción asociada sea considerada válida.

Para un estudio más profundo sobre las ACLs, refiérase al tema en la Guía de Operaciones sobre [ACLs](../access_control.html).

### Políticas de endoso de contratos inteligentes

Cada contrato inteligente dentro de un paquete de chaincode tiene una política de endoso que
especifica cuántos pares pertenecientes a diferentes miembros del canal necesitan ejecutar
y validar una transacción contra un contrato inteligente dado para que la
transacción sea considerada válida. Por lo tanto, las políticas de endoso definen las
organizaciones (a través de sus pares) que deben "endorzar" (es decir, aprobar) la
ejecución de una propuesta.

### Políticas de modificación

Hay un último tipo de política que es crucial para cómo funcionan las políticas en Fabric,
la `Política de modificación`. Las políticas de modificación especifican el grupo de identidades
requerido para firmar (aprobar) cualquier _actualización_ de configuración. Es la política que
define cómo se actualiza la política. Así, cada elemento de configuración del canal
incluye una referencia a una política que gobierna su modificación.

## Los dominios de política de Fabric

Si bien las políticas de Fabric son flexibles y pueden configurarse para satisfacer las necesidades de una red, la estructura de la política lleva naturalmente a una división entre los dominios
gobernados por las organizaciones del Servicio de Ordenamiento o los miembros del
consorcio. En el siguiente diagrama, puedes ver cómo las políticas predeterminadas
implementan control sobre los dominios de política de Fabric a continuación.

![policies.policies](./FabricPolicyHierarchy-4.png) *Una mirada más detallada a los
dominios de política gobernados por las organizaciones del Ordenador y las organizaciones del consorcio.*

Una red de Fabric completamente funcional puede contar con muchas organizaciones con diferentes
responsabilidades. Los dominios proporcionan la capacidad de extender diferentes privilegios
y roles a diferentes organizaciones al permitir a los fundadores del servicio de ordenamiento la capacidad de establecer las reglas iniciales y la membresía del
consorcio. También permiten a las organizaciones que se unen al consorcio crear
canales de aplicación privados, gobernar su propia lógica de negocio y restringir
el acceso a los datos que se colocan en la red.

La configuración del canal del sistema y una parte de cada configuración del canal de aplicación
proporcionan a las organizaciones de ordenamiento control sobre qué organizaciones
son miembros del consorcio, cómo se entregan los bloques a los canales y el
mecanismo de consenso utilizado por los nodos del servicio de ordenamiento.

La configuración del canal del sistema proporciona a los miembros del consorcio la capacidad
de crear canales. Los canales de aplicación y las ACL son el mecanismo que
las organizaciones del consorcio usan para agregar o eliminar miembros de un canal y restringir
el acceso a los datos y contratos inteligentes en un canal.

## Cómo escribir una política en Fabric

Si quieres cambiar algo en Fabric, la política asociada con el recurso describe **quién** necesita aprobarlo, ya sea con una firma explícita de individuos o una firma implícita por un grupo. En el dominio de seguros, una firma explícita podría ser un solo miembro del grupo de agentes de seguros de hogar. Y una firma implícita sería análoga a requerir la aprobación de una mayoría de los miembros gerenciales del grupo de seguros de hogar. Esto es particularmente útil porque los miembros de ese grupo pueden cambiar con el tiempo sin requerir que la política sea actualizada. En Hyperledger Fabric, las firmas explícitas en las políticas se expresan usando la sintaxis `Signature` y las firmas implícitas usan la sintaxis `ImplicitMeta`.

### Políticas de firma

Las políticas de `Signature` definen tipos específicos de usuarios que deben firmar para que una política sea satisfecha, como `OR('Org1.peer', 'Org2.peer')`. Estas políticas son consideradas las más versátiles porque permiten la construcción de reglas extremadamente específicas como: “Un admin de la org A y otros 2 admins, o 5 de 6 admins de organizaciones”. La sintaxis soporta combinaciones arbitrarias de `AND`, `OR` y `NOutOf`. Por ejemplo, una política puede ser fácilmente expresada usando `AND('Org1.member', 'Org2.member')` lo que significa que se requiere una firma de al menos un miembro en Org1 Y un miembro en Org2 para que la política sea satisfecha.

### Políticas ImplicitMeta

Las políticas `ImplicitMeta` solo son válidas en el contexto de configuración de canal que se basa en una jerarquía escalonada de políticas en un árbol de configuración. Las políticas ImplicitMeta agregan el resultado de políticas más profundas en el árbol de configuración que finalmente son definidas por políticas de Signature. Son `Implicit` porque se construyen implícitamente basadas en las organizaciones actuales en la configuración del canal, y son `Meta` porque su evaluación no es contra principios MSP específicos, sino más bien contra otras sub-políticas debajo de ellas en el árbol de configuración.

El siguiente diagrama ilustra la estructura de política escalonada para un canal de aplicación y muestra cómo se resuelve la política de administradores de configuración de canal `ImplicitMeta`, llamada `/Channel/Admins`, cuando las sub-políticas llamadas `Admins` debajo de ella en la jerarquía de configuración son satisfechas donde cada marca de verificación representa que las condiciones de la sub-política fueron satisfechas.

![policies.policies](./FabricPolicyHierarchy-6.png)

Como puedes ver en el diagrama anterior, las políticas `ImplicitMeta`, Tipo = 3, usan una
sintaxis diferente, `"<ANY|ALL|MAJORITY> <NombreSubPolítica>"`, por ejemplo:
```
`MAJORITY sub policy: Admins`
```
El diagrama muestra una sub-política `Admins`, que se refiere a todas las políticas `Admins`
debajo de ella en el árbol de configuración. Puedes crear tus propias sub-políticas
y nombrarlas como quieras y luego definirlas en cada una de tus
organizaciones.

Como se mencionó anteriormente, un beneficio clave de una política `ImplicitMeta` como `MAYORÍA
Admins` es que cuando agregas una nueva organización administradora al canal, no necesitas
actualizar la política del canal. Por lo tanto, las políticas `ImplicitMeta` se consideran
más flexibles a medida que cambian los miembros del consorcio. El consorcio
en el ordenador puede cambiar a medida que se agregan nuevos miembros o un miembro existente se va
con los miembros del consorcio acordando los cambios, pero no se requieren actualizaciones de políticas. Recuerda que las políticas `ImplicitMeta` finalmente resuelven las
sub-políticas de `Firma` debajo de ellas en el árbol de configuración como
muestra el diagrama.

También puedes definir una política implícita a nivel de aplicación para operar a través de
organizaciones, en un canal por ejemplo, y requerir que CUALQUIERA de ellas
se satisfaga, que TODAS se satisfagan, o que una MAYORÍA se satisfaga. Este
formato se presta a mejores y más naturales valores predeterminados, de modo que cada
organización puede decidir qué significa para un endoso válido.

Se puede lograr una mayor granularidad y control si incluyes [`NodeOUs`](msp.html#organizational-units) en la definición de tu
organización. Las Unidades Organizativas (OUs) se definen en el archivo de configuración del cliente de Fabric CA
y pueden asociarse con una identidad cuando se crea. En Fabric, `NodeOUs` proporciona una manera de clasificar identidades en una jerarquía de certificados digitales. Por ejemplo, una organización con `NodeOUs` específicos habilitados podría requerir que un 'peer' firme para que sea un endoso válido,
mientras que una organización sin ninguno podría simplemente requerir que cualquier miembro pueda
firmar.

## Un ejemplo: política de configuración del canal

Comprender las políticas comienza con examinar el `configtx.yaml` donde se definen las políticas del canal. Podemos usar el archivo `configtx.yaml` en la red de prueba de Fabric para ver ejemplos de ambos tipos de sintaxis de políticas. Vamos a examinar el archivo configtx.yaml utilizado por la muestra [fabric-samples/test-network](https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/test-network/configtx/configtx.yaml) sample.

La primera sección del archivo define las organizaciones de la red. Dentro de cada definición de organización están las políticas predeterminadas para esa organización, `Readers`, `Writers`,
`Admins` y `Endorsement`, aunque puedes nombrar tus políticas como quieras. Cada política tiene un `Type` que describe cómo se expresa la política (`Signature` o `ImplicitMeta`) y una `Rule`.

The test network example below shows the Org1 organization definition in the system
channel, where the policy `Type` is `Signature` and the endorsement policy rule
is defined as `"OR('Org1MSP.peer')"`. This policy specifies that a peer that is
a member of `Org1MSP` is required to sign. It is these signature policies that
become the sub-policies that the ImplicitMeta policies point to.  

El ejemplo de la red de prueba a continuación muestra la definición de la organización Org1 en el canal del sistema, donde el `Type` de política es `Signature` y la regla de política de endoso se define como `"OR('Org1MSP.peer')"`. Esta política especifica que se requiere la firma de un peer que es miembro de `Org1MSP`. Son estas políticas de firma las que se convierten en las sub-políticas a las que apuntan las políticas ImplicitMeta.

<details>
  <summary>
    **Haga clic aquí para ver un ejemplo de una organización definida con directivas de firma**
  </summary>

```
 - &Org1
        # DefaultOrg define la organización que se usa en el sampleconfig
        # del entorno de desarrollo fabric.git
        Nombre: Org1MSP

        # ID para cargar la definición de MSP como
        ID: Org1MSP

        MSPDir: crypto-config/peerOrganizations/org1.example.com/msp

        # Directivas define el conjunto de directivas en este nivel del árbol de configuración
        # Para las políticas de organización, su ruta canónica suele ser
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies:
            Readers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.peer', 'Org1MSP.client')"
            Writers:
                Type: Signature
                Rule: "OR('Org1MSP.admin', 'Org1MSP.client')"
            Admins:
                Type: Signature
                Rule: "OR('Org1MSP.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('Org1MSP.peer')"
```
</details>

El siguiente ejemplo muestra el tipo de política `ImplicitMeta` utilizado en la sección `Application` del `configtx.yaml`. Este conjunto de políticas se encuentra en la ruta `/Channel/Application/`. Si utilizas el conjunto predeterminado de ACLs de Fabric, estas políticas definen el comportamiento de muchas características importantes de los canales de aplicación, como quién puede consultar el libro mayor del canal, invocar un chaincode o actualizar una configuración del canal. Estas políticas apuntan a las sub-políticas definidas para cada organización. La Org1 definida en la sección anterior contiene sub-políticas de `Reader`, `Writer` y `Admin` que son evaluadas por las políticas `ImplicitMeta` de `Reader`, `Writer` y `Admin` en la sección `Application`. Debido a que la red de prueba se construye con las políticas predeterminadas, puedes usar el ejemplo de Org1 para consultar el libro mayor del canal, invocar un chaincode y aprobar actualizaciones del canal para cualquier canal de la red de prueba que crees.

<details>
  <summary>
    **Haga clic aquí para ver un ejemplo de políticas de ImplicitMeta**
  </summary>
```
################################################################################
#
#   SECCIÓN: Aplicación
#
#   - Esta sección define los valores a codificar en una transacción de configuración o
#    bloque de génesis para parámetros relacionados con la aplicación
#
################################################################################
Aplicación: &ApplicationDefaults

    # Organizations es la lista de organizaciones que se definen como participantes en
    # el lado de la aplicación de la red
    Organizaciones:

    # Directivas define el conjunto de directivas en este nivel del árbol de configuración
    # Para las directivas de aplicación, su ruta canónica es
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
```
</details>

## Ciclo de vida del chaincode de Fabric

En la versión 2.0 de Fabric, se introdujo un nuevo proceso de ciclo de vida del chaincode,
donde se utiliza un proceso más democrático para gobernar el chaincode en la red.
El nuevo proceso permite que múltiples organizaciones voten sobre cómo se operará un chaincode antes
de que pueda usarse en un canal. Esto es significativo porque es
la combinación de este nuevo proceso de ciclo de vida y las políticas que se
especifican durante ese proceso lo que dicta la seguridad a través de la red. Más detalles sobre
el flujo están disponibles en el tema de concepto [Ciclo de vida del chaincode de Fabric](../chaincode_lifecycle.html),
pero para los propósitos de este tema, deberías entender cómo se utilizan las políticas en este flujo. El nuevo flujo incluye dos pasos donde se especifican políticas:
cuando el chaincode es **aprobado** por los miembros de la organización, y cuando se **compromete**
al canal.

La sección `Application` del archivo `configtx.yaml` incluye la política de respaldo del ciclo de vida del chaincode predeterminada. En un entorno de producción, personalizarías esta definición para tu propio caso de uso.

```
################################################################################
#
#   SECCIÓN: Aplicación
#
#   - Esta sección define los valores a codificar en una transacción de configuración o
#     bloque de génesis para parámetros relacionados con la aplicación
#
################################################################################
Application: &ApplicationDefaults

    # Organizations es la lista de organizaciones que se definen como participantes en
    # el lado de la aplicación de la red
    Organizaciones:

    # Directivas define el conjunto de directivas en este nivel del árbol de configuración
    # Para las directivas de aplicación, su ruta canónica es
    #   /Channel/Application/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
```

- La política de apoyo a la Flota Fluvial rige quién necesita aprobar un chaincode
definición.
- La política de aprobación por defecto
a chaincode_. Más sobre esto a continuación.

## Políticas de endoso de chaincode

La política de endoso se especifica para un **chaincode** cuando es aprobado
y comprometido con el canal usando el ciclo de vida del chaincode de Fabric (es decir, una
política de endoso cubre todo el estado asociado con un chaincode). La
política de endoso puede especificarse ya sea por referencia a una política de endoso
definida en la configuración del canal o especificando explícitamente una política de Firma.

Si una política de endoso no se especifica explícitamente durante el paso de aprobación,
la política de `Endoso` predeterminada `"MAJORITY Endorsement"` se utiliza, lo que significa
que la mayoría de los pares pertenecientes a los diferentes miembros del canal
(organizaciones) necesitan ejecutar y validar una transacción contra el chaincode
para que la transacción sea considerada válida. Esta política predeterminada permite
que las organizaciones que se unen al canal sean automáticamente añadidas a la política de endoso
del chaincode. Si no quieres usar la política de endoso predeterminada,
usa el formato de política de Firma para especificar una política de endoso más compleja
(como requerir que un chaincode sea endosado por una organización, y
luego por una de las otras organizaciones en el canal).

Las políticas de Firma también te permiten incluir `principales`, que son simplemente una manera
de hacer coincidir una identidad con un rol. Los principales son como identificaciones de usuario o
identificaciones de grupo, pero son más versátiles porque pueden incluir una amplia gama de
propiedades de la identidad de un actor, como la organización del actor,
unidad organizativa, rol o incluso la identidad específica del actor. Cuando hablamos
sobre principales, son las propiedades que determinan sus permisos.
Los principales se describen como 'MSP.ROL', donde `MSP` representa el ID de MSP requerido
(la organización), y `ROL` representa uno de los cuatro roles aceptados:
Miembro, Admin, Cliente y Par. Un rol se asocia a una identidad cuando un usuario
se inscribe con una CA. Puedes personalizar la lista de roles disponibles en tu CA de Fabric.

Algunos ejemplos de principales válidos son:
* 'Org0.Admin': un administrador del MSP Org0
* 'Org1.Member': un miembro del MSP Org1
* 'Org1.Client': un cliente del MSP Org1
* 'Org1.Peer': un par del MSP Org1
* 'OrdererOrg.Orderer': un ordenador en el MSP OrdererOrg

Hay casos en los que puede ser necesario que un estado particular
(un par clave-valor, en otras palabras) tenga una política de endoso diferente.
Este **endoso basado en estado** permite que las políticas de endoso predeterminadas a nivel de chaincode
sean sobrescritas por una política diferente para las claves especificadas.

Para un análisis más profundo sobre cómo escribir una política de endoso, consulta el tema sobre
[Políticas de endoso](../endorsement-policies.html) en la Guía de Operaciones.

**Nota:** Las políticas funcionan de manera diferente dependiendo de qué versión de Fabric estás
  utilizando:
- En las versiones de Fabric anteriores a 2.0, las políticas de endoso de chaincode pueden ser
  actualizadas durante la instanciación del chaincode o utilizando los comandos del ciclo de vida del chaincode. Si no se especifica en el momento de la instanciación, la política de endoso
  predeterminada es “cualquier miembro de las organizaciones en el canal”. Por ejemplo,
  un canal con “Org1” y “Org2” tendría una política de endoso predeterminada de
  “OR(‘Org1.member’, ‘Org2.member’)”.
- A partir de Fabric 2.0, Fabric introdujo un nuevo proceso de ciclo de vida del chaincode
  que permite a múltiples organizaciones acordar cómo se operará un
  chaincode antes de que pueda usarse en un canal. El nuevo proceso
  requiere que las organizaciones acuerden los parámetros que definen un chaincode,
  como el nombre, la versión y la política de endoso del chaincode.

## Sobrescribiendo definiciones de políticas

Hyperledger Fabric incluye políticas predeterminadas que son útiles para comenzar,
desarrollar y probar tu blockchain, pero están destinadas a ser personalizadas
en un entorno de producción. Debes estar al tanto de las políticas predeterminadas
en el archivo `configtx.yaml`. Las políticas de configuración del canal pueden ser extendidas
con verbos arbitrarios, más allá de los predeterminados `Readers, Writers, Admins` en
`configtx.yaml`. Los canales del sistema de ordenamiento y los canales de aplicación son sobrescritos al
emitir una actualización de configuración cuando sobrescribes las políticas predeterminadas editando el
`configtx.yaml` para el canal del sistema de ordenamiento o el `configtx.yaml` para un
canal específico.

Consulta el tema sobre
[Actualizando una configuración de canal](../config_update.html#updating-a-channel-configuration)
para más información.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/) -->