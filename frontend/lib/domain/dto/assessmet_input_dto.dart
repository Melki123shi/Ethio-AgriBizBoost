import 'package:app/domain/entity/assessment_input_entity.dart';

class AssessmentInputDTO {
  final String cropType;
  final double governmentSubsidy;
  final double salePricePerQuintal;
  final double totalCost;
  final double quantitySold;

  AssessmentInputDTO({
    required this.cropType,
    required this.governmentSubsidy,
    required this.salePricePerQuintal,
    required this.totalCost,
    required this.quantitySold,
  });

  factory AssessmentInputDTO.fromJson(Map<String, dynamic> json) {
    return AssessmentInputDTO(
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

  static AssessmentInputDTO fromEntity(AssessmentInputEntity entity) {
    return AssessmentInputDTO(
      cropType: entity.cropType,
      governmentSubsidy: entity.governmentSubsidy,
      salePricePerQuintal: entity.salePricePerQuintal,
      totalCost: entity.totalCost,
      quantitySold: entity.quantitySold,
    );
  }

  AssessmentInputEntity toEntity() {
    return AssessmentInputEntity(
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
