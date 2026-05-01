import 'package:auto_club_ai/features/auth/bloc/auth_bloc.dart';
import 'package:auto_club_ai/features/auth/bloc/auth_event.dart';
import 'package:auto_club_ai/features/auth/presentation/screens/reset_password.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/custom_button.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/logo.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_field.dart';
import 'package:auto_club_ai/features/auth/presentation/widgets/text_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => 
  _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =  TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signin(BuildContext context, String email, String password) async {
    if (_formKey.currentState!.validate()) {
        context.read<AuthBloc>().add(SignInRequested(email, password));
    }
  }

  // handle the navigation to the signup
  void navigateToSignup() {
    context.read<AuthBloc>().add(CreateAccount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  
                  // app logo
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                    child: const Logo(),
                  ),

                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                    child: CustomTextField(
                      label: "Email",
                      hintText: "example@graduate.utm.my",
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

                    Padding(
                      padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                      child: CustomTextField(
                      label: "Password",
                      hintText: "Password1234",
                      textEditingController: _passwordController,
                      textInputAction: TextInputAction.done,
                      textInputType: TextInputType.emailAddress,
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

                    Center(
                      child: Padding(
                        padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                        child: TextLink(
                          text: 'Do not have an account?',
                          linkText: 'Register Now',
                          onTap: navigateToSignup
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                      child: CustomButton(
                        onTap: () => signin(context, _emailController.text.trim(), _passwordController.text.trim()),
                        text: 'Sign In',
                      ),
                    ),

                    Center(
                      child: Padding(
                        padding: const EdgeInsetsGeometry.symmetric(vertical: 5),
                        child: TextLink(
                          text: 'Forgot your password?',
                          linkText: 'Reset Here',
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
                          },
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