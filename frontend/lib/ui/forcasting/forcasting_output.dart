import 'package:app/domain/entity/forcasting_result_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForcastingOutput extends StatelessWidget {
 final ForcastingResultEntity result;

  const ForcastingOutput({
    super.key,
    required this.result,
  });

  static const List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
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
                    "Price & Demand Forecast",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: BarChart(
                      BarChartData(
                        maxY: _getMaxY(),
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= months.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    months[index],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 9),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) {
                                if (value % 1000 == 0) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: List.generate(months.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barsSpace: 6,
                            barRods: [
                              BarChartRodData(
                                toY: result.predictedMinPrice,
                                color: Colors.yellow.shade300,
                                width: 6,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              BarChartRodData(
                                toY: result.predictedMaxPrice,
                                color: Colors.orangeAccent,
                                width: 6,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          );
                        }),
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
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendItem(color: Colors.yellow, text: 'Min Price'),
                      SizedBox(width: 10),
                      _LegendItem(color: Colors.orangeAccent, text: 'Max Price'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Demand : ${result.predictedDemand}"),
                    ],
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
  final values = [
    result.predictedMinPrice,
    result.predictedMaxPrice,
  ];

  final maxVal = values.reduce((a, b) => a > b ? a : b);
  return (maxVal / 1000).ceil() * 1000 + 500;
}
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
