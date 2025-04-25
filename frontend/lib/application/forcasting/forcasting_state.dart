import 'package:app/domain/entity/forcasting_input_entity.dart';
import 'package:app/domain/entity/forcasting_result_entity.dart';

class ForcastingState {}

final class ForcastingInitial extends ForcastingState {}

final class ForcastingLoading extends ForcastingState {}

class ForcastingInputUpdated extends ForcastingState {
  final ForcastingInputEntity inputFields;

  ForcastingInputUpdated(this.inputFields);

  List<Object> get props => [inputFields];
}

class ForcastingSuccess extends ForcastingState {
  final ForcastingResultEntity forcastingResult;

  ForcastingSuccess(this.forcastingResult);
}

final class ForcastingFailure extends ForcastingState {}
