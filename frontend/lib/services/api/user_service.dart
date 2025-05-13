// import 'package:app/domain/dto/user_dto.dart';
// import 'package:app/services/network/dio_client.dart';
// import 'package:dio/dio.dart';
// import 'package:app/domain/entity/user_entity.dart';
// import 'package:app/domain/dto/update_profile_dto.dart';
// import 'package:app/domain/dto/update_password_dto.dart';
// import 'package:app/domain/entity/update_profile_entity.dart';
// import 'package:app/domain/entity/update_password_entity.dart';

// class UserService {
//   final Dio dio = DioClient.getDio();

//   Future<UserEntity> getMe() async {
//     try {
//       final response = await dio.get('/auth/profile');
//       if (response.statusCode == 200) {
//         final dto = UserDTO.fromJson(response.data);
//         return dto.toEntity();
//       } else {
//         throw Exception('Failed to fetch user: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Dio error: ${e.message}');
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<UpdateProfileEntity> updateUserProfile(
//       UpdateProfileEntity input) async {
//     try {
//       final dto = UpdateProfileDTO.fromEntity(input);
//       final res = await dio.patch('/auth/profile', data: dto.toJson());

//       if (res.statusCode == 200) {
//         final updated = (res.data['user'] ?? res.data) as Map<String, dynamic>;
//         return UpdateProfileDTO.fromJson(updated).toEntity();
//       }
//       throw Exception('Failed to update profile: ${res.statusCode}');
//     } on DioException catch (e) {
//       throw Exception('Dio error: ${e.message}');
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }

//   Future<void> updatePassword(UpdatePasswordEntity input) async {
//     try {
//       final dto = UpdatePasswordDTO.fromEntity(input);
//       final res = await dio.post('/auth/password', data: dto.toJson());

//       if (res.statusCode == 200) return;

//       throw Exception('Failed to update password: ${res.statusCode}');
//     } on DioException catch (e) {
//       throw Exception('Dio error: ${e.message}');
//     } catch (e) {
//       throw Exception('Unexpected error: $e');
//     }
//   }
// }

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:app/domain/dto/user_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:app/domain/entity/user_entity.dart';
import 'package:app/domain/dto/update_profile_dto.dart';
import 'package:app/domain/dto/update_password_dto.dart';
import 'package:app/domain/entity/update_profile_entity.dart';
import 'package:app/domain/entity/update_password_entity.dart';

class UserService {
  final Dio _dio = DioClient.getDio();

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded) as Map<String, dynamic>;
      final exp = map['exp'] as int?;
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  Future<bool> _tryRefresh() async {
    final refresh = await TokenStorage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final resp = await _dio.post('/auth/refresh', data: {
        'refreshToken': refresh,
      });
      if (resp.statusCode != 200) return false;
      final newAccess = resp.data['access_token'] as String?;
      final newRefresh = resp.data['refresh_token'] as String?;
      if (newAccess == null || newAccess.isEmpty) return false;
      await TokenStorage.saveAccessToken(newAccess);
      if (newRefresh != null) await TokenStorage.saveRefreshToken(newRefresh);
      _dio.options.headers['Authorization'] = 'Bearer $newAccess';
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserEntity> getMe() async {
    final token = await TokenStorage.readAccessToken();
    if (token == null) {
      throw Exception('No saved credentials');
    }

    if (_isTokenExpired(token)) {
      final refreshed = await _tryRefresh();
      if (!refreshed) {
        throw Exception('Session expired, please log in again');
      }
    }

    try {
      final response = await _dio.get('/auth/profile');
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
      final res = await _dio.patch('/auth/profile', data: dto.toJson());
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
      final res = await _dio.post('/auth/password', data: dto.toJson());
      if (res.statusCode == 200) return;
      throw Exception('Failed to update password: ${res.statusCode}');
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
