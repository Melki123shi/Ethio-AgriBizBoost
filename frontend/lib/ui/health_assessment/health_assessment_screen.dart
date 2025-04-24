import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_event.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/ui/custom_input_field.dart';
import 'package:app/ui/health_assessment/health_assessmet_output.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthAssessmentScreen extends StatefulWidget {
  const HealthAssessmentScreen({super.key});

  @override
  State<HealthAssessmentScreen> createState() => _HealthAssessmentScreenState();
}

class _HealthAssessmentScreenState extends State<HealthAssessmentScreen> {
  final Map<String, dynamic> _formData = {};
  final _formKey = GlobalKey<FormState>();

  void _updateInputFieldData() {
    context.read<HealthAssessmentBloc>().add(
          UpdateInputFieldEvent(
            _formData['cropType'],
            _formData['subsidy'],
            _formData['salePrice'],
            _formData['totalCost'],
            _formData['quantitySold'],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthAssessmentBloc, HealthAssessmentState>(
      listener: (context, state) {
        if (state is HealthAssessmentSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  HealthAssessmentOutput(result: state.assessmentResult),
            ),
          );
        } else if (state is HealthAssessmentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment failed. Please try again.'),
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  hintText: 'Crop Type',
                  isRequired: true,
                  onChanged: (value) {
                    _formData['cropType'] = value;
                    _updateInputFieldData();
                  },
                ),
                const SizedBox(height: 30),
                CustomInputField(
                  hintText: 'Government Subsidy',
                  isRequired: true,
                  onChanged: (value) {
                    _formData['subsidy'] = value;
                    _updateInputFieldData();
                  },
                ),
                const SizedBox(height: 30),
                CustomInputField(
                  hintText: 'Sale Price Per Quintal',
                  isRequired: true,
                  onChanged: (value) {
                    _formData['salePrice'] = value;
                    _updateInputFieldData();
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        hintText: 'Total Cost',
                        isRequired: true,
                        onChanged: (value) {
                          _formData['totalCost'] = value;
                          _updateInputFieldData();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomInputField(
                        hintText: 'Quantity Sold',
                        isRequired: true,
                        onChanged: (value) {
                          _formData['quantitySold'] = value;
                          _updateInputFieldData();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Center(
                  child: TextButton(
                    onPressed: () {
                      final isValid =
                          _formKey.currentState?.validate() ?? false;
                      if (isValid) {
                        context.read<HealthAssessmentBloc>().add(
                              SubmitHealthAssessmentEvent(
                                cropType: _formData['cropType'],
                                governmentSubsidy:
                                    double.parse(_formData['subsidy']),
                                salePricePerQuintal:
                                    double.parse(_formData['salePrice']),
                                totalCost:
                                    double.parse(_formData['totalCost']),
                                quantitySold:
                                    double.parse(_formData['quantitySold']),
                              ),
                            );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
