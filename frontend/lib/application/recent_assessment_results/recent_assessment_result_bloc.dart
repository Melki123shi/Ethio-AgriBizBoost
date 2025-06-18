import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/health_assessment/health_assessment_event.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/services/network/health_assessment_service.dart';

class RecentAssessmentBloc extends Bloc<HealthAssessmentEvent, HealthAssessmentState> {
  final HealthAssessmentService _healthAssessmentService;

  RecentAssessmentBloc(this._healthAssessmentService) : super(RecentAssessmentResultLoading()) {
    on<FetchRecentAssessmentsEvent>(_onFetchRecentAssessments);
  }

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
}
