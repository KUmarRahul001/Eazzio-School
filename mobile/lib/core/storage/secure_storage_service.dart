import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_jwt_token';
  static const _userDataKey = 'auth_user_data';
  static const _selectedPortalKey = 'selected_portal_choice';

  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return;
    }
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userMap) async {
    final str = jsonEncode(userMap);
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, str);
      return;
    }
    try {
      await _storage.write(key: _userDataKey, value: str);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, str);
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    String? str;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      str = prefs.getString(_userDataKey);
    } else {
      try {
        str = await _storage.read(key: _userDataKey);
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        str = prefs.getString(_userDataKey);
      }
    }
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    if (!kIsWeb) {
      try {
        await _storage.delete(key: _tokenKey);
        await _storage.delete(key: _userDataKey);
      } catch (_) {}
    }
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
