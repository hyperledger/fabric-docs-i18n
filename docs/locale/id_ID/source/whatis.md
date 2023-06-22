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

## Kontrak Pintar

Kontrak pintar, atau yang di Fabric disebut juga "chaincode", berfungsi
sebagai aplikasi terdistribusi tepercaya yang memperoleh keamanan/kepercayaan
dari blockchain dan konsensus yang mendasari di antara rekan-rekan.
Ini adalah logika bisnis dari aplikasi blockchain.

Ada tiga poin utama yang berlaku untuk kontrak pintar, terutama saat
diterapkan pada platform:

- banyak kontrak pintar berjalan secara bersamaan di jaringan,
- mereka dapat digunakan secara dinamis (dalam banyak kasus oleh siapa saja), dan
- kode aplikasi harus diperlakukan sebagai tidak tepercaya,
bahkan berpotensi berbahaya.

Sebagian besar platform blockchain berkemampuan kontrak pintar yang ada mengikuti
arsitektur **order-execute** di mana protokol konsensus:

- memvalidasi dan memesan transaksi kemudian menyebarkannya ke semua node peer,
- setiap peer kemudian mengeksekusi transaksi secara berurutan.

Arsitektur order-execute dapat ditemukan di hampir semua sistem blockchain yang ada,
mulai dari platform publik/permissionless seperti
[Ethereum](https://ethereum.org/) (dengan konsensus berbasis PoW) ke platform
blockchain permissioned seperti [Tendermint](http://tendermint.com/),
[Chain](http://chain.com/), dan [Quorum](http://www.jpmorgan.com/global/Quorum).

Kontrak pintar yang dieksekusi dalam blockchain yang beroperasi dengan arsitektur
order-execute harus bersifat deterministik; jika tidak, konsensus mungkin tidak
akan pernah tercapai.Untuk mengatasi masalah non-determinisme, banyak platform
mengharuskan kontrak pintar ditulis dalam bahasa non-standar, atau domain-specific language
(seperti [Solidity](https://solidity.readthedocs.io/en/v0.4.23/)) sehingga
operasi non-deterministik dapat dihilangkan. Ini menghambat adopsi yang meluas
karena mengharuskan pengembang menulis kontrak pintar untuk mempelajari bahasa baru
dan dapat menyebabkan kesalahan pemrograman.

Selanjutnya, karena semua transaksi dijalankan secara berurutan oleh semua node,
kinerja dan skala menjadi terbatas. Fakta bahwa kode kontrak pintar dijalankan pada
setiap node dalam sistem menuntut pengambilan tindakan kompleks untuk melindungi
keseluruhan sistem dari kontrak yang berpotensi berbahaya untuk memastikan
ketahanan sistem secara keseluruhan.

## Pendekatan Baru

Fabric memperkenalkan arsitektur baru untuk transaksi yang kami sebut
**execute-order-validate**. Ini mengatasi tantangan ketahanan, fleksibilitas,
skalabilitas, kinerja dan kerahasiaan yang dihadapi oleh model order-execute
dengan memisahkan aliran transaksi menjadi tiga langkah:

- mengeksekusi (_execute_) transaksi dan memeriksa kebenarannya, dengan demikian mengesahkannya,
- memesan (_order_) transaksi melalui protokol konsensus (pluggable), dan
- memvalidasi (_validate_) transaksi terhadap kebijakan pengesahan khusus aplikasi
sebelum melakukan mereka ke buku besar

Desain ini berangkat secara radikal dari paradigma order-execute di mana
Fabric mengeksekusi transaksi sebelum mencapai kesepakatan akhir atas pesanan mereka.

Di Fabric, kebijakan pengesahan khusus aplikasi menentukan peer node mana,
atau berapa banyak dari mereka, yang perlu menjamin eksekusi yang benar dari
smart contract yang diberikan. Dengan demikian, setiap transaksi hanya perlu
dijalankan (didukung) oleh subset dari peer node yang diperlukan untuk memenuhi
kebijakan pengesahan transaksi. Ini memungkinkan eksekusi paralel meningkatkan
kinerja keseluruhan dan skala sistem. Fase pertama ini juga **menghilangkan non-determinisme**,
karena hasil yang tidak konsisten dapat disaring sebelum memesan.

Karena kami telah menghilangkan non-determinisme, Fabric adalah teknologi
blockchain pertama yang **memungkinkan penggunaan bahasa pemrograman standar**.

## Privasi dan Kerahasiaan

Seperti yang telah kita diskusikan, di jaringan blockchain publik _permissionless_ 
yang memanfaatkan PoW untuk model konsensusnya, transaksi dijalankan di setiap node.
Ini berarti bahwa tidak ada kerahasiaan kontrak itu sendiri, maupun data transaksi 
yang mereka proses. Setiap transaksi, dan kode yang mengimplementasikannya, 
dapat dilihat oleh setiap node dalam jaringan. Dalam hal ini, kami telah menawarkan 
kerahasiaan kontrak dan data untuk konsensus _byzantine fault tolerant_ yang 
dibawakan oleh PoW.

Kurangnya kerahasiaan ini dapat menjadi masalah bagi banyak _use case_ bisnis/perusahaan. 
Misalnya, dalam jaringan mitra rantai pasokan, beberapa konsumen mungkin diberikan tarif 
pilihan sebagai sarana untuk memperkuat hubungan, atau mempromosikan penjualan tambahan. 
Jika setiap peserta dapat melihat setiap kontrak dan transaksi, menjadi tidak mungkin untuk 
mempertahankan hubungan bisnis seperti itu dalam jaringan yang benar-benar transparan 
--- semua orang pasti menginginkan harga yang terbaik!

Sebagai contoh kedua, pertimbangkan sebuah industri sekuritas, di mana seorang pedagang 
membangun posisi (atau membuangnya) tidak ingin pesaingnya mengetahui hal ini, 
atau mereka akan berusaha untuk ikut serta, melemahkan langkah pedagang.

Untuk mengatasi kurangnya privasi dan kerahasiaan untuk memenuhi persyaratan _use case_ perusahaan, 
platform blockchain telah mengadopsi berbagai pendekatan. Semua memiliki _trade-off_ mereka.

Mengenkripsi data adalah salah satu pendekatan untuk menyediakan kerahasiaan; 
namun, dalam jaringan _permissionless_ yang memanfaatkan PoW untuk konsensusnya, 
data terenkripsi berada di setiap node. Mengingat cukup waktu dan sumber daya komputasi, 
enkripsi dapat rusak. Untuk banyak _use case_ perusahaan, risiko bahwa informasi 
mereka dapat disusupi tidak dapat diterima.

Zero knowledge proofs (ZKP) adalah bidang penelitian lain yang sedang dieksplorasi untuk 
mengatasi masalah ini, _trade-off_ di sini adalah bahwa, saat ini, menghitung ZKP 
membutuhkan banyak waktu dan sumber daya komputasi. Oleh karena itu, _trade-off_ 
dalam hal ini adalah kinerja untuk kerahasiaan.

Dalam konteks _permissioned_ yang dapat memanfaatkan bentuk konsensus alternatif, 
seseorang dapat mengeksplorasi pendekatan yang membatasi distribusi informasi rahasia 
secara eksklusif ke node yang berwenang.

Hyperledger Fabric, sebagai platform _permissioned_, memungkinkan kerahasiaan 
melalui arsitektur salurannya dan fitur [data pribadi](./private-data/private-data.html). 
Di dalam sebuah _channel_, peserta di jaringan Fabric membuat sub-jaringan di mana setiap anggota 
memiliki visibilitas ke serangkaian transaksi tertentu. Dengan demikian, hanya node 
yang berpartisipasi dalam _channel_ yang memiliki akses ke smart contract (chaincode) dan 
data yang ditransaksikan, menjaga privasi dan kerahasiaan keduanya. Data pribadi memungkinkan 
pengumpulan antara anggota di _channel_, memungkinkan perlindungan yang sama seperti saluran 
tanpa biaya pemeliharaan untuk membuat dan memelihara saluran terpisah.

## Konsensus _Pluggable_

Urutan transaksi didelegasikan ke komponen modular untuk konsensus yang secara 
logis dipisahkan dari peer yang mengeksekusi transaksi dan memelihara ledger. 
Secara khusus, _ordering service_. Karena konsensus bersifat modular, penerapannya 
dapat disesuaikan dengan asumsi kepercayaan penerapan atau solusi tertentu. 
Arsitektur modular ini memungkinkan platform untuk mengandalkan toolkit yang 
sudah mapan untuk pemesanan CFT (crash fault-tolerant) atau BFT (byzantine fault-tolerant).

Fabric saat ini menawarkan implementasi _ordering service_ CFT berdasarkan 
[`etcd` library](https://coreos.com/etcd/) dari [protokol Raft](https://raft.github.io/raft.pdf). 
Untuk informasi tentang _ordering service_ yang tersedia saat ini, 
lihat [dokumentasi konseptual tentang _ordering service_](./orderer/ordering_service.html) kami.

Perhatikan juga bahwa ini tidak saling eksklusif. Jaringan Fabric dapat memiliki beberapa 
_ordering service_ yang mendukung berbagai aplikasi atau persyaratan aplikasi.

## Performa dan Skalabilitas

Kinerja platform blockchain dapat dipengaruhi oleh banyak variabel seperti ukuran transaksi, 
ukuran blok, ukuran jaringan, serta batasan perangkat keras, dll. 
Hyperledger Fabric [Performance and Scale working group](https://wiki.hyperledger.org/display/PSWG/Performance+and+Scale+Working+Group) saat ini bekerja pada kerangka _benchmarking_ yang disebut 
[Hyperledger Caliper](https://wiki.hyperledger.org/display/caliper).

Beberapa makalah penelitian telah diterbitkan untuk mempelajari dan menguji kemampuan kinerja Hyperledger Fabric. 
[Fabric yang diskalakan menjadi 20.000 transaksi per detik](https://arxiv.org/abs/1901.00910) terbaru.

## Kesimpulan

Setiap evaluasi serius dari platform blockchain harus menyertakan Hyperledger Fabric 
dalam daftar singkatnya.

Jika digabungkan, kemampuan pembeda dari Fabric menjadikannya sistem yang sangat skalabel 
untuk blockchain permissioned mendukung asumsi kepercayaan fleksibel yang memungkinkan
platform untuk mendukung berbagai kasus penggunaan industri mulai dari pemerintah, 
hingga keuangan, hingga logistik rantai pasokan, hingga perawatan kesehatan 
dan sebagainya lebih banyak.

Hyperledger Fabric adalah proyek Hyperledger yang paling aktif. Pembangunan di komunitas 
di sekitar platform terus berkembang, dan inovasi yang disampaikan dengan setiap rilis 
berturut-turut jauh melampaui platform blockchain perusahaan lainnya.

## Pengakuan

Yang sebelumnya berasal dari peer review 
["Hyperledger Fabric: A Distributed Operating System for Permissioned Blockchains"](https://dl.acm.org/doi/10.1145/3190508.3190538) - Elli Androulaki, Artem
Barger, Vita Bortnikov, Christian Cachin, Konstantinos Christidis, Angelo De
Caro, David Enyeart, Christopher Ferris, Gennady Laventman, Yacov Manevich,
Srinivasan Muralidharan, Chet Murthy, Binh Nguyen, Manish Sethi, Gari Singh,
Keith Smith, Alessandro Sorniotti, Chrysoula Stathakopoulou, Marko Vukolic,
Sharon Weed Cocco, Jason Yellick
