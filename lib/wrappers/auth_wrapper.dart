import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/two_fa_screen.dart';
import 'package:auto_club_ai/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
          );
        }
        if (state is AwaitingTwoFactor) {
          return const TwoFAScreen();
        }
        if (state is Authenticated) {
          return HomeScreen(user: state.user);
        }
        if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
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