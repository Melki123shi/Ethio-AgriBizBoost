import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_bloc.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_event.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_state.dart';
import 'package:app/domain/entity/loan_advice_input_entity.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:go_router/go_router.dart';

class LoanAdviceScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const LoanAdviceScreen({super.key, this.onSubmitted});

  @override
  State<LoanAdviceScreen> createState() => _LoanAdviceScreenState();
}

class _LoanAdviceScreenState extends State<LoanAdviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  void _updateInputFieldData() {
    final input = LoanAdviceInputEntity(
      cropType: _formData['cropType'] ?? '',
      governmentSubsidy: double.tryParse(_formData['subsidy'] ?? '0') ?? 0,
      salePricePerQuintal: double.tryParse(_formData['salePrice'] ?? '0') ?? 0,
      totalCost: double.tryParse(_formData['totalCost'] ?? '0') ?? 0,
      quantitySold: double.tryParse(_formData['quantitySold'] ?? '0') ?? 0,
    );
    context.read<LoanAdviceBloc>().add(UpdateInputFieldEvent(input));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoanAdviceBloc, LoanAdviceState>(
      listener: (context, state) {
        if (state is LoanAdviceSuccess) {
          widget.onSubmitted?.call();
          context.push('/loan_advice_result', extra: state.loanAdviceResult);
        } else if (state is LoanAdviceFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.commonLocals.loan_advice_failed),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(
                label: context.commonLocals.crop_type,
                hintText: context.commonLocals.crop_type,
                isRequired: true,
                onChanged: (val) {
                  _formData['cropType'] = val;
                  _updateInputFieldData();
                },
              ),
              const SizedBox(height: 30),
              CustomInputField(
                label: context.commonLocals.government_subsidy,
                hintText: context.commonLocals.government_subsidy,
                isRequired: true,
                onChanged: (val) {
                  _formData['subsidy'] = val;
                  _updateInputFieldData();
                },
              ),
              const SizedBox(height: 30),
              CustomInputField(
                label: context.commonLocals.sale_price_per_quintal,
                hintText: context.commonLocals.sale_price_per_quintal,
                isRequired: true,
                onChanged: (val) {
                  _formData['salePrice'] = val;
                  _updateInputFieldData();
                },
              ),
              const SizedBox(height: 30),
              CustomInputField(
                label: context.commonLocals.total_cost,
                hintText: context.commonLocals.total_cost,
                isRequired: true,
                onChanged: (val) {
                  _formData['totalCost'] = val;
                  _updateInputFieldData();
                },
              ),
              const SizedBox(height: 30),
              CustomInputField(
                label: context.commonLocals.quantity_sold,
                hintText: context.commonLocals.quantity_sold,
                isRequired: true,
                onChanged: (val) {
                  _formData['quantitySold'] = val;
                  _updateInputFieldData();
                },
              ),
              const SizedBox(height: 80),
              BlocBuilder<LoanAdviceBloc, LoanAdviceState>(
                builder: (context, state) {
                  final isLoading = state is LoanAdviceLoading;
                  return Center(
                    child: LoadingButton(
                      label: context.commonLocals.submit,
                      loading: isLoading,
                      onPressed: () {
                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (isValid) {
                          final input = LoanAdviceInputEntity(
                            cropType: _formData['cropType'],
                            governmentSubsidy:
                                double.parse(_formData['subsidy']),
                            salePricePerQuintal:
                                double.parse(_formData['salePrice']),
                            totalCost: double.parse(_formData['totalCost']),
                            quantitySold:
                                double.parse(_formData['quantitySold']),
                          );
                          context
                              .read<LoanAdviceBloc>()
                              .add(SubmitLoanAdviceEvent(input));
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
