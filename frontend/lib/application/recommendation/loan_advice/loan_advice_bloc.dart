import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/domain/entity/loan_advice_input_entity.dart';
import 'package:app/domain/entity/loan_advice_result_entity.dart';
import 'package:app/domain/dto/loan_advice_input_dto.dart';
import 'package:app/services/api/loan_advice_service.dart';
import 'loan_advice_event.dart';
import 'loan_advice_state.dart';

class LoanAdviceBloc extends Bloc<LoanAdviceEvent, LoanAdviceState> {
  final LoanAdviceService _loanAdviceService;

  LoanAdviceBloc(this._loanAdviceService) : super(LoanAdviceInitial()) {
    on<UpdateInputFieldEvent>(_onUpdateInputField);
    on<SubmitLoanAdviceEvent>(_onSubmitLoanAdvice);
  }

  LoanAdviceInputEntity _loanAdviceInputEntity = LoanAdviceInputEntity(
    cropType: '',
    governmentSubsidy: 0.0,
    salePricePerQuintal: 0.0,
    totalCost: 0.0,
    quantitySold: 0.0,
  );

  void _onUpdateInputField(UpdateInputFieldEvent event, Emitter<LoanAdviceState> emit) {
    _loanAdviceInputEntity = event.input;
    emit(LoanAdviceInputUpdated(_loanAdviceInputEntity));
  }

  Future<void> _onSubmitLoanAdvice(SubmitLoanAdviceEvent event, Emitter<LoanAdviceState> emit) async {
    emit(LoanAdviceLoading());
    try {
      final dto = LoanAdviceInputDto.fromEntity(event.input);
      final result = await _loanAdviceService.giveLoanAdvice(dto);
      final entityResult = LoanAdviceResultEntity.fromJson(result);
      emit(LoanAdviceSuccess(entityResult));
    } catch (_) {
      emit(LoanAdviceFailure());
    }
  }
}
