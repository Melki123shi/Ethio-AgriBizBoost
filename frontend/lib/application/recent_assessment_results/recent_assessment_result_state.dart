import 'package:app/domain/entity/recent_assessment_results_entity.dart';
import 'package:equatable/equatable.dart';

abstract class RecentAssessmentState extends Equatable {
  const RecentAssessmentState();

  @override
  List<Object> get props => [];
}

class RecentAssessmentInitial extends RecentAssessmentState {}

class RecentAssessmentLoading extends RecentAssessmentState {}

class RecentAssessmentSuccess extends RecentAssessmentState {
  final RecentAssessmentAveragesEntity averages;

  const RecentAssessmentSuccess(this.averages);

  @override
  List<Object> get props => [averages];
}

class RecentAssessmentFailure extends RecentAssessmentState {
  final String error;

  const RecentAssessmentFailure(this.error);

  @override
  List<Object> get props => [error];
}