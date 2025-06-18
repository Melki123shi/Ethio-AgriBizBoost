import 'package:app/domain/dto/cost_cutting_strategies_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart'; 

class RecommendationService {
  final Dio _dio = DioClient.getDio();
  
  Future<RecommendationOutput> getRecommendation(
      FarmInput farmInput, String? language) async {
    final recommendationInput = RecommendationInput(
      farmInput: farmInput,
      language: language,
    );

    try {
      final response = await _dio.post(
        '/recommend',
        data: recommendationInput.toJson(),
      );

      if (response.statusCode == 200) {
        return RecommendationOutput.fromJson(response.data as Map<String, dynamic>);
      } else {
        final String errorMessage = response.data?['detail'] ?? 'Failed to load recommendation';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final String errorMessage = e.response!.data?['detail'] ?? 'Server error occurred: ${e.response!.statusCode}';
        throw Exception(errorMessage); 
      } else {
        throw Exception('Network error: ${e.message ?? 'No response received.'}'); 
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e'); 
    }
  }
}
