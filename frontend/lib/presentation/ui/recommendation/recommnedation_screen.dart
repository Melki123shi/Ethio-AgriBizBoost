import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';

class RecommnedationScreen extends StatelessWidget {
  final VoidCallback? onSubmitted;

  const RecommnedationScreen({super.key, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
              label: context.commonLocals.expense_reduction, hintText: context.commonLocals.expense_reduction),
          const SizedBox(height: 30),
          CustomInputField(
              label: context.commonLocals.crop_selection, hintText: context.commonLocals.crop_selection),
          const SizedBox(height: 30),
          CustomInputField(label: context.commonLocals.loan_advice, hintText: context.commonLocals.loan_advice),
          const SizedBox(height: 150),
          Center(
            child: TextButton(
              onPressed: onSubmitted,
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                context.commonLocals.submit,
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
