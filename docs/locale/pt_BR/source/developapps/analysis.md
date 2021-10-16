# Análise

**Audiência**: Arquitetos, desenvolvedores de aplicações e contratos inteligentes, 
professionais de negócio

Vamos analisar o papel comercial com um pouco mais de detalhes. Participantes do PaperNet
como MagnetoCorp e DigiBank usam transações de papel comercial para alcançar
seus objetivos de negócios - vamos examinar a estrutura de um papel comercial
e as transações que o afetam ao longo do tempo. Também consideraremos quais
as organizações no PaperNet precisam assinar uma transação com base nas
relações de confiança entre as organizações da rede. Mais tarde, vamos nos concentrar em como
o dinheiro flui entre compradores e vendedores; por enquanto, vamos nos concentrar no primeiro papel
emitido pela MagnetoCorp.

## Ciclo de vida do papel comercial

Um papel 00001 é emitido pela MagnetoCorp em 31 de maio. Olhando para
o primeiro **estado** deste papel, com suas diferentes propriedades e valores:

```
Emitente = MagnetoCorp
Papel = 00001
Proprietário = MagnetoCorp
Data emissão = 31 Maio 2020
Vencimento = 30 Novembro 2020
Valor = 5M USD
Estado atual = emitido
```
Este estado de papel é resultado da transação de **emissão** e traz o primeiro papel comercial da MagnetoCorp à existência! Observe como este papel tem um valor de US$ 5 milhões para resgate no final do ano. Veja como o `Emissor` e o `Proprietário` são os mesmos quando o papel 00001 é emitido. Observe que este papel pode ser identificado exclusivamente como `MagnetoCorp00001` - uma composição das propriedades` Emitente` e `Papel`. Finalmente, veja como a propriedade `Estado atual = emitido` identifica rapidamente o estágio do papel 00001 da MagnetoCorp em seu ciclo de vida.


Logo após a emissão, o papel é comprado pelo DigiBank. Passado alguns momentos, observe como o mesmo papel comercial mudou como resultado desta transação de **compra**:

```
Emitente = MagnetoCorp
Papel = 00001
Proprietário = DigiBank
Data emissão = 31 Maio 2020
Vencimento = 30 Novembro 2020
Valor = 5M USD
Estado atual = negociado
```

A mudança mais significativa é a de `Proprietário` - veja como o papel inicialmente propriedade da `MagnetoCorp` agora é propriedade do `DigiBank`. Poderíamos imaginar como o papel poderia ser posteriormente vendido para BrokerHouse ou HedgeMatic, e a mudança correspondente para `Proprietário`. Observe como o `Estado atual` nos permite identificar facilmente que o papel agora está `negociado`.

Após 6 meses, se o DigiBank ainda detém o papel comercial, ele pode resgatá-lo com a MagnetoCorp:

```
Emitente = MagnetoCorp
Papel = 00001
Proprietário = MagnetoCorp
Data emissão = 31 Maio 2020
Vencimento = 30 Novembro 2020
Valor = 5M USD
Current state = resgatado
```

Esta transação de **resgate** final encerrou o ciclo de vida do papel comercial - pode ser considerada fechada. Muitas vezes, é obrigatório manter um registro dos papéis comerciais resgatados, e o estado `resgatado` nos permite identificá-los rapidamente. O valor do `Proprietário` de um papel pode ser usado para realizar o controle de acesso na transação de **resgate**, comparando o `Proprietário` com a identidade do criador da transação. O Fabric suporta isso por meio da [API chaincode getCreator()](https://github.com/hyperledger/fabric-chaincode-node/blob/{BRANCH}/fabric-shim/lib/stub.js#L293). Se Go for usado como uma linguagem chaincode, a biblioteca de [chaincode de identidade do cliente](https://github.com/hyperledger/fabric-chaincode-go/blob/{BRANCH}/pkg/cid/README.md) pode ser usada para recuperar atributos adicionais do criador da transação.

## Transações

Vimos que o ciclo de vida do papel 00001 é relativamente simples - ele muda status entre `emitido`,` negociado` e `resgatado` como resultado de uma transação de **emissão**, **compra** ou **resgate**.

Essas três transações são iniciadas por MagnetoCorp e DigiBank (duas vezes) e conduzem as mudanças de estado do papel 00001. Vamos dar uma olhada nas transações que afetam este papel com um pouco mais de detalhes:

### Emissão

Examine a primeira transação iniciada pela MagnetoCorp:

```
Txn = emissão
Emitente = MagnetoCorp
Papel = 00001
Hora emissão = 31 Maio 2020 09:00:00 EST
Vencimento = 30 Novembro 2020
Valor = 5M USD
```

Veja como a transação **emissão** possui uma estrutura com propriedades e valores.
Essa estrutura de transação é diferente, mas corresponde exatamente à estrutura do papel 00001. Isso porque são coisas diferentes - o papel 00001 reflete um estado do PaperNet que é resultado da transação **emissão**. É a lógica por trás da transação **emissão** (que não podemos ver) que pega essas propriedades e cria este papel. Como a transação **cria** o papel, isso significa que há uma relação muito próxima entre essas estruturas.

A única organização envolvida na transação de **emissão** é a MagnetoCorp.
Naturalmente, a MagnetoCorp precisa assinar a transação. Em geral, o emissor de um papel é obrigado a assinar uma transação que emite um novo papel.

### Compra

Em seguida, vamos examinar a transação de **compra** que transfere a propriedade do papel 00001 da MagnetoCorp para o DigiBank:

```
Txn = compra
Emitente = MagnetoCorp
Papel = 00001
Proprietário atual = MagnetoCorp
Novo proprietário = DigiBank
Hora compra = 31 Maio 2020 10:00:00 EST
Preço = 4.94M USD
```

Veja como a transação **compra** tem menos propriedades que acabam neste artigo.
Isso porque esta transação apenas **modifica** este papel. É apenas `New owner = DigiBank` que muda como resultado desta transação; tudo o mais é o mesmo. Tudo bem - a coisa mais importante sobre a transação **compra** é a mudança de propriedade e, de fato, nesta transação, há um reconhecimento do atual proprietário do papel, MagnetoCorp.

Você pode se perguntar por que as propriedades `Hora compra` e `Preço` não são capturadas no papel 00001? Isso nos remete à diferença entre a transação e o papel. O preço de 4,94 M USD é, na verdade, uma propriedade da transação, e não uma propriedade deste documento. Passe algum tempo pensando sobre essa diferença; não é tão óbvio quanto parece. Veremos mais tarde que o ledger registrará ambas as informações - o histórico de todas as transações que afetam este papel, bem como seu estado mais recente. Ter clareza sobre essa separação de informações é muito importante.

Vale lembrar também que o papel 00001 pode ser comprado e vendido diversas vezes.
Embora estejamos avançando um pouco em nosso cenário, vamos examinar quais transações **podemos** ver se o papel 00001 muda de propriedade.

Se tivermos uma compra por BigFund:

```
Txn = compra
Emitente = MagnetoCorp
Papel = 00001
Proprietário atual = DigiBank
Novo proprietário = BigFund
Hora compra = 2 Junho 2020 12:20:00 EST
Preço = 4.93M USD
```
Seguido por uma compra subsequente pela HedgeMatic:
```
Txn = compra
Emitente = MagnetoCorp
Papel = 00001
Proprietário atual = BigFund
Novo proprietário = HedgeMatic
Hora compra = 3 Junho 2020 15:59:00 EST
Preço = 4.90M USD
```

Veja como os proprietários do papel mudam e como, em nosso exemplo, o preço muda. Você consegue pensar em um motivo pelo qual o preço dos papéis comerciais da MagnetoCorp pode estar caindo?

Intuitivamente, uma transação de **compra** exige que tanto a organização vendedora quanto a compradora precisem assinar tal transação de forma que haja prova do acordo mútuo entre as duas partes que fazem parte do negócio.

### Resgate

A transação **resgate** para papel 00001 representa o fim de seu ciclo de vida.
Em nosso exemplo relativamente simples, o HedgeMatic inicia a transação que transfere o papel comercial de volta para a MagnetoCorp:

```
Txn = resgate
Emitente = MagnetoCorp
Paper = 00001
Proprietário atual = HedgeMatic
Hora resgate = 30 Novembro 2020 12:00:00 EST
```

Novamente, observe como a transação de **resgate** tem muito poucas propriedades; todas as mudanças no papel 00001 podem ser dados calculados pela lógica de transação de resgate:
o `Emissor` se tornará o novo proprietário, e o `Estado atual` mudará para `resgatado`. A propriedade `Current owner` é especificada em nosso exemplo, para que possa ser verificada com o atual detentor do papel.

Do ponto de vista da confiança, o mesmo raciocínio da transação **compra** também se aplica à instrução **resgate**: ambas as organizações envolvidas na transação devem assiná-la.

## O Ledger

Neste tópico, vimos como as transações e os estados de papel resultantes são os dois conceitos mais importantes no PaperNet. Na verdade, veremos esses dois elementos fundamentais em qualquer [ledger](../ledger/ledger.html) distribuída do Hyperledger Fabric - um estado mundial, que contém o valor atual de todos os objetos, e um blockchain que registra o histórico de todas as transações que resultaram no estado mundial atual.

As aprovações necessárias nas transações são aplicadas por meio de regras, que são avaliadas antes de anexar uma transação ao ledger. Somente se as assinaturas necessárias estiverem presentes, o Fabric aceitará uma transação como válida.

Agora você está em um ótimo lugar para traduzir essas ideias em um contrato inteligente. Não se preocupe se sua programação estiver um pouco enferrujada, forneceremos dicas e sugestões para entender o código do programa. Dominar o contrato inteligente de papel comercial é o primeiro grande passo para projetar seu próprio aplicativo. Ou, se você é um analista de negócios que se sente confortável com um pouco de programação, não tenha medo de cavar um pouco mais fundo!

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
