import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/domain/entity/login_input_entity.dart';
import 'package:app/presentation/ui/custom_input_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              loginData: LoginInputEntity(
                phoneNumber: _phoneController.text.trim(),
                password: _passwordController.text.trim(),
              ),
            ),
          );
    } else {
      print('Form validation failed.');
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final cleanedValue = value.replaceAll(' ', '');
    final ethioPhoneRegex = RegExp(r'^(?:\+2519\d{8}|09\d{8})$');
    if (!ethioPhoneRegex.hasMatch(cleanedValue)) {
      return 'Enter a valid Ethiopian phone number.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to your account",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoading) {
                  } else if (state is AuthSuccess) {
                    context.go('/home');
                  } else if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage)),
                    );
                  }
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        label: 'Phone Number',
                        hintText: 'Enter your phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),
                      CustomInputField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        isRequired: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/signup');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
