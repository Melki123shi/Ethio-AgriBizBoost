class ForcastingResultEntity {
  final String predictedDemand;
  final double predictedMinPrice;
  final double predictedMaxPrice;

  ForcastingResultEntity({
    required this.predictedDemand,
    required this.predictedMinPrice,
    required this.predictedMaxPrice,
  });

  factory ForcastingResultEntity.fromJson(Map<String, dynamic> json) {
    return ForcastingResultEntity(
      predictedDemand: json['Predicted Demand'] ?? '',
      predictedMinPrice: (json['Predicted Min Price'] ?? 0.0).toDouble(),
      predictedMaxPrice: (json['Predicted Max Price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Predicted Demand': predictedDemand,
      'Predicted Min Price': predictedMinPrice,
      'Predicted Max Price': predictedMaxPrice,
    };
  }
}
