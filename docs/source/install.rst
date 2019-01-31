Install Samples, Binaries and Docker Images - 安装示例、二进制文件和Docker镜像
===========================================

While we work on developing real installers for the Hyperledger Fabric
binaries, we provide a script that will download and install samples and
binaries to your system. We think that you'll find the sample applications
installed useful to learn more about the capabilities and operations of
Hyperledger Fabric.

在我们为Hyperledger Fabric二进制文件开发真正的安装程序时，我们提供了一个脚本，可以下载
并安装样例和二进制文件到您的系统。 我们认为您会发现安装的示例应用程序可以帮助去了解Hyperledger
 Fabric有关的功能和运维的更多信息。

.. note:: If you are running on **Windows** you will want to make use of the
	  Docker Quickstart Terminal for the upcoming terminal commands.
          Please visit the :doc:`prereqs` if you haven't previously installed
          it.

          If you are using Docker Toolbox on Windows 7 or macOS, you
          will need to use a location under ``C:\Users`` (Windows 7) or
          ``/Users`` (macOS) when installing and running the samples.

          If you are using Docker for Mac, you will need to use a location
          under ``/Users``, ``/Volumes``, ``/private``, or ``/tmp``.  To use a different
          location, please consult the Docker documentation for
          `file sharing <https://docs.docker.com/docker-for-mac/#file-sharing>`__.

          If you are using Docker for Windows, please consult the Docker
          documentation for `shared drives <https://docs.docker.com/docker-for-windows/#shared-drives>`__
          and use a location under one of the shared drives.


.. note:: 如果您在 **Windows** 上运行样例，则需要使用Docker快速启动终端来执行即将发布的终端命令。
          如果您之前没有安装，请访问 :doc:`prereqs` 。

          如果您在Windows 7或macOS上使用Docker Toolbox， 您在安装和运行示例需要使用到 ``C:\Users`` （Windows 7）
          或 ``/Users`` （macOS）目录下的路径。

          如果您在Mac上使用Docker，则需要使用到 ``/Users``、 ``/Volumes``、 ``/private``、 或 ``/tmp``
          这些目录下的路径。 要使用其他路径，请参阅Docker文档以获取
          `文件共享 <https://docs.docker.com/docker-for-mac/#file-sharing>`__ 。

          如果您在Windows下使用Docker，请参阅Docker文档以获取
          `共享驱动器 <https://docs.docker.com/docker-for-windows/#shared-drives>`__ ，并使用其中一个共享驱动器下的路径。

Determine a location on your machine where you want to place the `fabric-samples`
repository and enter that directory in a terminal window. The
command that follows will perform the following steps:

#. If needed, clone the `hyperledger/fabric-samples <https://github.com/hyperledger/fabric-samples>`_ repository
#. Checkout the appropriate version tag
#. Install the Hyperledger Fabric platform-specific binaries and config files
   for the version specified into the /bin and /config directories of fabric-samples
#. Download the Hyperledger Fabric docker images for the version specified

确定计算机上要放置 `fabric-samples` 仓存的位置，并在终端窗口中进入该目录。 按以下步骤执行相关命令：

#. 如果需要，克隆 `hyperledger/fabric-samples <https://github.com/hyperledger/fabric-samples>`_ 仓库
#. 检出适当的版本标签
#. 将指定版本的Hyperledger Fabric平台特定二进制文件和配置文件安装到fabric-samples下的/bin和/config目录中
#. 下载指定版本的Hyperledger Fabric docker镜像

Once you are ready, and in the directory into which you will install the
Fabric Samples and binaries, go ahead and execute the following command:

一旦您准备好了，在要安装Fabric Samples和二进制文件的目录中，继续执行以下命令：

.. code:: bash

  curl -sSL http://bit.ly/2ysbOFE | bash -s 1.4.0

.. note:: If you want to download different versions for Fabric, Fabric-ca and thirdparty
          Docker images, you must pass the version identifier for each.

.. note:: 如果要为Fabric、Fabric-ca和第三方Docker镜像下载不同的版本，则必须为每个镜像传递版本标识符。

.. code:: bash

  curl -sSL http://bit.ly/2ysbOFE | bash -s <fabric> <fabric-ca> <thirdparty>
  curl -sSL http://bit.ly/2ysbOFE | bash -s 1.4.0 1.4.0 0.4.14

.. note:: If you get an error running the above curl command, you may
          have too old a version of curl that does not handle
          redirects or an unsupported environment.

	  Please visit the :doc:`prereqs` page for additional
	  information on where to find the latest version of curl and
	  get the right environment. Alternately, you can substitute
	  the un-shortened URL:
	  https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh

.. note:: 如果运行上述curl命令时出错，则可能是旧版本的curl不能处理重定向或环境不支持。

          请访问 :doc:`prereqs` 页面获取有有关在哪里可以找到最新版的curl并获得正确环境的其他信息。
          或者，您可以访问未缩写的URL： https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh

.. note:: You can use the command above for any published version of Hyperledger
          Fabric. Simply replace `1.4.0` with the version identifier
          of the version you wish to install.

.. note:: 你可以在任何已发布的Hyperledger Fabric版本使用上述命令。 只需将 `1.4.0` 替换为你要安装的版本的版本标识符即可。

The command above downloads and executes a bash script
that will download and extract all of the platform-specific binaries you
will need to set up your network and place them into the cloned repo you
created above. It retrieves the following platform-specific binaries:

上面的命令下载并执行一个bash脚本，该脚本将下载并提取设置网络所需的所有特定于平台的二进制文件，
并将它们放入您在上面创建的克隆仓库中。它检索以下特定平台的二进制文件：

  * ``configtxgen``,
  * ``configtxlator``,
  * ``cryptogen``,
  * ``discover``,
  * ``idemixgen``
  * ``orderer``,
  * ``peer``, and
  * ``fabric-ca-client``

and places them in the ``bin`` sub-directory of the current working
directory.

并将它们放在当前工作目录的子目录 ``bin`` 中。

You may want to add that to your PATH environment variable so that these
can be picked up without fully qualifying the path to each binary. e.g.:

你可能希望将其添加到PATH环境变量中，以便在不需要指定每个二进制文件的绝对路径的情况下获取这些命令。
例如：

.. code:: bash

  export PATH=<path to download location>/bin:$PATH

Finally, the script will download the Hyperledger Fabric docker images from
`Docker Hub <https://hub.docker.com/u/hyperledger/>`__ into
your local Docker registry and tag them as 'latest'.

最后，该脚本会将从 `Docker Hub <https://hub.docker.com/u/hyperledger/>`__ 上下载
Hyperledger Fabric docker镜像到本地Docker注册表中，并将其标记为 'latest'。

The script lists out the Docker images installed upon conclusion.

该脚本列出了结束时安装的Docker镜像。

Look at the names for each image; these are the components that will ultimately
comprise our Hyperledger Fabric network.  You will also notice that you have
two instances of the same image ID - one tagged as "amd64-1.x.x" and
one tagged as "latest". Prior to 1.2.0, the image being downloaded was determined
by ``uname -m`` and showed as "x86_64-1.x.x".

查看每个镜像的名称；这些组件最终将构成我们的Hyperledger Fabric网络。你还会注意到，你有两个具有相
同镜像ID的实例——一个标记为“amd64-1.x.x”，另一个标记为 "latest"。在1.2.0之前，由 ``uname -m``
命令结果来确定下载的镜像，并显示为“x86_64-1.x.x”。

.. note:: On different architectures, the x86_64/amd64 would be replaced
          with the string identifying your architecture.

.. note:: 在不同的体系架构中，x86_64/amd64将替换为标识你的体系架构的字符串。

.. note:: If you have questions not addressed by this documentation, or run into
          issues with any of the tutorials, please visit the :doc:`questions`
          page for some tips on where to find additional help.

.. note:: 如果你有本文档未解决的问题，或遇到任何有关教程的问题，请访问 :doc:`questions`
          页面，获取有关在何处寻求其他帮助的一些提示。

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
