import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseService {
  static const _draftsKey = 'offline_attendance_drafts';

  // Attendance draft operations using SharedPreferences (matching frontend web localStorage model)
  static Future<int> insertAttendanceDraft({
    required int courseId,
    required String courseName,
    required String date,
    required List<Map<String, dynamic>> records,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getPendingAttendanceDrafts();
    final newId = DateTime.now().millisecondsSinceEpoch;

    drafts.insert(0, {
      'id': newId,
      'course_id': courseId,
      'course_name': courseName,
      'date': date,
      'records_json': jsonEncode(records),
      'created_at': DateTime.now().toIso8601String(),
      'status': 'PENDING',
    });

    await prefs.setString(_draftsKey, jsonEncode(drafts));
    return newId;
  }

  static Future<List<Map<String, dynamic>>> getPendingAttendanceDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((d) => d['status'] == 'PENDING')
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> updateDraftStatus(int id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftsKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      final drafts = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      for (final d in drafts) {
        if (d['id'] == id) {
          d['status'] = status;
          break;
        }
      }
      await prefs.setString(_draftsKey, jsonEncode(drafts));
    } catch (_) {}
  }

  static Future<void> deleteDraft(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftsKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      final drafts = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((d) => d['id'] != id)
          .toList();
      await prefs.setString(_draftsKey, jsonEncode(drafts));
    } catch (_) {}
  }

  // Clear all local cached data and offline attendance drafts upon user logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftsKey);
  }
}
