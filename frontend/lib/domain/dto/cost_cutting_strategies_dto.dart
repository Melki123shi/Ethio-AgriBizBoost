class FarmInput {
  final double farmSizeHectares;
  final String cropType;
  final String season;
  final double fertilizerExpenseETB;
  final double laborExpenseETB;
  final double pesticideExpenseETB;
  final double equipmentExpenseETB;
  final double transportationExpenseETB;
  final double seedExpenseETB;
  final double utilityExpenseETB;

  FarmInput({
    required this.farmSizeHectares,
    required this.cropType,
    required this.season,
    required this.fertilizerExpenseETB,
    required this.laborExpenseETB,
    required this.pesticideExpenseETB,
    required this.equipmentExpenseETB,
    required this.transportationExpenseETB,
    required this.seedExpenseETB,
    required this.utilityExpenseETB,
  });

  Map<String, dynamic> toJson() {
    return {
      'farm_size_hectares': farmSizeHectares,
      'crop_type': cropType,
      'season': season,
      'fertilizer_expense_ETB': fertilizerExpenseETB,
      'labor_expense_ETB': laborExpenseETB,
      'pesticide_expense_ETB': pesticideExpenseETB,
      'equipment_expense_ETB': equipmentExpenseETB,
      'transportation_expense_ETB': transportationExpenseETB,
      'seed_expense_ETB': seedExpenseETB,
      'utility_expense_ETB': utilityExpenseETB,
    };
  }
}

class RecommendationInput {
  final FarmInput farmInput;
  final String? language;

  RecommendationInput({
    required this.farmInput,
    this.language = "en",
  });

  Map<String, dynamic> toJson() {
    return {
      'farm_input': farmInput.toJson(),
      'language': language,
    };
  }
}

class RecommendationData {
  final String recommendation;

  RecommendationData({
    required this.recommendation,
  });

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    return RecommendationData(
      recommendation: json['recommendation'],
    );
  }
}

class RecommendationOutput {
  final bool success;
  final RecommendationData data;

  RecommendationOutput({
    required this.success,
    required this.data,
  });

  factory RecommendationOutput.fromJson(Map<String, dynamic> json) {
    return RecommendationOutput(
      success: json['success'],
      data: RecommendationData.fromJson(json['data']),
    );
  }
}
