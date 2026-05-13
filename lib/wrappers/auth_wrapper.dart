import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/reset_password.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/signup_screen.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/email_verification.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthError &&
          previous is! PasswordReset &&
          previous is! PasswordResetLoading,
      listener: (context, state) {
        if (state is AuthError) {
          showAppAlert(context, message: state.error);
        }
      },
      buildWhen: (_, current) => current is! AuthError,
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading || state is Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 4)),
          );
        }
        if (state is AuthCreateAccount) return const SignupScreen();
        if (state is AwaitingEmailVerfication) return const EmailVerificationScreen();
        if (state is PasswordReset ||
            state is PasswordResetLoading ||
            state is PasswordResetEmailSent) {
          return const ResetPasswordScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
