import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';

class CostCuttingStrategiesScreen extends StatelessWidget {
  final VoidCallback? onSubmitted;

  const CostCuttingStrategiesScreen({super.key, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            label: context.commonLocals.farm_size,
            hintText: context.commonLocals.farm_size,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.crop_type,
            hintText: context.commonLocals.crop_type,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.season,
            hintText: context.commonLocals.season,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.fertilizer_expense,
            hintText: context.commonLocals.fertilizer_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.pesticide_expense,
            hintText: context.commonLocals.pesticide_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.transportation_expense,
            hintText: context.commonLocals.transportation_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.equipment_expense,
            hintText: context.commonLocals.equipment_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.seed_expense,
            hintText: context.commonLocals.seed_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.labour_expense,
            hintText: context.commonLocals.labour_expense,
          ),
          const SizedBox(height: 30),
          CustomInputField(
            label: context.commonLocals.other_utilities,
            hintText: context.commonLocals.other_utilities,
          ),
          const SizedBox(height: 150),
          Center(
            child: LoadingButton(
              onPressed: onSubmitted,
              label: context.commonLocals.submit,
              loading: false,
            ),
          ),
        ],
      ),
    );
  }
}
