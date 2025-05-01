import 'package:app/domain/dto/login_request_dto.dart';
import 'package:app/domain/dto/signup_request_dto.dart';
import 'package:app/services/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:app/domain/entity/user_entity.dart';

class AuthService {
  final Dio dio = DioClient.getDio();

  Future<UserEntity> signup(SignupRequestDTO signupDTO) async {
  final response = await dio.post('/auth/register', data: signupDTO.toJson());
  final userId = response.data['user_id'];

  if (userId == null || userId is! String) {
    throw Exception('Invalid signup response: user_id missing.');
  }

  return UserEntity(
    id: userId,
  );
}

  Future<UserEntity> login(LoginRequestDTO loginDTO) async {
  final response = await dio.post('/auth/login-with-json', data: loginDTO.toJson());

  final accessToken = response.data['access_token'];
  final refreshToken = response.data['refresh_token'];
  final tokenType = response.data['token_type'];

  if (accessToken == null || refreshToken == null || tokenType == null) {
    throw Exception('Invalid login response: token fields missing.');
  }

  return UserEntity(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType
  );
}
}
