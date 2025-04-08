import 'package:app/ui/custom_input_field.dart';
import 'package:flutter/material.dart';

class ForcastingScreen extends StatelessWidget {
  const ForcastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomInputField(hintText: 'Crop Type'),
            const SizedBox(height: 30),
            const CustomInputField(hintText: 'Harvesting Month'),
            const SizedBox(height: 30),
            const CustomInputField(hintText: 'Region'),
            const SizedBox(height: 150),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forcastingOutput');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
    );
  }
}
