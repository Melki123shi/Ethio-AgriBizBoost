import 'package:app/ui/input_field.dart';
import 'package:flutter/material.dart';

class HealthAssessmentScreen extends StatelessWidget {
  const HealthAssessmentScreen({super.key});

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
            const CustomInputField(hintText: 'Government Subsidy'),
            const SizedBox(height: 30),
            const CustomInputField(hintText: 'Sale Price Per Quintal'),
            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(child: CustomInputField(hintText: 'Total Cost')),
                SizedBox(width: 10),
                Expanded(child: CustomInputField(hintText: 'Quantity Sold')),
              ],
            ),
            const SizedBox(height: 80),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/healthAssessmentOutput'); 
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
