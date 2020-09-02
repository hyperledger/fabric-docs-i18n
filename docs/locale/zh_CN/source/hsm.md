# 使用硬件安全模块（Hardware Security Module，HSM）

你可以使用硬件安全模块（HSM）来生成和存储 Fabric 节点使用的私钥。HSM 可以保护你的私钥并处理密码学操作，它可以让 Peer 节点和排序节点在不暴露私钥的情况下进行签名和背书。
The cryptographic operations performed by Fabric nodes can be delegated to
a Hardware Security Module (HSM).  An HSM protects your private keys and
handles cryptographic operations, allowing your peers and orderer nodes to
sign and endorse transactions without exposing their private keys.  If you
require compliance with government standards such as FIPS 140-2, there are
multiple certified HSMs from which to choose.

目前，Fabric 只支持按照 PKCS11 标准和 HSM 进行通信。

## 配置 HSM

要在 Fabric 节点中使用 HSM，你需要在节点配置文件（比如 core.yaml 或者 orderer.yaml）中更新 BCCSP （Crypto Service Provider，加密服务提供者）部分。在 BCCSP 部分中，你需要选择 PKCS11 作为提供者，并且要选择你要使用的 PKCS11 库所在的路径。你还需要提供你创建秘钥文件的 label 和 pin。你可以使用一个秘钥生成和保存多个秘钥。

预编译的 Hyperledger Fabric Docker 镜像不支持使用 PKCS11。如果你使用 docker 部署 Fabric，你需要重新编译镜像并启用 PKCS11，编译命令如下：
```
make docker GO_TAGS=pkcs11
```
你需要确保 PKCS11 库可用，你可以在节点上安装它，也可以把它挂载到容器里。

### 示例

下边的示例演示了如何配置 Fabric 节点使用 HSM。

首先，你需要安装 PKCS11 接口的实现。本示例使用开源实现 [softhsm](https://github.com/opendnssec/SoftHSMv2)。下载并配置 softhsm 之后，你需要将环境变量 SOFTHSM2_CONF 设置为 softhsm2 的配置文件。

然后你就可以使用 softhsm 来创建秘钥并在 Fabric 节点内部的 HSM slot 中处理密码学操作。在本示例中，我们创建了一个标记为 “fabric” 并把 pin 设置为 “71811222” 的秘钥。你创建秘钥之后，将配置文件修改为使用 PKCS11 和你的秘钥作为加密服务提供者。下边是一个 BCCSP 部分的示例：

```
#############################################################################
# BCCSP (BlockChain Crypto Service Provider) section is used to select which
# crypto library implementation to use
#############################################################################
bccsp:
  default: PKCS11
  pkcs11:
    Library: /etc/hyperledger/fabric/libsofthsm2.so
    Pin: "71811222"
    Label: fabric
    hash: SHA2
    security: 256
    Immutable: false
```

By default, when private keys are generated using the HSM, the private key is mutable, meaning PKCS11 private key  attributes can be changed after the key is generated. Setting `Immutable` to `true` means that the private key attributes cannot be altered after key generation. Before you configure immutability by setting `Immutable: true`, ensure that PKCS11 object copy is supported by the HSM.

你也可以使用环境变量覆盖配置文件中相关字段。如果你使用 Fabric CA 服务端链接 HSM，你需要设置如下环境变量或者 directly set the corresponding values in the CA server config file：

```
FABRIC_CA_SERVER_BCCSP_DEFAULT=PKCS11
FABRIC_CA_SERVER_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
FABRIC_CA_SERVER_BCCSP_PKCS11_PIN=71811222
FABRIC_CA_SERVER_BCCSP_PKCS11_LABEL=fabric
```

If you are connecting to softhsm2 using the Fabric peer, you could set the following environment variables or directly set the corresponding values in the peer config file:

```
CORE_PEER_BCCSP_DEFAULT=PKCS11
CORE_PEER_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
CORE_PEER_BCCSP_PKCS11_PIN=71811222
CORE_PEER_BCCSP_PKCS11_LABEL=fabric
```

If you are connecting to softhsm2 using the Fabric orderer, you could set the following environment variables or directly set the corresponding values in the orderer config file:

```
ORDERER_GENERAL_BCCSP_DEFAULT=PKCS11
ORDERER_GENERAL_BCCSP_PKCS11_LIBRARY=/etc/hyperledger/fabric/libsofthsm2.so
ORDERER_GENERAL_BCCSP_PKCS11_PIN=71811222
ORDERER_GENERAL_BCCSP_PKCS11_LABEL=fabric
```

如果你编译了 docker 镜像并使用 docker compose 部署节点，你可以修改 docker compose 配置文件的 volumes 部分来挂载 softhsm 库和配置文件。下边的示例演示了如何在docker compose 配置文件中设置环境变量和卷：
```
  environment:
     - SOFTHSM2_CONF=/etc/hyperledger/fabric/config.file
  volumes:
     - /home/softhsm/config.file:/etc/hyperledger/fabric/config.file
     - /usr/local/Cellar/softhsm/2.1.0/lib/softhsm/libsofthsm2.so:/etc/hyperledger/fabric/libsofthsm2.so
```

## 设置一个使用 HSM 的网络

如果你使用 HSM 部署 Fabric 节点，你需要在 HSM 中生成私钥而不是在节点本地 MSP 目录的 `keystore` 目录中。MSP 的 `keystore` 目录置空。另外，Fabric 节点会使用 `signcerts` 目录中签名证书的主体密钥标识符（subject key identifier）来检索 HSM 中的私钥。根据你使用 Fabric CA（Certificate Authority）还是你自己的 CA 的情况，创建 MSP 目录的操作是不一样的。

### Before you begin

Before configuring a Fabric node to use an HSM, you should have completed the following steps:

1. Created a partition on your HSM Server and recorded the `Label` and `PIN` of the partition.
2. Followed instructions in the documentation from your HSM provider to configure an HSM Client that communicates with your HSM server.

### 使用带有 HSM 的 Fabric CA

你可以像 Peer 节点或者排序节点一样，通过修改配置文件让 Fabric CA 使用 HSM。因为你可以使用 Fabric CA 在 HSM 内部生成秘钥，所以创建本地 MSP 目录的过程就很简单。按照下边的步骤：

1. Modify the `bccsp` section of the Fabric CA server configuration file and point to the `Label` and `PIN` that you created for your HSM. When the Fabric CA server starts, the private key is generated and stored in the HSM. If you are not concerned about exposing your CA signing certificate, you can skip this step and only configure an HSM for your peer or ordering nodes, described in the next steps.

2. 使用 Fabrci CA 客户端，用你的 CA 来注册 Peer 节点或者排序节点的身份。

3. Before you deploy a peer or ordering node with HSM support, you need to enroll the node identity by storing its private key in the HSM. Edit the `bccsp` section of the Fabric CA client config file or use the associated environment variables to point to the HSM configuration for your peer or ordering node. In the Fabric CA Client configuration file, replace the default `SW` configuration with the `PKCS11` configuration and provide the values for your own HSM:

  ```
  bccsp:
    default: PKCS11
    pkcs11:
      Library: /etc/hyperledger/fabric/libsofthsm2.so
      Pin: "71811222"
      Label: fabric
      hash: SHA2
      security: 256
      Immutable: false
  ```

  Then for each node, use the Fabric CA client to generate the peer or ordering node's MSP folder by enrolling against the node identity that you registered in step 2. Instead of storing the private key in the `keystore` folder of the associated MSP, the enroll command uses the node's HSM to generate and store the private key for the peer or ordering node. The `keystore` folder remains empty.

4. To configure a peer or ordering node to use the HSM, similarly update the `bccsp` section of the peer or orderer configuration file to use PKCS11 and provide the `Label` and `PIN`. Also, edit the value of the `mspConfigPath` (for a peer node) or the `LocalMSPDir` (for an ordering node) to point to the MSP folder that was generated in the previous step using the Fabric CA client. Now that the peer or ordering node is configured to use HSM, when you start the node it will be able sign and endorse transactions with the private key protected by the HSM.

### 在你自己的 CA 上使用 HSM

如果你使用你自己的 CA 来部署 Fabric 组件，你可以按如下步骤使用 HSM：

1. Configure your CA to communicate with an HSM using PKCS11 and create a `Label` and `PIN`.
Then use your CA to generate the private key and signing certificate for each
node, with the private key generated inside the HSM.

2. 使用你的 CA 构建节点 MSP 目录。将第 1 步生成的签名证书放入 `signcerts` 目录。你也可以让 `keystore` 目录为空。

3. To configure a peer or ordering node to use the HSM, similarly update the `bccsp` section of the peer or orderer configuration file to use PKCS11 andand provide the `Label` and `PIN`. Edit the value of the `mspConfigPath` (for a peer node) or the `LocalMSPDir` (for an ordering node) to point to the MSP folder that was generated in the previous step using the Fabric CA client. Now that the peer or ordering node is configured to use HSM, when you start the node it will be able sign and endorse transactions with the private key protected by the HSM.

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->