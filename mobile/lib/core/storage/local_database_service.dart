import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eazzio_school.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table for offline attendance drafts
        await db.execute('''
          CREATE TABLE attendance_drafts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            course_id INTEGER NOT NULL,
            course_name TEXT,
            date TEXT NOT NULL,
            records_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL -- 'PENDING', 'SYNCED', 'FAILED'
          )
        ''');

        // Table for read-only caching (dashboard, notices, routine)
        await db.execute('''
          CREATE TABLE cache_store (
            cache_key TEXT PRIMARY KEY,
            data_json TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Attendance draft operations
  static Future<int> insertAttendanceDraft({
    required int courseId,
    required String courseName,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final db = await database;
    return await db.insert('attendance_drafts', {
      'course_id': courseId,
      'course_name': courseName,
      'date': date,
      'records_json': jsonEncode(records),
      'created_at': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingAttendanceDrafts() async {
    final db = await database;
    return await db.query(
      'attendance_drafts',
      where: 'status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at DESC',
    );
  }

  static Future<void> updateDraftStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'attendance_drafts',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteDraft(int id) async {
    final db = await database;
    await db.delete('attendance_drafts', where: 'id = ?', whereArgs: [id]);
  }

  // Generic key-value cache operations
  static Future<void> cacheData(String key, dynamic data) async {
    final db = await database;
    await db.insert(
      'cache_store',
      {
        'cache_key': key,
        'data_json': jsonEncode(data),
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<dynamic> getCachedData(String key) async {
    final db = await database;
    final res = await db.query(
      'cache_store',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (res.isNotEmpty) {
      return jsonDecode(res.first['data_json'] as String);
    }
    return null;
  }

  // Clear all local cached data and offline attendance drafts upon user logout
  static Future<void> clearUserData() async {
    final db = await database;
    await db.delete('cache_store');
    await db.delete('attendance_drafts');
  }
}
