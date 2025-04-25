import 'package:app/application/health_assessment/health_assessment_event.dart';
import 'package:app/application/health_assessment/health_assessment_state.dart';
import 'package:app/domain/dto/assessmet_input_dto.dart';
import 'package:app/domain/entity/assessment_input_entity.dart';
import 'package:app/domain/entity/assessment_result_entity.dart';
import 'package:app/services/api/health_assessment_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthAssessmentBloc
    extends Bloc<HealthAssessmentEvent, HealthAssessmentState> {
  final HealthAssessmentService _healthAssessmentService;
  AssessmentInputEntity _assessmentInputEntity = AssessmentInputEntity(
    cropType: '',
    governmentSubsidy: 0.0,
    salePricePerQuintal: 0.0,
    totalCost: 0.0,
    quantitySold: 0.0,
  );

  HealthAssessmentBloc(this._healthAssessmentService)
      : super(HealthAssessmentInitial()) {
    on<UpdateInputFieldEvent>(_onUpdateInputField);
    on<SubmitHealthAssessmentEvent>(_onSubmitAssessment);
  }
  void _onUpdateInputField(
      UpdateInputFieldEvent event, Emitter<HealthAssessmentState> emit) {
    _assessmentInputEntity = AssessmentInputEntity(
      cropType: event.cropType,
      governmentSubsidy: event.governmentSubsidy,
      salePricePerQuintal: event.salePricePerQuintal,
      totalCost: event.totalCost,
      quantitySold: event.quantitySold,
    );

    emit(HealthAssessmentInputUpdated(_assessmentInputEntity));
  }

  Future<void> _onSubmitAssessment(SubmitHealthAssessmentEvent event,
      Emitter<HealthAssessmentState> emit) async {
    emit(HealthAssessmentLoading());
    try {
      final entity = AssessmentInputEntity.fromUserInput(
          cropType: event.cropType,
          governmentSubsidy: event.governmentSubsidy,
          salePricePerQuintal: event.salePricePerQuintal,
          totalCost: event.totalCost,
          quantitySold: event.quantitySold);
      final dto = AssessmentInputDTO.fromEntity(entity);
      final result =
          await _healthAssessmentService.calculateHealthAssessment(dto);

      final assessmentResult = AssessmentResultEntity(
        totalIncome: (result['totalIncome'] as num).toDouble(),
        profit: (result['profit'] as num).toDouble(),
        financialStability: (result['financialStability'] as num).toDouble(),
        cashFlow: (result['cashFlow'] as num).toDouble(),
        totalExpense: (result['totalExpense'] as num).toDouble(),
      );

      emit(HealthAssessmentSuccess(assessmentResult));
    } catch (e) {
      emit(HealthAssessmentFailure());
    }
  }
}
