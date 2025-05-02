import 'package:app/application/forcasting/forcasting_bloc.dart';
import 'package:app/application/forcasting/forcasting_event.dart';
import 'package:app/application/forcasting/forcasting_state.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:app/presentation/ui/common/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForcastingScreen extends StatefulWidget {
  final void Function(ForcastingResultEntity result)? onSubmitted;

  const ForcastingScreen({super.key, this.onSubmitted});

  @override
  State<ForcastingScreen> createState() => _ForcastingScreenState();
}

class _ForcastingScreenState extends State<ForcastingScreen> {
  final Map<String, dynamic> _formData = {};
  final _formKey = GlobalKey<FormState>();

  List<String> _getList(String key) {
    final val = _formData[key];
    return val != null ? [val] : [];
  }

  void _updateInputFieldData() {
    context.read<ForcastingBloc>().add(
          UpdateInputFieldEvent(
            _getList('region'),
            _getList('zone'),
            _getList('woreda'),
            _getList('marketname'),
            _getList('cropname'),
            _getList('varietyname'),
            _getList('season'),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForcastingBloc, ForcastingState>(
      listener: (context, state) {
        if (state is ForcastingSuccess) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!(state.forcastingResult); 
          }
        } else if (state is ForcastingFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Forecasting failed. Please try again.'),
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput('Region', 'region'),
              _buildInput('Zone', 'zone'),
              _buildInput('Woreda', 'woreda'),
              _buildInput('Market name', 'marketname'),
              _buildInput('Crop name', 'cropname'),
              _buildInput('Variety name', 'varietyname'),
              _buildInput('Season', 'season'),
              const SizedBox(height: 50),
              Center(
                child: TextButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (isValid) {
                      context.read<ForcastingBloc>().add(
                            SubmitForcastingEvent(
                              region: _getList('region'),
                              zone: _getList('zone'),
                              woreda: _getList('woreda'),
                              marketname: _getList('marketname'),
                              cropname: _getList('cropname'),
                              varietyname: _getList('varietyname'),
                              season: _getList('season'),
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
                    'Submit',
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
    );
  }

  Widget _buildInput(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: CustomInputField(
        label: label,
        hintText: label,
        isRequired: true,
        onChanged: (value) {
          _formData[key] = value;
          _updateInputFieldData();
        },
      ),
    );
  }
}
