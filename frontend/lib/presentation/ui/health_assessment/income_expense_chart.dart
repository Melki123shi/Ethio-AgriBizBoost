import 'package:app/presentation/utils/localization_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeExpenseChart extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double profit;

  const IncomeExpenseChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      context.commonLocals.jan,
      context.commonLocals.feb,
      context.commonLocals.mar,
      context.commonLocals.apr,
      context.commonLocals.may,
      context.commonLocals.jun,
      context.commonLocals.jul,
      context.commonLocals.aug,
      context.commonLocals.sep,
      context.commonLocals.oct,
      context.commonLocals.nov,
      context.commonLocals.dec,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: _buildTitles(months),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _flatLine(months.length, totalIncome, Colors.yellow),
                    _flatLine(months.length, totalExpense, Colors.redAccent),
                    _flatLine(months.length, profit, Colors.greenAccent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                _legend(Colors.yellow, context.commonLocals.income),
                _legend(Colors.redAccent, context.commonLocals.expense),
                _legend(Colors.greenAccent, context.commonLocals.profit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _flatLine(int count, double value, Color color) =>
      LineChartBarData(
        spots: List.generate(
          count,
          (i) => FlSpot(i.toDouble(), value),
        ),
        isCurved: false,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
      );

  FlTitlesData _buildTitles(List<String> months) => FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 16,
            interval: 1,
            getTitlesWidget: (v, _) => Text(
              months[v.toInt() % months.length],
              style: const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
        ),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      );

  Widget _legend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      );
}
