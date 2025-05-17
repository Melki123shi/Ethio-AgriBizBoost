import 'package:app/domain/entity/loan_advice_input_entity.dart';

class LoanAdviceInputDto {
  final String cropType;
  final double governmentSubsidy;
  final double salePricePerQuintal;
  final double totalCost;
  final double quantitySold;

  LoanAdviceInputDto({
    required this.cropType,
    required this.governmentSubsidy,
    required this.salePricePerQuintal,
    required this.totalCost,
    required this.quantitySold,
  });

  factory LoanAdviceInputDto.fromEntity(LoanAdviceInputEntity entity) {
    return LoanAdviceInputDto(
      cropType: entity.cropType,
      governmentSubsidy: entity.governmentSubsidy,
      salePricePerQuintal: entity.salePricePerQuintal,
      totalCost: entity.totalCost,
      quantitySold: entity.quantitySold,
    );
  }
}

