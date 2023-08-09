Hyperledger Fabric Model
========================

Bagian ini menguraikan fitur desain utama yang dijalin ke dalam Hyperledger Fabric yang
memenuhi janjinya akan solusi blockchain perusahaan yang komprehensif namun dapat disesuaikan:

* `Assets`_ --- Definisi aset memungkinkan pertukaran hampir semua hal dengan nilai
  moneter melalui jaringan, mulai dari makanan utuh hingga mobil antik hingga mata uang berjangka.
* `Chaincode`_ --- Eksekusi chaincode dipartisi dari pemesanan transaksi, membatasi tingkat
  kepercayaan dan verifikasi yang diperlukan di seluruh jenis node, dan mengoptimalkan skalabilitas
  dan kinerja jaringan.
* `Ledger Features`_ --- Ledger bersama yang tidak dapat diubah menyandikan seluruh
  riwayat transaksi untuk setiap channel, dan menyertakan kemampuan kueri seperti SQL untuk
  audit yang efisien dan penyelesaian sengketa.
* `Privacy`_ --- Channel dan pengumpulan data pribadi memungkinkan transaksi multilateral
  pribadi dan rahasia yang biasanya dibutuhkan oleh bisnis yang bersaing dan industri yang
  diatur yang bertukar aset di jaringan bersama.
* `Security & Membership Services`_ --- Keanggotaan yang diizinkan menyediakan jaringan
  blockchain tepercaya, di mana peserta mengetahui bahwa semua transaksi dapat dideteksi
  dan dilacak oleh regulator dan auditor resmi.
* `Consensus`_ --- Pendekatan unik untuk konsensus memungkinkan
  fleksibilitas dan skalabilitas yang diperlukan untuk perusahaan.


Assets
------

Aset dapat berkisar dari yang berwujud (real estat dan perangkat keras) hingga
yang tidak berwujud (kontrak dan kekayaan intelektual). Hyperledger Fabric memberikan
kemampuan untuk memodifikasi aset menggunakan transaksi chaincode.

Aset direpresentasikan dalam Hyperledger Fabric sebagai kumpulan pasangan key-value,
dengan perubahan status dicatat sebagai transaksi pada ledger :ref:`Channel`.
Aset dapat direpresentasikan dalam bentuk biner dan/atau JSON.


Chaincode
---------

Chaincode adalah perangkat lunak yang mendefinisikan aset atau banyak aset, dan
instruksi transaksi untuk memodifikasi aset; dengan kata lain, ini adalah logika bisnis.
Chaincode memberlakukan aturan untuk membaca atau mengubah key-value pair atau informasi
database status lainnya. Fungsi-fungsi chaincode dijalankan terhadap database ledger state saat ini
dan dimulai melalui proposal transaksi. Eksekusi chaincode menghasilkan sekumpulan penulisan
key-value (write set) yang dapat dikirimkan ke jaringan dan diterapkan ke ledger di semua peer.


Ledger Features
---------------

Ledger adalah catatan yang diurutkan dan tidak dapat dirusak dari semua transisi state
di dalam struktur. Transisi state adalah hasil dari pemanggilan chaincode ('transaksi') yang
diajukan oleh pihak yang berpartisipasi. Setiap transaksi menghasilkan sekumpulan pasangan
key-value aset yang berkomitmen ke ledger sebagai pembuatan, pembaruan, atau penghapusan.

Ledger terdiri dari blockchain ('rantai') untuk menyimpan catatan yang tidak dapat diubah
dan diurutkan dalam blok, serta state database untuk mempertahankan current fabric state.
Ada satu ledger per channel. Setiap partisipan menyimpan salinan ledger untuk setiap channel
tempat mereka menjadi anggota.

Beberapa fitur dari ledger Fabric ialah:

- Kueri dan perbarui ledger menggunakan key-based lookups, kueri rentang, dan kueri kunci gabungan
- Kueri hanya baca menggunakan rich query language (jika menggunakan CouchDB sebagai state database)
- Kueri riwayat read-only --- Kueri riwayat ledger untuk kunci, mengaktifkan skenario sumber data
- Transaksi terdiri dari versi keys/values yang dibaca dalam chaincode (read set) dan keys/values yang ditulis dalam chaincode (write set)
- Transaksi berisi tanda tangan dari setiap peer yang mendukung dan diserahkan ke ordering service
- Transaksi dipesan ke dalam blok dan "dikirim" dari ordering service ke peer di channel
- Rekan memvalidasi transaksi terhadap kebijakan dukungan dan menegakkan kebijakan
- Sebelum menambahkan blok, pemeriksaan versi dilakukan untuk memastikan bahwa status aset yang dibaca tidak berubah sejak waktu eksekusi chaincode
- Ada immutability setelah transaksi divalidasi dan dilakukan
- Channel ledger berisi blok konfigurasi yang menentukan kebijakan, daftar kontrol akses, dan informasi terkait lainnya
- Channel berisi contoh :ref:`MSP` yang memungkinkan material crypto berasal dari otoritas sertifikat yang berbeda

Lihat topik :doc:`ledger/ledger` untuk mempelajari lebih dalam tentang database, struktur penyimpanan, dan "kemampuan kueri".

Privacy
-------

Hyperledger Fabric employs an immutable ledger on a per-channel basis, as well as
chaincode that can manipulate and modify the current state of assets (i.e. update
key-value pairs).  A ledger exists in the scope of a channel --- it can be shared
across the entire network (assuming every participant is operating on one common
channel) --- or it can be privatized to include only a specific set of participants.

In the latter scenario, these participants would create a separate channel and
thereby isolate/segregate their transactions and ledger.  In order to solve
scenarios that want to bridge the gap between total transparency and privacy,
chaincode can be installed only on peers that need to access the asset states
to perform reads and writes (in other words, if a chaincode is not installed on
a peer, it will not be able to properly interface with the ledger).

When a subset of organizations on that channel need to keep their transaction
data confidential, a private data collection (collection) is used to segregate
this data in a private database, logically separate from the channel ledger,
accessible only to the authorized subset of organizations.

Thus, channels keep transactions private from the broader network whereas
collections keep data private between subsets of organizations on the channel.

To further obfuscate the data, values within chaincode can be encrypted
(in part or in total) using common cryptographic algorithms such as AES before
sending transactions to the ordering service and appending blocks to the ledger.
Once encrypted data has been written to the ledger, it can be decrypted only by
a user in possession of the corresponding key that was used to generate the cipher
text.

See the :doc:`private-data-arch` topic for more details on how to achieve
privacy on your blockchain network.


Security & Membership Services
------------------------------

Hyperledger Fabric underpins a transactional network where all participants have
known identities.  Public Key Infrastructure is used to generate cryptographic
certificates which are tied to organizations, network components, and end users
or client applications.  As a result, data access control can be manipulated and
governed on the broader network and on channel levels.  This "permissioned" notion
of Hyperledger Fabric, coupled with the existence and capabilities of channels,
helps address scenarios where privacy and confidentiality are paramount concerns.

For more information see the :doc:`security_model` topic.

Consensus
---------

In distributed ledger technology, consensus has recently become synonymous with
a specific algorithm, within a single function. However, consensus encompasses more
than simply agreeing upon the order of transactions, and this differentiation is
highlighted in Hyperledger Fabric through its fundamental role in the entire
transaction flow, from proposal and endorsement, to ordering, validation and commitment.
In a nutshell, consensus is defined as the full-circle verification of the correctness of
a set of transactions comprising a block.

Consensus is achieved ultimately when the order and results of a block's
transactions have met the explicit policy criteria checks. These checks and balances
take place during the lifecycle of a transaction, and include the usage of
endorsement policies to dictate which specific members must endorse a certain
transaction class, as well as system chaincodes to ensure that these policies
are enforced and upheld.  Prior to commitment, the peers will employ these
system chaincodes to make sure that enough endorsements are present, and that
they were derived from the appropriate entities.  Moreover, a versioning check
will take place during which the current state of the ledger is agreed or
consented upon, before any blocks containing transactions are appended to the ledger.
This final check provides protection against double spend operations and other
threats that might compromise data integrity, and allows for functions to be
executed against non-static variables.

In addition to the multitude of endorsement, validity and versioning checks that
take place, there are also ongoing identity verifications happening in all
directions of the transaction flow.  Access control lists are implemented on
hierarchical layers of the network (ordering service down to channels), and
payloads are repeatedly signed, verified and authenticated as a transaction proposal passes
through the different architectural components.  To conclude, consensus is not
merely limited to the agreed upon order of a batch of transactions; rather,
it is an overarching characterization that is achieved as a byproduct of the ongoing
verifications that take place during a transaction's journey from proposal to
commitment.

Check out the :doc:`txflow` diagram for a visual representation
of consensus.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
