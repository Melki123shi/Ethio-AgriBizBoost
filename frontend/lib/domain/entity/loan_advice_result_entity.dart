class LoanAdviceResultEntity {
  final String loanAdviceRecommendation;

  LoanAdviceResultEntity({required this.loanAdviceRecommendation});

  factory LoanAdviceResultEntity.fromJson(Map<String, dynamic> json) {
    return LoanAdviceResultEntity(
      loanAdviceRecommendation: json['loanAdviceRecommendation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanAdviceRecommendation': loanAdviceRecommendation,
    };
  }
}
