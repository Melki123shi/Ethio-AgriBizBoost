class RecentAssessmentResultState extends HealthAssessmentState {
  final double averageFinancialStability;
  final double averageCashFlow;
  final int recordsConsidered;

  RecentAssessmentResultState({
    required this.averageFinancialStability,
    required this.averageCashFlow,
    required this.recordsConsidered,
  });
}

final class RecentAssessmentResultLoading extends HealthAssessmentState {}

final class RecentAssessmentResultFailure extends HealthAssessmentState {}
