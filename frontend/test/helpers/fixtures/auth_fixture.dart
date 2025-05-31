import 'package:app/domain/dto/login_dto.dart';
import 'package:app/domain/dto/signup_dto.dart';
import 'package:app/domain/entity/login_entity.dart';
import 'package:app/domain/entity/signup_entity.dart';

/// Test fixtures for authentication testing
class AuthFixture {
  // Login Entities
  static final validLoginRequestEntity = LoginRequestEntity(
    phoneNumber: '+251912345678',
    password: 'validPassword123',
  );

  static final invalidLoginRequestEntity = LoginRequestEntity(
    phoneNumber: 'invalid',
    password: '123',
  );

  static final validLoginResponseEntity = LoginResponseEntity(
    id: 'user123',
    accessToken: 'valid_access_token',
    refreshToken: 'valid_refresh_token',
    tokenType: 'Bearer',
  );

  // Login DTOs
  static final validLoginRequestDTO = LoginRequestDTO(
    phoneNumber: '+251912345678',
    password: 'validPassword123',
  );

  static final validLoginResponseDTO = LoginResponseDTO(
    accessToken: 'valid_access_token',
    refreshToken: 'valid_refresh_token',
    tokenType: 'Bearer',
  );

  // Signup Entities
  static final validSignupRequestEntity = SignupRequestEntity(
    phoneNumber: '+251912345678',
    password: 'validPassword123',
    name: 'John Doe',
    email: 'john@example.com',
  );

  static final validSignupResponseEntity = SignupResponseEntity(
    userId: 'user123',
    message: 'User created successfully',
  );

  // Signup DTOs
  static final validSignupRequestDTO = SignupRequestDTO(
    phoneNumber: '+251912345678',
    password: 'validPassword123',
    name: 'John Doe',
    email: 'john@example.com',
  );

  static final validSignupResponseDTO = SignupResponseDTO(
    userId: 'user123',
    message: 'User created successfully',
  );

  // API Response Maps
  static const Map<String, dynamic> validLoginResponseMap = {
    'access_token': 'valid_access_token',
    'refresh_token': 'valid_refresh_token',
    'token_type': 'Bearer',
  };

  static const Map<String, dynamic> validSignupResponseMap = {
    'user_id': 'user123',
    'message': 'User created successfully',
  };

  static const Map<String, dynamic> errorResponseMap = {
    'detail': 'Invalid credentials',
  };
}
