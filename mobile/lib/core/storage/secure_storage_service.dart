import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_jwt_token';
  static const _userDataKey = 'auth_user_data';
  static const _selectedPortalKey = 'selected_portal_choice';

  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userMap) async {
    await _storage.write(key: _userDataKey, value: jsonEncode(userMap));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final str = await _storage.read(key: _userDataKey);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userDataKey);
  }

  // Preference for remembering last selected portal on login screen
  Future<void> saveSelectedPortal(String portal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedPortalKey, portal);
  }

  Future<String?> getSelectedPortal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedPortalKey);
  }
}
