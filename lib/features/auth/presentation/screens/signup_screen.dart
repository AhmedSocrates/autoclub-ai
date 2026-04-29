import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/logo.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_field.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_link.dart';
import 'package:auto_club_ai/features/auth/repositories/auth_repository.dart';
import 'package:auto_club_ai/features/auth/repositories/user_repository.dart';
import 'package:auto_club_ai/shared_widgets/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // handle the signup by calling the signup and create user from user and auth repositories
  void signup(String username, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        final newUser = await _authRepository.signUp(email: email, password: password, username: username);
        if (newUser != null) {
          await _userRepository.createUser(newUser.uid, username);
        }
      } catch (e) {
        if (mounted) {
          showAppAlert(
            context,
            message: e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }
    }
  }

  void navigateToLogin() {
    context.read<AuthBloc>().add(AuthUserChanged(null));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // App logo
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Logo(),
                  ),

                  // Username
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomTextField(
                      label: 'Username',
                      hintText: 'e.g. john_doe',
                      textEditingController: _usernameController,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Email
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomTextField(
                      label: 'Email',
                      hintText: 'example@graduate.utm.my',
                      textEditingController: _emailController,
                      textInputAction: TextInputAction.next,
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

                  // Password
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomTextField(
                      label: 'Password',
                      hintText: 'Password1234',
                      textEditingController: _passwordController,
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Confirm Password
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      textEditingController: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password cannot be empty';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Info note
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You will be assigned as a general user once registered. '
                              'Your membership will be fully activated once a club lead accepts your request.',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign Up button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomButton(
                      onTap: ()=> signup(_usernameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text.trim()),
                      text: 'Create Account',
                    ),
                  ),

                  // Link to login
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: TextLink(
                        text: 'Already have an account? ',
                        linkText: 'Sign In',
                        onTap: navigateToLogin,
                      ),
                    ),
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