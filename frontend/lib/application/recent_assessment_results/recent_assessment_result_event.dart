class FetchRecentAssessmentsEvent extends HealthAssessmentEvent {}
on<FetchRecentAssessmentsEvent>(_onFetchRecentAssessments);

Future<void> _onFetchRecentAssessments(
    FetchRecentAssessmentsEvent event,
    Emitter<HealthAssessmentState> emit,
) async {
  emit(RecentAssessmentResultLoading());
  try {
    final result = await _healthAssessmentService.fetchRecentAssessmentResults();

    emit(RecentAssessmentResultState(
      averageFinancialStability: (result['averageFinancialStability'] as num).toDouble(),
      averageCashFlow: (result['averageCashFlow'] as num).toDouble(),
      recordsConsidered: result['recordsConsidered'] as int,
    ));
  } catch (e) {
    emit(RecentAssessmentResultFailure());
  }
}
class FetchRecentAssessmentsEvent extends HealthAssessmentEvent {}
on<FetchRecentAssessmentsEvent>(_onFetchRecentAssessments);

Future<void> _onFetchRecentAssessments(
    FetchRecentAssessmentsEvent event,
    Emitter<HealthAssessmentState> emit,
) async {
  emit(RecentAssessmentResultLoading());
  try {
    final result = await _healthAssessmentService.fetchRecentAssessmentResults();

    emit(RecentAssessmentResultState(
      averageFinancialStability: (result['averageFinancialStability'] as num).toDouble(),
      averageCashFlow: (result['averageCashFlow'] as num).toDouble(),
      recordsConsidered: result['recordsConsidered'] as int,
    ));
  } catch (e) {
    emit(RecentAssessmentResultFailure());
  }
}
