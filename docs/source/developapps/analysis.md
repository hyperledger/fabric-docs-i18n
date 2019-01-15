# Analysis

**Audience**: Architects, Application and smart contract developers, Business
professionals

**受众**: 架构师，应用和合约开发者，业务专家

Let's analyze commercial paper in a little more detail. PaperNet participants
such as MagnetoCorp and DigiBank use commercial paper transactions to achieve
their business objectives -- let's examine the structure of a commercial paper
and the transactions that affect it over time. Later we'll focus on how money
flows between buyers and sellers; for now, let's focus on the first paper issued
by MagnetoCorp.

让我们更详细的分析商业票据。MagnetoCorp 和 DigiBank 等 PaperNet 参与者使用商业票据交易来
实现其业务目标 -- 让我们检查商业票据的结构以及影响它的交易。稍后我们将关注买家和卖家之间的资
金流动情况; 现在，让我们关注 MagnetoCorp 发布的第一个票据。

## Commercial paper lifecycle

A paper 00001 is issued by MagnetoCorp on May 31. Spend a few moments looking at
the first **state** of this paper, with its different properties and values:

票据 00001 是 5 月 31 号由 MagnetoCorp 发行的。花点时间来看看该票据的第一个 **状态**，它
具有不同的属性和值：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = MagnetoCorp
Issue date = 31 May 2020
Maturity = 30 November 2020
Face value = 5M USD
Current state = issued
```

This paper state is a result of the **issue** transaction and it brings
MagnetoCorp's first commercial paper into existence! Notice how this paper has a
5M USD face value for redemption later in the year. See how the `Issuer` and
`Owner` are the same when paper 00001 is issued. Notice that this paper could be
uniquely identified as `MagnetoCorp00001` -- a composition of the `Issuer` and
`Paper` properties. Finally, see how the property `Current state = issued`
quickly identifies the stage of MagnetoCorp paper 00001 in its lifecycle.

该票据的状态是 **issue** 交易的结果，它带来了 MagnetoCorp 公司的第一张商业票据面世！注意
该票据在今年晚些时候如何兑换面值 500 万美元。当票据 00001 发行后 `Issuer` 和 `Owner` 具有
相同的值。该票据有唯一标识 `MagnetoCorp00001` -- 它是 `Issuer` 属性和 `Paper` 属性的组合。
最后，属性 `Current state = issued` 快速识别了 MagnetoCorp 票据 00001 在它生命周期中的阶段。

Shortly after issuance, the paper is bought by DigiBank. Spend a few moments
looking at how the same commercial paper has changed as a result of this **buy**
transaction:

发行后不久，该票据被 DigiBank 购买。花点时间来看看由于 **buy** 交易，同一个商业票据如何发生了变化：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = DigiBank
Issue date = 31 May 2020
Maturity date = 30 November 2020
Face value = 5M USD
Current state = trading
```

The most significant change is that of `Owner` -- see how the paper initially
owned by `MagnetoCorp` is now owned by `DigiBank`.  We could imagine how the
paper might be subsequently sold to BrokerHouse or HedgeMatic, and the
corresponding change to `Owner`. Note how `Current state` allow us to easily
identify that the paper is now `trading`.

最重要的变化是 `Owner` 的改变 -- 票据初始拥有者 `MagnetoCorp` 而现在是 `DigiBank`。
我们可以想象该票据后来如何被出售给 BrokerHouse 或 HedgeMatic，以及相应的变更为相应的 `Owner`。
注意 `Current state` 允许我们轻松的识别该票据目前状态是 `trading`。

After 6 months, if DigiBank still holds the the commercial paper, it can redeem
it with MagnetoCorp:

6 个月后，如果 DigiBank 仍然持有商业票据，它就可以从 MagnetoCorp 那里兑换：

```
Issuer = MagnetoCorp
Paper = 00001
Owner = MagnetoCorp
Issue date = 31 May 2020
Maturity date = 30 November 2020
Face value = 5M USD
Current state = redeemed
```

This final **redeem** transaction has ended the commercial paper's lifecycle --
it can be considered closed. It is often mandatory to keep a record of redeemed
commercial papers, and the `redeemed` state allows us to quickly identify these.

最终的 **redeem** 交易结束了这个商业票据的生命周期 -- 它可以被认为是关闭的。通常必须保留
已兑换的商业票据的记录，并且 `redeemed` 状态允许我们快速识别这些。

## Transactions

We've seen that paper 00001's lifecycle is relatively straightforward -- it
moves between `issued`, `trading` and `redeemed` as a result of an **issue**,
**buy**, or **redeem** transaction.

我们已经看到票据 00001 的生命周期相对简单 -- 由于 **issue**, **buy**, 和 **redeem** 交易，
它在 `issued`, `trading` 和 `redeemed` 状态之间转移。

These three transactions are initiated by MagnetoCorp and DigiBank (twice), and
drive the state changes of paper 00001. Let's have a look at the transactions
that affect this paper in a little more detail:

这三笔交易由 MagnetoCorp 和 DigiBank（两次）发起，并推动了 00001 票据的状态变化。
让我们更详细地看一下影响票据的交易：

### Issue

Examine the first transaction initiated by MagnetoCorp:

检查 MagnetoCorp 发起的第一笔交易：

```
Txn = issue
Issuer = MagnetoCorp
Paper = 00001
Issue time = 31 May 2020 09:00:00 EST
Maturity date = 30 November 2020
Face value = 5M USD
```

See how the **issue** transaction has a structure with properties and values.
This transaction structure is different to, but closely matches, the structure
of paper 00001. That's because they are different things -- paper 00001 reflects
a state of PaperNet that is a result of the **issue** transaction. It's the
logic behind the **issue** transaction (which we cannot see) that takes these
properties and creates this paper. Because the transaction **creates** the
paper, it means there's a very close relationship between these structures.



### Buy

Next, examine the **buy** transaction which transfers ownership of paper 00001
from MagnetoCorp to DigiBank:

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = MagnetoCorp
New owner = DigiBank
Purchase time = 31 May 2020 10:00:00 EST
Price = 4.94M USD
```

See how the **buy** transaction has fewer properties that end up in this paper.
That's because this transaction only **modifies** this paper. It's only `New
owner = DigiBank` that changes as a result of this transaction; everything else
is the same. That's OK -- the most important thing about the **buy** transaction
is the change of ownership, and indeed in this transaction, there's an
acknowledgement of the current owner of the paper, MagnetoCorp.

You might ask why the `Purchase time` and `Price` properties are not captured in
paper 00001? This comes back to the difference between the transaction and the
paper. The 4.94 M USD price tag is actually a property of the transaction,
rather than a property of this paper. Spend a little time thinking about
this difference; it is not as obvious as it seems. We're going to see later
that the ledger will record both pieces of information -- the history of all
transactions that affect this paper, as well its latest state. Being clear on
this separation of information is really important.

It's also worth remembering that paper 00001 may be bought and sold many times.
Although we're skipping ahead a little in our scenario, let's examine what
transactions we **might** see if paper 00001 changes ownership.

If we have a purchase by BigFund:

```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = DigiBank
New owner = BigFund
Purchase time = 2 June 2020 12:20:00 EST
Price = 4.93M USD
```
Followed by a subsequent purchase by HedgeMatic:
```
Txn = buy
Issuer = MagnetoCorp
Paper = 00001
Current owner = BigFund
New owner = HedgeMatic
Purchase time = 3 June 2020 15:59:00 EST
Price = 4.90M USD
```

See how the paper owners changes, and how in out example, the price changes. Can
you think of a reason why the price of MagnetoCorp commercial paper might be
falling?

### Redeem

The **redeem** transaction for paper 00001 represents the end of its lifecycle.
In our relatively simple example, DigiBank initiates the transaction which
transfers the commercial paper back to MagnetoCorp:

```
Txn = redeem
Issuer = MagnetoCorp
Paper = 00001
Current owner = HedgeMatic
Redeem time = 30 Nov 2020 12:00:00 EST
```

Again, notice how the **redeem** transaction has very few properties; all of the
changes to paper 00001 can be calculated data by the redeem transaction logic:
the `Issuer` will become the new owner, and the `Current state` will change to
`redeemed`. The `Current owner` property is specified in our example, so that it
can be checked against the current holder of the paper.

## The Ledger

In this topic, we've seen how transactions and the resultant paper states are
the two most important concepts in PaperNet. Indeed, we'll see these two
fundamental elements in any Hyperledger Fabric distributed
[ledger](../ledger/ledger.html) -- a world state, that contains the current
value of all objects, and a blockchain that records the history of all
transactions that resulted in the current world state.

You're now in a great place translate these ideas into a smart contract. Don't
worry if your programming is a little rusty, we'll provide tips and pointers to
understand the program code. Mastering the commercial paper smart contract is
the first big step towards designing your own application. Or, if you're a
business analyst who's comfortable with a little programming, don't be afraid to
keep dig a little deeper!

<!--- Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/ -->
