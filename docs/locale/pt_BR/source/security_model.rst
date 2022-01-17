# Modelo de segurança (Security Model)

O Hyperledger Fabric é um blockchain permissionado em que cada componente e ator tem uma identidade e as políticas definem o controle de acesso e a governança.
Este tópico fornece uma visão geral do modelo de segurança do Fabric e inclui links para informações adicionais. 

## Identidades

Os diferentes atores em uma rede blockchain incluem pares, ordenadores, aplicativos clientes, administradores e muito mais.
Cada um desses atores — elementos ativos dentro ou fora de uma rede capaz de consumir serviços — possui uma identidade digital encapsulada em um certificado digital X.509 emitido por uma Autoridade Certificadora (CA).
Essas identidades são importantes porque determinam as permissões exatas sobre recursos e acesso a informações que os atores têm em uma rede blockchain.

Para obter mais informações, consulte o [tópico de Identidade](./identity/identity.html).

## Provedor de Serviço de Associação (MSP)

Para que uma identidade seja verificável, ela deve vir de uma autoridade confiável.
Um provedor de serviços de associação (MSP) é essa autoridade confiável no Fabric.
Mais especificamente, um MSP é um componente que define as regras que regem as identidades válidas para uma organização.
Um canal do Hyperledger Fabric define um conjunto de MSPs da organização como membros.
A implementação padrão do MSP no Fabric usa certificados X.509 emitidos por uma Autoridade de Certificação (CA) como identidades, adotando um modelo hierárquico tradicional de Infraestrutura de Chave Pública (PKI).
As identidades podem ser associadas a funções dentro de um MSP, como 'cliente' e 'admin', utilizando as funções Node UO.
As funções Node OU podem ser usadas em definições de política para restringir o acesso aos recursos do Fabric para determinados MSPs e funções.

Para obter mais informações, consulte o tópico [Provedor de Serviço de Associação (MSP)](./membership/membership.html).

## Políticas

No Hyperledger Fabric, as políticas são o mecanismo para gerenciamento de infraestrutura.
As políticas do Fabric representam como os membros concordam em aceitar ou rejeitar alterações na rede, em um canal ou em um contrato inteligente.
As políticas são acordadas pelos membros do canal quando o canal é configurado originalmente, mas também podem ser modificadas à medida que o canal evolui.
Por exemplo, eles descrevem os critérios para adicionar ou remover membros de um canal, alteram como os blocos são formados ou especificam o número de organizações necessárias para endossar um contrato inteligente.
Todas essas ações são descritas por uma política que define quem pode realizar a ação.
Simplificando, tudo o que você deseja fazer em uma rede Fabric é controlado por uma política.
Uma vez escritas, as políticas avaliam a coleta de assinaturas anexadas a transações e propostas e validam se as assinaturas atendem à governança acordada pela rede.

As políticas podem ser usadas em Políticas de Canal, Políticas de Modificação de Canal, Listas de Controle de Acesso, Políticas de Ciclo de Vida de Chaincode e Políticas de Endosso de Chaincode.

Para obter mais informações, consulte o [tópico de políticas](./policies/policies.html).

### Políticas do canal 

As políticas na configuração do canal definem várias políticas administrativas e de uso em um canal.
Por exemplo, a política para adicionar uma organização de mesmo nível a um canal é definida no domínio administrativo das organizações de mesmo nível (conhecido como Grupo de Aplicativos).
Da mesma forma, a adição de nós de ordenação no conjunto consenter do canal é controlada por uma política dentro do grupo Orderer.
As ações que cruzam os domínios organizacionais do peer e do orderer estão contidas no grupo de canais.

Para obter mais informações, consulte o [tópico de políticas do canal](./policies/policies.html#how-are-policies-implemented).

### Políticas de modificação do canal

As políticas de modificação especificam o grupo de identidades necessário para assinar (aprovar) qualquer atualização de configuração de canal.
É a política que define como uma política de canal é atualizada.
Assim, cada elemento de configuração de canal inclui uma referência a uma política que rege sua modificação.

Para obter mais informações, consulte o [tópico de políticas de modificação](./policies/policies.html#modification-policies).

### Listas de controle de acesso

As listas de controle de acesso (ACLs) fornecem a capacidade de configurar o acesso aos recursos do canal associando esses recursos às políticas existentes.

Para obter mais informações, consulte o tópico [Access Control Lists (ACLs)](./access_control.html). 

### Política de Ciclo de Vida do Chaincode

O número de organizações que precisam aprovar uma definição de chaincode antes que ela possa ser confirmada com sucesso em um canal é regido pela política de LifecycleEndorsement do canal.

Para obter mais informações, consulte o [tópico do Ciclo de vida do Chaincode](./chaincode_lifecycle.html). 

### Políticas de endosso de Chaincode

Cada contrato inteligente dentro de um pacote chaincode tem uma política de endosso que especifica quantos pares pertencentes a diferentes membros do canal precisam executar e validar uma transação em relação a um determinado contrato inteligente para que a transação seja considerada válida.
Assim, as políticas de endosso definem as organizações (através de seus pares) que devem “endossar” (ou seja, assinar) a execução de uma proposta.

Para obter mais informações, consulte o [tópico de políticas de endosso](./policies/policies.html#chaincode-endorsement-policies). 

## Pares

Os pares são elementos fundamentais da rede porque hospedam livros contábeis e contratos inteligentes.
Os pares têm uma identidade própria e são gerenciados por um administrador de uma organização.

Para obter mais informações, consulte o [tópico Peers and Identity](./peers/peers.html#peers-and-identity) e [tópico Peer Deployment and Administration](./deploypeer/peerdeploy.html). 

## Ordenando nós de serviço (Ordering service nodes)

A solicitação de nós de serviço ordena transações em blocos e depois distribui blocos para peers conectados para validação e confirmação.
Os nós de serviço de pedidos têm uma identidade própria e são gerenciados por um administrador de uma organização.

Para obter mais informações, consulte o [tópico Pedido de nós e identidade](./orderer/ordering_service.html#orderer-nodes-and-identity) e [tópico Pedido de implantação e administração de nós](./deployorderer/ordererdeploy.html). 

## Segurança da camada de transporte (TLS)

O Fabric dá suporte à comunicação segura entre nós usando o Transport Layer Security (TLS).
A comunicação TLS pode usar autenticação unidirecional (somente servidor) e bidirecional (servidor e cliente).

Para obter mais informações, consulte o [tópico TLS (Transport Layer Security)](./enable_tls.html). 

## Peer and Ordering service node operations service

O peer e o ordenador hospedam um servidor HTTP que oferece uma API de “operações” RESTful.
Essa API não está relacionada aos serviços de rede do Fabric e deve ser usada por operadores, não administradores ou “usuários” da rede.

Como o serviço de operações é focado em operações e intencionalmente não relacionado à rede Fabric, ele não usa o Membership Services Provider para controle de acesso.
Em vez disso, o serviço de operações depende inteiramente de TLS mútuo com autenticação de certificado de cliente.

Para obter mais informações, consulte o [tópico do Serviço de Operações](./operations_service.html). 

## Módulos de segurança de hardware

As operações criptográficas realizadas pelos nós do Fabric podem ser delegadas a um Hardware Security Module (HSM).
Um HSM protege suas chaves privadas e lida com operações criptográficas, permitindo que seus pares endossem transações e nós de pedidos assinem blocos sem expor suas chaves privadas.

Atualmente, o Fabric aproveita o padrão PKCS11 para se comunicar com um HSM.

Para obter mais informações, consulte o tópico [Hardware Security Module (HSM)](./hsm.html). 

## Aplicações Fabric

Um aplicativo Fabric pode interagir com uma rede blockchain enviando transações para um livro-razão ou consultando o conteúdo do livro-razão.
Um aplicativo interage com uma rede blockchain usando um dos SDKs do Fabric.

Os SDKs do Fabric v2.x suportam apenas funções de transação e consulta e escuta de eventos.
O suporte para funções administrativas para canais e nós foi removido dos SDKs em favor das ferramentas CLI.

Os aplicativos geralmente residem em uma camada gerenciada da infraestrutura de uma organização.
A organização pode criar identidades de clientes para a organização em geral ou identidades de clientes para usuários finais individuais do aplicativo.
As identidades dos clientes têm permissão apenas para enviar transações e consultar o livro-razão, elas não têm permissões administrativas ou operacionais em canais ou nós.

Em alguns casos de uso, a camada do aplicativo pode persistir as credenciais do usuário, incluindo a chave privada e assinar transações.
Em outros casos de uso, os usuários finais do aplicativo podem querer manter sua chave privada em segredo.
Para oferecer suporte a esses casos de uso, o SDK do Node.js oferece suporte à assinatura offline de transações.
Em ambos os casos, um Módulo de Segurança de Hardware pode ser usado para armazenar chaves privadas, o que significa que o aplicativo cliente não tem acesso a elas.

Independentemente do design do aplicativo, os SDKs não têm nenhum acesso privilegiado a serviços de mesmo nível ou do solicitador além do fornecido pela identidade do cliente.
De uma perspectiva de segurança, os SDKs são apenas um conjunto de funções de conveniência específicas de linguagem para interagir com os serviços gRPC expostos pelos peers e solicitadores do Fabric.
Toda a imposição de segurança é realizada pelos nós do Fabric conforme destacado anteriormente neste tópico, não pelo SDK do cliente.

Para obter mais informações, consulte o [tópico de aplicativos](./developapps/application.html) e [tutorial de assinatura offline](https://hyperledger.github.io/fabric-sdk-node/release-2.2/tutorial-sign-transaction-offline.html).

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
