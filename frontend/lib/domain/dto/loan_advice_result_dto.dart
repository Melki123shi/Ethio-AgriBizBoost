import 'package:app/domain/entity/loan_advice_result_entity.dart';

class LoanAdviceResultDto {
  final String recommendation;

  LoanAdviceResultDto({required this.recommendation});

  factory LoanAdviceResultDto.fromJson(Map<String, dynamic> json) {
    return LoanAdviceResultDto(
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
    };
  }

  LoanAdviceResultEntity toEntity() {
    return LoanAdviceResultEntity(recommendation: recommendation);
  }
}
