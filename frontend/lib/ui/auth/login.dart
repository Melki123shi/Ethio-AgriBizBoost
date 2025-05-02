import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/domain/entity/login_input_entity.dart';
import 'package:app/ui/custom_input_field.dart';
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
    final ethioPhoneRegex = RegExp(r'^(?:\+2519\d{8}|09\d{8})\$');
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 207, 255, 149),
                    Color.fromARGB(255, 188, 247, 161)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: 45,
            child: Container(
              width: 280,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 179, 216, 134),
                    Color.fromARGB(255, 200, 255, 174)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/plant.jpeg'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      child: BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            context.go('/home');
                          } else if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.errorMessage)),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Text(
                                      'Login',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.focusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    CustomInputField(
                                      label: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      isRequired: true,
                                      validator: _validatePhone,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomInputField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: true,
                                      isRequired: true,
                                      validator: _validatePassword,
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: 140,
                                      child: ElevatedButton(
                                        onPressed: () => _submitForm(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.primaryColor,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: theme.focusColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    RichText(
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}