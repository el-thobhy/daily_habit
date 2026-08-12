import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryStorage = {};

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('SecureStorage write error ($key): $e');
      _memoryStorage[key] = value;
    }
  }

  Future<String?> _read(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null) return value;
    } catch (e) {
      debugPrint('SecureStorage read error ($key): $e');
    }
    return _memoryStorage[key];
  }

  Future<void> _deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('SecureStorage deleteAll error: $e');
    }
    _memoryStorage.clear();
  }

  Future<void> saveToken(String token) async {
    await _write(_keyToken, token);
  }

  Future<String?> getToken() async {
    return await _read(_keyToken);
  }

  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
  }) async {
    await _write(_keyUserId, id);
    await _write(_keyUserName, name);
    await _write(_keyUserEmail, email);
  }

  Future<Map<String, String>> getUserData() async {
    final id = await _read(_keyUserId) ?? '';
    final name = await _read(_keyUserName) ?? '';
    final email = await _read(_keyUserEmail) ?? '';
    return {'id': id, 'name': name, 'email': email};
  }

  Future<void> saveCustomKey(String key, String value) async {
    await _write(key, value);
  }

  Future<String?> getCustomKey(String key) async {
    return await _read(key);
  }

  Future<void> clearAll() async {
    await _deleteAll();
  }
}
