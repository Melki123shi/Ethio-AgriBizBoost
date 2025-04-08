class AssessmentResultEntity {
  final double financialStability;
  final double cashFlow;
  final double totalIncome;
  final double profit;
  final double totalExpense;

  AssessmentResultEntity(
      {required this.financialStability,
      required this.cashFlow,
      required this.totalIncome,
      required this.profit,
      required this.totalExpense});

  Map<String, dynamic> toJson() {
    return {
      'financialStability': financialStability,
      'cashFlow': cashFlow,
      'totalIncome': totalIncome,
      'profit': profit,
      'totalExpense': totalExpense,
    };
  }
}
