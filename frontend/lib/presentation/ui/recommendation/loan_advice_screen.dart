import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_bloc.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_event.dart';
import 'package:app/application/recommendation/loan_advice/loan_advice_state.dart';
import 'package:app/constants/mappings.dart'; // Added for crop data
import 'package:app/domain/entity/loan_advice_input_entity.dart';
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
  // Changed to Map<String, String?> for consistency
  final Map<String, String?> _formData = {
    'cropType': null,
    'subsidy': null,
    'salePrice': null,
    'totalCost': null,
    'quantitySold': null,
  };

  // Added keys for positioning the dropdown
  final Map<String, GlobalKey> _fieldKeys = {
    'cropType': GlobalKey(),
  };

  void _updateInputFieldData() {
    final input = LoanAdviceInputEntity(
      cropType: _formData['cropType'] ?? '',
      governmentSubsidy: double.tryParse(_formData['subsidy'] ?? '') ?? 0,
      salePricePerQuintal: double.tryParse(_formData['salePrice'] ?? '') ?? 0,
      totalCost: double.tryParse(_formData['totalCost'] ?? '') ?? 0,
      quantitySold: double.tryParse(_formData['quantitySold'] ?? '') ?? 0,
    );
    context.read<LoanAdviceBloc>().add(UpdateInputFieldEvent(input));
  }

  // Helper function to show the crop dropdown
  Future<void> _showCropDropdown() async {
    final items = cropNameVarietyMapping.keys.toList();
    const key = 'cropType';
    final renderBox = _fieldKeys[key]!.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      color: Theme.of(context).indicatorColor,
      items: items
          .map(
            (crop) => PopupMenuItem(
              value: crop,
              child: SizedBox(
                width: size.width,
                child: Text(
                  crop,
                  style: TextStyle(color: Theme.of(context).focusColor),
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selected != null) {
      setState(() => _formData[key] = selected);
      _updateInputFieldData();
    }
  }

  // New helper for the dropdown UI
  Widget _buildDropdown(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: _showCropDropdown,
        child: Container(
          key: _fieldKeys[key],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 148, 196, 149),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formData[key] ?? label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: _formData[key] != null ? FontWeight.w300 : FontWeight.normal,
                    color: _formData[key] != null ? Theme.of(context).focusColor : Colors.grey,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color.fromARGB(255, 148, 196, 149),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New helper for styled number fields
  Widget _buildStyledNumberField({
    required String label,
    required String fieldKey,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 148, 196, 149),
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
      ),
    );

    return TextFormField(
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "$label is required";
        if (double.tryParse(val.trim()) == null) return "Enter a valid number";
        return null;
      },
      onChanged: (val) {
        _formData[fieldKey] = val;
        _updateInputFieldData();
      },
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // REPLACED CustomInputField with the new dropdown
              _buildDropdown('cropType', context.commonLocals.crop_type),

              // REPLACED CustomInputField with the new styled number field
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildStyledNumberField(
                  label: context.commonLocals.government_subsidy,
                  fieldKey: 'subsidy',
                ),
              ),

              // REPLACED CustomInputField with the new styled number field
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildStyledNumberField(
                  label: context.commonLocals.sale_price_per_quintal,
                  fieldKey: 'salePrice',
                ),
              ),

              // REPLACED CustomInputFields and added a Row for better layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStyledNumberField(
                      label: context.commonLocals.total_cost,
                      fieldKey: 'totalCost',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStyledNumberField(
                      label: context.commonLocals.quantity_sold,
                      fieldKey: 'quantitySold',
                    ),
                  ),
                ],
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
                        if (_formKey.currentState?.validate() ?? false) {
                          final input = LoanAdviceInputEntity(
                            cropType: _formData['cropType']!,
                            governmentSubsidy: double.parse(_formData['subsidy']!),
                            salePricePerQuintal: double.parse(_formData['salePrice']!),
                            totalCost: double.parse(_formData['totalCost']!),
                            quantitySold: double.parse(_formData['quantitySold']!),
                          );
                          context.read<LoanAdviceBloc>().add(SubmitLoanAdviceEvent(input));
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