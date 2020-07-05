.. protocolo-de-disseminacao-de-dados-gossip:

Protocolo de disseminação de dados gossip
=========================================

A Hyperledger Fabric otimiza o desempenho, a segurança e a escalabilidade da rede blockchain, dividindo a carga de trabalho entre pares de 
execução de transação (endossando e confirmando) e nós de ordens de transação. Essa dissociação das operações da rede requer um protocolo de 
disseminação de dados seguro, confiável e escalável para garantir a integridade e consistência dos dados. Para atender a esses requisitos, 
a Fabric implementa um **protocolo de disseminação de dados gossip**.

.. gossip-protocol:

Protocolo de gossip
-------------------

Os pares aproveitam o gossip para transmitir os dados do livro-razão e do canal de maneira escalável. As mensagens gossip são contínuas e 
cada nó em um canal recebe constantemente dados atuais e consistentes do livro-razão de vários pares. Cada mensagem gossip é assinada, 
permitindo assim que os participantes Bizantinos que enviam mensagens falsas sejam facilmente identificados e a distribuição da(s) 
mensagem(s) para destinos indesejados seja evitada. Os pares afetados por atrasos, partições de rede ou outras causas que resultam em blocos 
perdidos acabarão sendo sincronizados com o estado atual do razão, entrando em contato com os pares em posse desses blocos ausentes.

O protocolo de disseminação de dados com base em gossip executa três funções principais em uma rede Fabric:

1. Gerencia a descoberta de pares e a associação ao canal, identificando continuamente os membros membros disponíveis e eventualmente, 
   detectando os pares que ficaram offline.
2. Divulga os dados do livro-razão entre todos os pares de um canal. Qualquer par com dados fora de sincronia com o restante do canal 
   identifica os blocos ausentes e sincroniza-se copiando os dados corretos.
3. Atualiza os pares recém-conectados, permitindo a transferência de atualização de estado ponto-a-ponto dos dados do livro-razão.

A transmissão baseada em gossip opera nos pares que recebem mensagens de outros pares do canal e, em seguida, encaminham essas mensagens 
para um número de pares selecionados aleatoriamente no canal, onde esse número é uma constante configurável. Os pares também podem exercer 
um mecanismo de recebimento em vez de aguardar a entrega de uma mensagem. Esse ciclo se repete, com o resultado da associação ao canal, as 
informações do livro-razão e do estado são mantidas continuamente atualizadas e sincronizadas. Para a disseminação de novos blocos, o 
**líder** no canal retira os dados do serviço de ordens e inicia a disseminação gossip para os pares em sua própria organização.

.. leader-election:

Eleição do líder
----------------

O mecanismo de eleição do líder é usado para **eleger** um par por organização que manterá a conexão com o serviço de ordens e iniciará a
distribuição dos blocos recém-chegados entre os pares de sua própria organização. A alavancagem da eleição do líder fornece ao sistema a 
capacidade de utilizar com eficiência a largura de banda do serviço de ordens. Existem dois modos de operação possíveis para um módulo de 
eleição de líder:

1. **Estático** --- um administrador do sistema configura manualmente um par em uma organização para ser o líder.
2. **Dinâmico** --- pares executam um procedimento de eleição de líder para selecionar um par em uma organização para se tornar líder.

.. static-leader-election:

Eleição estática do líder
~~~~~~~~~~~~~~~~~~~~~~~~~

A eleição estática do líder permite definir manualmente um ou mais pares dentro de uma organização como pares líderes. Observe, no entanto, 
que muitos pares conectados ao serviço de ordens pode resultar no uso ineficiente da largura de banda. Para ativar o modo de eleição 
estática do líder, configure os seguintes parâmetros na seção ``core.yaml``:

::

    peer:
        # Gossip related configuration
        gossip:
            useLeaderElection: false
            orgLeader: true

Como alternativa, esses parâmetros podem ser configurados e substituídos por variáveis ambientais:

::

    export CORE_PEER_GOSSIP_USELEADERELECTION=false
    export CORE_PEER_GOSSIP_ORGLEADER=true


.. note:: A configuração a seguir manterá o par no modo de espera, ou seja, o par não tentará se tornar um líder:

::

    export CORE_PEER_GOSSIP_USELEADERELECTION=false
    export CORE_PEER_GOSSIP_ORGLEADER=false

2. Definir ``CORE_PEER_GOSSIP_USELEADERELECTION`` e ``CORE_PEER_GOSSIP_ORGLEADER`` com o valor ``true`` é ambíguo e levará a um erro.
3. Na configuração estática, o administrador é responsável por fornecer alta disponibilidade do nó líder em caso de falha.

.. dynamic-leader-election:

Eleição dinâmica de líderes
~~~~~~~~~~~~~~~~~~~~~~~~~~~

A eleição dinâmica de líderes permite que os pares da organização **elejam** um par que se conectará ao serviço de ordens e obterá novos 
blocos. Esse líder é eleito para os colegas de uma organização de forma independente.

Um líder eleito dinamicamente envia mensagens de **batimento cardíaco** para o resto dos colegas como uma evidência de vivacidade. Se um ou 
mais colegas não receberem atualizações de **batimentos cardíacos** durante um período determinado de tempo, eles elegerão um novo líder.

No pior cenário de partição uma rede, haverá mais de um líder ativo para a organização garantir resiliência e disponibilidade e permitir que 
os pares da organização continuem progredindo. Após a cura da partição da rede, um dos líderes renuncia à sua liderança. Em um estado 
estável, sem partições de rede, haverá **apenas** um líder ativo conectado ao serviço de ordens.

A seguinte configuração controla a frequência das mensagens de **pulsação** do líder:

::

    peer:
        # Gossip related configuration
        gossip:
            election:
                leaderAliveThreshold: 10s

Para habilitar a eleição dinâmica do líder, os seguintes parâmetros precisam ser configurados no ``core.yaml``:

::

    peer:
        # Gossip related configuration
        gossip:
            useLeaderElection: true
            orgLeader: false

Como alternativa, esses parâmetros podem ser configurados e substituídos por variáveis de ambiente:

::

    export CORE_PEER_GOSSIP_USELEADERELECTION=true
    export CORE_PEER_GOSSIP_ORGLEADER=false

.. anchor-peers:

Pares de âncora
---------------

Os pares âncora são usados ​​pela gossip para garantir que pares de diferentes organizações se conheçam.

Quando um bloco de configuração que contém uma atualização para os pares âncoras é confirmado, os demais pares se conectam aos pares âncoras 
e aprendem com eles sobre todos os pares conhecidos pelos pares de âncoras. Depois que pelo menos um colega de cada organização entrar em 
contato com um par âncora, os nós âncora aprendem sobre todos os colegas do canal. Como a comunicação gossip é constante, e como os pares 
sempre pedem que sejam informados sobre a existência de alguém que eles desconhecem, uma visão comum da associação pode ser estabelecida 
para um canal.

Por exemplo, vamos assumir que temos três organizações --- `A`,` B`, `C` --- no canal e um único ponto de ancoragem --- `peer0.orgC` --- 
definido para a organização `C `. Quando `peer1.orgA` (da organização` A`) entra em contato com `peer0.orgC`, ele informa sobre `peer0.orgA`. 
E quando mais tarde o `peer1.orgB` entrar em contato com o `peer0.orgC`, o último diria ao primeiro sobre o `peer0.orgA`. Desse ponto em 
diante, as organizações `A` e `B` começariam a trocar informações de membros diretamente sem a ajuda de `peer0.orgC`.

Como a comunicação entre as organizações depende do gossip para funcionar, deve haver pelo menos um ponto de ancoragem definido na 
configuração do canal. É altamente recomendável que toda organização forneça seu próprio conjunto de pontos-âncora para alta disponibilidade 
e redundância. Observe que o ponto de ancoragem não precisa ser o mesmo que o líder.

.. external-and-internal-endpoints:

Ponto de contatos externos e internos
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Para que o gossip funcione efetivamente, os pares precisam obter as informações de ponto de contato de seus pares em sua própria organização 
e de outras organizações.

Quando um par é inicializado, ele usa ``peer.gossip.bootstrap`` em seu ``core.yaml`` para se anunciar e trocar informações de associação, 
criando uma visão de todos os pares disponíveis em sua própria organização.

A propriedade ``peer.gossip.bootstrap`` no ``core.yaml`` do par é usada para inicializar o gossip **dentro de uma organização**. Se você 
estiver usando gossip, normalmente configurará todos os pares da organização para apontar para um conjunto inicial de pares de 
autoinicialização (você pode especificar uma lista de pares separados por espaço). O ponto de contato interno geralmente é calculado 
automaticamente pelo próprio par ou apenas passado explicitamente através de ``core.peer.address`` em ``core.yaml``. Se você precisar 
sobrescrever esse valor, poderá exportar ``CORE_PEER_GOSSIP_ENDPOINT`` como uma variável de ambiente.

As informações de inicialização são igualmente necessárias para estabelecer a comunicação **entre as organizações**. As informações iniciais 
de auto-inicialização da organização cruzada são fornecidas através da configuração "pontos de ancoragem" descrita acima. Se você quiser que 
outros colegas da sua organização sejam conhecidos por outras organizações, defina o ``peer.gossip.externalendpoint`` no ``core.yaml`` do 
seu par. Se isso não estiver definido, as informações do ponto de contato do par não serão transmitidas para os pares de outras organizações.

Para definir essas propriedades, defina:

::

    export CORE_PEER_GOSSIP_BOOTSTRAP=<uma lista de pontos de contato dentro da organização do parceiro>
    export CORE_PEER_GOSSIP_EXTERNALENDPOINT=<o ponto de contato conhecido fora da organização>

.. gossip-messaging:

Mensagens gossip
----------------

Os pares online indicam sua disponibilidade transmitindo continuamente mensagens "ativas", cada uma contendo o ID da **infra-estrutura de 
chave pública (PKI)** e a assinatura do remetente sobre a mensagem. Os nós pares mantêm a associação ao canal coletando essas mensagens 
ativas, se nenhum par receber uma mensagem ativa de um par específico, esse par "morto" será eventualmente eliminado da associação ao canal. 
Como as mensagens "ativas" são assinadas criptograficamente, os pares mal-intencionados nunca podem se passar por outros, pois não possuem 
uma chave de assinatura autorizada por uma autoridade de certificação raiz.

Além do encaminhamento automático de mensagens recebidas, um processo de reconciliação de estado sincroniza **estado global** entre pares em 
cada canal. Cada par puxa continuamente blocos de outros pares no canal, a fim de reparar seu próprio estado se forem identificadas 
discrepâncias. Como a conectividade fixa não é necessária para manter a disseminação de dados com base em gossip, o processo fornece 
consistência e integridade dos dados para o razão compartilhado, incluindo tolerância a falhas nos nós.

Como os canais são segregados, os pares de um canal não podem enviar mensagens ou compartilhar informações com nenhum outro canal. Embora 
qualquer par possa pertencer a vários canais, as mensagens particionadas impedem a disseminação de blocos para pares que não estão no canal, 
aplicando políticas de roteamento de mensagens com base nas assinaturas de um canal de pares.

.. note:: 1. A segurança das mensagens ponto-a-ponto é tratada pela camada TLS dos pares e não requer assinaturas. Os pares são autenticados 
          por seus certificados, atribuídos por uma CA. Embora os certificados TLS também sejam usados, são os certificados de pares que são 
          autenticados na camada gossip. Os blocos do livro-razão são assinados pelo serviço de ordens e entregues aos pares líderes em um 
          canal.

          2. A autenticação é governada pelo provedor de serviços de associação para o par. Quando o ponto se conecta ao canal pela primeira 
          vez, a sessão TLS se liga à identidade da associação. Isso essencialmente autentica cada ponto no ponto de conexão, com relação à 
          participação na rede e no canal.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
