# 分析

**受众**: 架构师，应用和合约开发者，业务专家

接下来让我们详细探讨一下商业票据。MagnetoCorp 和 DigiBank 等 PaperNet 网络的参与者皆使用商业票据交易来实现自己的商业目的，我们来一起检验一下商业票据的结构以及逐渐影响这一结构的交易。我们还将基于各网络组织之间的信任关系来考虑哪个组织需要对交易签名。紧接着我们还将讨论票据买方和卖方之间的资金流动，不过现在让我们只关注 MagnetoCorp 发布的第一个票据。

## 商业票据生命周期

5月31号 MagnetoCorp 发行一张商业票据00001。花点时间来看看该票据的第一个**状态**，它具有不同的属性和值：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = MagnetoCorp
Issue date = 31 May 2020
Maturity = 30 November 2020
Face value = 5M USD
Current state = issued
```

该票据的状态是**发行**交易的结果，它使得 MagnetoCorp 公司的第一张商业票据面世！注意一下该票据在今年晚些时候将兑换500万美元。在发行票据00001时 `Issuer` 和 `Owner` 具有相同的值。该票据可有唯一标识 `MagnetoCorp00001`，它是 `Issuer` 属性和 `Paper` 属性的组合。最后，看属性 `Current state = issued` 如何快速识别 MagnetoCorp 票据 00001 在其生命周期中所处阶段。

发行后不久，票据被 DigiBank 买下。花点时间来看看该该票据如何因为此**购买**交易发生变化：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = DigiBank
Issue date = 31 May 2020
Maturity date = 30 November 2020
Face value = 5M USD
Current state = trading
```

最重要的变化是 `Owner` 的改变，票据初始拥有者是 `MagnetoCorp` 而现在是 `DigiBank`。我们可以想象如果后期该票据被出售给 BrokerHouse 或 HedgeMatic，则 `Owner` 也会相应更改为BrokerHouse 或 HedgeMatic。注意 `Current state` 让我们很容易识别出该票据目前状态是 `trading`。

六个月后，如果 DigiBank 仍然持有该商业票据，它就可以从 MagnetoCorp 那里进行兑换：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = MagnetoCorp
Issue date = 31 May 2020
Maturity date = 30 November 2020
Face value = 5M USD
Current state = redeemed
```

最终的**兑换**交易结束了这张商业票据的生命周期，可以认为生命周期已经终止。对已兑换的商业票据作记录通常是强制性的，`redeemed` 状态可以让我们能很快判断出票据是否已经兑换。通过对比 `Owner` 的值和交易创建者的身份,就可以利用票据的 `Owner` 值来执行**兑换**交易中的访问控制。Fabric 通过 [`getCreator()` 链码 API](https://github.com/hyperledger/fabric-chaincode-node/blob/master/fabric-shim/lib/stub.js#L293) 来支持这个功能。如果使用 golang 作为链码开发的语言，[客户端身份链码库](https://github.com/hyperledger/fabric/blob/master/core/chaincode/shim/ext/cid/README.md)可用于检索交易创建者的额外属性。

## 交易

从上文中我们可以看出，票据00001的生命周期相对直接，通过**发行**、**购买**和**兑换**交易，其生命周期在 `issued`、`trading` 和 `redeemed` 状态之间转换。

这三笔交易由 MagnetoCorp 和 DigiBank（两次）发起，使得00001票据的状态发生变化。让我们详细讨论一下对票据造成影响的交易：

### 发行（Issue）

看一下由 MagnetoCorp 发起的第一笔交易：

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

我们可以看到，**发行**交易的结构由属性和值组成。这个交易的结构和票据00001的结构不同但二者十分匹配。那是因为它们是不同的东西，票据00001反映的是 PaperNet 由于**发行**交易而产生的状态。它是包含这些属性并生成这张商业票据的**发行**交易背后的逻辑（这些我们看不到）。由于交易**创建**了票据，这也就意味着这些结构之间存在紧密联系。

**发行**交易唯一涉及到的组织是 MagnetoCorp。因此，MagnetoCorp 需要对这笔交易进行离线签名。一般来说票据的发行者需要在发行新票据的交易上进行离线签名。

### 购买（Buy）

接下来，看一下**购买**交易，该交易将票据00001的所有权从 MagnetoCorp 转移到 DigiBank：

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

对比之前的交易我们可以看到，**购买**交易中的属性更少。这是因为该交易只能**修改**该票据，它只改变了 `New owner = DigiBank` 属性，其余属性未发生变化。**购买**交易中最重要的点在于所有权的变更，事实上这份交易中存在票据当前所有人MagnetoCorp 的承认。



你可能会奇怪为什么 `Purchase time` 和 `Price` 这两个属性没有在票据00001中体现呢？这要回到交易和票据之间的差异。494万美元的价格标签实际上是交易的属性，而不是票据的属性。花点时间来思考一下这两者的不同，它并不像看上去那么明显。稍后我们会看到账本会记录一些信息，其中包括影响票据的所有交易历史，还包括票据的最新状态。弄清楚如何区分这些信息是非常重要的。

同样值得注意的是，票据00001可能会被买卖多次。尽管我们的场景中略微跳过了一部分环节，但我们还是来检查一下票据00001的所有权发生变更的话**可能**会发生哪些交易。

如果 BigFund 购买：

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = DigiBank
New owner = BigFund
Purchase time = 2 June 2020 12:20:00 EST
Price = 4.93M USD
```

接着由 HedgeMatic 购买：

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = BigFund
New owner = HedgeMatic
Purchase time = 3 June 2020 15:59:00 EST
Price = 4.90M USD
```

看看票据所有者如何变化，价格如何变化。你能想到 MagnetoCorp 商业票据价格会降低的原因吗？

一项**购买**交易需要买卖双方的签名以作为交易两方达成共识的证据。

### 兑换（Redeem）

票据00001的**兑换**交易代表了它生命周期的结束。以上这个例子相对简单，其中  HedgeMatic 是将商业票据交回 MagnetoCorp 这一交易的发起方：

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Current owner = HedgeMatic
Redeem time = 30 Nov 2020 12:00:00 EST
```

注意，**兑换**交易的属性也很少；票据00001所有更改都可以通过兑换交易逻辑来进行数据计算： `Issuer` 将成为票据新的所有者，`Current state` 将变成 `redeemed`。上述例子中指定了 `Current owner` 属性，因此可以根据当前的票据持有者来检查这一属性。

从信任的角度来说，**兑换**交易的逻辑也适用于**购买**交易：在购买交易中，买卖双方也都需要对交易进行离线签名。

## 账本

从以上讨论中我们可以看出，交易和由交易导致的票据状态是 PaperNet 中两个重要的概念。事实上，任何 Hyperledger Fabric 分布式[账本](../ledger/ledger.html)中都存在这两个基本成分——其一为包含了所有物件当前值的世界状态；其二则是记录了所有导致当前世界状态的交易历史的区块链。

根据规则对交易进行离线签名是硬性要求，在把交易添加到账本上之前会判断是否已进行签名。只有存在规定签名的交易才能被 Fabric 视为有效。

现在你可以将以上想法转化为智能合约，可能你的编程技能有些生疏，但别担心，我们会提供理解程序代码的相关提示。掌握商业票据智能合约是设计自己的应用程序的第一个重要步骤。如果你是一个有编程经验的业务分析师，不要害怕继续深入挖掘！

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
