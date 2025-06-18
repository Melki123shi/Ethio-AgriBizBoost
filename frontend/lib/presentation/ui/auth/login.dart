import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_event.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();

  final _pwdCtrl = TextEditingController();

  bool _isObsecure = true;

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              loginData: LoginRequestEntity(
                phoneNumber: _phoneCtrl.text.trim(),
                password: _pwdCtrl.text.trim(),
              ),
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validatePwd(String? v) => (v == null || v.length < 8)
      ? 'Password must be at least 8 characters.'
      : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _bCircle(const [Color(0xFFDFFF95), Color(0xFFBCF7A1)], -60, -80, 220),
          _bCircle(const [Color(0xFFB3D886), Color(0xFFC8FFAE)], -60, 45, 280,
              h: 140),
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
                          context.read<UserBloc>().add(FetchUser());
                          if (state is AuthSuccess) {
                            context.go('/home');
                          }
                          // else if (state is AuthInitial) {
                          //   context.read<UserBloc>().add(ClearUser());
                          // }
                          else if (state is AuthFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.errorMessage)),
                            );
                          }
                        },
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return Form(
                              key: _formKey,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Text('Login',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color: theme.focusColor,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const SizedBox(height: 24),
                                    CustomInputField(
                                      label: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      isRequired: true,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomInputField(
                                      label: 'Password',
                                      hintText: 'Enter your password',
                                      controller: _pwdCtrl,
                                      obscureText: _isObsecure,
                                      isRequired: true,
                                      validator: _validatePwd,
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _isObsecure = !_isObsecure;
                                            });
                                          },
                                          icon: _isObsecure
                                              ? const Icon(Icons.visibility)
                                              : const Icon(Icons.visibility_off)),
                                    ),
                                    const SizedBox(height: 24),
                                    LoadingButton(
                                      label: 'Login',
                                      loading: isLoading,
                                      onPressed: () => _submit(context),
                                    ),
                                    const SizedBox(height: 15),
                                    RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(
                                            text: "Sign Up",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap =
                                                  () => context.go('/signup'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _bCircle(List<Color> colors, double t, double l, double w,
          {double? h}) =>
      Positioned(
        top: t,
        left: l,
        child: Container(
          width: w,
          height: h ?? w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
          ),
        ),
      );
}
