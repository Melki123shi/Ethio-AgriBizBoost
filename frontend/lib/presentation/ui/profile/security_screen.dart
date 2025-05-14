import 'package:app/domain/entity/update_password_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_event.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/presentation/ui/common/bottom_border_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  @override
  void dispose() {
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  String? _validatePwd(String? v) => (v == null || v.length < 8)
      ? context.commonLocals.password_too_short
      : null;

  String? _validateConfirm(String? v) => v != _newPwdCtrl.text
      ? context.commonLocals.passwords_do_not_match
      : _validatePwd(v);

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final entity = UpdatePasswordEntity(
        currentPassword: _currentPwdCtrl.text,
        newPassword: _newPwdCtrl.text,
        confirmNewPassword: _confirmPwdCtrl.text,
      );
      context.read<UserBloc>().add(UpdateUserPassword(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locals = context.commonLocals;

    return Scaffold(
      appBar: AppBar(title: Text(locals.security)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserPasswordUpdated) {
              context.read<UserBloc>().add(FetchUser());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message,
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor)),
                    backgroundColor: Theme.of(context).primaryColor),
              );
            } else if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final loading = state is UserLoading;
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  BottomBorderInputField(
                    controller: _currentPwdCtrl,
                    labelText: locals.current_password,
                    obscureText: true,
                    validator: _validatePwd,
                  ),
                  const SizedBox(height: 16),
                  BottomBorderInputField(
                    controller: _newPwdCtrl,
                    labelText: locals.new_password,
                    obscureText: true,
                    validator: _validatePwd,
                  ),
                  const SizedBox(height: 16),
                  BottomBorderInputField(
                    controller: _confirmPwdCtrl,
                    labelText: locals.confirm_new_password,
                    obscureText: true,
                    validator: _validateConfirm,
                  ),
                  const Spacer(),
                  LoadingButton(
                    label: locals.update_password,
                    loading: loading,
                    width: double.infinity,
                    onPressed: _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
