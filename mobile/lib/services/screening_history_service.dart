import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'auth_service.dart';
import 'connectivity_service.dart';

class ScreeningHistoryService {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = '${await getDatabasesPath()}/skinx_local_history.db';
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (database, _) async {
        await database.execute('''CREATE TABLE screenings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          owner_id TEXT NOT NULL,
          created_at TEXT NOT NULL,
          result TEXT NOT NULL,
          record_key TEXT NOT NULL,
          deleted INTEGER NOT NULL DEFAULT 0,
          synced INTEGER NOT NULL DEFAULT 0,
          UNIQUE(owner_id, record_key)
        )''');
      },
      onUpgrade: (database, oldVersion, _) async {
        if (oldVersion < 2) {
          await database.execute('ALTER TABLE screenings ADD COLUMN record_key TEXT');
          await database.execute('ALTER TABLE screenings ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0');
          await database.execute('ALTER TABLE screenings ADD COLUMN synced INTEGER NOT NULL DEFAULT 0');
          final rows = await database.query('screenings', columns: ['id']);
          for (final row in rows) {
            await database.update('screenings', {'record_key': _newKey()},
                where: 'id = ?', whereArgs: [row['id']]);
          }
          await database.execute('CREATE UNIQUE INDEX IF NOT EXISTS screening_owner_key ON screenings (owner_id, record_key)');
        }
      },
    );
    return _db!;
  }

  static String _newKey() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> save({required String ownerId, required String result}) async {
    final database = await db;
    await database.insert('screenings', {
      'owner_id': ownerId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'result': result,
      'record_key': _newKey(),
      'deleted': 0,
      'synced': 0,
    });
    await sync(ownerId);
  }

  Future<List<Map<String, Object?>>> getAll(String ownerId) async {
    await sync(ownerId);
    final database = await db;
    return database.query('screenings',
        where: 'owner_id = ? AND deleted = 0', whereArgs: [ownerId],
        orderBy: 'created_at DESC');
  }

  Future<void> remove({required String ownerId, required int id}) async {
    final database = await db;
    await database.update('screenings', {'deleted': 1, 'synced': 0},
        where: 'id = ? AND owner_id = ?', whereArgs: [id, ownerId]);
    await sync(ownerId);
  }

  Future<void> sync(String ownerId) async {
    if (!ConnectivityService.instance.online || AuthService.user?.id != ownerId) return;
    final database = await db;
    final table = AuthService.client.from('screening_records');
    try {
      final pending = await database.query('screenings',
          where: 'owner_id = ? AND synced = 0', whereArgs: [ownerId]);
      for (final row in pending) {
        final recordKey = row['record_key'] as String;
        if (row['deleted'] == 1) {
          await table.delete().eq('user_id', ownerId).eq('client_record_id', recordKey);
        } else {
          await table.upsert({
            'user_id': ownerId,
            'client_record_id': recordKey,
            'result': row['result'],
            'created_at': row['created_at'],
          }, onConflict: 'user_id,client_record_id', ignoreDuplicates: true);
        }
        await database.update('screenings', {'synced': 1},
            where: 'id = ? AND owner_id = ?', whereArgs: [row['id'], ownerId]);
      }
      final remote = await table.select('client_record_id, result, created_at')
          .eq('user_id', ownerId).order('created_at', ascending: false).limit(500);
      if (remote.length < 500) {
        final remoteKeys = remote.map((item) => item['client_record_id'] as String).toSet();
        final stored = await database.query('screenings',
            where: 'owner_id = ? AND synced = 1 AND deleted = 0', whereArgs: [ownerId]);
        for (final item in stored) {
          if (!remoteKeys.contains(item['record_key'])) {
            await database.delete('screenings', where: 'id = ?', whereArgs: [item['id']]);
          }
        }
      }
      for (final row in remote) {
        await database.insert('screenings', {
          'owner_id': ownerId,
          'record_key': row['client_record_id'],
          'result': row['result'],
          'created_at': row['created_at'],
          'deleted': 0,
          'synced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {
      // Local records are retained and synchronization can be retried later.
    }
  }
}
