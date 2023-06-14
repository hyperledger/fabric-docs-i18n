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

Alur Transaksi
----------------

Pada tingkat tinggi, alur transaksi terdiri dari proposal transaksi yang dikirim oleh klien aplikasi
ke peer pendukung tertentu. Peer pendukung memverifikasi _signature_ klien, dan menjalankan fungsi
chaincode untuk mensimulasikan transaksi. Keluarannya adalah hasil chaincode, kumpulan versi
key-value yang dibaca dalam chaincode (set baca), dan kumpulan kunci/nilai yang ditulis dalam
chaincode (set tulis). Tanggapan proposal akan dikirim kembali ke klien bersama dengan
_signature_ pengesahan.

Klien menyusun pengesahan menjadi muatan transaksi dan menyiarkannya ke ordering service.
Ordering service mengirimkan transaksi yang dipesan sebagai blok ke semua peer di _channel_.

Sebelum berkomitmen, kumpulan peer akan memvalidasi transaksi. Pertama, mereka akan memeriksa kebijakan
pengesahan untuk memastikan bahwa penjatahan yang benar dari peer yang ditentukan telah menandatangani hasil,
dan mereka akan mengautentikasi _signature_ terhadap muatan transaksi.

Kedua, peer akan melakukan pemeriksaan versi terhadap kumpulan pembacaan transaksi, untuk memastikan
integritas data dan melindungi dari ancaman seperti _double-spending_. Hyperledger Fabric memiliki
kontrol konkurensi dimana transaksi dijalankan secara paralel (oleh endorser) untuk meningkatkan throughput,
dan setelah komit (oleh semua peer) setiap transaksi diverifikasi untuk memastikan bahwa tidak ada transaksi
lain yang mengubah data yang telah dibacanya. Dengan kata lain, hal itu memastikan bahwa data yang dibaca selama
eksekusi chaincode tidak berubah sejak waktu eksekusi (endorsement), sehingga hasil eksekusi masih valid
dan dapat di-commit ke database ledger state. Jika data yang dibaca telah diubah oleh transaksi lain,
maka transaksi di blok tersebut ditandai sebagai tidak valid dan tidak diterapkan ke database ledger state.
Aplikasi klien diberi tahu, dan dapat menangani kesalahan atau mencoba lagi sebagaimana mestinya.

Lihat topik :doc:`txflow`, :doc:`readwrite`, dan :doc:`couchdb_as_state_database` untuk mengetahui lebih dalam
selami struktur transaksi, kontrol konkurensi, dan DB status.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
