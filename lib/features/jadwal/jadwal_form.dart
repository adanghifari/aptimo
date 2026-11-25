import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _cokelat = Color(0xFF302520);
const _terakota = Color(0xFF91431E);
const _peach = Color(0xFFFCE3D2);
const _putih = Color(0xFFFFFDFA);

enum ModeJam { sendiri, interval }

class JadwalFormData {
  const JadwalFormData({
    required this.nama,
    required this.jam,
    required this.hari,
    required this.tanggalMulai,
    this.dosis,
    this.catatan,
    this.tanggalSelesai,
  });

  final String nama;
  final String? dosis;
  final String? catatan;
  final List<TimeOfDay> jam;
  final Set<int> hari;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
}

Future<JadwalFormData?> tampilkanFormTambahJadwal(BuildContext context) {
  return showDialog<JadwalFormData>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x880F0805),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: const _FormJadwal(),
    ),
  );
}

class _FormJadwal extends StatefulWidget {
  const _FormJadwal();

  @override
  State<_FormJadwal> createState() => _FormJadwalState();
}

class _FormJadwalState extends State<_FormJadwal> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _jumlah = TextEditingController();
  final _nama = TextEditingController();
  final _dosis = TextEditingController();
  final _catatan = TextEditingController();
  final _jarakJam = TextEditingController(text: '0');
  final _jarakMenit = TextEditingController(text: '0');
  final _jam = <TimeOfDay?>[null];
  final _hariTertentu = <int>{};
  late DateTime _mulai = DateUtils.dateOnly(DateTime.now());
  DateTime? _selesai;
  ModeJam? _mode;
  bool _setiapHari = true;
  bool _validasi = false;
  String? _pesan;

  int? get _frekuensi {
    final nilai = int.tryParse(_jumlah.text.trim());
    return nilai != null && nilai > 0 ? nilai : null;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _jumlah.dispose();
    _nama.dispose();
    _dosis.dispose();
    _catatan.dispose();
    _jarakJam.dispose();
    _jarakMenit.dispose();
    super.dispose();
  }

  void _ubahJumlah(String _) {
    final jumlah = _frekuensi;
    setState(() {
      if (jumlah != null) {
        if (jumlah < _jam.length) {
          _jam.removeRange(jumlah, _jam.length);
        } else {
          _jam.addAll(List<TimeOfDay?>.filled(jumlah - _jam.length, null));
        }
      }
      _pesan = null;
    });
  }

  Future<void> _pilihJam(int index) async {
    final sebelumnya = index > 0 && _mode == ModeJam.sendiri
        ? _jam[index - 1]
        : null;
    if (index > 0 && _mode == ModeJam.sendiri && sebelumnya == null) return;
    final minimalMenit = sebelumnya == null ? 0 : _menit(sebelumnya) + 1;
    if (minimalMenit > 1439) return;
    final pilihan = await showDialog<TimeOfDay>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PemilihJam(
        awal: _jam[index] ?? const TimeOfDay(hour: 8, minute: 0),
        judul: _labelJam(index),
        minimalMenit: minimalMenit,
      ),
    );
    if (pilihan != null && mounted) {
      setState(() {
        _jam[index] = pilihan;
        if (_mode == ModeJam.sendiri) {
          for (var i = index + 1; i < _jam.length; i++) {
            if (_jam[i - 1] == null ||
                (_jam[i] != null && _menit(_jam[i]!) <= _menit(_jam[i - 1]!))) {
              _jam[i] = null;
            }
          }
        }
        _pesan = null;
      });
    }
  }

  Future<void> _pilihTanggal({required bool akhir}) async {
    final pilihan = await showDatePicker(
      context: context,
      initialDate: akhir ? (_selesai ?? _mulai) : _mulai,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: akhir ? 'Tanggal selesai' : 'Tanggal mulai',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      fieldLabelText: 'Tanggal',
    );
    if (pilihan != null && mounted) {
      setState(() {
        if (akhir) {
          _selesai = pilihan;
        } else {
          _mulai = pilihan;
        }
        _pesan = null;
      });
    }
  }

  int? get _intervalMenit {
    final jam = int.tryParse(_jarakJam.text.trim());
    final menit = int.tryParse(_jarakMenit.text.trim());
    if (jam == null || menit == null || jam < 0 || menit < 0 || menit > 59) {
      return null;
    }
    final total = jam * 60 + menit;
    return total > 0 ? total : null;
  }

  List<TimeOfDay>? get _jamHasil {
    final jumlah = _frekuensi;
    if (jumlah == null || _jam.first == null) return null;
    if (jumlah == 1) return [_jam.first!];
    if (_mode == ModeJam.sendiri) {
      if (_jam.length < jumlah || _jam.take(jumlah).any((jam) => jam == null)) {
        return null;
      }
      final waktu = _jam.take(jumlah).cast<TimeOfDay>().toList();
      for (var i = 1; i < waktu.length; i++) {
        if (_menit(waktu[i]) <= _menit(waktu[i - 1])) return null;
      }
      return waktu;
    }
    if (_mode == ModeJam.interval && _intervalMenit != null) {
      return hitungJamInterval(_jam.first!, jumlah, _intervalMenit!);
    }
    return null;
  }

  String? get _kesalahanInterval {
    if (_frekuensi == null ||
        _frekuensi! <= 1 ||
        _mode != ModeJam.interval ||
        _jam.first == null ||
        _intervalMenit == null) {
      return null;
    }
    if (_menit(_jam.first!) + (_frekuensi! - 1) * _intervalMenit! > 1439) {
      return 'Jam ke-${_frekuensi!} melewati 23.59. Kurangi jarak atau pilih Jam ke-1 yang lebih awal.';
    }
    return null;
  }

  bool get _adaJamLewatHariIni {
    final sekarang = DateTime.now();
    if (_mulai.isAfter(DateUtils.dateOnly(sekarang))) return false;
    return _jamHasil?.any(
          (jam) => _menit(jam) <= _menit(TimeOfDay.fromDateTime(sekarang)),
        ) ??
        false;
  }

  String? get _kesalahanTanggal {
    if (_selesai == null) return null;
    if (_selesai!.isBefore(_mulai)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }
    if (_selesai!.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      return 'Tanggal selesai sudah lewat. Pilih hari ini atau setelahnya.';
    }
    return null;
  }

  void _simpan() {
    setState(() => _validasi = true);
    final isianValid = _formKey.currentState?.validate() ?? false;
    final namaValid = _nama.text.trim().isNotEmpty;
    final hasil = _jamHasil;
    final hariValid = _setiapHari || _hariTertentu.isNotEmpty;
    final tanggalValid = _kesalahanTanggal == null;
    if (!isianValid ||
        !namaValid ||
        hasil == null ||
        !hariValid ||
        !tanggalValid) {
      setState(() {
        _pesan =
            _kesalahanInterval ??
            (hasil == null
                ? 'Periksa jumlah dan jam minum di bagian atas.'
                : !namaValid
                ? 'Nama obat perlu diisi sebelum jadwal ditambahkan.'
                : !hariValid
                ? 'Pilih sedikitnya satu hari yang berlaku.'
                : !tanggalValid
                ? _kesalahanTanggal!
                : 'Periksa isian yang ditandai sebelum menambahkan jadwal.');
      });
      _scroll.animateTo(
        hasil == null
            ? 0
            : !namaValid
            ? _scroll.position.maxScrollExtent * 0.5
            : _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }

    Navigator.of(context).pop(
      JadwalFormData(
        nama: _nama.text.trim(),
        dosis: _opsional(_dosis.text),
        catatan: _opsional(_catatan.text),
        jam: hasil,
        hari: _setiapHari ? {1, 2, 3, 4, 5, 6, 7} : Set.of(_hariTertentu),
        tanggalMulai: _mulai,
        tanggalSelesai: _selesai,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jumlah = _frekuensi;
    final layar = MediaQuery.sizeOf(context);
    final tinggi = math.min(
      720.0,
      layar.height - MediaQuery.viewInsetsOf(context).bottom - 48,
    );
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: _putih,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SizedBox(
        width: math.min(520, layar.width - 32),
        height: tinggi,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tambah jadwal',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: _cokelat,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup formulir',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
                  children: [
                    const Text(
                      'Isi sesuai aturan obat Anda. Jadwal dapat diperiksa sebelum ditambahkan.',
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    _judulBagian('Frekuensi minum'),
                    const SizedBox(height: 10),
                    TextFormField(
                      key: const ValueKey('jumlahMinum'),
                      controller: _jumlah,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Berapa kali sehari?',
                        hintText: 'Contoh: 3',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _ubahJumlah,
                      validator: (_) => _frekuensi == null
                          ? 'Isi dengan angka minimal 1.'
                          : null,
                    ),
                    if (jumlah != null) ...[
                      const SizedBox(height: 24),
                      if (jumlah == 1) ...[
                        _judulBagian('Jam minum'),
                        const SizedBox(height: 10),
                        _tombolJam(0),
                      ] else ...[
                        _judulBagian('Cara mengatur jam'),
                        const SizedBox(height: 7),
                        const Text(
                          'Pilih cara yang sesuai dengan aturan obat Anda.',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            _pilihanMode(ModeJam.sendiri, 'Atur sendiri'),
                            _pilihanMode(ModeJam.interval, 'Interval'),
                          ],
                        ),
                        if (_validasi && _mode == null)
                          _error('Pilih salah satu cara mengatur jam.'),
                        if (_mode != null) ...[
                          const SizedBox(height: 22),
                          _judulBagian('Jam minum'),
                        ],
                        if (_mode == ModeJam.sendiri) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Pilih setiap jam sesuai urutan dalam satu hari.',
                            ),
                          ),
                          _tombolJam(0),
                          const SizedBox(height: 10),
                          for (var i = 1; i < jumlah; i++) ...[
                            _tombolJam(i),
                            const SizedBox(height: 10),
                          ],
                        ],
                        if (_mode == ModeJam.interval) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Pilih Jam ke-1, lalu isi jarak antarjam. Jam berikutnya akan dihitung otomatis.',
                            ),
                          ),
                          _tombolJam(0),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _isianInterval(_jarakJam, 'Jarak (jam)'),
                              const SizedBox(height: 10),
                              _isianInterval(_jarakMenit, 'Jarak (menit)'),
                            ],
                          ),
                          if (_validasi && _intervalMenit == null)
                            _error(
                              'Isi jarak lebih dari nol. Menit harus 0 sampai 59.',
                            ),
                          if (_kesalahanInterval != null)
                            _error(_kesalahanInterval!),
                        ],
                      ],
                      if (_jamHasil != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _peach,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Jam yang akan dijadwalkan: ${_jamHasil!.map(_formatJam).join(', ')}',
                            style: const TextStyle(
                              color: _terakota,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (_adaJamLewatHariIni) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Jam yang sudah lewat hari ini tidak dihitung. Pada hari aktif berikutnya, jadwal dimulai lagi dari Jam ke-1.',
                            style: TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ],
                      ],
                      const SizedBox(height: 24),
                      _judulBagian('Obat'),
                      const SizedBox(height: 10),
                      TextFormField(
                        key: const ValueKey('namaObat'),
                        controller: _nama,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Nama obat',
                          hintText: 'Contoh: Paracetamol',
                          border: OutlineInputBorder(),
                        ),
                        validator: (nilai) => (nilai?.trim().isEmpty ?? true)
                            ? 'Nama obat perlu diisi.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dosis,
                        decoration: const InputDecoration(
                          labelText: 'Dosis (opsional)',
                          hintText: 'Contoh: 1 tablet',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _catatan,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          hintText: 'Contoh: setelah makan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _judulBagian('Hari berlaku'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Setiap hari'),
                            selected: _setiapHari,
                            onSelected: (_) =>
                                setState(() => _setiapHari = true),
                          ),
                          ChoiceChip(
                            label: const Text('Hari tertentu'),
                            selected: !_setiapHari,
                            onSelected: (_) =>
                                setState(() => _setiapHari = false),
                          ),
                        ],
                      ),
                      if (!_setiapHari) ...[
                        const Text(
                          'Pilih hari yang berlaku:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          children: [
                            for (var i = 1; i <= 7; i++)
                              FilterChip(
                                label: Text(
                                  const [
                                    'Senin',
                                    'Selasa',
                                    'Rabu',
                                    'Kamis',
                                    'Jumat',
                                    'Sabtu',
                                    'Minggu',
                                  ][i - 1],
                                ),
                                selected: _hariTertentu.contains(i),
                                onSelected: (pilih) => setState(() {
                                  if (pilih) {
                                    _hariTertentu.add(i);
                                  } else {
                                    _hariTertentu.remove(i);
                                  }
                                }),
                              ),
                          ],
                        ),
                        if (_validasi && _hariTertentu.isEmpty)
                          _error('Pilih sedikitnya satu hari.'),
                      ],
                      const SizedBox(height: 24),
                      _judulBagian('Periode minum obat'),
                      const SizedBox(height: 10),
                      _tombolTanggal(
                        'Tanggal mulai',
                        _mulai,
                        () => _pilihTanggal(akhir: false),
                      ),
                      const SizedBox(height: 10),
                      if (_selesai == null)
                        OutlinedButton.icon(
                          onPressed: () => _pilihTanggal(akhir: true),
                          icon: const Icon(Icons.event_outlined),
                          label: const Text('Tambah tanggal selesai'),
                          style: _gayaPilihan,
                        )
                      else ...[
                        _tombolTanggal(
                          'Tanggal selesai',
                          _selesai!,
                          () => _pilihTanggal(akhir: true),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selesai = null),
                          child: const Text('Hapus tanggal selesai'),
                        ),
                      ],
                      if (_validasi && _kesalahanTanggal != null)
                        _error(_kesalahanTanggal!),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_pesan != null) ...[
                    Text(
                      _pesan!,
                      style: const TextStyle(color: Color(0xFF9C3124)),
                    ),
                    const SizedBox(height: 6),
                  ],
                  const Text(
                    'Pratinjau: alarm belum aktif dan jadwal belum tersimpan permanen.',
                    style: TextStyle(fontSize: 13, color: _cokelat),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _simpan,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Tambahkan jadwal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _judulBagian(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: _cokelat,
    ),
  );

  Widget _error(String pesan) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      pesan,
      style: const TextStyle(fontSize: 13, color: Color(0xFF9C3124)),
    ),
  );

  Widget _pilihanMode(ModeJam mode, String label) => ChoiceChip(
    label: Text(label),
    selected: _mode == mode,
    onSelected: (_) => setState(() {
      _mode = mode;
      _pesan = null;
    }),
  );

  Widget _tombolJam(int index) {
    final label = _labelJam(index);
    final terpilih = _jam[index];
    final sebelumnya = index > 0 && _mode == ModeJam.sendiri
        ? _jam[index - 1]
        : null;
    final menungguSebelumnya =
        index > 0 && _mode == ModeJam.sendiri && sebelumnya == null;
    final tidakAdaSisaJam = sebelumnya != null && _menit(sebelumnya) == 1439;
    final keliru =
        terpilih != null &&
        sebelumnya != null &&
        _menit(terpilih) <= _menit(sebelumnya);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: menungguSebelumnya || tidakAdaSisaJam
              ? null
              : () => _pilihJam(index),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size.fromHeight(60),
            foregroundColor: _terakota,
            backgroundColor: terpilih == null ? null : _peach,
            side: BorderSide(
              color: terpilih == null ? const Color(0xFFD7AC90) : _terakota,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                terpilih == null
                    ? Icons.access_time_rounded
                    : Icons.check_circle_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$label: ${terpilih == null ? 'Pilih jam' : _formatJam(terpilih)}',
                      style: TextStyle(
                        fontWeight: terpilih == null
                            ? FontWeight.w500
                            : FontWeight.w700,
                        fontSize: terpilih == null ? 15 : 17,
                      ),
                    ),
                    if (terpilih != null)
                      const Text(
                        'Sudah dipilih · Ketuk untuk ubah',
                        style: TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (menungguSebelumnya)
          _error('Pilih ${_labelJam(index - 1)} lebih dulu.'),
        if (tidakAdaSisaJam)
          _error(
            'Tidak ada waktu setelah 23.59. Ubah ${_labelJam(index - 1)}.',
          ),
        if (_validasi &&
            terpilih == null &&
            !menungguSebelumnya &&
            !tidakAdaSisaJam)
          _error('$label perlu dipilih.'),
        if (keliru) _error('$label harus setelah jam sebelumnya.'),
      ],
    );
  }

  Widget _isianInterval(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() => _pesan = null),
      );

  Widget _tombolTanggal(String label, DateTime tanggal, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(
          '$label: ${tanggal.day} ${_bulan[tanggal.month - 1]} ${tanggal.year}',
        ),
        style: _gayaPilihan,
      );

  ButtonStyle get _gayaPilihan => OutlinedButton.styleFrom(
    alignment: Alignment.centerLeft,
    minimumSize: const Size.fromHeight(52),
    foregroundColor: _terakota,
    side: const BorderSide(color: Color(0xFFD7AC90)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

class _PemilihJam extends StatefulWidget {
  const _PemilihJam({
    required this.awal,
    required this.judul,
    required this.minimalMenit,
  });

  final TimeOfDay awal;
  final String judul;
  final int minimalMenit;

  @override
  State<_PemilihJam> createState() => _PemilihJamState();
}

class _PemilihJamState extends State<_PemilihJam> {
  late final int _minimalJam = widget.minimalMenit ~/ 60;
  late int _jam = math.max(widget.awal.hour, _minimalJam);
  late int _menit = _jam == widget.awal.hour
      ? math.max(widget.awal.minute, _menitPertama(_jam))
      : _menitPertama(_jam);

  int _menitPertama(int jam) =>
      jam == _minimalJam ? widget.minimalMenit % 60 : 0;

  @override
  Widget build(BuildContext context) {
    final lebar = math.max(
      120.0,
      math.min(320.0, MediaQuery.sizeOf(context).width - 128),
    );
    return AlertDialog(
      backgroundColor: _putih,
      title: Text(widget.judul),
      content: SizedBox(
        width: lebar,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.minimalMenit == 0
                  ? 'Geser angka untuk memilih waktu.'
                  : '${widget.judul} harus setelah jam sebelumnya.',
              style: const TextStyle(fontSize: 15, color: _cokelat),
            ),
            if (widget.minimalMenit > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Pilihan mulai ${_formatJam(TimeOfDay(hour: widget.minimalMenit ~/ 60, minute: widget.minimalMenit % 60))}.',
                style: const TextStyle(fontSize: 14, color: _terakota),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _KolomAngka(
                    label: 'Jam',
                    mulai: _minimalJam,
                    jumlah: 24 - _minimalJam,
                    awal: _jam,
                    onPilih: (nilai) => setState(() {
                      _jam = nilai;
                      _menit = math.max(_menit, _menitPertama(nilai));
                    }),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _KolomAngka(
                    key: ValueKey('menit-$_jam'),
                    label: 'Menit',
                    mulai: _menitPertama(_jam),
                    jumlah: 60 - _menitPertama(_jam),
                    awal: _menit,
                    onPilih: (nilai) => setState(() => _menit = nilai),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Jam terpilih: ${_formatJam(TimeOfDay(hour: _jam, minute: _menit))}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _terakota,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(TimeOfDay(hour: _jam, minute: _menit)),
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}

class _KolomAngka extends StatefulWidget {
  const _KolomAngka({
    super.key,
    required this.label,
    required this.mulai,
    required this.jumlah,
    required this.awal,
    required this.onPilih,
  });

  final String label;
  final int mulai;
  final int jumlah;
  final int awal;
  final ValueChanged<int> onPilih;

  @override
  State<_KolomAngka> createState() => _KolomAngkaState();
}

class _KolomAngkaState extends State<_KolomAngka> {
  late final _penggulung = FixedExtentScrollController(
    initialItem: widget.awal - widget.mulai,
  );

  @override
  void dispose() {
    _penggulung.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 190,
          child: CupertinoPicker(
            scrollController: _penggulung,
            itemExtent: 52,
            useMagnifier: true,
            magnification: 1.08,
            selectionOverlay: DecoratedBox(
              decoration: BoxDecoration(
                color: _peach.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onSelectedItemChanged: (index) =>
                widget.onPilih(widget.mulai + index),
            children: [
              for (
                var nilai = widget.mulai;
                nilai < widget.mulai + widget.jumlah;
                nilai++
              )
                Center(
                  child: Text(
                    nilai.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 25, color: _cokelat),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

int _menit(TimeOfDay jam) => jam.hour * 60 + jam.minute;

String _labelJam(int index) => 'Jam ke-${index + 1}';

List<TimeOfDay>? hitungJamInterval(
  TimeOfDay pertama,
  int jumlah,
  int jarakMenit,
) {
  if (jumlah < 1 ||
      jarakMenit <= 0 ||
      _menit(pertama) + (jumlah - 1) * jarakMenit > 1439) {
    return null;
  }
  return List.generate(jumlah, (index) {
    final nilai = _menit(pertama) + index * jarakMenit;
    return TimeOfDay(hour: nilai ~/ 60, minute: nilai % 60);
  });
}

String _formatJam(TimeOfDay jam) =>
    '${jam.hour.toString().padLeft(2, '0')}.${jam.minute.toString().padLeft(2, '0')}';

String? _opsional(String teks) => teks.trim().isEmpty ? null : teks.trim();

const _bulan = [
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
];
