import 'package:daily_habit/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpSentState extends AuthState {
  final String email;
  const OtpSentState(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotOtpVerifiedState extends AuthState {
  final String email;
  final String resetToken;
  const ForgotOtpVerifiedState({required this.email, required this.resetToken});

  @override
  List<Object?> get props => [email, resetToken];
}

class PasswordResetSuccessState extends AuthState {}
