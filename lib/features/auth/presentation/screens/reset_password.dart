import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_state.dart';
import 'package:auto_club_ai/shared_widgets/custom_button.dart';
import 'package:auto_club_ai/shared_widgets/text_field.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SendPasswordResetEmail(_emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is PasswordResetEmailSent || current is AuthError,
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AppAlertDialog(
              message: 'Password reset email sent! Please check your inbox.',
              buttonText: 'OK',
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<AuthBloc>().add(BackToLogin());
            }
          });
        }
        if (state is AuthError) {
          showAppAlert(context, message: state.error);
        }
      },
      buildWhen: (_, current) =>
          current is PasswordReset ||
          current is PasswordResetLoading ||
          current is PasswordResetEmailSent,
      builder: (context, state) {
        final isLoading = state is PasswordResetLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Reset Password"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.read<AuthBloc>().add(BackToLogin()),
            ),
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
                        textAlign: TextAlign.center,
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
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(onTap: _submit, text: "Reset Password"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
