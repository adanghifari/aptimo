# APTIMO — Product Requirements Document

**Versi 0.5 · Draf kerja · 26 November 2026**

Dokumen ini menjadi acuan tujuan produk, perilaku aplikasi, dan syarat selesai versi pertama. Keputusan yang belum disepakati dicatat di bagian 7. Rincian visual yang masih berubah disimpan di [Catatan UI](APTIMO-UI.md); penyempurnaan tampilan yang tidak mengubah perilaku produk tidak memerlukan revisi PRD.

## 1. Pengertian dan arah aplikasi

### 1.1 Apa itu APTIMO

APTIMO adalah aplikasi Android untuk membantu pengguna mengingat jadwal minum obat dan mencatat konfirmasi konsumsi. Pengguna memasukkan nama obat, waktu, dan periode pemakaiannya sendiri. APTIMO mengingatkan sesuai jadwal tersebut; aplikasi tidak menentukan obat, dosis, atau aturan medis bagi pengguna.

### 1.2 Pengguna dan tujuan

- Ditujukan bagi pengguna pribadi dari berbagai kelompok usia, baik untuk obat rutin maupun obat dengan periode tertentu.
- Pengguna dapat melihat pengingat berikutnya dengan cepat, mengelola seluruh jadwal, dan memeriksa riwayat konfirmasi.
- Pengalaman penggunaan harus mudah dipahami tanpa mengandalkan istilah teknis, warna saja, atau gerakan tersembunyi.

### 1.3 Prinsip produk

- **Lokal dan sederhana:** berjalan secara offline di Android, tanpa akun, backend, sinkronisasi, atau biaya hosting. Jadwal dan riwayat disimpan di perangkat.
- **Bahasa Indonesia:** semua teks buatan aplikasi menggunakan bahasa Indonesia yang singkat dan jelas. Nama obat dan catatan yang ditulis pengguna ditampilkan sebagaimana dimasukkan. Teks sistem Android mengikuti pengaturan perangkat.
- **Status yang jujur:** tidak ada konfirmasi konsumsi otomatis. Jika pengguna hanya menghentikan alarm, statusnya tetap **Belum dikonfirmasi**; aplikasi tidak boleh menyebutnya **Belum diminum** karena tidak mengetahui apakah obat benar-benar diminum.
- **Akses untuk berbagai usia:** utamakan teks yang mudah dibaca, area sentuh yang nyaman, tombol berlabel, kontras yang jelas, dan alur dengan pilihan yang tidak berlebihan.

### 1.4 Cakupan awal

Versi pertama berfokus pada jadwal, alarm, konfirmasi konsumsi, dan riwayat. Distribusi awal melalui APK untuk uji pribadi. Sinkronisasi antardevice, akun, dan pengingat untuk anggota keluarga berada di luar cakupan awal.

## 2. Struktur dan alur aplikasi

1. Saat dibuka dari ikon, aplikasi menampilkan logo APTIMO selama data lokal disiapkan, lalu langsung membuka **Jadwal**.
2. Navigasi bawah hanya memiliki dua tab: **Jadwal** dan **Riwayat**. Jadwal menjadi tab awal.
3. Layar pembuka, formulir jadwal, pengaturan, dan layar alarm tidak menampilkan navigasi bawah.
4. Pengaturan alarm dan fitur **Coba alarm** dapat dibuka dari ikon pengaturan di halaman Jadwal.
5. Mengetuk notifikasi alarm yang masih aktif membuka layar alarm terkait. Jika kejadian alarm sudah selesai, aplikasi membuka Jadwal.

## 3. Fungsi dan aturan

### 3.1 Membuat dan mengelola jadwal

- Nama obat wajib. Dosis dan catatan bersifat opsional.
- Pengguna memilih jumlah minum per hari, jam minum, hari berlaku (setiap hari atau hari tertentu), tanggal mulai, dan tanggal selesai opsional. Tanggal selesai bersifat inklusif; pada jadwal baru tanggal selesai tidak boleh mendahului tanggal mulai atau hari pembuatan.
- Jadwal dapat diedit, dinonaktifkan sementara, diaktifkan kembali, atau diakhiri. Perubahan memperbarui alarm mendatang tanpa menghapus riwayat kejadian sebelumnya.
- **Akhiri jadwal** menghentikan pengingat mendatang untuk seluruh jadwal obat tersebut. Tindakan ini tidak sama dengan **Sudah diminum**, yang hanya mengonfirmasi satu kejadian. Jadwal dengan tanggal selesai berakhir otomatis setelah periode yang ditetapkan.
- Jadwal yang belum dimulai, aktif, nonaktif, dan sudah berakhir harus dapat dibedakan melalui label status yang jelas.

### 3.2 Pengaturan jam minum

1. Isian pertama adalah **Berapa kali sehari?**, berupa bilangan bulat minimal 1.
2. Setelah jumlah diisi, tampilkan **Jam pertama**. Untuk satu kali sehari, hanya jam ini yang diperlukan.
3. Untuk lebih dari satu kali sehari, pengguna memilih salah satu mode berikut:

| Mode | Isian dan validasi |
|---|---|
| **Atur jam sendiri** | Tampilkan isian jam sebanyak jumlah minum per hari, termasuk jam pertama. Semua jam wajib diisi dan berurutan naik secara ketat: jam 1 < jam 2 < jam 3, dan seterusnya. Jam yang sama atau urutan terbalik ditolak dengan pesan pada isian terkait. |
| **Atur dengan interval** | Pengguna mengisi jam pertama dan jarak antarjam dalam jam dan menit. Interval harus lebih dari nol. Aplikasi menghitung dan menampilkan semua jam sebelum jadwal disimpan. Contoh: 3 kali sehari, 08.00, interval 4 jam menjadi 08.00, 12.00, 16.00. Jam terakhir harus paling lambat 23.59 pada hari yang sama; hasil yang melewati tengah malam ditolak dengan pesan yang jelas. |

Saat jadwal baru dibuat, jam yang sudah lewat pada hari pembuatan tidak dianggap sebagai pengingat tertinggal atau catatan **Belum dikonfirmasi**. Hanya jam yang masih akan datang yang berlaku hari itu. Mulai hari berikutnya, seluruh urutan jam berlaku lagi sesuai hari aktif dan periode jadwal. Tanggal selesai tetap inklusif.

### 3.3 Alarm dan tindakan

- Pengingat menggunakan alarm Android yang tetap dapat bekerja ketika APTIMO tidak sedang terbuka. Saat aktif, nada berbunyi berulang dan perangkat bergetar sesuai pengaturan sampai pengguna menanganinya.
- Layar alarm APTIMO menampilkan waktu, nama obat, dosis, dan catatan jika ada. Bila beberapa obat jatuh pada waktu yang sama, satu alarm menampilkan semua obat dengan konfirmasi masing-masing.
- **Sudah diminum:** mengonfirmasi obat yang dipilih dan menyimpan waktu konfirmasi. Ketukan berulang tidak membuat catatan ganda. Jika semua obat dalam alarm sudah dikonfirmasi, alarm berhenti.
- **Tunda 10 menit:** menghentikan bunyi saat ini dan mengingatkan kembali obat yang masih belum dikonfirmasi untuk kejadian tersebut. Jadwal rutin berikutnya tidak bergeser.
- **Hentikan alarm:** hanya menghentikan bunyi; obat yang belum dikonfirmasi tetap berstatus **Belum dikonfirmasi**.
- Pengguna dapat mengonfirmasi suatu kejadian dari agenda/kartu yang relevan. Pengingat untuk kejadian yang seluruh obatnya sudah dikonfirmasi dibatalkan.

| Kondisi perangkat | Perilaku yang ditargetkan |
|---|---|
| Layar tidur atau perangkat terkunci | Alarm membangunkan layar dan menampilkan layar APTIMO di atas layar kunci jika akses layar penuh tersedia. Perangkat tetap terkunci; setelah layar alarm ditutup, pembukaan perangkat tetap memerlukan autentikasi yang diatur pengguna. |
| APTIMO sedang terbuka | Layar alarm tampil langsung dalam aplikasi. |
| Aplikasi lain sedang digunakan | Android dapat menampilkan banner yang bisa diketuk untuk membuka layar alarm. |
| Akses layar penuh tidak tersedia | Gunakan banner bila notifikasi diizinkan dan tampilkan status izin pada pengaturan. |
| Izin alarm tepat waktu belum tersedia | Simpan isian jadwal, tampilkan status **Alarm belum terjadwal**, dan sediakan jalan menuju pengaturan Android. |
| Perangkat dimulai ulang | Periksa izin dan pulihkan alarm mendatang dari jadwal tersimpan; perilaku ini harus diuji tanpa membuka aplikasi kembali. |

### 3.4 Riwayat

- Tampilkan kejadian terbaru lebih dulu, dikelompokkan berdasarkan tanggal.
- Setiap kejadian memperlihatkan nama obat, jam terjadwal, status **Sudah diminum** atau **Belum dikonfirmasi**, dan waktu konfirmasi jika ada.
- Riwayat tetap tersimpan jika suatu jadwal diedit, dinonaktifkan, berakhir otomatis, atau diakhiri secara manual.

### 3.5 Pengaturan

Tampilkan status izin notifikasi, alarm tepat waktu, dan tampilan layar penuh bila relevan. Sediakan pilihan getaran dan **Coba alarm**. Alarm uji tidak membuat catatan konsumsi.

## 4. Pengalaman penggunaan

- Halaman **Jadwal** memperlihatkan pengingat mendatang yang paling dekat dan daftar jadwal aktif. Jika tidak ada pengingat atau jadwal aktif, tampilkan keadaan yang sebenarnya dengan penjelasan yang jelas. Jadwal nonaktif dan berakhir tidak memenuhi daftar aktif; jadwal nonaktif tetap harus dapat ditemukan dan diaktifkan kembali melalui alur pengelolaan yang akan ditentukan.
- Pengguna dapat menambah dan mengedit jadwal. Tindakan **Akhiri jadwal** meminta konfirmasi, menghentikan pengingat mendatang, dan tidak mencatat konsumsi obat.
- Formulir menampilkan frekuensi lebih dulu, lalu jam dan mode yang relevan, hari berlaku, serta periode. Hasil interval terlihat sebelum disimpan. Kesalahan isian dijelaskan di dekat isian terkait.
- Layar alarm mengutamakan waktu, identitas obat, dan perbedaan antara **Sudah diminum**, **Tunda 10 menit**, dan **Hentikan alarm**. Riwayat menunjukkan status tanpa hanya mengandalkan warna atau ikon.
- Semua layar menggunakan bahasa Indonesia yang jelas, teks yang terbaca, label tindakan, kontras yang cukup, dan area sentuh yang nyaman untuk berbagai kelompok usia. Periksa pada layar Android serta ukuran font sistem yang berbeda.

Rancangan komposisi, palet, teks judul, dan gaya komponen yang sedang diuji ada di [Catatan UI](APTIMO-UI.md). Dokumen tersebut dapat berkembang tanpa mengubah persyaratan produk di sini.

## 5. Data dan arah teknis

- Jadwal, kejadian alarm, dan riwayat konfirmasi disimpan secara lokal menggunakan SQLite pada perangkat.
- Penjadwalan perlu bertahan tanpa membuka aplikasi setiap hari, memulihkan alarm setelah restart, dan membatalkan alarm lama ketika jadwal berubah.
- Kemampuan alarm berulang, akses layar penuh, dan pemulihan setelah restart harus diverifikasi pada perangkat Android asli sebelum memilih implementasi final.
- Perizinan Android untuk notifikasi, alarm tepat waktu, dan layar penuh harus diperiksa, diminta melalui alur yang jelas, dan ditunjukkan status nyatanya kepada pengguna.
- Versi minimum Android final ditetapkan setelah pilihan dependensi dan cakupan pengujian jelas.

## 6. Kriteria penerimaan versi pertama

- Membuka aplikasi menampilkan logo lalu Jadwal; navigasi bawah hanya berisi Jadwal dan Riwayat. Semua teks buatan aplikasi berbahasa Indonesia.
- Halaman Jadwal memiliki satu kartu pengingat terdekat, daftar **Jadwal Aktif**, dan cara tambah jadwal yang jelas. Jadwal nonaktif dan berakhir tidak tampil dalam daftar aktif; jadwal nonaktif tetap dapat ditemukan dan diaktifkan kembali melalui tempat pengelolaan jadwal yang akan dirancang. **Akhiri jadwal** tidak mencatat konsumsi.
- Tanpa internet, pengguna dapat membuat, mengedit, menonaktifkan, mengaktifkan, dan mengakhiri jadwal, lalu melihat data dan riwayat yang tetap ada setelah aplikasi dibuka kembali.
- Frekuensi satu kali hanya memerlukan jam pertama. Mode manual untuk tiga kali meminta tiga jam dan menolak duplikat serta urutan terbalik. Mode interval 08.00 dengan jarak 4 jam menghasilkan 08.00, 12.00, dan 16.00; interval nol dan jam yang melewati 23.59 ditolak.
- Jika jadwal 08.00, 12.00, dan 16.00 dibuat pada pukul 13.00, hanya 16.00 yang berlaku pada hari itu. Hari aktif berikutnya kembali dimulai dari 08.00 tanpa membuat kejadian tertinggal untuk 08.00 dan 12.00 pada hari pembuatan.
- Jadwal dengan tanggal selesai tidak memicu alarm setelah periode berakhir. Riwayat lama tetap ada.
- Dua obat pada waktu yang sama memicu satu alarm dengan konfirmasi terpisah. Tunda tidak menggeser jadwal rutin; Hentikan tidak mengonfirmasi konsumsi.
- Pada perangkat Android asli, uji bunyi berulang, getaran, banner, ketiga tindakan, alarm saat aplikasi terbuka, serta layar alarm ketika perangkat tidur atau terkunci. Perangkat tetap terkunci setelah layar alarm ditutup.
- Uji pemulihan alarm setelah restart tanpa membuka APTIMO dan perubahan jadwal tanpa meninggalkan alarm lama. Saat izin tidak tersedia, aplikasi menampilkan keadaan sebenarnya dan langkah yang relevan.
- Uji keterbacaan dengan teks sistem diperbesar, label tombol/status, serta area sentuh pada layar berukuran berbeda.

## 7. Keputusan terbuka

| Topik | Status dan catatan |
|---|---|
| Kejadian lewat tanpa konfirmasi | **Perlu dirinci untuk jadwal yang sudah berjalan:** apakah kartu utama menampilkan kejadian terlewat sebelum pengingat mendatang, dan bagaimana urutannya jika ada beberapa kejadian. Jam yang telah lewat sebelum jadwal dibuat hari ini tidak membuat kejadian; status kejadian yang memang terjadwal tetap **Belum dikonfirmasi**. |
| Akses jadwal nonaktif | **Perlu dirancang:** jadwal nonaktif dan berakhir tidak tampil di daftar Jadwal Aktif. Sediakan tempat lain untuk menemukan jadwal nonaktif dan mengaktifkannya kembali sebelum fitur nonaktifkan tersedia. |
| Implementasi alarm | **Perlu diuji:** pilih pendekatan Android setelah bunyi berulang, getaran, layar kunci, izin, dan pemulihan setelah restart berhasil diuji pada HP asli. |
