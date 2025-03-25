import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthAssessmentOutput extends StatelessWidget {
  const HealthAssessmentOutput({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            AssessmentCard(title: "Financial Stability", percentage: 67),
            SizedBox(width: 15), 
            AssessmentCard(title: "Cash Flow", percentage: 43),
          ],
        ),
        SizedBox(height: 20), 
        IncomeExpenseChart(),
      ],
    );
  }
}

class AssessmentCard extends StatelessWidget {
  final String title;
  final int percentage;

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
            percent: percentage / 100,
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


class IncomeExpenseChart extends StatelessWidget {
  const IncomeExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 34, 34, 34), 
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0), 
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          const months = ["Sept", "Oct", "Nov", "Dec", "Jan", "Feb"];
                          return Text(
                            months[value.toInt() % months.length],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 100),
                        const FlSpot(1, 120),
                        const FlSpot(2, 200),
                        const FlSpot(3, 250),
                        const FlSpot(4, 320),
                        const FlSpot(5, 300),
                      ],
                      isCurved: true,
                      color: Colors.yellow,
                      barWidth: 3,
                      isStrokeCapRound: true,
                    ),
      
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 90),
                        const FlSpot(1, 110),
                        const FlSpot(2, 180),
                        const FlSpot(3, 240),
                        const FlSpot(4, 310),
                        const FlSpot(5, 290),
                      ],
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                    ),
      
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 20),
                        const FlSpot(1, 30),
                        const FlSpot(2, 60),
                        const FlSpot(3, 90),
                        const FlSpot(4, 120),
                        const FlSpot(5, 110),
                      ],
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
      
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendDot(Colors.yellow, "Total Income"),
                const SizedBox(width: 10),
                _buildLegendDot(Colors.redAccent, "Total Expense"),
                const SizedBox(width: 10),
                _buildLegendDot(Colors.greenAccent, "Profit"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

