import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';

abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationSuccess extends RecommendationState {
  final RecommendationData recommendation;

  RecommendationSuccess({required this.recommendation});
}

class RecommendationFailure extends RecommendationState {
  final String errorMessage;

  RecommendationFailure({required this.errorMessage});
}
