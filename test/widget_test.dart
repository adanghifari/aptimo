import 'package:aptimo/features/jadwal/jadwal_page.dart';
import 'package:aptimo/features/jadwal/jadwal_form.dart';
import 'package:aptimo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tab awal memiliki keadaan kosong dan dua navigasi', (
    tester,
  ) async {
    await tester.pumpWidget(const AptimoApp());

    expect(find.text('Cek Jadwal\nMinum Obatmu!'), findsOneWidget);
    expect(find.textContaining('Pratinjau tampilan'), findsNothing);
    expect(find.text('Belum ada jadwal aktif'), findsOneWidget);
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
    expect(find.text('Jadwal Aktif'), findsOneWidget);
    expect(find.text('1 obat'), findsOneWidget);
    expect(find.text('Obat batuk'), findsNothing);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.byType(PopupMenuButton), findsNothing);
    expect(find.text('Edit Jadwal'), findsOneWidget);
    expect(find.text('Akhiri Jadwal'), findsOneWidget);
  });

  testWidgets('logo mengganti data contoh dan keadaan kosong', (tester) async {
    await tester.pumpWidget(const AptimoApp(tampilkanContoh: true));

    expect(find.text('Paracetamol'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('aptimoDemoToggle')));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada jadwal aktif'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('aptimoDemoToggle')));
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol'), findsWidgets);
  });

  testWidgets('form tambah jadwal membuka dialog dan menambah obat', (
    tester,
  ) async {
    await tester.pumpWidget(const AptimoApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Berapa kali sehari?'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('jumlahMinum')), '1');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jam ke-1: Pilih jam'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsNWidgets(2));
    expect(find.text('Jam terpilih: 08.00'), findsOneWidget);
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('namaObat')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.enterText(find.byKey(const ValueKey('namaObat')), 'Vitamin C');
    await tester.tap(find.text('Tambahkan jadwal'));
    await tester.pumpAndSettle();

    expect(find.text('Jadwal Aktif'), findsOneWidget);
    expect(find.text('1 obat'), findsOneWidget);
    expect(find.text('Vitamin C'), findsWidgets);
  });

  testWidgets('pilihan metode muncul sebelum isian jam untuk beberapa kali', (
    tester,
  ) async {
    await tester.pumpWidget(const AptimoApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('jumlahMinum')), '3');
    await tester.pumpAndSettle();

    expect(find.text('Cara mengatur jam'), findsOneWidget);
    expect(find.text('Jam minum'), findsNothing);
    expect(find.text('Jam ke-1: Pilih jam'), findsNothing);

    await tester.tap(find.text('Atur sendiri'));
    await tester.pumpAndSettle();
    expect(find.text('Jam minum'), findsOneWidget);
    expect(find.text('Jam ke-1: Pilih jam'), findsOneWidget);
    expect(find.text('Jam ke-2: Pilih jam'), findsOneWidget);

    await tester.tap(find.text('Interval'));
    await tester.pumpAndSettle();
    expect(find.text('Jam ke-1: Pilih jam'), findsOneWidget);
    expect(find.text('Jam ke-2: Pilih jam'), findsNothing);
  });

  testWidgets('jam berikutnya dimulai satu menit setelah jam sebelumnya', (
    tester,
  ) async {
    await tester.pumpWidget(const AptimoApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('jumlahMinum')), '2');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Atur sendiri'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jam ke-1: Pilih jam'));
    await tester.pumpAndSettle();
    final pemilihJam = tester.widget<CupertinoPicker>(
      find.byType(CupertinoPicker).first,
    );
    pemilihJam.scrollController!.jumpToItem(9);
    await tester.pumpAndSettle();
    expect(find.text('Jam terpilih: 09.00'), findsOneWidget);
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    expect(find.text('Jam ke-1: 09.00'), findsOneWidget);
    expect(find.text('Sudah dipilih · Ketuk untuk ubah'), findsOneWidget);
    await tester.ensureVisible(find.text('Jam ke-2: Pilih jam'));
    await tester.tap(find.text('Jam ke-2: Pilih jam'));
    await tester.pumpAndSettle();
    expect(find.text('Jam ke-2 harus setelah jam sebelumnya.'), findsOneWidget);
    expect(find.text('Pilihan mulai 09.01.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CupertinoPicker).first,
        matching: find.text('08'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(CupertinoPicker).last,
        matching: find.text('00'),
      ),
      findsNothing,
    );
    expect(find.text('Jam terpilih: 09.01'), findsOneWidget);
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Jam ke-1: 09.00'));
    await tester.tap(find.text('Jam ke-1: 09.00'));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoPicker>(find.byType(CupertinoPicker).first)
        .scrollController!
        .jumpToItem(10);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(find.text('Jam ke-2: Pilih jam'), findsOneWidget);
  });

  test('interval tetap pada hari yang sama', () {
    const pertama = TimeOfDay(hour: 8, minute: 0);
    expect(hitungJamInterval(pertama, 3, 240), const [
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
    ]);
    expect(
      hitungJamInterval(const TimeOfDay(hour: 20, minute: 0), 3, 240),
      isNull,
    );
    expect(
      hitungJamInterval(const TimeOfDay(hour: 23, minute: 59), 1, 60),
      const [TimeOfDay(hour: 23, minute: 59)],
    );
  });

  test('jadwal baru mengabaikan jam yang telah lewat pada hari pembuatan', () {
    final jadwal = JadwalObat(
      nama: 'Vitamin C',
      jam: hitungJamInterval(const TimeOfDay(hour: 8, minute: 0), 3, 240)!,
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.aktif,
      tanggalMulai: DateTime(2026, 11, 26),
    );
    expect(
      jadwal.berikutnya(DateTime(2026, 11, 26, 13)),
      DateTime(2026, 11, 26, 16),
    );
    expect(
      jadwal.berikutnya(DateTime(2026, 11, 26, 16, 1)),
      DateTime(2026, 11, 27, 8),
    );
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

  testWidgets('jadwal yang diakhiri hilang dari daftar aktif', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JadwalPage(
          sekarang: DateTime(2026, 11, 26, 7),
          jadwalAwal: const [
            JadwalObat(
              nama: 'Paracetamol',
              jam: [TimeOfDay(hour: 8, minute: 0)],
              hari: {1, 2, 3, 4, 5, 6, 7},
              status: StatusJadwal.aktif,
            ),
          ],
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('Akhiri Jadwal'), 200);
    await tester.tap(find.text('Akhiri Jadwal'));
    await tester.pumpAndSettle();
    expect(find.text('Akhiri jadwal?'), findsOneWidget);

    await tester.tap(find.text('Akhiri jadwal'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada jadwal aktif'), findsOneWidget);
    expect(find.text('Edit Jadwal'), findsNothing);
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
