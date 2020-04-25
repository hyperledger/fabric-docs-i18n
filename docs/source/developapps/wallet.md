# 钱包

**受众**：架构师、应用程序和智能合约应用开发者们

一个钱包包括了一组用户身份。当与通道连接的时候，应用程序会从这些身份中选择一个用户来运行。对通道资源的访问权限，比如账本，由与 MSP（Membership provider）相关联的这个身份所定义。

在本主题中，我们将涉及：

* [为什么钱包是重要的](#场景)
* [钱包是如何被组织的](#结构)
* [钱包的不同类型](#类型)
* [钱包的操作](#操作)

## 场景

当应用程序连接到一个比如像 PaperNer 的网络通道的时候，它选择一个用户身份去这么做，例如 `ID1`。通道的 MSP 将 `ID1` 与组织内特定的角色相关联，而且这个角色将最终决定应用程序在通道上的权限。、

![wallet.scenario](./develop.diagram.10.png)
*两个用户， Isabella 和 Balaji 拥有包含能够用于连接不同网络通道的不同身份的钱包，PaperNet 和 BondNet。*

思考一下这两个用户的例子；来自于 MagnetoCorp 的 lsabella 和来自 DigiBank 的 Balaji。Isabella 打算使用应用程序1去调用 PaperNet 里的智能合约和一个 BondNet 的智能合约。同理，Balaji 打算使用应用程序2去调用智能合约，但是这是在 PaperNet 中。（对于应用程序来说，访问多个网络和其中多个的智能合约是[简单的](./application.html#construct-request)。)

看一下：

* MagnetoCorp 使用 CA1 去颁发身份，DigiBank 使用 CA2 去颁发身份。这些身份被存储在用户的钱包中。

* Balaji 的钱包拥有一个唯一的身份, `ID4` 由 CA2 发行。Isabella 的钱包拥有多种被 CA1 颁发的身份，`ID1`、 `ID2`  和 `ID3`。钱包能够让一个用户拥有多个身份，并且每一个身份都能由不同的 CA 颁发。

* Isabella 和 Balaji 都连接到 PaperNet，它（PaperNet）的 MSP 确定了 Isabella 是 MagnetoCorp 的成员，且确定了 Balaji 是 DigiBank 组织的一员，因为信任颁发他们身份的 CA。（一个组织使用多个 CA 或者一个 CA 支持多个组织是[可能的](../membership/membership.html#mapping-msps-to-organizations)） 

* Isabella 能够使用 `ID1` 去连接 PaperNet 和 BondNet。在这两种情况下，当 Isabella 使用这个身份时候，她会被是识别为 MangetoCorp 的一员。

* Isabella 能够使用 `ID2` 去连接 BondNet，在这种情况下，她被标识为 MagnetoCorp 的管理员。这给了 Isabella 两种不同的权利：`ID1` 把她标识为能够读写 BondNet 账本的 MagnetoCorp 的普通一员，然而 `ID2` 标识她为能够给 BondNet 添加组织的 MagnetoCorp 的管理员。

* Balaji 不能够使用 `ID4` 连接 BondNet。如果他尝试去连接，`ID4` 将不会被认可其属于 DigiBank，因为 CA2 不知道 BondNet 的 MSP。

## 类型

根据他们身份存储的位置，会有不同的钱包的类型。

![wallet.types](./develop.diagram.12.png)
*四种不同的钱包类型:文件系统、内存、硬件安全模块和 CouchDB*

* **文件系统（FileSystem）**：这是存储钱包最常见的地方；文件系统是无处不在的、容易理解且可以挂载在网络上。对于钱包来说，这是很好的默认选择。

  使用 `FileSystemWallet` [class](https://fabric-sdk-node.github.io/master/module-fabric-network.FileSystemWallet.html)去管理文件系统钱包。


* **内存（In-memory）**：存储在应用程序里的钱包。当你的应用程序正在运行在一个没有访问文件系统的约束环境的时候，使用这种类型的钱包；有代表性的是 web 浏览器。需要记住的是这种类型的钱包是不稳定的；在应用程序正常结束或者崩溃的时候，身份将失去丢失。

  使用 `InMemoryWallet`  [类](https://fabric-sdk-node.github.io/master/module-fabric-network.InMemoryWallet.html) 去管理内存钱包。

* **硬件安全模块（HSM）**：一个钱包存储在 [HSM](https://en.wikipedia.org/wiki/Hardware_security_module)。这个超安全、防干扰设备存储数字身份信息，特别是私钥。HSM 能够本地连接到你的电脑或可访问的网络。

  一般你应该将 `FileSystemWallet` [类](https://fabric-sdk-node.github.io/master/module-fabric-network.FileSystemWallet.html) 与 [HSMWalletMixin](https://fabric-sdk-node.github.io/master/module-fabric-network.HSMWalletMixin.html) 类联合使用以管理 HSM 钱包。

* **CouchDB**：存储在 Couch DB 的钱包。这是最罕见的一种钱包存储形式，但是对于想去使用数据备份和恢复机制的用户来说，CouchDB 钱包能够提供一个有用的选择去简化崩溃的恢复。

  使用 `CouchDBWallet`  [类](https://fabric-sdk-node.github.io/master/module-fabric-network.CouchDBWallet.html)去管理 CouchDB 钱包.

## 结构

一个单一的钱包能够保存多个身份，每一个都被一个被指定的证书机构发放。每一个身份都有一个规范的带有描述性标签的结构，一个包括公钥、私钥与一些 Fabric-specific 元数据的 X.509 证书。不同的[钱包类型](#类型) 将这个结构合理地映射到他们地存储机制上。

![wallet.structure](./develop.diagram.11.png)
*Fabric 钱包能够持有多个被不同证书机构颁发的身份，身份包含了证书、私钥和一些 Fabric 元数据*

这是几个关键的类方法，使得钱包和身份更容易被管理：

```JavaScript
const identity = X509WalletMixin.createIdentity('Org1MSP', certificate, key);

await wallet.import(identityLabel, identity);
```

看一下 `X509WalletMixin.createIdentity()` [方法](https://fabric-sdk-node.github.io/master/module-fabric-network.X509WalletMixin.html)如何创建一个包含元数据 `Org1MSP` 、`证书` 和一个`私钥` 的身份 。

`网关`类只需要为一个身份设置一个 `mspid` 元数据，如上述例子中的 `Org1MSP`。它*当前*使用这个值去识别来自于[连接配置](./connectionprofile.html)特定的 Peer 节点，例如，当一个特定的通知[策略](./connectoptions.html)被要求的时候。在 DigiBank 网关文件 `networkConnection.yaml`，看一下 `Org1MSP` 通知将如何与 `peer0.org1.example.com` 关联：

```yaml
organizations:
  Org1:
    mspid: Org1MSP

    peers:
      - peer0.org1.example.com
```

你真的不需要担心内部不同的钱包类型的结构，但是如果你感兴趣，导航到商业票据例子里的用户身份文件夹：

```
magnetocorp/identity/user/isabella/
                                  wallet/
                                        User1@org1.example.com/
                                                              User1@org.example.com
                                                              c75bd6911aca8089...-priv
                                                              c75bd6911aca8089...-pub
```

你能够检查这些文件，但是正如讨论的，它很容易去使用 SDK 实现这些数据。

## 选项

一个共同的[钱包](https://fabric-sdk-node.github.io/master/module-fabric-network.Wallet.html)基类衍生出不同的钱包类，该基类提供了管理身份的一套标准的 API 。这意味着可以使应用程序独立于底层钱包存储机制；比如，文件系统和 HSM 钱包被一个非常相似方法来处理。

![wallet.operations](./develop.diagram.13.png)
*钱包遵循一个生命周期：他们能够被创建、被打开，身份能够被读取、添加、删除和导出。*

应用程序能够根据一个简单的生命周期去使用钱包。钱包能够被打开、创建，随后可以添加、读取、更新、删除和导出身份。花费一些时间在 [JSDOC](https://fabric-sdk-node.github.io/master/module-fabric-network.Wallet.html) 中不同的 `Wallet` 方法上来看一下他们是如何工作的；商业票据的教程在 `addToWallet.js` 中提供了一个很好的例子：

```JavaScript
const wallet = new FileSystemWallet('../identity/user/isabella/wallet');

const cert = fs.readFileSync(path.join(credPath, '.../User1@org1.example.com-cert.pem')).toString();
const key = fs.readFileSync(path.join(credPath, '.../_sk')).toString();

const identityLabel = 'User1@org1.example.com';
const identity = X509WalletMixin.createIdentity('Org1MSP', cert, key);

await wallet.import(identityLabel, identity);
```

注意：

* 当程序第一次运行的时候，钱包被创建在本地文件系统 `.../isabella/wallet`。

* `证书`和`密钥`从文件系统中下载。

* 一个新的身份使用`证书`,`密钥`来创建，并且 `Org1MSP` 使用 `X509WalletMixin.createIdentity()`。

* 新的身份通过 `wallet.import()` 导出带有 `User1@org1.example.com` 标签的钱包中。

这是关于钱包你所要知道的所有事情。你已经看到用户代表在访问 Fabric 网络资源上，钱包如何持有被应用程序使用的身份的。根据你的应用程序和安全需要，这里有一些有用的不同类型的钱包，和一套简单的 API 去帮助应用程序去管理其内部的钱包和身份。

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
