先决条件
========================

在我们开始之前，如果您还没有这样做，您可能希望检查以下所有先决条件是否已安装在您将开发区块链应用程序以及/或运行 Hyperledger Fabric 的平台上。

安装cURL
------------

如果尚未安装cURl或在服务器上运行文档中的curl命令出错时请下载最新版本的 `cURL <https://curl.haxx.se/download.html>`__ 工具。

.. note:: 如果你是在 Windows 上的话，请查看下边的 `Windows extras`_ 里的特殊说明。

安装 wget
------------

如果你想要基于 :doc:`install` 文档来下载 Fabric binaries 文件的话，你需要安装 ``wget``。

  - MacOSX 默认不包含 ``wget``，你可以使用 ``brew install wget`` 来安装。

Docker 和 Docker Compose
------------------------------------

您将需要在将要运行或基于 Hyperledger Fabric 开发（或开发 Hyperledger Fabric）的平台上安装以下内容：

  - MacOSX，* nix 或 Windows 10： 要求 `Docker <https://www.docker.com/get-docker>`__ Docker 版本 17.06.2-ce 及以上。
  - 较旧版本的 Windows：`Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ - 要求 Docker 版本Docker 17.06.2-ce 及以上。

您可以通过执行以下终端提示符中的命令来检查已安装的 Docker 的版本：

.. code:: bash

  docker --version

.. note:: 下边的适用于运行 systemd 的 linux 系统。

确保 docker daemon 是在运行着的。

.. code:: bash

  sudo systemctl start docker

可选：如果你希望 docker daemon 在系统启动的时候会自动启动的话，使用下边的命令：

.. code:: bash

  sudo systemctl enable docker

将你的用户添加到 docker 组。

.. code:: bash

  sudo usermod -a -G docker <username>

.. note:: 在 Mac 或 Windows 以及 Docker Toolbox 中安装 Docker， 也会安装 Docker Compose。 如果您已安装 Docker，则应检查是否已安装 Docker Compose 版本 1.14.0 或更高版本。 如果没有，我们建议您安装最新版本的 Docker。

您可以通过执行以下终端提示符中的命令来检查已安装的 Docker Compose 的版本：

.. code:: bash

  docker-compose --version

.. _Golang:

Go 编程语言
---------------------------------

Hyperledger Fabric 许多组件使用 Go 编程语言开发。

  - `Go <https://golang.org/dl/>`__ 要求 1.13.x 版本.

鉴于我们将在 Go 中编写链码程序，您需要正确设置两个环境变量; 您可以将这些设置永久保存在相应的启动文件中，例如您的个人 ``~/.bashrc`` 文件（如果您在 Linux 下使用 ``bash`` shell）。

首先，您必须将环境变量 ``GOPATH`` 设置为指向包含下载的 Fabric 代码库的 Go 工作空间，例如：

.. code:: bash

  export GOPATH=$HOME/go

.. note:: 您 **必须** 设置 GOPATH 变量

  即使在 Linux 中，Go 的 ``GOPATH`` 变量可以是以冒号分隔的目录列表，如果未设置，将使用默认值 ``$HOME/go`` ，
  当前的 Fabric 构建框架仍然需要您设置和输出该变量，它必须 **只** 包含Go工作区的单个目录名称。（此限制可能会在将来的版本中删除。）

其次，您应该（再次，在适当的启动文件中）扩展您的命令搜索路径以包含Go ``bin``目录，例如下面是Linux下的``bash``示例：

.. code:: bash

  export PATH=$PATH:$GOPATH/bin

虽然此目录可能不存在于新安装的Go工作区中，但稍后由Fabric构建系统填充，其中构建系统的其他部分使用少量Go可执行文件。因此，即使您目前还没有此类目录，也可以像上面那样扩展shell搜索路径。

Node.js运行环境及NPM
------------------------------------------------------------

如果你将用 Node.js 的Hyperledger Fabric SDK 开发 Hyperledger Fabric 的应用程序，版本 8 的支持是从 8.9.4 或者更高。Node.js 版本 10 的支持是从 10.15.3 或者更高。

  - `Node.js <https://nodejs.org/en/download/>`__ 下载

.. note:: 安装Node.js也会安装NPM，但建议您确认安装的NPM版本。 您可以使用以下命令升级 ``npm`` 工具：

.. code:: bash

  npm install npm@5.6.0 -g

Python
^^^^^^

.. note:: 以下内容仅适用于 Ubuntu 16.04 用户.

默认情况下，Ubuntu 16.04附带了Python 3.5.1安装的 ``python3`` 二进制文件。Fabric Node.js SDK需要使用
Python 2.7版本才能成功完成 ``npm install`` 操作。使用以下命令安装2.7版本：

.. code:: bash

  sudo apt-get install python

检查您的版本:

.. code:: bash

  python --version

.. _windows-extras:

Windows 附加功能
------------------------------------------

如果您在Windows 7上进行开发，你将会想要在 Docker Quickstart Terminal 上工作。但是，默认地它使用一个旧的 `Git Bash <https://git-scm.com/downloads>`__ 并且经验显示这个是个很差的开发环境，只有有限的功能。我们建议运行基于 Docker 的场景，比如 :doc:`getting_started`，但是当你调用 ``make`` 和 ``docker`` 命令的时候可能会遇到困难。

或者，我们建议使用 MSYS2 环境并且从 MSYS2 命令 shell 来运行 make 和 docker。你需要，`install MSYS2 <https://github.com/msys2/msys2/wiki/MSYS2-installation>`__（也包含基本的开发者 toolchain 和使用 pacman 的 gcc 包）并且从 MSYS2 shell 使用下边的命令来加载 Docker Toolbox：

::

   /c/Program\ Files/Docker\ Toolbox/start.sh

或者，你可以改变 Docker Quickstart 终端命令来使用 MSYS2 bash，通过改变 Windows shortcut 的目标从：

::

   "C:\Program Files\Git\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"

到：

::

   "C:\msys64\usr\bin\bash.exe" --login -i "C:\Program Files\Docker Toolbox\start.sh"

通过上边的改动，你现在可以简单地加载 Docker Quickstart Terminal 并且获得一个合适的环境。

在 Windows 10 上，你应该使用本地 Docker 发行版，并且可以使用 Windows PowerShell。但是你仍需要可用的 ``uname`` 命令以便成功运行 ``binaries`` 命令。

在运行任何``git clone``命令前，运行如下命令：
::

    git config --global core.autocrlf false
    git config --global core.longpaths true

你可以通过如下命令检查这些参数的设置：

::

    git config --get core.autocrlf
    git config --get core.longpaths

它们必须分别是false和true 。

Git 和 Docker Toolbox 附带的 ``curl`` 命令很旧，无法正确处理 :doc:`getting_started` 中使用的重定向。
因此要确保你从 `cURL downloads page <https://curl.haxx.se/download.html>`__ 安装并使用的是较新版本。

对于 Node.js，你还需要必需的 Visual Studio C ++ 构建工具，它是免费可用的并且可以使用以下命令进行安装：

.. code:: bash

	  npm install --global windows-build-tools

有关更多详细信息，请参阅 `NPM windows-build-tools 页面 <https://www.npmjs.com/package/windows-build-tools>`__ 。

完成此操作后，还应使用以下命令安装 NPM GRPC 模块：

.. code:: bash

	  npm install --global grpc

你的环境现在应该已准备好实现 :doc:`getting_started` 中的示例和教程。

.. note:: 如果你有本文档未解决的问题，或遇到任何有关教程的问题，请访问 :doc:`questions` 页面，获取有关在何处寻求其他帮助的一些提示。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
