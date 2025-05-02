import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForcastingOutput extends StatelessWidget {
  final ForcastingResultEntity result;

  const ForcastingOutput({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final maxY = _getMaxY();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 34, 34, 34),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Price Forecast",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: BarChart(
                      BarChartData(
                        maxY: maxY,
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Min Price',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10));
                                  case 1:
                                    return const Text('Max Price',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10));
                                  default:
                                    return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, _) => Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(
                              toY: result.predictedMinPrice,
                              color: Colors.yellow.shade300,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                              toY: result.predictedMaxPrice,
                              color: Colors.orangeAccent,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ]),
                        ],
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 1000,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Colors.white24,
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Demand : ${result.predictedDemand}",
                    style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY() {
    final maxVal = [
      result.predictedMinPrice,
      result.predictedMaxPrice,
    ].reduce((a, b) => a > b ? a : b);
    return (maxVal / 1000).ceil() * 1000 + 500;
  }
}
