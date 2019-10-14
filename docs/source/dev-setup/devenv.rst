设置开发环境
--------------------------------------

概览
~~~~~~~~

在 v1.0.0 之前，使用 Vagrant 运行 Ubuntu 镜像来作为开发环境来加载 Docker 镜像，以此让使用不同操作系统的开发者有相同的开发体验，比如 macOS, Windows， Linux 或者其他系统。大多数操作系统都已经原生支持 Docker 了，比如 macOS、Windows。因此我们已经开始使用 Docker 来进行构建了。但是我们仍然维护着 Vagrant 的方法，因为有一些旧版本的 macOS 和 Windows 系统不支持 Docker。我们强烈建议不要再使用 Vagrant 开发了。

值得提醒的是，基于 Vagrant 的开发不能部署在云环境中，但是基于 Docker 可以，目前支持的云平台有 AWS、Azure、Google 和 IBM 等。请参考下边的内容在 Ubuntu 下构建。

前置工作
~~~~~~~~~~~~~

-  `Git 客户端 <https://git-scm.com/downloads>`__
-  `Go <https://golang.org/dl/>`__ - 版本 1.11.x
-  （macOS） 必须安装 `Xcode <https://itunes.apple.com/us/app/xcode/id497799835?mt=12>`__
-  `Docker <https://www.docker.com/get-docker>`__ - 17.06.2-ce 或更高版本
-  `Docker Compose <https://docs.docker.com/compose/>`__ - 1.14.0 或更高版本
-  `Pip <https://pip.pypa.io/en/stable/installing/>`__
-  （macOS） 你必须安装 gnutar，macOS 默认使用 bsdtar，但是构建使用了一些 gnutar 的参数。你可以使用 Homebrew 来安装它:

::

    brew install gnu-tar --with-default-names

-  （macOS） `Libtool <https://www.gnu.org/software/libtool/>`__ 。你可以使用 Homebrew 来安装它：

::

    brew install libtool

-  （只有使用 Vagrant 的需要安装） - `Vagrant <https://www.vagrantup.com/>`__ - 1.9 或更高版本
-  （只有使用 Vagrant 的需要安装） - `VirtualBox <https://www.virtualbox.org/>`__ - 5.0 或更高版本
-  BIOS 开启虚拟化，因硬件而异
-  注意: BIOS虚拟化设置可能在 BIOS 的 CPU 或者 Security 设置里。

``pip``
~~~~~~

::

    pip install --upgrade pip


步骤
~~~~~

设置 GOPATH
^^^^^^^^^^^^^^^

确保你已经设置了你主机的 `GOPATH 环境变量 <https://github.com/golang/go/wiki/GOPATH>`__ 。只有设置了环境变量才能在你的主机或者虚拟机中编译。

如果你安装的 Go 不在默认位置，请确保你设置了 `GOROOT 环境变量 <https://golang.org/doc/install#install>`__ 。

Windows 用户请注意
^^^^^^^^^^^^^^^^^^^^^

如果你用的是 Windows 系统，在运行 ``git clone`` 命令之前，请先运行如下命令。

::

    git config --get core.autocrlf

如果 ``core.autocrlf`` 为 ``true``, 你必须将它设置为 ``false`` 

::

    git config --global core.autocrlf false

如果你将 ``core.autocrlf`` 设置为 ``true``，``vagrant up`` 命令将会报错:


``./setup.sh: /bin/bash^M: bad interpreter: No such file or directory``

克隆 Hyperledger Fabric 项目源代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

因为 Hyperledger Fabric 是用 ``Go`` 编写的，所以你需要将它克隆到 $GOPATH/src 目录。如果你有多个 $GOPATH，请选择第一个 $GOPATH。有一些内容需要设置：

::

    cd $GOPATH/src
    mkdir -p github.com/hyperledger
    cd github.com/hyperledger

重申一下，我们使用 ``Gerrit`` 来管理源码，``Gerrit`` 内部有自己的 git 仓库。因此我们需要从 :doc:`Gerrit <../Gerrit/gerrit>` 克隆。命令如下：

::

    git clone ssh://LFID@gerrit.hyperledger.org:29418/fabric && scp -p -P 29418 LFID@gerrit.hyperledger.org:hooks/commit-msg fabric/.git/hooks/

**注意:** 当然你要将 ``LFID`` 替换为你的 :doc:`Linux Foundation ID <../Gerrit/lf-account>` 。

使用 Vagrant 启动虚拟机
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

如果你想用 Vagrant 来开发，你需要执行如下步骤。**再说一次，我们只建议在不支持 Docker 的系统中使用该方法。**

::

    cd $GOPATH/src/github.com/hyperledger/fabric/devenv
    vagrant up

来杯咖啡。。。这需要点时间。完成后，你就可以通过 ``ssh`` 进入刚才创建的 Vagrant 虚拟机了。

::

    vagrant ssh

进入到虚拟机之后，你就可以看到 ``$GOPATH/src/github.com/hyperledger/fabric`` 下边的源码了。它被挂载在 ``/hyperledger`` 目录。

构建 Hyperledger Fabric
~~~~~~~~~~~~~~~~~~~~~~~~~~~

当你安装好了所有依赖，并且克隆了仓库，你就可以执行 :doc:`构建和测试 <build>` Hyperledger
Fabric 了。

注意事项
~~~~~~~~~~~~~~~~~~~~

**注意：** 你修改的 fabric 文件（在 ``$GOPATH/src/github.com/hyperledger/fabric`` 目录下）会同步在虚拟机中的 fabric 文件夹中更新。

**注意：** 如果你想在 HTTP 代理下运行开发环境，你就需要配置客户端。你可以通过 *vagrant-proxyconf* 来完成。通过 ``vagrant plugin install vagrant-proxyconf`` 进行安装，然后在执行 ``vagrant up`` *之前* 配置 VAGRANT\_HTTP\_PROXY and VAGRANT\_HTTPS\_PROXY 环境变量。详情请查看这里： here: https://github.com/tmatilai/vagrant-proxyconf/

**注意：** 第一次运行的时候会比较耗时（可能会超过30分钟），在这期间你会以为它什么都没做。如果没有报错，就让它继续运行。

**Windows 10的用户请注意：** T在 Windows 10下有一个已知的 vagrant 问题（查看 `hashicorp/vagrant#6754 <https://github.com/hashicorp/vagrant/issues/6754>`__）。如果 ``vagrant up`` 命令执行失败，可能是因为你没有安装 Microsoft Visual C++ Redistributable。你可以在这个地址下载缺失的软件包：http://www.microsoft.com/en-us/download/details.aspx?id=8328

**注意：** 编译 fabric 的过程中 miekg/pkcs11 依赖 ltdl.h。请确认您安装了 libtool 和 libltdl-dev。否则你会遇到丢失 ltdl.h 头文件错误。你可以通过该命令安装缺失的软件包： ``sudo apt-get install -y build-essential git make curl unzip g++ libtool``。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

