# Introdução

Em termos gerais, blockchain é um sistema de livro-razão com registros 
imutáveis, mantido em uma rede distribuída por múltiplos nós pares 
(_peer nodes_). Esses nós mantêm uma cópia do livro-razão contendo as 
transações que foram validadas por um protocolo de consenso e agrupadas
em blocos que inclue um hash que liga cada bloco ao bloco anterior.

A aplicação amplamente reconhecida do blockchain é a criptomoeda 
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin), embora outras moedas 
tenham seguido seus passos. A Ethereum, uma criptomoeda alternativa,
adotou uma abordagem diferente, integrando muitas das características
do Bitcoin, mas adicionando contratos inteligentes (_smart contracts_) 
para criar uma plataforma para aplicativos distribuídos. Bitcoin e 
Ethereum se enquadram em uma classe de blockchain que classificamos 
como tecnologia de blockchain pública não permissionada
(_public permissionless_). Basicamente, são redes públicas, abertas a 
qualquer pessoa, onde os participantes interagem anonimamente.

À medida que a popularidade do Bitcoin, Ethereum e algumas outras 
tecnologias derivadas aumentavam, o interesse em aplicar as tecnologias 
subjacentes do blockchain, como, registro distribuído e a plataforma 
de aplicativos distribuídos em casos de uso mais inovadores para
_empresas_ também crescia. No entanto, muitos casos de uso corporativos
exigem características de desempenho que as tecnologias blockchain 
sem permissão não conseguem (atualmente) atender. Além disso, em 
muitos casos de uso, a identidade dos participantes é um requisito 
obrigatório, como no caso de transações financeiras, onde é 
obrigatório conhecer o consumidor (_Know-Your-Customer - KYC_) e 
regras antí-lavagem de dinheiro devem ser seguidas 
(_Anti-Money Laundering - AML_).

Para uso corporativo, precisamos considerar os seguintes requisitos:

- Os participantes devem ser identificados/identificáveis
- As redes precisam ser _permissionadas_
- Alta performance nas transações
- Baixa latência na confirmação das transações
- Privacidade e confidencialidade nas transações e nos dados 
referentes as transações comerciais

Embora muitas plataformas de blockchain antigas estejam sendo 
_adaptadas_ para uso corporativo, a Hyperledger Fabric foi _projetada_ 
para uso corporativo desde o início. As seções a seguir descrevem como
a Hyperledger Fabric (Fabric) se diferencia de outras plataformas de 
blockchain e descreve algumas das motivações para suas decisões de 
arquitetura.

## Hyperledger Fabric

A Hyperledger Fabric é uma plataforma de tecnologia de livro-razão 
distribuído (Distributed Ledger Technology - DLT) de nível empresarial
e código aberto, projetada para uso em ambientes empresariais e que
fornece alguns recursos diferenciados importantes em relação a outras 
plataformas populares de livro-razão distribuído ou blockchain.

Um ponto chave de diferenciação é que o Hyperledger foi estabelecido
sob a Linux Foundation, que possui uma longa e muito bem-sucedida 
história de fomentar projetos de código aberto sob 
**governança aberta**, que desenvolvem comunidades sustentáveis fortes
e ecossistemas prósperos. A Hyperledger é governada por um comitê de
direção técnica diversificada e o projeto Hyperledger Fabric por um
conjunto diversificado de mantenedores de várias organizações. Tem uma
comunidade de desenvolvimento que ultrapassa 35 organizações e
quase 200 desenvolvedores desde suas primeiras versões.

A Fabric possui uma arquitetura altamente **modular** e
**configurável**, permitindo inovação, versatilidade e otimização para 
uma ampla gama de casos de uso da indústria, incluindo bancos,
finanças, seguros, assistência médica, recursos humanos, cadeia de 
suprimentos e até distribuição de música digital.

A Fabric, é a primeira plataforma de livro-razão distribuído a 
suportar **contratos inteligentes criados em linguagens de programação
de uso geral** como Java, Go e Node.js, em vez de linguagens 
específicas de domínio restrito (Domain-specific Languages - DSL). 
Isso significa que a maioria das empresas já possui o conjunto de 
habilidades necessárias para desenvolver contratos inteligentes e não
é necessário treinamento adicional para aprender um novo 
idioma ou DSL.

A plataforma Fabric também é **permissionada**, o que significa que, 
diferente de uma rede pública, sem identificação, os participantes são 
conhecidos uns pelos outros, em vez de anônimos e _totalmente_ não 
confiáveis. Isso significa que, embora os participantes não confiem 
plenamente uns nos outros (eles podem, por exemplo, ser concorrentes 
no mesmo mercado), uma rede pode ser operada sob um modelo de 
governança baseada na confiança que _existe_ entre os participantes, 
como um contrato ou modelo para reger divergências.

Um dos diferenciais mais importantes da plataforma é o suporte aos
**protocolos de consenso conectáveis**, o que permite que a plataforma 
seja mais customizável e atenda modelos de confiança e casos de uso
específicos. Por exemplo, quando implantado em uma única empresa, ou 
operado por uma autoridade confiável, consenso tolerante a falha
bizantina pode ser considerado desnecessário pois impacta na performance
e na taxa de transferência de dados. Em situações assim, um protocolo
de consenso [tolerante a falhas](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT)
pode ser mais do que adequado, enquanto que, em caso de uso 
descentralizado, um método mais tradicional de consenso com um
protocolo [tolerante a falha bizantina](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)
(BFT) pode ser necessário.

A Fabric pode suportar protocolos de consenso que **não se baseiam em
criptomoeda** para incentivar mineração ou para promover a execução
de contratos inteligentes. Evitar uma criptomoeda reduz alguns vetores
significativos de risco/ataque. A ausência de operações de mineração 
criptográfica significa que a plataforma pode ser implementado com 
aproximadamente o mesmo custo operacional que qualquer outro sistema 
distribuído.

A combinação desses recursos de design diferenciados faz da Fabric uma
das **plataformas com melhor desempenho** disponíveis hoje, tanto em
termos de processamento de transações e da latência na confirmação da 
transação, além de permitir **privacidade e confidencialidade** nas 
transações e nos contratos inteligentes (o que a Fabric chama 
"chaincode") que os implementa.

Vamos explorar esses recursos diferenciadores em mais detalhes.

## Modularidade

A Hyperledger Fabric foi arquitetada especificamente para ter uma
arquitetura modular. Seja com consenso conectável, gerenciamento de 
identidade conectável de protocolos como LDAP ou OpenID Connect, 
protocolos de gerenciamento de chaves ou bibliotecas criptográficas, a 
plataforma foi projetada em seu núcleo para ser configurada para
atender à diversidade de requisitos de casos de uso corporativos.

Em alto nível, a Fabric é composta pelos seguintes componentes 
modulares:

- Um _serviço de pedidos_ conectável estabelece um consenso na ordem 
das transações e depois transmite blocos aos pares.
- Um _provedor de serviços de associação_ conectável é responsável por
associar entidades na rede com identidades criptográficas.
- Um serviço opcional de _comunicação ponto-a-ponto_ divulga os blocos
produzidos pelo serviço de pedidos aos outros pares.
- Contratos inteligentes ("chaincode") executados isoladamente em um 
ambiente de contêiner (por exemplo, Docker). Eles podem ser escritos
em linguagens de programação padrão, mas não tem acesso direto ao 
do livro-razão.
- O livro-razão pode ser configurado para suportar uma variedade de
SGBDs.
- Ter políticas de reconhecimento e validação conectáveis e que possam
ser configurados independentemente por cada aplicativo.

Existe consenso no mercado de que não existe "um blockchain único
para tudo". A Hyperledger Fabric pode ser configurada de várias 
maneiras para satisfazer as diversas necessidades de vários casos de 
uso.

## Blockchains Permissionada ou Não Permissionada

Em uma blockchain **sem permissão** (ou não permissionada), praticamente 
qualquer um pode participar e todos os participants são anônimos. 
Nesse contexto, pode não haver outra confiança senão o estado da 
blockchain, que antes de mais nada, é imutável. Para atenuar essa 
falta de confiança, blockchains não permissionadas normalmente 
empregam uma criptomoeda nativa "minerada" ou taxa por transação para
fornecer incentivo econômico para compensar os custos extraordinários 
na participação em um protocolo de consenso bizantino tolerante a 
falhas com base na "prova de trabalho" (PoW).

As blockchains **com permissão** (ou permissionadas), por outro lado, 
operam uma blockchain com um conjunto conhecido de participantes, 
identificados e frequentemente controlados, que operam sob um modelo 
de governança que promove um certo grau de confiança. Uma blockchain
permissionada fornece uma maneira de proteger as interações entre um 
grupo de entidades que têm um objetivo comum, mas que podem não 
confiar totalmente uma nas outras. Ao confiar nas identidades dos 
participantes, uma blockchain permissionada pode usar protocolos de
consenso mais tolerante a falhas (CFT) ou tolerante a falha
bizantina (BFT), que não exigem mineração dispendiosa.

Além disso, no contexto permissionado, o risco da introdução 
intencional de um código malicioso por um participante usando um 
contrato inteligente diminui. Primeiro, os participantes se conhecem e
todas suas ações, seja enviar transações, modificar a configuração da 
rede ou implantar um contrato inteligente, são registradas no 
blockchain, seguindo uma política de endosso que foi estabelecida para 
a rede e o tipo de transação. Por não ser completamente anônimo, a
parte culpada pode ser facilmente identificada e o incidente tratado 
de acordo com as regras do modelo de governança.

## Contratos Inteligentes

Um contrato inteligente ("smart contract"), o que a Fabric chama de 
"chaincode", funciona como um aplicativo distribuído confiável, que 
garante sua segurança/confiabilidade no blockchain e do consenso 
subjacente entre os pares. É a lógica de negócios em um aplicativo
blockchain.

Existem três pontos principais que se aplicam a contratos inteligentes,
especialmente quando aplicados a uma plataforma:

- muitos contratos inteligentes são executados simultaneamente na rede,
- eles podem ser implantados dinamicamente (em muitos casos por qualquer
pessoa), e
- o código do aplicativo deve ser tratado como não confiável, 
potencialmente malicioso.

A maioria das plataformas existentes de blockchain que suportam 
contratos inteligentes segue uma arquitetura de **ordena-executa** 
na qual o protocolo de consenso:

- valida e ordena as transações e depois as propaga para todos os nós 
pares,
- então cada par executa as transações sequencialmente.

A arquitetura ordena-executa pode ser encontrada em praticamente todos 
os sistemas de blockchain existentes, desde plataformas públicas/não 
permissionada, como na [Ethereum](https://ethereum.org/) (com consenso 
baseado em PoW), como em plataformas permissionadas como 
[Tendermint](http://tendermint.com/), [Cadeia](http://chain.com/) e
[Quorum](http://www.jpmorgan.com/global/Quorum).

Os contratos inteligentes executados em uma blockchain que opera com 
a arquitetura ordena-executa devem ser determinísticos; caso 
contrário, o consenso nunca poderá ser alcançado. Para solucionar o 
problema do não determinismo, muitas plataformas exigem que os contratos
inteligentes sejam escritos em um idioma não padrão ou específico do 
domínio (como [Solidity](https://solidity.readthedocs.io/en/v0.4.23/))
para que operações não determinísticas possam ser eliminadas. Isso
dificulta uma ampla adoção dessas plataformas, pois requer que os 
desenvolvedores aprendam uma nova linguagem para escrever os contratos 
inteligentes, o que pode levar a erros de programação.

Além disso, como todas as transações são executadas sequencialmente 
por todos os nós, o desempenho e a escala são limitados. O fato de o 
código do contrato inteligente ser executado em todos os nós do sistema 
exige que medidas complexas sejam tomadas para proteger o sistema como
um todo contra contratos potencialmente maliciosos, a fim de garantir
a resiliência do sistema.

## Uma Nova Abordagem

O Fabric introduz uma nova arquitetura para transações que chamamos de
**executa-ordena-valida**. Ele aborda os desafios de resiliência, 
flexibilidade, escalabilidade, desempenho e confidencialidade
enfrentados pelo modelo ordena-executa, separando o fluxo da transação 
em três etapas:

- _executa_ a transação, verifica sua validade, então a endossa,
- _ordena_ as transações usando um protocolo de consenso (conectável), 
e
- _valida_ as transações usando uma política de endosso específica do 
aplicativo antes de enviá-las ao livro-razão

Esse design se afasta radicalmente do paradigma ordena-executa, onde,
a Fabric executa as transações antes de chegar a um acordo final sobre
a ordem.

Na Fabric, uma política de endosso específica do aplicativo especifica 
quais nós pares, ou quantos deles, precisam garantir a execução correta
de um determinado contrato inteligente. Assim, cada transação só 
precisa ser executada (endossada) por um subconjunto dos nós pares para
satisfazer a política de endosso da transação. Isso permite a execução
paralela, aumentando o desempenho geral e a escala do sistema. Essa
primeira fase também **elimina qualquer não-determinismo**, pois os 
resultados inconsistentes podem ser filtrados antes do pedido.

Como eliminamos o não determinismo, a Fabric é a primeira tecnologia 
blockchain que **permite o uso de linguagens de programação de
mercado**.

## Privacidade e Confidencialidade

Como discutimos, em uma rede pública de blockchain não permissionada 
que aproveita o PoW para seu modelo de consenso, as transações são 
executadas em todos os nós. Isso significa que pode não haver 
confidencialidade nos contratos, nem nos dados de transação que eles 
processam. Toda transação e o código que a implementa são visíveis para
todos os nós da rede. Nesse caso, trocamos a confidencialidade do 
contrato e dos dados por consenso tolerante a falha bizantina
fornecido pela prova de trabalho (PoW).

Essa falta de confidencialidade pode ser problemática para muitos casos
de uso de negócios/empresas. Por exemplo, em uma rede de parceiros da 
cadeia de suprimentos, alguns consumidores podem receber taxas
preferenciais como meio de solidificar um relacionamento ou promover 
vendas adicionais. Se todo participante puder ver todos os contratos e
transações, torna-se impossível manter essas relações comerciais em 
uma rede completamente transparente --- todo mundo vai querer as 
tarifas preferenciais!

Como segundo exemplo, considere o setor de valores mobiliários, onde 
um trader que constrói uma posição (ou se desfaz de uma) e não gostaria 
que seus concorrentes soubessem disso, ou então eles tentariam entrar 
no jogo, enfraquecendo a aposta do trader.

Para abordar a falta de privacidade e confidencialidade e com o 
objetivo de atender aos requisitos de casos de uso corporativos, as 
plataformas blockchain adotaram uma variedade de abordagens. E todas
têm seus prós e contras.

Criptografar dados é uma abordagem para fornecer confidencialidade, no
entanto, em uma rede não permissionada que utiliza a prova de trabalho 
(PoW) no seu consenso, os dados criptografados estão em todos os nós. 
Com tempo e recursos computacionais suficientes, a criptografia pode 
ser quebrada. Para muitos casos de uso corporativo, o risco de suas
informações serem comprometidas é inaceitável.

As provas de conhecimento zero (ZKP) é outra área de pesquisa que está
sendo explorada para resolver esse problema, o trade-off aqui é que,
atualmente, computar um ZKP requer tempo e recursos computacionais
consideráveis. Portanto, o compromisso neste caso é o desempenho por
confidencialidade.

Em um contexto permissionado, pode se alavancar formas alternativas de 
consenso, pode-se explorar abordagens que restrinjam a distribuição de
informações confidenciais exclusivamente a nós autorizados.

A Hyperledger Fabric, por ser uma plataforma permissionada, permite a 
confidencialidade por meio de sua arquitetura de canal e o recurso de
[dados privados](./private-data/private-data.html). Nos canais, os 
participantes de uma rede Fabric estabelecem uma sub-rede na qual cada
membro tem visibilidade para de conjunto específico de transações. 
Assim, apenas os nós que participam de um canal têm acesso ao contrato
inteligente (chaincode) e aos dados transacionados, preservando a 
privacidade e a confidencialidade de ambos. Os dados privados permitem
divisões entre membros em um canal, permitindo a mesma proteção que os
canais sem a sobrecarga operacional de criar e manter um canal separado.

## Consenso Conectável

A ordem das transações é delegada a um componente modular de consenso 
que é logicamente desacoplado dos pares que executam as transações e
mantêm o livro-razão. Especificamente, o serviço de pedidos. Como o 
consenso é modular, sua implementação pode ser adaptada à necessidade
de confiança de uma implantação ou solução específica. Essa arquitetura
modular permite que a plataforma conte com um conjunto de ferramentas 
melhor estabelecido para ordens tolerantes a falhas (CFT) ou tolerante 
a falhas bizantina (BFT).

Atualmente a Fabric oferece uma implementação de serviço de ordens 
que suporta CFT com base na [biblioteca `etcd`](https://coreos.com/etcd/) 
do [protocolo Raft](https://raft.github.io/raft.pdf). Para mais 
informações sobre os serviços de ordem disponíveis no momento, consulte 
nossa [documentação conceitual sobre ordens](./orderer/ordering_service.html).

Observe que eles não são mutuamente exclusivos. Uma rede Fabric pode
ter vários serviços de ordem que suportem os aplicativos ou requisitos
de diferentes aplicativos.

## Performance e Escalabilidade

O desempenho de uma plataforma de blockchain pode ser afetado por 
inúmeras variáveis, como, tamanho da transação, tamanho do bloco, 
tamanho da rede, bem como limites do hardware, etc. O 
[Grupo de Trabalho de Performance e Escalabilidade](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group)
da Hyperledger Fabric atualmente trabalha em um modelo de performance
chamado [Hyperledger Caliper](https://wiki.hyperledger.org/projects/caliper).

Vários trabalhos de pesquisa foram publicados estudando e testando os 
recursos de performance do Hyperledger Fabric. O mais recente 
[escalou a Fabric para 20.000 transações por segundo](https://arxiv.org/abs/1901.00910).

## Conclusão

Qualquer avaliação séria das plataformas blockchain deve incluir a 
Hyperledger Fabric em sua lista final.

Combinados, os recursos diferenciadores da Fabric o tornam um sistema 
altamente escalável para blockchains com permissão, oferece suporte a 
assunções de confiança flexíveis que permitem à plataforma suportar
uma ampla variedade de casos de uso da indústria, desde governo, 
finanças, logística da cadeia de suprimentos, saúde e muito mais.

A Hyperledger Fabric é um dos projetos mais ativos da Hyperledger.
A construção da comunidade em torno da plataforma está crescendo 
constantemente, e a inovação oferecida a cada lançamento ultrapassa em
muito qualquer das outras plataformas corporativas de blockchain.

## Agradecimento

Esse conteúdo é derivado da revisão por pares 
["Hyperledger Fabric: um sistema operacional distribuído para blockchains permitidos"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem Barger, Vita Bortnikov, Christian Cachin,
Konstantinos Christidis, Angelo De Caro, David Enyeart, Christopher 
Ferris, Gennady Laventman, Yacov Manevich, Srinivasan Muralidharan,
Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh, Keith Smith, 
Alessandro Sorniotti, Chrysoula Stathakopoul, Mark Smith Jason Yellick 
Cocco
