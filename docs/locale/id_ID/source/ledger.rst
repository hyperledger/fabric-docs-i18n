Buku Besar (Ledger)
======

Buku besar adalah catatan yang diurutkan dan tidak dapat dirusak dari semua transisi _state_. 
Transisi _state_ adalah hasil dari pemanggilan chaincode ("transaksi") yang diajukan oleh pihak 
yang berpartisipasi. Setiap transaksi menghasilkan sekumpulan pasangan nilai kunci aset yang 
berkomitmen untuk buku besar sebagai membuat, memperbarui, atau menghapus.

Ledger terdiri dari blockchain ('rantai') untuk menyimpan catatan yang tidak dapat diubah 
dan diurutkan dalam blok, serta database _state_ untuk mempertahankan status saat ini. 
Ada satu buku besar per _channel_. Setiap rekan menyimpan salinan buku besar untuk setiap _channel_ 
tempat mereka menjadi anggota.

Rantai
-----

Rantai adalah log transaksi, terstruktur sebagai blok hash-linked, di mana setiap blok berisi urutan N transaksi. 
Header blok menyertakan hash dari transaksi blok, serta hash dari header blok sebelumnya. 
Dengan cara ini, semua transaksi pada buku besar diurutkan dan secara kriptografi dihubungkan bersama. 
Dengan kata lain, tidak mungkin mengutak-atik data buku besar, tanpa memutus tautan hash. Hash dari blok terbaru 
mewakili setiap transaksi yang telah terjadi sebelumnya, sehingga memungkinkan untuk memastikan bahwa semua peer 
berada dalam status yang konsisten dan tepercaya.

Rantai disimpan pada sistem file peer (baik penyimpanan lokal atau terpasang), secara efisien mendukung 
sifat tambahan dari beban kerja blockchain.

Basis Data _State_ (State Database) 
--------------

Data _state_ buku besar saat ini mewakili nilai terbaru untuk semua kunci yang pernah disertakan 
dalam log transaksi berantai. Karena _state_ saat ini mewakili semua nilai kunci terbaru yang diketahui _channel_, 
terkadang disebut sebagai World State.

Pemanggilan chaincode mengeksekusi transaksi terhadap data _state_ saat ini. Untuk membuat interaksi 
chaincode ini sangat efisien, nilai terbaru dari semua kunci disimpan dalam basis data _state_. 
Basis data _state_ hanyalah tampilan yang diindeks ke dalam log transaksi rantai, oleh karena itu 
dapat dibuat ulang dari rantai kapan saja. Basis data _state_ akan secara otomatis dipulihkan 
(atau dihasilkan jika diperlukan) saat peer memulai, sebelum transaksi diterima.

Pilihan untuk basis data _state_ termasuk LevelDB dan CouchDB. LevelDB adalah database status default yang disematkan 
dalam proses peer dan menyimpan data chaincode sebagai pasangan nilai kunci (key-value). 
CouchDB adalah database status eksternal alternatif opsional yang menyediakan dukungan kueri tambahan 
saat data chaincode Anda dimodelkan sebagai JSON, memungkinkan kueri kaya konten JSON. 
Lihat :doc:`couchdb_as_state_database` untuk informasi lebih lanjut tentang CouchDB.

Transaction Flow
----------------

At a high level, the transaction flow consists of a transaction proposal sent by an application
client to specific endorsing peers.  The endorsing peers verify the client signature, and execute
a chaincode function to simulate the transaction. The output is the chaincode results,
a set of key-value versions that were read in the chaincode (read set), and the set of keys/values
that were written in chaincode (write set). The proposal response gets sent back to the client
along with an endorsement signature.

The client assembles the endorsements into a transaction payload and broadcasts it to an ordering
service. The ordering service delivers ordered transactions as blocks to all peers on a channel.

Before committal, peers will validate the transactions. First, they will check the endorsement
policy to ensure that the correct allotment of the specified peers have signed the results, and they
will authenticate the signatures against the transaction payload.

Secondly, peers will perform a versioning check against the transaction read set, to ensure
data integrity and protect against threats such as double-spending. Hyperledger Fabric has concurrency
control whereby transactions execute in parallel (by endorsers) to increase throughput, and upon
commit (by all peers) each transaction is verified to ensure that no other transaction has modified
data it has read. In other words, it ensures that the data that was read during chaincode execution
has not changed since execution (endorsement) time, and therefore the execution results are still
valid and can be committed to the ledger state database. If the data that was read has been changed
by another transaction, then the transaction in the block is marked as invalid and is not applied to
the ledger state database. The client application is alerted, and can handle the error or retry as
appropriate.

See the :doc:`txflow`, :doc:`readwrite`, and :doc:`couchdb_as_state_database` topics for a deeper
dive on transaction structure, concurrency control, and the state DB.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
