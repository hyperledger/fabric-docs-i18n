# 安装 Fabric 和 Fabric 例子

请安装[先决条件](./prereqs.html)，然后按照这些安装说明安装。

我们认为理解事物的最好方法是自己使用它。为了帮助你使用 Fabric，我们使用 Docker compose 创建了一个简单的 Fabric 测试网络，以及一组示例应用程序，展示了它的核心功能。

我们还预编译了 `Fabric CLI工具二进制文件` 和 `Fabric Docker 镜像`，它们将被下载到您的环境中，以便您使用。

下面说明中的cURL命令将设置您的环境，以便您可以运行Fabric测试网络。具体来说，它执行以下步骤：

* 克隆 [hyperledger/fabric-samples](https://github.com/hyperledger/fabric-samples) 存储库。
* 下载最新的 Hyperledger Fabric Docker 镜像并将其标记为 `latest`
* 下载以下特定于平台的 Hyperledger Fabric CLI工具二进制文件和配置文件到 `fabric-samples` `/bin` 和 `/config` 目录中。这些二进制文件将帮助您与测试网络进行交互。
  * `configtxgen`,
  * `configtxlator`,
  * `cryptogen`,
  * `discover`,
  * `idemixgen`,
  * `orderer`,
  * `osnadmin`,
  * `peer`,
  * `fabric-ca-client`,
  * `fabric-ca-server`

## 下载 Fabric 示例、Docker 镜像和二进制文件{#downloading-the-fabric-samples-docker-images-and-binaries}

需要一个工作目录 —— 例如，Go开发人员使用 `$HOME/go/src/github.com/<your_github_userid>` 目录。这是 Golang 社区对 Go 项目的推荐。

```shell
mkdir -p $HOME/go/src/github.com/<your_github_userid>
cd $HOME/go/src/github.com/<your_github_userid>
```

获取安装脚本：

```bash
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

使用 `-h` 选项运行脚本以查看选项：

```bash
./install-fabric.sh -h
Usage: ./install-fabric.sh [-f|--fabric-version <arg>] [-c|--ca-version <arg>] <comp-1> [<comp-2>] ... [<comp-n>] ...
        <comp>: Component to install one or more of  d[ocker]|b[inary]|s[amples]. If none specified, all will be installed
        -f, --fabric-version: FabricVersion (default: '2.5.2')
        -c, --ca-version: Fabric CA Version (default: '1.5.6')
```

## 选择哪些组件{#choosing-which-components}

要指定下载的组件，请添加以下一个或多个参数。每个参数都可以简写为它的第一个字母。

* `docker` 使用 Docker 下载 Fabric 容器镜像
* `podman` 使用 podman 下载 Fabric 容器映像
* `binary` 下载 Fabric 二进制文件
* `samples` 将 fabric-samples 的 github 仓库克隆到当前目录

要获取 Docker 容器并克隆示例仓库，请运行以下命令之一

```bash
./install-fabric.sh docker samples binary
or
./install-fabric.sh d s b
```

如果没有提供参数，则假定参数为 `docker binary samples`。

## 选择哪个版本{#choosing-which-version}

默认使用组件的最新版本;可以使用选项 `--fabric-version` 和 `-ca-version`来修改这些版本。`-f` 和`-c` 是各自的缩写形式。

例如，下载v2.5.2版本的二进制文件，执行以下命令

```bash
./install-fabric.sh --fabric-version 2.5.2 binary
```

至此，Fabric 示例、Docker 镜像和二进制文件已经安装完成。

* 如果您想要设置您的环境来为 Fabric 做出贡献，请参阅[设置贡献者开发环境](https://hyperledger-fabric.readthedocs.io/en/latest/dev-setup/devenv.html)的说明。

> 注意：这是一个更新的安装脚本，最终结果与现有脚本相同，但语法有所改进。此脚本采用主动选择的方式来选择要安装的组件。 原始的脚本仍然存在于相同的位置 `curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh| bash -s`

* 如果你需要帮助，请在 [Hyperledger Discord Chat](https://discord.com/invite/hyperledger) 或 [StackOverflow](https://stackoverflow.com/questions/tagged/hyperledger-fabric) 的 **fabric-questions** 频道上发表您的问题并分享您的日志。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
