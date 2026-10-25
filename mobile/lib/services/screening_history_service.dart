import 'package:sqflite/sqflite.dart';

/// Only anonymous result and time are saved, following an explicit Save action.
/// Images and patient names are intentionally never persisted in this pilot.
class ScreeningHistoryService {
  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = '${await getDatabasesPath()}/skinx_local_history.db';
    _db = await openDatabase(path, version: 1, onCreate: (database, _) async {
      await database.execute('''CREATE TABLE screenings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        result TEXT NOT NULL
      )''');
    });
    return _db!;
  }

  Future<void> save({required String ownerId, required String result}) async {
    final database = await db;
    await database.insert('screenings', {
      'owner_id': ownerId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'result': result,
    });
  }

  Future<List<Map<String, Object?>>> getAll(String ownerId) async {
    final database = await db;
    return database.query('screenings', where: 'owner_id = ?', whereArgs: [ownerId], orderBy: 'created_at DESC');
  }

  Future<void> remove({required String ownerId, required int id}) async {
    final database = await db;
    await database.delete('screenings', where: 'id = ? AND owner_id = ?', whereArgs: [id, ownerId]);
  }
}
