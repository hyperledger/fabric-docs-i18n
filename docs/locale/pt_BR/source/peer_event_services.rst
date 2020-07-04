Serviços de eventos em canal 
============================

.. general-overview:

Visao geral
-----------

Nas versões anteriores da Fabric, o serviço de eventos do par era conhecido como hub de eventos. Esse serviço enviava eventos sempre que um 
novo bloco era adicionado ao livro razão do parceiro, independentemente do canal ao qual esse bloco pertencia, e só era acessível aos 
membros da organização que executava o parceiro de eventos (ou seja, aquele que estava conectado para eventos).

A partir da v1.1, existem novos serviços que fornecem eventos. Esses serviços usam um design totalmente diferente para fornecer eventos por 
canal. Isso significa que o registro de eventos ocorre no nível do canal, e não no par, permitindo um controle mais refinado do acesso aos 
dados do nó. As solicitações para receber eventos são aceitas a partir de identidades externas à organização do par (conforme definido pela 
configuração do canal). Isso também fornece maior confiabilidade e uma maneira de receber eventos que podem ter sido perdidos (devido a um problema de conectividade ou porque o par está ingressando em uma rede que já está em execução).

.. available-services:

Serviços Disponíveis
--------------------

* ``Deliver``

Este serviço envia blocos inteiros que foram confirmados no livro-razão. Se algum evento foi definido por um chaincode, ele pode ser 
encontrado dentro do ``ChaincodeActionPayload`` do bloco.

* ``DeliverWithPrivateData``

Este serviço envia os mesmos dados que o serviço ``Deliver`` e inclui adicionalmente quaisquer dados de coleções privadas que a organização
do cliente está autorizada a acessar.

* ``DeliverFiltered``

Este serviço envia blocos "filtrados", conjuntos mínimos de informações sobre blocos que foram confirmados no livro-razão. Destina-se a ser 
usado em uma rede em que os proprietários dos nós pares desejam que clientes externos recebam, principalmente, informações sobre suas 
transações e o status dessas transações. Se algum evento tiver sido definido por um chaincode, ele poderá ser encontrado dentro de 
``FilteredChaincodeAction`` do bloco filtrado.

.. note:: O conteúdo útil dos eventos do chaincode não será incluída nos blocos filtrados.

.. how-to-register-for-events:

Como se registrar para eventos
------------------------------

O registro de eventos é feito enviando um envelope contendo uma mensagem de informações de busca de entrega ao par que contém as posições de 
início e fim desejados, o comportamento de busca (espere até que esteja pronto ou falhe se não estiver pronto). Existem variáveis auxiliares 
``SeekOldest`` e ``SeekNewest`` que podem ser usadas para indicar o bloco mais antigo (por exemplo, o primeiro) ou o bloco mais recente (por 
exemplo, o último) no livro-razão. Para que os serviços enviem eventos indefinidamente, a mensagem ``SeekInfo`` deve incluir uma posição de 
parada de ``MAXINT64``.

.. note:: Se o TLS estiver ativado no par, o hash do certificado TLS deverá ser definido no cabeçalho do canal do envelope.

Por padrão, os serviços de eventos usam a política de Leitores de Canal para determinar se devem autorizar os clientes solicitantes para eventos.

.. overview-of-deliver-response-messages:

Visão geral de entrega de mensagens de resposta
-----------------------------------------------

Os serviços de eventos enviam mensagens ``DeliverResponse``.

Cada mensagem contém um dos dados seguintes:

 * status -- código de status HTTP. Cada um dos serviços retornará o código de falha apropriado se ocorrer alguma falha, caso contrário, ele 
   retornará ``200 - SUCCESS`` assim que o serviço concluir o envio de todas as informações solicitadas pela mensagem ``SeekInfo``.
 * block -- retornado apenas pelo serviço ``Deliver``.
 * dados privados e de bloco -- retornados apenas pelo serviço ``DeliverWithPrivateData``.
 * bloco filtrado -- retornado apenas pelo serviço ``DeliverFiltered``.

Um bloco filtrado contém:

 * ID do canal.
 * número (ou seja, o número do bloco).
 * matriz de transações filtradas.
 * ID da transação.

   * type (por exemplo, ``ENDORSER_TRANSACTION``, ``CONFIG``).
   * código de validação de transação.

 * ações de transação filtradas.
     * matriz de ações do chaincode filtradas.
        * evento chaincode para a transação (com o conteúdo detalhado).

Documentação de evento do SDK
-----------------------------

Para mais detalhes sobre o uso dos serviços de eventos, consulte a `documentação do SDK. <https://hyperledger.github.io/fabric-sdk-node/{BRANCH}/tutorial-channel-events.html>`_

.. Licensed under Creative Commons Attribution 4.0 International License
    https://creativecommons.org/licenses/by/4.0/
