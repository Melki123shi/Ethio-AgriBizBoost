import 'package:flutter/material.dart';

class LoanAdviceMockData extends StatelessWidget {
  const LoanAdviceMockData({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 18, 18, 18), 
        borderRadius: BorderRadius.circular(10), 
      ),
      child: Text(
        "Farming Cost Reduction Tips:\n\n"
        "Use Organic Compost** Reduce fertilizer costs by making compost from farm waste instead of buying chemical fertilizers.\n"
        "Practice Crop Rotation** Prevent soil depletion and minimize pest issues, reducing the need for expensive pesticides.\n"
        "Invest in Drip Irrigation** Save water and cut electricity costs by using efficient irrigation methods instead of flood irrigation.\n"
        "Buy Seeds in Bulk** Purchase high-quality seeds in bulk at the start of the season to get discounts and avoid mid-season price hikes.\n"
        "Utilize Government Subsidies** Take advantage of agricultural grants, low-interest loans, and subsidies to reduce input costs.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8), 
        ),
      ),
    );
  }
}
