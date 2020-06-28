# Recursos de canal

**Audiência**: Administradores de canal, administradores de nó

*Nota: este é um conceito avançado da Fabric que não é necessário para novos usuários ou desenvolvedores de aplicativos entenderem. No entanto, à medida que os canais e as redes amadurecem, o entendimento e o gerenciamento de recursos se tornam vitais. Além disso, é importante reconhecer que a atualização de recursos é um processo diferente, embora frequentemente relacionado, para a atualização de nós. Vamos descrever isso em detalhes neste tópico.*

Como a Fabric é um sistema distribuído que geralmente envolve várias organizações, é possível (e típico) que existam versões diferentes do código da Fabric em nós diferentes da rede e nos canais dessa rede. A Fabric permite isso --- não é necessário que todos os nós pares e de ordens estejam na mesmo de versão. De fato, oferecer suporte a diferentes níveis de versão é o que permite atualizações contínuas dos nós da Fabric.

O que é importante, é que redes e canais processem as coisas da mesma maneira, criando resultados determinísticos para coisas como atualizações de configuração de canais e invocações de chaincode. Sem resultados determinísticos, um ponto em um canal pode invalidar uma transação, enquanto outro ponto pode validá-la.

Para esse fim, a Fabric define os níveis dos chamados "recursos". Esses recursos, definidos na configuração de cada canal, garantem o determinismo, definindo um nível no qual os comportamentos produzem resultados consistentes. Como você verá, esses recursos têm versões intimamente relacionadas às versões binárias dos nós. Os recursos permitem que os nós executados em diferentes níveis de versão se comportem de maneira compatível e consistente, dada a configuração do canal em uma altura específica do bloco. Você também verá que existem recursos em muitas partes da árvore de configuração, definidas ao longo das linhas de administração para tarefas específicas.

Como você verá, às vezes é necessário atualizar seu canal para um novo nível de capacidade para ativar um novo recurso.

<a name="node-versions-and-capability-versions"></a>

## Versões de nós e versões de recursos

Se você estiver familiarizado com a Hyperledger Fabric, estará ciente de que ela segue um padrão típico de versão: v1.1, v1.2.1, v2.0, etc. Essas versões referem-se a releases e suas versões binárias relacionadas.

Os recursos seguem a mesma convenção de versão. Existem recursos da v1.1 e da v1.2 e da 2.0 e assim por diante. Mas é importante observar algumas distinções.

* **Não há necessariamente um novo nível de capacidade em cada versão**.
  A necessidade de estabelecer um novo recurso é determinada caso a caso e depende principalmente da compatibilidade com versões anteriores de novos recursos e versões binárias mais antigas. A adição do serviço de ordens do Raft na v1.4.1, por exemplo, não mudou a maneira como as transações ou funções do serviço de orden são tratadas e, portanto, não exigiu o estabelecimento de novos recursos. [Dados privados](./private-data/private-data.html), por outro lado, não podiam ser manipulados por pares antes da v1.2, exigindo o estabelecimento de um nível de capacidade da v1.2. Como nem toda versão contém um novo recurso (ou uma correção de bug) que altera a maneira como as transações são processadas, certas versões não exigirão novos recursos (por exemplo, v1.4), enquanto outras terão apenas novos recursos em níveis específicos (como como v1.2 e v1.3). Discutiremos os "níveis" de recursos e onde eles residem na árvore de configuração posteriormente.

* **Os nós devem estar pelo menos no nível de certos recursos em um canal**.
  Quando um nó se junta a um canal, ele lê todos os blocos no razão sequencialmente, começando com o bloco genesis do canal e continuando pelos blocos de transação e quaisquer blocos de configuração subseqüentes. Se um nó, por exemplo, um par, tentar ler um bloco que contém uma atualização para um recurso que ele não entende (por exemplo, um par v1.4.x tentando ler um bloco que contém um recurso de aplicativo v2.0), **o par irá falhar**. Esse comportamento de travamento é intencional, pois um par v1.4.x não deve tentar validar ou confirmar nenhuma transação além deste ponto. Antes de ingressar em um canal, **verifique se o nó tem pelo menos o nível da versão Fabric (binária) dos recursos especificados na configuração do canal relevante para o nó**. Discutiremos quais recursos são relevantes para quais nós posteriormente. No entanto, como nenhum usuário deseja que seus nós travem, é altamente recomendável atualizar todos os nós para o nível necessário (preferencialmente, para a versão mais recente) antes de tentar atualizar os recursos. Isso está de acordo com a recomendação padrão da Fabric de **sempre** estar nos mais recentes níveis binários e de capacidade.

Se os usuários não puderem atualizar seus binários, os recursos deverão ser deixados nos níveis mais baixos. Os binários e recursos de nível inferior ainda funcionarão juntos como devem. No entanto, lembre-se de que é uma prática recomendada sempre atualizar para novos binários, mesmo se um usuário optar por não atualizar seus recursos. Como os próprios recursos também incluem correções de bugs, é sempre recomendável atualizar os recursos assim que os binários da rede os suportam.

<a name="capability-configuration-groupings"></a>

## Agrupamentos de configuração de capacidade

Como discutimos anteriormente, não há um único nível de capacidade que englobe um canal inteiro. Em vez disso, existem três recursos, cada um representando uma área de administração.

* **Ordenação**: esses recursos controlam as tarefas e o processamento exclusivo do serviço de ordens. Como esses recursos não envolvem processos que afetam as transações ou os pares, a atualização deles cabe exclusivamente aos administradores do serviço de ordens (os pares não precisam entender os recursos da ordem e, portanto, não travam, independentemente da atualização do recurso de ordem). Observe que esses recursos não foram alterados entre a v1.1 e a v1.4.2. No entanto, como veremos na seção **canal**, isso não significa que os nós de ordens da v1.1 funcionem em todos os canais com níveis de capacidade abaixo da v1.4.2.

* **Aplicativo**: esses recursos controlam tarefas e processamento exclusivo para os pares. Como os administradores de serviço de ordens não têm nenhum papel na decisão sobre a natureza das transações entre organizações pares, a alteração desse nível de capacidade recai exclusivamente nas organizações pares. Por exemplo, Dados Privados podem ser ativados apenas em um canal com o recurso de grupo de aplicativos v1.2 (ou superior) ativado. No caso de Dados Privados, esse é o único recurso que deve ser ativado, pois nada na maneira como os Dados Privados funcionam exige uma alteração na administração do canal ou na maneira como o serviço de ordens processa transações.

* **Canal**: esse agrupamento abrange tarefas que são **administradas em conjunto** pelas organizações parceiras e pelo serviço de ordens. Por exemplo, esse é o recurso que define o nível em que são processadas as atualizações de configuração do canal, iniciadas pelas organizações de pares e orquestradas pelo serviço de ordens. Em um nível prático, **esse agrupamento define o nível mínimo para todos os binários em um canal, pois os nós de ordens e os pares devem estar pelo menos no nível binário correspondente a esse recurso para processar o recurso**.

Os recursos **ordenador** e **canal** de um canal são herdados por padrão do canal do sistema de ordens, onde modificá-los é da exclusiva responsabilidade dos administradores de serviços de ordens. Como resultado, as organizações pares devem inspecionar o bloco de gênese de um canal antes de associar seus pares a esse canal. Embora a capacidade do canal seja administrada pelos solicitantes no canal do sistema do ordenador (assim como a associação ao consórcio), é típico e esperado que os administradores de ordens se coordenem com os administradores do consórcio para garantir que a capacidade do canal seja atualizada apenas quando o consórcio está pronto para isso.

Como o canal do sistema de ordens não define um recurso de **aplicativo**, esse recurso deve ser especificado no perfil do canal ao criar o bloco genesis para o canal.

**Tenha cuidado** ao especificar ou modificar um recurso de aplicativo. Como o serviço de ordens não valida a existência do nível de capacidade, permitirá que um canal seja criado (ou modificado) para conter, por exemplo, um recurso de aplicativo v1.8, mesmo que não exista esse recurso. Qualquer par que tentar ler um bloco de configuração com esse recurso travaria, como mostramos, e mesmo que fosse possível modificar o canal mais uma vez para um nível de recurso válido, isso não importaria, pois nenhum colega seria capaz de superar o bloco com o recurso v1.8 inválido.

Para uma visão completa dos recursos atuais válidos para ordens, aplicativos e canais, consulte um [exemplo de arquivo `configtx.yaml`](http://github.com/hyperledger/fabric/blob/{BRANCH}/sampleconfig/configtx.yaml), que os lista na seção "Recursos".

Para obter informações mais específicas sobre recursos e onde eles residem na configuração do canal, consulte [definindo requisitos de recursos](capability_requirements.html).

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
