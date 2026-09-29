class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.date,
    required this.readCount,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String date;
  final int readCount;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? 'Tanpa Judul',
      content: json['content'] as String? ?? json['body'] as String? ?? '',
      author: json['author'] as String? ?? 'Admin Jurusan',
      category: json['category'] as String? ?? 'Akademik',
      date: json['date'] as String? ?? '2026-09-01',
      readCount: json['readCount'] is int ? json['readCount'] as int : 0,
    );
  }

  static List<Announcement> getSampleAnnouncements() {
    return <Announcement>[
      const Announcement(
        id: 1,
        title: 'Pendaftaran Semester Genap 2026',
        content: 'Mahasiswa diharapkan segera melakukan pendaftaran semester genap melalui portal akademik sebelum batas akhir.',
        author: 'Bagian Akademik',
        category: 'Akademik',
        date: '2026-09-23',
        readCount: 420,
      ),
      const Announcement(
        id: 2,
        title: 'Beasiswa Prestasi Mahasiswa',
        content: 'Pendaftaran beasiswa prestasi dibuka untuk mahasiswa dengan IPK minimal 3.50 dan aktif berorganisasi.',
        author: 'Divisi Beasiswa',
        category: 'Beasiswa',
        date: '2026-09-22',
        readCount: 350,
      ),
      const Announcement(
        id: 3,
        title: 'Lomba Desa Wisata Kampus',
        content: 'Mahasiswa dari semua program studi dipersilakan mengikuti lomba inovasi digital desa wisata yang diselenggarakan kampus.',
        author: 'Panitia Kegiatan',
        category: 'Kegiatan',
        date: '2026-09-21',
        readCount: 280,
      ),
      const Announcement(
        id: 4,
        title: 'Juara Kompetisi Robotik Nasional',
        content: 'Tim robotik Poliwangi berhasil meraih juara 1 kompetisi nasional dan mendapatkan apresiasi dari pihak kampus.',
        author: 'Kepala Lab',
        category: 'Prestasi',
        date: '2026-09-20',
        readCount: 515,
      ),
    ];
  }
}
