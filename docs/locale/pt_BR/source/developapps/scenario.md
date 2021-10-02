# O cenário

**Audiência**: Arquitetos, desenvolvedores de aplicações e contratos inteligentes, 
professionais de negócio

Neste tópico, vamos descrever um cenário de negócios envolvendo seis
organizações que usam PaperNet, uma rede de papel comercial construída no Hyperledger
Fabric, para emitir, comprar e resgatar papel comercial. Vamos usar o
cenário para definir os requisitos para o desenvolvimento comercial de
aplicativos e contratos inteligentes usados pelas organizações participantes.

## O que é um papel comercial?

O papel comercial é um tipo comumente de instrumento de dívida usado de curto prazo sem garantia
emitido por empresas, normalmente usado para o financiamento de folha de pagamento, contas
a pagar e estoques, ou atender outras responsabilidades de curto prazo. Vencimentos em
papéis comerciais normalmente duram vários dias e raramente ultrapassam 270 dias.
O valor de face do papel comercial é o valor que a empresa emissora
paragá ao resgatador no vencimento. Ao comprar o papel, o credor
compra por um preço inferior ao valor de face. A diferença entre o valor de face e
o preço pelo qual o credor comprou o papel é o lucro obtido pelo credor.

## Rede PaperNet

PaperNet é uma rede de papel comercial que permite participantes emitir,
negociar, resgatar e classificar papel comercial devidamente autorizados.

![develop.systemscontext](./develop.diagram.1.png)

*A rede de papel comercial PaperNet. Seis organizações usam atualmente a rede PaperNet
para emitir, comprar, vender, resgatar e classificar papéis comerciais. MagentoCorp
emite e resgata papéis comerciais. DigiBank, BigFund, BrokerHouse e
a HedgeMatic negocia papéis comerciais entre si. RateM fornece vários
medidas de risco para papéis comerciais.*

Vamos ver como MagnetoCorp usa PaperNet e papel comercial para ajudar seu
o negócio.

## Introduzindo os atores

MagnetoCorp é uma empresa respeitada que fabrica  veículos de eletricidade autônoma.
No início de abril de 2020, a MagnetoCorp conquistou um grande pedido para fabricar
10.000 carros Modelo D para Daintree, um novo operador no mercado de transporte pessoal.
Embora o pedido represente uma vitória significativa para a MagnetoCorp,
a Daintree não terá que pagar pelos veículos até que eles comecem a ser entregues
em 1º de novembro, seis meses após o acordo formalmente firmado entre MagnetoCorp
e Daintree.

Para fabricar os veículos, a MagnetoCorp precisará contratar 1000 trabalhadores por
pelo menos 6 meses. Isso coloca uma pressão de curto prazo em suas finanças - exigirá
5 milhões de dólares extras a cada mês para pagar esses novos funcionários. ** Papel comercial ** é
projetado para ajudar a MagnetoCorp a superar suas necessidades de financiamento de curto prazo - para atender
folha de pagamento todos os meses com base na expectativa de que será terá lucro quando
a Daintree começa a pagar por seus novos carros Modelo D.

No final de maio, a MagnetoCorp precisa de 5 milhões de dólares para atender à folha de pagamento extra
dos trabalhadores que contratou em 1º de maio. Para isso, emite um papel comercial com um
valor de 5 milhões de dólares com uma data de vencimento 6 meses no futuro - quando se espera
receber o valor da Daintree. DigiBank acha que MagnetoCorp é
digna de crédito e, portanto, não exige muito acima da taxa central base de 2%,
que valorizaria 4,95 milhões de dólares hoje a 5 milhões de dólares em 6 meses.
Portanto, adquire o papel comercial da MagnetoCorp de 6 meses por 4,94 milhões
USD - um pequeno desconto em relação aos 4,95 milhões de dólares que vale a pena. DigiBank espera totalmente
poder resgatar 5 milhões de dólares da MagnetoCorp em 6 meses,
obtendo um lucro de 10K USD por suportar o risco associado a
este papel comercial. Esses 10K extras significam que ele recebe um retorno de 2,4% sobre
investimento - significativamente melhor do que o retorno sem risco de 2%.

No final de junho, quando MagnetoCorp emite um novo papel comercial por 5 milhões de dólares para
atender à folha de pagamento de junho, ele é comprado pela BigFund por 4,94 milhões de dólares. Isso é porque
as condições comerciais são praticamente as mesmas em junho e maio,
resultando em BigFund avaliando o papel comercial MagnetoCorp o mesmo preço que
DigiBank fez em maio.

A cada mês subsequente, a MagnetoCorp pode emitir novos papéis comerciais para atender a sua
obrigações de folha de pagamento, e estes podem ser adquiridos pelo DigiBank, ou qualquer outro
participante da rede de papel comercial PaperNet - BigFund, HedgeMatic ou
BrokerHouse. Essas organizações podem pagar mais ou menos pelo papel comercial
dependendo de dois fatores - a taxa básica do banco central e o risco associado
com MagnetoCorp. Este último valor depende de uma variedade de fatores, como o
produção de carros Modelo D e a qualidade de crédito da MagnetoCorp conforme avaliado
pela RateM, uma agência de classificação.

As organizações no PaperNet têm funções diferentes, documentos de questões da MagnetoCorp,
DigiBank, BigFund, HedgeMatic e BrokerHouse avaliam o papel e RateM avalia o papel.
Organizações com a mesma função, como DigiBank, Bigfund, HedgeMatic e
BrokerHouse são concorrentes. Organizações com funções diferentes não são
necessariamente concorrentes, mas ainda podem ter interesses comerciais opostos, por
exemplo MagentoCorp desejará uma alta classificação para seus papéis para vendê-los em
um preço alto, enquanto o DigiBank se beneficiaria de uma classificação baixa, de modo que pode
compra-los por um preço baixo. Como pode ser visto, mesmo uma rede aparentemente simples como
o PaperNet pode ter relações de confiança complexas. Um blockchain pode ajudar
estabelecer confiança entre organizações que são concorrentes ou que tem interesses comerciais 
opostos que podem levar a disputas. Hyperledger Fabric, em particular, tem o
objectivo de capturar até mesmo relacionamentos de confiança mais refinados.

Vamos pausar a história da MagnetoCorp por um momento e desenvolver o aplicativo do cliente
e contratos inteligentes que o PaperNet usa para emitir, comprar, vender e
resgatar papel comercial, bem como capturar as relações de confiança entre
as organizações. Voltaremos ao papel da agência de classificação,
RateM, um pouco mais tarde.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
