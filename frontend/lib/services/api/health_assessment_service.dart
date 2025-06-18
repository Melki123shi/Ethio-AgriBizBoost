import 'package:app/domain/dto/assessmet_input_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';

class HealthAssessmentService {
  final Dio dio = DioClient.getDio();

  Future<Map<String, dynamic>> calculateHealthAssessment(
      AssessmentInputDTO assessmentInputDTO) async {
    try {
      final response = await dio.post('/health_assessment',
          data: assessmentInputDTO.toJson());
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to fetch health assessment data: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<Map<String, dynamic>> fetchRecentAssessmentResults() async {
  try {
    final response = await dio.get('/assessment-result-recents');
    return response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    throw Exception('Failed to fetch recent assessment data: ${e.message}');
  } catch (e) {
    throw Exception('An unexpected error occurred');
  }
}
}
