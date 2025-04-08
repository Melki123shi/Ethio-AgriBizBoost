import 'package:app/domain/entity/assessment_result_entity.dart';

class AssessmentResultDTO {
  final double financialStability;
  final double cashFlow;
  final double totalIncome;
  final double profit;
  final double totalExpense;

  AssessmentResultDTO({
    required this.financialStability,
    required this.cashFlow,
    required this.totalIncome,
    required this.profit,
    required this.totalExpense,
  });

  factory AssessmentResultDTO.fromJson(Map<String, dynamic> json) {
    return AssessmentResultDTO(
      financialStability: _toDouble(json['financialStability']),
      cashFlow: _toDouble(json['cashFlow']),
      totalIncome: _toDouble(json['totalIncome']),
      profit: _toDouble(json['profit']),
      totalExpense: _toDouble(json['totalExpense']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'financialStability': financialStability,
      'cashFlow': cashFlow,
      'totalIncome': totalIncome,
      'profit': profit,
      'totalExpense': totalExpense,
    };
  }

  AssessmentResultEntity toEntity() {
    return AssessmentResultEntity(
      financialStability: financialStability,
      cashFlow: cashFlow,
      totalIncome: totalIncome,
      profit: profit,
      totalExpense: totalExpense,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
