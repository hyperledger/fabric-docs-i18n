<div dir="rtl">
  
# معرفی

به طور کلی ، بلاکچین یک دفتر معاملاتی تغییرناپذیر است که در یک شبکه توزیع شده از _گره های همتا_ حفظ می شود. این گره ها هر کدام با استفاده از معاملات معتبر با پروتکل اجماع ، یک کپی از دفترچه را نگهداری می کنند ، در بلوک هایی قرار می گیرند که شامل یک هش هستند که هر بلوک را به بلوک قبلی متصل می کند.

به طور کلی ، بلاکچین یک دفتر معاملاتی تغییرناپذیر است که در یک شبکه توزیع شده از گره های همتا حفظ می شود. این گره ها هر کدام با استفاده از 
اولین و شناخته شده ترین کاربرد بلاک ¬چین ارز رمزنگاری شده [Bitcoin](https://en.wikipedia.org/wiki/Bitcoin)  است. گرچه دیگران نیز ردپای آن را دنبال کرده اند. Ethereum ، یک ارز رمزنگاری شده جایگزین ، رویکرد متفاوتی را در پیش گرفت ، بسیاری از ویژگی های مشابه بیت کوین را ادغام کرد اما _قراردادهای هوشمند_ را برای ایجاد بستری برای برنامه های توزیع شده اضافه کرد. بیت کوین و اتریوم در یک کلاس بلاکچین قرار می گیرند که ما آنها را به عنوان فناوری بلاکچین _بدون مجوز وعمومی_ طبقه بندی می کنیم. اساساً ، اینها شبکه های عمومی هستند ، برای همه آزاد است ، جایی که شرکت کنندگان به صورت ناشناس در تعامل هستند.

با افزایش محبوبیت بیت کوین ، Ethereum و چند فناوری مشتق شده دیگر ، علاقه به استفاده از فناوری زیر بلاکچین ، دفترکل توزیع شده و برنامه توزیع شده برای موارد استفاده از _شرکت های نوآور_ نیز افزایش یافت. با این حال ، بسیاری از موارد استفاده تجاری، به ویژگیهای عملکردی نیاز دارند که فناوریهای بلاکچین بدون مجوز (فعلاً) قادر به ارائه آنها نیستند. علاوه بر این ، در بسیاری از موارد استفاده ، هویت شرکت کنندگان یک شرط مهم است ، مثلا در مورد معاملات مالی که مقررات شناسایی مشتریان (KYC) و مبارزه با پولشویی (AML) را باید دنبال کنید.



برای استفاده تجاری ، ما باید شرایط زیر را در نظر بگیریم:

-	شرکت کنندگان باید شناسایی شوند / قابل شناسایی باشند
-	شبکه ها باید _دارای مجوز_ باشند
-	عملکرد بالای تراکنش
-	تأخیر تأیید معامله کم باشد
-	حریم خصوصی و محرمانه بودن معاملات و داده های مربوط به معاملات تجاری حفظ شود


در حالی که بسیاری از سیستم عامل های زنجیره بلوک اولیه در حال حاضر برای استفاده سازمانی _سازگار_ شده اند ، Hyperledger Fabric از همان ابتدا برای استفاده در شرکت ها _طراحی_ شده است. بخشهای زیر نحوه تمایز Fabric از سایر پلتفرم های بلاکچین را توصیف می کند و برخی از انگیزه های تصمیمات برای معماری این شبکه را توصیف می کند.




## Hyperledger Fabric

Hyperledger Fabric یک پلتفرم منبع باز ارائه تکنولوژی دفترکل توزیع شده، در شاخه کاربردهای تجاری است که برای استفاده در زمینه های سازمانی طراحی شده است و برخی از قابلیت های اصلی آن، تمایز را نسبت به سایر سیستم های معروف دفترکل توزیع شده یا بلاکچین نشان می دهد.

یک نکته اصلی تمایز این است که هایپرلجر تحت نظر بنیاد لینوکس تاسیس شد ، که خود دارای سابقه طولانی و بسیار موفق پرورش پروژه های منبع باز تحت **حاکمیت باز** است که جوامع پایدار و اکوسیستم های پر رونق را رشد می دهد. Hyperledger توسط کمیته فنی حرفه ای و پروژه Hyperledger Fabric توسط مجموعه متنوعی از متخصصان در سازمانهای مختلف اداره می شود. این پروژه یک جامعه توسعه دهندگان دارد که از ابتدای شروع خود به بیش از 35 سازمان و نزدیک به 200 توسعه دهنده رسیده است.

فبریک دارای معماری کاملاً **ماژولار** و **قابل تنظیم** است که نوآوری ، کارایی و بهینه سازی را برای طیف گسترده ای از موارد استفاده صنعتی از جمله بانکی ، مالی ، بیمه ، خدمات درمانی ، منابع انسانی ، زنجیره تأمین و حتی تحویل موسیقی دیجیتال امکان پذیر می سازد.

Fabric به جای زبانهای محدود به دامنه خاص (DSL) ، اولین پلتفرم دفتر توزیع شده است که از **قراردادهای هوشمند کدنویسی شده با زبان های برنامه نویسی عمومی** مانند Java ، Go و Node.js پشتیبانی می کند. این بدان معنی است که اکثر شرکت ها از قبل مجموعه مهارت های لازم برای توسعه قراردادهای هوشمند را دارند و هیچ آموزش اضافی برای یادگیری زبان جدید یا DSL لازم نیست.

The Fabric platform is also **permissioned**, meaning that, unlike with a public
permissionless network, the participants are known to each other, rather than
anonymous and therefore fully untrusted. This means that while the participants
may not _fully_ trust one another (they may, for example, be competitors in the
same industry), a network can be operated under a governance model that is built
off of what trust _does_ exist between participants, such as a legal agreement
or framework for handling disputes.

One of the most important of the platform's differentiators is its support for
**pluggable consensus protocols** that enable the platform to be more
effectively customized to fit particular use cases and trust models. For
instance, when deployed within a single enterprise, or operated by a trusted
authority, fully byzantine fault tolerant consensus might be considered
unnecessary and an excessive drag on performance and throughput. In situations
such as that, a
[crash fault-tolerant](https://en.wikipedia.org/wiki/Fault_tolerance) (CFT)
consensus protocol might be more than adequate whereas, in a multi-party,
decentralized use case, a more traditional
[byzantine fault tolerant](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance)
(BFT) consensus protocol might be required.

Fabric can leverage consensus protocols that **do not require a native
cryptocurrency** to incent costly mining or to fuel smart contract execution.
Avoidance of a cryptocurrency reduces some significant risk/attack vectors,
and absence of cryptographic mining operations means that the platform can be
deployed with roughly the same operational cost as any other distributed system.

The combination of these differentiating design features makes Fabric one of
the **better performing platforms** available today both in terms of transaction
processing and transaction confirmation latency, and it enables **privacy and confidentiality** of transactions and the smart contracts (what Fabric calls
"chaincode") that implement them.

Let's explore these differentiating features in more detail.

</div> 

## Modularity

Hyperledger Fabric has been specifically architected to have a modular
architecture. Whether it is pluggable consensus, pluggable identity management
protocols such as LDAP or OpenID Connect, key management protocols or
cryptographic libraries, the platform has been designed at its core to be
configured to meet the diversity of enterprise use case requirements.

At a high level, Fabric is comprised of the following modular components:

- A pluggable _ordering service_ establishes consensus on the order of
transactions and then broadcasts blocks to peers.
- A pluggable _membership service provider_ is responsible for associating
entities in the network with cryptographic identities.
- An optional _peer-to-peer gossip service_ disseminates the blocks output by
ordering service to other peers.
- Smart contracts ("chaincode") run within a container environment (e.g. Docker)
for isolation. They can be written in standard programming languages but do not
have direct access to the ledger state.
- The ledger can be configured to support a variety of DBMSs.
- A pluggable endorsement and validation policy enforcement that can be
independently configured per application.

There is fair agreement in the industry that there is no "one blockchain to
rule them all". Hyperledger Fabric can be configured in multiple ways to
satisfy the diverse solution requirements for multiple industry use cases.

## Permissioned vs Permissionless Blockchains

In a permissionless blockchain, virtually anyone can participate, and every
participant is anonymous. In such a context, there can be no trust other than
that the state of the blockchain, prior to a certain depth, is immutable. In
order to mitigate this absence of trust, permissionless blockchains typically
employ a "mined" native cryptocurrency or transaction fees to provide economic
incentive to offset the extraordinary costs of participating in a form of
byzantine fault tolerant consensus based on "proof of work" (PoW).

**Permissioned** blockchains, on the other hand, operate a blockchain amongst
a set of known, identified and often vetted participants operating under a
governance model that yields a certain degree of trust. A permissioned
blockchain provides a way to secure the interactions among a group of entities
that have a common goal but which may not fully trust each other. By relying on
the identities of the participants, a permissioned blockchain can use more
traditional crash fault tolerant (CFT) or byzantine fault tolerant (BFT)
consensus protocols that do not require costly mining.

Additionally, in such a permissioned context, the risk of a participant
intentionally introducing malicious code through a smart contract is diminished.
First, the participants are known to one another and all actions, whether
submitting application transactions, modifying the configuration of the network
or deploying a smart contract are recorded on the blockchain following an
endorsement policy that was established for the network and relevant transaction
type. Rather than being completely anonymous, the guilty party can be easily
identified and the incident handled in accordance with the terms of the
governance model.

## Smart Contracts

A smart contract, or what Fabric calls "chaincode", functions as a trusted
distributed application that gains its security/trust from the blockchain and
the underlying consensus among the peers. It is the business logic of a
blockchain application.

There are three key points that apply to smart contracts, especially when
applied to a platform:

- many smart contracts run concurrently in the network,
- they may be deployed dynamically (in many cases by anyone), and
- application code should be treated as untrusted, potentially even
malicious.

Most existing smart-contract capable blockchain platforms follow an
**order-execute** architecture in which the consensus protocol:

- validates and orders transactions then propagates them to all peer nodes,
- each peer then executes the transactions sequentially.

The order-execute architecture can be found in virtually all existing blockchain
systems, ranging from public/permissionless platforms such as
[Ethereum](https://ethereum.org/) (with PoW-based consensus) to permissioned
platforms such as [Tendermint](http://tendermint.com/),
[Chain](http://chain.com/), and [Quorum](http://www.jpmorgan.com/global/Quorum).

Smart contracts executing in a blockchain that operates with the order-execute
architecture must be deterministic; otherwise, consensus might never be reached.
To address the non-determinism issue, many platforms require that the smart
contracts be written in a non-standard, or domain-specific language
(such as [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) so that
non-deterministic operations can be eliminated. This hinders wide-spread
adoption because it requires developers writing smart contracts to learn a new
language and may lead to programming errors.

Further, since all transactions are executed sequentially by all nodes,
performance and scale is limited. The fact that the smart contract code executes
on every node in the system demands that complex measures be taken to protect
the overall system from potentially malicious contracts in order to ensure
resiliency of the overall system.

## A New Approach

Fabric introduces a new architecture for transactions that we call
**execute-order-validate**. It addresses the resiliency, flexibility,
scalability, performance and confidentiality challenges faced by the
order-execute model by separating the transaction flow into three steps:

- _execute_ a transaction and check its correctness, thereby endorsing it,
- _order_ transactions via a (pluggable) consensus protocol, and
- _validate_ transactions against an application-specific endorsement policy
before committing them to the ledger

This design departs radically from the order-execute paradigm in that Fabric
executes transactions before reaching final agreement on their order.

In Fabric, an application-specific endorsement policy specifies which peer
nodes, or how many of them, need to vouch for the correct execution of a given
smart contract. Thus, each transaction need only be executed (endorsed) by the
subset of the peer nodes necessary to satisfy the transaction's endorsement
policy. This allows for parallel execution increasing overall performance and
scale of the system. This first phase also **eliminates any non-determinism**,
as inconsistent results can be filtered out before ordering.

Because we have eliminated non-determinism, Fabric is the first blockchain
technology that **enables use of standard programming languages**.

## Privacy and Confidentiality

As we have discussed, in a public, permissionless blockchain network that
leverages PoW for its consensus model, transactions are executed on every node.
This means that neither can there be confidentiality of the contracts
themselves, nor of the transaction data that they process. Every transaction,
and the code that implements it, is visible to every node in the network. In
this case, we have traded confidentiality of contract and data for byzantine
fault tolerant consensus delivered by PoW.

This lack of confidentiality can be problematic for many business/enterprise use
cases. For example, in a network of supply-chain partners, some consumers might
be given preferred rates as a means of either solidifying a relationship, or
promoting additional sales. If every participant can see every contract and
transaction, it becomes impossible to maintain such business relationships in a
completely transparent network --- everyone will want the preferred rates!

As a second example, consider the securities industry, where a trader building
a position (or disposing of one) would not want her competitors to know of this,
or else they will seek to get in on the game, weakening the trader's gambit.

In order to address the lack of privacy and confidentiality for purposes of
delivering on enterprise use case requirements, blockchain platforms have
adopted a variety of approaches. All have their trade-offs.

Encrypting data is one approach to providing confidentiality; however, in a
permissionless network leveraging PoW for its consensus, the encrypted data is
sitting on every node. Given enough time and computational resource, the
encryption could be broken. For many enterprise use cases, the risk that their
information could become compromised is unacceptable.

Zero knowledge proofs (ZKP) are another area of research being explored to
address this problem, the trade-off here being that, presently, computing a ZKP
requires considerable time and computational resources. Hence, the trade-off in
this case is performance for confidentiality.

In a permissioned context that can leverage alternate forms of consensus, one
might explore approaches that restrict the distribution of confidential
information exclusively to authorized nodes.

Hyperledger Fabric, being a permissioned platform, enables confidentiality
through its channel architecture and [private data](./private-data/private-data.html)
feature. In channels, participants on a Fabric network establish a sub-network
where every member has visibility to a particular set of transactions. Thus, only
those nodes that participate in a channel have access to the smart contract
(chaincode) and data transacted, preserving the privacy and confidentiality of
both. Private data allows collections between members on a channel, allowing
much of the same protection as channels without the maintenance overhead of
creating and maintaining a separate channel.

## Pluggable Consensus

The ordering of transactions is delegated to a modular component for consensus
that is logically decoupled from the peers that execute transactions and
maintain the ledger. Specifically, the ordering service. Since consensus is
modular, its implementation can be tailored to the trust assumption of a
particular deployment or solution. This modular architecture allows the platform
to rely on well-established toolkits for CFT (crash fault-tolerant) or BFT
(byzantine fault-tolerant) ordering.

Fabric currently offers a CFT ordering service implementation
based on the [`etcd` library](https://coreos.com/etcd/) of the [Raft protocol](https://raft.github.io/raft.pdf).
For information about currently available ordering services, check
out our [conceptual documentation about ordering](./orderer/ordering_service.html).

Note also that these are not mutually exclusive. A Fabric network can have
multiple ordering services supporting different applications or application
requirements.

## Performance and Scalability

Performance of a blockchain platform can be affected by many variables such as
transaction size, block size, network size, as well as limits of the hardware,
etc. The Hyperledger Fabric [Performance and Scale working group](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group)
currently works on a benchmarking framework called [Hyperledger Caliper](https://wiki.hyperledger.org/display/caliper).

Several research papers have been published studying and testing the performance
capabilities of Hyperledger Fabric. The latest [scaled Fabric to 20,000 transactions per second](https://arxiv.org/abs/1901.00910).

## Conclusion

Any serious evaluation of blockchain platforms should include Hyperledger Fabric
in its short list.

Combined, the differentiating capabilities of Fabric make it a highly scalable
system for permissioned blockchains supporting flexible trust assumptions that
enable the platform to support a wide range of industry use cases ranging from
government, to finance, to supply-chain logistics, to healthcare and so much
more.

Hyperledger Fabric is the most active of the Hyperledger projects. The community
building around the platform is growing steadily, and the innovation delivered
with each successive release far out-paces any of the other enterprise blockchain
platforms.

## Acknowledgement

The preceding is derived from the peer reviewed
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
