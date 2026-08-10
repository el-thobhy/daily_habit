import 'package:daily_habit/core/services/secure_storage_service.dart';
import 'package:daily_habit/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession(String token, UserModel user);
  Future<UserModel?> getSavedUser();
  Future<String?> getSavedToken();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveSession(String token, UserModel user) async {
    await secureStorage.saveToken(token);
    await secureStorage.saveUserData(
      id: user.id,
      name: user.name,
      email: user.email,
    );
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) return null;

    final data = await secureStorage.getUserData();
    if (data['id']!.isEmpty) return null;

    return UserModel(
      id: data['id']!,
      name: data['name']!,
      email: data['email']!,
    );
  }

  @override
  Future<String?> getSavedToken() async {
    return await secureStorage.getToken();
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.clearAll();
  }
}
