Dados Privados
==============

.. note:: Este tópico pressupõe uma compreensão do conteúdo conceitual da 
          `documentação sobre dados privados <private-data/private-data.html>`_.

.. private-data-collection-definition:

Definição de coleção de dados particulares
------------------------------------------

Uma configuração de coleção contém uma ou mais coleções, cada uma com uma definição de políticas listando as organizações da coleção, bem 
como as propriedades usadas para controlar a disseminação de dados privados no momento do endosso e, opcionalmente, se os dados serão 
removidos.

Começando com o ciclo de vida do chaincode introduzido na Fabric v2.0, a definição de coleção faz parte da definição do chaincode. A coleção 
é aprovada pelos membros do canal e, em seguida, implementada quando a definição do chaincode é confirmada no canal. O arquivo de coleção 
precisa ser o mesmo para todos os membros do canal. Se você estiver usando a CLI do par para aprovar e confirmar a definição de chaincode, 
use a diretiva ``--collections-config`` para especificar o caminho para o arquivo de definição de coleção. Se você estiver usando o Fabric 
SDK para Node.js, visite `Como instalar e iniciar seu chaincode <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-chaincode-lifecycle.html>`_. 
Para usar o `processo de ciclo de vida anterior <https://hyperledger-fabric.readthedocs.io/en/release-1.4/chaincode4noah.html>`_ para 
implantar uma coleção de dados privada, use a diretiva ``--collections-config`` ao 
`instanciar seu chaincode <https://hyperledger-fabric.readthedocs.io/en/latest/commands/peerchaincode.html#peer-chaincode-instantiate>`_.

As definições de coleção são compostas das seguintes propriedades:

* ``name``: Nome da coleção.

* ``policy``: A política de distribuição da coleção de dados privada define quais pares de organizações têm permissão para registrar os dados 
  na coleção expressa usando a sintaxe da política ``Signature``, com cada membro sendo incluído em uma lista de política de assinatura do 
  tipo``OR``. Para dar suporte às transações de leitura/gravação, a política de distribuição de dados privada deve definir um conjunto mais 
  amplo de organizações do que a política de endosso do chaincode, pois os pares devem ter os dados privados para endossar as transações 
  propostas. Por exemplo, em um canal com dez organizações, cinco das organizações podem ser incluídas em uma política de distribuição de 
  coleção de dados privada, mas a política de endosso pode exigir que três das organizações endossem.

* ``requiredPeerCount``: número mínimo de pares (entre organizações autorizadas) para os quais cada parceiro endossante deve disseminar com 
  êxito dados privados antes que o par assine o endosso e retorne a resposta da proposta ao cliente. Exigir a disseminação como condição de 
  endosso garantirá que dados privados estejam disponíveis na rede, mesmo que os pares endossantes fiquem indisponíveis. Quando 
  ``requiredPeerCount`` é ``0``, significa que nenhuma distribuição é **necessária**, mas pode haver alguma distribuição se ``maxPeerCount`` 
  for maior que zero. Normalmente, um ``requiredPeerCount`` de ``0`` não seria recomendado, pois poderia levar à perda de dados privados na 
  rede se o(s) par(es) endossante(s) ficar(em) indisponível(is). Normalmente, você deseja exigir pelo menos alguma distribuição dos dados 
  privados no momento do endosso, para garantir a redundância dos dados privados em vários pares da rede.

* ``maxPeerCount``: Para fins de redundância de dados, o número máximo de outros pares (entre organizações autorizadas) para os quais cada 
  par que endossa tentará distribuir os dados privados. Se um par endossante ficar indisponível entre o horário do endosso e o tempo de 
  confirmação, outros colegas que são membros da coleção, mas que ainda não receberam os dados privados no momento do endosso, poderão 
  extrair os dados privados dos colegas para os quais os dados privados foram divulgados. Se esse valor for definido como ``0``, os dados 
  privados não serão disseminados no momento do endosso, forçando a atração de dados privados contra os endossados ​​de todos os pares 
  autorizados no momento da confirmação.

* ``blockToLive``: Representa quanto tempo os dados devem permanecer no banco de dados privado em termos de blocos. Os dados permanecerão 
  para esse número especificado de blocos no banco de dados privado e, depois disso, serão eliminados, tornando esses dados obsoletos na 
  rede, para que não possam ser consultados no chaincode e não possam ser disponibilizados aos pares solicitantes. Para manter os dados 
  privados indefinidamente, ou seja, para nunca limpar os dados privados, defina a propriedade ``blockToLive`` como ``0``.

* ``memberOnlyRead``: O valor ``true`` indica que os pares impõem automaticamente que apenas clientes pertencentes a uma das organizações 
  membro da coleção tenham acesso de leitura permitido aos dados privados. Se um cliente de uma organização não membro tentar executar uma 
  função de chaincode que lê uma chave de dados privada, a chamada do chaincode será encerrada com um erro. Utilize um valor de ``false`` se 
  desejar codificar um controle de acesso mais granular nas funções individuais de chaincode.

* ``memberOnlyWrite``: O valor ``true`` indica que os pares aplicam automaticamente que apenas clientes pertencentes a uma das organizações 
  membros da coleção têm permissão para gravar dados privados a partir do chaincode. Se um cliente de uma organização não membro tentar 
  executar uma função de chaincode que execute uma gravação em uma coleção de dados privada, a chamada do chaincode será encerrada com um 
  erro. Utilize o valor ``false`` se desejar codificar um controle de acesso mais granular nas funções individuais do chaincode, por exemplo, 
  você pode desejar que determinados clientes de organizações não-membros possam criar dados privados em uma determinada coleção.

* ``endorsementPolicy``: Uma política de endosso opcional a ser utilizada para a coleção que substitui a política de endosso no nível do 
  chaincode. Uma política de endosso de nível de coleção pode ser especificada na forma de ``signaturePolicy`` ou pode ser uma referência 
  ``channelConfigPolicy`` a uma política existente a partir da configuração do canal. O ``endorsementPolicy`` pode ser o mesmo que a 
  distribuição da coleção ``policy``, ou pode exigir menos ou mais pares da organização.

Aqui está um arquivo JSON de definição de coleção de exemplo, contendo uma matriz de duas definições de coleção:

.. code:: bash

 [
  {
     "name": "collectionMarbles",
     "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
     "requiredPeerCount": 0,
     "maxPeerCount": 3,
     "blockToLive":1000000,
     "memberOnlyRead": true,
     "memberOnlyWrite": true
  },
  {
     "name": "collectionMarblePrivateDetails",
     "policy": "OR('Org1MSP.member')",
     "requiredPeerCount": 0,
     "maxPeerCount": 3,
     "blockToLive":3,
     "memberOnlyRead": true,
     "memberOnlyWrite":true,
     "endorsementPolicy": {
       "signaturePolicy": "OR('Org1MSP.member')"
     }
  }
 ]

Este exemplo usa as organizações da rede de teste da Fabric, ``Org1`` e ``Org2``. A política na definição ``collectionMarbles`` autoriza 
ambas as organizações aos dados privados. Essa é uma configuração típica quando os dados do chaincode precisam permanecer privados dos nós 
do serviço de ordens. No entanto, a política na definição ``collectionMarblePrivateDetails`` restringe o acesso a um subconjunto de 
organizações no canal (neste caso, ``Org1``). Além disso, a gravação desta coleção exige o endosso de um par ``Org1``, mesmo que a política 
de endosso no nível do chaincode possa exigir o endosso de ``Org1`` ou ``Org2``. E como "memberOnlyWrite" é verdadeiro, apenas clientes de 
``Org1`` podem chamar o chaincode que grava na coleção de dados privada. Dessa maneira, você pode controlar quais organizações são 
encarregadas de gravar em determinadas coleções de dados particulares.

.. private-data-dissemination: 

Divulgação de dados privados
----------------------------

Como os dados privados não são incluídos nas transações que são enviadas ao serviço de ordens e, portanto, não são incluídos nos blocos que 
são distribuídos a todos os pares em um canal, o parceiro endossante desempenha um papel importante na disseminação de dados privados para 
outros pares de organizações autorizadas. Isso garante a disponibilidade de dados privados na coleção do canal, mesmo que os pares 
endossantes fiquem indisponíveis após o seu endosso. Para ajudar nessa disseminação, as propriedades ``maxPeerCount`` e ``requiredPeerCount`` 
na definição de coleção controlam o grau de disseminação no momento do endosso.

Se o ponto de endosso não puder disseminar com êxito os dados privados para pelo menos o ``requiredPeerCount``, ele retornará um erro ao 
cliente. O par endossante tentará disseminar os dados privados para colegas de diferentes organizações, em um esforço para garantir que cada 
organização autorizada tenha uma cópia dos dados privados. Como as transações não são confirmadas no momento da execução do chaincode, os 
pares endossantes e destinatários armazenam uma cópia dos dados privados em um ``armazenamento transitório`` local ao lado de sua blockchain 
até que a transação seja confirmada.

Quando os pares autorizados não tiverem uma cópia dos dados privados em seu armazenamento temporário de dados no momento da confirmação 
(porque não eram um par endossante ou porque não receberam os dados privados por disseminação no momento do endosso), eles tentarão obter os 
dados privados de outro par autorizado, *por um período configurável*, com base na propriedade do par ``peer.gossip.pvtData.pullRetryThreshold`` 
no arquivo ``core.yaml`` da configuração do par.

.. note:: Os pares que estão sendo solicitados a fornecer dados particulares somente retornarão os dados privados se o par solicitante for 
          um membro da coleção, conforme definido pela política de disseminação de dados privados.

Considerações ao usar ``pullRetryThreshold``:

* Se o ponto solicitante puder recuperar os dados privados dentro do ``pullRetryThreshold``, confirmará a transação no razão (incluindo o 
  hash de dados privados) e armazenará os dados privados em seu banco de dados de estado, logicamente separados dos outros dados do estado 
  do canal.

* Se o parceiro solicitante não conseguir recuperar os dados privados dentro do ``pullRetryThreshold``, confirmará a transação em sua 
  blockchain (incluindo o hash de dados privados), sem os dados privados.

* Se o par tiver direito aos dados privados, mas estiverem ausentes, ele não poderá endossar transações futuras que fazem referência aos 
  dados privados ausentes - uma consulta do chainchode para uma chave que estiver faltando será detectada (com base na presença do hash da 
  chave no banco de dados do estado) e o chaincode receberá um erro.

Portanto, é importante definir as propriedades ``requiredPeerCount`` e ``maxPeerCount`` grandes o suficiente para garantir a disponibilidade 
de dados privados em seu canal. Por exemplo, se cada um dos pares endossantes se tornar indisponível antes da transação ser confirmada, as 
propriedades ``requiredPeerCount`` e ``maxPeerCount`` garantirão que os dados privados estejam disponíveis em outros pares.

.. note:: Para que as coleções funcionem, é importante ter o protocolo gossip configurado corretamente entre as organizações. Consulte nossa 
          documentação em :doc:`gossip`, prestando atenção especial à configuração "Pares de âncora" e "Ponto de contatos externos e internos".

.. referencing-collections-from-chaincode:

Referenciando coleções no chaincode
-----------------------------------

Um conjunto de `APIs proxy <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim>`_ está disponível para configurar e recuperar 
dados particulares.

As mesmas operações de dados do chaincode podem ser aplicadas aos dados do estado do canal e aos dados privados, mas, no caso de dados 
privados, um nome de coleção é especificado junto com os dados nas APIs do chaincode, por exemplo ``PutPrivateData(collection, key, value)`` 
e ``GetPrivateData(coleção, chave)``.

Um único chaincode pode fazer referência a várias coleções.

.. referencing-implicit-collections-from-chaincode:

Referenciando coleções Implícitas do chaincode
----------------------------------------------

A partir da v2.0, uma coleção de dados privada implícita pode ser usada para cada organização em um canal, para que você não precise definir 
coleções se desejar utilizar coleções por organização. Cada coleção implícita específica da organização possui uma política de distribuição 
e uma política de endosso da organização correspondente. Portanto, você pode utilizar coleções implícitas para casos de uso em que deseja 
garantir que uma organização específica tenha gravado em um namespace específico. O ciclo de vida do chaincode v2.0 usa coleções implícitas 
para rastrear quais organizações aprovaram uma definição de chaincode. Da mesma forma, você pode usar coleções implícitas no chaincode do 
para rastrear quais organizações aprovaram ou votaram em alguma mudança de estado.

Para escrever e ler uma chave na coleção de dados privada implícita, nas APIs de chaincode ``PutPrivateData`` e ``GetPrivateData``, 
especifique o parâmetro de coleção como ``"_implicit_org_ <MSPID>"``, por exemplo, ``"_implicit_org_Org1MSP"``.

.. note:: Os nomes de coleções definidas pelo aplicativo não podem começar com um sublinhado, portanto, não há chance de um nome implícito 
          de coleção colidir com um nome de coleção definido pelo aplicativo.

.. how-to-pass-private-data-in-a-chaincode-proposal:

Como passar dados privados em uma proposta de um chaincode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Como a proposta de um chaincode é armazenada no blockchain, também é importante não incluir dados privados na parte principal da proposta do 
chaincode. Um campo especial na proposta do chaincode chamado ``transient`` pode ser usado para passar dados privados do cliente (ou dados 
que o chaincode usará para gerar dados privados), para chamar do chaincode no par. O chaincode pode recuperar o campo ``transient`` chamando 
a API `GetTransient() <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetTransient>`_. Este campo 
``transient`` é excluído da transação do canal.

.. protecting-private-data-content:

Protegendo o conteúdo de dados privados
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Se os dados privados forem relativamente simples e previsíveis (por exemplo, valor em Real das transações), os membros do canal que não 
estão autorizados ha coletar privados poderão tentar adivinhar o conteúdo dos dados privados por meio do hash de força bruta no espaço do 
domínio, na esperança de encontrar uma correspondência com o hash de dados privados na cadeia. Os dados privados que são previsíveis devem, 
portanto, incluir um "valor" aleatório que é concatenado com a chave de dados privados e incluído no valor dos dados privados, para que um 
hash correspondente não possa ser encontrado realisticamente via força bruta. O "valor" aleatório pode ser gerado no lado do cliente (por 
exemplo, amostrando uma fonte psuedo-aleatória segura) e depois passado junto com os dados privados no campo transitório no momento da 
chamada do chaincode.

.. access-control-for-private-data:

Controle de acesso aos dados privados
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Até a versão 1.3, o controle de acesso aos dados privados com base na associação à coleção era aplicado apenas aos pares. O controle de 
acesso baseado na organização do remetente da proposta do chaincode precisava ser codificado na lógica do chaincode. As opções de 
configuração da coleção ``memberOnlyRead`` (desde a versão v1.4) e ``memberOnlyWrite`` (desde a versão v2.0) podem impor automaticamente que 
o remetente da proposta do chaincode deve ser de um membro da coleção para ler ou gravar dados privados chave. Para obter mais informações 
sobre definições de configuração de coleção e como defini-las, consulte a seção `Definição de coleção de dados particulares`_ deste tópico.

.. note:: Se você quiser um controle de acesso mais granular, poderá configurar ``memberOnlyRead`` e ``memberOnlyWrite`` para false. Você 
          pode aplicar sua própria lógica de controle de acesso no chaincode, por exemplo, chamando a API GetCreator() no chaincode ou 
          usando a `biblioteca do chaincode de identidade do cliente <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStub.GetCreator>`__.

.. querying-private-data:

Consultando dados privados
~~~~~~~~~~~~~~~~~~~~~~~~~~

A coleção de dados privados pode ser consultada como os dados normais do canal, usando as APIs proxy:

* ``GetPrivateDataByRange(collection, startKey, endKey string)``
* ``GetPrivateDataByPartialCompositeKey(collection, objectType string, keys []string)``

E para o banco de dados de estado CouchDB, as consultas de conteúdo JSON podem ser transmitidas usando a API proxy:

* ``GetPrivateDataQueryResult(collection, query string)``

Limitações:

* Os clientes que chamam o chaincode que executam consultas de intervalo ou JSON avançados devem estar cientes de que podem receber um 
  subconjunto do conjunto de resultados, se o par que consulta tiver dados particulares ausentes, com base na explicação na seção 
  Disseminação de dados privados acima. Os clientes podem consultar vários pares e comparar os resultados para determinar se um par pode 
  estar perdendo parte do conjunto de resultados.
* Chaincode que executa consultas avançadas JSON ou de intervalo e atualiza dados em uma única transação não é suportado, pois os resultados 
  da consulta não podem ser validados nos pares que não têm acesso aos dados privados ou nos pares que estão ausentes. Se um chaincode 
  chamar consultas e atualizar dados particulares, a solicitação da proposta retornará um erro. Se seu aplicativo puder tolerar alterações 
  no conjunto de resultados entre a execução do chaincode e o tempo de validação/confirmação, você poderá chamar uma função de chaincode 
  para executar a consulta e, em seguida, chamar uma segunda função de chaincode para fazer as atualizações. Observe que as chamadas para 
  GetPrivateData() para recuperar chaves individuais podem ser feitas na mesma transação que as chamadas PutPrivateData(), pois todos os 
  pares podem validar leituras de chave com base na versão da chave com hash.

.. using-indexes-with-collections:

Usando índices com coleções
~~~~~~~~~~~~~~~~~~~~~~~~~~~

O tópico: doc:`couchdb_as_state_database` descreve índices que podem ser aplicados ao banco de dados de estado do canal para ativar 
consultas de conteúdo JSON, empacotando os índices no diretório ``META-INF/statedb/couchdb/indexes`` no momento da instalação do chaincode. 
Da mesma forma, os índices também podem ser aplicados a coleções de dados particulares, empacotando índices em um diretório 
``META-INF/statedb/couchdb/collections/<collection_name>/indexes``. Um índice de exemplo está disponível 
`aqui <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02_private/go/META-INF/statedb/couchdb/collections/collectionMarbles/indexes/indexOwner.json>`_.

.. considerations-when-using-private-data:

Considerations when using private data
--------------------------------------

.. private-data-purging:

Limpeza de dados privados
~~~~~~~~~~~~~~~~~~~~

Os dados privados podem ser periodicamente eliminados dos pares. Para obter mais detalhes, consulte a propriedade de definição de coleção 
``blockToLive`` acima.

Além disso, lembre-se de que, antes da confirmação, os pares armazenam dados privados em um armazenamento de dados temporários local. Esses 
dados são limpos automaticamente quando a transação é confirmada. Mas, se uma transação nunca foi enviada ao canal e, portanto, nunca foi 
confirmada, os dados privados permaneceriam no armazenamento temporário de cada par. Esses dados são eliminados do armazenamento temporário 
após um número configurável ser definido usando a propriedade ``peer.gossip.pvtData.transientstoreMaxBlockRetention`` do par no arquivo 
``core.yaml`` do par.

.. updating-a-collection-definition:

Atualizando uma definição de coleção
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Para atualizar uma definição de coleção ou adicionar uma nova coleção, você pode atualizar a definição do chaincode e passar a nova 
configuração de coleção nas transações de aprovação e confirmação do chaincode, por exemplo, usando o sinalizador ``--collections-config`` 
se estiver usando o CLI. Se uma configuração de coleção for especificada ao atualizar a definição do chaincode, uma definição para cada uma 
das coleções existentes deverá ser incluída.

Ao atualizar uma definição de chaincode, você pode adicionar novas coleções de dados particulares e atualizar coleções de dados particulares 
existentes, por exemplo, para adicionar novos membros a uma coleção existente ou alterar uma das propriedades de definição de coleção. 
Observe que você não pode atualizar o nome da coleção ou a propriedade ``blockToLive``, pois um ``blockToLive`` consistente é necessário, 
independentemente da altura do bloco de um par.

As atualizações de coleção tornam-se efetivas quando um par confirma o bloco com a definição do chaincode atualizada. Observe que as 
coleções não podem ser excluídas, pois pode haver hashes de dados privados anteriores na cadeia de blocos do canal que não podem ser 
removidos.

.. private-data-reconciliation:

Reconciliação de dados privados
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A partir da v1.4, os pares de organizações adicionados a uma coleção existente buscarão automaticamente dados privados que foram confirmados 
na coleção antes de ingressarem na coleção.

Essa "reconciliação" de dados privados também se aplica a pares que tinham direito a receber dados particulares, mas ainda não os receberam 
- devido a uma falha na rede, por exemplo -, acompanhando os dados privados "ausentes" na hora da confirmação do bloco.

A reconciliação de dados privados ocorre periodicamente com base nas propriedades ``peer.gossip.pvtData.reconciliationEnabled`` e 
``peer.gossip.pvtData.reconcileSleepInterval`` no core.yaml. O par tentará periodicamente buscar os dados privados de outros colegas membros 
da coleção.

Observe que esse recurso de reconciliação de dados particulares funciona apenas em pares executando a v1.4 ou posterior da Fabric.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
