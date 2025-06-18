import 'package:app/application/recent_assessment_results/recent_assessment_result_event.dart';
import 'package:app/application/recent_assessment_results/recent_assessment_result_state.dart';
import 'package:app/domain/entity/recent_assessment_results_entity.dart';
import 'package:app/services/api/health_assessment_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentAssessmentBloc extends Bloc<RecentAssessmentEvent, RecentAssessmentState> {
  final HealthAssessmentService _healthAssessmentService;

  RecentAssessmentBloc(this._healthAssessmentService) : super(RecentAssessmentInitial()) {
    on<FetchRecentAverages>(_onFetchRecentAverages);
  }

  Future<void> _onFetchRecentAverages(
    FetchRecentAverages event,
    Emitter<RecentAssessmentState> emit,
  ) async {
    emit(RecentAssessmentLoading());
    try {
      final Map<String, dynamic> result = await _healthAssessmentService.fetchRecentAssessmentResults();

      if (result.containsKey('message')) {
        final noDataEntity = RecentAssessmentAveragesEntity.empty();
        emit(RecentAssessmentSuccess(noDataEntity));
      } else {
        final averagesEntity = RecentAssessmentAveragesEntity.fromJson(result);
        emit(RecentAssessmentSuccess(averagesEntity));
      }

    } catch (e) {
      emit(RecentAssessmentFailure(e.toString()));
    }
  }
}