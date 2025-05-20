class LoanAdviceResultEntity {
  final String recommendation;

  LoanAdviceResultEntity({required this.recommendation});

  factory LoanAdviceResultEntity.fromJson(Map<String, dynamic> json) {
    return LoanAdviceResultEntity(
      recommendation: json['recommendation']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
    };
  }
}
