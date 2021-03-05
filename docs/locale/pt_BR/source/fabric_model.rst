Modelo Hyperledger Fabric 
=========================

Esta seção descreve os principais recursos de design incorporados a Hyperledger 
Fabric que cumprem sua promessa de uma solução blockchain corporativa abrangente, 
mas personalizável:

* :ref:`Ativos` --- Ativos permitem a troca de quase tudo com valor monetário na
  rede, de alimentos integrais, a carros antigos e futuros de moeda.
* :ref:`Chaincode` --- A execução do chaincode é particionado pela ordem das 
  transações, limitando os níveis necessários de confiança e verificação nos 
  nós e otimizando a escalabilidade e o desempenho da rede.
* :ref:`Livro-Razao` --- O livro-razão imutável compartilhado codifica todo 
  o histórico de transações de cada canal e inclui recursos de consulta 
  semelhantes a SQL para auditoria eficiente e resolução de disputas.
* :ref:`Privacidade` --- Canais e dados privados permitem transações 
  multilaterais privadas e confidenciais, geralmente exigidas por empresas 
  concorrentes e indústrias reguladas que trocam ativos em uma rede comum.
* :ref:`Servicos-Seguranca-Associacao` --- A associação permissionada fornece 
  uma rede blockchain confiável, na qual os participantes sabem que todas as 
  transações podem ser detectadas e rastreadas por reguladores e auditores 
  autorizados.
* :ref:`Consenso` --- Uma abordagem única para o consenso permite a flexibilidade 
  e a escalabilidade necessárias para a empresa.

.. _Ativos:
.. _Assets:

Ativos (Assets)
---------------

Os ativos podem variar do tangível (imóveis e ferramentas) ao intangível 
(contratos e propriedade intelectual). A Hyperledger Fabric fornece a capacidade
realizar operações nos ativos usando contratos inteligentes.

Os ativos são representados na Hyperledger Fabric como uma coleção de pares de
chave-valor, com as alterações de estado registradas como transações no 
livro-razão do :ref:`Canal`. Os ativos podem ser representados no formato 
binário e/ou JSON.

.. _Chaincode:

Chaincode
---------

Chaincode é um software que define um ativo ou ativos, e as instruções de 
transação para modificar o(s) ativo(s); em outras palavras, é a lógica de 
negócio. O Chaincode garante a aplicação das regras para ler ou alterar os pares
de chave-valor ou outras informações do banco de dados de estado. As funções do
Chaincode são executadas no banco de dados de estado atual do livro-razão e são 
iniciadas por meio de uma proposta de transação. O resultado da execução de um 
chaincode é um conjunto de atualizações de chave-valor que podem ser enviadas à 
rede e aplicadas ao livro-razão de todos os pares.

.. _Livro-Razao:
.. _Ledger-Features:

Livro-Razão (Ledger)
--------------------

O livro-razão é o registro sequencial e resistente a violações de todas as 
transições de estado na Fabric. As transições de estado são resultado de 
invocações do chaincode ('transações') enviadas pelas partes participantes. Cada 
transação resulta em um conjunto de pares de chave-valor referente a um ativo 
que são confirmados no livro-razão quando criados, atualizados ou excluídos.

O livro-razão é composto por uma cadeia de blocos ('chain') para armazenar o 
registro imutável e sequenciado em blocos ('blockchain'), bem como um banco de 
dados de estado para manter o estado atual da Fabric. Há um livro-razão por 
canal. Cada par mantém uma cópia do livro-razão para cada canal do qual eles são
membros.

Alguns recursos do livro-razão da Fabric:

- Consulta e atualização do livro-razão usando pesquisas baseadas em chave, consultas de intervalo e consultas com chave composta
- Consultas somente para leitura usando uma linguagem de consulta avançada (se estiver usando o CouchDB como banco de dados de estado)
- Consultas somente para leitura do histórico --- Consulta do histórico do livro-razão usando por uma chave, permitindo inspecionar a proveniência de dados
- As transações consistem nas versões das chaves/valores que foram lidos no chaincode da chamada (conjunto de dados) e chaves/valores que foram gravados na chamada (conjunto da gravação)
- As transações contêm as assinaturas de todos os pares endossantes e são enviadas para o serviço de ordem
- As transações são ordenadas em blocos e são "entregues" por um serviço de pedidos aos pares em um canal
- Os pares validam transações nas políticas de endosso e fazem cumprir as políticas
- Antes de anexar um bloco, é realizada uma verificação da versão para garantir que os estados dos blocos ativos que foram lidos não tenham sido alterados desde o tempo de execução do chaincode
- Se torna imutável uma vez que uma transação é validada e confirmada
- O livro-razão de um canal contém um bloco de configuração que define suas políticas, listas de controle de acesso e outras informações pertinentes
- Os canais possuem instâncias do :ref:`MSP` permitindo que a criptografia possa ser derivada de diferentes autoridades certificadoras

Consulte o tópico :doc:`ledger` para obter informações mais detalhadas sobre 
bancos de dados, estrutura de armazenamento e "capacidade de consulta".

.. _Privacidade:
.. _Privacy:

Privacidade
-----------

A Hyperledger Fabric emprega um livro-razão imutável por canal e também um 
código ('chaincode') que pode manipular e modificar o estado atual dos ativos 
(ou seja, atualizar pares de chave-valor). Um livro-razão existe no escopo de um 
canal - ele pode ser compartilhado em toda a rede (assumindo que todos os 
participantes operam em um canal comum) - ou pode ser segregado para incluir 
apenas um conjunto específico de participantes.

No último cenário, o participantes criariam um canal separado e, assim, 
isolariam/segregariam suas transações e o livro-razão. Para resolver cenários 
que desejam preencher a lacuna entre total transparência e privacidade, o 
chaincode pode ser instalado apenas nos pares que precisam acessar os estados do 
ativo para executar leituras e gravações (em outras palavras, se um chaincode 
não estiver instalado em um par), ele não poderá interagir adequadamente com o 
livro-razão).

Quando um subconjunto de organizações em um canal precisa manter seus dados de
transação confidenciais, um conjunto privado de dados (coleção) é usado para 
segregar esses dados em um banco de dados privado, logicamente separando o 
livro-razão do canal, sendo acessível apenas pelo subconjunto autorizado de 
organizações.

Assim, os canais mantêm as transações privadas da rede mais ampla, enquanto as 
coleções mantêm os dados privados entre subconjuntos de organizações no canal.

Para ofuscar ainda mais os dados, os valores no chaincode podem ser criptografados 
(em parte ou no total) usando algoritmos criptográficos comuns, como o AES, 
antes de enviar as transações para o serviço de ordem e anexar os blocos ao 
livro-razão. Depois que os dados criptografados são gravados no razão, eles 
podem ser descriptografados apenas pelo usuário que possui a chave 
correspondente que foi usada para gerar o texto criptografado.

Consulte o tópico :doc:`private-data-arch` para ter mais detalhes sobre como 
obter privacidade em sua rede blockchain.

.. _Servicos-Seguranca-Associacao:
.. _Security-Membership-Services:

Serviços de Segurança e Associação
----------------------------------

A Hyperledger Fabric suporta uma rede transacional em que todos os participantes
têm identidades conhecidas ('permissionada'). A infraestrutura de chave pública 
é usada para gerar certificados criptográficos vinculados às organizações, 
componentes de rede e usuários finais ou aplicativos clientes. Como resultado, o 
controle de acesso a dados pode ser manipulado e controlado em uma rede ampla e 
nos níveis de canal. Essa noção "permissionada" da Hyperledger Fabric, juntamente 
com a existência e os recursos dos canais, ajuda a lidar com cenários em que a 
privacidade e a confidencialidade são preocupações fundamentais.

Consulte o tópico :doc:`msp` para entender melhor as implementações 
criptográficas e a abordagem de assinatura, verificação e autenticação usada na
Hyperledger Fabric.

.. _Consenso:
.. _Consensus:

Consenso
--------

Na tecnologia de livro-razão distribuído, o consenso tornou-se recentemente 
sinônimo de um algoritmo específico, dentro de uma única função. No entanto, o 
consenso abrange mais do que simplesmente concordar com a ordem das transações,
e essa diferenciação é destacada na Hyperledger Fabric por seu papel fundamental
em todo o fluxo da transação, desde a proposta e endosso, até a ordem, validação 
e registro. Em poucas palavras, o consenso é processo completo de verificar a 
validade e coerência de um conjunto de transações de um bloco.

Finalmente, o consenso é alcançado quando a ordem e os resultados das transações 
de um bloco atendem às verificações explícitas dos critérios da política. Essas 
verificações e resultados ocorrem durante o ciclo de vida de uma transação e 
incluem o uso das políticas de endosso para determinar quais membros 
especificamente devem endossar uma determinada classe de transação, bem como 
os chaincodes que garantem que essas políticas sejam aplicadas e mantidas. Antes
da gravação, os pares empregarão esses chaincodes para garantir que há confirmações 
o suficiente dos demais pares e que elas foram derivadas das entidades 
apropriadas. Além disso, ocorrerá uma verificação da versão atual do 
livro-razão, da qual poderá ser válida ou não, antes que quaisquer blocos contendo
transações sejam anexados ao livro-razão. Essa verificação final fornece 
proteção contra operações com registro duplicado e outras ameaças que possam 
comprometer a integridade dos dados e permite que funções sejam executadas 
em variáveis não estáticas.

Além das inúmeras verificações de endosso, validade e versão que ocorrem, também 
existem verificações de identidade ativa em todas as direções do fluxo da 
transação. As listas de controle de acesso são implementadas nas camadas
hierárquicas da rede (serviço de ordem até os canais) e os dados transferidos 
são repetidamente assinados, verificados e autenticados à medida que uma 
proposta de transação passa pelos diferentes componentes da arquitetura. Para 
concluir, o consenso não se limita apenas à ordem acordada de um lote de
transações, pelo contrário, é uma caracterização abrangente que é obtida como um 
subproduto das verificações em andamento que ocorrem durante a jornada de uma 
transação, da proposta ao registro.

Confira o diagrama :doc:`txflow` para uma representação visual
de consenso.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
