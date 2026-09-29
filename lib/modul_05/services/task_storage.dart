import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  static const String kunciTugas = 'modul_05__tuas';
  static const String kunciVersi = 'modul_05_versi_skema';
  static const String kunciWaktuTerakhirDisimpan = 'modul_05__last_saved_at';
  static const String kunciJumlahTulisanTerakhir = 'modul_05__last_write_count';
  static const String kunciTotalTulisan = 'modul_05__total_write_count';
  static const String kunciCadanganDataRusak = 'modul_05__backup_invalid_json';
  static const String kunciPemberitahuanCadangan =
      'modul_05__last_recovery_message';
  static const int versiSkema = 1;

  final Duration tunda;
  const TaskStorage({this.tunda = Duration.zero});

  Future<Map<String, dynamic>> metadata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return <String, dynamic>{
      'lastSavedAt': prefs.getString(kunciWaktuTerakhirDisimpan),
      'lastWriteCount': prefs.getInt(kunciJumlahTulisanTerakhir) ?? 0,
      'totalWriteCount': prefs.getInt(kunciTotalTulisan) ?? 0,
      'lastRecoveryMessage': prefs.getString(kunciPemberitahuanCadangan),
    };
  }

  Future<List<Task>> muat() async {
    if (tunda > Duration.zero) {
      await Future<void>.delayed(tunda);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mentah = prefs.getString(kunciTugas);

    if (mentah == null) {
      return List<Task>.of(Task.getSampleTasks());
    }

    final List<dynamic> baris;
    try {
      baris = jsonDecode(mentah) as List<dynamic>;
    } on FormatException {
      await prefs.setString(kunciCadanganDataRusak, mentah);
      await prefs.setString(
        kunciPemberitahuanCadangan,
        'Cadangan data rusak telah dibuat.',
      );
      return const <Task>[];
    } on TypeError {
      await prefs.setString(kunciCadanganDataRusak, mentah);
      await prefs.setString(
        kunciPemberitahuanCadangan,
        'Data rusak telah disimpan sebagai cadangan.',
      );
      return const <Task>[];
    }

    await prefs.remove(kunciPemberitahuanCadangan);
    return List<Task>.generate(
      baris.length,
      (int i) => Task.fromJson(baris[i] as Map<String, dynamic>),
      growable: true,
    );
  }

  Future<void> simpan(List<Task> tugas) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mentah = jsonEncode(
      tugas.map((Task t) => t.toJson()).toList(growable: false),
    );

    final bool berhasil = await prefs.setString(kunciTugas, mentah);
    if (!berhasil) {
      throw Exception('Penyimpanan perangkat menolak penulisan data tugas.');
    }

    final DateTime sekarang = DateTime.now();
    final int jumlahTulisan = tugas.length;
    final int totalTulisan = (prefs.getInt(kunciTotalTulisan) ?? 0) + 1;

    await prefs.setString(
      kunciWaktuTerakhirDisimpan,
      sekarang.toIso8601String(),
    );
    await prefs.setInt(kunciJumlahTulisanTerakhir, jumlahTulisan);
    await prefs.setInt(kunciTotalTulisan, totalTulisan);
    await prefs.remove(kunciPemberitahuanCadangan);
    await prefs.setInt(kunciVersi, versiSkema);
  }

  Future<void> hapusSemua() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kunciTugas);
    await prefs.remove(kunciVersi);
    await prefs.remove(kunciWaktuTerakhirDisimpan);
    await prefs.remove(kunciJumlahTulisanTerakhir);
    await prefs.remove(kunciTotalTulisan);
    await prefs.remove(kunciCadanganDataRusak);
    await prefs.remove(kunciPemberitahuanCadangan);
  }

  /// Hanya untuk praktikum: menulis data yang sengaja rusak.
  Future<void> rusakkanUntukDemo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(kunciTugas, '{ini sengaja bukan JSON yang sah');
  }
}
