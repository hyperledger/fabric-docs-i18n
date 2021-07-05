Pré-requisitos
=============

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
Antes de iniciar, se ainda não tiver feito isso, você pode verificar se possui 
todos os pré-requisitos abaixo instalados na(s) plataforma(s)
na qual desenvolverá aplicativos blockchain e/ou operará o
Hyperledger Fabric.

Instale Git
=======
Antes de iniciar, você deveconfirmar se instalou todos os pré-requisitos abaixo na plataforma onde executará oHyperledger Fabric.
=======
Before we begin, if you haven't already done so, you may wish to check that
Antes de iniciar, se ainda não ter feito isso, você pode verificar se possui 
=======
Antes de iniciar, se ainda não tiver feito isso, você pode verificar se possui 
>>>>>>> 9b5a018 (Update prereqs.rst)
todos os pré-requisitos abaixo instalados na(s) plataforma(s)
na qual desenvolverá aplicativos blockchain e/ou operará o
Hyperledger Fabric.
>>>>>>> f9a0bc8 (tradução pre final)

<<<<<<< HEAD
Instalar Git
>>>>>>> 3ceaa37 (begin)
=======
Instale Git
>>>>>>> 9b5a018 (Update prereqs.rst)
-----------
Baixe a última versão do `git
<https://git-scm.com/downloads>`_ se ainda não estiver instalado
ou se você tiver problemas ao executar os comandos curl.

<<<<<<< HEAD
<<<<<<< HEAD
Instale cURL
------------

Baixe a última versão da ferramenta `cURL
<https://curl.haxx.se/download.html>`__ se ainda não estiver instalado
ou se você receber erros ao executar os comandos curl da
documentação.

.. note:: Se você estiver no Windows, por favor consulte a nota de especificação abaixo em `Windows
   extras`_.
=======
Instalando cURL
=======
Instale cURL
>>>>>>> 9b5a018 (Update prereqs.rst)
------------

Baixe a última versão da ferramenta `cURL
<https://curl.haxx.se/download.html>`__ se ainda não estiver instalado
ou se você receber erros ao executar os comandos curl da
documentação.

<<<<<<< HEAD
.. note:: Se você estiver no Windows, por favor consulte a nota de especificação em `Windows
   extras`_ abaixo.
>>>>>>> 3ceaa37 (begin)
=======
.. note:: Se você estiver no Windows, por favor consulte a nota de especificação abaixo em `Windows
   extras`_.
>>>>>>> 9b5a018 (Update prereqs.rst)

Docker e Docker Compose
-------------------------

<<<<<<< HEAD
<<<<<<< HEAD
Você precisará das seguintes instalações em sua plataforma em que
estiver operando ou desenvolvendo em (ou para) Hyperledger Fabric:
=======
Você precisará das seguintes instações em sua plataforma de operação ou desenvolvimento
operating, or developing on (or for), Hyperledger Fabric:
>>>>>>> 3ceaa37 (begin)

  - MacOSX, \*nix, ou Windows 10: `Docker <https://www.docker.com/get-docker>`__
    Docker versão 17.06.2-ce ou superior.
  - Versões antigas do Windows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
    novamente, Docker versão Docker 17.06.2-ce ou superior.
=======
Você precisará das seguintes instalações em sua plataforma em que
estiver operando ou desenvolvendo em (ou para) Hyperledger Fabric:

  - MacOSX, \*nix, ou Windows 10: `Docker <https://www.docker.com/get-docker>`__
    Docker versão 17.06.2-ce ou superior.
  - Versões antigas do Windows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
<<<<<<< HEAD
    novamente, Docker versão Docker 17.06.2-ce ou superior é necessária.
>>>>>>> f9a0bc8 (tradução pre final)
=======
    novamente, Docker versão Docker 17.06.2-ce ou superior.
>>>>>>> 9b5a018 (Update prereqs.rst)

Você pode checar a versão do Docker instalada com o seguinte 
comando em um prompt de terminal:

.. code:: bash

  docker --version

<<<<<<< HEAD
.. note:: As seguintes instruções se aplicam a sistemas Linux executando o systemd.
=======
.. note:: O seguinte se aplica a sistemas Linux executando o systemd.
>>>>>>> f9a0bc8 (tradução pre final)

Certifique-se de que o daemon do Docker esteja em execução.

.. code:: bash

  sudo systemctl start docker

<<<<<<< HEAD
<<<<<<< HEAD
Opcional: Se você quiser que o daemon do Docker seja iniciado quando o sistema for iniciado, use o comando:
=======
Opcional: Se você quiser o daemon do Docker para iniciar quando o sistema inicia, use o seguinte:
>>>>>>> f9a0bc8 (tradução pre final)
=======
Opcional: Se você quiser que o daemon do Docker seja iniciado quando o sistema for iniciado, use o comando:
>>>>>>> 9b5a018 (Update prereqs.rst)

.. code:: bash

  sudo systemctl enable docker

<<<<<<< HEAD
Adicione um usuário para seu grupo docker.
=======
Adicionando um usuário para seu grupo docker.
>>>>>>> f9a0bc8 (tradução pre final)

.. code:: bash

  sudo usermod -a -G docker <usuário>

.. note:: A instalação do Docker para Mac ou Windows, ou do Docker Toolbox também
<<<<<<< HEAD
          instalará o Docker Compose. Se você já instalou o Docker, você
          deve checar se o Docker Compose está na versão 1.14.0 ou superior
          instalada. Se não, nós recomendamos que você instale a versão
          mais recente do Docker.

Você pode checar a versão do Docker Compose instalado com o
=======
          intalará o Docker Compose. Se você já instalou o Docker, você
          deve checar se o Docker Compose está na versão 1.14.0 ou superior
          instalada. Se não, nós recomendamos que você instale a versão
          mais recente do Docker.

<<<<<<< HEAD
Você ppode checar a versão do Docker Compose instalado com o
>>>>>>> f9a0bc8 (tradução pre final)
=======
Você pode checar a versão do Docker Compose instalado com o
>>>>>>> 9b5a018 (Update prereqs.rst)
seguinte comando em um prompt de terminal:

.. code:: bash

  docker-compose --version

.. _Go:

Linguagem de programação Go
-----------------------

Hyperledger Fabric utiliza a linguagem de programação Go para muitos de seus
componentes.

  - `Go <https://golang.org/dl/>`__ versão 1.14.x é necessária.

<<<<<<< HEAD
<<<<<<< HEAD
Dado que nós vamos escrever programas chaincode em Go, existem duas
variáveis de ambiente que você precisará definir corretamente; você pode tornar estas
configurações permanente colocando-as no arquivo de inicialização apropriado, como
=======
Dado que nós vamos escrever programas chaincode em Go, tem dois
variáveis de ambiente você precisará definir corretamente; você pode tornar estas
configurações permanente, colocando-as no arquivo de inicialização apropriado, como
>>>>>>> f9a0bc8 (tradução pre final)
=======
Dado que nós vamos escrever programas chaincode em Go, existem duas
variáveis de ambiente que você precisará definir corretamente; você pode tornar estas
configurações permanente colocando-as no arquivo de inicialização apropriado, como
>>>>>>> 9b5a018 (Update prereqs.rst)
seu arquivo pessoal ``~/.bashrc`` se você estiver usando o shell ``bash``
no Linux.

Primeiro, voçe deve definir a variável de ambiente ``GOPATH`` para o apontar para a
<<<<<<< HEAD
<<<<<<< HEAD
área de trabalho Go que contem a base de código do Fabric baixada, algo como:
=======
área de trabalho Go que contem a base de código do Fabric baixada, com algo como:
>>>>>>> f9a0bc8 (tradução pre final)
=======
área de trabalho Go que contem a base de código do Fabric baixada, algo como:
>>>>>>> 9b5a018 (Update prereqs.rst)

.. code:: bash

  export GOPATH=$HOME/go

.. note:: Você **deve** definir a variável GOPATH

  Mesmo que, no Linux, a variável ``GOPATH`` de Go possa ser uma lista de diretórios separados
  por dois pontos, e usará um valor padrão de ``$HOME/go`` se não estiver definido,
  a estrutura de construção do framework Fabric atual ainda requer a definição e exportação dessa
<<<<<<< HEAD
<<<<<<< HEAD
  variável, e ela deve conter **somente** o nome do diretório único para o espaço de
  trabalho Go. (Esta restrição pode ser removida em uma versão futura.)

Em segundo lugar, você deve (novamente, no arquivo de inicialização apropriado) estender seu
=======
  variável, e ela deve conter **somente** o nome do diretório único name para o espaço de
  trabalho Go. (Esta restrição pode ser removida em uma versão futura.)

Segundo, você deve (novamente, em um arquivo de inicialização apropriado) extender seu
>>>>>>> f9a0bc8 (tradução pre final)
=======
  variável, e ela deve conter **somente** o nome do diretório único para o espaço de
  trabalho Go. (Esta restrição pode ser removida em uma versão futura.)

Em segundo lugar, você deve (novamente, no arquivo de inicialização apropriado) estender seu
>>>>>>> 9b5a018 (Update prereqs.rst)
caminho de pesquisa para incluir o diretório Go ``bin``, tal como é seguido
no exemplo a seguir para ``bash`` no Linux:

.. code:: bash

  export PATH=$PATH:$GOPATH/bin

Enquanto este diretório possa não existir em uma nova instalação do espaço de trabalho Go, este é
preenchido posteriormente pelo sistema de compilação do Fabric com um pequeno número de executavéis Go
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
usados por outras partes do sistema de compilação. Portanto, mesmo que você ainda não tenha
esse diretório, estenda o caminho de pesquisa do shell como acima.
=======
usados por outras partes de uma compilação do sistema (of the build system). Portanto, mesmo se você ainda não tiver
neste diretório, estenda o caminho de pesquisa do shell como acima.
>>>>>>> f9a0bc8 (tradução pre final)
=======
usados por outras partes de uma compilação do sistema (of the build system). Portanto, mesmo que você ainda não tenha
=======
usados por outras partes do sistema de compilação. Portanto, mesmo que você ainda não tenha
>>>>>>> 64053f8 (Update prereqs.rst)
esse diretório, estenda o caminho de pesquisa do shell como acima.
>>>>>>> 9b5a018 (Update prereqs.rst)

Node.js Runtime e NPM
-----------------------

Se você vai desenvolver aplicações para Hyperledger Fabric aproveitando o
<<<<<<< HEAD
<<<<<<< HEAD
SDK do Hyperledger Fabric para Node.js, a versão 8 é compatível com a versão 8.9.4 e superior.
A versão 10 de Node.js é compatível com 10.15.3 e superior.
=======
SDK do Hyperledger Fabric para Node.js, versão 8 é compatível com a versão 8.9.4 e superior.
Node.js versão 10 é compatível com 10.15.3 e superior.
>>>>>>> f9a0bc8 (tradução pre final)
=======
SDK do Hyperledger Fabric para Node.js, a versão 8 é compatível com a versão 8.9.4 e superior.
A versão 10 de Node.js é compatível com 10.15.3 e superior.
>>>>>>> 9b5a018 (Update prereqs.rst)

  - `Node.js <https://nodejs.org/en/download/>`__ download

.. note:: Instalando Node.js vai também instalar o NPM, no enquanto é recomendado
          que você confirme a versão do NPM instalada. Você pode atualizar
<<<<<<< HEAD
<<<<<<< HEAD
          a ferramenta ``npm`` com o seguinte comando:
=======
          a ferramente ``npm`` com o seguinte comando:
>>>>>>> f9a0bc8 (tradução pre final)
=======
          a ferramenta ``npm`` com o seguinte comando:
>>>>>>> 9b5a018 (Update prereqs.rst)

.. code:: bash

  npm install npm@5.6.0 -g

Python
^^^^^^

<<<<<<< HEAD
<<<<<<< HEAD
.. note:: O seguinte se aplica somente a usuários Ubuntu 16.04.
=======
.. note:: A seguir se aplica somente para usuários Ubuntu 16.04.
>>>>>>> f9a0bc8 (tradução pre final)
=======
.. note:: O seguinte se aplica somente a usuários Ubuntu 16.04.
>>>>>>> 9b5a018 (Update prereqs.rst)

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

<<<<<<< HEAD
Em vez disso, é recomendado usar o ambiente MSYS2 e execute o make
e docker a partir do shell de comando MSYS2. Para fazer isso, `instale o
=======
Em vez disso, é recomendado usar o ambiente MSYS2 e executar o make
<<<<<<< HEAD
e docker a partir do shell de comando MSYS2. Para fazer isso, `install
>>>>>>> f9a0bc8 (tradução pre final)
=======
e docker a partir do shell de comando MSYS2. Para fazer isso, `instale o
>>>>>>> 9b5a018 (Update prereqs.rst)
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
<<<<<<< HEAD
:doc:`getting_started`. Certifique-se de ter e usar uma versão mais recente,
a qual pode ser baixada na `página de download cURL
<https://curl.haxx.se/download.html>`__.

Para Node.js você também vai precisar necessariamente da ferramente de compilação do Visual Studio C++,
=======
:doc:`getting_started`. Certifique=se de ter e usar uma versão mais recente,
a qual pode ser baixada na `página de download cURL
<https://curl.haxx.se/download.html>`__.

Para Node.js você também vai precisar necessáriamente da ferramente de compilação do Visual Studio C++,
>>>>>>> f9a0bc8 (tradução pre final)
a qual está disponivel gratuitamente e pode ser instalada seguindo o
comando:

.. code:: bash

	  npm install --global windows-build-tools

Veja a `página NPM windows-build-tools
<https://www.npmjs.com/package/windows-build-tools>`__ para mais
detalhes.

<<<<<<< HEAD
Uma vez feito isso, você também deve instalar o módulo NPM GRPC com o
=======
Feito isso, você deve instalar o módulo NPM GRPC com o
>>>>>>> f9a0bc8 (tradução pre final)
comando seguinte:

.. code:: bash

	  npm install --global grpc

Seu ambiente deve estar agora pronto para passar para
<<<<<<< HEAD
<<<<<<< HEAD
exemplos e tutoriais em :doc:`getting_started`.

.. note:: Se você tem perguntas/dúvidas não respondidas nesta documentação,
          ou com qualquer um dos tutoriais, por favor visite a página 
=======
:doc:`getting_started` exemplos e tutoriais.

.. note:: Se você tem perguntas/dúvidas não respondidas nesta documentação,
          ou com qualquer um um dos tutoriais, por favor visite a página 
>>>>>>> f9a0bc8 (tradução pre final)
=======
exemplos e tutoriais em :doc:`getting_started`.

.. note:: Se você tem perguntas/dúvidas não respondidas nesta documentação,
          ou com qualquer um dos tutoriais, por favor visite a página 
>>>>>>> 9b5a018 (Update prereqs.rst)
          :doc:`questions` para algumas dicas sobre onde encontrar ajuda adicional.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
