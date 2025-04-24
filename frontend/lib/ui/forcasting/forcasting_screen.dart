import 'package:app/ui/custom_input_field.dart';
import 'package:flutter/material.dart';

class ForcastingScreen extends StatefulWidget {
  const ForcastingScreen({super.key});

  @override
  State<ForcastingScreen> createState() => _ForcastingScreenState();
}

class _ForcastingScreenState extends State<ForcastingScreen> {
  final _formKey = GlobalKey<FormState>();

  // If you later need to read the typed data, add controllers or onChanged.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomInputField(hintText: 'Region', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(hintText: 'Zone', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(hintText: 'Woreda', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(hintText: 'Market name', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(hintText: 'Crop name', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(
                  hintText: 'Variety name', isRequired: true),
              const SizedBox(height: 30),
              const CustomInputField(hintText: 'Season', isRequired: true),
              const SizedBox(height: 50),
              Center(
                child: TextButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (!isValid) return;

                    Navigator.pushNamed(context, '/forcastingOutput');
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
}
