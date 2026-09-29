import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabases {
  AppDatabases._();

  static final AppDatabases _instance = AppDatabases._();
  factory AppDatabases() => _instance;

  static const String namaBerkas = 'poliwangi_tugas.db';
  static const String tabelTugas = 'tugas';
  static const int versiSkema = 2;

  static const String sqlBuatTabelV1 =
      '''
    CREATE TABLE $tabelTugas (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      course TEXT NOT NULL,
      done INTEGER NOT NULL DEFAULT 0,
      createdAt TEXT NOT NULL,
      prioritas INTEGER NOT NULL DEFAULT 2
    )
  ''';

  static const String sqlMigrasiKeV2 =
      '''
    ALTER TABLE $tabelTugas ADD COLUMN prioritas INTEGER NOT NULL DEFAULT 2
  ''';

  Database? _basisData;

  Future<Database> get basisData async {
    final Database? tersimpan = _basisData;
    if (tersimpan != null) return tersimpan;

    final String direktori = await getDatabasesPath();
    final String jalur = join(direktori, namaBerkas);

    final Database db = await openDatabase(
      jalur,
      version: versiSkema,
      onCreate: (db, version) async {
        await db.execute(sqlBuatTabelV1);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(sqlMigrasiKeV2);
        }
      },
    );

    _basisData = db;
    return db;
  }
}
