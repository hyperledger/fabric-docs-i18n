构建 Hyperledger Fabric
---------------------------

下面的教程假设你已经设置好了你的 :doc:`开发环境 <devenv>`  。

构建 Hyperledger Fabric：

::

    cd $GOPATH/src/github.com/hyperledger/fabric
    make dist-clean all

运行单元测试
~~~~~~~~~~~~~~~~~~~~~~

使用下面的命令运行期所有单元测试

::

    cd $GOPATH/src/github.com/hyperledger/fabric
    make unit-test

要它运行一部分测试的话，要设置环境变量 TEST_PKGS。指定一个包的列表（用空格隔开），例如：

::

    export TEST_PKGS="github.com/hyperledger/fabric/core/ledger/..."
    make unit-test

要运行指定的测试，需要使用 ``-run RE`` 参数，RE 的意思是正则匹配测试用例的名字。使用 ``-v`` 参数显示输出。例如运行测试用例 ``TestGetFoo``，切换到包含 ``foo_test.go`` 的目录，然后执行：

::

    go test -v -run=TestGetFoo



运行 Node.js 客户端 SDK 的单元测试
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

要保证 Node.js client SDK 没有因为你的修改而出问题，你就必须运行 Node.js 单元测试。
要运行 Node.js 单元测试，请遵循`下述 <https://github.com/hyperledger/fabric-sdk-node/blob/master/README.md>`__ 指南。

在 Vagrant 之外构建
---------------------------

在 Vagrant 之外构建工程和运行节点也是可以的。你需要将 Vagrant `配置文件 <https://github.com/hyperledger/fabric/blob/master/devenv/setup.sh>`__ “翻译” 成与你选择的平台匹配的内容。

在 Z 上构建
~~~~~~~~~~~~~

为了方便快捷地在 Z 上构建，我们提供了 `这个脚本 <https://github.com/hyperledger/fabric/blob/master/devenv/setupRHELonZ.sh>`__ （和 Vagrant 的 `配置文件 <https://github.com/hyperledger/fabric/blob/master/devenv/setup.sh>`__ 类似）。该脚本只在 RHEL 7.2 上测试过，并且有一些设置你可能需要参考（防火墙设置，使用 root 用户开发等）。它仅仅适用于在个人开发者的虚拟机上进行开发。

从一个新安装的系统开始：

::

    sudo su
    yum install git
    mkdir -p $HOME/git/src/github.com/hyperledger
    cd $HOME/git/src/github.com/hyperledger
    git clone http://gerrit.hyperledger.org/r/fabric
    source fabric/devenv/setupRHELonZ.sh

后边的步骤请参考 Vagrant 开发环境。

::

    cd $GOPATH/src/github.com/hyperledger/fabric
    make peer unit-test

在 Power 平台上构建
~~~~~~~~~~~~~~~~~~~~~~~~~~

我们已经实现了在 vagrant 意外的 Power（ppc64le）系统上构建，参考 `这里<#building-outside-of-vagrant>`__ 。要想方便地在 Ubuntu 环境中构建，请使用 root 用户执行 `这个脚本 <https://github.com/hyperledger/fabric/blob/master/devenv/setupUbuntuOnPPC64le.sh>`__ 。这个脚本已经在 Ubuntu 16.04 上验证过了，但是也需要设置一些内容（比如，安装系统仓库，防火墙设置等等），这个脚本可以进一步改进。

要开始在 Ubuntu 上安装的 Power 服务器上构建，你首先要确保设置好了 `GOPATH 环境变量 <https://github.com/golang/go/wiki/GOPATH>`__ 。然后执行如下命令构建 Fabric 。

::

    mkdir -p $GOPATH/src/github.com/hyperledger
    cd $GOPATH/src/github.com/hyperledger
    git clone http://gerrit.hyperledger.org/r/fabric
    sudo ./fabric/devenv/setupUbuntuOnPPC64le.sh
    cd $GOPATH/src/github.com/hyperledger/fabric
    make dist-clean all

在 Centos 7 上构建
~~~~~~~~~~~~~~~~~~~~

你必须从源码安装 CouchDB，因为该发行版上没有 CouchDB 的安装包。如果你想使用多个排序节点，你同样需要从源码安装 Apache Kafka。Apache Kafka 包括 Zookeeper 和 Kafka 的可执行程序和相关配置文件。

::

   export GOPATH={directory of your choice}
   mkdir -p $GOPATH/src/github.com/hyperledger
   FABRIC=$GOPATH/src/github.com/hyperledger/fabric
   git clone https://github.com/hyperledger/fabric $FABRIC
   cd $FABRIC
   git checkout master # <-- only if you want the master branch
   export PATH=$GOPATH/bin:$PATH
   make native

如果你不想使用构建 Docker 镜像，那你就需要原生的。

配置
-------------

配置采用 `viper <https://github.com/spf13/viper>`__ 和 `cobra <https://github.com/spf13/cobra>`__ 库来实现。

peer 程序需要使用 **core.yaml** 作为配置文件。很多配置都可以被带有 *'CORE\_'* 前缀的环境变量覆盖。例如，通过环境变量设置日志级别：

::

    CORE_PEER_LOGGING_LEVEL=CRITICAL peer

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
