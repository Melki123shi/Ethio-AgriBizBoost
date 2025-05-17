import 'package:app/domain/dto/user_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:app/domain/entity/user_entity.dart';
import 'package:app/domain/dto/update_profile_dto.dart';
import 'package:app/domain/dto/update_password_dto.dart';
import 'package:app/domain/entity/update_profile_entity.dart';
import 'package:app/domain/entity/update_password_entity.dart';

class UserService {
  final Dio dio = DioClient.getDio();

  Future<UserEntity> getMe() async {
    try {
      final response = await dio.get('/auth/profile');
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

  Future<UpdateProfileEntity> updateUserProfile(
      UpdateProfileEntity input) async {
    try {
      final dto = UpdateProfileDTO.fromEntity(input);
      final res = await dio.patch('/auth/profile', data: dto.toJson());

      if (res.statusCode == 200) {
        final updated = (res.data['user'] ?? res.data) as Map<String, dynamic>;
        return UpdateProfileDTO.fromJson(updated).toEntity();
      }
      throw Exception('Failed to update profile: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> updatePassword(UpdatePasswordEntity input) async {
    try {
      final dto = UpdatePasswordDTO.fromEntity(input);
      final res = await dio.post('/auth/password', data: dto.toJson());

      if (res.statusCode == 200) return;

      throw Exception('Failed to update password: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}