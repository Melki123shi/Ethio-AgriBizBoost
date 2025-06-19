import 'package:app/domain/entity/loan_advice_result_entity.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class LoanAdviceResultScreen extends StatelessWidget {
  final LoanAdviceResultEntity result;

  const LoanAdviceResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 10),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.commonLocals.loan_advice_result),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.commonLocals.recommendation_label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    result.recommendation,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).focusColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
