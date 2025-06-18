import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';

abstract class RecommendationEvent {}

class GetRecommendationEvent extends RecommendationEvent {
  final FarmInput farmInput;
  final String? language;

  GetRecommendationEvent({required this.farmInput, this.language});
}
