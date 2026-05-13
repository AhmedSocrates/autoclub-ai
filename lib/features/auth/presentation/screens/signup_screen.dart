import 'package:auto_club_ai/core/theme/app_colors.dart';
import 'package:auto_club_ai/core/theme/app_text_styles.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/bloc/password_strength_cubit.dart';
import 'package:auto_club_ai/features/auth/bloc/password_strength_state.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/password_strength_bar.dart';
import 'package:auto_club_ai/shared_widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/logo.dart';
import 'package:auto_club_ai/shared_widgets/text_field.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_link.dart';
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
  late final PasswordStrengthCubit _strengthCubit;

  @override
  void initState() {
    super.initState();
    _strengthCubit = PasswordStrengthCubit();
    _passwordController.addListener(() {
      _strengthCubit.updatePassword(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _strengthCubit.close();
    super.dispose();
  }

  void signup(BuildContext context, String username, String email, String password) async {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpRequested(username, email, password));
    }
  }

  void navigateToLogin() {
    context.read<AuthBloc>().add(AuthUserChanged(null));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _strengthCubit,
      child: Scaffold(
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

                    // Password + strength indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          CustomTextField(
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
                          BlocBuilder<PasswordStrengthCubit, PasswordStrength>(
                            builder: (context, strength) {
                              if (strength == PasswordStrength.empty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: PasswordStrengthBar(strength: strength),
                              );
                            },
                          ),
                        ],
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
                        onTap: () => signup(
                          context,
                          _usernameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        ),
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
      ),
    );
  }
}