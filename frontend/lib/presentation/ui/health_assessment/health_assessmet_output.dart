import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/presentation/ui/health_assessment/assessment_card.dart';
import 'package:app/presentation/ui/health_assessment/income_expense_chart.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';


class HealthAssessmentOutput extends StatelessWidget {
  final AssessmentResultEntity result;

  const HealthAssessmentOutput({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.commonLocals.assessment_result)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AssessmentCard(
                  title: context.commonLocals.financial_stability,
                  percentage: double.parse(result.financialStability.toStringAsFixed(1)),
                ),
                const SizedBox(width: 15),
                AssessmentCard(
                  title: context.commonLocals.cash_flow,
                  percentage: double.parse(result.cashFlow.toStringAsFixed(1)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            IncomeExpenseChart(totalIncome: result.totalIncome, totalExpense: result.totalExpense, profit: result.profit),
          ],
        ),
      ),
    );
  }
}
