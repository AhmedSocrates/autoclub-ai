import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_field.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reset Password"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Enter your email to receive the password reset link",
                    style: AppTextStyles.bodyLg,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CustomTextField(
                      label: "Email",
                      hintText: "email@graduate.utm.my",
                      textEditingController: _emailController,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!value.trim().endsWith('@graduate.utm.my')) {
                          return 'Email must use your @graduate.utm.my address';
                        }
                        return null;
                      }
                    ),
                  ),

                  
              
              
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: CustomButton(onTap: (){}, text: "Reset Password"),
                  ),
                ],
              ),
            ), 
          ),
        ),
      ),
    );
  }
}