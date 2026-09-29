import 'package:sqflite/sqflite.dart';

import '../databases/app_databases.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> ambilSemua();
  Future<void> tambah(Task tugas);
  Future<void> ubah(Task tugas);
  Future<void> hapus(String id);
  Future<void> ubahStatus(String id, bool selesai);
  Future<void> hapusSelesai();
  Future<void> bersihkan();
  Future<int> jumlah();
}

class PrefsTaskRepository implements TaskRepository {
  PrefsTaskRepository() : _db = AppDatabases();

  final AppDatabases _db;

  static Map<String, Object?> _keBaris(Task tugas) {
    return {
      'id': tugas.id,
      'title': tugas.title,
      'course': tugas.course,
      'done': tugas.done ? 1 : 0,
      'createdAt': tugas.createdAt,
      'prioritas': tugas.prioritas,
    };
  }

  static Task _dariBaris(Map<String, Object?> row) {
    return Task(
      id: row['id'] as String,
      title: row['title'] as String,
      course: row['course'] as String,
      done: (row['done'] as int?) == 1,
      createdAt: row['createdAt'] as String,
      prioritas: (row['prioritas'] as int?) ?? 2,
    );
  }

  @override
  Future<List<Task>> ambilSemua() async {
    final Database db = await _db.basisData;
    final List<Map<String, Object?>> rows = await db.query(
      AppDatabases.tabelTugas,
      orderBy: 'prioritas ASC, createdAt DESC',
    );

    return rows.map(_dariBaris).toList(growable: true);
  }

  @override
  Future<void> tambah(Task tugas) async {
    final Database db = await _db.basisData;
    await db.insert(
      AppDatabases.tabelTugas,
      _keBaris(tugas),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> ubah(Task tugas) async {
    final Database db = await _db.basisData;
    await db.update(
      AppDatabases.tabelTugas,
      _keBaris(tugas),
      where: 'id = ?',
      whereArgs: [tugas.id],
    );
  }

  @override
  Future<void> hapus(String id) async {
    final Database db = await _db.basisData;
    await db.delete(AppDatabases.tabelTugas, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> ubahStatus(String id, bool selesai) async {
    final Database db = await _db.basisData;
    await db.update(
      AppDatabases.tabelTugas,
      {'done': selesai ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> hapusSelesai() async {
    final Database db = await _db.basisData;
    await db.delete(AppDatabases.tabelTugas, where: 'done = ?', whereArgs: [1]);
  }

  @override
  Future<void> bersihkan() async {
    final Database db = await _db.basisData;
    await db.delete(AppDatabases.tabelTugas);
  }

  @override
  Future<int> jumlah() async {
    final Database db = await _db.basisData;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS jumlah FROM ${AppDatabases.tabelTugas}',
    );

    final Object? value = rows.first['jumlah'];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
