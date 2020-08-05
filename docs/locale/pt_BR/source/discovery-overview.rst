Serviço de Localização
======================

.. _why-do-we-need-service-discovery:

Por que precisamos de um serviço de localização?
------------------------------------------------

Para executar o chaincode nos nós pares, enviar transações aos ordenadores e ser atualizado sobre o status das transações, os aplicativos se
conectam a uma API exposta por um SDK.

No entanto, o SDK precisa de muitas informações para permitir que os aplicativos se conectem aos nós de rede relevantes. Além dos
certificados CA e TLS dos ordenadores e pares no canal --- assim como seus endereços IP e números de porta --- ele deve conhecer as
políticas de endosso relevantes, bem como quais pares têm o chaincode instalado (para que o aplicativo saiba para quais pares enviar
propostas de chaincode).

Antes da v1.2, essas informações eram codificadas estaticamente. No entanto, essa implementação não é dinamicamente reativa a alterações na
rede (como a adição de pares que instalaram o chaincode relevante ou pares que estão temporariamente off-line). As configurações estáticas
também não permitem que os aplicativos reajam às alterações da própria política de endosso (como pode acontecer quando uma nova organização
ingressa em um canal).

Além disso, o aplicativo cliente não tem como saber quais pares possuem registros atualizados e quais não. Como resultado, o aplicativo pode
enviar propostas aos pares cujos dados do livro-razão não estão sincronizados com o restante da rede, resultando na invalidação da transação
na confirmação e no desperdício de recursos como consequência.

O **serviço de localização** aprimora esse processo fazendo com que os pares calculem dinamicamente as informações necessárias e as
apresentem ao SDK de maneira consumível.

.. _how-service-discovery-works-in-fabric:

Como o serviço de localização funciona na Fabric
------------------------------------------------

O aplicativo é inicializado sabendo ​​pelo desenvolvedor/administrador do aplicativo sobre um grupo de pares confiáveis para fornecer
respostas autênticas às consultas de localização. Um bom candidato a ser usado pelo aplicativo cliente é aquele que está na mesma
organização. Observe que, para que os pares sejam conhecidos pelo serviço de localização, eles devem ter um ``EXTERNAL_ENDPOINT`` definido.
Para ver como fazer isso, consulte nossa documentação :doc:`discovery-cli`.

O aplicativo emite uma consulta de configuração para o serviço de localização e obtém todas as informações estáticas necessárias para se
comunicar com o restante dos nós da rede. Essas informações podem ser atualizadas a qualquer momento enviando uma consulta subsequente ao
serviço de localização de um nó par.

O serviço é executado nos pares --- não no aplicativo --- e usa as informações de metadados da rede mantidas pela camada de comunicação de
gossip para descobrir quais pares estão online. Ele também busca informações, como quaisquer políticas de endosso relevantes, no banco de
dados de estado do par.

Com o serviço de localização, os aplicativos não precisam mais especificar de quais pares eles precisam de endossos. O SDK pode simplesmente
enviar uma consulta ao serviço de localização perguntando quais são os pares necessários, dado um canal e um ID de chaincode. O serviço de
localização calculará um descritor composto por dois objetos:

1. **Layouts**: uma lista de grupos de pares e uma quantidade correspondente de pares de cada grupo que deve ser selecionado.
2. **Mapeamento de grupo de pares**: dos grupos nos layouts aos pontos do canal. Na prática, cada grupo provavelmente seria pares que
   representam organizações individuais, mas como a API de serviço é genérica e ignora as organizações, esse é apenas um "grupo".

A seguir, é apresentado um exemplo de descritor da avaliação de uma política de ``AND(Org1, Org2)``, onde há dois pares em cada uma das
organizações.

.. code-block::JSON

   Layouts: [
        QuantitiesByGroup: {
          “Org1”: 1,
          “Org2”: 1,
        }
   ],
   EndorsersByGroups: {
     “Org1”: [peer0.org1, peer1.org1],
     “Org2”: [peer0.org2, peer1.org2]
   }

Em outras palavras, a política de endosso requer a assinatura de um par na Org1 e um no Org2. E fornece os nomes dos pares disponíveis nas
organizações que podem endossar (``peer0`` e ``peer1`` nos Org1 e Org2).

O SDK seleciona um layout aleatório da lista. No exemplo acima, a política de endosso é Org1 ``AND`` Org2. Se, em vez disso, fosse uma
política ``OR``, o SDK selecionaria aleatoriamente Org1 ou Org2, já que uma assinatura de um par de qualquer uma dessas Org atenderia a
política.

Depois que o SDK seleciona um layout, ele seleciona os pares no layout com base em um critério especificado no lado do cliente (o SDK pode
fazer isso porque tem acesso a metadados, como o tamanho do livro-razão). Por exemplo, ele pode preferir pares com livro-razão maiores que
outros --- ou excluir pares que o aplicativo descobrir estar offline --- de acordo com o número de pares de cada grupo no layout. Se nenhum
par único for preferível com base nos critérios, o SDK selecionará aleatoriamente dentre os pares que melhor atendem aos critérios.

.. _capabilities-of-the-discovery-service:

Recursos do serviço de localização
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

O serviço de localização pode responder às seguintes consultas:

* **Consulta de configuração**: retorna o ``MSPConfig`` de todas as organizações no canal, juntamente com os endereços dos ordenadores
  do canal.
* **Consulta à associação de pares**: retorna os pares que ingressaram no canal.
* **Consulta de endosso**: retorna um descritor de endosso para o(s) chaincode(s) especificado(s) em um canal.
* **Consulta de associação de pares local**: Retorna as informações de associação do par local que responde à consulta. Por padrão, o
  cliente precisa ser um administrador para que o par responda a essa consulta.

.. _special-requirements:

Requisitos especiais
~~~~~~~~~~~~~~~~~~~~
Quando o nó está em execução com o TLS ativado, o cliente deve fornecer um certificado TLS ao conectar-se ao nó. Se o par não estiver
configurado para verificar os certificados do cliente (`clientAuthRequired` é `false`), esse certificado TLS poderá ser autoassinado.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
