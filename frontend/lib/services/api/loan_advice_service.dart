import 'package:app/domain/dto/loan_advice_input_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';

class LoanAdviceService {
  final Dio dio = DioClient.getDio();

  Future<Map<String, dynamic>> giveLoanAdvice(
      LoanAdviceInputDto loanAdviceInputDTO) async {
    try {
      final response = await dio.post('/loan_advice',
          data: loanAdviceInputDTO);
      return response.data as Map<String, dynamic>;
    } on DioException {
      throw Exception('Failed to fetch loan advice');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}
