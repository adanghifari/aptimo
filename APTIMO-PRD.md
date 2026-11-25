# APTIMO — Product Requirements Document

**Versi 0.3 · Draf kerja · 26 November 2026**

Dokumen ini memisahkan arah produk, perilaku aplikasi, dan rancangan tampilan. Keputusan yang masih terbuka dicatat di bagian **Catatan dan keputusan terbuka** agar tidak dianggap sebagai aturan final.

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
- Pengguna memilih jumlah minum per hari, jam minum, hari berlaku (setiap hari atau hari tertentu), tanggal mulai, dan tanggal selesai opsional. Tanggal selesai bersifat inklusif.
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
| **Atur dengan interval** | Pengguna mengisi jam pertama dan jarak antarjam dalam jam dan menit. Interval harus lebih dari nol. Aplikasi menghitung dan menampilkan semua jam sebelum jadwal disimpan. Contoh: 3 kali sehari, 08.00, interval 4 jam menjadi 08.00, 12.00, 16.00. |

Perilaku interval yang melewati tengah malam **belum diputuskan**. Jangan mengunci penolakan atau penerimaan kasus ini sebelum aturan hari berlaku dan tanggal selesai disepakati; lihat catatan di bagian 8.

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

## 4. Rancangan tampilan dan pengalaman penggunaan

### 4.1 Arah visual umum

Logo jam alarm APTIMO menjadi acuan. Gunakan latar krem hangat, permukaan putih hangat, serta aksen peach dan oranye lembut. Warna menekankan prioritas informasi; setiap prioritas dan status tetap memiliki label teks. Tampilan referensi adalah inspirasi komposisi, bukan daftar elemen yang harus ditiru.

| Peran | Warna usulan awal |
|---|---|
| Latar utama | Krem hangat `#FFF8F2` |
| Permukaan kartu | Putih hangat `#FFFDFA` |
| Aksen utama | Aprikot `#F4B183`, dengan teks gelap |
| Tab aktif dan penekanan lembut | Peach muda `#FCE3D2` |
| Teks atau tautan bernuansa oranye | Terakota `#91431E` |
| Teks utama | Cokelat arang `#302520` |

Kode warna masih usulan. Kontras, keterbacaan, ukuran teks, dan area sentuh harus diperiksa pada perangkat nyata, termasuk dengan ukuran font sistem yang diperbesar.

### 4.2 Halaman Jadwal

Urutan informasi yang disepakati untuk rancangan awal:

1. **Judul “Jadwal Minum Obat”**, dengan tanggal hari ini sebagai teks pendamping. Judul tidak dibatasi “Hari Ini” karena daftar di bawah memuat semua jadwal dan alarm berikutnya mungkin jatuh besok.
2. **Satu kartu utama “Minum berikutnya”** menggantikan area hari dan kartu obat pada referensi. Tampilkan waktu, nama obat, dosis jika ada, dan keterangan waktu yang jelas, misalnya **Dalam 30 menit** atau **Besok**. Jika beberapa obat berada pada waktu yang sama, tampilkan semuanya dengan identitas masing-masing.
3. Informasi jadwal setelahnya, jika diperlukan, cukup berupa satu baris singkat **Setelah ini: [nama obat], [jam]** dalam kartu utama. Tidak diperlukan kartu besar kedua yang mengulang isi daftar.
4. **“Semua Jadwal”** menggantikan bagian belanja pada referensi. Tampilkan daftar semua jadwal yang terdaftar, bukan deretan produk. Setiap jadwal obat tampil sekali; jam di sisi kiri diberi makna **pengingat berikutnya**, sementara seluruh jam minum, hari berlaku, dosis, dan status dapat ditampilkan sebagai informasi pendamping yang ringkas. Jadwal aktif ditampilkan lebih dulu; jadwal nonaktif dan berakhir tetap dapat dikenali.
5. Gunakan tombol melayang **+ Tambah jadwal**. Bila daftar kosong, tampilkan penjelasan singkat dan tombol tambah jadwal yang mudah ditemukan.

Kartu terdekat harus memperlihatkan keadaan sebenarnya. Jika tidak ada alarm mendatang, tampilkan keadaan kosong yang jelas. Jika suatu waktu sudah lewat tetapi belum dikonfirmasi, tampilkan label **Belum dikonfirmasi** atau penanda keterlambatan yang tidak menyatakan obat pasti belum diminum. Rincian penempatan kejadian lewat pada kartu utama masih perlu diputuskan.

Tindakan **Akhiri jadwal** berada di menu opsi jadwal dengan penjelasan akibatnya sebelum dijalankan, bukan tombol utama pada setiap baris. **Sudah diminum** tetap merupakan tindakan untuk satu kejadian obat, terutama pada layar alarm atau agenda yang relevan.

### 4.3 Formulir Jadwal

Tampilkan pertanyaan dan isian bertahap agar formulir tidak terasa penuh sejak awal: frekuensi dahulu, lalu jam pertama dan mode jam bila diperlukan, kemudian hari dan periode. Label menggunakan bahasa sehari-hari. Perlihatkan jam hasil interval sebelum menyimpan dan tampilkan pesan kesalahan tepat di dekat isian yang bermasalah.

### 4.4 Layar Alarm dan Riwayat

Pada layar alarm, utamakan waktu, nama obat, dan tiga tindakan yang berbeda jelas: **Sudah diminum**, **Tunda 10 menit**, dan **Hentikan alarm**. Pada Riwayat, status dan waktu konfirmasi harus dapat dipahami tanpa hanya mengandalkan warna atau ikon.

## 5. Data dan arah teknis

- Jadwal, kejadian alarm, dan riwayat konfirmasi disimpan secara lokal menggunakan SQLite pada perangkat.
- Penjadwalan perlu bertahan tanpa membuka aplikasi setiap hari, memulihkan alarm setelah restart, dan membatalkan alarm lama ketika jadwal berubah.
- Paket Flutter `alarm` merupakan kandidat prototipe, **belum keputusan akhir**. Kemampuan alarm berulang, akses layar penuh, dan pemulihan setelah restart harus diverifikasi pada perangkat Android asli sebelum memilih implementasi final.
- Perizinan Android untuk notifikasi, alarm tepat waktu, dan layar penuh harus diperiksa, diminta melalui alur yang jelas, dan ditunjukkan status nyatanya kepada pengguna.
- Versi minimum Android final ditetapkan setelah pilihan dependensi dan cakupan pengujian jelas.

## 6. Kriteria penerimaan versi pertama

- Membuka aplikasi menampilkan logo lalu Jadwal; navigasi bawah hanya berisi Jadwal dan Riwayat. Semua teks buatan aplikasi berbahasa Indonesia.
- Halaman Jadwal memiliki satu kartu pengingat terdekat, daftar **Semua Jadwal**, dan cara tambah jadwal yang jelas. Daftar membedakan aktif, nonaktif, dan berakhir. **Akhiri jadwal** tidak mencatat konsumsi.
- Tanpa internet, pengguna dapat membuat, mengedit, menonaktifkan, mengaktifkan, dan mengakhiri jadwal, lalu melihat data dan riwayat yang tetap ada setelah aplikasi dibuka kembali.
- Frekuensi satu kali hanya memerlukan jam pertama. Mode manual untuk tiga kali meminta tiga jam dan menolak duplikat serta urutan terbalik. Mode interval 08.00 dengan jarak 4 jam menghasilkan 08.00, 12.00, dan 16.00; interval nol ditolak.
- Jadwal dengan tanggal selesai tidak memicu alarm setelah periode berakhir. Riwayat lama tetap ada.
- Dua obat pada waktu yang sama memicu satu alarm dengan konfirmasi terpisah. Tunda tidak menggeser jadwal rutin; Hentikan tidak mengonfirmasi konsumsi.
- Pada perangkat Android asli, uji bunyi berulang, getaran, banner, ketiga tindakan, alarm saat aplikasi terbuka, serta layar alarm ketika perangkat tidur atau terkunci. Perangkat tetap terkunci setelah layar alarm ditutup.
- Uji pemulihan alarm setelah restart tanpa membuka APTIMO dan perubahan jadwal tanpa meninggalkan alarm lama. Saat izin tidak tersedia, aplikasi menampilkan keadaan sebenarnya dan langkah yang relevan.
- Uji keterbacaan dengan teks sistem diperbesar, label tombol/status, serta area sentuh pada layar berukuran berbeda.

**Catatan:** kriteria untuk interval yang melewati tengah malam baru dapat difinalkan setelah keputusan pada bagian 8 dibuat.

## 7. Urutan pengerjaan

1. **Prototipe alarm Android:** satu alarm uji pada HP asli, termasuk layar kunci, bunyi berulang, banner, Hentikan, dan Tunda.
2. **Alur utama:** layar pembuka, dua tab, formulir dua mode jam, penyimpanan lokal, dan penjadwalan berulang.
3. **Pencatatan dan pemulihan:** konfirmasi per obat, Riwayat, perubahan/akhir jadwal, pemulihan alarm, dan pengujian izin.

## 8. Catatan dan keputusan terbuka

| Topik | Status dan catatan |
|---|---|
| Bahasa dan target pengguna | **Disepakati:** seluruh UI buatan aplikasi berbahasa Indonesia dan mudah digunakan oleh berbagai kelompok usia. |
| Halaman Jadwal | **Disepakati sebagai arah awal:** satu kartu pengingat terdekat, daftar semua jadwal terdaftar, tombol melayang tambah jadwal, dan navigasi bawah dua tab. Rincian visual bisa diperbaiki setelah diuji. |
| Tindakan “Selesai” | **Disepakati:** gunakan istilah **Akhiri jadwal** untuk menghentikan seluruh periode. Jangan samakan dengan **Sudah diminum** untuk satu kejadian. Jadwal bertanggal selesai berakhir otomatis. |
| Interval lintas tengah malam | **Belum diputuskan:** PRD sebelumnya mengusulkan penolakan. Alternatifnya adalah mengizinkan jam berikutnya pada hari kalender berikutnya. Keputusan perlu menjelaskan hubungan dengan hari aktif dan tanggal selesai. Jangan jadikan usulan lama sebagai validasi final. |
| Kejadian lewat tanpa konfirmasi | **Perlu dirinci:** apakah kartu utama menampilkan kejadian terlewat sebelum pengingat mendatang, dan bagaimana urutannya jika ada beberapa kejadian. Status tetap **Belum dikonfirmasi**. |
| Daftar yang panjang | **Perlu diuji:** cara menampilkan jadwal nonaktif dan berakhir tanpa menyulitkan pencarian jadwal aktif. Pilihan lipat bagian atau penyaring belum dikunci. |
| Implementasi alarm | **Kandidat teknis:** paket `alarm` perlu uji pada HP asli; pilihan akhir belum ditetapkan. |

## Referensi teknis dalam draf sebelumnya

- [Android — batas tampilan layar penuh](https://source.android.com/docs/core/permissions/fsi-limits)
- [Android — penjadwalan alarm](https://developer.android.com/develop/background-work/services/alarms)
- [Android — izin notifikasi](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [Flutter — paket alarm](https://pub.dev/packages/alarm)

Referensi teknis ini menjadi titik awal pemeriksaan implementasi, bukan bukti bahwa perilaku paket atau sistem Android sudah teruji untuk APTIMO.
