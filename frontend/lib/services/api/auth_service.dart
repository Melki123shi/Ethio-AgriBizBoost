import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:app/domain/entity/signup_entity.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio dio = DioClient.getDio();
  final _storage = const FlutterSecureStorage();

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
    final refreshToken = await _storage.read(key: 'refresh');
    if (refreshToken == null) return false;

    try {
      final res =
          await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});

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
    final a = await _storage.read(key: 'access');
    final r = await _storage.read(key: 'refresh');
    final t = await _storage.read(key: 'type');
    if ([a, r, t].every((e) => e != null)) {
      return LoginResponseEntity(
          accessToken: a!, refreshToken: r!, tokenType: t!);
    }
    return null;
  }

  Future<void> logout() async {
    final refresh = await _storage.read(key: 'refresh');
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await dio.post('/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {/* ignore */}
    }
    await _storage.deleteAll();
  }

  Future<void> _writeTokens(String access, String refresh, String type) async {
    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);
    await _storage.write(key: 'type', value: type);
  }

  String _msg(dynamic data, int? code, {String fallback = 'Unknown error'}) {
    if (data is Map && data['detail'] != null) return data['detail'];
    if (data is String && data.isNotEmpty) return data;
    return '$fallback (status $code)';
  }
}
