import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otpCode;

  const VerifyOtpEvent({required this.email, required this.otpCode});

  @override
  List<Object?> get props => [email, otpCode];
}

class InitiateForgotPasswordEvent extends AuthEvent {
  final String email;
  const InitiateForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyForgotOtpEvent extends AuthEvent {
  final String email;
  final String otpCode;

  const VerifyForgotOtpEvent({required this.email, required this.otpCode});

  @override
  List<Object?> get props => [email, otpCode];
}

class ResetPasswordEvent extends AuthEvent {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordEvent({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [resetToken, newPassword, confirmPassword];
}

class LogoutEvent extends AuthEvent {}
