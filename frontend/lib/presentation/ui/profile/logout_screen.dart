import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app/application/auth/auth_bloc.dart';
import 'package:app/application/auth/auth_event.dart';
import 'package:app/application/auth/auth_state.dart';
import 'package:app/presentation/ui/common/loading_button.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locals = context.commonLocals;

    return Scaffold(
      appBar: AppBar(title: Text(locals.log_out)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final loading = state is AuthLoading;

              return Column(
                children: [
                  const Spacer(),
                  Text(
                    locals.confirm_logout,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LoadingButton(
                    label: locals.log_out,
                    width: 140,
                    loading: loading,
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      locals.cancel,
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
