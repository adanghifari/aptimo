# APTIMO

APTIMO adalah aplikasi pengingat jadwal minum obat untuk Android yang dirancang berjalan secara lokal. Spesifikasi produk ada di [APTIMO-PRD.md](APTIMO-PRD.md).

## Menjalankan pratinjau halaman Jadwal

```powershell
flutter run --dart-define=APTIMO_DEMO=true
```

Mode ini menampilkan obat contoh untuk meninjau kartu pengingat terdekat, daftar jadwal aktif/nonaktif/berakhir, dan keadaan kosong. Tombol **Lihat keadaan kosong** tersedia di bagian atas halaman. Tanpa `APTIMO_DEMO`, halaman dimulai tanpa jadwal contoh.

**Tahap saat ini hanya pratinjau UI.** Jadwal contoh dan perubahan status hanya ada dalam memori. Form tambah jadwal, alarm Android, izin, penyimpanan lokal, dan riwayat konsumsi belum diimplementasikan. Aplikasi menampilkan pesan bahwa pengingat belum aktif agar tidak digunakan sebagai alarm obat pada tahap ini.

## Pemeriksaan

```powershell
flutter analyze
flutter test
```
