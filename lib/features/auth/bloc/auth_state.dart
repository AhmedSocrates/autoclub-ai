import 'package:auto_club_ai/core/models/user.dart';
import 'package:equatable/equatable.dart';


abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthCreateAccount extends AuthState {}
class Unauthenticated extends AuthState {}
class PasswordReset extends AuthState {}
class PasswordResetLoading extends AuthState {}
class PasswordResetEmailSent extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AwaitingEmailVerfication extends AuthState {}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
  @override
  List<Object?> get props => [error];
}