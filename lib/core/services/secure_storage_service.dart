import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  Future<Map<String, String>> getUserData() async {
    final id = await _storage.read(key: _keyUserId) ?? '';
    final name = await _storage.read(key: _keyUserName) ?? '';
    final email = await _storage.read(key: _keyUserEmail) ?? '';
    return {'id': id, 'name': name, 'email': email};
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
