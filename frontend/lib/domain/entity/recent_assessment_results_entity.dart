import 'package:equatable/equatable.dart';

class RecentAssessmentAveragesEntity extends Equatable {
  final double averageFinancialStability;
  final double averageCashFlow;
  final int recordsConsidered;

  const RecentAssessmentAveragesEntity({
    required this.averageFinancialStability,
    required this.averageCashFlow,
    required this.recordsConsidered,
  });

  factory RecentAssessmentAveragesEntity.fromJson(Map<String, dynamic> json) {
    return RecentAssessmentAveragesEntity(
      averageFinancialStability: (json['averageFinancialStability'] as num).toDouble(),
      averageCashFlow: (json['averageCashFlow'] as num).toDouble(),
      recordsConsidered: json['recordsConsidered'] as int,
    );
  }

  factory RecentAssessmentAveragesEntity.empty() {
    return const RecentAssessmentAveragesEntity(
      averageFinancialStability: 0.0,
      averageCashFlow: 0.0,
      recordsConsidered: 0,
    );
  }

  @override
  List<Object?> get props => [averageFinancialStability, averageCashFlow, recordsConsidered];
}