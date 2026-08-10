import 'package:daily_habit/features/auth/domain/entities/user_entity.dart';
import 'package:daily_habit/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<void> call(String name, String email, String password) {
    return repository.register(name, email, password);
  }
}

class VerifyOtpUseCase {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  Future<UserEntity> call(String email, String otpCode) {
    return repository.verifyOtp(email, otpCode);
  }
}

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);

  Future<void> initiate(String email) {
    return repository.initiateForgotPassword(email);
  }

  Future<String> verify(String email, String otpCode) {
    return repository.verifyForgotOtp(email, otpCode);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  Future<void> call(
    String resetToken,
    String newPassword,
    String confirmPassword,
  ) {
    return repository.resetPassword(resetToken, newPassword, confirmPassword);
  }
}

class CheckAuthStatusUseCase {
  final AuthRepository repository;
  CheckAuthStatusUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
