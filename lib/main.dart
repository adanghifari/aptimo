import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/jadwal/jadwal_page.dart';

void main() => runApp(
  const AptimoApp(tampilkanContoh: bool.fromEnvironment('APTIMO_DEMO')),
);

class AptimoApp extends StatelessWidget {
  const AptimoApp({super.key, this.tampilkanContoh = false});

  final bool tampilkanContoh;

  @override
  Widget build(BuildContext context) {
    const warnaTeks = Color(0xFF302520);
    return MaterialApp(
      title: 'APTIMO',
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F2),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFFE97638),
              surface: const Color(0xFFFFFDFA),
            ).copyWith(
              primary: const Color(0xFF91431E),
              onPrimary: Colors.white,
              onSurface: warnaTeks,
            ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: warnaTeks,
          displayColor: warnaTeks,
        ),
      ),
      home: _Beranda(tampilkanContoh: tampilkanContoh),
    );
  }
}

class _Beranda extends StatefulWidget {
  const _Beranda({required this.tampilkanContoh});

  final bool tampilkanContoh;

  @override
  State<_Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<_Beranda> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          JadwalPage(tampilkanContoh: widget.tampilkanContoh),
          const _RiwayatAwal(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: const Color(0xFFFFFDFA),
        indicatorColor: const Color(0xFFFCE3D2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class _RiwayatAwal extends StatelessWidget {
  const _RiwayatAwal();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 56,
                color: Color(0xFF91431E),
              ),
              const SizedBox(height: 18),
              Text(
                'Riwayat',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Catatan obat yang sudah dikonfirmasi akan tampil di sini '
                'setelah fitur riwayat tersedia.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
