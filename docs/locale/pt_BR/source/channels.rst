Canais
======

Um ``canal`` da Hyperledger Fabric é uma "sub-rede" privada de comunicação entre dois ou mais membros específicos da rede, com o objetivo de
realizar transações privadas e confidenciais. Um canal é definido por membros (organizações), pares âncoras por membro, livro-razão
compartilhado, aplicativo(s) de chaincode e nó(s) de serviço de ordens. Cada transação na rede é executada em um canal, onde cada parte deve
ser autenticada e autorizada a realizar transações nesse canal. Cada par que ingressa em um canal tem sua própria identidade fornecida por
um provedor de serviços de associação (MSP), que autentica cada par de seus pares e serviços de canal.

Para criar um novo canal, o SDK do cliente chama o chaincode do sistema de configuração e faz referência a propriedades como ``anchor peers``
e membros (organizações). Essa solicitação cria um ``bloco de gênese`` para o livro-razão do canal, que armazena informações de configuração
sobre as políticas do canal, membros e pontos de ancoragem. Ao adicionar um novo membro a um canal existente, esse bloco de gênese ou, se
aplicável, um bloco de reconfiguração mais recente, é compartilhado com o novo membro.

.. note:: Veja a seção :doc:`configtx` para mais detalhes sobre as propriedades e proto estruturas das transações de configuração.

A eleição de um ``nó líder`` para cada membro em um canal determina qual parceiro se comunica com o serviço de ordens em nome do membro. Se
nenhum líder for identificado, um algoritmo pode ser usado para identificar o líder. O serviço de consenso ordena as transações e as entrega,
em um bloco, para cada nó lider, que distribui o bloco para os nós membros e através do canal, usando o protocolo ``gossip``.

Embora qualquer nó âncora possa pertencer a vários canais e, portanto, manter vários registros, nenhum dado do registro pode passar de um
canal para outro. Essa separação de livros-razão, por canal, é definida e implementada pelo chaincode de configuração, pelo serviço de
associação de identidade e pelo protocolo de disseminação de dados gossip. A disseminação de dados, que inclui informações sobre transações,
estado do livro-razão e associação ao canal, é restrita a pares com associação verificável no canal. Esse isolamento de dados de pares e de
libro-razão, por canal, permite que membros da rede que exigem transações privadas e confidenciais coexistam com concorrentes de negócios e
outros membros restritos, na mesma rede blockchain.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
