Descoberta de Serviço
=====================

Por que precisamos da descoberta de serviço?
--------------------------------------------

Para executar o chaincode nos pares, submeter transações aos ordenadores e
receber atualizações de status das transações, as aplicações se conectam a uma
API exposta por um SDK.

No entanto, o SDK precisa de muitas informações para permitir que as aplicações
se conectem aos nós de rede pertinentes. Além dos certificados de CA e TLS de
ordenadores e pares do canal - bem como seus endereços IP e números de porta - o
SDK precisa saber as políticas de endosso aplicáveis, assim como quais pares têm
o chaincode instalado (para que a aplicação saiba para quais pares deve enviar
propostas).

Antes da v1.2 essas informações eram codificadas estaticamente. Entretanto, essa
implementação não reage dinamicamente às mudanças na rede (como na inclusão de
novos pares com determinado chaincode instalado, ou quando pares estão
temporariamente offline). Configurações estáticas também não permitem que as
aplicações reajam às mudanças na própria política de endosso (como pode ocorrer
quando uma nova organização entra em um canal).

Além disso, a aplicação cliente não tem como saber quais pares possuem o
livro-razão atualizado e quais ainda não. Como resultado, a aplicação pode
enviar propostas a pares cujos dados do livro-razão não estão sincronizados com
o restante da rede, resultando na invalidação da transação na fase de
confirmação e, consequentemente, no desperdício de recursos.

O **serviço de descoberta** melhora esse processo fazendo com que os pares
computem as informações necessárias dinamicamente e as apresentem ao SDK de
forma digerível.

Como a descoberta de serviço funciona no Fabric
-----------------------------------------------

A aplicação é inicializada com a informação do grupo de pares que são de
confiança do desenvolvedor/administrador da aplicação para fornecer respostas
legítimas às solicitações de descoberta. Um bom par candidato a ser usado pela
aplicação cliente é um que pertença à sua própria organização. Observe que para
que os pares sejam conhecidos pelo serviço de descoberta, eles devem ter um
``EXTERNAL_ENDPOINT`` definido. Para saber como fazer isso, veja a documentação
do :doc:`discovery-cli`.

A aplicação envia uma consulta de configuração para o serviço de descoberta e
obtém todas as informações estáticas que, de outra forma, seriam necessárias
para se comunicar com os demais nós da rede. Essas informações podem ser
atualizadas a qualquer momento, enviando consultas subsequentes ao serviço de
descoberta de um par.

O serviço é executado nos pares - não na aplicação - e usa as informações de
metadados da rede mantidas pela camada de comunicação do gossip para descobrir
quais pares estão online. Também busca informações, como as políticas de endosso
válidas, do banco de dados de estado do par.

Com a descoberta de serviço, as aplicações não precisam mais especificar de
quais pares elas precisam de endossos. O SDK pode simplesmente enviar uma
consulta para o serviço de descoberta perguntando quais pares são necessários
para um dado canal e um ID de chaincode. O serviço de descoberta irá então
computar um descritor composto por dois objetos:

1. **Layouts**: uma lista de grupos de pares e a quantidade correspondente de
   pares de cada grupo que devem ser selecionados.
2. **Mapeamento de grupo para par**: dos grupos nos layouts para os pares do
   canal. Na prática, cada grupo provavelmente seria de pares que representam
   organizações individuais, mas como a API do serviço é genérica e desconhece 
   as organizações, isso é apenas um "grupo".

A seguir há um exemplo de um descritor gerado a partir da avaliação de uma
política ``AND(Org1, Org2)`` onde há dois pares em cada organização.

.. code-block:: JSON

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

Em outras palavras, essa política de endosso requer a assinatura de um par da
Org1 e de um par da Org2. E fornece os nomes dos pares disponíveis nessas orgs
que podem endossar (``peer0`` e ``peer1`` em ambas Org1 e Org2).

O SDK então seleciona aleatoriamente um layout da lista. No exemplo acima, a
política de endosso é Org1 ``AND`` Org2. Se, em vez disso, fosse uma política
``OR``, o SDK selecionaria aleatoriamente a Org1 ou a Org2, já que uma
assinatura de um peer de qualquer uma das orgs satisfaria a política.

Depois que o SDK selecionou um layout, ele seleciona os pares do layout com base
em critérios especificados no lado do cliente (o SDK consegue fazer isso porque
tem acesso a metadados, como a altura do livro-razão). Por exemplo, ele pode
preferir pares com livros-razão mais atuais que outros - ou excluir pares que a
aplicação descobriu que estão offline - de acordo com o número de pares de
cada grupo no layout. Se, com base nos critérios, não há somente "um" par
preferido, o SDK selecionará aleatoriamente dentre os pares que melhor atendem
aos critérios.

Capacidades do serviço de descoberta
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

O serviço de descoberta pode responder às seguintes consultas:

* **Consulta de configuração**: Retorna o ``MSPConfig`` de todas as organizações
  no canal, junto com os endpoints dos ordenadores do canal.
* **Consulta de associação de pares**: Retorna os pares que participam do canal.
* **Consulta de endosso**: Retorna um descritor de endosso para um dado
  chaincode do canal.
* **Consulta local de associação do par**: Retorna as informações locais de
  associação do par que responde à consulta. Por padrão, o cliente precisa ser
  um administrador para o par responder a essa consulta.

Requisitos especiais
~~~~~~~~~~~~~~~~~~~~
Quando o par estiver executando com o
TLS ativado o cliente deve fornecer um certificado de TLS para se conectar a
ele. Se o par não estiver configurado para verificar os certificados do cliente
(clientAuthRequired está false), esse certificado TLS pode ser auto-assinado.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
