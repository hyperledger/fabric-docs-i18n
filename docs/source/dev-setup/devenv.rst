Setting up the development environment - 设置开发环境
-----------------------------------------------------

Prerequisites - 前置工作
~~~~~~~~~~~~~~~~~~~~~~~

-  `Git client <https://git-scm.com/downloads>`__
-  `Go <https://golang.org/dl/>`__ - version 1.11.x
-  (macOS)
   `Xcode <https://itunes.apple.com/us/app/xcode/id497799835?mt=12>`__
   must be installed
-  `Docker <https://www.docker.com/get-docker>`__ - 17.06.2-ce or later
-  `Docker Compose <https://docs.docker.com/compose/>`__ - 1.14.0 or later
-  (macOS) you may need to install gnutar, as macOS comes with bsdtar
   as the default, but the build uses some gnutar flags. You can use
   Homebrew to install it as follows:

::

    brew install gnu-tar --with-default-names

-  (macOS) `Libtool <https://www.gnu.org/software/libtool/>`__. You can use
   Homebrew to install it as follows:

::

    brew install libtool

-  (only if using Vagrant) - `Vagrant <https://www.vagrantup.com/>`__ -
   1.9 or later
-  (only if using Vagrant) -
   `VirtualBox <https://www.virtualbox.org/>`__ - 5.0 or later
-  BIOS Enabled Virtualization - Varies based on hardware

-  Note: The BIOS Enabled Virtualization may be within the CPU or
   Security settings of the BIOS


-  `Git 客户端 <https://git-scm.com/downloads>`__
-  `Go <https://golang.org/dl/>`__ - 版本 1.11.x
-  (macOS)
   `Xcode <https://itunes.apple.com/us/app/xcode/id497799835?mt=12>`__
   必须安装
-  `Docker <https://www.docker.com/get-docker>`__ - 17.06.2-ce 或者更高
-  `Docker Compose <https://docs.docker.com/compose/>`__ - 1.14.0 或者更高
-  (macOS) 你必须安装gnutar,macOS默认使用bsdtar，
   但是构建使用了一些gnutar的标识。 
   你可以使用Homebrew来安装它:

::

    brew install gnu-tar --with-default-names

-  (macOS) `Libtool <https://www.gnu.org/software/libtool/>`__ 。
    你可以使用Homebrew来安装它：

::

    brew install libtool

-  (只有使用Vagrant的需要安装) - `Vagrant <https://www.vagrantup.com/>`__ -
   1.9 或者更高
-  (只有使用Vagrant的需要安装) -
   `VirtualBox <https://www.virtualbox.org/>`__ - 5.0 或者更高
-  BIOS 支持虚拟化 - 因硬件而异

-  注意: BIOS虚拟化设置可能在BIOS的CPU或者Security setting里


Steps - 步骤
~~~~~~~~~~~~~~~

Set your GOPATH - 设置GOPATH
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Make sure you have properly setup your Host's `GOPATH environment
variable <https://github.com/golang/go/wiki/GOPATH>`__. This allows for
both building within the Host and the VM.

确保你已经设置了你主机的 
`GOPATH 环境变量 <https://github.com/golang/go/wiki/GOPATH>`__ 。
只有设置了环境变量才能在你的主机或者虚拟机中编译构建。

In case you installed Go into a different location from the standard one
your Go distribution assumes, make sure that you also set `GOROOT
environment variable <https://golang.org/doc/install#install>`__.

如果你安装的Go不在默认位置，确保你设置了
 `GOROOT环境变量 <https://golang.org/doc/install#install>`__ 。

Note to Windows users - Windows用户请注意
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are running Windows, before running any ``git clone`` commands,
run the following command.

如果你用的是Windows系统，在运行 ``git clone`` 命令之前，请先运行下列命令。

::

    git config --get core.autocrlf

If ``core.autocrlf`` is set to ``true``, you must set it to ``false`` by
running

如果 ``core.autocrlf`` 设置 ``true``, 你必须将它设置为 ``false`` 

::

    git config --global core.autocrlf false

If you continue with ``core.autocrlf`` set to ``true``, the
``vagrant up`` command will fail with the error:

如果你继续设置 ``core.autocrlf`` 为 ``true`` ，
``vagrant up`` 命令将会报错:

``./setup.sh: /bin/bash^M: bad interpreter: No such file or directory``

Cloning the Hyperledger Fabric source - 克隆Hyperledger Fabric项目源代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since Hyperledger Fabric is written in ``Go``, you'll need to
clone the source repository to your $GOPATH/src directory. If your $GOPATH
has multiple path components, then you will want to use the first one.
There's a little bit of setup needed:

因为Hyperledger Fabric是用 ``Go`` 写的，所以你需要将它克隆到$GOPATH/src目录。
如果你的$GOPATH有多个，那么请选择第一个$GOPATH。
这里有一些需要设置：

::

    cd $GOPATH/src
    mkdir -p github.com/hyperledger
    cd github.com/hyperledger

Recall that we are using ``Gerrit`` for source control, which has its
own internal git repositories. Hence, we will need to clone from
:doc:`Gerrit <../Gerrit/gerrit>`.
For brevity, the command is as follows:

重申一下，我们使用 ``Gerrit`` 来做代码的控制， ``Gerrit`` 内部有自己的git仓库。
因此我们需要从
:doc:`Gerrit <../Gerrit/gerrit>` 来克隆。

::

    git clone ssh://LFID@gerrit.hyperledger.org:29418/fabric && scp -p -P 29418 LFID@gerrit.hyperledger.org:hooks/commit-msg fabric/.git/hooks/

**Note:** Of course, you would want to replace ``LFID`` with your own
:doc:`Linux Foundation ID <../Gerrit/lf-account>`.

**注意:** 当然你要用将 ``LFID`` 替换为你的
:doc:`Linux Foundation ID <../Gerrit/lf-account>` 。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/

