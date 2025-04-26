import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final double percentage;

  const AssessmentCard({
    super.key,
    required this.title,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 10.0,
            percent: percentage / 100,
            animation: true,
            animationDuration: 800,
            backgroundColor: Theme.of(context).canvasColor,
            linearGradient: const LinearGradient(
              colors: [
                Color(0xFF00FF7F),
                Color(0xFFFFFF00),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).focusColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).focusColor,
            ),
          ),
        ],
      ),
    );
  }
}
