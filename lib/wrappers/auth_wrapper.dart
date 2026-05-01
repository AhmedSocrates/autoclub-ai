import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/signup_screen.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/email_verification.dart';
import 'package:auto_club_ai/features/home/home.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      
      listenWhen: (previous, current) => current is AuthError,
      listener: (context, state) {
        if(state is AuthError) {
          showAppAlert(context, message: state.error);
        }
      },

      buildWhen: (previous, current) => current is !AuthError, 
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
          );
        }
        if (state is AwaitingEmailVerfication) {
          return const EmailVerificationScreen();
        }
        if (state is Authenticated) {
          return HomeScreen(user: state.user);
        }
        if (state is Unauthenticated) {
          return const LoginScreen();
        }

        if (state is AuthCreateAccount) {
          return const SignupScreen();
        }

        return Scaffold(
          body: Center(
            child: Text("Something went wrong!", style: AppTextStyles.h1),
          ),
        );
      },
    );
  }
}