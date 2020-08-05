CouchDB como o banco de dados de estado
=======================================

.. state-database-options:

Opções de banco de dados de estado
----------------------------------

As opções atuais para o banco de dados de estado do nó são LevelDB e CouchDB. LevelDB é o banco de dados de estado do padrão chave-valor
incorporado no processo nó par. O CouchDB é um banco de dados de estado externo alternativo. Assim como o armazenamento de chave-valor do
LevelDB, o CouchDB pode armazenar qualquer dado binário modelado em chaincode (os anexos do CouchDB são usados ​​internamente para dados não
JSON). Como um armazenamento de objeto de documento, o CouchDB permite armazenar dados no formato JSON, realizar consultas completas nos
dados e usar índices para dar suporte às suas consultas.

O LevelDB e o CouchDB suportam operações básicas do chaincode, como obter e definir uma chave (ativo) e consultas com base em chaves. As
chaves podem ser consultadas por intervalo, e as chaves compostas podem ser modeladas para permitir consultas de equivalência em relação a
vários parâmetros. Por exemplo, uma chave composta de ``owner,asset_id`` pode ser usada para consultar todos os ativos pertencentes a uma
determinada entidade. Essas consultas baseadas em chave podem ser usadas para consultas de somente leitura no livro-razão, bem como em
transações que atualizem o livro-razão.

A modelagem de seus dados em JSON permite realizar consultas completas com relação aos valores dos dados, em vez de apenas poder consultar
as chaves. Isso facilita para seus aplicativos e chaincodes a leitura dos dados armazenados no livro-razão da blockchain. O uso do CouchDB
pode ajudá-lo a atender aos requisitos de auditoria e relatório para muitos casos de uso que não são suportados pelo LevelDB. Se você usar o
CouchDB e modelar seus dados em JSON, também poderá implantar índices com seu chaincode. O uso de índices torna as consultas mais flexíveis
e eficientes, além de permitir consultar grandes conjuntos de dados a partir do chaincode.

O CouchDB é executado como um processo de banco de dados separado no par, portanto, há considerações adicionais em termos de configuração,
gerenciamento e operação. Você pode considerar começar com a solução incorporada do LevelDB e mudar para o CouchDB se precisar de consultas
adicionais mais complexas. É uma boa prática modelar dados de ativos como JSON, para que você tenha a opção de executar consultas complexas
se necessário no futuro.

.. note:: A chave para um documento CouchDB JSON pode conter apenas valores UTF-8 válidos e não pode começar com um sublinhado ("_"). Se
   você estiver usando o CouchDB ou o LevelDB, evite usar U+0000 (zero byte) nas chaves.

   Os documentos JSON no CouchDB não podem usar os seguintes valores como nomes de campo. Esses valores são reservados para uso interno.

    - ``Qualquer campo começando com um sublinhado, "_"``
    - ``~version``

.. using-couchdb-from-chaincode:

Usando o CouchDB no Chaincode
-----------------------------

.. chaincode-queries:

Consultas com chaincode
~~~~~~~~~~~~~~~~~~~~~~~

A maioria das APIs `chaincode shim  <https://godoc.org/github.com/hyperledger/fabric-chaincode-go/shim#ChaincodeStubInterface>`__ podem ser
utilizadas com o banco de dados de estado LevelDB ou CouchDB, por exemplo. ``GetState``, ``PutState``, ``GetStateByRange``,
``GetStateByPartialCompositeKey``. Além disso, quando você utiliza o CouchDB como o banco de dados de estado e os ativos de modelo como JSON
no chaincode, é possível executar consultas completas com JSON no banco de dados de estado usando a API ``GetQueryResult`` e passando uma
string de consulta para o CouchDB. A string de consulta segue a sintaxe de consulta
`CouchDB JSON <http://docs.couchdb.org/en/2.1.1/api/database/find.html>`__.

A `exemplo da Fabric marbles02 <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/marbles_chaincode.go>`__
demonstra o uso de consultas CouchDB do chaincode. Ele inclui uma função ``queryMarblesByOwner()``, que demonstra consultas parametrizadas
passando um ID do proprietário para o chaincode. Em seguida, ele consulta os dados do estado usando o JSON correspondentes ao docType de
"marble" e o ID do proprietário usando a sintaxe de consulta JSON:

.. code:: bash

  {"selector":{"docType":"marble","owner":<OWNER_ID>}}

As respostas a consultas completas são úteis para entender os dados no livro-razão. No entanto, não há garantia de que o conjunto de
resultados para uma consulta avançada seja estável entre a execução do chaincode e o tempo da confirmação. Como resultado, você não deve
usar uma consulta avançada e atualizar o livro-razão do canal em uma única transação. Por exemplo, se você executar uma consulta avançada
para todos os ativos pertencentes a Alice e transferi-los para Bob, um novo ativo poderá ser atribuído a Alice por outra transação entre o
tempo de execução do chaincode e o tempo de confirmação.

.. couchdb-pagination:

Paginação no CouchDB
^^^^^^^^^^^^^^^^^^^^

A Fabric suporta a paginação dos resultados para consultas avançadas e consultas baseadas em intervalos. As APIs que suportam paginação
permitem que o uso do tamanho da página e dos favoritos seja usado para consultas mais abrangentes. Para oferecer suporte à paginação
eficiente, as APIs de paginação da Fabric devem ser usadas. Especificamente, a palavra-chave ``limit`` do CouchDB não será respeitada nas
consultas do CouchDB, pois a própria Fabric gerencia a paginação dos resultados da consulta e define implicitamente o limite do ``pageSize``
que é passado ao CouchDB.

Se um ``pageSize`` for especificado usando as APIs de consulta paginada (``GetStateByRangeWithPagination()``,
``GetStateByPartialCompositeKeyWithPagination()`` e ``GetQueryResultWithPagination()``), um conjunto de resultados (vinculado pelo pageSize)
será retornado ao chaincode junto com um marcador. O marcador pode ser retornado do chaincode para os clientes, que podem usar o marcador em
uma consulta seguinte para receber a próxima "página" de resultados.

As APIs de paginação são para uso somente em transações de leitura, os resultados da consulta destinam-se a suportar requisitos de paginação
do cliente. Para transações que precisam ler e gravar, use as APIs de consulta do chaincode não paginadas. No chaincode, você pode percorrer
os conjuntos de resultados na profundidade desejada.

Independentemente das APIs de paginação serem utilizadas, todas as consultas de chaincode são vinculadas por ``totalQueryLimit`` (padrão
100000) a partir do ``core.yaml``. Esse é o número máximo de resultados que o chaincode percorrerá e retornará ao cliente, para evitar
consultas acidentais ou mal-intencionadas.

.. note:: Independentemente do chaincode usar ou não consultas paginadas, o nó par consultará o CouchDB em lotes com base no
          ``internalQueryLimit`` (padrão 1000) do ``core.yaml``. Esse comportamento garante que conjuntos de resultados de
          tamanho razoável sejam passados entre o par e o CouchDB ao executar o chaincode e seja transparente ao chaincode e
          ao cliente que está chamando.

Um exemplo usando paginação está incluído no tutorial :doc:`couchdb_tutorial`.

.. couchdb-indexes:

Índice no CouchDB
~~~~~~~~~~~~~~~~~

Os índices no CouchDB são necessários para tornar as consultas JSON eficientes e são necessárias para qualquer consulta JSON com uma
classificação. Os índices permitem consultar dados do chaincode quando você tem uma grande quantidade de dados no seu livro-razão. Os
índices podem ser empacotados juntamente com o chaincode no diretório ``/META-INF/statedb/couchdb/indexes``. Cada índice deve ser definido
em seu próprio arquivo de texto com a extensão ``*.json``, com a definição de índice formatada em JSON, seguindo a sintaxe
`índice do CouchDB em JSON <http://docs.couchdb.org/en/2.1.1/api/database/find.html#db-index>`__. Por exemplo, para suportar a consulta do
``marble`` acima, é fornecido um índice para os campos ``docType`` e ``owner``:

.. code:: bash

  {"index":{"fields":["docType","owner"]},"ddoc":"indexOwnerDoc", "name":"indexOwner","type":"json"}

O índice pode ser encontrado `aqui <https://github.com/hyperledger/fabric-samples/blob/{BRANCH}/chaincode/marbles02/go/META-INF/statedb/couchdb/indexes/indexOwner.json>`__.

Qualquer índice no diretório ``META-INF/statedb/couchdb/indexes`` do chaincode será empacotado com o chaincode para implantação. O índice
será implementado em um canal de nós pares e em um banco de dados específico do chaincode quando o pacote for instalado no par e a definição
de chaincode for confirmada no canal. Se você instalar o chaincode primeiro e depois confirmar a definição de chaincode no canal, o índice
será implementado no momento da confirmação. Se o chaincode já tiver sido definido no canal e o pacote chaincode for posteriormente
instalado em um ponto associado ao canal, o índice será implementado no momento da **instalação** do chaincode.

Na implantação, o índice será utilizado automaticamente por consultas do chaincode. O CouchDB pode determinar automaticamente qual índice
usar com base nos campos que estão sendo usados ​​em uma consulta. Como alternativa, na consulta o índice pode ser especificado usando a
palavra-chave ``use_index``.

O mesmo índice pode existir nas versões subseqüentes do chaincode que é instalado. Para alterar o índice, use o mesmo nome, mas altere a
definição do índice. Após a instalação/instanciação, a definição do índice será reimplantada no banco de dados de estado do nó par.

Se você já possui um grande volume de dados e instala posteriormente o chaincode, a criação do índice na instalação pode levar algum tempo.
Da mesma forma, se você já possui um grande volume de dados e confirma a definição de uma versão subsequente do chaincode, a criação do
índice pode levar algum tempo. Evite chamar funções chaincode que consultam o banco de dados de estado nesses momentos, pois a consulta ao
chaincode pode atingir o tempo limite enquanto o índice está sendo inicializado. Durante o processamento da transação, os índices serão
atualizados automaticamente quando os blocos forem confirmados no livro-razão. Se o par travar durante a instalação do chaincode, os índices
couchdb podem não ser criados. Se isso ocorrer, você precisará reinstalar o chaincode para criar os índices.

.. couchdb-configuration:

Configuração do CouchDB
-----------------------

O CouchDB é ativado como o banco de dados de estado alterando a opção de configuração ``stateDatabase`` de ``goleveldb`` no CouchDB. Além
disso, o ``couchDBAddress`` precisa ser configurado para apontar para o CouchDB a ser usado pelo nó par. As propriedades de nome de usuário
e senha devem ser preenchidas com um nome de usuário e senha de administrador se o CouchDB estiver configurado com um nome de usuário e uma
senha. Opções adicionais são fornecidas na seção ``couchDBConfig`` e estão documentadas no local. As alterações no *core.yaml* entrarão em
vigor imediatamente após reiniciar o nó par.

Você também pode usar variáveis de ambiente do docker para substituir os valores no *core.yaml*, por exemplo,
``CORE_LEDGER_STATE_STATEDATABASE`` e ``CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS``.

Abaixo está a seção ``stateDatabase`` de *core.yaml*:

.. code:: bash

    state:
      # stateDatabase - options are "goleveldb", "CouchDB"
      # goleveldb - default state database stored in goleveldb.
      # CouchDB - store state database in CouchDB
      stateDatabase: goleveldb
      # Limit on the number of records to return per query
      totalQueryLimit: 10000
      couchDBConfig:
         # It is recommended to run CouchDB on the same server as the peer, and
         # not map the CouchDB container port to a server port in docker-compose.
         # Otherwise proper security must be provided on the connection between
         # CouchDB client (on the peer) and server.
         couchDBAddress: couchdb:5984
         # This username must have read and write authority on CouchDB
         username:
         # The password is recommended to pass as an environment variable
         # during start up (e.g. LEDGER_COUCHDBCONFIG_PASSWORD).
         # If it is stored here, the file must be access control protected
         # to prevent unintended users from discovering the password.
         password:
         # Number of retries for CouchDB errors
         maxRetries: 3
         # Number of retries for CouchDB errors during peer startup
         maxRetriesOnStartup: 10
         # CouchDB request timeout (unit: duration, e.g. 20s)
         requestTimeout: 35s
         # Limit on the number of records per each CouchDB query
         # Note that chaincode queries are only bound by totalQueryLimit.
         # Internally the chaincode may execute multiple CouchDB queries,
         # each of size internalQueryLimit.
         internalQueryLimit: 1000
         # Limit on the number of records per CouchDB bulk update batch
         maxBatchUpdateSize: 1000
         # Warm indexes after every N blocks.
         # This option warms any indexes that have been
         # deployed to CouchDB after every N blocks.
         # A value of 1 will warm indexes after every block commit,
         # to ensure fast selector queries.
         # Increasing the value may improve write efficiency of peer and CouchDB,
         # but may degrade query response time.
         warmIndexesAfterNBlocks: 1

O CouchDB hospedado em contêineres Docker fornecidos com a Hyperledger Fabric tem a capacidade de definir o nome de usuário e a senha do
CouchDB como variáveis ​​de ambiente passadas em ``COUCHDB_USER`` e ``COUCHDB_PASSWORD`` usando o script do Docker Compose.

Para instalações do CouchDB fora das imagens docker fornecidas com a Fabric, o arquivo
`local.ini da instalação <http://docs.couchdb.org/en/2.1.1/config/intro.html#configuration-files>`__ deve ser editado para definir o nome de
usuário e a senha do administrador.

Os scripts Docker definem apenas o nome de usuário e a senha na criação do contêiner. O arquivo *local.ini* deve ser editado para alterar o
nome de usuário ou a senha após a criação do contêiner.

Se você optar por mapear a porta do contêiner fabric-couchdb para uma porta do host, verifique se você está ciente das implicações de
segurança. O mapeamento da porta do contêiner do CouchDB em um ambiente de desenvolvimento expõe a API REST do CouchDB e permite visualizar
o banco de dados por meio da interface da web do CouchDB (Fauxton). Em um ambiente de produção, você deve evitar o mapeamento da porta do
host para restringir o acesso ao contêiner do CouchDB. Somente o par poderá acessar o contêiner do CouchDB.

.. note:: As opções do do CouchDB são lidas em cada inicialização dos pares.

.. good-practices-for-queries:

Boas práticas para consultas
----------------------------

Evite usar o chaincode para consultas que resultem em uma varredura de todo o banco de dados do CouchDB. As leituras completas do banco de
dados resultarão em longos tempos de resposta e degradarão o desempenho da sua rede. Você pode seguir algumas das etapas a seguir para
evitar consultas longas:

- Ao usar consultas JSON:

    * Certifique-se de criar índices no pacote do chaincode.
    * Evite operadores de consulta como ``$or``, ``$in`` e ``$regex``, que levam a verificações completas do banco de dados.

- Para consultas de intervalo, consultas de chave composta e consultas JSON:

    * Utilize suporte de paginação em vez de um grande conjunto de resultados.

- Se você deseja criar um painel ou coletar dados agregados como parte do seu aplicativo, pode consultar um banco de dados fora da cadeia
  que replica os dados da sua rede blockchain. Isso permitirá que você consulte e analise os dados da blockchain em um armazenamento de
  dados otimizado para suas necessidades, sem degradar o desempenho da sua rede ou interromper as transações. Para conseguir isso, os
  aplicativos podem usar eventos de bloco ou chaincode para gravar dados de transação em um banco de dados ou mecanismo de análise fora da
  cadeia. Para cada bloco recebido, o aplicativo ouvinte de blocos percorre as transações de bloco e constrói um armazenamento de dados
  usando as gravações de chave/valor do ``rwset`` de cada transação válida. O :doc:`peer_event_services` fornece eventos reproduzíveis para
  garantir a integridade dos armazenamentos de dados posteriores.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
