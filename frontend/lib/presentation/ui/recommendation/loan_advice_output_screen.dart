import 'package:app/domain/entity/loan_advice_result_entity.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class LoanAdviceResultScreen extends StatelessWidget {
  final LoanAdviceResultEntity result;

  const LoanAdviceResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.commonLocals.loan_advice_result)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20)),
          child: Text(
            result.recommendation,
            style: TextStyle(fontSize: 18, color: Theme.of(context).focusColor),
          ),
        ),
      ),
    );
  }
}
