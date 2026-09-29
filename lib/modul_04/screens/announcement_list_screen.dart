import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

  /// Dapat disuntikkan dari luar (widget test atau demo offline).
  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  // ERROR: properti state seperti _api, _futurePengumuman, dan _kategoriTerpilih
  // harus dideklarasikan di sini. Kalau tidak, kode di bawahnya akan error karena
  // variabel belum ada ketika method dipanggil.
  late final AnnouncementApi _api;
  late Future<List<Announcement>> _futurePengumuman;
  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AnnouncementApi(modeSimulasi: true);
    _futurePengumuman = _api.ambilPengumuman();
  }

  Future<void> _muatUlang() async {
    // ERROR: method ini pernah dibuat berulang di dalam dirinya sendiri.
    // Ini adalah hasil copy-paste yang salah karena blok method tertanam di dalam
    // method yang sama. Akibatnya, struktur class rusak dan kode tidak valid.
    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();
    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error akan ditangani oleh FutureBuilder melalui snapshot.hasError.
      // Catch ini hanya untuk mencegah unhandled exception saat refresh.
    }
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) return;
    setState(() => _kategoriTerpilih = kategori);
  }

  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  List<Announcement> _filterPengumuman(List<Announcement> daftar) {
    if (_kategoriTerpilih == 'Semua') {
      return daftar;
    }

    return daftar
        .where((Announcement item) => item.category == _kategoriTerpilih)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ERROR: StatefulWidget wajib punya build(). Tanpa method ini, layar tidak tahu
    // cara merender UI ke layar, sehingga list tidak tampil.
    return Scaffold(
      appBar: AppBar(title: const Text('Pengumuman'), centerTitle: true),
      body: FutureBuilder<List<Announcement>>(
        future: _futurePengumuman,
        builder:
            (BuildContext context, AsyncSnapshot<List<Announcement>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Gagal memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final List<Announcement> data = snapshot.data ?? <Announcement>[];
              final List<Announcement> dataTampil = _filterPengumuman(data);

              return RefreshIndicator(
                onRefresh: _muatUlang,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: _kategori.length,
                        separatorBuilder: (BuildContext context, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (BuildContext context, int index) {
                          final String kategori = _kategori[index];
                          final bool dipilih = _kategoriTerpilih == kategori;
                          return ChoiceChip(
                            label: Text(kategori),
                            selected: dipilih,
                            onSelected: (_) => _pilihKategori(kategori),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: dataTampil.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada pengumuman untuk kategori ini.',
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: dataTampil.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Announcement item = dataTampil[index];
                                return AnnouncementCard(
                                  announcement: item,
                                  onTap: () => _bukaDetail(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
      ),
    );
  }
}
