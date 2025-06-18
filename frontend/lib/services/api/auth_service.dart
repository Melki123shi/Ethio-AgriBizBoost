import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:app/domain/entity/signup_entity.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:app/services/token_storage.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = DioClient.getDio();

  Future<SignupResponseEntity> signup(SignupRequestDTO dto) async {
    try {
      final res = await dio.post('/auth/register', data: dto.toJson());

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception(_msg(res.data, res.statusCode));
      }

      final id = res.data['user_id'];
      if (id is! String || id.isEmpty) {
        throw Exception(
            _msg(res.data, res.statusCode, fallback: 'Missing user_id'));
      }

      return SignupResponseEntity(userId: id);
    } on DioException catch (e) {
      throw Exception(_msg(e.response?.data, e.response?.statusCode));
    }
  }

  Future<LoginResponseEntity> login(LoginRequestDTO dto) async {
    try {
      final res = await dio.post('/auth/login-with-json', data: dto.toJson());

      if (res.statusCode != 200) {
        throw Exception(_msg(res.data, res.statusCode));
      }

      final a = res.data['access_token'];
      final r = res.data['refresh_token'];
      final t = res.data['token_type'];
      if ([a, r, t].contains(null)) {
        throw Exception(_msg(res.data, res.statusCode,
            fallback: 'Malformed login response'));
      }

      await _writeTokens(a, r, t);
      return LoginResponseEntity(accessToken: a, refreshToken: r, tokenType: t);
    } on DioException catch (e) {
      throw Exception(_msg(e.response?.data, e.response?.statusCode));
    }
  }

  Future<bool> refresh() async {
    final refreshToken = await TokenStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await dio
          .post('/auth/refresh', data: {'refresh_token': refreshToken});

      if (res.statusCode != 200) return false;

      final newAccess = res.data['access_token'] as String?;
      final newRefresh = res.data['refresh_token'] as String? ?? refreshToken;
      final type = res.data['token_type'] as String? ?? 'Bearer';

      if (newAccess == null || newAccess.isEmpty) return false;

      await _writeTokens(newAccess, newRefresh, type);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<LoginResponseEntity?> tryAutoLogin() async {
    try {
      // Try to get user profile to verify token is valid
      // This will automatically trigger refresh if needed via interceptor
      final res = await dio.get('/auth/profile');

      if (res.statusCode == 200) {
        // Token is valid (either directly or after refresh)
        final access = await TokenStorage.readAccessToken();
        final refresh = await TokenStorage.readRefreshToken();
        final type = await TokenStorage.readTokenType();

        if (access != null && refresh != null) {
          return LoginResponseEntity(
            accessToken: access,
            refreshToken: refresh,
            tokenType: type ?? 'Bearer',
          );
        }
      }
    } on DioException catch (e) {
      // If we get a 401 and refresh also failed, clear tokens
      if (e.response?.statusCode == 401) {
        await TokenStorage.clearAccessToken();
        await TokenStorage.clearRefreshToken();
        await TokenStorage.clearTokenType();
      }
    } catch (_) {
      // Any other error
    }
    return null;
  }

  Future<void> logout() async {
    final refresh = await TokenStorage.readRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await dio.post('/auth/logout', data: {'refresh_token': refresh});
      } catch (_) {}
    }
    // Clear all tokens
    await TokenStorage.clearAccessToken();
    await TokenStorage.clearRefreshToken();
    await TokenStorage.clearTokenType();
  }

  Future<void> _writeTokens(String access, String refresh, String type) async {
    await TokenStorage.saveAccessToken(access);
    await TokenStorage.saveRefreshToken(refresh);
    await TokenStorage.saveTokenType(type);
  }

  String _msg(dynamic data, int? code, {String fallback = 'Unknown error'}) {
    if (data is Map && data['detail'] != null) return data['detail'];
    if (data is String && data.isNotEmpty) return data;
    return '$fallback (status $code)';
  }
}
