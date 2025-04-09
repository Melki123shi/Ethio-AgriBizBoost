import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final double percentage;

  const AssessmentCard({
    super.key, 
    required this.title, 
    required this.percentage
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 160,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 34, 34, 34), 
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            // percent: percentage / 100,
            center: Text(
              "$percentage%",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            progressColor: Colors.greenAccent,
            backgroundColor: const Color.fromARGB(255, 169, 255, 88),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}