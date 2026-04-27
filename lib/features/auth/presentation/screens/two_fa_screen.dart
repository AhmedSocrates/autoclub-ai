import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class TwoFAScreem extends StatefulWidget {
  const TwoFAScreem({super.key});

  @override
  State<TwoFAScreem> createState() => _TwoFAScreemState();
}

class _TwoFAScreemState extends State<TwoFAScreem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Two Factor Authentication"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                child: Text("An email has been sent to you follow the link to continue your 2FA"), 
              ),
              CustomButton(onTap: ()=>{}, text: "Resend Email"),
              CustomButton(onTap: ()=>{}, text: "Go back to Login"),
            ],
          ),
        ),
      ),
    );
  }
}