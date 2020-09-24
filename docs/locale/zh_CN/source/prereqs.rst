准备阶段
========================

在我们开始之前，如果您还没有这样做，您可能希望检查以下所有先决条件是否已安装在您将开发区块链应用程序或运行 Hyperledger Fabric 的平台上。

.. note:: 以下准备阶段是针对Fabric用户推荐的。如果你是Fabric开发者，你应该参考设置开发环境文档 :doc:`dev-setup/devenv`.

安装 Git
-----------
如果还没安装，下载最新版本的 `git
<https://git-scm.com/downloads>`_ , 或者你运行curl命令有问题。

安装 cURL
------------

如果尚未安装 cURl 或在服务器上运行 curl 命令出错时请下载最新版本的 `cURL <https://curl.haxx.se/download.html>`__ 工具。

.. note:: 如果你是在 Windows 上的话，请查看下边的 `Windows附加功能`_ 里的特殊说明。

Docker 和 Docker Compose
------------------------------------

您将需要在将要运行或基于 Hyperledger Fabric 开发（或开发 Hyperledger Fabric）的平台上安装以下内容：

  - MacOSX， \*nix 或 Windows 10： 要求 `Docker <https://www.docker.com/get-docker>`__ 版本 17.06.2-ce 及以上。
  - 较旧版本的 Windows：`Docker
    Toolbox <https://docs.docker.com/toolbox/toolbox_install_windows/>`__ - 要求 Docker 版本 17.06.2-ce 及以上。

您可以通过执行以下命令来检查已安装的 Docker 的版本：

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

.. note:: 在 Mac 或 Windows 以及 Docker Toolbox 中安装 Docker，也会安装 Docker Compose。如果您已安装 Docker，则应检查是否已安装 Docker Compose 版本 1.14.0 或更高版本。如果没有，我们建议您安装最新版本的 Docker。


您可以通过执行以下命令来检查已安装的 Docker Compose 的版本：

.. code:: bash

  docker-compose --version

.. _windows-extras:

Windows附加功能
------------------------------------------

在 Windows 10 上，你应该使用本地 Docker 发行版，并且可以使用 Windows PowerShell。但是你仍需要可用的 ``uname`` 命令以便成功运行 ``二进制`` 命令。你可以通过 Git 来得到它，但是只支持 64 位的版本。

在运行任何``git clone``命令前，运行如下命令：

::

    git config --global core.autocrlf false
    git config --global core.longpaths true

你可以通过如下命令检查这些参数的设置：

::

    git config --get core.autocrlf
    git config --get core.longpaths

它们必须分别是 ``false`` 和 ``true`` 。

Git 和 Docker Toolbox 附带的 ``curl`` 命令很旧，无法正确处理 :doc:`getting_started` 中使用的重定向。因此要确保你从 `cURL 下载页 <https://curl.haxx.se/download.html>`__ 安装并使用的是较新版本。

.. note:: 如果你有本文档未解决的问题，或遇到任何有关教程的问题，请访问 :doc:`questions` 页面，获取有关在何处寻求其他帮助的一些提示。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
