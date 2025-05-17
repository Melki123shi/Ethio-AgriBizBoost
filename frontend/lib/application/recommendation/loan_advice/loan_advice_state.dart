import 'package:app/domain/entity/loan_advice_input_entity.dart';
import 'package:app/domain/entity/loan_advice_result_entity.dart';

class LoanAdviceState {}

final class LoanAdviceInitial extends LoanAdviceState {}

final class LoanAdviceLoading extends LoanAdviceState {}

class LoanAdviceInputUpdated extends LoanAdviceState {
  final LoanAdviceInputEntity inputFields;

  LoanAdviceInputUpdated(this.inputFields);

  List<Object> get props => [inputFields];
}

class LoanAdviceSuccess extends LoanAdviceState {
  final LoanAdviceResultEntity loanAdviceResult;

  LoanAdviceSuccess(this.loanAdviceResult);
}

final class LoanAdviceFailure extends LoanAdviceState {}
