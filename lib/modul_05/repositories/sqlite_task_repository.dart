import 'package:sqflite/sqflite.dart';

import '../databases/app_databases.dart';
import '../models/task.dart';
import 'prefs_task_repository.dart';

class SqliteTaskRepository extends PrefsTaskRepository {
  SqliteTaskRepository() : _db = AppDatabases();

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

    final List<Map<String, Object?>> baris = await db.query(
      AppDatabases.tabelTugas,
      orderBy: 'prioritas ASC, createdAt DESC',
    );

    return baris.map(_dariBaris).toList(growable: true);
  }

  @override
  Future<void> ubah(Task tugas) async {
    final Database db = await _db.basisData;
    await db.update(
      AppDatabases.tabelTugas,
      _keBaris(tugas),
      where: 'id = ?',
      whereArgs: <Object?>[tugas.id],
    );
  }

  @override
  Future<int> jumlah() async {
    final Database db = await _db.basisData;
    final List<Map<String, Object?>> hasil = await db.rawQuery(
      'SELECT COUNT(*) AS jumlah FROM ${AppDatabases.tabelTugas}',
    );
    return Sqflite.firstIntValue(hasil) ?? 0;
  }
}
