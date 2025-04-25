import 'package:app/domain/entity/assessment_input_entity.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';

class HealthAssessmentState {}

final class HealthAssessmentInitial extends HealthAssessmentState {}

final class HealthAssessmentLoading extends HealthAssessmentState {}

class HealthAssessmentInputUpdated extends HealthAssessmentState {
  final AssessmentInputEntity inputFields;

  HealthAssessmentInputUpdated(this.inputFields);

  List<Object> get props => [inputFields];
}

class HealthAssessmentSuccess extends HealthAssessmentState {
  final AssessmentResultEntity assessmentResult;

  HealthAssessmentSuccess(this.assessmentResult);
}

final class HealthAssessmentFailure extends HealthAssessmentState {}
