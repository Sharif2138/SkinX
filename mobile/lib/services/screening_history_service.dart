import 'dart:math';

import 'package:sqflite/sqflite.dart';

import 'auth_service.dart';
import 'connectivity_service.dart';

class ScreeningHistoryService {
  Database? _db;
  String? lastSyncError;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = '${await getDatabasesPath()}/skinx_local_history.db';
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (database, _) async {
        await database.execute('''CREATE TABLE screenings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          owner_id TEXT NOT NULL,
          created_at TEXT NOT NULL,
          result TEXT NOT NULL,
          patient_name TEXT,
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
        if (oldVersion < 3) {
          await database.execute('ALTER TABLE screenings ADD COLUMN patient_name TEXT');
        }
      },
    );
    return _db!;
  }

  static String _newKey() {
    final random = Random.secure();
    return List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> save({
    required String ownerId,
    required String result,
    String? patientName,
    bool communityHealthWorker = false,
  }) async {
    final cleanName = patientName?.trim();
    if (communityHealthWorker && (cleanName == null || cleanName.isEmpty)) {
      throw ArgumentError('Patient name is required.');
    }
    if (cleanName != null && cleanName.length > 120) {
      throw ArgumentError('Patient name is too long.');
    }
    final database = await db;
    await database.insert('screenings', {
      'owner_id': ownerId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'result': result,
      'patient_name': communityHealthWorker ? cleanName : null,
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
    lastSyncError = null;
    if (!ConnectivityService.instance.online || AuthService.user?.id != ownerId) return;
    final database = await db;
    final table = AuthService.client.from('screening_records');
    try {
      var failedUploads = false;
      final pending = await database.query('screenings',
          where: 'owner_id = ? AND synced = 0', whereArgs: [ownerId]);
      for (final row in pending) {
        final recordKey = row['record_key'] as String;
        try {
          if (row['deleted'] == 1) {
            await table.delete().eq('user_id', ownerId).eq('client_record_id', recordKey);
          } else {
            await table.upsert({
              'user_id': ownerId,
              'client_record_id': recordKey,
              'result': row['result'],
              'patient_name': row['patient_name'],
              'created_at': row['created_at'],
            }, onConflict: 'user_id,client_record_id', ignoreDuplicates: true);
          }
          await database.update('screenings', {'synced': 1},
              where: 'id = ? AND owner_id = ?', whereArgs: [row['id'], ownerId]);
        } catch (_) {
          failedUploads = true;
          continue;
        }
      }
      if (failedUploads) {
        lastSyncError = 'Some records are waiting to sync. They are saved on this device.';
        return;
      }
      final remote = <Map<String, dynamic>>[];
      const pageSize = 500;
      for (var offset = 0; ; offset += pageSize) {
        final page = await table
            .select('client_record_id, result, created_at, patient_name')
            .eq('user_id', ownerId)
            .order('created_at', ascending: false)
            .range(offset, offset + pageSize - 1);
        remote.addAll(page);
        if (page.length < pageSize) break;
      }
      final remoteKeys = remote.map((item) => item['client_record_id'] as String).toSet();
      final stored = await database.query('screenings',
          where: 'owner_id = ? AND synced = 1 AND deleted = 0', whereArgs: [ownerId]);
      for (final item in stored) {
        if (!remoteKeys.contains(item['record_key'])) {
          await database.delete('screenings', where: 'id = ?', whereArgs: [item['id']]);
        }
      }
      for (final row in remote) {
        await database.insert('screenings', {
          'owner_id': ownerId,
          'record_key': row['client_record_id'],
          'result': row['result'],
          'patient_name': row['patient_name'],
          'created_at': row['created_at'],
          'deleted': 0,
          'synced': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (_) {
      lastSyncError = 'Could not sync screening history. Records remain on this device.';
    }
  }
}
