import 'package:auto_club_ai/core/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class SignOutRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email, password;
  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username, email, password;
  SignUpRequested(this.username ,this.email, this.password);
}

class EmailVerificationCompleted extends AuthEvent {}
class EmailVerificationRequested extends AuthEvent {}
class ResetPasswordRequested extends AuthEvent {}
class BackToLogin extends AuthEvent {}
class DeleteAccountRequested extends AuthEvent {
  final String uid;
  DeleteAccountRequested(this.uid);
}
class RefreshUserProfile extends AuthEvent {}

class SendPasswordResetEmail extends AuthEvent {
  final String email;
  SendPasswordResetEmail(this.email);
  @override
  List<Object?> get props => [email];
}

// handling the change of signup and signin screens
// because the stack doesnt work well when i change the states of signed in user
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