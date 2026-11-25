import 'package:aptimo/features/jadwal/jadwal_page.dart';
import 'package:aptimo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tab awal memiliki keadaan kosong dan dua navigasi', (
    tester,
  ) async {
    await tester.pumpWidget(const AptimoApp());

    expect(find.text('Jadwal Minum Obat'), findsOneWidget);
    expect(find.text('Belum ada jadwal obat'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(2));

    await tester.tap(find.text('Riwayat').last);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Catatan obat yang sudah dikonfirmasi akan tampil di sini '
        'setelah fitur riwayat tersedia.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('jam pengingat terdekat dan daftar terisi ditampilkan', (
    tester,
  ) async {
    final sekarang = DateTime(2026, 11, 26, 7);
    final jadwal = [
      const JadwalObat(
        nama: 'Paracetamol',
        jam: [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 20, minute: 0)],
        hari: {1, 2, 3, 4, 5, 6, 7},
        status: StatusJadwal.aktif,
      ),
      const JadwalObat(
        nama: 'Obat batuk',
        jam: [TimeOfDay(hour: 9, minute: 0)],
        hari: {1, 2, 3, 4, 5, 6, 7},
        status: StatusJadwal.nonaktif,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: JadwalPage(jadwalAwal: jadwal, sekarang: sekarang),
      ),
    );

    expect(find.text('08.00'), findsWidgets);
    expect(find.text('Dalam 1 jam'), findsOneWidget);
    expect(find.text('Semua Jadwal'), findsOneWidget);
  });

  test('jadwal nonaktif tidak menghasilkan pengingat mendatang', () {
    const jadwal = JadwalObat(
      nama: 'Obat batuk',
      jam: [TimeOfDay(hour: 9, minute: 0)],
      hari: {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.nonaktif,
    );
    expect(jadwal.berikutnya(DateTime(2026, 11, 26, 7)), isNull);
  });

  test('periode yang selesai tidak menghasilkan pengingat baru', () {
    final jadwal = JadwalObat(
      nama: 'Obat sementara',
      jam: const [TimeOfDay(hour: 9, minute: 0)],
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.aktif,
      tanggalSelesai: DateTime(2026, 11, 25),
    );
    final sekarang = DateTime(2026, 11, 26, 7);
    expect(jadwal.statusPada(sekarang), StatusJadwal.berakhir);
    expect(jadwal.berikutnya(sekarang), isNull);
  });
}
