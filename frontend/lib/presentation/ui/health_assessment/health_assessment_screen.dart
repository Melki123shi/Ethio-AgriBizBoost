import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_event.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/constants/mappings.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/presentation/ui/common/assessment_card.dart';
import 'package:app/application/health_assessment/recent_assessment_bloc.dart';

class HealthAssessmentScreen extends StatefulWidget {
  final void Function(AssessmentResultEntity result) onSubmitted;

  const HealthAssessmentScreen({required this.onSubmitted, super.key});

  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen> {
  final Map<String, String?> _formData = {
    'cropType': null,
    'subsidy': null,
    'salePrice': null,
    'totalCost': null,
    'quantitySold': null,
  };

  final Map<String, GlobalKey> _fieldKeys = {
    'cropType': GlobalKey(),
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<RecentAssessmentBloc>().add(FetchRecentAssessmentsEvent());
  }

  void _updateInputFieldData() {
    context.read<HealthAssessmentBloc>().add(
          UpdateInputFieldEvent(
            _formData['cropType'] ?? '',
            double.tryParse(_formData['subsidy'] ?? '') ?? 0,
            double.tryParse(_formData['salePrice'] ?? '') ?? 0,
            double.tryParse(_formData['totalCost'] ?? '') ?? 0,
            double.tryParse(_formData['quantitySold'] ?? '') ?? 0,
          ),
        );
  }

  Future<void> _showCropDropdown() async {
    final items = cropNameVarietyMapping.keys.toList();
    final key = 'cropType';
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
      setState(() {
        _formData[key] = selected;
      });
      _updateInputFieldData();
    }
  }

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

  Widget _buildSubmitButton() {
    return BlocBuilder<HealthAssessmentBloc, HealthAssessmentState>(
      builder: (context, state) {
        final isLoading = state is HealthAssessmentLoading;

        return LoadingButton(
          label: context.commonLocals.submit,
          loading: isLoading,
          onPressed: isLoading
              ? null
              : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<HealthAssessmentBloc>().add(
                          SubmitHealthAssessmentEvent(
                            cropType: _formData['cropType']!,
                            governmentSubsidy: double.parse(_formData['subsidy'] ?? '0'),
                            salePricePerQuintal: double.parse(_formData['salePrice'] ?? '0'),
                            totalCost: double.parse(_formData['totalCost'] ?? '0'),
                            quantitySold: double.parse(_formData['quantitySold'] ?? '0'),
                          ),
                        );
                  }
                },
        );
      },
    );
  }

  Widget _buildRecentResultHeader() {
    return BlocBuilder<RecentAssessmentBloc, HealthAssessmentState>(
      builder: (context, state) {
        if (state is RecentAssessmentResultState) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AssessmentCard(
                  title: context.commonLocals.financial_stability,
                  percentage: double.parse(state.averageFinancialStability.toStringAsFixed(1)),
                ),
                const SizedBox(width: 15),
                AssessmentCard(
                  title: context.commonLocals.cash_flow,
                  percentage: double.parse(state.averageCashFlow.toStringAsFixed(1)),
                ),
              ],
            ),
          );
        } else if (state is RecentAssessmentResultLoading) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is RecentAssessmentResultFailure) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Center(child: Text("Failed to load recent data")),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HealthAssessmentBloc, HealthAssessmentState>(
          listener: (context, state) {
            if (state is HealthAssessmentSuccess) {
              widget.onSubmitted(state.assessmentResult);
              // Refresh the recent result on success
              context.read<RecentAssessmentBloc>().add(FetchRecentAssessmentsEvent());
            } else if (state is HealthAssessmentFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.commonLocals.assessment_failed)),
              );
            }
          },
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecentResultHeader(),
              _buildDropdown('cropType', context.commonLocals.crop_type),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildStyledNumberField(
                  label: context.commonLocals.government_subsidy,
                  fieldKey: 'subsidy',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _buildStyledNumberField(
                  label: context.commonLocals.sale_price_per_quintal,
                  fieldKey: 'salePrice',
                ),
              ),
              Row(
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
              Center(child: _buildSubmitButton()),
            ],
          ),
        ),
      ),
    );
  }
}
