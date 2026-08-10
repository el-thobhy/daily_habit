import 'package:daily_habit/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<UserEntity> verifyOtp(String email, String otpCode);
  Future<void> initiateForgotPassword(String email);
  Future<String> verifyForgotOtp(String email, String otpCode);
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}
