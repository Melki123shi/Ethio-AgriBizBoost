import 'package:app/ui/health_assessment/income_expense_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForcastingOutput extends StatelessWidget {
  const ForcastingOutput({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> priceValues = [180, 230, 70, 120, 320, 250];
    final List<double> demandValues = [220, 270, 60, 40, 220, 190];
    final months = ['Sept', 'Oct', 'Nov', 'Dec', 'Jua', 'Feb'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 34, 34, 34),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 150, 
                  child: BarChart(
                    BarChartData(
                      maxY: 350,
                      minY: 0,
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= months.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  months[index],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value % 100 == 0) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(color: Colors.white),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: List.generate(months.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barsSpace: 8,
                          barRods: [
                            BarChartRodData(
                              toY: priceValues[index],
                              color: Colors.yellow,
                              width: 10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            BarChartRodData(
                              toY: demandValues[index],
                              color: Colors.red,
                              width: 10,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        );
                      }),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        horizontalInterval: 100,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: Colors.white24,
                          strokeWidth: 1,
                        ),
                        drawVerticalLine: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: Colors.yellow, text: 'Price'),
                    SizedBox(width: 20),
                    _LegendItem(color: Colors.red, text: 'Demand'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const IncomeExpenseChart(totalIncome: 10, totalExpense: 8, profit: 2),
      ],
    );
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
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

