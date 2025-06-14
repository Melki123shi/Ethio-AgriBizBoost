import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/domain/entity/signup_entity.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();

  final _emailCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();

  final _pwdCtrl = TextEditingController();

  bool _isObsecure = true;

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignupSubmitted(
              signupData: SignupRequestEntity(
                name: _nameCtrl.text.trim().isEmpty
                    ? null
                    : _nameCtrl.text.trim(),
                email: _emailCtrl.text.trim().isEmpty
                    ? null
                    : _emailCtrl.text.trim(),
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

  String? _validatePhone(String? v) {
    final cleaned = v?.replaceAll(' ', '') ?? '';
    if (cleaned.isEmpty) return 'Phone number is required.';
    final ok = RegExp(r'^(?:\+2519\d{8}|09\d{8})$').hasMatch(cleaned);
    return ok ? null : 'Enter a valid Ethiopian phone number.';
  }

  String? _validatePwd(String? v) => (v == null || v.length < 8)
      ? 'Password must be at least 8 characters.'
      : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
    return ok ? null : 'Enter a valid email address.';
  }

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
                        listener: (ctx, state) {
                          if (state is AuthSignupDone) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                  content: Text(
                                    'Account created. Please log in.',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).primaryColor),
                            );
                            ctx.go('/login');
                          } else if (state is AuthFailure) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(state.errorMessage)),
                            );
                          }
                        },
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (ctx, state) {
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
                                    Text('Sign Up',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          color: theme.focusColor,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const SizedBox(height: 24),
                                    CustomInputField(
                                      label: 'Name',
                                      hintText: 'Enter your name',
                                      controller: _nameCtrl,
                                      isRequired: false,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomInputField(
                                      label: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      controller: _phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      isRequired: true,
                                      validator: _validatePhone,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomInputField(
                                      label: 'Email',
                                      hintText: 'Enter your email',
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      isRequired: false,
                                      validator: _validateEmail,
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
                                              : const Icon(
                                                  Icons.visibility_off)),
                                    ),
                                    const SizedBox(height: 24),
                                    LoadingButton(
                                      label: 'Sign Up',
                                      loading: isLoading,
                                      onPressed: () => _submit(ctx),
                                    ),
                                    const SizedBox(height: 15),
                                    RichText(
                                      text: TextSpan(
                                        text: "Already have an account? ",
                                        style: theme.textTheme.bodyMedium,
                                        children: [
                                          TextSpan(
                                            text: "Login",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap =
                                                  () => context.go('/login'),
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
