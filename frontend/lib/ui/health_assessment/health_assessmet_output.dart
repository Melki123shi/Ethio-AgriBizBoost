import 'package:app/application/health_assessment/health_assessment_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/ui/health_assessment/assessment_card.dart';
import 'package:app/ui/health_assessment/income_expense_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthAssessmentOutput extends StatelessWidget {
  const HealthAssessmentOutput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HealthAssessmentBloc, HealthAssessmentState>(
        builder: (context, state) {
      if (state is HealthAssessmentSuccess) {
        final assessmentResult = state.assessmentResult;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AssessmentCard(
                    title: "Financial Stability",
                    percentage: assessmentResult.financialStability),
                const SizedBox(width: 15),
                AssessmentCard(
                    title: "Cash Flow",
                    percentage: assessmentResult.cashFlow),
              ],
            ),
            const SizedBox(height: 20),
            const IncomeExpenseChart(),
          ],
        );
      }
      return const Center(
        child:
            SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
      );
    });
  }
}
