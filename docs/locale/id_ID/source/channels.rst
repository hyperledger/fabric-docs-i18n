Saluran (Channels)
========

Hyperledger Fabric ``channel`` adalah "subnet" pribadi komunikasi antara dua atau 
lebih anggota jaringan tertentu, untuk tujuan melakukan transaksi pribadi dan rahasia. 
Channel ditentukan oleh anggota (organisasi), anchor peer per anggota, ledger bersama, 
aplikasi chaincode, dan node ordering service. Setiap transaksi di jaringan dijalankan 
di channel, di mana masing-masing pihak harus diautentikasi dan diberi otorisasi untuk 
bertransaksi di channel tersebut. Setiap rekan yang bergabung dengan channel, memiliki 
identitasnya sendiri yang diberikan oleh penyedia layanan keanggotaan (MSP), yang mengautentikasi 
setiap rekan ke rekan dan layanan channelnya.

Untuk membuat channel baru, SDK klien memanggil sistem konfigurasi chaincode dan properti 
referensi seperti ``anchor peer``, dan anggota (organisasi). Permintaan ini membuat ``genesis block``
untuk channel ledger, yang menyimpan informasi konfigurasi tentang kebijakan channel, 
anggota, dan anchor peer. Saat menambahkan anggota baru ke channel yang ada, genesis block ini, 
atau jika berlaku, blok konfigurasi ulang yang lebih baru, dibagikan dengan anggota baru.

.. note:: Lihat bagian :doc:`configtx` untuk detail lebih lanjut tentang properti
         dan struktur proto transaksi konfigurasi.

Pemilihan ``leading peer`` untuk setiap anggota di channel menentukan rekan mana yang 
berkomunikasi dengan ordering service atas nama anggota. Jika tidak ada pemimpin yang teridentifikasi, 
sebuah algoritma dapat digunakan untuk mengidentifikasi pemimpin. Layanan konsensus memesan transaksi 
dan mengirimkannya, dalam satu blok, ke setiap leading peer, yang kemudian mendistribusikan 
blok tersebut ke rekan anggotanya, dan melintasi channel, menggunakan protokol ``gossip``.

Meskipun satu anchor peer dapat menjadi milik beberapa channel, dan karena itu mempertahankan 
banyak ledger, tidak ada data ledger yang dapat berpindah dari satu channel ke channel lainnya. 
Pemisahan ledger ini, menurut channel, ditentukan dan diterapkan oleh konfigurasi chaincode, 
identity membership service, dan protokol penyebaran data gosip. Penyebaran data, yang mencakup informasi 
tentang transaksi, status ledger, dan keanggotaan channel, dibatasi untuk peer dengan keanggotaan 
yang dapat diverifikasi di channel tersebut. Isolasi peer dan data ledger ini, melalui channel, 
memungkinkan anggota jaringan yang memerlukan transaksi pribadi dan rahasia untuk hidup berdampingan 
dengan pesaing bisnis dan anggota terbatas lainnya, di jaringan blockchain yang sama.

.. Licensed under Creative Commons Attribution 4.0 International License
   https://creativecommons.org/licenses/by/4.0/
