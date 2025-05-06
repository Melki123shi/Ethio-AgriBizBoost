import 'package:app/domain/dto/user_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:app/domain/entity/user_entity.dart';

class UserService {
  final Dio dio = DioClient.getDio();

  Future<UserEntity> getMe() async {
    try {
      final response = await dio.get('/me'); 

      if (response.statusCode == 200) {
        final dto = UserDTO.fromJson(response.data);
        return dto.toEntity();
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserEntity> updateProfile(UserEntity updatedUser) async {
    try {
      final dto = UserDTO.fromEntity(updatedUser);
      final response = await dio.put('/me', data: dto.toJson()); 

      if (response.statusCode == 200) {
        return UserDTO.fromJson(response.data).toEntity();
      } else {
        throw Exception('Failed to update user');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
