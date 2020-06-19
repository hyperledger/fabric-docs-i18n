# Guia de estilo para colaboradores

**Audiência**: redatores e editores de documentação

Embora este guia de estilo também se refira às práticas recomendadas usando o 
ReStructured Text (também conhecido como RST), em geral, aconselhamos escrever a
documentação em Markdown, pois é um padrão de documentação aceito universalmente. 
Ambos os formatos são utilizáveis, no entanto, e se você decidir escrever um tópico 
em RST (ou estiver editando um tópico do RST), consulte este guia de estilo.

**Em caso de dúvida, use as próprias documentações para orientação sobre como 
formatar as coisas.**

* [Para formatação RST](http://hyperledger-fabric.readthedocs.io/en/release-1.4/channel_update_tutorial.html).

* [Para formatação do Markdown](http://hyperledger-fabric.readthedocs.io/en/release-1.4/peers/peers.html).

Se você quiser apenas ver como as coisas são formatadas, navegue até o repositório 
da Fabric para ver o arquivo bruto, clicando no link `Edit on Github` no canto 
superior direito da página. Depois clique na aba `Raw`. Isso mostrará a formatação 
do documento. **Não tente editar o arquivo no Github.** Se você quiser fazer uma 
alteração, clone o repositório e siga as instruções em [Contribuindo](./CONTRIBUTING.html) 
para criar um PR.

**Comprimentos de linha.**

Se você olhar as versões brutas da documentação, verá que muitos tópicos estão em 
conformidade com um comprimento de linha de aproximadamente 70 caracteres. Como 
essa restrição não é mais necessária, você pode criar linhas do tamanho que desejar.

**Os tutoriais devem ter uma lista de etapas na parte superior.**

Uma lista de etapas (com links para as seções correspondentes) no início de um 
tutorial ajuda os usuários a encontrar etapas específicas nas quais estão 
interessados. Por exemplo, consulte [Usar dados privados no Fabric](../private-data/private-data.html).

**"Fabric", "Hyperledger Fabric" ou "HLF"?**

O primeiro uso deve ser "Hyperledger Fabric" e depois apenas "Fabric". Não use 
"HLF" ou "Hyperledger" por si só.

**Chaincode vs. Chaincodes?**

Um chaincode é um "chaincode". Se você está falando sobre vários chaincodes, use 
"chaincodes".

**Quando usar negrito?**

Com pouca frequência. O melhor uso deles é como um resumo ou como uma maneira 
de chamar a atenção para os conceitos sobre os quais você deseja falar. "Uma rede 
blockchain contém um livro-razão, pelo menos um chaincode e nós pares", 
especialmente se você estiver falando sobre essas coisas nesse parágrafo. Evite 
usá-los simplesmente para enfatizar uma única palavra, como em algo como 
"as redes Blockchain **devem** usar protocolos de segurança de propriedade".

**Quando cercar algo com crases `nnn`?**

Isso é útil para chamar a atenção para palavras que não fazem sentido em português 
ou ao fazer referência a partes do código (especialmente se você inseriu trechos 
de código em seu documento). Por exemplo, ao falar sobre o diretório fabric-samples,
envolva `fabric-samples` com crases. O mesmo com uma função de código como 
`hf.Revoker`. Também pode fazer sentido colocar crases em torno de palavras que 
fazem sentido no português mas que fazem parte do código, se você as estiver 
referenciando em um contexto de código. Por exemplo, ao referenciar um `atributo`
como parte de uma Lista de Controle de Acesso.

**É sempre apropriado usar um traço?**

Os traços podem ser incrivelmente úteis, mas não são necessariamente tão 
tecnicamente apropriados quanto usado em frases declarativas separadas. Vamos 
considerar esta frase de exemplo:

```
Isso nos deixa com um objeto JSON ajustado --- config.json, localizado na pasta 
fabric-samples dentro da first-network --- que servirá como linha de base para a 
atualização da configuração.
```

Existem várias maneiras de apresentar essa mesma informação, mas, neste caso, os 
traços dividem a informação, mantendo-a como parte do mesmo pensamento. Se você 
usar um traço, use o traço "em", que é três vezes maior que um hífen. Esses traços 
devem ter um espaço antes e depois.

**Quando usar hífens?**

Os hífens são geralmente usados como parte de um "adjetivo composto". Por exemplo, 
"carro a jato". Observe que o adjetivo composto deve preceder imediatamente o 
substantivo que está sendo modificado. Em outras palavras, "a jato" por si 
só não precisa de um hífen. Em caso de dúvida, use o Google, pois adjetivos 
compostos são complicados e são uma discussão popular em fóruns de gramática.

**Quantos espaços após o ponto final?**

Um.

**Como os números devem ser renderizados?**

Os números de zero a nove são explícitos. Um, dois, três, quatro, etc. Os 
números após 10 são renderizados como números.

Exceções a isso seriam usos no código. Nesse caso, use o que estiver no código. 
E também exemplos como Org1. Não escreva como OrgOne.

**Tente evitar usar as mesmas palavras com muita frequência.**

Se você puder evitar usar uma palavra duas vezes em uma frase, faça-o. Não usá-lo 
mais de duas vezes em um único parágrafo é melhor. É claro que às vezes talvez 
não seja possível evitar isso --- um documento sobre stateDB provavelmente estará 
repleto de usos da palavra “banco de dados” ou “livro-razão”. Mas o uso excessivo 
de qualquer palavra em particular tende a ter um efeito entorpecedor no leitor.

**Como os arquivos devem ser nomeados?**

Por exemplo, `identity_use_case_tutorial.md`. Embora nem todos os arquivos usem 
esse padrão, novos arquivos devem aderir a ele.

**Regras do maiúsculo para títulos de documentos.**

As regras padrão para letras maiúsculas nas sentenças devem ser seguidas. Em 
outras palavras, a menos que uma palavra seja a primeira palavra no título ou um 
nome próprio, não coloque em maiúscula sua primeira letra. Por exemplo, "Noções 
Básicas Sobre Identidades na Fabric" deve ser "Noções básicas sobre identidades 
na Fabric". Embora nem todo documento siga esse padrão ainda, é o padrão para o 
qual estamos nos movendo e deve ser seguido para novos tópicos.

Os títulos dentro dos tópicos devem seguir o mesmo padrão.

**JSON vs .json?**

Use "JSON". O mesmo se aplica a qualquer formato de arquivo (por exemplo, YAML).

**Referindo-se ao leitor.**

É perfeitamente aceitável usar a palavra "você" ou "nós".

**E comercial (&).**

Não substitui a palavra "e". Evite-os, a menos que você tenha um motivo para 
usá-lo (como em um trecho de código que o inclui).

**Acrônimos.**

O primeiro uso de um acrônimo deve ser escrito, a menos que seja um acrônimo de
uso tão amplo que seja desnecessário. Por exemplo, “Software Development Kit (SDK)” 
no primeiro uso. Em seguida, use o "SDK" posteriormente.

**Legendas.**

Eles devem estar em itálico e é o único uso real válido para itálico em nossos 
documentos.

**Comandos.**

Em geral, coloque cada comando em seu próprio snippet. Ele fica melhor, 
especialmente quando os comandos são longos. Uma exceção a essa regra é ao 
sugerir a exportação de várias variáveis de ambiente.

**Partes de código.**

No Markdown, se você quiser postar um código de amostra, use três cráses para 
ativar o snippet. Por exemplo:

```
Código vai aqui.

Ainda mais código aqui.

E ainda mais.
```

No RST, você precisará ativar o snippet de código usando uma formatação semelhante a esta:

```
.. code:: bash

    Código vai aqui.
```

Você pode substituir o `bash` por uma linguagem como Java ou Go, quando apropriado.

**Listas enumeradas no Markdown.**

Observe que no Markdown, as listas enumeradas não funcionarão se você separar os 
números com um espaço. O Markdown vê isso como o início de uma nova lista, não 
como uma continuação da antiga (todo número será "1"). Se você precisar de uma 
lista enumerada, precisará usar o RST. As listas com marcadores são um bom 
substituto no Markdown e são a alternativa recomendada.

**Vinculação.**

Ao vincular a outro documento, use links relativos, não links diretos. Ao nomear 
um link, não o chame apenas de "link". Use um nome mais criativo e descritivo. 
Por motivos de acessibilidade, o nome do link também deve deixar claro que é um 
link. Por exemplo, confira [este link para o Google](www.google.com).

**curl ou cURL.**

A ferramenta é chamada "cURL". Os comando sem sí "curl".

**Fabric CA.**

Não chame de "fabric-CA", "fabricCA" ou FabricCA. É a Fabric CA.

**Raft e RAFT.**

"Raft" não é um acrônimo. Não o chame de "serviço de pedidos RAFT".

**Todos os documentos precisam terminar com uma declaração de licença.**

No RST, é o seguinte:

```
.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
```

No markdown:

```
<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
```

**Quantos espaços de identação?**

Depende do caso de uso. Freqüentemente é necessário, especialmente no RST, recuar 
dois espaços, especialmente em um bloco de código. Em uma caixa NOTA no RST, você
deve recuar para o espaço após os dois pontos após a nota, assim:

```
.. note:: Algumas palavras e outras coisas etc etc etc (a linha continua até a 
          o limite de 70 caracteres) a linha diretamente abaixo deve começar no 
          mesmo espaço da linha acima.
```

**Quando usar qual tipo de cabeçalho?**

Confira [este tópico sobre cabeçalhos](http://blender-manual-i18n.readthedocs.io/ja/latest/about/markup_style_guide.html?highlight=tooltip#headings).

No RST, use isto:

```
Capítulo 1 Título
=================

Seção 1.1 Título
----------------

Subseção 1.1.1 Título
~~~~~~~~~~~~~~~~~~~~~

Seção 1.2 Título
----------------
```

Observe que o comprimento da marcação do título deve ser o mesmo do próprio título. 
Isso não é um problema no Atom, que dá a cada caractere a mesma largura por padrão 
(isso é chamado de "monoespaçamento", se você usa o Jeopardy! precisa dessas 
informações).

No Markdown, é um pouco mais simples. Você deve:

```
# O nome do documento (isso será usado para o sumário).

## Primeira subseção

## Segunda subseção
```

Ambos os formatos de arquivo não gostam quando essas coisas são feitas fora de 
ordem. Por exemplo, você pode querer que um `####` seja a primeira coisa após o 
seu `#` Título. O Markdown não permitirá. Da mesma forma, o RST usará como padrão 
a ordem que você der aos formatos de título (como eles aparecem nas primeiras 
seções do seu documento).

**Links relativos devem ser usados sempre que possível.**

   Para o RST, a sintaxe preferida é:
   ```
     :doc:`texto âncora <caminho relativo>`
   ```
   Não coloque o sufixo .rst no final do caminho do arquivo.

   Para Markdown, a sintaxe preferida é:
   ```
     [texto âncora](<caminho relativo>)
   ```

   Para outros arquivos, como texto ou YAML, use um link direto para o arquivo em
   github por exemplo:

   [https://github.com/hyperledger/fabric/blob/master/docs/README.md](https://github.com/hyperledger/fabric/blob/master/docs/README.md)

   Infelizmente, os links relativos não estão funcionando no github ao navegar por um
   Arquivo RST.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
