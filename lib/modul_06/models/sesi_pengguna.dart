class SesiPengguna {
  final String token;
  final String email;
  final String nama;
  final String peran;
  final String masukPada;
  final String kedaluwarsaPada;

  const SesiPengguna({
    required this.token,
    required this.email,
    required this.nama,
    required this.peran,
    required this.masukPada,
    required this.kedaluwarsaPada,
  });

  factory SesiPengguna.fromJson(Map<String, dynamic> json) {
    return SesiPengguna(
      token: json['token'] as String? ?? '',
      email: json['email'] as String? ?? 'tanpa-email',
      nama: json['nama'] as String? ?? 'Pengguna',
      peran: json['peran'] as String? ?? 'mahasiswa',
      masukPada: json['masukPada'] as String? ?? '1970-01-01T00:00:00.000',
      kedaluwarsaPada:
          json['kedaluwarsaPada'] as String? ?? '1970-01-01T00:00:00.000',
    );
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
    'token': token,
    'email': email,
    'nama': nama,
    'peran': peran,
    'masukPada': masukPada,
    'kedaluwarsaPada': kedaluwarsaPada,
  };

  /// Sisa masa berlaku - ditambahkan di beranda.
  Duration sisaWaktu(DateTime sekarang) {
    final DateTime? batas = DateTime.tryParse(kedaluwarsaPada);
    if (batas == null) return Duration.zero;
    final Duration sisa = batas.difference(sekarang);
    return sisa.isNegative ? Duration.zero : sisa;
  }
  /// Metode copWith ini adalah pola yan umum di gunakan dan penting di dart/flutter
  /// Terutama kalau kelas model data kamu bersifat immutable (semua propertinya di-set final).
  /// Fungsi ini digunakan untuk membuat salinan (copy) dari objek SesiPengguna yang sudah ada, 
  /// tapi dengan opsi mengubah beberapa nilai tertentu saja tanpa merusak data lainnya
  SesiPengguna copyWith({
    String? token,
    String? email,
    String? nama,
    String? peran,
    String? masukPada,
    String? kedaluwarsaPada,
  }) {
  /// token: token ?? this.token berarti: kalau parameter token yang baru diisi (tidak null), 
  /// gunakan nilai baru tersebut; tapi kalau dikosongkan (null), 
  /// pertahankan nilai token yang lama (this.token)
    return SesiPengguna(
      token: token ?? this.token,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      peran: peran ?? this.peran,
      masukPada: masukPada ?? this.masukPada,
      kedaluwarsaPada: kedaluwarsaPada ?? this.kedaluwarsaPada,
    );
  }

  /// Label peran yang enak dibaca manusia.
  /// Fungsi ini menganndalkan parameter peran seagai penampung data input
  /// serta menggunakan nilai literal string ('Dosen', 'Mahasiswa', dan 'Pengguna') 
  /// sebagai hasil keluaran (return values).
  static String labelPeran(String peran) {
    switch (peran) {
      case 'dosen':
        return 'Dosen';
      case 'mahasiswa':
        return 'Mahasiswa';
      default:
        return 'Pengguna';
    }
  }
  bool sudahKedaluwarsa(DateTime sekarang) {
  final DateTime? batas = DateTime.tryParse(kedaluwarsaPada);
  if (batas == null) return true; // Tanggal rusak = anggap kedaluwarsa.
  return !sekarang.isBefore(batas);
}

/// Versi praktis untuk dipakai di UI (beranda).
bool get kedaluwarsa => sudahKedaluwarsa(DateTime.now());

/// Sesi contoh — dipakai pengujian dan mode simulasi.
static SesiPengguna contoh({
  String token = 'dummy-token-fase-a',
  String email = 'student@trpl.test',
  String nama = 'Mahasiswa TRPL',
  String peran = 'mahasiswa',
  Duration masaBerlaku = const Duration(hours: 2),
  DateTime? sekarang,
}) {
  final DateTime mulai = sekarang ?? DateTime(2026, 9, 21, 8, 0);
  return SesiPengguna(
    token: token,
    email: email,
    nama: nama,
    peran: peran,
    masukPada: mulai.toIso8601String(),
    kedaluwarsaPada: mulai.add(masaBerlaku).toIso8601String(),
  );
}

@override
String toString() =>
    'SesiPengguna(email: $email, peran: $peran, '
    'kedaluwarsaPada: $kedaluwarsaPada)';
}
