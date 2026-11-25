# APTIMO

APTIMO adalah aplikasi pengingat jadwal minum obat untuk Android yang dirancang berjalan secara lokal. [PRD](APTIMO-PRD.md) memuat tujuan, perilaku, dan kriteria selesai; [Catatan UI](APTIMO-UI.md) memuat arah tampilan yang sedang diuji. Perbaikan visual kecil tidak perlu dicatat di PRD.

## Menjalankan pratinjau halaman Jadwal

```powershell
flutter run --dart-define=APTIMO_DEMO=true
```

Mode ini menampilkan obat contoh untuk meninjau kartu pengingat terdekat, daftar jadwal aktif, dan keadaan kosong. Ketuk logo **APTIMO** di kiri atas untuk berganti antara jadwal contoh dan keadaan kosong. Pemicu sementara ini hanya aktif saat `APTIMO_DEMO=true` dan harus dihapus setelah fitur jadwal asli tersedia. Tanpa `APTIMO_DEMO`, halaman dimulai tanpa jadwal contoh.

**Tahap saat ini hanya pratinjau UI.** Jadwal contoh dan perubahan status hanya ada dalam memori. Form tambah jadwal, alarm Android, izin, penyimpanan lokal, dan riwayat konsumsi belum diimplementasikan. Jangan gunakan pratinjau ini sebagai alarm obat.

## Catatan teknis awal

Paket Flutter [`alarm`](https://pub.dev/packages/alarm) merupakan kandidat untuk prototipe, belum keputusan akhir. Perilaku bunyi berulang, getaran, layar kunci, izin, dan pemulihan setelah restart perlu diuji di HP Android asli. Referensi awal: [alarm Android](https://developer.android.com/develop/background-work/services/alarms), [notifikasi Android](https://developer.android.com/develop/ui/views/notifications/notification-permission), dan [batas layar penuh](https://source.android.com/docs/core/permissions/fsi-limits).

## Pemeriksaan

```powershell
flutter analyze
flutter test
```
