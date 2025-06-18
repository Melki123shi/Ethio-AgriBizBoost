import 'package:app/application/recommendation/cost_cutting_strategies/cost_cutting_strategies_event.dart';
import 'package:app/application/recommendation/cost_cutting_strategies/cost_cutting_strategies_state.dart';
import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';
import 'package:app/services/api/cost_cutting_recommendation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  final RecommendationService _recommendationService;

  RecommendationBloc({required RecommendationService recommendationService})
      : _recommendationService = recommendationService,
        super(RecommendationInitial()) {
    on<GetRecommendationEvent>(_onGetRecommendationEvent);
  }

  Future<void> _onGetRecommendationEvent(
      GetRecommendationEvent event, Emitter<RecommendationState> emit) async {
    emit(RecommendationLoading());
    try {
      final RecommendationOutput result =
          await _recommendationService.getRecommendation(event.farmInput, event.language);
      emit(RecommendationSuccess(recommendation: result.data));
    } catch (e) {
      emit(RecommendationFailure(errorMessage: e.toString()));
    }
  }
}

