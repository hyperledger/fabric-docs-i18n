Prerequisites - 先决条件
=============

Before we begin, if you haven't already done so, you may wish to check that
you have all the prerequisites below installed on the platform(s)
on which you'll be developing blockchain applications and/or operating
Hyperledger Fabric.

在我们开始之前，如果您还没有这样做，您可能希望检查以下所有先决条件是否已安装在您将开发区块链应用程序以及/或运行Hyperledger Fabric的平台上。

Install cURL - 安装cURL
------------

Download the latest version of the `cURL
<https://curl.haxx.se/download.html>`__ tool if it is not already
installed or if you get errors running the curl commands from the
documentation.

如果尚未安装cURl或在服务器上运行文档中的curl命令出错时请下载最新版本的`cURL<https://curl.haxx.se/download.html>`__ 工具。

.. note:: If you're on Windows please see the specific note on `Windows
   extras`_ below.

.. note:: 如果您使用的是Windows，请参阅下面有关Windows附加功能(`Windows extras`_)的特定说明。

Docker and Docker Compose
-------------------------

You will need the following installed on the platform on which you will be
operating, or developing on (or for), Hyperledger Fabric:

  - MacOSX, \*nix, or Windows 10: `Docker <https://www.docker.com/get-docker>`__
    Docker version 17.06.2-ce or greater is required.
  - Older versions of Windows: `Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ -
    again, Docker version Docker 17.06.2-ce or greater is required.

您将需要在将要运行或基于Hyperledger Fabric开发（或开发Hyperledger Fabric）的平台上安装以下内容：

  - MacOSX，* nix或Windows 10： 要求 `Docker <https://www.docker.com/get-docker>`__ Docker版本17.06.2-ce及以上。
  - 较旧版本的Windows：`Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ - 要求Docker版本Docker 17.06.2-ce及以上。

You can check the version of Docker you have installed with the following
command from a terminal prompt:

您可以通过执行以下终端提示符中的命令来检查已安装的Docker的版本：

.. code:: bash

  docker --version

.. note:: Installing Docker for Mac or Windows, or Docker Toolbox will also
          install Docker Compose. If you already had Docker installed, you
          should check that you have Docker Compose version 1.14.0 or greater
          installed. If not, we recommend that you install a more recent
          version of Docker.

.. note:: 在Mac或Windows以及Docker Toolbox中安装Docker， 也会安装Docker Compose。 如果您已安装Docker，则应检查是否已安装
          Docker Compose版本1.14.0或更高版本。 如果没有，我们建议您安装最新版本的Docker。

You can check the version of Docker Compose you have installed with the
following command from a terminal prompt:

您可以通过执行以下终端提示符中的命令来检查已安装的Docker Compose的版本：

.. code:: bash

  docker-compose --version

.. _Golang:

Go Programming Language - Go 编程语言
-----------------------

Hyperledger Fabric uses the Go Programming Language for many of its
components.

  - `Go <https://golang.org/dl/>`__ version 1.11.x is required.

Hyperledger Fabric许多组件使用Go编程语言开发。

  - `Go <https://golang.org/dl/>`__ 要求 1.11.x 版本.

Given that we will be writing chaincode programs in Go, there are two
environment variables you will need to set properly; you can make these
settings permanent by placing them in the appropriate startup file, such
as your personal ``~/.bashrc`` file if you are using the ``bash`` shell
under Linux.

鉴于我们将在Go中编写链码程序，您需要正确设置两个环境变量; 您可以将这些设置永久保存在相应的启动文件中，例如您的个人``~/.bashrc``文件（如果您在Linux下使用``bash``shell）。

First, you must set the environment variable ``GOPATH`` to point at the
Go workspace containing the downloaded Fabric code base, with something like:

首先，您必须将环境变量 ``GOPATH`` 设置为指向包含下载的Fabric代码库的Go工作空间，例如：

.. code:: bash

  export GOPATH=$HOME/go

.. note:: You **must** set the GOPATH variable

  Even though, in Linux, Go's ``GOPATH`` variable can be a colon-separated list
  of directories, and will use a default value of ``$HOME/go`` if it is unset,
  the current Fabric build framework still requires you to set and export that
  variable, and it must contain **only** the single directory name for your Go
  workspace. (This restriction might be removed in a future release.)

.. note:: 您 **必须** 设置GOPATH变量

  即使在Linux中，Go的``GOPATH``变量可以是以冒号分隔的目录列表，如果未设置，将使用默认值``$HOME/go``，
  当前的Fabric构建框架仍然需要您设置和输出该变量，它必须**只**包含Go工作区的单个目录名称。（此限制可能会在将来的版本中删除。）

Second, you should (again, in the appropriate startup file) extend your
command search path to include the Go ``bin`` directory, such as the following
example for ``bash`` under Linux:

其次，您应该（再次，在适当的启动文件中）扩展您的命令搜索路径以包含Go ``bin``目录，例如下面是Linux下的``bash``示例：

.. code:: bash

  export PATH=$PATH:$GOPATH/bin

While this directory may not exist in a new Go workspace installation, it is
populated later by the Fabric build system with a small number of Go executables
used by other parts of the build system. So even if you currently have no such
directory yet, extend your shell search path as above.

虽然此目录可能不存在于新安装的Go工作区中，但稍后由Fabric构建系统填充，其中构建系统的其他部分使用少量Go可执行文件。
因此，即使您目前还没有此类目录，也可以像上面那样扩展shell搜索路径。

Node.js Runtime and NPM - Node.js运行环境及NPM
-----------------------

If you will be developing applications for Hyperledger Fabric leveraging the
Hyperledger Fabric SDK for Node.js, you will need to have version 8.9.x of Node.js
installed.

如果你将用Node.js的Hyperledger Fabric SDK开发Hyperledger Fabric的应用程序，则需安装Node.js的8.9.x版本.

.. note:: Versions other than the 8.x series are not supported at this time. 目前不支持8.x系列以外的版本。

  - `Node.js <https://nodejs.org/en/download/>`__ - version 8.x

.. note:: Installing Node.js will also install NPM, however it is recommended
          that you confirm the version of NPM installed. You can upgrade
          the ``npm`` tool with the following command:

.. note:: 安装Node.js也会安装NPM，但建议您确认安装的NPM版本。 您可以使用以下命令升级``npm`` 工具：

.. code:: bash

  npm install npm@5.6.0 -g

Python
^^^^^^

.. note:: The following applies to Ubuntu 16.04 users only.

.. note:: 以下内容仅适用于Ubuntu 16.04用户.

By default Ubuntu 16.04 comes with Python 3.5.1 installed as the ``python3`` binary.
The Fabric Node.js SDK requires an iteration of Python 2.7 in order for ``npm install``
operations to complete successfully.  Retrieve the 2.7 version with the following command:

默认情况下，Ubuntu 16.04附带了Python 3.5.1安装的``python3`` 二进制文件。Fabric Node.js SDK需要使用
Python 2.7版本才能成功完成 npm install 操作。使用以下命令安装2.7版本：

.. code:: bash

  sudo apt-get install python

Check your version(s):

检查您的版本:

.. code:: bash

  python --version

.. _windows-extras:

Windows extras - Windows附加功能
--------------

If you are developing on Windows 7, you will want to work within the
Docker Quickstart Terminal which uses `Git Bash
<https://git-scm.com/downloads>`__ and provides a better alternative
to the built-in Windows shell.

如果您在Windows 7上进行开发，则需要在使用 `Git Bash<https://git-scm.com/downloads>`__ 的Docker Quickstart终端中工作，
它是一个比内置Windows shel更好的替代方案。

However experience has shown this to be a poor development environment
with limited functionality. It is suitable to run Docker based
scenarios, such as :doc:`getting_started`, but you may have
difficulties with operations involving the ``make`` and ``docker``
commands.

然而，经验表明这是一个功能有限的糟糕开发环境。它适合运行基于Docker的场景，如 :doc:`getting_started`，
但你可能在操作包括``make``和 ``docker``命令时出现问题。

On Windows 10 you should use the native Docker distribution and you
may use the Windows PowerShell. However, for the ``binaries``
command to succeed you will still need to have the ``uname`` command
available. You can get it as part of Git but beware that only the
64bit version is supported.

在Windows 10上，你应该使用本地Docker发行版，并且可以使用Windows PowerShell。但是你仍需要可用的``uname``命令以便成功运行``binaries``命令。

Before running any ``git clone`` commands, run the following commands:

在运行任何``git clone``命令前，运行如下命令：
::

    git config --global core.autocrlf false
    git config --global core.longpaths true

You can check the setting of these parameters with the following commands:

你可以通过如下命令检查这些参数的设置：

::

    git config --get core.autocrlf
    git config --get core.longpaths

These need to be ``false`` and ``true`` respectively.

它们必须分别是false和true 。

The ``curl`` command that comes with Git and Docker Toolbox is old and
does not handle properly the redirect used in
:doc:`getting_started`. Make sure you install and use a newer version
from the `cURL downloads page <https://curl.haxx.se/download.html>`__

Git和Docker Toolbox附带的``curl``命令很旧，无法正确处理:doc:`getting_started`中使用的重定向。
因此要确保你从`cURL downloads page <https://curl.haxx.se/download.html>`__ 安装并使用的是较新版本。

For Node.js you also need the necessary Visual Studio C++ Build Tools
which are freely available and can be installed with the following
command:

对于Node.js，你还需要必需的Visual Studio C ++构建工具，它是免费可用的并且可以使用以下命令进行安装：

.. code:: bash

	  npm install --global windows-build-tools

See the `NPM windows-build-tools page
<https://www.npmjs.com/package/windows-build-tools>`__ for more
details.

有关更多详细信息，请参阅 `NPM windows系统搭建工具页面`__ 。

Once this is done, you should also install the NPM GRPC module with the
following command:

完成此操作后，还应使用以下命令安装NPM GRPC模块：

.. code:: bash

	  npm install --global grpc

Your environment should now be ready to go through the
:doc:`getting_started` samples and tutorials.

你的环境现在应该已准备好实现:doc:`getting_started`中的示例和教程。

.. note:: If you have questions not addressed by this documentation, or run into
          issues with any of the tutorials, please visit the :doc:`questions`
          page for some tips on where to find additional help.

.. note:: 如果你有本文档未解决的问题，或遇到任何有关教程的问题，请访问 :doc:`questions`页面，
          获取有关在何处寻求其他帮助的一些提示。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
