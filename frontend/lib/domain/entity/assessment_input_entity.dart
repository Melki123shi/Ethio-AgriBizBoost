class AssessmentInputEntity {
  final String cropType;
  final double governmentSubsidy;
  final double salePricePerQuintal;
  final double totalCost;
  final double quantitySold;

  AssessmentInputEntity({
    required this.cropType,
    required this.governmentSubsidy,
    required this.salePricePerQuintal,
    required this.totalCost,
    required this.quantitySold,
  });

  static AssessmentInputEntity fromUserInput({
    required String cropType,
    required double governmentSubsidy,
    required double salePricePerQuintal,
    required double totalCost,
    required double quantitySold,
  }) {
    return AssessmentInputEntity(
        cropType: cropType,
        governmentSubsidy: governmentSubsidy,
        salePricePerQuintal: salePricePerQuintal,
        totalCost: totalCost,
        quantitySold: quantitySold);
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
}
