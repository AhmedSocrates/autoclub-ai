import 'package:auto_club_ai/core/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class SignOutRequested extends AuthEvent {}
class CreateAccount extends AuthEvent {}
class AuthUserChanged extends AuthEvent {
  final User? firebaseUser;
  AuthUserChanged(this.firebaseUser);
}

class EmailVerified extends AuthEvent {
  final UserModel user;
  EmailVerified(this.user);
  @override
  List<Object?> get props => [user];
}