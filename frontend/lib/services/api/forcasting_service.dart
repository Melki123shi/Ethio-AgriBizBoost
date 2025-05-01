import 'package:app/domain/dto/forcasting_input_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';

class ForcastingService {
  final Dio dio = DioClient.getDio();

  Future<Map<String, dynamic>> calculateForcasting(
      ForcastingInputDTO forcastingInputDTO) async {
    final requestData = forcastingInputDTO.toJson();
    try {
      final response = await dio.post('/predict', data: requestData);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Unexpected response format: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch predicted data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}
