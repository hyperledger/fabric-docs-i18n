Quais as novidades na Hyperledger Fabric v2.x
=====================================

Sendo o primeiro grande lançamento da Hyperledger Fabric desde a v1.0, a Fabric v2.0
oferece novos recursos e mudanças importantes para usuários e operadores,
incluindo suporte para novas aplicações e padrões de privacidade, governança
aprimorada em torno de contratos inteligentes e novas opções para nós operacionais.

Cada lançamento menor v2.x baseia-se na versão v2.0 com recursos secundários,
melhorias e correções de bugs.

Vamos dar uma olhada em alguns dos destaques do lançamento da Fabric v2.0...

Governança descentralizada para smart contracts
--------------------------------------------

Fabric v2.0 introduz governança descentralizada para smart contracts, com um novo
processo para instalação de chaincode em seus peers e para iniciá-lo em um canal.
O novo ciclo de vida do chaincode da Fabric permite que várias organizações cheguem
a um acordo sobre os parâmetros de um chaincode, como a política de endosso do 
chaincode, antes que ele possa ser usado para interagir com o livro-razão. O novo
modelo oferece diversas melhorias em relação ao ciclo de vida anterior:

* **Várias organizações devem concordar com os parâmetros de um chaincode**
  Nas versões 1.x da Fabric, uma organização tinha a capacidade de definir 
  parâmetros de um chaincode (por exemplo, a política de endosso) para todos
  os outros membros do canal, que só tinham o poder de recusar a instalação
  do chaincode e, portanto, não participar em transações que o invocam. O novo 
  ciclo de vida do chaincode Fabric é mais flexível, pois suporta tanto modelos de
  confiança centralizados (como o do modelo de ciclo de vida anterior), quanto
  modelos descentralizados que exigem um número suficiente de organizações para 
  concordar com uma política de endosso e outros detalhes antes que o chaincode
  se torne ativo em um canal.

* **Processo de atualização de chaincode mais deliberado** No ciclo de vida anterior
  do chaincode, a transação de atualização poderia ser emitida por uma única 
  organização, criando um risco para um membro do canal que ainda não tivesse
  instalado o novo chaincode. O novo modelo permite que um chaincode seja atualizado
  somente após um número suficiente de organizações ter aprovado a atualização.

* **Política de endosso mais simples e atualizações na coleta de dados privados**
  O ciclo de vida da Fabric permite alterar uma política de endosso ou configuração 
  de coleta de dados privados sem precisar reempacotar ou reinstalar o chaincode. 
  Os usuários também podem aproveitar uma nova política de endosso padrão que exige
  o endosso da maioria das organizações no canal. Esta política é atualizada 
  automaticamente quando organizações são adicionadas ou removidas do canal.

* **Pacotes de chaincode inspecionáveis** O ciclo de vida da Fabric empacota o 
  chaincode em arquivos tar facilmente legíveis. Isso torna mais fácil inspecionar
  o pacote chaincode e coordenar a instalação em várias organizações.

* **Inicie vários chaincodes em um canal usando um pacote** O ciclo de vida anterior
  definia cada chaincode no canal usando um nome e uma versão que eram especificados
  quando o pacote chaincode era instalado. Agora você pode usar um único pacote 
  chaincode e implantá-lo várias vezes com nomes diferentes no mesmo canal ou em 
  canais diferentes. Por exemplo, se você quiser rastrear diferentes tipos de ativos
  em sua própria ‘cópia’ do chaincode.

* **Os pacotes Chaincode não precisam ser idênticos entre os membros do canal**
  As organizações podem estender um chaincode para seu próprio caso de uso, por 
  exemplo, para realizar diferentes validações no interesse de sua organização.
  Contanto que o número necessário de organizações endossem as transações do
  chaincode com resultados correspondentes, a transação será validada e commitada no
  livro-razão. Isso também permite que as organizações implementem individualmente 
  pequenas correções de acordo com seus próprios cronogramas, sem exigir que toda a 
  rede prossiga em sincronia.

Usando o novo ciclo de vida do chaincode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Para implantações existentes da Fabric, você pode continuar a usar o ciclo de vida
anterior do chaincode com a Fabric v2.0. O novo ciclo de vida do chaincode entrará 
em vigor somente quando a capacidade do canal for atualizado para v2.0. Veja o tópico
conceitual :doc:`chaincode_lifecycle` para uma visão geral do novo ciclo de vida do
chaincode.

Novos padrões de aplicação chaincode para colaboração e consenso
------------------------------------------------------------------

Os mesmos métodos descentralizados de chegar a um acordo que sustentam o
novo gerenciamento do ciclo de vida do chaincode também podem ser usados
em seus próprios aplicativos de chaincode para garantir que as organizações
concordem com as transações de dados antes de serem efetivamente registradas
no livro-razão.

* **Verificações automatizadas** Conforme mencionado acima, as organizações 
  podem adicionar verificações automatizadas às funções do chaincode para 
  validar informações adicionais antes de endossar uma proposta de transação.

* **Acordo descentralizado** As decisões humanas podem ser modeladas em um 
  processo chaincode que abrange múltiplas transações. O chaincode pode exigir
  que atores de várias organizações indiquem seus termos e condições de acordo 
  em uma transação no livro-razão. Então, uma proposta final de chaincode pode
  verificar se as condições de todos os transatores individuais foram atendidas
  e “liquidar” a transação comercial com finalidade em todos os membros do canal. 
  Para um exemplo concreto de indicação de termos e condições em modo privado, veja
  o cenário de transferência de ativos na documentação :doc:`private-data/private-data`.

Melhorias de dados privados
-------------------------

A Fabric v2.0 também permite novos padrões para trabalhar e compartilhar dados privados,
sem a necessidade de criar coleções de dados privados para todas as combinações de membros
do canal que queiram fazer transações. Especificamente, em vez de partilhar dados privados
dentro de uma coleção de vários membros, poderá querer partilhar dados privados entre 
coleções, onde cada coleção pode incluir uma única organização, ou talvez uma única
organização juntamente com um regulador ou auditor.

Vários aprimoramentos na Fabric v2.0 tornam possíveis esses novos padrões de dados privados:

* **Compartilhando e verificando dados privados** Quando dados privados são compartilhados
  com um membro do canal que não é membro de uma coleção, ou compartilhados com outra coleção
  de dados privados que contém um ou mais membros do canal (gravando uma chave para essa 
  coleção), as partes receptoras podem utilizar o método GetPrivateDataHash() da API chaincode
  para verificar se os dados privados correspondem aos hashes (registrados na blockchain)
  que foram criados a partir desses dados privados em transações anteriores.

* **Políticas de endosso em nível de coleção** As coleções de dados privados agora podem ser
  opcionalmente definidas com uma política de endosso que sobrescreve a política de endosso
  em nível de chaincode por chaves dentro da coleção. Esse recurso pode ser usado para 
  restringir quais organizações podem gravar dados em uma coleção e é o que permite o novo
  ciclo de vida do chaincode e os novos padrões de aplicação do chaincode mencionados
  anteriormente. Por exemplo, você pode ter uma política de endosso de chaincode que exige o
  endosso da maioria das organizações, mas para qualquer transação, você pode precisar que
  duas organizações transacionais endossem individualmente seu acordo em suas próprias
  coleções de dados privadas.

* **Coleções implícitas por organização** Se quiser utilizar padrões de dados privados por
  organização, você nem precisa definir as coleções ao implantar o chaincode na Fabric v2.0.
  Coleções implícitas específicas da organização podem ser usadas sem qualquer definição inicial.

Para saber mais sobre os novos padrões de dados privados, consulte :doc:`private-data/private-data`
(documentação conceitual). Para detalhes sobre configuração de coleta de dados privados e
coleções implícitas, veja :doc:`private-data-arch` (documentação de referência).

Lançador de chaincode externo
---------------------------

O recurso de inicialização de chaincode externo permite que os operadores criem e lancem
chaincode com a tecnologia de sua escolha. O uso de construtores e inicializadores externos
não é necessário, pois o comportamento padrão cria e executa o chaincode da mesma maneira
que as versões anteriores usando a API Docker.

* **Elimine a dependência do daemon do Docker** As versões anteriores da Fabric exigiam que
  os pares tivessem acesso a um daemon Docker para construir e lançar o chaincode – algo que
  pode não ser desejável em ambientes de produção devido aos privilégios exigidos pelo 
  processo de pares.

* **Alternativas aos contêineres** O Chaincode não precisa mais ser executado em contêineres
  Docker e pode ser executado no ambiente de escolha do operador (incluindo contêineres).

* **Executáveis de construtor externo** Um operador pode fornecer um conjunto de executáveis
  de construtor externo para substituir como o peer constrói e inicia o chaincode.

* **Chaincode como um serviço externo** Tradicionalmente, os chaincodes são lançados pelo peer
  e, em seguida, conectam-se novamente ao peer. Agora é possível executar o chaincode como um
  serviço externo, por exemplo, em um pod Kubernetes, ao qual um peer pode se conectar e 
  utilizar para execução do chaincode. Veja :doc:`cc_service` para mais informações.

Veja :doc:`cc_launcher` para saber mais sobre o recurso de inicializador externo de chaincode.

Cache de banco de dados de estado para melhor desempenho no CouchDB
--------------------------------------------------------

* Ao usar o banco de dados de estado externo do CouchDB, os atrasos de leitura durante
  as fases de endosso e validação têm sido historicamente um gargalo de desempenho.

* Com a Fabric v2.0, um novo cache peer substitui muitas dessas pesquisas caras por
  leituras rápidas de cache local. O tamanho do cache pode ser configurado usando a
  propriedade core.yaml ``cacheSize``.

Imagens docker baseadas em Alpine
--------------------------

A partir da v2.0, as imagens da Hyperledger Fabric Docker usarão o Alpine Linux,
uma distribuição Linux leve e orientada para a segurança. Isso significa que as
imagens do Docker agora são muito menores, proporcionando tempos de download e 
inicialização mais rápidos, além de ocupar menos espaço em disco nos sistemas do
host. O Alpine Linux foi projetado desde o início com a segurança em mente, e a
natureza minimalista da distribuição Alpine reduz bastante o risco de vulnerabilidades
de segurança.

Rede de teste de amostra
-------------------

O repositório de amostras da Fabric agora inclui uma nova rede de teste Fabric.
A rede de teste foi construída para ser uma rede Fabric de amostra modular e fácil
de usar que facilita o teste de seus aplicativos e contratos inteligentes. A rede
também oferece suporte à capacidade de implantar sua rede usando Autoridades de
Certificação, além do criptogênio.

Para mais informações sobre esta rede, confira :doc:`test_network`.

Atualizando para Fabric v2.x
------------------------

Uma nova versão principal traz algumas considerações adicionais de atualização. Porém,
saiba de que as atualizações contínuas de v1.4.x para v2.x são suportadas, então os
componentes de rede podem ser atualizados um de cada vez, sem tempo de inatividade.

A documentação de atualização foi significativamente expandida e retrabalhada, e agora
tem uma página independente na documentação: :doc:`upgrade`. Aqui você encontrará 
documentação sobre :doc:`upgrading_your_components` e :doc:`updating_capabilities`,
bem como uma visão específica das considerações para atualizar para v2.0, :doc:`upgrade_to_newest_version`.

Notas de lançamento
=============

As notas de lançamento fornecem mais detalhes para usuários que estão migrando para a nova
versão. Especificamente, dê uma olhada nas mudanças e descontinuações que estão sendo 
anunciadas com a nova versão da Fabric v2.0 e nas mudanças introduzidas na v2.1.

* `Notas de lançamento Fabric v2.0.0 <https://github.com/hyperledger/fabric/releases/tag/v2.0.0>`_.
* `Notas de lançamento Fabric v2.0.1 <https://github.com/hyperledger/fabric/releases/tag/v2.0.1>`_.
* `Notas de lançamento Fabric v2.1.0 <https://github.com/hyperledger/fabric/releases/tag/v2.1.0>`_.

.. Licenciado sob Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
