Pré-requisitos
=============

Before we begin, if you haven't already done so, you may wish to check that
Antes de iniciar, se ainda não ter feito isso, você pode verificar se possui 
todos os pré-requisitos abaixo instalados na(s) plataforma(s)
na qual desenvolverá aplicativos e/ou operações
Hyperledger Fabric.

Instalar Git
-----------
Baixe a última versão do `git
<https://git-scm.com/downloads>`_ se ainda não estiver instalado
ou se você tiver problemas ao executar os comandos curl.

Instalando cURL
------------

Baixe a última versão da ferramenta `cURL
<https://curl.haxx.se/download.html>`__ se ainda não estiver instalado
ou se você receber erros ao executar os comandos curl da
documentação.

.. note:: Se você estiver no Windows, por favor consulte a nota de especificação em `Windows
   extras`_ abaixo.

Docker and Docker Compose
-------------------------

Você precisará das seguintes instalações em sua plataforma em que
estiver operando ou desenvolvendo em (ou para) Hyperledger Fabric:

  - MacOSX, \*nix, ou Windows 10: `Docker <https://www.docker.com/get-docker>`__
    Docker versão 17.06.2-ce ou superior é necessária.
  - Versões antigas do Windows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
    novamente, Docker versão Docker 17.06.2-ce ou superior é necessária.

Você pode checar a versão do Docker instalada com o seguinte 
comando em um prompt de terminal:

.. code:: bash

  docker --version

.. note:: O seguinte se aplica a sistemas Linux executando o systemd.

Certifique-se de que o daemon do Docker esteja em execução.

.. code:: bash

  sudo systemctl start docker

Opcional: Se você quiser o daemon do Docker para iniciar quando o sistema inicia, use o seguinte:

.. code:: bash

  sudo systemctl enable docker

Adicionando um usuário para seu grupo docker.

.. code:: bash

  sudo usermod -a -G docker <username>

.. note:: A instalação do Docker para Mac ou Windows, ou do Docker Toolbox também
          intalará o Docker Compose. Se você já instalou o Docker, você
          deve checar se o Docker Compose está na versão 1.14.0 ou superior
          instalada. Se não, nós recomendamos que você instale a versão recente
          mais recente do Docker.

Você ppode checar a versão do Docker Compose instalado com o
seguinte comando em um prompt de terminal:

.. code:: bash

  docker-compose --version

.. _Go:

Linguagem de programação Go
-----------------------

Hyperledger Fabric utiliza a linguagem de programação Go para muitos de seus
componentes.

  - `Go <https://golang.org/dl/>`__ versão 1.14.x é necessária.

Dado que nós vamos escrever programas chaincode em Go, tem dois
variáveis de ambiente você precisará definir corretamente; você pode tornar estas
configurações permanente, colocando-as no arquivo de inicialização apropriado, como
seu arquivo pessoal ``~/.bashrc`` se você estiver usando o shell ``bash``
no Linux.

Primeiro, voçe deve definir a variável de ambiente ``GOPATH`` para o apontar para a
área de trabalho Go que contem a base de código do Fabric baixada, com algo como:

.. code:: bash

  export GOPATH=$HOME/go

.. note:: Você **deve** definir a variável GOPATH

  Mesmo que, no Linux, a variável ``GOPATH`` de Go possa ser uma lista de diretórios separados
  por dois pontos, e usará um valor padrão de ``$HOME/go`` se não estiver definido,
  a estrutura de construção do framework Fabric atual ainda requer a definição e exportação dessa
  variável, e ela deve conter **somente** o nome do diretório único name para o espaço de
  trabalho Go. (Esta restrição pode ser removida em uma versão futura.)

Segundo, você deve (novamente, em um arquivo de inicialização apropriado) extender seu
caminho de pesquisa para incluir o diretório Go ``bin``, tal como é seguido
no exemplo a seguir para ``bash`` no Linux:

.. code:: bash

  export PATH=$PATH:$GOPATH/bin

Enquanto este diretório possa não existir em uma nova instalação do espaço de trabalho Go, este é
preenchido posteriormente pelo sistema de compilação do Fabric com um pequeno número de executavéis Go
usados por outras partes de uma compilação do sistema (of the build system). Portanto, mesmo se você ainda não tiver
neste diretório, estenda o caminho de pesquisa do shell como acima.

Node.js Runtime e NPM
-----------------------

Se você vai desenvolver aplicações para Hyperledger Fabric aproveitando o
SDK do Hyperledger Fabric para Node.js, versão 8 é compatível com a versão 8.9.4 e superior.
Node.js versão 10 é compatível com 10.15.3 e superior.

  - `Node.js <https://nodejs.org/en/download/>`__ download

.. note:: Instalando Node.js vai também instalar o NPM, no enquanto é recomendado
          que você confirme a versão do NPM instalada. Você pode atualizar
          a ferramente ``npm`` com o seguinte comando:

.. code:: bash

  npm install npm@5.6.0 -g

Python
^^^^^^

.. note:: A seguir se aplica somente para usuários Ubuntu 16.04.

Por padrão o Ubuntu 16.04 vem com Python 3.5.1 instalado como o binário do ``python3``.
O Fabric Node.js SDK requer uma iteração do Python 2.7 para que as operações com ``npm install``
sejam completadas com sucesso. Recupere a versão 2.7 com o seguinte comando:

.. code:: bash

  sudo apt-get install python

Cheque sua(s) versão(ões):

.. code:: bash

  python --version

.. _windows-extras:

Windows extras
--------------

Se você estiver desenvolvendo no Windows 7, convém trabalhar dentro do
Terminal Docker Quickstart. No enquanto, por padrão, ele usa um antigo `Git
Bash <https://git-scm.com/downloads>`__ e a experiencia tem mostrado que este
é um ambiente de desenvolvimento pobre com funcionalidades limitadas. Ele é
adequado para executar cenários baseados em Docker, como
:doc:`getting_started`, mas você terá dificuldades com operações
envolvendo os comandos ``make`` e ``docker``.

Em vez disso, é recomendado usar o ambiente MSYS2 e executar o make
e docker a partir do shell de comando MSYS2. Para fazer isso, `install
MSYS2 <https://github.com/msys2/msys2/wiki/MSYS2-installation>`__
(junto com o conjunto de ferramentas do desenvolvedor básico e pacotes gcc usando
pacman) e inicie o Docker Toolbox a partir do shell MSYS2 com o
seguinte comando:

::

   /c/Program\ Files/Docker\ Toolbox/start.sh

Alternativamente, você pode alterar o comando Docker Quickstart Terminal
para usar o bash MSYS2 alterando o destino do atalho do Windows de:

::

   "C:\Program Files\Git\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"

para:

::

   "C:\msys64\usr\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"

Com a alteração acima, você pode agora simplesmente iniciar o Docker Quickstart
Terminal e obter o ambiente adequado.

No Windows 10 você deve usar a distribuição nativa do Docker e pode
usar o Windows PowerShell. No entanto, para que o comando ``binaries``
tenha sucesso você ainda precisará ter o comando ``uname``
disponível. Você pode obtê-lo como parte do Git, mas cuidado, pois apenas a versão
de 64bit é compatível.

Antes de executar qualquer comando de ``git clone``, execute os seguintes comandos:

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

Você pode checar a configuração desses parametros com o seguintes comandos:

::

    git config --get core.autocrlf
    git config --get core.longpaths

Eles precisam ser ``false`` (falso) e ``true`` (verdadeiro) respectivamente.

O comando ``curl`` que vem com o Git e Docker Toolbox é antigo e
não lida corretamente com o redirecionamento usado em
:doc:`getting_started`. Certifique=se de ter e usar uma versão mais recente,
a qual pode ser baixada na `página de download cURL
<https://curl.haxx.se/download.html>`__

Para Node.js você também vai precisar necessáriamente da ferramente de compilação do Visual Studio C++,
a qual está disponivel gratuitamente e pode ser instalada seguindo o
comando:

.. code:: bash

	  npm install --global windows-build-tools

Veja a `página NPM windows-build-tools
<https://www.npmjs.com/package/windows-build-tools>`__ para mais
detalhes.

Feito isso, você deve instalar o módulo NPM GRPC com o
comando seguinte:

.. code:: bash

	  npm install --global grpc

Seu ambiente deve estar agora pronto para passar para
:doc:`getting_started` exemplos e tutoriais.

.. note:: Se você tem perguntas/dúvidas não respondidas nesta documentação,
          ou com qualquer um um dos tutoriais, por favor visite a página 
          :doc:`questions` para algumas dicas sobre onde encontrar ajuda adicional.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
