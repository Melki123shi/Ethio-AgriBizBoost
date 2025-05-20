
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

  factory LoanAdviceInputDto.fromJson(Map<String, dynamic> json) {
    return LoanAdviceInputDto(
      cropType: json['cropType'] ?? '',
      governmentSubsidy: _toDouble(json['governmentSubsidy']),
      salePricePerQuintal: _toDouble(json['salePricePerQuintal']),
      totalCost: _toDouble(json['totalCost']),
      quantitySold: _toDouble(json['quantitySold']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'governmentSubsidy': governmentSubsidy,
      'salePricePerQuintal': salePricePerQuintal,
      'totalCost': totalCost,
      'quantitySold': quantitySold,
    };
  }

  static LoanAdviceInputDto fromEntity(LoanAdviceInputEntity entity) {
    return LoanAdviceInputDto(
      cropType: entity.cropType,
      governmentSubsidy: entity.governmentSubsidy,
      salePricePerQuintal: entity.salePricePerQuintal,
      totalCost: entity.totalCost,
      quantitySold: entity.quantitySold,
    );
  }

  LoanAdviceInputEntity toEntity() {
    return LoanAdviceInputEntity(
      cropType: cropType,
      governmentSubsidy: governmentSubsidy,
      salePricePerQuintal: salePricePerQuintal,
      totalCost: totalCost,
      quantitySold: quantitySold,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
