import 'package:flutter/material.dart';

const _teks = Color(0xFF302520);
const _terakota = Color(0xFF91431E);
const _oranye = Color(0xFFE97638);
const _peach = Color(0xFFFCE3D2);
const _kartu = Color(0xFFFFFDFA);

enum StatusJadwal { aktif, nonaktif, berakhir }

class JadwalObat {
  const JadwalObat({
    required this.nama,
    required this.jam,
    required this.hari,
    required this.status,
    this.dosis,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  final String nama;
  final String? dosis;
  final List<TimeOfDay> jam;
  final Set<int> hari;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final StatusJadwal status;

  StatusJadwal statusPada(DateTime sekarang) {
    if (status == StatusJadwal.berakhir ||
        (tanggalSelesai != null &&
            DateUtils.dateOnly(
              sekarang,
            ).isAfter(DateUtils.dateOnly(tanggalSelesai!)))) {
      return StatusJadwal.berakhir;
    }
    return status;
  }

  JadwalObat denganStatus(StatusJadwal baru) => JadwalObat(
    nama: nama,
    dosis: dosis,
    jam: jam,
    hari: hari,
    tanggalMulai: tanggalMulai,
    tanggalSelesai: tanggalSelesai,
    status: baru,
  );

  DateTime? berikutnya(DateTime sekarang) {
    if (statusPada(sekarang) != StatusJadwal.aktif ||
        hari.isEmpty ||
        jam.isEmpty) {
      return null;
    }

    final hariIni = DateUtils.dateOnly(sekarang);
    final mulai = tanggalMulai == null
        ? hariIni
        : DateUtils.dateOnly(tanggalMulai!);
    final awal = mulai.isAfter(hariIni) ? mulai : hariIni;
    final akhir = tanggalSelesai == null
        ? null
        : DateUtils.dateOnly(tanggalSelesai!);

    for (var i = 0; i <= 7; i++) {
      final tanggal = DateUtils.addDaysToDate(awal, i);
      if (akhir != null && tanggal.isAfter(akhir)) break;
      if (!hari.contains(tanggal.weekday)) continue;
      final pilihan =
          jam
              .map(
                (waktu) => DateTime(
                  tanggal.year,
                  tanggal.month,
                  tanggal.day,
                  waktu.hour,
                  waktu.minute,
                ),
              )
              .where((waktu) => waktu.isAfter(sekarang))
              .toList()
            ..sort();
      if (pilihan.isNotEmpty) return pilihan.first;
    }
    return null;
  }
}

class JadwalPage extends StatefulWidget {
  const JadwalPage({
    super.key,
    this.tampilkanContoh = false,
    this.jadwalAwal,
    this.sekarang,
  });

  final bool tampilkanContoh;
  final List<JadwalObat>? jadwalAwal;
  final DateTime? sekarang;

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late List<JadwalObat> _jadwal;
  bool _lihatKosong = false;

  @override
  void initState() {
    super.initState();
    _jadwal = List.of(
      widget.jadwalAwal ??
          (widget.tampilkanContoh
              ? _contohJadwal(DateTime.now())
              : <JadwalObat>[]),
    );
  }

  void _infoTahapBerikutnya(String judul, String isi) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _kartu,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(isi, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _akhiri(int index) async {
    final obat = _jadwal[index];
    final setuju = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akhiri jadwal?'),
        content: Text(
          'Pengingat ${obat.nama} berikutnya akan dihentikan. '
          'Ini tidak mencatat obat sebagai sudah diminum.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Akhiri jadwal'),
          ),
        ],
      ),
    );
    if (setuju == true && mounted) {
      setState(() => _jadwal[index] = obat.denganStatus(StatusJadwal.berakhir));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sekarang = widget.sekarang ?? DateTime.now();
    final daftar = _lihatKosong ? <JadwalObat>[] : _jadwal;
    final urutan = List.generate(daftar.length, (index) => index)
      ..sort((a, b) {
        final status = daftar[a]
            .statusPada(sekarang)
            .index
            .compareTo(daftar[b].statusPada(sekarang).index);
        if (status != 0) return status;
        final waktuA = daftar[a].berikutnya(sekarang);
        final waktuB = daftar[b].berikutnya(sekarang);
        if (waktuA != null && waktuB != null) {
          final waktu = waktuA.compareTo(waktuB);
          if (waktu != 0) return waktu;
        }
        return daftar[a].nama.compareTo(daftar[b].nama);
      });
    final mendatang =
        daftar
            .map((obat) => (obat: obat, waktu: obat.berikutnya(sekarang)))
            .where((item) => item.waktu != null)
            .toList()
          ..sort((a, b) => a.waktu!.compareTo(b.waktu!));
    final terdekat = mendatang.isEmpty ? null : mendatang.first.waktu;
    final bersama = mendatang
        .where((item) => item.waktu == terdekat)
        .map((item) => item.obat)
        .toList();
    final berikut = mendatang
        .where((item) => item.waktu != terdekat)
        .firstOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _infoTahapBerikutnya(
          'Tambah jadwal',
          'Formulir jadwal akan tersedia pada tahap berikutnya. '
              'Pratinjau ini belum menyimpan obat atau mengaktifkan alarm.',
        ),
        backgroundColor: _terakota,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah jadwal'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 116),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 19,
                      backgroundColor: _oranye,
                      child: Icon(Icons.alarm_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'APTIMO',
                      style: TextStyle(
                        color: _terakota,
                        fontSize: 13,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton.filledTonal(
                      tooltip: 'Pengaturan',
                      onPressed: () => _infoTahapBerikutnya(
                        'Pengaturan',
                        'Pengaturan dan Coba alarm akan tersedia setelah '
                            'pengingat Android diimplementasikan.',
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Jadwal Minum Obat',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _tanggal(sekarang),
                  style: const TextStyle(
                    color: _terakota,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _PesanPratinjau(
                  tampilkanContoh: widget.tampilkanContoh,
                  lihatKosong: _lihatKosong,
                  onGanti: widget.tampilkanContoh
                      ? () => setState(() => _lihatKosong = !_lihatKosong)
                      : null,
                ),
                const SizedBox(height: 22),
                _KartuTerdekat(
                  waktu: terdekat,
                  obat: bersama,
                  berikut: berikut,
                  sekarang: sekarang,
                ),
                const SizedBox(height: 27),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Semua Jadwal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (daftar.isNotEmpty)
                      Text(
                        '${daftar.length} obat',
                        style: const TextStyle(
                          color: _terakota,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (daftar.isEmpty)
                  _Kosong(
                    onTambah: () => _infoTahapBerikutnya(
                      'Tambah jadwal',
                      'Formulir jadwal akan tersedia pada tahap berikutnya. '
                          'Pratinjau ini belum menyimpan obat atau mengaktifkan alarm.',
                    ),
                  )
                else
                  for (final index in urutan) ...[
                    _BarisJadwal(
                      obat: daftar[index],
                      berikutnya: daftar[index].berikutnya(sekarang),
                      sekarang: sekarang,
                      onPilih: (aksi) {
                        if (aksi == 'akhiri') {
                          _akhiri(index);
                        } else if (aksi == 'ubah') {
                          setState(() {
                            final status = _jadwal[index].statusPada(sekarang);
                            _jadwal[index] = _jadwal[index].denganStatus(
                              status == StatusJadwal.aktif
                                  ? StatusJadwal.nonaktif
                                  : StatusJadwal.aktif,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuTerdekat extends StatelessWidget {
  const _KartuTerdekat({
    required this.waktu,
    required this.obat,
    required this.berikut,
    required this.sekarang,
  });

  final DateTime? waktu;
  final List<JadwalObat> obat;
  final ({JadwalObat obat, DateTime? waktu})? berikut;
  final DateTime sekarang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _peach,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: _terakota),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'MINUM BERIKUTNYA',
                  style: TextStyle(
                    color: _terakota,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (waktu != null)
                Text(
                  _hariRelatif(waktu!, sekarang),
                  style: const TextStyle(
                    color: _terakota,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (waktu == null) ...[
            const SizedBox(height: 20),
            const Text(
              'Belum ada pengingat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jadwal aktif berikutnya akan terlihat di sini.',
              style: TextStyle(fontSize: 15, height: 1.4),
            ),
          ] else ...[
            const SizedBox(height: 17),
            Text(
              _formatJam(waktu!),
              style: const TextStyle(
                fontSize: 43,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 14),
            for (final item in obat) ...[
              Text(
                item.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.dosis != null)
                Text(item.dosis!, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 5),
            ],
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: _kartu.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  _jarakWaktu(waktu!, sekarang),
                  style: const TextStyle(
                    color: _terakota,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (berikut?.waktu != null) ...[
              const SizedBox(height: 17),
              const Divider(color: Color(0xFFDBB599)),
              const SizedBox(height: 6),
              Text(
                'Setelah ini: ${berikut!.obat.nama} · '
                '${_formatJam(berikut!.waktu!)} '
                '(${_hariRelatif(berikut!.waktu!, sekarang)})',
                style: const TextStyle(color: _teks, fontSize: 14),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _BarisJadwal extends StatelessWidget {
  const _BarisJadwal({
    required this.obat,
    required this.berikutnya,
    required this.sekarang,
    required this.onPilih,
  });

  final JadwalObat obat;
  final DateTime? berikutnya;
  final DateTime sekarang;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    final statusObat = obat.statusPada(sekarang);
    final aktif = statusObat == StatusJadwal.aktif;
    final belumMulai =
        aktif &&
        obat.tanggalMulai != null &&
        DateUtils.dateOnly(
          obat.tanggalMulai!,
        ).isAfter(DateUtils.dateOnly(sekarang));
    final status = switch (statusObat) {
      StatusJadwal.aktif => belumMulai ? 'Akan dimulai' : 'Aktif',
      StatusJadwal.nonaktif => 'Nonaktif',
      StatusJadwal.berakhir => 'Berakhir',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 6, 16),
      decoration: BoxDecoration(
        color: _kartu,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E2D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  berikutnya == null ? '—' : _formatJam(berikutnya!),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: aktif ? _terakota : const Color(0xFF6F635D),
                  ),
                ),
                Text(
                  berikutnya == null
                      ? 'Tanpa alarm'
                      : _hariRelatif(berikutnya!, sekarang),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF645A53),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 52,
            margin: const EdgeInsets.only(right: 12),
            color: aktif ? _oranye : const Color(0xFFDDD0C6),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obat.nama,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (obat.dosis != null)
                  Text(obat.dosis!, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 7),
                Text(
                  '${obat.jam.length} kali sehari · ${_ringkasanHari(obat.hari)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF645A53),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Jam: ${obat.jam.map(_formatWaktu).join(', ')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF645A53),
                  ),
                ),
                if (obat.tanggalSelesai != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Sampai ${_tanggal(obat.tanggalSelesai!)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF645A53),
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: aktif ? _peach : const Color(0xFFF2EEEA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: aktif ? _terakota : _teks,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (statusObat != StatusJadwal.berakhir)
            PopupMenuButton<String>(
              tooltip: 'Opsi jadwal ${obat.nama}',
              onSelected: onPilih,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'ubah',
                  child: Text(aktif ? 'Nonaktifkan' : 'Aktifkan kembali'),
                ),
                const PopupMenuItem(
                  value: 'akhiri',
                  child: Text('Akhiri jadwal'),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded, color: _terakota),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _Kosong extends StatelessWidget {
  const _Kosong({required this.onTambah});

  final VoidCallback onTambah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _kartu,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E2D8)),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication_outlined, size: 44, color: _terakota),
          const SizedBox(height: 16),
          const Text(
            'Belum ada jadwal obat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jadwal yang Anda tambahkan akan tersusun di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onTambah,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah jadwal'),
          ),
        ],
      ),
    );
  }
}

class _PesanPratinjau extends StatelessWidget {
  const _PesanPratinjau({
    required this.tampilkanContoh,
    required this.lihatKosong,
    required this.onGanti,
  });

  final bool tampilkanContoh;
  final bool lihatKosong;
  final VoidCallback? onGanti;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2C6B3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pratinjau tampilan · Alarm belum aktif',
            style: TextStyle(color: _terakota, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Jadwal pada tahap ini belum tersimpan dan belum menghasilkan pengingat.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          if (tampilkanContoh) ...[
            const SizedBox(height: 7),
            TextButton(
              onPressed: onGanti,
              child: Text(
                lihatKosong ? 'Lihat jadwal contoh' : 'Lihat keadaan kosong',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<JadwalObat> _contohJadwal(DateTime sekarang) {
  final kemarin = DateUtils.addDaysToDate(sekarang, -1);
  return [
    JadwalObat(
      nama: 'Paracetamol',
      dosis: '1 tablet',
      jam: const [
        TimeOfDay(hour: 8, minute: 0),
        TimeOfDay(hour: 20, minute: 0),
      ],
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.aktif,
      tanggalMulai: kemarin,
    ),
    JadwalObat(
      nama: 'Vitamin C',
      dosis: '1 tablet',
      jam: const [TimeOfDay(hour: 12, minute: 0)],
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.aktif,
    ),
    JadwalObat(
      nama: 'Obat batuk',
      jam: const [TimeOfDay(hour: 9, minute: 0)],
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.nonaktif,
    ),
    JadwalObat(
      nama: 'Obat sementara',
      jam: const [TimeOfDay(hour: 18, minute: 0)],
      hari: const {1, 2, 3, 4, 5, 6, 7},
      status: StatusJadwal.berakhir,
      tanggalSelesai: kemarin,
    ),
  ];
}

String _formatWaktu(TimeOfDay waktu) =>
    '${waktu.hour.toString().padLeft(2, '0')}.${waktu.minute.toString().padLeft(2, '0')}';

String _formatJam(DateTime waktu) =>
    _formatWaktu(TimeOfDay.fromDateTime(waktu));

String _hariRelatif(DateTime waktu, DateTime sekarang) {
  final selisih = DateUtils.dateOnly(
    waktu,
  ).difference(DateUtils.dateOnly(sekarang)).inDays;
  if (selisih == 0) return 'Hari ini';
  if (selisih == 1) return 'Besok';
  return '${_namaHari(waktu.weekday)}, ${waktu.day} ${_namaBulan(waktu.month)}';
}

String _jarakWaktu(DateTime waktu, DateTime sekarang) {
  final menit = (waktu.difference(sekarang).inSeconds / 60).ceil();
  if (menit <= 1) return 'Kurang dari 1 menit';
  if (menit < 60) return 'Dalam $menit menit';
  final jam = menit ~/ 60;
  final sisa = menit % 60;
  return sisa == 0 ? 'Dalam $jam jam' : 'Dalam $jam jam $sisa menit';
}

String _tanggal(DateTime waktu) =>
    '${_namaHari(waktu.weekday)}, ${waktu.day} ${_namaBulan(waktu.month)} ${waktu.year}';

String _namaHari(int hari) => const [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
][hari - 1];

String _namaBulan(int bulan) => const [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
][bulan - 1];

String _ringkasanHari(Set<int> hari) {
  if (hari.length == 7) return 'Setiap hari';
  final urut = hari.toList()..sort();
  return urut.map(_namaHari).join(', ');
}
