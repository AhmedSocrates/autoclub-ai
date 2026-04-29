import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthRepository _authRepository = AuthRepository();
  
  void signOut() async {
    await _authRepository.signOut();
  }

  void resendVerificationEmail() async {
    await _authRepository.sendEmailVerification();
  }

  void checkVerification() async {
    final User? user = await _authRepository.getCurrentUser();

    if(user!.emailVerified) {
      if(mounted) context.read<AuthBloc>().add(AuthUserChanged(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "An email has been sent to you. Please follow the link to verify your email address.",
                    textAlign: TextAlign.center,
                  ), 
                ),
                CustomButton(onTap: checkVerification, text: "I have verified my email"),
                const SizedBox(height: 10,),
                CustomButton(onTap: resendVerificationEmail, text: "Resend Email"),
                const SizedBox(height: 10,),
                CustomButton(onTap: signOut, text: "Go back to sign in"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}