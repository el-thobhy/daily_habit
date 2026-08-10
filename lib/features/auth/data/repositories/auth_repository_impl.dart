import 'package:daily_habit/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:daily_habit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:daily_habit/features/auth/data/models/user_model.dart';
import 'package:daily_habit/features/auth/domain/entities/user_entity.dart';
import 'package:daily_habit/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    final String token = result['token'];
    final UserModel user = result['user'];

    await localDataSource.saveSession(token, user);
    return user.toEntity();
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await remoteDataSource.register(name, email, password);
  }

  @override
  Future<UserEntity> verifyOtp(String email, String otpCode) async {
    final result = await remoteDataSource.verifyOtp(email, otpCode);
    final String token = result['token'];
    final UserModel user = result['user'];

    await localDataSource.saveSession(token, user);
    return user.toEntity();
  }

  @override
  Future<void> initiateForgotPassword(String email) async {
    await remoteDataSource.forgotPasswordInitiate(email);
  }

  @override
  Future<String> verifyForgotOtp(String email, String otpCode) async {
    return await remoteDataSource.forgotPasswordVerify(email, otpCode);
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    await remoteDataSource.resetPassword(resetToken, newPassword, confirmPassword);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final savedUser = await localDataSource.getSavedUser();
    return savedUser?.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearSession();
  }
}
