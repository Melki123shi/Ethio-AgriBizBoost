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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
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
                  titlesData: _buildTitles(),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _flatLine(totalIncome, Colors.yellow),
                    _flatLine(totalExpense, Colors.redAccent),
                    _flatLine(profit, Colors.greenAccent),
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
                _legend(Colors.yellow,  'Income'),
                _legend(Colors.redAccent, 'Expense'),
                _legend(Colors.greenAccent, 'Profit'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _flatLine(double value, Color color) =>
      LineChartBarData(
        spots: List.generate(
          _months.length,
          (i) => FlSpot(i.toDouble(), value),
        ),
        isCurved: false,
        color: color,
        barWidth: 2,                       
        isStrokeCapRound: true,
      );

  FlTitlesData _buildTitles() => FlTitlesData(
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
              _months[v.toInt() % _months.length],
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
