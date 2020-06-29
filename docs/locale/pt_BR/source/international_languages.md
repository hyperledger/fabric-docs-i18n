# Idiomas internacionais

**Audiência**: qualquer pessoa que queira contribuir com a documentação da Fabric 
em outro idioma que não o inglês.

Este pequeno guia descreve como você pode fazer alterações em um dos muitos idiomas 
suportados pela Fabric. Se você está apenas começando, este guia mostrará como 
ingressar em um grupo de trabalho de tradução de idiomas existente ou como iniciar 
um novo grupo de trabalho se o idioma escolhido não estiver disponível.

Neste tópico, abordaremos:
* [Uma introdução ao suporte de idioma da Fabric](#introducao)
* [Como ingressar em um grupo de trabalho de idiomas existente](#entrando-em-um-grupo-de-trabalho)
* [Como iniciar um novo grupo de trabalho de idiomas](#iniciando-um-grupo-de-trabalho)
* [Conectando-se a outros colaboradores de idiomas](#conectando-se-a-outros-colaboradores-de-idiomas)

## Introdução

O [repositório principal do Fabric](https://github.com/hyperledger/fabric) está 
localizado no GitHub da Hyperledger. Ele contém uma tradução em inglês da 
documentação na pasta `/docs/source`. Quando criados, os arquivos nesta pasta 
resultam no [site da documentação](https://hyperledger-fabric.readthedocs.io/en/latest/).

Este site tem outras traduções de idiomas disponíveis, como [Chinês](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/). 
No entanto, esses idiomas são criados a partir de repositórios de idiomas específicos 
hospedados na [organização do HL Labs](https://github.com/hyperledger-labs). Por 
exemplo, a documentação em chinês está armazenada [neste repositório](https://github.com/hyperledger-labs/fabric-docs-cn).

Os repositórios de idiomas têm uma estrutura de corte, eles contêm apenas as pastas 
e arquivos relacionados à documentação:

```bash
(base) user/git/fabric-docs-ml ls -l
total 48
-rw-r--r--   1 user  staff  11357 14 May 10:47 LICENSE
-rw-r--r--   1 user  staff   3228 14 May 17:01 README.md
drwxr-xr-x  12 user  staff    384 15 May 07:40 docs
```

Como essa estrutura é um subconjunto do repositório principal da Fabric, você pode 
usar as mesmas ferramentas e processos para contribuir qualquer tradução de 
idioma, você simplesmente deve trabalhar no repositório apropriado.

## Entrando em um grupo de trabalho

Embora o idioma padrão do Hyperledger Fabric seja o inglês, como vimos, outras 
traduções estão disponíveis. A documentação do [idioma chinês](https://hyperledger-fabric.readthedocs.io/zh_CN/latest/) 
está bem avançada e outros idiomas, como o português do Brasil e o malaiala, 
estão em andamento.

Você pode encontrar uma lista de todos os 
[grupos de idiomas internacionais atuais](https://wiki.hyperledger.org/display/fabric/International+groups) 
no wiki do Hyperledger. Esses grupos têm listas de membros ativos com os quais 
você pode se conectar. Eles realizam reuniões regulares nas quais você pode 
participar.

Sinta-se à vontade para seguir [estas instruções](./docs_guide.html) para 
contribuir com uma alteração na documentação de qualquer repositório de idiomas. 
Aqui está uma lista dos repositórios de idiomas atuais:

* [Inglês](https://github.com/hyperledger/fabric/tree/master/docs)
* [Chinês](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/zh_CN)
* [Malayalam](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/ml_IN)
* [Português do Brasil](https://github.com/hyperledger/fabric-docs-i18n/tree/master/docs/locale/pt_BR)

## Iniciando um grupo de trabalho

Se o idioma escolhido não estiver disponível, por que não iniciar uma nova 
tradução para o idioma? É relativamente fácil seguir em frente. Um grupo de 
trabalho pode ajudá-lo a organizar e compartilhar o trabalho de traduzir, manter 
e gerenciar um repositório de idiomas. Trabalhar com outros colaboradores e 
mantenedores em uma tradução de idioma pode ser uma atividade muito satisfatória 
para você e outros usuários da Fabric.

Siga estas instruções para criar seu próprio repositório de idiomas. Nossas 
instruções usarão o idioma sânscrito como exemplo:

1. Identifique o código internacional do idioma [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 
   de duas letras para o seu idioma. O sânscrito possui o código de duas letras `sa`.

1. Clone o repositório principal do Fabric na sua máquina local, renomeando o 
   repositório durante o clone:

    ```bash
    git clone git@github.com:hyperledger/fabric.git fabric-docs-sa
    ```

1. Selecione a versão do Fabric que você usará como linha de base. Recomendamos 
   que você comece com pelo menos o Fabric 2.1 e, idealmente, uma versão de 
   Suporte de Longo Prazo, como 2.2. Você pode adicionar outros lançamentos mais 
   tarde.

   ```bash
   cd fabric-docs-sa
   git fetch origin
   git checkout release-2.1
   ```

1. Remova todas as pastas do diretório raiz, exceto `/doc`. Da mesma forma, remova 
   todos os arquivos (incluindo os ocultos), exceto `LICENCE` e `README.md`, para 
   que você fique com o seguinte:

   ```bash
   ls -l
   total 40
   -rw-r--r--   1 user  staff  11358  5 Jun 14:38 LICENSE
   -rw-r--r--   1 user  staff   4822  5 Jun 15:09 README.md
   drwxr-xr-x  11 user  staff    352  5 Jun 14:38 docs
   ```

1. Atualize o arquivo `README.md` para usar [este](https://github.com/hyperledger-labs/fabric-docs-ml/blob/master/README.md) 
   como exemplo.

    Personalize o arquivo `README.md` para o seu novo idioma.

1. Adicione um arquivo `.readthedocs.yml` [como este](https://github.com/hyperledger-labs/fabric-docs-ml/blob/master/.readthedocs.yml) 
   na pasta de nível superior. Este arquivo está configurado para desativar as 
   compilações do ReadTheDocs PDF que podem falhar se você usar conjuntos de 
   caracteres não latinos. Sua pasta de repositório de nível superior será agora 
   assim:

   ```bash
   (base) anthonyodowd/git/fabric-docs-sa ls -al
   total 96
   ...
   -rw-r--r--   1 anthonyodowd  staff    574  5 Jun 15:49 .readthedocs.yml
   -rw-r--r--   1 anthonyodowd  staff  11358  5 Jun 14:38 LICENSE
   -rw-r--r--   1 anthonyodowd  staff   4822  5 Jun 15:09 README.md
   drwxr-xr-x  11 anthonyodowd  staff    352  5 Jun 14:38 docs
   ```

1. Confirme as alterações no seu repositório local:

   ```bash
   git add .
   git commit -s -m "Initial commit"
   ```

1. Crie um novo repositório na sua conta do GitHub chamado `fabric-docs-sa`. No 
   campo de descrição, digite `Documentação do Hyperledger Fabric em idioma sânscrito`.

1. Atualize seu git local `origin` para apontar para este repositório, substituindo 
`YOURGITHUBID` pelo seu ID do GitHub:

   ```bash
   git remote set-url origin git@github.com:YOURGITHUBID/fabric-docs-sa.git
   ```

   Nesta fase do processo, um `upstream` não pode ser definido porque o repositório 
   `fabric-docs-sa` ainda não foi criado na organização HL Labs, faremos isso um 
   pouco mais tarde.

   Por enquanto, confirme se a `origem` está definida:
   
   ```bash
   git remote -v
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (fetch)
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (push)
   ```

1. Empurre o seu ramo `release-2.1` para ser o ramo `master` neste repositório:

   ```bash
   git push origin release-2.1:master

   Enumerating objects: 6, done.
   Counting objects: 100% (6/6), done.
   Delta compression using up to 8 threads
   Compressing objects: 100% (4/4), done.
   Writing objects: 100% (4/4), 1.72 KiB | 1.72 MiB/s, done.
   Total 4 (delta 1), reused 0 (delta 0)
   remote: Resolving deltas: 100% (1/1), completed with 1 local object.
   To github.com:ODOWDAIBM/fabric-docs-sa.git
   b3b9389be..7d627aeb0  release-2.1 -> master
   ```

1. Verifique se o seu novo repositório `fabric-docs-sa` está preenchido corretamente 
   no GitHub sob o ramo` master`.

1. Conecte seu repositório ao ReadTheDocs usando estas [instruções](./docs_guide.html#desenvolvendo-no-github). 
   Verifique se sua documentação foi criada corretamente.

1. Agora você pode executar atualizações de tradução em `fabric-docs-sa`.

    Recomendamos que você traduza pelo menos a [página inicial do Fabric](https://hyperledger-fabric.readthedocs.io/en/latest/) 
    e a [Introdução](https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html) 
    antes de prosseguir. Dessa forma, os usuários terão clara sua intenção de 
    traduzir a documentação do Fabric, o que ajudará você a obter contribuidores. 
    Mais sobre isso [mais tarde](#conectando-se-a-outros-colaboradores-de-idiomas).

1. Quando estiver satisfeito com o seu repositório, crie uma solicitação para 
   criar um repositório equivalente na organização Hyperledger Labs, seguindo 
   [estas instruções](https://github.com/hyperledger-labs/hyperledger-labs.github.io) .

    Aqui está um [exemplo de PR](https://github.com/hyperledger-labs/hyperledger-labs.github.io/pull/126) 
    para mostrar o processo no trabalho.

1. Depois que seu repositório for aprovado, você poderá adicionar um `upstream`:

   ```bash
   git remote add upstream git@github.com:hyperledger-labs/fabric-docs-sa.git
   ```

   Confirme se seus `origin` e `upstream` remotos estão definidos:

   ```bash
   git remote -v
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (fetch)
   origin	git@github.com:ODOWDAIBM/fabric-docs-sa.git (push)
   upstream	git@github.com:hyperledger-labs/fabric-docs-sa.git (fetch)
   upstream	git@github.com:hyperledger-labs/fabric-docs-sa.git (push)
   ```

   Parabéns! Agora você está pronto para criar uma comunidade de colaboradores 
   para o seu repositório de idiomas internacional recém-criado.


## Conectando-se a outros colaboradores de idiomas

Aqui estão algumas maneiras de se conectar com outras pessoas interessadas em 
traduções de idiomas internacionais:

  * Rocket chat

    Leia a conversa ou faça uma pergunta no 
    [canal do Rocket de documentação da Fabric](https://chat.hyperledger.org/channel/fabric-documentation). 
    Você encontrará iniciantes e especialistas compartilhando informações sobre
    documentação.

    Há também um canal dedicado para questões específicas de 
    [internacionalização](https://chat.hyperledger.org/channel/i18n).


  * Participar de uma reunião do grupo de trabalho de documentação

    Um ótimo lugar para conhecer pessoas trabalhando na documentação é em uma 
    reunião do grupo de trabalho. São realizadas regularmente em um horário 
    conveniente para os hemisférios leste e oeste. A agenda é publicada com 
    antecedência e há atas e gravações de cada sessão. [Saiba mais](https://wiki.hyperledger.org/display/fabric/Documentation+Working+Group).


  * Participar de um grupo de trabalho de tradução de idiomas

    Cada um dos idiomas internacionais possui um grupo de trabalho onde todos são
    bem-vindos e incentivados a participar. Essa é a 
    [lista de grupos de trabalho internacionais](https://wiki.hyperledger.org/display/fabric/International+groups). 
    Veja o que seu grupo de trabalho favorito está fazendo e conecte-se a eles,
    cada grupo de trabalho tem uma lista de membros e suas informações de contato.


  * Crie uma página de grupo de trabalho de tradução de idiomas

    Se você decidiu criar uma tradução para um novo idioma, adicione um novo 
    grupo de trabalho à [lista de grupos de trabalho internacionais](https://wiki.hyperledger.org/display/fabric/International+groups), 
    usando um dos grupos existentes páginas do grupo de trabalho como um exemplo.

    Vale a pena documentar como o seu grupo de trabalho colaborará, reuniões, 
    chats e listas de discussão podem ser muito eficazes. O detalhamento desses 
    mecanismos na página do seu grupo de trabalho pode ajudar a criar uma 
    comunidade de tradutores.


   * Use um dos muitos outros mecanismos da Fabric, como lista de discussão, 
   reuniões de colaboradores e reuniões de mantenedores. Leia mais [aqui](./contributing.html).

Boa sorte e obrigado por contribuir com o Hyperledger Fabric.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->