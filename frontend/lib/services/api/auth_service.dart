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
    final response = await dio.post('/auth/login', data: loginDTO.toJson());
    
    final userId = response.data['user_id'];
   if (userId == null || userId is! String)  {
      throw Exception('Invalid login response: user data missing.');
    }

     return UserEntity(
    id: userId,
  );
  }
}
