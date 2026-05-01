import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  
  
  void signOut(BuildContext context) {
    context.read<AuthBloc>().add(SignOutRequested());
  }

  void resendVerificationEmail(BuildContext context) async {
    context.read<AuthBloc>().add(EmailVerificationRequested());  
  }
  

  void checkVerification(BuildContext context) {
    context.read<AuthBloc>().add(EmailVerificationCompleted());
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
                CustomButton(onTap: () => checkVerification(context), text: "I have verified my email"),
                const SizedBox(height: 10,),
                CustomButton(onTap: () => resendVerificationEmail(context), text: "Resend Email"),
                const SizedBox(height: 10,),
                CustomButton(onTap: () => signOut(context), text: "Go back to sign in"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}