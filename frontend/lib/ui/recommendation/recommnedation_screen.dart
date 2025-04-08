import 'package:flutter/material.dart';
import 'package:app/ui/custom_input_field.dart';

class RecommnedationScreen extends StatelessWidget {
  const RecommnedationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomInputField(hintText: 'Expense Reduction'),
            const SizedBox(height: 30),
            const CustomInputField(hintText: 'Crop Selection'),
            const SizedBox(height: 30),
            const CustomInputField(hintText: 'Loan Advice'),
            const SizedBox(height: 150),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/loanAdvice'); 
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
