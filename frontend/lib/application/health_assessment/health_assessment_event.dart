class HealthAssessmentEvent {}

class UpdateInputFieldEvent extends HealthAssessmentEvent {
  final String cropType;
  final double governmentSubsidy;
  final double salePricePerQuintal;
  final double totalCost;
  final double quantitySold;

  UpdateInputFieldEvent(this.cropType, this.governmentSubsidy,
      this.salePricePerQuintal, this.totalCost, this.quantitySold);

  List<Object> get props => [
        cropType,
        governmentSubsidy,
        salePricePerQuintal,
        totalCost,
        quantitySold
      ];
}

class SubmitHealthAssessmentEvent extends HealthAssessmentEvent {
  final String cropType;
  final double governmentSubsidy;
  final double salePricePerQuintal;
  final double totalCost;
  final double quantitySold;

  SubmitHealthAssessmentEvent(
      {required this.cropType,
      required this.governmentSubsidy,
      required this.salePricePerQuintal,
      required this.totalCost,
      required this.quantitySold});
}
