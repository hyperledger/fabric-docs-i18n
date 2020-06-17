# Fazendo uma alteração na documentação

**Audiência**: qualquer pessoa que queira contribuir com a documentação da Fabric.

Este pequeno guia descreve como a documentação da Fabric é estruturada, criada e 
publicada, bem como algumas convenções que você deve conhecer antes de fazer 
alterações na documentação do Fabric.

Neste tópico, abordaremos:
* [Uma introdução à documentação](#introducao)
* [Estrutura do repositório](#estrutura-do-repositorio)
* [Testando suas alterações](#testando-suas-alteracoes)
* [Construindo a documentação localmente](#construindo-localmente)
* [Criando a documentação no GitHub e ReadTheDocs](#desenvolvendo-no-github)
* [Fazendo alteração na Referência de Comandos](#atualizacoes-da-referencia-de-comandos)
* [Adicionando um novo comando no CLI](#adicionando-um-novo-comando-no-cli)

## Introdução

A documentação da Fabric é escrita em uma combinação de [Markdown](https://www.markdownguide.org/) 
e [reStructuredText](http://docutils.sourceforge.net/rst.html) e, como novo autor, 
você pode usar um ou ambos. Recomendamos que você use o Markdown como uma maneira 
fácil e poderosa de começar, embora se você tem experiência em Python, pode 
preferir usar o RST.

Como parte do processo de criação, os arquivos de origem da documentação são 
convertidos para HTML usando [Sphinx](http://www.sphinx-doc.org/en/stable/) e 
publicados [aqui](http://hyperledger-fabric.readthedocs.io). Existe uma referência 
do GitHub para o [repositório principal da Fabric](https://github.com/hyperledger/fabric), 
de forma que qualquer conteúdo novo ou alterado em `docs/source` acione uma nova 
compilação e subsequente publicação do documento.

As traduções da documentação do fabric estão disponíveis em diferentes idiomas:

   * [Documentação em chinês](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/)
   * [Documentação em malaiala](https://hyperledgerlabsml.readthedocs.io/en/latest/)
   * Documentação em português do Brasil - em breve

Cada um deles é criado a partir de seu repositório específico de idioma no
[Hyperledger Labs](https://github.com/hyperledger-labs).

Por exemplo:

 * [Repositório da lingua Chinesa](https://github.com/hyperledger-labs/fabric-docs-cn)
 * [Repositório da lingua Malayalam](https://github.com/hyperledger-labs/fabric-docs-ml)
 * Repositório da lingua portuguesa do Brasil -- em breve

Quando um repositório de idiomas estiver quase completo, ele poderá contribuir 
para o site de publicação principal do Fabric. Por exemplo, os documentos em 
idioma chinês estão disponíveis no
[site principal da documentação](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/).

## Estrutura do repositório

Em cada um desses repositórios, os documentos da Fabric são sempre mantidos na 
pasta de nível superior `/docs`.

```bash
(docs) bash-3.2$ ls -l docs
total 56
-rw-r--r--    1 user  staff   2107  4 Jun 09:42 Makefile
-rw-r--r--    1 user  staff    199  4 Jun 09:42 Pipfile
-rw-r--r--    1 user  staff  10924  4 Jun 09:42 Pipfile.lock
-rw-r--r--@   1 user  staff    288  4 Jun 14:50 README.md
drwxr-xr-x    4 user  staff    128  4 Jun 10:10 build
drwxr-xr-x    3 user  staff     96  4 Jun 09:42 custom_theme
-rw-r--r--    1 user  staff    283  4 Jun 09:42 requirements.txt
drwxr-xr-x  103 user  staff   3296  4 Jun 12:32 source
drwxr-xr-x   18 user  staff    576  4 Jun 09:42 wrappers
```

Os arquivos neste diretório são os arquivos de configuração para o processo de 
construção. Toda a documentação está contida na pasta `/source`:


```bash
(docs) bash-3.2$ ls -l docs/source
total 2576
-rw-r--r--   1 user  staff   20045  4 Jun 12:33 CONTRIBUTING.rst
-rw-r--r--   1 user  staff    1263  4 Jun 09:42 DCO1.1.txt
-rw-r--r--   1 user  staff   10559  4 Jun 09:42 Fabric-FAQ.rst
drwxr-xr-x   4 user  staff     128  4 Jun 09:42 _static
drwxr-xr-x   4 user  staff     128  4 Jun 09:42 _templates
-rw-r--r--   1 user  staff   10995  4 Jun 09:42 access_control.md
-rw-r--r--   1 user  staff     353  4 Jun 09:42 architecture.rst
-rw-r--r--   1 user  staff   11020  4 Jun 09:42 blockchain.rst
-rw-r--r--   1 user  staff   75552  4 Jun 09:42 build_network.rst
-rw-r--r--   1 user  staff    9115  4 Jun 09:42 capabilities_concept.md
-rw-r--r--   1 user  staff    2851  4 Jun 09:42 capability_requirements.rst
...
```

Esses arquivos e diretórios são mapeados diretamente para a estrutura da 
documentação que você vê nos [documentos publicados](https://hyperledger-fabric.readthedocs.io/en/latest/). 
Especificamente, o índice tem como seu raiz o arquivo 
[`index.rst`](https://github.com/hyperledger/fabric/blob/master/docs/source/index.rst), 
que vincula todos os demais arquivos em [`/docs/source`](https://github.com/hyperledger/fabric/tree/master/docs/source).

Passe algum tempo navegando nesses diretórios e arquivos para ver como eles se
vinculam.

Para atualizar a documentação, basta alterar um ou mais desses arquivos usando 
git, construir a alteração localmente para verificar se está OK e, em seguida, 
enviar uma PR ao repositório principal da Fabric. Se a alteração for aceita pelos 
mantenedores, ela será mesclada no repositório principal da Fabric e se tornará 
parte da documentação publicada. É realmente fácil!

Você pode aprender como fazer um PR [aqui](./github/github.html), mas antes de 
fazer isso, continue lendo para ver como construir sua alteração localmente 
primeiro. Além disso, se você é novo no git e no GitHub, achará o [livro Git](https://git-scm.com/book/en/v2) 
fundamental.

## Testando suas alterações

Encorajamos fortemente você a testar suas alterações na documentação antes de 
enviar um PR. Você deve começar criando os documentos em sua própria máquina e, 
posteriormente, enviar as alterações para seu próprio repositório de preparação 
do GitHub, onde é possível vincular ao site de publicação do [ReadTheDocs](https://readthedocs.org/). 
Quando estiver satisfeito com sua alteração, você poderá enviá-la por meio de um 
PR para inclusão no repositório principal da Fabric.

As seções a seguir abordam primeiro como criar os documentos localmente e, em 
seguida, use seu próprio fork do Github para publicar no ReadTheDocs.

## Construindo localmente

Depois de clonar o repositório da Fabric na sua máquina local, siga estas etapas 
rápidas para criar a documentação da Fabric. Nota: pode ser necessário realizar 
algum ajuste dependendo do seu sistema operacional.

Pré-requisitos:

 - [Python 3.7](https://wiki.python.org/moin/BeginnersGuide/Download)
 - [Pipenv](https://docs.pipenv.org/en/latest/#install-pipenv-today)

```
cd fabric/docs
pipenv install
pipenv shell
make html
```

Isso irá gerar todos os arquivos html da documentação do Fabric em `docs/build/html`, 
que você poderá começar a navegar localmente usando seu navegador, simplesmente 
navegue até o arquivo `index.html`.

Faça uma pequena alteração em um arquivo e recrie a documentação para verificar 
se sua alteração foi criada localmente. Toda vez que você fizer uma alteração na 
documentação, é claro, será necessário executar novamente o `make html`.

Além disso, se desejar, você também pode executar um servidor web local com os 
seguintes comandos (ou equivalente, dependendo do seu sistema operacional):

```
sudo apt-get install apache2
cd build/html
sudo cp -r * /var/www/html/
```

Você pode acessar os arquivos html em `http://localhost/index.html`.

## Desenvolvendo no GitHub

Muitas vezes, pode ser útil usar uma ramificação do repositório da Fabric para 
criar a documentação da Fabric em um site público, disponível para outras pessoas. 
As instruções a seguir mostram como usar o ReadTheDocs para fazer isso.

1. Acesse http://readthedocs.org e inscreva-se em uma conta.
2. Crie um projeto. Seu nome de usuário precederá a URL e você poderá anexar 
   `-fabric` para garantir que você possa distinguir este de outros documentos 
   que você precise criar para outros projetos. Por exemplo: 
   `YOURGITHUBID-fabric.readthedocs.io/en/latest`. 
3. Clique em `Admin`, clique em `Integrations`, clique em `Add integration`, 
   escolha `GitHub incoming webhook` e clique em `Add integration`.
4. Ramificação [Fabric no GitHub](https://github.com/hyperledger/fabric).
5. Na ramificação, vá para `Settings` na parte superior direita da tela.
6. Clique em `Webhooks`.
7. Clique em `Add webhook`.
8. Adicione o URL do ReadTheDocs em `Payload URL`.
9. Selecione `Let me select individual events`:`Pushes`, `Branch or tag creation`,
   `Branch or tag deletion`.
10. Clique em `Add webhook`.

Agora, sempre que você modificar ou adicionar conteúdo da documentação ao seu fork, 
essa URL será atualizado automaticamente com as alterações!

## Atualizações da referência de Comandos

Atualizando no tópico do conteúdo das [Referências de Comando](https://hyperledger-fabric.readthedocs.io/en/latest/command_ref.html)  
requer etapas adicionais. Como as informações no tópico Referência de Comandos 
são geradas, você não pode simplesmente atualizar os arquivos associados.
- Em vez disso, você precisa atualizar os arquivos do comando `_preamble.md` ou 
  `_postscript.md` em `src/github.com/hyperledger/fabric/docs/wrappers`.
- Para atualizar o texto de ajuda do comando, é necessário editar o arquivo `.go` 
  associado ao comando localizado em `/fabric/internal/peer`.
- Em seguida, na pasta `fabric`, você precisa executar o comando `make help-docs`, 
  que gera os arquivos atualizados em `docs/source/command`.

Lembre-se de que quando você enviar as alterações para o GitHub, incluir o arquivo 
`_preamble.md`, `_postscript.md` ou `_.go` que foi modificado, bem como o arquivo 
gerado.

Esse processo se aplica apenas às traduções para o inglês. Atualmente, a tradução
de referência de comando não é possível em idiomas internacionais.

## Adicionando um novo comando no CLI

Para adicionar um novo comando no CLI, execute as seguintes etapas:

- Crie uma nova pasta em `/fabric/internal/peer` para o novo comando e o texto 
  de ajuda associado. Veja `internal/peer/version` para um exemplo simples para 
  começar.
- Adicione uma seção para seu comando no CLI em `src/github.com/hyperledger/fabric/scripts/generateHelpDoc.sh`.
- Crie dois novos arquivos em `/src/github.com/hyperledger/fabric/docs/wrappers`
   com o conteúdo associado:
   - `<comando>_preamble.md` (Nome e sintaxe do comando)
   - `<comando>_postscript.md` (Uso de exemplo)
- Execute `make help-docs` para gerar o conteúdo e envie todos os arquivos 
  alterados para o GitHub.

Esse processo se aplica apenas às traduções para o inglês. Atualmente, a tradução 
de comandos no CLI não é possível em idiomas internacionais.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->