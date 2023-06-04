# Introduction

Secara umum, blockchain adalah buku besar transaksi (ledger) yang tidak dapat diubah, 
dikelola dalam jaringan terdistribusi _peer node_. Node ini masing-masing mengelola 
salinan buku besar dengan menerapkan transaksi yang telah divalidasi oleh _protocol consensus_, 
dikelompokkan ke dalam blok yang menyertakan hash yang mengikat setiap blok ke blok sebelumnya.

The first and most widely recognized application of blockchain is the
[Bitcoin](https://en.wikipedia.org/wiki/Bitcoin) cryptocurrency, though others
have followed in its footsteps. Ethereum, an alternative cryptocurrency, took a
different approach, integrating many of the same characteristics as Bitcoin but
adding _smart contracts_ to create a platform for distributed applications.
Bitcoin and Ethereum fall into a class of blockchain that we would classify as
_public permissionless_ blockchain technology. Basically, these are public
networks, open to anyone, where participants interact anonymously.

As the popularity of Bitcoin, Ethereum and a few other derivative technologies
grew, interest in applying the underlying technology of the blockchain,
distributed ledger and distributed application platform to more innovative
_enterprise_ use cases also grew. However, many enterprise use cases require
performance characteristics that the permissionless blockchain technologies are
unable (presently) to deliver. In addition, in many use cases, the identity of
the participants is a hard requirement, such as in the case of financial
transactions where Know-Your-Customer (KYC) and Anti-Money Laundering (AML)
regulations must be followed.

For enterprise use, we need to consider the following requirements:

- Participants must be identified/identifiable
- Networks need to be _permissioned_
- High transaction throughput performance
- Low latency of transaction confirmation
- Privacy and confidentiality of transactions and data pertaining to business
  transactions

While many early blockchain platforms are currently being _adapted_ for
enterprise use, Hyperledger Fabric has been _designed_ for enterprise use from
the outset. The following sections describe how Hyperledger Fabric (Fabric)
differentiates itself from other blockchain platforms and describes some of the
motivation for its architectural decisions.

## Hyperledger Fabric

Hyperledger Fabric is an open source enterprise-grade permissioned distributed
ledger technology (DLT) platform, designed for use in enterprise contexts,
that delivers some key differentiating capabilities over other popular
distributed ledger or blockchain platforms.

Salah satu perbedaan utama adalah bahwa Hyperledger didirikan di bawah Linux Foundation, 
yang memiliki sejarah panjang dan sangat sukses dalam memelihara proyek open source 
di bawah **open governance** yang menumbuhkan komunitas berkelanjutan yang kuat 
dan ekosistem yang berkembang. Hyperledger dikelola oleh komite pengarah teknis 
yang beragam, dan proyek Hyperledger Fabric oleh beragam pengelola dari berbagai organisasi. 
Proyek ini memiliki komunitas pengembangan yang telah berkembang menjadi lebih dari 
35 organisasi dan hampir 200 pengembang sejak komit paling awal.

Fabric memiliki arsitektur yang sangat **modular** dan **configurable**, memungkinkan inovasi, 
keserbagunaan, dan pengoptimalan untuk berbagai _use case_ industri termasuk perbankan, 
keuangan, asuransi, layanan kesehatan, sumber daya manusia, rantai pasokan, dan bahkan 
penerbitan musik digital .

Fabric adalah platform ledger terdistribusi pertama yang mendukung 
**smart contract yang dibuat dalam bahasa pemrograman tujuan umum** seperti 
Java, Go, dan Node.js, bukan _domain-specific languages_ (DSL). 
Ini berarti bahwa sebagian besar perusahaan sudah memiliki keahlian yang diperlukan 
untuk mengembangkan kontrak pintar, dan tidak diperlukan pelatihan tambahan untuk 
mempelajari bahasa baru atau DSL.

Platform Fabric juga **permissioned**, artinya, tidak seperti jaringan tanpa izin publik, 
para peserta saling mengenal, bukan anonim dan karena itu sepenuhnya tidak dipercaya. 
Ini berarti bahwa partisipan mungkin saja tidak _sepenuhnya_ mempercayai satu sama lain 
(dalam hal ini mungkin, misalnya, menjadi pesaing satu sama lain dalam industri yang sama), 
jaringan dapat dioperasikan di bawah model tata kelola yang dibangun dari kepercayaan yang _ada_ 
di antara peserta, seperti kesepakatan hukum atau kerangka kerja untuk menangani sengketa.

Salah satu pembeda platform yang paling penting adalah dukungannya untuk 
**pluggable consensus protocols** yang memungkinkan platform disesuaikan 
secara lebih efektif agar sesuai dengan _use case_ tertentu dan model kepercayaan. 
Misalnya, ketika digunakan dalam satu perusahaan, atau dioperasikan oleh otoritas tepercaya, 
konsensus yang sepenuhnya toleran terhadap kesalahan Bizantium mungkin dianggap 
tidak perlu dan terlalu membebani kinerja dan throughput. Dalam situasi seperti itu, 
protokol konsensus [crash-fault-tolerant] (https://en.wikipedia.org/wiki/Fault_tolerance) (CFT) 
mungkin lebih dari cukup sedangkan, dalam kasus penggunaan multi-pihak yang terdesentralisasi, 
protokol konsensus [byzantine-fault-tolerance](https://en.wikipedia.org/wiki/Byzantine_fault_tolerance) 
(BFT) yang lebih tradisional mungkin diperlukan.

Fabric dapat memanfaatkan protokol konsensus yang **tidak memerlukan mata uang kripto asli** 
untuk mendorong penambangan yang mahal atau mendorong pelaksanaan kontrak cerdas. 
Menghindari cryptocurrency mengurangi beberapa vektor risiko/serangan yang signifikan, 
dan tidak adanya operasi penambangan kriptografi berarti bahwa platform dapat digunakan dengan 
biaya operasional yang kira-kira sama dengan sistem terdistribusi lainnya.

Kombinasi dari fitur desain yang berbeda ini menjadikan Fabric salah satu **platform berperforma lebih baik** 
yang tersedia saat ini baik dalam hal pemrosesan transaksi dan latensi konfirmasi transaksi, 
dan memungkinkan **privasi dan kerahasiaan** dari transaksi dan kontrak pintar 
(disebut juga "chaincode") yang mengimplementasikannya.

Mari jelajahi fitur pembeda ini secara lebih mendetail.

## Modularitas

Hyperledger Fabric secara khusus dirancang untuk memiliki arsitektur modular. 
Baik itu _pluggable consensus_, _pluggable identity management protocols_ 
seperti LDAP atau OpenID Connect, _key management protocols_, atau _cryptographic libraries_, 
platform ini telah dirancang pada intinya agar dapat dikonfigurasi untuk memenuhi keragaman 
persyaratan _use case_ pada perusahaan.

Pada tingkat tinggi, Fabric terdiri dari komponen modular berikut:

- Sebuah _ordering service_ pluggable menetapkan konsensus tentang urutan
transaksi dan kemudian menyiarkan blok ke peer.
- Sebuah _membership service provider_ pluggable bertanggung jawab untuk mengasosiasikan
entitas dalam jaringan dengan identitas kriptografi.
- Sebuah _peer-to-peer gossip service_ opsional menyebarkan output blok-blok oleh
ordering service menuju peer-peer lainnya.
- Kontrak pintar ("chaincode") dijalankan dalam lingkungan container (mis. Docker)
untuk isolasi. Mereka dapat ditulis dalam bahasa pemrograman standar tetapi tidak
memiliki akses langsung ke status ledger.
- Ledger dapat dikonfigurasi untuk mendukung berbagai DBMS.
- Sebuah _endorsement and validation policy_ pluggable yang dapat dikonfigurasi secara 
independen per aplikasi.

Ada sebuah _fair agreement_ dalam industri ini bahwa tidak ada 
"satu blockchain yang mengatur semuanya". Hyperledger Fabric dapat dikonfigurasi 
dalam berbagai cara untuk memenuhi persyaratan solusi yang beragam untuk berbagai 
_use case_ industri.

## Blockchain Permissionless vs Permissioned

Terkait blockchain permissionless, hampir semua orang dapat berpartisipasi, dan setiap 
peserta bersifat anonim. Dalam konteks seperti itu, tidak ada kepercayaan selain
bahwa _state_ blockchain, sebelum kedalaman tertentu, tidak dapat diubah. Untuk mengurangi 
ketiadaan kepercayaan ini, blockchain permissionless biasanya menggunakan cryptocurrency asli 
yang "ditambang" atau biaya transaksi untuk memberikan insentif ekonomi untuk mengimbangi 
biaya luar biasa untuk berpartisipasi dalam bentuk konsensus byzantine fault tolerant berdasarkan 
"proof of work" (PoW).

Blockchain **permissioned**, di sisi lain, mengoperasikan blockchain di antara 
sekumpulan peserta yang dikenal, teridentifikasi, dan sering diperiksa yang 
beroperasi di bawah model tata kelola yang menghasilkan tingkat kepercayaan tertentu. 
Blockchain permissioned menyediakan cara untuk mengamankan interaksi di antara 
sekelompok entitas yang memiliki tujuan bersama tetapi mungkin tidak sepenuhnya 
saling percaya. Dengan mengandalkan identitas peserta, sebuah blockchain permissioned 
dapat menggunakan protokol konsensus crash fault tolerant (CFT) atau 
byzantine fault tolerant (BFT) yang lebih tradisional dimana tidak memerlukan 
aktivitas penambangan yang mahal.

Selain itu, dalam konteks _permissioned_ seperti itu, risiko peserta
terekspos secara sengaja terhadap kode berbahaya melalui smart contract berkurang.
Pertama, para peserta saling mengenal satu sama lain dan semua tindakan, baik 
mengirimkan transaksi aplikasi, mengubah konfigurasi jaringan, atau menggunakan 
smart contract dicatat di blockchain mengikuti kebijakan pengesahan yang dibuat 
untuk jaringan dan jenis transaksi yang relevan. Alih-alih sepenuhnya anonim, pihak 
yang bersalah dapat dengan mudah diidentifikasi dan insiden tersebut ditangani 
sesuai dengan ketentuan model tata kelola.

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
