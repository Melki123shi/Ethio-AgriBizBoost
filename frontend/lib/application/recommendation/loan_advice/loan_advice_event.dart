import 'package:app/domain/entity/loan_advice_input_entity.dart';

class LoanAdviceEvent {}

class UpdateInputFieldEvent extends LoanAdviceEvent {
  final LoanAdviceInputEntity input;

  UpdateInputFieldEvent(this.input);

  List<Object> get props => [
        input.cropType,
        input.governmentSubsidy,
        input.salePricePerQuintal,
        input.totalCost,
        input.quantitySold,
      ];
}

class SubmitLoanAdviceEvent extends LoanAdviceEvent {
  final LoanAdviceInputEntity input;

  SubmitLoanAdviceEvent(this.input);
}
