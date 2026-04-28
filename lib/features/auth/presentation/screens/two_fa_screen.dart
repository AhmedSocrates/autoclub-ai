import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

class TwoFAScreen extends StatefulWidget {
  const TwoFAScreen({super.key});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  AuthRepository _authRepository = AuthRepository();
  void signOut() async {
    await _authRepository.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Two Factor Authentication"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                  child: Text("An email has been sent to you follow the link to continue your 2FA"), 
                ),
                CustomButton(onTap: ()=>{}, text: "Resend Email"),
                SizedBox(height: 10,),
                CustomButton(onTap: signOut, text: "Go back to Login"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}